-- Murder Mystery 2 ESP - UI Premium
-- Suporte para PC e Mobile

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Configurações
local config = {
    murdererColor = Color3.fromRGB(255, 0, 0),
    sheriffColor = Color3.fromRGB(0, 100, 255),
    gunColor = Color3.fromRGB(0, 255, 100),
    espEnabled = true,
    gunESPEnabled = true,
    textSize = 14
}

local espObjects = {}
local gunESPObjects = {}
local currentSheriff = nil
local currentMurderer = nil

-- Criar ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MM2_ESP_GUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    screenGui.Parent = game:GetService("CoreGui")
end)
if screenGui.Parent ~= game:GetService("CoreGui") then
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Função de Tween suave
local function tweenProperty(object, property, endValue, duration)
    local tweenInfo = TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local tween = TweenService:Create(object, tweenInfo, property)
    tween:Play()
    return tween
end

-- ===== BOTÃO TOGGLE FLUTUANTE =====
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 55, 0, 55)
toggleButton.Position = UDim2.new(0.92, 0, 0.08, 0)
toggleButton.AnchorPoint = Vector2.new(0.5, 0.5)
toggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
toggleButton.BorderSizePixel = 0
toggleButton.Text = ""
toggleButton.AutoButtonColor = false
toggleButton.Active = true
toggleButton.Parent = screenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(1, 0)
toggleCorner.Parent = toggleButton

local toggleShadow = Instance.new("ImageLabel")
toggleShadow.Name = "Shadow"
toggleShadow.Size = UDim2.new(1, 30, 1, 30)
toggleShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
toggleShadow.AnchorPoint = Vector2.new(0.5, 0.5)
toggleShadow.BackgroundTransparency = 1
toggleShadow.Image = "rbxassetid://5554236805"
toggleShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
toggleShadow.ImageTransparency = 0.5
toggleShadow.ZIndex = 0
toggleShadow.Parent = toggleButton

local toggleIcon = Instance.new("ImageLabel")
toggleIcon.Name = "Icon"
toggleIcon.Size = UDim2.new(0, 28, 0, 28)
toggleIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
toggleIcon.AnchorPoint = Vector2.new(0.5, 0.5)
toggleIcon.BackgroundTransparency = 1
toggleIcon.Image = "rbxassetid://7733960981"
toggleIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
toggleIcon.Parent = toggleButton

local toggleGlow = Instance.new("ImageLabel")
toggleGlow.Name = "Glow"
toggleGlow.Size = UDim2.new(1, 20, 1, 20)
toggleGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
toggleGlow.AnchorPoint = Vector2.new(0.5, 0.5)
toggleGlow.BackgroundTransparency = 1
toggleGlow.Image = "rbxassetid://5554236805"
toggleGlow.ImageColor3 = Color3.fromRGB(88, 101, 242)
toggleGlow.ImageTransparency = 0.7
toggleGlow.ZIndex = -1
toggleGlow.Parent = toggleButton

-- Sistema de Drag melhorado
local dragging = false
local dragInput, dragStart, startPos

local function updateDrag(input)
    local delta = input.Position - dragStart
    toggleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

toggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = toggleButton.Position
        
        tweenProperty(toggleButton, {Size = UDim2.new(0, 50, 0, 50)}, 0.1)
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                tweenProperty(toggleButton, {Size = UDim2.new(0, 55, 0, 55)}, 0.2)
            end
        end)
    end
end)

toggleButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateDrag(input)
    end
end)

-- ===== MENU PRINCIPAL =====
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 0, 0, 0)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Visible = false
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = mainFrame

local mainShadow = Instance.new("ImageLabel")
mainShadow.Name = "Shadow"
mainShadow.Size = UDim2.new(1, 40, 1, 40)
mainShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
mainShadow.AnchorPoint = Vector2.new(0.5, 0.5)
mainShadow.BackgroundTransparency = 1
mainShadow.Image = "rbxassetid://5554236805"
mainShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
mainShadow.ImageTransparency = 0.3
mainShadow.ZIndex = -1
mainShadow.Parent = mainFrame

-- Header
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 60)
header.BackgroundColor3 = Color3.fromRGB(32, 34, 40)
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 16)
headerCorner.Parent = header

local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0, 16)
headerFix.Position = UDim2.new(0, 0, 1, -16)
headerFix.BackgroundColor3 = Color3.fromRGB(32, 34, 40)
headerFix.BorderSizePixel = 0
headerFix.Parent = header

local headerLine = Instance.new("Frame")
headerLine.Name = "Line"
headerLine.Size = UDim2.new(1, -40, 0, 2)
headerLine.Position = UDim2.new(0, 20, 1, -2)
headerLine.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
headerLine.BorderSizePixel = 0
headerLine.Parent = header

local headerGradient = Instance.new("UIGradient")
headerGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(88, 101, 242)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(142, 71, 221))
}
headerGradient.Parent = headerLine

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, -80, 0, 22)
titleLabel.Position = UDim2.new(0, 20, 0, 12)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Sultan Gostoso"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = header

local subtitleLabel = Instance.new("TextLabel")
subtitleLabel.Name = "Subtitle"
subtitleLabel.Size = UDim2.new(1, -80, 0, 16)
subtitleLabel.Position = UDim2.new(0, 20, 0, 34)
subtitleLabel.BackgroundTransparency = 1
subtitleLabel.Text = "BN GAY"
subtitleLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
subtitleLabel.TextSize = 12
subtitleLabel.Font = Enum.Font.Gotham
subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
subtitleLabel.Parent = header

-- Botão Fechar
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 36, 0, 36)
closeButton.Position = UDim2.new(1, -48, 0, 12)
closeButton.BackgroundColor3 = Color3.fromRGB(40, 42, 48)
closeButton.BorderSizePixel = 0
closeButton.Text = "×"
closeButton.TextColor3 = Color3.fromRGB(200, 200, 210)
closeButton.TextSize = 24
closeButton.Font = Enum.Font.GothamBold
closeButton.AutoButtonColor = false
closeButton.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeButton

-- Container de Conteúdo
local contentFrame = Instance.new("Frame")
contentFrame.Name = "Content"
contentFrame.Size = UDim2.new(1, -40, 1, -80)
contentFrame.Position = UDim2.new(0, 20, 0, 70)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Função para criar toggle switch
local function createToggle(name, text, icon, enabled, parent, yPos)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = name
    toggleFrame.Size = UDim2.new(1, 0, 0, 56)
    toggleFrame.Position = UDim2.new(0, 0, 0, yPos)
    toggleFrame.BackgroundColor3 = Color3.fromRGB(32, 34, 40)
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Parent = parent
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 12)
    frameCorner.Parent = toggleFrame
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -140, 1, 0)
    textLabel.Position = UDim2.new(0, 16, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextSize = 15
    textLabel.Font = Enum.Font.GothamSemibold
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = toggleFrame
    
    local switchButton = Instance.new("TextButton")
    switchButton.Name = "Switch"
    switchButton.Size = UDim2.new(0, 50, 0, 28)
    switchButton.Position = UDim2.new(1, -62, 0.5, -14)
    switchButton.BackgroundColor3 = enabled and Color3.fromRGB(88, 101, 242) or Color3.fromRGB(50, 52, 58)
    switchButton.BorderSizePixel = 0
    switchButton.Text = ""
    switchButton.AutoButtonColor = false
    switchButton.Parent = toggleFrame
    
    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(1, 0)
    switchCorner.Parent = switchButton
    
    local switchCircle = Instance.new("Frame")
    switchCircle.Name = "Circle"
    switchCircle.Size = UDim2.new(0, 22, 0, 22)
    switchCircle.Position = enabled and UDim2.new(1, -25, 0.5, -11) or UDim2.new(0, 3, 0.5, -11)
    switchCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    switchCircle.BorderSizePixel = 0
    switchCircle.Parent = switchButton
    
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = switchCircle
    
    local circleShadow = Instance.new("ImageLabel")
    circleShadow.Size = UDim2.new(1, 8, 1, 8)
    circleShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    circleShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    circleShadow.BackgroundTransparency = 1
    circleShadow.Image = "rbxassetid://5554236805"
    circleShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    circleShadow.ImageTransparency = 0.6
    circleShadow.ZIndex = 0
    circleShadow.Parent = switchCircle
    
    return {frame = toggleFrame, switch = switchButton, circle = switchCircle, text = textLabel}
end

-- Criar toggles
local espToggle = createToggle("ESPToggle", "Player ESP", "", config.espEnabled, contentFrame, 0)
local gunToggle = createToggle("GunToggle", "Gun ESP", "", config.gunESPEnabled, contentFrame, 66)

-- Animação de hover nos botões
local function addHoverEffect(button)
    button.MouseEnter:Connect(function()
        tweenProperty(button, {BackgroundColor3 = Color3.fromRGB(50, 52, 60)}, 0.2)
    end)
    
    button.MouseLeave:Connect(function()
        tweenProperty(button, {BackgroundColor3 = Color3.fromRGB(40, 42, 48)}, 0.2)
    end)
end

addHoverEffect(closeButton)

-- Sistema de Drag para MainFrame
local mainDragging = false
local mainDragInput, mainDragStart, mainStartPos

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        mainDragging = true
        mainDragStart = input.Position
        mainStartPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                mainDragging = false
            end
        end)
    end
end)

header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        mainDragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == mainDragInput and mainDragging then
        local delta = input.Position - mainDragStart
        mainFrame.Position = UDim2.new(mainStartPos.X.Scale, mainStartPos.X.Offset + delta.X, mainStartPos.Y.Scale, mainStartPos.Y.Offset + delta.Y)
    end
end)

-- Funções de ESP
local function createESP(player)
    if player == LocalPlayer then return end
    if not config.espEnabled then return end
    if not player.Character then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.Adornee = player.Character
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.Parent = player.Character
    
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "ESP_Billboard"
    billboardGui.Adornee = player.Character:FindFirstChild("Head")
    billboardGui.Size = UDim2.new(0, 100, 0, 40)
    billboardGui.StudsOffset = Vector3.new(0, 3, 0)
    billboardGui.AlwaysOnTop = true
    billboardGui.Parent = player.Character
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = player.Name
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextSize = config.textSize
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextStrokeTransparency = 0.5
    textLabel.Parent = billboardGui
    
    espObjects[player] = {highlight = highlight, billboard = billboardGui}
end

local function removeESP(player)
    if espObjects[player] then
        if espObjects[player].highlight then
            pcall(function() espObjects[player].highlight:Destroy() end)
        end
        if espObjects[player].billboard then
            pcall(function() espObjects[player].billboard:Destroy() end)
        end
        espObjects[player] = nil
    end
end

local function createGunESP(gunModel)
    if not config.gunESPEnabled then return end
    if gunESPObjects[gunModel] then return end
    
    local gunPart = nil
    
    if gunModel:IsA("Tool") then
        gunPart = gunModel:FindFirstChild("Handle")
    elseif gunModel:IsA("Model") then
        gunPart = gunModel.PrimaryPart or gunModel:FindFirstChildWhichIsA("BasePart")
    elseif gunModel:IsA("BasePart") then
        gunPart = gunModel
    end
    
    if not gunPart then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "GunESP_Highlight"
    highlight.Adornee = gunModel:IsA("Model") and gunModel or gunPart
    highlight.FillColor = config.gunColor
    highlight.FillTransparency = 0.3
    highlight.OutlineTransparency = 0
    highlight.OutlineColor = config.gunColor
    highlight.Parent = gunPart
    
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "GunESP_Billboard"
    billboardGui.Adornee = gunPart
    billboardGui.Size = UDim2.new(0, 100, 0, 40)
    billboardGui.StudsOffset = Vector3.new(0, 2, 0)
    billboardGui.AlwaysOnTop = true
    
    pcall(function()
        billboardGui.Parent = game:GetService("CoreGui")
    end)
    if billboardGui.Parent ~= game:GetService("CoreGui") then
        billboardGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "🔫 GUN"
    textLabel.TextColor3 = config.gunColor
    textLabel.TextSize = 16
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextStrokeTransparency = 0.5
    textLabel.Parent = billboardGui
    
    gunESPObjects[gunModel] = {highlight = highlight, billboard = billboardGui, part = gunPart}
end

local function removeGunESP(gunModel)
    if gunESPObjects[gunModel] then
        if gunESPObjects[gunModel].highlight then
            pcall(function() gunESPObjects[gunModel].highlight:Destroy() end)
        end
        if gunESPObjects[gunModel].billboard then
            pcall(function() gunESPObjects[gunModel].billboard:Destroy() end)
        end
        gunESPObjects[gunModel] = nil
    end
end

local function updateESP(player)
    if not config.espEnabled then return end
    if not player.Character then return end
    if not espObjects[player] then return end
    
    local backpack = player:FindFirstChild("Backpack")
    local character = player.Character
    local role = nil
    
    if backpack and backpack:FindFirstChild("Knife") then
        role = "Murderer"
        currentMurderer = player
    elseif character and character:FindFirstChild("Knife") then
        role = "Murderer"
        currentMurderer = player
    elseif backpack and backpack:FindFirstChild("Gun") then
        role = "Sheriff"
        currentSheriff = player
    elseif character and character:FindFirstChild("Gun") then
        role = "Sheriff"
        currentSheriff = player
    end
    
    if currentSheriff == player and role ~= "Sheriff" then
        currentSheriff = nil
    end
    
    if currentMurderer == player and role ~= "Murderer" then
        currentMurderer = nil
    end
    
    if role == "Murderer" then
        espObjects[player].highlight.FillColor = config.murdererColor
        espObjects[player].billboard.TextLabel.Text = player.Name .. "\n[MURDERER]"
        espObjects[player].billboard.TextLabel.TextColor3 = config.murdererColor
    elseif role == "Sheriff" then
        espObjects[player].highlight.FillColor = config.sheriffColor
        espObjects[player].billboard.TextLabel.Text = player.Name .. "\n[SHERIFF]"
        espObjects[player].billboard.TextLabel.TextColor3 = config.sheriffColor
    else
        espObjects[player].highlight.FillColor = Color3.fromRGB(255, 255, 255)
        espObjects[player].billboard.TextLabel.Text = player.Name
        espObjects[player].billboard.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end

local function checkForDroppedGuns()
    if not config.gunESPEnabled then return end
    
    local sheriffAlive = false
    if currentSheriff and currentSheriff.Character then
        local humanoid = currentSheriff.Character:FindFirstChild("Humanoid")
        if humanoid and humanoid.Health > 0 then
            sheriffAlive = true
        end
    end
    
    if sheriffAlive then
        for gun, _ in pairs(gunESPObjects) do
            removeGunESP(gun)
        end
        return
    end
    
    local workspace = game:GetService("Workspace")
    
    local function checkItem(item)
        if not item or not item.Parent then return end
        if gunESPObjects[item] then return end
        
        local itemName = item.Name:lower()
        if itemName:find("gun") or itemName == "gundrop" then
            if item:IsA("Tool") or item:IsA("Model") or item:IsA("BasePart") then
                local isInInventory = false
                for _, player in pairs(Players:GetPlayers()) do
                    if player.Character and player.Character:FindFirstChild(item.Name) then
                        isInInventory = true
                        break
                    end
                    if player:FindFirstChild("Backpack") and player.Backpack:FindFirstChild(item.Name) then
                        isInInventory = true
                        break
                    end
                end
                
                if not isInInventory then
                    createGunESP(item)
                end
            end
        end
    end
    
    for _, item in pairs(workspace:GetChildren()) do
        checkItem(item)
    end
    
    local folders = {"Normal", "Dropped", "Items", "Ignore"}
    for _, folderName in pairs(folders) do
        local folder = workspace:FindFirstChild(folderName)
        if folder then
            for _, item in pairs(folder:GetChildren()) do
                checkItem(item)
            end
        end
    end
end

-- Event Handlers
toggleButton.MouseButton1Click:Connect(function()
    if mainFrame.Visible then
        tweenProperty(mainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
        tweenProperty(toggleIcon, {ImageColor3 = Color3.fromRGB(255, 255, 255)}, 0.3)
        wait(0.3)
        mainFrame.Visible = false
    else
        mainFrame.Visible = true
        mainFrame.Size = UDim2.new(0, 0, 0, 0)
        tweenProperty(mainFrame, {Size = UDim2.new(0, 360, 0, 210)}, 0.4)
        tweenProperty(toggleIcon, {ImageColor3 = Color3.fromRGB(88, 101, 242)}, 0.3)
    end
end)

closeButton.MouseButton1Click:Connect(function()
    tweenProperty(closeButton, {BackgroundColor3 = Color3.fromRGB(220, 50, 50)}, 0.1)
    wait(0.1)
    tweenProperty(mainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
    tweenProperty(toggleIcon, {ImageColor3 = Color3.fromRGB(255, 255, 255)}, 0.3)
    wait(0.3)
    mainFrame.Visible = false
    tweenProperty(closeButton, {BackgroundColor3 = Color3.fromRGB(40, 42, 48)}, 0.1)
end)

local function toggleSwitch(toggle, enabled)
    if toggle == espToggle then
        config.espEnabled = enabled
    elseif toggle == gunToggle then
        config.gunESPEnabled = enabled
    end
    
    tweenProperty(toggle.switch, {
        BackgroundColor3 = enabled and Color3.fromRGB(88, 101, 242) or Color3.fromRGB(50, 52, 58)
    }, 0.3)
    
    tweenProperty(toggle.circle, {
        Position = enabled and UDim2.new(1, -25, 0.5, -11) or UDim2.new(0, 3, 0.5, -11)
    }, 0.3)
    
    if toggle == espToggle then
        if enabled then
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character then
                    createESP(player)
                    updateESP(player)
                end
            end
        else
            for player, _ in pairs(espObjects) do
                removeESP(player)
            end
        end
    elseif toggle == gunToggle then
        if enabled then
            checkForDroppedGuns()
        else
            for gun, _ in pairs(gunESPObjects) do
                removeGunESP(gun)
            end
        end
    end
end

espToggle.switch.MouseButton1Click:Connect(function()
    toggleSwitch(espToggle, not config.espEnabled)
end)

gunToggle.switch.MouseButton1Click:Connect(function()
    toggleSwitch(gunToggle, not config.gunESPEnabled)
end)

-- Setup inicial
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        wait(1)
        if config.espEnabled then
            createESP(player)
            updateESP(player)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

for _, player in pairs(Players:GetPlayers()) do
    if player.Character and config.espEnabled then
        createESP(player)
    end
    
    player.CharacterAdded:Connect(function()
        wait(1)
        if config.espEnabled then
            createESP(player)
            updateESP(player)
        end
    end)
end

-- Loop principal
local lastGunCheck = 0
local gunCheckInterval = 0.5

RunService.RenderStepped:Connect(function()
    if config.espEnabled then
        for player, _ in pairs(espObjects) do
            if player.Character then
                updateESP(player)
            else
                removeESP(player)
            end
        end
        
        if currentSheriff then
            if not currentSheriff.Character or not currentSheriff.Character:FindFirstChild("Humanoid") then
                currentSheriff = nil
            else
                local humanoid = currentSheriff.Character.Humanoid
                if humanoid.Health <= 0 then
                    currentSherif config.gunESPEnabled then
    local currentTime = tick()
    if currentTime - lastGunCheck >= gunCheckInterval then
        lastGunCheck = currentTime
        checkForDroppedGuns()
        
        for gun, _ in pairs(gunESPObjects) do
            if not gun or not gun.Parent then
                removeGunESP(gun)
            end
        end
    end
end
task.wait(0.2)

if not child or not child.Parent then return end

local itemName = child.Name:lower()
if itemName:find("gun") or itemName == "gundrop" then
    if child:IsA("Tool") or child:IsA("Model") or child:IsA("BasePart") then
        local sheriffAlive = false
        if currentSheriff and currentSheriff.Character then
            local humanoid = currentSheriff.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                sheriffAlive = true
            end
        end
        
        local isInInventory = false
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild(child.Name) then
                isInInventory = true
                break
            end
            if player:FindFirstChild("Backpack") and player.Backpack:FindFirstChild(child.Name) then
                isInInventory = true
                break
            end
        end
        
        if not sheriffAlive and not isInInventory then
            createGunESP(child)
        end
    end
end
