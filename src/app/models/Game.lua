require("app.models.TableEx") -- 对 table 表的一些扩展功能
require("app.models.MathEx") -- 对 math 数学库的一些扩展功能
require("app.models.StringEx") -- sting 字符串的一些扩展功能

local Game = class("Game")

local NeedWord_ = 2  --游戏难度。越高时，要填的空就越多。最多不超过全句 gLevel_
local peotry_anthology_ --当前关卡所用诗句
local OOXX_table_idx = {} --要填的字对应的索引
local number_successes = 0 -- 成功答题次数，用来判断是否答完。可继续下一句
local yes_or_no_ -- 本次选择的字是对是错

Game.HOLE_POSITION = cc.p(display.cx - 30, display.cy - 75)
Game.INIT_STARS = 5
Game.BUG_ENTER_HOLE_EVENT = "BUG_ENTER_HOLE_EVENT"
Game.PLAYER_DEAD_EVENT = "PLAYER_DEAD_EVENT"

Game.CHOOSE_THE_CORRECT_WORD = "CHOOSE_THE_CORRECT_WORD"
-- local BugAnt = import(".BugAnt")
-- local BugSpider = import(".BugSpider")

function Game:ctor(stage)
    self.stage_ = stage

    self.stars_ = Game.INIT_STARS
    -- self.bugs_ = {}
    -- self.bugsSprite_ = {}
    -- self.deadCount_ = 0

    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
end

-- function Game:getStars()
--     return self.stars_
-- end

-- function Game:getDeadCount()
--     return self.deadCount_
-- end

function Game:onTouch(event)

    if event.name == "began" then
        print("事件:" ,event.name, event.x, event.y)
        --self:onTouchBegan(event, x, y)
        return true
    elseif event.name == "moved" then
        print("事件:" ,event.name, event.x, event.y)
        --self:onTouchMoved(event, x, y)
        return true
    elseif event.name == "ended" then
        print("事件:" ,event.name, event.x, event.y)
        self:onTouchEnded(event)
        return true
    end

end


function Game:onTouchEnded(event)
    print("Game:onTouchEnded 手指离开：", event.x,event.y)
-- dump(OOXX_table_idx,"Game:onTouchEnded OOXX_table_idx")

    local p = cc.p(event.x,event.y)
    local value_ -- 存入正确答案，对应的位置。
    if cc.rectContainsPoint(self.stage_.emplacementBoundingBox, p) then -- 在炮台区放手

        for k,v in pairs(OOXX_table_idx) do -- 遍历正确答案数组，检查拖进来的文字是否正确
            --print("----------------------: ",k ,event["tag"])
            value_ = v
            if k == event["tag"] then -- 如果选对了，执行以下操作:
                yes_or_no_ = "yes" -- 选择结果是否正确
                number_successes = number_successes + 1 --填对字数 +1
                break -- 找到就不用继续了，直接跳出
            else
                yes_or_no_ = "no"  -- 选择结果是否正确
            end

        end

        -- 触发事件告诉场景已经选了字，请按相应规则刷新。( PlayScene 中在监听 )
        self:dispatchEvent({name = Game.CHOOSE_THE_CORRECT_WORD, type=yes_or_no_, value=value_})

        -- -- 检测本句是否填完，如果填完了就清屏。显示下一组诗句。
        -- if number_successes >= gLevel then  --不知为啥我就喜欢 >= 感觉完全点
        --     number_successes = 0 -- 清空填对计数
        --     --播放结束动画
        --     transition.scaleTo(self.upGroup, 
        --     {
        --         time = .2, 
        --         scale = 0.5,
        --         easing = "BACKIN",
        --         onComplete = function() self:showPoetryUp() end,-- 刷新下一句
        --     })
        -- end

    end
end 

-- 判断选没选对
function Game.check_YESorNO()
    -- 相当于 yes_or_no_ == "yes" ? "yes" : "no"
    return yes_or_no_ == "yes" and "yes" or "no"
end


-- 重构中临时用。先把数据转过了，方便随时调试
function Game.set_OOXX_table_idx(xxx)
    --print("======================OOXX_table_idx,传进 game 里来了")
    OOXX_table_idx = xxx
end

return Game
