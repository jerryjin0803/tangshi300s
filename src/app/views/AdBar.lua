local AdBar = {}

function AdBar.new()
	-- 图都打包在 AllSprites 图集里了
    local sprite = cc.ui.UIPushButton.new({normal = "#AdBar.png"})
    sprite:align(display.BOTTOM_CENTER, display.cx, display.bottom)
    sprite:onButtonClicked(function()
        -- 打开网址。模拟器没反应，但是我只在模拟上玩。坑了
        device.openURL("http://blog.csdn.net/jx520")
    end)
    return sprite
end

return AdBar
