local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage.Modules
local Packages = Modules.Packages

local JSDOTLUA_SHARED = require(Packages["JsDotLua-Shared"])
local React = require(Packages.React)
local Cryo = require(Packages.Cryo)

local Provider: JSDOTLUA_SHARED.React_ComponentType<any> = React.Component:extend("Provider")

export type Props = {
	store: Rodux.Store,
	mapFunc: (value: any, key: any) -> (any, any),

	children: { [any]: JSDOTLUA_SHARED.React_Element<any> } | nil,
	key: string | nil,
	ref: any,
}

Provider.defaultProps = {}

function Provider:init(props: Props)
	self.state = props.store:getState()

	self.connection = props.store.changed:connect(function(newState, oldState)
		self:setState(newState)
	end)
end

function Provider:render()
	local props: Props = self.props
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
