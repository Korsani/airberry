#!/usr/bin/env bash
eval "$(bash $(dirname "$0")/libkoca.sh koca_lockMe)"
koca_lockMe /tmp/check-fs-space 0
source /etc/airberry.conf
FS="$1"
LOW_WATER_SPACE=500
[ -z "$FS" ] && exit 1
while true
do
	space=$(df "$FS" | tail -1 | awk '{print $4}')
	if [ "$space" -le $LOW_WATER_SPACE ]
	then
		curl -L http://127.0.0.1:4001/v2/keys/$ETCD_DIR/monitor -XPOST -d value=DISK_FULL
		$HERE/lcd.py cls
		$HERE/lcd.py text 0 0 'Disk full !'
	fi
	sleep 10
done
