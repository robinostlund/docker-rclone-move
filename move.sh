#!/bin/sh

set -e

echo "INFO: Starting move.sh pid $$ $(date)"

if [ `lsof | grep $0 | wc -l | tr -d ' '` -gt 1 ]
then
  echo "WARNING: A previous move is still running. Skipping new move command."
else

echo $$ > /tmp/move.pid

if test "$(rclone ls $MOVE_SRC $RCLONE_OPTS)"; then
  # the source directory is not empty
  # it can be moved without clear data loss
  echo "INFO: Starting rclone move $MOVE_SRC $MOVE_DEST $RCLONE_OPTS $MOVE_OPTS"
  rclone move $MOVE_SRC $MOVE_DEST $RCLONE_OPTS $MOVE_OPTS

  if [ -z "$CHECK_URL" ]
  then
    echo "INFO: Define CHECK_URL with https://healthchecks.io to monitor move job"
  else
    wget $CHECK_URL -O /dev/null
  fi
else
  echo "WARNING: Source directory is empty. Skipping move command."
fi

rm -f /tmp/move.pid

fi
