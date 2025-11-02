-- generic text

local Camera = workspace.CurrentCamera
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Packages = Modules:WaitForChild("Packages")

local JSDOTLUA_SHARED = require(Packages:WaitForChild("JsDotLua-Shared"))
local React = require(Packages.React)

local debugText = React.Component:extend("debugText") :: JSDOTLUA_SHARED.React_Component<any, any>

type props = {
	[any]: any,

	Text: string,
	TextSize: number,
	TextColor: Color3,
	Font: Font,

	Position: UDim2,
	AnchorPoint: Vector2,

	Transparency: number,
	BackgroundTransparency: number,

	LifeTime: number,

	UpdateRate: number,
	LastUpdate: number,
	FadeGoal: number,

	creationTick: number,

	children: { [any]: JSDOTLUA_SHARED.React_Element<any> } | nil,
}
debugText.defaultProps = {
	Text = "TESTING-TESTING-TESTING",
	TextSize = 14,
	TextColor = Color3.fromRGB(255, 255, 255),
	Font = Enum.Font.Code,

	Position = UDim2.new(),
	AnchorPoint = Vector2.zero,

	BackgroundTransparency = 0.35,

	LifeTime = 10,
	FadeGoal = 0.1,

	UpdateRate = 1 / 60,

	creationTick = tick(),
}
function debugText:init(props: props, state)
	--

	self.props.BaseLifeTime = props.LifeTime
	self.props.LifeTime = props.creationTick + props.LifeTime
	self.LastUpdate = props.creationTick + props.UpdateRate
	self:setState({
		Transparency = 0,
	})
end

function debugText:render()
	local props = self.props :: props
	local state = self.state
	local viewSize = Vector2.new(math.huge, math.huge)
	local textSizeDetails = TextService:GetTextSize(props.Text, props.TextSize, props.Font, viewSize)

	local lines = {}
	for line in props.Text:gmatch("([^\n]*)\n?") do
		if line ~= "" then
			table.insert(lines, line)
		end
	end
	local backgrounds = {}
	local totalYSize = 0
	for i, line in ipairs(lines) do
		local size = TextService:GetTextSize(line, props.TextSize, props.Font, viewSize)
		totalYSize += math.ceil(size.Y)
		backgrounds[i] = React.createElement("Frame", {
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			BackgroundTransparency = props.BackgroundTransparency
				+ math.max((state.Transparency - props.BackgroundTransparency), 0),
			Size = UDim2.new(0, size.X, 0, math.ceil(size.Y)),
			LayoutOrder = i,
			ZIndex = -5,
		})
	end
	return React.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0, textSizeDetails.X, 0, totalYSize),
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
	}, {
		TextLabel = React.createElement("TextLabel", {
			BackgroundTransparency = 1,
			Text = props.Text,
			TextSize = props.TextSize,
			LineHeight = 1,
			RichText = false,
			FontFace = Font.fromEnum(props.Font),
			TextColor3 = props.TextColor,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = true,
			Size = UDim2.new(1, 0, 1, 0),
			TextTransparency = state.Transparency,
		}, {
			UIListLayout = React.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
		}, backgrounds),
	})
end

function debugText:componentDidMount()
	local props = self.props :: props
	local state = self.state
	props.Updater = RunService.RenderStepped:Connect(function(deltaTime)
		if tick() >= self.LastUpdate then
			local currentTick = tick()
			self.LastUpdate = currentTick + props.UpdateRate

			local goal = math.max((props.LifeTime - currentTick) / props.BaseLifeTime, 0)
			local disappearingNow = goal <= props.FadeGoal

			if disappearingNow then
				self:setState(function(stats)
					stats.Transparency = math.min(
						(1 - math.max((props.LifeTime - currentTick) / props.BaseLifeTime, 0) / props.FadeGoal),
						1
					)
					return stats
				end)
			end
		end
	end)
end
function debugText:componentWillUnmount()
	local props = self.props :: props
	if props.Updater ~= nil then
		props.Updater:Disconnect()
		props.Updater = nil
	end
end

return debugText
