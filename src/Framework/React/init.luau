--!strict

local types = script.Types
local reactManagerTypes = require(types.ReactManager)

local util = require(script:WaitForChild("Util"))
local stateManager = require(script:WaitForChild("StateManager"))

local reactManager = {} :: reactManagerTypes.ReactManagerImpl
reactManager.__index = reactManager

function reactManager.New()
	local self = setmetatable({}, reactManager)
	
	self.state = stateManager.New(self)
	self.components = {}
	self.currentComponent = nil
	
	return self
end

function reactManager:RegisterComponent(componentFn, props)
	local component: reactManagerTypes.ComponentInst = {
		fn = componentFn,
		hasMounted = false,
		hookIndex = 0,
		props = props or {},
		hooks = {},
		subscribedSlices = {},
		prevChildren = {},
		stateManager = self.state,
		cleanup = function(self) end
	}
	
	component.cleanup = function(self)
		for sliceName, _ in pairs(self.subscribedSlices) do
			self.stateManager:Unsubscribe(sliceName, self)
		end
		
		for _, hook in pairs(self.hooks) do
			if typeof(hook) == "table" and hook.cleanup then
				hook.cleanup()
			end
		end

		self.subscribedSlices = {}
		if self.onUnmount then
			self.onUnmount()
		end
	end
	
	table.insert(self.components, component)
	self:UpdateComponent(component)
	
	return component
end

function reactManager:RemoveComponent(component)
	component:cleanup()
	
	local index = table.find(self.components, component)
	if index then
		table.remove(self.components, index)
	end
end

function reactManager:UpdateComponent(component, newProps)
	component.hookIndex = 0
	
	if util.deepEqual(component.props, newProps) then
		return
	end
	
	self.currentComponent = component
	
	local env = getfenv(component.fn)
	env.__react_manager = self
	setfenv(component.fn, env)

	local newChildren = component.fn(component.props) or {}

	if not component.hasMounted then
		if component.onMount then
			component.onMount()
		end

		component.hasMounted = true
	end

	self:DiffChildren(component, newChildren)
	
	self.currentComponent = nil
end

function reactManager:UpdateComponents()
	for _, component in ipairs(self.components) do
		self:UpdateComponent(component)
	end
end

function reactManager:DiffChildren(parent, newChildren)
	local prevChildren = parent.prevChildren
	
	for key, child in pairs(parent.prevChildren) do
		if not newChildren[key] then
			self:RemoveComponent(prevChildren[key])
			prevChildren[key] = nil
		end
	end
	
	parent.prevChildren = prevChildren
	
	for key, newChild in pairs(newChildren) do
		if not prevChildren[key] then
			prevChildren[key] = self:RegisterComponent(newChild[1], newChild[2])
		else
			local child = prevChildren[key]
			if child then
				self:UpdateComponent(child, newChild[2])
			end
		end
	end
end

return reactManager