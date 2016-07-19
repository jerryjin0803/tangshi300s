
local Levels = import("..data.Levels")
local Board = import("..views.Board")
local AdBar = import("..views.AdBar")

local PlayScene = class("PlayScene", function()
    return display.newScene("PlayScene")
end)

function PlayScene:ctor(levelIndex)
    local bg = display.newSprite("#PlayLevelSceneBg.png")
    -- make background sprite always align top
    bg:setPosition(display.cx, display.top - bg:getContentSize().height / 2)
    self:addChild(bg)

    local title = display.newSprite("#Title.png", display.left + 150, display.top - 50)
    title:setScale(0.5)
    self:addChild(title)

    print("------------levelIndex-------------",BOSS_LIST[levelIndex])--
    showPoetryUp(POETRY_DATA, BOSS_LIST[levelIndex])
    
    -- local adBar = AdBar.new()
    -- self:addChild(adBar)

    -- local label = cc.ui.UILabel.new({
    --     UILabelType = 1,
    --     text  = string.format("Level: %s", tostring(levelIndex)),
    --     font  = "UIFont.fnt",
    --     x     = display.left + 10,
    --     y     = display.bottom + 120,
    --     align = cc.ui.TEXT_ALIGN_LEFT,
    -- })
    -- self:addChild(label)

    -- self.board = Board.new(Levels.get(levelIndex))
    -- self.board:addEventListener("LEVEL_COMPLETED", handler(self, self.onLevelCompleted))
    -- self:addChild(self.board)

    --返回按钮
    cc.ui.UIPushButton.new({normal = "#BackButton.png", pressed = "#BackButtonSelected.png"})
        :align(display.CENTER, display.right - 100, display.bottom + 120)
        :onButtonClicked(function()
            audio.playSound(GAME_SFX.backButton)
            app:enterChooseLevelScene()
            print("ooooooooooooooooooooooooooooout ")
        end)
        :addTo(self)
        
end

function PlayScene:onLevelCompleted()
    audio.playSound(GAME_SFX.levelCompleted)

    local dialog = display.newSprite("#LevelCompletedDialogBg.png")
    dialog:setPosition(display.cx, display.top + dialog:getContentSize().height / 2 + 40)
    self:addChild(dialog)

    transition.moveTo(dialog, {time = 0.7, y = display.top - dialog:getContentSize().height / 2 - 40, easing = "BOUNCEOUT"})
end

function PlayScene:onEnter()

end


-- 按 key 找值
function searchTableByKey(t, key)  
    -- 遍历表 t
    for k, v in pairs(t) do 
        -- 如果是要找 key，把值返回
        if k == key then
            return v
        end

        -- 如果值是一个"表" 
        if (type(v) == "table") then 
            searchTableByKey(v, key) -- 递归调用  
        end
    end

    return {李白={":你妹的啥也没有!"}}
end  

-- 递归遍历表，打印出内容
function print_table(t, i)  
    local indent ="" -- i缩进，当前调用缩进 
    local i = i or 0 -- 如果未进来，默认为 0
    for j = 0, i do   
        indent = indent .. "    " 
    end  
    for k, v in pairs(t) do   
        if (type(v) == "table") then -- type(v) 当前类型时否table 如果是，则需要递归，  
            print(indent .. "< " .. k .. " is a table />")  
            print_table(v, i + 1) -- 递归调用  
            print(indent .. "/> end table ".. k .. "/>")  
        else -- 否则直接输出当前值  
                  
            print(indent .. "<" .. k .. "=" .. v.."/>")  
        end  
    end  
end  

-- 对表进行随机排序
function tableEx_randSort(my_table)
    -- if (type(my_table) == "table") then
    --     print("----------------传进来的是表！----------------")  
    -- else
    --     print("----------------传进来的是 >> "..my_table)  
    -- end

    -- --随机播种子
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))  
    
    local tempValue
    local randNumber
    local tableLen = table.maxn(my_table)

    --填充数组
    for i=1, tableLen do
        randNumber = math.random(1,tableLen)--生成随机数

        --将当前下标 i 的内容与随机数 randNumber 下标对应的内容交换
        tempValue = my_table[randNumber]
        my_table[randNumber] = my_table[i]
        my_table[i] = tempValue
  
    end

    -- 查看排序后的结果
    --print_table(my_table)

    return my_table
end

-- 在下句中，选出要填的字。（个数与难度相关）
function chooseSomeWord(my_table)
    -- if (type(my_table) == "table") then
    --     print("----------------传进来的是表！----------------")  
    -- else
    --     print("----------------传进来的是 >> "..my_table)  
    -- end

    -- --随机播种子
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))  
    
    local tempValue
    local randNumber
    local tableLen = table.maxn(my_table)

    --填充数组
    for i=1, tableLen do
        randNumber = math.random(1,tableLen)--生成随机数

        --将当前下标 i 的内容与随机数 randNumber 下标对应的内容交换
        tempValue = my_table[randNumber]
        my_table[randNumber] = my_table[i]
        my_table[i] = tempValue
  
    end

    -- 查看排序后的结果
    for k, v in pairs(my_table) do
        print(k.." : "..v[1]..","..v[2])
    end  

    return my_table
end

-- 取出诗句
function getPoetry(my_table)
-- local title = table.concat{tbl,":"}
-- print("\n\n"..title.."\n\n")
-- print("----------------------",table.concat(POETRY_DATA2["李白"], ":"))
-- print(string.split(title, "/"))
-- local poetry = table.concat{POETRY_DATA["李白"],","}
print("----------------------",table.concat(POETRY_DATA["李白"], ""))
print("----------------------",POETRY_DATA["李白"][1])
-- print("poetry 是 ".. type(poetry)..poetry[1],poetry[2])

-- print("------------------",type(table.concat{POETRY_DATA["李白"],":"}))
--url转码
-- print(string.urlencode("人"))
-- print(string.urldecode("%E4%BA%BA"))
end

-- 取出诗句
function tableUnfold(my_table, delimiter)
    local delimiter = delimiter or "," -- 默认为逗号分隔
    local tempStr = "" --临时变量用来存字符串

    --tableUnfold
    for k, v in pairs(my_table) do
        if (type(v[1]) == "table") then -- type(v) 当前类型时否table 
        --如果是，则需要递归，  
            tableUnfold(v) -- 递归调用  
        else -- 否则拼接字符串  
            tempStr = tempStr..delimiter..table.concat(v, delimiter)   
        end  
    end

    return tempStr
end


    POETRY_table = {}
    POETRY_number = 1
-- 显示上句
function  showPoetryUp(my_table, table_Key)
    local table_Key = table_Key or error("fuuuuuuuuuuuuuk")
    POETRY_table = tableEx_randSort(
            searchTableByKey(my_table, table_Key)
    )

    print(POETRY_table[POETRY_number])

end


return PlayScene
