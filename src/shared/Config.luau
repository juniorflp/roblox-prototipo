--!strict
--// Valores de design usados pelo servidor e pelo cliente.
--// Posições ficam no mapa (Workspace.Mapa, editado no Studio), não aqui.

local Config = {}

Config.PASTA_REMOTES = "TesteRemotes"
Config.REMOTES = { "OrbColetado", "VoltarAoCentro", "AvisoHUD" }

Config.DATASTORE_JOGADORES = "Jogadores_v1"
Config.AUTOSAVE = 120

Config.RESPAWN_ORB = 6
Config.COOLDOWN_TELEPORTE = 2

Config.PALETA = {
	preto  = Color3.fromRGB(14, 16, 24),
	branco = Color3.fromRGB(240, 244, 255),
	cinza  = Color3.fromRGB(150, 158, 178),
	neon   = Color3.fromRGB(0, 200, 255),
	ouro   = Color3.fromRGB(255, 186, 60),
}

Config.CORES_NUCLEO = {
	Color3.fromRGB(0, 200, 255),
	Color3.fromRGB(255, 120, 190),
	Color3.fromRGB(130, 255, 140),
	Color3.fromRGB(255, 186, 60),
}

return Config
