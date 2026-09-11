local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local Config = require(game.ReplicatedStorage.Shared.GameConfig)
local Store = DataStoreService:GetDataStore(Config.DataStoreName)

local Service = {}
local sessions = {}
local dirty = {}

local function defaultData()
    local p = Config.Pickaxes[Config.StartingPickaxe]
    return {
        Coins = Config.StartingCoins,
        BackpackAmount = 0,
        BackpackCapacity = Config.StartingBackpack,
        Pickaxe = Config.StartingPickaxe,
        Pets = {},
        EquippedPets = {},
        Version = 1,
    }
end

local function sanitize(data)
    if type(data) ~= "table" then data = defaultData() end
    local d = defaultData()
    d.Coins = math.max(0, math.floor(tonumber(data.Coins) or 0))
    d.BackpackAmount = math.clamp(math.floor(tonumber(data.BackpackAmount) or 0), 0, 1000000)
    d.BackpackCapacity = math.clamp(math.floor(tonumber(data.BackpackCapacity) or Config.StartingBackpack), Config.StartingBackpack, 1000000)
    d.Pickaxe = Config.Pickaxes[data.Pickaxe] and data.Pickaxe or Config.StartingPickaxe
    d.Pets = type(data.Pets) == "table" and data.Pets or {}
    d.EquippedPets = type(data.EquippedPets) == "table" and data.EquippedPets or {}
    d.Version = 1
    return d
end

function Service.Load(player)
    local key = "player_" .. player.UserId
    local success, result = pcall(function() return Store:GetAsync(key) end)
    if not success then warn("Data load failed for", player.UserId, result) end
    local data = sanitize(success and result or nil)
    sessions[player] = data
    dirty[player] = false
    return data
end

function Service.Get(player)
    return sessions[player]
end

function Service.MarkDirty(player)
    dirty[player] = true
end

function Service.Save(player)
    local data = sessions[player]
    if not data then return false end
    local key = "player_" .. player.UserId
    local snapshot = sanitize(data)
    local success, err = pcall(function()
        Store:UpdateAsync(key, function()
            return snapshot
        end)
    end)
    if success then dirty[player] = false else warn("Data save failed for", player.UserId, err) end
    return success
end

function Service.Release(player)
    Service.Save(player)
    sessions[player] = nil
    dirty[player] = nil
end

function Service.IsDirty(player)
    return dirty[player] == true
end

return Service
