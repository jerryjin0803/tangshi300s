--[[
    这里是控制层。
--]]

require("app.models.MathEx") -- 对 math 数学库的一些扩展功能
require("app.models.TableEx") -- 对 table 表的一些扩展功能
require("app.models.StringEx") -- sting 字符串的一些扩展功能

local PlayModel = import("..models.PlayModel") -- 逻辑层
local PlayController = class("PlayController")

function PlayController:ctor(levelIdx)
    -- -- 创建 PlayModel 对象负责游戏逻辑部分处理
    -- self.model_ = PlayModel.new(self,levelIdx)
end

-- onPeotryDataReady
function PlayController:initPlayController()
    -- 数据准备完成，开始游戏事件。
    self.model_:addEventListener(PlayModel.ON_GAME_START, 
        handler(self.view_, self.view_.onGameStart)) 
    -- 监听事件，拖放文字到指定区域后放手触发
    self.model_:addEventListener(PlayModel.CHOOSE_THE_WORD, 
        handler(self, self.onChooseTheWord)) 
    -- 胜利事件，当前诗词库已空。过关
    self.model_:addEventListener(PlayModel.ON_LEVEL_COMPLETED, 
        handler(self.view_, self.view_.onLevelCompleted)) 
    -- 挑战失败
    self.model_:addEventListener(PlayModel.ON_LEVEL_FAILURE, 
        handler(self.view_, self.view_.onLevelFailure)) 
    -- 诗词数据已经准备好。 更新相关 UI
    self.model_:addEventListener(PlayModel.ON_PEOTRY_DATA_READY, 
        handler(self.view_, self.view_.onPeotryDataReady))
    -- 卡牌归位
    self.model_:addEventListener(PlayModel.CHOOSE_END_BACK_EVENT, 
        handler(self.view_, self.view_.wordActionBack))
    -- -- 选错结果，诗人受击，扣分等
    -- self.model_:addEventListener(PlayModel.CHOOSE_WRONG_EVENT, 
    --     handler(self, self.onChooseWrong))
    -- 创建诗词的卡牌，布局，添加UI动画...
	self:onPeotryDataReady()

end

-- 当诗句准备好了，就通知 view 刷新
function PlayController:onPeotryDataReady()

    local WordUp, WordUp_Len = self.model_:getWordUp() -- 获取诗词的上句 和 字数
    local WordDown, WordDown_Len = self.model_:getWordDown() -- 获取诗词的下句 和 字数
    local WordPick, WordPick_Len = self.model_:getWordPick() -- 获取答案选项 和 字数

	-- 创建诗词的卡牌，添加UI动画...
    self.view_:onPeotryDataReady(WordUp,WordDown,WordPick)

    -- 更新其它UI元素
    -- balababala....
end

function PlayController:setModel(model)
	self.model_ = model
end

function PlayController:getModel()
	return self.model_
end
-- 把显示层对象，赋给自己的 self.view_ 变量
function PlayController:setView(view)
	self.view_ = view
    self.view_:setController(self) -- 把显示层的 controller_ 变量，设置为自己

end

function PlayController:getView()
	return  self.view_
end

-- 选择是否 Right
function PlayController:isRight()
    return self.model_.isRight()
end
-- 选择是否 Finished
function PlayController:isFinished()
    return self.model_.isFinished()
end
-- 选择是否 Victory
function PlayController:isVictory()
    return self.model_.isVictory()
end
-- 选择是否 Failed
function PlayController:isFailed()
    return self.model_.isFailed()
end
                            
-- 触摸事件是由 PlayView 触发的。交给 PlayController 来分配。
function PlayController:onTouch(event,cardGroup)
    --print("------------------ event.tag -----------------",event.tag)
    --print("--------xxx--------",cardGroup:getChildren()[event["tag"]]:getChildByName("labl"):getString())
    --print("----------- event.name -----------",event.card:getChildByName("labl"):getString())
    --dump(event,"----------- event -----------")

	-- 获取 “炮台” 对象碰撞框
	local emplacementBoundingBox_ = self.view_:getEmplacement():getBoundingBox()
    -- 调用逻辑层里的 onTouch 函数进行处理
	self.model_:onTouch(event,emplacementBoundingBox_)
	return true
end

-- -- 选错结果，诗人受击，扣分等
function PlayController:onChooseTheWord(event)
    -- 选完字
    self.view_:onChooseTheWord(event)

    if self.model_.isRight() then
        self.view_.heroViews_.hero_:setScore(self.view_.heroViews_.hero_:getScore()+10)
        self.view_.heroViews_.hero_:getready()
        -- print("------------- self.view_.heroViews_.hero_:getScore() ----------",self.view_.heroViews_.hero_:getScore())
        
    else
        if not self.view_.heroViews_.hero_:canUnderAttack() then return end
        self.view_.heroViews_.hero_:gethit()
    end

    return true
end

return PlayController