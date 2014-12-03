Transform a Raspberry Pi to an automated cracking box

Of course, crack only wep

![AirBerry, functionning](https://lut.im/ZGuU6EWC/2VuGrC2Y)

# Installation 

1. Buy and plug an USB Wifi. I personnaly use TL-WN722N

2. Plug an 5110 screen (PCD8544) to the Raspberry. Lib used is [this one](https://github.com/rm-hull/pcd8544), and you'll find there instructions to plug one. You can buy such a screen on eBay for no cost.

3. Run install.sh as root. This **WILL** break things, such as installing/uninstalling packages, modifying mount options, ...

4. Put that in your rc.local :
nohup /path/to/airberry/run-at-boot > /tmp/run-at-boot.log 2>&1 &

# Usage

Reboot.

Logs are /tmp/wifite.out and /tmp/run-at-boot.log

Info of what is happening (wifi scanning, key found, ...) is on the screen

# Featuring

* [Modified Wifite](https://github.com/Korsani/wifite) for cracking
* [etcd](https://github.com/coreos/etcd) for communication between scripts
* You can safely unplug Rpi whenever you want
* No password will be broadcasted anywhere, unless you want to
