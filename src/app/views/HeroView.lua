
--[[--

“英雄”的视图

视图注册模型事件，从而在模型发生变化时自动更新视图

]]

local HeroView = class("HeroView", function()
    return display.newNode()
end)

function HeroView:ctor(hero)
    local cls = hero.class

    -- 通过代理注册事件的好处：可以方便的在视图删除时，清理所以通过该代理注册的事件，
    -- 同时不影响目标对象上注册的其他事件
    --
    -- EventProxy.new() 第一个参数是要注册事件的对象，第二个参数是绑定的视图
    -- 如果指定了第二个参数，那么在视图删除时，会自动清理注册的事件
    cc.EventProxy.new(hero, self)
        :addEventListener(cls.CHANGE_STATE_EVENT, handler(self, self.onStateChange_))
        :addEventListener(cls.HP_CHANGED_EVENT, handler(self, self.updateLabel_))
        :addEventListener(cls.UNDER_ATTACK_EVENT, handler(self, self.updateLabel_2))

    self.hero_ = hero

    self.sprite_ = display.newSprite():addTo(self)

    -- BOSS动画帧 (游戏进行界面用) 在 config 里定义了全局变量,这里按钮BOSS的ID来取
    -- getId 得到的 1 是字符串，和数字1是两个不同的KEY
    display.addSpriteFrames(
        -- BOSS_FRAMES_DATA[tonumber(self.hero_:getId())], 
        -- BOSS_FRAMES_IMAGE[tonumber(self.hero_:getId())]
        "BOSS_libai_Frames.plist", "BOSS_libai_Frames.png"
        )

    -- 得分
    self.idLabel_ = cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_BM, -- 常数 1
            text = string.format("%s:%s", "$", self.hero_:getScore()),
            size = 20,
            font = "UIFont.fnt",
            color = cc.c3b(255, 255, 0),
        })
        :align(display.CENTER_TOP, 0, 0)
        :addTo(self)
        :pos(0,485)

    -- HP 标签
    self.stateLabel_ = cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_BM, -- 常数 1
            text = "HP:10",
            size = 20,
            font = "UIFont.fnt",
            color = display.COLOR_RED,
        })
        :align(display.CENTER_TOP, 0, 0)
        :addTo(self)
        :pos(250,485)

    -- 按状态更新BOSS动画，初始
    self:updateSprite_(self.hero_:getState())

    -- 创建帧动画缓存
    -- self:addAnimationCache()

    -- 初始得分。这里这样写不太好。不应用直接用 Actor 的，应该创建个 Hero 继承 Actor 。
    self.hero_:setScore(0)
end

function HeroView:onStateChange_(event)
    self:updateSprite_(self.hero_:getState())
end
-- HP 标签
function HeroView:updateLabel_()
    local h = self.hero_
    self.stateLabel_:setString(string.format("HP:%d", h:getHp()))
end
-- 得分
function HeroView:updateLabel_2()
    local h = self.hero_
    self.idLabel_:setString(string.format("%s:%s", "$", h:getScore()))
    print("------------------------------------- updateLabel_2 --------------",h:getScore())
end

-- -- 不成功，暂时没有用这个
-- function HeroView:addAnimationCache()
--     -- animations 表示角色的三种动画
--     local animations = {"idle", "gethit"} 
--     -- animationFrameNum 表示三种动画分别有的帧总数。
--     local animationFrameNum = {2, 2}

--     for i = 1, #animations do
--         -- 1
--         local frames = display.newFrames( animations[i] .. "_%02d.png", 1, animationFrameNum[i])
--         -- 2
--         local animation = display.newAnimation(frames, 0.5 / 2)
--         -- 3
--         display.setAnimationCache(animations[i], animation)
--     end
-- end

-- 按状态，更新相应的图片资源用于显示
function HeroView:updateSprite_(state)
    local frameName
    local animation
    print("--------------  getId   -----------",self.hero_:getId(),self.hero_:getId() == "1")

if self.hero_:getId() == "1" then -- 目前只有李白做了动画。其它的，就直接放图算了

    if state == "idle" or state == "none" then
        print("--------------  state == \"idle\"   -----------")
        frameName = display.newFrames("idle_%02d.png", 1, 2) -- MyApp 里加载了图集,这里直接用
        animation = display.newAnimation(frameName, 0.5 / 2) -- 0.5s play 20 frames
    elseif state == "gethit" then

        print("--------------  state == \"gethit\"   -----------")
        frameName = display.newFrames("gethit_%02d.png", 1, 2) -- MyApp 里加载了图集,这里直接用
        animation = display.newAnimation(frameName, 0.1 / 2) -- 0.5s play 20 frames
    end

    if not frameName then return end
    transition.stopTarget(self.sprite_)
    self.sprite_:playAnimationForever(animation)

else
    --[[
    其实没有做动画的角色，暂时用这个顶一下。这样不合理吧。如果BOSS几十个，肯定不能打包在图集里啊，应该一个BOSS一张图，但是在这里 self.sprite_ 还不知道怎么实现。不过按理说，这里也都应该是动画才对。每个boss 一个 split
    所以这里只是暂时将就的.
    --]]
    self.sprite_:setSpriteFrame(display.newSpriteFrame(
        string.format("char_%03d.png", self.hero_:getId())
    ))
    :setPositionY(display.CENTER + 50 )
end

end

return HeroView
