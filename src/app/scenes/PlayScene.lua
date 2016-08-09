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

    -- 创建 playView 对象负责游戏显示部分
    self.playView_ = PlayView.new(self.control_)
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

    -- 创建一个精灵作为背景图. plist里的图片名字前加 # 区分
    local bg = display.newSprite("#PlayLevelSceneBg.png") 
    -- make background sprite always align top --设置背景图位置
    bg:setPosition(display.cx, display.top - bg:getContentSize().height / 2)
    self:addChild(bg) -- 将背景图加载到场景默认图层 self 中。

    -- 例子里带的加载一张图片作为 Title。 不碍事，暂时留着
    local title = display.newSprite("#Title.png", display.left + 150, display.top - 50)
    title:setScale(0.5)
    self:addChild(title)

-- --调试用：显示上句
-- self.labelup = cc.ui.UILabel.new({
--     UILabelType = 2,
--     text = "仄平平仄仄平仄",
--     size = 50})
-- :align(display.CENTER, display.cx, display.top-200)
-- self:addChild(self.labelup)

-- --调试用：显示下句 
-- self.labeldown = cc.ui.UILabel.new({
--     UILabelType = 2,
--     text = "仄仄平平仄仄平",
--     size = 50})
-- :align(display.CENTER, display.cx, display.top-250)
-- self:addChild(self.labeldown)

-- -- 炮台,子弹(字)拖放上来。它就发射。(就是一个气泡按钮)
-- self.emplacement = display.newScale9Sprite("wordBg.png")
-- :setContentSize(cc.size(300, 200))
-- :align(display.CENTER, display.cx, display.bottom + 220)
-- :addTo(self)    
-- :setOpacity(80)
-- :addChild(-- 加入测试点，显示锚点 0，0 位置
--     cc.LayerColor:create(cc.c4b(0,0,0,255),5,5)
--     :align(display.CENTER, 0, 0)
--     )

-- dump(self.emplacement:getContentSize(),"--------self.emplacement:getContentSize()==============")

-- -- 获取炮台碰撞框
-- self.emplacementBoundingBox = self.emplacement:getBoundingBox()

----执行按钮(没用到，暂时留着)
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
    cc.ui.UIPushButton.new({normal = "#LevelListsCellIndicator.png", pressed = "#LevelListsCellSelected.png"})
        --:setButtonSize(20, 20)    --设置按钮大小
        :align(display.LEFT_TOP, display.left +10 , display.top - 10) 
        :onButtonClicked(function()
            audio.playSound(GAME_SFX.backButton)    -- 播放音效
            app:enterChooseLevelScene() -- 切换场景
        end)
        :addTo(self)

    -- --初始化关卡数据
    -- self:init(levelIdx)
end

return PlayScene


-- 初始化关卡数据
-- function PlayScene:init(levelIdx)
--     -- 创建显示诗句
--     -- self:showPoetryUp()

--     -- 创建进度条显示
--     -- self:loadBar()
-- end

-- function PlayScene:onEnter()
--     -- -- 挑战失败
--     -- self.game_:addEventListener(PlayModel.ON_GAME_START, 
--     --     handler(self, self.onGameStart)) 
--     -- -- 监听事件，拖放文字到指定区域后放手触发
--     -- self.game_:addEventListener(PlayModel.CHOOSE_THE_WORD, 
--     --     handler(self, self.onChooseTheWord))
--     -- -- 胜利事件，当前诗词库已空。过关
--     -- self.game_:addEventListener(PlayModel.ON_LEVEL_COMPLETED, 
--     --     handler(self, self.onLevelCompleted)) 
--     -- -- 挑战失败
--     -- self.game_:addEventListener(PlayModel.ON_LEVEL_FAILURE, 
--     --     handler(self, self.onLevelFailure)) 
--     -- -- 诗词数据已经准备好。 更新相关 UI
--     -- self.game_:addEventListener(PlayModel.ON_PEOTRY_DATA_READY, 
--     --     handler(self, self.onPeotryDataReady))
--     -- 创建诗词的卡牌，布局，添加UI动画...
--     self.playView:onPeotryDataReady()
-- end

-- function PlayScene:onExit()
--     print("--------------- 退出了 PlayScene:onExit() --------------")
-- end

-- --==============================  事件响应 ======================================
-- -- 玩家选定一个文字放到指定区域后会触发此事件。
-- function PlayScene:onGameStart(event)
--     print("++++++++++++++++ onGameStart +++++++++++++++++++")
-- end

-- -- 玩家选定一个文字放到指定区域后会触发此事件。
-- function PlayScene:onChooseTheWord(event)
--     --[[
--     print("----- onChooseTheWord ----",
--         "\n事件名称：",event.name,
--         "\n是否正确：",event.chooseRight,
--         "\n所选的字：",event.key,
--         "\n填空位置：",event.value) 
--     --]]
--     -- local p1,p2
--     -- local n1 = self.downGroup:getChildren()[event.value]
--     -- local n2 = self.emplacement

--     -- -- 如果正确，文字卡片飞向诗句中对应的位置。否则飞向屏幕中心对角色造成伤害。
--     -- if event.chooseRight then
--     --     -- 我也不知道这个偏移量是怎么产生的。和炮台大小位置有关，以后有空再查吧
--     --     p1 = n1:convertToWorldSpace(cc.p(34,40)) 
--     --     p2 = n2:convertToNodeSpace(p1)
--     --     -- 执行正确时的动画
--     --     self:wordAction(self.pickGroup:getChildren()[event.key], p2.x, p2.y)
--     --     -- 已经选过的卡牌就不再需要响应触摸事件了
--     --     self.pickGroup:getChildren()[event.key]:setTouchEnabled(false)
--     -- else
--     --     p1 = cc.p(display.cx+34, display.cy+40) 
--     --     p2 = n2:convertToNodeSpace(p1)
--     --     -- 执行错误时的动画
--     --     self:wordAction(self.pickGroup:getChildren()[event.key], p2.x, p2.y)
--     -- end
--     slef.playView:onChooseTheWord(event)
-- end

-- -- 胜利过关
-- function PlayScene:onLevelCompleted(event)
--     print("===============PlayScene:onLevelCompleted==============")
--     audio.playSound(GAME_SFX.levelCompleted)

--     --local dialog = display.newSprite("#LevelCompletedDialogBg.png")
--     local dialog = cc.ui.UIPushButton.new({normal = "#LevelCompletedDialogBg.png"})
--     dialog:setPosition(display.cx, display.top + dialog:getContentSize().height / 2 + 40)
--     dialog:onButtonClicked(function()
--         audio.playSound(GAME_SFX.backButton)    -- 播放音效
--         app:enterChooseLevelScene() -- 切换场景
--     end)

--     PlayScene.FGLayer:setVisible(true) -- 前景层默认被我们关掉了，现在先把它显示出来
--     PlayScene.FGLayer:addChild(dialog) -- 弹窗放进前景层里
--     transition.moveTo(dialog, {time = 0.7, y = display.cy + dialog:getContentSize().height / 2 + 40, easing = "BOUNCEOUT"})
-- end
-- -- 挑战失败
-- function PlayScene:onLevelFailure(event)
--     print("xxxxxxxxxxxxxxxx=PlayScene:onLevelFailure=xxxxxxxxxxxxxx")
--     audio.playSound(GAME_SFX.levelCompleted)

--     --local dialog = display.newSprite("#LevelCompletedDialogBg.png")
--     local dialog = cc.ui.UIPushButton.new({normal = "#LevelCompletedDialogBg.png"})
--     dialog:setPosition(display.cx, display.top + dialog:getContentSize().height / 2 + 40)
--     dialog:onButtonClicked(function()
--         audio.playSound(GAME_SFX.backButton)    -- 播放音效
--         app:enterChooseLevelScene() -- 切换场景
--     end)

--     PlayScene.FGLayer:setVisible(true) -- 前景层默认被我们关掉了，现在先把它显示出来
--     PlayScene.FGLayer:addChild(dialog) -- 弹窗放进前景层里
--     dialog:rotation(180)
--     transition.moveTo(dialog, {time = 0.7, y = display.cy + dialog:getContentSize().height / 2 + 40, easing = "BOUNCEOUT"})
-- end

-- -- 创建诗词的卡牌，布局，添加UI动画...
-- function PlayScene:onPeotryDataReady(event)
--     print("////////////////    PlayScene:onPeotryDataReady   /////////////////")
--     local xOffset,yOffset,xSpacing,ySpacing = 0,150,2,2 --文字显示的相关位置信息
--     local WordUp, WordUp_Len = self.game_:getWordUp() -- 获取诗词的上句 和 字数
--     local WordDown, WordDown_Len = self.game_:getWordDown() -- 获取诗词的下句 和 字数
--     local WordPick, WordPick_Len = self.game_:getWordPick() -- 获取答案选项 和 字数

--  -- ======================显示上句=========================
--     -- 先清除上一次用的诗句。type输出的结果是字符串所以要和"nil"对比。  
--     -- 这种写法没有后面的好，浪费。但是我任性
--     if ( type(self.upGroup) ~= "nil" ) then 
--         self.upGroup:removeFromParent()
--     end

--     -- 创建诗句的文字卡牌，装在一个容器里。
--     self.upGroup = self:creatCardGroup(self.game_:getWordUp())
--     self:addChild(self.upGroup)

--     -- 将容器放置初始位置
--     self.upGroup:pos(
--         xOffset + display.cx - ((txtBoxSize.width+ySpacing)*(WordUp_Len-1))/2+ySpacing,
--         display.cy 
--         )

--     -- 容器动画，移到正确位置
--     transition.moveTo(self.upGroup, 
--     {
--         time = .5, 
--         y = display.top - yOffset,
--         easing = "backout",
--         onComplete = function() print("上句已出，请对下句！") end,
--     })

--     -- ======================显示下句=========================
--     -- 先清除上一次用的诗句
--     if (self.downGroup) then -- 只要不为 nil 就会执行清理
--         self.downGroup:removeFromParent()
--     end

--     -- 创建诗句的文字卡牌，装在一个容器里。
--     self.downGroup = self:creatCardGroup(self.game_:getWordDown())
--     --打开了子对象的透明度才受控制
--     self.downGroup:setCascadeOpacityEnabled(true) 
--     self:addChild(self.downGroup)

--     -- 将容器放置初始位置
--     self.downGroup:pos(
--         xOffset + display.cx - ((txtBoxSize.width+ySpacing)*(WordDown_Len-1))/2+ySpacing,
--         display.top - yOffset - txtBoxSize.height - xSpacing 
--         )

--     -- 容器动画，淡入
--     self.downGroup:setOpacity(10)
--     transition.fadeIn(self.downGroup, 
--     {
--         time = 5, 
--         delay = 1,
--         --easing = "backout",
--         --onComplete = function() print("下句已出，请填空！") end,
--     })

--     -- ======================显示选词内容=========================
--     -- 先清除上一题的答案
--     if (self.pickGroup) then -- 只要不为 nil 就会执行清理
--         self.pickGroup:removeFromParent()
--     end

--     -- 创建一个容器,用来放答案选项
--     self.pickGroup = self:creatPickCardGroup(self.game_:getWordPick())
--     self:addChild(self.pickGroup)

--     -- 将容器放置初始位置
--     self.pickGroup:pos(
--         xOffset + display.cx - ((txtBoxSize.width+ySpacing)*(WordPick_Len-1))/2+ySpacing,
--         display.bottom + txtBoxSize.height
--         )

-- end

-- --===============================================================================
-- ---============================== 界面功能 ======================================
-- -- 创建文字(背景+文字)
-- function PlayScene:createTxtCard(text,point)
--     -- 创建文字的容器(用来陈放 背景+文字)
--     local textBox = display.newNode()
--     :setCascadeOpacityEnabled(true) --打开了子对象的透明度才受控制
--     :setPosition(point) -- 放置位置

--     -- 创建文字底图，加入容器
--     local txtBg = display.newScale9Sprite(WORDCARDBG, txtBoxSize.width/2, txtBoxSize.height/2)
--     :align(display.CENTER, 0, 0)
--     :setContentSize(cc.size(txtBoxSize.width, txtBoxSize.height))
--     :addTo(textBox)-- 也可以用 textBox 的 addChild 来添加 textBox:addChild(txtBg)

--     -- 创建文字，加入容器
--     local lab1 = display.newTTFLabel({text=text,color=c3,align=cc.ui.TEXT_ALIGN_CENTER,size=50})
--     --lab1:setPosition(cc.p(txtBg:getContentSize().width/2,txtBg:getContentSize().height/2))
--     :align(display.CENTER, 0, 0)
--     :addTo(textBox) -- 也可以用 textBox 的 addChild 来添加 textBox:addChild(lab1)

--     -- 加入测试点，显示锚点 0，0 位置，加入容器。 开发结束记得注释或删掉
--     local anchor_point = cc.LayerColor:create(cc.c4b(0,0,0,100),5,5)
--     :align(display.CENTER, 0, 0)
--     textBox:addChild(anchor_point)

--     -- 将容器返回。
--     return textBox
-- end

-- -- 创建诗句。 word_array：诗句字数组，每个元素就是一个字
-- function PlayScene:creatCardGroup(word_array)
--     -- 创建一个容器,用来放文字
--     local cardGroup = display.newNode()
--     -- 存放诗句字数的临时变量
--     local strLen = #word_array -- stringEx_len(word_array)
--     --文字卡牌的相关位置信息
--     local xOffset,yOffset,xSpacing,ySpacing = 0,0,2,2 

--     --逐字处理,要填的字改成空格 
--     for i=1,strLen do
--         self:createTxtCard(
--             -- stringEx_sub(word_array, i, i), -- 截取汉字
--             word_array[i], -- 截取汉字
--             cc.p(
--                  display.left + (txtBoxSize.width+ySpacing)*(i-1),
--                  display.bottom
--             )
--         ):addTo(cardGroup)
--     end
--     return cardGroup
-- end

-- -- 创建答案卡组。 word_array：随机汉字数组，每个元素就是一个字
-- function PlayScene:creatPickCardGroup(word_array)
--     -- 创建一个容器,用来放文字
--     local cardGroup = display.newNode()
--     -- 临时变量
--     local tempBtn

--     local strLen = #word_array
--     -- 文字卡牌的相关位置信息
--     local xOffset,yOffset,xSpacing,ySpacing = 0,0,2,2 
--     -- 生成排序的随机索引,在创建卡牌时，读这个索引，就实现了随机打乱卡牌顺序
--     local randPos = mathEx_randNumArray(strLen)

--     --逐个创建答案选项 
--     for i=1, strLen do 
--         -- 创建按钮
--         tempBtn = self:createTxtCard(
--             word_array[i],
--             cc.p(
--                     display.left + (txtBoxSize.width+ySpacing)*(randPos[i]-1),
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
                

--         -- 选字完成，触发事件，相应场景会按规则刷新。(此例中 PlayScene 有监听此事件 )
--         self.game_:dispatchEvent({name = PlayModel.CHOOSE_TOUCH_EVENT, target = tempBtn})
--                 return self.game_:onTouch(event) -- self.game_ 负责处理该事件
--             end
--         )
--     end
--     return cardGroup
-- end

-- -- -- 创建答案卡组。 word_array：随机汉字数组，每个元素就是一个字
-- -- function PlayScene:creatPickCardGroup(word_array)
-- --     -- 创建一个容器,用来放文字
-- --     local cardGroup = display.newNode()
-- --     -- 临时变量
-- --     local tempBtn, temp_str

-- --     local rand_str_array = word_array

-- --     local strLen = #word_array
-- --     -- 文字卡牌的相关位置信息
-- --     local xOffset,yOffset,xSpacing,ySpacing = 0,0,2,2 
-- --     -- 生成排序的随机索引,在创建卡牌时，读这个索引，就实现了随机打乱卡牌顺序
-- --     local randPos = mathEx_randNumArray(strLen)

-- --     --逐个创建答案选项 
-- --     for i=1, strLen do
-- --         temp_str = rand_str_array[i]
-- --         -- 创建按钮
-- --         tempBtn = self:createTxtCard(
-- --             temp_str,
-- --             cc.p(
-- --                     display.left + (txtBoxSize.width+ySpacing)*(i-1),--(randPos[i]-1),
-- --                     display.bottom
-- --                 )
-- --             )
-- --         cc(tempBtn):addComponent("components.ui.DraggableProtocol"):exportMethods()
        
-- --         :setDraggableEnable(true)
-- --         -- 添加到容器中
-- --         cardGroup:addChild(tempBtn)
-- --         tempBtn:setName(i)
-- --         --添加监听事件
-- --         tempBtn:setTouchEnabled(true)
-- --         tempBtn:addNodeEventListener(cc.NODE_TOUCH_EVENT, 
-- --             function(event)
-- --                 event["tag"] = i --加个标签用来判断事件发送者
-- --                 -- event:setName(i) --加个标签用来判断事件发送者
-- --                 return self.game_:onTouch(event,tempBtn) -- self.game_ 负责处理该事件
-- --             end
-- --         )
-- --     end
-- --     return cardGroup
-- -- end

-- -- 卡牌动画 
-- function PlayScene:wordAction(wordCard, x, y)
--     -- local animation = display.newAnimation(frames, 0.5 / 20) -- 0.5s play 20 frames
--     -- sprite:playAnimationForever(animation)

--     -- 卡牌飞行动画
--     transition.moveTo(wordCard, 
--     {
--         time = .2, 
--         delay = 0,
--         x = x,
--         y = y,
--         easing = "backout",
--         onComplete = function() 
--             -- 播放音效
--             audio.playSound(GAME_SFX.tapButton) 

--             if self.game_.isRight() then -- 如果选对了
--                 print("---------------恭喜选对了。")

--                 if self.game_.isFinished() then -- 这句填完了
--                     print("+++++++++++++++++++++你这句填完了")

--                     -- 尚未通关。 继续刷新显示下一句
--                     if not self.game_.isVictory() then
--                         self:onPeotryDataReady()
--                     end
--                 end
--             else -- 否则(选错了)
--                 -- 攻击了诗人的文字会消失
--                 wordCard:setVisible(false)

--                 print("--------xxxxxxxx-------坑货，你选错了。")

--                 if self.game_.isFailed() then -- 已经失败了
--                     print("xxxxxxxxxxxxxxxxxxxxxxx 你挂了")
--                 end
--             end
--         end,
--     })

-- end
