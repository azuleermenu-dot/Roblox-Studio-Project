local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local Debris=game:GetService("Debris")
local player=Players.LocalPlayer

-- Armor is intentionally visualized as an aura, never as physical armor pieces.
local aura={
 Cloth={color=Color3.fromRGB(190,220,255),size=1.03,brightness=1.0,particles=8},
 Iron={color=Color3.fromRGB(120,180,255),size=1.08,brightness=1.4,particles=12},
 Steel={color=Color3.fromRGB(170,110,255),size=1.14,brightness=1.9,particles=16},
 Diamond={color=Color3.fromRGB(80,245,255),size=1.22,brightness=2.8,particles=24},
}

local function clearAura(char)
 local old=char:FindFirstChild("ArmorAura");if old then old:Destroy() end
end

local function applyAura(plr,char)
 if not char then return end
 clearAura(char)
 local tier=plr:GetAttribute("Armor") or "Cloth"
 local cfg=aura[tier] or aura.Cloth
 local root=char:FindFirstChild("HumanoidRootPart")
 local torso=char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
 if not root or not torso then return end

 local folder=Instance.new("Folder");folder.Name="ArmorAura";folder.Parent=char

 -- Soft spherical force-field shell.
 local shell=Instance.new("Part")
 shell.Name="AuraShell"
 shell.Shape=Enum.PartType.Ball
 shell.Size=Vector3.new(4,5.2,3.2)*cfg.size
 shell.CFrame=torso.CFrame
 shell.Anchored=false;shell.CanCollide=false;shell.CanTouch=false;shell.CanQuery=false;shell.Massless=true
 shell.Material=Enum.Material.ForceField;shell.Color=cfg.color;shell.Transparency=.78
 shell.Parent=folder
 local weld=Instance.new("WeldConstraint");weld.Part0=shell;weld.Part1=torso;weld.Parent=shell

 local light=Instance.new("PointLight");light.Name="AuraLight";light.Color=cfg.color;light.Range=8*cfg.size;light.Brightness=cfg.brightness;light.Parent=root
 light.Parent=folder
 local lw=Instance.new("WeldConstraint");lw.Part0=root;lw.Part1=light.Parent:IsA("BasePart") and light.Parent or root

 -- Orbiting aura ring.
 local ring=Instance.new("Part");ring.Name="AuraRing";ring.Shape=Enum.PartType.Cylinder
 ring.Size=Vector3.new(.12,4.2*cfg.size,4.2*cfg.size);ring.CFrame=root.CFrame*CFrame.Angles(0,0,math.rad(90))
 ring.Anchored=false;ring.CanCollide=false;ring.CanTouch=false;ring.CanQuery=false;ring.Massless=true
 ring.Material=Enum.Material.Neon;ring.Color=cfg.color;ring.Transparency=.35;ring.Parent=folder
 local rw=Instance.new("WeldConstraint");rw.Part0=ring;rw.Part1=root;rw.Parent=ring

 local att=Instance.new("Attachment");att.Name="AuraParticles";att.Parent=root
 local pe=Instance.new("ParticleEmitter");pe.Name="AuraParticles";pe.Texture="rbxasset://textures/particles/sparkles_main.dds"
 pe.Color=ColorSequence.new(cfg.color);pe.LightEmission=1;pe.Rate=cfg.particles;pe.Lifetime=NumberRange.new(.6,1.15)
 pe.Speed=NumberRange.new(.3,1.2);pe.SpreadAngle=Vector2.new(180,180);pe.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,.22),NumberSequenceKeypoint.new(.7,.1),NumberSequenceKeypoint.new(1,0)})
 pe.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.15),NumberSequenceKeypoint.new(.8,.35),NumberSequenceKeypoint.new(1,1)})
 pe.Parent=att

 if tier=="Diamond" then
  -- Diamond aura pulses instead of adding armor geometry.
  task.spawn(function()
   while folder.Parent and char.Parent do
    TweenService:Create(shell,TweenInfo.new(.7,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Transparency=.62}):Play()
    TweenService:Create(ring,TweenInfo.new(.7,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Transparency=.08}):Play()
    task.wait(.7)
    if not folder.Parent then break end
    TweenService:Create(shell,TweenInfo.new(.7,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Transparency=.82}):Play()
    TweenService:Create(ring,TweenInfo.new(.7,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Transparency=.42}):Play()
    task.wait(.7)
   end
  end)
 end
end

local function setup(plr)
 local function char(c) task.wait(.2);applyAura(plr,c) end
 plr.CharacterAdded:Connect(char)
 plr:GetAttributeChangedSignal("Armor"):Connect(function() applyAura(plr,plr.Character) end)
 if plr.Character then applyAura(plr,plr.Character) end
end
for _,p in ipairs(Players:GetPlayers()) do setup(p) end
Players.PlayerAdded:Connect(setup)

local function makeBillboard(plr,char)
 local root=char:FindFirstChild("HumanoidRootPart");local hum=char:FindFirstChildOfClass("Humanoid");if not root or not hum then return end
 local old=char:FindFirstChild("CombatBillboard");if old then old:Destroy() end
 local gui=Instance.new("BillboardGui");gui.Name="CombatBillboard";gui.Size=UDim2.fromOffset(200,62);gui.StudsOffset=Vector3.new(0,4.2,0);gui.AlwaysOnTop=true;gui.Parent=char
 local name=Instance.new("TextLabel");name.Size=UDim2.new(1,0,.38,0);name.BackgroundTransparency=1;name.Text=plr.DisplayName;name.Font=Enum.Font.GothamBold;name.TextScaled=true;name.TextColor3=Color3.new(1,1,1);name.Parent=gui
 local bg=Instance.new("Frame");bg.Position=UDim2.new(.1,0,.43,0);bg.Size=UDim2.new(.8,0,.13,0);bg.BackgroundColor3=Color3.fromRGB(35,35,35);bg.BorderSizePixel=0;bg.Parent=gui
 local hp=Instance.new("Frame");hp.Size=UDim2.fromScale(1,1);hp.BackgroundColor3=Color3.fromRGB(80,220,100);hp.BorderSizePixel=0;hp.Parent=bg
 local auraLabel=Instance.new("TextLabel");auraLabel.Position=UDim2.new(0,0,.58,0);auraLabel.Size=UDim2.new(1,0,.22,0);auraLabel.BackgroundTransparency=1;auraLabel.Font=Enum.Font.GothamBold;auraLabel.TextScaled=true;auraLabel.Parent=gui
 local egg=Instance.new("TextLabel");egg.Position=UDim2.new(0,0,.78,0);egg.Size=UDim2.new(1,0,.22,0);egg.BackgroundTransparency=1;egg.Font=Enum.Font.GothamBold;egg.TextScaled=true;egg.TextColor3=Color3.fromRGB(255,220,80);egg.Parent=gui
 local function refresh()
  hp.Size=UDim2.new(math.clamp(hum.Health/math.max(hum.MaxHealth,1),0,1),0,1,0)
  local tier=plr:GetAttribute("Armor") or "Cloth";local cfg=aura[tier] or aura.Cloth
  auraLabel.Text="✦ "..tier.." AURA";auraLabel.TextColor3=cfg.color
  if plr:GetAttribute("NewPlayerProtection") then egg.Text="🛡 STARTER PROTECTED" elseif plr:GetAttribute("CarryingEgg") then egg.Text="🥚 EGG CARRIER • HIT TO STEAL" else egg.Text="" end
 end
 hum.HealthChanged:Connect(refresh);plr:GetAttributeChangedSignal("NewPlayerProtection"):Connect(refresh);plr:GetAttributeChangedSignal("CarryingEgg"):Connect(refresh);plr:GetAttributeChangedSignal("Armor"):Connect(refresh);refresh()
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
