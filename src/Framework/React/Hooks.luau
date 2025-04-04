--!strict
local types = script.Parent.Types
local reactTypes = require(types.ReactManager)
local util = require(script.Parent.Util)

local Hooks = {}

function getManager(): (reactTypes.ReactManager)
	local level = 1
	local manager

	while true do
		local env = getfenv(level)
		if not env then break end 

		manager = env.__react_manager
		if manager then break end

		level += 1
	end

	assert(manager, "Cannot use hooks outside of component context!")
	return manager
end

function getCurrentComponent(manager: reactTypes.ReactManager)
	local component = manager.currentComponent
	assert(component, "Hook failed to find current component reference.")
		
	return component
end

function Hooks.useState(initialValue: any): (any, (state: any & (data: any) -> (any)) -> ())
	local manager = getManager()
	local component = getCurrentComponent(manager)
	component.hookIndex += 1
	local index = component.hookIndex
		
	if component.hooks[index] == nil then
		component.hooks[index] = initialValue
	end
		
	local function setState(data: any & (data: any) -> (any))
		if typeof(data) == "function" then
			component.hooks[index] = data(component.hooks[index])
		else
			component.hooks[index] = data
		end
			
		manager:UpdateComponent(component)
	end
		
	return component.hooks[index], setState
end

function Hooks.useEffect(callback: () -> (), dependencies: {any})
	local manager = getManager()
	local component = getCurrentComponent(manager)
	component.hookIndex += 1
		
	local index = component.hookIndex
	local hook = component.hooks[index]
		
	local shouldRun = false
	if hook == nil then
		shouldRun = true
	else
		for i, dep in ipairs(dependencies) do
			if hook[i] ~= dep then
				shouldRun = true
				break
			end
		end
	end
		
	if shouldRun then
		if hook and hook.cleanup then
			hook.cleanup()
		end
			
		local newHook = { unpack(dependencies) }
		component.hooks[index] = newHook
			
		task.defer(function()
			component.hooks[index].cleanup = callback()
		end)
	end
end

function Hooks.useRef(initialValue: any)
	local manager = getManager()
	local component = getCurrentComponent(manager)
	component.hookIndex += 1
	local index = component.hookIndex

	if component.hooks[index] == nil then
		component.hooks[index] = { current = initialValue }
	end

	return component.hooks[index]
end

function Hooks.useStore(sliceName: string)
	local manager = getManager()
	local component = getCurrentComponent(manager)
	local stateManager = manager.state
	
	stateManager:Subscribe(sliceName, component)
	
	return stateManager:GetSlice(sliceName).state
end

function Hooks.useDispatch(sliceName: string)
	local manager = getManager()
	local stateManager = manager.state
	
	local function dispatch(fn: (state: any) -> (any))
		local slice = stateManager:GetSlice(sliceName)
		local updatedState = fn(table.clone(slice.state))
		
		assert(updatedState ~= nil, "Dispatch function returned nil as a state.")
		
		stateManager:Set(sliceName, updatedState)
	end
	
	return dispatch
end

function Hooks.useMount(fn: () -> ())
	local manager = getManager()
	local component = getCurrentComponent(manager)
	
	if component.onMount then
		return
	end
	component.onMount = fn
end

function Hooks.useUnmount(fn: () -> ())
	local manager = getManager()
	local component = getCurrentComponent(manager)

	if component.onUnmount then 
		return 
	end
	
	component.onUnmount = fn
end

return Hooks