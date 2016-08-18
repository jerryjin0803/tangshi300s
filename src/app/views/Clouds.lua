--[[
    这里是 Clouds 层。在背景上面漂浮的云
--]]

require("app.models.MathEx") -- 对 math 数学库的一些扩展功能

local scheduler = require("framework.scheduler")

local Clouds = class("Clouds", function()
    return display.newLayer()
end)

function Clouds:ctor(speed,makeSpeed)
    print("------------------ Clouds ---------------")

    -- 关闭事件吞噬，因为有些按钮放在后面的场景上
    self:setTouchSwallowEnabled(false)
    -- 开启了和会执行 onEnter、onExit 等事件。看下源码就知道了
    self:setNodeEventEnabled(true)

	self.cloudsGroup_ = {}

    self.speed_ = speed -- 云的移动数度
    self.makeSpeed_ = makeSpeed -- 出云的间隔时间
end

-- 造云函数。
function Clouds:MakeCloud(rseed)

	--随机播种子
    math.randomseed(tostring(rseed):reverse():sub(1, 6))
    randImg = string.format("#cloud_%02d.png", math.random(1, 9))

    -- --生成随机图片 index 。 图都打包在 AllSprites 图集里了
    -- randImg = string.format("#cloud_%02d.png", mathEx_randNumArray(9)[3])

	--随机播种子
    math.randomseed(tonumber(tostring(rseed):reverse():sub(2, 7)))
    --生成随机坐标
    randX = math.random(0, display.width)
    
	-- --随机播种子
 --    math.randomseed(tostring(os.time()):reverse():sub(4, 6))
 --    --生成随机坐标
 --    randY = math.random(0, display.height)

    -- print(randImg, randX, display.top - 100)

    -- 创建一朵云
    local cloud = display.newSprite(randImg, randX, display.top + 100 )

    self:addChild(cloud,0)
    if randX % 2 == 0 then
    	cloud:flipX(true) 
    	--print("------------- cloud:flipX(true)  --------------")
    end
     
    --随机播种子
    math.randomseed(tonumber(tostring(rseed):reverse():sub(3, 8)))
    --随机缩放
    cloud:setScale(math.random(0, 2))

    cloud.speed = self.speed_-- 云的移动数度
    self.cloudsGroup_[#self.cloudsGroup_ + 1] = cloud  -- 添加到云数组中

end

function Clouds:onEnter()
	local time = 0
    local function onInterval(dt)
        time = time + 1
        --dump(dt,"--------dt------------")
        --print(string.format("%d", time))
        -- 我不知道 dt 是啥，不过好像用来做随机种子不错
        self:MakeCloud(dt)
    end

    -- 每帧更新云的位置，超出视图就移除
	local function update(dt)
	    -- print("--------- Clouds:update ----------")
	    local len = #self.cloudsGroup_

	    for index = #self.cloudsGroup_, 1, -1 do
	        local bullet = self.cloudsGroup_[index]
	        local x, y = bullet:getPosition()
	        y = y - bullet.speed
	        bullet:setPositionY(y)

	        if y < 0 then
	            bullet:removeSelf()
	            table.remove(self.cloudsGroup_, index)
	        end
	    end

	end
    self.handleX = scheduler.scheduleGlobal(onInterval, self.makeSpeed_) -- 每隔一会生成一朵云
    self.handle = scheduler.scheduleUpdateGlobal(update) -- 每帧更新云的位置，超出视图就移除
    -- print("--------- Clouds:onEnter() ----------")

end

function Clouds:onExit()
    -- 退出时，两个记时器都要清掉
    scheduler.unscheduleGlobal(self.handle)
    scheduler.unscheduleGlobal(self.handleX)

    print("--------- Clouds:onExit() ----------")
end

return Clouds

--[[ 打乱卡牌的摆放位置 (随机效果不好)
function Clouds:randChildrenPosition(obj)
    print("-----obj:getChildrenCount()---------",obj:getChildrenCount())
    local childrenCount = obj:getChildrenCount()
    local objChildren = obj:getChildren()
    local randPos = tableEx_randSort(mathEx_randNumArray(childrenCount))

    -- 打乱位置 
    for i=1, childrenCount do 
        print("---- 随机位置 ----",randPos[i])
        print("-----随机位置---------",objChildren[ randPos[i] ]:getPosition(),randPos[i])
        local p1, p2 = objChildren[i]:getPositionX(),objChildren[ randPos[i] ]:getPositionX()
        objChildren[i]:setPositionX(p2)
        objChildren[ randPos[i] ]:setPositionX(p1)
    end
end
--]]