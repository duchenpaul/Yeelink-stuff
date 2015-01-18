#!/bin/sh

CURTIME=`date +"%Y-%m-%d %H:%M:%S"`
echo $CURTIME "Yeelink started" >>/data/usr/log/yeelink.log

sleep 30
while [ 1 ];do
CURTIME=`date +"%Y-%m-%dT%H:%M:%S"`
PCBTEMP=`/usr/sbin/readtmp | /usr/bin/awk '{print $2}'`
DISKTEMP=`/usr/sbin/smartctl -A /dev/sda | grep Temperature_Celsius | /usr/bin/awk '{print $10}'`
FANSPEED=`/usr/sbin/readfanspeed | /usr/bin/awk '{print $3}' | /bin/sed 's/Speed=//g'`
LOADAVG=`cat /proc/loadavg | /usr/bin/awk '{print $1}'`

echo $CURTIME $PCBTEMP $DISKTEMP $FANSPEED $LOADAVG >>/tmp/log/yeelink.log

if [ $PCBTEMP -ge 0 ]
then
echo '{"timestamp":"'$CURTIME'", "value":'$PCBTEMP'}' >/tmp/datafile
/usr/bin/wget -q --post-file=/tmp/datafile --header="U-ApiKey:86493543ff87c604bc56fac6a89aee56" -O /tmp/yeelink http://api.yeelink.net/v1.0/device/15031/sensor/30299/datapoints
fi

echo '{"timestamp":"'$CURTIME'", "value":'$DISKTEMP'}' >/tmp/datafile	
/usr/bin/wget -q --post-file=/tmp/datafile --header="U-ApiKey:86493543ff87c604bc56fac6a89aee56" -O /tmp/yeelink http://api.yeelink.net/v1.0/device/15031/sensor/30300/datapoints

echo '{"timestamp":"'$CURTIME'", "value":'$FANSPEED'}' >/tmp/datafile
/usr/bin/wget -q --post-file=/tmp/datafile --header="U-ApiKey:86493543ff87c604bc56fac6a89aee56" -O /tmp/yeelink http://api.yeelink.net/v1.0/device/15031/sensor/30301/datapoints

echo '{"timestamp":"'$CURTIME'", "value":'$LOADAVG'}' >/tmp/datafile
/usr/bin/wget -q --post-file=/tmp/datafile --header="U-ApiKey:86493543ff87c604bc56fac6a89aee56" -O /tmp/yeelink http://api.yeelink.net/v1.0/device/15031/sensor/30302/datapoints

sleep 59
done

# ==run in router ==
# vi /etc/rc.local
# cp /userdisk/data/router_yeelink.sh /tmp
# chmod a+x /tmp/router_yeelink.sh
# sh /tmp/router_yeelink.sh &
