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
        :align(display.CENTER, display.right - 100, display.bottom + 120)
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

--每当翻页，刷新数据
function ChooseLevelScene:refresh(pageIdx)
    --print("------------------当前页的id是： "..pageIdx)

    -- 显示对应的BOSS名称
    self.LevelNamelabel:setString(BOSS_LIST[pageIdx])
    -- 用BOSS名称查找对应诗句
    --print_table(POETRY_DATA[BOSS_LIST[pageIdx]], 0)

    --随机显示BOSS的两句诗
    -- for k, v in pairs(searchTableByKey(POETRY_DATA, BOSS_LIST[pageIdx])) do   
    --     if (type(v) == "table") then
    --         print(BOSS_LIST[pageIdx].." : "..v[1].." , "..v[2])  
    --     end
    -- end  

-- print("----------------",type((searchTableByKey(POETRY_DATA, BOSS_LIST[pageIdx]))))

    -- print_table(
    --     tableEx_randSort(
    --             searchTableByKey(POETRY_DATA, BOSS_LIST[pageIdx])
    --         )
    --     )

    -- print(string.gsub(tableUnfold(POETRY_DATA,""),",",""))
    -- print(string.len(tableUnfold(POETRY_DATA,"")))
    print("------------------", self.pv:getCurPageIdx())

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

-- -- 按 key 找值
-- function searchTableByKey(t, key)  
--     -- 遍历表 t
--     for k, v in pairs(t) do 
--         -- 如果是要找 key，把值返回
--         if k == key then
--             return v
--         end

--         -- 如果值是一个"表" 
--         if (type(v) == "table") then 
--             searchTableByKey(v, key) -- 递归调用  
--         end
--     end

--     return {李白={":你妹的啥也没有!"}}
-- end  

-- -- 递归遍历表，打印出内容
-- function print_table(t, i)  
--     local indent ="" -- i缩进，当前调用缩进 
--     local i = i or 0 -- 如果未进来，默认为 0
--     for j = 0, i do   
--         indent = indent .. "    " 
--     end  
--     for k, v in pairs(t) do   
--         if (type(v) == "table") then -- type(v) 当前类型时否table 如果是，则需要递归，  
--             print(indent .. "< " .. k .. " is a table />")  
--             print_table(v, i + 1) -- 递归调用  
--             print(indent .. "/> end table ".. k .. "/>")  
--         else -- 否则直接输出当前值  
                  
--             print(indent .. "<" .. k .. "=" .. v.."/>")  
--         end  
--     end  
-- end  

-- -- 对表进行随机排序
-- function tableEx_randSort(my_table)
--     -- if (type(my_table) == "table") then
--     --     print("----------------传进来的是表！----------------")  
--     -- else
--     --     print("----------------传进来的是 >> "..my_table)  
--     -- end

--     -- --随机播种子
--     math.randomseed(tostring(os.time()):reverse():sub(1, 6))  
    
--     local tempValue
--     local randNumber
--     local tableLen = table.maxn(my_table)

--     --填充数组
--     for i=1, tableLen do
--         randNumber = math.random(1,tableLen)--生成随机数

--         --将当前下标 i 的内容与随机数 randNumber 下标对应的内容交换
--         tempValue = my_table[randNumber]
--         my_table[randNumber] = my_table[i]
--         my_table[i] = tempValue
  
--     end

--     -- 查看排序后的结果
--     --print_table(my_table)

--     return my_table
-- end

-- -- 在下句中，选出要填的字。（个数与难度相关）
-- function chooseSomeWord(my_table)
--     -- if (type(my_table) == "table") then
--     --     print("----------------传进来的是表！----------------")  
--     -- else
--     --     print("----------------传进来的是 >> "..my_table)  
--     -- end

--     -- --随机播种子
--     math.randomseed(tostring(os.time()):reverse():sub(1, 6))  
    
--     local tempValue
--     local randNumber
--     local tableLen = table.maxn(my_table)

--     --填充数组
--     for i=1, tableLen do
--         randNumber = math.random(1,tableLen)--生成随机数

--         --将当前下标 i 的内容与随机数 randNumber 下标对应的内容交换
--         tempValue = my_table[randNumber]
--         my_table[randNumber] = my_table[i]
--         my_table[i] = tempValue
  
--     end

--     -- 查看排序后的结果
--     for k, v in pairs(my_table) do
--         print(k.." : "..v[1]..","..v[2])
--     end  

--     return my_table
-- end

-- -- 取出诗句
-- function getPoetry(my_table)
-- -- local title = table.concat{tbl,":"}
-- -- print("\n\n"..title.."\n\n")
-- -- print("----------------------",table.concat(POETRY_DATA2["李白"], ":"))
-- -- print(string.split(title, "/"))
-- -- local poetry = table.concat{POETRY_DATA["李白"],","}
-- print("----------------------",table.concat(POETRY_DATA["李白"], ""))
-- print("----------------------",POETRY_DATA["李白"][1])
-- -- print("poetry 是 ".. type(poetry)..poetry[1],poetry[2])

-- -- print("------------------",type(table.concat{POETRY_DATA["李白"],":"}))
-- --url转码
-- -- print(string.urlencode("人"))
-- -- print(string.urldecode("%E4%BA%BA"))
-- end

-- -- 取出诗句
-- function tableUnfold(my_table, delimiter)
--     local delimiter = delimiter or "," -- 默认为逗号分隔
--     local tempStr = "" --临时变量用来存字符串

--     --tableUnfold
--     for k, v in pairs(my_table) do
--         if (type(v[1]) == "table") then -- type(v) 当前类型时否table 
--         --如果是，则需要递归，  
--             tableUnfold(v) -- 递归调用  
--         else -- 否则拼接字符串  
--             tempStr = tempStr..delimiter..table.concat(v, delimiter)   
--         end  
--     end

--     return tempStr
-- end


--     POETRY_table = {}
--     POETRY_number = 1
-- -- 显示上句
-- function  showPoetryUp(my_table, table_Key)

--     POETRY_table = tableEx_randSort(
--             searchTableByKey(my_table, table_Key)
--     )

--     print(POETRY_table[POETRY_number])

-- end

return ChooseLevelScene
