

local TxtCard = class("TxtCard")

function TxtCard:ctor(word_array)
    assert(type(word_array) == "table",
        string.format("老子要的是数组，你传进来的什么鬼？", tostring(word_array)))

    -- 添加事件组件
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()


    self:creatCardGroup(word_array)
end

function TxtCard:onEnter()
    -- 数据准备完成，开始游戏 (此例中 PlayScene 有监听此事件 )
    -- self:dispatchEvent({name = Game.ON_GAME_START})
end

-- 触摸事件是由 PlayScene 触发的。交给 Game 来处理。
function TxtCard:onTouch(event, target)
    if event.name == "began" then
        --print("事件:" ,event.name, event.x, event.y)
        --self:onTouchBegan(event, x, y)
        return true
    elseif event.name == "moved" then
        --print("事件:" ,event.name, event.x, event.y)
        --self:onTouchMoved(event, x, y)
        return true
    elseif event.name == "ended" then
        --print("事件:" ,event.name, event.x, event.y)
        --self:onTouchEnded(event,target)

        dump(event:getCurrentTarget(),"event:getCurrentTarget()")




        return true
    end
end

-- 创建诗句。 word_array：诗句字数组，每个元素就是一个字
function TxtCard:creatCardGroup(word_array)
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
            )
        ):addTo(cardGroup)
    end
    return cardGroup
end

-- 创建答案卡组。 word_array：随机汉字数组，每个元素就是一个字
function PlayScene:creatPickCardGroup(word_array)
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
                )
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
                return self.game_:onTouch(event,tempBtn) -- self.game_ 负责处理该事件
            end
        )
    end
    return cardGroup
end

-- 创建文字(背景+文字)
function TxtCard:createTxtCardGroup(text,point)
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
    local anchor_point = cc.LayerColor:create(cc.c4b(0,0,0,255),5,5)
    :align(display.CENTER, 0, 0)
    textBox:addChild(anchor_point)

    -- 将容器返回。
    return textBox
end

return TxtCard
