-- generic text

local Camera = workspace.CurrentCamera
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Packages = Modules:WaitForChild("Packages")

local React = require(Packages:WaitForChild("react"))

local debugText = React.Component:extend("debugText")
local defaultFont = Enum.Font.Code

debugText.lastUpdate = tick()

function debugText:init(props)
	self.updater = nil

	self:setState({
		Text = props.Text or "hi. i'm debug text!",
		TextSize = props.TextSize or 11,
		TextColor = props.TextColor or Color3.fromRGB(255, 255, 255),
		Font = props.Font or defaultFont,
		LifeTime = tick() + (props.LifeTime or 10),
		LayoutOrder = props.LayoutOrder or 1,

		-- DO NOT EDIT
		_baseLifeTime = props.LifeTime or 10,
		_disappearing = false,
		_disappearingGoal = props._disappearingGoal or 0.01,

		_updateRate = 1 / 60,
	})
end

function debugText:render()
	local currentTick = tick()
	local viewSize = Vector2.new(math.huge, math.huge)
	local textSizeDetails = TextService:GetTextSize(self.state.Text, self.state.TextSize, self.state.Font, viewSize)

	local lines = {}
	for line in self.state.Text:gmatch("([^\n]*)\n?") do
		if line ~= "" then
			table.insert(lines, line)
		end
	end

	local Transparency = math.min(
		self.state._disappearing
				and (1 - math.max((self.state.LifeTime - currentTick) / self.state._baseLifeTime, 0) / self.state._disappearingGoal)
			or 0,
		1
	)
	if Transparency >= 1 then
		return nil
	end
	local backgrounds = {}
	local totalYSize = 0
	for i, line in ipairs(lines) do
		local size = TextService:GetTextSize(line, self.state.TextSize, self.state.Font, viewSize)
		totalYSize += math.ceil(size.Y)
		backgrounds[i] = React.createElement("Frame", {
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			BackgroundTransparency = 0.3 + Transparency,
			Size = UDim2.new(0, size.X, 0, math.ceil(size.Y)),
			LayoutOrder = i,
			ZIndex = -5,
		})
	end
	return React.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0, textSizeDetails.X, 0, totalYSize),
		LayoutOrder = self.state.LayoutOrder,
		AnchorPoint = Vector2.new(0, 1),
	}, {
		TextLabel = React.createElement("TextLabel", {
			BackgroundTransparency = 1,
			Text = self.state.Text,
			TextSize = self.state.TextSize,
			LineHeight = 1,
			RichText = false,
			FontFace = Font.fromEnum(self.state.Font),
			TextColor3 = self.state.TextColor,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = true,
			Size = UDim2.new(1, 0, 1, 0),
			TextTransparency = Transparency,
		}, {
			UIListLayout = React.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			unpack(backgrounds),
		}),
	})
end

function debugText:didMount()
	if self.state.LifeTime == math.huge then
		return
	end

	self.updater = RunService.RenderStepped:Connect(function(dt)
		if self == nil then
			self.updater:Disconnect()
			return
		end
		local currentTick = tick()
		if tick() >= self.lastUpdate then
			self.lastUpdate = currentTick + self.state._updateRate
			local goal = math.max((self.state.LifeTime - currentTick) / self.state._baseLifeTime, 0)
			local disappearingNow = goal <= self.state._disappearingGoal
			if disappearingNow then
				self:setState(function(state)
					return {
						_disappearing = disappearingNow,
					}
				end)
			end
			if goal <= 0 then
				self.updater:Disconnect()
			end
		end
	end)
end
function debugText:willUnmount()
	if self.updater ~= nil then
		self.updater:Disconnect()
		self.updater = nil
	end
end

return debugText
