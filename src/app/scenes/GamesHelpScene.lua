
local AdBar = import("..views.AdBar")

local GamesHelpScene = class("GamesHelpScene", function()
    return display.newScene("GamesHelpScene")
end)

function GamesHelpScene:ctor()
    self.bg = display.newSprite("#OtherSceneBg.png", display.cx, display.cy)
    self:addChild(self.bg)

    self.adBar = AdBar.new()
    self:addChild(self.adBar)

    -- 游戏玩法介绍
    cc.ui.UILabel.new({
            UILabelType = 2, text = "选出你认为对的字，补全诗句！", size = 64})
        :align(display.CENTER, display.cx, display.cy)
        :addTo(self)

    --返回按钮
    cc.ui.UIPushButton.new({normal = "#BackButton.png", pressed = "#BackButtonSelected.png"})
        :align(display.RIGHT_TOP, display.right - 0, display.top - 0)
        :onButtonClicked(function(sender)
            sender.target:setVisible(false) -- 先隐藏此按钮。这样切换的动画好看点
            audio.playSound(GAME_SFX.backButton)
            app:enterMainScene("slideInR")
        end)
        :addTo(self)
end

-- function AboutScene:onEnter()
-- end

-- function AboutScene:onExit()
-- end

return GamesHelpScene
