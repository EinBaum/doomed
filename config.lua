
--------------------------------------------------------------------------------
-- Saved Variables
--------------------------------------------------------------------------------

Doom:SetScript('OnEvent', function()
	Doom[event](arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)
end)
Doom:RegisterEvent('PLAYER_ENTERING_WORLD')

function Doom.PLAYER_ENTERING_WORLD()
	if not DoomDB then
		DoomDB = {showbg = true, scale = 1, strata = 2}
	end

   Doom.config.scale:SetValue(DoomDB.scale)
   Doom.config.strata:SetValue(DoomDB.strata)

   Doom.showBackground(DoomDB.showbg)

   Doom.setPowerType(UnitPowerType('player'))
   Doom.UNIT_HEALTH('player')

   Doom:RegisterEvent('UNIT_COMBAT')
   Doom:RegisterEvent('UNIT_HEALTH')
   Doom:RegisterEvent('UNIT_AURA')
   Doom:RegisterEvent('UNIT_DISPLAYPOWER')

   Doom:SetScript('OnUpdate', Doom.OnUpdate)
end

--------------------------------------------------------------------------------
-- Configuration UI
-- Currently just for setting scale and strata.
--------------------------------------------------------------------------------

Doom.config = CreateFrame('Frame', nil, UIParent)
local ui = Doom.config

ui:Hide()
ui:SetFrameStrata('HIGH')
ui:SetPoint('Center', UIParent, 'Center', 0, 0)
ui:SetWidth(230)
ui:SetHeight(172)
ui:SetHitRectInsets(0, 0, -10, 0) -- for titlebar
ui:SetBackdrop {
   bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
   edgeFile = 'Interface\\DialogFrame\\UI-DialogBox-Border',
   insets = { left=6, right=6, top=6, bottom=6 },
   tile=true, tileSize=128, edgeSize=24
}
Doom.MakeDraggable(ui)

ui.titlebar = ui:CreateTexture(nil, 'ARTWORK')
ui.titlebar:SetTexture('Interface\\DialogFrame\\UI-DialogBox-Header')
ui.titlebar:SetPoint('TopLeft', ui, 'TopLeft', -5, 15)
ui.titlebar:SetPoint('BottomRight', ui, 'TopRight', 0, -50)

ui.titletext = ui:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
ui.titletext:SetPoint('Top', ui, 'Top', 0, 1)
ui.titletext:SetText('Doom Config')

ui.scale = CreateFrame('Slider', 'DoomScale', ui, 'OptionsSliderTemplate')
ui.scale:SetPoint('Top', ui, 'Top', 0, -45)
ui.scale:SetMinMaxValues(.5, 2.5)
ui.scale:SetValueStep(.1)
ui.scale:SetScript('OnValueChanged',
   function()
      DoomDB.scale = arg1
      Doom:SetScale(arg1)
      DoomScaleText:SetText(format('Scale: %.1f', arg1))
   end
   )

ui.close = CreateFrame('Button', nil, ui, 'UIPanelButtonTemplate')
ui.close:SetHeight(22)
ui.close:SetWidth(96)
ui.close:SetPoint('Bottom', ui, 'Bottom', 0, 16)
ui.close:SetScript('OnClick', function() ui:Hide() end)
ui.close:SetText('Okay')

local strata_lookup = { 'LOW', 'MEDIUM', 'HIGH', 'DIALOG', 'FULLSCREEN', 'TOOLTIP' }
ui.strata = CreateFrame('Slider', 'DoomStrata', ui, 'OptionsSliderTemplate')
ui.strata:SetPoint('Bottom', ui.scale, 'Top', 0, -70)
ui.strata:SetMinMaxValues(1, 6)
ui.strata:SetValueStep(1)
ui.strata:SetScript('OnValueChanged',
   function()
      DoomDB.strata = arg1
      Doom:SetFrameStrata(strata_lookup[DoomDB.strata])
      DoomStrataText:SetText(format('Strata: %s', strata_lookup[arg1]))
   end
   )

function Doom.showBackground(show)
   local display = show and Doom.bar.Show or Doom.bar.Hide
   display(Doom.bar)
   display(Doom.powerlabel)
   for i=1,4 do
      display(Doom.health[i])
      display(Doom.health[i].shadow)
      display(Doom.power[i])
      display(Doom.power[i].shadow)
   end
   if show then
      Doom.UNIT_HEALTH('player')
      Doom:SetHitRectInsets(0,0,0,0)
   else
      Doom:SetHitRectInsets(59, 63, 1, 2)
   end
end

Doom:SetScript('OnMouseUp',
   function()
      if arg1 == 'RightButton' then
         if Doom.config:IsVisible() then
            Doom.config:Hide()
         else
            Doom.config:Show()
         end
      else
         DoomDB.showbg = not DoomDB.showbg
         Doom.showBackground(DoomDB.showbg)
      end
   end
   )
