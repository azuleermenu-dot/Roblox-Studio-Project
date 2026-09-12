local Players = game:GetService("Players")
local MessagingService = game:GetService("MessagingService")
local HttpService = game:GetService("HttpService")
local Data = require(script.Parent.PlayerDataService)
local EggSpawner = require(script.Parent.EggSpawner)
local Service = {}
local TOPIC = "EggMiner_Admin_v1"
local ADMIN_USERNAMES = { ["titomodaga137"] = true }
local processed = {}
function Service.IsAdmin(player) return player and ADMIN_USERNAMES[string.lower(player.Name)] == true end
function Service.GiveCoins(player, amount)
    local d = Data.Get(player); amount = math.floor(tonumber(amount) or 0)
    if not d or amount <= 0 or amount > 1000000000 then return false end
    d.Coins += amount; Data.MarkDirty(player); return true
end
function Service.GivePet(player, petName, rarity, multiplier)
    local d = Data.Get(player)
    if not d or type(petName) ~= "string" or #petName < 1 or #petName > 40 then return false end
    local pet = {Name=petName, Rarity=tostring(rarity or "Common"), Multiplier=math.clamp(tonumber(multiplier) or 1,1,1000)}
    table.insert(d.Pets,pet); if #d.EquippedPets < 3 then table.insert(d.EquippedPets,pet) end; Data.MarkDirty(player); return true
end
local function applyGlobal(payload)
    if type(payload) ~= "table" or type(payload.id) ~= "string" or processed[payload.id] then return end
    processed[payload.id] = os.clock()
    if payload.kind == "announce" then return "announce",tostring(payload.text or "") end
    if payload.kind == "giveCoins" then
        local amount=math.floor(tonumber(payload.amount) or 0); if amount<=0 or amount>1000000000 then return end
        for _,player in ipairs(Players:GetPlayers()) do Service.GiveCoins(player,amount) end; return "giveCoins",amount
    end
    if payload.kind == "givePet" then
        for _,player in ipairs(Players:GetPlayers()) do Service.GivePet(player,payload.petName,payload.rarity,payload.multiplier) end; return "givePet",payload.petName
    end
    if payload.kind == "spawnEgg" then
        local zone=tostring(payload.zone or "Forest")
        local count=math.clamp(math.floor(tonumber(payload.count) or 1),1,20)
        local spawned=0
        for _=1,count do if EggSpawner.SpawnOne(zone,true) then spawned+=1 end end
        return "spawnEgg",zone..":"..tostring(spawned)
    end
end
function Service.PublishGlobal(kind,data)
    local payload=data or {}; payload.kind=kind; payload.id=HttpService:GenerateGUID(false)
    local ok,err=pcall(function() MessagingService:PublishAsync(TOPIC,payload) end); if not ok then return false,tostring(err) end; return true
end
function Service.Subscribe(onApplied)
    local ok,err=pcall(function() MessagingService:SubscribeAsync(TOPIC,function(message)
        local result,value=applyGlobal(message.Data); if result and onApplied then onApplied(result,value) end
    end) end)
    if not ok then warn("Admin MessagingService subscription failed",err) end; return ok
end
function Service.Kick(player,targetName,reason)
    if type(targetName)~="string" then return false end
    local target=Players:FindFirstChild(targetName); if not target then return false end
    target:Kick(reason and tostring(reason)~="" and tostring(reason) or "Removed by an administrator"); return true
end
return Service