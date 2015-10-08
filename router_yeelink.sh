#!/bin/sh

CURTIME=`date +"%Y-%m-%d %H:%M:%S"`
echo $CURTIME "Yeelink started" >>/data/usr/log/yeelink.log

#sleep 30
get_cpu_info() 
{ 
  cat /proc/stat|grep '^cpu[0-9]'|awk '{used+=$2+$3+$4;unused+=$5+$6+$7+$8} END{print used,unused}' 
} 
 
watch_cpu() 
{ 
  time_point_1=`get_cpu_info` 
  sleep 30
  time_point_2=`get_cpu_info` 
  cpu_usage=`echo $time_point_1 $time_point_2|awk '{used=$3-$1;total=$3+$4-$1-$2;print used*100/total}'` 
}


while [ 1 ];do

#Time check
YEAR_CHK=`date |cut -d ' ' -f 6`
while [ $YEAR_CHK -lt 2014 ]; do
	echo ''$CURTIME', time is wrong,wait for 5 sec...'>>/tmp/log/yeelink.log
	#ntpdate 192.168.31.1
	sleep 5
	YEAR_CHK=`date |cut -d ' ' -f 6`
done
watch_cpu

CURTIME=`date +"%Y-%m-%dT%H:%M:%S"`
PCBTEMP=`/usr/sbin/readtmp | /usr/bin/awk '{print $2}'`
DISKTEMP=`/usr/sbin/smartctl -A /dev/sda | grep Temperature_Celsius | /usr/bin/awk '{print $10}'`
FANSPEED=`/usr/sbin/readfanspeed | /usr/bin/awk '{print $3}' | /bin/sed 's/Speed=//g'`
#LOADAVG=`cat /proc/loadavg | /usr/bin/awk '{print 100*$1}'`
LOADAVG=$cpu_usage
NETSPEEDRX=`sar -n DEV 1 1 | grep eth0 | grep -v '^Average' | /usr/bin/awk '{print $5}'`     
NETSPEEDTX=`sar -n DEV 1 1 | grep eth0 | grep -v '^Average' | /usr/bin/awk '{print $6}'` 
LoadCycleCount=`/usr/sbin/smartctl -a /dev/sda4 | grep Load_Cycle_Count | /usr/bin/awk '{print $10}'`
Power_On_Hours=`/usr/sbin/smartctl -a /dev/sda4 | grep Power_On_Hours | /usr/bin/awk '{print $10}'`
Power_Cycle_Count=`/usr/sbin/smartctl -a /dev/sda4 | grep Power_Cycle_Count | /usr/bin/awk '{print $10}'`


echo $CURTIME $PCBTEMP $DISKTEMP $FANSPEED $LOADAVG >>/tmp/log/yeelink.log

if [ $PCBTEMP -ge 0 ]
then
echo '{"timestamp":"'$CURTIME'", "value":'$PCBTEMP'}' >/tmp/datafile
curl --request POST --data-binary @"/tmp/datafile" --header "U-ApiKey:86493543ff87c604bc56fac6a89aee56" --verbose http://api.yeelink.net/v1.0/device/15031/sensor/30320/datapoints
fi

echo '{"timestamp":"'$CURTIME'", "value":'$DISKTEMP'}' >/tmp/datafile	
curl --request POST --data-binary @"/tmp/datafile" --header "U-ApiKey:86493543ff87c604bc56fac6a89aee56" --verbose http://api.yeelink.net/v1.0/device/15031/sensor/30321/datapoints

echo '{"timestamp":"'$CURTIME'", "value":'$FANSPEED'}' >/tmp/datafile
curl --request POST --data-binary @"/tmp/datafile" --header "U-ApiKey:86493543ff87c604bc56fac6a89aee56" --verbose http://api.yeelink.net/v1.0/device/15031/sensor/30322/datapoints

echo '{"timestamp":"'$CURTIME'", "value":'$LOADAVG'}' >/tmp/datafile
curl --request POST --data-binary @"/tmp/datafile" --header "U-ApiKey:86493543ff87c604bc56fac6a89aee56" --verbose http://api.yeelink.net/v1.0/device/15031/sensor/30323/datapoints
#RX
echo '{"timestamp":"'$CURTIME'", "value":'$NETSPEEDRX'}' >/tmp/datafile
curl --request POST --data-binary @"/tmp/datafile" --header "U-ApiKey:86493543ff87c604bc56fac6a89aee56" --verbose http://api.yeelink.net/v1.0/device/15031/sensor/30388/datapoints

#TX
echo '{"timestamp":"'$CURTIME'", "value":'$NETSPEEDTX'}' >/tmp/datafile
curl --request POST --data-binary @"/tmp/datafile" --header "U-ApiKey:86493543ff87c604bc56fac6a89aee56" --verbose http://api.yeelink.net/v1.0/device/15031/sensor/30387/datapoints

#硬盘启停次数
echo '{"timestamp":"'$CURTIME'", "value":'$LoadCycleCount'}' >/tmp/datafile
curl --request POST --data-binary @"/tmp/datafile" --header "U-ApiKey:86493543ff87c604bc56fac6a89aee56" --verbose http://api.yeelink.net/v1.0/device/15031/sensor/30389/datapoints

#硬盘通电时间
echo '{"timestamp":"'$CURTIME'", "value":'$Power_On_Hours'}' >/tmp/datafile
curl --request POST --data-binary @"/tmp/datafile" --header "U-ApiKey:86493543ff87c604bc56fac6a89aee56" --verbose http://api.yeelink.net/v1.0/device/15031/sensor/30390/datapoints

#硬盘通电次数
echo '{"timestamp":"'$CURTIME'", "value":'$Power_Cycle_Count'}' >/tmp/datafile
curl --request POST --data-binary @"/tmp/datafile" --header "U-ApiKey:86493543ff87c604bc56fac6a89aee56" --verbose http://api.yeelink.net/v1.0/device/15031/sensor/30391/datapoints

sleep 565
done

# ==run in router ==
# vi /etc/rc.local
# cp /userdisk/data/router_yeelink.sh /tmp
# chmod a+x /tmp/router_yeelink.sh
# sh /tmp/router_yeelink.sh &
