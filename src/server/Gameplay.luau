--// Regras: orbs colecionáveis, núcleo interativo e teleporte.

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Config = require(RS:WaitForChild("Compartilhado"):WaitForChild("Config"))

local Gameplay = {}

local function criarRemotes(): Folder
	local antiga = RS:FindFirstChild(Config.PASTA_REMOTES)
	if antiga then
		antiga:Destroy()
	end

	local pasta = Instance.new("Folder")
	pasta.Name = Config.PASTA_REMOTES
	for _, nome in ipairs(Config.REMOTES) do
		local ev = Instance.new("RemoteEvent")
		ev.Name = nome
		ev.Parent = pasta
	end
	pasta.Parent = RS
	return pasta
end

local function darLeaderstats(player: Player)
	if player:FindFirstChild("leaderstats") then
		return
	end
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	local orbs = Instance.new("IntValue")
	orbs.Name = "Orbs"
	orbs.Parent = stats
	stats.Parent = player
end

local function prepararOrb(orb: BasePart, total: number, evOrb: RemoteEvent)
	local ativo = true
	local alturaBase = orb.Position.Y

	task.spawn(function()
		local t = math.random() * 10
		while orb.Parent do
			t += RunService.Heartbeat:Wait()
			if ativo then
				orb.CFrame = CFrame.new(orb.Position.X, alturaBase + math.sin(t * 2) * 0.8, orb.Position.Z)
					* CFrame.Angles(0, t, 0)
			end
		end
	end)

	local function alternarVisual(visivel: boolean)
		orb.Transparency = visivel and 0 or 1
		orb.CanTouch = visivel
		for _, l in ipairs(orb:GetChildren()) do
			if l:IsA("PointLight") then
				l.Enabled = visivel
			end
		end
	end

	orb.Touched:Connect(function(hit)
		if not ativo then
			return
		end
		local personagem = hit:FindFirstAncestorOfClass("Model")
		if not personagem then
			return
		end
		local player = Players:GetPlayerFromCharacter(personagem)
		if not player then
			return
		end

		ativo = false
		alternarVisual(false)

		local stats = player:FindFirstChild("leaderstats")
		if stats then
			local contador = stats:FindFirstChild("Orbs") :: IntValue?
			if contador then
				contador.Value += 1
				evOrb:FireClient(player, contador.Value, total)
			end
		end

		task.delay(Config.RESPAWN_ORB, function()
			if not orb.Parent then
				return
			end
			alternarVisual(true)
			ativo = true
		end)
	end)
end

function Gameplay.iniciar(cenario: Folder)
	local remotes = criarRemotes()
	local evOrb = remotes:WaitForChild("OrbColetado") :: RemoteEvent
	local evVoltar = remotes:WaitForChild("VoltarAoCentro") :: RemoteEvent
	local evAviso = remotes:WaitForChild("AvisoHUD") :: RemoteEvent

	Players.PlayerAdded:Connect(darLeaderstats)
	for _, p in ipairs(Players:GetPlayers()) do
		darLeaderstats(p)
	end

	local pastaOrbs = cenario:WaitForChild("Orbs")
	local total = #pastaOrbs:GetChildren()
	for _, orb in ipairs(pastaOrbs:GetChildren()) do
		if orb:IsA("BasePart") then
			prepararOrb(orb, total, evOrb)
		end
	end

	-- núcleo girando
	local nucleo = cenario.Base:WaitForChild("Nucleo") :: BasePart
	task.spawn(function()
		local t = 0
		while nucleo.Parent do
			t += RunService.Heartbeat:Wait()
			nucleo.CFrame = CFrame.new(0, 10 + math.sin(t) * 0.6, 0)
				* CFrame.Angles(math.rad(25), t * 0.8, math.rad(15))
		end
	end)

	-- prompt troca a cor dos faróis
	local corAtual = 1
	local prompt = nucleo:WaitForChild("PromptNucleo") :: ProximityPrompt
	prompt.Triggered:Connect(function(player)
		corAtual = corAtual % #Config.CORES_NUCLEO + 1
		local cor = Config.CORES_NUCLEO[corAtual]
		local info = TweenInfo.new(0.4)

		TweenService:Create(nucleo, info, { Color = cor }):Play()
		for _, l in ipairs(nucleo:GetChildren()) do
			if l:IsA("PointLight") then
				TweenService:Create(l, info, { Color = cor }):Play()
			end
		end
		for _, p in ipairs(cenario.Pilares:GetChildren()) do
			if p:IsA("BasePart") and p.Name:match("^Farol") then
				TweenService:Create(p, info, { Color = cor }):Play()
				local l = p:FindFirstChildOfClass("PointLight")
				if l then
					TweenService:Create(l, info, { Color = cor }):Play()
				end
			end
		end

		evAviso:FireAllClients(player.DisplayName .. " mudou a cor do núcleo")
	end)

	-- teleporte pedido pela HUD
	evVoltar.OnServerEvent:Connect(function(player)
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
		if hrp then
			hrp.CFrame = Config.DESTINO_TELEPORTE
			evAviso:FireClient(player, "Teleportado para o centro")
		end
	end)

	return total
end

return Gameplay
