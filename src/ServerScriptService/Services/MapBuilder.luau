local MapBuilder = {}

local Workspace = game:GetService("Workspace")

local MAP_NAME = "MiningWorld"

local function part(parent, name, size, position, material, color, anchored)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Position = position
    p.Anchored = anchored ~= false
    p.Material = material or Enum.Material.SmoothPlastic
    p.Color = color or Color3.fromRGB(120, 120, 120)
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end

local function label(parent, text, position, size, color)
    local anchor = part(parent, "LabelAnchor", Vector3.new(0.2, 0.2, 0.2), position, Enum.Material.SmoothPlastic, Color3.new(1, 1, 1))
    anchor.Transparency = 1
    local gui = Instance.new("BillboardGui")
    gui.Name = "Label"
    gui.Size = UDim2.fromOffset(size or 180, 50)
    gui.StudsOffset = Vector3.new(0, 2, 0)
    gui.AlwaysOnTop = true
    gui.Parent = anchor

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.fromScale(1, 1)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextColor3 = color or Color3.new(1, 1, 1)
    textLabel.TextStrokeTransparency = 0.35
    textLabel.Parent = gui
end

local function tree(parent, position, scale)
    scale = scale or 1
    local trunk = part(parent, "TreeTrunk", Vector3.new(1.5, 6, 1.5) * scale, position + Vector3.new(0, 3 * scale, 0), Enum.Material.Wood, Color3.fromRGB(105, 70, 42))
    trunk.Shape = Enum.PartType.Cylinder
    local crown = part(parent, "TreeCrown", Vector3.new(6, 6, 6) * scale, position + Vector3.new(0, 7 * scale, 0), Enum.Material.Grass, Color3.fromRGB(62, 142, 70))
    crown.Shape = Enum.PartType.Ball
end

local function crystal(parent, position, scale, color)
    local c = part(parent, "Crystal", Vector3.new(1.2, 4, 1.2) * scale, position + Vector3.new(0, 2 * scale, 0), Enum.Material.Neon, color)
    c.Shape = Enum.PartType.Cylinder
    c.Orientation = Vector3.new(0, 0, 25)
end

local function rock(parent, position, size, color)
    local r = part(parent, "MiningRock", size, position + Vector3.new(0, size.Y / 2, 0), Enum.Material.Slate, color)
    r.Shape = Enum.PartType.Ball
    r:SetAttribute("Mineable", true)
    return r
end

local function eggPedestal(parent, name, position, color)
    local base = part(parent, name .. "Pedestal", Vector3.new(7, 1, 7), position, Enum.Material.Marble, Color3.fromRGB(235, 235, 235))
    base.Shape = Enum.PartType.Cylinder
    local egg = part(parent, name, Vector3.new(4, 5, 4), position + Vector3.new(0, 3, 0), Enum.Material.SmoothPlastic, color)
    egg.Shape = Enum.PartType.Ball
    egg:SetAttribute("WorldEgg", true)
    label(egg, name:gsub("Egg", " Egg"), egg.Position + Vector3.new(0, 2.5, 0), 130, Color3.new(1, 1, 1))
end

local function zone(parent, name, center, floorColor, accentColor)
    local floor = part(parent, name .. "Ground", Vector3.new(90, 2, 70), center, Enum.Material.Grass, floorColor)
    floor:SetAttribute("Zone", name)

    local sign = part(parent, name .. "Sign", Vector3.new(20, 5, 1), center + Vector3.new(0, 6, -32), Enum.Material.Wood, Color3.fromRGB(70, 45, 30))
    label(sign, name .. " ZONE", sign.Position + Vector3.new(0, 3, 0), 220, Color3.new(1, 1, 1))

    for x = -35, 35, 17.5 do
        crystal(parent, center + Vector3.new(x, 0, 18), 1, accentColor)
    end
end

function MapBuilder.Build()
    local old = Workspace:FindFirstChild(MAP_NAME)
    if old then old:Destroy() end

    local map = Instance.new("Folder")
    map.Name = MAP_NAME
    map.Parent = Workspace

    -- Main spawn island.
    part(map, "SpawnGround", Vector3.new(100, 2, 90), Vector3.new(0, 0, 0), Enum.Material.Grass, Color3.fromRGB(84, 170, 82))
    label(map, "MINING + STEAL AN EGG", Vector3.new(0, 8, -35), 300, Color3.fromRGB(255, 245, 110))

    -- Central path.
    part(map, "MainPath", Vector3.new(22, 0.6, 210), Vector3.new(0, 1.3, 105), Enum.Material.Cobblestone, Color3.fromRGB(145, 145, 145))

    -- Spawn pad.
    local spawn = Instance.new("SpawnLocation")
    spawn.Name = "PlayerSpawn"
    spawn.Size = Vector3.new(12, 1, 12)
    spawn.Position = Vector3.new(0, 2, -25)
    spawn.Anchored = true
    spawn.Material = Enum.Material.Neon
    spawn.Color = Color3.fromRGB(70, 210, 255)
    spawn.Neutral = true
    spawn.Parent = map

    -- Starter stations.
    part(map, "SellArea", Vector3.new(16, 1, 12), Vector3.new(-25, 2, -15), Enum.Material.Neon, Color3.fromRGB(75, 220, 120))
    label(map, "SELL", Vector3.new(-25, 4, -15), 100, Color3.new(1, 1, 1))

    part(map, "UpgradeArea", Vector3.new(16, 1, 12), Vector3.new(25, 2, -15), Enum.Material.Neon, Color3.fromRGB(255, 190, 70))
    label(map, "UPGRADES", Vector3.new(25, 4, -15), 120, Color3.new(1, 1, 1))

    -- Forest mining zone.
    local forest = Instance.new("Folder")
    forest.Name = "Forest"
    forest.Parent = map
    zone(forest, "Forest", Vector3.new(0, 0, 65), Color3.fromRGB(72, 155, 74), Color3.fromRGB(65, 210, 255))
    for _, p in ipairs({Vector3.new(-38, 1, 40), Vector3.new(38, 1, 42), Vector3.new(-36, 1, 85), Vector3.new(38, 1, 90), Vector3.new(-25, 1, 100), Vector3.new(25, 1, 105)}) do
        tree(forest, p, 1)
    end
    rock(forest, Vector3.new(-18, 1, 55), Vector3.new(8, 7, 8), Color3.fromRGB(95, 105, 115))
    rock(forest, Vector3.new(18, 1, 55), Vector3.new(9, 8, 9), Color3.fromRGB(110, 120, 130))
    rock(forest, Vector3.new(-15, 1, 82), Vector3.new(10, 8, 10), Color3.fromRGB(100, 110, 120))
    rock(forest, Vector3.new(16, 1, 88), Vector3.new(8, 7, 8), Color3.fromRGB(90, 100, 110))
    eggPedestal(forest, "BasicEgg", Vector3.new(-24, 2, 105), Color3.fromRGB(235, 245, 255))
    eggPedestal(forest, "CrystalEgg", Vector3.new(0, 2, 108), Color3.fromRGB(100, 220, 255))
    eggPedestal(forest, "GoldenEgg", Vector3.new(24, 2, 105), Color3.fromRGB(255, 210, 70))

    -- Locked progression zones: visual map only for now.
    local desert = Instance.new("Folder")
    desert.Name = "Desert"
    desert.Parent = map
    zone(desert, "Desert", Vector3.new(0, 0, 155), Color3.fromRGB(211, 178, 91), Color3.fromRGB(255, 205, 70))
    label(desert, "UNLOCK WITH COINS", Vector3.new(0, 9, 123), 220, Color3.fromRGB(255, 230, 100))
    for _, p in ipairs({Vector3.new(-32, 1, 145), Vector3.new(30, 1, 170), Vector3.new(-20, 1, 185)}) do
        rock(desert, p, Vector3.new(10, 8, 10), Color3.fromRGB(135, 115, 85))
    end
    eggPedestal(desert, "DesertEgg", Vector3.new(0, 2, 178), Color3.fromRGB(255, 145, 65))

    local ice = Instance.new("Folder")
    ice.Name = "Ice"
    ice.Parent = map
    zone(ice, "Ice", Vector3.new(0, 0, 245), Color3.fromRGB(155, 210, 225), Color3.fromRGB(170, 245, 255))
    label(ice, "ICE ZONE", Vector3.new(0, 9, 213), 180, Color3.new(1, 1, 1))
    for _, p in ipairs({Vector3.new(-30, 1, 230), Vector3.new(30, 1, 235), Vector3.new(-25, 1, 270), Vector3.new(25, 1, 275)}) do
        crystal(ice, p, 1.5, Color3.fromRGB(150, 240, 255))
    end
    eggPedestal(ice, "IceEgg", Vector3.new(0, 2, 268), Color3.fromRGB(130, 220, 255))

    local volcano = Instance.new("Folder")
    volcano.Name = "Volcano"
    volcano.Parent = map
    zone(volcano, "Volcano", Vector3.new(0, 0, 335), Color3.fromRGB(75, 55, 50), Color3.fromRGB(255, 90, 35))
    label(volcano, "VOLCANO ZONE", Vector3.new(0, 10, 303), 220, Color3.fromRGB(255, 145, 70))
    for _, p in ipairs({Vector3.new(-30, 1, 320), Vector3.new(30, 1, 325), Vector3.new(-22, 1, 365), Vector3.new(24, 1, 370)}) do
        rock(volcano, p, Vector3.new(12, 10, 12), Color3.fromRGB(65, 45, 42))
    end
    eggPedestal(volcano, "VolcanoEgg", Vector3.new(0, 2, 365), Color3.fromRGB(255, 75, 35))

    -- Invisible guide attributes for future zone/teleport systems.
    map:SetAttribute("Version", 1)
    map:SetAttribute("Description", "Mining simulator progression map with world egg collection")

    return map
end

return MapBuilder
