Transform a Raspberry Pi to an automated cracking box

* Installation 

Put that in your rc.local :
nohup /path/to/kocrack/run-at-boot > /tmp/kocrack.log 2>&1 &

* Usage

Reboot.

Logs are /tmp/wifite.log and /tmp/kocrack.log
