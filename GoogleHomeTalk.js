const googlehome = require('/home/pi/google-home/node_modules/google-home-notifier')
googlehome.ip(process.argv[2]); // GoogleHomeのIPアドレス
googlehome.device(process.argv[3], 'ja');  //  GoogleHome の名前 言語指定
googlehome.notify(process.argv[4], function (res) {
    console.log(res);
});
