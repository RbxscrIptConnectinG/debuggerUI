local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Packages = Modules:WaitForChild("Packages")

local React = require(Packages:WaitForChild("react"))
local ReactRoblox = require(Packages:WaitForChild("react-roblox"))
local quickFormatter = require(script:WaitForChild("debugFormatter"))

--local Store = require(script:WaitForChild("debugStore"))
local debugGui = require(script:WaitForChild("debugGui"))

return function(InitRoot: Instance)
	assert(InitRoot ~= nil, "you forgot about Root.")
	local screenUI = Instance.new("ScreenGui")
	screenUI.IgnoreGuiInset = true
	screenUI.ResetOnSpawn = false
	screenUI.Parent = InitRoot
	screenUI.Name = "debugUI"

	local root = ReactRoblox.createRoot(screenUI)

	local dispatch = {
		tagSystem = "Tick", -- | "numbers" | "GenerateGUID" (VERY VERY LOW CHANCE OF DUPLICATE) | "Tick" (low chance of stuff having same tick. maybe.)
		currentTag = 0,
		renderAfterRemoving = true, -- could be buggy if set to true, but i'm not really sure. try it yourself

		texts = {},
	}

	dispatch.formatter = quickFormatter

	-- turning table into string
	function dispatch:formatTable(...): ({ [any]: any }, string | nil) -> string -- quick
		return self.formatter:tableToString(...)
	end

	-- counts how many items in texts
	function dispatch:countTexts(): () -> number
		local number = 0
		for _, _ in pairs(self.texts) do
			number += 1
		end
		return number
	end

	-- renders root
	function dispatch:render(): () -> nil
		root:render(React.createElement(debugGui, self.texts, nil))
	end

	-- sends data to texts and then renders it
	function dispatch:sendText(data): (
		{
			Text: string | any | nil,
			TextSize: number | nil,
			TextColor: Color3 | nil,
			Font: Enum.Font | nil,
			LifeTime: number | nil,
			LayoutOrder: nil | number, -- (questionable actually.)

			_disappearingGoal: nil | number,
			_baseLifeTime: nil | number,
		} | nil
	) -> nil
		data = data or {}
		self.currentTag = self.tagSystem == "numbers" and self.currentTag + 1 -- classic
			or self.tagSystem == "GenerateGUID" and `{self:countTexts() + 1}-{HttpService:GenerateGUID(false)}`
			or self.tagSystem == "Tick" and tick() / 4294967296 -- dividing with 32 bit. once humanity will reach tick beyond 64 bit, this is what still be standing and working for a bit more time (maybe)
			or `SelectAProperTagSystem-{math.random(-255, 255)}` -- wrong input for tagSystem
		data._endTick = tick() + (data.LifeTime or 5) + (1 / 60) -- additional frame time
		self.texts[tostring(self.currentTag)] = data -- simple as that.
		self:render() -- throw that in oven and bake it
	end

	-- deleter. could be more optimized tho.
	RunService:BindToRenderStep(
		`{HttpService:GenerateGUID(false)}-debuggerUI-updater`,
		Enum.RenderPriority.First.Value,
		function(dt)
			for index, value in pairs(dispatch.texts) do
				if tick() >= value._endTick then
					dispatch.texts[index] = nil
					if dispatch.renderAfterRemoving then
						dispatch:render()
					end
				end
			end
		end
	)
	dispatch:render() -- to init UI
	return root, dispatch
end
