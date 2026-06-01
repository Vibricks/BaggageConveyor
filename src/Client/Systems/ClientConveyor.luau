local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Charm = require(ReplicatedStorage.Packages.Charm)
local ConveyorStore = require(ReplicatedStorage.Shared.Store.ConveyorStore)

local module = {}

local function spawnBag(conveyorId, bagData)
	local conveyorModel = workspace.Active:FindFirstChild(conveyorId)

	if not conveyorModel then
		warn(`No valid model found for conveyor - ({conveyorId})`)
		return
	end

	local bagModel = ReplicatedStorage.Assets.Bags.DefaultBag:Clone()
	bagModel.Parent = workspace

	bagModel:PivotTo(conveyorModel.StartPoint.CFrame)
end

function module.start()
	local ConveyorAtom = ConveyorStore.getAtom()

	Charm.subscribe(ConveyorAtom, function(newState, oldState)
		for conveyorId, conveyorData in newState do
			local activeBags = conveyorData.ActiveBags
			local oldConveyorData = oldState[conveyorId]
			local oldActiveBags = oldConveyorData and oldConveyorData.ActiveBags or {}

			for bagId, bagData in activeBags do
				if not oldActiveBags[bagId] then
					warn("New bag added:", bagId)
					spawnBag(conveyorId, bagData)
				end
			end
		end
	end)
end

return module
