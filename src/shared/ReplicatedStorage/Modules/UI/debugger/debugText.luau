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
local Otter = require(Packages.Otter)

local debugText = React.Component:extend("debugText") :: JSDOTLUA_SHARED.React_Component<any, any>

type props = {
	[any]: any,

	Text: string,
	TextSize: number,
	TextColor: Color3,
	Font: Font,

	Position: UDim2,
	AnchorPoint: Vector2,

	BackgroundTransparency: number,

	LifeTime: number,

	Fade: number,

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
	Fade = 0.5,
}
function debugText:init(props: props, state)
	self.spentTime = 0
	self.state = {
		isAnimating = false,
	}
	self.animationBinding, self.animationBindingUpdate = React.createBinding(0)

	self.transparencyBinding = self.animationBinding:map(function(animation)
		return 1 * animation
	end)
	self.backgroundTransparencyBinding = self.animationBinding:map(function(animation)
		return props.BackgroundTransparency + math.max((animation - props.BackgroundTransparency), 0)
	end)

	self.motor = Otter.createSingleMotor(1)
	self.motor:onStep(function(value)
		self.animationBindingUpdate(value)
	end)
	self.motor:onComplete(function()
		self:setState({
			isAnimating = false,
		})
	end)
end

function debugText:render()
	local props = self.props :: props
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
			BackgroundTransparency = self.backgroundTransparencyBinding,
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
		key = tostring(props.creationTick), -- i'm new gen i'm new gen!!!
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
			TextTransparency = self.transparencyBinding,
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
	self.Updater = RunService.RenderStepped:Connect(function(deltaTime)
		self.spentTime += deltaTime
		if self.spentTime >= (props.LifeTime - props.Fade) then
			self.Updater:Disconnect()
			self.Updater = nil
			self.motor:setGoal(Otter.instant(0))
			self.motor:step(0)
			self.motor:setGoal(Otter.ease(1, {
				easingStyle = Enum.EasingStyle.Sine,
				duration = props.Fade,
			}))
			self.motor:start()
			self:setState({
				isAnimating = true,
			})
		end
	end)
end
function debugText:componentWillUnmount()
	if self.Updater ~= nil then
		self.Updater:Disconnect()
		self.Updater = nil
	end
	self.motor:destroy()
	self.animationBinding = nil
	self.animationBindingUpdate = nil

	self.transparencyBinding = nil
	self.backgroundTransparencyBinding = nil
end

return debugText
