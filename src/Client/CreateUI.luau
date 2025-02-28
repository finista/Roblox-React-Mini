--!strict

return function()
    local function _create_image(imageId: string, position: UDim2, parent: Instance)
        local image = Instance.new("ImageLabel")

        image.Image = imageId
        image.Position = position
        image.Parent = parent
        
        image.ScaleType = Enum.ScaleType.Fit
        image.Size = UDim2.new(0.094, 0, 0.166, 0)
        image.BackgroundTransparency = 1

        return image
    end

    local function _create_button(text, position, parent)
        local button = Instance.new("TextButton")

        local uiCorner = Instance.new("UICorner", button)
        local uiStroke = Instance.new("UIStroke", button)

        button.Parent = parent
        button.Position = position
        button.Text = text

        button.Size = UDim2.new(0.178, 0, 0.07, 0)
        button.BackgroundColor3 = Color3.fromRGB(94, 95, 104)
        button.TextScaled = true
        button.TextColor3 = Color3.fromRGB(255, 255, 255)

        uiCorner.CornerRadius = UDim.new(0, 8)

        uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        uiStroke.Color = Color3.fromRGB(64, 63, 70)
        uiStroke.Thickness = 3

        return button
    end

    local function _create_label(text, parent, position, size)
        local label = Instance.new("TextLabel")

        label.Text = text
        label.Parent = parent
        label.Position = position
        label.Size = size

        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Font = Enum.Font.Ubuntu
        label.TextScaled = true

        return label
    end

    local UI = Instance.new("ScreenGui")
    local background = Instance.new("Frame", UI)

    local titleLabel = _create_label("Roblox-React Demo", background, UDim2.new(0.327, 0, 0.108, 0), UDim2.new(0.346, 0,0.078, 0))
    local counterLabel = _create_label("Current clicks: 0", background, UDim2.new(0.327, 0, 0.538, 0), UDim2.new(0.346, 0, 0.058, 0))

    local addButton = _create_button("Add count", UDim2.new(0.314, 0, 0.615, 0), background)
    local resetButton = _create_button("Reset", UDim2.new(0.508, 0, 0.615, 0), background)
    
    UI.IgnoreGuiInset = true

    background.Size = UDim2.new(1, 0, 1, 0)
    background.Position = UDim2.new(0, 0, 0, 0)
    background.BackgroundColor3 = Color3.fromRGB(51, 54, 59)

    titleLabel.FontFace.Weight = Enum.FontWeight.Bold

    _create_image("rbxassetid://7271246894", UDim2.new(0.396, 0, 0.196, 0), background) 
    _create_image("rbxassetid://82066392272381", UDim2.new(0.508, 0, 0.196, 0), background)

    return {
        UI = UI,
        counter = counterLabel,
        addButton = addButton,
        resetButton = resetButton
    }
end