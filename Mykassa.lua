local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local MasterControl = require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"):WaitForChild("ControlModule"))

-- Atualiza referências ao renascer (Respawn)
player.CharacterAdded:Connect(function(newChar)
	character = newChar
	humanoid = character:WaitForChild("Humanoid")
	rootPart = character:WaitForChild("HumanoidRootPart")
end)

-- Variáveis de Estado do Voo
local isFlying = false
local isFlyLoading = false
local flySpeed = 60
local verticalVelocity = 0

-- Variáveis de Estado do Noclip
local isNoclip = false
local isNoclipLoading = false

-- Controle de abertura pela 1ª vez
local isFirstActivation = true

local bodyVelocity = nil
local bodyGyro = nil
local renderConnection = nil
local noclipConnection = nil

--------------------------------------------------------------------------------
-- CRIAÇÃO DA INTERFACE GRÁFICA (TEMA VERMELHO E PRETO)
--------------------------------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlySystemGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Botão Abrir / Fechar Menu (Texto: MY - KASSA)
local toggleMenuBtn = Instance.new("TextButton")
toggleMenuBtn.Size = UDim2.new(0, 140, 0, 40)
toggleMenuBtn.Position = UDim2.new(0.02, 0, 0.15, 0)
toggleMenuBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
toggleMenuBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
toggleMenuBtn.Text = "MY  -  KASSA"
toggleMenuBtn.Font = Enum.Font.GothamBlack
toggleMenuBtn.TextSize = 15
toggleMenuBtn.TextWrapped = true
toggleMenuBtn.Parent = screenGui

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = toggleMenuBtn

local btnStroke = Instance.new("UIStroke")
btnStroke.Color = Color3.fromRGB(200, 0, 0)
btnStroke.Thickness = 2
btnStroke.Parent = toggleMenuBtn

--------------------------------------------------------------------------------
-- ANIMAÇÕES DO BOTÃO "MY - KASSA"
--------------------------------------------------------------------------------
task.spawn(function()
	local hue = 0
	while true do
		hue = (hue + 0.005) % 1
		local rainbowColor = Color3.fromHSV(hue, 0.8, 1)
		toggleMenuBtn.TextColor3 = rainbowColor
		btnStroke.Color = rainbowColor
		task.wait(0.03)
	end
end)

task.spawn(function()
	local tweenInfo = TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
	local tweenGlow = TweenService:Create(btnStroke, tweenInfo, {Transparency = 0.6})
	tweenGlow:Play()
end)

--------------------------------------------------------------------------------
-- TELA DE APRESENTAÇÃO ANIMADA (PRIMEIRA ATIVAÇÃO)
--------------------------------------------------------------------------------
local introFrame = Instance.new("Frame")
introFrame.Name = "IntroFrame"
introFrame.Size = UDim2.new(1, 0, 1, 0)
introFrame.Position = UDim2.new(0, 0, 0, 0)
introFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
introFrame.BackgroundTransparency = 1
introFrame.Visible = false
introFrame.ZIndex = 10
introFrame.Parent = screenGui

local introLabel = Instance.new("TextLabel")
introLabel.Size = UDim2.new(0, 300, 0, 80)
introLabel.Position = UDim2.new(0.5, -150, 0.5, -40)
introLabel.BackgroundTransparency = 1
introLabel.Text = "MY  -  KASSA"
introLabel.TextColor3 = Color3.fromRGB(255, 30, 30)
introLabel.Font = Enum.Font.GothamBlack
introLabel.TextSize = 1
introLabel.TextTransparency = 1
introLabel.ZIndex = 11
introLabel.Parent = introFrame

local introStroke = Instance.new("UIStroke")
introStroke.Color = Color3.fromRGB(255, 0, 0)
introStroke.Thickness = 3
introStroke.Transparency = 1
introStroke.Parent = introLabel

--------------------------------------------------------------------------------
-- PAINEL PRINCIPAL
--------------------------------------------------------------------------------
local targetSize = UDim2.new(0, 220, 0, 260)

local mainFrame = Instance.new("Frame")
mainFrame.Size = targetSize
mainFrame.Position = UDim2.new(0.02, 0, 0.22, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Visible = false
mainFrame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = mainFrame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(180, 0, 0)
frameStroke.Thickness = 2
frameStroke.Parent = mainFrame

-- Título (Área para clicar e arrastar o menu)
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "SISTEMA DE VOO"
titleLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 14
titleLabel.Parent = mainFrame

--------------------------------------------------------------------------------
-- SISTEMA PARA ARRASTAR O MENU (DRAGGABLE)
--------------------------------------------------------------------------------
local dragging = false
local dragInput, dragStart, startPos

local function update(input)
	local delta = input.Position - dragStart
	mainFrame.Position = UDim2.new(
		startPos.X.Scale, 
		startPos.X.Offset + delta.X, 
		startPos.Y.Scale, 
		startPos.Y.Offset + delta.Y
	)
end

titleLabel.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

titleLabel.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)

--------------------------------------------------------------------------------
-- COMPONENTES DO MENU
--------------------------------------------------------------------------------

-- 1. BOTÃO E BARRA DE VOO
local flyToggleBtn = Instance.new("TextButton")
flyToggleBtn.Size = UDim2.new(0.9, 0, 0, 30)
flyToggleBtn.Position = UDim2.new(0.05, 0, 0.12, 0)
flyToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
flyToggleBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
flyToggleBtn.Text = "ACTIVAR VOO"
flyToggleBtn.Font = Enum.Font.GothamBold
flyToggleBtn.TextSize = 12
flyToggleBtn.Parent = mainFrame

local flyBtnCorner = Instance.new("UICorner")
flyBtnCorner.CornerRadius = UDim.new(0, 8)
flyBtnCorner.Parent = flyToggleBtn

local flyBtnStroke = Instance.new("UIStroke")
flyBtnStroke.Color = Color3.fromRGB(150, 0, 0)
flyBtnStroke.Thickness = 1.5
flyBtnStroke.Parent = flyToggleBtn

local flyProgressBarBackground = Instance.new("Frame")
flyProgressBarBackground.Size = UDim2.new(0.9, 0, 0, 4)
flyProgressBarBackground.Position = UDim2.new(0.05, 0, 0.24, 0)
flyProgressBarBackground.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
flyProgressBarBackground.BorderSizePixel = 0
flyProgressBarBackground.Parent = mainFrame

local flyProgressCornerBG = Instance.new("UICorner")
flyProgressCornerBG.CornerRadius = UDim.new(1, 0)
flyProgressCornerBG.Parent = flyProgressBarBackground

local flyProgressStroke = Instance.new("UIStroke")
flyProgressStroke.Color = Color3.fromRGB(100, 0, 0)
flyProgressStroke.Thickness = 1
flyProgressStroke.Parent = flyProgressBarBackground

local flyProgressBarFill = Instance.new("Frame")
flyProgressBarFill.Size = UDim2.new(0, 0, 1, 0)
flyProgressBarFill.BackgroundColor3 = Color3.fromRGB(255, 30, 30)
flyProgressBarFill.BorderSizePixel = 0
flyProgressBarFill.Parent = flyProgressBarBackground

local flyProgressCornerFill = Instance.new("UICorner")
flyProgressCornerFill.CornerRadius = UDim.new(1, 0)
flyProgressCornerFill.Parent = flyProgressBarFill

local flyPercentLabel = Instance.new("TextLabel")
flyPercentLabel.Size = UDim2.new(0.9, 0, 0, 12)
flyPercentLabel.Position = UDim2.new(0.05, 0, 0.26, 0)
flyPercentLabel.BackgroundTransparency = 1
flyPercentLabel.Text = ""
flyPercentLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
flyPercentLabel.Font = Enum.Font.Gotham
flyPercentLabel.TextSize = 10
flyPercentLabel.Parent = mainFrame


-- 2. BOTÃO E BARRA DE NOCLIP (LOGO ABAIXO DO VOO)
local noclipToggleBtn = Instance.new("TextButton")
noclipToggleBtn.Size = UDim2.new(0.9, 0, 0, 30)
noclipToggleBtn.Position = UDim2.new(0.05, 0, 0.32, 0)
noclipToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
noclipToggleBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
noclipToggleBtn.Text = "ACTIVAR NOCLIP"
noclipToggleBtn.Font = Enum.Font.GothamBold
noclipToggleBtn.TextSize = 12
noclipToggleBtn.Parent = mainFrame

local noclipBtnCorner = Instance.new("UICorner")
noclipBtnCorner.CornerRadius = UDim.new(0, 8)
noclipBtnCorner.Parent = noclipToggleBtn

local noclipBtnStroke = Instance.new("UIStroke")
noclipBtnStroke.Color = Color3.fromRGB(150, 0, 0)
noclipBtnStroke.Thickness = 1.5
noclipBtnStroke.Parent = noclipToggleBtn

local noclipProgressBarBackground = Instance.new("Frame")
noclipProgressBarBackground.Size = UDim2.new(0.9, 0, 0, 4)
noclipProgressBarBackground.Position = UDim2.new(0.05, 0, 0.44, 0)
noclipProgressBarBackground.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
noclipProgressBarBackground.BorderSizePixel = 0
noclipProgressBarBackground.Parent = mainFrame

local noclipProgressCornerBG = Instance.new("UICorner")
noclipProgressCornerBG.CornerRadius = UDim.new(1, 0)
noclipProgressCornerBG.Parent = noclipProgressBarBackground

local noclipProgressStroke = Instance.new("UIStroke")
noclipProgressStroke.Color = Color3.fromRGB(100, 0, 0)
noclipProgressStroke.Thickness = 1
noclipProgressStroke.Parent = noclipProgressBarBackground

local noclipProgressBarFill = Instance.new("Frame")
noclipProgressBarFill.Size = UDim2.new(0, 0, 1, 0)
noclipProgressBarFill.BackgroundColor3 = Color3.fromRGB(255, 30, 30)
noclipProgressBarFill.BorderSizePixel = 0
noclipProgressBarFill.Parent = noclipProgressBarBackground

local noclipProgressCornerFill = Instance.new("UICorner")
noclipProgressCornerFill.CornerRadius = UDim.new(1, 0)
noclipProgressCornerFill.Parent = noclipProgressBarFill

local noclipPercentLabel = Instance.new("TextLabel")
noclipPercentLabel.Size = UDim2.new(0.9, 0, 0, 12)
noclipPercentLabel.Position = UDim2.new(0.05, 0, 0.46, 0)
noclipPercentLabel.BackgroundTransparency = 1
noclipPercentLabel.Text = ""
noclipPercentLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
noclipPercentLabel.Font = Enum.Font.Gotham
noclipPercentLabel.TextSize = 10
noclipPercentLabel.Parent = mainFrame


-- 3. CAMPO DE VELOCIDADE
local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(0.9, 0, 0, 26)
speedBox.Position = UDim2.new(0.05, 0, 0.52, 0)
speedBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
speedBox.PlaceholderText = "Velocidade (Ex: 60)"
speedBox.Text = "60"
speedBox.Font = Enum.Font.Gotham
speedBox.TextSize = 12
speedBox.Parent = mainFrame

local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0, 8)
speedCorner.Parent = speedBox

local speedStroke = Instance.new("UIStroke")
speedStroke.Color = Color3.fromRGB(100, 0, 0)
speedStroke.Thickness = 1
speedStroke.Parent = speedBox


-- 4. BOTÕES SUBIR / DESCER
local upBtn = Instance.new("TextButton")
upBtn.Size = UDim2.new(0.425, 0, 0, 28)
upBtn.Position = UDim2.new(0.05, 0, 0.65, 0)
upBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
upBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
upBtn.Text = "Subir (^)"
upBtn.Font = Enum.Font.GothamBold
upBtn.TextSize = 12
upBtn.Parent = mainFrame

local upCorner = Instance.new("UICorner")
upCorner.CornerRadius = UDim.new(0, 8)
upCorner.Parent = upBtn

local upStroke = Instance.new("UIStroke")
upStroke.Color = Color3.fromRGB(120, 0, 0)
upStroke.Thickness = 1
upStroke.Parent = upBtn

local downBtn = Instance.new("TextButton")
downBtn.Size = UDim2.new(0.425, 0, 0, 28)
downBtn.Position = UDim2.new(0.525, 0, 0.65, 0)
downBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
downBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
downBtn.Text = "Descer (v)"
downBtn.Font = Enum.Font.GothamBold
downBtn.TextSize = 12
downBtn.Parent = mainFrame

local downCorner = Instance.new("UICorner")
downCorner.CornerRadius = UDim.new(0, 8)
downCorner.Parent = downBtn

local downStroke = Instance.new("UIStroke")
downStroke.Color = Color3.fromRGB(120, 0, 0)
downStroke.Thickness = 1
downStroke.Parent = downBtn


-- 5. ATALHOS RÁPIDOS (50, 100, 150)
local presetFrame = Instance.new("Frame")
presetFrame.Size = UDim2.new(0.9, 0, 0, 24)
presetFrame.Position = UDim2.new(0.05, 0, 0.78, 0)
presetFrame.BackgroundTransparency = 1
presetFrame.Parent = mainFrame

local speeds = {50, 100, 150}
for i, spd in ipairs(speeds) do
	local pBtn = Instance.new("TextButton")
	pBtn.Size = UDim2.new(0.3, 0, 1, 0)
	pBtn.Position = UDim2.new((i - 1) * 0.35, 0, 0, 0)
	pBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	pBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
	pBtn.Text = tostring(spd)
	pBtn.Font = Enum.Font.Gotham
	pBtn.TextSize = 12
	pBtn.Parent = presetFrame
	
	local pCorner = Instance.new("UICorner")
	pCorner.CornerRadius = UDim.new(0, 6)
	pCorner.Parent = pBtn

	local pStroke = Instance.new("UIStroke")
	pStroke.Color = Color3.fromRGB(150, 0, 0)
	pStroke.Thickness = 1
	pStroke.Parent = pBtn
	
	pBtn.MouseButton1Click:Connect(function()
		flySpeed = spd
		speedBox.Text = tostring(spd)
	end)
end

--------------------------------------------------------------------------------
-- ANIMAÇÃO DA TELA DE APRESENTAÇÃO (PRIMEIRA VEZ)
--------------------------------------------------------------------------------
local function playIntroAnimation()
	introFrame.Visible = true
	
	-- Fade In do Fundo Escuro
	TweenService:Create(introFrame, TweenInfo.new(0.4), {BackgroundTransparency = 0.3}):Play()
	task.wait(0.2)
	
	-- Animação do Texto Crescendo + Aparecendo + Glow
	local textTween = TweenService:Create(introLabel, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		TextSize = 36,
		TextTransparency = 0
	})
	local strokeTween = TweenService:Create(introStroke, TweenInfo.new(0.8), {
		Transparency = 0
	})
	textTween:Play()
	strokeTween:Play()
	
	textTween.Completed:Wait()
	task.wait(0.8) -- Tempo para visualização do título
	
	-- Fade Out de Saída da Intro
	local fadeOutText = TweenService:Create(introLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		TextTransparency = 1,
		TextSize = 50
	})
	local fadeOutBg = TweenService:Create(introFrame, TweenInfo.new(0.5), {
		BackgroundTransparency = 1
	})
	
	fadeOutText:Play()
	fadeOutBg:Play()
	
	fadeOutBg.Completed:Wait()
	introFrame:Destroy() -- Destrói a intro para não consumir memória
end

--------------------------------------------------------------------------------
-- ANIMAÇÃO DE ABRIR E MINIMIZAR MENU
--------------------------------------------------------------------------------
local menuVisible = false
local isAnimating = false

local function toggleMenuAnimation()
	if isAnimating then return end
	isAnimating = true

	-- Se for a PRIMEIRA VEZ ativando
	if isFirstActivation then
		isFirstActivation = false
		playIntroAnimation()
	end

	if menuVisible then
		local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In)
		local tweenSize = TweenService:Create(mainFrame, tweenInfo, {
			Size = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1
		})
		
		TweenService:Create(frameStroke, TweenInfo.new(0.2), {Transparency = 1}):Play()
		
		tweenSize:Play()
		tweenSize.Completed:Wait()
		
		mainFrame.Visible = false
		menuVisible = false
	else
		mainFrame.Visible = true
		mainFrame.Size = UDim2.new(0, 0, 0, 0)
		mainFrame.BackgroundTransparency = 1
		frameStroke.Transparency = 1

		local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		
		TweenService:Create(frameStroke, TweenInfo.new(0.3), {Transparency = 0}):Play()
		
		local tweenSize = TweenService:Create(mainFrame, tweenInfo, {
			Size = targetSize,
			BackgroundTransparency = 0
		})
		
		tweenSize:Play()
		tweenSize.Completed:Wait()
		
		menuVisible = true
	end

	isAnimating = false
end

toggleMenuBtn.MouseButton1Click:Connect(function()
	toggleMenuAnimation()
end)

--------------------------------------------------------------------------------
-- LÓGICA DO NOCLIP (COM CARREGAMENTO)
--------------------------------------------------------------------------------
local function enableNoclipPhysics()
	isNoclip = true
	noclipToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
	noclipToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	noclipToggleBtn.Text = "NOCLIP: LIGADO"
	noclipPercentLabel.Text = ""

	noclipConnection = RunService.Stepped:Connect(function()
		if isNoclip and character then
			for _, part in ipairs(character:GetDescendants()) do
				if part:IsA("BasePart") and part.CanCollide then
					part.CanCollide = false
				end
			end
		end
	end)
end

local function disableNoclipPhysics()
	isNoclip = false
	noclipToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	noclipToggleBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
	noclipToggleBtn.Text = "ACTIVAR NOCLIP"
	
	noclipProgressBarFill.Size = UDim2.new(0, 0, 1, 0)
	noclipPercentLabel.Text = ""

	if noclipConnection then
		noclipConnection:Disconnect()
		noclipConnection = nil
	end

	if character then
		for _, part in ipairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = true
			end
		end
	end
end

noclipToggleBtn.MouseButton1Click:Connect(function()
	if isNoclipLoading then return end
	
	if isNoclip then
		disableNoclipPhysics()
	else
		isNoclipLoading = true
		noclipToggleBtn.Text = "CARREGANDO..."
		noclipProgressBarFill.Size = UDim2.new(0, 0, 1, 0)
		
		local duration = 2.5
		
		local fillTween = TweenService:Create(
			noclipProgressBarFill, 
			TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
			{Size = UDim2.new(1, 0, 1, 0)}
		)
		fillTween:Play()
		
		task.spawn(function()
			local startTime = tick()
			while isNoclipLoading do
				local elapsed = tick() - startTime
				local progress = math.clamp(elapsed / duration, 0, 1)
				noclipPercentLabel.Text = math.floor(progress * 100) .. "%"
				
				if progress >= 1 then break end
				task.wait(0.03)
			end
		end)
		
		fillTween.Completed:Wait()
		
		isNoclipLoading = false
		enableNoclipPhysics()
	end
end)

--------------------------------------------------------------------------------
-- LÓGICA DO VOO E CARREGAMENTO
--------------------------------------------------------------------------------
speedBox.FocusLost:Connect(function()
	local newSpeed = tonumber(speedBox.Text)
	if newSpeed then
		flySpeed = newSpeed
	else
		speedBox.Text = tostring(flySpeed)
	end
end)

upBtn.MouseButton1Down:Connect(function() verticalVelocity = flySpeed end)
upBtn.MouseButton1Up:Connect(function() verticalVelocity = 0 end)

downBtn.MouseButton1Down:Connect(function() verticalVelocity = -flySpeed end)
downBtn.MouseButton1Up:Connect(function() verticalVelocity = 0 end)

local function startFlyingPhysics()
	isFlying = true
	flyToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
	flyToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	flyToggleBtn.Text = "VOO: LIGADO"
	flyPercentLabel.Text = ""
	
	bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
	bodyVelocity.Velocity = Vector3.new(0, 0, 0)
	bodyVelocity.Parent = rootPart
	
	bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
	bodyGyro.P = 10000
	bodyGyro.CFrame = rootPart.CFrame
	bodyGyro.Parent = rootPart

	humanoid:ChangeState(Enum.HumanoidStateType.Swimming)

	renderConnection = RunService.RenderStepped:Connect(function()
		if isFlying and bodyVelocity and bodyGyro then
			local camera = workspace.CurrentCamera
			local moveVector = MasterControl:GetMoveVector()

			bodyGyro.CFrame = CFrame.new(rootPart.Position, rootPart.Position + camera.CFrame.LookVector * Vector3.new(1, 0, 1))

			local flyDirection = Vector3.new(0, 0, 0)
			
			if moveVector.Magnitude > 0 then
				flyDirection = (camera.CFrame.RightVector * moveVector.X) + (camera.CFrame.LookVector * -moveVector.Z)
			end
			
			bodyVelocity.Velocity = (flyDirection * flySpeed) + Vector3.new(0, verticalVelocity, 0)
		end
	end)
end

local function stopFlyingPhysics()
	isFlying = false
	flyToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	flyToggleBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
	flyToggleBtn.Text = "ACTIVAR VOO"
	
	flyProgressBarFill.Size = UDim2.new(0, 0, 1, 0)
	flyPercentLabel.Text = ""
	
	if renderConnection then renderConnection:Disconnect() end
	if bodyVelocity then bodyVelocity:Destroy() end
	if bodyGyro then bodyGyro:Destroy() end

	humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
end

flyToggleBtn.MouseButton1Click:Connect(function()
	if isFlyLoading then return end
	
	if isFlying then
		stopFlyingPhysics()
	else
		isFlyLoading = true
		flyToggleBtn.Text = "CARREGANDO..."
		flyProgressBarFill.Size = UDim2.new(0, 0, 1, 0)
		
		local duration = 2.5
		
		local fillTween = TweenService:Create(
			flyProgressBarFill, 
			TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
			{Size = UDim2.new(1, 0, 1, 0)}
		)
		fillTween:Play()
		
		task.spawn(function()
			local startTime = tick()
			while isFlyLoading do
				local elapsed = tick() - startTime
				local progress = math.clamp(elapsed / duration, 0, 1)
				flyPercentLabel.Text = math.floor(progress * 100) .. "%"
				
				if progress >= 1 then break end
				task.wait(0.03)
			end
		end)
		
		fillTween.Completed:Wait()
		
		isFlyLoading = false
		startFlyingPhysics()
	end
end)
