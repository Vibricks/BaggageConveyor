local ReplicatedStorage = game:GetService("ReplicatedStorage")

export type ConveyorModel = typeof(workspace.Active.ConveyorModel)
export type bagModel = typeof(ReplicatedStorage.Assets.Bags.DefaultBag)

local ConveyorUtil = {}

ConveyorUtil.MIN_SPAWN_INTERVAL = 1
ConveyorUtil.MAX_SPAWN_INTERVAL = 10

function ConveyorUtil.calculateBagLifeTime(conveyorModel: ConveyorModel): number
	local startPoint = conveyorModel.StartPoint.Position
	local endPoint = conveyorModel.EndPoint.Position
	local velocity = conveyorModel:GetAttribute("Velocity") or 10

	local distance = (startPoint - endPoint).Magnitude

	local bagLifeTime = distance / velocity
	return bagLifeTime
end

return ConveyorUtil
