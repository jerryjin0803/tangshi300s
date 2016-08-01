
local AdBar = import("..views.AdBar")   -- 官方例子里的广告条，感觉不错，P下图就能用了。所以留着
local BubbleButton = import("..views.BubbleButton") -- 官方例子里的气泡按钮,正好用来当发炮效果

local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
    -- 添加背景图
    -- 在Quick中使用图片有个规则，如果使用的图片是以#开头的话表示是从SpriteFrameCache中读取。如果没有使用#开头的话表示是直接从文件读取。
    self.bg = display.newSprite("#MenuSceneBg.png", display.cx, display.cy):zorder(0)
    self:addChild(self.bg)

    -- 添加广告栏
    self.adBar = AdBar.new()
    self:addChild(self.adBar)

    --【按钮】跳转到：游戏玩法介绍界面
    cc.ui.UIPushButton.new({normal = "#BackButton.png", pressed = "#BackButtonSelected.png"})
        :align(display.LEFT_TOP, display.left - 0, display.top - 0) -- 对齐左上角，偏移量0,0
        :onButtonClicked(function(sender)   -- 点击事件
            sender.target:setVisible(false) -- 先隐藏此按钮。这样切换的动画好看点
            audio.playSound(GAME_SFX.backButton)    -- 播放音效
            app:enterGamesHelpScene() --切换场景
        end)
        :addTo(self)

    --【按钮】跳转到：选关界面
    self.startButton = BubbleButton.new({ -- 创建气泡按钮。
            image = "#MenuSceneStartButton.png",
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

    --【按钮】跳转到：笨笨简介界面
    cc.ui.UIPushButton.new({normal = "#BackButton.png", pressed = "#BackButtonSelected.png"})
        :align(display.RIGHT_TOP, display.right + 0, display.top - 0)
        :onButtonClicked(function(sender)
            sender.target:setVisible(false) -- 先隐藏此按钮。这样切换的动画好看点
            audio.playSound(GAME_SFX.backButton)
            app:enterAboutScene()
        end)
        :addTo(self)

    -- 初始化相关数据
    -- self:init()

end

-- function MainScene:init()
-- end

-- function MainScene:onEnter()
-- end

return MainScene
