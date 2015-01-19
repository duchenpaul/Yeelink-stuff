#!/bin/sh 

#20140524pm修改
#增加硬盘启停次数、硬盘通电时间、硬盘通电次数、实时网速、内存使用率
#对内存使用率的公式进行修改，更符合linux系统。内存使用率(MEMUsedPerc)=100*(MemTotal-MemFree-Buffers-Cached)/MemTotal
#修正网速显示，增加上传下载网速
CURTIME=`date +"%Y-%m-%dT%H:%M:%S"`                        
echo $CURTIME "Yeelink started" >>/data/usr/log/yeelink.log
sleep 30                                                                                         
while [ 1 ];do                                                                                   
CURTIME=`date +"%Y-%m-%dT%H:%M:%S"`                                                              
PCBTEMP=`/usr/sbin/readtmp | /usr/bin/awk '{print $2}'`                                          
DISKTEMP=`/usr/sbin/smartctl -A /dev/sda | grep Temperature_Celsius | /usr/bin/awk '{print $10}'`
FANSPEED=`/usr/sbin/readfanspeed | /usr/bin/awk '{print $3}' | /bin/sed 's/Speed=//g'`           
LOADAVG=`cat /proc/loadavg | /usr/bin/awk '{print 100*$1}'`                                          
NETSPEEDRX=`sar -n DEV 1 1 | grep pppoe-wan | grep -v '^Average' | /usr/bin/awk '{print $5}'`     
NETSPEEDTX=`sar -n DEV 1 1 | grep pppoe-wan | grep -v '^Average' | /usr/bin/awk '{print $6}'` 
#MEMUsedPerc=`free -m|grep "Mem:"|awk '{printf("%2.2f\n",$3 * 100/$2)}'`      
MEMUsedPerc=`free -m|grep "Mem:"|awk '{printf("%2.2f\n",100*($2-$4-$6-$7)/$2)}'`
LoadCycleCount=`/usr/sbin/smartctl -a /dev/sda4 | grep Load_Cycle_Count | /usr/bin/awk '{print $10}'`
Power_On_Hours=`/usr/sbin/smartctl -a /dev/sda4 | grep Power_On_Hours | /usr/bin/awk '{print $10}'`
Power_Cycle_Count=`/usr/sbin/smartctl -a /dev/sda4 | grep Power_Cycle_Count | /usr/bin/awk '{print $10}'`

echo $CURTIME $PCBTEMP $DISKTEMP $FANSPEED $LOADAVG $NETSPEEDRX $NETSPEEDTX $MEMUsedPerc $LoadCycleCount $Power_On_Hours $Power_Cycle_Count >>/tmp/log/yeelink.log

if [ $PCBTEMP -ge 0 ]
then
echo '{"timestamp":"'$CURTIME'", "value":'$PCBTEMP'}' >/tmp/datafile
/usr/bin/wget -q --post-file=/tmp/datafile --header="U-ApiKey: 你的api号" -O /tmp/yeelink 你的传感器地址1--主板温度
fi

echo '{"timestamp":"'$CURTIME'", "value":'$DISKTEMP'}' >/tmp/datafile
/usr/bin/wget -q --post-file=/tmp/datafile --header="U-ApiKey: 你的api号" -O /tmp/yeelink 你的传感器地址2-硬盘温度

echo '{"timestamp":"'$CURTIME'", "value":'$FANSPEED'}' >/tmp/datafile
/usr/bin/wget -q --post-file=/tmp/datafile --header="U-ApiKey: 你的api号" -O /tmp/yeelink 你的传感器地址3-风扇速度

echo '{"timestamp":"'$CURTIME'", "value":'$LOADAVG'}' >/tmp/datafile
/usr/bin/wget -q --post-file=/tmp/datafile --header="U-ApiKey: 你的api号" -O /tmp/yeelink 你的传感器地址4-负载

echo '{"timestamp":"'$CURTIME'", "value":'$NETSPEEDRX'}' >/tmp/datafile
/usr/bin/wget -q --post-file=/tmp/datafile --header="U-ApiKey: 你的api号" -O /tmp/yeelink 你的传感器地址5-下载网速

echo '{"timestamp":"'$CURTIME'", "value":'$MEMUsedPerc'}' >/tmp/datafile
/usr/bin/wget -q --post-file=/tmp/datafile --header="U-ApiKey: 你的api号" -O /tmp/yeelink 你的传感器地址6-内存使用率

echo '{"timestamp":"'$CURTIME'", "value":'$LoadCycleCount'}' >/tmp/datafile
/usr/bin/wget -q --post-file=/tmp/datafile --header="U-ApiKey: 你的api号" -O /tmp/yeelink 你的传感器地址7-硬盘启停次数

echo '{"timestamp":"'$CURTIME'", "value":'$Power_On_Hours'}' >/tmp/datafile
/usr/bin/wget -q --post-file=/tmp/datafile --header="U-ApiKey: 你的api号" -O /tmp/yeelink 你的传感器地址8-硬盘通电时间

echo '{"timestamp":"'$CURTIME'", "value":'$Power_Cycle_Count'}' >/tmp/datafile
/usr/bin/wget -q --post-file=/tmp/datafile --header="U-ApiKey: 你的api号" -O /tmp/yeelink 你的传感器地址9-硬盘通电次数

echo '{"timestamp":"'$CURTIME'", "value":'$NETSPEEDTX'}' >/tmp/datafile
/usr/bin/wget -q --post-file=/tmp/datafile --header="U-ApiKey: 你的api号" -O /tmp/yeelink 你的传感器地址10-上传网速

sleep 59
done
