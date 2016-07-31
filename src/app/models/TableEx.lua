--[[
    对 table 表的一些扩展功能
--]]

-- 递归遍历表，打印出内容
function tableEx_print(t, i)  
    local indent ="" -- i缩进，当前调用缩进 
    local i = i or 0 -- 如果未进来，默认为 0
    for j = 0, i do   
        indent = indent .. "    " 
    end  
    for k, v in pairs(t) do   
        if (type(v) == "table") then -- type(v) 当前类型时否table 如果是，则需要递归，  
            print(indent .. "< " .. k .. " is a table />")  
            tableEx_print(v, i + 1) -- 递归调用  
            print(indent .. "/> end table ".. k .. "/>")  
        else -- 否则直接输出当前值  
            print(indent .. "<" .. k .. "=" .. v.."/>")  
        end  
    end  
end  

-- 截取表。
function tableEx_cut(my_table,tlen)

    if not my_table then
        error("用来截取的表是空的！")
    end
    local tempT = {}

    for i=1,tlen do
        tempT[i] = my_table[i]
    end

    --输出结果检查
    tableEx_print(tempT)

    return tempT
end

-- 按 key 找值
function tableEx_searchByKey(t, key)  
    -- 遍历表 t
    for k, v in pairs(t) do 
        -- 如果是要找 key，把值返回
        if k == key then
            return v
        end

        -- 如果值是一个"表" 
        if (type(v) == "table") then 
            tableEx_searchByKey(v, key) -- 递归调用  
        end
    end

    return nil --{李白={":你妹的啥也没有!"}}
end  

-- 对表进行随机排序
function tableEx_randSort(my_table)
    -- if (type(my_table) == "table") then
    --     print("----------------传进来的是表！----------------")  
    -- else
    --     print("----------------传进来的是 >> "..my_table)  
    -- end

    -- --随机播种子
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))  
    
    local tempValue
    local randNumber
    local tableLen = table.maxn(my_table)

    --填充数组
    for i=1, tableLen do
        randNumber = math.random(1,tableLen)--生成随机数

        --将当前下标 i 的内容与随机数 randNumber 下标对应的内容交换
        tempValue = my_table[randNumber]
        my_table[randNumber] = my_table[i]
        my_table[i] = tempValue
  
    end

    -- 查看排序后的结果
    --tableEx_print(my_table)

    return my_table
end

-- 递归遍历表，展开成字符串
function tableEx_Unfold(my_table, delimiter)
    local delimiter = delimiter or "," -- 默认为逗号分隔
    local tempStr = "" --临时变量用来存字符串

    --tableEx_Unfold
    for k, v in pairs(my_table) do
        if (type(v[1]) == "table") then -- type(v) 当前类型是否table 
        --如果是，则需要递归，  
            tableEx_Unfold(v) -- 递归调用  
        else -- 否则拼接字符串  
            tempStr = tempStr..delimiter..table.concat(v, delimiter)   
        end  
    end

    return tempStr
end