local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Packages = Modules:WaitForChild("Packages")

local React = require(Packages.React)
local Cryo = require(Packages.Cryo)

export type props = {
	Texts: {
		[any]: any,
	},
}

local mapper: React_Component<props, any> = React.Component:extend("mapper")
local debugText = require(script.Parent.text)

mapper.defaultProps = {
	Texts = {},
}

function mapper:render()
	local props = self.props

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
