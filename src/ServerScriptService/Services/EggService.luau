local Players = game:GetService("Players")
local Config = require(game.ReplicatedStorage.Shared.GameConfig)
local Data = require(script.Parent.PlayerDataService)
local EggSpawner = require(script.Parent.EggSpawner)
local Service = {}
local carrying = {}

local function root(p)
    local c=p.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function attachEgg(player, name, color)
    local r=root(player)
    if not r then return false end
    local carried=Instance.new("Part")
    carried.Name="CarriedEgg"; carried.Shape=Enum.PartType.Ball; carried.Size=Vector3.new(3.2,3.8,3.2); carried.Material=Enum.Material.SmoothPlastic; carried.Color=color; carried.CanCollide=false; carried.CanTouch=false; carried.CanQuery=false; carried.Massless=true; carried.CFrame=r.CFrame*CFrame.new(0,3.1,-1.5); carried.Parent=player.Character
    local weld=Instance.new("Weld"); weld.Name="EggCarryWeld"; weld.Part0=r; weld.Part1=carried; weld.C0=CFrame.new(0,3.1,-1.5); weld.Parent=carried
    return true
end

function Service.Take(player, egg)
    if typeof(egg)~="Instance" or not egg:IsDescendantOf(workspace:FindFirstChild("StealEggs")) or carrying[player] then return false,"Find an egg first" end
    local r=root(player)
    if not r or (r.Position-egg.Position).Magnitude>18 or egg:GetAttribute("Taken") then return false,"Get closer to an available egg" end
    local name=egg:GetAttribute("EggType") or egg.Name
    if not Config.HatchEggs[name] then return false,"This egg cannot be hatched" end
    egg:SetAttribute("Taken",true); egg.Transparency=1; egg.CanTouch=false; egg.CanQuery=false
    local stripe=egg:FindFirstChild("Stripe"); if stripe then stripe.Transparency=1 end
    local light=egg:FindFirstChild("EggGlow"); if light then light.Brightness=0 end
    carrying[player]={name=name,egg=egg,color=egg.Color}
    if not attachEgg(player,name,egg.Color) then
        carrying[player]=nil
        EggSpawner.Restore(egg)
        return false,"Could not carry egg"
    end
    return true,name
end

function Service.Steal(victim, thief)
    local state=carrying[victim]
    if not state or carrying[thief] then return false,"Steal failed" end
    local tr=root(thief)
    local vr=root(victim)
    if not tr or not vr or (tr.Position-vr.Position).Magnitude>Config.Combat.HitRange + 2 then return false,"Too far away" end

    local oldCarried=victim.Character and victim.Character:FindFirstChild("CarriedEgg")
    if oldCarried then oldCarried:Destroy() end
    carrying[victim]=nil
    carrying[thief]={name=state.name,egg=state.egg,color=state.color}
    if not attachEgg(thief,state.name,state.color) then
        carrying[thief]=nil
        carrying[victim]=state
        attachEgg(victim,state.name,state.color)
        return false,"Steal failed" 
    end
    return true,state.name
end

function Service.HatchAtBase(player,pad)
    local state=carrying[player]; local r=root(player)
    if not state or not r then return false,"Bring an egg back to your base" end
    if not pad or (r.Position-pad.Position).Magnitude>16 then return false,"Stand on the hatch pad at your base" end
    local data=Data.Get(player); if not data then return false,"Player data isn't ready" end
    local petService=require(script.Parent.PetService)
    local pet,err=petService.Hatch(player,state.name)
    if not pet then return false,err or "Could not hatch" end
    local egg=state.egg; carrying[player]=nil
    local carried=player.Character and player.Character:FindFirstChild("CarriedEgg"); if carried then carried:Destroy() end
    if egg and egg.Parent then
        local zone=egg:GetAttribute("Zone")
        egg:Destroy()
        if zone then EggSpawner.Respawn(zone) end
    end
    return true,pet
end

function Service.IsCarrying(player) return carrying[player]~=nil end

local function clear(p)
    local state=carrying[p]
    carrying[p]=nil
    local c=p.Character and p.Character:FindFirstChild("CarriedEgg"); if c then c:Destroy() end
    if state and state.egg and state.egg.Parent then
        local zone=state.egg:GetAttribute("Zone")
        EggSpawner.Restore(state.egg)
        if zone then EggSpawner.Respawn(zone) end
    end
end

Players.PlayerRemoving:Connect(clear)
Players.PlayerAdded:Connect(function(p) p.CharacterRemoving:Connect(function() clear(p) end) end)
return Service
