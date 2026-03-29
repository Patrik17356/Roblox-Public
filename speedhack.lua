--// Player & GUI
local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "SpeedGUI"
gui.Parent = player:WaitForChild("PlayerGui")

--// Main Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 150)
frame.Position = UDim2.new(0.5, -125, 0.5, -75)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

--// Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "Speed Controller"
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.TextColor3 = Color3.new(1,1,1)
title.Parent = frame

--// Slider Background
local sliderBG = Instance.new("Frame")
sliderBG.Size = UDim2.new(0.8, 0, 0, 10)
sliderBG.Position = UDim2.new(0.1, 0, 0.4, 0)
sliderBG.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
sliderBG.Parent = frame

--// Slider Fill
local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(0, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
sliderFill.Parent = sliderBG

--// Slider Button (draggable)
local sliderBtn = Instance.new("TextButton")
sliderBtn.Size = UDim2.new(0, 10, 0, 20)
sliderBtn.Position = UDim2.new(0, -5, 0.5, -10)
sliderBtn.Text = ""
sliderBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderBtn.Parent = sliderBG

--// Speed Label
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, 0, 0, 20)
speedLabel.Position = UDim2.new(0, 0, 0.55, 0)
speedLabel.Text = "Speed: 16"
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.new(1,1,1)
speedLabel.Parent = frame

--// Toggle Button
local button = Instance.new("TextButton")
button.Size = UDim2.new(0.8, 0, 0, 30)
button.Position = UDim2.new(0.1, 0, 0.75, 0)
button.Text = "Toggle Speed: OFF"
button.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
button.TextColor3 = Color3.new(1,1,1)
button.Parent = frame

--// Variables
local toggled = false
local defaultSpeed = 16
local currentSpeed = 16
local dragging = false

--// Slider Logic
local function updateSlider(x)
	local rel = math.clamp((x - sliderBG.AbsolutePosition.X) / sliderBG.AbsoluteSize.X, 0, 1)
	sliderFill.Size = UDim2.new(rel, 0, 1, 0)
	sliderBtn.Position = UDim2.new(rel, -5, 0.5, -10)

	currentSpeed = math.floor(1 + (99 * rel)) -- range 1–100
	speedLabel.Text = "Speed: " .. currentSpeed
end

sliderBtn.MouseButton1Down:Connect(function()
	dragging = true
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		updateSlider(input.Position.X)
	end
end)

--// Function to apply + hook humanoid
local function setupHumanoid(character)
	local humanoid = character:WaitForChild("Humanoid")

	-- Instant apply
	if toggled then
		humanoid.WalkSpeed = currentSpeed
	end

	-- Hook (protect from resets)
	humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
		if toggled and humanoid.WalkSpeed ~= currentSpeed then
			humanoid.WalkSpeed = currentSpeed
		end
	end)
end

--// Character respawn hook
player.CharacterAdded:Connect(function(char)
	setupHumanoid(char)
end)

-- Initial character
if player.Character then
	setupHumanoid(player.Character)
end

--// Loop backup (extra safety)
task.spawn(function()
	while true do
		if toggled then
			local char = player.Character
			if char then
				local hum = char:FindFirstChild("Humanoid")
				if hum then
					hum.WalkSpeed = currentSpeed
				end
			end
		end
		task.wait(0.5)
	end
end)

--// Toggle button
button.MouseButton1Click:Connect(function()
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")

	if not toggled then
		toggled = true
		humanoid.WalkSpeed = currentSpeed
		button.Text = "Toggle Speed: ON"
		button.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
	else
		toggled = false
		humanoid.WalkSpeed = defaultSpeed
		button.Text = "Toggle Speed: OFF"
		button.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
	end
end)