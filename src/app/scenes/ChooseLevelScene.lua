local Levels = import("..data.Levels")
local BubbleButton = import("..views.BubbleButton")

local ChooseLevelScene = class("ChooseLevelScene", function()
    return display.newScene("ChooseLevelScene")
end)

function ChooseLevelScene:ctor()
    --添加资源搜索路径
    cc.FileUtils:getInstance():addSearchPath("res/")
    cc.FileUtils:getInstance():addSearchPath("res/charactar/")

    --设置界面背景
    local bg = display.newSprite("#OtherSceneBg.png")
    -- make background sprite always align top
    bg:setPosition(display.cx, display.top - bg:getContentSize().height / 2)
    self:addChild(bg)

    self:createPageView()

    --关卡名称
    self.LevelNamelabel = cc.ui.UILabel.new({
        UILabelType = 2,
        text = BOSS_LIST[1],
        size = 64})
    :align(display.CENTER, display.cx, display.top-150)
    self:addChild(self.LevelNamelabel)

    --【开始游戏按钮】跳转到：简介场景
    self.gameStartButton = BubbleButton.new({
            image = "#MenuSceneStartButton.png",
            sound = GAME_SFX.tapButton,
            prepare = function()
                audio.playSound(GAME_SFX.tapButton)
            end,
            listener = function()            
                app:enterPlayScene(self.pv:getCurPageIdx())
            end,
        })
        :align(display.CENTER, display.cx, display.bottom + 200)
        :addTo(self)

        --返回按钮
    cc.ui.UIPushButton.new("#BackButton.png")
        :align(display.LEFT_TOP, display.left +10 , display.top - 10)
        :onButtonClicked(function()
            audio.playSound(GAME_SFX.backButton)
            app:enterMainScene()
        end)
        :addTo(self)

end

-- 创建关卡
function ChooseLevelScene:createPageView()
    --创建 UIPageView 用于装载关卡BOSS形象
    self.pv = cc.ui.UIPageView.new {
            viewRect = cc.rect(40, 300, 560, 500),
            column = 1, row = 1,
            padding = {left = 20, right = 20, top = 20, bottom = 20},
            columnSpace = 0, rowSpace = 0,
            bCirc =true }
        :onTouch(handler(self, self.touchListener))
        :addTo(self)

    -- add items
    --加载所有关卡人物 —— BOSS形象
    for k, v in ipairs(GAME_CHARACTAR) do
        --print("k:"..k.."v:"..v)
        local item = self.pv:newItem()

        --创建关卡人物精灵
        local content = display.newSprite(v)
        --print("图片坐标在：x[".. item:getPositionX() .."]y["..item:getPositionY().."]")
        --print("中心在："..display.cx .. "图片宽一半："..content:getContentSize().width/2)
        content:setPosition(display.cx - content:getContentSize().width/4, display.c_top/2)
        item:addChild(content)  -- 添加关卡人物精灵到显示对象中

        self.pv:addItem(item)  -- 添加显示对象到容器中      
    end
    self.pv:reload() --刷新 UIPageView

end



-- 触控相应事件【翻页】
function ChooseLevelScene:touchListener(event)
    dump(event, "ChooseLevelScene - event:")
    local listView = event.listView
    if 3 == event.itemPos then
        listView:removeItem(event.item, true)
    else
        -- event.item:setItemSize(120, 80)
    end

    -- 翻页音效
    audio.playSound(GAME_SFX.voltiSound)
    
    --调用刷新界面函数
    self:refresh(event.pageIdx)
end

--每当翻页，刷新数据
function ChooseLevelScene:refresh(pageIdx)
    --print("------------------当前页的id是： "..pageIdx)

    -- 显示对应的BOSS名称
    self.LevelNamelabel:setString(BOSS_LIST[pageIdx])
    print("--------- BOSS "..self.pv:getCurPageIdx(),BOSS_LIST[pageIdx], "---------")
--     用BOSS名称查找对应诗句
--     print_table(POETRY_DATA[BOSS_LIST[pageIdx]], 0)

--     随机显示BOSS的两句诗
--     for k, v in pairs(searchTableByKey(POETRY_DATA, BOSS_LIST[pageIdx])) do   
--         if (type(v) == "table") then
--             print(BOSS_LIST[pageIdx].." : "..v[1].." , "..v[2])  
--         end
--     end  

-- print("----------------",type((searchTableByKey(POETRY_DATA, BOSS_LIST[pageIdx]))))

--     print_table(
--         tableEx_randSort(
--                 searchTableByKey(POETRY_DATA, BOSS_LIST[pageIdx])
--             )
--         )

--     print(string.gsub(tableUnfold(POETRY_DATA,""),",",""))
--     print(string.len(tableUnfold(POETRY_DATA,"")))
end

return ChooseLevelScene
