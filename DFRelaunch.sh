#!/bin/sh

#-------------------------------------------------------------------------------------------------
# Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
# Some rights reserved: <http://opensource.org/licenses/mit-license.php>
#-------------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------------
# Bash script to relaunch the app

# give app a chance to terminate within 10 seconds
i="10"
while [ $i -gt 0 ]
do
  sleep 1
  
  is_running=$(osascript -e 'tell application "System Events" to exists (process 1 whose unix id is '$2')')
  echo "Waiting for shutdown: " $is_running
  if [ "$is_running" = "false" ]; then
    i="0"
  else
    i=$(($i - 1))
  fi
done

# relaunch the app
osascript -e 'tell application "'"$1"'" to activate'

