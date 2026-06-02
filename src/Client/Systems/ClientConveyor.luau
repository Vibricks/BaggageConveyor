local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Charm = require(ReplicatedStorage.Packages.Charm)
local Flipper = require(ReplicatedStorage.Packages.Flipper)
local ConveyorStore = require(ReplicatedStorage.Shared.Store.ConveyorStore)
local conveyorSchema = require(ReplicatedStorage.Shared.Store.ConveyorStore.conveyorSchema)
local ConveyorUtil = require(ReplicatedStorage.Shared.Util.ConveyorUtil)

local module = {}

local activeBagModels = {}

local function animateBag(bagModel: ConveyorUtil.bagModel, conveyorModel)
	local startPos = conveyorModel.StartPoint.Position
	local endPos = conveyorModel.EndPoint.Position
	local distance = (endPos - startPos).Magnitude
	local direction = (endPos - startPos).Unit

	local velocity = conveyorModel:GetAttribute("Velocity") or 1
	local bagLifeTime = ConveyorUtil.calculateBagLifeTime(conveyorModel)

	local positionMotor = Flipper.SingleMotor.new(0)
	positionMotor:setGoal(Flipper.Linear.new(distance, { velocity = velocity }))

	local scaleMotor = Flipper.SingleMotor.new(0.3)
	scaleMotor:setGoal(Flipper.Spring.new(1, { frequency = 5, dampingRatio = 0.8 }))

	local rotationMotor = Flipper.SingleMotor.new(0)
	rotationMotor:setGoal(Flipper.Linear.new(math.pi * 2, { velocity = 12 }))

	positionMotor:onStep(function(value)
		bagModel:PivotTo(CFrame.new(startPos + direction * value) * CFrame.Angles(0, rotationMotor:getValue(), 0))
	end)

	scaleMotor:onStep(function(value)
		bagModel:ScaleTo(value)
	end)

	task.wait(bagLifeTime - 0.3)

	local scaleOutMotor = Flipper.SingleMotor.new(1)
	scaleOutMotor:setGoal(Flipper.Spring.new(0.1, { frequency = 5, dampingRatio = 0.8 }))

	scaleOutMotor:onStep(function(value)
		bagModel:ScaleTo(value)
	end)

	task.wait(0.3)
	bagModel:Destroy()
end

local function updateBagVisuals(bagModel: ConveyorUtil.bagModel, bagData: conveyorSchema.BagData)
	bagModel.Main.Color = bagData.Color
	bagModel.Main.Material = bagData.Material
end

local function spawnBag(conveyorId: string, bagData: conveyorSchema.BagData)
	local conveyorModel = workspace.Active:FindFirstChild(conveyorId)

	if not conveyorModel then
		warn(`No valid model found for conveyor - ({conveyorId})`)
		return
	end

	local bagModel = ReplicatedStorage.Assets.Bags.DefaultBag:Clone()
	updateBagVisuals(bagModel, bagData)

	bagModel.Parent = workspace
	bagModel:PivotTo(conveyorModel.StartPoint.CFrame)
	bagModel:ScaleTo(0.3)

	if not activeBagModels[conveyorId] then
		activeBagModels[conveyorId] = {}
	end
	activeBagModels[conveyorId][bagData.UUID] = bagModel

	animateBag(bagModel, conveyorModel)

	return bagModel
end

function module.start()
	--I'm doing this to fix a weird bug with the first bag not loading correctly (Really weird)
	local dummyBag = ReplicatedStorage.Assets.Bags.DefaultBag:Clone()
	dummyBag.Parent = workspace
	dummyBag:Destroy()

	local ConveyorAtom = ConveyorStore.getAtom()

	Charm.subscribe(ConveyorAtom, function(newState, oldState)
		for conveyorId, conveyorData in newState do
			local activeBags = conveyorData.ActiveBags
			local oldConveyorData = oldState[conveyorId]
			local oldActiveBags = oldConveyorData and oldConveyorData.ActiveBags or {}

			for bagId, bagData in activeBags do
				if not oldActiveBags[bagId] then
					spawnBag(conveyorId, bagData)
				end
			end

			for bagId in oldActiveBags do
				if not activeBags[bagId] then
					local bagModel = activeBagModels[conveyorId] and activeBagModels[conveyorId][bagId]
					if bagModel then
						bagModel:Destroy()
						activeBagModels[conveyorId][bagId] = nil
					end
				end
			end
		end
	end)
end

return module
