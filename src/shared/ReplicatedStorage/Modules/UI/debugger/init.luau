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
local debugContainer = require(script:WaitForChild("debugContainer")) :: JSDOTLUA_SHARED.React_Component<any, any>

return function(InitRoot: Instance)
	assert(InitRoot ~= nil, "you forgot about Root.")
	local screenUI = Instance.new("ScreenGui")
	screenUI.IgnoreGuiInset = true
	screenUI.ResetOnSpawn = false
	screenUI.Parent = InitRoot
	screenUI.Name = "debugUI"

	local root = ReactRoblox.createRoot(screenUI)

	local debugger = {}

	debugger.formatter = quickFormatter

	-- turning table into string
	function debugger:formatTable(...): ({ [any]: any }, string | nil) -> string -- quick
		return self.formatter:tableToString(...)
	end

	-- renders root
	function debugger:render(): (() -> ()) -> boolean
		root:render(React.createElement(debugContainer, {
			store = Store,
		}, {
			Padding = React.createElement("UIPadding", {
				PaddingTop = UDim.new(0, 5),
				PaddingBottom = UDim.new(0, 5),
				PaddingRight = UDim.new(0, 5),
				PaddingLeft = UDim.new(0, 5),
			}),
			UIListLayout = React.createElement("UIListLayout", {
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Bottom,

				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
		}))
	end

	-- sends data to texts and renders it
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
		data.creationTick = tick()
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

	debugger:render() -- to init UI
	return debugger, root
end
