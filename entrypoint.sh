#!/bin/sh

set -e

if [ ! -z "$TZ" ]
then
  cp /usr/share/zoneinfo/$TZ /etc/localtime
  echo $TZ > /etc/timezone
fi

rm -f /tmp/move.pid

if [ -z "$MOVE_SRC" ] || [ -z "$MOVE_DEST" ]
then
  echo "INFO: No MOVE_SRC and MOVE_DEST found. Starting rclone config"
  rclone config $RCLONE_OPTS
  echo "INFO: Define MOVE_SRC and MOVE_DEST to start move process."
else
  # MOVE_SRC and MOVE_DEST setup
  # run move either once or in cron depending on CRON
  if [ -z "$CRON" ]
  then
    echo "INFO: No CRON setting found. Running move once."
    echo "INFO: Add CRON=\"0 0 * * *\" to perform move every midnight"
    /move.sh
  else
    if [ -z "$FORCE_MOVE" ]
    then
      echo "INFO: Add FORCE_MOVE=1 to perform a move upon boot"
    else
      /move.sh
    fi

    # Setup cron schedule
    crontab -d
    echo "$CRON /move.sh >>/tmp/move.log 2>&1" > /tmp/crontab.tmp
    if [ -z "$CRON_ABORT" ]
    then
      echo "INFO: Add CRON_ABORT=\"0 6 * * *\" to cancel outstanding move at 6am"
    else
      echo "$CRON_ABORT /move-abort.sh >>/tmp/move.log 2>&1" >> /tmp/crontab.tmp
    fi
    crontab /tmp/crontab.tmp
    rm /tmp/crontab.tmp

    # Start cron
    echo "INFO: Starting crond ..."
    touch /tmp/move.log
    touch /tmp/crond.log
    crond -b -l 0 -L /tmp/crond.log
    echo "INFO: crond started"
    tail -F /tmp/crond.log /tmp/move.log
  fi
fi

