#!/usr/bin/env bash
eval "$(bash $(dirname "$0")/libkoca.sh koca_lockMe)"
koca_lockMe /tmp/check-fs-space 0
FS="$1"
LOW_WATER_SPACE=500
SOCKET=/var/run/kocrack
[ -z "$FS" ] && exit 1
[ ! -p "$SOCKET" ] && exit 1
exec 5<>$SOCKET
while true
do
	space=$(df "$FS" | tail -1 | awk '{print $4}')
	if [ "$space" -le $LOW_WATER_SPACE ]
	then
		echo "$(date +%s):$(basename "$0"):FS_FULL:Filesystem $FS full : ${space}k free" >&5
	fi
	sleep 10
done
