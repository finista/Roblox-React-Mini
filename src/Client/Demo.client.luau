local player = game:GetService("Players").LocalPlayer
local createUI = require("./CreateUI")

local UI = createUI()

local React = game.ReplicatedStorage:WaitForChild("React")
local Hooks = require(React:WaitForChild("Hooks"))

local root = require(React).New()

function App()
    local slice = Hooks.useStore("counter")

    if slice.amount >= 10 then
        return {
            counter = {Counter},
            resetButton = {ResetButton}
        }
    end

    return {
        counter = {Counter},
        addButton = {AddButton},
        resetButton = {ResetButton}
    }
end

function AddButton()
    local button = UI.addButton

	local dispatch = Hooks.useDispatch("counter")
	local invertColor, setInvertColor = Hooks.useState(false)

	Hooks.useMount(function()
		button.Visible = true
	end)

	Hooks.useUnmount(function()
		button.Visible = false
	end)

	Hooks.useEffect(function()
		local conn = button.MouseButton1Click:Connect(function()
			dispatch(function(state)
				return {
					amount = state.amount + 1
				}
			end)

			setInvertColor(function(state)
				return not state
			end)
		end)

		return function()
			conn:Disconnect()
		end
	end, {})

	if invertColor then
		button.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	else
		button.BackgroundColor3 = Color3.fromRGB(94, 95, 104)
	end
end

function ResetButton()
	local dispatch = Hooks.useDispatch("counter")

	Hooks.useEffect(function()
		local conn = UI.resetButton.MouseButton1Click:Connect(function()
			dispatch(function(state)
				return {
					amount = 0
				}
			end)
		end)

		return function()
			conn:Disconnect()
		end
	end, {})
end

function Counter()
    local countSlice = Hooks.useStore("counter")

	Hooks.useEffect(function()
		UI.counter.Text = `Current clicks: {countSlice.amount}`	
	end, {countSlice.amount})
end

UI.UI.Parent = player:WaitForChild("PlayerGui")

root.state:CreateSlice(
    "counter",
    { amount = 0 }
)
root:RegisterComponent(App, {})