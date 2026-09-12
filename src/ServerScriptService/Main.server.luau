local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Config=require(ReplicatedStorage.Shared.GameConfig)
local Data=require(script.Parent.Services.PlayerDataService)
local Mining=require(script.Parent.Services.MiningService)
local Upgrades=require(script.Parent.Services.UpgradeService)
local Pets=require(script.Parent.Services.PetService)
local Eggs=require(script.Parent.Services.EggService)
local MapBuilder=require(script.Parent.Services.MapBuilder)
local map=MapBuilder.Build()
local remotes=ReplicatedStorage:FindFirstChild("Remotes") or Instance.new("Folder"); remotes.Name="Remotes"; remotes.Parent=ReplicatedStorage
local function remote(n) local r=remotes:FindFirstChild(n) or Instance.new("RemoteEvent"); r.Name=n; r.Parent=remotes; return r end
local Mine=remote("MineResource"); local Sell=remote("Sell"); local Upgrade=remote("UpgradePickaxe"); local TakeEgg=remote("TakeEgg"); local Hatch=remote("HatchCarriedEgg"); local State=remote("StateUpdate"); local Notice=remote("Notification")
local resources=workspace:FindFirstChild("MiningResources") or Instance.new("Folder"); resources.Name="MiningResources"; resources.Parent=workspace
local eggs=workspace:FindFirstChild("StealEggs") or Instance.new("Folder"); eggs.Name="StealEggs"; eggs.Parent=workspace
local function node(name,pos,color,material)
 local p=Instance.new("Part"); p.Name=name; p.Shape=Enum.PartType.Ball; p.Size=Vector3.new(7,6,7); p.Position=pos; p.Anchored=true; p.Color=color; p.Material=material or Enum.Material.Slate; p.Parent=resources; p:SetAttribute("Health",Config.Resources[name].MaxHealth)
end
if #resources:GetChildren()==0 then
 node("Stone",Vector3.new(-18,4,72),Color3.fromRGB(100,100,100)); node("Stone",Vector3.new(0,4,76),Color3.fromRGB(110,110,110)); node("Crystal",Vector3.new(18,5,72),Color3.fromRGB(80,180,255),Enum.Material.Neon)
 node("DesertRock",Vector3.new(-18,4,162),Color3.fromRGB(170,130,75)); node("DesertRock",Vector3.new(18,4,170),Color3.fromRGB(190,145,80))
 node("IceCrystal",Vector3.new(-16,5,252),Color3.fromRGB(160,230,255),Enum.Material.Ice); node("IceCrystal",Vector3.new(18,5,260),Color3.fromRGB(130,210,255),Enum.Material.Ice)
 node("MagmaRock",Vector3.new(-18,5,342),Color3.fromRGB(70,45,40)); node("MagmaRock",Vector3.new(18,5,350),Color3.fromRGB(80,50,40))
end
local function egg(name,pos,color)
 local e=Instance.new("Part"); e.Name=name; e.Shape=Enum.PartType.Ball; e.Size=Vector3.new(5,6,5); e.Position=pos; e.Anchored=true; e.Color=color; e.Material=Enum.Material.SmoothPlastic; e.Parent=eggs; e:SetAttribute("EggType",name); e:SetAttribute("Taken",false)
end
if #eggs:GetChildren()==0 then
 egg("BasicEgg",Vector3.new(-24,6,105),Color3.fromRGB(245,245,245)); egg("CrystalEgg",Vector3.new(0,6,108),Color3.fromRGB(100,220,255)); egg("GoldenEgg",Vector3.new(24,6,105),Color3.fromRGB(255,205,60)); egg("DesertEgg",Vector3.new(0,6,195),Color3.fromRGB(220,160,70)); egg("IceEgg",Vector3.new(0,6,285),Color3.fromRGB(170,235,255)); egg("VolcanoEgg",Vector3.new(0,6,375),Color3.fromRGB(235,90,45))
end
local sell=workspace:FindFirstChild("SellArea") or map:FindFirstChild("SellArea")
local hatchPad=workspace:FindFirstChild("HatchPad") or Instance.new("Part"); hatchPad.Name="HatchPad"; hatchPad.Size=Vector3.new(14,1,14); hatchPad.Position=Vector3.new(25,2,-10); hatchPad.Anchored=true; hatchPad.Material=Enum.Material.Neon; hatchPad.Color=Color3.fromRGB(160,90,255); hatchPad.Parent=workspace
local function sync(p)
 local d=Data.Get(p); if not d then return end
 State:FireClient(p,{Coins=d.Coins,BackpackAmount=d.BackpackAmount,BackpackCapacity=d.BackpackCapacity,Pickaxe=d.Pickaxe,PetMultiplier=Pets.GetMultiplier(p),PetCount=#d.Pets,Carrying=Eggs.IsCarrying(p),EquippedPets=d.EquippedPets})
end
local function leader(p) local f=Instance.new("Folder"); f.Name="leaderstats"; f.Parent=p; local c=Instance.new("IntValue"); c.Name="Coins"; c.Parent=f; task.spawn(function() while p.Parent do local d=Data.Get(p); if d then c.Value=d.Coins end task.wait(1) end end) end
Players.PlayerAdded:Connect(function(p) Data.Load(p); leader(p); sync(p) end)
Players.PlayerRemoving:Connect(function(p) Data.Release(p) end)
Mine.OnServerEvent:Connect(function(p,t) if Mining.Mine(p,t) then sync(p) end end)
Sell.OnServerEvent:Connect(function(p) local d=Data.Get(p); local r=p.Character and p.Character:FindFirstChild("HumanoidRootPart"); if not d or not r or not sell or (r.Position-sell.Position).Magnitude>18 or d.BackpackAmount<=0 then return end; d.Coins+=d.BackpackAmount*Config.SellMultiplier; d.BackpackAmount=0; Data.MarkDirty(p); sync(p); Notice:FireClient(p,"Sold! +coins") end)
Upgrade.OnServerEvent:Connect(function(p) local ok,res=Upgrades.Upgrade(p); if ok then sync(p); Notice:FireClient(p,"Upgraded to "..res.." Pickaxe!") else Notice:FireClient(p,res) end end)
TakeEgg.OnServerEvent:Connect(function(p,e) local ok,res=Eggs.Take(p,e); if ok then sync(p); Notice:FireClient(p,"Egg secured! Bring it to the purple Hatch Pad.") else Notice:FireClient(p,res) end end)
Hatch.OnServerEvent:Connect(function(p) local ok,res=Eggs.HatchAtBase(p,hatchPad); if ok then sync(p); Notice:FireClient(p,"Hatched "..res.Name.." ["..res.Rarity.."]! Pet bonus activated.") else Notice:FireClient(p,res) end end)
task.spawn(function() while true do task.wait(Config.AutosaveSeconds); for _,p in ipairs(Players:GetPlayers()) do if Data.IsDirty(p) then Data.Save(p) end end end end)
game:BindToClose(function() for _,p in ipairs(Players:GetPlayers()) do Data.Save(p) end; task.wait(2) end)
