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