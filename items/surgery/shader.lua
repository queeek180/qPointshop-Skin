ITEM.Name = "Moist"
ITEM.Price = 8000
ITEM.Model = "models/player/kleiner.mdl"
ITEM.Material = "models/shadertest/shader3"
ITEM.SubCategory = "Skin Graft"

function ITEM:OnEquip(ply, modifications)
	ply:SetMaterial(self.Material)
	ply.PS_HasMaterial = true
end

function ITEM:OnHolster(ply)
	ply:SetMaterial("")
	ply.PS_HasMaterial = false
end

function ITEM:PlayerSetMaterial(ply)
	ply:SetMaterial(self.Material)
end

function ITEM:CanPlayerEquip(ply)
	if tobool(ply.PS_HasMaterial) then
		return false
	end
	
	return true
end
