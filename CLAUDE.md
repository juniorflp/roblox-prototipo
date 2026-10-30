# CLAUDE.md

Guia para o Claude (e para qualquer dev) trabalhar neste projeto Roblox. As regras valem para todo código novo; o código existente que ainda não segue está em **Débitos conhecidos**.

## Visão geral

- Jogo Roblox em **Luau**, sincronizado com o Studio pelo **Rojo 7** (mapeamento em `default.project.json`).
- **Fluxo híbrido, como nos estúdios:**
  - **Código e modelos de itens** → repositório (Git), sincronizados pelo Rojo.
  - **Mapa** (`Workspace.Mapa`, iluminação, terreno) → vive no **place publicado na Roblox**, editado visualmente no Studio. Salvo com **File → Save to Roblox** (Cmd/Ctrl+S); o histórico de versões do place é o "Git do mapa".
  - O código nunca constrói o mapa: acha os objetos por **tag** (`src/shared/Tags.luau`).
- Idioma do projeto: português. Identificadores sem acento (`criarRemotes`, `pastaOrbs`); strings e comentários podem ter acento.

## Fluxo de trabalho

```bash
rojo serve                       # sync ao vivo (Studio: Plugins → Rojo → Connect)
rojo build -o prototipo.rbxl     # gera o place do zero (serve como "build" do projeto)
rojo sourcemap -o sourcemap.json # para o luau-lsp entender os requires
```

Ciclo de código: edita `.luau` no editor → salva → Rojo atualiza o Studio → Play no Studio → commit.
Ciclo de mapa: edita no Studio → Play → **Save to Roblox** (não vai para o Git).

O Rojo só mexe nos caminhos listados no `default.project.json`; `Workspace` e `Lighting` não estão lá, então ele nunca sobrescreve o mapa.

## Regras para o Claude

1. **Código só em `src/` e `assets/`.** Nunca altere scripts dentro do Studio (nem via MCP `multi_edit`/`execute_luau`): o Rojo sobrescreve e a mudança se perde.
2. **Use o MCP do Roblox Studio para tudo no Studio** (preferência do usuário):
   - inspecionar: `search_game_tree`, `inspect_instance`, `script_read`, `screen_capture`
   - testar: `start_stop_play`, `get_console_output`, `character_navigation`, `user_keyboard_input`
   - **editar o mapa**: `execute_luau` no modo Edit, dentro de `ChangeHistoryService:TryBeginRecording` (o usuário pode desfazer com Ctrl+Z). Objetos com função no jogo recebem a tag certa. Depois, **lembre o usuário de salvar o place** (o MCP não salva na nuvem).
3. **Antes de dizer que terminou** uma mudança de gameplay: rode um play-test pelo MCP e confirme que o console não tem erros nem warnings novos. Se o Studio não estiver conectado, diga que não foi testado.
4. **Assets criados no Studio** (meshes geradas, modelos da Toolbox, terreno) não entram no repo sozinhos. Avise o usuário e combine onde salvar (ex.: `assets/*.rbxm` + entrada no `default.project.json`).
5. Não fazer commit/push sem pedido. Mensagens de commit em português, no imperativo.
6. Ao adicionar ferramenta, biblioteca ou pasta nova, atualize este arquivo e o `README.md`.

## Arquitetura

| Pasta | No Studio | Quem vê |
|---|---|---|
| `src/server/` | `ServerScriptService.Jogo` | só o servidor |
| `src/client/` | `StarterPlayer.StarterPlayerScripts.Cliente` | só o cliente |
| `src/shared/` | `ReplicatedStorage.Compartilhado` | os dois |
| `assets/Itens/` | `ServerStorage.Itens` | só o servidor (modelos dos itens) |
| *(fora do Git)* | `Workspace.Mapa`, `Lighting` | todos; vive no place da Roblox |

### Tags do mapa

| Tag | Em quê | Quem usa |
|---|---|---|
| `Orb` | parte colecionável | `Gameplay` (coleta), `Animacoes` (flutua) |
| `Nucleo` | parte com `ProximityPrompt` | `Gameplay` (troca cor), `Animacoes` (gira) |
| `Farol` | partes que mudam de cor junto com o núcleo | `Gameplay` |
| `Expositor` | pedestal com atributo `ItemId` + `ProximityPrompt` | `Inventario` (coleta do item) |
| `Vitrine` | cópia decorativa do item sobre o pedestal | `Animacoes` (gira) |
| `DestinoTeleporte` | parte invisível, destino do botão "Voltar ao centro" | `Gameplay` |

Para criar mais um orb, por exemplo: duplicar um orb no Studio (Ctrl+D), mover e salvar. A tag vem junto e o código já reconhece.

Convenções de arquivo do Rojo: `init.server.luau` → Script, `init.client.luau` → LocalScript, `Nome.server.luau`/`Nome.client.luau` → Script/LocalScript solto, `Nome.luau` → ModuleScript.

- **Um ponto de entrada por contexto** (`init.server.luau`, `init.client.luau`) que faz `require` dos módulos e chama `iniciar()`/`criar()`. Evite Scripts soltos: a ordem de execução entre eles não é garantida.
- **Módulos** retornam uma tabela com funções públicas; estado interno fica em `local` no módulo.
- **Constantes e números de design** (tempos, cores, preços, cooldowns) vão em `src/shared/Config.luau`, nada de números mágicos espalhados. **Posições e layout ficam no mapa**, não no código.
- Ao crescer, organize por responsabilidade: `src/server/Servicos/`, `src/client/Controladores/`, `src/shared/Util/`, `src/shared/Tipos.luau`.
- Use **CollectionService** (tags) para achar objetos do mundo, em vez de depender de nome/caminho.

### Adicionando um item (padrão da Lanterna)

1. **Modelo**: `assets/Itens/<Id>.model.json` (texto) ou `<Id>.rbxmx` exportado do Studio (clique direito → *Save to File*). Raiz é uma `Tool` com atributo `ItemId`.
2. **Catálogo**: entrada em `src/shared/Itens.luau` (nome, descrição, raridade).
3. **Comportamento**: função em `USOS` no `src/server/Inventario.luau`, ligada pela tag `Item` (funciona também nas cópias de respawn).
4. **Onde aparece**: no Studio, duplicar `Workspace.Mapa.Expositores.PedestalLanterna`, mudar o atributo `ItemId` e o `ObjectText` do prompt, trocar a vitrine e salvar o place.

Persistência: `src/server/Dados.luau` guarda `perfil.itens[id] = true`. Campos novos no perfil exigem tratar em `migrar()` e, se mudar o formato, subir `VERSAO`.

## Cliente × servidor (a regra mais importante)

O cliente roda na máquina do jogador e **pode ser modificado por exploiters**. Tudo o que vem dele é suspeito.

- **Servidor é autoridade** sobre pontos, moedas, inventário, dano, compras, teleporte e progresso. O cliente só pede e exibe.
- **Valide todo argumento de Remote** no servidor: tipo (`typeof`), faixa, existência da instância, distância do player, se a ação faz sentido agora.
- **Rate limit por player** em todo `OnServerEvent`/`OnServerInvoke`.
- Remotes são criados pelo servidor; o cliente usa `WaitForChild`.
- Nunca use `RemoteFunction:InvokeClient`: um cliente que não responde trava a thread do servidor.
- Segredos e lógica sensível só em `ServerScriptService`/`ServerStorage`. Tudo em `ReplicatedStorage` é público.
- Física: partes perto do jogador podem ter *network ownership* do cliente. Para objetos de gameplay críticos use `part:SetNetworkOwner(nil)`.
- Efeitos puramente visuais (girar, piscar, tween de UI, partículas) rodam **no cliente**; o servidor replica só o estado.

Padrão de handler:

```luau
local ultimoUso: { [Player]: number } = {}

remote.OnServerEvent:Connect(function(player: Player, alvoId: unknown)
	local agora = os.clock()
	if agora - (ultimoUso[player] or 0) < Config.COOLDOWN_ACAO then
		return
	end
	ultimoUso[player] = agora

	if typeof(alvoId) ~= "number" or alvoId ~= alvoId then -- rejeita NaN
		return
	end
	-- ... valida existência/distância, depois aplica
end)

Players.PlayerRemoving:Connect(function(player)
	ultimoUso[player] = nil
end)
```

## Estilo Luau

- `--!strict` no topo de todo arquivo novo; tipe parâmetros e retornos de funções públicas. Use `export type` para tipos compartilhados.
- Serviços no topo: `local Players = game:GetService("Players")`.
- Use a biblioteca `task` (`task.wait`, `task.spawn`, `task.delay`, `task.defer`). Nunca `wait()`, `spawn()`, `delay()` (deprecated).
- Configure as propriedades de uma `Instance` **antes** de setar `Parent`.
- `WaitForChild` só onde há replicação ou ordem incerta; no mesmo contexto use referência direta.
- Iteração: `for _, x in lista do` (iteração generalizada) ou `ipairs` para arrays.
- Nomes: `camelCase` para locais e funções, `PascalCase` para módulos e Instances, `MAIUSCULAS` para constantes de `Config`.
- Cada arquivo começa com um comentário `--//` dizendo o que ele faz (padrão atual).
- Erros esperados (rede, DataStore, Marketplace) sempre em `pcall`; nunca deixe uma chamada `*Async` sem tratamento.

## Performance

- Evite um loop `Heartbeat` por objeto. Prefira um loop central sobre uma lista, ou mova a animação para o cliente.
- Partes estáticas `Anchored = true`; desligue `CanCollide`/`CanTouch`/`CanQuery` quando não precisar.
- Mobile é a maior fatia de jogadores: limite `PointLight`/`SpotLight` com sombra, partículas e número de partes.
- Avalie `Workspace.StreamingEnabled` quando o mapa crescer.
- Objetos criados/destruídos com frequência (projéteis, efeitos): use pool em vez de `Instance.new` + `Destroy`.
- Ferramentas de diagnóstico: Developer Console (F9: Memory, Network, Scripts), MicroProfiler (Ctrl+Alt+F6), Script Profiler.

## Memória e ciclo de vida

- Guarde as conexões que não morrem junto com a instância e chame `:Disconnect()` quando acabar.
- Limpe tabelas indexadas por `Player` em `Players.PlayerRemoving`.
- Para objetos com muitos recursos, use o padrão Trove/Janitor (um objeto que junta conexões e instâncias e limpa tudo de uma vez).
- Loops `while instancia.Parent do` precisam ter garantia de terminar.

## Persistência (DataStore)

`src/server/Dados.luau` já faz o básico: `UpdateAsync`, `pcall` com retry e backoff, save em `PlayerRemoving`/`BindToClose`, autosave, kick se o carregamento falhar (para não sobrescrever progresso com perfil vazio) e DataStore `_Studio` separado. O que falta para produção:

- **Session locking** (evita duplicar itens quando o jogador troca de servidor rápido). Migrar para **ProfileStore** antes de liberar trocas entre jogadores.
- Chave por `UserId` (`"Player_" .. player.UserId`), nunca por nome.
- Dados com `versao` no schema, para migrar sem perder progresso.
- Em Studio: Game Settings → Security → *Enable Studio Access to API Services*, e use um DataStore com nome diferente para testes.

## Monetização

- `MarketplaceService.ProcessReceipt` precisa ser **idempotente**: registre o `PurchaseId` e só retorne `PurchaseGranted` depois de salvar o item.
- Gamepass: `UserOwnsGamePassAsync` no servidor, com `pcall` e cache por sessão.
- Nunca conceda item porque o cliente disse que comprou.

## UI

- Posições/tamanhos em **Scale** + `UIAspectRatioConstraint`/`UISizeConstraint`; teste no **Device Emulator** (celular, tablet, console).
- Alvos de toque com pelo menos ~44px; respeite a área segura (`ScreenGui.ScreenInsets`).
- Suporte teclado, toque e gamepad (`ContextActionService`, `GuiService.SelectedObject`).
- HUDs persistentes com `ResetOnSpawn = false` (a HUD atual já usa).
- Todo texto **digitado por jogadores** e exibido a outros precisa passar por `TextService:FilterStringAsync` (exigência dos Termos da Roblox).

## Testes

Três camadas, da mais barata para a mais cara:

1. **Unitários (lógica pura).** Separe lógica (calcular, validar, regras) de efeitos (Instances, rede). Módulos puros ficam em `src/shared/` e são testados com **Jest-Lua** (arquivos `Modulo.spec.luau` ao lado do módulo), rodando no Studio ou fora dele com **Lune**. *Ainda não configurado.*
2. **Play-test no Studio.** `start_stop_play` + `get_console_output` pelo MCP, ou F5. Para replicação e multiplayer: aba Test → *Clients and Servers* com 2+ jogadores.
3. **Checklist manual antes de publicar:**
   - console limpo (servidor e cliente)
   - entrar, sair e reentrar; morrer e respawnar
   - Device Emulator em celular e tablet
   - lag simulado (Studio Settings → Network → *Incoming Replication Lag*)
   - persistência (sair e voltar mantém os dados)
   - tentar o "caminho do exploiter": disparar remotes com argumentos inválidos pelo `execute_luau` no cliente

## Ferramentas

Instalado hoje: **Rojo 7.7**. Padrão do mercado, a configurar quando o projeto crescer:

| Ferramenta | Para quê |
|---|---|
| **Rokit** | fixa as versões das ferramentas abaixo em `rokit.toml` |
| **StyLua** | formatação automática (`stylua src`) |
| **Selene** | linter (`selene src`) |
| **luau-lsp** | autocomplete e checagem de tipos no VS Code (usa o `sourcemap.json`) |
| **Wally** | gerenciador de pacotes (`wally.toml`, pasta `Packages/`) |
| **Lune** | roda Luau fora do Studio (scripts, testes) |
| **Jest-Lua** | framework de testes |

Bibliotecas comuns: ProfileStore (dados), Trove/Janitor (limpeza), Promise, GoodSignal, ByteNet/Packet (rede eficiente), Fusion ou React-Lua (UI declarativa).

## CI e publicação

- **CI (GitHub Actions)** em todo PR: `stylua --check src`, `selene src`, `rojo build`, testes.
- **Deploy** pelo Open Cloud (API key em GitHub Secrets): publica primeiro num **place de staging**, depois produção.
- Teste em servidor privado antes de abrir para o público; o Studio guarda o histórico de versões do place para rollback.
- Preencha o questionário de **Maturity & Compliance** antes de publicar.
- Use `AnalyticsService` (funis, economia, eventos) para medir retenção e onde os jogadores desistem.

## Git

- `main` sempre roda (`rojo build` funciona). Trabalho em branches `feat/...`, `fix/...`.
- Commits pequenos, em português, no imperativo ("Adiciona cooldown no teleporte").
- Não versionar `.rbxl`/`.rbxlx` nem `sourcemap.json` (já no `.gitignore`). Ao instalar o Wally, adicione `Packages/` ao `.gitignore`.

## Débitos conhecidos

- `leaderstats` (orbs) ainda não é salvo; só o inventário de itens.
- `Dados.luau` sem session locking.
- `HUD` e `DayCycle` ainda sem `--!strict`.
- Remotes criados em runtime pelo servidor (`Gameplay.criarRemotes`). Alternativa mais robusta: declará-los no `default.project.json`.
- Aviso `rbxassetid://203785492 ... Asset type does not match` no console durante o play-test. Nenhuma instância do place usa esse id, então provavelmente vem do avatar do jogador. É inofensivo, pode ignorar.
- `DayCycle.server.luau` é um Script solto (de terceiros) fora do ponto de entrada.
- Sem StyLua, Selene, testes ou CI configurados.
