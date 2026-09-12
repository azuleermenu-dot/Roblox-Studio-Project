local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local remotes=ReplicatedStorage:WaitForChild("Remotes")
local Action=remotes:WaitForChild("AdminAction")
local Notice=remotes:WaitForChild("AdminNotice")
if player.Name:lower()~="titomodaga137" then return end
local gui=Instance.new("ScreenGui");gui.Name="AdminPanel";gui.ResetOnSpawn=false;gui.Parent=player:WaitForChild("PlayerGui")
local open=Instance.new("TextButton");open.Text="⚡ ADMIN";open.Font=Enum.Font.GothamBold;open.TextScaled=true;open.Size=UDim2.fromOffset(115,44);open.Position=UDim2.new(1,-130,0,18);open.Parent=gui
local panel=Instance.new("Frame");panel.Size=UDim2.new(0,360,0,470);panel.Position=UDim2.new(1,-375,0,70);panel.BackgroundTransparency=.08;panel.Visible=false;panel.Parent=gui
local title=Instance.new("TextLabel");title.Text="⚡ ADMIN CONTROL CENTER";title.Font=Enum.Font.GothamBlack;title.TextScaled=true;title.Size=UDim2.new(1,-20,0,45);title.Position=UDim2.fromOffset(10,8);title.Parent=panel
local function label(text,y) local l=Instance.new("TextLabel");l.Text=text;l.Font=Enum.Font.GothamBold;l.TextScaled=true;l.Size=UDim2.new(1,-30,0,28);l.Position=UDim2.fromOffset(15,y);l.BackgroundTransparency=1;l.Parent=panel;return l end
local function box(text,y) local b=Instance.new("TextBox");b.Text=text;b.PlaceholderText=text;b.Font=Enum.Font.Gotham;b.TextScaled=true;b.Size=UDim2.new(1,-30,0,38);b.Position=UDim2.fromOffset(15,y);b.ClearTextOnFocus=false;b.Parent=panel;return b end
local function button(text,y) local b=Instance.new("TextButton");b.Text=text;b.Font=Enum.Font.GothamBold;b.TextScaled=true;b.Size=UDim2.new(1,-30,0,38);b.Position=UDim2.fromOffset(15,y);b.Parent=panel;return b end
label("GLOBAL BROADCAST",58);local msg=box("Announcement text",88);local send=button("📢 SEND TO EVERY SERVER",132)
label("GLOBAL COIN GIVEAWAY",178);local coins=box("1000",208);local giveCoins=button("🎁 GIVE COINS TO EVERYONE",252)
label("GLOBAL PET GIVEAWAY",298);local pet=box("Admin Pet",328);local rarity=box("Legendary",372);local mult=box("10",416);local givePet=button("🐾 GIVE PET TO EVERYONE",460)
local zone="Forest"
local zoneBtn=button("🥚 SPAWN EGG • FOREST • EVERY SERVER",504)
local status=Instance.new("TextLabel");status.Text="";status.Font=Enum.Font.GothamBold;status.TextScaled=true;status.Size=UDim2.new(1,-30,0,34);status.Position=UDim2.fromOffset(15,545);status.Parent=panel
local zones={"Forest","Desert","Ice","Volcano"};local zi=1
zoneBtn.Activated:Connect(function() zi=zi%#zones+1;zone=zones[zi];zoneBtn.Text="🥚 SPAWN EGG • "..zone:upper().." • EVERY SERVER" end)
open.Activated:Connect(function() panel.Visible=not panel.Visible end)
send.Activated:Connect(function() Action:FireServer("announce",{text=msg.Text}) end)
giveCoins.Activated:Connect(function() Action:FireServer("giveCoins",{amount=coins.Text}) end)
givePet.Activated:Connect(function() Action:FireServer("givePet",{petName=pet.Text,rarity=rarity.Text,multiplier=mult.Text}) end)
zoneBtn.Activated:Connect(function() if zoneBtn.Text:find("SPAWN EGG") then Action:FireServer("spawnEgg",{zone=zone,count=1}) end end)
Notice.OnClientEvent:Connect(function(text) status.Text=tostring(text);task.delay(4,function() if status.Text==text then status.Text="" end end) end)
