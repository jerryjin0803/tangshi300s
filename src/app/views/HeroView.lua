
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

    -- 得分
    self.idLabel_ = cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_BM, -- 常数 1
            text = string.format("%s:%s", "$", self.hero_:getScore()),
            size = 20,
            font = "UIFont.fnt",
            color = cc.c3b(255, 255, 0),
        })
        :align(display.RIGHT, 0, 0)
        :addTo(self)
        :pos(-50,450)

    -- HP 标签
    self.stateLabel_ = cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_BM, -- 常数 1
            text = "",
            size = 20,
            font = "UIFont.fnt",
            color = display.COLOR_RED,
        })
        :align(display.CENTER_TOP, 0, 0)
        :addTo(self)
        :pos(250,490)

    self:updateSprite_(self.hero_:getState())
    self:updateLabel_()

    -- 创建帧动画缓存
    -- self:addAnimationCache()

    -- 初始得分。这里这样写不太好。不应用直接用 Actor 的，应该创建个 Hero 继承 Actor 。
    self.hero_:setScore(0)
end

function HeroView:onStateChange_(event)
    self:updateSprite_(self.hero_:getState())
end

function HeroView:updateLabel_()
    local h = self.hero_
    self.stateLabel_:setString(string.format("HP:%d", h:getHp()))
end

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

end

return HeroView
