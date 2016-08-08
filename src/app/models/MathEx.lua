--[[
    对 math 数学库的一些扩展功能
--]]

-- 生成一个从 minN 到 maxN 的随机数字数组。minN 到 maxN 是随机范围
function mathEx_randNumArray(maxN,minN)
    -- 默认数组内容 1 个
    local maxN = maxN or 1
    local minN = minN or 1
    local my_table = {}
    --print("--------------mathEx_randNumArray---------------",type(COMMON_CHINESE),COMMON_CHINESE[1])

    -- --随机播种子
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))

    --填充数组
    for i = minN, maxN do
        my_table[i] = i
    end
    
    -- 打乱顺序
    for i = minN, maxN do
        randNumber = math.random(1,maxN)--生成随机数
        --将当前下标 i 的内容与随机数 randNumber 下标对应的内容交换
        my_table[randNumber],my_table[i] = my_table[i],my_table[randNumber]
    end

    -- 查看排序后的结果
    --print("mathEx_randNumArray")
    --tableEx_print(my_table)

    return my_table
end

--[[
 写的很 high 但其实 cocos2d 已经有实现了。也不知道我在写个毛。
 cc.pGetAngle(self,other),cc.pGetDistance(startP,endP) 等等都有。
--]]

-- 计算两点间距离： 参数:点A的 x,y 坐标，点B的 x,y 坐标
function mathEx_getDist(x1, y1, x2, y2)
    local dx,dy = x1 - x2, y1 - y2
    return math.sqrt(dx*dx + dy*dy)
end

-- 计算两点间距离： 参数:两个点
function mathEx_getDistByPoint(p1, p2)
    return mathEx_dist(p1.x,p1.y,p2.x,p2.y)
end

-- 计算两点间连线的角度
function mathEx_getAngle(x1, y1, x2, y2)
    return math.atan((y2-y1)/(x2-x1))
end

-- 计算两点间连线的角度 参数:两个点
function mathEx_getAngleByPoint(p1, p2)
    return mathEx_getAngle(p1.x, p1.y, p2.x, p2.y)
end

