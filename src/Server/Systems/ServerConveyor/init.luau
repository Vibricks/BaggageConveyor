local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sift = require(ReplicatedStorage.Packages.Sift)
local ConveyorStore = require(ReplicatedStorage.Shared.Store.ConveyorStore)
local conveyorSchema = require(ReplicatedStorage.Shared.Store.ConveyorStore.conveyorSchema)
local ConveyorUtil = require(ReplicatedStorage.Shared.Util.ConveyorUtil)

local module = {}

module.ActiveConveyorModels = {}

local firstPlayer: Player

local function loadConveyor(conveyorModel: ConveyorUtil.ConveyorModel)
	local generatedId = string.sub(HttpService:GenerateGUID(false), 1, 4)
	local conveyorId = "Conveyor-" .. generatedId

	local data = conveyorSchema.getDefaultData()
	data.UUID = conveyorId

	conveyorModel.Name = conveyorId
	conveyorModel:SetAttribute("Velocity", data.Velocity)

	if firstPlayer then
		data.Owner = firstPlayer.UserId
	end

	ConveyorStore.setConveyorData(conveyorId, conveyorSchema.getDefaultData())

	module.ActiveConveyorModels[conveyorId] = conveyorModel
end

local function generateRandomBag(conveyorId): conveyorSchema.BagData
	local bagData: conveyorSchema.BagData = {
		Color = BrickColor.Random().Color,
		Material = "SmoothPlastic",
		TimeSpawned = os.clock(),
		UUID = string.sub(HttpService:GenerateGUID(false), 1, 4),
	}

	return bagData
end

function module.start()
	local conveyorModels = CollectionService:GetTagged("Conveyor")

	for _, model in conveyorModels do
		loadConveyor(model)
	end

	CollectionService:GetInstanceAddedSignal("Conveyor"):Connect(function(model)
		loadConveyor(model)
	end)

	while true do
		local conveyorAtom = ConveyorStore.getAtom()

		for conveyorId, conveyorData in conveyorAtom() do
			local spawnInterval = conveyorData.SpawnInterval
			local lastSpawnTime = conveyorData.LastSpawnTime

			if os.clock() - lastSpawnTime > spawnInterval then
				--We generate the bag here
				local newBag = generateRandomBag(conveyorId)

				--We update the conveyor atom so that the new bag replicates to every client
				ConveyorStore.updateConveyorData(conveyorId, function(state)
					return Sift.Dictionary.merge(state, {
						LastSpawnTime = os.clock(),
						ActiveBags = Sift.Dictionary.merge(state.ActiveBags, { [newBag.UUID] = newBag }),
					})
				end)

				--We determine the life time of the bag based on the distance and speed of the conveyor belt
				local bagLifeTime = ConveyorUtil.calculateBagLifeTime(module.ActiveConveyorModels[conveyorId])

				--We clean up after the end is reached based on the calculation above
				task.delay(bagLifeTime, function()
					ConveyorStore.updateConveyorData(conveyorId, function(state)
						return Sift.Dictionary.merge(state, {
							ActiveBags = Sift.Dictionary.removeKey(state.ActiveBags, newBag.UUID),
						})
					end)
				end)
			end
		end

		task.wait()
	end
end

function module.playerAdded(player)
	if not firstPlayer then
		firstPlayer = player
	end
end

return module
