require("config")
require("cocos.init")
require("framework.init")
require("framework.shortcodes")
require("framework.cc.init")

local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)
end

function MyApp:run()
    -- 添加资源搜索的路径
    cc.FileUtils:getInstance():addSearchPath("res/")
    
    -- 加载图集。 大写字母的这些是 config 里定义的全局变量
    -- BOSS动画帧
    display.addSpriteFrames(GAME_TEXTURE_DATA_FILENAME, GAME_TEXTURE_IMAGE_FILENAME)
    -- BOSS形象图 (选关界面用)
    display.addSpriteFrames(CHARACTAR_DATA_FILENAME,CHARACTAR_IMAGE_FILENAME)

    -- preload all sounds 
    -- 预加载所有音效资源。GAME_SFX 是 config 里定义的全局变量
    --但是这会造成开游戏前白屏卡顿几秒。应该改成异步才好
    for k, v in pairs(GAME_SFX) do
        audio.preloadSound(v)
    end

    -- -- 预加载所有音乐资源。GAME_MUSIC 是 config 里定义的全局变量 -- 音乐出慢点好像也无妨
    -- for k, v in pairs(GAME_MUSIC) do
    --     audio.preloadMusic(v)
    -- end

    -- 进入游戏主界面
    self:enterMainScene()
end

-- 进入游戏主界面
function MyApp:enterMainScene(transitionType)
    local transitionType = transitionType or "fade" -- 默认转场特效为淡入淡出 背景然为白色
    self:enterScene("MainScene", nil, transitionType, SceneTransitionTime, display.COLOR_WHITE)
end
-- 进入选关界面
function MyApp:enterChooseLevelScene()
    self:enterScene("ChooseLevelScene", nil, "fade", SceneTransitionTime, display.COLOR_WHITE)
end
-- 进入游戏场景界面。这里的重点是进入界面时的传参方法
function MyApp:enterPlayScene(levelIndex)
    self:enterScene("PlayScene", {levelIndex}, "fade", SceneTransitionTime, display.COLOR_WHITE)
end
-- 进入游戏玩法介绍界面
function MyApp:enterGamesHelpScene()
    -- 新场景从左边滑入。模拟翻页效果
    self:enterScene("GamesHelpScene", nil, "slideInL", SceneTransitionTime)
end
-- 进入笨笨介绍界面
function MyApp:enterAboutScene()
    -- 新场景从右边滑入。模拟翻页效果
    self:enterScene("AboutScene", nil, "slideInR", SceneTransitionTime)
end

-- appInstance = MyApp
return MyApp
