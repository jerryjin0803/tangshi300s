--[[
	对 sting 字符串的一些扩展功能
--]]

-- 生成一个 随机中文数组。 strLen:数组长度
function stringEx_randChineseArray(strLen)
    -- -- 默认数组内容 1 个
    local strLen = strLen or 1
    local my_table = {}
    local tempLen,rand_idx,tempStr

    -- 要记得汉字不要用默认的 string.len 取出来不一样的
    tempLen = stringEx_len(COMMON_CHINESE) 

    -- 随机播种子
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))
    
    -- 随机从字符串中取字
    for i=1,strLen do
        rand_idx = math.random(1,tempLen)
        table.insert(my_table, i, stringEx_sub(COMMON_CHINESE,rand_idx,rand_idx))
    end

    -- 查看排序后的结果
    -- print("mathEx_randChineseArray")
    -- tableEx_print(my_table)

    return my_table
end

-- 中文字符串长度
function stringEx_len(str)
    --local m,n = string.gsub (str, "[^\128-\193]", '笨')
    local m,n = str:gsub ("[^\128-\193]", '笨')
    return n
end

-- 中文字符串截取 。 str：字符串,s：开始位置,e：结束位置
function stringEx_sub(str,s,e)
    local s = s or 1   -- 未填写则默认为：1
    local e = e or s   -- 未填写则默认 end = start
    --str=str:gsub('([\001-\127])','\000%1')
    str=str:sub(1+3*(s-1),3+3*(e-1)) -- 因为纯中文所以直接这样处理了
    --str=str:gsub('\000','')
    return str

end

-- 中文字符串遍历
function stringEx_iterator(str)
    local my_table
    local tempStr = str
    local start = 1
    function closureF()
        print(str:sub(start, start + 2))        
        start = start + 3
    end
    return closureF
end

-- 中文字符串逐字转数组(因为中文字符串不能直接遍历)
function stringEx_str2Array(str)
    -- local my_table = {}
    -- local len = string.len(str)    
    -- for i=1,len,3 do  -- 每个汉字占 3 字节，所以步长是 3 
    --     my_table[i] = str:sub(i, i + 2) -- lua文档要用 utf8 ，按中文宽设置偏移量
    -- end
    -- return my_table

    local my_table = {}
    -- 取出诗句字数
    local strLen = stringEx_len(str)
    -- 转成数组方便遍历替换元素
    for i=1,strLen do
        my_table[#my_table+1] = stringEx_sub(str,i,i)
    end
    return my_table
end
