
local myname, Squeenix = ...


----------------------
--      Locals      --
----------------------

local tekcheck = LibStub("tekKonfig-Checkbox")
local tekbutton = LibStub("tekKonfig-Button")
local tekslider = LibStub("tekKonfig-Slider")
local tekdropdown = LibStub("tekKonfig-Dropdown")
local GAP = 8


---------------------
--      Panel      --
---------------------

if AddonLoader and AddonLoader.RemoveInterfaceOptions then AddonLoader:RemoveInterfaceOptions("Squeenix") end

local frame = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)
frame.name = "Squeenix"
frame:Hide()
frame:SetScript("OnShow", function(frame)
	local Squeenix = Squeenix
	local title, subtitle = LibStub("tekKonfig-Heading").new(frame, "Squeenix", "General settings for the Squeenix square minimap.")


	local lockpos = tekcheck.new(frame, nil, "Lock minimap", "TOPLEFT", subtitle, "BOTTOMLEFT", -2, -GAP)
	lockpos.tiptext = "Locks the minimap to prevent accidental movement"
	local checksound = lockpos:GetScript("OnClick")
	lockpos:SetScript("OnClick", function(self) checksound(self); Squeenix.db.unlocked = not Squeenix.db.unlocked; Squeenix:SetPosition() end)
	lockpos:SetChecked(not Squeenix.db.unlocked)


	local resetpos = tekbutton.new_small(frame, "TOP", lockpos, "CENTER", 0, 11)
	resetpos:SetPoint("RIGHT", frame, "CENTER", -16, 0)
	resetpos:SetText("Reset")
	resetpos.tiptext = "Reset the minimap to the default position"
	resetpos:SetScript("OnClick", function(self) Squeenix.db.x, Squeenix.db.y, Squeenix.db.anchorframe, Squeenix.db.anchor = nil; Squeenix:SetPosition() end)


	local showcompass = tekcheck.new(frame, nil, "Show full compass", "TOPLEFT", lockpos, "BOTTOMLEFT", 0, -GAP)
	showcompass.tiptext = "Add 'ESW' compass directions to the map"
	showcompass:SetScript("OnClick", function(self) checksound(self); Squeenix.db.hidecompass = not Squeenix.db.hidecompass; Squeenix:ShowCompass() end)
	showcompass:SetChecked(not Squeenix.db.hidecompass)


	local refresh = tekbutton.new_small(frame, "TOP", showcompass, "CENTER", 0, 11)
	refresh:SetPoint("RIGHT", frame, "CENTER", -16, 0)
	refresh:SetText("Refresh")
	refresh.tiptext = "Refresh the minimap, should fix blanked out maps."
	refresh:SetScript("OnClick", function(self) Minimap:SetMaskTexture("Interface\\AddOns\\Squeenix\\Mask.blp") end)


	local scrollzoom = tekcheck.new(frame, nil, "Use mousewheel zoom", "TOPLEFT", showcompass, "BOTTOMLEFT", 0, -GAP)
	scrollzoom.tiptext = "Zoom the minimap using the mouse scroll wheel"
	scrollzoom:SetScript("OnClick", function(self) checksound(self); Squeenix.db.noscrollzoom = not Squeenix.db.noscrollzoom end)
	scrollzoom:SetChecked(not Squeenix.db.noscrollzoom)


	local scaleslider, scaleslidertext, scalecontainer = tekslider.new(frame, string.format("Scale: %.2f", Squeenix.db.scale or 1), 0.5, 2, "TOPLEFT", scrollzoom, "BOTTOMLEFT", 2, -GAP)
	scaleslider.tiptext = "Set the minimap scale."
	scaleslider:SetValue(Squeenix.db.scale or 1)
	scaleslider:SetValueStep(.05)
	scaleslider:SetScript("OnValueChanged", function(self)
		Squeenix.db.scale = self:GetValue()
		scaleslidertext:SetText(string.format("Scale: %.2f", Squeenix.db.scale or 1))
		Squeenix:SetScale()
	end)


	local borderdropdown, borderdropdowntext, borderdropdowncontainer = tekdropdown.new(frame, "Border style", "TOPLEFT", scalecontainer, "BOTTOMLEFT", 0, -GAP)
	borderdropdowntext:SetText(Squeenix.db.border or "Rounded")
	borderdropdown.tiptext = "Change the minimap border style."

	local function OnClick(self)
		UIDropDownMenu_SetSelectedValue(borderdropdown, self.value)
		borderdropdowntext:SetText(self.value)
		Squeenix:SetBorder(self.value)
	end
	UIDropDownMenu_Initialize(borderdropdown, function()
		local selected, info = UIDropDownMenu_GetSelectedValue(borderdropdown) or "Rounded", UIDropDownMenu_CreateInfo()

		for name in pairs(Squeenix.borders) do
			info.text = name
			info.value = name
			info.func = OnClick
			info.checked = name == selected
			UIDropDownMenu_AddButton(info)
		end
	end)


	-- Hide minimap buttons
	local zoom = tekcheck.new(frame, nil, "Show zoom buttons", "TOP", subtitle, "BOTTOM", 0, -GAP)
	zoom:SetPoint("LEFT", frame, "CENTER", GAP, 0)
	local checksound = zoom:GetScript("OnClick")
	zoom:SetScript("OnClick", function(self) checksound(self); Squeenix.db.hideMinimapZoom = not Squeenix.db.hideMinimapZoom; Squeenix:HideButtons() end)
	zoom:SetChecked(not Squeenix.db.hideMinimapZoom)


	local mail = tekcheck.new(frame, nil, "Show new mail indicator", "TOPLEFT", zoom, "BOTTOMLEFT", 0, -GAP)
	mail:SetScript("OnClick", function(self) checksound(self); Squeenix.db.hideMiniMapMailFrame = not Squeenix.db.hideMiniMapMailFrame; Squeenix:HideButtons() end)
	mail:SetChecked(not Squeenix.db.hideMiniMapMailFrame)


	local anchor = mail
	for name,desc in pairs(Squeenix.hidesetupframes) do
		local check = tekcheck.new(frame, nil, "Show "..desc, "TOPLEFT", anchor, "BOTTOMLEFT", 0, -GAP)
		check:SetScript("OnClick", function(self) checksound(self); Squeenix.db["hide"..name] = not Squeenix.db["hide"..name]; Squeenix:HideButtons() end)
		check:SetChecked(not Squeenix.db["hide"..name])
		anchor = check
	end


	frame:SetScript("OnShow", nil)
end)

InterfaceOptions_AddCategory(frame)


-----------------------------
--      Slash command      --
-----------------------------

SLASH_SQUEENIX1 = "/squee"
SLASH_SQUEENIX2 = "/squeenix"
SlashCmdList.SQUEENIX = function(input)
	if input:find("refresh") then Minimap:SetMaskTexture("Interface\\AddOns\\Squeenix\\Mask.blp")
	else InterfaceOptionsFrame_OpenToCategory(frame) end
end


----------------------------------------
--      Quicklaunch registration      --
----------------------------------------

LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("Squeenix", {
	type = "launcher",
	icon = "Interface\\Icons\\INV_Gizmo_BronzeFramework_01",
	OnClick = function()
		if IsShiftKeyDown() then Minimap:SetMaskTexture("Interface\\AddOns\\Squeenix\\Mask.blp")
		else InterfaceOptionsFrame_OpenToCategory(frame) end
	end,
})
