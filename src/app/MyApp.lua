
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

function MyApp:enterMainScene()
    self:enterScene("MainScene", nil, "fade", 0.6, display.COLOR_WHITE)
end

function MyApp:enterMoreGamesScene()
    self:enterScene("MoreGamesScene", nil, "fade", 0.6, display.COLOR_WHITE)
end

function MyApp:enterChooseLevelScene()
    self:enterScene("ChooseLevelScene", nil, "fade", 0.6, display.COLOR_WHITE)
end

function MyApp:playLevel(levelIndex)
    self:enterScene("PlayLevelScene", {levelIndex}, "fade", 0.6, display.COLOR_WHITE)
end

function MyApp:enterAboutScene()
    self:enterScene("AboutScene", nil, "fade", 0.6, display.COLOR_WHITE)
end

function MyApp:enterPlayScene(levelIndex)
    self:enterScene("PlayScene", {levelIndex}, "fade", 0.6, display.COLOR_WHITE)
end
-- appInstance = MyApp
return MyApp
