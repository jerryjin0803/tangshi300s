--[[
    这里是逻辑层。
--]]

require("app.models.MathEx") -- 对 math 数学库的一些扩展功能
require("app.models.TableEx") -- 对 table 表的一些扩展功能
require("app.models.StringEx") -- sting 字符串的一些扩展功能

local PlayModel = class("PlayModel")

local peotry_group_ --当前关卡所用诗句
local peotry_Word -- 正在进行的整句
local rand_str_array -- 随机汉字数字组,生成7个随机汉字的数组
local OOXX_table_idx = {} --要填的字在句中的索引位置
local needWord_ --游戏难度。越高时，要填的空就越多。最多不超过全句 gLevel_
local number_successes -- 成功填空次数，用来判断是否答完。
local HP_ -- 诗人的血量。填错时会扣血。HP_ == 0 当前关卡就失败了。
local oPosX, oPosY

-- 状态类变量
local finished_ -- 本句是否填完
local chooseRight_ --选择结果是否正确
local victory_ -- 是否已经胜利

-- 自定义事件
PlayModel.ON_GAME_START = "ON_GAME_START"  -- 数据准备完成，开始游戏事件。
PlayModel.CHOOSE_THE_WORD = "CHOOSE_THE_WORD"  -- 选定文字事件。
PlayModel.ON_PEOTRY_DATA_READY = "ON_PEOTRY_DATA_READY"  -- 诗词数据已经准备好。
PlayModel.ON_LEVEL_COMPLETED = "ON_LEVEL_COMPLETED"  -- 胜利事件，当前诗词库已空时表示过关。
PlayModel.ON_LEVEL_FAILURE = "ON_LEVEL_FAILURE" -- 胜挑战失败 。
PlayModel.CHOOSE_END_BACK_EVENT = "CHOOSE_END_BACK_EVENT" -- 卡牌未拖到指定区域，要自动归位。

-- 构造函数
function PlayModel:ctor(stage, levelIdx)
    -- 获取场景对象
    self.stage_ = stage

    -- 添加事件组件
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()

    -- 初始化
    self:init(levelIdx)

    -- 诗库中弹出一句放到变量中： local peotry_Word
    self:getPeotry()

    -- 数据准备完成，开始游戏 (此例中 PlayController 在监听此事件 )
    self:dispatchEvent({name = PlayModel.ON_GAME_START})

end

function PlayModel:init(levelIdx)
    ------------------ 初始化数据 ---------------
    --复制一份并随机排序。因为使用时会有移除操作
    peotry_group_ = tableEx_randSort(POETRY_ANTHOLOGY[BOSS_LIST[levelIdx]])

    needWord_ = NEEDWORD or 1  --游戏难度。越高时，要填的空就越多。最多不超过全句 gLevel_
    number_successes = 0 -- 成功填空次数，用来判断是否答完。
    HP_ = 10 -- 诗人的血量。填错时会扣血。HP_ == 0 当前关卡就失败了。
    victory_ = false -- 胜利状态
end

-- 触摸事件是由 PlayController 触发的。交给 PlayModel 来处理。
function PlayModel:onTouch(event, target)
    --print("---------------- event.name ----------------",event.name)
    if event.name == "began" then
        --print("事件:" ,event.name, event.x, event.y)
        --self:onTouchBegan(event, x, y)
        -- 保存初始位置
        oPosX, oPosY = event.card:getPositionX(),event.card:getPositionY() --event.x, event.y
        return true
    elseif event.name == "moved" then
        --print("事件:" ,event.name, event.x, event.y)
        --self:onTouchMoved(event, x, y)
        return true
    elseif event.name == "ended" then
        --print("事件:" ,event.name, event.x, event.y)
        self:onTouchEnded(event,target)
        return true
    elseif event.name == "cancelled" then
        print("移出了屏幕，放后卡牌要飞回源处才行,后面再实现。模拟器上没反应，不知道是不是不支持")
    end
end

-- 没有用到
function PlayModel:onChoose_touch_event(event)
    dump(event.target,"event.target")
end

-- 当手指离开时，处理：
function PlayModel:onTouchEnded(event, target)
    print("PlayModel:onTouchEnded 手指离开：", event.name,event.x,event.y)
   -- self.stage_.downGroup:getChildByName(event["tag"]),"getChildByName"
   -- dump(self.stage_.downGroup:getChildren()[1],"getChildByName")
    local p = cc.p(event.x,event.y)
    local value_ -- 所选的字的 index, 在对就诗句中的位置 index。

    -- 在炮台区放手,则判断是否正确，并处理。否则，让卡牌回到原处
    if cc.rectContainsPoint(target, p) then 
        -- 遍历正确答案数组，检查拖进来的文字是否正确
        for k,v in pairs(OOXX_table_idx) do 
            value_ =  v
            -- 空格位置的内容  ==  所选卡牌(上的字)
            if stringEx_sub(peotry_Word[2],v,v) == event.text then
                OOXX_table_idx[k] = "0" -- 已经填过的字，就从索引中移除掉。
                chooseRight_ = true -- 选择结果是否正确
                break -- 找到就不用继续了，直接跳出
            else
                chooseRight_ = false -- 选择结果是否正确
            end
        end

        -- 本次选择结果是否正确
        if  chooseRight_ then
            number_successes = number_successes + 1 --填对字数 +1
            print("---------- 对了----------- HP: ",HP_)
        else
            HP_ = HP_ - 1 -- 简化规则，每错一字，扣一点血
            print("---------- 错了----------- HP: ",HP_)
        end

        -- 判断是否已经过关。(所有的空都填好了，就是过关)
        -- 如果成功填完就更新 finished_ 状态。并准备下一句的数据，以便显示层处理完动画后，显示下一句
        if number_successes >= math.min( needWord_, #peotry_Word) then -- 需填字数一定小于全句字数.
            finished_ = true  -- 状态 本句完成
            number_successes = 0 -- 清空计数器
        else
            finished_ = false  -- 状态 本句尚未完成
        end

        -- 选字完成，触发事件，相应场景会按规则刷新。(此例中 PlayController 在监听此事件 )
        self:dispatchEvent({name = PlayModel.CHOOSE_THE_WORD, 
            chooseRight = chooseRight_,  -- 本次有没有选对。
            value = value_, -- 卡牌上的字
            card = event.card  -- 被拖拽的卡牌对象
            })

        -- 检查是否失败。如果失败触发事件
        self:checkFailed()

        -- 如果本句完成。
        if self.isFinished() then
            -- 如果本句完成，并且诗词库已空。 这句一定要放到 self:getPeotry() 前面。
            -- 因为 self:getPeotry() 会从 peotry_group_ 数组弹出诗句
            if #peotry_group_ <= 0 and true or false then
                victory_ = true
            end
            -- 检查是否胜利, 如果胜利触发事件。(如果就不会执行到下一句了)
            self:checkVictory()

            -- 诗库中弹出一句放到变量中： local peotry_Word 
            self:getPeotry() 
        end
    else -- 否则，卡牌未放到选定区，则让卡牌回到原处
        print("------ event.card:getPosition() ---------",oPosX, oPosY )
        self:dispatchEvent({name = PlayModel.CHOOSE_END_BACK_EVENT, 
            card = event.card, 
            x = oPosX,
            y = oPosY
        })
    end
end 

-- 获取当前 HP 值
function PlayModel.get_HP()
    return HP_
end

-- 选择正确
function PlayModel.isRight()
    return chooseRight_
end

-- 判断本句是否填完
function PlayModel.isFinished()
    return finished_
end

-- 获取胜利状态
function PlayModel.isVictory()
    return victory_ 
end

-- 获取失败状态
function PlayModel.isFailed()
    return HP_ <= 0
end

-- 判断是否胜利过关
function PlayModel:checkVictory()
    if self.isVictory() then
        -- 胜利事件 (此例中 PlayController 有监听此事件 )
        self:dispatchEvent({name = PlayModel.ON_LEVEL_COMPLETED})
    end
    return self.isVictory()
end

-- 判断是否挑战失败
function PlayModel:checkFailed()
    if self.isFailed() then
        -- 失败事件 (此例中 PlayController 有监听此事件 )
        self:dispatchEvent({name = PlayModel.ON_LEVEL_FAILURE})
    end
    return HP_ <= 0
end

-- 获取上句
function PlayModel:getWordUp()
    local temp = stringEx_str2Array(peotry_Word[1])
    return temp, #temp
end

-- 获取下句
function PlayModel:getWordDown()
    -- 取出诗句字数
    local strLen = stringEx_len(peotry_Word[2])
    -- 转成数组方便遍历替换元素
    local tempTabel = {}
    tempTabel = stringEx_str2Array(peotry_Word[2])

    -- 按索引把要填空的字换成 ？问号
    for k,v in pairs(OOXX_table_idx) do
        tempTabel[v] = "?"
    end
    -- 返回数组
    return tempTabel, #tempTabel
end

-- 获取答案
function PlayModel:getWordPick()
    -- 默认答案卡牌的数量
    local strLen = 7
    -- 随机汉字数字组,生成7个随机汉字的数组
    rand_str_array = stringEx_randChineseArray(strLen) 
    for i=1,needWord_ do
        -- 把正确选项替换进来。后面在UI对显示位置做随机就可以了
        rand_str_array[i] = stringEx_sub(peotry_Word[2],OOXX_table_idx[i],OOXX_table_idx[i])
    end

    return rand_str_array, strLen
end

-- 弹出一句诗词。
function PlayModel:getPeotry()
    -- 如果此诗人的诗句表中还有，就取一句出来继续。否则就过关了
    print("=======================#peotry_group_ 长度:",#peotry_group_,"HP:",HP_)
    if(#peotry_group_>0) then
        -- 取出一句拆成数组
        peotry_Word = string.split(table.remove(peotry_group_,1), ",")

        -- 在下句中，随机生成填空位置
        local strLen = stringEx_len(peotry_Word[2])
        OOXX_table_idx = mathEx_randNumArray(strLen) --创建一个随机数组(里面就是空格的索引)
        OOXX_table_idx = tableEx_cut(OOXX_table_idx,needWord_) --根据难度级别留 N 个空格
    end
    return {"仄平平仄仄平仄","仄仄平平仄仄平"}
end

-- 暂时没用上
-- -- set 控制层对象变量
-- function PlayModel:setController(controller)
--     self.controller_ = controller
-- end
-- -- get 控制层对象变量
-- function PlayModel:getController()
--     return self.controller_
-- end

return PlayModel



