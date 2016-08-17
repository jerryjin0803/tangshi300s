--[[
    大家好，我是笨笨，笨笨的笨，笨笨的笨，谢谢！
    这是一个名叫《躺尸三百首》的小游戏。
    因为想学习下 Lua ，最好的方法肯定就是做个小 Demo 啦。
    所以选了 Cocos2dx Quick 3.5 ,第一次接触，对于我这个新人来说感觉满地是坑。
    1、很多人说 3.5 没 3.3 好，是个阉割版。
    2、触控不让玩 Quick 了，太子是 js ，lua 势危。 Quick 3.5 就绝后了，合并入 Cocos2dx 了。逆了天了，我说怎么那么奇怪。看到网上那些3.3搭建环境和上手的教程，都那么人性化。结果3.5坑回来，原来是这个原因。统统向 Cocos2dx 看齐了。
    3、因为我的习惯是边做边学。所以当我知道这一切的时候，已经放弃治疗了。
    4、反正我感觉触控的东西一真不怎么人性化的。搞了几个 IDE 结果招万人唾骂。我只想说，你们的用户体验难到是程序给的解决方案？不过最近这个抄 U3D 的 CocosCreator 感觉好像还行。但愿能抄好。
    5、当然用过 Quick 的凭良心讲不可能喜欢 Cocos2dx 那套搞法，所以泰然网出了个社区版 Quick-Cocos2dx-Community 据说也得到了 Quick 作者的支持。想想下次如果再玩 Lua 估计会选这个版本了。
    6、其实我还是满喜欢 H5 的。毕竟非程序员，还是喜欢轻便的开发环境，还要打包什么的才能分享出去，太不方便了。

--]]

local AdBar = import("..views.AdBar")   -- 官方例子里的广告条，感觉不错，P下图就能用了。所以留着
local BubbleButton = import("..views.BubbleButton") -- 官方例子里的气泡按钮,正好用来当发炮效果
-- local Clouds = import("..views.Clouds") -- 背景上的云层效果

local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
    -- 添加背景图
    -- 在Quick中使用图片有个规则，如果使用的图片是以#开头的话表示是从SpriteFrameCache中读取。如果没有使用#开头的话表示是直接从文件读取。(图片名统一放到 config 里去了)
    self.bg = display.newScale9Sprite(BACKGROUND, display.cx, display.cy, display.size):zorder(0)
    self:addChild(self.bg, -1)
    
    -- -- 创建 云
    -- self.clouds_ = Clouds.new()
    -- self:addChild(self.clouds_,-1) -- 加入场景才会显示出来。

    -- 游戏名称
    self.gameName = display.newSprite(GAMENAME, display.cx, display.cy + 200)
    self:addChild(self.gameName)


    -- 添加广告栏
    self.adBar = AdBar.new()
    self:addChild(self.adBar,0)

    --【按钮】跳转到：选关界面
    cc.ui.UIPushButton.new({normal = STARTBUTTON, pressed = STARTBUTTON_1})
        -- 自身中心为锚点，X：屏幕中心，Y：从底部向上偏移 300
        :align(display.CENTER, display.cx, display.bottom + 300) 
        :addTo(self)
        :onButtonClicked(function()
            audio.playSound(GAME_SFX.tapButton)
            app:enterChooseLevelScene()
        end)

--[[
    --【按钮】跳转到：选关界面 (泡泡版)
    self.startButton = BubbleButton.new({ -- 创建气泡按钮。
            image = STARTBUTTON,
            image1 = STARTBUTTON_1,
            prepare = function() -- 点击后，气泡动画完成前。执行的内容
                audio.playSound(GAME_SFX.tapButton)
                --self.startButton:setButtonEnabled(false)  --这句多余。BubbleButton 类里已经处理了。
            end,
            listener = function() -- 气泡动画播完后执行。
                app:enterChooseLevelScene()
            end,
        })
        -- 自身中心为锚点，X：屏幕中心，Y：从底部向上偏移 300
        :align(display.CENTER, display.cx, display.bottom + 300) 
        :addTo(self)

    --【按钮】跳转到：游戏玩法介绍界面
    cc.ui.UIPushButton.new({normal = ARROWL, pressed = ARROWL_1})
        :align(display.LEFT_TOP, display.left - 0, display.top - 0) -- 对齐左上角，偏移量0,0
        :onButtonClicked(function(sender)   -- 点击事件
            sender.target:setVisible(false) -- 先隐藏此按钮。这样切换的动画好看点
            audio.playSound(GAME_SFX.backButton)    -- 播放音效
            app:enterGamesHelpScene() --切换场景
        end)
        :addTo(self)
        -- 不透明度在指定时间内，从 0 到 70
        :setOpacity(0):fadeTo(SceneTransitionTime * 3, ArrarImgOpacity) 
--]]
    --【按钮】跳转到：笨笨简介界面
    cc.ui.UIPushButton.new({normal = ARROWR, pressed = ARROWR_1})
        :align(display.RIGHT_TOP, display.right + 0, display.top - 0)
        :onButtonClicked(function(sender)
            sender.target:setVisible(false) -- 先隐藏此按钮。这样切换的动画好看点
            audio.playSound(GAME_SFX.backButton)
            app:enterAboutScene()
        end)
        :addTo(self)
        -- 不透明度在指定时间内，从 0 到 70
        :setOpacity(0):fadeTo(SceneTransitionTime * 3, ArrarImgOpacity) 


    -- 初始化相关数据
    -- self:init()

end

-- function MainScene:init()
-- end

function MainScene:onEnter()
    -- 进入场景开始播放背景音乐
    audio.playMusic(GAME_MUSIC.bgm_2, true)
end

-- function MainScene:onExit()
    -- 退出场景关闭当前背景音乐
    -- audio.stopMusic(false)
-- end

return MainScene
