# docker run --cap-add SYS_RAWIO --cap-add NET_ADMIN --net=host --device /dev/mem -t -i airberry /bin/bash
FROM sdhibit/rpi-raspbian
MAINTAINER Gabriel Guillon <korsani@free.fr>
ENV ETCD_VERSION=0.4.6
ENV GO_VERSION=1.4.2
ENV JQ_VERSION=1.4
ENV ETCD_URL=https://github.com/coreos/etcd/archive/v$ETCD_VERSION.tar.gz
ENV ETCD_SIZE=2901706
ENV GO_URL=http://koca-root.s3.amazonaws.com/raspberry/go$GO_VERSION-bin-armv6.tar.gz
ENV GO_SIZE=26818141
ENV ARCH=armv6l
ENV BASE_PACKAGES="deborphan curl sudo"
ENV DEV_PACKAGES="subversion git libnl-3-dev libnl-genl-3-dev libssl-dev gcc pkg-config python-dev python-pip libffi-dev make"
ENV TOOLS_PACKAGES="iw wireless-tools net-tools vim"
ENV AIRCRACK_UTILS="ethtool usbutils"

RUN apt-get update 
#RUN apt-get upgrade -y -q && apt-get dist-upgrade -y -q && apt-get -y -q autoclean && apt-get -y -q autoremove)
RUN apt-get -y -q install ${BASE_PACKAGES} ${AIRCRACK_UTILS} ${DEV_PACKAGES} ${TOOLS_PACKAGES}
#ADD packages.docker /tmp/packages
#ADD libkoca.sh /tmp/libkoca.sh
#ADD install.sh /tmp/install.sh
ADD ../airberry.conf.dist /etc/airberry.conf
ADD ../etcd.initd /etc/init.d/etcd
#ADD run-at-boot /root/
ADD ../00-watcher_hub.go.patch /tmp/00-watcher_hub.go.patch
RUN (cd /usr/src && svn co http://svn.aircrack-ng.org/trunk aircrack-ng && cd aircrack-ng && make install)
RUN (cd /tmp && curl -sL http://stedolan.github.io/jq/download/source/jq-${JQ_VERSION}.tar.gz | tar -C /usr/src/ -xzf - && cd /usr/src/jq-${JQ_VERSION} && ./configure && make && make install )
RUN (cd /usr/src && git clone https://github.com/rm-hull/wiringPi /usr/src/wiringPi && cd /usr/src/wiringPi && ./build)
#RUN (cd /usr/src && git clone https://github.com/rm-hull/pcd8545c.git /usr/src/pcd8544 && pip install pillow && cd /usr/src/pcd8544 && ./setup.py clean build && ./setup.py install)
RUN (cd /usr/src && curl -s -L http://koca-root.s3.amazonaws.com/raspberry/pcd8544.tar.gz | tar -C /usr/src -xzf - && pip install pillow && cd /usr/src/pcd8544 && ./setup.py clean build && ./setup.py install)
RUN (git clone https://github.com/Korsani/wifite.git /usr/src/wifite && ln -f -s /usr/src/wifite/wifite.py /usr/local/bin/wifite.py)
RUN (curl -s -L $GO_URL |tar -C /tmp/ -xzf - && curl -s -L $ETCD_URL | tar -C /usr/src -xzf - )
RUN ( cd /usr/src/etcd-$ETCD_VERSION && patch -p0 < /tmp/00-watcher_hub.go.patch && GOROOT=/tmp/go PATH=$PATH:/tmp/go/bin ./build > /tmp/build.log && cp bin/etcd  /usr/local/sbin/ )
RUN pip install python-etcd
RUN mkdir /root/airberry
#RUN bash /etc/init.d/etcd start
# && make install)
CMD echo 'Airberry cracking box'
ENTRYPOINT sleep 120000
RUN rm -rf /usr/src/{aircrack-ng,jq-${JQ_VERSION},wiringPi,pcd8544}
RUN rm -rf /tmp/go
#RUN apt-get remove --purge ${DEV_PACKAGES} ${TOOLS_PACKAGES} ${AIRCRACK_UTILS}
#RUN (apt-get remove --purge $(deborphan) ; apt-get remove --purge $(deborphan) ; apt-get remove --purge $(deborphan) ; apt-get remove --purge deborphan)
