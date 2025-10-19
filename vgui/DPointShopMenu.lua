surface.CreateFont( "PS_Icons", {
	font = "marlett",
	size = math.Clamp( ScreenScaleH(10), 10, 18 ),
	weight = 700,
	antialias = true,
	symbol = true,
})

surface.CreateFont( "PS_IconsSmall", {
	font = "marlett",
	size = math.Clamp( ScreenScaleH(6), 6, 12 ),
	weight = 700,
	antialias = true,
	symbol = true,
})

surface.CreateFont( "PS_Heading", {
	font = "Roboto",
	size = 64,
	weight = 500,
	antialias = true,
})

surface.CreateFont( "PS_Default", {
	font = "Roboto",
	size = math.Clamp( ScreenScaleH(8), 8, 16 ),
	weight = 500,
	antialias = true,
})

surface.CreateFont( "PS_DefaultBold", {
	font = "Roboto-Bold",
	size = math.Clamp( ScreenScaleH(8), 8, 16 ),
	weight = 700,
	antialias = true,
})

surface.CreateFont( "PS_LargeTitle", {
	font = "Roboto-Bold",
	size = math.Clamp( ScreenScaleH(10), 10, 18 ),
	weight = 700, 
	antialias = true,
})

surface.CreateFont( "PS_ItemText", {
	font = "Roboto-Bold",
	size = math.Clamp( ScreenScaleH(8), 8, 16 ),
	weight = 700, 
	antialias = true,
})

local PANEL = {}

function PANEL:Init()
	self:SetSize( ScreenScale(512), ScreenScaleH(384) )
	self:SetPos((ScrW() / 2) - (self:GetWide() / 2), (ScrH() / 2) - (self:GetTall() / 2))
	self:DockPadding(math.Clamp(ScreenScaleH(2), 2, 4), math.Clamp(ScreenScaleH(2), 2, 4), math.Clamp(ScreenScaleH(2), 2, 4), math.Clamp(ScreenScaleH(2), 2, 4))

	self:SortCat()
	self:SortItems()
	local ply = LocalPlayer()

	local qTitleFrame = self:Panel(self, TOP, 0, PS.Config.Darkest, true)
	local qTitle = self:Label(qTitleFrame, LEFT, "PS_LargeTitle", PS.Config.CommunityName, 4, true)
	local qSubTitle = self:Label(qTitleFrame, LEFT, "PS_Default", "You have "..ply:PS_GetPoints().." "..PS.Config.PointsName..".", 4)

	qSubTitle.Think = function(self)
		if self:GetText() ~= tostring("You have "..ply:PS_GetPoints().." "..PS.Config.PointsName..".") then
			self:SetText("You have "..ply:PS_GetPoints().." "..PS.Config.PointsName..".")
		end
	end

	local qCloseButton = self:CloseButton(qTitleFrame, RIGHT)

	local qSidePanelL = self:Panel(self, LEFT, self:GetWide() / 6, PS.Config.Darker)

	local qCatPanel = self:Panel(qSidePanelL, TOP, qSidePanelL:GetWide(), PS.Config.Darker)
	local qButPanel = self:Panel(qSidePanelL, BOTTOM, qSidePanelL:GetWide(), PS.Config.Darker)

	if PS.Config.DisplayPreviewInMenu then
		local qSidePanelR = self:Panel(self, RIGHT, self:GetWide() / 4, PS.Config.Dark)
		local qPreview = vgui.Create('DPointShopPreview', qSidePanelR)
	end

	local qPointsBut = self:CatButton(qButPanel, nil, BOTTOM, "Gift "..PS.Config.PointsName, "money")
	qPointsBut.DoClick = function()
		vgui.Create('DPointShopGivePoints')
		surface.PlaySound("Buttons.snd14")
	end
		

	local qInv = self:Panel(self, FILL, 0, PS.Config.Dark)
	local qInvBut = self:CatButton(qButPanel, qInv, BOTTOM, "Inventory", "box")
	local qInvList = self:SubCatList(qInv, FILL, "Inventory")

	for category_id, CATEGORY in ipairs(qCategories) do
		local qCat = self:Panel(self, FILL, 0, PS.Config.Dark)
		local qCatBut = self:CatButton(qCatPanel, qCat, TOP, CATEGORY.Name, CATEGORY.Icon, CATEGORY.SubcategoryOrder)

		local qSubList = self:SubCatList(qCat, FILL, CATEGORY.Name)

		local qInvBuilt = self:SubCat(qInvList, FILL, CATEGORY.Name)
		local qInvItems = self:ItemPanel(qInvBuilt)
		qInvBuilt:SetContents(qInvItems)

		for i=1, #CATEGORY.SubcategoryOrder do -- looping INSIDE a loop?? :glasses:
			local qSubBuilt = self:SubCat(qSubList, FILL, CATEGORY.SubcategoryOrder[i])
			local qSubItems = self:ItemPanel(qSubBuilt)
			qSubBuilt:SetContents(qSubItems)

			for _, ITEM in ipairs(qItems) do -- looping INSIDE a loop INSIDE a loop???!! :glasses:glasses:
				if not ITEM.SubCategory then
					ITEM.SubCategory = CATEGORY.DefaultSubcategoryName
				end

				if (ITEM.Category ~= CATEGORY.Name or ITEM.SubCategory ~= CATEGORY.SubcategoryOrder[i])  then
					continue
				end

				if ply:PS_HasItem(ITEM.ID) then
					local qInvFrame = self:ItemFrame(qInvItems, qSubItems, ITEM, ply)
					local qItemContent = self:ItemContent(qInvFrame, "Inventory", CATEGORY.Name, ITEM)
					continue
				end

				local qItemFrame = self:ItemFrame(qSubItems, qInvItems, ITEM, ply)
				local qItemContent = self:ItemContent(qItemFrame, CATEGORY.Name, CATEGORY.SubcategoryOrder[i], ITEM)
			end
		end
	end

	return self
end

function PANEL:Paint(w, h)
	Derma_DrawBackgroundBlur(self, nil)
	surface.SetDrawColor(PS.Config.Black)
	surface.DrawOutlinedRect(0, 0, w, h, math.Clamp(ScreenScaleH(2), 2, 4))	
end

function PANEL:Panel(Parent, Dock, Width, Col, Outline) -- PANEL:Panel my beloved <3
	local qPanel = vgui.Create("DPanel", Parent)
	qPanel:Dock(Dock)
	qPanel:SetWidth(Width)
	qPanel:DockMargin(0, 0, 0, 0)

	if not Col then
		qPanel:SetDrawBackground(false)
		return qPanel
	end

	if not Outline then
		qPanel.Paint = function(s, w, h)
			draw.RoundedBox(0, 0, 0, w, h, Col)
		end

		return qPanel
	end

	qPanel:DockPadding(0, 0, 0, math.Clamp(ScreenScaleH(2), 2, 4))

	qPanel.Paint = function(s, w, h)
		draw.RoundedBox(0, 0, 0, w, h - math.Clamp(ScreenScaleH(2), 2, 4), Col)

		surface.SetDrawColor(PS.Config.Black)
		for i = 0, math.Clamp(ScreenScaleH(2), 2, 4) do
			surface.DrawLine(0, h - i, w, h - i)
		end
	end

	return qPanel
end

function PANEL:Label(Parent, Dock, Font, Text, ContentAlign, TitleBar)
	local qLabel = vgui.Create("DLabel", Parent)
	qLabel:Dock(Dock)
	qLabel:DockMargin(ScreenScaleH(2), 0, ScreenScaleH(2), 0)
	qLabel:SetFont(Font)
	qLabel:SetTextColor(PS.Config.White)
	qLabel:SetText(Text or "Pointshop")
	qLabel:SetContentAlignment(ContentAlign)
	qLabel:SizeToContents()
	qLabel:SetMouseInputEnabled(true)

	if TitleBar then
		Parent:SetTall(draw.GetFontHeight(Font) * 1.25)
	end

	return qLabel
end

function PANEL:CloseButton(Parent, Dock)
	local qCloseButton = vgui.Create("DButton", Parent)
	qCloseButton:Dock(Dock)
	qCloseButton:SetSize(Parent:GetTall() * 2, Parent:GetTall())
	qCloseButton:SetFont("PS_Icons")
	qCloseButton:SetColor(PS.Config.White)
	qCloseButton:SetText("r")

	qCloseButton.Paint = function(s,w,h)
		if qCloseButton:IsHovered() then
			draw.RoundedBox(0, 0, 0, w, h, PS.Config.Darker)
		end
	end

	qCloseButton.DoClick = function()
		PS:ToggleMenu()
	end

	return qCloseButton
end

function PANEL:CatButton(Parent, Panel, Dock, CatName, CatIcon)
 -- although it may seem more reasonable to use DColumnSheet, this does not readily support moving the buttons to a different panel which is needed for the bottom buttons. this can be worked around but requires overriding a lot of it's internal logic. since we already have our PANEL:Panel function (PANEL:Panel my beloved <3), it is more efficient to do it ourselves
	local qCatButton = vgui.Create("DButton", Parent)

	if Dock == TOP then
		qCatButton:DockMargin(math.Clamp(ScreenScaleH(2), 2, 4), math.Clamp(ScreenScaleH(2), 2, 4), math.Clamp(ScreenScaleH(2), 2, 4), 0)
	else
		qCatButton:DockMargin(math.Clamp(ScreenScaleH(2), 2, 4), 0, math.Clamp(ScreenScaleH(2), 2, 4), math.Clamp(ScreenScaleH(2), 2, 4))
	end
	qCatButton:Dock(Dock)
	qCatButton:SetTall(draw.GetFontHeight("PS_DefaultBold") * 2)
	qCatButton:SetFont("PS_DefaultBold")
	qCatButton:SetTextColor(PS.Config.White)
	qCatButton:SetText(CatName)
	qCatButton:SetImage("icon16/"..CatIcon..".png")
	Parent:SetTall(Parent:GetTall() + qCatButton:GetTall() + math.Clamp(ScreenScaleH(2), 2, 4))

	qCatButton.Paint = function(s, w, h)
		if qCatButton:IsHovered() or (IsValid(Panel) and Panel:IsVisible()) then
			draw.RoundedBox(0, 0, 0, w, h , PS.Config.Dark)
		end
	end

	if not IsValid(Panel) then
		return qCatButton
	end

	qCatButton.DoClick = function()
		if self.CatActive == Panel then
			return
		end

		if self.CatActive ~= nil then
			self.CatActive:ToggleVisible()
		end

		surface.PlaySound("Buttons.snd14")
		Panel:ToggleVisible()
		self.CatActive = Panel
	end

	if self.CatFirstAdded or CatName == "Inventory" then
		Panel:ToggleVisible()
		return qCatButton
	end
	
	self.CatActive = Panel
	self.CatFirstAdded = true
	
	return qCatButton
end

function PANEL:SubCatList(Parent, Dock, CatName)
	local qSubCatList = vgui.Create( "DCategoryList", Parent)
	qSubCatList:Dock(Dock)

	qSubCatList.Paint = function(s, w, h)
		draw.RoundedBox(0, 0, 0, w, h, PS.Config.Dark)
	end

	local vbar = qSubCatList:GetVBar()
	vbar.Paint = function(s, w, h) 
		draw.RoundedBox(0, 0, 0, w, h, PS.Config.Dark)
	end
	vbar.btnUp.Paint = function(s, w, h)
		draw.RoundedBox(0, 0, 0, w, h, PS.Config.Darker)
		draw.SimpleText("5", 'PS_Icons', w / 2, h / 2, PS.Config.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	vbar.btnDown.Paint = function(s, w, h) 
		draw.RoundedBox(0, 0, 0, w, h, PS.Config.Darker)
		draw.SimpleText("6", 'PS_Icons', w / 2, h / 2, PS.Config.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	vbar.btnGrip.Paint = function(s, w, h) 
		draw.RoundedBox(0, 0, 0, w, h, PS.Config.Darker)
	end
	vbar:SetWide(ScreenScaleH(6))
	vbar:DockMargin(ScreenScaleH(2), ScreenScaleH(4), ScreenScaleH(2), ScreenScaleH(4))

	return qSubCatList
end

function PANEL:SubCat(Parent, Dock, SubCatName)
	local qSubCategories = Parent:Add(SubCatName)
	qSubCategories:DockMargin(ScreenScaleH(4), ScreenScaleH(2), ScreenScaleH(4), ScreenScaleH(2))
	qSubCategories:SetHeaderHeight(draw.GetFontHeight("PS_DefaultBold") * 2)
	qSubCategories:SetAnimTime(0)
	qSubCategories.Header:SetContentAlignment(5)
	qSubCategories.Header:SetFont("PS_DefaultBold")
	qSubCategories.Header:SetTextColor(PS.Config.White)

	qSubCategories.Paint = function(s, w, h)
		surface.SetDrawColor(PS.Config.Black)
		surface.DrawOutlinedRect(0, 0, w, h, math.Clamp(ScreenScaleH(2), 2, 4))
		draw.RoundedBox(0, math.Clamp(ScreenScaleH(2), 2, 4), math.Clamp(ScreenScaleH(2), 2, 4), w - math.Clamp(ScreenScaleH(4), 4, 8), h - math.Clamp(ScreenScaleH(4), 4, 8), PS.Config.Dark)
	end

	qSubCategories.OnToggle = function()
		surface.PlaySound("Buttons.snd14")
	end

	qSubCategories.Header.Paint = function(s, w, h)
		surface.SetDrawColor(PS.Config.Black)
		surface.DrawOutlinedRect(0, 0, w, h, math.Clamp(ScreenScaleH(2), 2, 4))

		if qSubCategories:GetExpanded() or qSubCategories.Header:IsHovered() then
			draw.RoundedBox(0, math.Clamp(ScreenScaleH(2), 2, 4), math.Clamp(ScreenScaleH(2), 2, 4), w - math.Clamp(ScreenScaleH(4), 4, 8), h - math.Clamp(ScreenScaleH(4), 4, 8), PS.Config.Dark)
		else
			draw.RoundedBox(0, math.Clamp(ScreenScaleH(2), 2, 4), math.Clamp(ScreenScaleH(2), 2, 4), w - math.Clamp(ScreenScaleH(4), 4, 8), h - math.Clamp(ScreenScaleH(4), 4, 8), PS.Config.Darker)
		end
	end

	return qSubCategories
end

function PANEL:ItemPanel(Parent)
	local qItemPanel = vgui.Create('DIconLayout', Parent)
	qItemPanel:Dock(FILL)
	qItemPanel:DockPadding(math.Clamp(ScreenScaleH(4), 4, 8), math.Clamp(ScreenScaleH(4), 4, 8), math.Clamp(ScreenScaleH(4), 4, 8), math.Clamp(ScreenScaleH(4), 4, 8))
	qItemPanel:SetBorder(math.Clamp(ScreenScaleH(4), 4, 8))
	qItemPanel:SetSpaceX(math.Clamp(ScreenScaleH(4), 4, 8))
	qItemPanel:SetSpaceY(math.Clamp(ScreenScaleH(4), 4, 8))

	return qItemPanel
end

-- the majority of code from this point on is all item code. since dpointshopitem never gets reused outside of this menu, i opted to merge it here but it ended up larger than i expected so might split again some time
function PANEL:ItemFrame(Parent, Adopt, ITEM, ply)
	local qItemFrame = vgui.Create("DButton", Parent)
	qItemFrame:SetSize(ScreenScaleH(48), ScreenScaleH(48))
	qItemFrame:DockPadding(math.Clamp(ScreenScaleH(2), 2, 4), math.Clamp(ScreenScaleH(2), 2, 4), math.Clamp(ScreenScaleH(2), 2, 4), draw.GetFontHeight("PS_ItemText"))
	qItemFrame:SetFont("PS_ItemText")
	qItemFrame:SetContentAlignment(2)

	qItemFrame.Paint = function(s, w, h)
		if ply:PS_HasItem(ITEM.ID) then
			surface.SetDrawColor(PS.Config.Owned)
			qItemFrame:SetTextColor(PS.Config.Owned)

		elseif ply:PS_HasPoints(PS.Config.CalculateBuyPrice(ply, ITEM)) then
			surface.SetDrawColor(PS.Config.Afford)
			qItemFrame:SetTextColor(PS.Config.Afford)

		else
			surface.SetDrawColor(PS.Config.NotAfford)
			qItemFrame:SetTextColor(PS.Config.NotAfford)
		end

		if not qItemFrame:IsHovered() and not qItemFrame:IsChildHovered(true) then
			qItemFrame:SetText(ITEM.Name)
		else
			qItemFrame:SetText(PS.Config.CalculateBuyPrice(ply, ITEM))
		end

		qItemFrame:DrawFilledRect()
		surface.SetDrawColor(PS.Config.Darkest)
		surface.DrawOutlinedRect(0, 0, w, h, math.Clamp(ScreenScaleH(2), 2, 4))
		draw.RoundedBox(0, 0, h - draw.GetFontHeight("PS_ItemText"), w, h, PS.Config.Darkest)
	end

	qItemFrame.PaintOver = function(s, w, h)
		if ITEM.AdminOnly then
			surface.SetDrawColor(color_white)
			surface.SetMaterial(PS.Config.AdminIcon)
			surface.DrawTexturedRect(math.Clamp(ScreenScaleH(4), 4, 8), math.Clamp(ScreenScaleH(4), 4, 8), math.Clamp(ScreenScaleH(8), 8, 16), math.Clamp(ScreenScaleH(8), 8, 16))
		end

		if ply:PS_HasItemEquipped(ITEM.ID) then
			surface.SetDrawColor(color_white)
			surface.SetMaterial(PS.Config.EquippedIcon)
			surface.DrawTexturedRect(w - (math.Clamp(ScreenScaleH(8), 8, 16) + math.Clamp(ScreenScaleH(4), 4, 8)), math.Clamp(ScreenScaleH(4), 4, 8), math.Clamp(ScreenScaleH(8), 8, 16), math.Clamp(ScreenScaleH(8), 8, 16))
		end

		if ITEM.AllowedUserGroups and #ITEM.AllowedUserGroups > 0 then
			surface.SetDrawColor(color_white)
			surface.SetMaterial(PS.Config.GroupIcon)
			surface.DrawTexturedRect(math.Clamp(ScreenScaleH(4), 4, 8), h - (draw.GetFontHeight("PS_ItemText") + math.Clamp(ScreenScaleH(2), 2, 4) + math.Clamp(ScreenScaleH(8), 8, 16)), math.Clamp(ScreenScaleH(8), 8, 16), math.Clamp(ScreenScaleH(8), 8, 16))
		end

		if ply.PS_Items and ply.PS_Items[ITEM.ID] and ply.PS_Items[ITEM.ID].Modifiers and ply.PS_Items[ITEM.ID].Modifiers.color then
			surface.SetDrawColor(ply.PS_Items[ITEM.ID].Modifiers.color)
			surface.DrawRect(w - (math.Clamp(ScreenScaleH(8), 8, 16) + math.Clamp(ScreenScaleH(4), 4, 8)), (h - (draw.GetFontHeight("PS_ItemText") + math.Clamp(ScreenScaleH(2), 2, 4))) / 2, math.Clamp(ScreenScaleH(8), 8, 16), math.Clamp(ScreenScaleH(8), 8, 16))
		end
	end

	qItemFrame.DoClick = function()
		local points = PS.Config.CalculateBuyPrice(ply, ITEM)

		if not ply:PS_HasItem(ITEM.ID) and not ply:PS_HasPoints(points) then
			notification.AddLegacy("You do not have enough "..PS.Config.PointsName.." for this!", NOTIFY_GENERIC, 5)
			surface.PlaySound("Buttons.snd10")
			return
		end

		surface.PlaySound("Buttons.snd14")
		PANEL:ItemMenu(ply, ITEM, qItemFrame, Parent, Adopt)
	end

	qItemFrame.OnCursorEntered = function()
		self.Hovered = true	
		PS:SetHoverItem(ITEM.ID)
	end

	qItemFrame.OnCursorExited = function()
		self.Hovered = false	
		PS:RemoveHoverItem()
	end

	return qItemFrame
end

function PANEL:ItemModel(Parent, Width, Height, FOV, Player, ITEM)
	local qItemModel = vgui.Create("DModelPanel", Parent)
	qItemModel:Dock(FILL)
	qItemModel:SetModel(ITEM.Model)
	qItemModel:SetSize(ScreenScaleH(Width), ScreenScaleH(Height))
	qItemModel:SetMouseInputEnabled(false)

	if ITEM.ManipBone then
		if ITEM.ScaleBone then
			local Bone = qItemModel.Entity:LookupBone(ITEM.ScaleBone)

			if Bone ~= nil then
				qItemModel.Entity:ManipulateBoneScale(Bone, ITEM.ScaleVect)
			end
		end

		if ITEM.PosBone then
			local Bone = qItemModel.Entity:LookupBone(ITEM.PosBone)

			if Bone ~= nil then	
				qItemModel.Entity:ManipulateBonePosition(Bone, ITEM.PosVect)
			end
		end
	end

	if ITEM.Material then
		qItemModel.Entity:SetMaterial(ITEM.Material)
	end

	local qItemMin, qItemMax = qItemModel.Entity:GetRenderBounds()
	local qItemSize = 0
	qItemSize = math.max(qItemSize, math.abs(qItemMin.x) + math.abs(qItemMax.x))
	qItemSize = math.max(qItemSize, math.abs(qItemMin.y) + math.abs(qItemMax.y))
	qItemSize = math.max(qItemSize, math.abs(qItemMin.z) + math.abs(qItemMax.z))

	qItemModel:SetFOV(FOV)
	qItemModel:SetCamPos(Vector( qItemSize, qItemSize, qItemSize ))
	qItemModel:SetLookAt((qItemMax + qItemMin) * 0.5)

	function qItemModel:LayoutEntity(ent)
		if not Player then
			if Parent:IsHovered() or Parent:IsChildHovered() then
				local qRotateAngle = ent:GetAngles()
				qRotateAngle:RotateAroundAxis(Vector(0, 0, 0.1), 8)
				ent:SetAngles(qRotateAngle)
			elseif ent:GetAngles() ~= Angle(0, 0, 0) then
				ent:SetAngles(Angle(0, 0, 0))
			end
			return
		end

		if Parent:IsHovered() or Parent:IsChildHovered() then
			ent:SetSequence("menu_walk")
		else
			ent:SetSequence("idle_all_01")
		end

		qItemModel:RunAnimation()
	end

	Parent:SetSize(ScreenScaleH(Width), ScreenScaleH(Height))
	return qItemModel
end

function PANEL:ItemMat(Parent, ITEM)
	local qItemMat = vgui.Create("DImage", Parent)
	qItemMat:Dock(FILL)
	qItemMat:SetImage(ITEM.Material)
	qItemMat:SetSize(ScreenScaleH(48), ScreenScaleH(48))
	qItemMat:SetMouseInputEnabled(false)

	Parent:SetSize(ScreenScaleH(48), ScreenScaleH(48))
	return qItemMat
end

function PANEL:ItemMenu(ply, ITEM, qItem, qItemParent, qItemAdopt, SubMenu) -- this & PANEL:Query are a bit of a mess. could use a cleanup
	local BuyPoints = PS.Config.CalculateBuyPrice(ply, ITEM)
	local SellPoints = PS.Config.CalculateSellPrice(ply, ITEM)
	local qMenuPanel = vgui.Create("DPanel")
	RegisterDermaMenuForClose(qMenuPanel)
	qMenuPanel:DockPadding(2, 2, 2, 2)
	qMenuPanel:SetSize(ScreenScaleH(24), 4)
	qMenuPanel:SetIsMenu(true)
	qMenuPanel:SetPos(input.GetCursorPos())

	qMenuPanel.Paint = function(s, w, h)
		surface.SetDrawColor(PS.Config.Black)
		surface.DrawOutlinedRect(0, 0, w, h, 2)
		draw.RoundedBox(0, 2, 2, w - 4, h - 4, PS.Config.Darker)
	end

	qMenuPanel.GetDeleteSelf = function()
		return true
	end

	if SubMenu then
		return qMenuPanel
	end

	if ply:PS_HasItem(ITEM.ID) then
		PANEL:MenuBut(qMenuPanel, "Sell", function() PANEL:Query("Sell "..ITEM.Name.."?", SellPoints.." "..PS.Config.PointsName, "CANCEL", "CONFIRM", qItem, ITEM.ID, qItemParent, qItemAdopt, function() ply:PS_SellItem(ITEM.ID) end) end)

		if ply:PS_HasItemEquipped(ITEM.ID) then
			PANEL:MenuSpacer(qMenuPanel)
			PANEL:MenuBut(qMenuPanel, "Holster", function() ply:PS_HolsterItem(ITEM.ID) end)

			if ITEM.Modify then
				PANEL:MenuSpacer(qMenuPanel)
				PANEL:MenuBut(qMenuPanel, "Modify", function() PS.Items[ITEM.ID]:Modify(ply.PS_Items[ITEM.ID].Modifiers) end)
			end

		else
			PANEL:MenuSpacer(qMenuPanel)
			PANEL:MenuBut(qMenuPanel, "Equip", function() ply:PS_EquipItem(ITEM.ID) end)
		end

		if PS.Config.CanPlayersGiveItems and player.GetCount() > 1 then
			PANEL:MenuSpacer(qMenuPanel)

			local qGiveBut = PANEL:MenuBut(qMenuPanel, "Gift Item")
			local qGiveIcon = PANEL:Label(qGiveBut, NODOCK, "PS_IconsSmall", "4", 5)
			qGiveIcon:SetMouseInputEnabled(false)
			qGiveIcon:SetPos((qGiveBut:GetWide() - qGiveIcon:GetWide()) - 4, qGiveBut:GetTall() / 4)

			local qGiveMenu = PANEL:ItemMenu(ply, ITEM, qItem, qItemParent, qItemAdopt, true)
			qGiveMenu:SetPos(qMenuPanel:GetX() + qMenuPanel:GetWide() + 2, qMenuPanel:GetY() + (qMenuPanel:GetTall() - qGiveBut:GetTall() - 4))
			qGiveMenu:SetVisible(false)

			qGiveBut.OnCursorEntered = function()
				timer.Simple(0.1, function()
					qGiveMenu:SetVisible(true)
				end)
			end

			qGiveBut.OnCursorExited = function()
				timer.Simple(0.1, function()
					if qGiveMenu:IsHovered() or qGiveMenu:IsChildHovered() then
						return
					end

					qGiveMenu:SetVisible(false)
				end)
			end

			for _, ply in ipairs(player.GetHumans()) do
				if ply == LocalPlayer() then
					continue
				end

				local qPlyBut = PANEL:MenuBut(qGiveMenu, ply:Nick(), function()
					net.Start('PS_SendItem')
					net.WriteEntity(ply)
					net.WriteString(ITEM.ID)
					net.WriteString(ITEM.Name)
					net.SendToServer()

					timer.Simple(0.1, function() -- need timer for PS_HasItem to return updated value
						if LocalPlayer():PS_HasItem(ITEM.ID) then
							surface.PlaySound("Buttons.snd10")
							return
						end

						if qItem:GetParent() ~= qItemAdopt then
							qItemAdopt:Add(qItem)
							return
						end

						qItemParent:Add(qItem)
					end)
				end)

				qPlyBut.OnCursorExited = function()
					timer.Simple(0.1, function()
						if qGiveBut:IsHovered() then
							return
						end

						qGiveMenu:SetVisible(false)
					end)
				end
			end
		end

	elseif ply:PS_HasPoints(BuyPoints) then
		PANEL:MenuBut(qMenuPanel, "Buy", function() PANEL:Query("Purchase "..ITEM.Name.."?", BuyPoints.." "..PS.Config.PointsName, "CANCEL", "CONFIRM", qItem, ITEM.ID, qItemParent, qItemAdopt, function() ply:PS_BuyItem(ITEM.ID) end) end)
	end

	return qMenuPanel
end

function PANEL:MenuBut(Parent, Text, Func)
	local qMenuBut = vgui.Create("DButton", Parent)
	qMenuBut:Dock(TOP)
	qMenuBut:SetFont("PS_Default")
	qMenuBut:SetTextColor(PS.Config.White)
	qMenuBut:SetText(Text)

	local TextWidth, TextHeight = qMenuBut:GetTextSize()
	qMenuBut:SetSize(TextWidth * 1.5, TextHeight)
	Parent:SetSize(math.max(Parent:GetWide(), qMenuBut:GetWide()), Parent:GetTall() + qMenuBut:GetTall())
	qMenuBut:SetWide(Parent:GetWide())

	qMenuBut.Paint = function(s, w, h)
		if qMenuBut:IsHovered() then
			draw.RoundedBox(0, 0, 0, w, h, PS.Config.Dark)
		end
	end

	qMenuBut.DoClick = function()
		if not Func then
			return
		end

		Func()
		surface.PlaySound("Buttons.snd14")
		CloseDermaMenus()
	end

	return qMenuBut
end

function PANEL:MenuSpacer(Parent)
	local qMenuSpacer = vgui.Create("DPanel", Parent)
	qMenuSpacer:Dock(TOP)
	qMenuSpacer:SetTall(1)
	Parent:SetTall(Parent:GetTall() + qMenuSpacer:GetTall())

	qMenuSpacer.Paint = function(s, w, h)
		surface.SetDrawColor(PS.Config.Black)
		surface.DrawLine(2, 0, w - 4, 0)
	end

	return qMenuSpacer
end

function PANEL:Query(qText01, qText02, qButText01, qButText02, qItem, qItemID, qItemParent, qItemAdopt, qButAction) -- query could possibly be broken out into its own file
	local qItemState = LocalPlayer():PS_HasItem(qItemID)
	local qItemSizeZ, qItemSizeY = qItem:GetSize()
	local qItemChild = qItem:GetChild(0)
	local qQuery = vgui.Create("EditablePanel")
	qQuery:SetSize(qItemSizeZ * 1.75, qItemSizeY * 2)
	qQuery:DockPadding(math.Clamp(ScreenScaleH(2), 2, 4), math.Clamp(ScreenScaleH(2), 2, 4), math.Clamp(ScreenScaleH(2), 2, 4), math.Clamp(ScreenScaleH(2), 2, 4))
	qQuery:Center()
	qQuery:MakePopup()
	qQuery:DoModal()

	qQuery.Paint = function(s, w, h)
		Derma_DrawBackgroundBlur(qQuery, nil)
		surface.SetDrawColor(PS.Config.Black)
		surface.DrawOutlinedRect( 0, 0, w, h, math.Clamp(ScreenScaleH(2), 2, 4) )
		draw.RoundedBox(0, math.Clamp(ScreenScaleH(2), 2, 4), math.Clamp(ScreenScaleH(2), 2, 4), w - math.Clamp(ScreenScaleH(4), 4, 8), h - math.Clamp(ScreenScaleH(4), 4, 8), PS.Config.Darker)
	end

	local qButCancel = function()
		qQuery:Remove()
		qItem:Add(qItemChild)
		qItemChild:SetSize(qItemSizeZ, qItemSizeY)
		qItemChild:SetMouseInputEnabled(false)
	end

	local qButConfirm = function()
		qQuery:Remove()
		qButAction()
		qItem:Add(qItemChild)
		qItemChild:SetSize(qItemSizeZ, qItemSizeY)
		qItemChild:SetMouseInputEnabled(false)

		timer.Simple(0.1, function() -- PS_HasItem will not return an updated value without a timer
			if qItemState == LocalPlayer():PS_HasItem(qItemID) then
				surface.PlaySound("Buttons.snd10")
				return
			end

			if qItem:GetParent() ~= qItemAdopt then
				qItemAdopt:Add(qItem)
			else
				qItemParent:Add(qItem)
			end
		end)
	end

	local qQueryFrame = PANEL:Panel(qQuery, BOTTOM, qQuery:GetWide() / 2, nil)
	qQueryFrame:DockMargin(math.Clamp(ScreenScaleH(4), 4, 8), math.Clamp(ScreenScaleH(4), 4, 8), math.Clamp(ScreenScaleH(4), 4, 8), math.Clamp(ScreenScaleH(4), 4, 8))
	
	PANEL:Label(qQuery, TOP, "PS_DefaultBold", qText01, 5, false)
	PANEL:Label(qQuery, TOP, "PS_Default", qText02, 5, false)
	PANEL:QueryBut(qQueryFrame, LEFT, "PS_Default", qButText01, qButCancel)
	PANEL:QueryBut(qQueryFrame, RIGHT, "PS_Default", qButText02, qButConfirm)

	qItemChild:SetParent(qQuery)
	qItemChild:Dock(FILL)
	qItemChild:SetMouseInputEnabled(false)

	return qQuery
end

function PANEL:QueryBut(Parent, Dock, Font, Text, qButAction)
	local qQueryBut = vgui.Create("DButton", Parent)
	qQueryBut:Dock(Dock)
	qQueryBut:SetWide(Parent:GetWide() * 0.75)
	qQueryBut:SetFont(Font)
	qQueryBut:SetTextColor(PS.Config.White)
	qQueryBut:SetText(Text)

	Parent:SetTall(draw.GetFontHeight(Font) * 1.25)

	qQueryBut.Paint = function(s, w, h)
		surface.SetDrawColor(PS.Config.Black)
		surface.DrawOutlinedRect(0, 0, w, h, 2)

		if qQueryBut:IsHovered() or qQueryBut:GetToggle() then
			draw.RoundedBox(0, 2, 2, w - 4, h - 4, PS.Config.Dark)
		else
			draw.RoundedBox(0, 2, 2, w - 4, h - 4, PS.Config.Darker)
		end
	end

	qQueryBut.DoClick = function()
		qButAction()
		surface.PlaySound("Buttons.snd14")
	end

	return qQueryBut
end

function PANEL:ItemContent(Parent, qCategory, qSubCategory, ITEM)
	if ITEM.Model then
		if ITEM.Attachment or ITEM.Bone or ITEM.WeaponClass or ITEM.NoPreview then
			local qItemContent = PANEL:ItemModel(Parent, 48, 48, 45, false, ITEM)
		else
			local qItemContent = PANEL:ItemModel(Parent, 48, 96, 25, true, ITEM)
		end
	end

	if ITEM.Material and not ITEM.Model then
		local qItemContent = PANEL:ItemMat(Parent, ITEM)
	end

	return qItemContent
end

function PANEL:SortCat()
	qCategories = {}

	for _, CATEGORY in pairs(PS.Categories) do
		table.insert(qCategories, CATEGORY)
	end

	table.sort(qCategories, function(a, b)
		if a.Order == b.Order then
			return a.Name < b.Name
		else
			return a.Order < b.Order
		end
	end)
end

function PANEL:SortItems()
	qItems = {}

	for _, i in pairs(PS.Items) do
		table.insert(qItems, i)
	end

	table.SortByMember(qItems, PS.Config.SortItemsBy, function(a, b)
		return a > b 
	end)
end

vgui.Register('DPointShopMenu', PANEL)
