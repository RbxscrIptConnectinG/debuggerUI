local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Packages = Modules:WaitForChild("Packages")

local React = require(Packages.React)

local debugContainer = require(script.Parent:WaitForChild("debugContainer"))
local debugText = require(script.Parent:WaitForChild("debugText"))

local debuggerGui = React.Component:extend("debuggerGui")

function debuggerGui:init(props) end

-- and why i created this?

debuggerGui.defaultProps = {
	ListPadding = UDim.new(0, 0),
}

function debuggerGui:render()
	return React.createElement(debugContainer, self.props, self.props.children, {
		UIListLayout = React.createElement("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			Padding = self.props.ListPadding,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
end

return debuggerGui
