local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local MineEgg = remotes:WaitForChild("MineEgg")
local Sell = remotes:WaitForChild("Sell")
local Upgrade = remotes:WaitForChild("UpgradePickaxe")
local Hatch = remotes:WaitForChild("HatchEgg")
local StateUpdate = remotes:WaitForChild("StateUpdate")
local Notification = remotes:WaitForChild("Notification")

local gui = Instance.new("ScreenGui")
gui.Name = "EggMinerUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local function label(parent, text, size, position)
    local x = Instance.new("TextLabel")
    x.BackgroundTransparency = 0.2
    x.TextScaled = true
    x.Font = Enum.Font.GothamBold
    x.Text = text
    x.Size = size
    x.Position = position
    x.Parent = parent
    return x
end

local function button(parent, text, size, position)
    local b = Instance.new("TextButton")
    b.TextScaled = true
    b.Font = Enum.Font.GothamBold
    b.Text = text
    b.Size = size
    b.Position = position
    b.AutoButtonColor = true
    b.Parent = parent
    return b
end

local stats = Instance.new("Frame")
stats.Size = UDim2.fromScale(0.32, 0.18)
stats.Position = UDim2.fromScale(0.02, 0.03)
stats.BackgroundTransparency = 0.15
stats.Parent = gui

local coinsLabel = label(stats, "Coins: 0", UDim2.fromScale(1, .32), UDim2.fromScale(0, 0))
local backpackLabel = label(stats, "Backpack: 0/25", UDim2.fromScale(1, .32), UDim2.fromScale(0, .34))
local petLabel = label(stats, "Pets: x1.00", UDim2.fromScale(1, .32), UDim2.fromScale(0, .68))

local actions = Instance.new("Frame")
actions.Size = UDim2.fromScale(0.42, 0.14)
actions.Position = UDim2.fromScale(0.29, 0.82)
actions.BackgroundTransparency = 1
actions.Parent = gui

local sellButton = button(actions, "SELL", UDim2.fromScale(.31, 1), UDim2.fromScale(0, 0))
local upgradeButton = button(actions, "UPGRADE", UDim2.fromScale(.31, 1), UDim2.fromScale(.345, 0))
local hatchButton = button(actions, "HATCH", UDim2.fromScale(.31, 1), UDim2.fromScale(.69, 0))

local notice = label(gui, "", UDim2.fromScale(.55, .07), UDim2.fromScale(.225, .7))
notice.BackgroundTransparency = 1
notice.Visible = false

local function notify(text)
    notice.Text = text
    notice.Visible = true
    task.delay(2, function()
        if notice.Text == text then notice.Visible = false end
    end)
end

local function mineTarget(target)
    if target and target:IsDescendantOf(workspace:WaitForChild("Eggs")) then
        MineEgg:FireServer(target)
    end
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        mineTarget(player:GetMouse().Target)
    elseif input.UserInputType == Enum.UserInputType.Touch then
        local camera = workspace.CurrentCamera
        local pos = input.Position
        local ray = camera:ViewportPointToRay(pos.X, pos.Y)
        local result = workspace:Raycast(ray.Origin, ray.Direction * 200)
        if result then mineTarget(result.Instance) end
    end
end)

sellButton.Activated:Connect(function() Sell:FireServer() end)
upgradeButton.Activated:Connect(function() Upgrade:FireServer() end)
hatchButton.Activated:Connect(function() Hatch:FireServer("BasicEgg") end)

StateUpdate.OnClientEvent:Connect(function(state)
    coinsLabel.Text = "Coins: " .. tostring(state.Coins or 0)
    backpackLabel.Text = "Backpack: " .. tostring(state.BackpackAmount or 0) .. "/" .. tostring(state.BackpackCapacity or 0)
    petLabel.Text = string.format("Pets: x%.2f", tonumber(state.PetMultiplier) or 1)
    upgradeButton.Text = "UPGRADE " .. tostring(state.Pickaxe or "Wooden")
end)

Notification.OnClientEvent:Connect(notify)
