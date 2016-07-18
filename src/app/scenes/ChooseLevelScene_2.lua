
local AdBar = import("..views.AdBar")
local LevelsList = import("..views.LevelsList")

local ChooseLevelScene = class("ChooseLevelScene", function()
    return display.newScene("ChooseLevelScene")
end)

function ChooseLevelScene:ctor()
    --设置界面背景
    local bg = display.newSprite("#OtherSceneBg.png")
    -- make background sprite always align top
    bg:setPosition(display.cx, display.top - bg:getContentSize().height / 2)
    self:addChild(bg)

    --顶部横幅
    local title = display.newSprite("#Title.png", display.cx, display.top - 100)
    self:addChild(title)

    local adBar = AdBar.new()
    self:addChild(adBar)

    --创建关卡列表
    local rect = cc.rect(display.left, display.bottom + 180, display.width, display.height - 280)
    self.levelsList = LevelsList.new(rect)
    self.levelsList:addEventListener("onTapLevelIcon", handler(self, self.onTapLevelIcon))
    self:addChild(self.levelsList)

    --返回按钮
    cc.ui.UIPushButton.new({normal = "#BackButton.png", pressed = "#BackButtonSelected.png"})
        :align(display.CENTER, display.right - 100, display.bottom + 120)
        :onButtonClicked(function()
            audio.playSound(GAME_SFX.backButton)
            app:enterMainScene()
        end)
        :addTo(self)
end

function ChooseLevelScene:onTapLevelIcon(event)
    audio.playSound(GAME_SFX.tapButton)
    app:playLevel(event.levelIndex)
end

function ChooseLevelScene:onEnter()
    self.levelsList:setTouchEnabled(true)
end

return ChooseLevelScene
