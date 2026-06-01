local ReplicatedStorage = game:GetService("ReplicatedStorage")

export type ConveyorModel = typeof(workspace.Active.ConveyorModel)
export type bagModel = typeof(ReplicatedStorage.Assets.Bags.DefaultBag)

local ConveyorUtil = {}

function ConveyorUtil.calculateBagLifeTime(conveyorModel: ConveyorModel): number
	local startPoint = conveyorModel.StartPoint.Position
	local endPoint = conveyorModel.EndPoint.Position
	local velocity = conveyorModel:GetAttribute("Velocity") or 10

	local distance = (startPoint - endPoint).Magnitude

	local bagLifeTime = distance / velocity
	return bagLifeTime
end

return ConveyorUtil
