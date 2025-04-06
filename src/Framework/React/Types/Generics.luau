export type ComponentChildren = {[string]: ComponentChild}
export type ComponentChild = typeof({ function() end :: any, {} :: {any} })
export type Component<P> = (P) -> ComponentChildren

return {}