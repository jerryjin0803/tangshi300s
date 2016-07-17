
require("config")
require("cocos.init")
require("framework.init")


local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)
end

--初始化一些数据
function MyApp:run()
    cc.FileUtils:getInstance():addSearchPath("res/")
    display.addSpriteFrames(GAME_TEXTURE_DATA_FILENAME, GAME_TEXTURE_IMAGE_FILENAME)
    -- self:enterScene("MainScene")
    MyApp.EnterMainScene()
end

--进入主场景
function MyApp.EnterMainScene()
    -- local BenchmarkScene = require("app.scenes.BenchmarkScene")
    -- display.replaceScene(BenchmarkScene.new())
    MyApp:enterScene("BenchmarkScene", nil, "fade", 0.6, display.COLOR_WHITE)

end

-- 全局变量用于一些公共的控制
game = {}

--退出游戏
function game.exit()
    os.exit()
end

return MyApp
