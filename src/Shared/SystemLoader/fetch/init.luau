local noYield = require(script.noYield)

local function fetch(directory: Folder)
	local systems = {}

	local function fetchRecursive(folder: Instance)
		for _, module in ipairs(folder:GetChildren()) do
			if module:IsA("ModuleScript") and module:FindFirstAncestorWhichIsA("ModuleScript") == nil then
				table.insert(systems, noYield(module))
			else
				fetchRecursive(module)
			end
		end
	end

	fetchRecursive(directory)

	return systems
end

return fetch
