--// Ponto de entrada do servidor

local Cenario = require(script.Cenario)
local Gameplay = require(script.Gameplay)

local cenario = Cenario.construir()
local totalOrbs = Gameplay.iniciar(cenario)

print(string.format("[Jogo] cenário construído (%d partes), %d orbs ativos", #cenario:GetDescendants(), totalOrbs))
