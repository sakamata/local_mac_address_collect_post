#!/bin/bash

# arp-scan でネットワーク上の機器 IP/MACaddress/ベンダーを取得 MACaddressのみ抽出・ソート
macs=$(sudo arp-scan -l --interface eth0 | grep -io '[0-9A-F]\{2\}\(:[0-9A-F]\{2\}\)\{5\}' | sort -u )
echo $macs
# テキストをjson化する。
# ***ToDo*** 他の値をもたせステータスやセキュリティの確保
array=($macs)
json=$(jo "${array[@]}" -a -p)

##### 環境毎にurl 変更を行うこと ######
# curl --tlsv1 -k -v --digest -u "GeekOffice:kogaidan" -F "mac=`cat json.txt`" https://www.livelynk.jp/inport_post/mac_address
curl -F "mac=$json" http://192.168.11.99/inport_post/mac_address
echo "now posted"
