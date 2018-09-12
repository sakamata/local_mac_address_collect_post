# README!
本レポジトリは livelynkシステムで、ローカルネットワーク内に設置するRaspberryPI3 modelB の環境設定を行う為のファイルと操作をまとめたものです。

RaspberryPIに本ドキュメントでの各種設定を行うことで、ローカルネットワーク内に接続されたPCやスマホ等の端末のMacアドレスとvendor情報が、定期的に LivelynkにPOSTされるようになります。これによりPOSTされた端末情報から在席確認ができるシステムとなっています。


本システムは以下の構成で動作確認をしています。  
- ハードウェア  raspberryPI3 model B
- OS  raspbian Version:2.8.2
- ローカルwi-fiネットワーク


データの取得、及びPOSTはcronによる定期動作をしています。   
以下の手順で設定を行います。   
このリポジトリ自体はRaspberryPIの環境設定を行って行く際にcloneしますので、   
まず最初にRaspberryPI本体にOSをインストールする作業を行ってください。

***
# OS raspbian をダウンロードする

raspbianを以下のいずれかのサイトより入手します。   
動作確認Version  NOOBS  Version:2.8.2   Release date:2018-06-27   

公式サイト（DLに時間がかかります）   
https://www.raspberrypi.org/downloads/noobs/   

ミラーサイト(比較的早くDLできます)   
http://ftp.jaist.ac.jp/pub/raspberrypi/raspbian/images/raspbian-2018-06-29/   

# microSDカードにOS raspbian を焼く

OSイメージをmicroSDに焼くには様々なソフトがありますが、ETCHERが簡単でお勧めです。   
ETCHER   
https://etcher.io/   
参考:[ラズパイ の OS イメージを焼くときは Etcher が 便利 ＆ UI カッコいい](https://azriton.github.io/2017/11/12/ラズパイのOSイメージを焼くときはEtcherが便利＆UIカッコいい/)   


## wpa_supplicant.conf ファイルの作成   

この設定を行うとRaspberryPIが初回起動時にwi-fi接続を自動でしてくれます。   

本レポジトリの wpa_supplicant.conf.example ファイルをコピーして wpa_supplicant.conf としてデスクトップ等に別名保存します。   

wpa_supplicant.conf をエディタで開き、livelynkを使用するwi-fi環境のSSIDとパスワードを記述します。   
（注意:ファイル編集の際は、改行コードはwindowsのCRLFではなくlinuxのLFになるようにエディタを設定し、保存してください。）   
ssid=" この部分にwi-fiの接続先のタイトル "   
psk=" この部分にパスワード "   
```
country=JP
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
network={
ssid="----Your-WiFi-SSID----"
psk="----PLAIN-PASSPHRASE----"
}
```

RaspberryPIのOSをmicroSDカードに焼いた直後に、設定を記載した   
wpa_supplicant.conf を、microSDの直下のディレクトリにコピーしてください。   
これによりRaspberryPIが初回起動時にwi-fi接続をしてくれます。   


# rasipberryPIにmicroSDを入れ起動
モニター、マウス、キーボード接続後にUSBを差して起動させます。

## 以下の初期設定をGUI画面で行う
画面の指示に従い以下の設定を行ってください。

- ローカライズ　日本に設定
- 一般user pi の password設定
- wi-fi 接続(上記の設定が確立してる場合は不要と思われます)
- 初回 update かなり時間がかかる場合があります。検証時は1時間程でした
- アップデート後に再起動します。
- 再起動後再度ターミナルを開く

# 再起動後パスワード設定を行う
大変重要なパスワードなので、この二つのパスワードは漏洩厳禁で忘れないようにしてください。   


### piユーザー(標準ユーザー)のパスワード変更
```
passwd
```
以下の様にメッセージが出ます

```
pi 用にパスワードを変更中
現在の UNIX パスワード:
```
初期設定のパスワードとして以下を入力します。
```
raspberry
```
続けて設定を行うパスワードを2回入力します。

### rootユーザーのパスワード変更
```
sudo passwd root
pass二回入力
```

# ターミナルでさらにパッケージ更新と再起動
```
sudo sh -c 'apt update && apt upgrade -y && reboot'
```

# SSHログインの確立を行う

ホスト側のマシンからログインをして詳細な設定を行う為、SSHログインができる様にします。   
開発環境と、導入環境でIPの設定が異なる事があり、環境構築後、再設定が必要になるケースがあります。   

## IPを固定する

### /etc/dhcpcd.conf を開き以下の部分をコメントアウトと記載で設定します
```
sudo vi /etc/dhcpcd.conf
```
/etc/dhcpcd.conf
```
interface wlan0
static ip_address=192.168.1.181/24
static routers=192.168.11.1
static domain_name_servers=192.168.11.1
```
- interface wlan0     # wi-fi接続前提 wlan または wlan0 となる   
- ip_address          # 本体に設定したいIPアドレスを指定   
- routers             # デフォルトゲートウェイ, ルーターのIPアドレス   
- domain_name_server  # ルーターのIPアドレス   

再起動する
```
sudo reboot
```

***

# ここから別マシンからのsshログインでの作業となります。

## sshログインをする方のマシンのコンソールを起動し sshログインをする
```
ssh pi@192.168.1.181
```
pi user のパスワード入力でログイン
```
pi@raspberrypi:~ $
```
と表示されればsshログイン完了です。


# Gitをインストールし、このリポジトリをクローンする
```
sudo apt -y install git
cd
git clone https://github.com/sakamata/local_mac_address_collect_post.git
```

# 環境構築用のスクリプトを実行させる

PI_setting.sh.example をコピーし、vimで開き環境変数の設定をする
```
cd local_mac_address_collect_post
cp PI_setting.sh.example PI_setting.sh
sudo vim PI_setting.sh
```

ファイル内の下記の部分に、運営者から指定された環境変数を設定します。
```
# ---------------------------------------------------

# 以下の変数にご自分の環境にあった値を入れてください。
github_name="First-name Family-name"
github_email="username@example.com"
# ifconfig で表示されたネットワークのタイプを設定します。 eth0 wlan 等
net=net_type
# コミュニティ単位で指定された ID をセットします。
community_id=unique_community_id
# ルーターのIDであるユニークの数値をセットします。
router_id=router_number_int
# 指定されたハッシュ値をセットします。
secret=secret_key_hash
# Webアプリ側にPOSTを行うurlを指定します。
post_url=https://www.livelynk.jp/inport_post/mac_address

# ---------------------------------------------------
```

PI_setting.sh を実行する
```
sudo bash PI_setting.sh
```
各種、メッセージが表示されつつ設定が行われます。   
設定が完了するまでしばらく待ちます。   

# cron 実行に必要な postfix のインストール
```
sudo apt -y install postfix
```
インストールの際以下の操作が必要です。
- ダイアログで 了解を選び enter
- 選択肢が出たら [了解]を押します tab enter と操作します
- 次に[設定なし]を選択し、[了解]を押します 上キー 右キー enter と操作します

# cronの起動
```
sudo /etc/init.d/cron start
```

1分程待ってからlivelynkのサイトを表示してください。   
新規ユーザーが表示されていれば無事、設定完了となります。   



test expect sample
```
#!/bin/sh

expect -c "
spawn su -
expect \"パスワード:\"
send  \"pi\n\"
send -- \"ls -la\n\"
interact
"
```
