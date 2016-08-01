require("app.models.MathEx") -- 对 math 数学库的一些扩展功能
require("app.models.TableEx") -- 对 table 表的一些扩展功能
require("app.models.StringEx") -- sting 字符串的一些扩展功能

local Game = class("Game")

local peotry_group_ --当前关卡所用诗句
local peotry_Word -- 正在进行的整句
local peotry_WordUp_ --正在进行的上句
local peotry_WordDown_ --正在进行的下句
local peotry_down_ --当前关卡所用诗句
local OOXX_table_idx = {} --要填的字对应的索引
local needWord_ = 2  --游戏难度。越高时，要填的空就越多。最多不超过全句 gLevel_
local number_successes = 0 -- 成功填空次数，用来判断是否答完。
local HP_ -- 诗人的血量。填错时会扣血。HP_ == 0 当前关卡就失败了。

-- 状态类变量
local finished_ -- 本句是否填完
local chooseRight_ --选择结果是否正确
local victory_ -- 是否已经胜利

-- 自定义事件
Game.CHOOSE_THE_WORD = "CHOOSE_THE_WORD"  -- 选定文字事件。
Game.ON_LEVEL_COMPLETED = "ON_LEVEL_COMPLETED"  -- 胜利事件，当前诗词库已空时表示过关。

-- 构造函数
function Game:ctor(stage, levelIdx)
    self.stage_ = stage

    ------------------ 初始化数据 ----------------
    HP_ = 10 -- 先来 10 点试试 
    -- --复制一份。因为使用时会有移除操作
    peotry_group_ = tableEx_randSort(POETRY_ANTHOLOGY[BOSS_LIST[levelIdx]])
    -- dump(POETRY_ANTHOLOGY[BOSS_LIST[levelIdx]],"POETRY_ANTHOLOGY[BOSS_LIST[levelIdx]]")
    --- dump(peotry_group_,"peotry_group_")
    -- 添加事件组件
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    -- 诗库中弹出一句放到变量中： local peotry_Word
    self:getPeotry()
        -- self.bugs_ = {}
    -- self.bugsSprite_ = {}
    -- self.deadCount_ = 0

    --self:init(levelIdx)

end

-- function Game:init(levelIdx)
--     --复制一份。因为使用时会有移除操作
--     peotry_group_ = tableEx_randSort(POETRY_ANTHOLOGY[BOSS_LIST[levelIdx]])

-- end

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
            self:getPeotry() -- 诗库中弹出一句放到变量中： local peotry_Word

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

-- 选择正确
function Game.isRight()
    return chooseRight_
end

-- 判断本句是否填完
function Game.isFinished()
    return finished_
end

-- 判断是否胜利过关
function Game.isVictory()
    return victory_
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

-- 获取上句
function Game:getWordUp()
    local temp = stringEx_str2Array(peotry_Word[1])
    return temp, #temp
end

-- 获取下句
function Game:getWordDown()

    -- 取出诗句字数
    local strLen = stringEx_len(peotry_Word[2])
    -- 转成数组方便遍历替换元素
    local tempTabel = {}
    tempTabel = stringEx_str2Array(peotry_Word[2])

    -- 按索引把要填空的字换成 ？问号
    for k,v in pairs(OOXX_table_idx) do
        tempTabel[v] = "?"
    end
    -- OOXX_table_idx = mathEx_randNumArray(strLen) --创建一个随机数组，作为填空的索引
    -- OOXX_table_idx = tableEx_cut(OOXX_table_idx,needWord_) --根据难度级别留 N 个空格 

    -- --逐字处理,要填的字改成 ? 问题
    -- for i=1,strLen do
    --     temp_str = stringEx_sub(peotry_Word[2],i,i)

    --     -- 找出要留空的字，替换掉
    --     for j=1,needWord_ do
    --         if i == OOXX_table_idx[j] then
    --             --print("填空在：",v)
    --             temp_str = "?"
    --         end
    --     end

    --     -- -- 创建文字
    --     -- self.downGroup:addChild(
    --     --     self:createTxtBox(temp_str,cc.p(
    --     --     display.left + (txtBoxSize.width+ySpacing)*(i-1),
    --     --     display.bottom))
    --     --     :setTag(i)
    --     --     )
    -- end
    -- 返回数组
    return tempTabel, #tempTabel
end

-- 获取答案
function Game:getWordPick()
    -- 默认答案卡牌的数量
    local strLen = 7
    -- 随机汉字数字组,生成7个随机汉字的数组
    local rand_str_array = stringEx_randChineseArray(strLen) 
    for i=1,needWord_ do
        -- 把正确选项替换进来。后面在UI对显示位置做随机就可以了
        rand_str_array[i] = stringEx_sub(peotry_Word[2],OOXX_table_idx[i],OOXX_table_idx[i])
    end
    return rand_str_array, strLen
end

-- 弹出一句诗
function Game:getPeotry()
    -- 如果此诗人的诗句表中还有，就取一句出来继续。否则就过关了
    -- print("=======================#peotry_group_ 长度:",#peotry_group_,"HP:",HP_)
    -- dump(peotry_group_,"peotry_group_")
    if(#peotry_group_>0) then
        -- 取出一句拆成数组
        peotry_Word = string.split(table.remove(peotry_group_,1), ",")

        -- 在下句中，随机生成填空位置
        local strLen = stringEx_len(peotry_Word[2])
        OOXX_table_idx = mathEx_randNumArray(strLen) --创建一个随机数组(里面就是空格的索引)
        OOXX_table_idx = tableEx_cut(OOXX_table_idx,needWord_) --根据难度级别留 N 个空格 

    else
        print("诗集已空！闯关成功！")
        victory_ = true -- 当前已经胜利

        -- 设置状态，选对卡牌的动画播完就会检查一下。如果胜利就播过关动画
        -- 胜利事件，当前诗词库已空时表示过关。(此例中 PlayScene 有监听此事件 )
        -- self:dispatchEvent({name = Game.ON_LEVEL_COMPLETED})
    end

    return {"仄平平仄仄平仄","仄仄平平仄仄平"}
end

return Game



