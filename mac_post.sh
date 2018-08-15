#!/bin/bash

# ***ToDo*** テキスト記録ではなく変数に入れて処理するようにする

# macs.txtファイルを読み込み、MAC記載あれば、空にしてから処理開始
# 無ければ処理中と想定し処理中止、ファイル1行目に"empty"と記

#. /home/pi/whois/shell/set_var.sh

ip_head="192.168.11."
ip_min=2
ip_max=20
ping_cnt=3
post_url="192.168.11.99"

if [ ! -s "macs.txt" ]; then
    #中身が空なら
    echo "empty!_cron_delay" > macs.txt
    exit 0
else
    : > macs.txt
fi
# IPにpingを送り返ったMACアドレスをgrep抽出、１行毎にテキストに入れる
# -c ping回数
##### 環境毎にIPと範囲の変更を行うこと ######
for ip in `seq $ip_min $ip_max`;do arping -c $ping_cnt $ip_head$ip | grep -io '[0-9A-F]\{2\}\(:[0-9A-F]\{2\}\)\{5\}';done | sort -u >> macs.txt
# テキストをjson化する。
# ***ToDo*** 他の値をもたせステータスやセキュリティの確保
array=(`cat macs.txt`)
jo "${array[@]}" -a -p > json.txt
##### 環境毎にurl 変更を行うこと ######
curl -F "mac=`cat json.txt`" http://$post_url/inport_post/mac_address
# テキストを空にする
#: > macs.txt
