#!/usr/bin/env bash
FS="$1"
LOW_WATER_SPACE=500
[ -z "$FS" ] && exit 1
exec 5<>/var/run/kocrack
while true
do
	space=$(df "$FS" | tail -1 | awk '{print $4}')
	if [ "$space" -le $LOW_WATER_SPACE ]
	then
		echo "$(date +%s):$(basename "$0"):FS_FULL:Filesystem $FS full : ${space}k free" >&5
	fi
	sleep 10
done
