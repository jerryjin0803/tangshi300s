--[[
    这里是游戏的主场景。
--]]

local PlayModel = import("..models.PlayModel") -- 逻辑层
local PlayView = import("..views.PlayView") -- 官方例子里的气泡按钮,正好用来当发炮效果
local PlayController = import("..controllers.PlayController") -- 官方例子里的气泡按钮,正好用来当发炮效果

local PlayScene = class("PlayScene", function()
    return display.newScene("PlayScene")
end)

function PlayScene:ctor(levelIdx)
    -- 创建 Game 对象负责游戏逻辑部分处理
    self.game_ = PlayModel.new(self,levelIdx)

    -- 创建控制层对象
    self.control_ = PlayController.new(levelIdx)

    -- 创建 playView 对象负责游戏显示(文字卡部分)
    self.playView_ = PlayView.new()
    self:addChild(self.playView_,1) -- 加入场景才会显示出来。

    -- 初始化 PlayController
    self.control_:setModel(self.game_)
    self.control_:setView(self.playView_)
    self.control_:initPlayController()

    -- 创建个前景场层，用来显示弹窗类对象
    PlayScene.FGLayer = display.newLayer()
    :addTo(self, 1) -- 添加到当前场景，深度为 1
    :setVisible(false) -- 默认关掉前景场。要用时再显示出来
    --:setTouchEnabled(false) -- 因为是前景，所以关掉触摸
    --PlayScene.BGLayer = display.newLayer():addTo(self, -1)

    -- 创建一个精灵作为背景图. plist里的图片名字前加 # 区分(图片名统一放到 config 里去了)
    local bg = display.newScale9Sprite(BACKGROUND, display.cx, display.cy, display.size) 
    self:addChild(bg) -- 将背景图加载到场景默认图层 self 中。

    -- -- 例子里带的加载一张图片作为 Title。 不碍事，暂时留着
    -- local title = display.newSprite("#Title.png", display.left + 150, display.top - 50)
    -- title:setScale(0.5)
    -- self:addChild(title)

    --返回按钮
    cc.ui.UIPushButton.new({normal = BACKBUTTON, pressed = BACKBUTTON_1})
        --:setButtonSize(20, 20)    --设置按钮大小
        :align(display.LEFT_TOP, display.left +10 , display.top - 10) 
        :onButtonClicked(function()
            audio.playSound(GAME_SFX.backButton)    -- 播放音效
            app:enterChooseLevelScene() -- 切换场景
        end)
        :addTo(self)
        -- 不透明度在指定时间内，从 0 到 70
        :setOpacity(0):fadeTo(SceneTransitionTime * 3, ArrarImgOpacity + 50) 

--[[调试用：显示上句
self.labelup = cc.ui.UILabel.new({
    UILabelType = 2,
    text = "仄平平仄仄平仄",
    size = 50})
:align(display.CENTER, display.cx, display.top-200)
self:addChild(self.labelup)
--]]

--[[调试用：显示下句 
self.labeldown = cc.ui.UILabel.new({
    UILabelType = 2,
    text = "仄仄平平仄仄平",
    size = 50})
:align(display.CENTER, display.cx, display.top-250)
self:addChild(self.labeldown)
--]]

--[[执行按钮(没用到，暂时留着)
self.goButton = BubbleButton.new({
        image = "#MenuSceneStartButton.png",
        sound = GAME_SFX.tapButton,
        prepare = function()
            audio.playSound(GAME_SFX.tapButton)
        end,
        listener = function()           
            self:showPoetryWord()
        end,
    })
    :align(display.CENTER, display.cx, display.bottom + 200)
    :addTo(self)
    --初始化关卡数据
    self:init(levelIdx)
--]] 

end

function PlayScene:onExit()
    print("------------- PlayScene:onEnter() -------------")
    audio.stopAllSounds() -- 退出场景时终止所以有音效。
end

return PlayScene

