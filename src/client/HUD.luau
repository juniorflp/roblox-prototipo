--// Monta a HUD por código e conecta aos remotes.

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(RS:WaitForChild("Compartilhado"):WaitForChild("Config"))
local C = Config.PALETA

local HUD = {}

local function cantos(pai: Instance, raio: number)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, raio)
	c.Parent = pai
end

local function contorno(pai: Instance, cor: Color3, transp: number): UIStroke
	local s = Instance.new("UIStroke")
	s.Color = cor
	s.Transparency = transp
	s.Thickness = 1.5
	s.Parent = pai
	return s
end

local function painel(nome: string, pai: Instance, props: { [string]: any }): Frame
	local f = Instance.new("Frame")
	f.Name = nome
	f.BackgroundColor3 = C.preto
	f.BackgroundTransparency = 0.12
	f.BorderSizePixel = 0
	for k, v in pairs(props) do
		(f :: any)[k] = v
	end
	f.Parent = pai
	cantos(f, 10)
	return f
end

local function texto(nome: string, pai: Instance, props: { [string]: any }): TextLabel
	local t = Instance.new("TextLabel")
	t.Name = nome
	t.BackgroundTransparency = 1
	t.TextColor3 = C.branco
	t.Font = Enum.Font.GothamMedium
	t.TextSize = 14
	t.TextXAlignment = Enum.TextXAlignment.Left
	for k, v in pairs(props) do
		(t :: any)[k] = v
	end
	t.Parent = pai
	return t
end

function HUD.criar()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	local antiga = playerGui:FindFirstChild("TesteHUD")
	if antiga then
		antiga:Destroy()
	end

	local gui = Instance.new("ScreenGui")
	gui.Name = "TesteHUD"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	---------------------------------------------------------------- título
	local cardTitulo = painel("CardTitulo", gui, {
		Position = UDim2.new(0, 20, 0, 20),
		Size = UDim2.new(0, 268, 0, 74),
	})
	contorno(cardTitulo, C.neon, 0.65)
	texto("Nome", cardTitulo, {
		Position = UDim2.new(0, 18, 0, 14),
		Size = UDim2.new(1, -36, 0, 22),
		Text = "PROTÓTIPO",
		Font = Enum.Font.GothamBold,
		TextSize = 19,
	})
	texto("Sub", cardTitulo, {
		Position = UDim2.new(0, 18, 0, 38),
		Size = UDim2.new(1, -36, 0, 18),
		Text = "Cenário de teste · build via MCP",
		TextColor3 = C.cinza,
		TextSize = 13,
	})

	local status = Instance.new("Frame")
	status.Name = "Status"
	status.AnchorPoint = Vector2.new(1, 0)
	status.Position = UDim2.new(1, -16, 0, 16)
	status.Size = UDim2.new(0, 8, 0, 8)
	status.BackgroundColor3 = Color3.fromRGB(80, 230, 140)
	status.BorderSizePixel = 0
	status.Parent = cardTitulo
	cantos(status, 4)

	---------------------------------------------------------------- orbs
	local cardOrbs = painel("CardOrbs", gui, {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -20, 0, 20),
		Size = UDim2.new(0, 210, 0, 74),
	})
	contorno(cardOrbs, C.ouro, 0.65)
	texto("Rotulo", cardOrbs, {
		Position = UDim2.new(0, 18, 0, 13),
		Size = UDim2.new(1, -36, 0, 16),
		Text = "ORBS COLETADOS",
		TextColor3 = C.cinza,
		TextSize = 11,
		Font = Enum.Font.GothamBold,
	})
	local valor = texto("Valor", cardOrbs, {
		Position = UDim2.new(0, 18, 0, 29),
		Size = UDim2.new(1, -36, 0, 24),
		Text = "0 / -",
		TextColor3 = C.ouro,
		Font = Enum.Font.GothamBold,
		TextSize = 22,
	})

	local trilho = Instance.new("Frame")
	trilho.Name = "Trilho"
	trilho.Position = UDim2.new(0, 18, 1, -16)
	trilho.Size = UDim2.new(1, -36, 0, 5)
	trilho.BackgroundColor3 = Color3.fromRGB(48, 52, 66)
	trilho.BorderSizePixel = 0
	trilho.Parent = cardOrbs
	cantos(trilho, 3)

	local preenchimento = Instance.new("Frame")
	preenchimento.Name = "Preenchimento"
	preenchimento.Size = UDim2.new(0, 0, 1, 0)
	preenchimento.BackgroundColor3 = C.ouro
	preenchimento.BorderSizePixel = 0
	preenchimento.Parent = trilho
	cantos(preenchimento, 3)

	---------------------------------------------------------------- aviso
	local aviso = painel("Aviso", gui, {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 24),
		Size = UDim2.new(0, 320, 0, 40),
		BackgroundTransparency = 1,
	})
	local contornoAviso = contorno(aviso, C.neon, 1)
	local msg = texto("Msg", aviso, {
		Size = UDim2.new(1, 0, 1, 0),
		Text = "",
		TextTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Center,
		Font = Enum.Font.GothamBold,
		TextSize = 15,
	})

	---------------------------------------------------------------- botões
	local acoes = Instance.new("Frame")
	acoes.Name = "Acoes"
	acoes.AnchorPoint = Vector2.new(0.5, 1)
	acoes.Position = UDim2.new(0.5, 0, 1, -24)
	acoes.Size = UDim2.new(0, 360, 0, 44)
	acoes.BackgroundTransparency = 1
	acoes.Parent = gui

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Padding = UDim.new(0, 12)
	layout.Parent = acoes

	local function botao(nome: string, rotulo: string, cor: Color3): TextButton
		local b = Instance.new("TextButton")
		b.Name = nome
		b.Size = UDim2.new(0, 168, 1, 0)
		b.BackgroundColor3 = C.preto
		b.BackgroundTransparency = 0.12
		b.BorderSizePixel = 0
		b.AutoButtonColor = false
		b.Text = rotulo
		b.TextColor3 = cor
		b.Font = Enum.Font.GothamBold
		b.TextSize = 14
		b.Parent = acoes
		cantos(b, 10)
		contorno(b, cor, 0.55)

		b.MouseEnter:Connect(function()
			TweenService:Create(b, TweenInfo.new(0.15), { BackgroundTransparency = 0 }):Play()
		end)
		b.MouseLeave:Connect(function()
			TweenService:Create(b, TweenInfo.new(0.15), { BackgroundTransparency = 0.12 }):Play()
		end)
		return b
	end

	local btVoltar = botao("Voltar", "Voltar ao centro", C.neon)
	local btAlternar = botao("Alternar", "Ocultar HUD", C.cinza)

	gui.Parent = playerGui

	---------------------------------------------------------------- lógica
	local remotes = RS:WaitForChild(Config.PASTA_REMOTES)
	local evOrb = remotes:WaitForChild("OrbColetado") :: RemoteEvent
	local evVoltar = remotes:WaitForChild("VoltarAoCentro") :: RemoteEvent
	local evAviso = remotes:WaitForChild("AvisoHUD") :: RemoteEvent

	local total = (remotes:GetAttribute("TotalOrbs") :: number?) or 0
	valor.Text = "0 / " .. total
	local tokenAviso = 0

	local function mostrarAviso(mensagem: string)
		tokenAviso += 1
		local meu = tokenAviso
		msg.Text = mensagem
		TweenService:Create(msg, TweenInfo.new(0.2), { TextTransparency = 0 }):Play()
		TweenService:Create(aviso, TweenInfo.new(0.2), { BackgroundTransparency = 0.15 }):Play()
		TweenService:Create(contornoAviso, TweenInfo.new(0.2), { Transparency = 0.5 }):Play()

		task.delay(2.4, function()
			if meu ~= tokenAviso then
				return
			end
			TweenService:Create(msg, TweenInfo.new(0.35), { TextTransparency = 1 }):Play()
			TweenService:Create(aviso, TweenInfo.new(0.35), { BackgroundTransparency = 1 }):Play()
			TweenService:Create(contornoAviso, TweenInfo.new(0.35), { Transparency = 1 }):Play()
		end)
	end

	evOrb.OnClientEvent:Connect(function(quantidade: number, totalServidor: number?)
		total = totalServidor or total
		valor.Text = quantidade .. " / " .. total
		TweenService:Create(preenchimento, TweenInfo.new(0.35, Enum.EasingStyle.Quad), {
			Size = UDim2.new(math.clamp(quantidade / total, 0, 1), 0, 1, 0),
		}):Play()

		local pulo = TweenService:Create(valor, TweenInfo.new(0.12), { TextSize = 28 })
		pulo.Completed:Connect(function()
			TweenService:Create(valor, TweenInfo.new(0.18), { TextSize = 22 }):Play()
		end)
		pulo:Play()

		mostrarAviso("Orb coletado!")
	end)

	evAviso.OnClientEvent:Connect(mostrarAviso)

	btVoltar.MouseButton1Click:Connect(function()
		evVoltar:FireServer()
	end)

	local visivel = true
	btAlternar.MouseButton1Click:Connect(function()
		visivel = not visivel
		cardTitulo.Visible = visivel
		cardOrbs.Visible = visivel
		btAlternar.Text = visivel and "Ocultar HUD" or "Mostrar HUD"
	end)

	return gui
end

return HUD
