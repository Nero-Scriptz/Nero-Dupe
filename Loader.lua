--// 🐾 Nero Pet Duplicator + Locked Loading Screen 🐾
--// Place in a LocalScript (e.g., StarterPlayerScripts)

---------------------------------------------------------------------
-- SERVICES & BASIC HELPERS
---------------------------------------------------------------------
local Players               = game:GetService("Players")
local StarterGui            = game:GetService("StarterGui")
local CoreGui               = game:GetService("CoreGui")
local UserInputService      = game:GetService("UserInputService")
local ContextActionService  = game:GetService("ContextActionService")

local player      = Players.LocalPlayer
local playerGui   = player:WaitForChild("PlayerGui")

local function wipeOld()
	for _,g in ipairs(playerGui:GetChildren()) do
		if g:IsA("ScreenGui") and (g.Name == "NeroDupeUI" or g.Name == "FullCoverLoading") then
			g:Destroy()
		end
	end
end

local function freezeCharacter()
	local char = player.Character or player.CharacterAdded:Wait()
	local hum  = char:FindFirstChildOfClass("Humanoid")
	if hum then hum.WalkSpeed, hum.JumpPower = 0, 0 end
end

local function percentToColor(p)
	if p < 50 then
		return Color3.fromRGB(255, p * 5, 0)
	else
		return Color3.fromRGB(255 - ((p - 50) * 5), 255, 0)
	end
end

---------------------------------------------------------------------
-- LOADING-SCREEN CONSTRUCTOR
---------------------------------------------------------------------
local rotatingTips = {
	"tip: JOIN OUR DISCORD TO GET THE PREMIUM RAYFIELD VERSION",
	"tip: THE MORE PETS YOU DUPLICATE THE LONGER THE DUPLICATION",
	"tip: DON'T LEAVE WHILE DUPLICATING, PROGRESS MIGHT GET DELETED",
	"tip: YOSHI IS KING"
}

local function showLockedLoading()
	-----------------------------------------------------------------
	-- GLOBAL LOCKDOWN
	-----------------------------------------------------------------
	pcall(function()
		StarterGui:SetCore("TopbarEnabled", false)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
		StarterGui:SetCore("ResetButtonCallback", false)
	end)
	ContextActionService:BindAction(
		"BlockEsc",
		function() return Enum.ContextActionResult.Sink end,
		false,
		Enum.KeyCode.Escape
	)
	freezeCharacter()
	player.CharacterAdded:Connect(freezeCharacter)

	-----------------------------------------------------------------
	-- GUI CONSTRUCTION
	-----------------------------------------------------------------
	local loading = Instance.new("ScreenGui", playerGui)
	loading.Name = "FullCoverLoading"
	loading.IgnoreGuiInset = true
	loading.ZIndexBehavior = Enum.ZIndexBehavior.Global

	local bg = Instance.new("Frame", loading)
	bg.Size = UDim2.new(1, 0, 1, 0)
	bg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	Instance.new("UIGradient", bg).Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 80, 80)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
	}

	local title = Instance.new("TextLabel", bg)
	title.Size = UDim2.new(1, 0, 0.12, 0)
	title.Position = UDim2.new(0, 0, 0.02, 0)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.Bangers
	title.Text = "Nero Scriptz"
	title.TextScaled = true
	title.TextColor3 = Color3.new(1, 1, 1)
	local stroke = Instance.new("UIStroke", title)
	stroke.Thickness = 3
	stroke.Color = Color3.new(0, 0, 0)
	stroke.Transparency = 0.2

	-- Tips below the banner
	local tips = {
		"TIP: join our discord to get the Rayfield Version",
		"TIP: the more pets you duplicate the longer the duplication",
		"TIP: DON'T LEAVE WHILE DUPLICATING, PROGRESS MIGHT GET DELETED",
		"tired of waiting? GET THE RAYFIELD VERSION!"
	}
	local tipLabel = Instance.new("TextLabel", bg)
	tipLabel.Size = UDim2.new(1, 0, 0.05, 0)
	tipLabel.Position = UDim2.new(0, 0, 0.14, 0)
	tipLabel.BackgroundTransparency = 1
	tipLabel.Font = Enum.Font.Gotham
	tipLabel.TextColor3 = Color3.new(1, 1, 1)
	tipLabel.TextScaled = true
	tipLabel.Text = tips[1]

	coroutine.wrap(function()
		local i = 1
		while true do
			tipLabel.Text = tips[i]
			i = i % #tips + 1
			task.wait(4)
		end
	end)()

	-- Progress bar
	local track = Instance.new("Frame", bg)
	track.Size, track.Position = UDim2.new(0.6,0,0.05,0), UDim2.new(0.2,0,0.48,0)
	track.BackgroundColor3, track.ZIndex = Color3.fromRGB(200,200,200), 10001
	Instance.new("UICorner", track).CornerRadius = UDim.new(0,12)

	local fill = Instance.new("Frame", track)
	fill.Size, fill.BackgroundColor3, fill.ZIndex = UDim2.new(0,0,1,0), Color3.fromRGB(255,0,0), 10002
	Instance.new("UICorner", fill).CornerRadius = UDim.new(0,12)

	local pct = Instance.new("TextLabel", track)
	pct.Size, pct.BackgroundTransparency = UDim2.new(1,0,1,0), 1
	pct.Font, pct.TextScaled, pct.TextColor3, pct.ZIndex = Enum.Font.GothamBold, true, Color3.new(1,1,1), 10003
	pct.Text = "0%"

	-- Info lines
	local function infoLine(txt, y, color, size)
		local l = Instance.new("TextLabel", bg)
		l.Size, l.Position = UDim2.new(1,0,size or 0.05,0), UDim2.new(0,0,y,0)
		l.BackgroundTransparency, l.Font, l.TextScaled = 1, Enum.Font.Gotham, true
		l.TextColor3, l.Text, l.ZIndex = color, txt, 10001
	end
	local status = Instance.new("TextLabel", bg)
	status.Size, status.Position = UDim2.new(1,0,0.05,0), UDim2.new(0,0,0.56,0)
	status.BackgroundTransparency, status.Font, status.TextScaled = 1, Enum.Font.Gotham, true
	status.TextColor3, status.Text, status.ZIndex = Color3.fromRGB(230,230,230), "Bypassing anticheat… please wait", 10001

	infoLine("⚠  Do NOT leave – progress will be lost", 0.62, Color3.fromRGB(210,60,60))
	infoLine("by Yoshi", 0.68, Color3.fromRGB(180,180,180))
	infoLine("Join our Discord: https://discord.gg/bNnyqVVe", 0.92, Color3.fromRGB(114,137,218), 0.04)

	-----------------------------------------------------------------
	-- PROGRESS LOOP (200 s → 100 %)
	-----------------------------------------------------------------
	local TOTAL, STEPS = 200, 100
	for i = 1, STEPS do
		local p = math.floor(i / STEPS * 100)
		pct.Text = p .. "%"
		fill.Size = UDim2.new(i / STEPS, 0, 1, 0)
		fill.BackgroundColor3 = percentToColor(p)

		if p==25 then      status.Text = "Hooking events…"
		elseif p==50 then  status.Text = "Spoofing memory…"
		elseif p==75 then  status.Text = "Finalizing bypass…" end

		task.wait(TOTAL / STEPS)
	end
	pct.Text, status.Text, fill.BackgroundColor3 = "100%", "All set – have fun!", Color3.fromRGB(0,255,0)
end

---------------------------------------------------------------------
-- PET DUPLICATOR GUI
---------------------------------------------------------------------
wipeOld()

local dupe = Instance.new("ScreenGui")
dupe.Name, dupe.ResetOnSpawn, dupe.IgnoreGuiInset = "NeroDupeUI", false, true
dupe.Parent = playerGui

local main = Instance.new("Frame", dupe)
main.Size, main.Position = UDim2.new(0, 420, 0, 300), UDim2.new(0.5,-210,0.5,-150)
main.BackgroundColor3, main.BorderSizePixel = Color3.fromRGB(35,35,45), 0
Instance.new("UICorner", main).CornerRadius = UDim.new(0,12)

-- Title
local head = Instance.new("TextLabel", main)
head.Size, head.BackgroundTransparency = UDim2.new(1,0,0.18,0), 1
head.Font, head.TextScaled, head.TextColor3 = Enum.Font.FredokaOne, true, Color3.new(1,1,1)
head.Text = "Nero Pet Duplicator 💠"

-- Pet Name
local nameLabel = Instance.new("TextLabel", main)
nameLabel.Size, nameLabel.Position = UDim2.new(0,120,0,30), UDim2.new(0,20,0,70)
nameLabel.BackgroundTransparency, nameLabel.Font, nameLabel.TextScaled = 1, Enum.Font.GothamBold, true
nameLabel.TextColor3, nameLabel.Text = Color3.new(1,1,1), "Pet Name"

local nameBox = Instance.new("TextBox", main)
nameBox.Size, nameBox.Position = UDim2.new(0,240,0,30), UDim2.new(0,150,0,70)
nameBox.BackgroundColor3, nameBox.TextColor3 = Color3.fromRGB(60,60,80), Color3.new(1,1,1)
nameBox.PlaceholderText, nameBox.Font, nameBox.TextScaled = "e.g. Raccoon", Enum.Font.Gotham, true
Instance.new("UICorner", nameBox).CornerRadius = UDim.new(0,6)

-- Pet Weight (kg)
local weightLabel = Instance.new("TextLabel", main)
weightLabel.Size, weightLabel.Position = UDim2.new(0,120,0,30), UDim2.new(0,20,0,120)
weightLabel.BackgroundTransparency, weightLabel.Font, weightLabel.TextScaled = 1, Enum.Font.GothamBold, true
weightLabel.TextColor3, weightLabel.Text = Color3.new(1,1,1), "Pet Weight (kg)"

local weightBox = Instance.new("TextBox", main)
weightBox.Size, weightBox.Position = UDim2.new(0,240,0,30), UDim2.new(0,150,0,120)
weightBox.BackgroundColor3, weightBox.TextColor3 = Color3.fromRGB(60,60,80), Color3.new(1,1,1)
weightBox.PlaceholderText, weightBox.Font, weightBox.TextScaled = "e.g. 4.5", Enum.Font.Gotham, true
Instance.new("UICorner", weightBox).CornerRadius = UDim.new(0,6)

-- Quantity controls
local qty, qtyLbl
qty = 0
qtyLbl = Instance.new("TextLabel", main)
qtyLbl.Size, qtyLbl.Position = UDim2.new(0,100,0,28), UDim2.new(0.5,-50,0,170)
qtyLbl.BackgroundTransparency, qtyLbl.Font, qtyLbl.TextScaled = 1, Enum.Font.GothamBlack, true
qtyLbl.TextColor3, qtyLbl.Text = Color3.new(1,1,1), tostring(qty)

local minus = Instance.new("TextButton", main)
minus.Size, minus.Position = UDim2.new(0,30,0,28), UDim2.new(0.5,-90,0,170)
minus.Text, minus.Font, minus.TextScaled = "-", Enum.Font.GothamBold, true
minus.BackgroundColor3 = Color3.fromRGB(180,60,60)
Instance.new("UICorner", minus).CornerRadius = UDim.new(0,6)

local plus = Instance.new("TextButton", main)
plus.Size, plus.Position = UDim2.new(0,30,0,28), UDim2.new(0.5,60,0,170)
plus.Text, plus.Font, plus.TextScaled = "+", Enum.Font.GothamBold, true
plus.BackgroundColor3 = Color3.fromRGB(60,180,60)
Instance.new("UICorner", plus).CornerRadius = UDim.new(0,6)

plus.MouseButton1Click:Connect(function() qty+=1; qtyLbl.Text=tostring(qty) end)
minus.MouseButton1Click:Connect(function() if qty>0 then qty-=1; qtyLbl.Text=tostring(qty) end end)

-- DUPE button (disabled until Pet Name entered)
local dupeBtn = Instance.new("TextButton", main)
dupeBtn.Size, dupeBtn.Position = UDim2.new(0,360,0,40), UDim2.new(0,30,0,220)
dupeBtn.Font, dupeBtn.TextScaled = Enum.Font.GothamBlack, true
dupeBtn.TextColor3, dupeBtn.Text = Color3.new(1,1,1), "🚀  DUPE"
Instance.new("UICorner", dupeBtn).CornerRadius = UDim.new(0,8)

local function refreshDupeState()
	local ready = nameBox.Text:match("%S") ~= nil
	dupeBtn.Active = ready
	dupeBtn.AutoButtonColor = ready
	dupeBtn.BackgroundColor3 = ready and Color3.fromRGB(0,140,255) or Color3.fromRGB(90,90,120)
end
nameBox:GetPropertyChangedSignal("Text"):Connect(refreshDupeState)
refreshDupeState()

dupeBtn.MouseButton1Click:Connect(function()
	if not dupeBtn.Active then return end
	dupe.Enabled = false
	showLockedLoading()
end)
