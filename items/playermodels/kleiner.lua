ITEM.Name = 'Kleiner'
ITEM.Price = 250
ITEM.Model = 'models/player/kleiner.mdl'

function ITEM:OnEquip(ply, modifications)
	if not ply._OldModel then
		ply._OldModel = ply:GetModel()
	end

  ply:PS_SetModel(self.Model)
end

function ITEM:OnHolster(ply)
	if ply._OldModel then
		ply:PS_SetModel(ply._OldModel)
	end
end

function ITEM:PlayerSetModel(ply)
	ply:PS_SetModel(self.Model)
end
