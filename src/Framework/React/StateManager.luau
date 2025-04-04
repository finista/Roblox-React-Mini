--!strict
local types = require(script.Parent.Types.StateManager)
local util = require(script.Parent.Util)

local stateManager = {} :: types.StateManagerImpl
stateManager.__index = stateManager

function stateManager.New(manager)
	local self = setmetatable({}, stateManager)
	
	self.slices = {}
	self.manager = manager

	return self
end

function stateManager:GetSlice(sliceName)
	local slice = self.slices[sliceName]
	assert(slice, `Slice {sliceName} does not exist!`)
	
	return slice
end

function stateManager:CreateSlice(sliceName, initialState)
	local slice = {
		subscribers = {},
		state = initialState or {}
	}
	
	self.slices[sliceName] = slice
end

function stateManager:Subscribe(sliceName, component)
	local slice = self:GetSlice(sliceName)
	if table.find(slice.subscribers, component) then
		return
	end
	
	table.insert(self:GetSlice(sliceName).subscribers, component)
end

function stateManager:Unsubscribe(sliceName, component)
	local slice = self:GetSlice(sliceName)
	
	for i, subscriber in ipairs(slice.subscribers) do
		if subscriber == component then
			table.remove(slice.subscribers, i)
			break
		end
	end
end

function stateManager:Set(sliceName, state)
	local slice = self:GetSlice(sliceName)

	if util.deepEqual(slice.state, state) then
		return
	end
	
	slice.state = state
	self:Notify(sliceName)
end

function stateManager:Notify(sliceName)
	local slice = self:GetSlice(sliceName)

	for _, component in ipairs(slice.subscribers) do
		self.manager:UpdateComponent(component)
	end
end

return stateManager
