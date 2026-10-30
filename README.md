# protótipo roblox

Protótipo de teste: praça circular, parkour, orbs colecionáveis, um item (Lanterna) e HUD.

O projeto é **híbrido**, como nos estúdios:

- **Código e modelos de itens** ficam neste repositório e chegam ao Studio pelo Rojo.
- **O mapa** (`Workspace.Mapa`) fica no place publicado na Roblox
  (placeId `104410580710448`) e é editado visualmente no Studio. Ele não vai para o Git.
- O código acha os objetos do mapa por **tags** (`src/shared/Tags.luau`).

## Estrutura

| Pasta | Vira, no Studio |
|---|---|
| `src/server/` | `ServerScriptService.Jogo` (Script + módulos) |
| `src/client/` | `StarterPlayer.StarterPlayerScripts.Cliente` (LocalScript + módulos) |
| `src/shared/` | `ReplicatedStorage.Compartilhado` |
| `assets/Itens/` | `ServerStorage.Itens` (modelos dos itens) |
| *(no place)* | `Workspace.Mapa`, `Lighting` |

## Rodando

1. No Studio, abra o place pela sua conta (ele está publicado na Roblox).
2. No terminal, na pasta do projeto:
   ```bash
   rojo serve          # porta 34872
   ```
3. No Studio: **Plugins → Rojo → Connect**. Daí em diante, salvar um arquivo atualiza o Studio na hora.
4. **Play** (F5) para jogar.

Mudou o mapa? **File → Save to Roblox** (Cmd/Ctrl+S). Mudou código? Commit e push.

DataStore no Studio: Experience Settings → *Enable Studio Access to API Services*.

## Comandos úteis

```bash
rojo serve                      # sync ao vivo
rojo build -o prototipo.rbxl    # gera um place só com o código (sem o mapa)
rojo sourcemap -o sourcemap.json
```

## O que tem dentro

- **Mapa**: praça de 120 studs, 8 pilares com faróis, pedestal com núcleo flutuante,
  parkour (6 degraus + mirante + rampa), 6 orbs, expositor da Lanterna, 12 árvores
- **Gameplay**: leaderstats, coleta de orbs com respawn de 6s, `ProximityPrompt` que
  troca a cor de todos os faróis, teleporte ao centro (com cooldown)
- **Itens**: Lanterna (pega no pedestal, clique liga/desliga), inventário salvo no DataStore
- **HUD**: contador com barra animada, toast de aviso, botões de teleporte e ocultar
- **Animações**: flutuar/girar rodam só no cliente (`src/client/Animacoes.luau`)

`DayCycle` é de [@Shyfoox](https://devforum.roblox.com), ciclo dia/noite de ~20 min.
