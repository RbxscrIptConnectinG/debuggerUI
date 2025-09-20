local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Packages = Modules:WaitForChild("Packages")

local React = require(Packages:WaitForChild("react"))

local debugContainer = React.Component:extend("debugContainer")

local debugText = require(script.Parent:WaitForChild("debugText"))

function debugContainer:render()
	local children = {
		UIListLayout = React.createElement("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			Padding = UDim.new(0, 0), -- <- you can edit here
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		UIPadding = React.createElement("UIPadding", {
			PaddingBottom = UDim.new(0, 5),
			PaddingTop = UDim.new(0, 5),
			PaddingLeft = UDim.new(0, 5),
			PaddingRight = UDim.new(0, 5),
		}),
	}
	for i, v in pairs(self.props) do
		children[i] = React.createElement(debugText, v)
	end
	return React.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1,
	}, children)
end

return debugContainer
