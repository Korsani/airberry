#!/bin/bash
dpkg-query -W deborphan || apt-get install deborphan
egrep '^-' packages | sed -e 's/^-//' | xargs apt-get -y purge 
egrep '^\+' packages | sed -e 's/^\+//' | xargs apt-get -y install 
apt-get -y purge $(deborphan)
apt-get -y purge $(deborphan)
apt-get -y purge $(deborphan)
apt-get -y autoremove -y
[ ! -d /usr/src/aircrack-ng ]		&& svn co http://svn.aircrack-ng.org/trunk/ /usr/src/aircrack-ng && cd /usr/src/aircrack-ng && make install
[ ! -d /usr/src/wiringPi ]			&& git clone git://git.drogon.net/wiringPi /usr/src/wiringPi && cd /usr/src/wiringPi && ./build
[ ! -d /usr/src/pcd8544 ]			&& git clone https://github.com/XavierBerger/pcd8544.git /usr/src/pcd8544
