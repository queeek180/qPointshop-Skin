ITEM.Name = "Long Right Arm"
ITEM.Price = 375
ITEM.Model = "models/player/kleiner.mdl"
ITEM.ManipBone = true
ITEM.PosBone = "ValveBiped.Bip01_R_UpperArm"
ITEM.PosVect = Vector(15, -20, 1)
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
