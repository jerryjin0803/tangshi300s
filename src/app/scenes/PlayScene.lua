
local Levels = import("..data.Levels")
local AdBar = import("..views.AdBar")
local BubbleButton = import("..views.BubbleButton")
local peotry_anthology_ --当前关卡所用诗句
local peotry_word = {}  -- 整句诗从字符器拆成上下句，放到此数组中
local OOXX_table_idx = {}--要填的字对应的索引
local gLevel =2  --游戏难度。越高时，要填的空就越多。最多不超过全句
local txtBoxSize = cc.size(60,80)
local c1 = cc.c4b(150,200,190,200)
local c2 = cc.c4b(100,100,50,200)
local buttonBoundingBoxs = {}-- 用来存放正确选荐的碰撞框。
local number_successes = 0 -- 成功答题次数，用来判断是否答完。可继续下一句

local PlayScene = class("PlayScene", function()
    return display.newScene("PlayScene")
end)

function PlayScene:ctor(levelIdx)
    local bg = display.newSprite("#PlayLevelSceneBg.png")
    -- make background sprite always align top
    bg:setPosition(display.cx, display.top - bg:getContentSize().height / 2)
    self:addChild(bg)

    --初始化关卡数据
    self:init(levelIdx)

    local title = display.newSprite("#Title.png", display.left + 150, display.top - 50)
    title:setScale(0.5)
    self:addChild(title)

    -- --显示上句
    -- self.labelup = cc.ui.UILabel.new({
    --     UILabelType = 2,
    --     text = "仄平平仄仄平仄",
    --     size = 50})
    -- :align(display.CENTER, display.cx, display.top-200)
    -- self:addChild(self.labelup)

    -- --显示下句 
    -- self.labeldown = cc.ui.UILabel.new({
    --     UILabelType = 2,
    --     text = "仄仄平平仄仄平",
    --     size = 50})
    -- :align(display.CENTER, display.cx, display.top-250)
    -- self:addChild(self.labeldown)

    -- 炮台
    self.emplacement = display.newScale9Sprite("wordBg.png")
    :setContentSize(cc.size(200, 200))
    :align(display.CENTER, display.cx, display.bottom + 200)
    :addTo(self)    
    :setOpacity(80)
    :addChild(-- 加入测试点，显示锚点 0，0 位置
        cc.LayerColor:create(cc.c4b(0,0,0,255),5,5)
        :align(display.CENTER, 0, 0)
        )

    -- 获取碰撞框
    self.emplacementBoundingBox = self.emplacement:getBoundingBox()

    ----执行按钮
    -- self.goButton = BubbleButton.new({
    --         image = "#MenuSceneStartButton.png",
    --         sound = GAME_SFX.tapButton,
    --         prepare = function()
    --             audio.playSound(GAME_SFX.tapButton)
    --         end,
    --         listener = function()           
    --             self:showPoetryWord()
    --         end,
    --     })
    --     :align(display.CENTER, display.cx, display.bottom + 200)
    --     :addTo(self)

    --返回按钮
    cc.ui.UIPushButton.new({normal = "#BackButton.png", pressed = "#BackButtonSelected.png"})
        :align(display.LEFT_TOP, display.left +10 , display.top - 10)
        :onButtonClicked(function()
            audio.playSound(GAME_SFX.backButton)
            app:enterChooseLevelScene()
            print("ooooooooooooooooooooooooooooout ")
        end)
        :addTo(self)

        
end

function PlayScene:init(levelIdx)
	--复制一份。因为使用时会有移除操作
	peotry_anthology_ = tableEx_randSort(POETRY_ANTHOLOGY[BOSS_LIST[levelIdx]])
    -- 创建显示诗句
    self:showPoetryUp()

    -- 初始难度等级 （还未实现具体的难度等级控制。默认先用1级）
    -- gLevel = 1

    -- 创建进度条显示
    self:loadBar()
end

-- 创建进度条显示,用于判别操作的 好坏程度
function PlayScene:loadBar()
    print("PlayScene:loadBar")
    local loadBar = cc.ui.UILoadingBar.new({
        scale9 = true,
        capInsets = cc.rect(5,5,5,5), -- scale region
        image =  "wordBg.png", -- loading bar image
        viewRect = cc.rect(0,0,400,20), -- set loading bar rect
        percent = 100, -- set loading bar percent
        -- direction = DIRECTION_RIGHT_TO_LEFT
        -- direction = DIRECTION_LEFT_TO_RIGHT -- default
    })
    :addTo(self)
    :align(display.CENTER,display.cx , display.cy)
end

function PlayScene:onLevelCompleted()
    audio.playSound(GAME_SFX.levelCompleted)

    local dialog = display.newSprite("#LevelCompletedDialogBg.png")
    dialog:setPosition(display.cx, display.top + dialog:getContentSize().height / 2 + 40)
    self:addChild(dialog)

    transition.moveTo(dialog, {time = 0.7, y = display.top - dialog:getContentSize().height / 2 - 40, easing = "BOUNCEOUT"})
end

function PlayScene:onEnter()
    self:setTouchEnabled(true)
    :addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        return self:onTouch(event, event.x, event.y)
    end)
end

-- 触摸相关事件
function PlayScene:onTouchBegan(event,x, y)
    --print("开始触摸：", x, y)
 
    -- local p = cc.p(x, y)
    -- if cc.rectContainsPoint(self.emplacementBoundingBox, p) then
    --     self.state = "fireControlOn"
    -- else
    --     self.state = "fireControlOff"
    -- end
end

function PlayScene:onTouchMoved(event,x, y)
    --print("触摸移动中：", x, y)
    -- local p = cc.p(x, y)
    -- if cc.rectContainsPoint(self.emplacementBoundingBox, p) then
    --     self.state = "fireControlOn"
    -- else
    --     self.state = "fireControlOff"
    -- end
end

function PlayScene:onTouchEnded(event,x, y)
    print("手指离开：", x, y)

    local p = cc.p(x, y)
    if cc.rectContainsPoint(self.emplacementBoundingBox, p) then
       for k,v in pairs(OOXX_table_idx) do
            if k == event["tag"] then

                print(k,v)
                --print("索引值:"..v ,"标签:"..event["tag"],"这是正确答案" )
                transition.rotateTo(self.downGroup:getChildren()[v], {rotate = 360, time = 0.5})

                local p1,p2,xx,yy
                local n1 = self.downGroup:getChildren()[v]
                local n2 = self.emplacement

                -- 我也不知道这个偏移量是怎么产生的cc.p(84,20)
                p1 = n1:convertToWorldSpace(cc.p(84,20)) 
                p2 = n2:convertToNodeSpace(p1)

            transition.moveTo(self.pickGroup:getChildren()[k], 
            {
                time = 3.2, 
                delay = 0,
                x = p2.x,
                y = p2.y,
                easing = "backout",
                -- onComplete = function() print("容器动画，移到正确位置") end,
            })
            number_successes = number_successes + 1 --填对一字
            end
        end
        audio.playSound(GAME_SFX.tapButton)
        
        -- 本句是否填完
        if number_successes >= gLevel then  --不知为啥我就喜欢 >= 感觉完全点
            number_successes = 0 -- 清空填对计数
            --播放结束动画
            transition.scaleTo(self.upGroup, 
            {
                time = .2, 
                scale = 0.5,
                easing = "BACKIN",
                onComplete = function() self:showPoetryUp() end,-- 刷新下一句
            })
        end

    end
end 

function PlayScene:onTouch(event, x, y)
    --local target = event:getCurrentTarget() 
    -- print("event.getCurrentTarget():".. type(event.getCurrentTarget()))
    if event.name == "began" then
        --print(event, x, y)
        self:onTouchBegan(event, x, y)
        return true
    elseif event.name == "moved" then
        --print(event, x, y)
        self:onTouchMoved(event, x, y)
        return true
    else--if event ~= "" then
        --print(event, x, y)
        self:onTouchEnded(event, x, y)
        return true
    end
end
--------------=========================================================
-- 显示上句
function  PlayScene:showPoetryUp()

    -- 从顶部弹出诗句待处理
    local temp_str  --  遍历诗句时逐字操作时用的临时变量
    local strLen --存放诗句字数的临时变量
    local xOffset,yOffset,xSpacing,ySpacing = 0,250,2,2 --文字显示的相关位置信息
    

    -- 如果此诗人的诗句表中还有，就取一句出来继续。否则就过关了
	if(#peotry_anthology_>0) then
        -- 取出一句拆成数组
		peotry_word = string.split(table.remove(peotry_anthology_,1), ",")
		print(peotry_word[1],peotry_word[2])
	else
		print("诗集已空！闯关成功！")
	end

	-- ======================显示上句=========================
	--self.labelup:setString(peotry_word[1]) --调试时显示上句的label

    -- 先清除上一次用的诗句。type输出的结果是字符串所以要和"nil"对比。  
    -- 这种写法没有后面的好，浪费。但是我任性
    if ( type(self.upGroup) ~= "nil" ) then 
        self.upGroup:removeFromParent()
    end

    -- 创建一个容器,用来放文字
    self.upGroup = display.newNode()
    --self.upGroup = cc.LayerColor:create(cc.c4b(c1.r,c1.g,c1.b,c1.a),500,100)

    -- 取出诗句字数
    strLen = stringEx_len(peotry_word[1])
    --逐字处理,要填的字改成空格 
    for i=1,strLen do
        temp_str = stringEx_sub(peotry_word[1],i,i)
        --print(temp_str)
            --   self.upGroup:addChild(self:createTxtBox(temp_str,cc.p(
            -- display.left + (txtBoxSize.width+2)*(i-1),
            -- txtBoxSize.height)))  --display.top - 
        self.upGroup:addChild(self:createTxtBox(temp_str,cc.p(
            display.left + (txtBoxSize.width+ySpacing)*(i-1),
            display.bottom
            )))  --display.top - 
    end
    self:addChild(self.upGroup)

    -- 将容器放置初始位置
    self.upGroup:pos(
        xOffset + display.cx - ((txtBoxSize.width+ySpacing)*(strLen-1))/2+ySpacing,
        display.cy 
        )
    -- 容器动画，移到正确位置
    transition.moveTo(self.upGroup, 
    {
        time = .5, 
        --x = xOffset + display.cx - ((txtBoxSize.width+ySpacing)*(strLen-1))/2+ySpacing,
        y = display.top - yOffset,
        easing = "backout",
        onComplete = function() print("上句已出，请对下句！") end,
    })
        --x = xOffset + display.cx - ((txtBoxSize.width+ySpacing)*strLen)/2+ySpacing,
    -- ======================显示下句=========================
    --self.labeldown:setString(peotry_word[2]) --调试时显示下句的label
    
    -- 先清除上一次用的诗句
    if (self.downGroup) then -- 只要不为 nil 就会执行清理
        self.downGroup:removeFromParent()
    end

    -- 创建一个容器,用来放文字
    self.downGroup = display.newLayer() 
    :setCascadeOpacityEnabled(true) --打开了子对象的透明度才受控制

    self:addChild(self.downGroup)
    -- 取出诗句字数
    strLen = stringEx_len(peotry_word[2])
    OOXX_table_idx = mathEx_randNumArray(strLen) --创建一个随机数组，作为填空的索引
    OOXX_table_idx = tableEx_cut(OOXX_table_idx,gLevel) --根据难度级别留 N 个空格 

    --逐字处理,要填的字改成空格
    for i=1,strLen do
        temp_str = stringEx_sub(peotry_word[2],i,i)

        -- 找出要留空的字，替换掉
        for j=1,gLevel do
            if i == OOXX_table_idx[j] then
                --print("填空在：",v)
                temp_str = "?"
            end
        end

        -- 创建文字
        self.downGroup:addChild(
            self:createTxtBox(temp_str,cc.p(
            display.left + (txtBoxSize.width+ySpacing)*(i-1),
            display.bottom))
            :setTag(i)
            )
    end
    
    -- 将容器放置初始位置
    self.downGroup:pos(
       -- xOffset + display.cx - ((txtBoxSize.width+ySpacing)*strLen)/2+ySpacing,
        xOffset + display.cx - ((txtBoxSize.width+ySpacing)*(strLen-1))/2+ySpacing,
        display.top - yOffset - txtBoxSize.height - xSpacing 
        )

    -- 容器动画，淡入
    self.downGroup:setOpacity(10)
    transition.fadeIn(self.downGroup, 
    {
        time = 5, 
        delay = 1,
        --easing = "backout",
        --onComplete = function() print("下句已出，请填空！") end,
    })

    -- 下句转成数组方便操作
    -- stringEx_str2Array(peotry_word[2])

    -- self.word1 = self:createEquipmentBox("笨",cc.p(display.width/2/2-txtBoxSize.width/2,display.height/10*7))
    -- self:addChild(self.word1)

    -- ======================显示选词内容=========================
    -- 答案选项的个数
    strLen = 7
    --随机汉字数字组,生成7个随机汉字的数组
    local rand_str_array = string_randChineseArray(strLen) 
    for i=1,gLevel do
        -- 把正确选项替换进来。后面在UI对显示位置做随机就可以了
        rand_str_array[i] = stringEx_sub(peotry_word[2],OOXX_table_idx[i],OOXX_table_idx[i])
    end

    -- 先清除上一题的答案
    if (self.pickGroup) then -- 只要不为 nil 就会执行清理
        self.pickGroup:removeFromParent()
    end

    -- 创建一个容器,用来放答案选项
    self.pickGroup = display.newNode()
    local tempBtn
    --逐个创建答案选项 
    for i=1,strLen do
        temp_str = rand_str_array[i]
        -- 创建按钮
        tempBtn = self:createTxtBox(
            temp_str,
            cc.p(
                    display.left + (txtBoxSize.width+ySpacing)*(i-1),
                    display.bottom
                )
            )
        cc(tempBtn):addComponent("components.ui.DraggableProtocol")
        :exportMethods()
        :setDraggableEnable(true)
        -- 添加到容器中
        self.pickGroup:addChild(tempBtn)
        -- 碰撞框添加到数组中
        table.insert(buttonBoundingBoxs,tempBtn:getBoundingBox())

        --添加监听事件
        tempBtn:setTouchEnabled(true)
        :addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
            event["tag"] = i --加个标签用来判断事件发送者
            return self:onTouch(event, event.x, event.y)
        end)

        --self.pickGroup:addChild()
    end
    self:addChild(self.pickGroup)

    -- 将容器放置初始位置
    self.pickGroup:pos(
        --xOffset + display.cx - ((txtBoxSize.width+ySpacing)*strLen)/2+ySpacing,
        xOffset + display.cx - ((txtBoxSize.width+ySpacing)*(strLen-1))/2+ySpacing,
        display.bottom + txtBoxSize.height
        )

end
--==============================================================================

-- 显示可选字
function  PlayScene:showPoetryWord(peotry_str)

end


-- 创建文字底框
function PlayScene:createTxtBox(text,point)
    -- 每个字的容器
    -- local box1 = display.newNode()
    local box1 = display.newNode()
    :setCascadeOpacityEnabled(true) --打开了子对象的透明度才受控制

    -- 加入文字底图
    local txtBg = display.newScale9Sprite("wordBg.png",txtBoxSize.width/2, txtBoxSize.height/2)
    :align(display.CENTER, 0, 0)
    box1:addChild(txtBg)
    txtBg:setContentSize(cc.size(txtBoxSize.width, txtBoxSize.height))
    box1:setPosition(point)

    -- 加入文字
    local lab1 = display.newTTFLabel({text=text,color=c3,align=cc.ui.TEXT_ALIGN_CENTER,size=50})
    --lab1:setPosition(cc.p(txtBg:getContentSize().width/2,txtBg:getContentSize().height/2))
    :align(display.CENTER, 0, 0)
    box1:addChild(lab1)

    -- 加入测试点，显示锚点 0，0 位置
    local anchor_point = cc.LayerColor:create(cc.c4b(0,0,0,255),5,5)
    :align(display.CENTER, 0, 0)
    box1:addChild(anchor_point)

    return box1
end

-- 创建文字底框
function animation_finished(text,point)

end


--/////////////////////////////////////////////////////////////////////////////
-- 生成要填的诗句。
function make_poetry(poetry,level)
    local level = level or 1
    local poetry
    local OOXX_table
    OOXX_table = mathEx_randNumArray(level)


    return poetry
end

-- 生成一个 随机中文数组。
function string_randChineseArray(strLen)
    -- -- 默认数组内容 1 个
    local strLen = strLen or 1
    local my_table = {}
    local tempLen,rand_idx,tempStr    

    tempLen = stringEx_len(COMMON_CHINESE) -- 记得汉字不要用默认的 string.len 取出来不一样的

    -- 随机播种子
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))
    
    -- 随机从字符串中取字
    for i=1,strLen do
        rand_idx = math.random(1,tempLen)
        table.insert(my_table, i, stringEx_sub(COMMON_CHINESE,rand_idx,rand_idx))
    end

    -- 查看排序后的结果
     -- print("mathEx_randChineseArray")
     -- tableEx_print(my_table)

    return my_table
end

-- 生成一个从 minN 到 maxN 的随机数字数组。
function mathEx_randNumArray(maxN,minN)
    -- 默认数组内容 1 个
    local maxN = maxN or 1
    local minN = minN or 1
    local my_table = {}
    print("--------------mathEx_randNumArray---------------",type(COMMON_CHINESE),COMMON_CHINESE[1])
    -- --随机播种子
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))

    --填充数组
    for i = minN, maxN do
        my_table[i] = i
    end
    
    -- 打乱顺序
    for i = minN, maxN do
        randNumber = math.random(1,maxN)--生成随机数
        --将当前下标 i 的内容与随机数 randNumber 下标对应的内容交换
        my_table[randNumber],my_table[i] = my_table[i],my_table[randNumber]
    end

    -- 查看排序后的结果
    --print("mathEx_randNumArray")
    --tableEx_print(my_table)

    return my_table
end

-- 截取表。
function tableEx_cut(my_table,tlen)

    if not my_table then
        error("用来截取的表是空的！")
    end
    local tempT = {}

    for i=1,tlen do
        tempT[i] = my_table[i]
    end

    --输出结果检查
    tableEx_print(tempT)

    return tempT

end

-- 中文字符串长度
function stringEx_len(str)
    --local m,n = string.gsub (str, "[^\128-\193]", '笨')
    local m,n = str:gsub ("[^\128-\193]", '笨')
    return n
end

-- 中文字符串截取
function stringEx_sub(str,s,e)
    local s = s or 1   -- 未填写则默认为：1
    local e = e or s   -- 未填写则默认 end = start
    --str=str:gsub('([\001-\127])','\000%1')
    str=str:sub(1+3*(s-1),3+3*(e-1)) -- 因为纯中文所以直接这样处理了
    --str=str:gsub('\000','')
    return str

end

-- 中文字符串逐字转数组(因为中文字符串不能直接遍历)
function stringEx_str2Array(str)
    local my_table = {}
    local len = string.len(str)    
    for i=1,len,3 do
        my_table[i] = str:sub(i, i + 2) -- lua文档要用 utf8 ，按中文宽设置偏移量
    end
    return my_table
end

-- 中文字符串遍历
function stringEx_iterator(str)
    local my_table
    local tempStr = str
    local start = 1
    function closureF()
        print(str:sub(start, start + 2))        
        start = start + 3
    end
    return closureF
end

-- 按 key 找值
function tableEx_searchByKey(t, key)  
    -- 遍历表 t
    for k, v in pairs(t) do 
        -- 如果是要找 key，把值返回
        if k == key then
            return v
        end

        -- 如果值是一个"表" 
        if (type(v) == "table") then 
            tableEx_searchByKey(v, key) -- 递归调用  
        end
    end

    return {李白={":你妹的啥也没有!"}}
end  

-- 递归遍历表，打印出内容
function tableEx_print(t, i)  
    local indent ="" -- i缩进，当前调用缩进 
    local i = i or 0 -- 如果未进来，默认为 0
    for j = 0, i do   
        indent = indent .. "    " 
    end  
    for k, v in pairs(t) do   
        if (type(v) == "table") then -- type(v) 当前类型时否table 如果是，则需要递归，  
            print(indent .. "< " .. k .. " is a table />")  
            tableEx_print(v, i + 1) -- 递归调用  
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
    --tableEx_print(my_table)

    return my_table
end

-- 在下句中，选出要填的字。（个数与难度相关）
function chooseSomeWord(my_table)
    -- --随机播种子
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))  

    --打乱数组原本的顺序
    local randNumber
    for k, v in pairs(my_table) do
        randNumber = math.random(1,tableLen)--生成随机数
        --交换下标 i 与下标 randNumber 的内容
        my_table[k],my_table[randNumber] = my_table[i],my_table[randNumber]
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
-- print("----------------------",table.concat(POETRY_ANTHOLOGY2["李白"], ":"))
-- print(string.split(title, "/"))
-- local poetry = table.concat{POETRY_ANTHOLOGY["李白"],","}
print("----------------------",table.concat(POETRY_ANTHOLOGY["李白"], ""))
print("----------------------",POETRY_ANTHOLOGY["李白"][1])
-- print("poetry 是 ".. type(poetry)..poetry[1],poetry[2])

-- print("------------------",type(table.concat{POETRY_ANTHOLOGY["李白"],":"}))
--url转码
-- print(string.urlencode("人"))
-- print(string.urldecode("%E4%BA%BA"))
end

-- 取出诗句
function tableEx_Unfold(my_table, delimiter)
    local delimiter = delimiter or "," -- 默认为逗号分隔
    local tempStr = "" --临时变量用来存字符串

    --tableEx_Unfold
    for k, v in pairs(my_table) do
        if (type(v[1]) == "table") then -- type(v) 当前类型时否table 
        --如果是，则需要递归，  
            tableEx_Unfold(v) -- 递归调用  
        else -- 否则拼接字符串  
            tempStr = tempStr..delimiter..table.concat(v, delimiter)   
        end  
    end

    return tempStr
end


    -- POETRY_table = {}
    -- POETRY_number = 1



return PlayScene
