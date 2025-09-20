local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Packages = Modules:WaitForChild("Packages")

local React = require(Packages:WaitForChild("react"))

local debugContainer = require(script.Parent:WaitForChild("debugContainer"))
local debugText = require(script.Parent:WaitForChild("debugText"))

local debuggerGui = React.Component:extend("debuggerGui")

function debuggerGui:init(props)
	self.props = props
end

function debuggerGui:render()
	return React.createElement(debugContainer, self.props)
end

return debuggerGui
