local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage.Modules
local Packages = Modules.Packages

local React = require(Packages.React)
local Cryo = require(Packages.Cryo)
export type props = {
	store: Rodux.Store,
	mapFunc: (value: any, key: any) -> (any, any),

	children: { [any]: any } | nil,
	key: string | nil,
	ref: any,
}
export type state = { [any]: any }
local Provider: React_Component<props, state> = React.Component:extend("Provider")

Provider.defaultProps = {}

function Provider:init(props: props)
	self.state = props.store:getState()

	self.connection = props.store.changed:connect(function(newState, oldState)
		self:setState(newState)
	end)
end

function Provider:render()
	local props: props = self.props
	local state = props.mapFunc ~= nil and Cryo.Dictionary.map(self.state, props.mapFunc) or self.state

	return Cryo.Dictionary.map(props.children, function(child, index)
		child.props = Cryo.Dictionary.join(child.props, state)
		return child, index
	end)
end

function Provider:componentWillUnmount()
	self.connection()
	self.connection = nil
end

return Provider
