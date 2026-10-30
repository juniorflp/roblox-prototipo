--!strict
--// Catálogo de itens: dados que servidor e cliente compartilham.
--// O visual de cada item fica em assets/Itens/<id> (vira ServerStorage.Itens no Studio).

export type Raridade = "Comum" | "Raro" | "Epico" | "Lendario"

export type Item = {
	id: string,
	nome: string,
	descricao: string,
	raridade: Raridade,
}

local Itens: { [string]: Item } = {
	Lanterna = {
		id = "Lanterna",
		nome = "Lanterna",
		descricao = "Ilumina o caminho à noite. Clique para ligar.",
		raridade = "Comum",
	},
}

return Itens
