-- I wrote my own UI output, I'm not a newbie like the people who use ACS
-- T10 Koles

-- github: https://github.com/RbxscrIptConnectinG/debuggerUI

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LogService = game:GetService("LogService")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local ServerLog = Remotes:WaitForChild("ServerLog")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local UIs = Modules:WaitForChild("UI")

local LocalPlayer = Players.LocalPlayer

local debugger, debuggerUIRoot = require(UIs:WaitForChild("debugger"))(LocalPlayer.PlayerGui)

local colors = {
	[Enum.MessageType.MessageOutput] = Color3.new(255, 255, 255),
	[Enum.MessageType.MessageError] = Color3.fromRGB(255, 68, 68),
	[Enum.MessageType.MessageInfo] = Color3.fromRGB(75, 163, 255),
	[Enum.MessageType.MessageWarning] = Color3.fromRGB(255, 142, 60),
}
local allowPrints = true
if allowPrints then
	LogService.MessageOut:Connect(function(message, messageType: Enum.MessageType)
		debugger:sendText({
			Text = message,
			TextColor = colors[messageType] or colors[Enum.MessageType.MessageOutput],
		})
	end)

	ServerLog.OnClientEvent:Connect(function(message, enumValue)
		debugger:sendText({
			Text = message,
			TextColor = colors[Enum.MessageType:FromValue(enumValue or 0)],
		})
	end)
end

--[[
		
			Allowed to edit data:
				Text = custom or "hi. i'm debug text!",
				TextSize = custom or 11,
				TextColor = custom or Color3.fromRGB(255, 255, 255),

				BackgroundTransparency = custom or 0.35

				Font = custom or Enum.Font.Code,
				LifeTime = custom or 10,
				Fade = custom or 0.5

		
--]]

--ye.

-- testing zone

local testing = false
if not testing then
	return
end
local UserInputService = game:GetService("UserInputService")

local randomTexts = require(script:WaitForChild("randomTexts"))

local function getLine(space: boolean)
	return `[{script:GetFullName()}:{debug.info(2, "l")}]` .. (space and " " or "")
end

local function start()
	UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local basic = `{randomTexts[math.random(1, #randomTexts)]}: {debugger:formatTable({
				hi = {
					this = randomTexts[math.random(1, #randomTexts)],
				},
				hello = {
					that = randomTexts[math.random(1, #randomTexts)],
				},
				randomNumber = math.random(-500, 500),
			})}\nhello there! {LocalPlayer.UserId}`
			debugger:sendText({
				Text = randomTexts[math.random(1, #randomTexts)],
			})
		end
	end)
end
start()
