local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local remotes=ReplicatedStorage:WaitForChild("Remotes")
local AdminAction=remotes:WaitForChild("AdminAction"); local AdminNotice=remotes:WaitForChild("AdminNotice")
local gui=Instance.new("ScreenGui");gui.Name="AdminPanel";gui.ResetOnSpawn=false;gui.DisplayOrder=100;gui.Enabled=false;gui.Parent=player:WaitForChild("PlayerGui")
local function mk(class,parent,props) local x=Instance.new(class);for k,v in pairs(props) do x[k]=v end;x.Parent=parent;return x end
local root=mk("Frame",gui,{Size=UDim2.fromScale(.9,.72),Position=UDim2.fromScale(.05,.14),BackgroundColor3=Color3.fromRGB(18,18,24),BorderSizePixel=0})
mk("UICorner",root,{CornerRadius=UDim.new(0,14)})
mk("TextLabel",root,{Text="⚡ ADMIN CONTROL CENTER",Font=Enum.Font.GothamBlack,TextSize=24,TextColor3=Color3.new(1,1,1),BackgroundTransparency=1,Size=UDim2.fromScale(.8,.1),Position=UDim2.fromScale(.04,.02),TextXAlignment=Enum.TextXAlignment.Left})
local close=mk("TextButton",root,{Text="X",Font=Enum.Font.GothamBold,TextSize=20,TextColor3=Color3.new(1,1,1),BackgroundColor3=Color3.fromRGB(180,55,70),Size=UDim2.fromScale(.08,.08),Position=UDim2.fromScale(.88,.03)})
local function field(text,y) local box=mk("TextBox",root,{PlaceholderText=text,Text="",ClearTextOnFocus=false,Font=Enum.Font.Gotham,TextSize=18,TextColor3=Color3.new(1,1,1),BackgroundColor3=Color3.fromRGB(35,35,45),Size=UDim2.fromScale(.42,.09),Position=UDim2.fromScale(.04,y)});mk("UICorner",box,{CornerRadius=UDim.new(0,8)});return box end
local coins=field("Coins for everyone (e.g. 1000)",.16);local announce=field("Announcement to EVERY server",.28);local petName=field("Pet name (e.g. Golden Bunny)",.40);local petRarity=field("Rarity (Common/Legendary)",.52);local petMult=field("Pet multiplier (e.g. 5)",.64);local target=field("Player username for this server",.76);local reason=field("Kick reason",.88)
local function btn(text,x,y,w) local b=mk("TextButton",root,{Text=text,Font=Enum.Font.GothamBold,TextSize=17,TextColor3=Color3.new(1,1,1),BackgroundColor3=Color3.fromRGB(55,85,150),Size=UDim2.fromScale(w,.09),Position=UDim2.fromScale(x,y)});mk("UICorner",b,{CornerRadius=UDim.new(0,8)});return b end
local giveCoins=btn("🎁 GIVE COINS • ALL SERVERS",.52,.16,.42);local sendAnnounce=btn("📢 BROADCAST • ALL SERVERS",.52,.28,.42);local givePet=btn("🥚 GIVE PET • ALL SERVERS",.52,.40,.42);local kick=btn("⛔ KICK PLAYER • THIS SERVER",.52,.52,.42);local refresh=btn("🔄 REFRESH",.52,.64,.42)
local status=mk("TextLabel",root,{Text="Ready",Font=Enum.Font.Gotham,TextSize=16,TextColor3=Color3.fromRGB(180,220,255),BackgroundTransparency=1,Size=UDim2.fromScale(.42,.1),Position=UDim2.fromScale(.52,.76),TextWrapped=true})
local openButton=mk("TextButton",gui,{Text="⚡ ADMIN",Font=Enum.Font.GothamBlack,TextSize=16,TextColor3=Color3.new(1,1,1),BackgroundColor3=Color3.fromRGB(70,50,130),Size=UDim2.fromScale(.15,.07),Position=UDim2.fromScale(.82,.03)});mk("UICorner",openButton,{CornerRadius=UDim.new(0,10)});openButton.Visible=false
local function act(kind,data) status.Text="Sending...";AdminAction:FireServer(kind,data or {}) end
giveCoins.Activated:Connect(function() act("giveCoins",{amount=tonumber(coins.Text) or 0}) end)
sendAnnounce.Activated:Connect(function() act("announce",{text=announce.Text}) end)
givePet.Activated:Connect(function() act("givePet",{petName=petName.Text,rarity=petRarity.Text,multiplier=tonumber(petMult.Text) or 1}) end)
kick.Activated:Connect(function() act("kick",{target=target.Text,reason=reason.Text}) end)
refresh.Activated:Connect(function() act("refresh",{}) end)
openButton.Activated:Connect(function() gui.Enabled=true;root.Visible=true;openButton.Visible=false end)
close.Activated:Connect(function() root.Visible=false;openButton.Visible=true end)
AdminNotice.OnClientEvent:Connect(function(text) status.Text=tostring(text);if string.sub(tostring(text),1,4)=="OPEN" then gui.Enabled=true;root.Visible=true;openButton.Visible=false end end)
player:GetAttributeChangedSignal("IsAdmin"):Connect(function() local ok=player:GetAttribute("IsAdmin")==true;openButton.Visible=ok and not root.Visible;if not ok then gui.Enabled=false end end)
if player:GetAttribute("IsAdmin")==true then openButton.Visible=true end
