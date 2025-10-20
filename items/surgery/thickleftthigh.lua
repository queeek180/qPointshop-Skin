ITEM.Name = 'Thick Left Thigh'
ITEM.Price = 375
ITEM.Model = "models/player/kleiner.mdl"
ITEM.ManipBone = true
ITEM.ScaleBone = "ValveBiped.Bip01_L_Thigh"
ITEM.ScaleVect = Vector(1.5, 3, 1.5)
ITEM.SubCategory = "Joint Correction"

function ITEM:OnEquip(ply, modifications)
	local ScaleBone = ply:LookupBone(self.ScaleBone)

	if ScaleBone ~= nil then	
		ply:ManipulateBoneScale(ScaleBone, self.ScaleVect)
	end
end

function ITEM:OnHolster(ply)
	local ScaleBone = ply:LookupBone(self.ScaleBone)
	
	if ScaleBone ~= nil then
		ply:ManipulateBoneScale(ScaleBone, Vector(1, 1, 1))
	end
end

function ITEM:ModelSet(ply)
	self:OnEquip(ply)
end
