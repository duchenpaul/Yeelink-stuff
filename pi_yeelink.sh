#注意这句执行的是/mnt/tmp/下的文件，而不是home/pi/
sudo python /mnt/tmp/temp.py
curl --request POST --data-binary @"/mnt/tmp/temp.txt" --header "U-ApiKey:86493543ff87c604bc56fac6a89aee56" --verbose http://api.yeelink.net/v1.0/device/15028/sensor/25761/datapoints

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


CURTIME=`date +"%Y-%m-%d %H:%M:%S"`
watch_cpu
#LOADAVG=`cat /proc/loadavg | /usr/bin/awk '{print 100*$1}'`
LOADAVG=$cpu_usage
echo '{"timestamp":"'$CURTIME'", "value":'$LOADAVG'}' >/tmp/datafile
/usr/bin/wget -q --post-file=/tmp/datafile --header="U-ApiKey:86493543ff87c604bc56fac6a89aee56" -O /tmp/yeelink http://api.yeelink.net/v1.0/device/15028/sensor/32478/datapoints


temp=`/opt/vc/bin/vcgencmd measure_temp | cut -c 6-7`
curl -v --request POST http://www.lewei50.com/api/V1/gateway/UpdateSensors/01 --data "[{'Name':'S1','Value':'$temp'}]" --header "userkey:2325ed9fb0c94947b18d1a7245a50be4"
#post 到乐联网

curl -v --request POST http://www.lewei50.com/api/V1/gateway/UpdateSensors/01 --data "[{'Name':'S2','Value':'$LOADAVG'}]" --header "userkey:2325ed9fb0c94947b18d1a7245a50be4"
