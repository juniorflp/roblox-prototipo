--// Ponto de entrada do servidor.
--// O mapa já existe no place (Workspace.Mapa); os módulos acham os objetos por tag.

local Gameplay = require(script.Gameplay)
local Dados = require(script.Dados)
local Inventario = require(script.Inventario)

local totalOrbs = Gameplay.iniciar()
Inventario.iniciar()
Dados.iniciar()

print(string.format("[Jogo] servidor pronto, %d orbs ativos", totalOrbs))
