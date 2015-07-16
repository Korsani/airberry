.PHONY: image clean docker_image_file docker_image jq etcd wifite pcd8544 aircrack-ng go wiringPi
ARCH:=$(shell uname -m)
PROJECT_NAME:=airberry

DOCKER_IMAGE_NAME:=$(PROJECT_NAME)
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
IMAGE_DIR:=$(CURDIR)/image

ETCD_SIZE=$(shell curl -s -I -L ${ETCD_URL} | grep 'Content-Length' | cut -d ':' -f 2)
GO_SIZE=$(shell curl -s -I -L ${GO_URL} | grep 'Content-Length' | cut -d ':' -f 2)

DOCKER_IMAGE_FILE:=$(DOCKER_IMAGE_NAME)-$(ARCH)-$(shell date -I).tar.gz
IMAGE_FILE:=image.tar.gz

image: $(IMAGE_FILE)

docker_image_file: $(DOCKER_IMAGE_FILE)

$(IMAGE_FILE): etcd $(IMAGE_DIR)/etc/airberry.conf $(IMAGE_DIR)/etc/motd aircrack-ng wifite pcd8544 wiringPi airberry | $(IMAGE_DIR)
	tar -C $(IMAGE_DIR) --exclude .git -cvzf $(IMAGE_FILE) usr root etc

airberry: $(IMAGE_DIR)/root/airberry

etcd: $(IMAGE_DIR)/usr/local/sbin/etcd $(IMAGE_DIR)/etc/init.d/etcd

aircrack-ng: $(IMAGE_DIR)/usr/local/bin/aircrack-ng 

jq: $(IMAGE_DIR)/usr/local/bin/jq
	
wifite: $(IMAGE_DIR)/usr/src/wifite
	
pcd8544: $(IMAGE_DIR)/usr/local/lib/python2.7/dist-packages/pcd8544/lcd.py

wiringPi: $(IMAGE_DIR)/usr/local/lib/python2.7/dist-packages/wiringPy.so

go: ${GO_DIR}/bin/go

$(IMAGE_DIR)/root/airberry:
	git clone --depth 1 https://github.com/Korsani/airberry $(IMAGE_DIR)/root/airberry

$(IMAGE_DIR)/aircrack-ng:
	svn co http://svn.aircrack-ng.org/trunk/ $(IMAGE_DIR)/aircrack-ng

$(IMAGE_DIR)/usr/local/bin/aircrack-ng: $(IMAGE_DIR)/aircrack-ng
	sed -i -e "s!= /usr/local!= $(IMAGE_DIR)/usr/local!" $(IMAGE_DIR)/aircrack-ng/common.mak
	$(MAKE) -C $(IMAGE_DIR)/aircrack-ng install

$(IMAGE_DIR)/usr/local/bin/jq:
	curl -sL http://stedolan.github.io/jq/download/source/jq-${JQ_VERSION}.tar.gz | tar -C $(IMAGE_DIR) -xzf -
	cd $(IMAGE_DIR)/jq-$(JQ_VERSION) && ./configure --prefix=$(IMAGE_DIR)/usr/local
	$(MAKE) -C $(IMAGE_DIR)/jq-$(JQ_VERSION) install

$(IMAGE_DIR)/usr/src/master.zip:
	curl -s -L https://github.com/Korsani/wifite/archive/master.zip -o $(IMAGE_DIR)/usr/src/master.zip

$(IMAGE_DIR)/usr/src/wifite: $(IMAGE_DIR)/usr/src $(IMAGE_DIR)/usr/src/master.zip
	unzip -o -d $(IMAGE_DIR)/usr/src/ $(IMAGE_DIR)/usr/src/master.zip
	ln -s -f $(IMAGE_DIR)/usr/src/wifite-master $(IMAGE_DIR)/usr/src/wifite

$(IMAGE_DIR)/usr/local/lib/python2.7/dist-packages/pcd8544/lcd.py:
	curl -s -L http://koca-root.s3.amazonaws.com/raspberry/pcd8544.tar.gz | tar -C $(IMAGE_DIR) -xzf -
	cd $(IMAGE_DIR)/pcd8544 && ./setup.py clean build && ./setup.py install --root=$(IMAGE_DIR)/usr/local

$(IMAGE_DIR)/wiringPi:
	git clone --depth 1 https://github.com/rm-hull/wiringPi $(IMAGE_DIR)/wiringPi 

$(IMAGE_DIR)/usr/local/lib/python2.7/dist-packages/wiringPy.so: $(IMAGE_DIR)/usr/lib $(IMAGE_DIR)/usr/local/lib/python2.7/dist-packages $(IMAGE_DIR)/wiringPi
	sed -i -e "s!DESTDIR=/usr!DESTDIR=$(IMAGE_DIR)/usr!g" $(IMAGE_DIR)/wiringPi/wiringPi/Makefile
	cd $(IMAGE_DIR)/wiringPi ; ./build

$(DOCKER_IMAGE_FILE): image docker_image
	docker save -o $(DOCKER_IMAGE_FILE) $(DOCKER_IMAGE_NAME)
docker_image:
	docker build -t $(DOCKER_IMAGE_NAME) -f $(DOCKERFILE) --rm $(CURDIR)

$(IMAGE_DIR)/etc/init.d/etcd: $(CURDIR)/../etcd.initd | $(IMAGE_DIR)
	install -D -m644 $< $@
$(IMAGE_DIR)/etc/airberry.conf: $(CURDIR)/../airberry.conf.dist | $(IMAGE_DIR)
	install -D -m644 $< $@
$(IMAGE_DIR)/etc/motd: $(CURDIR)/../motd | $(IMAGE_DIR)
	install -D -m644 $< $@
$(IMAGE_DIR)/usr/local/sbin/etcd: ${ETCD_DIR}/bin/etcd | $(IMAGE_DIR)
	install -D -m755 ${ETCD_DIR}/bin/etcd $@

${GO_DIR}/bin/go:
	curl -s -L ${GO_URL} | pv -s ${GO_SIZE} |tar -C ${GO_DIR}/.. -xzf - 

${ETCD_DIR}:
	curl -s -L ${ETCD_URL} | pv -s ${ETCD_SIZE} | tar -C ${SRC_DIR} -xzf -
	cd ${ETCD_DIR} && patch -p0 < ${CURDIR}/../00-watcher_hub.go.patch

${ETCD_DIR}/bin/etcd: ${GO_DIR}/bin/go ${ETCD_DIR}
	cd ${ETCD_DIR} && GOROOT=${GO_DIR} PATH=${PATH}:${GO_DIR}/bin ./build

$(IMAGE_DIR)/usr/lib $(IMAGE_DIR)/usr/local/lib/python2.7/dist-packages $(IMAGE_DIR)/usr/src:
	mkdir -p $@

$(IMAGE_DIR):
	mkdir -p $@
	mount -t tmpfs tmpfs $@

clean:
	umount $(IMAGE_DIR)
	rmdir $(IMAGE_DIR)
	rm -f $(DOCKER_IMAGE_FILE) build
