local Players = game:GetService("Players")
local Data = require(script.Parent.PlayerDataService)
local Config = require(game.ReplicatedStorage.Shared.GameConfig)
local Eggs = require(script.Parent.EggService)

local Service = {}
local hitCooldown = {}

local function root(p)
    local c = p.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function tier(name)
    for i, armor in ipairs(Config.Armor) do
        if armor.Name == name then return i, armor end
    end
    return 1, Config.Armor[1]
end

function Service.EquipArmor(player)
    local d = Data.Get(player)
    if not d then return false, "Player data isn't ready" end
    local currentTier = tier(d.Armor)
    local nextArmor = Config.Armor[currentTier + 1]
    if not nextArmor then return false, "You already have max armor" end
    if d.Coins < nextArmor.Cost then return false, "Need " .. nextArmor.Cost .. " coins for " .. nextArmor.Name .. " Armor" end
    d.Coins -= nextArmor.Cost
    d.Armor = nextArmor.Name
    Data.MarkDirty(player)
    return true, nextArmor.Name
end

function Service.HitPlayer(attacker, target)
    if typeof(target) ~= "Instance" or not target:IsA("Player") or attacker == target then
        return false, "Invalid target"
    end
    local ad = Data.Get(attacker)
    local td = Data.Get(target)
    local ar = root(attacker)
    local tr = root(target)
    if not ad or not td or not ar or not tr then return false, "Player not ready" end
    if not Eggs.IsCarrying(target) then return false, "That player isn't carrying an egg" end
    if (ar.Position - tr.Position).Magnitude > Config.Combat.HitRange then return false, "Too far away" end

    local now = os.clock()
    if hitCooldown[attacker] and now - hitCooldown[attacker] < Config.Combat.HitCooldown then
        return false, "" 
    end
    hitCooldown[attacker] = now

    -- New-player protection and armor gap protection prevent high-level players
    -- from repeatedly farming fresh players. A much stronger attacker cannot
    -- steal from a protected/new player.
    local _, attackerArmor = tier(ad.Armor)
    local defenderTier, defenderArmor = tier(td.Armor)
    if target:GetAttribute("NewPlayerProtection") then
        return false, "That new player is protected"
    end
    local attackerTier = tier(ad.Armor)
    if defenderTier - attackerTier >= Config.Combat.MaxArmorGap then
        return false, "Your armor is too weak to steal from this player"
    end

    local damage = math.max(1, Config.Combat.BaseDamage - defenderArmor.DamageReduction)
    local hum = target.Character and target.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum:TakeDamage(damage)
    end

    local hits = (target:GetAttribute("EggStagger") or 0) + 1
    target:SetAttribute("EggStagger", hits)
    local needed = math.max(1, Config.Combat.BaseHitsToSteal + defenderArmor.StaggerBonus)
    if hits >= needed then
        local ok, name = Eggs.Steal(target, attacker)
        target:SetAttribute("EggStagger", 0)
        if ok then
            return true, "STOLEN " .. name
        end
        return false, name or "Could not steal egg"
    end
    return true, "Hit! " .. tostring(needed - hits) .. " more hit(s) to knock the egg loose"
end

Players.PlayerRemoving:Connect(function(p)
    hitCooldown[p] = nil
end)

return Service
