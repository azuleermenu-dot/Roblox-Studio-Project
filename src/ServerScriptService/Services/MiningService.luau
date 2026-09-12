local Service = {}
local Config = require(game.ReplicatedStorage.Shared.GameConfig)
local Data = require(script.Parent.PlayerDataService)
local Pets = require(script.Parent.PetService)
local lastMine = {}
function Service.Mine(player, target)
 local resources = workspace:FindFirstChild("MiningResources")
 if typeof(target) ~= "Instance" or not resources or not target:IsDescendantOf(resources) then return false end
 local now = os.clock(); if now - (lastMine[player] or 0) < Config.MiningCooldown then return false end; lastMine[player] = now
 local d = Data.Get(player); local cfg = Config.Resources[target.Name]
 if not d or not cfg or player:DistanceFromCharacter(target:GetPivot().Position) > 25 then return false end
 local health = tonumber(target:GetAttribute("Health")) or cfg.MaxHealth
 if health <= 0 or d.BackpackAmount >= d.BackpackCapacity then return false end
 local pickaxe = Config.Pickaxes[d.Pickaxe]
 local damage = math.min(math.max(1, math.floor(pickaxe.Power * Pets.GetMultiplier(player))), health, d.BackpackCapacity - d.BackpackAmount)
 target:SetAttribute("Health", health - damage); d.BackpackAmount += damage; Data.MarkDirty(player)
 if health - damage <= 0 then
  d.Coins += damage * cfg.Reward; d.BackpackAmount -= damage; Data.MarkDirty(player)
  target.Transparency = 1; target.CanCollide = false
  task.delay(2, function() if target and target.Parent then target:SetAttribute("Health", cfg.MaxHealth); target.Transparency = 0; target.CanCollide = true end end)
 end
 return true
end
return Service
