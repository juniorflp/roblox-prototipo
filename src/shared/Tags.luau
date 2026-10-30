--!strict
--// Tags que ligam o mapa (montado no Studio) ao código.
--// Aplique no Studio: selecione o objeto → Properties → Tags (ou View → Tag Editor).

local CollectionService = game:GetService("CollectionService")

local Tags = {}

Tags.ORB = "Orb"
Tags.NUCLEO = "Nucleo"
Tags.FAROL = "Farol"
Tags.EXPOSITOR = "Expositor" -- atributo ItemId + ProximityPrompt filho
Tags.VITRINE = "Vitrine"
Tags.DESTINO_TELEPORTE = "DestinoTeleporte"
Tags.ITEM = "Item" -- ferramentas entregues ao jogador

-- Chama `callback` para cada instância com a tag: as que já existem e as que surgirem
-- depois (com StreamingEnabled, partes do mapa chegam ao cliente aos poucos).
function Tags.observar(tag: string, callback: (Instance) -> ()): RBXScriptConnection
	for _, instancia in CollectionService:GetTagged(tag) do
		task.spawn(callback, instancia)
	end
	return CollectionService:GetInstanceAddedSignal(tag):Connect(callback)
end

return Tags
