local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Packages = Modules:WaitForChild("Packages")

local JSDOTLUA_SHARED = require(Packages:WaitForChild("JsDotLua-Shared"))
local React = require(Packages.React)
local Cryo = require(Packages.Cryo)

local Container = React.Component:extend("Container") :: JSDOTLUA_SHARED.React_Component<any, any>
local DebugText = require(script.Parent:WaitForChild("debugText"))

export type containerProps = {
	Size: UDim2 | nil,
	AnchorPoint: Vector2 | nil,
	Position: UDim2 | nil,
	store: Rodux.Store,
	Padding: {
		Top: UDim | nil,
		Bottom: UDim | nil,
		Left: UDim | nil,
		Right: UDim | nil,
	} | nil,
	children: { [any]: JSDOTLUA_SHARED.React_Element<any> } | nil,
}

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

function Container:init(props: containerProps, state)
	self.state = {
		Texts = {},
	}
end

function Container:render()
	local props: containerProps = self.props
	local state = self.state
	return React.createElement("Frame", {
		Size = props.ContainerSize or UDim2.fromScale(1, 1),
		BorderSizePixel = 0,
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,
		Transparency = 1,
	}, state.Texts, props.children)
end

function Container:componentDidMount()
	local props = self.props
	self.connection = props.store.changed:connect(function(newState, oldState)
		local reactElements = {}
		for i, v in pairs(newState.Texts) do
			reactElements[i] = React.createElement(DebugText, v)
		end
		self:setState({
			Texts = reactElements,
		})

		reactElements = nil
	end)
end
function Container:componentWillUnmount()
	self.connection.disconnect()
	self.connection = nil
end

return Container
