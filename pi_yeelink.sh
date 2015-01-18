#注意这句执行的是/mnt/tmp/下的文件，而不是home/pi/
sudo python /mnt/tmp/temp.py
curl --request POST --data-binary @"/mnt/tmp/temp.txt" --header "U-ApiKey:86493543ff87c604bc56fac6a89aee56" --verbose http://api.yeelink.net/v1.0/device/15028/sensor/25761/datapoints
temp=`/opt/vc/bin/vcgencmd measure_temp | cut -c 6-7`
