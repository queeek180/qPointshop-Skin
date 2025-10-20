ITEM.Name = "Tall"
ITEM.Price = 750
ITEM.Model = "models/player/kleiner.mdl"
ITEM.ManipBone = true
ITEM.PosBone = "ValveBiped.Bip01_Spine2"
ITEM.PosVect = Vector(40, 0, 0)
ITEM.SubCategory = "Joint Correction"

function ITEM:OnEquip(ply, modifications)
	local PosBone = ply:LookupBone(self.PosBone)

	if PosBone ~= nil then		
		ply:ManipulateBonePosition(PosBone, self.PosVect, true)
	end
end

function ITEM:OnHolster(ply)
	local PosBone = ply:LookupBone(self.PosBone)
	
	if PosBone ~= nil then
		ply:ManipulateBonePosition(PosBone, Vector(1, 1, 1), true)
	end
end

function ITEM:ModelSet(ply)
	self:OnEquip(ply)
end
