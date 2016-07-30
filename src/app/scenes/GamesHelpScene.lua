
local AdBar = import("..views.AdBar")

local GamesHelpScene = class("GamesHelpScene", function()
    return display.newScene("GamesHelpScene")
end)

function GamesHelpScene:ctor()
    self.bg = display.newSprite("#MenuSceneBg.png", display.cx, display.cy)
    self:addChild(self.bg)

    self.adBar = AdBar.new()
    self:addChild(self.adBar)

    -- 游戏玩法介绍
    cc.ui.UILabel.new({
            UILabelType = 2, text = "选出你认为对的字，补全诗句！", size = 64})
        :align(display.CENTER, display.cx, display.cy)
        :addTo(self)

    --返回按钮
    cc.ui.UIPushButton.new("#BackButton.png")
        :align(display.CENTER, display.right - 100, display.top - 120)
        :onButtonClicked(function()
            audio.playSound(GAME_SFX.backButton)
            app:enterMainScene("slideInR")
        end)
        :addTo(self)
end

return GamesHelpScene
