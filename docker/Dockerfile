# docker run --cap-add SYS_RAWIO --cap-add NET_ADMIN --net=host --device /dev/mem -t -i airberry /bin/bash
FROM sdhibit/rpi-raspbian
MAINTAINER Gabriel Guillon <korsani@free.fr>
ENV ETCD_VERSION=0.4.6 GO_VERSION=1.4.2 JQ_VERSION=1.4
ENV ETCD_URL=https://github.com/coreos/etcd/archive/v$ETCD_VERSION.tar.gz GO_URL=http://koca-root.s3.amazonaws.com/raspberry/go$GO_VERSION-bin-armv6.tar.gz
#ENV ETCD_SIZE=2901706
#ENV GO_SIZE=26818141
#ENV ARCH=armv6l
ENV BASE_PACKAGES="deborphan curl sudo python-imaging python-pip python-dev" DEV_PACKAGES="libnl-3-dev libnl-genl-3-dev libssl-dev gcc pkg-config python-dev python-pip libffi-dev make" DEV_TOOLS="subversion git" TOOLS_PACKAGES="iw wireless-tools net-tools vim" AIRCRACK_UTILS="ethtool usbutils"

RUN apt-get update 
#RUN apt-get upgrade -y -q && apt-get dist-upgrade -y -q && apt-get -y -q autoclean && apt-get -y -q autoremove)
#RUN apt-get -y -q install ${BASE_PACKAGES} ${AIRCRACK_UTILS} ${DEV_PACKAGES} ${TOOLS_PACKAGES} ${DEV_TOOLS}
RUN apt-get -y -q install ${BASE_PACKAGES} ${AIRCRACK_UTILS}
#ADD packages.docker /tmp/packages
#ADD libkoca.sh /tmp/libkoca.sh
#ADD install.sh /tmp/install.sh
#ADD run-at-boot /root/
#ADD 00-watcher_hub.go.patch /tmp/00-watcher_hub.go.patch
COPY pkg/usr/ /usr/
COPY pkg/root/ /root/
COPY pkg/etc/ /etc/
RUN pip install pillow python-etcd
#RUN (svn co http://svn.aircrack-ng.org/trunk /usr/src/aircrack-ng && make -C /usr/src/aircrack-ng install)
#RUN (cd /tmp && curl -sL http://stedolan.github.io/jq/download/source/jq-${JQ_VERSION}.tar.gz | tar -C /usr/src/ -xzf - && cd /usr/src/jq-${JQ_VERSION} && ./configure && make && make install )
#RUN (cd /usr/src && git clone https://github.com/rm-hull/wiringPi /usr/src/wiringPi && cd /usr/src/wiringPi && ./build)
#RUN (cd /usr/src && git clone https://github.com/rm-hull/pcd8545c.git /usr/src/pcd8544 && pip install pillow && cd /usr/src/pcd8544 && ./setup.py clean build && ./setup.py install)
#RUN (cd /usr/src && curl -s -L http://koca-root.s3.amazonaws.com/raspberry/pcd8544.tar.gz | tar -C /usr/src -xzf - && pip install pillow && cd /usr/src/pcd8544 && ./setup.py clean build && ./setup.py install)
#RUN (git clone https://github.com/Korsani/wifite.git /usr/src/wifite && ln -f -s /usr/src/wifite/wifite.py /usr/local/bin/wifite.py)
#RUN (curl -s -L $GO_URL |tar -C /tmp/ -xzf - && curl -s -L $ETCD_URL | tar -C /usr/src -xzf - )
#RUN( cd /usr/src/etcd-$ETCD_VERSION && patch -p0 < /tmp/00-watcher_hub.go.patch && GOROOT=/tmp/go PATH=$PATH:/tmp/go/bin ./build > /tmp/build.log && cp bin/etcd  /usr/local/sbin/ )

#RUN git clone --depth 1 https://github.com/Korsani/airberry /root/airberry
#RUN bash /etc/init.d/etcd start
# && make install)
CMD /root/airberry/run-at-boot
RUN rm -rf /usr/src/{aircrack-ng,jq-${JQ_VERSION},wiringPi,pcd8544} /tmp/go
#RUN apt-get remove --purge ${DEV_PACKAGES} ${TOOLS_PACKAGES} ${AIRCRACK_UTILS}
#RUN apt-get remove --purge ${DEV_PACKAGES} 
#RUN (apt-get remove --purge $(deborphan) ; apt-get remove --purge $(deborphan) ; apt-get remove --purge $(deborphan) ; apt-get remove --purge deborphan)
