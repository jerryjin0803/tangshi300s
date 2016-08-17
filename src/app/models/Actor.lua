
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

--[[--

“角色”类

level 是角色的等级，角色的攻击力、防御力、初始 Hp 都和 level 相关

]]

local Actor = class("Actor", cc.mvc.ModelBase)

-- 定义事件
Actor.CHANGE_STATE_EVENT = "CHANGE_STATE_EVENT"
Actor.START_EVENT         = "START_EVENT"
Actor.READY_EVENT         = "READY_EVENT"
Actor.HP_CHANGED_EVENT    = "HP_CHANGED_EVENT"
Actor.UNDER_ATTACK_EVENT  = "UNDER_ATTACK_EVENT"

-- 定义属性
Actor.schema = clone(cc.mvc.ModelBase.schema)
Actor.schema["nickname"] = {"string"} -- 字符串类型，没有默认值
Actor.schema["hp"]       = {"number", 1}
Actor.schema["score"]    = {"number", 0}


function Actor:ctor(properties, events, callbacks)
    Actor.super.ctor(self, properties)

    -- 因为角色存在不同状态，所以这里为 Actor 绑定了状态机组件
    self:addComponent("components.behavior.StateMachine")
    -- 由于状态机仅供内部使用，所以不应该调用组件的 exportMethods() 方法，改为用内部属性保存状态机组件对象
    self.fsm__ = self:getComponent("components.behavior.StateMachine")

    -- 设定状态机的默认事件
    local defaultEvents = {
        -- 初始化后，角色处于 idle 状态
        {name = "start",  from = "none",    to = "idle" },
        -- 回到准备状态
        {name = "ready",  from = "*",  to = "idle"},
        -- 受击
        {name = "underAttack",  from = "idle",  to = "gethit"},
    }
    -- 如果继承类提供了其他事件，则合并
    -- print("-------------------------------------------")
    -- dump(events)
    -- print("-------------------------------------------")
    table.insertto(defaultEvents, checktable(events))

    -- 设定状态机的默认回调
    local defaultCallbacks = {
        onchangestate = handler(self, self.onChangeState_),
        onstart       = handler(self, self.onStart_),
        onready       = handler(self, self.onReady_),
        onunderAttack = handler(self, self.onUnderAttack_),
    }
    -- 如果继承类提供了其他回调，则合并
    table.merge(defaultCallbacks, checktable(callbacks))

    self.fsm__:setupState({
        events = defaultEvents,
        callbacks = defaultCallbacks
    })

    self.fsm__:doEvent("start") -- 启动状态机
end

-- 待机
function Actor:getready()
    print("----------")
    self.fsm__:doEvent("ready")
end

-- 受攻击
function Actor:gethit()
    print("----------")
    self.fsm__:doEvent("underAttack",2)
    -- self.fsm__:doEvent("ready",)
end

-- 获取得分
function Actor:getScore()
    return self.score_
end

-- 设置得分
function Actor:setScore(score)
    print("---------- 设置当前得分为：----------",score)
    self.score_ = score
    return self
end

function Actor:getNickname()
    return self.nickname_
end

function Actor:canUnderAttack()
    print("---------- 正无聊，能挨揍 ----------")
    return self.fsm__:canDoEvent("underAttack")
end

function Actor:getHp()
    return self.hp_
end

function Actor:getState()
    return self.fsm__:getState()
end

function Actor:setFullHp()
    self.hp_ = 10
    return sef
end

function Actor:getId()
    return self.id_
end

function Actor:increaseHp(hp)
    local newhp = self.hp_ + hp
    if newhp > self:getMaxHp() then
        newhp = self:getMaxHp()
    end

    if newhp > self.hp_ then
        self.hp_ = newhp
        self:dispatchEvent({name = Actor.HP_CHANGED_EVENT})
    end

    return self
end

function Actor:decreaseHp(hp)

    local newhp = self.hp_ - hp
    if newhp <= 0 then
        newhp = 0
    end

    if newhp < self.hp_ then
        self.hp_ = newhp
        self:dispatchEvent({name = Actor.HP_CHANGED_EVENT})
    end

    return self
end

---- state callbacks

function Actor:onChangeState_(event)
    printf("actor %s:%s state change from %s to %s", self:getId(), self.nickname_, event.from, event.to)
    event = {name = Actor.CHANGE_STATE_EVENT, from = event.from, to = event.to}
    --print("++++++++++++++++++++++++ Actor:onChangeState_(event)------------------------------")
    self:dispatchEvent(event)
end

-- 启动状态机时，设定角色默认 Hp
function Actor:onStart_(event)
    printf("actor %s:%s start", self:getId(), self.nickname_)
    self:setFullHp()
    self:dispatchEvent({name = Actor.START_EVENT})
end

function Actor:onReady_(event)
    printf("actor %s:%s ready", self:getId(), self.nickname_)
    self:dispatchEvent({name = Actor.READY_EVENT})
end

function Actor:onUnderAttack_(event)
    self:dispatchEvent({name = Actor.UNDER_ATTACK_EVENT})
end

return Actor
