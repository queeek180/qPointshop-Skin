local PANEL = {}
local DPointShopMenu = vgui.GetControlTable("DPointShopMenu")

function PANEL:Init()
	self:SetSize(ScreenScaleH(128), ScreenScaleH(128))
	self:SetPos((ScrW() / 2) - (self:GetWide() / 2), (ScrH() / 2) - (self:GetTall() / 2))
	self:DockPadding(math.Clamp(ScreenScaleH(2), 2, 4), math.Clamp(ScreenScaleH(2), 2, 4), math.Clamp(ScreenScaleH(2), 2, 4), math.Clamp(ScreenScaleH(2), 2, 4))
	self:MakePopup()
	self:DoModal()

	local qPanel = DPointShopMenu:Panel(self, FILL, self:GetWide(), PS.Config.Darker, false)
	qPanel:SetTall(self:GetTall())
	DPointShopMenu:Label(qPanel, TOP, "PS_DefaultBold", "Give "..PS.Config.PointsName, 5, false)

	local qGiveFrame = DPointShopMenu:Panel(qPanel, FILL, self:GetWide(), nil)
	qGiveFrame:SetTall(qPanel:GetTall())
	qGiveFrame:DockMargin(math.Clamp(ScreenScaleH(4), 4, 8), 0, math.Clamp(ScreenScaleH(4), 4, 8), 0)

	local qPlyBut = self:PlayerList(qGiveFrame, FILL)

	local qNumberWang = self:NumberWang(qGiveFrame, RIGHT)

	local qButFrame = DPointShopMenu:Panel(qPanel, BOTTOM, self:GetWide() / 2, nil)
	qButFrame:DockMargin(math.Clamp(ScreenScaleH(4), 4, 8), math.Clamp(ScreenScaleH(4), 4, 8), math.Clamp(ScreenScaleH(4), 4, 8), math.Clamp(ScreenScaleH(4), 4, 8))

	DPointShopMenu:QueryBut(qButFrame, LEFT, "PS_Default", "Cancel", function()
		self:Remove()
	end)

	DPointShopMenu:QueryBut(qButFrame, RIGHT, "PS_Default", "Confirm", function()
		self:Remove()

		if not IsValid(self.PlySelected) or qNumberWang:GetValue() > LocalPlayer():PS_GetPoints() then
			surface.PlaySound("Buttons.snd10")
			return
		end

		net.Start('PS_SendPoints')
		net.WriteEntity(self.PlySelected)
		net.WriteInt(qNumberWang:GetValue(), 32)
		net.SendToServer()
	end)
end

function PANEL:Paint(w, h)
	Derma_DrawBackgroundBlur(self, nil)
	surface.SetDrawColor(PS.Config.Black)
	surface.DrawOutlinedRect(0, 0, w, h, math.Clamp(ScreenScaleH(2), 2, 4))	
end

function PANEL:PlayerList(Parent, Dock)
	local qPlyFrame = vgui.Create("DPanel", Parent)
	qPlyFrame:Dock(Dock)
	qPlyFrame:DockPadding(math.Clamp(ScreenScaleH(2), 2, 4), math.Clamp(ScreenScaleH(2), 2, 4), math.Clamp(ScreenScaleH(2), 2, 4), math.Clamp(ScreenScaleH(2), 2, 4))

	qPlyFrame.Paint = function(s, w, h)
		surface.SetDrawColor(PS.Config.Black)
		surface.DrawOutlinedRect(0, 0, w, h, 2)	
		draw.RoundedBox(0, 2, 2, w - 4, h - 4, PS.Config.Darker)
	end

	local qPlyList = vgui.Create("DScrollPanel", qPlyFrame)
	qPlyList:Dock(FILL)

	local vbar = qPlyList:GetVBar()
	vbar.Paint = function(s, w, h) 
		draw.RoundedBox(0, 0, 0, w, h, PS.Config.Darker)
	end
	vbar.btnUp.Paint = function(s, w, h)
		draw.RoundedBox(0, 0, 0, w, h, PS.Config.Darkest)
		draw.SimpleText("5", 'PS_Icons', w / 2, h / 2, PS.Config.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	vbar.btnDown.Paint = function(s, w, h) 
		draw.RoundedBox(0, 0, 0, w, h, PS.Config.Darkest)
		draw.SimpleText("6", 'PS_Icons', w / 2, h / 2, PS.Config.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	vbar.btnGrip.Paint = function(s, w, h) 
		draw.RoundedBox(0, 0, 0, w, h, PS.Config.Darkest)
	end
	vbar:SetWide(ScreenScaleH(4))
	vbar:DockMargin(0, math.Clamp(ScreenScaleH(2), 2, 4), 0, 0)

	for _, ply in ipairs(player.GetHumans()) do
		if ply == LocalPlayer() then
			continue
		end

		local qPlyBut = DPointShopMenu:QueryBut(qPlyList, TOP, "PS_Default", ply:Nick())
		qPlyBut:DockMargin(math.Clamp(ScreenScaleH(2), 2, 4), math.Clamp(ScreenScaleH(2), 2, 4), math.Clamp(ScreenScaleH(2), 2, 4), 0)
		qPlyBut:SetIsToggle(true)

		qPlyBut.DoClick = function()
			if self.Toggled == qPlyBut then
				return
			end

			if IsValid(self.Toggled) then
				self.Toggled:Toggle()
			end

			qPlyBut:Toggle()
			self.Toggled = qPlyBut
			self.PlySelected = ply
			surface.PlaySound("Buttons.snd14")
		end

		qPlyList:Add(qPlyBut)
	end

	return qPlyFrame
end

function PANEL:NumberWang(Parent, Dock)
	local qWangFrame = vgui.Create("DPanel", Parent)
	qWangFrame:Dock(Dock)
	qWangFrame:DockMargin(math.Clamp(ScreenScaleH(2), 2, 4), 0, math.Clamp(ScreenScaleH(2), 2, 4), 0)
	qWangFrame:SetSize(Parent:GetWide() / 6, Parent:GetTall())
	qWangFrame:SetDrawBackground(false)

	local qNumberWang = vgui.Create("DNumberWang", qWangFrame)
	qNumberWang:Dock(TOP)
	qNumberWang:SetTall(qWangFrame:GetTall() / 12)
	qNumberWang:SetMinMax(1, LocalPlayer():PS_GetPoints())
	qNumberWang:SetDecimals(0)
	qNumberWang:SetPaintBackground(false)
	qNumberWang:SetFont("PS_Default")
	qNumberWang:SetTextColor(PS.Config.White)
	qNumberWang:SetCursorColor(PS.Config.White)
	qNumberWang:SetHighlightColor(PS.Config.Blue)

	qNumberWang.PaintOver = function(s, w, h)
		surface.SetDrawColor(PS.Config.Black)
		surface.DrawOutlinedRect(0, 0, w, h, 2)
	end

	qNumberWang.Up:SetFont("PS_IconsSmall")
	qNumberWang.Up:SetTextColor(PS.Config.White)
	qNumberWang.Up:SetText("5")
	qNumberWang.Up.Paint = function() end

	qNumberWang.Down:SetFont("PS_IconsSmall")
	qNumberWang.Down:SetTextColor(PS.Config.White)
	qNumberWang.Down:SetText("6")
	qNumberWang.Down.Paint = function() end

	-- below are hacks to fix the number value not capping when text box is used
	qNumberWang.HasFocus = function()
		return false
	end

	qNumberWang.OnValueChanged = function(self)
		if self:GetValue() > self:GetMax() or self:GetValue() < self:GetMin() then
			self:SetText(math.Clamp(self:GetValue(), self:GetMin(), self:GetMax()))
		end
	end

	return qNumberWang
end

vgui.Register('DPointShopGivePoints', PANEL, "EditablePanel")
