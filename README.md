Transform a Raspberry Pi to an automated cracking box

Of course, crack only wep

# Installation 

1. Plug an 5110 screen (PCD8544) to the Raspberry. Lib used is [this one](https://github.com/rm-hull/pcd8544), and you'll find there instructions to plug one. You can buy such a screen on eBay for no cost.

2. Run install.sh as root. This **WILL** break things, such as installing/uninstalling packages, modifying mount options, ...

3. Put that in your rc.local :
nohup /path/to/airberry/run-at-boot > /tmp/airberry.log 2>&1 &

# Usage

Reboot.

Logs are /tmp/wifite.log and /tmp/airberry.log

# Featuring

* [Modified Wifite](https://github.com/Korsani/wifite) for cracking
* [etcd](https://github.com/coreos/etcd) for communication between scripts
* You can safely unplug Rpi whenever you want
