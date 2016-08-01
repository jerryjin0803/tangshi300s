require("app.models.MathEx") -- 对 math 数学库的一些扩展功能
require("app.models.TableEx") -- 对 table 表的一些扩展功能
require("app.models.StringEx") -- sting 字符串的一些扩展功能

local Game = class("Game")

local peotry_anthology_ --当前关卡所用诗句
local OOXX_table_idx = {} --要填的字对应的索引
local needWord_ = 2  --游戏难度。越高时，要填的空就越多。最多不超过全句 gLevel_
local number_successes = 0 -- 成功填空次数，用来判断是否答完。
local HP_ -- 诗人的血量。填错时会扣血。HP_ == 0 当前关卡就失败了。

-- 状态类变量
local finished_ -- 本句是否填完
local chooseRight_ --选择结果是否正确

-- 自定义事件
Game.CHOOSE_THE_WORD = "CHOOSE_THE_WORD"  -- 选定文字事件。

-- 构造函数
function Game:ctor(stage)
    self.stage_ = stage

    -- 初始化数据
    HP_ = 10 -- 先来 10 点试试 

    -- self.bugs_ = {}
    -- self.bugsSprite_ = {}
    -- self.deadCount_ = 0

    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
end

-- 触摸事件是由 PlayScene 触发的。交给 Game 来处理。
function Game:onTouch(event)

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
        self:onTouchEnded(event)
        return true
    end

end

-- 当手指离开时，处理：
function Game:onTouchEnded(event)
-- print("Game:onTouchEnded 手指离开：", event.x,event.y)
-- dump(OOXX_table_idx,"Game:onTouchEnded OOXX_table_idx")

    local p = cc.p(event.x,event.y)
    local yes_or_no_ -- 本次选择的字是对是错
    local key_, value_ -- 所选的字的 index, 在对就诗句中的位置 index。

    if cc.rectContainsPoint(self.stage_.emplacementBoundingBox, p) then -- 在炮台区放手

        -- 遍历正确答案数组，检查拖进来的文字是否正确
        for k,v in pairs(OOXX_table_idx) do 
            key_, value_ = event["tag"], v
            if k == event["tag"] then -- 如果选对了，执行以下操作:
                yes_or_no_ = "yes" -- 选择结果是否正确
                chooseRight_ = true -- 选择结果是否正确
                number_successes = number_successes + 1 --填对字数 +1
                break -- 找到就不用继续了，直接跳出
            else
                yes_or_no_ = "no"  -- 选择结果是否正确
                chooseRight_ = false -- 选择结果是否正确
                HP_ = HP_ - 1 -- 简化规则，每错一字，扣一点血
            end
        end

        -- print("选择的卡: "..key_,"对应空格：".. value_)

        -- 判断是否已经过关。(所有的空都填好了，就是过关)
        -- 如果成功填完就更新 finished_ 状态。并准备下一句的数据，以便显示层处理完动画后，显示下一句
        if number_successes >= needWord_ then
            finished_ = true  -- 状态 为本句完成
            number_successes = 0 -- 清空计数器
            -- 更新相关数据
            -- ......

        else
            finished_ = false  -- 状态 本句尚未完成
        end

        -- 选字完成，触发事件，相应场景会按规则刷新。(此例中 PlayScene 有监听此事件 )
        self:dispatchEvent({name = Game.CHOOSE_THE_WORD, 
            yesOrNo = yes_or_no_, 
            key = event["tag"],
            value = value_,
            --passed = finished_
            })
    end
end 

-- 获取当前 HP 值
function Game.get_HP()
    return HP_
end

-- 判断本句是否填完
function Game.isRight()
    return chooseRight_
end

-- 判断本句是否填完
function Game.isFinished()
    return finished_
end

-- 判断是否胜利过关
function Game.isVictory()
    -- return finished_
end

-- 判断是否挑战失败
function Game.isFailed()
    return HP_ <= 0
end

-- 重构中临时用。先把数据转过了，方便随时调试
function Game.set_OOXX_table_idx(xxx)
    --print("======================OOXX_table_idx,传进 game 里来了")
    OOXX_table_idx = xxx
end

return Game
