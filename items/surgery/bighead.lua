ITEM.Name = 'Big Head'
ITEM.Price = 750
ITEM.Model = "models/player/kleiner.mdl"
ITEM.ManipBone = true
ITEM.ScaleBone = "ValveBiped.Bip01_Head1"
ITEM.ScaleVect = Vector(2.5, 2.5, 2.5)
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
