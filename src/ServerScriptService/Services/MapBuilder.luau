local MapBuilder = {}
local Workspace = game:GetService("Workspace")
local MAP_NAME = "MiningWorld"

local function part(parent, name, size, position, material, color, shape)
    local p = Instance.new("Part")
    p.Name, p.Size, p.Position = name, size, position
    p.Anchored = true
    p.Material = material or Enum.Material.SmoothPlastic
    p.Color = color or Color3.fromRGB(120,120,120)
    p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
    if shape then p.Shape = shape end
    p.Parent = parent
    return p
end

local function label(parent, text, position, width, color, height)
    local a = part(parent, "LabelAnchor", Vector3.new(.2,.2,.2), position, Enum.Material.SmoothPlastic, Color3.new(1,1,1))
    a.Transparency, a.CanCollide = 1, false
    local gui = Instance.new("BillboardGui")
    gui.Size, gui.StudsOffset, gui.AlwaysOnTop = UDim2.fromOffset(width or 180, height or 52), Vector3.new(0,1,0), true
    gui.Parent = a
    local t = Instance.new("TextLabel")
    t.Size, t.BackgroundTransparency, t.Text = UDim2.fromScale(1,1), 1, text
    t.TextScaled, t.Font = true, Enum.Font.GothamBlack
    t.TextColor3, t.TextStrokeTransparency = color or Color3.new(1,1,1), .15
    t.Parent = gui
end

local function tree(parent, pos, s)
    s = s or 1
    part(parent,"TreeTrunk",Vector3.new(1.7,6,1.7)*s,pos+Vector3.new(0,3*s,0),Enum.Material.Wood,Color3.fromRGB(105,70,42),Enum.PartType.Cylinder)
    part(parent,"TreeCrown",Vector3.new(7,7,7)*s,pos+Vector3.new(0,7*s,0),Enum.Material.Grass,Color3.fromRGB(56,145,65),Enum.PartType.Ball)
    part(parent,"TreeCrownSmall",Vector3.new(5,5,5)*s,pos+Vector3.new(0,10*s,0),Enum.Material.Grass,Color3.fromRGB(78,170,78),Enum.PartType.Ball)
end

local function crystal(parent,pos,s,color)
    local c = part(parent,"Crystal",Vector3.new(1.5,5,1.5)*s,pos+Vector3.new(0,2.5*s,0),Enum.Material.Neon,color,Enum.PartType.Cylinder)
    c.Orientation = Vector3.new(0,0,25)
end

local function rock(parent,pos,size,color)
    local r = part(parent,"MiningRock",size,pos+Vector3.new(0,size.Y/2,0),Enum.Material.Slate,color,Enum.PartType.Ball)
    r:SetAttribute("Mineable",true)
    local glow = part(parent,"RockAccent",Vector3.new(size.X*.35,.18,size.Z*.35),r.Position+Vector3.new(0,size.Y*.35,0),Enum.Material.Neon,Color3.fromRGB(70,215,255),Enum.PartType.Cylinder)
    glow.CanCollide = false
end

local function lantern(parent,pos,accent)
    part(parent,"LampPost",Vector3.new(.6,7,.6),pos+Vector3.new(0,3.5,0),Enum.Material.Wood,Color3.fromRGB(105,70,42))
    part(parent,"Lamp",Vector3.new(1.8,1.8,1.8),pos+Vector3.new(0,7,0),Enum.Material.Neon,accent or Color3.fromRGB(255,203,62),Enum.PartType.Ball)
end

local function station(parent,name,pos,color,text)
    part(parent,name,Vector3.new(16,1.2,13),pos,Enum.Material.Neon,color)
    part(parent,name.."Body",Vector3.new(11,3,7),pos+Vector3.new(0,2,0),Enum.Material.SmoothPlastic,Color3.fromRGB(35,38,45),Enum.PartType.Cylinder)
    part(parent,name.."Glow",Vector3.new(8,.3,5),pos+Vector3.new(0,3.6,0),Enum.Material.Neon,color,Enum.PartType.Cylinder)
    label(parent,text,pos+Vector3.new(0,6,0),170,Color3.new(1,1,1))
end

local function eggModel(parent,name,pos,color)
    local base = part(parent,name.."EggBase",Vector3.new(5,.7,5),pos,Enum.Material.Neon,color,Enum.PartType.Cylinder)
    base.CanCollide = false
    local egg = part(parent,name,Vector3.new(3.4,4.3,3.4),pos+Vector3.new(0,2.5,0),Enum.Material.SmoothPlastic,Color3.fromRGB(247,247,247),Enum.PartType.Ball)
    egg.CanCollide = false
    local stripe = part(parent,name.."Stripe",Vector3.new(3.45,.55,3.45),pos+Vector3.new(0,2.4,0),Enum.Material.Neon,color,Enum.PartType.Cylinder)
    stripe.CanCollide = false
    return egg
end

local function eggPedestal(parent,name,pos,color)
    part(parent,name.."Pedestal",Vector3.new(8,1.2,8),pos,Enum.Material.Marble,Color3.fromRGB(245,248,255),Enum.PartType.Cylinder)
    part(parent,name.."Glow",Vector3.new(6.5,.35,6.5),pos+Vector3.new(0,.8,0),Enum.Material.Neon,color,Enum.PartType.Cylinder)
    eggModel(parent,name,pos+Vector3.new(0,1,0),color)
    label(parent,name:gsub("Egg"," Egg"),pos+Vector3.new(0,8,0),160,color)
end

local function gate(parent,name,pos,color)
    part(parent,name.."Left",Vector3.new(2,12,2),pos+Vector3.new(-13,6,0),Enum.Material.SmoothPlastic,color)
    part(parent,name.."Right",Vector3.new(2,12,2),pos+Vector3.new(13,6,0),Enum.Material.SmoothPlastic,color)
    part(parent,name.."Top",Vector3.new(28,2,2),pos+Vector3.new(0,12,0),Enum.Material.Neon,color)
    label(parent,"ZONE GATE",pos+Vector3.new(0,15,0),130,color)
end

local function zone(parent,name,center,material,floorColor,accent)
    local floor=part(parent,name.."Ground",Vector3.new(90,2,70),center,material,floorColor)
    floor:SetAttribute("Zone",name)
    part(parent,name.."Border",Vector3.new(94,1,3),center+Vector3.new(0,1.5,-34),Enum.Material.Neon,accent)
    part(parent,name.."BorderBack",Vector3.new(94,1,3),center+Vector3.new(0,1.5,34),Enum.Material.Neon,accent)
    local sign=part(parent,name.."Sign",Vector3.new(26,6,1),center+Vector3.new(0,7,-31),Enum.Material.Wood,Color3.fromRGB(70,45,30))
    label(sign,name.." ZONE",sign.Position+Vector3.new(0,3,0),240,Color3.new(1,1,1))
    for x=-35,35,17.5 do crystal(parent,center+Vector3.new(x,0,24),.8,accent) end
end

local function arch(parent,pos,color)
    part(parent,"ArchLeft",Vector3.new(2,14,2),pos+Vector3.new(-9,7,0),Enum.Material.SmoothPlastic,color)
    part(parent,"ArchRight",Vector3.new(2,14,2),pos+Vector3.new(9,7,0),Enum.Material.SmoothPlastic,color)
    part(parent,"ArchTop",Vector3.new(20,2,2),pos+Vector3.new(0,14,0),Enum.Material.Neon,color)
end

function MapBuilder.Build()
    local old=Workspace:FindFirstChild(MAP_NAME)
    if old then old:Destroy() end
    local map=Instance.new("Folder")
    map.Name=MAP_NAME
    map.Parent=Workspace

    -- Bright Roblox-style starter hub.
    part(map,"SpawnIslandEdge",Vector3.new(108,4,98),Vector3.new(0,-2,0),Enum.Material.Slate,Color3.fromRGB(53,128,62))
    part(map,"SpawnGround",Vector3.new(102,2,92),Vector3.new(0,0,0),Enum.Material.Grass,Color3.fromRGB(83,174,86))
    label(map,"MINING + STEAL AN EGG",Vector3.new(0,11,-35),360,Color3.fromRGB(255,239,100),58)
    label(map,"MINE • SELL • UPGRADE • HATCH • REPEAT",Vector3.new(0,7,-35),340,Color3.new(1,1,1),42)
    arch(map,Vector3.new(0,2,20),Color3.fromRGB(70,215,255))
    label(map,"STARTER WORLD",Vector3.new(0,19,20),180,Color3.fromRGB(70,215,255))

    part(map,"MainPath",Vector3.new(24,.7,390),Vector3.new(0,1.3,165),Enum.Material.Cobblestone,Color3.fromRGB(156,156,156))
    for z=20,345,25 do lantern(map,Vector3.new(-15,2,z),Color3.fromRGB(255,203,62)); lantern(map,Vector3.new(15,2,z),Color3.fromRGB(255,203,62)) end

    local spawn=Instance.new("SpawnLocation")
    spawn.Name,spawn.Size,spawn.Position="PlayerSpawn",Vector3.new(14,1,14),Vector3.new(0,2,-24)
    spawn.Anchored,spawn.Material,spawn.Color,spawn.Neutral=true,Enum.Material.Neon,Color3.fromRGB(70,215,255),true
    spawn.Parent=map
    label(map,"START HERE",Vector3.new(0,7,-24),140,Color3.fromRGB(70,215,255))
    station(map,"SellArea",Vector3.new(-25,2,-10),Color3.fromRGB(70,225,125),"SELL ORE")
    station(map,"UpgradeArea",Vector3.new(25,2,-10),Color3.fromRGB(255,190,65),"UPGRADE")
    label(map,"MINE ROCKS → FILL BACKPACK → SELL",Vector3.new(0,8,10),310,Color3.new(1,1,1))

    local forest=Instance.new("Folder"); forest.Name="Forest"; forest.Parent=map
    zone(forest,"FOREST",Vector3.new(0,0,65),Enum.Material.Grass,Color3.fromRGB(72,158,76),Color3.fromRGB(70,215,255))
    for _,p in ipairs({Vector3.new(-38,1,42),Vector3.new(38,1,44),Vector3.new(-38,1,88),Vector3.new(38,1,92),Vector3.new(-28,1,102),Vector3.new(28,1,103)}) do tree(forest,p,1) end
    rock(forest,Vector3.new(-18,1,55),Vector3.new(9,7,9),Color3.fromRGB(92,102,112))
    rock(forest,Vector3.new(18,1,55),Vector3.new(10,8,10),Color3.fromRGB(108,118,128))
    rock(forest,Vector3.new(-16,1,82),Vector3.new(11,8,11),Color3.fromRGB(100,110,120))
    rock(forest,Vector3.new(16,1,87),Vector3.new(9,7,9),Color3.fromRGB(88,98,108))
    eggPedestal(forest,"BasicEgg",Vector3.new(-24,2,105),Color3.fromRGB(245,248,255))
    eggPedestal(forest,"CrystalEgg",Vector3.new(0,2,108),Color3.fromRGB(70,215,255))
    eggPedestal(forest,"GoldenEgg",Vector3.new(24,2,105),Color3.fromRGB(255,203,62))
    label(forest,"FIND EGGS • TAKE THEM HOME • HATCH PETS",Vector3.new(0,10,116),340,Color3.fromRGB(255,239,100))
    gate(map,"ForestGate",Vector3.new(0,2,120),Color3.fromRGB(255,203,62))

    local desert=Instance.new("Folder"); desert.Name="Desert"; desert.Parent=map
    zone(desert,"DESERT",Vector3.new(0,0,155),Enum.Material.Sand,Color3.fromRGB(214,181,94),Color3.fromRGB(255,203,62))
    label(desert,"UNLOCK WITH COINS",Vector3.new(0,9,126),220,Color3.fromRGB(255,230,100))
    for _,p in ipairs({Vector3.new(-32,1,145),Vector3.new(30,1,168),Vector3.new(-22,1,185),Vector3.new(30,1,190)}) do rock(desert,p,Vector3.new(10,8,10),Color3.fromRGB(137,116,82)) end
    eggPedestal(desert,"DesertEgg",Vector3.new(0,2,178),Color3.fromRGB(255,145,65))
    gate(map,"DesertGate",Vector3.new(0,2,210),Color3.fromRGB(255,175,55))

    local ice=Instance.new("Folder"); ice.Name="Ice"; ice.Parent=map
    zone(ice,"ICE",Vector3.new(0,0,245),Enum.Material.Ice,Color3.fromRGB(158,215,230),Color3.fromRGB(170,245,255))
    label(ice,"ICE ZONE • RARER LOOT",Vector3.new(0,9,216),240,Color3.new(1,1,1))
    for _,p in ipairs({Vector3.new(-30,1,230),Vector3.new(30,1,235),Vector3.new(-25,1,270),Vector3.new(25,1,275)}) do crystal(ice,p,1.5,Color3.fromRGB(150,240,255)) end
    eggPedestal(ice,"IceEgg",Vector3.new(0,2,268),Color3.fromRGB(130,220,255))
    gate(map,"IceGate",Vector3.new(0,2,300),Color3.fromRGB(120,235,255))

    local volcano=Instance.new("Folder"); volcano.Name="Volcano"; volcano.Parent=map
    zone(volcano,"VOLCANO",Vector3.new(0,0,335),Enum.Material.Basalt,Color3.fromRGB(69,51,47),Color3.fromRGB(255,92,35))
    label(volcano,"VOLCANO ZONE • BEST REWARDS",Vector3.new(0,11,304),280,Color3.fromRGB(255,145,70))
    for _,p in ipairs({Vector3.new(-30,1,320),Vector3.new(30,1,325),Vector3.new(-22,1,365),Vector3.new(24,1,370)}) do rock(volcano,p,Vector3.new(12,10,12),Color3.fromRGB(60,43,40)) end
    for _,p in ipairs({Vector3.new(-12,1,345),Vector3.new(12,1,350),Vector3.new(0,1,382)}) do crystal(volcano,p,1.4,Color3.fromRGB(255,92,35)) end
    eggPedestal(volcano,"VolcanoEgg",Vector3.new(0,2,365),Color3.fromRGB(255,92,35))
    label(volcano,"ENDGAME",Vector3.new(0,10,382),150,Color3.fromRGB(255,203,62))

    map:SetAttribute("Version",3)
    map:SetAttribute("Description","Bright stylized Mining + Steal An Egg world with colorful zones, egg displays, mining rocks and upgrade hub")
    return map
end

return MapBuilder
