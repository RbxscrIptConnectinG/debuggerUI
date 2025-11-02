local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LogService = game:GetService("LogService")
local RunService = game:GetService("RunService")
local Remotes = ReplicatedStorage.Remotes
local ServerLog = Remotes.ServerLog

LogService.MessageOut:Connect(function(message, messageType: Enum.MessageType)
	if RunService:IsStudio() then
		return
	end -- server logs and client logs are merged together in studio
	ServerLog:FireAllClients(message, messageType.Value)
end)
