const GoogleHomePlayer = require("/home/pi/google-home/node_modules/google-home-player")
const ip = process.argv[2]
const lang = "ja"
const googleHome = new GoogleHomePlayer(ip, lang);

(async () => {
    await googleHome.say(process.argv[4], lang, false)
    // await googleHome.say("first text")
    // await googleHome.say("second text", "en") // 第二引数で言語を指定
    // await googleHome.say("final text", "en", true) // 第三引数でslowの有効/無効を指定
})()
