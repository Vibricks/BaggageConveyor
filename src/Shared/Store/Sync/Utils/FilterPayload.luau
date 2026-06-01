local function filterPayload(id: string, payload: any)
	--[[
	 Here we edit/filter out stuff from the payload
	 This lets us send only relevant data to the client!

	Example:
		-- if payload.data.playerData then
		-- 	payload = table.clone(payload)
		-- 	payload.data = table.clone(payload.data)

		-- 	if payload.data.playerData then
		-- 		payload.data.playerData = {
		-- 			[id] = payload.data.playerData[id],
		-- 		}
		-- 	end
		-- end

		This sends only the players specific data instead of the data of EVERY player.
	--]]

	return payload
end

return filterPayload
