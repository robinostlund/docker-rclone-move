#!/bin/sh

set -e

if [ ! -f /tmp/move.pid ]
then
  echo "INFO: No outstanding move $(date)"
else
  echo "INFO: Stopping move pid $(cat /tmp/move.pid) $(date)"

  pkill -P $(cat /tmp/move.pid)
  kill -15 $(cat /tmp/move.pid)
  rm -f /tmp/move.pid
fi
