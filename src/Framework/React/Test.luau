--!strict
local types = require(script.Parent.Types.Tests)

local test = {} :: types.TestImpl
test.__index = test

function test.New()
    local self = setmetatable({}, test)
    self.tests = {}
    return self
end

function test:CreateTest(name, fn)
    table.insert(self.tests, {
        test = fn,
        name = `{script.Name}/{name or "Test"}` 
    })
end

function test:AddTestTable(tests)
    for _, test: types.TestObj in ipairs(tests) do
        if not test.test or not test.name then
            print("Did not register a test because the name or test function is missing.")
            continue
        end

        table.insert(self.tests, test)
    end
end

function test:LoadTestsIn(inst)
    for _, obj in ipairs(inst:GetChildren()) do
        if not obj:IsA("ModuleScript") then
            continue
        end

        local success, data = pcall(function() 
            return require(obj) :: any
        end)

        if not success then
            warn(`Failed to load {obj.Name}, error: {data or "No error given."}`)
            continue
        end

        if typeof(data) ~= "table" then
            warn(`{obj.Name} did not return a table.`)
            continue
        end

        self:AddTestTable(data)
    end
end

function test:RunTests()
    if #self.tests <= 0 then
        warn("No tests detected.")
        return
    end

    local result = {
        passed = 0,
        failed = 0
    }

    print(`Running tests, detected {#self.tests}.`)

    for _, test in ipairs(self.tests) do
        local start = tick()

        local success, data = pcall(test.test)
        if not success then
            warn(`Test {test.name} failed: {data or "No error given."} ({tick() - start}s)`)
            result.failed += 1
        else
            print(`Test {test.name} passed. ({tick() - start}s)`)
            result.passed += 1
        end
    end

    if result.failed ~= 0 then
        print(`Finished running tests, {result.passed} passed, {result.failed} failed.`)
        return
    end

    print(`All tests passed.`)
end

return test