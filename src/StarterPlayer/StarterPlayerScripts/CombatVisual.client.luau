local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local Debris=game:GetService("Debris")
local player=Players.LocalPlayer
local colors={Cloth=Color3.fromRGB(205,170,130),Iron=Color3.fromRGB(150,160,175),Steel=Color3.fromRGB(90,105,125),Diamond=Color3.fromRGB(100,230,255)}
local function part(parent,name,size,color,cf,transparency)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.Color=color;p.CFrame=cf;p.Material=Enum.Material.Metal;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Massless=true;p.Transparency=transparency or 0;p.Parent=parent;return p
end
local function weld(a,b)
 local w=Instance.new("WeldConstraint");w.Part0=a;w.Part1=b;w.Parent=a;return w
end
local function clearArmor(char)
 local old=char:FindFirstChild("CombatArmorVisual");if old then old:Destroy() end
end
local function applyArmor(plr,char)
 if not char then return end
 clearArmor(char)
 local tier=plr:GetAttribute("Armor") or "Cloth"
 local c=colors[tier] or colors.Cloth
 local folder=Instance.new("Folder");folder.Name="CombatArmorVisual";folder.Parent=char
 local torso=char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
 local head=char:FindFirstChild("Head")
 if not torso then return end
 local plate=part(folder,"ChestPlate",Vector3.new(2.5,2.2,.32),c,torso.CFrame*CFrame.new(0,0,-.18),.05);weld(plate,torso)
 local left=char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm")
 local right=char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm")
 if left then local p=part(folder,"LeftGuard",Vector3.new(1.05,1.7,.28),c,left.CFrame*CFrame.new(0,0,-.12),.05);weld(p,left) end
 if right then local p=part(folder,"RightGuard",Vector3.new(1.05,1.7,.28),c,right.CFrame*CFrame.new(0,0,-.12),.05);weld(p,right) end
 if tier~="Cloth" and head then local helm=part(folder,"Helmet",Vector3.new(2.05,.55,2.05),c,head.CFrame*CFrame.new(0,.35,0),.08);weld(helm,head) end
 if tier=="Diamond" then
  local glow=Instance.new("PointLight");glow.Color=c;glow.Range=8;glow.Brightness=1.2;glow.Parent=plate
 end
end
local function setup(plr)
 local function char(c) task.wait(.2);applyArmor(plr,c) end
 plr.CharacterAdded:Connect(char)
 plr:GetAttributeChangedSignal("Armor"):Connect(function() applyArmor(plr,plr.Character) end)
 plr:GetAttributeChangedSignal("CarryingEgg"):Connect(function() end)
 if plr.Character then applyArmor(plr,plr.Character) end
end
for _,p in ipairs(Players:GetPlayers()) do setup(p) end
Players.PlayerAdded:Connect(setup)
local function makeBillboard(plr,char)
 local root=char:FindFirstChild("HumanoidRootPart");local hum=char:FindFirstChildOfClass("Humanoid");if not root or not hum then return end
 local old=char:FindFirstChild("CombatBillboard");if old then old:Destroy() end
 local gui=Instance.new("BillboardGui");gui.Name="CombatBillboard";gui.Size=UDim2.fromOffset(180,55);gui.StudsOffset=Vector3.new(0,4.2,0);gui.AlwaysOnTop=true;gui.Parent=char
 local name=Instance.new("TextLabel");name.Size=UDim2.new(1,0,.42,0);name.BackgroundTransparency=1;name.Text=plr.DisplayName;name.Font=Enum.Font.GothamBold;name.TextScaled=true;name.TextColor3=Color3.new(1,1,1);name.Parent=gui
 local bg=Instance.new("Frame");bg.Position=UDim2.new(.1,0,.48,0);bg.Size=UDim2.new(.8,0,.16,0);bg.BackgroundColor3=Color3.fromRGB(35,35,35);bg.BorderSizePixel=0;bg.Parent=gui
 local hp=Instance.new("Frame");hp.Size=UDim2.fromScale(1,1);hp.BackgroundColor3=Color3.fromRGB(80,220,100);hp.BorderSizePixel=0;hp.Parent=bg
 local egg=Instance.new("TextLabel");egg.Position=UDim2.new(0,0,.68,0);egg.Size=UDim2.new(1,0,.32,0);egg.BackgroundTransparency=1;egg.Text="";egg.Font=Enum.Font.GothamBold;egg.TextScaled=true;egg.TextColor3=Color3.fromRGB(255,220,80);egg.Parent=gui
 local function refresh()
  hp.Size=UDim2.new(math.clamp(hum.Health/math.max(hum.MaxHealth,1),0,1),0,1,0)
  if plr:GetAttribute("NewPlayerProtection") then egg.Text="🛡 STARTER PROTECTED" elseif plr:GetAttribute("CarryingEgg") then egg.Text="🥚 EGG CARRIER • HIT TO STEAL" else egg.Text="" end
 end
 hum.HealthChanged:Connect(refresh);plr:GetAttributeChangedSignal("NewPlayerProtection"):Connect(refresh);plr:GetAttributeChangedSignal("CarryingEgg"):Connect(refresh);refresh()
end
local function fx(position,color)
 local ring=Instance.new("Part");ring.Shape=Enum.PartType.Cylinder;ring.Size=Vector3.new(.15,1.5,1.5);ring.CFrame=CFrame.new(position)*CFrame.Angles(0,0,math.rad(90));ring.Anchored=true;ring.CanCollide=false;ring.CanTouch=false;ring.CanQuery=false;ring.Material=Enum.Material.Neon;ring.Color=color;ring.Transparency=.15;ring.Parent=workspace
 TweenService:Create(ring,TweenInfo.new(.35,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=Vector3.new(.15,7,7),Transparency=1}):Play();Debris:AddItem(ring,.4)
end
local function watch(plr)
 local function c(char)
  task.wait(.3);makeBillboard(plr,char)
  local hum=char:FindFirstChildOfClass("Humanoid")
  if hum then hum.HealthChanged:Connect(function() if hum.Health<hum.MaxHealth then local r=char:FindFirstChild("HumanoidRootPart");if r then fx(r.Position,Color3.fromRGB(255,90,70)) end end end) end
 end
 plr.CharacterAdded:Connect(c);if plr.Character then c(plr.Character) end
end
for _,p in ipairs(Players:GetPlayers()) do watch(p) end
Players.PlayerAdded:Connect(watch)
