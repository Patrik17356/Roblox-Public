--// Player & Services
local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

--// GUI
local gui = Instance.new("ScreenGui")
gui.Name = "SpeedGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

--// Main Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 160)
frame.Position = UDim2.new(0.5, -130, 0.5, -80)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

--// Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "Speed Controller"
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = frame

--// Slider BG
local sliderBG = Instance.new("Frame")
sliderBG.Size = UDim2.new(0.8, 0, 0, 12)
sliderBG.Position = UDim2.new(0.1, 0, 0.4, 0)
sliderBG.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
sliderBG.BorderSizePixel = 0
sliderBG.Parent = frame

--// Slider Fill
local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(0, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderBG

--// Slider Button
local sliderBtn = Instance.new("Frame")
sliderBtn.Size = UDim2.new(0, 14, 0, 14)
sliderBtn.Position = UDim2.new(0, -7, 0.5, -7)
sliderBtn.BackgroundColor3 = Color3.fromRGB(255,255,255)
sliderBtn.BorderSizePixel = 0
sliderBtn.Parent = sliderBG

--// Speed Label
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, 0, 0, 20)
speedLabel.Position = UDim2.new(0, 0, 0.55, 0)
speedLabel.Text = "Speed: 16"
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.new(1,1,1)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 14
speedLabel.Parent = frame

--// Toggle Button
local button = Instance.new("TextButton")
button.Size = UDim2.new(0.8, 0, 0, 32)
button.Position = UDim2.new(0.1, 0, 0.75, 0)
button.Text = "OFF"
button.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
button.TextColor3 = Color3.new(1,1,1)
button.Font = Enum.Font.GothamBold
button.TextSize = 14
button.Parent = frame

--// Variables
local toggled = false
local defaultSpeed = 16
local currentSpeed = 16
local dragging = false

--// Slider Function
local function updateSliderFromX(x)
	local rel = math.clamp((x - sliderBG.AbsolutePosition.X) / sliderBG.AbsoluteSize.X, 0, 1)

	sliderFill.Size = UDim2.new(rel, 0, 1, 0)
	sliderBtn.Position = UDim2.new(rel, -7, 0.5, -7)

	currentSpeed = math.floor(1 + (99 * rel))
	speedLabel.Text = "Speed: " .. currentSpeed
end

--// Input Handling (PC + Mobile)
sliderBG.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		updateSliderFromX(input.Position.X)
	end
end)

UIS.InputChanged:Connect(function(input)
	if dragging and (
		input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch
	) then
		updateSliderFromX(input.Position.X)
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

--// Humanoid Setup
local function setupHumanoid(character)
	local humanoid = character:WaitForChild("Humanoid")

	if toggled then
		humanoid.WalkSpeed = currentSpeed
	end

	-- Hook protection
	humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
		if toggled and humanoid.WalkSpeed ~= currentSpeed then
			humanoid.WalkSpeed = currentSpeed
		end
	end)
end

--// Respawn Hook
player.CharacterAdded:Connect(setupHumanoid)

if player.Character then
	setupHumanoid(player.Character)
end

--// Frame-based enforcement
RunService.RenderStepped:Connect(function()
	if toggled then
		local char = player.Character
		if char then
			local hum = char:FindFirstChild("Humanoid")
			if hum and hum.WalkSpeed ~= currentSpeed then
				hum.WalkSpeed = currentSpeed
			end
		end
	end
end)

--// Toggle Button
button.MouseButton1Click:Connect(function()
	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")

	toggled = not toggled

	if toggled then
		hum.WalkSpeed = currentSpeed
		button.Text = "ON"
		button.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
	else
		hum.WalkSpeed = defaultSpeed
		button.Text = "OFF"
		button.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
	end
end)
