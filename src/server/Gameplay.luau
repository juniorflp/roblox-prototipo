--!strict
--// Regras: orbs colecionáveis, núcleo interativo e teleporte.
--// Os objetos vêm do mapa (montado no Studio) e são encontrados por tag.

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Compartilhado = RS:WaitForChild("Compartilhado")
local Config = require(Compartilhado:WaitForChild("Config"))
local Tags = require(Compartilhado:WaitForChild("Tags"))

local Gameplay = {}

local function criarRemotes(totalOrbs: number): Folder
	local antiga = RS:FindFirstChild(Config.PASTA_REMOTES)
	if antiga then
		antiga:Destroy()
	end

	local pasta = Instance.new("Folder")
	pasta.Name = Config.PASTA_REMOTES
	pasta:SetAttribute("TotalOrbs", totalOrbs)
	for _, nome in Config.REMOTES do
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

-- A animação do orb roda no cliente (client/Animacoes); aqui só o estado.
local function prepararOrb(orb: BasePart, total: number, evOrb: RemoteEvent)
	local ativo = true

	local function alternarVisual(visivel: boolean)
		orb.Transparency = if visivel then 0 else 1
		orb.CanTouch = visivel
		for _, l in orb:GetChildren() do
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
		local player = personagem and Players:GetPlayerFromCharacter(personagem)
		if not player then
			return
		end

		ativo = false
		alternarVisual(false)

		local stats = player:FindFirstChild("leaderstats")
		local contador = stats and stats:FindFirstChild("Orbs") :: IntValue?
		if contador then
			contador.Value += 1
			evOrb:FireClient(player, contador.Value, total)
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

local function prepararNucleo(nucleo: BasePart, evAviso: RemoteEvent)
	local prompt = nucleo:FindFirstChildOfClass("ProximityPrompt")
	if not prompt then
		warn("[Gameplay] Núcleo sem ProximityPrompt:", nucleo:GetFullName())
		return
	end

	local corAtual = 1
	prompt.Triggered:Connect(function(player)
		corAtual = corAtual % #Config.CORES_NUCLEO + 1
		local cor = Config.CORES_NUCLEO[corAtual]
		local info = TweenInfo.new(0.4)

		local function pintar(parte: BasePart)
			TweenService:Create(parte, info, { Color = cor }):Play()
			for _, l in parte:GetChildren() do
				if l:IsA("PointLight") then
					TweenService:Create(l, info, { Color = cor }):Play()
				end
			end
		end

		pintar(nucleo)
		for _, farol in CollectionService:GetTagged(Tags.FAROL) do
			if farol:IsA("BasePart") then
				pintar(farol)
			end
		end

		evAviso:FireAllClients(player.DisplayName .. " mudou a cor do núcleo")
	end)
end

function Gameplay.iniciar(): number
	local orbs = CollectionService:GetTagged(Tags.ORB)
	local total = #orbs

	local remotes = criarRemotes(total)
	local evOrb = remotes:WaitForChild("OrbColetado") :: RemoteEvent
	local evVoltar = remotes:WaitForChild("VoltarAoCentro") :: RemoteEvent
	local evAviso = remotes:WaitForChild("AvisoHUD") :: RemoteEvent

	Players.PlayerAdded:Connect(darLeaderstats)
	for _, p in Players:GetPlayers() do
		darLeaderstats(p)
	end

	for _, orb in orbs do
		if orb:IsA("BasePart") then
			prepararOrb(orb, total, evOrb)
		end
	end

	Tags.observar(Tags.NUCLEO, function(nucleo)
		if nucleo:IsA("BasePart") then
			prepararNucleo(nucleo, evAviso)
		end
	end)

	-- teleporte pedido pela HUD: o cliente só pede, o servidor decide
	local ultimoTeleporte: { [Player]: number } = {}
	Players.PlayerRemoving:Connect(function(player)
		ultimoTeleporte[player] = nil
	end)

	evVoltar.OnServerEvent:Connect(function(player)
		local agora = os.clock()
		if agora - (ultimoTeleporte[player] or 0) < Config.COOLDOWN_TELEPORTE then
			return
		end
		ultimoTeleporte[player] = agora

		local destino = CollectionService:GetTagged(Tags.DESTINO_TELEPORTE)[1]
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
		if hrp and destino and destino:IsA("BasePart") then
			hrp.CFrame = destino.CFrame
			evAviso:FireClient(player, "Teleportado para o centro")
		end
	end)

	return total
end

return Gameplay
