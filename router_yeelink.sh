#!/bin/sh

CURTIME=`date +"%Y-%m-%d %H:%M:%S"`
echo $CURTIME "Yeelink started" >>/data/usr/log/yeelink.log

sleep 30
while [ 1 ];do

#Time check
YEAR_CHK=`date |cut -d ' ' -f 6`
while [ $YEAR_CHK -lt 2014 ]; do
	echo ''$CURTIME', time is wrong,wait for 5 sec...'>>/tmp/log/yeelink.log
	#ntpdate 192.168.31.1
	sleep 5
	YEAR_CHK=`date |cut -d ' ' -f 6`
done

CURTIME=`date +"%Y-%m-%dT%H:%M:%S"`
PCBTEMP=`/usr/sbin/readtmp | /usr/bin/awk '{print $2}'`
DISKTEMP=`/usr/sbin/smartctl -A /dev/sda | grep Temperature_Celsius | /usr/bin/awk '{print $10}'`
FANSPEED=`/usr/sbin/readfanspeed | /usr/bin/awk '{print $3}' | /bin/sed 's/Speed=//g'`
LOADAVG=`cat /proc/loadavg | /usr/bin/awk '{print 100*$1}'`
NETSPEEDRX=`sar -n DEV 1 1 | grep pppoe-wan | grep -v '^Average' | /usr/bin/awk '{print $5}'`     
NETSPEEDTX=`sar -n DEV 1 1 | grep pppoe-wan | grep -v '^Average' | /usr/bin/awk '{print $6}'` 


echo $CURTIME $PCBTEMP $DISKTEMP $FANSPEED $LOADAVG >>/tmp/log/yeelink.log

if [ $PCBTEMP -ge 0 ]
then
echo '{"timestamp":"'$CURTIME'", "value":'$PCBTEMP'}' >/tmp/datafile
/usr/bin/wget -q --post-file=/tmp/datafile --header="U-ApiKey:86493543ff87c604bc56fac6a89aee56" -O /tmp/yeelink http://api.yeelink.net/v1.0/device/15031/sensor/30320/datapoints
fi

echo '{"timestamp":"'$CURTIME'", "value":'$DISKTEMP'}' >/tmp/datafile	
/usr/bin/wget -q --post-file=/tmp/datafile --header="U-ApiKey:86493543ff87c604bc56fac6a89aee56" -O /tmp/yeelink http://api.yeelink.net/v1.0/device/15031/sensor/30321/datapoints

echo '{"timestamp":"'$CURTIME'", "value":'$FANSPEED'}' >/tmp/datafile
/usr/bin/wget -q --post-file=/tmp/datafile --header="U-ApiKey:86493543ff87c604bc56fac6a89aee56" -O /tmp/yeelink http://api.yeelink.net/v1.0/device/15031/sensor/30322/datapoints

echo '{"timestamp":"'$CURTIME'", "value":'$LOADAVG'}' >/tmp/datafile
/usr/bin/wget -q --post-file=/tmp/datafile --header="U-ApiKey:86493543ff87c604bc56fac6a89aee56" -O /tmp/yeelink http://api.yeelink.net/v1.0/device/15031/sensor/30323/datapoints

echo '{"timestamp":"'$CURTIME'", "value":'$NETSPEEDRX'}' >/tmp/datafile
/usr/bin/wget -q --post-file=/tmp/datafile --header="U-ApiKey:86493543ff87c604bc56fac6a89aee56" -O /tmp/yeelink 你的传感器地址5-下载网速

echo '{"timestamp":"'$CURTIME'", "value":'$NETSPEEDTX'}' >/tmp/datafile
/usr/bin/wget -q --post-file=/tmp/datafile --header="U-ApiKey:86493543ff87c604bc56fac6a89aee56" -O /tmp/yeelink 你的传感器地址10-上传网速


sleep 59
done

# ==run in router ==
# vi /etc/rc.local
# cp /userdisk/data/router_yeelink.sh /tmp
# chmod a+x /tmp/router_yeelink.sh
# sh /tmp/router_yeelink.sh &
