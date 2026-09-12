local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local EggSpawner = {}
local rng = Random.new()
local folder
local respawnQueued = {}

local COLORS={BasicEgg=Color3.fromRGB(245,248,255),CrystalEgg=Color3.fromRGB(70,215,255),GoldenEgg=Color3.fromRGB(255,203,62),DesertEgg=Color3.fromRGB(255,145,65),IceEgg=Color3.fromRGB(130,220,255),VolcanoEgg=Color3.fromRGB(255,92,35)}
local ZONES={
 Forest={types={"BasicEgg","CrystalEgg","GoldenEgg"},points={Vector3.new(-34,1,48),Vector3.new(-24,1,96),Vector3.new(-4,1,100),Vector3.new(20,1,94),Vector3.new(34,1,55),Vector3.new(28,1,76),Vector3.new(-30,1,74),Vector3.new(4,1,62)}},
 Desert={types={"DesertEgg"},points={Vector3.new(-32,1,137),Vector3.new(-8,1,145),Vector3.new(18,1,140),Vector3.new(34,1,157),Vector3.new(-28,1,176),Vector3.new(24,1,180),Vector3.new(4,1,165)}},
 Ice={types={"IceEgg"},points={Vector3.new(-34,1,228),Vector3.new(-12,1,238),Vector3.new(20,1,225),Vector3.new(34,1,248),Vector3.new(-28,1,266),Vector3.new(22,1,278),Vector3.new(4,1,255)}},
 Volcano={types={"VolcanoEgg"},points={Vector3.new(-34,1,318),Vector3.new(-12,1,326),Vector3.new(22,1,316),Vector3.new(34,1,340),Vector3.new(-28,1,360),Vector3.new(22,1,374),Vector3.new(4,1,348)}},
}
local ACTIVE_PER_ZONE=3
local RESPAWN_MIN=5
local RESPAWN_MAX=11

local function getFolder()
 folder=Workspace:FindFirstChild("StealEggs")
 if not folder then folder=Instance.new("Folder"); folder.Name="StealEggs"; folder.Parent=Workspace end
 return folder
end
local function chooseType(types)
 if #types==1 then return types[1] end
 local roll=rng:NextNumber(); if roll<=.60 then return types[1] elseif roll<=.90 then return types[2] else return types[3] end
end
local function makeEgg(eggType,position,zoneName,pointIndex)
 local egg=Instance.new("Part"); egg.Name=eggType; egg.Shape=Enum.PartType.Ball; egg.Size=Vector3.new(3.4,4.3,3.4); egg.Position=position+Vector3.new(0,2.15,0); egg.Anchored=true; egg.CanCollide=false; egg.CanTouch=true; egg.CanQuery=true; egg.Material=Enum.Material.SmoothPlastic; egg.Color=COLORS[eggType] or Color3.new(1,1,1); egg:SetAttribute("EggType",eggType); egg:SetAttribute("Zone",zoneName); egg:SetAttribute("SpawnPoint",pointIndex); egg:SetAttribute("Taken",false); egg.Parent=getFolder()
 local stripe=Instance.new("Part"); stripe.Name="Stripe"; stripe.Shape=Enum.PartType.Cylinder; stripe.Size=Vector3.new(3.45,.55,3.45); stripe.CFrame=egg.CFrame*CFrame.new(0,-.1,0); stripe.Anchored=false; stripe.CanCollide=false; stripe.CanTouch=false; stripe.CanQuery=false; stripe.Massless=true; stripe.Material=Enum.Material.Neon; stripe.Color=egg.Color; stripe.Parent=egg
 local weld=Instance.new("WeldConstraint"); weld.Part0=egg; weld.Part1=stripe; weld.Parent=stripe
 local light=Instance.new("PointLight"); light.Name="EggGlow"; light.Color=egg.Color; light.Range=7; light.Brightness=.8; light.Parent=egg
 return egg
end
local function isPointOccupied(zoneName,index)
 for _,egg in ipairs(getFolder():GetChildren()) do if egg:GetAttribute("Zone")==zoneName and egg:GetAttribute("SpawnPoint")==index then return true end end
 return false
end
local function activeAt(zoneName)
 local count=0; for _,egg in ipairs(getFolder():GetChildren()) do if egg:GetAttribute("Zone")==zoneName and not egg:GetAttribute("Taken") then count+=1 end end; return count
end
function EggSpawner.SpawnOne(zoneName)
 local zone=ZONES[zoneName]; if not zone then return nil end
 local available={}
 for i,point in ipairs(zone.points) do if not isPointOccupied(zoneName,i) then table.insert(available,{index=i,point=point}) end end
 if #available==0 then return nil end
 local pick=available[rng:NextInteger(1,#available)]; local egg=makeEgg(chooseType(zone.types),pick.point,zoneName,pick.index)
 egg.Transparency=1; local stripe=egg:FindFirstChild("Stripe"); if stripe then stripe.Transparency=1 end; local light=egg:FindFirstChild("EggGlow"); if light then light.Brightness=0 end
 TweenService:Create(egg,TweenInfo.new(.45,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Transparency=0}):Play(); if stripe then TweenService:Create(stripe,TweenInfo.new(.45),{Transparency=0}):Play() end; if light then TweenService:Create(light,TweenInfo.new(.45),{Brightness=.8}):Play() end
 return egg
end
function EggSpawner.Respawn(zoneName)
 if respawnQueued[zoneName] then return end
 respawnQueued[zoneName]=true
 task.delay(rng:NextNumber(RESPAWN_MIN,RESPAWN_MAX),function() respawnQueued[zoneName]=nil; if activeAt(zoneName)<ACTIVE_PER_ZONE then EggSpawner.SpawnOne(zoneName) end end)
end
function EggSpawner.Initialize()
 local f=getFolder(); for _,child in ipairs(f:GetChildren()) do child:Destroy() end
 for zoneName in pairs(ZONES) do for _=1,ACTIVE_PER_ZONE do EggSpawner.SpawnOne(zoneName) end end
end
function EggSpawner.Restore(egg)
 if not egg or not egg.Parent then return end
 egg:SetAttribute("Taken",false); egg.Transparency=0; egg.CanTouch=true; egg.CanQuery=true; local stripe=egg:FindFirstChild("Stripe"); if stripe then stripe.Transparency=0 end; local light=egg:FindFirstChild("EggGlow"); if light then light.Brightness=.8 end
end
return EggSpawner
