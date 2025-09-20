-- I wrote my own UI output, I'm not a newbie like the people who use ACS
-- T10 Koles

-- github: https://github.com/RbxscrIptConnectinG/debuggerUI

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LogService = game:GetService("LogService")
local UserInputService = game:GetService("UserInputService")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Packages = Modules:WaitForChild("Packages")

local UIs = Modules:WaitForChild("UI")

local LocalPlayer = Players.LocalPlayer

local debuggerUIRoot, dispatch = require(UIs:WaitForChild("debugger"))(LocalPlayer.PlayerGui)

local randomTexts = require(script:WaitForChild("randomTexts"))

local function getLine(space: boolean)
	return `[{script:GetFullName()}:{debug.info(2, "l")}]` .. (space and " " or "")
end

--[[
		
			Allowed to edit data:
				Text = custom or "hi. i'm debug text!",
				TextSize = custom or 11,
				TextColor = custom or Color3.fromRGB(255, 255, 255),
				Font = custom or Enum.Font.Code,
				LifeTime = custom or 5,
				LayoutOrder = custom or 1,

			Questionable to edit data:
				_baseLifeTime = props.LifeTime or 5,
				_disappearingGoal = 0.3 <- (props.LifeTime / _static_LifeTime) -> _disappearing

			Unrecommended to edit data:
				_currentTick = tick(),
				_disappearing = false,
		
--]]

local function start()
	UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local basic = `{randomTexts[math.random(1, #randomTexts)]}: {dispatch:formatTable({
				hi = {
					this = randomTexts[math.random(1, #randomTexts)],
				},
				hello = {
					that = randomTexts[math.random(1, #randomTexts)],
				},
			})}\nhello there! {LocalPlayer.UserId}`
			dispatch:sendText({
				Text = basic,
			})
		end
	end)
end
start()
