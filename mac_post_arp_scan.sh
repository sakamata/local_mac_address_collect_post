#!/bin/bash

ip_head="192.168.1."
post_url="www.livelynk.jp"

macs=$(sudo arp-scan -l --interface wlan0 | grep -io '[0-9A-F]\{2\}\(:[0-9A-F]\{2\}\)\{5\}' | sort -u )

array=($macs)
json=$(jo "${array[@]}" -a -p)
echo ${array[@]}
echo $json
##### 環境毎にurl 変更を行うこと ######
curl --tlsv1 -k -v -F "mac=`echo $json`" https://www.livelynk.jp/inport_post/mac_address

echo "now posted"
#curl -F "mac=`cat json.txt`" http://192.168.1.74/inport_post/mac_address
