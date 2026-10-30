--!strict
--// Animações puramente visuais dos objetos do mapa (flutuar, girar).
--// Rodam só no cliente: não pesam no servidor e não precisam replicar.

local CollectionService = game:GetService("CollectionService")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Tags = require(RS:WaitForChild("Compartilhado"):WaitForChild("Tags"))

type Movimento = (base: CFrame, t: number) -> CFrame

type Animado = {
	base: CFrame,
	fase: number,
	movimento: Movimento,
}

local MOVIMENTOS: { [string]: Movimento } = {
	[Tags.ORB] = function(base, t)
		return CFrame.new(base.Position + Vector3.yAxis * math.sin(t * 2) * 0.8) * CFrame.Angles(0, t, 0)
	end,
	[Tags.NUCLEO] = function(base, t)
		return CFrame.new(base.Position + Vector3.yAxis * math.sin(t) * 0.6)
			* CFrame.Angles(math.rad(25), t * 0.8, math.rad(15))
	end,
	[Tags.VITRINE] = function(base, t)
		return CFrame.new(base.Position + Vector3.yAxis * math.sin(t * 1.5) * 0.3)
			* CFrame.Angles(0, t * 0.6, 0)
			* CFrame.Angles(math.rad(-30), 0, 0)
	end,
}

local Animacoes = {}

local animados: { [BasePart]: Animado } = {}

function Animacoes.iniciar()
	for tag, movimento in MOVIMENTOS do
		Tags.observar(tag, function(instancia)
			if instancia:IsA("BasePart") and not animados[instancia] then
				animados[instancia] = { base = instancia.CFrame, fase = math.random() * 10, movimento = movimento }
			end
		end)
		CollectionService:GetInstanceRemovedSignal(tag):Connect(function(instancia)
			animados[instancia :: BasePart] = nil
		end)
	end

	RunService.Heartbeat:Connect(function()
		local agora = os.clock()
		for parte, a in animados do
			parte.CFrame = a.movimento(a.base, agora + a.fase)
		end
	end)
end

return Animacoes
