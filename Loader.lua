--// Nero Scriptz Loading Screen – Locked Version
--//  • Topbar disabled (no Roblox logo)
--//  • 20× slower load (200 s)
--//  • Freezes forever at 100 %

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TextChatService  = game:GetService("TextChatService")
local CoreGui          = game:GetService("CoreGui")
local StarterGui       = game:GetService("StarterGui")
local player           = Players.LocalPlayer
local playerGui        = player:WaitForChild("PlayerGui")

---------------------------------------------------------------------
-- Wipe previous instance
local prev = playerGui:FindFirstChild("FullCoverLoading")
if prev then prev:Destroy() end

---------------------------------------------------------------------
-- Hide the entire Roblox top-bar (logo, menu, etc.)
pcall(function()
	StarterGui:SetCore("TopbarEnabled", false)          -- new!
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
end)

---------------------------------------------------------------------
-- Freeze player movement
local function freeze()
	local char = player.Character or player.CharacterAdded:Wait()
	local hum  = char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed = 0
		hum.JumpPower = 0
	end
end
freeze()
player.CharacterAdded:Connect(freeze)

---------------------------------------------------------------------
-- Disable / hide all other GUIs
for _,g in ipairs(playerGui:GetChildren()) do
	if g:IsA("ScreenGui") and g.Name ~= "FullCoverLoading" then
		g.Enabled = false
	end
end
playerGui.ChildAdded:Connect(function(c)
	if c:IsA("ScreenGui") and c.Name ~= "FullCoverLoading" then
		c.Enabled = false
	end
end)

-- Nukes classic chat (and blocks it from re-spawning)
pcall(function()
	if CoreGui:FindFirstChild("Chat") then
		CoreGui.Chat:Destroy()
	end
end)
CoreGui.ChildAdded:Connect(function(c)
	if c.Name == "Chat" then c:Destroy() end
end)

---------------------------------------------------------------------
-- Build the loading GUI
local gui = Instance.new("ScreenGui", playerGui)
gui.Name = "FullCoverLoading"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn   = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global

local bg = Instance.new("Frame", gui)
bg.Size = UDim2.new(1,0,1,0)
bg.BackgroundColor3 = Color3.fromRGB(30,30,30)
bg.ZIndex = 10000
Instance.new("UIGradient", bg).Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(80,80,80)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(20,20,20))
}

-- Title
local title = Instance.new("TextLabel", bg)
title.Size = UDim2.new(1,0,0.15,0)
title.Position = UDim2.new(0,0,0.03,0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.Bangers          -- comic style
title.Text = "Nero Scriptz"
title.TextScaled = true
title.TextColor3 = Color3.new(1,1,1)
title.ZIndex = 10001
local stroke = Instance.new("UIStroke", title)
stroke.Thickness = 3
stroke.Color = Color3.new(0,0,0)
stroke.Transparency = 0.2

-- Loading bar
local barTrack = Instance.new("Frame", bg)
barTrack.Size = UDim2.new(0.6,0,0.05,0)
barTrack.Position = UDim2.new(0.2,0,0.48,0)
barTrack.BackgroundColor3 = Color3.fromRGB(200,200,200)
barTrack.ZIndex = 10001
Instance.new("UICorner", barTrack).CornerRadius = UDim.new(0,12)

local barFill = Instance.new("Frame", barTrack)
barFill.Size = UDim2.new(0,0,1,0)
barFill.BackgroundColor3 = Color3.fromRGB(255,0,0)
barFill.ZIndex = 10002
Instance.new("UICorner", barFill).CornerRadius = UDim.new(0,12)

local pctLabel = Instance.new("TextLabel", barFill)
pctLabel.Size = UDim2.new(1,0,1,0)
pctLabel.BackgroundTransparency = 1
pctLabel.Font = Enum.Font.GothamBold
pctLabel.TextScaled = true
pctLabel.TextColor3 = Color3.new(1,1,1)
pctLabel.Text = "0%"
pctLabel.ZIndex = 10003

-- Helper: color by percentage
local function percentToColor(p)
	if p < 50 then
		return Color3.fromRGB(255, p * 5, 0)           -- red → yellow
	else
		return Color3.fromRGB(255 - ((p - 50)*5), 255, 0) -- yellow → green
	end
end

-- Info labels
local function newInfo(txt, y, color, size)
	local l = Instance.new("TextLabel", bg)
	l.Size = UDim2.new(1,0,size or 0.05,0)
	l.Position = UDim2.new(0,0,y,0)
	l.BackgroundTransparency = 1
	l.Font = Enum.Font.Gotham
	l.TextScaled = true
	l.TextColor3 = color
	l.Text = txt
	l.ZIndex = 10001
	return l
end

local status  = newInfo("Bypassing anticheat… please wait", 0.56, Color3.fromRGB(230,230,230))
local warning = newInfo("⚠  Do NOT leave – progress will be lost", 0.62, Color3.fromRGB(210,60,60))
local credit  = newInfo("by Yoshi", 0.68, Color3.fromRGB(180,180,180))
local discord = newInfo("Join our Discord: https://discord.gg/bNnyqVVe", 0.92, Color3.fromRGB(114,137,218), 0.04)

-- Swallow all input
UserInputService.InputBegan:Connect(function() return Enum.ContextActionResult.Sink end)

---------------------------------------------------------------------
-- 20× slower loading (200 seconds)
local TOTAL = 10 * 20    -- 200 s
local STEPS = 100        -- 1 % per step

for i = 1, STEPS do
	local p = math.floor(i / STEPS * 100)
	pctLabel.Text          = p .. "%"
	barFill.Size           = UDim2.new(i / STEPS, 0, 1, 0)
	barFill.BackgroundColor3 = percentToColor(p)

	if p==25 then
		status.Text = "Hooking events…"
	elseif p==50 then
		status.Text = "Spoofing memory…"
	elseif p==75 then
		status.Text = "Finalizing bypass…"
	end
	task.wait(TOTAL / STEPS)
end

-- Stuck at 100 % permanently
pctLabel.Text = "100%"
status.Text   = "All set – have fun!"
barFill.BackgroundColor3 = Color3.fromRGB(0,255,0)     -- full green

-- (No fade out / no re-enable of GUIs)
-- The player remains on this screen indefinitely, with movement & top-bar disabled.
