local ReplicatedStorage = game:GetService("ReplicatedStorage")
local conveyorStore = require(ReplicatedStorage.Shared.Store.ConveyorStore)

return {
	conveyorData = conveyorStore.getAtom(),
}
