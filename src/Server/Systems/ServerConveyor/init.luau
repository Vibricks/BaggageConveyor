local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sift = require(ReplicatedStorage.Packages.Sift)
local ConveyorStore = require(ReplicatedStorage.Shared.Store.ConveyorStore)
local conveyorSchema = require(ReplicatedStorage.Shared.Store.ConveyorStore.conveyorSchema)

local module = {}

local firstPlayer: Player

local function loadConveyor(model: typeof(workspace.Active.ConveyorModel))
	warn("setting up conveyor", model)

	local generatedId = string.sub(HttpService:GenerateGUID(false), 1, 4)
	local conveyorId = "Conveyor-" .. generatedId

	model.Name = conveyorId

	local data = conveyorSchema.getDefaultData()
	data.UUID = conveyorId

	if firstPlayer then
		data.Owner = firstPlayer.UserId
	end

	ConveyorStore.setConveyorData(conveyorId, conveyorSchema.getDefaultData())
	local conveyorData = ConveyorStore.getConveyorData(conveyorId)
	warn(conveyorData)
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
			local newBag = generateRandomBag(conveyorId)

			if os.clock() - lastSpawnTime > spawnInterval then
				print(conveyorId, conveyorData)

				ConveyorStore.updateConveyorData(conveyorId, function(state)
					return Sift.Dictionary.merge(state, {
						LastSpawnTime = os.clock(),
						ActiveBags = Sift.Dictionary.merge(state.ActiveBags, { [newBag.UUID] = newBag }),
					})
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
