.PHONY: pkg clean container jq etcd wifite pcd8544 aircrack-ng go wiringPi
ARCH:=$(shell uname -m)
PROJECT_NAME:=airberry

DOCKERFILE:=Dockerfile
SRC_DIR:=/usr/src
PACKAGES:=libnl-3-dev libnl-genl-3-dev libssl-dev

ETCD_VERSION:=0.5.0-alpha.4
ETCD_VERSION:=0.4.6
GO_VERSION:=1.4.2
JQ_VERSION:=1.4

ETCD_URL:=https://github.com/coreos/etcd/archive/v${ETCD_VERSION}.tar.gz
GO_URL:=http://koca-root.s3.amazonaws.com/raspberry/go${GO_VERSION}-bin-${ARCH}.tar.gz

ETCD_DIR:=${SRC_DIR}/etcd-${ETCD_VERSION}
GO_DIR:=${SRC_DIR}/go
PKG_DIR:=$(CURDIR)/pkg

ETCD_SIZE=$(shell curl -s -I -L ${ETCD_URL} | grep 'Content-Length' | cut -d ':' -f 2)
GO_SIZE=$(shell curl -s -I -L ${GO_URL} | grep 'Content-Length' | cut -d ':' -f 2)

DOCKER_IMAGE:=$(PROJECT_NAME)-$(ARCH).tar.gz

pkg: pkg.tar.gz

container: $(DOCKER_IMAGE)

pkg.tar.gz: etcd $(PKG_DIR)/etc/airberry.conf $(PKG_DIR)/etc/motd aircrack-ng wifite pcd8544 wiringPi airberry | $(PKG_DIR)
	tar -C $(PKG_DIR) --exclude .git -cvzf pkg.tar.gz usr root etc

airberry: $(PKG_DIR)/root/airberry

etcd: $(PKG_DIR)/usr/local/sbin/etcd $(PKG_DIR)/etc/init.d/etcd

aircrack-ng: $(PKG_DIR)/usr/local/bin/aircrack-ng 

jq: $(PKG_DIR)/usr/local/bin/jq
	
wifite: $(PKG_DIR)/usr/src/wifite
	
pcd8544: $(PKG_DIR)/usr/local/lib/python2.7/site-packages/pcd8544

wiringPi: $(PKG_DIR)/usr/local/lib/python2.7/dist-packages/wiringPy.so

go: ${GO_DIR}/bin/go

$(PKG_DIR)/root/airberry:
	git clone --depth 1 https://github.com/Korsani/airberry $(PKG_DIR)/root/airberry

$(PKG_DIR)/aircrack-ng:
	svn co http://svn.aircrack-ng.org/trunk/ $(PKG_DIR)/aircrack-ng

$(PKG_DIR)/usr/local/bin/aircrack-ng: $(PKG_DIR)/aircrack-ng
	sed -i -e "s!= /usr/local!= $(PKG_DIR)/usr/local!" $(PKG_DIR)/aircrack-ng/common.mak
	$(MAKE) -C $(PKG_DIR)/aircrack-ng install

$(PKG_DIR)/usr/local/bin/jq:
	curl -sL http://stedolan.github.io/jq/download/source/jq-${JQ_VERSION}.tar.gz | tar -C $(PKG_DIR) -xzf -
	cd $(PKG_DIR)/jq-$(JQ_VERSION) && ./configure --prefix=$(PKG_DIR)/usr/local
	$(MAKE) -C $(PKG_DIR)/jq-$(JQ_VERSION) install

$(PKG_DIR)/usr/src/master.zip:
	curl -s -L https://github.com/Korsani/wifite/archive/master.zip -o $(PKG_DIR)/usr/src/master.zip

$(PKG_DIR)/usr/src/wifite: $(PKG_DIR)/usr/src $(PKG_DIR)/usr/src/master.zip
	unzip -o -d $(PKG_DIR)/usr/src/ $(PKG_DIR)/usr/src/master.zip
	ln -s -f $(PKG_DIR)/usr/src/wifite-master $(PKG_DIR)/usr/src/wifite

$(PKG_DIR)/usr/local/lib/python2.7/site-packages/pcd8544:
	curl -s -L http://koca-root.s3.amazonaws.com/raspberry/pcd8544.tar.gz | tar -C $(PKG_DIR) -xzf -
	cd $(PKG_DIR)/pcd8544 && ./setup.py clean build && ./setup.py install --prefix=$(PKG_DIR)/usr/local

$(PKG_DIR)/wiringPi:
	git clone --depth 1 https://github.com/rm-hull/wiringPi $(PKG_DIR)/wiringPi 

$(PKG_DIR)/usr/local/lib/python2.7/dist-packages/wiringPy.so: $(PKG_DIR)/usr/lib $(PKG_DIR)/usr/local/lib/python2.7/dist-packages $(PKG_DIR)/wiringPi
	sed -i -e "s!DESTDIR=/usr!DESTDIR=$(PKG_DIR)/usr!g" $(PKG_DIR)/wiringPi/wiringPi/Makefile
	cd $(PKG_DIR)/wiringPi ; ./build

$(DOCKER_IMAGE): pkg
	docker build -t $(PROJECT_NAME) -f $(DOCKERFILE) --rm $(CURDIR)
	docker save -o $(DOCKER_IMAGE) $(PROJECT_NAME)

$(PKG_DIR)/etc/init.d/etcd: $(CURDIR)/../etcd.initd | $(PKG_DIR)
	install -D -m644 $< $@
$(PKG_DIR)/etc/airberry.conf: $(CURDIR)/../airberry.conf.dist | $(PKG_DIR)
	install -D -m644 $< $@
$(PKG_DIR)/etc/motd: $(CURDIR)/../motd | $(PKG_DIR)
	install -D -m644 $< $@
$(PKG_DIR)/usr/local/sbin/etcd: ${ETCD_DIR}/bin/etcd | $(PKG_DIR)
	install -D -m755 ${ETCD_DIR}/bin/etcd $@

${GO_DIR}/bin/go:
	curl -s -L ${GO_URL} | pv -s ${GO_SIZE} |tar -C ${GO_DIR}/.. -xzf - 

${ETCD_DIR}:
	curl -s -L ${ETCD_URL} | pv -s ${ETCD_SIZE} | tar -C ${SRC_DIR} -xzf -
	cd ${ETCD_DIR} && patch -p0 < ${CURDIR}/../00-watcher_hub.go.patch

${ETCD_DIR}/bin/etcd: ${GO_DIR}/bin/go ${ETCD_DIR}
	cd ${ETCD_DIR} && GOROOT=${GO_DIR} PATH=${PATH}:${GO_DIR}/bin ./build

$(PKG_DIR)/usr/lib $(PKG_DIR)/usr/local/lib/python2.7/dist-packages $(PKG_DIR)/usr/src:
	mkdir -p $@
$(PKG_DIR):
	mkdir -p $@
	mount -t tmpfs tmpfs $@

clean:
	umount $(PKG_DIR)
	rmdir $(PKG_DIR)
	rm -f $(DOCKER_IMAGE)
