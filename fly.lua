--// Player & Services
local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

--// GUI
local gui = Instance.new("ScreenGui")
gui.Name = "FlyGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

--// Frame
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
title.Text = "Fly Controller"
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

--// Label
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, 0, 0, 20)
speedLabel.Position = UDim2.new(0, 0, 0.55, 0)
speedLabel.Text = "Fly Speed: 50"
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
local flying = false
local flySpeed = 50
local dragging = false

local bv, bg

--// Slider
local function updateSlider(x)
	local rel = math.clamp((x - sliderBG.AbsolutePosition.X) / sliderBG.AbsoluteSize.X, 0, 1)

	sliderFill.Size = UDim2.new(rel, 0, 1, 0)
	sliderBtn.Position = UDim2.new(rel, -7, 0.5, -7)

	flySpeed = math.floor(10 + (190 * rel))
	speedLabel.Text = "Fly Speed: " .. flySpeed
end

sliderBG.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		updateSlider(input.Position.X)
	end
end)

UIS.InputChanged:Connect(function(input)
	if dragging and (
		input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch
	) then
		updateSlider(input.Position.X)
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

--// Fly Movement
local function startFly(character)
	local hrp = character:WaitForChild("HumanoidRootPart")

	bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
	bv.Velocity = Vector3.zero
	bv.Parent = hrp

	bg = Instance.new("BodyGyro")
	bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
	bg.CFrame = hrp.CFrame
	bg.Parent = hrp
end

local function stopFly()
	if bv then bv:Destroy() end
	if bg then bg:Destroy() end
end

--// Movement Control
RunService.RenderStepped:Connect(function()
	if flying and bv and bg then
		local char = player.Character
		if not char then return end

		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end

		local cam = workspace.CurrentCamera
		local dir = Vector3.zero

		if UIS:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
		if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0,1,0) end

		bv.Velocity = dir.Unit * flySpeed
		bg.CFrame = cam.CFrame
	end
end)

--// Toggle
button.MouseButton1Click:Connect(function()
	local char = player.Character or player.CharacterAdded:Wait()

	flying = not flying

	if flying then
		startFly(char)
		button.Text = "ON"
		button.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
	else
		stopFly()
		button.Text = "OFF"
		button.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
	end
end)

--// Respawn fix
player.CharacterAdded:Connect(function(char)
	if flying then
		task.wait(0.2)
		startFly(char)
	end
end)