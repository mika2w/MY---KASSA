---1 ---
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local CONFIG = {
    Nome = "MY - KASSA",
    Versao = "V2.1",

    Cores = {
        Fundo = Color3.fromRGB(9, 9, 12),
        Fundo2 = Color3.fromRGB(14, 14, 18),
        Fundo3 = Color3.fromRGB(20, 20, 25),
        Vermelho = Color3.fromRGB(225, 40, 40),
        VermelhoClaro = Color3.fromRGB(255, 70, 70),
        VermelhoEscuro = Color3.fromRGB(125, 20, 20),
        Branco = Color3.fromRGB(245, 245, 248),
        Cinza = Color3.fromRGB(160, 160, 168),
        CinzaEscuro = Color3.fromRGB(85, 85, 94),
        Verde = Color3.fromRGB(65, 220, 115),
        Amarelo = Color3.fromRGB(245, 190, 65)
    }
}

local RED = CONFIG.Cores.Vermelho
local LIGHT_RED = CONFIG.Cores.VermelhoClaro
local DARK = CONFIG.Cores.Fundo
local DARK_2 = CONFIG.Cores.Fundo2
local DARK_3 = CONFIG.Cores.Fundo3
local WHITE = CONFIG.Cores.Branco
local GRAY = CONFIG.Cores.Cinza
local DARK_GRAY = CONFIG.Cores.CinzaEscuro
local GREEN = CONFIG.Cores.Verde

local destroyed = false

local character
local humanoid
local rootPart

local isFlying = false
local isFlyLoading = false
local flySpeed = 60

local flyCurrentVelocity = Vector3.zero
local flyAcceleration = 7
local flyDeceleration = 10
local FLY_INPUT_DEADZONE = 0.05

local isNoclip = false
local isNoclipLoading = false

local espBox = false
local espTracer = false
local espHealth = false
local espDistance = false
local espSkeleton = false

local tracerColor = Color3.fromRGB(255, 60, 60)

local lowEndMode = false
local ultraLowMemory = false
local cleanBusy = false

local espUpdateAccumulator = 0

local flyVelocity
local flyOrientation
local flyAttachment

local originalCollision = {}

local ultraParticles = {}
local ultraTrails = {}
local ultraBeams = {}
local ultraLights = {}
local ultraEffects = {}
local ultraShadows = {}

local espObjects = {}
local connections = {}

local applyUltraLowMemory
local restoreUltraLowMemory
local unloadGUI

local function connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(connections, connection)
    return connection
end

local function disconnectAll()
    for _, connection in ipairs(connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end

    table.clear(connections)
end

local function tween(object, info, properties)
    local animation = TweenService:Create(object, info, properties)
    animation:Play()
    return animation
end

local function addCorner(object, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = object
    return corner
end

local function addStroke(object, color, transparency, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or RED
    stroke.Transparency = transparency or 0
    stroke.Thickness = thickness or 1
    stroke.Parent = object
    return stroke
end

local function createLabel(parent, text, size, position, font, color)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Text = text or ""
    label.TextColor3 = color or WHITE
    label.TextSize = size or 14
    label.Font = font or Enum.Font.Gotham
    label.Position = position or UDim2.new()
    label.Size = UDim2.new(1, 0, 0, 25)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    return label
end

local oldGui = playerGui:FindFirstChild("MY_KASSA_V2")

if oldGui then
    oldGui:Destroy()
end

local character = player.Character or player.CharacterAdded:Wait()

local function updateCharacter(char)
    character = char
    humanoid = char:WaitForChild("Humanoid", 10)
    rootPart = char:WaitForChild("HumanoidRootPart", 10)
end

updateCharacter(character)

local controlModule

pcall(function()
    local playerScripts = player:WaitForChild("PlayerScripts")
    local playerModule = playerScripts:WaitForChild("PlayerModule")
    controlModule = require(playerModule:WaitForChild("ControlModule"))
end)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MY_KASSA_V2"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local introFrame = Instance.new("Frame")
introFrame.Name = "Intro"
introFrame.Size = UDim2.fromScale(1, 1)
introFrame.BackgroundColor3 = DARK
introFrame.BorderSizePixel = 0
introFrame.ZIndex = 100
introFrame.Parent = screenGui

local introGlow = Instance.new("Frame")
introGlow.Size = UDim2.new(0, 360, 0, 360)
introGlow.Position = UDim2.new(0.5, -180, 0.5, -180)
introGlow.BackgroundColor3 = RED
introGlow.BackgroundTransparency = 0.94
introGlow.ZIndex = 101
introGlow.Parent = introFrame
addCorner(introGlow, 180)

local introCard = Instance.new("Frame")
introCard.Size = UDim2.new(0, 350, 0, 270)
introCard.Position = UDim2.new(0.5, -175, 0.5, -135)
introCard.BackgroundColor3 = DARK_2
introCard.BorderSizePixel = 0
introCard.ZIndex = 102
introCard.Parent = introFrame
addCorner(introCard, 18)
addStroke(introCard, Color3.fromRGB(55, 55, 62), 0.2, 1)

local introLine = Instance.new("Frame")
introLine.Size = UDim2.new(0, 65, 0, 3)
introLine.Position = UDim2.new(0.5, -32, 0, 26)
introLine.BackgroundColor3 = RED
introLine.BorderSizePixel = 0
introLine.ZIndex = 103
introLine.Parent = introCard
addCorner(introLine, 4)

local introTitle = createLabel(
    introCard,
    "MY - KASSA",
    31,
    UDim2.new(0, 0, 0, 55),
    Enum.Font.GothamBold,
    WHITE
)

introTitle.Size = UDim2.new(1, 0, 0, 45)
introTitle.TextXAlignment = Enum.TextXAlignment.Center
introTitle.ZIndex = 103

local introSubtitle = createLabel(
    introCard,
    "PAINEL DE CONTROLE",
    10,
    UDim2.new(0, 0, 0, 99),
    Enum.Font.GothamMedium,
    GRAY
)

introSubtitle.Size = UDim2.new(1, 0, 0, 20)
introSubtitle.TextXAlignment = Enum.TextXAlignment.Center
introSubtitle.ZIndex = 103

local introStatus = createLabel(
    introCard,
    "Iniciando...",
    12,
    UDim2.new(0, 25, 0, 145),
    Enum.Font.GothamMedium,
    GRAY
)

introStatus.Size = UDim2.new(1, -50, 0, 22)
introStatus.ZIndex = 103

local progressBackground = Instance.new("Frame")
progressBackground.Size = UDim2.new(1, -50, 0, 5)
progressBackground.Position = UDim2.new(0, 25, 0, 177)
progressBackground.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
progressBackground.BorderSizePixel = 0
progressBackground.ZIndex = 103
progressBackground.Parent = introCard
addCorner(progressBackground, 5)

local progressBar = Instance.new("Frame")
progressBar.Size = UDim2.new(0, 0, 1, 0)
progressBar.BackgroundColor3 = RED
progressBar.BorderSizePixel = 0
progressBar.ZIndex = 104
progressBar.Parent = progressBackground
addCorner(progressBar, 5)

local introPercent = createLabel(
    introCard,
    "0%",
    11,
    UDim2.new(0, 25, 0, 192),
    Enum.Font.GothamBold,
    RED
)

introPercent.Size = UDim2.new(1, -50, 0, 20)
introPercent.TextXAlignment = Enum.TextXAlignment.Right
introPercent.ZIndex = 103

local introVersion = createLabel(
    introCard,
    "MY - KASSA  •  V2.1",
    10,
    UDim2.new(0, 0, 0, 238),
    Enum.Font.Gotham,
    DARK_GRAY
)

introVersion.Size = UDim2.new(1, 0, 0, 18)
introVersion.TextXAlignment = Enum.TextXAlignment.Center
introVersion.ZIndex = 103

local espGui = Instance.new("ScreenGui")
espGui.Name = "KassaESP"
espGui.ResetOnSpawn = false
espGui.IgnoreGuiInset = true
espGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
espGui.Parent = playerGui

local espLayer = Instance.new("Frame")
espLayer.BackgroundTransparency = 1
espLayer.Size = UDim2.fromScale(1, 1)
espLayer.ZIndex = 5
espLayer.Parent = espGui

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "FloatingButton"
toggleButton.Size = UDim2.new(0, 46, 0, 46)
toggleButton.Position = UDim2.new(0, 14, 0.5, -23)
toggleButton.BackgroundColor3 = DARK_2
toggleButton.Text = ""
toggleButton.AutoButtonColor = false
toggleButton.Visible = false
toggleButton.ZIndex = 50
toggleButton.Parent = screenGui
addCorner(toggleButton, 14)
addStroke(toggleButton, RED, 0.15, 1)

local toggleIcon = createLabel(
    toggleButton,
    "☰",
    22,
    UDim2.new(),
    Enum.Font.GothamBold,
    WHITE
)

toggleIcon.Size = UDim2.fromScale(1, 1)
toggleIcon.TextXAlignment = Enum.TextXAlignment.Center
toggleIcon.TextYAlignment = Enum.TextYAlignment.Center

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainPanel"
mainFrame.Size = UDim2.new(0, 285, 0, 390)
mainFrame.Position = UDim2.new(0.5, -142, 0.5, -195)
mainFrame.BackgroundColor3 = DARK
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.ZIndex = 20
mainFrame.Parent = screenGui
addCorner(mainFrame, 17)
addStroke(mainFrame, Color3.fromRGB(50, 50, 57), 0.15, 1)

local mainTopLine = Instance.new("Frame")
mainTopLine.Size = UDim2.new(1, -28, 0, 2)
mainTopLine.Position = UDim2.new(0, 14, 0, 0)
mainTopLine.BackgroundColor3 = RED
mainTopLine.BorderSizePixel = 0
mainTopLine.ZIndex = 21
mainTopLine.Parent = mainFrame
addCorner(mainTopLine, 3)

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 74)
header.BackgroundColor3 = DARK_2
header.BorderSizePixel = 0
header.ZIndex = 21
header.Parent = mainFrame
addCorner(header, 17)

local headerCover = Instance.new("Frame")
headerCover.Size = UDim2.new(1, 0, 0, 18)
headerCover.Position = UDim2.new(0, 0, 1, -18)
headerCover.BackgroundColor3 = DARK_2
headerCover.BorderSizePixel = 0
headerCover.ZIndex = 21
headerCover.Parent = header

local logoBox = Instance.new("Frame")
logoBox.Size = UDim2.new(0, 42, 0, 42)
logoBox.Position = UDim2.new(0, 14, 0, 15)
logoBox.BackgroundColor3 = Color3.fromRGB(35, 18, 20)
logoBox.BorderSizePixel = 0
logoBox.ZIndex = 22
logoBox.Parent = header
addCorner(logoBox, 12)
addStroke(logoBox, RED, 0.25, 1)

local logoText = createLabel(
    logoBox,
    "K",
    21,
    UDim2.new(),
    Enum.Font.GothamBold,
    RED
)

logoText.Size = UDim2.fromScale(1, 1)
logoText.TextXAlignment = Enum.TextXAlignment.Center
logoText.TextYAlignment = Enum.TextYAlignment.Center
logoText.ZIndex = 23

local title = createLabel(
    header,
    "MY - KASSA",
    16,
    UDim2.new(0, 67, 0, 13),
    Enum.Font.GothamBold,
    WHITE
)

title.Size = UDim2.new(0, 150, 0, 22)
title.ZIndex = 22

local playerName = createLabel(
    header,
    player.DisplayName,
    11,
    UDim2.new(0, 67, 0, 35),
    Enum.Font.GothamMedium,
    GRAY
)

playerName.Size = UDim2.new(0, 150, 0, 18)
playerName.TextTruncate = Enum.TextTruncate.AtEnd
playerName.ZIndex = 22

local activeBadge = Instance.new("Frame")
activeBadge.Size = UDim2.new(0, 70, 0, 25)
activeBadge.Position = UDim2.new(1, -84, 0, 23)
activeBadge.BackgroundColor3 = Color3.fromRGB(18, 45, 28)
activeBadge.BorderSizePixel = 0
activeBadge.ZIndex = 22
activeBadge.Parent = header
addCorner(activeBadge, 8)

local activeDot = Instance.new("Frame")
activeDot.Size = UDim2.new(0, 6, 0, 6)
activeDot.Position = UDim2.new(0, 9, 0.5, -3)
activeDot.BackgroundColor3 = GREEN
activeDot.BorderSizePixel = 0
activeDot.ZIndex = 23
activeDot.Parent = activeBadge
addCorner(activeDot, 5)

local activeText = createLabel(
    activeBadge,
    "ATIVO",
    9,
    UDim2.new(0, 21, 0, 0),
    Enum.Font.GothamBold,
    GREEN
)

activeText.Size = UDim2.new(1, -21, 1, 0)
activeText.TextYAlignment = Enum.TextYAlignment.Center
activeText.ZIndex = 23

local dragging = false
local dragStart
local startPosition

local function updateDrag(input)
    local delta = input.Position - dragStart

    mainFrame.Position = UDim2.new(
        startPosition.X.Scale,
        startPosition.X.Offset + delta.X,
        startPosition.Y.Scale,
        startPosition.Y.Offset + delta.Y
    )
end

connect(header.InputBegan, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPosition = mainFrame.Position
    end
end)

connect(UserInputService.InputChanged, function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        updateDrag(input)
    end
end)

connect(UserInputService.InputEnded, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, -20, 0, 42)
tabBar.Position = UDim2.new(0, 10, 0, 78)
tabBar.BackgroundColor3 = DARK_2
tabBar.BorderSizePixel = 0
tabBar.ZIndex = 21
tabBar.Parent = mainFrame
addCorner(tabBar, 11)

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabLayout.Padding = UDim.new(0, 3)
tabLayout.Parent = tabBar

local tabs = {}
local pages = {}

local function createTab(name, icon)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(0, 47, 0, 34)
    button.BackgroundColor3 = DARK_2
    button.BorderSizePixel = 0
    button.Text = ""
    button.AutoButtonColor = false
    button.ZIndex = 22
    button.Parent = tabBar
    addCorner(button, 9)

    local iconLabel = createLabel(
        button,
        icon,
        14,
        UDim2.new(0, 0, 0, 1),
        Enum.Font.GothamBold,
        GRAY
    )

    iconLabel.Size = UDim2.new(1, 0, 0, 16)
    iconLabel.TextXAlignment = Enum.TextXAlignment.Center
    iconLabel.ZIndex = 23

    local nameLabel = createLabel(
        button,
        name,
        7,
        UDim2.new(0, 0, 0, 17),
        Enum.Font.GothamMedium,
        GRAY
    )

    nameLabel.Size = UDim2.new(1, 0, 0, 12)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Center
    nameLabel.ZIndex = 23

    tabs[name] = {
        Button = button,
        Icon = iconLabel,
        Label = nameLabel
    }

    return button
end

createTab("Voo", "✈")
createTab("Noclip", "◈")
createTab("ESP", "◎")
createTab("TP", "↗")
createTab("Config", "⚙")

local pageContainer = Instance.new("Frame")
pageContainer.Size = UDim2.new(1, -20, 1, -132)
pageContainer.Position = UDim2.new(0, 10, 0, 128)
pageContainer.BackgroundTransparency = 1
pageContainer.ZIndex = 21
pageContainer.Parent = mainFrame

local function createPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "Page"
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = RED
    page.CanvasSize = UDim2.new()
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.ZIndex = 22
    page.Parent = pageContainer

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Parent = page

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 2)
    padding.PaddingRight = UDim.new(0, 2)
    padding.PaddingTop = UDim.new(0, 3)
    padding.PaddingBottom = UDim.new(0, 8)
    padding.Parent = page

    pages[name] = page

    return page
end

local vooPage = createPage("Voo")
local noclipPage = createPage("Noclip")
local espPage = createPage("ESP")
local tpPage = createPage("TP")
local configPage = createPage("Config")

local function createSectionTitle(parent, text, subtitle)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 45)
    holder.BackgroundTransparency = 1
    holder.ZIndex = 23
    holder.Parent = parent

    local label = createLabel(
        holder,
        text,
        14,
        UDim2.new(0, 4, 0, 2),
        Enum.Font.GothamBold,
        WHITE
    )

    label.Size = UDim2.new(1, -8, 0, 20)
    label.ZIndex = 24

    local sub = createLabel(
        holder,
        subtitle or "",
        9,
        UDim2.new(0, 4, 0, 23),
        Enum.Font.Gotham,
        GRAY
    )

    sub.Size = UDim2.new(1, -8, 0, 17)
    sub.TextTruncate = Enum.TextTruncate.AtEnd
    sub.ZIndex = 24

    return holder
end

local function createCard(parent, height)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, height or 60)
    card.BackgroundColor3 = DARK_2
    card.BorderSizePixel = 0
    card.ZIndex = 23
    card.Parent = parent
    addCorner(card, 12)
    addStroke(card, Color3.fromRGB(40, 40, 47), 0.35, 1)
    return card
end

local function createButton(parent, text, callback, height)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, height or 42)
    button.BackgroundColor3 = DARK_2
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = WHITE
    button.TextSize = 11
    button.Font = Enum.Font.GothamMedium
    button.AutoButtonColor = false
    button.ZIndex = 24
    button.Parent = parent
    addCorner(button, 10)
    addStroke(button, Color3.fromRGB(40, 40, 47), 0.4, 1)

    connect(button.MouseEnter, function()
        if destroyed then
            return
        end

        tween(button, TweenInfo.new(0.15), {
            BackgroundColor3 = DARK_3
        })
    end)

    connect(button.MouseLeave, function()
        if destroyed then
            return
        end

        tween(button, TweenInfo.new(0.15), {
            BackgroundColor3 = DARK_2
        })
    end)

    connect(button.MouseButton1Click, function()
        if callback then
            callback()
        end
    end)

    return button
end

local function createToggle(parent, titleText, subtitleText, initial, callback)
    local card = createCard(parent, 59)

    local titleLabel = createLabel(
        card,
        titleText,
        11,
        UDim2.new(0, 13, 0, 9),
        Enum.Font.GothamBold,
        WHITE
    )

    titleLabel.Size = UDim2.new(1, -75, 0, 20)
    titleLabel.ZIndex = 25

    local subLabel = createLabel(
        card,
        subtitleText or "",
        8,
        UDim2.new(0, 13, 0, 30),
        Enum.Font.Gotham,
        GRAY
    )

    subLabel.Size = UDim2.new(1, -75, 0, 16)
    subLabel.TextTruncate = Enum.TextTruncate.AtEnd
    subLabel.ZIndex = 25

    local switch = Instance.new("TextButton")
    switch.Size = UDim2.new(0, 45, 0, 24)
    switch.Position = UDim2.new(1, -57, 0.5, -12)
    switch.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
    switch.BorderSizePixel = 0
    switch.Text = ""
    switch.AutoButtonColor = false
    switch.ZIndex = 25
    switch.Parent = card
    addCorner(switch, 20)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = UDim2.new(0, 3, 0.5, -9)
    knob.BackgroundColor3 = Color3.fromRGB(175, 175, 180)
    knob.BorderSizePixel = 0
    knob.ZIndex = 26
    knob.Parent = switch
    addCorner(knob, 20)

    local state = initial == true

    local function setVisual(value)
        state = value

        if value then
            tween(switch, TweenInfo.new(0.18), {
                BackgroundColor3 = RED
            })

            tween(knob, TweenInfo.new(0.18, Enum.EasingStyle.Quart), {
                Position = UDim2.new(1, -21, 0.5, -9),
                BackgroundColor3 = WHITE
            })
        else
            tween(switch, TweenInfo.new(0.18), {
                BackgroundColor3 = Color3.fromRGB(45, 45, 52)
            })

            tween(knob, TweenInfo.new(0.18, Enum.EasingStyle.Quart), {
                Position = UDim2.new(0, 3, 0.5, -9),
                BackgroundColor3 = Color3.fromRGB(175, 175, 180)
            })
        end
    end

    setVisual(state)

    connect(switch.MouseButton1Click, function()
        state = not state
        setVisual(state)

        if callback then
            callback(state)
        end
    end)

    return {
        Card = card,

        Set = function(value)
            setVisual(value)
        end,

        Get = function()
            return state
        end
    }
end

local function createLoading(parent)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 32)
    holder.BackgroundTransparency = 1
    holder.Visible = false
    holder.ZIndex = 23
    holder.Parent = parent

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, -4, 0, 4)
    bg.Position = UDim2.new(0, 2, 0.5, -2)
    bg.BackgroundColor3 = Color3.fromRGB(38, 38, 44)
    bg.BorderSizePixel = 0
    bg.ZIndex = 24
    bg.Parent = holder
    addCorner(bg, 4)

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 0, 1, 0)
    bar.BackgroundColor3 = RED
    bar.BorderSizePixel = 0
    bar.ZIndex = 25
    bar.Parent = bg
    addCorner(bar, 4)

    return holder, bar
end

local function runLoading(holder, bar, callback)
    if not holder or not bar then
        if callback then
            callback()
        end

        return
    end

    holder.Visible = true
    bar.Size = UDim2.new(0, 0, 1, 0)

    tween(
        bar,
        TweenInfo.new(
            0.45,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        ),
        {
            Size = UDim2.new(1, 0, 1, 0)
        }
    )

    task.delay(0.5, function()
        if destroyed then
            return
        end

        holder.Visible = false

        if callback then
            callback()
        end
    end)
end

local flyToggle

local flyLoading, flyLoadingBar = createLoading(vooPage)

createSectionTitle(
    vooPage,
    "CONTROLE DE VOO",
    "Use o analógico para movimentar e a câmera para direcionar."
)

flyToggle = createToggle(
    vooPage,
    "Voo",
    "Analógico + câmera controlam o movimento 3D.",
    false,
    function(enabled)

        if isFlyLoading then
            flyToggle.Set(isFlying)
            return
        end

        isFlyLoading = true

        runLoading(flyLoading, flyLoadingBar, function()

            if enabled then

                if not rootPart or not humanoid then
                    isFlyLoading = false
                    flyToggle.Set(false)
                    return
                end

                isFlying = true
                flyCurrentVelocity = Vector3.zero

                flyAttachment = Instance.new("Attachment")
                flyAttachment.Name = "KassaFlyAttachment"
                flyAttachment.Parent = rootPart

                flyVelocity = Instance.new("LinearVelocity")
                flyVelocity.Name = "KassaFlyVelocity"
                flyVelocity.Attachment0 = flyAttachment
                flyVelocity.MaxForce = math.huge
                flyVelocity.VectorVelocity = Vector3.zero
                flyVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
                flyVelocity.Parent = rootPart

                flyOrientation = Instance.new("AlignOrientation")
                flyOrientation.Name = "KassaFlyOrientation"
                flyOrientation.Attachment0 = flyAttachment
                flyOrientation.MaxTorque = math.huge
                flyOrientation.Responsiveness = 25
                flyOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
                flyOrientation.Parent = rootPart

                humanoid.AutoRotate = false

                pcall(function()
                    humanoid:ChangeState(
                        Enum.HumanoidStateType.Physics
                    )
                end)

            else

                isFlying = false
                flyCurrentVelocity = Vector3.zero

                if flyVelocity then
                    flyVelocity.VectorVelocity = Vector3.zero
                    flyVelocity:Destroy()
                    flyVelocity = nil
                end

                if flyOrientation then
                    flyOrientation:Destroy()
                    flyOrientation = nil
                end

                if flyAttachment then
                    flyAttachment:Destroy()
                    flyAttachment = nil
                end

                if humanoid then
                    humanoid.AutoRotate = true

                    pcall(function()
                        humanoid:ChangeState(
                            Enum.HumanoidStateType.GettingUp
                        )
                    end)
                end
            end

            isFlyLoading = false
        end)
    end
)

local speedCard = createCard(vooPage, 72)

local speedTitle = createLabel(
    speedCard,
    "VELOCIDADE",
    10,
    UDim2.new(0, 13, 0, 9),
    Enum.Font.GothamBold,
    WHITE
)

speedTitle.Size = UDim2.new(0.5, 0, 0, 20)

local speedValue = Instance.new("TextBox")
speedValue.Size = UDim2.new(0, 72, 0, 30)
speedValue.Position = UDim2.new(1, -85, 0, 8)
speedValue.BackgroundColor3 = DARK_3
speedValue.BorderSizePixel = 0
speedValue.Text = tostring(flySpeed)
speedValue.TextColor3 = WHITE
speedValue.TextSize = 11
speedValue.Font = Enum.Font.GothamBold
speedValue.ClearTextOnFocus = false
speedValue.ZIndex = 25
speedValue.Parent = speedCard
addCorner(speedValue, 8)

local speedSub = createLabel(
    speedCard,
    "Valor entre 10 e 500",
    8,
    UDim2.new(0, 13, 0, 32),
    Enum.Font.Gotham,
    GRAY
)

speedSub.Size = UDim2.new(0.6, 0, 0, 16)

connect(speedValue.FocusLost, function()
    local value = tonumber(speedValue.Text)

    if value then
        flySpeed = math.clamp(
            math.floor(value),
            10,
            500
        )
    end

    speedValue.Text = tostring(flySpeed)
end)

local presetCard = createCard(vooPage, 65)

local presetTitle = createLabel(
    presetCard,
    "PRESETS",
    9,
    UDim2.new(0, 13, 0, 8),
    Enum.Font.GothamBold,
    GRAY
)

presetTitle.Size = UDim2.new(1, -20, 0, 16)

local presets = {
    50,
    100,
    150
}

for i, value in ipairs(presets) do

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 68, 0, 28)
    button.Position = UDim2.new(
        0,
        10 + ((i - 1) * 76),
        0,
        30
    )

    button.BackgroundColor3 = DARK_3
    button.BorderSizePixel = 0
    button.Text = tostring(value)
    button.TextColor3 = WHITE
    button.TextSize = 9
    button.Font = Enum.Font.GothamBold
    button.AutoButtonColor = false
    button.ZIndex = 25
    button.Parent = presetCard
    addCorner(button, 7)

    connect(button.MouseButton1Click, function()

        flySpeed = value
        speedValue.Text = tostring(value)

        tween(button, TweenInfo.new(0.12), {
            BackgroundColor3 = RED
        })

        task.delay(0.15, function()
            if button and button.Parent then
                tween(button, TweenInfo.new(0.15), {
                    BackgroundColor3 = DARK_3
                })
            end
        end)

    end)
end

local flyInfo = createCard(vooPage, 78)

local flyInfoIcon = createLabel(
    flyInfo,
    "✈",
    21,
    UDim2.new(0, 13, 0, 14),
    Enum.Font.GothamBold,
    RED
)

flyInfoIcon.Size = UDim2.new(0, 30, 0, 30)
flyInfoIcon.TextXAlignment = Enum.TextXAlignment.Center
flyInfoIcon.TextYAlignment = Enum.TextYAlignment.Center

local flyInfoTitle = createLabel(
    flyInfo,
    "CONTROLE 3D",
    10,
    UDim2.new(0, 50, 0, 11),
    Enum.Font.GothamBold,
    WHITE
)

flyInfoTitle.Size = UDim2.new(1, -60, 0, 18)

local flyInfoText = createLabel(
    flyInfo,
    "Analógico move o personagem. A câmera define subida, descida e direção.",
    8,
    UDim2.new(0, 50, 0, 31),
    Enum.Font.Gotham,
    GRAY
)

flyInfoText.Size = UDim2.new(1, -62, 0, 34)
flyInfoText.TextWrapped = true

createSectionTitle(
    noclipPage,
    "NOCLIP",
    "Atravessa paredes sem alterar o sistema de voo."
)

local noclipLoading, noclipLoadingBar = createLoading(noclipPage)

createToggle(
    noclipPage,
    "Noclip",
    "Desativa a colisão do seu personagem.",
    false,
    function(enabled)

        if isNoclipLoading then
            return
        end

        isNoclipLoading = true

        runLoading(noclipLoading, noclipLoadingBar, function()

            if enabled then

                isNoclip = true
                table.clear(originalCollision)

                if character then

                    for _, object in ipairs(
                        character:GetDescendants()
                    ) do

                        if object:IsA("BasePart") then
                            originalCollision[object] =
                                object.CanCollide

                            object.CanCollide = false
                        end
                    end
                end

            else

                isNoclip = false

                for object, value in pairs(
                    originalCollision
                ) do

                    if object and object.Parent then
                        object.CanCollide = value
                    end
                end

                table.clear(originalCollision)
            end

            isNoclipLoading = false
        end)
    end
)

local noclipInfo = createCard(noclipPage, 78)

local noclipIcon = createLabel(
    noclipInfo,
    "◈",
    20,
    UDim2.new(0, 13, 0, 15),
    Enum.Font.GothamBold,
    RED
)

noclipIcon.Size = UDim2.new(0, 30, 0, 30)
noclipIcon.TextXAlignment = Enum.TextXAlignment.Center
noclipIcon.TextYAlignment = Enum.TextYAlignment.Center

local noclipInfoTitle = createLabel(
    noclipInfo,
    "MODO SEGURO",
    10,
    UDim2.new(0, 50, 0, 13),
    Enum.Font.GothamBold,
    WHITE
)

noclipInfoTitle.Size = UDim2.new(1, -60, 0, 18)

local noclipInfoText = createLabel(
    noclipInfo,
    "A colisão é restaurada automaticamente quando o Noclip é desligado.",
    8,
    UDim2.new(0, 50, 0, 32),
    Enum.Font.Gotham,
    GRAY
)

noclipInfoText.Size = UDim2.new(1, -62, 0, 30)
noclipInfoText.TextWrapped = true

createSectionTitle(
    espPage,
    "ESP",
    "Informações visuais dos jogadores."
)

createToggle(
    espPage,
    "ESP Box",
    "Mostra uma caixa ao redor do jogador.",
    false,
    function(value)
        espBox = value
    end
)

createToggle(
    espPage,
    "ESP Tracers",
    "Linha indicando a posição dos jogadores.",
    false,
    function(value)
        espTracer = value
    end
)

createToggle(
    espPage,
    "ESP Vida",
    "Mostra a vida atual do jogador.",
    false,
    function(value)
        espHealth = value
    end
)

createToggle(
    espPage,
    "ESP Distância",
    "Mostra a distância até o jogador.",
    false,
    function(value)
        espDistance = value
    end
)

createToggle(
    espPage,
    "Skeleton ESP",
    "Desenha o esqueleto do personagem.",
    false,
    function(value)
        espSkeleton = value
    end
)

local colorCard = createCard(espPage, 62)

local colorTitle = createLabel(
    colorCard,
    "COR DO ESP",
    9,
    UDim2.new(0, 13, 0, 8),
    Enum.Font.GothamBold,
    GRAY
)

colorTitle.Size = UDim2.new(0.7, 0, 0, 16)

local colorPreview = Instance.new("Frame")
colorPreview.Size = UDim2.new(0, 36, 0, 28)
colorPreview.Position = UDim2.new(1, -49, 0, 23)
colorPreview.BackgroundColor3 = tracerColor
colorPreview.BorderSizePixel = 0
colorPreview.ZIndex = 25
colorPreview.Parent = colorCard
addCorner(colorPreview, 8)

local colorButton = Instance.new("TextButton")
colorButton.Size = UDim2.new(1, 0, 1, 0)
colorButton.BackgroundTransparency = 1
colorButton.Text = ""
colorButton.ZIndex = 26
colorButton.Parent = colorCard

local colorPicker
local hue = 0
local saturation = 1
local value = 1

local function updateESPColor()
    tracerColor = Color3.fromHSV(
        hue,
        saturation,
        value
    )

    colorPreview.BackgroundColor3 = tracerColor
end

local function createColorPicker()

    if colorPicker then
        colorPicker:Destroy()
        colorPicker = nil
        return
    end

    colorPicker = Instance.new("Frame")
    colorPicker.Size = UDim2.new(0, 240, 0, 245)
    colorPicker.Position = UDim2.new(0.5, -120, 0.5, -122)
    colorPicker.BackgroundColor3 = DARK_2
    colorPicker.BorderSizePixel = 0
    colorPicker.ZIndex = 70
    colorPicker.Parent = screenGui

    addCorner(colorPicker, 14)
    addStroke(
        colorPicker,
        Color3.fromRGB(65, 65, 72),
        0.1,
        1
    )

    local pickerTitle = createLabel(
        colorPicker,
        "COR DO ESP",
        12,
        UDim2.new(0, 15, 0, 12),
        Enum.Font.GothamBold,
        WHITE
    )

    pickerTitle.Size = UDim2.new(1, -50, 0, 22)
    pickerTitle.ZIndex = 71

    local closePicker = Instance.new("TextButton")
    closePicker.Size = UDim2.new(0, 28, 0, 28)
    closePicker.Position = UDim2.new(1, -38, 0, 8)
    closePicker.BackgroundColor3 = DARK_3
    closePicker.Text = "×"
    closePicker.TextColor3 = GRAY
    closePicker.TextSize = 18
    closePicker.Font = Enum.Font.GothamBold
    closePicker.AutoButtonColor = false
    closePicker.ZIndex = 71
    closePicker.Parent = colorPicker
    addCorner(closePicker, 8)

    connect(closePicker.MouseButton1Click, function()

        if colorPicker then
            colorPicker:Destroy()
            colorPicker = nil
        end

    end)

    local saturationBox = Instance.new("ImageLabel")
    saturationBox.Size = UDim2.new(0, 205, 0, 145)
    saturationBox.Position = UDim2.new(0, 17, 0, 48)
    saturationBox.BackgroundColor3 =
        Color3.fromHSV(hue, 1, 1)

    saturationBox.BorderSizePixel = 0
    saturationBox.Image = "rbxassetid://4155801252"
    saturationBox.ZIndex = 71
    saturationBox.Parent = colorPicker
    addCorner(saturationBox, 8)

    local satIndicator = Instance.new("Frame")
    satIndicator.Size = UDim2.new(0, 10, 0, 10)
    satIndicator.AnchorPoint =
        Vector2.new(0.5, 0.5)

    satIndicator.BackgroundTransparency = 1
    satIndicator.ZIndex = 73
    satIndicator.Parent = saturationBox

    local satStroke = Instance.new("UIStroke")
    satStroke.Color = WHITE
    satStroke.Thickness = 2
    satStroke.Parent = satIndicator

    addCorner(satIndicator, 10)

    local hueBar = Instance.new("Frame")
    hueBar.Size = UDim2.new(0, 205, 0, 14)
    hueBar.Position = UDim2.new(0, 17, 0, 203)
    hueBar.BorderSizePixel = 0
    hueBar.ZIndex = 71
    hueBar.Parent = colorPicker
    addCorner(hueBar, 7)

    local hueGradient = Instance.new("UIGradient")

    hueGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(
            0,
            Color3.fromRGB(255, 0, 0)
        ),

        ColorSequenceKeypoint.new(
            0.16,
            Color3.fromRGB(255, 0, 255)
        ),

        ColorSequenceKeypoint.new(
            0.33,
            Color3.fromRGB(0, 0, 255)
        ),

        ColorSequenceKeypoint.new(
            0.5,
            Color3.fromRGB(0, 255, 255)
        ),

        ColorSequenceKeypoint.new(
            0.66,
            Color3.fromRGB(0, 255, 0)
        ),

        ColorSequenceKeypoint.new(
            0.83,
            Color3.fromRGB(255, 255, 0)
        ),

        ColorSequenceKeypoint.new(
            1,
            Color3.fromRGB(255, 0, 0)
        )
    })

    hueGradient.Parent = hueBar

    local hueIndicator = Instance.new("Frame")
    hueIndicator.Size = UDim2.new(0, 5, 1, 4)
    hueIndicator.AnchorPoint =
        Vector2.new(0.5, 0.5)

    hueIndicator.Position =
        UDim2.new(hue, 0, 0.5, 0)

    hueIndicator.BackgroundColor3 = WHITE
    hueIndicator.ZIndex = 73
    hueIndicator.Parent = hueBar
    addCorner(hueIndicator, 3)

    local function updateSaturation(input)

        local relativeX = math.clamp(
            (input.Position.X -
                saturationBox.AbsolutePosition.X)
            / saturationBox.AbsoluteSize.X,
            0,
            1
        )

        local relativeY = math.clamp(
            (input.Position.Y -
                saturationBox.AbsolutePosition.Y)
            / saturationBox.AbsoluteSize.Y,
            0,
            1
        )

        saturation = relativeX
        value = 1 - relativeY

        satIndicator.Position =
            UDim2.new(
                saturation,
                0,
                1 - value,
                0
            )

        updateESPColor()
    end

    local function updateHue(input)

        hue = math.clamp(
            (input.Position.X -
                hueBar.AbsolutePosition.X)
            / hueBar.AbsoluteSize.X,
            0,
            1
        )

        hueIndicator.Position =
            UDim2.new(hue, 0, 0.5, 0)

        saturationBox.BackgroundColor3 =
            Color3.fromHSV(hue, 1, 1)

        updateESPColor()
    end

    local satDragging = false
    local hueDragging = false

    connect(saturationBox.InputBegan, function(input)

        if input.UserInputType ==
            Enum.UserInputType.MouseButton1
            or input.UserInputType ==
            Enum.UserInputType.Touch then

            satDragging = true
            updateSaturation(input)
        end

    end)

    connect(hueBar.InputBegan, function(input)

        if input.UserInputType ==
            Enum.UserInputType.MouseButton1
            or input.UserInputType ==
            Enum.UserInputType.Touch then

            hueDragging = true
            updateHue(input)
        end

    end)

    connect(UserInputService.InputChanged, function(input)

        if not colorPicker then
            return
        end

        if input.UserInputType ==
            Enum.UserInputType.MouseMovement
            or input.UserInputType ==
            Enum.UserInputType.Touch then

            if satDragging then
                updateSaturation(input)

            elseif hueDragging then
                updateHue(input)
            end
        end

    end)

    connect(UserInputService.InputEnded, function(input)

        if input.UserInputType ==
            Enum.UserInputType.MouseButton1
            or input.UserInputType ==
            Enum.UserInputType.Touch then

            satDragging = false
            hueDragging = false
        end

    end)
end

connect(
    colorButton.MouseButton1Click,
    createColorPicker
)

local function getCharacterParts(targetCharacter)

    local parts = {}

    for _, object in ipairs(
        targetCharacter:GetDescendants()
    ) do

        if object:IsA("BasePart") then
            table.insert(parts, object)
        end

    end

    return parts
end

local function getBoundingBox(targetCharacter, camera)

    local parts =
        getCharacterParts(targetCharacter)

    if #parts == 0 then
        return nil
    end

    local minX = math.huge
    local minY = math.huge
    local maxX = -math.huge
    local maxY = -math.huge

    local visible = false

    for _, part in ipairs(parts) do

        local cf = part.CFrame
        local size = part.Size / 2

        local corners = {
            cf * Vector3.new(
                -size.X,
                -size.Y,
                -size.Z
            ),

            cf * Vector3.new(
                -size.X,
                -size.Y,
                size.Z
            ),

            cf * Vector3.new(
                -size.X,
                size.Y,
                -size.Z
            ),

            cf * Vector3.new(
                -size.X,
                size.Y,
                size.Z
            ),

            cf * Vector3.new(
                size.X,
                -size.Y,
                -size.Z
            ),

            cf * Vector3.new(
                size.X,
                -size.Y,
                size.Z
            ),

            cf * Vector3.new(
                size.X,
                size.Y,
                -size.Z
            ),

            cf * Vector3.new(
                size.X,
                size.Y,
                size.Z
            )
        }

        for _, corner in ipairs(corners) do

            local screenPosition, onScreen =
                camera:WorldToViewportPoint(corner)

            if screenPosition.Z > 0 then

                minX = math.min(
                    minX,
                    screenPosition.X
                )

                minY = math.min(
                    minY,
                    screenPosition.Y
                )

                maxX = math.max(
                    maxX,
                    screenPosition.X
                )

                maxY = math.max(
                    maxY,
                    screenPosition.Y
                )

                if onScreen then
                    visible = true
                end
            end
        end
    end

    if not visible then
        return nil
    end

    return minX, minY, maxX, maxY
end

local function getOrCreateESP(target)

    if espObjects[target] then
        return espObjects[target]
    end

    local object = {}

    object.Gui = Instance.new("Frame")
    object.Gui.Name =
        "ESP_" .. target.Name

    object.Gui.BackgroundTransparency = 1
    object.Gui.Size = UDim2.fromScale(1, 1)
    object.Gui.Visible = false
    object.Gui.ZIndex = 10
    object.Gui.Parent = espLayer

    object.Box = Instance.new("Frame")
    object.Box.BackgroundTransparency = 1
    object.Box.BorderSizePixel = 0
    object.Box.ZIndex = 10
    object.Box.Parent = object.Gui

    addStroke(
        object.Box,
        tracerColor,
        0,
        1.5
    )

    object.Name = createLabel(
        object.Gui,
        target.DisplayName,
        10,
        UDim2.new(),
        Enum.Font.GothamBold,
        WHITE
    )

    object.Name.Size =
        UDim2.new(0, 150, 0, 18)

    object.Name.TextXAlignment =
        Enum.TextXAlignment.Center

    object.Name.ZIndex = 11

    object.Distance = createLabel(
        object.Gui,
        "",
        8,
        UDim2.new(),
        Enum.Font.GothamMedium,
        GRAY
    )

    object.Distance.Size =
        UDim2.new(0, 150, 0, 15)

    object.Distance.TextXAlignment =
        Enum.TextXAlignment.Center

    object.Distance.ZIndex = 11

    object.HealthBackground = Instance.new("Frame")
    object.HealthBackground.BackgroundColor3 =
        Color3.fromRGB(35, 35, 38)

    object.HealthBackground.BorderSizePixel = 0
    object.HealthBackground.ZIndex = 10
    object.HealthBackground.Parent = object.Gui
    addCorner(object.HealthBackground, 3)

    object.HealthBar = Instance.new("Frame")
    object.HealthBar.BackgroundColor3 = GREEN
    object.HealthBar.BorderSizePixel = 0
    object.HealthBar.ZIndex = 11
    object.HealthBar.Parent =
        object.HealthBackground

    addCorner(object.HealthBar, 3)

    object.Tracer = Instance.new("Frame")
    object.Tracer.AnchorPoint =
        Vector2.new(0, 0.5)

    object.Tracer.BorderSizePixel = 0
    object.Tracer.BackgroundColor3 =
        tracerColor

    object.Tracer.ZIndex = 9
    object.Tracer.Parent = object.Gui

    local skeletonNames = {
        "HeadTorso",
        "TorsoLeftUpper",
        "LeftUpperLeftLower",
        "LeftLowerLeftHand",
        "TorsoRightUpper",
        "RightUpperRightLower",
        "RightLowerRightHand",
        "TorsoLeftLower",
        "LeftLowerLeftFoot",
        "TorsoRightLower",
        "RightLowerRightFoot",
        "TorsoHead",
        "TorsoLeftArmR6",
        "TorsoRightArmR6"
    }

    object.Skeleton = {}

    for _, name in ipairs(skeletonNames) do

        local line = Instance.new("Frame")

        line.BorderSizePixel = 0
        line.BackgroundColor3 =
            tracerColor

        line.AnchorPoint =
            Vector2.new(0, 0.5)

        line.ZIndex = 10
        line.Visible = false
        line.Parent = object.Gui

        object.Skeleton[name] = line
    end

    espObjects[target] = object

    return object
end

local function hideESP(object)

    if object and object.Gui then
        object.Gui.Visible = false
    end

end

local function setLine(line, from, to)

    local delta = to - from
    local length = delta.Magnitude

    line.Position =
        UDim2.fromOffset(
            from.X,
            from.Y
        )

    line.Size =
        UDim2.new(
            0,
            length,
            0,
            1.5
        )

    line.Rotation =
        math.deg(
            math.atan2(
                delta.Y,
                delta.X
            )
        )

    line.BackgroundColor3 =
        tracerColor

    line.Visible = true
end

local function worldToScreen(camera, position)

    local point, visible =
        camera:WorldToViewportPoint(position)

    if not visible or point.Z <= 0 then
        return nil
    end

    return Vector2.new(
        point.X,
        point.Y
    )
end

local function drawSkeleton(
    targetCharacter,
    object,
    camera
)

    for _, line in pairs(object.Skeleton) do
        line.Visible = false
    end

    local humanoidTarget =
        targetCharacter:FindFirstChildOfClass(
            "Humanoid"
        )

    if not humanoidTarget then
        return
    end

    local joints = {}

    if humanoidTarget.RigType ==
        Enum.HumanoidRigType.R15 then

        local function part(name)
            return targetCharacter:FindFirstChild(name)
        end

        joints = {
            {
                "HeadTorso",
                part("Head"),
                part("UpperTorso")
            },

            {
                "TorsoLeftUpper",
                part("UpperTorso"),
                part("LeftUpperArm")
            },

            {
                "LeftUpperLeftLower",
                part("LeftUpperArm"),
                part("LeftLowerArm")
            },

            {
                "LeftLowerLeftHand",
                part("LeftLowerArm"),
                part("LeftHand")
            },

            {
                "TorsoRightUpper",
                part("UpperTorso"),
                part("RightUpperArm")
            },

            {
                "RightUpperRightLower",
                part("RightUpperArm"),
                part("RightLowerArm")
            },

            {
                "RightLowerRightHand",
                part("RightLowerArm"),
                part("RightHand")
            },

            {
                "TorsoLeftLower",
                part("UpperTorso"),
                part("LeftUpperLeg")
            },

            {
                "LeftLowerLeftFoot",
                part("LeftUpperLeg"),
                part("LeftLowerLeg")
            },

            {
                "TorsoRightLower",
                part("UpperTorso"),
                part("RightUpperLeg")
            },

            {
                "RightLowerRightFoot",
                part("RightUpperLeg"),
                part("RightLowerLeg")
            },

            {
                "TorsoHead",
                part("UpperTorso"),
                part("Head")
            }
        }

    else

        local function part(name)
            return targetCharacter:FindFirstChild(name)
        end

        joints = {
            {
                "TorsoHead",
                part("Torso"),
                part("Head")
            },

            {
                "TorsoLeftArmR6",
                part("Torso"),
                part("Left Arm")
            },

            {
                "TorsoRightArmR6",
                part("Torso"),
                part("Right Arm")
            },

            {
                "TorsoLeftLower",
                part("Torso"),
                part("Left Leg")
            },

            {
                "TorsoRightLower",
                part("Torso"),
                part("Right Leg")
            }
        }
    end

    for _, data in ipairs(joints) do

        local lineName = data[1]
        local p1 = data[2]
        local p2 = data[3]

        if p1 and p2 then

            local a =
                worldToScreen(
                    camera,
                    p1.Position
                )

            local b =
                worldToScreen(
                    camera,
                    p2.Position
                )

            if a and b and
                object.Skeleton[lineName] then

                setLine(
                    object.Skeleton[lineName],
                    a,
                    b
                )
            end
        end
    end
end

local function updateESP()

    local camera =
        Workspace.CurrentCamera

    if not camera then
        return
    end

    local shouldShow =
        espBox
        or espTracer
        or espHealth
        or espDistance
        or espSkeleton

    if not shouldShow then

        for _, object in pairs(espObjects) do
            hideESP(object)
        end

        return
    end

    for _, target in ipairs(
        Players:GetPlayers()
    ) do

        if target ~= player then

            local targetCharacter =
                target.Character

            local targetHumanoid =
                targetCharacter
                and targetCharacter:
                    FindFirstChildOfClass("Humanoid")

            local targetRoot =
                targetCharacter
                and targetCharacter:
                    FindFirstChild(
                        "HumanoidRootPart"
                    )

            if targetCharacter
                and targetHumanoid
                and targetRoot
                and targetHumanoid.Health > 0 then

                local object =
                    getOrCreateESP(target)

                local minX, minY, maxX, maxY =
                    getBoundingBox(
                        targetCharacter,
                        camera
                    )

                if minX and minY
                    and maxX and maxY then

                    object.Gui.Visible = true

                    local width =
                        math.max(
                            maxX - minX,
                            4
                        )

                    local height =
                        math.max(
                            maxY - minY,
                            4
                        )

                    object.Box.Position =
                        UDim2.fromOffset(
                            minX,
                            minY
                        )

                    object.Box.Size =
                        UDim2.fromOffset(
                            width,
                            height
                        )

                    object.Box.Visible = espBox

                    object.Name.Position =
                        UDim2.fromOffset(
                            minX + width / 2 - 75,
                            minY - 20
                        )

                    object.Name.Text =
                        target.DisplayName

                    object.Name.Visible =
                        espBox

                    if rootPart then

                        local distance =
                            (
                                rootPart.Position
                                - targetRoot.Position
                            ).Magnitude

                        object.Distance.Position =
                            UDim2.fromOffset(
                                minX + width / 2 - 75,
                                maxY + 3
                            )

                        object.Distance.Text =
                            math.floor(distance)
                            .. " studs"

                        object.Distance.Visible =
                            espDistance

                        local screenRoot =
                            worldToScreen(
                                camera,
                                targetRoot.Position
                            )

                        if screenRoot then

                            local screenSize =
                                camera.ViewportSize

                            local startPoint =
                                Vector2.new(
                                    screenSize.X / 2,
                                    screenSize.Y
                                )

                            local delta =
                                screenRoot
                                - startPoint

                            object.Tracer.Position =
                                UDim2.fromOffset(
                                    startPoint.X,
                                    startPoint.Y
                                )

                            object.Tracer.Size =
                                UDim2.new(
                                    0,
                                    delta.Magnitude,
                                    0,
                                    1
                                )

                            object.Tracer.Rotation =
                                math.deg(
                                    math.atan2(
                                        delta.Y,
                                        delta.X
                                    )
                                )

                            object.Tracer.BackgroundColor3 =
                                tracerColor

                            object.Tracer.Visible =
                                espTracer

                        else

                            object.Tracer.Visible =
                                false
                        end

                    else

                        object.Tracer.Visible =
                            false
                    end

                    local healthRatio =
                        math.clamp(
                            targetHumanoid.Health
                            / math.max(
                                targetHumanoid.MaxHealth,
                                1
                            ),
                            0,
                            1
                        )

                    object.HealthBackground.Position =
                        UDim2.fromOffset(
                            minX - 7,
                            minY
                        )

                    object.HealthBackground.Size =
                        UDim2.fromOffset(
                            4,
                            height
                        )

                    object.HealthBar.AnchorPoint =
                        Vector2.new(0, 1)

                    object.HealthBar.Position =
                        UDim2.new(0, 0, 1, 0)

                    object.HealthBar.Size =
                        UDim2.new(
                            1,
                            0,
                            healthRatio,
                            0
                        )

                    object.HealthBar.BackgroundColor3 =
                        Color3.fromHSV(
                            healthRatio * 0.33,
                            0.9,
                            0.9
                        )

                    object.HealthBackground.Visible =
                        espHealth

                    if espSkeleton then

                        drawSkeleton(
                            targetCharacter,
                            object,
                            camera
                        )

                    else

                        for _, line in pairs(
                            object.Skeleton
                        ) do
                            line.Visible = false
                        end
                    end

                else

                    hideESP(object)
                end

            else

                if espObjects[target] then
                    hideESP(
                        espObjects[target]
                    )
                end
            end
        end
    end
end

connect(
    RunService.RenderStepped,
    function(delta)

        if destroyed then
            return
        end

        espUpdateAccumulator += delta

        local interval =
            lowEndMode
            and 0.10
            or 0.03

        if espUpdateAccumulator >= interval then

            espUpdateAccumulator = 0
            updateESP()
        end
    end
)

connect(
    Players.PlayerRemoving,
    function(target)

        local object =
            espObjects[target]

        if object then

            object.Gui:Destroy()
            espObjects[target] = nil
        end
    end
)

createSectionTitle(
    tpPage,
    "TELEPORTE",
    "Selecione um jogador para ir até a posição dele."
)

local searchCard = createCard(tpPage, 48)

local searchBox = Instance.new("TextBox")
searchBox.Size =
    UDim2.new(1, -20, 0, 30)

searchBox.Position =
    UDim2.new(0, 10, 0, 9)

searchBox.BackgroundColor3 =
    DARK_3

searchBox.BorderSizePixel = 0
searchBox.PlaceholderText =
    "Pesquisar jogador..."

searchBox.PlaceholderColor3 =
    DARK_GRAY

searchBox.Text = ""
searchBox.TextColor3 = WHITE
searchBox.TextSize = 10
searchBox.Font = Enum.Font.Gotham
searchBox.ClearTextOnFocus = false
searchBox.ZIndex = 25
searchBox.Parent = searchCard
addCorner(searchBox, 8)

local playerList = Instance.new("ScrollingFrame")
playerList.Size =
    UDim2.new(1, 0, 0, 190)

playerList.BackgroundTransparency = 1
playerList.BorderSizePixel = 0
playerList.ScrollBarThickness = 2
playerList.ScrollBarImageColor3 = RED
playerList.CanvasSize = UDim2.new()
playerList.AutomaticCanvasSize =
    Enum.AutomaticSize.Y

playerList.ZIndex = 23
playerList.Parent = tpPage

local playerLayout =
    Instance.new("UIListLayout")

playerLayout.Padding =
    UDim.new(0, 6)

playerLayout.HorizontalAlignment =
    Enum.HorizontalAlignment.Center

playerLayout.Parent =
    playerList

local function teleportTo(target)

    if not target
        or target == player then
        return
    end

    if not rootPart then
        return
    end

    local targetCharacter =
        target.Character

    local targetRoot =
        targetCharacter
        and targetCharacter:
            FindFirstChild(
                "HumanoidRootPart"
            )

    if targetRoot then

        rootPart.CFrame =
            targetRoot.CFrame
            * CFrame.new(0, 0, 3)
    end
end

local function refreshPlayerList()

    for _, object in ipairs(
        playerList:GetChildren()
    ) do

        if object:IsA("TextButton") then
            object:Destroy()
        end
    end

    local search =
        string.lower(
            searchBox.Text or ""
        )

    for _, target in ipairs(
        Players:GetPlayers()
    ) do

        if target ~= player then

            local display =
                string.lower(
                    target.DisplayName
                )

            local username =
                string.lower(
                    target.Name
                )

            if search == ""
                or string.find(
                    display,
                    search,
                    1,
                    true
                )
                or string.find(
                    username,
                    search,
                    1,
                    true
                ) then

                local button =
                    Instance.new("TextButton")

                button.Size =
                    UDim2.new(1, 0, 0, 47)

                button.BackgroundColor3 =
                    DARK_2

                button.BorderSizePixel = 0
                button.Text = ""
                button.AutoButtonColor = false
                button.ZIndex = 24
                button.Parent = playerList

                addCorner(button, 10)

                addStroke(
                    button,
                    Color3.fromRGB(
                        40,
                        40,
                        47
                    ),
                    0.4,
                    1
                )

                local avatar =
                    Instance.new("Frame")

                avatar.Size =
                    UDim2.new(0, 31, 0, 31)

                avatar.Position =
                    UDim2.new(
                        0,
                        8,
                        0.5,
                        -15
                    )

                avatar.BackgroundColor3 =
                    Color3.fromRGB(
                        35,
                        35,
                        41
                    )

                avatar.BorderSizePixel = 0
                avatar.ZIndex = 25
                avatar.Parent = button

                addCorner(avatar, 9)

                local avatarText =
                    createLabel(
                        avatar,
                        string.upper(
                            string.sub(
                                target.DisplayName,
                                1,
                                1
                            )
                        ),
                        11,
                        UDim2.new(),
                        Enum.Font.GothamBold,
                        RED
                    )

                avatarText.Size =
                    UDim2.fromScale(1, 1)

                avatarText.TextXAlignment =
                    Enum.TextXAlignment.Center

                avatarText.TextYAlignment =
                    Enum.TextYAlignment.Center

                avatarText.ZIndex = 26

                local displayLabel =
                    createLabel(
                        button,
                        target.DisplayName,
                        10,
                        UDim2.new(
                            0,
                            49,
                            0,
                            7
                        ),
                        Enum.Font.GothamBold,
                        WHITE
                    )

                displayLabel.Size =
                    UDim2.new(
                        1,
                        -60,
                        0,
                        17
                    )

                displayLabel.TextTruncate =
                    Enum.TextTruncate.AtEnd

                displayLabel.ZIndex = 25

                local userLabel =
                    createLabel(
                        button,
                        "@" .. target.Name,
                        8,
                        UDim2.new(
                            0,
                            49,
                            0,
                            25
                        ),
                        Enum.Font.Gotham,
                        GRAY
                    )

                userLabel.Size =
                    UDim2.new(
                        1,
                        -60,
                        0,
                        14
                    )

                userLabel.TextTruncate =
                    Enum.TextTruncate.AtEnd

                userLabel.ZIndex = 25

                local arrow =
                    createLabel(
                        button,
                        "›",
                        18,
                        UDim2.new(
                            1,
                            -28,
                            0,
                            10
                        ),
                        Enum.Font.GothamBold,
                        RED
                    )

                arrow.Size =
                    UDim2.new(
                        0,
                        18,
                        0,
                        25
                    )

                arrow.TextXAlignment =
                    Enum.TextXAlignment.Center

                arrow.ZIndex = 25

                connect(
                    button.MouseButton1Click,
                    function()

                        teleportTo(target)

                        tween(
                            button,
                            TweenInfo.new(0.12),
                            {
                                BackgroundColor3 =
                                    Color3.fromRGB(
                                        45,
                                        22,
                                        24
                                    )
                            }
                        )

                        task.delay(
                            0.18,
                            function()

                                if button
                                    and button.Parent then

                                    tween(
                                        button,
                                        TweenInfo.new(0.15),
                                        {
                                            BackgroundColor3 =
                                                DARK_2
                                        }
                                    )
                                end
                            end
                        )
                    end
                )
            end
        end
    end
end

connect(
    searchBox:GetPropertyChangedSignal("Text"),
    refreshPlayerList
)

connect(
    Players.PlayerAdded,
    refreshPlayerList
)

connect(
    Players.PlayerRemoving,
    refreshPlayerList
)

createSectionTitle(
    configPage,
    "CONFIGURAÇÕES",
    "Controle o desempenho e o comportamento do painel."
)

local profileCard = createCard(
    configPage,
    78
)

local profileTitle =
    createLabel(
        profileCard,
        "PERFIL ATUAL",
        9,
        UDim2.new(0, 13, 0, 9),
        Enum.Font.GothamBold,
        GRAY
    )

profileTitle.Size =
    UDim2.new(1, -20, 0, 16)

local profileName =
    createLabel(
        profileCard,
        player.DisplayName,
        14,
        UDim2.new(0, 13, 0, 29),
        Enum.Font.GothamBold,
        WHITE
    )

profileName.Size =
    UDim2.new(0.65, 0, 0, 20)

local profileUser =
    createLabel(
        profileCard,
        "@" .. player.Name,
        8,
        UDim2.new(0, 13, 0, 50),
        Enum.Font.Gotham,
        GRAY
    )

profileUser.Size =
    UDim2.new(0.65, 0, 0, 16)

local profileStatus =
    createLabel(
        profileCard,
        "● ONLINE",
        9,
        UDim2.new(1, -85, 0, 30),
        Enum.Font.GothamBold,
        GREEN
    )

profileStatus.Size =
    UDim2.new(0, 70, 0, 20)

profileStatus.TextXAlignment =
    Enum.TextXAlignment.Right

local statusCard =
    createCard(
        configPage,
        56
    )

local statusTitle =
    createLabel(
        statusCard,
        "STATUS DO PAINEL",
        8,
        UDim2.new(0, 13, 0, 8),
        Enum.Font.GothamBold,
        GRAY
    )

statusTitle.Size =
    UDim2.new(1, -26, 0, 15)

local statusText =
    createLabel(
        statusCard,
        "MY - KASSA ativo",
        11,
        UDim2.new(0, 13, 0, 27),
        Enum.Font.GothamBold,
        GREEN
    )

statusText.Size =
    UDim2.new(1, -26, 0, 20)

local function setStatus(text, color)

    statusText.Text = text
    statusText.TextColor3 =
        color or GREEN

end

local cleanButton =
    createButton(
        configPage,
        "🧹   CLEAN CACHE",
        function()

            if cleanBusy then
                return
            end

            cleanBusy = true

            setStatus(
                "Limpando cache...",
                GRAY
            )

            for target, object in pairs(
                espObjects
            ) do

                if not target.Parent then

                    if object.Gui then
                        object.Gui:Destroy()
                    end

                    espObjects[target] =
                        nil
                end
            end

            for object in pairs(
                originalCollision
            ) do

                if not object
                    or not object.Parent then

                    originalCollision[object] =
                        nil
                end
            end

            if colorPicker then
                colorPicker:Destroy()
                colorPicker = nil
            end

            collectgarbage("collect")

            task.delay(
                0.35,
                function()

                    if destroyed then
                        return
                    end

                    cleanBusy = false

                    setStatus(
                        "Cache do painel limpo",
                        GREEN
                    )
                end
            )
        end,
        42
    )

cleanButton.BackgroundColor3 =
    Color3.fromRGB(
        27,
        27,
        32
    )

createToggle(
    configPage,
    "⚡ CELULAR FRACO",
    "Reduz a frequência das atualizações do ESP.",
    false,
    function(value)

        lowEndMode = value

        if value then

            setStatus(
                "Modo leve ativado • ESP reduzido",
                GREEN
            )

        else

            setStatus(
                "Modo normal ativado",
                GREEN
            )
        end
    end
)

createToggle(
    configPage,
    "🔥 ULTRA LOW MEMORY",
    "Reduz efeitos visuais e iluminação do mapa.",
    false,
    function(value)

        ultraLowMemory = value

        if value then

            applyUltraLowMemory()

            setStatus(
                "Ultra Low Memory ativado",
                GREEN
            )

        else

            restoreUltraLowMemory()

            setStatus(
                "Ultra Low Memory desativado",
                GREEN
            )
        end
    end
)

local infoCard =
    createCard(
        configPage,
        73
    )

local infoTitle =
    createLabel(
        infoCard,
        "DESEMPENHO",
        9,
        UDim2.new(0, 13, 0, 8),
        Enum.Font.GothamBold,
        GRAY
    )

infoTitle.Size =
    UDim2.new(1, -26, 0, 15)

local infoText =
    createLabel(
        infoCard,
        "Celular fraco reduz somente atualizações visuais.\nFly, TP e controles continuam funcionando.",
        8,
        UDim2.new(0, 13, 0, 27),
        Enum.Font.Gotham,
        GRAY
    )

infoText.Size =
    UDim2.new(1, -26, 0, 35)

infoText.TextWrapped = true

local performanceCard =
    createCard(
        configPage,
        62
    )

local performanceTitle =
    createLabel(
        performanceCard,
        "PERFORMANCE",
        8,
        UDim2.new(0, 13, 0, 8),
        Enum.Font.GothamBold,
        GRAY
    )

performanceTitle.Size =
    UDim2.new(1, -26, 0, 15)

local performanceText =
    createLabel(
        performanceCard,
        "MEM -- MB     •     FPS --     •     PING -- ms",
        9,
        UDim2.new(0, 13, 0, 29),
        Enum.Font.GothamBold,
        WHITE
    )

performanceText.Size =
    UDim2.new(1, -26, 0, 20)

performanceText.TextXAlignment =
    Enum.TextXAlignment.Center

local destroyButton =
    createButton(
        configPage,
        "×   DESTRUIR INTERFACE",
        function()

            if destroyed then
                return
            end

            unloadGUI()
        end,
        42
    )

destroyButton.BackgroundColor3 =
    Color3.fromRGB(
        60,
        20,
        22
    )

applyUltraLowMemory = function()

    if not ultraLowMemory then
        return
    end

    for _, object in ipairs(
        Workspace:GetDescendants()
    ) do

        if object:IsA("ParticleEmitter") then

            if ultraParticles[object] == nil then
                ultraParticles[object] =
                    object.Enabled
            end

            object.Enabled = false

        elseif object:IsA("Trail") then

            if ultraTrails[object] == nil then
                ultraTrails[object] =
                    object.Enabled
            end

            object.Enabled = false

        elseif object:IsA("Beam") then

            if ultraBeams[object] == nil then
                ultraBeams[object] =
                    object.Enabled
            end

            object.Enabled = false

        elseif object:IsA("PointLight")
            or object:IsA("SpotLight")
            or object:IsA("SurfaceLight") then

            if ultraLights[object] == nil then
                ultraLights[object] =
                    object.Enabled
            end

            object.Enabled = false

        elseif object:IsA("BasePart") then

            if ultraShadows[object] == nil then
                ultraShadows[object] =
                    object.CastShadow
            end

            object.CastShadow = false
        end
    end

    for _, object in ipairs(
        Lighting:GetDescendants()
    ) do

        if object:IsA("BloomEffect")
            or object:IsA("BlurEffect")
            or object:IsA("ColorCorrectionEffect")
            or object:IsA("SunRaysEffect")
            or object:IsA("DepthOfFieldEffect") then

            if ultraEffects[object] == nil then
                ultraEffects[object] =
                    object.Enabled
            end

            object.Enabled = false
        end
    end
end

restoreUltraLowMemory = function()

    for object, value in pairs(
        ultraParticles
    ) do

        if object and object.Parent then
            object.Enabled = value
        end
    end

    for object, value in pairs(
        ultraTrails
    ) do

        if object and object.Parent then
            object.Enabled = value
        end
    end

    for object, value in pairs(
        ultraBeams
    ) do

        if object and object.Parent then
            object.Enabled = value
        end
    end

    for object, value in pairs(
        ultraLights
    ) do

        if object and object.Parent then
            object.Enabled = value
        end
    end

    for object, value in pairs(
        ultraEffects
    ) do

        if object and object.Parent then
            object.Enabled = value
        end
    end

    for object, value in pairs(
        ultraShadows
    ) do

        if object and object.Parent then
            object.CastShadow = value
        end
    end

    table.clear(ultraParticles)
    table.clear(ultraTrails)
    table.clear(ultraBeams)
    table.clear(ultraLights)
    table.clear(ultraEffects)
    table.clear(ultraShadows)
end

connect(
    RunService.Stepped,
    function()

        if destroyed then
            return
        end

        if isNoclip and character then

            for _, object in ipairs(
                character:GetDescendants()
            ) do

                if object:IsA("BasePart") then
                    object.CanCollide = false
                end
            end
        end
    end
)

connect(
    RunService.RenderStepped,
    function(delta)

        if destroyed then
            return
        end

        if not isFlying then

            flyCurrentVelocity =
                Vector3.zero

            return
        end

        if not rootPart
            or not humanoid
            or not flyVelocity
            or not flyOrientation then

            return
        end

        local camera =
            Workspace.CurrentCamera

        if not camera then
            return
        end

        local moveVector =
            Vector3.zero

        if controlModule then

            pcall(function()
                moveVector =
                    controlModule:GetMoveVector()
            end)
        end

        local inputX =
            math.clamp(
                moveVector.X,
                -1,
                1
            )

        local inputForward =
            math.clamp(
                -moveVector.Z,
                -1,
                1
            )

        local inputMagnitude =
            math.clamp(
                moveVector.Magnitude,
                0,
                1
            )

        if inputMagnitude <
            FLY_INPUT_DEADZONE then

            inputMagnitude = 0
            inputX = 0
            inputForward = 0
        end

        local cameraCF =
            camera.CFrame

        local cameraLook =
            cameraCF.LookVector

        local cameraRight =
            cameraCF.RightVector

        local flatLook =
            Vector3.new(
                cameraLook.X,
                0,
                cameraLook.Z
            )

        local flatRight =
            Vector3.new(
                cameraRight.X,
                0,
                cameraRight.Z
            )

        if flatLook.Magnitude >
            0.001 then

            flatLook =
                flatLook.Unit
        end

        if flatRight.Magnitude >
            0.001 then

            flatRight =
                flatRight.Unit
        end

        local horizontalDirection =
            flatLook * inputForward
            + flatRight * inputX

        if horizontalDirection.Magnitude >
            1 then

            horizontalDirection =
                horizontalDirection.Unit
        end

        local verticalAmount = 0

        if inputMagnitude > 0 then

            verticalAmount =
                cameraLook.Y
                * inputMagnitude

        end

        local targetDirection =
            Vector3.new(
                horizontalDirection.X,
                verticalAmount,
                horizontalDirection.Z
            )

        if targetDirection.Magnitude >
            1 then

            targetDirection =
                targetDirection.Unit
        end

        local targetVelocity =
            Vector3.zero

        if inputMagnitude > 0 then

            targetVelocity =
                targetDirection
                * flySpeed
        end

        local response

        if inputMagnitude > 0 then
            response = flyAcceleration
        else
            response = flyDeceleration
        end

        local alpha =
            math.clamp(
                response * delta,
                0,
                1
            )

        flyCurrentVelocity =
            flyCurrentVelocity:Lerp(
                targetVelocity,
                alpha
            )

        if flyCurrentVelocity.Magnitude <
            0.05
            and inputMagnitude == 0 then

            flyCurrentVelocity =
                Vector3.zero
        end

        flyVelocity.VectorVelocity =
            flyCurrentVelocity

        local facingDirection =
            Vector3.new(
                cameraLook.X,
                0,
                cameraLook.Z
            )

        if facingDirection.Magnitude >
            0.01 then

            facingDirection =
                facingDirection.Unit

            flyOrientation.CFrame =
                CFrame.lookAt(
                    rootPart.Position,
                    rootPart.Position
                    + facingDirection
                )
        end

        pcall(function()

            humanoid:ChangeState(
                Enum.HumanoidStateType.Physics
            )

        end)
    end
)

local ultraTimer = 0

connect(
    RunService.Heartbeat,
    function(delta)

        if destroyed then
            return
        end

        ultraTimer += delta

        if ultraLowMemory
            and ultraTimer >= 1 then

            ultraTimer = 0
            applyUltraLowMemory()
        end
    end
)

local frames = 0
local frameTime = 0
local performanceTimer = 0

connect(
    RunService.RenderStepped,
    function(delta)

        if destroyed then
            return
        end

        frames += 1
        frameTime += delta
        performanceTimer += delta

        local interval =
            lowEndMode
            and 1
            or 0.5

        if performanceTimer >= interval then

            local fps = 0

            if frameTime > 0 then

                fps = math.floor(
                    frames / frameTime
                )
            end

            local memory = 0
            local ping = 0

            pcall(function()

                memory =
                    math.floor(
                        Stats:GetTotalMemoryUsageMb()
                    )

            end)

            pcall(function()

                ping =
                    math.floor(
                        player:GetNetworkPing()
                        * 1000
                    )

            end)

            performanceText.Text =
                "MEM "
                .. tostring(memory)
                .. " MB     •     FPS "
                .. tostring(fps)
                .. "     •     PING "
                .. tostring(ping)
                .. " ms"

            frames = 0
            frameTime = 0
            performanceTimer = 0
        end
    end
)

connect(
    Workspace.DescendantAdded,
    function(object)

        if not ultraLowMemory then
            return
        end

        task.defer(function()

            if destroyed
                or not object
                or not object.Parent then

                return
            end

            if object:IsA(
                "ParticleEmitter"
            ) then

                ultraParticles[object] =
                    object.Enabled

                object.Enabled = false

            elseif object:IsA("Trail") then

                ultraTrails[object] =
                    object.Enabled

                object.Enabled = false

            elseif object:IsA("Beam") then

                ultraBeams[object] =
                    object.Enabled

                object.Enabled = false

            elseif object:IsA("PointLight")
                or object:IsA("SpotLight")
                or object:IsA("SurfaceLight") then

                ultraLights[object] =
                    object.Enabled

                object.Enabled = false

            elseif object:IsA("BasePart") then

                ultraShadows[object] =
                    object.CastShadow

                object.CastShadow = false
            end
        end)
    end
)

connect(
    Lighting.DescendantAdded,
    function(object)

        if not ultraLowMemory then
            return
        end

        task.defer(function()

            if destroyed
                or not object
                or not object.Parent then

                return
            end

            if object:IsA("BloomEffect")
                or object:IsA("BlurEffect")
                or object:IsA("ColorCorrectionEffect")
                or object:IsA("SunRaysEffect")
                or object:IsA("DepthOfFieldEffect") then

                ultraEffects[object] =
                    object.Enabled

                object.Enabled = false
            end
        end)
    end
)

local currentPage = nil

local function switchTab(name)

    if currentPage == name then
        return
    end

    currentPage = name

    for tabName, data in pairs(tabs) do

        local selected =
            tabName == name

        if selected then

            tween(
                data.Button,
                TweenInfo.new(0.18),
                {
                    BackgroundColor3 =
                        Color3.fromRGB(
                            48,
                            22,
                            25
                        )
                }
            )

            tween(
                data.Icon,
                TweenInfo.new(0.18),
                {
                    TextColor3 = RED
                }
            )

            tween(
                data.Label,
                TweenInfo.new(0.18),
                {
                    TextColor3 = WHITE
                }
            )

        else

            tween(
                data.Button,
                TweenInfo.new(0.18),
                {
                    BackgroundColor3 =
                        DARK_2
                }
            )

            tween(
                data.Icon,
                TweenInfo.new(0.18),
                {
                    TextColor3 = GRAY
                }
            )

            tween(
                data.Label,
                TweenInfo.new(0.18),
                {
                    TextColor3 = GRAY
                }
            )
        end
    end

    for pageName, page in pairs(pages) do

        page.Visible =
            pageName == name
    end

    if name == "TP" then
        refreshPlayerList()
    end
end

for name, data in pairs(tabs) do

    connect(
        data.Button.MouseButton1Click,
        function()
            switchTab(name)
        end
    )
end

local menuOpen = false
local menuAnimating = false

local normalSize =
    UDim2.new(
        0,
        285,
        0,
        390
    )

local closedSize =
    UDim2.new(
        0,
        250,
        0,
        330
    )

local function openMenu()

    if menuAnimating
        or destroyed then

        return
    end

    menuAnimating = true
    menuOpen = true

    mainFrame.Visible = true
    mainFrame.Size = closedSize

    tween(
        mainFrame,
        TweenInfo.new(
            0.32,
            Enum.EasingStyle.Back,
            Enum.EasingDirection.Out
        ),
        {
            Size = normalSize
        }
    )

    task.delay(
        0.32,
        function()
            menuAnimating = false
        end
    )
end

local function closeMenu()

    if menuAnimating
        or destroyed then

        return
    end

    menuAnimating = true
    menuOpen = false

    local animation =
        tween(
            mainFrame,
            TweenInfo.new(
                0.22,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.In
            ),
            {
                Size = closedSize
            }
        )

    animation.Completed:Connect(
        function()

            if destroyed then
                return
            end

            mainFrame.Visible = false
            menuAnimating = false
        end
    )
end

connect(
    toggleButton.MouseButton1Click,
    function()

        if menuOpen then
            closeMenu()
        else
            openMenu()
        end
    end
)

connect(
    toggleButton.MouseEnter,
    function()

        tween(
            toggleButton,
            TweenInfo.new(0.15),
            {
                BackgroundColor3 =
                    Color3.fromRGB(
                        38,
                        20,
                        23
                    )
            }
        )
    end
)

connect(
    toggleButton.MouseLeave,
    function()

        tween(
            toggleButton,
            TweenInfo.new(0.15),
            {
                BackgroundColor3 =
                    DARK_2
            }
        )
    end
)

unloadGUI = function()

    if destroyed then
        return
    end

    destroyed = true

    if ultraLowMemory then
        restoreUltraLowMemory()
    end

    isFlying = false
    isNoclip = false
    flyCurrentVelocity = Vector3.zero

    if flyVelocity then

        flyVelocity.VectorVelocity =
            Vector3.zero

        flyVelocity:Destroy()
        flyVelocity = nil
    end

    if flyOrientation then
        flyOrientation:Destroy()
        flyOrientation = nil
    end

    if flyAttachment then
        flyAttachment:Destroy()
        flyAttachment = nil
    end

    if humanoid then

        humanoid.AutoRotate = true

        pcall(function()

            humanoid:ChangeState(
                Enum.HumanoidStateType.GettingUp
            )

        end)
    end

    for object, collision in pairs(
        originalCollision
    ) do

        if object and object.Parent then
            object.CanCollide = collision
        end
    end

    table.clear(originalCollision)

    for _, object in pairs(
        espObjects
    ) do

        if object.Gui then
            object.Gui:Destroy()
        end
    end

    table.clear(espObjects)

    disconnectAll()

    if colorPicker then
        colorPicker:Destroy()
        colorPicker = nil
    end

    if espGui then
        espGui:Destroy()
    end

    if screenGui then
        screenGui:Destroy()
    end
end

connect(
    player.CharacterAdded,
    function(char)

        if destroyed then
            return
        end

        isFlying = false
        isNoclip = false
        flyCurrentVelocity = Vector3.zero

        if flyVelocity then
            flyVelocity:Destroy()
            flyVelocity = nil
        end

        if flyOrientation then
            flyOrientation:Destroy()
            flyOrientation = nil
        end

        if flyAttachment then
            flyAttachment:Destroy()
            flyAttachment = nil
        end

        table.clear(originalCollision)

        updateCharacter(char)

        task.delay(
            0.5,
            function()

                if destroyed then
                    return
                end

                if ultraLowMemory then
                    applyUltraLowMemory()
                end
            end
        )
    end
)

local function playIntro()

    local steps = {
        {15, "Iniciando..."},
        {30, "Verificando ambiente..."},
        {45, "Lendo arquivos..."},
        {60, "Descompactando recursos..."},
        {72, "Inicializando módulos..."},
        {84, "Preparando interface..."},
        {94, "Carregando MY - KASSA..."},
        {100, "Concluído!"}
    }

    for _, step in ipairs(steps) do

        if destroyed then
            return
        end

        local percentage = step[1]
        local status = step[2]

        introStatus.Text = status
        introPercent.Text =
            tostring(percentage) .. "%"

        tween(
            progressBar,
            TweenInfo.new(
                0.28,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            ),
            {
                Size =
                    UDim2.new(
                        percentage / 100,
                        0,
                        1,
                        0
                    )
            }
        )

        task.wait(0.28)
    end

    task.wait(0.35)

    if destroyed then
        return
    end

    tween(
        introCard,
        TweenInfo.new(
            0.35,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.In
        ),
        {
            Position =
                UDim2.new(
                    0.5,
                    -175,
                    0.5,
                    -155
                )
        }
    )

    tween(
        introFrame,
        TweenInfo.new(
            0.45,
            Enum.EasingStyle.Quad
        ),
        {
            BackgroundTransparency = 1
        }
    )

    task.wait(0.4)

    introFrame.Visible = false
    toggleButton.Visible = true

    switchTab("Voo")
    openMenu()
end

switchTab("Voo")

mainFrame.Visible = false
toggleButton.Visible = false
introFrame.Visible = true

task.spawn(playIntro)
