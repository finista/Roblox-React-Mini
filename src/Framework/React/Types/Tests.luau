export type TestObj = {
    name: string,
    test: () -> (...any)
}

export type TestImpl = {
    __index: TestImpl,
    New: () -> (Test),
    CreateTest: (self: Test, name: string, fn: () -> (...any)) -> (),
    AddTestTable: (self: Test, table: {TestObj}) -> (),
    LoadTestsIn: (self: Test, inst: Instance) -> (),
    RunTests: (self: Test) -> ()
}

export type Test = typeof(setmetatable({} :: {
    tests: {TestObj}
}, {} :: TestImpl))

return {}