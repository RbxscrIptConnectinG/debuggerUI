local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Packages = Modules:WaitForChild("Packages")

local JSDOTLUA_SHARED = require(Packages:WaitForChild("JsDotLua-Shared"))
local React = require(Packages.React)
local Cryo = require(Packages.Cryo)

local mapper = React.Component:extend("mapper") :: JSDOTLUA_SHARED.React_Component<any, any>
local debugText = require(script.Parent.text)

export type props = {
	Texts: {
		[any]: any,
	},
}

mapper.defaultProps = {
	Texts = {},
}

function mapper:render()
	local props: props = self.props

	return Cryo.List.map(props.Texts, function(value, key)
		return React.createElement(
			debugText,
			Cryo.Dictionary.join(value, {
				key = tostring(value.id),
			})
		)
	end)
end

return mapper
