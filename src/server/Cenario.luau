--// Constrói a praça de teste inteiramente por código.
--// Idempotente: destrói e recria a pasta a cada chamada.

local RS = game:GetService("ReplicatedStorage")
local Config = require(RS:WaitForChild("Compartilhado"):WaitForChild("Config"))

local C = Config.PALETA
local DEITADO = CFrame.Angles(0, 0, math.rad(90))

local Cenario = {}

local function novaParte(nome: string, pai: Instance, props: { [string]: any }): Part
	local p = Instance.new("Part")
	p.Name = nome
	p.Anchored = true
	p.Material = Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	for k, v in pairs(props) do
		(p :: any)[k] = v
	end
	p.Parent = pai
	return p
end

local function luz(pai: Instance, cor: Color3, brilho: number, alcance: number)
	local l = Instance.new("PointLight")
	l.Color = cor
	l.Brightness = brilho
	l.Range = alcance
	l.Shadows = true
	l.Parent = pai
	return l
end

local function construirBase(root: Folder)
	local base = Instance.new("Folder")
	base.Name = "Base"
	base.Parent = root

	novaParte("Borda", base, {
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(2.2, 128, 128),
		CFrame = CFrame.new(0, 0.9, 0) * DEITADO,
		Color = C.borda,
		Material = Enum.Material.Pebble,
	})

	novaParte("Piso", base, {
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(2, 120, 120),
		CFrame = CFrame.new(0, 1.2, 0) * DEITADO,
		Color = C.piso,
		Material = Enum.Material.Pebble,
	})

	for i = 0, 3 do
		novaParte("Trilha" .. i, base, {
			Size = Vector3.new(10, 0.3, 52),
			CFrame = CFrame.new(0, 2.25, 0) * CFrame.Angles(0, math.rad(i * 90), 0) * CFrame.new(0, 0, -30),
			Color = C.trilha,
			Material = Enum.Material.Pebble,
		})
	end

	novaParte("Pedestal", base, {
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(3, 18, 18),
		CFrame = CFrame.new(0, 3.7, 0) * DEITADO,
		Color = C.borda,
		Material = Enum.Material.Marble,
	})

	local nucleo = novaParte("Nucleo", base, {
		Size = Vector3.new(5, 5, 5),
		CFrame = CFrame.new(0, 10, 0),
		Color = C.neon,
		Material = Enum.Material.Neon,
		CanCollide = false,
	})
	luz(nucleo, C.neon, 1.8, 26)

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "PromptNucleo"
	prompt.ActionText = "Alternar cor"
	prompt.ObjectText = "Núcleo"
	prompt.HoldDuration = 0.3
	prompt.MaxActivationDistance = 18
	prompt.RequiresLineOfSight = false
	prompt.Parent = nucleo

	local spawnLoc = Instance.new("SpawnLocation")
	spawnLoc.Name = "SpawnTeste"
	spawnLoc.Anchored = true
	spawnLoc.Size = Vector3.new(12, 1, 12)
	spawnLoc.CFrame = CFrame.new(0, 2.7, 38)
	spawnLoc.Color = C.ouro
	spawnLoc.Material = Enum.Material.Metal
	spawnLoc.TopSurface = Enum.SurfaceType.Smooth
	spawnLoc.Duration = 0
	spawnLoc.Parent = base
end

local function construirPilares(root: Folder)
	local pilares = Instance.new("Folder")
	pilares.Name = "Pilares"

	for i = 0, 7 do
		local ang = math.rad(i * 45 + 22.5)
		local pos = Vector3.new(math.cos(ang) * 50, 0, math.sin(ang) * 50)

		novaParte("PilarBase" .. i, pilares, {
			Size = Vector3.new(7, 1.5, 7),
			CFrame = CFrame.new(pos + Vector3.new(0, 3, 0)),
			Color = C.borda,
			Material = Enum.Material.Slate,
		})
		novaParte("Pilar" .. i, pilares, {
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(20, 4.5, 4.5),
			CFrame = CFrame.new(pos + Vector3.new(0, 13.7, 0)) * DEITADO,
			Color = C.pilar,
			Material = Enum.Material.Concrete,
		})
		local farol = novaParte("Farol" .. i, pilares, {
			Size = Vector3.new(5, 1.4, 5),
			CFrame = CFrame.new(pos + Vector3.new(0, 24.4, 0)),
			Color = C.neon,
			Material = Enum.Material.Neon,
		})
		luz(farol, C.neon, 1, 16)
	end

	pilares.Parent = root
end

local function construirParkour(root: Folder)
	local parkour = Instance.new("Folder")
	parkour.Name = "Parkour"

	for i = 1, 6 do
		novaParte("Degrau" .. i, parkour, {
			Size = Vector3.new(9, 1, 9),
			CFrame = CFrame.new(-26 - i * 2, 4 + i * 3.5, -16 + i * 6) * CFrame.Angles(0, math.rad(i * 8), 0),
			Color = C.trilha,
			Material = Enum.Material.Pebble,
		})
	end

	novaParte("Mirante", parkour, {
		Size = Vector3.new(22, 1.2, 22),
		CFrame = CFrame.new(-44, 26, 26),
		Color = C.piso,
		Material = Enum.Material.Pebble,
	})
	novaParte("Guarda", parkour, {
		Size = Vector3.new(22, 3, 1),
		CFrame = CFrame.new(-44, 28, 15.5),
		Color = C.ouro,
		Material = Enum.Material.Metal,
	})

	local rampa = Instance.new("WedgePart")
	rampa.Name = "Rampa"
	rampa.Anchored = true
	rampa.Size = Vector3.new(10, 24, 34)
	rampa.CFrame = CFrame.new(-44, 13.4, 46) * CFrame.Angles(0, math.rad(180), 0)
	rampa.Color = C.trilha
	rampa.Material = Enum.Material.Pebble
	rampa.Parent = parkour

	parkour.Parent = root
end

local function construirOrbs(root: Folder)
	local orbs = Instance.new("Folder")
	orbs.Name = "Orbs"

	for i, pos in ipairs(Config.ORBS) do
		local orb = novaParte("Orb" .. i, orbs, {
			Shape = Enum.PartType.Ball,
			Size = Vector3.new(3, 3, 3),
			CFrame = CFrame.new(pos),
			Color = C.ouro,
			Material = Enum.Material.Neon,
			CanCollide = false,
		})
		luz(orb, C.ouro, 1.4, 10)
	end

	orbs.Parent = root
end

local function construirDecoracao(root: Folder)
	local deco = Instance.new("Folder")
	deco.Name = "Decoracao"

	for i = 0, 11 do
		local ang = math.rad(i * 30 + 15)
		local raio = 76 + (i % 3) * 9
		local pos = Vector3.new(math.cos(ang) * raio, 0, math.sin(ang) * raio)
		local altura = 8 + (i % 4) * 2

		novaParte("Tronco" .. i, deco, {
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(altura, 2, 2),
			CFrame = CFrame.new(pos + Vector3.new(0, altura / 2, 0)) * DEITADO,
			Color = C.tronco,
			Material = Enum.Material.Wood,
		})
		novaParte("Copa" .. i, deco, {
			Shape = Enum.PartType.Ball,
			Size = Vector3.new(11, 9, 11),
			CFrame = CFrame.new(pos + Vector3.new(0, altura + 2.5, 0)),
			Color = C.verde,
			Material = Enum.Material.Grass,
		})
	end

	deco.Parent = root
end

function Cenario.construir(): Folder
	local antigo = workspace:FindFirstChild(Config.NOME_CENARIO)
	if antigo then
		antigo:Destroy()
	end

	local root = Instance.new("Folder")
	root.Name = Config.NOME_CENARIO

	construirBase(root)
	root.Parent = workspace

	construirPilares(root)
	construirParkour(root)
	construirOrbs(root)
	construirDecoracao(root)

	return root
end

return Cenario
