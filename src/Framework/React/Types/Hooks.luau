local reactTypes = require(script.Parent.ReactManager)

export type SetState<T> = (newState: T | (T) -> T) -> ()

export type HookTypes = {
    getManager: () -> (reactTypes.ReactManager),
    getCurrentComponent: () -> (reactTypes.ReactManager),
    useState: <T>(initialValue: T) -> (T, SetState<T>),
    useEffect: (callback: () -> (), dependencies: {any}) -> (),
    useRef: <T>(initial: T) -> (T),
    useStore: (sliceName: string) -> ({any}),
    useDispatch: (sliceName: string) -> (fn: (state: {any}) -> ({any})) -> (),
    useMount: (fn: () -> ()) -> (),
    useUnmount: (fn: () -> ()) -> ()
}

return {}