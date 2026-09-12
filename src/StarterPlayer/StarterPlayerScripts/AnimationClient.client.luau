local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer

local AnimationClient = {}
local miningBusy = false
local petFolder
local petVisuals = {}
local petTargets = {}

local function getCharacter()
    return player.Character
end

local function getRoot()
    local c = getCharacter()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHand()
    local c = getCharacter()
    if not c then return nil end
    return c:FindFirstChild("RightHand") or c:FindFirstChild("Right Arm")
end

local function ensurePickaxe()
    local c = getCharacter()
    local hand = getHand()
    if not c or not hand then return nil end

    local old = c:FindFirstChild("VisualPickaxe")
    if old then return old end

    local model = Instance.new("Model")
    model.Name = "VisualPickaxe"
    model.Parent = c

    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(0.35, 3.6, 0.35)
    handle.Color = Color3.fromRGB(130, 82, 45)
    handle.Material = Enum.Material.Wood
    handle.CanCollide = false
    handle.CanTouch = false
    handle.CanQuery = false
    handle.Massless = true
    handle.Parent = model

    local head = Instance.new("Part")
    head.Name = "Head"
    head.Size = Vector3.new(2.1, 0.35, 0.42)
    head.Color = Color3.fromRGB(185, 195, 205)
    head.Material = Enum.Material.Metal
    head.CanCollide = false
    head.CanTouch = false
    head.CanQuery = false
    head.Massless = true
    head.Parent = model

    local headWeld = Instance.new("Weld")
    headWeld.Part0 = handle
    headWeld.Part1 = head
    headWeld.C0 = CFrame.new(0, 1.55, 0)
    headWeld.Parent = head

    local weld = Instance.new("Weld")
    weld.Name = "HandWeld"
    weld.Part0 = hand
    weld.Part1 = handle
    weld.C0 = CFrame.new(0, -0.8, -0.15) * CFrame.Angles(math.rad(-25), math.rad(10), math.rad(-8))
    weld.Parent = handle
    model:SetAttribute("BaseC0", weld.C0)
    return model
end

function AnimationClient.MineSwing()
    if miningBusy then return end
    miningBusy = true
    local model = ensurePickaxe()
    local c = getCharacter()
    if model and c then
        local weld = model:FindFirstChild("HandWeld", true)
        if weld then
            local base = model:GetAttribute("BaseC0")
            if typeof(base) == "CFrame" then
                local windup = base * CFrame.Angles(math.rad(-55), math.rad(8), math.rad(18))
                local strike = base * CFrame.Angles(math.rad(65), math.rad(-12), math.rad(-24))
                TweenService:Create(weld, TweenInfo.new(0.10, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {C0 = windup}):Play()
                task.wait(0.10)
                TweenService:Create(weld, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {C0 = strike}):Play()
                task.wait(0.08)
                TweenService:Create(weld, TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {C0 = base}):Play()
            end
        end
    end
    task.delay(0.32, function() miningBusy = false end)
end

local function burst(position, color, amount)
    local folder = Instance.new("Folder")
    folder.Name = "FX"
    folder.Parent = workspace
    for i = 1, amount or 8 do
        local p = Instance.new("Part")
        p.Shape = Enum.PartType.Ball
        p.Size = Vector3.new(0.25, 0.25, 0.25)
        p.Material = Enum.Material.Neon
        p.Color = color
        p.CanCollide = false
        p.CanTouch = false
        p.CanQuery = false
        p.Anchored = true
        p.Position = position
        p.Parent = folder
        local angle = (i / (amount or 8)) * math.pi * 2
        local distance = math.random(3, 7)
        local goal = position + Vector3.new(math.cos(angle) * distance, math.random(2, 5), math.sin(angle) * distance)
        TweenService:Create(p, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = goal, Transparency = 1, Size = Vector3.new(0.05,0.05,0.05)}):Play()
    end
    Debris:AddItem(folder, 0.6)
end

function AnimationClient.HitFX(position, color)
    if position then burst(position, color or Color3.fromRGB(255, 220, 80), 7) end
end

function AnimationClient.HatchFX()
    local root = getRoot()
    if not root then return end
    burst(root.Position + Vector3.new(0, 2, 0), Color3.fromRGB(180, 100, 255), 18)
    local ring = Instance.new("Part")
    ring.Shape = Enum.PartType.Cylinder
    ring.Size = Vector3.new(0.2, 3, 3)
    ring.CFrame = CFrame.new(root.Position + Vector3.new(0, 0.1, 0)) * CFrame.Angles(0, 0, math.rad(90))
    ring.Anchored = true
    ring.CanCollide = false
    ring.CanTouch = false
    ring.CanQuery = false
    ring.Material = Enum.Material.Neon
    ring.Color = Color3.fromRGB(190, 120, 255)
    ring.Transparency = 0.2
    ring.Parent = workspace
    TweenService:Create(ring, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = Vector3.new(0.2, 12, 12), Transparency = 1}):Play()
    Debris:AddItem(ring, 0.7)
end

local petColors = {
    ["Tiny Mouse"] = Color3.fromRGB(185,185,195), ["Blue Bunny"] = Color3.fromRGB(80,170,255), ["Crystal Fox"] = Color3.fromRGB(120,240,255),
    ["Golden Dragon"] = Color3.fromRGB(255,195,55), ["Cosmic Phoenix"] = Color3.fromRGB(185,90,255), ["Crystal Bunny"] = Color3.fromRGB(90,220,255),
    ["Prism Dragon"] = Color3.fromRGB(230,100,255), ["Golden Bunny"] = Color3.fromRGB(255,215,70), ["Sun Phoenix"] = Color3.fromRGB(255,145,50),
    ["Sand Fox"] = Color3.fromRGB(225,170,90), ["Scarab"] = Color3.fromRGB(80,190,150), ["Golden Sphinx"] = Color3.fromRGB(255,205,65),
    ["Snow Bunny"] = Color3.fromRGB(215,245,255), ["Frost Fox"] = Color3.fromRGB(120,220,255), ["Ice Phoenix"] = Color3.fromRGB(130,235,255),
    ["Ember Cub"] = Color3.fromRGB(255,105,45), ["Magma Dragon"] = Color3.fromRGB(235,70,35), ["Inferno Titan"] = Color3.fromRGB(255,60,25),
}

local function createPet(pet, index)
    local model = Instance.new("Model")
    model.Name = "Pet_" .. tostring(index)
    local body = Instance.new("Part")
    body.Name = "Body"
    body.Shape = Enum.PartType.Ball
    body.Size = Vector3.new(2.2, 2.2, 2.2)
    body.Color = petColors[pet.Name] or Color3.fromRGB(150,200,255)
    body.Material = Enum.Material.SmoothPlastic
    body.Anchored = true
    body.CanCollide = false
    body.CanTouch = false
    body.CanQuery = false
    body.Parent = model

    local eye1 = Instance.new("Part"); eye1.Shape=Enum.PartType.Ball; eye1.Size=Vector3.new(.28,.28,.28); eye1.Color=Color3.new(0,0,0); eye1.Anchored=true; eye1.CanCollide=false; eye1.Parent=model
    local eye2 = eye1:Clone(); eye2.Parent=model
    local light = Instance.new("PointLight"); light.Range=5; light.Brightness=0.6; light.Color=body.Color; light.Parent=body

    local label = Instance.new("BillboardGui")
    label.Size = UDim2.fromOffset(130, 28)
    label.StudsOffset = Vector3.new(0, 1.8, 0)
    label.AlwaysOnTop = true
    label.Parent = body
    local text = Instance.new("TextLabel")
    text.Size = UDim2.fromScale(1,1)
    text.BackgroundTransparency = 1
    text.Text = pet.Name
    text.TextScaled = true
    text.Font = Enum.Font.GothamBold
    text.TextColor3 = Color3.new(1,1,1)
    text.TextStrokeTransparency = .25
    text.Parent = label

    model.PrimaryPart = body
    model.Parent = petFolder
    return model
end

function AnimationClient.UpdatePets(pets)
    if petFolder then petFolder:Destroy() end
    petFolder = Instance.new("Folder")
    petFolder.Name = "LocalPetFollowers"
    petFolder.Parent = workspace
    petVisuals = {}
    if type(pets) ~= "table" then return end
    for i, pet in ipairs(pets) do
        if i > 3 or type(pet) ~= "table" then break end
        petVisuals[i] = createPet(pet, i)
        petTargets[i] = pet
    end
end

RunService.RenderStepped:Connect(function(dt)
    local root = getRoot()
    if not root then return end
    local t = os.clock()
    for i, model in ipairs(petVisuals) do
        if model and model.PrimaryPart then
            local side = (i - 2) * 3.2
            local back = 4 + math.floor((i - 1) / 2) * 1.2
            local bob = math.sin(t * 4 + i) * 0.45
            local target = root.Position - root.CFrame.LookVector * back + root.CFrame.RightVector * side + Vector3.new(0, 1.7 + bob, 0)
            local current = model.PrimaryPart.Position
            local alpha = math.clamp(dt * 8, 0, 1)
            local pos = current:Lerp(target, alpha)
            local look = root.Position + Vector3.new(0,1.2,0)
            model:PivotTo(CFrame.lookAt(pos, look))
        end
    end

    local carried = getCharacter() and getCharacter():FindFirstChild("CarriedEgg")
    if carried then
        carried.CFrame = root.CFrame * CFrame.new(0, 3.1 + math.sin(t * 4) * 0.18, -1.5) * CFrame.Angles(0, t * 1.5, math.sin(t * 3) * 0.08)
    end
end)

player.CharacterAdded:Connect(function()
    task.wait(0.5)
    ensurePickaxe()
end)

return AnimationClient
