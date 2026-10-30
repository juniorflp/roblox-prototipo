--!strict
--// Carrega e salva o perfil de cada jogador no DataStore.
--// Sem acesso ao DataStore (Studio sem permissão de API), roda em memória e avisa no console.

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")

local Config = require(RS:WaitForChild("Compartilhado"):WaitForChild("Config"))

export type Perfil = {
	versao: number,
	itens: { [string]: boolean },
}

local VERSAO = 1
local TENTATIVAS = 3

local Dados = {}

local store: DataStore? = nil
local perfis: { [Player]: Perfil } = {}
local podeSalvar: { [Player]: boolean } = {}
local aoCarregarCallbacks: { (Player, Perfil) -> () } = {}

local function perfilPadrao(): Perfil
	return { versao = VERSAO, itens = {} }
end

-- Aceita dados antigos ou corrompidos sem quebrar: copia só o que é válido.
local function migrar(salvo: any): Perfil
	local perfil = perfilPadrao()
	if type(salvo) ~= "table" then
		return perfil
	end
	if type(salvo.itens) == "table" then
		for id, tem in salvo.itens do
			if type(id) == "string" and tem == true then
				perfil.itens[id] = true
			end
		end
	end
	return perfil
end

local function chave(player: Player): string
	return "Player_" .. player.UserId
end

local function comRetry(acao: () -> any): (boolean, any)
	local ok, resultado = false, nil
	for tentativa = 1, TENTATIVAS do
		ok, resultado = pcall(acao)
		if ok then
			return true, resultado
		end
		if tentativa < TENTATIVAS then
			task.wait(2 ^ tentativa)
		end
	end
	return false, resultado
end

local function carregar(player: Player)
	local perfil = perfilPadrao()

	local ds = store
	if ds then
		local ok, salvo = comRetry(function()
			return ds:GetAsync(chave(player))
		end)
		if not ok then
			-- Nunca deixar jogar com perfil vazio: o próximo save apagaria o progresso real.
			warn("[Dados] falha ao carregar", player.Name, salvo)
			player:Kick("Não foi possível carregar seus dados. Tente entrar de novo.")
			return
		end
		perfil = migrar(salvo)
		podeSalvar[player] = true
	end

	if player.Parent ~= Players then
		return
	end
	perfis[player] = perfil
	for _, callback in aoCarregarCallbacks do
		task.spawn(callback, player, perfil)
	end
end

function Dados.salvar(player: Player)
	local perfil = perfis[player]
	local ds = store
	if not (ds and perfil and podeSalvar[player]) then
		return
	end
	local ok, erro = comRetry(function()
		return ds:UpdateAsync(chave(player), function()
			return perfil, { player.UserId }
		end)
	end)
	if not ok then
		warn("[Dados] falha ao salvar", player.Name, erro)
	end
end

function Dados.obter(player: Player): Perfil?
	return perfis[player]
end

-- Chama `callback` para cada perfil carregado, inclusive os que já estavam prontos.
function Dados.aoCarregar(callback: (Player, Perfil) -> ())
	table.insert(aoCarregarCallbacks, callback)
	for player, perfil in perfis do
		task.spawn(callback, player, perfil)
	end
end

function Dados.iniciar()
	-- Dados de teste do Studio não se misturam com os dos jogadores reais.
	local nome = Config.DATASTORE_JOGADORES .. (if RunService:IsStudio() then "_Studio" else "")
	local ds = DataStoreService:GetDataStore(nome)

	local ok, erro = pcall(function()
		ds:GetAsync("_teste")
	end)
	if ok then
		store = ds
	else
		warn("[Dados] DataStore indisponível, progresso NÃO será salvo:", erro)
	end

	Players.PlayerAdded:Connect(carregar)
	for _, player in Players:GetPlayers() do
		task.spawn(carregar, player)
	end

	Players.PlayerRemoving:Connect(function(player)
		Dados.salvar(player)
		perfis[player] = nil
		podeSalvar[player] = nil
	end)

	game:BindToClose(function()
		local pendentes = 0
		for player in perfis do
			pendentes += 1
			task.spawn(function()
				Dados.salvar(player)
				pendentes -= 1
			end)
		end
		while pendentes > 0 do
			task.wait()
		end
	end)

	task.spawn(function()
		while true do
			task.wait(Config.AUTOSAVE)
			for player in perfis do
				task.spawn(Dados.salvar, player)
			end
		end
	end)
end

return Dados
