local function callSystems(systems, name, ...)
	for _, system in ipairs(systems) do
		if system[name] and typeof(system[name]) == "function" then
			task.defer(system[name], ...)
		end
	end
end

return callSystems
