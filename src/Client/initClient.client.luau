local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local CharmSync = require(Packages.CharmSync)
local Atoms = require(ReplicatedStorage.Shared.Store.Sync.Atoms)
local Promise = require(Packages.Promise)

local ClientRemotes = require(ReplicatedFirst.Client.ClientRemotes)

local syncer = CharmSync.client({ atoms = Atoms })

local SystemLoader = require(ReplicatedStorage.Shared.SystemLoader)

--This handles state replication from server to client

ClientRemotes.requestState.fire()

Promise.new(function(resolve)
	ClientRemotes.replicateState.setCallback(function(payload)
		syncer:sync(payload)
		resolve()
	end)
end):await()

--We initialize all client side systems here
SystemLoader.start(ReplicatedFirst.Client.Systems, {
	playerFilter = function()
		return true
	end,
})
