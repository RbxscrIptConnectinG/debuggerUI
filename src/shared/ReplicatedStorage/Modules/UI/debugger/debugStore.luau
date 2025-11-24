local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Packages = Modules:WaitForChild("Packages")

local Rodux = require(Packages.Rodux)
local Cryo = require(Packages.Cryo)

local reducer = Rodux.createReducer({
	Texts = {},
}, {
	AddText = function(state, action)
		local newState = state
		table.insert(newState.Texts, action.Value)
		return newState
	end,
	RemoveText = function(state, action)
		local newState = state
		for index, value in pairs(newState.Texts) do
			if Cryo.Dictionary.equals(value, action.Value) then
				newState.Texts[index] = nil
			end
		end
		return newState
	end,
})

local store: Rodux.Store & {
	getState: (self: Rodux.Store) -> {
		Texts: {
			[any]: any,
		},
	},
} =
	Rodux.Store.new(reducer, nil)

return store
