local PANEL = {}
local DPointShopMenu = vgui.GetControlTable("DPointShopMenu")

function PANEL:Init()
	self:SetSize(ScreenScaleH(128), ScreenScaleH(128))
	self:SetPos((ScrW() / 2) - (self:GetWide() / 2), (ScrH() / 2) - (self:GetTall() / 2))
	self:DockPadding(math.Clamp(ScreenScaleH(2), 2, 4), math.Clamp(ScreenScaleH(2), 2, 4), math.Clamp(ScreenScaleH(2), 2, 4), math.Clamp(ScreenScaleH(2), 2, 4))
	self:MakePopup()
	self:DoModal()

	local qPanel = DPointShopMenu:Panel(self, FILL, self:GetWide(), PS.Config.Darker, false)
	DPointShopMenu:Label(qPanel, TOP, "PS_DefaultBold", "Color Picker", 5, false)

	self.qColorPicker = self:ColorPicker(qPanel, FILL)

	local qButFrame = DPointShopMenu:Panel(qPanel, BOTTOM, self:GetWide() / 2, nil)
	qButFrame:DockMargin(math.Clamp(ScreenScaleH(4), 4, 8), math.Clamp(ScreenScaleH(4), 4, 8), math.Clamp(ScreenScaleH(4), 4, 8), math.Clamp(ScreenScaleH(4), 4, 8))

	DPointShopMenu:QueryBut(qButFrame, LEFT, "PS_Default", "Cancel", function()
		self:Remove()
	end)

	DPointShopMenu:QueryBut(qButFrame, RIGHT, "PS_Default", "Confirm", function()
		self.OnChoose(self.qColorPicker:GetColor())
		self:Remove()
	end)
end

function PANEL:Paint(w, h)
	Derma_DrawBackgroundBlur(self, nil)
	surface.SetDrawColor(PS.Config.Black)
	surface.DrawOutlinedRect(0, 0, w, h, math.Clamp(ScreenScaleH(2), 2, 4))	
end

function PANEL:ColorPicker(Parent, Dock)
	local qColorPicker = vgui.Create('DColorMixer', Parent)
	qColorPicker:Dock(Dock)
	qColorPicker:DockMargin(math.Clamp(ScreenScaleH(4), 4, 8), 0, math.Clamp(ScreenScaleH(4), 4, 8), 0)
	qColorPicker:SetPalette(false)
	qColorPicker:SetAlphaBar(false) -- pointshop seems to ignore alpha values

	qColorPicker.HSV.PaintOver = function(s, w, h)
		surface.SetDrawColor(PS.Config.Black)
		surface.DrawOutlinedRect(0, 0, w, h, 2)
	end

	qColorPicker.HSV.Knob:SetSize(self:GetWide() / 32, self:GetTall() / 32)
	qColorPicker.HSV.Knob.Paint = function(s, w, h)
		surface.SetDrawColor(PS.Config.Black)
		surface.DrawOutlinedRect(0, 0, w, h, 2)

		surface.SetDrawColor(color_white)
		surface.DrawRect(2, 2, w - 4, h - 4)
	end

	qColorPicker.RGB:SetWide(self:GetWide() / 12)
	qColorPicker.RGB.PaintOver = function(s, w, h)
		surface.SetDrawColor(PS.Config.Black)
		surface.DrawOutlinedRect(0, 0, w, h, 2)
	end

	for i=1, 3 do -- ehhhh maybe it would be better to write own function for the color picker if overriding so much?
		local pnl = nil
		local col = nil

		if i == 1 then
			pnl = qColorPicker.txtR
			col = PS.Config.Red
		elseif i == 2 then
			pnl = qColorPicker.txtG
			col = PS.Config.Green
		elseif i == 3 then
			pnl = qColorPicker.txtB
			col = PS.Config.Blue
		end

		pnl:SetTall(self:GetTall() / 16)
		pnl:SetPaintBackground(false)
		pnl:SetFont("PS_Default")
		pnl:SetTextColor(col)
		pnl:SetCursorColor(PS.Config.White)
		pnl:SetHighlightColor(col)
		pnl.PaintOver = function(s, w, h)
			surface.SetDrawColor(PS.Config.Black)
			surface.DrawOutlinedRect(0, 0, w, h, 2)
		end
		pnl.Up:SetFont("PS_IconsSmall")
		pnl.Up:SetTextColor(col)
		pnl.Up:SetText("5")
		pnl.Up.Paint = function() end
		pnl.Down:SetFont("PS_IconsSmall")
		pnl.Down:SetTextColor(col)
		pnl.Down:SetText("6")
		pnl.Down.Paint = function() end
	end

	qColorPicker.WangsPanel:SetWide(self:GetWide() / 8)

	return qColorPicker
end

function PANEL:OnChoose(color)
	-- nothing, gets over-ridden
end

function PANEL:SetColor(Col)
	self.qColorPicker:SetColor(Col or color_white)
end

vgui.Register("DPointShopColorChooser", PANEL, "EditablePanel")
