#注意这句执行的是/mnt/tmp/下的文件，而不是home/pi/
sudo python /mnt/tmp/temp.py
#curl --request POST --data-binary @"/mnt/tmp/temp.txt" --header "U-ApiKey:86493543ff87c604bc56fac6a89aee56" --verbose http://api.yeelink.net/v1.0/device/15028/sensor/25761/datapoints

get_cpu_info() 
{ 
  cat /proc/stat|grep '^cpu[0-9]'|awk '{used+=$2+$3+$4;unused+=$5+$6+$7+$8} END{print used,unused}' 
} 
 
watch_cpu() 
{ 
  time_point_1=`get_cpu_info` 
  sleep 3
  time_point_2=`get_cpu_info` 
  cpu_usage=`echo $time_point_1 $time_point_2|awk '{used=$3-$1;total=$3+$4-$1-$2;print used*100/total}'` 
}

post_to_wsncloud() #Usage: post_to_wsncloud sensor_id value
{
	sensor_id=$1
	value=$2
	curl -v --request POST "http://www.wsncloud.com/api/data/v1/numerical/insert?timestamp=` date '+%Y-%m-%d+%H%%3A%M%%3A%S'`&ak=52596388390a355aa1e90d4076d26d2d&id=$sensor_id&value=$value"
}

post_to_devicehub() #Usage: post_to_devicehub_rpi "[sensor_key]" e.g. 6062/device/f41c2cd1-a05e-462e-b674-4b00b8addc4c/sensor/CPU_Temperature [value]
{
	sensor_key=$1
	value=$2
	curl -H "X-ApiKey: 94b66098-a1b2-4295-856f-0f2ee4810747" -H "Content-Type: application/json" -i "https://api.devicehub.net/v2/project/$sensor_key/data" -d '{"value":'$value'}'
}


CURTIME=`date +"%Y-%m-%d %H:%M:%S"`
watch_cpu
#LOADAVG=`cat /proc/loadavg | /usr/bin/awk '{print 100*$1}'`
LOADAVG=$cpu_usage
echo '{"timestamp":"'$CURTIME'", "value":'$LOADAVG'}' >/tmp/datafile
#/usr/bin/wget -q --post-file=/tmp/datafile --header="U-ApiKey:86493543ff87c604bc56fac6a89aee56" -O /tmp/yeelink http://api.yeelink.net/v1.0/device/15028/sensor/32478/datapoints


temp=`/opt/vc/bin/vcgencmd measure_temp | cut -c 6-7`
curl -v --request POST http://www.lewei50.com/api/V1/gateway/UpdateSensors/01 --data "[{'Name':'S1','Value':'$temp'}]" --header "userkey:2325ed9fb0c94947b18d1a7245a50be4"
#post 到乐联网

curl -v --request POST http://www.lewei50.com/api/V1/gateway/UpdateSensors/01 --data "[{'Name':'S2','Value':'$LOADAVG'}]" --header "userkey:2325ed9fb0c94947b18d1a7245a50be4"

sensor_id_cpu_temp=56514e73e4b0932584ded5e5
sensor_id_cpu_Load=56541041e4b00415c4381c64

post_to_wsncloud $sensor_id_cpu_temp $temp
post_to_wsncloud $sensor_id_cpu_Load $LOADAVG

sensor_id_CPU_Temperature="6062/device/f41c2cd1-a05e-462e-b674-4b00b8addc4c/sensor/CPU_Temperature"
sensor_id_CPU_Load="6062/device/f41c2cd1-a05e-462e-b674-4b00b8addc4c/sensor/CPU_Load"

post_to_devicehub $sensor_id_CPU_Temperature $temp
post_to_devicehub $sensor_id_CPU_Load $LOADAVG
