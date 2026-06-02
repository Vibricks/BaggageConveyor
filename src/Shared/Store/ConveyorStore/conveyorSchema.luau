local ReplicatedStorage = game:GetService("ReplicatedStorage")
local gt = require(ReplicatedStorage.Packages.GreenTea)

local module = {}

local bagData = gt.table({
	Material = gt.string(),
	Color = gt.Color3(),
	UUID = gt.number(),
	TimeSpawned = gt.number(),
})

local conveyorSchema = gt.build(gt.table({
	ActiveBags = gt.struct({ [gt.string()] = bagData }),
	SpawnInterval = gt.number(),
	LastSpawnTime = gt.number(),
	Velocity = gt.number(),
	Owner = gt.number(), --We'll use the playerId here
	UUID = gt.number(),
}))

local defaultData: ConveyorData = {
	ActiveBags = {},
	SpawnInterval = 1,
	LastSpawnTime = os.clock(),
	Velocity = 10,
	Owner = nil, -- We'll set this when theres an available player
	UUID = nil, --We'll se this at run time
}

module.conveyorSchema = conveyorSchema

export type ConveyorData = typeof(conveyorSchema:type())
export type BagData = typeof(bagData)

function module.getDefaultData()
	return defaultData
end

return module
