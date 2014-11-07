#!/usr/bin/env bash
PACKAGES_FILE=packages
[ $(id -u) -ne 0 ] && echo "I have to be ran as root" && exit 1
declare -A src
src['/usr/src/aircrack-ng']="svn co http://svn.aircrack-ng.org/trunk/ /usr/src/aircrack-ng && cd /usr/src/aircrack-ng && make install"
src['/usr/src/wiringPi']="git clone git://git.drogon.net/wiringPi /usr/src/wiringPi && cd /usr/src/wiringPi && ./build"
src['/usr/src/pcd8544']='git clone https://github.com/XavierBerger/pcd8544.git /usr/src/pcd8544'
src['/usr/src/wifite']="git clone https://github.com/Korsani/wifite.git /usr/src/wifite && mkdir -p $HOME/bin && ln -f -s /usr/src/wifite/wifite.py $HOME/bin/wifite.py"
egrep '^-' $PACKAGES_FILE | sed -e 's/^-//' | xargs apt-get -q -y purge 
egrep '^\+' $PACKAGES_FILE | sed -e 's/^\+//' | xargs apt-get -y install 
while [ -n "$(deborphan)" ]
do
	apt-get -y purge $(deborphan)
done
apt-get -y autoremove 
dpkg -l | egrep '^rc' | awk '{print $2}' | xargs apt-get -y purge
rpi-update
for d in "${!src[@]}"
do
	if [ ! -d $d ]
	then
		eval ${src[$d]}
	fi
done
if ! $(grep -q 'tmpfs /tmp tmpfs' /proc/mounts)
then
	echo 'tmpfs           /tmp            tmpfs   defaults        0       0' >> /etc/fstab
	mount /tmp
fi
