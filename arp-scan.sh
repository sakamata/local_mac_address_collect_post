#!/bin/bash

# arp-scan でネットワーク上の機器 IPとMACaddressのみ抽出する基本コマンド
# macs=$(sudo arp-scan -l --interface eth0 | grep -io '[0-9A-F]\{2\}\(:[0-9A-F]\{2\}\)\{5\}')
# ips=$(sudo arp-scan -l --interface eth0 | grep -Eio '^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}')

# arp scan でIP mac vendor の出力行のみをテキストに収納する。項目の間はタブスペース区切り
# sortでmacアドレス順に出力、mac重複削除
# sudo arp-scan -l --interface eth0 | grep -i '[0-9A-F]\{2\}\(:[0-9A-F]\{2\}\)\{5\}' | sort -u -t$'\t' -k2 | uniq -f 1 > now.txt

# sudo arp-scan -l --interface eth0 | grep -i '[0-9A-F]\{2\}\(:[0-9A-F]\{2\}\)\{5\}' | sort -u -t$'\t' -k2 | uniq -f 1 > now.txt
sudo arp-scan -l --interface $net | grep -i '[0-9A-F]\{2\}\(:[0-9A-F]\{2\}\)\{5\}' | sort -u -t$'\t' -k2 | uniq -f 1 > now.txt

if test -e "old.txt"; then
    echo "old.txt found."
else
    echo "old.txt NOT found."
    touch old.txt
fi

check=`diff -q now.txt old.txt`
diff -q now.txt old.txt
# 定期POSTで、かつ取得内容が前回と同じ場合は処理を中止する
if [ -z "$check" -a ${trigger} = "everytime" ]; then
   echo "変化無し exitします"
   exit
fi

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
done < ./now.txt

# 改行を配列の区切りとして設定
IFS=$'\n'
vendor=(`echo "${vendor[*]}"`)
macs=($macs)
ips=($ips)
time=$(date +%s)
# sha256 でhash値作成 文末にスペースとハイフンが付くのでawkコマンドで削除
hash=(`echo -n $time$secret | shasum -a 256 | awk '{print $1}'`)

# テキストをjson化する。
json=$(jo status=$trigger hash=$hash time=$time community_id=$community_id router_id=$router_id mac=$(jo "${mac[@]}" -a)  vendor=$(jo "${vendor[@]}" -a))
echo -e $json

##### 環境毎にurl 変更を行うこと ######
#curl --tlsv1 -k -v --digest -u "GeekOffice:kogaidan" -F "json=`cat json.txt`" https://www.livelynk.jp/inport_post/mac_address
curl -F "json=$json" $post_url
cp now.txt old.txt
echo "now posted"
