local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local AnimationClient = {}
local miningBusy = false
local petFolder
local petVisuals = {}
local eggBases = {}
local hatchBusy = false

local function getCharacter() return player.Character end
local function getRoot() local c=getCharacter(); return c and c:FindFirstChild("HumanoidRootPart") end
local function getHand()
    local c=getCharacter(); if not c then return nil end
    return c:FindFirstChild("RightHand") or c:FindFirstChild("Right Arm")
end

local function ensurePickaxe()
    local c,hand=getCharacter(),getHand(); if not c or not hand then return nil end
    local old=c:FindFirstChild("VisualPickaxe"); if old then return old end
    local model=Instance.new("Model"); model.Name="VisualPickaxe"; model.Parent=c
    local handle=Instance.new("Part"); handle.Name="Handle"; handle.Size=Vector3.new(.35,3.6,.35); handle.Color=Color3.fromRGB(130,82,45); handle.Material=Enum.Material.Wood; handle.CanCollide=false; handle.CanTouch=false; handle.CanQuery=false; handle.Massless=true; handle.Parent=model
    local head=Instance.new("Part"); head.Name="Head"; head.Size=Vector3.new(2.1,.35,.42); head.Color=Color3.fromRGB(185,195,205); head.Material=Enum.Material.Metal; head.CanCollide=false; head.CanTouch=false; head.CanQuery=false; head.Massless=true; head.Parent=model
    local hw=Instance.new("Weld"); hw.Part0=handle; hw.Part1=head; hw.C0=CFrame.new(0,1.55,0); hw.Parent=head
    local weld=Instance.new("Weld"); weld.Name="HandWeld"; weld.Part0=hand; weld.Part1=handle; weld.C0=CFrame.new(0,-.8,-.15)*CFrame.Angles(math.rad(-25),math.rad(10),math.rad(-8)); weld.Parent=handle
    model:SetAttribute("BaseC0",weld.C0)
    return model
end

function AnimationClient.MineSwing()
    if miningBusy then return end
    miningBusy=true
    local model=ensurePickaxe()
    if model then
        local weld=model:FindFirstChild("HandWeld",true); local base=model:GetAttribute("BaseC0")
        if weld and typeof(base)=="CFrame" then
            TweenService:Create(weld,TweenInfo.new(.10,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{C0=base*CFrame.Angles(math.rad(-55),math.rad(8),math.rad(18))}):Play()
            task.wait(.10)
            TweenService:Create(weld,TweenInfo.new(.08,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{C0=base*CFrame.Angles(math.rad(65),math.rad(-12),math.rad(-24))}):Play()
            task.wait(.08)
            TweenService:Create(weld,TweenInfo.new(.16,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{C0=base}):Play()
        end
    end
    task.delay(.32,function() miningBusy=false end)
end

local function burst(position,color,amount)
    local folder=Instance.new("Folder"); folder.Name="FX"; folder.Parent=workspace
    for i=1,(amount or 8) do
        local p=Instance.new("Part"); p.Shape=Enum.PartType.Ball; p.Size=Vector3.new(.25,.25,.25); p.Material=Enum.Material.Neon; p.Color=color; p.CanCollide=false; p.CanTouch=false; p.CanQuery=false; p.Anchored=true; p.Position=position; p.Parent=folder
        local angle=(i/(amount or 8))*math.pi*2; local distance=math.random(3,7); local goal=position+Vector3.new(math.cos(angle)*distance,math.random(2,5),math.sin(angle)*distance)
        TweenService:Create(p,TweenInfo.new(.45,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=goal,Transparency=1,Size=Vector3.new(.05,.05,.05)}):Play()
    end
    Debris:AddItem(folder,.6)
end
function AnimationClient.HitFX(position,color) if position then burst(position,color or Color3.fromRGB(255,220,80),7) end end

local function makeCrack(parent,cf,size)
    local crack=Instance.new("Part"); crack.Name="Crack"; crack.Size=size or Vector3.new(.12,1.3,.08); crack.CFrame=cf; crack.Anchored=true; crack.CanCollide=false; crack.CanTouch=false; crack.CanQuery=false; crack.Material=Enum.Material.Neon; crack.Color=Color3.fromRGB(255,255,255); crack.Transparency=1; crack.Parent=parent
    TweenService:Create(crack,TweenInfo.new(.18,Enum.EasingStyle.Quad),{Transparency=0}):Play()
    return crack
end

function AnimationClient.HatchCinematic(pet)
    if hatchBusy then return end
    hatchBusy=true
    local root=getRoot(); if not root then hatchBusy=false; return end
    local folder=Instance.new("Folder"); folder.Name="HatchCinematic"; folder.Parent=workspace
    local base=root.Position+Vector3.new(0,3.2,0)
    local egg=Instance.new("Part"); egg.Name="HatchingEgg"; egg.Shape=Enum.PartType.Ball; egg.Size=Vector3.new(4.4,5.4,4.4); egg.Position=base; egg.Anchored=true; egg.CanCollide=false; egg.CanTouch=false; egg.CanQuery=false; egg.Material=Enum.Material.SmoothPlastic; egg.Color=Color3.fromRGB(190,110,255); egg.Parent=folder
    local light=Instance.new("PointLight"); light.Color=egg.Color; light.Range=12; light.Brightness=2; light.Parent=egg
    local ring=Instance.new("Part"); ring.Shape=Enum.PartType.Cylinder; ring.Size=Vector3.new(.15,5,5); ring.CFrame=CFrame.new(base-Vector3.new(0,2.4,0))*CFrame.Angles(0,0,math.rad(90)); ring.Anchored=true; ring.CanCollide=false; ring.CanTouch=false; ring.CanQuery=false; ring.Material=Enum.Material.Neon; ring.Color=egg.Color; ring.Transparency=.25; ring.Parent=folder
    task.wait(.12)
    for i=1,3 do
        TweenService:Create(egg,TweenInfo.new(.10,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut),{CFrame=egg.CFrame*CFrame.Angles(0,0,math.rad(i%2==0 and -12 or 12))}):Play()
        task.wait(.10)
    end
    makeCrack(folder,egg.CFrame*CFrame.new(-.8,.4,-2.05)*CFrame.Angles(0,0,math.rad(18)))
    makeCrack(folder,egg.CFrame*CFrame.new(.7,-.3,-2.05)*CFrame.Angles(0,0,math.rad(-28)))
    makeCrack(folder,egg.CFrame*CFrame.new(0,.1,-2.08)*CFrame.Angles(0,0,math.rad(90)),Vector3.new(.12,1.7,.08))
    task.wait(.35)
    TweenService:Create(egg,TweenInfo.new(.28,Enum.EasingStyle.Back,Enum.EasingDirection.In),{Size=Vector3.new(5.8,7.1,5.8),Transparency=1}):Play()
    TweenService:Create(light,TweenInfo.new(.25),{Brightness=0,Range=18}):Play()
    TweenService:Create(ring,TweenInfo.new(.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=Vector3.new(.15,18,18),Transparency=1}):Play()
    burst(base,egg.Color,26)
    task.wait(.28)
    if pet and type(pet)=="table" then
        local revealFolder=Instance.new("Folder"); revealFolder.Name="RevealPet"; revealFolder.Parent=folder
        local revealPet=pet
        local temp=createPet -- resolved below after function definition
        if temp then
            local model=temp(revealPet,99,revealFolder)
            if model then
                model:PivotTo(CFrame.new(base+Vector3.new(0,-.4,0)))
                for _,d in ipairs(model:GetDescendants()) do
                    if d:IsA("BasePart") then d.Transparency=.05 end
                end
                task.delay(.7,function()
                    if model and model.Parent then
                        for _,d in ipairs(model:GetDescendants()) do if d:IsA("BasePart") then TweenService:Create(d,TweenInfo.new(.25),{Transparency=1}):Play() end end
                    end
                end)
            end
        end
        burst(base,Color3.fromRGB(255,220,110),18)
    end
    Debris:AddItem(folder,1.4)
    hatchBusy=false
end

function AnimationClient.HatchFX()
    local root=getRoot(); if not root then return end
    burst(root.Position+Vector3.new(0,2,0),Color3.fromRGB(180,100,255),18)
    local ring=Instance.new("Part"); ring.Shape=Enum.PartType.Cylinder; ring.Size=Vector3.new(.2,3,3); ring.CFrame=CFrame.new(root.Position+Vector3.new(0,.1,0))*CFrame.Angles(0,0,math.rad(90)); ring.Anchored=true; ring.CanCollide=false; ring.CanTouch=false; ring.CanQuery=false; ring.Material=Enum.Material.Neon; ring.Color=Color3.fromRGB(190,120,255); ring.Transparency=.2; ring.Parent=workspace
    TweenService:Create(ring,TweenInfo.new(.6,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=Vector3.new(.2,12,12),Transparency=1}):Play(); Debris:AddItem(ring,.7)
end

local petColors={
 ["Tiny Mouse"]=Color3.fromRGB(185,185,195),["Blue Bunny"]=Color3.fromRGB(80,170,255),["Crystal Fox"]=Color3.fromRGB(120,240,255),["Golden Dragon"]=Color3.fromRGB(255,195,55),["Cosmic Phoenix"]=Color3.fromRGB(185,90,255),["Crystal Bunny"]=Color3.fromRGB(90,220,255),["Prism Dragon"]=Color3.fromRGB(230,100,255),["Golden Bunny"]=Color3.fromRGB(255,215,70),["Sun Phoenix"]=Color3.fromRGB(255,145,50),["Sand Fox"]=Color3.fromRGB(225,170,90),["Scarab"]=Color3.fromRGB(80,190,150),["Golden Sphinx"]=Color3.fromRGB(255,205,65),["Snow Bunny"]=Color3.fromRGB(215,245,255),["Frost Fox"]=Color3.fromRGB(120,220,255),["Ice Phoenix"]=Color3.fromRGB(130,235,255),["Ember Cub"]=Color3.fromRGB(255,105,45),["Magma Dragon"]=Color3.fromRGB(235,70,35),["Inferno Titan"]=Color3.fromRGB(255,60,25),
}
local function part(model,name,size,color,cf,shape,material)
    local p=Instance.new("Part"); p.Name=name; p.Size=size; p.Color=color; p.CFrame=cf or CFrame.new(); p.Shape=shape or Enum.PartType.Block; p.Material=material or Enum.Material.SmoothPlastic; p.Anchored=true; p.CanCollide=false; p.CanTouch=false; p.CanQuery=false; p.Massless=true; p.Parent=model; return p
end
local function orb(model,name,size,color,pos,material) return part(model,name,size,color,CFrame.new(pos),Enum.PartType.Ball,material) end
local function petPiece(model,name,size,color,pos,angles,material)
    return part(model,name,size,color,CFrame.new(pos)*CFrame.Angles(math.rad(angles and angles[1] or 0),math.rad(angles and angles[2] or 0),math.rad(angles and angles[3] or 0)),Enum.PartType.Block,material)
end
local function addEye(model,x,z)
    return orb(model,"Eye",Vector3.new(.24,.30,.16),Color3.new(0,0,0),Vector3.new(x,.35,z),Enum.Material.Neon)
end

local function createPet(pet,index,parentOverride)
    local model=Instance.new("Model"); model.Name="Pet_"..index
    local color=petColors[pet.Name] or Color3.fromRGB(150,200,255)
    local lower=string.lower(pet.Name or "")
    local bodySize=Vector3.new(2.2,2.2,2.2)
    if string.find(lower,"dragon") or string.find(lower,"phoenix") or string.find(lower,"titan") then bodySize=Vector3.new(2.5,2.3,2.5) end
    local body=orb(model,"Body",bodySize,color,Vector3.new(0,0,0),Enum.Material.SmoothPlastic)
    model.PrimaryPart=body

    if string.find(lower,"mouse") then
        orb(model,"EarL",Vector3.new(.72,.72,.30),color,Vector3.new(-.72,.78,.02))
        orb(model,"EarR",Vector3.new(.72,.72,.30),color,Vector3.new(.72,.78,.02))
        orb(model,"Tail",Vector3.new(.42,.42,1.25),color,Vector3.new(0,-.15,1.25),Enum.Material.SmoothPlastic)
    elseif string.find(lower,"bunny") then
        petPiece(model,"EarL",Vector3.new(.48,1.45,.48),color,Vector3.new(-.48,1.15,0),{0,0,-8})
        petPiece(model,"EarR",Vector3.new(.48,1.45,.48),color,Vector3.new(.48,1.15,0),{0,0,8})
        orb(model,"Tail",Vector3.new(.62,.62,.62),color,Vector3.new(0,-.1,1.05))
    elseif string.find(lower,"fox") or string.find(lower,"cub") then
        petPiece(model,"EarL",Vector3.new(.55,.75,.55),color,Vector3.new(-.68,.82,0),{0,0,-25})
        petPiece(model,"EarR",Vector3.new(.55,.75,.55),color,Vector3.new(.68,.82,0),{0,0,25})
        petPiece(model,"Tail",Vector3.new(.55,.55,1.7),color,Vector3.new(0,.05,1.25),{20,0,0})
        orb(model,"TailTip",Vector3.new(.62,.62,.62),Color3.new(1,1,1),Vector3.new(0,.35,2.02))
    elseif string.find(lower,"dragon") then
        petPiece(model,"HornL",Vector3.new(.30,.85,.30),Color3.fromRGB(255,235,160),Vector3.new(-.48,1.15,-.05),{0,0,-15},Enum.Material.Neon)
        petPiece(model,"HornR",Vector3.new(.30,.85,.30),Color3.fromRGB(255,235,160),Vector3.new(.48,1.15,-.05),{0,0,15},Enum.Material.Neon)
        petPiece(model,"WingL",Vector3.new(1.15,.18,1.55),color,Vector3.new(-1.15,.25,.25),{0,0,-18})
        petPiece(model,"WingR",Vector3.new(1.15,.18,1.55),color,Vector3.new(1.15,.25,.25),{0,0,18})
        petPiece(model,"Tail",Vector3.new(.45,.45,1.8),color,Vector3.new(0,-.15,1.35),{25,0,0})
    elseif string.find(lower,"phoenix") then
        petPiece(model,"WingL",Vector3.new(1.25,.20,1.75),color,Vector3.new(-1.15,.35,.1),{0,0,-28},Enum.Material.Neon)
        petPiece(model,"WingR",Vector3.new(1.25,.20,1.75),color,Vector3.new(1.15,.35,.1),{0,0,28},Enum.Material.Neon)
        petPiece(model,"Crest",Vector3.new(.35,1.05,.35),color,Vector3.new(0,1.25,.15),{0,0,0},Enum.Material.Neon)
        petPiece(model,"Tail",Vector3.new(.50,.50,1.8),color,Vector3.new(0,-.2,1.35),{25,0,0},Enum.Material.Neon)
    elseif string.find(lower,"scarab") then
        petPiece(model,"Shell",Vector3.new(2.7,.55,2.2),color,Vector3.new(0,.35,.15),{0,0,0},Enum.Material.Metal)
        petPiece(model,"LegL",Vector3.new(1.4,.16,.20),color,Vector3.new(-1.0,-.45,0),{0,0,-15})
        petPiece(model,"LegR",Vector3.new(1.4,.16,.20),color,Vector3.new(1.0,-.45,0),{0,0,15})
    elseif string.find(lower,"sphinx") then
        petPiece(model,"EarL",Vector3.new(.50,.70,.50),color,Vector3.new(-.62,.82,0),{0,0,-15})
        petPiece(model,"EarR",Vector3.new(.50,.70,.50),color,Vector3.new(.62,.82,0),{0,0,15})
        petPiece(model,"Crown",Vector3.new(1.3,.35,.75),Color3.fromRGB(255,235,120),Vector3.new(0,1.15,-.05),nil,Enum.Material.Neon)
        petPiece(model,"Tail",Vector3.new(.45,.45,1.5),color,Vector3.new(0,-.15,1.25),{25,0,0})
    else
        orb(model,"Tail",Vector3.new(.55,.55,.55),color,Vector3.new(0,-.15,1.05))
    end

    addEye(model,-.42,-.95); addEye(model,.42,-.95)
    orb(model,"Nose",Vector3.new(.25,.18,.16),Color3.fromRGB(35,25,25),Vector3.new(0,.02,-1.04))
    local light=Instance.new("PointLight"); light.Range=5; light.Brightness=.7; light.Color=color; light.Parent=body
    if pet.Rarity=="Legendary" or pet.Rarity=="Mythic" then
        local glow=Instance.new("Highlight"); glow.FillColor=color; glow.FillTransparency=.72; glow.OutlineColor=Color3.fromRGB(255,245,180); glow.OutlineTransparency=.05; glow.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; glow.Parent=model
    end
    local label=Instance.new("BillboardGui"); label.Size=UDim2.fromOffset(150,28); label.StudsOffset=Vector3.new(0,1.9,0); label.AlwaysOnTop=true; label.Parent=body
    local text=Instance.new("TextLabel"); text.Size=UDim2.fromScale(1,1); text.BackgroundTransparency=1; text.Text=pet.Name; text.TextScaled=true; text.Font=Enum.Font.GothamBold; text.TextColor3=Color3.new(1,1,1); text.TextStrokeTransparency=.2; text.Parent=label
    model.Parent=parentOverride or petFolder
    return model
end

function AnimationClient.UpdatePets(pets)
    if petFolder then petFolder:Destroy() end
    petFolder=Instance.new("Folder"); petFolder.Name="LocalPetFollowers"; petFolder.Parent=workspace; petVisuals={}
    if type(pets)~="table" then return end
    for i,pet in ipairs(pets) do if i>3 then break end; if type(pet)=="table" then petVisuals[i]=createPet(pet,i) end end
end

local function animateWorldEggs(t)
    local eggs=workspace:FindFirstChild("StealEggs")
    if not eggs then return end
    for _,egg in ipairs(eggs:GetChildren()) do
        if egg:IsA("BasePart") then
            local base=eggBases[egg]
            if not base then base=egg.CFrame; eggBases[egg]=base end
            if egg.Transparency < .9 then
                local phase=string.byte(string.sub(egg.Name,1,1)) or 1
                local bob=math.sin(t*2.5+phase)*.28
                egg.CFrame=base*CFrame.new(0,bob,0)*CFrame.Angles(0,t*.7+phase,0)
            end
        end
    end
end

RunService.RenderStepped:Connect(function(dt)
    local root=getRoot(); if not root then return end
    local t=os.clock()
    for i,model in ipairs(petVisuals) do
        if model and model.PrimaryPart then
            local side=(i-2)*3.2; local back=4+math.floor((i-1)/2)*1.2; local bob=math.sin(t*4+i)*.45
            local target=root.Position-root.CFrame.LookVector*back+root.CFrame.RightVector*side+Vector3.new(0,1.7+bob,0)
            local pos=model.PrimaryPart.Position:Lerp(target,math.clamp(dt*8,0,1))
            model:PivotTo(CFrame.lookAt(pos,root.Position+Vector3.new(0,1.2,0)))
        end
    end
    local carried=getCharacter() and getCharacter():FindFirstChild("CarriedEgg")
    if carried then
        local weld=carried:FindFirstChild("EggCarryWeld")
        if weld then weld.C0=CFrame.new(0,3.1+math.sin(t*4)*.18,-1.5)*CFrame.Angles(0,t*1.5,math.sin(t*3)*.08) end
    end
    animateWorldEggs(t)
end)
player.CharacterAdded:Connect(function() task.wait(.5); ensurePickaxe() end)
return AnimationClient
