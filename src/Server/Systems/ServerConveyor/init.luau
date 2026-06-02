local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerRemotes = require(ServerScriptService.Server.ServerRemotes)
local Sift = require(ReplicatedStorage.Packages.Sift)
local ConveyorStore = require(ReplicatedStorage.Shared.Store.ConveyorStore)
local conveyorSchema = require(ReplicatedStorage.Shared.Store.ConveyorStore.conveyorSchema)
local ConveyorUtil = require(ReplicatedStorage.Shared.Util.ConveyorUtil)

local module = {}

module.ActiveConveyorModels = {}

local function loadConveyor(conveyorModel: ConveyorUtil.ConveyorModel)
	local generatedId = string.sub(HttpService:GenerateGUID(false), 1, 4)
	local conveyorId = "Conveyor-" .. generatedId

	local data = conveyorSchema.getDefaultData()
	data.UUID = conveyorId

	conveyorModel.Name = conveyorId
	conveyorModel:SetAttribute("Velocity", data.Velocity)

	ConveyorStore.setConveyorData(conveyorId, conveyorSchema.getDefaultData())

	module.ActiveConveyorModels[conveyorId] = conveyorModel
end

local function generateRandomBag(conveyorId): conveyorSchema.BagData
	local MaterialOptions = {
		"SmoothPlastic",
		"Rock",
		"Wood",
		"Neon",
		"Pavement",
	}
	local selectedMaterial = MaterialOptions[math.random(1, #MaterialOptions)]

	local bagData: conveyorSchema.BagData = {
		Color = BrickColor.Random().Color,
		Material = selectedMaterial,
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

	ServerRemotes.updateSpawnInterval.setCallback(function(player, newInterval)
		newInterval = math.clamp(newInterval, ConveyorUtil.MIN_SPAWN_INTERVAL, ConveyorUtil.MAX_SPAWN_INTERVAL)

		for conveyorId, v in module.ActiveConveyorModels do
			if player:GetAttribute("AssignedConveyor") == conveyorId then
				ConveyorStore.updateConveyorData(conveyorId, function(state)
					return Sift.Dictionary.merge(state, {
						SpawnInterval = newInterval,
					})
				end)
			end
		end
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

function module.onPlayerAdded(player)
	for conveyorId, _ in module.ActiveConveyorModels do
		local conveyorData = ConveyorStore.getConveyorData(conveyorId)

		if not conveyorData.Owner then
			conveyorData.Owner = player.UserId
			player:SetAttribute("AssignedConveyor", conveyorId)
			ServerRemotes.toggleSlider.fire(player, true)
		end
	end
end

return module
