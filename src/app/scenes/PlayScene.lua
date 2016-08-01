require("app.models.MathEx") -- 对 math 数学库的一些扩展功能
require("app.models.TableEx") -- 对 table 表的一些扩展功能
require("app.models.StringEx") -- sting 字符串的一些扩展功能

local Levels = import("..data.Levels") -- 关卡等级数据，诗人诗句之类的
local BubbleButton = import("..views.BubbleButton") -- 官方例子里的气泡按钮,正好用来当发炮效果
local Game = import("..models.Game") -- 逻辑层

local peotry_anthology_ --当前关卡所用诗句
local peotry_word = {}  -- 整句诗从字符器拆成上下句，放到此数组中
local OOXX_table_idx = {}--要填的字对应的索引
local gLevel =2  --游戏难度。越高时，要填的空就越多。最多不超过全句
local txtBoxSize = cc.size(60,80) -- 文本框大小
local c1 = cc.c4b(150,200,190,200) -- 填充颜色值1
local c2 = cc.c4b(100,100,50,200) -- 填充颜色值2
local buttonBoundingBoxs = {}-- 用来存放正确答案的碰撞框。
local number_successes = 0 -- 成功答题次数，用来判断是否答完。可继续下一句


local PlayScene = class("PlayScene", function()
    return display.newScene("PlayScene")
end)


function PlayScene:ctor(levelIdx)
    -- 创建 Game 对象负责游戏逻辑部分处理
    self.game_ = Game.new(self)

    -- 创建一个精灵作为背景图. plist里的图片名字前加 # 区分
    local bg = display.newSprite("#PlayLevelSceneBg.png") 
    -- make background sprite always align top --设置背景图位置
    bg:setPosition(display.cx, display.top - bg:getContentSize().height / 2)
    self:addChild(bg) -- 将背景图加载到场景默认图层 self 中。

    --初始化关卡数据
    self:init(levelIdx)

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

    -- 炮台,子弹(字)拖放上来。它就发射。(就是一个气泡按钮)
    self.emplacement = display.newScale9Sprite("wordBg.png")
    :setContentSize(cc.size(200, 200))
    :align(display.CENTER, display.cx, display.bottom + 200)
    :addTo(self)    
    :setOpacity(80)
    :addChild(-- 加入测试点，显示锚点 0，0 位置
        cc.LayerColor:create(cc.c4b(0,0,0,255),5,5)
        :align(display.CENTER, 0, 0)
        )

    -- 获取炮台碰撞框
    self.emplacementBoundingBox = self.emplacement:getBoundingBox()

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
end

function PlayScene:init(levelIdx)
	--复制一份。因为使用时会有移除操作
	peotry_anthology_ = tableEx_randSort(POETRY_ANTHOLOGY[BOSS_LIST[levelIdx]])
    -- 创建显示诗句
    self:showPoetryUp()

    -- 创建进度条显示
    -- self:loadBar()
end

-- function PlayScene:onLevelCompleted()
--     audio.playSound(GAME_SFX.levelCompleted)

--     local dialog = display.newSprite("#LevelCompletedDialogBg.png")
--     dialog:setPosition(display.cx, display.top + dialog:getContentSize().height / 2 + 40)
--     self:addChild(dialog)

--     transition.moveTo(dialog, {time = 0.7, y = display.top - dialog:getContentSize().height / 2 - 40, easing = "BOUNCEOUT"})
-- end


function PlayScene:onEnter()
    -- 监听事件，拖放文字到指定区域后放手触发
    self.game_:addEventListener(Game.CHOOSE_THE_WORD, 
        handler(self, self.onChooseTheWord))

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
    --dump(OOXX_table_idx,"OOXX_table_idx")
    self.game_.set_OOXX_table_idx(OOXX_table_idx)--temp-----

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

    -- ======================显示选词内容=========================
    -- 答案选项的个数
    strLen = 7
    --随机汉字数字组,生成7个随机汉字的数组
    local rand_str_array = stringEx_randChineseArray(strLen) 
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
        tempBtn:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
            event["tag"] = i --加个标签用来判断事件发送者
            return self.game_:onTouch(event) --self:onTouch(event, event.x, event.y)
        end)

        --self.pickGroup:addChild()
    end
    self:addChild(self.pickGroup)

    -- 将容器放置初始位置
    self.pickGroup:pos(
        xOffset + display.cx - ((txtBoxSize.width+ySpacing)*(strLen-1))/2+ySpacing,
        display.bottom + txtBoxSize.height
        )

end
--==============================================================================

-- 创建文字(背景+文字)
function PlayScene:createTxtBox(text,point)
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

-- 玩家选定一个文字放到指定区域后会触发此事件。
function PlayScene:onChooseTheWord(event)
    --[[print("----- onChooseTheWord ----",
        "\n事件名称：",event.name,
        "\n是否正确：",event.yesOrNo,
        "\n所选的字：",event.key,
        "\n填空位置：",event.value) 
    --]]

    local p1,p2
    local n1 = self.downGroup:getChildren()[event.value]
    local n2 = self.emplacement

    -- 如果正确，文字卡片飞向诗句中对应的位置。否则飞向屏幕中心对角色造成伤害。
    if event.yesOrNo == "yes" then
        -- 我也不知道这个偏移量是怎么产生的cc.p(84,20)。以后有空再查吧
        p1 = n1:convertToWorldSpace(cc.p(84,20)) 
        p2 = n2:convertToNodeSpace(p1)
        -- 执行正确时的动画
        self:wordAction(self.pickGroup:getChildren()[event.key], p2.x, p2.y)
    else
        p1 = cc.p(display.cx+84, display.cy+20) 
        p2 = n2:convertToNodeSpace(p1)
        -- 执行错误时的动画
        self:wordAction(self.pickGroup:getChildren()[event.key], p2.x, p2.y)
    end

    
end


-- 卡牌动画 
function PlayScene:wordAction(wordCard, x, y)
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

            if self.game_.isRight() then -- 如果选对了
                print("---------------恭喜选对了。")

                if self.game_.isFinished() then -- 这句填完了
                    print("+++++++++++++++++++++你这句填完了")
                    self:showPoetryUp() 

                    if self.game_.isVictory() then -- 通关了
                        print("$$$$$$$$$$$$$$$$$$$$$$ 你通关了")
                    end
                end
            else -- 否则(选错了)
                print("--------xxxxxxxx-------坑货，你选错了。")

                if self.game_.isFailed() then -- 已经失败了
                    print("xxxxxxxxxxxxxxxxxxxxxxx 你挂了")
                end
            end
        end,
    })

    -- 播放音效
    audio.playSound(GAME_SFX.tapButton) 

end

return PlayScene
