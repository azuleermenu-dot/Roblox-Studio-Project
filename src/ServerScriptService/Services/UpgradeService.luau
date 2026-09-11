local Service = {}
local Config = require(game.ReplicatedStorage.Shared.GameConfig)
local Data = require(script.Parent.PlayerDataService)

local order = {"Wooden", "Stone", "Iron", "Gold", "Diamond"}

function Service.Upgrade(player)
    local d = Data.Get(player)
    if not d then return false, "No data" end
    local index
    for i, name in ipairs(order) do if name == d.Pickaxe then index = i break end end
    if not index or not order[index + 1] then return false, "Max pickaxe" end
    local nextName = order[index + 1]
    local nextConfig = Config.Pickaxes[nextName]
    if d.Coins < nextConfig.Cost then return false, "Not enough coins" end
    d.Coins -= nextConfig.Cost
    d.Pickaxe = nextName
    d.BackpackCapacity = nextConfig.Capacity
    Data.MarkDirty(player)
    return true, nextName
end

return Service
