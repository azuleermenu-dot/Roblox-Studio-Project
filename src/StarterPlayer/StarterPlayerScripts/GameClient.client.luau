local Players=game:GetService("Players")
local UserInputService=game:GetService("UserInputService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer; local remotes=ReplicatedStorage:WaitForChild("Remotes")
local Mine=remotes:WaitForChild("MineResource"); local Sell=remotes:WaitForChild("Sell"); local Upgrade=remotes:WaitForChild("UpgradePickaxe"); local TakeEgg=remotes:WaitForChild("TakeEgg"); local Hatch=remotes:WaitForChild("HatchCarriedEgg"); local State=remotes:WaitForChild("StateUpdate"); local Notice=remotes:WaitForChild("Notification")
local gui=Instance.new("ScreenGui"); gui.Name="EggMinerUI"; gui.ResetOnSpawn=false; gui.Parent=player:WaitForChild("PlayerGui")
local function label(parent,text,size,pos) local x=Instance.new("TextLabel"); x.BackgroundTransparency=.2; x.TextScaled=true; x.Font=Enum.Font.GothamBold; x.Text=text; x.Size=size; x.Position=pos; x.Parent=parent; return x end
local function button(parent,text,size,pos) local b=Instance.new("TextButton"); b.TextScaled=true; b.Font=Enum.Font.GothamBold; b.Text=text; b.Size=size; b.Position=pos; b.AutoButtonColor=true; b.Parent=parent; return b end
local stats=Instance.new("Frame"); stats.Size=UDim2.fromScale(.32,.21); stats.Position=UDim2.fromScale(.02,.03); stats.BackgroundTransparency=.15; stats.Parent=gui
local coins=label(stats,"Coins: 0",UDim2.fromScale(1,.25),UDim2.fromScale(0,0)); local bag=label(stats,"Backpack: 0/25",UDim2.fromScale(1,.25),UDim2.fromScale(0,.25)); local pet=label(stats,"Pets: x1.00",UDim2.fromScale(1,.25),UDim2.fromScale(0,.5)); local carry=label(stats,"Egg: NONE",UDim2.fromScale(1,.25),UDim2.fromScale(0,.75))
local actions=Instance.new("Frame"); actions.Size=UDim2.fromScale(.55,.14); actions.Position=UDim2.fromScale(.225,.82); actions.BackgroundTransparency=1; actions.Parent=gui
local sell=button(actions,"SELL",UDim2.fromScale(.22,1),UDim2.fromScale(0,0)); local upgrade=button(actions,"UPGRADE",UDim2.fromScale(.22,1),UDim2.fromScale(.26,0)); local hatch=button(actions,"HATCH EGG",UDim2.fromScale(.25,1),UDim2.fromScale(.52,0)); local help=label(gui,"MINE ROCKS • SELL • UPGRADE • FIND AN EGG • BRING IT HOME • HATCH",UDim2.fromScale(.72,.06),UDim2.fromScale(.14,.73)); help.BackgroundTransparency=.35
local notice=label(gui,"",UDim2.fromScale(.6,.07),UDim2.fromScale(.2,.65)); notice.BackgroundTransparency=1; notice.Visible=false
local function notify(t) notice.Text=t; notice.Visible=true; task.delay(2.5,function() if notice.Text==t then notice.Visible=false end end) end
local function targetAt(input)
 local camera=workspace.CurrentCamera; local p=input.Position; local ray=camera:ViewportPointToRay(p.X,p.Y); local result=workspace:Raycast(ray.Origin,ray.Direction*220); return result and result.Instance
end
local function interact(target)
 if not target then return end
 local resources=workspace:FindFirstChild("MiningResources"); local eggs=workspace:FindFirstChild("StealEggs")
 if resources and target:IsDescendantOf(resources) then Mine:FireServer(target)
 elseif eggs and target:IsDescendantOf(eggs) then TakeEgg:FireServer(target) end
end
UserInputService.InputBegan:Connect(function(input,processed) if processed then return end; if input.UserInputType==Enum.UserInputType.MouseButton1 then interact(player:GetMouse().Target) elseif input.UserInputType==Enum.UserInputType.Touch then interact(targetAt(input)) end end)
sell.Activated:Connect(function() Sell:FireServer() end); upgrade.Activated:Connect(function() Upgrade:FireServer() end); hatch.Activated:Connect(function() Hatch:FireServer() end)
State.OnClientEvent:Connect(function(s) coins.Text="Coins: "..tostring(s.Coins or 0); bag.Text="Backpack: "..tostring(s.BackpackAmount or 0).."/"..tostring(s.BackpackCapacity or 0); pet.Text=string.format("Pets: x%.2f",tonumber(s.PetMultiplier) or 1); carry.Text=s.Carrying and "Egg: CARRYING 🥚" or "Egg: NONE"; upgrade.Text="UPGRADE "..tostring(s.Pickaxe or "Wooden") end)
Notice.OnClientEvent:Connect(notify)
