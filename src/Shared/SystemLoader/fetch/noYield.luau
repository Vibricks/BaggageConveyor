local function noYield(module)
	local task = coroutine.create(require)
	local _, result = coroutine.resume(task, module)

	if coroutine.status(task) ~= "dead" then
		error(string.format("'%s' attempted to yield on require", module:GetFullName()))
	end

	return result
end

return noYield
