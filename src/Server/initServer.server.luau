local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local CharmSync = require(ReplicatedStorage.Packages.CharmSync)

local SystemLoader = require(ReplicatedStorage.Shared.SystemLoader)
local Atoms = require(ReplicatedStorage.Shared.Store.Sync.Atoms)
local FilterPayload = require(ReplicatedStorage.Shared.Store.Sync.Utils.FilterPayload)

local ServerRemotes = require(ServerScriptService.Server.ServerRemotes)

local syncer = CharmSync.server({ atoms = Atoms })

syncer:connect(function(player, payload)
	local filteredPayload = FilterPayload(player.Name, payload)

	ServerRemotes.replicateState.fire(player, filteredPayload)
end)

ServerRemotes.requestState.setCallback(function(player)
	syncer:hydrate(player)
end)

SystemLoader.start(ServerScriptService.Server.Systems, {
	playerFilter = function(player)
		return true
	end,
})
