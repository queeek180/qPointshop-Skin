local PANEL = {}
local DPointShopMenu = vgui.GetControlTable("DPointShopMenu")

function PANEL:Init()
	self:Dock(FILL)
	self:DockMargin(2, math.Clamp(ScreenScaleH(10), 10, 18), math.Clamp(ScreenScaleH(10), 10, 18), math.Clamp(ScreenScaleH(10), 10, 18))
	self.Angles = Angle(0, 0, 0)
	self.Model = LocalPlayer():GetModel()
	self:SetModel(self.Model)

	local qModelMin, qModelMax = self.Entity:GetRenderBounds()
	local qModelSize = 0
	qModelSize = math.max(qModelSize, math.abs(qModelMin.x) + math.abs(qModelMax.x))
	qModelSize = math.max(qModelSize, math.abs(qModelMin.y) + math.abs(qModelMax.y))
	qModelSize = math.max(qModelSize, math.abs(qModelMin.z) + math.abs(qModelMax.z))

	self:SetFOV(25)
	self:SetCamPos(Vector(qModelSize, qModelSize, qModelSize) - Vector(0, qModelSize, 0))
	self:SetLookAt((qModelMax + qModelMin) / 1.75)

	return self
end

function PANEL:PaintOver(w, h)
		surface.SetDrawColor(PS.Config.Black)
		surface.DrawOutlinedRect(0, 0, w, h, math.Clamp(ScreenScaleH(2), 2, 4))
end

function PANEL:OnDepressed()
	self.PressX, self.PressY = input.GetCursorPos()
	self.Pressed = true
end

function PANEL:OnReleased()
	self.Pressed = false
end

function PANEL:OnMouseWheeled(ScrollDelta)
	local OldFov = self:GetFOV()

	if OldFov == 1 and ScrollDelta == 1 then
		return
	end

	if OldFov == 45 and ScrollDelta == -1 then
		return
	end

	self:SetFOV(OldFov - ScrollDelta)
end

function PANEL:LayoutEntity(ent)
	if self.bAnimated then 
		self:RunAnimation() 
	end

	if self.Pressed then
		self.qCursorX, self.qCursorY = input.GetCursorPos()

		if not input.IsShiftDown() then
			self.Angles = self.Angles - Angle(0, self.PressX - self.qCursorX, 0)
		else
			self.Angles = self.Angles - Angle(self.PressY - self.qCursorY, 0, 0)
		end

		self.PressX, self.PressY = input.GetCursorPos()
	end

	ent:SetAngles(self.Angles)
end

function PANEL:PostDrawModel()
	local ply = LocalPlayer()

	if PS.ClientsideModels[ply] then
		for item_id, model in pairs(PS.ClientsideModels[ply]) do
			local ITEM = PS.Items[item_id]

			if not ITEM.Attachment and not ITEM.Bone then
				PS.ClientsideModel[ply][item_id] = nil
				continue
			end

			local pos = Vector()
			local ang = Angle()

			if ITEM.Attachment then
				local attach_id = self.Entity:LookupAttachment(ITEM.Attachment)

				if not attach_id then
					return
				end

				local attach = self.Entity:GetAttachment(attach_id)

				if not attach then
					return
				end

				pos = attach.Pos
				ang = attach.Ang
			else
				local bone_id = self.Entity:LookupBone(ITEM.Bone)

				if not bone_id then 
					return
				end

				pos, ang = self.Entity:GetBonePosition(bone_id)
			end

			model, pos, ang = ITEM:ModifyClientsideModel(ply, model, pos, ang)

			model:SetPos(pos)
			model:SetAngles(ang)

			model:SetRenderOrigin(pos)
			model:SetRenderAngles(ang)
			model:SetupBones()
			model:DrawModel()
			model:SetRenderOrigin()
			model:SetRenderAngles()
		end
	end

	if PS.HoverModel then
		local ITEM = PS.Items[PS.HoverModel]

		if ITEM.NoPreview then
			return
		end

		if ITEM.WeaponClass then
			return
		end

		if ITEM.ManipBone then
			if ITEM.ScaleBone then
				local Bone = self.Entity:LookupBone(ITEM.ScaleBone)

				if Bone ~= nil then	
					self.Entity:ManipulateBoneScale(Bone, ITEM.ScaleVect)
					self.PreviewScaledBone = Bone
				end
			end

			if ITEM.PosBone then
				local Bone = self.Entity:LookupBone(ITEM.PosBone)

				if Bone ~= nil then	
					self.Entity:ManipulateBonePosition(Bone, ITEM.PosVect)
					self.PreviewPosedBone = Bone
				end
			end

			self.PreviewHasBoneManipulations = true
			return
		end

		if not ITEM.Attachment and not ITEM.Bone then
			if not util.IsValidModel(ITEM.Model) then
				return
			end

			self:SetModel(ITEM.Model)

			if ply:GetBoneName(0) ~= "static_prop" then
				self:UpdateBones(self.Entity)
			end
		else
			local model = PS.HoverModelClientsideModel

			local pos = Vector()
			local ang = Angle()

			if ITEM.Attachment then
				local attach_id = self.Entity:LookupAttachment(ITEM.Attachment)

				if not attach_id then
					return
				end

				local attach = self.Entity:GetAttachment(attach_id)

				if not attach then
					return
				end

				pos = attach.Pos
				ang = attach.Ang
			else
				local bone_id = self.Entity:LookupBone(ITEM.Bone)

				if not bone_id then 
					return
				end

				pos, ang = self.Entity:GetBonePosition(bone_id)
			end

			model, pos, ang = ITEM:ModifyClientsideModel(ply, model, pos, ang)

			model:SetPos(pos)
			model:SetAngles(ang)

			model:DrawModel()
		end
	end

	if not PS.HoverModel then
		if ply:GetBoneName(0) ~= "static_prop" and self:GetModel() ~= ply:GetModel() then
			self.model = ply:GetModel()
			self:SetModel(self.model)
			self:UpdateBones(self.Entity)
		end

		if self.PreviewHasBoneManipulations then
			if self.PreviewPosedBone then
				self.Entity:ManipulateBonePosition(self.PreviewPosedBone, Vector(0, 0, 0))
			end

			if self.PreviewScaledBone then
				self.Entity:ManipulateBoneScale(self.PreviewScaledBone, Vector(1, 1, 1))
			end

			self.PreviewHasBoneManipulations = false
		end

		if ply:GetBoneName(0) ~= "static_prop" then
			self:UpdateBones(self.Entity) -- HasBoneManipulations always returns true if the entity has EVER had bone manipulations, so TODO: write a function for pointshop to track this properly and avoid running this constantly
		end
	end

	if PS.HoverMaterial then
		local ITEM = PS.Items[PS.HoverMaterial]

		if ITEM.NoPreview then
			return
		end

		self.Entity:SetMaterial(ITEM.Material)
	end

	if not PS.HoverMaterial then
		self.Entity:SetMaterial(ply:GetMaterial())
	end
end

function PANEL:UpdateBones(ent)
	ent:InvalidateBoneCache()
	local ply = LocalPlayer()

	for i=0, ent:GetBoneCount() do
		local PlyBoneName = ply:GetBoneName(i)
		local EntBone = ent:LookupBone(PlyBoneName)

		if not EntBone then
			continue
		end

		ent:ManipulateBonePosition(EntBone, ply:GetManipulateBonePosition(i))
		ent:ManipulateBoneScale(EntBone, ply:GetManipulateBoneScale(i))
	end
end

vgui.Register('DPointShopPreview', PANEL, 'DModelPanel')
