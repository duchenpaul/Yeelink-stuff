tfile = open("/sys/class/thermal/thermal_zone0/temp")
text = tfile.read()
tfile.close()
temperature = float(text)/1000
res = '{"value":%.1f}' %temperature
output = open('/mnt/tmp/temp.txt', 'w')
output.write(res)
output.close
