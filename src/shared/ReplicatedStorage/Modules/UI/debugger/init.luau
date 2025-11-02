local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Packages = Modules:WaitForChild("Packages")

local JSDOTLUA_SHARED = require(Packages:WaitForChild("JsDotLua-Shared"))
local React = require(Packages.React)
local ReactRoblox = require(Packages["React-roblox"])
local quickFormatter = require(script:WaitForChild("debugFormatter"))

local Store = require(script:WaitForChild("debugStore"))
local debugGui = require(script:WaitForChild("debugGui")) :: JSDOTLUA_SHARED.React_Component<any, any>
local debugText = require(script:WaitForChild("debugText")) :: JSDOTLUA_SHARED.React_Component<any, any>

return function(InitRoot: Instance)
	assert(InitRoot ~= nil, "you forgot about Root.")
	local screenUI = Instance.new("ScreenGui")
	screenUI.IgnoreGuiInset = true
	screenUI.ResetOnSpawn = false
	screenUI.Parent = InitRoot
	screenUI.Name = "debugUI"

	local root = ReactRoblox.createRoot(screenUI)

	local dispatch = {}

	dispatch.formatter = quickFormatter

	Store.changed:connect(function(newState, oldState)
		dispatch:render()
	end)

	-- turning table into string
	function dispatch:formatTable(...): ({ [any]: any }, string | nil) -> string -- quick
		return self.formatter:tableToString(...)
	end

	-- counts how many items in texts
	function dispatch:countTexts(): () -> number
		local number = 0
		for _, _ in pairs(Store:getState().Texts) do
			number += 1
		end
		return number
	end

	-- renders root
	function dispatch:render(onRender): (() -> ()) -> boolean
		local texts = {}
		for index, data in pairs(Store:getState().Texts) do
			texts[index] = React.createElement(debugText, data)
		end
		local success, output = pcall(
			root.render,
			root,
			React.createElement(debugGui, {
				Padding = {
					Top = UDim.new(0, 5),
					Bottom = UDim.new(0, 5),
					Right = UDim.new(0, 5),
					Left = UDim.new(0, 5),
				},
			}, texts)
		)
		if onRender ~= nil then
			onRender(success)
		end
		texts = nil
	end

	-- sends data to texts and renders it
	function dispatch:sendText(data): (
		{
			Text: string | any | nil,
			TextSize: number | nil,
			TextColor: Color3 | nil,
			BackgroundTransparency: number | nil,
			Font: Enum.Font | nil,
			LifeTime: number | nil,
			LayoutOrder: nil | number,
		} | nil
	) -> nil
		local currentTick = tick()
		data = data or {}
		data.creationTick = currentTick
		Store:dispatch({
			type = "AddText",
			Value = data,
		})
		task.delay((data.LifeTime or 10), function()
			Store:dispatch({
				type = "RemoveText",
				Value = data,
			})
		end)
	end

	dispatch:render() -- to init UI
	return root, dispatch
end
