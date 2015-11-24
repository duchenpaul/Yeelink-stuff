#!/bin/sh
sensor_id_PCBTEMP=56541aa3e4b00415c4381c6b
sensor_id_DISKTEMP=56541ac5e4b00415c4381c6c
sensor_id_FANSPEED=56541af4e4b00415c4381c6d
sensor_id_LOADAVG=56541b1ce4b00415c4381c6e
sensor_id_LoadCycleCount=56541b8de4b00415c4381c6f
sensor_id_Power_On_Hours=56541c2fe4b00415c4381c70
sensor_id_Power_Cycle_Count=56541c48e4b00415c4381c71
sensor_id_NETSPEEDRX=
sensor_id_NETSPEEDTX=



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

post_to_wsncloud() #Usage: post_to_wsncloud sensor_id value
{
	sensor_id=$1
	value=$2
	curl -v --request POST "http://www.wsncloud.com/api/data/v1/numerical/insert?timestamp=`date '+%Y-%m-%d+%H%3A%M%3A%S'`&ak=52596388390a355aa1e90d4076d26d2d&id=$sensor_id&value=$value"
}

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

j=1
for i in $PCBTEMP $DISKTEMP $FANSPEED $LOADAVG $NETSPEEDRX $NETSPEEDTX $LoadCycleCount $Power_On_Hours $Power_Cycle_Count; do
	
	echo '{"timestamp":"'$CURTIME'", "value":'$i'}' >/tmp/datafile
	curl -v --request POST http://www.lewei50.com/api/V1/gateway/UpdateSensors/02 --data "[{'Name':'XR$j','Value':'$i'}]" --header "userkey:2325ed9fb0c94947b18d1a7245a50be4"

	let j++
done

post_to_wsncloud $sensor_id_PCBTEMP $PCBTEMP
post_to_wsncloud $sensor_id_DISKTEMP $DISKTEMP
post_to_wsncloud $sensor_id_FANSPEED $FANSPEED
post_to_wsncloud $sensor_id_LOADAVG $LOADAVG
post_to_wsncloud $sensor_id_LoadCycleCount $LoadCycleCount
post_to_wsncloud $sensor_id_Power_On_Hours $Power_On_Hours
post_to_wsncloud $sensor_id_Power_Cycle_Count $Power_Cycle_Count




# ======================================================================================================================================================
# 	if [ $PCBTEMP -ge 0 ]
# 	then
# 	echo '{"timestamp":"'$CURTIME'", "value":'$PCBTEMP'}' >/tmp/datafile
# 	#curl --request POST --data-binary @"/tmp/datafile" --header "U-ApiKey:86493543ff87c604bc56fac6a89aee56" --verbose http://api.yeelink.net/v1.0/device/15031/sensor/30320/datapoints

# 	curl -v --request POST http://www.lewei50.com/api/V1/gateway/UpdateSensors/02 --data "[{'Name':'XR1','Value':'$PCBTEMP'}]" --header "userkey:2325ed9fb0c94947b18d1a7245a50be4"
# 	fi

# echo '{"timestamp":"'$CURTIME'", "value":'$DISKTEMP'}' >/tmp/datafile	
# #curl --request POST --data-binary @"/tmp/datafile" --header "U-ApiKey:86493543ff87c604bc56fac6a89aee56" --verbose http://api.yeelink.net/v1.0/device/15031/sensor/30321/datapoints

# curl -v --request POST http://www.lewei50.com/api/V1/gateway/UpdateSensors/02 --data "[{'Name':'XR2','Value':'$DISKTEMP'}]" --header "userkey:2325ed9fb0c94947b18d1a7245a50be4"

# echo '{"timestamp":"'$CURTIME'", "value":'$FANSPEED'}' >/tmp/datafile
# #curl --request POST --data-binary @"/tmp/datafile" --header "U-ApiKey:86493543ff87c604bc56fac6a89aee56" --verbose http://api.yeelink.net/v1.0/device/15031/sensor/30322/datapoints

# curl -v --request POST http://www.lewei50.com/api/V1/gateway/UpdateSensors/02 --data "[{'Name':'XR3','Value':'$FANSPEED'}]" --header "userkey:2325ed9fb0c94947b18d1a7245a50be4"

# echo '{"timestamp":"'$CURTIME'", "value":'$LOADAVG'}' >/tmp/datafile
# #curl --request POST --data-binary @"/tmp/datafile" --header "U-ApiKey:86493543ff87c604bc56fac6a89aee56" --verbose http://api.yeelink.net/v1.0/device/15031/sensor/30323/datapoints

# curl -v --request POST http://www.lewei50.com/api/V1/gateway/UpdateSensors/02 --data "[{'Name':'XR4','Value':'$LOADAVG'}]" --header "userkey:2325ed9fb0c94947b18d1a7245a50be4"
# #RX
# echo '{"timestamp":"'$CURTIME'", "value":'$NETSPEEDRX'}' >/tmp/datafile
# #curl --request POST --data-binary @"/tmp/datafile" --header "U-ApiKey:86493543ff87c604bc56fac6a89aee56" --verbose http://api.yeelink.net/v1.0/device/15031/sensor/30388/datapoints

# #curl -v --request POST http://www.lewei50.com/api/V1/gateway/UpdateSensors/02 --data "[{'Name':'XR5','Value':'$NETSPEEDRX'}]" --header "userkey:2325ed9fb0c94947b18d1a7245a50be4"

# #TX
# echo '{"timestamp":"'$CURTIME'", "value":'$NETSPEEDTX'}' >/tmp/datafile
# #curl --request POST --data-binary @"/tmp/datafile" --header "U-ApiKey:86493543ff87c604bc56fac6a89aee56" --verbose http://api.yeelink.net/v1.0/device/15031/sensor/30387/datapoints

# #curl -v --request POST http://www.lewei50.com/api/V1/gateway/UpdateSensors/02 --data "[{'Name':'XR6','Value':'$NETSPEEDTX'}]" --header "userkey:2325ed9fb0c94947b18d1a7245a50be4"

# #硬盘启停次数
# echo '{"timestamp":"'$CURTIME'", "value":'$LoadCycleCount'}' >/tmp/datafile
# #curl --request POST --data-binary @"/tmp/datafile" --header "U-ApiKey:86493543ff87c604bc56fac6a89aee56" --verbose http://api.yeelink.net/v1.0/device/15031/sensor/30389/datapoints

# #curl -v --request POST http://www.lewei50.com/api/V1/gateway/UpdateSensors/02 --data "[{'Name':'XR7','Value':'$LoadCycleCount'}]" --header "userkey:2325ed9fb0c94947b18d1a7245a50be4"

# #硬盘通电时间
# echo '{"timestamp":"'$CURTIME'", "value":'$Power_On_Hours'}' >/tmp/datafile
# #curl --request POST --data-binary @"/tmp/datafile" --header "U-ApiKey:86493543ff87c604bc56fac6a89aee56" --verbose http://api.yeelink.net/v1.0/device/15031/sensor/30390/datapoints

# #curl -v --request POST http://www.lewei50.com/api/V1/gateway/UpdateSensors/02 --data "[{'Name':'XR8','Value':'$Power_On_Hours'}]" --header "userkey:2325ed9fb0c94947b18d1a7245a50be4"

# #硬盘通电次数
# echo '{"timestamp":"'$CURTIME'", "value":'$Power_Cycle_Count'}' >/tmp/datafile
# #curl --request POST --data-binary @"/tmp/datafile" --header "U-ApiKey:86493543ff87c604bc56fac6a89aee56" --verbose http://api.yeelink.net/v1.0/device/15031/sensor/30391/datapoints

# #curl -v --request POST http://www.lewei50.com/api/V1/gateway/UpdateSensors/02 --data "[{'Name':'XR9','Value':'$Power_Cycle_Count'}]" --header "userkey:2325ed9fb0c94947b18d1a7245a50be4"

#=================================================================================================================================================================




# ==run in router ==
# vi /etc/rc.local
# cp /userdisk/data/router_yeelink.sh /tmp
# chmod a+x /tmp/router_yeelink.sh

#in crontab add
#*/5 * * * * sh /tmp/router_yeelink.sh >/dev/null 2>&1
