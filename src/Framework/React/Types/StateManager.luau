export type Slice = {
	subscribers: {any},
	state: any
}

export type StateManagerImpl = {
	__index: StateManagerImpl,
	New: (manager: any) -> (StateManager),
	GetSlice: (self: StateManager, sliceName: string) -> (Slice),
	CreateSlice: (self: StateManager, sliceName: string, initialState: any) -> (),
	Subscribe: (self: StateManager, sliceName: string, component: any) -> (),
	Unsubscribe: (self: StateManager, sliceName: string, component: any) -> (),
	Set: (self: StateManager, sliceName: string, state: any) -> (),
	Notify: (self: StateManager, sliceName: string) -> ()
}

export type StateManager = typeof(setmetatable({} :: {
	slices: {[string]: Slice},
	manager: any
}, {} :: StateManagerImpl))

return {}