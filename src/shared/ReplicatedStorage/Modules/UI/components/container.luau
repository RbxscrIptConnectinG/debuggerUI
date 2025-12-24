local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Packages = Modules:WaitForChild("Packages")

local React = require(Packages.React)

export type props = {
	Size: UDim2 | nil,
	AnchorPoint: Vector2 | nil,
	Position: UDim2 | nil,
	Padding: {
		Top: UDim | nil,
		Bottom: UDim | nil,
		Left: UDim | nil,
		Right: UDim | nil,
	} | nil,
	children: { [any]: any } | nil,
}

local Container: React_Component<props, any> = React.Component:extend("Container")

Container.defaultProps = {
	Size = UDim2.fromScale(1, 1),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),

	Padding = {
		Top = UDim.new(0, 0),
		Bottom = UDim.new(0, 0),
		Right = UDim.new(0, 0),
		Left = UDim.new(0, 0),
	},
}

function Container:render()
	local props: props = self.props
	return React.createElement("Frame", {
		Size = props.Size or UDim2.fromScale(1, 1),
		BorderSizePixel = 0,
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,
		Transparency = 1,
	}, {
		__Padding = React.createElement("UIPadding", {
			PaddingTop = props.Padding.Top,
			PaddingBottom = props.Padding.Bottom,

			PaddingLeft = props.Padding.Left,
			PaddingRight = props.Padding.Right,
		}),
	}, props.children)
end

return Container
