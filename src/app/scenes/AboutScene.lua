
local AdBar = import("..views.AdBar")

local AboutScene = class("AboutScene", function()
    return display.newScene("AboutScene")
end)

function AboutScene:ctor()
	self.bg = display.newSprite("#MenuSceneBg.png", display.cx, display.cy)
    self:addChild(self.bg)

	self.adBar = AdBar.new()
	self:addChild(self.adBar)
	
    -- 介绍文档区
    cc.ui.UILabel.new({
            UILabelType = 2, text = "大家好，我是笨笨，笨笨的笨，笨笨的笨，谢谢！", size = 64})
        :align(display.CENTER, display.cx, display.cy)
        :addTo(self)

    --返回按钮
    cc.ui.UIPushButton.new({normal = "#BackButton.png", pressed = "#BackButtonSelected.png"})
        :align(display.CENTER, display.left + 100, display.top - 120)
        :onButtonClicked(function()
            audio.playSound(GAME_SFX.backButton)
            app:enterMainScene("slideInL")
        end)
        :addTo(self)
end

function AboutScene:onEnter()
end

function AboutScene:onExit()
end

return AboutScene
