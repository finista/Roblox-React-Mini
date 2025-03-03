local React = script.Parent.Parent
local test = require(React:WaitForChild("Test")).New()

local Hooks = require(React:WaitForChild("Hooks"))
local StateManager = require(React:WaitForChild("StateManager"))

test:CreateTest("useState initializes correctly", function()
    local manager = { UpdateComponent = function() end, currentComponent = { hookIndex = 0, hooks = {} } }
    getfenv(1).__react_manager = manager

    local state, setState = Hooks.useState(10)
    assert(state == 10, "useState should initialize with provided value")
    setState(20)
    assert(manager.currentComponent.hooks[1] == 20, "useState should update value")
end)

test:CreateTest("useState handles nil initial value", function()
    local manager = { UpdateComponent = function() end, currentComponent = { hookIndex = 0, hooks = {} } }
    getfenv(1).__react_manager = manager

    local state, setState = Hooks.useState(nil)
    assert(state == nil, "useState should allow nil initial value")
    setState(5)
    assert(manager.currentComponent.hooks[1] == 5, "useState should update from nil to value")
end)

test:CreateTest("useEffect does not run if dependencies do not change", function()
    local manager = { UpdateComponent = function() end, currentComponent = { hookIndex = 0, hooks = {{1}} } }
    getfenv(1).__react_manager = manager

    local effectRun = false
    Hooks.useEffect(function()
        effectRun = true
    end, {1})

    assert(effectRun == false, "useEffect should not run if dependencies remain unchanged")
end)

test:CreateTest("useStore fails on missing slice", function()
    local manager = {
        state = StateManager.New({ UpdateComponent = function() end }),
        UpdateComponent = function() end,
        currentComponent = { hookIndex = 0, hooks = {} }
    }
    getfenv(1).__react_manager = manager

    local success, _ = pcall(function()
        Hooks.useStore("nonExistentSlice")
    end)
    assert(success == false, "useStore should error on missing slice")
end)

return test.tests