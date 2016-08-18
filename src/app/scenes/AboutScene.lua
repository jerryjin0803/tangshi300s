--[[
    about 界面，在主界面右侧
--]]

local AdBar = import("..views.AdBar")
local Clouds = import("..views.Clouds") -- 背景上的云层效果

local AboutScene = class("AboutScene", function()
    return display.newScene("AboutScene")
end)

function AboutScene:ctor()
    -- 创建一个精灵作为背景图. plist里的图片名字前加 # 区分(图片名统一放到 config 里去了)
	self.bg = display.newScale9Sprite(BACKGROUND, display.cx, display.cy, display.size)
    self:addChild(self.bg, -1)

    -- 添加广告条。当签名用了.哈哈
	self.adBar = AdBar.new()
	self:addChild(self.adBar)
	
    -- 二维码  
    self.twoDimensionCode_ = display.newSprite(
        "twoDimensionCode.png", 
        display.cx, 
        display.cy + 150
        )
    self:addChild(self.twoDimensionCode_)

    -- 介绍文档区
    cc.ui.UILabel.new({
            UILabelType = 2, text = "扫我！扫我！", size = 50 ,font = "KaiTi"})
        :align(display.CENTER, display.cx, display.cy -50)
        :addTo(self)

    --返回按钮
    cc.ui.UIPushButton.new({normal = ARROWL, pressed = ARROWL_1})
        :align(display.LEFT_TOP, display.left + 0, display.top - 0)
        :onButtonClicked(function(sender)
            sender.target:setVisible(false) -- 先隐藏此按钮。这样切换的动画好看点
            audio.playSound(GAME_SFX.backButton)
            app:enterMainScene("slideInL")
        end)
        :addTo(self)
        -- 不透明度在指定时间内，从 0 到 70
        :setOpacity(0):fadeTo(BUTTONFADEIN, ARRARIMGOPACITY) 

    -- 创建 云
    self.clouds_ = Clouds.new(5,.15)
    self:addChild(self.clouds_,-1) -- 加入场景才会显示出来。
end

function AboutScene:onEnter()
    -- 进入场景开始播放背景音乐
    audio.playMusic(GAME_MUSIC.bgm_3, true)
end

-- function AboutScene:onExit()
    -- 退出场景关闭当前背景音乐
    -- audio.stopMusic(false)
-- end

return AboutScene
