#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/root/bin
export HOME=/root
cd /root
while true ; do /root/bin/wifite.py --wep --all >/root/wifite.log ; done &
/root/kocrack/broadcast-keys
