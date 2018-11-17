# README!
本レポジトリは livelynkシステムで、ローカルネットワーク内に設置するRaspberryPi3 modelB の環境設定を行う為のファイルと操作をまとめたものです。

RaspberryPiに本ドキュメントでの各種設定を行うことで、ローカルネットワーク内に接続されたPCやスマホ等の端末のMacアドレスとvendor情報が、定期的に LivelynkにPOSTされるようになります。これによりPOSTされた端末情報から在席確認ができるシステムとなっています。

このドキュメントやコードのサポートは基本しません。   
自分が使うものをついでに公開しておく、という意味合いしかありません。   
もし、ご自分で環境構築されたい、という場合は皆さんの健闘を祈ります。そう、基本お祈りするだけです。ごめんなさい   

このセットアップをする際に必要と思われるスキル
- Linuxサーバーの環境構築の経験があればだいたい大丈夫です。むしろブラッシュアップお願いしたい位です。

たぶん何とかなります。と思われるスキルレベル
- Linuxコマンドを多少は使った事がある cd ls sudo install など
- vimエディタの使用経験 i で入力 :wq で保存？位でなんとか…
- wi-fiルーターやIPについてのごく基本的な知識(自宅のルーターの管理画面見た程度)

本システムは以下の構成で動作確認をしています。  
- ハードウェア  raspberryPi3 model B
- OS  raspbian Version:2.8.2
- ローカルwi-fiネットワーク

準備するもの
- raspberryPi3 model B または raspberryPi3 model B+
- microSDカード 16G程度(あまり古い規格はNG)
- キーボード（USB接続）
- マウス（USB接続）
- モニター
- HDMI～モニター間を接続できるケーブル
- USB電源共有ケーブル（MicroB端子） 2.5A以上の電流が確保できること

準備しておく情報
- 使用するWi-FiのID（SSID）とパスワード
- ルーターの管理画面に入る際のIPアドレス
- Livelynkより提供される以下の情報（これが無いとlivelynk側では動きません）
  - community_id
  - ルーターNo
  - secretキー
  - サービス利用URL一式

データの取得、及びPOSTはcronによる定期動作をしています。   
以下の手順で設定を行います。   
このリポジトリ自体はRaspberryPiの環境設定を行って行く際にcloneしますので、   
まず最初にRaspberryPi本体にOSをインストールする作業を行ってください。

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

イメージが焼けると、microSDカードの名称が（boot)と変更されます。
windows10の場合、『ドライブ X（任意）:を使うにはフォーマットをする必要があります　フォーマットしますか？』   
と、ダイアログがでますが、キャンセルしてください。


# rasipberryPiにmicroSDを入れ起動
モニター、マウス、キーボード、接続後に電源USBを差して起動させます。

## 以下の初期設定をGUI画面で行う
画面の指示に従い以下の設定を行ってください。

- ローカライズ　日本に設定
- 一般user pi の password設定(重要なパスワードなので忘れずに管理してください)
- wi-fi 接続
- 初回 update かなり時間がかかる場合があります。検証時は1時間程でした
- アップデート後に再起動します。
- 再起動後再度ターミナルを開いて次の作業を行います。


# rootユーザーのパスワード変更
pi user に続けて管理者である root user のパスワードも同様に変更します。   
大変重要なパスワードなので、この二つのパスワードは漏洩厳禁で忘れないようにしてください。   

```
sudo passwd root
```
と入力すると、先度同様、の変更処理が行われます。
これで root user のパスワードが変更されました。忘れずに管理してください。


# ターミナルでさらにパッケージ更新と再起動
OSのアップデートを行います。
```
sudo sh -c 'apt update && apt upgrade -y && reboot'
```
しばらく処理が続いた後に、再起動が行われます。


# SSHログインの確立を行う

ホスト側のマシンからログインをして詳細な設定を行う為、SSHログインができる様にします。   
開発環境と、導入環境でIPの設定が異なる事があり、環境構築後、再設定が必要になるケースがあります。   

## SSHを許可する

GUIの画面から設定できます。   
- 画面左上のRaaspberryPiアイコンをクリック   
- 設定を選択   
- Raaspberry Pi の設定をクリック   
- インターフェイスタブをクリック
- SSH: 有効 にチェックして OK ボタンを押す

## IPを固定する

設定前に必要な事
```
ifconfig
```
と入力し、最後の段落に表示された最初の文字を覚えておいてください
```
wlan0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.11.181  netmask 255.255.255.0  broadcast 192.168.11.255
        inet6 xxxx::xxxx:xxx:xxxx:xxxx  prefixlen 64  scopeid 0x20<link>
        ether xx:xx:xx:xx:xx:xx  txqueuelen 1000  (イーサネット)
        .....つづく

```
この例の場合は wlan0 となります。


### /etc/dhcpcd.conf を開き以下の部分をコメントアウトと記載で設定します
ターミナルを開き以下を入力します。   
もし vi エディタに慣れていない場合は、
```
sudo nano /etc/dhcpcd.conf
```
と、nanoエディタを使って編集するのが良いでしょう。   
慣れている方、vim は最初に入ってません、ちょっとクセのあるviを使うか apt でvimを入れてからでお願いします。(vimは後でインストールします)   

エディタが起動したら、以下の部分を編集してください。(下記は例としての値)

/etc/dhcpcd.conf
```
interface wlan0
static ip_address=192.168.1.181/24
static routers=192.168.11.1
static domain_name_servers=192.168.11.1
```
- interface wlan0     # ifconfigで表示された内容 wlan または wlan0 等   
- ip_address          # 本体に設定したい固定IPアドレスを指定（ルータの設定範囲内の値とします）   
- routers             # デフォルトゲートウェイ, ルーターのIPアドレス   
- domain_name_server  # ルーターのIPアドレス   

上書き保存をした後再起動します
```
sudo reboot
```

***


# ここから別マシンからのsshログインでの作業となります。

## sshログインをする方のマシンのコンソールを起動し sshログインをする
同じwi-fiネットワークまたはルーターにつながっている必要があります。
```
ssh pi@192.168.1.181
```
警告と鍵を追加するメッセージが出るので yes と入力してから   
先ほど設定した pi user のパスワードを入力してログインします。   

```
pi@raspberrypi:~ $
```
と表示されればsshログイン完了です。

# vimを入れて最低限の設定をする

以下の操作でvimの基本設定のファイルを作って記述する
```
sudo apt install -y vim
touch ~/.vimrc
vim ~/.vimrc
```
以下を記述
```
syntax on
colorscheme delek
set mouse-=a
```
ハイライト on
カラースキームを見易いものに
ビジュアルモードのマウスを無効に（コピペしやすく）


# Gitをインストールし、このリポジトリをクローンする
既にGitがインストールされているかもしれません
```
sudo apt -y install git
cd
git clone https://github.com/sakamata/local_mac_address_collect_post.git
```
パーミッション変更を無視に設定し、パーミッション変更を行う
```
cd local_mac_address_collect_post
git config core.filemode false
cd
chmod 774 local_mac_address_collect_post/*
```


# 環境構築用のスクリプトを実行させる

PI_setting.sh.example をコピーし、エディタで開き環境変数の設定をする
```
cd local_mac_address_collect_post
cp PI_setting.sh.example PI_setting.sh
```
```
sudo nano PI_setting.sh
```
または
```
sudo vi PI_setting.sh
```


ファイル内の下記の部分に、運営者から指定された環境変数を設定します。   
もし、不明や未設定の項目がある場合は、項目を変更しないまま実行してください。   
動作するには至りませんが、後から設定を変更できます。   
```
# ---------------------------------------------------

# 以下の変数にご自分の環境にあった値を入れてください。
github_name="First-name Family-name"
github_email="username@example.com"

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

# PI_setting.sh を実行する
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
- 次に[設定なし]を選択し enter と操作します

# cronの起動
```
sudo /etc/init.d/cron start
```
# 起動確認
1分程待ってからlivelynkのサイトを表示してください。   
wi-fiに接続された新規ユーザーが表示されていれば、無事設定完了となります。   

***
# 上手く動かない場合   
以下をご確認ください。   
- 入力した、各種環境設変数が間違って入力されていないか？   
  - 以下のファイルを確認し、正しく編集してください。   
  -  /home/pi にある env ファイル   
- windowsで作業した場合の改行をコピーペースト等で張り付けてしまっていないか？   
    注意してください。全く原因の掴めないエラーが出力されますが、この改行が原因ということがあります。   
- アプリケーションやOSのアップデート等でshellスクリプトが最後まで実行されない場合は、停止した箇所から、再度 PI_setting.sh に記載された各種コマンドを入力して、環境設定を完了させてください。   
