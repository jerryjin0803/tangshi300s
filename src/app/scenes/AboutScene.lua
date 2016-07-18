
local AdBar = import("..views.AdBar")

local AboutScene = class("AboutScene", function()
    return display.newScene("AboutScene")
end)

function AboutScene:ctor()
	self.bg = display.newSprite("#MenuSceneBg.png", display.cx, display.cy)
    self:addChild(self.bg)

	self.adBar = AdBar.new()
	self:addChild(self.adBar)
	
    cc.ui.UILabel.new({
            UILabelType = 2, text = "Hello, World", size = 64})
        :align(display.CENTER, display.cx, display.cy)
        :addTo(self)

        --返回按钮
    cc.ui.UIPushButton.new({normal = "#BackButton.png", pressed = "#BackButtonSelected.png"})
        :align(display.CENTER, display.right - 100, display.bottom + 120)
        :onButtonClicked(function()
            audio.playSound(GAME_SFX.backButton)
            app:enterMainScene()
        end)
        :addTo(self)
end

function AboutScene:onEnter()
end

function AboutScene:onExit()
end

return AboutScene
