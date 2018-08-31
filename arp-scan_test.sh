#!/bin/bash

# ***ToDo*** 取得した内容が前回と同じ場合は処理を中止


# arp-scan でネットワーク上の機器 IPとMACaddressのみ抽出する基本コマンド
# macs=$(sudo arp-scan -l --interface eth0 | grep -io '[0-9A-F]\{2\}\(:[0-9A-F]\{2\}\)\{5\}')
# ips=$(sudo arp-scan -l --interface eth0 | grep -Eio '^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}')

# arp scan でIP mac vendor の出力行のみをテキストに収納する。項目の間はタブスペース区切り
# sortでmacアドレス順に出力
sudo arp-scan -l --interface eth0 | grep -i '[0-9A-F]\{2\}\(:[0-9A-F]\{2\}\)\{5\}' | sort -u -t$'\t' -k2 > res.txt

while read line
do
    # テキスト1行内をタブ区切り毎を配列に収納
    # Thanks! https://qiita.com/ymdymd/items/0ff295b78ca744b69a0e
    eval ARRAY=("$(sed -e "s/'/'\\\\''/g" -e "s/\t/'\t'/g" -e "s/^/'/" -e "s/$/'/" <<< "$line")")
    # 配列変数macに値を追加、macの配列を作る
    mac+=(`echo $line | grep -io '[0-9A-F]\{2\}\(:[0-9A-F]\{2\}\)\{5\}'`)
    # 配列変数macに値を追加、ipの配列を作る
    ip+=(`echo $line | grep -Eio '^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}'`)
    # 3番目の要素 vendorを配列変数に追加
    vendor+=("${ARRAY[2]}")
done < ./res.txt

IFS=$'\n'
array_mac=(`echo "${mac[*]}"`)
echo "${array_mac[*]}"

array_ip=(`echo "${ip[*]}"`)
echo "${array_ip[*]}"

array_vendor=(`echo "${vendor[*]}"`)
echo "${array_vendor[*]}"


# テキストをjson化する。
# ***ToDo*** 他の値をもたせステータスやセキュリティの確保
macs=($macs)
ips=($ips)

# 改行付きでecho出力
# echo -e "$json"
community_id=GeekOfficeEbisu
router_id=1
time=$(date +%s)
secret=hoge
# hash値作成 文末にスペースとハイフンが付くのでawkコマンドで削除
hash=(`echo -n $time$secret | shasum -a 256 | awk '{print $1}'`)

json=$(jo status=ok hash=$hash time=$time community_id=$community_id router_id=$router_id mac=$(jo "${mac[@]}" -a)  vendor=$(jo "${vendor[@]}" -a))
# echo $hash
echo -e $json


##### 環境毎にurl 変更を行うこと ######
# curl --tlsv1 -k -v --digest -u "GeekOffice:kogaidan" -F "mac=`cat json.txt`" https://www.livelynk.jp/inport_post/mac_address
# curl -F "mac=$json" http://192.168.11.99/inport_post/mac_address
# echo "now posted"


# hash確認、PHPでの検証サンプル
# $a = '1535568589';
# $b = 'hoge';
# $hoge = hash('sha256',$a.$b);
# echo $hoge;
