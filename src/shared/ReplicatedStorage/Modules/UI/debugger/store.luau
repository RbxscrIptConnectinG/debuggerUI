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
		table.insert(newState.Texts, action.data)
		return newState
	end,
	RemoveText = function(state, action)
		local newState = state

		newState.Texts = Cryo.List.removeValue(newState.Texts, action.data)

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
