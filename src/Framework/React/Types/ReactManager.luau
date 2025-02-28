local stateTypes = require(script.Parent.StateManager)

export type ComponentInst = {
	fn: any,
	props: {any},
	hooks: {any},
	hookIndex: number,
	prevChildren: {[string]: ComponentInst},
	subscribedSlices: {string},
	stateManager: any,
	hasMounted: boolean,
	cleanup: ((self: ComponentInst) -> ()),
	onMount: (() -> ())?,
	onUnmount: (() -> ())?
}

export type ReactManagerImpl = {
	__index: ReactManagerImpl,
	New: () -> (ReactManager),
	RegisterComponent: (self: ReactManager, componentFn: any, props: {any}?) -> (ComponentInst),
	RemoveComponent: (self: ReactManager, component: ComponentInst) -> (),
	UpdateComponent: (self: ReactManager, component: ComponentInst, newProps: {any}?) -> (),
	UpdateComponents: (self: ReactManager) -> (),
	VerifyChild: (self: ReactManager, child: {any}) -> (boolean, string?),
	DiffChildren: (self: ReactManager, component: ComponentInst, newChildren: {[string]: {any}}) -> (),
}

export type ReactManager = typeof(setmetatable({} :: {
	state: stateTypes.StateManager,
	components: {ComponentInst},
	currentComponent: ComponentInst?
}, {} :: ReactManagerImpl))

return {}