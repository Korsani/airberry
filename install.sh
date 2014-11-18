#!/usr/bin/env bash
PACKAGES_FILE=packages
WHAT="packages interfaces rpi-update sources fstab"
[ $(id -u) -ne 0 ] && echo "I have to be run as root" && exit 1
[ $(uname -m) != "armv6l" ] && echo "Not on RPi" && exit 1
echo "This WILL break things. Please press enter to continue"
read
if  ! $(netstat -r | grep -q default) 
then
	echo 'No default route. Exiting.'
	exit 1
fi
declare -A src
src['/usr/src/aircrack-ng']="svn co http://svn.aircrack-ng.org/trunk/ /usr/src/aircrack-ng && cd /usr/src/aircrack-ng && make install"
src['/usr/src/wiringPi']="git clone git://git.drogon.net/wiringPi /usr/src/wiringPi && cd /usr/src/wiringPi && ./build"
src['/usr/src/pcd8544']='git clone https://github.com/XavierBerger/pcd8544.git /usr/src/pcd8544'
src['/usr/src/wifite']="git clone https://github.com/Korsani/wifite.git /usr/src/wifite && mkdir -p $HOME/bin && ln -f -s /usr/src/wifite/wifite.py $HOME/bin/wifite.py"
function packages() {
	egrep '^-' $PACKAGES_FILE | sed -e 's/^-//' | xargs apt-get -q -y purge 
	egrep '^\+' $PACKAGES_FILE | sed -e 's/^\+//' | xargs apt-get -y install 
	while [ -n "$(deborphan)" ]
	do
		apt-get -y purge $(deborphan)
	done
	apt-get -y autoremove 
	dpkg -l | egrep '^rc' | awk '{print $2}' | xargs apt-get -y purge
}
function interfaces() {
	cp -a etc_network_interfaces /etc/network/interfaces 
}
function sources() {
	for d in "${!src[@]}"
	do
		if [ ! -d $d ]
		then
			eval ${src[$d]}
		fi
	done
}
function fstab() {
	if [ ! -e /etc/fstab.d/tmpfs ]
	then
		echo 'tmpfs           /tmp            tmpfs   defaults        0       0' >> /etc/fstab.d/tmpfs
		mount -t tmpfs tmpfs /tmp
	fi
	sed -i.kocrack-root -e '/mmcblk0p2/c\/dev/mmcblk0p2  /               ext4    defaults,noatime,sync  0       1' /etc/fstab && mount -o remount /
	sed -i.kocrack-boot -e '/mmcblk0p1/c\/dev/mmcblk0p1  /boot           vfat    defaults,sync          0       2' /etc/fstab && mount -o remount /boot
}
if [ -n "$*" ]
then
	WHAT="$*"
fi
echo "*** Will run : $WHAT"
for what in $WHAT
do
	echo "** Proceeding with $what"
	$what
done
