local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Charm = require(ReplicatedStorage.Packages.Charm)
local Object = require(ReplicatedStorage.Shared.Util.Object)

local conveyorSchema = require(script.conveyorSchema)

export type ConveyorData = conveyorSchema.ConveyorData

local module = {}

local conveyorStore: Charm.Atom<{ [string]: ConveyorData }> = Charm.atom({})

function module.getConveyorData(conveyorId): ConveyorData?
	return conveyorStore()[conveyorId]
end

function module.setConveyorData(conveyorId: string, data: ConveyorData)
	conveyorStore(function(state)
		return Object.set(state, conveyorId, data)
	end)
end

function module.removeConveyorData(conveyorId: string)
	conveyorStore(function(state)
		return Object.delete(state, conveyorId)
	end)
end

function module.updateConveyorData(conveyorId: string, updater: (data: ConveyorData) -> ConveyorData)
	local currentData = module.getConveyorData(conveyorId)

	local newData

	if currentData then
		newData = updater(currentData)
	else
		warn(`Conveyor with id {conveyorId} not found`)
	end

	if newData then
		module.setConveyorData(conveyorId, newData)
	end
end

function module.getAtom()
	return conveyorStore
end

return module
