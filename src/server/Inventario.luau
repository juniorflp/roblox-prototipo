--!strict
--// Itens do jogador: coleta nos expositores, entrega das ferramentas e comportamento de cada item.
--// Toda decisão acontece aqui no servidor; o cliente só aperta o prompt e clica na ferramenta.

local CollectionService = game:GetService("CollectionService")
local RS = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Compartilhado = RS:WaitForChild("Compartilhado")
local Config = require(Compartilhado:WaitForChild("Config"))
local Itens = require(Compartilhado:WaitForChild("Itens"))
local Tags = require(Compartilhado:WaitForChild("Tags"))
local Dados = require(script.Parent.Dados)

local MARGEM_DISTANCIA = 4

local Inventario = {}

local modelos = ServerStorage:WaitForChild("Itens")
local ligados: { [Tool]: boolean } = setmetatable({}, { __mode = "k" }) :: any

-- Comportamento por item. Ligado via tag, então vale também para as cópias que o
-- StarterGear coloca na mochila a cada respawn.
local USOS: { [string]: (Tool) -> () } = {
	Lanterna = function(tool)
		local handle = tool:WaitForChild("Handle")
		local feixe = handle:WaitForChild("Feixe") :: SpotLight
		tool.Activated:Connect(function()
			feixe.Enabled = not feixe.Enabled
		end)
		tool.Unequipped:Connect(function()
			feixe.Enabled = false
		end)
	end,
}

local function ligarComportamento(instancia: Instance)
	if not instancia:IsA("Tool") or ligados[instancia] then
		return
	end
	ligados[instancia] = true
	local uso = USOS[instancia:GetAttribute("ItemId") :: string]
	if uso then
		uso(instancia)
	end
end

local function criarFerramenta(itemId: string): Tool?
	local item = Itens[itemId]
	local modelo = modelos:FindFirstChild(itemId)
	if not (item and modelo and modelo:IsA("Tool")) then
		warn("[Inventario] item sem modelo em ServerStorage.Itens:", itemId)
		return nil
	end
	local tool = modelo:Clone()
	tool.ToolTip = item.descricao
	CollectionService:AddTag(tool, Tags.ITEM)
	return tool
end

local function temFerramenta(container: Instance?, itemId: string): boolean
	return container ~= nil and container:FindFirstChild(itemId) ~= nil
end

-- StarterGear garante o item em todo respawn; a mochila recebe na hora.
local function entregar(player: Player, itemId: string)
	local starterGear = player:FindFirstChild("StarterGear")
	if starterGear and not temFerramenta(starterGear, itemId) then
		local tool = criarFerramenta(itemId)
		if tool then
			tool.Parent = starterGear
		end
	end

	local backpack = player:FindFirstChildOfClass("Backpack")
	if backpack and not temFerramenta(backpack, itemId) and not temFerramenta(player.Character, itemId) then
		local tool = criarFerramenta(itemId)
		if tool then
			tool.Parent = backpack
		end
	end
end

local function coletar(player: Player, itemId: string, prompt: ProximityPrompt, evAviso: RemoteEvent)
	local item = Itens[itemId]
	local perfil = Dados.obter(player)
	if not (item and perfil) then
		return
	end

	-- Prompts são acionados pelo cliente: confere a distância de verdade.
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	local alvo = prompt.Parent :: BasePart
	if not hrp or (hrp.Position - alvo.Position).Magnitude > prompt.MaxActivationDistance + MARGEM_DISTANCIA then
		return
	end

	if perfil.itens[itemId] then
		evAviso:FireClient(player, "Você já tem: " .. item.nome)
		return
	end

	perfil.itens[itemId] = true
	entregar(player, itemId)
	evAviso:FireClient(player, "Você pegou: " .. item.nome)
	task.spawn(Dados.salvar, player)
end

function Inventario.iniciar()
	local remotes = RS:WaitForChild(Config.PASTA_REMOTES)
	local evAviso = remotes:WaitForChild("AvisoHUD") :: RemoteEvent

	Tags.observar(Tags.ITEM, ligarComportamento)

	Dados.aoCarregar(function(player, perfil)
		for itemId in perfil.itens do
			entregar(player, itemId)
		end
	end)

	-- Expositor = parte do mapa com tag "Expositor", atributo ItemId e um ProximityPrompt.
	Tags.observar(Tags.EXPOSITOR, function(expositor)
		local itemId = expositor:GetAttribute("ItemId")
		local prompt = expositor:FindFirstChildOfClass("ProximityPrompt")
		if type(itemId) ~= "string" or not Itens[itemId] or not prompt then
			warn("[Inventario] expositor mal configurado:", expositor:GetFullName())
			return
		end
		prompt.Triggered:Connect(function(player)
			coletar(player, itemId, prompt, evAviso)
		end)
	end)
end

return Inventario
