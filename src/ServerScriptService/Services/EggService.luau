local Players = game:GetService("Players")
local Config = require(game.ReplicatedStorage.Shared.GameConfig)
local Data = require(script.Parent.PlayerDataService)
local Service = {}
local carrying = {}
local function root(p) local c=p.Character; return c and c:FindFirstChild("HumanoidRootPart") end
function Service.Take(player, egg)
 if typeof(egg)~="Instance" or egg.Parent~=workspace:FindFirstChild("StealEggs") or carrying[player] then return false,"Find an egg first" end
 local r=root(player); if not r or (r.Position-egg.Position).Magnitude>18 or egg:GetAttribute("Taken") then return false,"Get closer to an available egg" end
 local name=egg:GetAttribute("EggType") or egg.Name; if not Config.HatchEggs[name] then return false,"This egg cannot be hatched" end
 egg:SetAttribute("Taken",true); egg.Transparency=1; egg.CanTouch=false; egg.CanQuery=false
 carrying[player]={name=name,egg=egg}
 local carried=Instance.new("Part"); carried.Name="CarriedEgg"; carried.Shape=Enum.PartType.Ball; carried.Size=Vector3.new(3.2,3.8,3.2); carried.Material=Enum.Material.SmoothPlastic; carried.Color=egg.Color; carried.CanCollide=false; carried.CanTouch=false; carried.CanQuery=false; carried.Massless=true; carried.CFrame=r.CFrame*CFrame.new(0,3.2,-1.2); carried.Parent=player.Character
 local weld=Instance.new("WeldConstraint"); weld.Part0=r; weld.Part1=carried; weld.Parent=carried
 return true,name
end
function Service.HatchAtBase(player, pad)
 local state=carrying[player]; local r=root(player)
 if not state or not r then return false,"Bring an egg back to your base" end
 if not pad or (r.Position-pad.Position).Magnitude>16 then return false,"Stand on the hatch pad at your base" end
 local data=Data.Get(player); if not data then return false,"Player data isn't ready" end
 local petService=require(script.Parent.PetService); local pet,err=petService.Hatch(player,state.name)
 if not pet then return false,err or "Could not hatch" end
 local egg=state.egg; carrying[player]=nil
 local carried=player.Character and player.Character:FindFirstChild("CarriedEgg"); if carried then carried:Destroy() end
 if egg and egg.Parent then task.delay(8,function() if egg.Parent then egg:SetAttribute("Taken",false); egg.Transparency=0; egg.CanTouch=true; egg.CanQuery=true end end) end
 return true,pet
end
function Service.IsCarrying(player) return carrying[player]~=nil end
local function clear(p) carrying[p]=nil; local c=p.Character and p.Character:FindFirstChild("CarriedEgg"); if c then c:Destroy() end end
Players.PlayerRemoving:Connect(clear)
Players.PlayerAdded:Connect(function(p) p.CharacterRemoving:Connect(function() clear(p) end) end)
return Service
