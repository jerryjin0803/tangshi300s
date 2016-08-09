--[[
    这里是显示层。
--]]

require("app.models.MathEx") -- 对 math 数学库的一些扩展功能
require("app.models.TableEx") -- 对 table 表的一些扩展功能
require("app.models.StringEx") -- sting 字符串的一些扩展功能

local Levels = import("..data.Levels") -- 关卡等级数据，诗人诗句之类的
local BubbleButton = import("..views.BubbleButton") -- 官方例子里的气泡按钮,正好用来当发炮效果
local PlayModel = import("..models.PlayModel") -- 逻辑层

local txtBoxSize = cc.size(60,80) -- 文本框大小
local c1 = cc.c4b(150,200,190,200) -- 填充颜色值1
local c2 = cc.c4b(100,100,50,200) -- 填充颜色值2

local PlayView = class("PlayView", function()
    return display.newLayer()
end)

function PlayView:ctor(controller)
    print("------------------ PlayView ---------------")

    -- 关闭事件吞噬，因为有些按钮放在后面的场景上
    self:setTouchSwallowEnabled(false)

    -- 创建 Game 对象负责游戏逻辑部分处理
    self.controller_ = controller

    -- 创建 Game 对象负责游戏逻辑部分处理
    --self.controller_ = PlayModel.new(self,levelIdx)

    -- 创建个前景场层，用来显示弹窗类对象
    PlayView.FGLayer = display.newLayer()
    :addTo(self, 1) -- 添加到当前场景，深度为 1
    :setVisible(false) -- 默认关掉前景场。要用时再显示出来
    -- --:setTouchEnabled(false) -- 因为是前景，所以关掉触摸
    -- --PlayView.BGLayer = display.newLayer():addTo(self, -1)

    -- 炮台,子弹(字)拖放上来。它就发射。(就是一个气泡按钮)
    self.emplacement_ = display.newScale9Sprite("wordBg.png")
    :setContentSize(cc.size(300, 200))
    :align(display.CENTER, display.cx, display.bottom + 220)
    :addTo(self)    
    :setOpacity(80)
    :addChild(-- 加入测试点，显示锚点 0，0 位置
        cc.LayerColor:create(cc.c4b(0,0,0,255),5,5)
        :align(display.CENTER, 0, 0)
        )

    -- 获取炮台碰撞框
    self.emplacementBoundingBox_ = self.emplacement_:getBoundingBox()

    -- --初始化关卡数据
    -- self:init(levelIdx)
end

-- 玩家选定一个文字放到指定区域后会触发此事件。
function PlayView:onChooseTheWord(event)
    --[[
    print("----- onChooseTheWord ----",
        "\n事件名称：",event.name,
        "\n是否正确：",event.chooseRight,
        "\n所选的字：",event.key,
        "\n填空位置：",event.value) 
    --]]

    local p1,p2
    local n1 = self.downGroup:getChildren()[event.value]
    local n2 = self.emplacement_

    -- 如果正确，文字卡片飞向诗句中对应的位置。否则飞向屏幕中心对角色造成伤害。
    if event.chooseRight then
        -- 我也不知道这个偏移量是怎么产生的。和炮台大小位置有关，以后有空再查吧
        p1 = n1:convertToWorldSpace(cc.p(34,40)) 
        p2 = n2:convertToNodeSpace(p1)
        -- 执行正确时的动画
        self:wordAction(self.pickGroup:getChildren()[event.key], p2.x, p2.y)
        -- 已经选过的卡牌就不再需要响应触摸事件了
        self.pickGroup:getChildren()[event.key]:setTouchEnabled(false)
    else
        p1 = cc.p(display.cx+34, display.cy+40) 
        p2 = n2:convertToNodeSpace(p1)
        -- 执行错误时的动画
        self:wordAction(self.pickGroup:getChildren()[event.key], p2.x, p2.y)
    end
end

-- 胜利过关
function PlayView:onLevelCompleted(event)
    print("===============PlayView:onLevelCompleted==============")
    audio.playSound(GAME_SFX.levelCompleted)

    --local dialog = display.newSprite("#LevelCompletedDialogBg.png")
    local dialog = cc.ui.UIPushButton.new({normal = "#LevelCompletedDialogBg.png"})
    dialog:setPosition(display.cx, display.top + dialog:getContentSize().height / 2 + 40)
    dialog:onButtonClicked(function()
        audio.playSound(GAME_SFX.backButton)    -- 播放音效
        app:enterChooseLevelScene() -- 切换场景
    end)

    PlayView.FGLayer:setVisible(true) -- 前景层默认被我们关掉了，现在先把它显示出来
    PlayView.FGLayer:addChild(dialog) -- 弹窗放进前景层里
    transition.moveTo(dialog, {time = 0.7, y = display.cy + dialog:getContentSize().height / 2 + 40, easing = "BOUNCEOUT"})
end
-- 挑战失败
function PlayView:onLevelFailure(event)
    print("xxxxxxxxxxxxxxxx=PlayView:onLevelFailure=xxxxxxxxxxxxxx")
    audio.playSound(GAME_SFX.levelCompleted)

    --local dialog = display.newSprite("#LevelCompletedDialogBg.png")
    local dialog = cc.ui.UIPushButton.new({normal = "#LevelCompletedDialogBg.png"})
    dialog:setPosition(display.cx, display.top + dialog:getContentSize().height / 2 + 40)
    dialog:onButtonClicked(function()
        audio.playSound(GAME_SFX.backButton)    -- 播放音效
        app:enterChooseLevelScene() -- 切换场景
    end)

    PlayView.FGLayer:setVisible(true) -- 前景层默认被我们关掉了，现在先把它显示出来
    PlayView.FGLayer:addChild(dialog) -- 弹窗放进前景层里
    dialog:rotation(180)
    transition.moveTo(dialog, {time = 0.7, y = display.cy + dialog:getContentSize().height / 2 + 40, easing = "BOUNCEOUT"})
end

-- 创建诗词的卡牌，布局，添加UI动画...
function PlayView:onPeotryDataReady(WordUp, WordDown, WordPick)
    print("////////////////    PlayView:onPeotryDataReady   /////////////////")
    local xOffset,yOffset,xSpacing,ySpacing = 0,150,2,2 --文字显示的相关位置信息
    -- local WordUp, WordUp_Len = self.controller_:getWordUp() -- 获取诗词的上句 和 字数
    -- local WordDown, WordDown_Len = self.controller_:getWordDown() -- 获取诗词的下句 和 字数
    -- local WordPick, WordPick_Len = self.controller_:getWordPick() -- 获取答案选项 和 字数
    local WordUp, WordUp_Len = WordUp, #WordUp -- 获取诗词的上句 和 字数
    local WordDown, WordDown_Len = WordDown, #WordDown -- 获取诗词的下句 和 字数
    local WordPick, WordPick_Len = WordPick, #WordPick -- 获取答案选项 和 字数

    -- ======================显示上句=========================
    -- 先清除上一次用的诗句。type输出的结果是字符串所以要和"nil"对比。  
    -- 这种写法没有后面的好，浪费。但是我任性
    if ( type(self.upGroup) ~= "nil" ) then 
        self.upGroup:removeFromParent()
    end

    -- 创建诗句的文字卡牌，装在一个容器里。
    self.upGroup = self:creatCardGroup(WordUp)
    self:addChild(self.upGroup)

    -- 将容器放置初始位置
    self.upGroup:pos(
        xOffset + display.cx - ((txtBoxSize.width+ySpacing)*(WordUp_Len-1))/2+ySpacing,
        display.cy 
        )

    -- 容器动画，移到正确位置
    transition.moveTo(self.upGroup, 
    {
        time = .5, 
        y = display.top - yOffset,
        easing = "backout",
        onComplete = function() print("上句已出，请对下句！") end,
    })

    -- ======================显示下句=========================
    -- 先清除上一次用的诗句
    if (self.downGroup) then -- 只要不为 nil 就会执行清理
        self.downGroup:removeFromParent()
    end

    -- 创建诗句的文字卡牌，装在一个容器里。
    self.downGroup = self:creatCardGroup(WordDown)

    self.downGroup:setName("downGroup")

    --打开了子对象的透明度才受控制
    self.downGroup:setCascadeOpacityEnabled(true) 
    self:addChild(self.downGroup)

    -- 将容器放置初始位置
    self.downGroup:pos(
        xOffset + display.cx - ((txtBoxSize.width+ySpacing)*(WordDown_Len-1))/2+ySpacing,
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

    -- ======================显示选词内容=========================
    -- 先清除上一题的答案
    if (self.pickGroup) then -- 只要不为 nil 就会执行清理
        self.pickGroup:removeFromParent()
    end

    -- 创建一个容器,用来放答案选项
    self.pickGroup = self:creatPickCardGroup(WordPick)
    self:addChild(self.pickGroup)

    -- 将容器放置初始位置
    self.pickGroup:pos(
        xOffset + display.cx - ((txtBoxSize.width+ySpacing)*(WordPick_Len-1))/2+ySpacing,
        display.bottom + txtBoxSize.height
        )

end

--===============================================================================
---============================== 界面功能 ======================================
-- 创建文字(背景+文字)
function PlayView:createTxtCard(text, point, txtBoxSize)

    local txtBoxSize = txtBoxSize  or cc.size(60,80) -- 文本框大小
    -- 创建文字的容器(用来陈放 背景+文字)
    local textBox = display.newNode()
    :setCascadeOpacityEnabled(true) --打开了子对象的透明度才受控制
    :setPosition(point) -- 放置位置

    -- 创建文字底图，加入容器
    local txtBg = display.newScale9Sprite(WORDCARDBG, txtBoxSize.width/2, txtBoxSize.height/2)
    :align(display.CENTER, 0, 0)
    :setContentSize(cc.size(txtBoxSize.width, txtBoxSize.height))
    :addTo(textBox)-- 也可以用 textBox 的 addChild 来添加 textBox:addChild(txtBg)

    -- 创建文字，加入容器
    local lab1 = display.newTTFLabel({text=text,color=c3,align=cc.ui.TEXT_ALIGN_CENTER,size=50})
    --lab1:setPosition(cc.p(txtBg:getContentSize().width/2,txtBg:getContentSize().height/2))
    :align(display.CENTER, 0, 0)
    :addTo(textBox) -- 也可以用 textBox 的 addChild 来添加 textBox:addChild(lab1)

    -- 加入测试点，显示锚点 0，0 位置，加入容器。 开发结束记得注释或删掉
    local anchor_point = cc.LayerColor:create(cc.c4b(0,0,0,100),5,5)
    :align(display.CENTER, 0, 0)
    textBox:addChild(anchor_point)

    -- 将容器返回。
    return textBox
end

-- 创建诗句。 word_array：诗句字数组，每个元素就是一个字
function PlayView:creatCardGroup(word_array)
    -- 创建一个容器,用来放文字
    local cardGroup = display.newNode()
    -- 存放诗句字数的临时变量
    local strLen = #word_array -- stringEx_len(word_array)
    --文字卡牌的相关位置信息
    local xOffset,yOffset,xSpacing,ySpacing = 0,0,2,2 

    --逐字处理,要填的字改成空格 
    for i=1,strLen do
        self:createTxtCard(
            -- stringEx_sub(word_array, i, i), -- 截取汉字
            word_array[i], -- 截取汉字
            cc.p(
                 display.left + (txtBoxSize.width+ySpacing)*(i-1),
                 display.bottom
            ),
            txtBoxSize
        ):addTo(cardGroup)
    end
    return cardGroup
end

-- 创建答案卡组。 word_array：随机汉字数组，每个元素就是一个字
function PlayView:creatPickCardGroup(word_array)
    -- 创建一个容器,用来放文字
    local cardGroup = display.newNode()
    -- 临时变量
    local tempBtn

    local strLen = #word_array
    -- 文字卡牌的相关位置信息
    local xOffset,yOffset,xSpacing,ySpacing = 0,0,2,2 
    -- 生成排序的随机索引,在创建卡牌时，读这个索引，就实现了随机打乱卡牌顺序
    local randPos = mathEx_randNumArray(strLen)

    --逐个创建答案选项 
    for i=1, strLen do 
        -- 创建按钮
        tempBtn = self:createTxtCard(
            word_array[i],
            cc.p(
                    display.left + (txtBoxSize.width+ySpacing)*(randPos[i]-1),
                    display.bottom
                ),
            txtBoxSize
            )
        cc(tempBtn):addComponent("components.ui.DraggableProtocol"):exportMethods()
        
        :setDraggableEnable(true)
        -- 添加到容器中
        cardGroup:addChild(tempBtn)
        tempBtn:setName(i)
        --添加监听事件
        tempBtn:setTouchEnabled(true)
        tempBtn:addNodeEventListener(cc.NODE_TOUCH_EVENT, 
            function(event)
                event["tag"] = i --加个标签用来判断事件发送者
                -- event:setName(i) --加个标签用来判断事件发送者
                return self.controller_:onTouch(event) -- self.controller_ 负责处理该事件
            end
        )
    end
    return cardGroup
end

-- 卡牌动画 
function PlayView:wordAction(wordCard, x, y)
    -- local animation = display.newAnimation(frames, 0.5 / 20) -- 0.5s play 20 frames
    -- sprite:playAnimationForever(animation)

    -- 卡牌飞行动画
    transition.moveTo(wordCard, 
    {
        time = .2, 
        delay = 0,
        x = x,
        y = y,
        easing = "backout",
        onComplete = function() 
            -- 播放音效
            audio.playSound(GAME_SFX.tapButton) 

            if self.controller_:isRight() then -- 如果选对了
                print("---------------恭喜选对了。")

                if self.controller_:isFinished() then -- 这句填完了
                    print("+++++++++++++++++++++你这句填完了")

                    -- 尚未通关。 继续刷新显示下一句
                    if not self.controller_:isVictory() then
                        self.controller_:onPeotryDataReady()
                    end
                end
            else -- 否则(选错了)
                -- 攻击了诗人的文字会消失
                wordCard:setVisible(false)

                print("--------xxxxxxxx-------坑货，你选错了。")

                if self.controller_:isFailed() then -- 已经失败了
                    print("xxxxxxxxxxxxxxxxxxxxxxx 你挂了")
                end
            end
        end,
    })

end

-- 获取炮台的碰撞框 
function PlayView:getEmplacement()
    return self.emplacement_
end

return PlayView



-- -- 创建答案卡组。 word_array：随机汉字数组，每个元素就是一个字
-- function PlayView:creatPickCardGroup(word_array)
--     -- 创建一个容器,用来放文字
--     local cardGroup = display.newNode()
--     -- 临时变量
--     local tempBtn, temp_str

--     local rand_str_array = word_array

--     local strLen = #word_array
--     -- 文字卡牌的相关位置信息
--     local xOffset,yOffset,xSpacing,ySpacing = 0,0,2,2 
--     -- 生成排序的随机索引,在创建卡牌时，读这个索引，就实现了随机打乱卡牌顺序
--     local randPos = mathEx_randNumArray(strLen)

--     --逐个创建答案选项 
--     for i=1, strLen do
--         temp_str = rand_str_array[i]
--         -- 创建按钮
--         tempBtn = self:createTxtCard(
--             temp_str,
--             cc.p(
--                     display.left + (txtBoxSize.width+ySpacing)*(i-1),--(randPos[i]-1),
--                     display.bottom
--                 )
--             )
--         cc(tempBtn):addComponent("components.ui.DraggableProtocol"):exportMethods()
        
--         :setDraggableEnable(true)
--         -- 添加到容器中
--         cardGroup:addChild(tempBtn)
--         tempBtn:setName(i)
--         --添加监听事件
--         tempBtn:setTouchEnabled(true)
--         tempBtn:addNodeEventListener(cc.NODE_TOUCH_EVENT, 
--             function(event)
--                 event["tag"] = i --加个标签用来判断事件发送者
--                 -- event:setName(i) --加个标签用来判断事件发送者
--                 return self.controller_:onTouch(event,tempBtn) -- self.controller_ 负责处理该事件
--             end
--         )
--     end
--     return cardGroup
-- end