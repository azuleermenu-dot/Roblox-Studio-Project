-- Extraction Recovery Layer
-- Purpose: restore server-side behavior around the EXISTING instances in an extracted place.
-- This script intentionally does NOT rebuild the map, eggs, pets, plots, or UI.
-- It adopts what is already present and only creates missing plumbing.
--
-- Place in: ServerScriptService
--
-- Supported existing concepts detected by name/attributes:
-- CaptureTheEgg, HatchEgg, PlaceEgg, PlacePet, StealEgg, EquipEgg,
-- ExpandPen, PowerUpSystem, TeamSystem, RingSystem, FlyingSystem,
-- eggs, pets, pens/plots, and existing RemoteEvents/RemoteFunctions.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local HttpService = game:GetService("HttpService")

local ROOT_NAME = "ExtractionRecovery"
local REMOTES_NAME = "Remotes"
local STATE_NAME = "State"

local recovery = ReplicatedStorage:FindFirstChild(ROOT_NAME)
if not recovery then
    recovery = Instance.new("Folder")
    recovery.Name = ROOT_NAME
    recovery.Parent = ReplicatedStorage
end

local remotes = recovery:FindFirstChild(REMOTES_NAME)
if not remotes then
    remotes = Instance.new("Folder")
    remotes.Name = REMOTES_NAME
    remotes.Parent = recovery
end

local function getOrCreateRemote(className, name)
    local existing = remotes:FindFirstChild(name)
    if existing and existing:IsA(className) then
        return existing
    end
    if existing then existing:Destroy() end
    local r = Instance.new(className)
    r.Name = name
    r.Parent = remotes
    return r
end

local Action = getOrCreateRemote("RemoteEvent", "Action")
local StateUpdate = getOrCreateRemote("RemoteEvent", "StateUpdate")
local RequestState = getOrCreateRemote("RemoteFunction", "RequestState")

local stateFolder = recovery:FindFirstChild(STATE_NAME)
if not stateFolder then
    stateFolder = Instance.new("Folder")
    stateFolder.Name = STATE_NAME
    stateFolder.Parent = recovery
end

local playerState = {}
local cooldowns = {}
local adopted = setmetatable({}, {__mode = "k"})

local function now()
    return os.clock()
end

local function throttled(player, key, seconds)
    local id = player.UserId
    cooldowns[id] = cooldowns[id] or {}
    local t = cooldowns[id][key] or 0
    if now() - t < seconds then return true end
    cooldowns[id][key] = now()
    return false
end

local function ensureState(player)
    local s = playerState[player]
    if s then return s end
    s = {
        Cash = 0,
        EggsHatched = 0,
        EggsPlaced = 0,
        EggsStolen = 0,
        Capacity = 3,
        Multiplier = 1,
        OwnedEggs = {},
        OwnedPets = {},
    }
    playerState[player] = s
    return s
end

local function setAttributeIfMissing(inst, name, value)
    if inst:GetAttribute(name) == nil then
        inst:SetAttribute(name, value)
    end
end

local function modelLike(inst)
    return inst:IsA("Model") or inst:IsA("BasePart") or inst:IsA("Folder")
end

local function lower(s)
    return string.lower(s or "")
end

local function containsAny(s, list)
    s = lower(s)
    for _, term in ipairs(list) do
        if string.find(s, lower(term), 1, true) then return true end
    end
    return false
end

local function looksLikeEgg(inst)
    if inst:GetAttribute("Egg") == true or inst:GetAttribute("IsEgg") == true then return true end
    return containsAny(inst.Name, {"egg"}) and modelLike(inst)
end

local function looksLikePet(inst)
    if inst:GetAttribute("Pet") == true or inst:GetAttribute("IsPet") == true then return true end
    return containsAny(inst.Name, {"pet"}) and modelLike(inst)
end

local function looksLikePlot(inst)
    return containsAny(inst.Name, {"plot", "pen", "farm", "base", "tycoon"})
end

local function findOwnerAttribute(inst)
    local ownerId = inst:GetAttribute("OwnerUserId")
    if typeof(ownerId) == "number" then return ownerId end
    local owner = inst:GetAttribute("Owner")
    if typeof(owner) == "number" then return owner end
    if typeof(owner) == "string" and owner ~= "" then
        local n = tonumber(owner)
        if n then return n end
        local p = Players:FindFirstChild(owner)
        if p then return p.UserId end
    end
    return nil
end

local function assignOwner(inst, player)
    if not player then return end
    setAttributeIfMissing(inst, "OwnerUserId", player.UserId)
    setAttributeIfMissing(inst, "Owner", player.Name)
end

local function nearestPlayerTo(inst)
    local pivot
    if inst:IsA("Model") then
        local ok, cf = pcall(function() return inst:GetPivot() end)
        if ok then pivot = cf.Position end
    elseif inst:IsA("BasePart") then
        pivot = inst.Position
    end
    if not pivot then return nil end

    local best, bestDist
    for _, p in ipairs(Players:GetPlayers()) do
        local c = p.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        if hrp then
            local d = (hrp.Position - pivot).Magnitude
            if not bestDist or d < bestDist then
                best, bestDist = p, d
            end
        end
    end
    return best, bestDist
end

-- Preserve existing instances. We only tag/adopt them.
local function adoptInstance(inst)
    if adopted[inst] then return end
    if not modelLike(inst) then return end

    local isEgg = looksLikeEgg(inst)
    local isPet = looksLikePet(inst)
    local isPlot = looksLikePlot(inst)
    if not (isEgg or isPet or isPlot) then return end

    adopted[inst] = true
    setAttributeIfMissing(inst, "RecoveryAdopted", true)

    local ownerId = findOwnerAttribute(inst)
    if not ownerId and (isEgg or isPet) then
        local parent = inst.Parent
        if parent then
            ownerId = findOwnerAttribute(parent)
        end
        if not ownerId then
            local p = nearestPlayerTo(inst)
            -- Only infer ownership when the object is reasonably close.
            if p then
                local _, distance = nearestPlayerTo(inst)
                if distance and distance <= 60 then ownerId = p.UserId end
            end
        end
    end

    if ownerId then
        local p = Players:GetPlayerByUserId(ownerId)
        if p then
            assignOwner(inst, p)
            local s = ensureState(p)
            if isEgg then
                s.OwnedEggs[inst] = true
            elseif isPet then
                s.OwnedPets[inst] = true
            end
        end
    end
end

local function scan(root)
    for _, inst in ipairs(root:GetDescendants()) do
        adoptInstance(inst)
    end
end

-- Existing extracted hierarchy is the source of truth.
scan(workspace)
scan(ReplicatedStorage)
scan(ServerStorage)

workspace.DescendantAdded:Connect(function(inst)
    task.defer(adoptInstance, inst)
end)

ReplicatedStorage.DescendantAdded:Connect(function(inst)
    task.defer(adoptInstance, inst)
end)

local function characterRoot(player)
    local c = player.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getTarget(inst)
    if typeof(inst) == "Instance" then return inst end
    return nil
end

local function getDistance(player, inst)
    local root = characterRoot(player)
    if not root or not inst then return math.huge end
    local pos
    if inst:IsA("BasePart") then
        pos = inst.Position
    elseif inst:IsA("Model") then
        local ok, cf = pcall(function() return inst:GetPivot() end)
        if ok then pos = cf.Position end
    end
    if not pos then return math.huge end
    return (root.Position - pos).Magnitude
end

local function playerOwns(player, inst)
    local owner = findOwnerAttribute(inst)
    return owner == nil or owner == player.UserId
end

local function findExistingObjectById(id)
    if typeof(id) ~= "string" or #id > 100 then return nil end
    for _, root in ipairs({workspace, ReplicatedStorage}) do
        local inst = root:FindFirstChild(id, true)
        if inst then return inst end
    end
    return nil
end

local function updateClientState(player)
    local s = ensureState(player)
    local payload = {
        Cash = s.Cash,
        EggsHatched = s.EggsHatched,
        EggsPlaced = s.EggsPlaced,
        EggsStolen = s.EggsStolen,
        Capacity = s.Capacity,
        Multiplier = s.Multiplier,
    }
    StateUpdate:FireClient(player, payload)
end

RequestState.OnServerInvoke = function(player)
    return ensureState(player)
end

-- Conservative interaction bridge. It works with existing eggs/pets/plots rather than replacing them.
Action.OnServerEvent:Connect(function(player, actionName, objectRef, extra)
    if typeof(actionName) ~= "string" or #actionName > 40 then return end
    if throttled(player, actionName, 0.08) then return end

    local target = getTarget(objectRef)
    if not target and typeof(objectRef) == "string" then
        target = findExistingObjectById(objectRef)
    end
    if not target then return end
    if not target:IsDescendantOf(workspace) then return end

    -- Never allow clients to invoke arbitrary methods or manipulate arbitrary instances.
    local distance = getDistance(player, target)
    if distance > 24 then return end

    local s = ensureState(player)
    local action = lower(actionName)

    if action == "hatch" or action == "hatchegg" then
        if not looksLikeEgg(target) then return end
        if not playerOwns(player, target) then return end
        if throttled(player, "hatch:" .. target:GetDebugId(), 2) then return end
        setAttributeIfMissing(target, "Hatched", true)
        target:SetAttribute("Hatched", true)
        s.EggsHatched += 1
        updateClientState(player)
        return
    end

    if action == "collect" or action == "collectegg" then
        if not looksLikeEgg(target) then return end
        if not playerOwns(player, target) then return end
        if throttled(player, "collect:" .. target:GetDebugId(), 0.5) then return end
        local value = target:GetAttribute("Value")
        if typeof(value) ~= "number" then value = 10 end
        s.Cash += math.max(0, math.floor(value * s.Multiplier))
        s.EggsPlaced = math.max(0, s.EggsPlaced - 1)
        updateClientState(player)
        return
    end

    if action == "steal" or action == "stealegg" then
        if not looksLikeEgg(target) then return end
        local ownerId = findOwnerAttribute(target)
        if not ownerId or ownerId == player.UserId then return end
        if throttled(player, "steal:" .. target:GetDebugId(), 2) then return end
        target:SetAttribute("OwnerUserId", player.UserId)
        target:SetAttribute("Owner", player.Name)
        s.EggsStolen += 1
        s.OwnedEggs[target] = true
        updateClientState(player)
        return
    end

    if action == "place" or action == "placeegg" then
        if not looksLikeEgg(target) then return end
        if not playerOwns(player, target) then return end
        if s.EggsPlaced >= s.Capacity then return end
        target:SetAttribute("Placed", true)
        assignOwner(target, player)
        s.EggsPlaced += 1
        updateClientState(player)
        return
    end

    if action == "equip" or action == "equipegg" or action == "equipet" then
        if not (looksLikeEgg(target) or looksLikePet(target)) then return end
        if not playerOwns(player, target) then return end
        target:SetAttribute("EquippedByUserId", player.UserId)
        target:SetAttribute("Equipped", true)
        return
    end

    if action == "upgrade" then
        local amount = tonumber(extra) or 1
        amount = math.clamp(math.floor(amount), 1, 10)
        local cost = 50 * amount
        if s.Cash < cost then return end
        s.Cash -= cost
        s.Capacity += amount
        updateClientState(player)
        return
    end
end)

Players.PlayerAdded:Connect(function(player)
    ensureState(player)
    task.defer(function()
        scan(workspace)
        updateClientState(player)
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    playerState[player] = nil
    cooldowns[player.UserId] = nil
end)

-- Diagnostics visible in Server Output without changing existing gameplay objects.
print("[ExtractionRecovery] Recovery layer active. Existing instances preserved and adopted where identifiable.")
print("[ExtractionRecovery] Remotes: " .. remotes:GetFullName())
