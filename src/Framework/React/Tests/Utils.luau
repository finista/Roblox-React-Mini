local React = script.Parent.Parent
local test = require(React:WaitForChild("Test")).New()

local Util = require(React:WaitForChild("Util"))

test:CreateTest("deepEqual handles circular references", function()
    local table1 = {}
    table1.self = table1
    local table2 = {}
    table2.self = table2
    
    local success, _ = pcall(function()
        Util.deepEqual(table1, table2)
    end)
    assert(success == false, "deepEqual should handle circular references gracefully")
end)

return test.tests