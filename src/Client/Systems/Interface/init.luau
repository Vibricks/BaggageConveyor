local Interface = {}

function loadUIHandlers()
	for i, v in pairs(script:GetChildren()) do
		if v:IsA("ModuleScript") then
			local module = require(v)
			if module.init then
				module.init()
			end
		end
	end
end

function Interface.start()
	loadUIHandlers()
end

return Interface
