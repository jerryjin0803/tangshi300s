local Levels = import("..data.Levels")-- 关卡等级数据，诗人诗句之类的
local BubbleButton = import("..views.BubbleButton")-- 官方例子里的气泡按钮,正好用来当发炮效果
local AdBar = import("..views.AdBar")

local ChooseLevelScene = class("ChooseLevelScene", function()
    return display.newScene("ChooseLevelScene")
end)

function ChooseLevelScene:ctor()
    --添加资源搜索路径
    cc.FileUtils:getInstance():addSearchPath("res/")
    cc.FileUtils:getInstance():addSearchPath("res/charactar/")

    -- 创建一个精灵作为背景图. plist里的图片名字前加 # 区分(图片名统一放到 config 里去了)
    local bg = display.newScale9Sprite(BACKGROUND, display.cx, display.cy, display.size)
    -- make background sprite always align top
    bg:setPosition(display.cx, display.top - bg:getContentSize().height / 2)
    self:addChild(bg)

    self.adBar = AdBar.new()
    self:addChild(self.adBar)

    --关卡名称
    self.LevelNamelabel = cc.ui.UILabel.new({
        UILabelType = 2,
        text = BOSS_LIST[1],
        size = 64})
    :align(display.CENTER, display.cx, display.top-150)
    self:addChild(self.LevelNamelabel)

    -- 创建选择关卡用的 PageView
    self:createPageView()

    --【开始游戏按钮】跳转到：游戏场景
    self.gameStartButton = BubbleButton.new({
            image = "#MenuSceneStartButton.png",
            -- sound = GAME_SFX.tapButton
            prepare = function()
                -- 上面的sound 没用。 BubbleButton 里没有 audio.playSound(params.sound)
                -- 想了想，还是不要动它，在这里播好了。
                audio.playSound(GAME_SFX.tapButton)
            end,
            listener = function()       
                --[[ 
                这 app TMD是怎么来的。为什么 MyApp 类可以这样调用？
                因为 MyApp 继承自 cc.mvc.AppBase 这个类。
                它的构造函数最后一句是：app = self 一个全局变量
                进入游戏场景，这里传入了关卡 ID
                --]]
                app:enterPlayScene(self.pv:getCurPageIdx())
            end,
        })
        :align(display.CENTER, display.cx, display.bottom + 200)
        :addTo(self)

        --返回按钮
    cc.ui.UIPushButton.new({normal = ARROWL, pressed = ARROWL_1})
        :align(display.LEFT_TOP, display.left +10 , display.top - 10)
        :onButtonClicked(function()
            audio.playSound(GAME_SFX.backButton)
            app:enterMainScene()
        end)
        :addTo(self)
        -- 不透明度在指定时间内，从 0 到 70
        :setOpacity(0):fadeTo(SceneTransitionTime * 3, ArrarImgOpacity) 

end

-- 创建选择关卡用的 PageView
function ChooseLevelScene:createPageView()
    -- 创建 UIPageView 用于装载关卡BOSS形象
    self.pv = cc.ui.UIPageView.new {
            viewRect = cc.rect(40, 300, 560, 500), -- 视图区域范围
            column = 1, row = 1, -- 1行1列
            padding = {left = 20, right = 20, top = 20, bottom = 20}, -- 上下左右的填充距离
            columnSpace = 0, rowSpace = 0, -- 列间距，行间距
            bCirc =true } -- 翻页到尽头循环
        :onTouch(handler(self, self.touchListener)) --监听touch事件
        :addTo(self)

    -- 创建 item (BOSS形象)。 加载所有关卡人物,到关卡列表。
    for k, v in ipairs(GAME_CHARACTAR) do
        --print("k:"..k.."v:"..v)
        local item = self.pv:newItem()

        --创建关卡人物精灵
        local content = display.newSprite(v)
        --print("图片坐标在：x[".. item:getPositionX() .."]y["..item:getPositionY().."]")
        --print("中心在："..display.cx .. "图片宽一半："..content:getContentSize().width/2)
        content:setPosition(display.cx - content:getContentSize().width/4, display.c_top/2)
        item:addChild(content)  -- 添加关卡人物精灵到 item 中

        self.pv:addItem(item)  -- 添加 item 到 UIPageView 中      
    end
    self.pv:reload() --刷新 UIPageView

end



-- 触控相应事件【翻页】
function ChooseLevelScene:touchListener(event)
    -- dump(event, "ChooseLevelScene - event:")

    -- 翻页音效
    audio.playSound(GAME_SFX.voltiSound)
    
    --调用刷新界面函数
    self:refresh(event.pageIdx)
end

--每当翻页，刷新数据
function ChooseLevelScene:refresh(pageIdx)
    -- print("------------------当前页的id是： "..pageIdx)
    -- print("--------- BOSS "..self.pv:getCurPageIdx(),BOSS_LIST[pageIdx], "---------")

    -- 显示对应的BOSS名称
    self.LevelNamelabel:setString(BOSS_LIST[pageIdx])
end

return ChooseLevelScene
