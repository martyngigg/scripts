#! /bin/sh

#
# Opens up the current timehseet for editing
#
TIMESHEET=/mnt/data1/Timesheets/current.txt

RUNNING=`ps aux | grep "gedit $TIMESHEET" | grep -v grep`

if [ -z "$RUNNING" ]; then
    gedit $TIMESHEET &
fi
