local Service = {}
local Config = require(game.ReplicatedStorage.Shared.GameConfig)
local Data = require(script.Parent.PlayerDataService)
local Pets = require(script.Parent.PetService)

local lastMine = {}

function Service.Mine(player, egg)
    if typeof(egg) ~= "Instance" or not egg:IsDescendantOf(workspace:FindFirstChild("Eggs")) then return false end
    local now = os.clock()
    if now - (lastMine[player] or 0) < Config.MiningCooldown then return false end
    lastMine[player] = now

    local d = Data.Get(player)
    local cfg = Config.Eggs[egg.Name]
    if not d or not cfg then return false end
    local distance = player:DistanceFromCharacter(egg:GetPivot().Position)
    if distance > 25 then return false end
    local health = tonumber(egg:GetAttribute("Health")) or cfg.MaxHealth
    if health <= 0 or d.BackpackAmount >= d.BackpackCapacity then return false end

    local pickaxe = Config.Pickaxes[d.Pickaxe]
    local damage = math.max(1, math.floor(pickaxe.Power * Pets.GetMultiplier(player)))
    damage = math.min(damage, health, d.BackpackCapacity - d.BackpackAmount)
    egg:SetAttribute("Health", health - damage)
    d.BackpackAmount += damage
    Data.MarkDirty(player)

    if health - damage <= 0 then
        task.delay(0.35, function()
            if egg and egg.Parent then egg:SetAttribute("Health", cfg.MaxHealth) end
        end)
    end
    return true
end

return Service
