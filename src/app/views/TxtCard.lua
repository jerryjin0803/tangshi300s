--[[
    每个文字是一张卡牌
--]]

local TxtCard = class("TxtCard", function()
    return display.newNode()
end)

-- 构造函数
function TxtCard:ctor(text, txtBoxSize)
    print("---------- text ---------",text)
    assert(text, string.format("字都没有让我创建个毛啊，你传进来的什么鬼？", text))

    -- 卡牌的大小，如果未传参数进来，就默认用 cc.size(60,80) 
    local txtBoxSize = txtBoxSize  or cc.size(60,80) 

    --打开了子对象的透明度才受控制
    self:setCascadeOpacityEnabled(true) 

    -- 创建文字底图，加入容器
    local txtBg = display.newScale9Sprite(WORDCARDBG, txtBoxSize.width/2, txtBoxSize.height/2)
    :align(display.CENTER, 0, 0)
    :setContentSize(cc.size(txtBoxSize.width, txtBoxSize.height))
    self:addChild(txtBg) --也可以用 :addTo(self)

    -- 创建文字，加入容器
    local lab1 = display.newTTFLabel({text=text,color=c3,align=cc.ui.TEXT_ALIGN_CENTER,size=50})
    --lab1:setPosition(cc.p(txtBg:getContentSize().width/2,txtBg:getContentSize().height/2))
    :align(display.CENTER, 0, 0)
    :setName("labl")
    self:addChild(lab1) 

    -- 给卡牌添加触摸事件
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, 
        function(event)
            -- print("-------------- TxtCard:getName() --------------",self:getName())
            event["tag"] = self:getName() -- 加个标签用来判断事件发送者
            event["text"] = text -- 加个标签用来判存卡牌上的字（用起来方便点）
            event.card = self  -- 把自己也传进去。方便在回调函数中处理 事件发送者
            return self.controller_:onTouch(event) -- 交给 controller 去处理
        end
    )

    --[[ 加入测试点，显示锚点 0，0 位置，加入容器。 开发结束记得注释或删掉
    local anchor_point = cc.LayerColor:create(cc.c4b(0,0,0,100),5,5)
    :align(display.CENTER, 0, 0)
    self:addChild(anchor_point)
    --]]

end

-- set 控制层对象变量
function TxtCard:setController(controller)
    self.controller_ = controller
end
-- get 控制层对象变量
function TxtCard:getController()
    return self.controller_
end

return TxtCard