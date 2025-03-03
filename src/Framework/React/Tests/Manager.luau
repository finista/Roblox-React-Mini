local React = script.Parent.Parent
local test = require(React:WaitForChild("Test")).New()

local ReactManager = require(React)

test:CreateTest("ReactManager handles missing component update", function()
    local manager = ReactManager.New()
    local success, _ = pcall(function()
        manager:UpdateComponent(nil)
    end)
    assert(success == false, "ReactManager should error when updating a nil component")
end)

test:CreateTest("ReactManager initializes correctly", function()
    local manager = ReactManager.New()
    assert(manager.components ~= nil, "ReactManager should have a components table")
    assert(manager.state ~= nil, "ReactManager should have a state manager")
end)

test:CreateTest("ReactManager updates components", function()
    local manager = ReactManager.New()
    local component = { id = 1, render = function() end }
    manager.components[1] = component
    manager:UpdateComponent(component)
    assert(manager.components[1] == component, "ReactManager should update components correctly")
end)

return test.tests