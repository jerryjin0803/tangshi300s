
require("config")
require("cocos.init")
require("framework.init")
require("framework.shortcodes")
require("framework.cc.init")

local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)
    self.objects_ = {}
end

function MyApp:run()
    cc.FileUtils:getInstance():addSearchPath("res/")
    display.addSpriteFrames(GAME_TEXTURE_DATA_FILENAME, GAME_TEXTURE_IMAGE_FILENAME)

    -- preload all sounds
    for k, v in pairs(GAME_SFX) do
        audio.preloadSound(v)
    end

    self:enterMainScene()
end

-- 进入游戏主界面
function MyApp:enterMainScene(transitionType)
    local transitionType = transitionType or "fade"
    self:enterScene("MainScene", nil, transitionType, 0.6, display.COLOR_WHITE)
end
-- 进入选关界面
function MyApp:enterChooseLevelScene()
    self:enterScene("ChooseLevelScene", nil, "fade", 0.6, display.COLOR_WHITE)
end
-- 进入游戏场景界面。这里的重点是进入界面时的传参方法
function MyApp:enterPlayScene(levelIndex)
    self:enterScene("PlayScene", {levelIndex}, "fade", 0.6, display.COLOR_WHITE)
end
-- 进入游戏玩法介绍界面
function MyApp:enterGamesHelpScene()
    self:enterScene("GamesHelpScene", nil, "slideInL", 0.6)
end
-- 进入笨笨介绍界面
function MyApp:enterAboutScene()
    self:enterScene("AboutScene", nil, "slideInR", 0.6)
end

-- appInstance = MyApp
return MyApp
