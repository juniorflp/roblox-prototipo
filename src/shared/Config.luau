--!strict
--// Valores usados pelo servidor e pelo cliente

local Config = {}

Config.NOME_CENARIO = "CenarioTeste"
Config.PASTA_REMOTES = "TesteRemotes"
Config.REMOTES = { "OrbColetado", "VoltarAoCentro", "AvisoHUD" }

Config.RESPAWN_ORB = 6
Config.DESTINO_TELEPORTE = CFrame.new(0, 6, 22)

Config.PALETA = {
	preto  = Color3.fromRGB(14, 16, 24),
	branco = Color3.fromRGB(240, 244, 255),
	cinza  = Color3.fromRGB(150, 158, 178),
	neon   = Color3.fromRGB(0, 200, 255),
	ouro   = Color3.fromRGB(255, 186, 60),
	piso   = Color3.fromRGB(56, 62, 78),
	trilha = Color3.fromRGB(86, 94, 115),
	borda  = Color3.fromRGB(28, 32, 44),
	pilar  = Color3.fromRGB(198, 202, 214),
	verde  = Color3.fromRGB(86, 170, 110),
	tronco = Color3.fromRGB(104, 78, 56),
}

Config.CORES_NUCLEO = {
	Color3.fromRGB(0, 200, 255),
	Color3.fromRGB(255, 120, 190),
	Color3.fromRGB(130, 255, 140),
	Color3.fromRGB(255, 186, 60),
}

Config.ORBS = {
	Vector3.new(30, 5, 10),
	Vector3.new(-18, 5, 32),
	Vector3.new(14, 5, -34),
	Vector3.new(-40, 5, -20),
	Vector3.new(-44, 29, 26),
	Vector3.new(-32, 18, 8),
}

return Config
