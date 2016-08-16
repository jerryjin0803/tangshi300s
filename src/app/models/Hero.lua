
--[[--

“英雄”类

从“角色”类继承，增加了经验值等属性

]]

local Actor = import(".Actor")
local Hero = class("Hero", Actor)

Hero.schema = clone(Actor.schema)


return Hero
