# protótipo roblox

Protótipo de teste: praça circular, parkour, orbs colecionáveis e HUD.
**Todo o jogo é código** — o cenário 3D é construído em runtime por `src/server/Cenario.luau`,
então o place (`.rbxl`) é só um contêiner vazio e não precisa ir pro git.

## Estrutura

| Pasta | Vira, no Studio |
|---|---|
| `src/server/` | `ServerScriptService.Jogo` (Script + módulos) |
| `src/client/` | `StarterPlayer.StarterPlayerScripts.Cliente` (LocalScript + módulos) |
| `src/shared/` | `ReplicatedStorage.Compartilhado` |

## Rodando

```bash
rojo serve          # porta 34872
```

No Studio: aba **Plugins → Rojo → Connect**. A partir daí, salvar um arquivo
atualiza o Studio na hora.

## Comandos úteis

```bash
rojo serve                      # sync ao vivo
rojo build -o prototipo.rbxl    # gera um place do zero
rojo sourcemap -o sourcemap.json
```

## O que tem dentro

- **Cenário**: praça de 120 studs, 8 pilares com faróis, pedestal com núcleo flutuante,
  parkour (6 degraus + mirante + rampa), 6 orbs, 12 árvores
- **Gameplay**: leaderstats, coleta de orbs com respawn de 6s, `ProximityPrompt` que
  troca a cor de todos os faróis, teleporte ao centro
- **HUD**: contador com barra animada, toast de aviso, botões de teleporte e ocultar

`DayCycle` é de [@Shyfoox](https://devforum.roblox.com), ciclo dia/noite de ~20 min.
