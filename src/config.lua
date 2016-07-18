
-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
DEBUG = 2

-- display FPS stats on screen
DEBUG_FPS = false

-- dump memory info every 10 seconds
DEBUG_MEM = false

-- load deprecated API
LOAD_DEPRECATED_API = false

-- load shortcodes API
LOAD_SHORTCODES_API = true

-- screen orientation
CONFIG_SCREEN_ORIENTATION = "portrait"

-- design resolution
CONFIG_SCREEN_WIDTH  = 640
CONFIG_SCREEN_HEIGHT = 960

-- auto scale mode
CONFIG_SCREEN_AUTOSCALE = "FIXED_WIDTH"

-- sounds
GAME_SFX = {
    tapButton      = "sfx/TapButtonSound.mp3",
    backButton     = "sfx/BackButtonSound.mp3",
    flipCoin       = "sfx/ConFlipSound.mp3",
    levelCompleted = "sfx/LevelWinSound.mp3",
    voltiSound	   = "sfx/VoltiSound.mp3",
}

-- charactar
GAME_CHARACTAR = {
    "charactar/char_001.png",
    "charactar/char_002.png",
    "charactar/char_003.png",
    "charactar/char_004.png",
}


GAME_TEXTURE_DATA_FILENAME  = "AllSprites.plist"
GAME_TEXTURE_IMAGE_FILENAME = "AllSprites.png"

-- charactar
BOSS_LIST = {
    "李白","杜甫","白居易","李商隐"
}

POETRY_DATA = {
    李白 = {
        {"花间一壶酒","独酌无相亲"},
        {"醒时同交欢","醉后各分散"},
        {"床前明月光","疑是地上霜"},
        {"举杯邀明月","对影成三人"},
        {"我歌月徘徊","我舞影零乱"},
        {"醒时同交欢","醉后各分散"},
        {"床前明月光","疑是地上霜"},
        {"举头望明月","低头思故乡"},
        {"人生得意须尽欢","莫使金樽空对月"},
        {"天生我材必有用","千金散尽还复来"},
        {"古来圣贤皆寂寞","唯有饮者留其名"},
        {"五花马","千金裘"},
        {"呼儿将出换美酒","与尔同销万古愁"},
        {"日照香炉生紫烟","遥看瀑布挂前川"},
        {"飞流直下三千尺","疑是银河落九天"},
        {"李白乘舟将欲行","忽闻岸上踏歌声"},
        {"桃花潭水深千尺","不及汪伦送我情"},
        {"蜀道之难","难于上青天"},
        {"尔来四万八千岁","不与秦塞通人烟"},
        {"西当太白有鸟道","可以横绝峨眉巅"},
        {"长相思","在长安"},
        {"金樽清酒斗十千","玉盘珍馐值万钱"},
        {"欲渡黄河冰塞川","将登太行雪满山"},
        {"行路难","行路难"},
        {"故人西辞黄鹤楼","烟花三月下扬州"},
        {"孤帆远影碧空尽","惟见长江天际流"},
        {"岑夫子丹丘生","将进酒杯莫停"},
        {"青天有月来几时","我今停杯一问之"},
        {"今人不见古时月","今月曾经照古人"},
    },
    杜甫 = {
        {"朱门酒肉臭","路有冻死骨"},
        {"暮投石壕村","有吏夜捉人"},
        {"国破山河在","城春草木深"},
        {"此曲只应天上有","人间能得几回闻"},    
    },
    白居易 = {
        {"杨家有女初长成","养在深闺人未识"},
        {"回眸一笑百媚生","六宫粉黛无颜色"},
    },
    李商隐 = {
        {"沧海月明珠有泪","蓝田日暖玉生烟"},
        {"此情可待成追忆","只是当时已惘然"},
        {"君问归期未有期","巴山夜雨涨秋池"},
    },
}
