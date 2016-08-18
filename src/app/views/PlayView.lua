--[[
    这里是显示层。
--]]

require("app.models.MathEx") -- 对 math 数学库的一些扩展功能

local TxtCard = import("..views.TxtCard") -- 每一个字就是一张卡牌
local Actor = import("..models.Actor")

local txtBoxSize = cc.size(60,80) -- 文本框大小

local PlayView = class("PlayView", function()
    return display.newLayer()
end)

function PlayView:ctor(index)
    print("------------------ PlayView ---------------",type(index))

    -- 关闭事件吞噬，因为有些按钮放在后面的场景上
    self:setTouchSwallowEnabled(false)

    -- 创建个前景场层，用来显示弹窗类对象
    PlayView.FGLayer = display.newLayer()
    :addTo(self, 1) -- 添加到当前场景，深度为 1
    :setVisible(false) -- 默认关掉前景场。要用时再显示出来
    -- --:setTouchEnabled(false) -- 因为是前景，所以关掉触摸
    -- --PlayView.BGLayer = display.newLayer():addTo(self, -1)

    -- 添加诗人形象
    self.poet = Actor.new({
    id = tostring(index) ,
    nickname = "Poet",
    })

    self.heroViews_ = app:createView("HeroView", self.poet)
            :pos(display.cx, display.cy)
            :addTo(self)


    -- 炮台,子弹(字)拖放上来。它就发射。(就是一个气泡按钮)
    --self.emplacement_ = display.newScale9Sprite("wordBg.png")
    self.emplacement_ = display.newSprite(CANNON)
    :align(display.CENTER, display.cx, display.bottom + 240)
    :addTo(self)    
    -- :setOpacity(80)
    --[[ 加入测试点，显示锚点 0，0 位置
    :addChild(
        cc.LayerColor:create(cc.c4b(0,0,0,255),5,5)
        :align(display.CENTER, 0, 0)
        )
    --]]

    -- 获取炮台碰撞框
    self.emplacementBoundingBox_ = self.emplacement_:getBoundingBox()

    -- 炮台总会变，创建个定位器来当卡牌移动起点
    self.locator_ = display.newNode()
    --:addChild(cc.LayerColor:create(cc.c4b(0,0,0,255),20,20)) -- 测试点
    -- 我也不知道这个偏移量是怎么产生的。和炮台大小位置有关，以后有空再查吧
    :align(display.BOTTOM_LEFT , 105, 40) -- 
    :addTo(self)
    -- cc(self.locator_):addComponent("components.ui.DraggableProtocol")
    -- :setDraggableEnable(true)
end

-- 玩家选定一个文字放到指定区域后会触发此事件。
function PlayView:onChooseTheWord(event)
    --[[
    print("----- onChooseTheWord ----",
        "\n事件名称：",event.name,
        "\n是否正确：",event.chooseRight,
        -- "\n所选的字：",event.key,
        "\n填空位置：",event.value,
        "\n所选的卡：",event.card
        ) 
    --]]

    local p1,p2
    local n1 = self.downGroup:getChildren()[event.value]
    local n2 = self.locator_ --self.emplacement_ -- 

    -- 如果正确，文字卡片飞向诗句中对应的位置。否则飞向屏幕中心对角色造成伤害。
    if event.chooseRight then
        p1 = n1:convertToWorldSpace(cc.p(0,0))
        p2 = n2:convertToNodeSpace(p1)
    else
        p1 = cc.p(display.cx - 30 , display.cy -40)  -- 锚点在左下
        p2 = n2:convertToNodeSpace(p1)
    end

    -- 执行动画
    self:wordAction(event.card, p2.x, p2.y)
    -- 已经选过的卡牌就不再需要响应触摸事件了
    event.card:setTouchEnabled(false)
end

-- 胜利过关
function PlayView:onLevelCompleted(event)
    print("===============PlayView:onLevelCompleted==============")

    -- 胜利音效
    audio.playSound(GAME_SFX.victory)
    -- 停掉背景音效
    audio.stopMusic(false)

    --创建并显示 胜利UI 。点击回到选关界面
    local dialog = cc.ui.UIPushButton.new({normal = GAMEOVERVICTORY})
    -- dialog:setPosition(display.cx, display.top + dialog:getContentSize().height / 2 + 40)
    dialog:pos(display.cx, display.cy + 50)
    dialog:onButtonClicked(function()
        audio.playSound(GAME_SFX.backButton)    -- 播放音效
        app:enterChooseLevelScene() -- 切换场景
    end)

    PlayView.FGLayer:setVisible(true) -- 前景层默认被我们关掉了，现在先把它显示出来
    PlayView.FGLayer:addChild(dialog) -- 弹窗放进前景层里
    -- 创建一个精灵作为背景图. plist里的图片名字前加 # 区分(图片名统一放到 config 里去了)
    local bg = display.newScale9Sprite(BACKGROUND, display.cx, display.cy, display.size) 
    PlayView.FGLayer:addChild(bg, -1) -- 将背景图加载到场景默认图层 self 中。

    --[[ 创建并循环播放一个动画序列
        播放： runAction   参数就是一个 action,返回的也是 action 用于之后控制暂停之类的
            virtual Action* runAction(Action* action);
        播放次数：除了 RepeatForever 还可以用 Repeat 播放特定次数:
            static Repeat* create(FiniteTimeAction *action, unsigned int times);
        播放顺序:
            按顺序逐个播: Sequence
            同个 action 一起播: Spawn
        缓动效果：放到序列里就行了，参数就是要缓动的那个 Action。
            cc.EaseBackOut:create(cc.ScaleTo:create(1, 1, 1)),
        还没试过，不知道是否能互相嵌套实现复杂动画效果
    --]]
    dialog:runAction(cc.RepeatForever:create(cc.Sequence:create(
        -- cc.DelayTime:create(1.0), -- 延时一秒
        cc.ScaleTo:create(0.0001, 1, 1), -- 因为下面缩放了，这里要还原一下
        cc.JumpTo:create(0.5, cc.p(display.cx, display.cy-50), 300, 1),
        cc.ScaleTo:create(0.1, 1.5, .5),
        cc.DelayTime:create(.1) -- 延时一秒
        -- cc.CallFunc:create(function() -- 执行一个函数。
        --      print ("------- cc.RepeatForever:create ---------") 
        -- end)
    )))

end

-- 挑战失败
function PlayView:onLevelFailure(event)
    print("xxxxxxxxxxxxxxxx=PlayView:onLevelFailure=xxxxxxxxxxxxxx")
    -- 停掉背景音效
    audio.stopMusic(false)
    -- 失败音效
    audio.playSound(GAME_SFX.defeat)

    --创建并显示 失败UI 。点击回到选关界面
    local dialog = cc.ui.UIPushButton.new({normal = GAMEOVERFAILE})
    --dialog:setPosition(display.cx, display.top + dialog:getContentSize().height / 2 + 40)
    dialog:pos(display.cx, display.cy + 50)
    dialog:onButtonClicked(function()
        audio.playSound(GAME_SFX.backButton)    -- 播放音效
        app:enterChooseLevelScene() -- 切换场景
    end)

    PlayView.FGLayer:setVisible(true) -- 前景层默认被我们关掉了，现在先把它显示出来
    PlayView.FGLayer:addChild(dialog) -- 弹窗放进前景层里
    -- 创建一个精灵作为背景图. plist里的图片名字前加 # 区分(图片名统一放到 config 里去了)
    local bg = display.newScale9Sprite(BACKGROUND, display.cx, display.cy, display.size) 
    PlayView.FGLayer:addChild(bg, -1) -- 将背景图加载到场景默认图层 self 中。
    
    -- 循环缩放动画
    dialog:runAction(cc.RepeatForever:create(cc.Sequence:create(
        cc.ScaleTo:create(0.0001, 1, 1), -- 因为下面缩放了，这里要还原一下
        cc.JumpTo:create(0.5, cc.p(display.cx, display.cy-50), 300, 1),
        cc.ScaleTo:create(0.1, 1.5, .5),
        cc.DelayTime:create(.1) -- 延时一秒
    )))

    -- transition.scaleTo(dialog, {time = 0.7, scale = 1.2, easing = "BOUNCEOUT"})
    -- self:getParent().back_btn:hide() -- 隐藏返回按钮
end

-- 创建诗词的卡牌，布局，添加UI动画...
function PlayView:onPeotryDataReady(WordUp, WordDown, WordPick)
    print("////////////////    PlayView:onPeotryDataReady   /////////////////")
    local xOffset,yOffset,xSpacing,ySpacing = 0,150,2,2 --文字显示的相关位置信息
    local WordUp, WordUp_Len = WordUp, #WordUp -- 获取诗词的上句 和 字数
    local WordDown, WordDown_Len = WordDown, #WordDown -- 获取诗词的下句 和 字数
    local WordPick, WordPick_Len = WordPick, #WordPick -- 获取答案选项 和 字数

    -- ======================显示上句=========================
    -- 先清除上一次用的诗句。type输出的结果是字符串所以要和"nil"对比。  
    -- 这种写法没有后面的好，浪费。但是我任性
    if ( type(self.upGroup) ~= "nil" ) then 
        self.upGroup:removeFromParent()
    end

    -- 创建诗句的文字卡牌，装在一个容器里。 不允许拖动
    self.upGroup = self:creatCardGroup(WordUp,false)
    self:addChild(self.upGroup)
    self.upGroup:setName("upGroup")

    -- 将容器放置初始位置
    self.upGroup:pos(
        xOffset + display.cx - ((txtBoxSize.width+ySpacing)*(WordUp_Len))/2+ySpacing,
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

    -- 创建诗句的文字卡牌，装在一个容器里。不允许拖动 
    self.downGroup = self:creatCardGroup(WordDown, false)
    self:addChild(self.downGroup)
    self.downGroup:setName("downGroup")

    --打开了子对象的透明度才受控制
    self.downGroup:setCascadeOpacityEnabled(true) 

    -- 将容器放置初始位置
    self.downGroup:pos(
        xOffset + display.cx - ((txtBoxSize.width+ySpacing)*(WordDown_Len-0))/2+ySpacing,
        display.top - yOffset - txtBoxSize.height - xSpacing 
        )

    -- 容器动画，淡入
    self.downGroup:setOpacity(10)
    self.downGroupfadeIn_ = transition.fadeIn(self.downGroup, 
    {
        time = DOWNGROUPFADEINTIME, 
        delay = 1,
        --easing = "backout",
        --onComplete = function() print("下句已出，请填空！") end,
    })

    -- ======================显示选词内容=========================
    -- 先清除上一题的答案
    if (self.pickGroup) then -- 只要不为 nil 就会执行清理
        self.pickGroup:removeFromParent()
    end

    -- 创建一个容器,用来放答案选项。 允许拖动 
    -- self.pickGroup = self:creatPickCardGroup(WordPick) 
    self.pickGroup = self:creatCardGroup(WordPick, true, true) 
    self:addChild(self.pickGroup)
    self.pickGroup:setName("pickGroup")

    --[[ 打乱卡牌的摆放位置
        self:randChildrenPosition(self.pickGroup)
    --]]

    -- 将容器放置初始位置
    self.pickGroup:pos(
        xOffset + display.cx - ((txtBoxSize.width+ySpacing)*(WordPick_Len-0))/2+ySpacing,
        display.bottom + txtBoxSize.height/2
        )

end

--===============================================================================
---============================== 界面功能 ======================================

-- 创建诗句。 word_array：诗句字数组，每个元素就是一个字
function PlayView:creatCardGroup(word_array, dragEnable, rand)
    -- 创建一个容器,用来放文字
    local cardGroup = display.newNode()
    -- 临时变量(临时存放刚创建出来的文字卡牌)
    local tempBtn
    -- 存放诗句字数的临时变量
    local strLen = #word_array
    --文字卡牌摆放的相关位置信息
    local xOffset,yOffset,xSpacing,ySpacing = 0,0,2,2 
    -- 生成排序的随机索引,在创建卡牌时，读这个索引，就实现了随机打乱卡牌顺序
    local randPos = mathEx_randNumArray(strLen)
    local rand = rand or false

    --逐字处理,要填的字改成 ? 问号 
    for i=1,strLen do
        -- 创建文字卡牌
        tempBtn = TxtCard.new(
            word_array[i], -- 卡牌上要显示的字
            txtBoxSize -- 卡牌的大小
        )

        -- 添加到容器中
        cardGroup:addChild(tempBtn)

        -- 设置卡牌的排列位置
        if rand then -- 如果 随机为 true
            tempBtn:setPosition(cc.p(
                 display.left + (txtBoxSize.width+ySpacing)*(randPos[i]-1),
                 display.bottom))
        else
            tempBtn:setPosition(cc.p(
                display.left + (txtBoxSize.width+ySpacing)*(i-1),
                display.bottom)) 
        end

        -- 将名字设置为自己的索引
        tempBtn:setName(i)
        -- 卡牌要监听 touch 事件，然后交给 PlayController 去处理
        tempBtn:setController(self.controller_)
        -- 是否可以拖动
        if dragEnable then
            -- 添加拖放组件
            cc(tempBtn):addComponent("components.ui.DraggableProtocol"):exportMethods()
            -- 设置为允许拖动
            :setDraggableEnable(true) 
        end        
    end
    return cardGroup
end

-- 卡牌动画 
function PlayView:wordAction(wordCard, x, y)

 wordCard:runAction(cc.Sequence:create(  
         cc.EaseBackOut:create(cc.MoveTo:create(.2, cc.p(x, y))),  
         -- cc.FadeIn:create(.1),
         -- cc.EaseBackOut:create(cc.ScaleTo:create(1, 1.2, 1.2)),
         -- cc.EaseBackOut:create(cc.ScaleTo:create(1, 1, 1)),
         cc.CallFunc:create(function() 
            print("++++++++++++++++++++++++++++++++++++++++++++++++++++")
            if self.controller_:isRight() then -- 如果选对了
                -- 播放音效
                audio.playSound(GAME_SFX.coin) 
                print("---------------恭喜选对了。")
                self:method1()
                if self.controller_:isFinished() then -- 这句填完了
                    print("+++++++++++++++++++++你这句填完了")
                    -- 如果填完了，就直接不透明设置到 100%
                    transition.removeAction(self.downGroupfadeIn_)
                    self.downGroup:setOpacity(255)

                    -- 尚未通关。 继续刷新显示下一句
                    if not self.controller_:isVictory() then
                        -- 闪烁几下作提示效果。然后调用刷新
                        self.downGroup:runAction(
                            cc.RepeatForever:create(
                                cc.Sequence:create(
                                    cc.Blink:create(1.5, 3),
                                    cc.DelayTime:create(.2), -- 延时
                                    cc.CallFunc:create(function() -- 执行一个函数。
                                         self.controller_:onPeotryDataReady() 
                                    end)
                        )))

                    end
                end
            else -- 否则(选错了)
                -- 攻击了诗人的文字会消失
                wordCard:setVisible(false)
                audio.playSound(GAME_SFX.cannon) 
                self:method2()
                print("--------xxxxxxxx-------坑货，你选错了。")

                if self.controller_:isFailed() then -- 已经失败了
                    print("xxxxxxxxxxxxxxxxxxxxxxx 你挂了")
                end    
            end

         end)))    

    -- -- 卡牌飞行动画
    -- transition.moveTo(wordCard, 
    -- {
    --     time = .2, 
    --     delay = 0,
    --     x = x,
    --     y = y,
    --     easing = "backout",
    --     onComplete = function() 
            
    --             if self.controller_:isRight() then -- 如果选对了
    --                 -- 播放音效
    --                 audio.playSound(GAME_SFX.coin) 
    --                 print("---------------恭喜选对了。")
    --                 self:method1()
    --                 if self.controller_:isFinished() then -- 这句填完了
    --                     print("+++++++++++++++++++++你这句填完了")
    --                     -- 如果填完了，就直接不透明设置到 100%
    --                     self.downGroup:setOpacity(255)

    --                     -- 尚未通关。 继续刷新显示下一句
    --                     if not self.controller_:isVictory() then
    --                         self.controller_:onPeotryDataReady()
    --                     end
    --                 end
    --             else -- 否则(选错了)
    --                 -- 攻击了诗人的文字会消失
    --                 wordCard:setVisible(false)
    --                 audio.playSound(GAME_SFX.cannon) 
    --                 self:method2()
    --                 print("--------xxxxxxxx-------坑货，你选错了。")

    --                 if self.controller_:isFailed() then -- 已经失败了
    --                     print("xxxxxxxxxxxxxxxxxxxxxxx 你挂了")
    --                 end
    --             end
    --         end,
    --     })

end
-- 成功特效
function PlayView:method1()
    -- 读入plist文件
    local _emitter = cc.ParticleSystemQuad:create("fx/coin.plist")
    _emitter:setPosition(display.cx, display.height)
    :setAutoRemoveOnFinish(true)
    -- 获得粒子节点列表
    local batch = cc.ParticleBatchNode:createWithTexture(_emitter:getTexture())
    batch:addChild(_emitter)
    self:addChild(batch, 11)

    return _emitter
end
-- 受击特效
function PlayView:method2()
    -- 读入plist文件
    local _emitter = cc.ParticleSystemQuad:create("fx/githit.plist")
    _emitter:setPosition(display.cx, display.cy)
    :setAutoRemoveOnFinish(true)
    -- 获得粒子节点列表
    local batch = cc.ParticleBatchNode:createWithTexture(_emitter:getTexture())
    batch:addChild(_emitter)
    self:addChild(batch, 10)

    return _emitter
end

-- 卡牌复位动画 
function PlayView:wordActionBack(event)

    local wordCard = event.card
    local x, y = event.x, event.y 
    
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
            print("---------- 位置不对，已经放回 -----------")
        end
    })
end

--[[ 打乱卡牌的摆放位置 (随机效果不好)
function PlayView:randChildrenPosition(obj)
    print("-----obj:getChildrenCount()---------",obj:getChildrenCount())
    local childrenCount = obj:getChildrenCount()
    local objChildren = obj:getChildren()
    local randPos = tableEx_randSort(mathEx_randNumArray(childrenCount))

    -- 打乱位置 
    for i=1, childrenCount do 
        print("---- 随机位置 ----",randPos[i])
        print("-----随机位置---------",objChildren[ randPos[i] ]:getPosition(),randPos[i])
        local p1, p2 = objChildren[i]:getPositionX(),objChildren[ randPos[i] ]:getPositionX()
        objChildren[i]:setPositionX(p2)
        objChildren[ randPos[i] ]:setPositionX(p1)
    end
end
--]]

-- 获取炮台的碰撞框 
function PlayView:getEmplacement()
    return self.emplacement_
end

-- set 控制层对象变量
function PlayView:setController(controller)
    self.controller_ = controller
end
-- get 控制层对象变量
function PlayView:getController()
    return self.controller_
end

return PlayView