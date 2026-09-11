local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Config = require(ReplicatedStorage.Shared.GameConfig)
local Data = require(script.Parent.Services.PlayerDataService)
local Mining = require(script.Parent.Services.MiningService)
local Upgrades = require(script.Parent.Services.UpgradeService)
local Pets = require(script.Parent.Services.PetService)

local remotes = ReplicatedStorage:FindFirstChild("Remotes") or Instance.new("Folder")
remotes.Name = "Remotes"
remotes.Parent = ReplicatedStorage

local function remote(name)
    local r = remotes:FindFirstChild(name) or Instance.new("RemoteEvent")
    r.Name = name
    r.Parent = remotes
    return r
end

local MineEgg = remote("MineEgg")
local Sell = remote("Sell")
local UpgradePickaxe = remote("UpgradePickaxe")
local HatchEgg = remote("HatchEgg")
local StateUpdate = remote("StateUpdate")
local Notification = remote("Notification")

local eggsFolder = workspace:FindFirstChild("Eggs") or Instance.new("Folder")
eggsFolder.Name = "Eggs"
eggsFolder.Parent = workspace

local function makeEgg(name, position)
    local egg = eggsFolder:FindFirstChild(name)
    if not egg then
        egg = Instance.new("Part")
        egg.Name = name
        egg.Shape = Enum.PartType.Ball
        egg.Size = Vector3.new(6, 7, 6)
        egg.Position = position
        egg.Anchored = true
        egg.Material = Enum.Material.SmoothPlastic
        egg.Parent = eggsFolder
    end
    local cfg = Config.Eggs[name]
    egg:SetAttribute("Health", tonumber(egg:GetAttribute("Health")) or cfg.MaxHealth)
    return egg
end

makeEgg("BasicEgg", Vector3.new(0, 4, -12))
makeEgg("CrystalEgg", Vector3.new(10, 4, -12))
makeEgg("GoldenEgg", Vector3.new(-10, 4, -12))

local sell = workspace:FindFirstChild("SellArea")
if not sell then
    sell = Instance.new("Part")
    sell.Name = "SellArea"
    sell.Size = Vector3.new(12, 1, 12)
    sell.Position = Vector3.new(0, 0.5, 12)
    sell.Anchored = true
    sell.Material = Enum.Material.Neon
    sell.Parent = workspace
end

local function sync(player)
    local d = Data.Get(player)
    if not d then return end
    StateUpdate:FireClient(player, {
        Coins = d.Coins,
        BackpackAmount = d.BackpackAmount,
        BackpackCapacity = d.BackpackCapacity,
        Pickaxe = d.Pickaxe,
        PetMultiplier = Pets.GetMultiplier(player),
        PetCount = #d.Pets,
    })
end

local function setupLeaderstats(player)
    local folder = Instance.new("Folder")
    folder.Name = "leaderstats"
    folder.Parent = player
    local coins = Instance.new("IntValue")
    coins.Name = "Coins"
    coins.Parent = folder
    task.spawn(function()
        while player.Parent do
            local d = Data.Get(player)
            if d then coins.Value = d.Coins end
            task.wait(1)
        end
    end)
end

Players.PlayerAdded:Connect(function(player)
    Data.Load(player)
    setupLeaderstats(player)
    sync(player)
end)

Players.PlayerRemoving:Connect(function(player)
    Data.Release(player)
end)

MineEgg.OnServerEvent:Connect(function(player, egg)
    if Mining.Mine(player, egg) then sync(player) end
end)

Sell.OnServerEvent:Connect(function(player)
    local d = Data.Get(player)
    if not d then return end
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root or (root.Position - sell.Position).Magnitude > 18 then return end
    if d.BackpackAmount <= 0 then return end
    d.Coins += d.BackpackAmount * Config.SellMultiplier
    d.BackpackAmount = 0
    Data.MarkDirty(player)
    sync(player)
    Notification:FireClient(player, "Sold your backpack!")
end)

UpgradePickaxe.OnServerEvent:Connect(function(player)
    local ok, result = Upgrades.Upgrade(player)
    if ok then
        sync(player)
        Notification:FireClient(player, "Upgraded to " .. result .. " Pickaxe!")
    else
        Notification:FireClient(player, result)
    end
end)

HatchEgg.OnServerEvent:Connect(function(player, eggName)
    if eggName ~= "BasicEgg" then return end
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local egg = eggsFolder:FindFirstChild(eggName)
    if not root or not egg or (root.Position - egg.Position).Magnitude > 25 then return end
    local pet, err = Pets.Hatch(player, eggName)
    if pet then
        sync(player)
        Notification:FireClient(player, "Hatched " .. pet.Name .. " [" .. pet.Rarity .. "]!")
    else
        Notification:FireClient(player, err or "Could not hatch")
    end
end)

task.spawn(function()
    while true do
        task.wait(Config.AutosaveSeconds)
        for _, player in ipairs(Players:GetPlayers()) do
            if Data.IsDirty(player) then Data.Save(player) end
        end
    end
end)

game:BindToClose(function()
    for _, player in ipairs(Players:GetPlayers()) do
        Data.Save(player)
    end
    task.wait(2)
end)
