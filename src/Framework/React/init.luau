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
	assert(typeof(componentFn) == "function", "Component must be a function.")

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
				util.safeExecute(hook.cleanup)
			end
		end

		self.subscribedSlices = {}
		if self.onUnmount then
			util.safeExecute(self.onUnmount)
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

	if newProps and util.deepEqual(component.props, newProps) then
		return
	end
	
	if newProps then
		component.props = newProps
	end
	
	self.currentComponent = component
	
	local env = getfenv(component.fn)
	env.__react_manager = self
	setfenv(component.fn, env)

	local success, data = pcall(component.fn, component.props)
	if not success then
		local componentName = debug.info(component.fn, "n") or "component"
		warn(`Failed to update {componentName}, error: {data or "No error given."}`)

		self.currentComponent = nil
		return 
	end

	local newChildren = data or {}

	if not component.hasMounted then
		if component.onMount then
			util.safeExecute(component.onMount)
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

function reactManager:VerifyChild(child)
	if typeof(child) ~= "table" then
		return false, "Child component must be a table!"
	end

	if typeof(child[1]) ~= "function" then
		return false, "Child[1] must be a component function."
	end

	return true
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
			local valid, error = self:VerifyChild(newChild)
			if not valid then
				warn(error)
				continue
			end

			prevChildren[key] = self:RegisterComponent(newChild[1], newChild[2])
		else
			local child = prevChildren[key]
			if child then
				self:UpdateComponent(child, newChild[2])
			end
		end
	end
end

function reactManager:RunTests()
	local testManager = require(script:WaitForChild("Test")).New()
	
	testManager:LoadTestsIn(script:WaitForChild("Tests"))
	testManager:RunTests()
end

return reactManager