-------------------------------------------------------------------------------
-- Broker: SmartBuff
-- Created by Aeldra (EU-Proudmoore)
--
-- Data Broker support
-------------------------------------------------------------------------------

if (not SMARTBUFF_TITLE) then return end

local F = CreateFrame("Frame", "Broker_SmartBuff");

function SMARTBUFF_BROKER_SetIcon()
  if (not F.LS) then return end
  if (SMARTBUFF_Options and SMARTBUFF_Options.Toggle) then
    F.LS.icon = "Interface\\AddOns\\SmartBuff\\Icons\\IconEnabled";
  else
    F.LS.icon = "Interface\\AddOns\\SmartBuff\\Icons\\IconDisabled";
  end
end

F.LS = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("SmartBuff", {
	type = "launcher",
	label = SMARTBUFF_TITLE,
	OnClick = function(_, msg)
    if (msg == "RightButton") then
      SMARTBUFF_OToggle();
	  SMARTBUFF_BROKER_SetIcon();	-- bug fix, credit: SunNova
    elseif (msg == "LeftButton" and IsAltKeyDown()) then
      if (IsAddOnLoaded("SmartDebuff")) then
        SMARTDEBUFF_ToggleSF();
      end      
    elseif (msg == "LeftButton") then
      SMARTBUFF_OptionsFrame_Toggle();          
    end
	end,
	icon = "Interface\\AddOns\\SmartBuff\\Icons\\IconDisabled",
	OnTooltipShow = function(tooltip)
		if (not tooltip or not tooltip.AddLine) then return end
		tooltip:AddLine("|cffffffff"..SMARTBUFF_TITLE.."|r");
		tooltip:AddLine(SMARTBUFF_TITAN_TT);
	end,
});

F:Hide();
--print("Borker - SmartBuff loaded");
