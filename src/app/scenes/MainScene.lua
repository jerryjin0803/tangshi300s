
local AdBar = import("..views.AdBar")
local BubbleButton = import("..views.BubbleButton")

local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
    self.bg = display.newSprite("#MenuSceneBg.png", display.cx, display.cy):zorder(0)
    self:addChild(self.bg)

    self.adBar = AdBar.new()
    self:addChild(self.adBar)

    --跳转到：多余界面
    self.moreGamesButton = BubbleButton.new({
            image = "#MenuSceneMoreGamesButton.png",
            prepare = function()
                audio.playSound(GAME_SFX.tapButton)
                self.moreGamesButton:setButtonEnabled(false)
            end,
            listener = function()
                app:enterMoreGamesScene()
            end,
        })
        :align(display.CENTER, display.left + 150, display.bottom + 300)
        :addTo(self)

    --跳转到：选关界面
    self.startButton = BubbleButton.new({
            image = "#MenuSceneStartButton.png",
            prepare = function()
                --audio.playSound(GAME_SFX.tapButton)
                self.startButton:setButtonEnabled(false)
            end,
            listener = function()
                app:enterChooseLevelScene()
            end,
        })
        :align(display.CENTER, display.right - 150, display.bottom + 300)
        :addTo(self)

    --跳转到：简介界面
    self.aboutButton = BubbleButton.new({
            image = "#MenuSceneStartButton.png",
            prepare = function()
                audio.playSound(GAME_SFX.tapButton)
                self.startButton:setButtonEnabled(false)
            end,
            listener = function()
                app:enterAboutScene()
            end,
        })
        :align(display.CENTER, display.cx, display.bottom + 600)
        :addTo(self)

    -- 初始化相减数据
    self:init()

end

function MainScene:init()

end

function MainScene:onEnter()
end

return MainScene
