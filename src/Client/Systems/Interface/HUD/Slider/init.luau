local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local ClientRemotes = require(ReplicatedFirst.Client.ClientRemotes)
local ConveyorUtil = require(ReplicatedStorage.Shared.Util.ConveyorUtil)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local hudUI = playerGui:WaitForChild("HUD") :: typeof(StarterGui.HUD)

local MIN_SPAWN_INTERVAL = ConveyorUtil.MIN_SPAWN_INTERVAL
local MAX_SPAWN_INTERVAL = ConveyorUtil.MAX_SPAWN_INTERVAL

local Slider = {}

local function handleSlider()
	local sliderFrame = hudUI.Slider
	local bar = sliderFrame.Bar
	local btn = sliderFrame.Button
	local title = sliderFrame.Title

	sliderFrame.Visible = true

	local isDragging = false

	local currentSpawnInterval = MIN_SPAWN_INTERVAL

	local function updateText(spawnInterval)
		title.Text = string.format("Spawn Interval %.1fs", spawnInterval)
	end

	local function getSpawnInterval(relativeX)
		local sliderMin = sliderFrame.AbsolutePosition.X
		local sliderMax = sliderMin + sliderFrame.AbsoluteSize.X
		local sliderRange = sliderMax - sliderMin
		local percentage = relativeX / sliderRange
		local spawnInterval = MIN_SPAWN_INTERVAL + (MAX_SPAWN_INTERVAL - MIN_SPAWN_INTERVAL) * percentage
		return spawnInterval
	end

	btn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			isDragging = true
		end
	end)

	btn.InputEnded:Connect(function(input, gameProcessed)
		if isDragging and input.UserInputType == Enum.UserInputType.MouseButton1 then
			isDragging = false
			ClientRemotes.updateSpawnInterval.fire(currentSpawnInterval)
		end
	end)

	RunService.RenderStepped:Connect(function()
		if isDragging then
			local sliderMin = sliderFrame.AbsolutePosition.X
			local sliderMax = sliderMin + sliderFrame.AbsoluteSize.X

			local mouseX = UserInputService:GetMouseLocation().X
			local clampedX = math.clamp(mouseX, sliderMin, sliderMax)
			local relativeX = clampedX - sliderMin

			btn.Position = UDim2.new(0, relativeX - btn.AbsoluteSize.X / 2, btn.Position.Y.Scale, btn.Position.Y.Offset)

			local spawnInterval = getSpawnInterval(relativeX)
			updateText(spawnInterval)
			currentSpawnInterval = spawnInterval

			local barWidth = relativeX
			bar.Size = UDim2.new(0, barWidth, bar.Size.Y.Scale, bar.Size.Y.Offset)
		end
	end)
end

function Slider.init()
	ClientRemotes.toggleSlider.setCallback(function(state)
		local sliderFrame = hudUI.Slider

		if state == true then
			handleSlider()
		else
			sliderFrame.Visible = false
		end
	end)
end

return Slider
