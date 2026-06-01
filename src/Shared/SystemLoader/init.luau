type Options = {
	playerFilter: (Player) -> (),
}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local fetch = require(script.fetch)
local dispatch = require(script.dispatch)
local Subject = require(ReplicatedStorage.Packages.Subject)

local SystemLoader = {
	_started = false,
	_validPlayers = {},
	playerAdded = Subject.new(),
	playerRemoving = Subject.new(),
}

function SystemLoader.start(systemDirectory: Folder, options: Options?): ()
	if SystemLoader._started then
		error("SystemLoader has already started.")
	end

	SystemLoader._started = true

	local systems = fetch(systemDirectory)

	dispatch(systems, "start")

	local function onPlayerAdded(player)
		if options ~= nil and options.playerFilter ~= nil and not options.playerFilter(player) then
			return
		end

		SystemLoader._validPlayers[player] = true
		SystemLoader.playerAdded:notify(player)

		dispatch(systems, "onPlayerAdded", player)
	end

	local function onPlayerRemoving(player)
		if SystemLoader._validPlayers[player] == nil then
			return
		end

		SystemLoader._validPlayers[player] = nil
		SystemLoader.playerRemoving:notify(player)

		dispatch(systems, "onPlayerRemoving", player)
	end

	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)

	for _, player in ipairs(Players:GetPlayers()) do
		onPlayerAdded(player)
	end

	return systems
end

function SystemLoader.getPlayers()
	local players = {}

	for player in pairs(SystemLoader._validPlayers) do
		table.insert(players, player)
	end

	return players
end

return SystemLoader
