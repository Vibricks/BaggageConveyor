local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Charm = require(ReplicatedStorage.Packages.Charm)
local Flipper = require(ReplicatedStorage.Packages.Flipper)
local ConveyorStore = require(ReplicatedStorage.Shared.Store.ConveyorStore)
local conveyorSchema = require(ReplicatedStorage.Shared.Store.ConveyorStore.conveyorSchema)
local ConveyorUtil = require(ReplicatedStorage.Shared.Util.ConveyorUtil)

local module = {}

local activeBagModels = {}

local function moveBag(bagModel: ConveyorUtil.bagModel, conveyorModel)
	local startPos = conveyorModel.StartPoint.Position
	local endPos = conveyorModel.EndPoint.Position
	local distance = (endPos - startPos).Magnitude
	local direction = (endPos - startPos).Unit

	local velocity = conveyorModel:GetAttribute("Velocity") or 1

	local motor = Flipper.SingleMotor.new(0)
	motor:setGoal(Flipper.Linear.new(distance, { velocity = velocity }))

	motor:onStep(function(value)
		bagModel:PivotTo(CFrame.new(startPos + direction * value))
	end)

	motor:onComplete(function() end)

	local bagLifeTime = ConveyorUtil.calculateBagLifeTime(conveyorModel)
	task.wait(bagLifeTime)
	bagModel:Destroy()
end

local function spawnBag(conveyorId: string, bagData: conveyorSchema.BagData)
	local conveyorModel = workspace.Active:FindFirstChild(conveyorId)

	if not conveyorModel then
		warn(`No valid model found for conveyor - ({conveyorId})`)
		return
	end

	--We spawn the bag here
	local bagModel = ReplicatedStorage.Assets.Bags.DefaultBag:Clone()

	bagModel.Parent = workspace
	bagModel:PivotTo(conveyorModel.StartPoint.CFrame)

	--We track the bag in a table incase we ever want to easily reference it
	if not activeBagModels[conveyorId] then
		activeBagModels[conveyorId] = {}
	end
	activeBagModels[conveyorId][bagData.UUID] = bagModel

	--We move the bag along the conveyor belt here
	moveBag(bagModel, conveyorModel)

	return bagModel
end

function module.start()
	local ConveyorAtom = ConveyorStore.getAtom()

	Charm.subscribe(ConveyorAtom, function(newState, oldState)
		for conveyorId, conveyorData in newState do
			local activeBags = conveyorData.ActiveBags
			local oldConveyorData = oldState[conveyorId]
			local oldActiveBags = oldConveyorData and oldConveyorData.ActiveBags or {}

			--We add new bags here
			for bagId, bagData in activeBags do
				if not oldActiveBags[bagId] then
					spawnBag(conveyorId, bagData)
				end
			end

			--We delete old bags here
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
