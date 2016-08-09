-- 创建文字(背景+文字)
function PlayScene:createTxtCard(text,point)
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



local TxtCard = class("TxtCard", function()
    return display.newNode()
end)

function TxtCard:ctor(levelData)
    cc.GameObject.extend(self):addComponent("components.behavior.EventProtocol"):exportMethods()

    -- self.batch = display.newBatchNode(GAME_TEXTURE_IMAGE_FILENAME)
    -- self.batch:setPosition(display.cx, display.cy)
    -- self:addChild(self.batch)

    -- self.grid = clone(levelData.grid)
    -- self.rows = levelData.rows
    -- self.cols = levelData.cols
    -- self.coins = {}
    -- self.flipAnimationCount = 0

    local offsetX = -math.floor(NODE_PADDING * self.cols / 2) - NODE_PADDING / 2
    local offsetY = -math.floor(NODE_PADDING * self.rows / 2) - NODE_PADDING / 2
    -- create board, place all coins
    for row = 1, self.rows do
        local y = row * NODE_PADDING + offsetY
        for col = 1, self.cols do
            local x = col * NODE_PADDING + offsetX
            local nodeSprite = display.newSprite("#BoardNode.png", x, y)
            self.batch:addChild(nodeSprite, NODE_ZORDER)

            local node = self.grid[row][col]
            if node ~= Levels.NODE_IS_EMPTY then
                local coin = Coin.new(node)
                coin:setPosition(x, y)
                coin.row = row
                coin.col = col
                self.grid[row][col] = coin
                self.coins[#self.coins + 1] = coin
                self.batch:addChild(coin, COIN_ZORDER)
            end
        end
    end

    self:setNodeEventEnabled(true)
    self:setTouchEnabled(true)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        return self:onTouch(event.name, event.x, event.y)
    end)

end

-- function Board:checkLevelCompleted()
--     local count = 0
--     for _, coin in ipairs(self.coins) do
--         if coin.isWhite then count = count + 1 end
--     end
--     if count == #self.coins then
--         -- completed
--         self:setTouchEnabled(false)
--         self:dispatchEvent({name = "LEVEL_COMPLETED"})
--     end
-- end

-- function Board:getCoin(row, col)
--     if self.grid[row] then
--         return self.grid[row][col]
--     end
-- end

-- function Board:flipCoin(coin, includeNeighbour)
--     if not coin or coin == Levels.NODE_IS_EMPTY then return end

--     self.flipAnimationCount = self.flipAnimationCount + 1
--     coin:flip(function()
--         self.flipAnimationCount = self.flipAnimationCount - 1
--         self.batch:reorderChild(coin, COIN_ZORDER)
--         if self.flipAnimationCount == 0 then
--             self:checkLevelCompleted()
--         end
--     end)
--     if includeNeighbour then
--         audio.playSound(GAME_SFX.flipCoin)
--         self.batch:reorderChild(coin, COIN_ZORDER + 1)
--         self:performWithDelay(function()
--             self:flipCoin(self:getCoin(coin.row - 1, coin.col))
--             self:flipCoin(self:getCoin(coin.row + 1, coin.col))
--             self:flipCoin(self:getCoin(coin.row, coin.col - 1))
--             self:flipCoin(self:getCoin(coin.row, coin.col + 1))
--         end, 0.25)
--     end
-- end

function Board:onTouch(event, x, y)
    -- if event ~= "began" or self.flipAnimationCount > 0 then return end

    -- local padding = NODE_PADDING / 2
    -- for _, coin in ipairs(self.coins) do
    --     local cx, cy = coin:getPosition()
    --     cx = cx + display.cx
    --     cy = cy + display.cy
    --     if x >= cx - padding
    --         and x <= cx + padding
    --         and y >= cy - padding
    --         and y <= cy + padding then
    --         self:flipCoin(coin, true)
    --         break
    --     end
    -- end
end

function Board:onEnter()
    self:setTouchEnabled(true)
end

function Board:onExit()
    self:removeAllEventListeners()
end

return TxtCard
