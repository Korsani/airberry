#!/usr/bin/env python

import pcd8544.lcd as lcd
import etcd
import os, string, time, signal, sys
from datetime import datetime
"""
For pcd8544
"""
LCD_LINES=6
LCD_COLUMNS=14

PIDFILE='/var/run/'+os.path.basename(sys.argv[0])+'.pid'
CONF_FILE='/etc/airberry.conf'
CONF={}
# On some screen backlight is on when 0 is sent ...
(ON,OFF)=(0,1)
# Log function
def Log(sMessage):
    print '['+datetime.strftime(datetime.now(),'%Y/%m/%d %H:%M:%S')+'] '+sMessage

# Receive and parse etcd's datas
def parseEtcd(client):
    sStatus=str(client.read('/'+CONF['ETCD_DIR']+'/status').value)
    aStatus=string.split(sStatus,':')
    return aStatus

# Split given strings in chunks of iWidth chars OR upon \n delimiters
def splitLineForLCD(sLine,iWidth):
    aPreChunks=sLine.split("\n")
    aChunks=[]
    for sLine in aPreChunks:
        while len(sLine) > iWidth:
            sLineToAdd=sLine[:iWidth]
            if len(sLineToAdd) > 0:
                aChunks.append(sLine[:iWidth])
            sLine=sLine[iWidth:]
        if len(sLine) > 0:
            aChunks.append(sLine)

    return aChunks

# Display array to LCD, eventually 'scrolling'
def display(aToDisplay):
    aDisplay=[]
    lcd.cls()
    sToDisplay=''
    for sId in aToDisplay.keys():
        sToDisplay=sToDisplay+aToDisplay[sId]
    aDisplay=splitLineForLCD(sToDisplay,LCD_COLUMNS)
    y=0
    while len(aDisplay)>0:
        sLine=aDisplay.pop(0)
        lcd.text(sLine)
        y=y+1
        if y >= LCD_LINES:
            y=0
            time.sleep(5)
            lcd.cls()
        lcd.locate(0,y)

def status_wifite(sWhat,sValue):
    if 'rab' in aToDisplay:
        del aToDisplay['rab']
    if sWhat=='Cracked':
        try:
            # sValue is the AP's ssid
            sKey=str(client.read('/cracked/from_reboot/'+sValue).value)
        except KeyError:
            print 'No key for AP "'+sValue+'"'
        except:
            print 'Unexpected error:',sys.exec_info()[0]
        else:
            lcd.backlight(ON)
            aToDisplay[sValue]=">"+sValue+':'+sKey+"\n"
            if 'wifite' in aToDisplay:
                del aToDisplay['wifite']
    elif sWhat == 'Attacking':
        aToDisplay['wifite']="Attacking:\n"+sValue+"\n"
    elif sWhat == 'Start cracking':
        aWStatus=string.split(str(client.read('/wifite/status').value),':')
        aToDisplay['wifite']="Cracking:\n"+sValue+"\n"+aWStatus[1]+"\n"
    else:
        # Wifite status
        aToDisplay['wifite']=sValue+"\n"
    return aToDisplay

def status_cfs(sWhat,sValue):
    if sValue=='DISK_FULL':
        aToDisplay[sValue]="DF:Reboot\n"
    return aToDisplay

def status_rab(sWhat,sValue):
    if 'wifite' in aToDisplay:
        del aToDisplay['wifite']
    aToDisplay['rab']=sValue+"\n"
    return aToDisplay

def INTHandler(signum,frame):
    os.unlink(PIDFILE)
    sys.exit()

def parseConf(sCfgFile):
    for line in [line.strip() for line in open(sCfgFile,'r')]:
        [key,value]=line.split('=')
        CONF[key]=value

if __name__ == "__main__":
    pid=str(os.getpid())
    if os.path.isfile(PIDFILE):
        print "%s already exists, exiting" % PIDFILE
        sys.exit()
    else:
        file(PIDFILE, 'w').write(pid)
        signal.signal(signal.SIGINT,INTHandler)
        signal.signal(signal.SIGTERM,INTHandler)

    parseConf(CONF_FILE)

    Log('Starting')

    lcd.init()
    Log('Setting contrast to '+CONF['LCD_CONTRAST'])
    lcd.set_contrast(int(CONF['LCD_CONTRAST']))
    client=etcd.Client(port=int(CONF['ETCD_PORT']))
    aToDisplay={}
    while True:
        aStatus=parseEtcd(client)
        sFrom=aStatus[0]
        sWhat=aStatus[1]
        sValue=aStatus[2]
        if sFrom == 'Wifite':
            aToDisplay=status_wifite(sWhat,sValue)
        if sFrom=='cfs':
            aToDisplay=status_cfs(sWhat,sValue)
        if sFrom=='run-at-boot':
            aToDisplay=status_rab(sWhat,sValue)

        display(aToDisplay)
        time.sleep(3)
