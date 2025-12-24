local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Packages = Modules:WaitForChild("Packages")

local React = require(Packages.React)
local ReactRoblox = require(Packages["React-roblox"])
local quickFormatter = require(script.formatter)

local components = script.Parent.components

local container = require(components.container) :: any
local RoduxProvider = require(components.RoduxProvider)
local Mapper = require(script.mapper)

local _64BIT = 2 ^ 64

return function(InitRoot: Instance)
	assert(InitRoot ~= nil, "you forgot about Root.")
	local screenUI = Instance.new("ScreenGui")
	screenUI.IgnoreGuiInset = true
	screenUI.ResetOnSpawn = false
	screenUI.Parent = InitRoot
	screenUI.Name = "debugUI"

	local root = ReactRoblox.createRoot(screenUI)

	local debugger = {}
	debugger.STORE = require(script.store)

	debugger.formatter = quickFormatter

	-- turning table into string
	function debugger:formatTable(...): ({ [any]: any }, string | nil) -> string -- quick maybe.
		return self.formatter:tableToString(...)
	end

	-- renders root
	function debugger:render(): boolean
		root:render(React.createElement(container, {
			Padding = {
				Top = UDim.new(0, 5),
				Bottom = UDim.new(0, 5),
				Right = UDim.new(0, 5),
				Left = UDim.new(0, 5),
			},
		}, {
			React.createElement(RoduxProvider, {
				store = self.STORE,
			}, {
				mapper = React.createElement(Mapper),
			}),
			UIListLayout = React.createElement("UIListLayout", {
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Bottom,

				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
		}))
	end

	-- sends data to store
	function debugger:sendText(data): (
		{
			Text: string | any | nil,
			TextSize: number | nil,
			TextColor: Color3 | nil,
			BackgroundTransparency: number | nil,

			Font: Enum.Font | nil,
			LifeTime: number | nil,
			Fade: nil | number,
		} | nil
	) -> nil
		data = data or {}
		data.id = tostring(tick() / _64BIT)
		self.STORE:dispatch({
			type = "AddText",
			data = data,
		})
		task.delay(data.LifeTime or 10, function()
			self.STORE:dispatch({
				type = "RemoveText",
				data = data,
			})
		end)
	end

	debugger:render() -- to init UI
	return debugger, root
end
