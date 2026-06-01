local Object = {}

-- Immutably sets a key in a table
function Object.set(obj, key, value)
	local newTable = table.clone(obj)
	newTable[key] = value
	return newTable
end

-- Immutably deletes a key from a table
function Object.delete(obj, key)
	local newTable = table.clone(obj)
	newTable[key] = nil
	return newTable
end

return Object
