#!/bin/sh

#-------------------------------------------------------------------------------------------------
# Copyright (c) 2008 DaisyDisk Team: <https://daisydiskapp.com>
# Some rights reserved: <https://opensource.org/licenses/mit-license.php>
#-------------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------------
# Bash script to relaunch the app

processPath=$1
processID=$2
processBundleID=$3

# waiting cycle
i="10"
while [ $i -gt 0 ]
do
# wait one second
sleep 0.5

# check if running
instanceCount=$(ps -p $processID | grep $processPath | wc -l)

if [ $instanceCount -gt 0 ]
then
# wait again
echo Still running $instanceCount instances of application, $i attempts left;
i=$(($i - 1))

else
# exit cycle
i="0"
fi
done

# relaunch the app
echo Relaunching application
open -n -b $processBundleID

