-------------------------------------------------------------------------------
-- SmartBuff
-- Originally created by Aeldra (EU-Proudmoore)
-- Classic/Retail versions by Codermik (Mik/Castanova/Amarantine EU-Mirage Raceway or Castanova on EU-Aszune)
-- Discord: https://discord.gg/R6EkZ94TKK
-- Cast the most important buffs on you, tanks or party/raid members/pets.
-------------------------------------------------------------------------------

SMARTBUFF_DATE			= "180122";
SMARTBUFF_VERSION       = "r39."..SMARTBUFF_DATE;
SMARTBUFF_VERSIONMIN	= 11403;			-- min version
SMARTBUFF_VERSIONNR     = 30401;			-- max version
SMARTBUFF_TITLE         = "SmartBuff";
SMARTBUFF_SUBTITLE      = "Supports casting buffs on tanks, selected classes in party or raids.";
SMARTBUFF_DESC          = "Cast the most important buffs on you, tanks, party or raid members/pets";
SMARTBUFF_VERS_TITLE    = SMARTBUFF_TITLE .. " " .. SMARTBUFF_VERSION;
SMARTBUFF_OPTIONS_TITLE = SMARTBUFF_VERS_TITLE;

-- addon and client information.
local addonName = ...
local SmartbuffPrefix = "Smartbuff";
local SmartbuffSession = true;
local SmartbuffVerCheck = false;	-- for my use when checking guild users/testers versions  :)
local wowVersionString, wowBuild, _, wowTOC = GetBuildInfo();
local isWOTLKC = (_G.WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC and wowTOC >= 30400);
local SmartbuffRevision = 39;
local SmartbuffVerNotifyList = {}

-- Smartbuff now uses LibRangeCheck-2.0 by Mitchnull, not fully implemented
-- just yet but I will be moving over to this in the near future.
-- https://www.wowace.com/projects/librangecheck-2-0
local LRC = LibStub("LibRangeCheck-2.0")

local LCD = LibStub and LibStub("LibClassicDurations", true)
if LCD then LCD:Register(SMARTBUFF_TITLE) end

local UnitAuraFull = UnitAura
if LCD and LCD.UnitAura then UnitAuraFull = function(a, b, c) return LCD:UnitAura(a, b, c) end end


local SG = SMARTBUFF_GLOBALS;
local OG = nil; -- Options global
local O  = nil; -- Options local
local B  = nil; -- Buff settings local
local _;

BINDING_HEADER_SMARTBUFF = "SmartBuff";
SMARTBUFF_BOOK_TYPE_SPELL = "spell";


local GlobalCd = 1.5;
local maxSkipCoolDown = 3;
local maxRaid = 40;
local maxBuffs = 40;
local maxScrollButtons = 50;
local numBuffs = 0;

local isLoaded = false;
local isPlayer = false;
local isInit = false;
local isCombat = false;
local isSetBuffs = false;
local isSetZone = false;
local isFirstError = false;
local isMounted = false;
local isCTRA = true;
local isSetUnits = false;
local isKeyUpChanged = false;
local isKeyDownChanged = false;
local isAuraChanged = false;
local isClearSplash = false;
local isRebinding = false;
local isParrot = false;
local isSync = false;
local isSyncReq = false;
local isInitBtn = false;

local isShapeshifted = false;
local sShapename = "";

local tStartZone = 0;
local tTicker = 0;
local tSync = 0;

local sRealmName = nil;
local sPlayerName = nil;
local sID = nil;
local sPlayerClass = nil;
local iLastSubgroup = 0;
local tLastCheck = 0;
local iGroupSetup = -1;
local iLastBuffSetup = -1;
local sLastTexture = "";
local iLastGroupSetup = -99;
local sLastZone = "";
local tAutoBuff = 0;
local tDebuff = 0;
local sMsgWarning = "";
local iCurrentFont = 1;
local iCurrentList = -1;
local iLastPlayer = -1;

local isPlayerMoving = false;

local cGroups = { };
local cClassGroups = { };
local cBuffs = { };
local cBuffIndex = { };
local cBuffTimer = { };
local cBlacklist = { };
local cUnits = { };
local cBuffsCombat = { };

local cScrBtnBO = nil;

local cAddUnitList = { };
local cIgnoreUnitList = { };

local cClasses       = {"DRUID", "HUNTER", "MAGE", "PALADIN", "PRIEST", "ROGUE", "SHAMAN", "WARLOCK", "WARRIOR", "DEATHKNIGHT", "MONK", "DEMONHUNTER", "HPET", "WPET", "DKPET", "TANK", "HEALER", "DAMAGER"};
local cIgnoreClasses = { 11, 12, 17, 18 };
local cOrderGrp      = {0, 1, 2, 3, 4, 5, 6, 7, 8};
local cOrderClass    = {0, "WARRIOR", "PRIEST", "DRUID", "PALADIN", "SHAMAN", "MAGE", "WARLOCK", "HUNTER", "ROGUE", "TANK", "HPET", "WPET", "DKPET"};
local cFonts         = {"NumberFontNormal", "NumberFontNormalLarge", "NumberFontNormalHuge", "GameFontNormal", "GameFontNormalLarge", "GameFontNormalHuge", "ChatFontNormal", "QuestFont", "MailTextFontNormal", "QuestTitleFont"};

local currentUnit = nil;
local currentSpell = nil;
local currentRank = nil;
local currentTemplate = nil;
local currentSpec = nil;

local imgSB      = "Interface\\Icons\\Spell_Nature_Purge";
local imgIconOn  = "Interface\\AddOns\\SmartBuff\\Icons\\MiniMapButtonEnabled";
local imgIconOff = "Interface\\AddOns\\SmartBuff\\Icons\\MiniMapButtonDisabled";

local IconPaths = {
  ["Pet"]         = "Interface\\Icons\\spell_nature_spiritwolf",
  ["Roles"]       = "Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES",
  ["Classes"]     = "Interface\\WorldStateFrame\\Icons-Classes",
};
                
local Icons = {
  ["WARRIOR"]     = { IconPaths.Classes, 0.00, 0.25, 0.00, 0.25 },
  ["MAGE"]        = { IconPaths.Classes, 0.25, 0.50, 0.00, 0.25 },
  ["ROGUE"]       = { IconPaths.Classes, 0.50, 0.75, 0.00, 0.25 },
  ["DRUID"]       = { IconPaths.Classes, 0.75, 1.00, 0.00, 0.25 },
  ["HUNTER"]      = { IconPaths.Classes, 0.00, 0.25, 0.25, 0.50 },
  ["SHAMAN"]      = { IconPaths.Classes, 0.25, 0.50, 0.25, 0.50 },
  ["PRIEST"]      = { IconPaths.Classes, 0.50, 0.75, 0.25, 0.50 },
  ["WARLOCK"]     = { IconPaths.Classes, 0.75, 1.00, 0.25, 0.50 },
  ["PALADIN"]     = { IconPaths.Classes, 0.00, 0.25, 0.50, 0.75 },
  ["DEATHKNIGHT"] = { IconPaths.Classes, 0.25, 0.50, 0.50, 0.75 },
  ["MONK"]        = { IconPaths.Classes, 0.50, 0.75, 0.50, 0.75 },
  ["DEMONHUNTER"] = { IconPaths.Classes, 0.75, 1.00, 0.50, 0.75 },
  ["PET"]         = { IconPaths.Pet, 0.08, 0.92, 0.08, 0.92},
  ["TANK"]        = { IconPaths.Roles, 0.0, 19/64, 22/64, 41/64 },
  ["HEALER"]      = { IconPaths.Roles, 20/64, 39/64, 1/64, 20/64 },
  ["DAMAGER"]     = { IconPaths.Roles, 20/64, 39/64, 22/64, 41/64 },
  ["NONE"]        = { IconPaths.Roles, 20/64, 39/64, 22/64, 41/64 },
};

-- available sounds (14)
local Sounds = { 1141, 3784, 4574, 17318, 15262, 13830, 15273, 10042, 10720, 17316, 3337, 7894, 7914, 10033 }

local DebugChatFrame = DEFAULT_CHAT_FRAME;

-- upvalues
local UnitCastingInfo = _G.UnitCastingInfo or _G.CastingInfo
local UnitChannelInfo = _G.UnitChannelInfo or _G.ChannelInfo
local GetNumSpecGroups = _G.GetNumSpecGroups or function(...) return 1 end
local IsActiveBattlefieldArena = _G.IsActiveBattlefieldArena or function(...) return false end

-- Popup
StaticPopupDialogs["SMARTBUFF_DATA_PURGE"] = {
  text = SMARTBUFF_OFT_PURGE_DATA,
  button1 = SMARTBUFF_OFT_YES,
  button2 = SMARTBUFF_OFT_NO,
  OnAccept = function() SMARTBUFF_ResetAll() end,
  timeout = 0,
  whileDead = 1,
  hideOnEscape = 1
}

-- Rounds a number to the given number of decimal places. 
local r_mult;
local function Round(num, idp)
  r_mult = 10^(idp or 0);
  return math.floor(num * r_mult + 0.5) / r_mult;
end

-- Returns a chat color code string
local function BCC(r, g, b)
  return string.format("|cff%02x%02x%02x", (r*255), (g*255), (b*255));
end

local BL  = BCC(0, 0, 1);
local BLD = BCC(0, 0, 0.7);
local BLL = BCC(0.5, 0.8, 1);
local GR  = BCC(0, 1, 0);
local GRD = BCC(0, 0.7, 0);
local GRL = BCC(0.6, 1, 0.6);
local RD  = BCC(1, 0, 0);
local RDD = BCC(0.7, 0, 0);
local RDL = BCC(1, 0.3, 0.3);
local YL  = BCC(1, 1, 0);
local YLD = BCC(0.7, 0.7, 0);
local YLL = BCC(1, 1, 0.5);
local OR  = BCC(1, 0.7, 0);
local ORD = BCC(0.7, 0.5, 0);
local ORL = BCC(1, 0.6, 0.3);
local WH  = BCC(1, 1, 1);
local CY  = BCC(0.5, 1, 1);

-- function to preview selected warning sound in options screen
function SMARTBUFF_PlaySpashSound()
  PlaySound(Sounds[O.AutoSoundSelection]);
end

-- Reorders values in the table
local function treorder(t, i, n)
  if (t and type(t) == "table" and t[i]) then
    local s = t[i];
    tremove(t, i);
    if (i + n < 1) then
      tinsert(t, 1, s);
    elseif (i + n > #t) then
      tinsert(t, s);
    else
      tinsert(t, i + n, s);
    end
  end
end

-- Finds a value in the table and returns the index
local function tfind(t, s)
  if (t and type(t) == "table" and s) then 
    for k, v in pairs(t) do 
      if (v and v == s) then 
        return k;
      end 
    end 
  end 
  return false;
end

local function tcontains(t, s)
  if (t and type(t) == "table" and s) then 
    for _, v in ipairs(t) do
      if (v == s) then
        return true;
      end
    end
  end
  return false;
end

function strim(s)
   return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local function ChkS(text)
  if (text == nil) then
    text = "";
  end
  return text;
end

-- check for a given buff.
local function CheckForBuff(buff)
  for i=1,40 do
    name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId = UnitAura("player",i);
    if name == buff then
	  return true;
	end
  end
  return false;
end

local function IsFlying()
  if (O.WarnWhileMounted) then return false; end
  local result = GetShapeshiftForm(false)
  if ((result == 5 and not CheckForBuff(SMARTBUFF_DRUID_MOONKIN)) or result == 6) and sPlayerClass == "DRUID" then 
	return true 
  end
  return false
end

local function UnitInVehicle(unit)
  return false
end

local function UnitHasVehicleUI(unit)
  return false
end

local function UnitGroupRolesAssigned(unit)
  -- dont bother if we dont have assigned tanks
	if cClassGroups then
		if cClassGroups["TANK"] then
			for n = 1, maxRaid, 1 do
				local u = cClassGroups["TANK"][n]
				if u and u == unit then
					name, rank, subgroup, level, class, classeng, zone, online, isDead, role = GetRaidRosterInfo(n)
					if role and role == "MAINTANK" then
						return "TANK"
					end
				end
			end
		end
	end
	return "NONE"
end

local function IsVisibleToPlayer(self)
  if (not self) then return false; end  
  local w, h = UIParent:GetWidth(), UIParent:GetHeight();
  local x, y = self:GetLeft(), UIParent:GetHeight() - self:GetTop();  
  if (x >= 0 and x < (w - self:GetWidth()) and y >= 0 and y < (h - self:GetHeight())) then
    return true;
  end
  return false;
end

local function CS()
  if isWOTLKC then
      currentSpec = GetActiveTalentGroup() or nil;
  else
      if (currentSpec == nil) then
        currentSpec = GetSpecialization() or nil;
	  end
  end
  if (currentSpec == nil) then
    currentSpec = 1;
  end
  return currentSpec;
end

local function CT()
  return currentTemplate;
end

local function GetBuffSettings(buff)
  if (B and buff) then
    return B[CS()][CT()][buff];
  end
  return nil;
end

local function InitBuffSettings(cBI, reset)
  local buff = cBI.BuffS;
  local cBuff = GetBuffSettings(buff);
  if (cBuff == nil) then
    B[CS()][CT()][buff] = { };
    cBuff = B[CS()][CT()][buff];
    reset = true;
  end
  
  if (reset) then
    wipe(cBuff);
    cBuff.EnableS = false;
    cBuff.EnableG = false;
    cBuff.SelfOnly = false;
    cBuff.SelfNot = false;
    cBuff.CIn = false;
    cBuff.COut = true;
    cBuff.MH = false;
    cBuff.OH = false;
    cBuff.RH = false;
    cBuff.Reminder = true;
    cBuff.RBTime = 0;
    cBuff.ManaLimit = 0;    
    if (cBI.Type == SMARTBUFF_CONST_GROUP or cBI.Type == SMARTBUFF_CONST_ITEMGROUP) then
      for n in pairs(cClasses) do
        if (cBI.Type == SMARTBUFF_CONST_GROUP and not tcontains(cIgnoreClasses, n) and not string.find(cBI.Params, cClasses[n])) then
          cBuff[cClasses[n]] = true;
        else
          cBuff[cClasses[n]] = false;
        end
      end
    end
  end  
  
  -- Upgrades
  if (cBuff.RBTime == nil) then cBuff.Reminder = true; cBuff.RBTime = 0; end -- to 1.10g
  if (cBuff.ManaLimit == nil) then cBuff.ManaLimit = 0; end -- to 1.12b
  if (cBuff.SelfNot == nil) then cBuff.SelfNot = false; end -- to 2.0i
  if (cBuff.AddList == nil) then cBuff.AddList = { }; end -- to 2.1a
  if (cBuff.IgnoreList == nil) then cBuff.IgnoreList = { }; end -- to 2.1a  
  if (cBuff.RH == nil) then cBuff.RH = false; end -- to 4.0b

end

local function InitBuffOrder(reset)
  if (B[CS()].Order == nil) then
    B[CS()].Order = { };
  end
    
  local b;
  local i;
  local ord = B[CS()].Order;
  if (reset) then
    wipe(ord);
    SMARTBUFF_AddMsgD("Reset buff order");
  end
  
  -- Remove not longer existing buffs in the order list
  for k, v in pairs(ord) do
    if (v and cBuffIndex[v] == nil) then
      SMARTBUFF_AddMsgD("Remove from buff order: "..v);
      tremove(ord, k);
    end
  end  
  
  i = 1;
  while (cBuffs[i] and cBuffs[i].BuffS) do
    b = false;
    for _, v in pairs(ord) do
      if (v and v == cBuffs[i].BuffS) then
        b = true;
        break;
      end
    end
    -- buff not found add it to order list
    if (not b) then
      tinsert(ord, cBuffs[i].BuffS);
      SMARTBUFF_AddMsgD("Add to buff order: "..cBuffs[i].BuffS);
    end
    i = i + 1;
  end
end

local function IsMinLevel(minLevel)
  if (not minLevel) then 
    return true;
  end
  if (minLevel > UnitLevel("player")) then
    return false;
  end
  return true;
end

local function IsPowerLimitOk(bs)
  -- Check for power threshold
  if (bs.ManaLimit and bs.ManaLimit > 0) then
    local powerType, powerToken = UnitPowerType("player");
    -- if bs.ManaLimit <= 100 and powertype is mana then the ManaLimit is %
    if (bs.ManaLimit <= 100 and powerType == 0) then
      if (((UnitPower("player", powerType) / UnitPowerMax("player", powerType))) * 100 < bs.ManaLimit) then
        return false;
      end
    elseif (UnitPower("player", powerType) < bs.ManaLimit) then
      return false;
    end
  end
  return true;
end

local function IsPlayerInGuild()
    return IsInGuild() -- and GetGuildInfo("player")
end

local function SendSmartbuffVersion(player, unit)
	if player == UnitName("player") then return end
	for count,value in ipairs(SmartbuffVerNotifyList) do
		if value[1] == player then return end
	end
    local isInBattleground = UnitInBattleground("player")
    if not isInBattleground then
	    tinsert(SmartbuffVerNotifyList, {player, unit, GetTime()})
	    C_ChatInfo.SendAddonMessage(SmartbuffPrefix, SmartbuffRevision, "WHISPER", player)
	end
end

-- SMARTBUFF_OnLoad
function SMARTBUFF_OnLoad(self)

  self:RegisterEvent("ADDON_LOADED");
  self:RegisterEvent("PLAYER_LOGIN");
  self:RegisterEvent("PLAYER_ENTERING_WORLD");
  self:RegisterEvent("UNIT_NAME_UPDATE");
  self:RegisterEvent("GROUP_ROSTER_UPDATE");
  self:RegisterEvent("PLAYER_REGEN_ENABLED");
  self:RegisterEvent("PLAYER_REGEN_DISABLED");
  self:RegisterEvent("PLAYER_STARTED_MOVING");
  self:RegisterEvent("PLAYER_STOPPED_MOVING");
  self:RegisterEvent("SPELLS_CHANGED");
  self:RegisterEvent("ACTIONBAR_HIDEGRID");
  self:RegisterEvent("UNIT_AURA");
  self:RegisterEvent("CHAT_MSG_ADDON");
  self:RegisterEvent("CHAT_MSG_CHANNEL");
  self:RegisterEvent("UPDATE_MOUSEOVER_UNIT");
  self:RegisterEvent("UNIT_SPELLCAST_FAILED");
  self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
  
  -- One of them allows SmartBuff to be closed with the Escape key
  tinsert(UISpecialFrames, "SmartBuffOptionsFrame");
  UIPanelWindows["SmartBuffOptionsFrame"] = nil;
  
  -- setup command line.
  SlashCmdList["SMARTBUFF"] = SMARTBUFF_command;
  SLASH_SMARTBUFF1 = "/sbo";
  SLASH_SMARTBUFF2 = "/sbuff";
  SLASH_SMARTBUFF3 = "/smartbuff";
  SlashCmdList["SMARTBUFFMENU"] = SMARTBUFF_OptionsFrame_Toggle;
  SLASH_SMARTBUFFMENU1 = "/sbm";  
  SlashCmdList["SmartReloadUI"] = function(msg) ReloadUI(); end;
  SLASH_SmartReloadUI1 = "/rui";
  
  SMARTBUFF_InitSpellIDs();
end

-- END SMARTBUFF_OnLoad


-------------------------------------------------------------------------------------------------------------------------------------
--	SmartBuff Event Handler ---------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------
function SMARTBUFF_OnEvent(self, event, ...)
  local arg1, arg2, arg3, arg4, arg5 = ...;

  -- UNIT_NAME_UPDATE / PLAYER_ENTERING_WORLD
  if ((event == "UNIT_NAME_UPDATE" and arg1 == "player") or event == "PLAYER_ENTERING_WORLD") then	
	if IsPlayerInGuild() and event == "PLAYER_ENTERING_WORLD" then 
		C_ChatInfo.SendAddonMessage(SmartbuffPrefix, SmartbuffRevision, "GUILD")
	end
    isPlayer = true;
    if  (event == "PLAYER_ENTERING_WORLD" and isInit and O.Toggle) then
      isSetZone = true;
      tStartZone = GetTime();
    end

  -- ADDON_LOADED
  elseif(event == "ADDON_LOADED" and arg1 == SMARTBUFF_TITLE) then
    isLoaded = true;
  end

  -- PLAYER_LOGIN
  if event == "PLAYER_LOGIN" then 
	local prefixResult = C_ChatInfo.RegisterAddonMessagePrefix(SmartbuffPrefix) 
  end

  -- CHAT_MSG_ADDON
  if event == "CHAT_MSG_ADDON" then
	if arg1 == SmartbuffPrefix then
		-- its us.
		if arg2 then
			arg2 = tonumber(arg2)
			if arg2 > SmartbuffRevision and SmartbuffSession then
				-- detected a newer version of the addon, lets let the player know.
				DEFAULT_CHAT_FRAME:AddMessage(SMARTBUFF_MSG_NEWVER1..SMARTBUFF_VERSION..SMARTBUFF_MSG_NEWVER2..arg2..SMARTBUFF_MSG_NEWVER3)
				SmartbuffSession = false
			end 
			-- guild version check - for my use testing the addon with the guild testers. --
			if arg5 and arg5 ~= UnitName("player") and SmartbuffVerCheck then 
				DEFAULT_CHAT_FRAME:AddMessage("|cff00e0ffSmartbuff : |cffFFFF00"..arg5.." ("..arg3..")|cffffffff has revision |cffFFFF00r"..arg2.."|cffffffff installed.") 
			end
		end
	end
  end
  
  -- SMARTBUFF_UPDATE  
  if (event == "SMARTBUFF_UPDATE" and isLoaded and isPlayer and not isInit and not InCombatLockdown()) then
    SMARTBUFF_Options_Init(self);
  end
  
  if (not isInit or O == nil) then
    return;
  end;
  
  -- GROUP_ROSTER_UPDATE
  if (event == "GROUP_ROSTER_UPDATE") then
    isSetUnits = true;
    
  -- PLAYER_REGEN_DISABLED
  elseif (event == "PLAYER_REGEN_DISABLED") then
    SMARTBUFF_Ticker(true);
    
    if (O.Toggle) then
      if (O.InCombat) then
        for spell, data in pairs(cBuffsCombat) do
          if (data and data.Unit and data.ActionType) then
            if (data.Type == SMARTBUFF_CONST_SELF or data.Type == SMARTBUFF_CONST_FORCESELF or data.Type == SMARTBUFF_CONST_STANCE or data.Type == SMARTBUFF_CONST_ITEM) then
              SmartBuff_KeyButton:SetAttribute("unit", nil);
            else
              SmartBuff_KeyButton:SetAttribute("unit", data.Unit);
            end
            SmartBuff_KeyButton:SetAttribute("type", data.ActionType);
            SmartBuff_KeyButton:SetAttribute("spell", spell);
            SmartBuff_KeyButton:SetAttribute("item", nil);
            SmartBuff_KeyButton:SetAttribute("target-slot", nil);
            SmartBuff_KeyButton:SetAttribute("target-item", nil);
            SmartBuff_KeyButton:SetAttribute("macrotext", nil);
            SmartBuff_KeyButton:SetAttribute("action", nil);
            SMARTBUFF_AddMsgD("Enter Combat, set button: " .. spell .. " on " .. data.Unit .. ", " .. data.ActionType);
            break;
          end
        end
      end
      SMARTBUFF_SyncBuffTimers();
      SMARTBUFF_Check(1, true);
    end
    
  -- PLAYER_REGEN_ENABLED
  elseif (event == "PLAYER_REGEN_ENABLED") then
    SMARTBUFF_Ticker(true);    
    if (O.Toggle) then
      if (O.InCombat) then
        SmartBuff_KeyButton:SetAttribute("type", nil);
        SmartBuff_KeyButton:SetAttribute("unit", nil);
        SmartBuff_KeyButton:SetAttribute("spell", nil);
      end
      SMARTBUFF_SyncBuffTimers();
      SMARTBUFF_Check(1, true);
    end

  -- PLAYER_STARTED_MOVING / PLAYER_STOPPED_MOVING
  elseif (event == "PLAYER_STARTED_MOVING") then
	isPlayerMoving = true;

  elseif (event == "PLAYER_STOPPED_MOVING") then
	isPlayerMoving = false;

  -- SPELLS_CHANGED / ACTIONBAR_HIDEGRID
  elseif (event == "SPELLS_CHANGED" or event == "ACTIONBAR_HIDEGRID") then
    isSetBuffs = true;
  end

  if (not O.Toggle) then
    return;
  end;
  
  -- UNIT_AURA
  if (event == "UNIT_AURA") then
    if (UnitAffectingCombat("player") and (arg1 == "player" or string.find(arg1, "^party") or string.find(arg1, "^raid"))) then
      isSyncReq = true;
    end    
    -- checks if aspect of cheetah or pack is active and cancel it if someone gets dazed
    if (sPlayerClass == "HUNTER" and O.AntiDaze and (arg1 == "player" or string.find(arg1, "^party") or string.find(arg1, "^raid") or string.find(arg1, "pet"))) then
      local _, _, stuntex = GetSpellInfo(1604); --get Dazed icon
      if (SMARTBUFF_IsDebuffTexture(arg1, stuntex)) then
        buff = nil;
        if (arg1 == "player" and SMARTBUFF_CheckBuff(arg1, SMARTBUFF_AOTC)) then
          buff = SMARTBUFF_AOTC;
        elseif (SMARTBUFF_CheckBuff(arg1, SMARTBUFF_AOTP, true)) then
          buff = SMARTBUFF_AOTP;
        end
        if (buff) then
          if (O.ToggleAutoSplash and not SmartBuffOptionsFrame:IsVisible()) then
            SmartBuffSplashFrame:Clear();
            SmartBuffSplashFrame:SetTimeVisible(1);
            SmartBuffSplashFrame:AddMessage("!!! CANCEL "..buff.." !!!", O.ColSplashFont.r, O.ColSplashFont.g, O.ColSplashFont.b, 1.0);
          end
          if (O.ToggleAutoChat) then
            SMARTBUFF_AddMsgWarn("!!! CANCEL "..buff.." !!!", true);
          end            
        end
      end      
    end    
  end
    
  -- UI_ERROR_MESSAGE
  if (event == "UI_ERROR_MESSAGE") then
    SMARTBUFF_AddMsgD(string.format("Error message: %s",arg1));
  end

  -- UNIT_SPELLCAST_FAILED
  if (event == "UNIT_SPELLCAST_FAILED") then
    currentUnit = arg1;
    SMARTBUFF_AddMsgD(string.format("Spell failed: %s",arg1));
    if (currentUnit and (string.find(currentUnit, "party") or string.find(currentUnit, "raid") or (currentUnit == "target" and O.Debug))) then
      if (UnitName(currentUnit) ~= sPlayerName and O.BlacklistTimer > 0) then
        cBlacklist[currentUnit] = GetTime();
        if (currentUnit and UnitName(currentUnit)) then
          SMARTBUFF_AddMsgD(UnitName(currentUnit).." ("..currentUnit..") blacklisted ("..O.BlacklistTimer.."sec)");
        end
      end
    end
    currentUnit = nil;
  
  -- UNIT_SPELLCAST_SUCCEEDED  
  elseif (event == "UNIT_SPELLCAST_SUCCEEDED") then 
    if (arg1 and arg1 == "player") then
      local unit = nil;
      local spell = nil;
      local target = nil;

      -- temporary dirty hack to force a spell list refresh and check when a warlock stone is created.
      -- yes yes, i know its horrible but its temporary as a quick fix - i will tidy this up later.
      if (sPlayerClass == "WARLOCK") then
	    -- only really interested if im a warlock, otherwise just skip over.
        if arg3 == 2362 or arg3 == 17727 or arg3 == 17728 or arg3 == 28172 or arg3 == 47886 or arg3 == 47888 or
            arg3 == 6366 or arg3 == 17951 or arg3 == 17952 or arg3 == 17954 or arg3 == 27250 or arg3 == 60219 then
		    isSetBuffs = true;
		end
	  end
      
      if (arg1 and arg2) then
        if (not arg3) then arg3 = ""; end
        if (not arg4) then arg4 = ""; end
        SMARTBUFF_AddMsgD("Spellcast succeeded: " .. arg1 .. ", " .. arg2 .. ", " .. arg3 .. ", " .. arg4)
        if (string.find(arg1, "party") or string.find(arg1, "raid")) then
          spell = arg2;
        end        
      end      
      if (currentUnit and currentSpell and currentUnit ~= "target") then
        unit = currentUnit;
        spell = currentSpell;
      end      
      if (unit) then
        local name = UnitName(unit);
        if (cBuffTimer[unit] == nil) then
          cBuffTimer[unit] = { };
        end
          cBuffTimer[unit][spell] = GetTime();
        if (name ~= nil) then
          SMARTBUFF_AddMsg(name .. ": " .. spell .. " " .. SMARTBUFF_MSG_BUFFED);
          currentUnit = nil;
          currentSpell = nil;
          currentRank = nil;
        end
      end      
      if (isClearSplash) then
        isClearSplash = false;
        SMARTBUFF_Splash_Clear();
      end      
    end    
  end

end

-------------------------------------------------------------------------------------------------------------------------------------
--	SMARTBUFF_OnUpdate --------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------
function SMARTBUFF_OnUpdate(self, elapsed)
  if not self.Elapsed then 
    self.Elapsed = 0.2
  end
  self.Elapsed = self.Elapsed - elapsed
  if self.Elapsed > 0 then 
    return 
  end
  self.Elapsed = 0.2
  
  if (not isInit) then
    if (isLoaded and GetTime() > tAutoBuff + 0.5) then
      tAutoBuff = GetTime();
      _, tName = GetTalentInfo(1, 1, 1);
      if (tName) then
        SMARTBUFF_OnEvent(self, "SMARTBUFF_UPDATE");
      end
    end    
  else
    if (isSetZone and GetTime() > (tStartZone + 4)) then
      SMARTBUFF_CheckLocation();
    end
    SMARTBUFF_Ticker();
    SMARTBUFF_Check(1);
  end
end

-------------------------------------------------------------------------------------------------------------------------------------
--	SMARTBUFF_Ticker ----------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------
function SMARTBUFF_Ticker(force)
  if (force or GetTime() > tTicker + 1) then
    tTicker = GetTime();
       
    if (isSetUnits) then
      isSetUnits = false;
      SMARTBUFF_SetUnits();
      isSyncReq = true;
    end

    if (isSyncReq or tTicker > tSync + 10) then
      SMARTBUFF_SyncBuffTimers();
    end
        
    if (isAuraChanged) then
      isAuraChanged = false;
      SMARTBUFF_Check(1, true);
    end
    
  end 
end

-------------------------------------------------------------------------------------------------------------------------------------
--
--	SMARTBUFF_AddMsg	
--	SMARTBUFF_AddMsgErr
--	SMARTBUFF_AddMsgWarn	
--	SMARTBUFF_AddMsgD
--
-------------------------------------------------------------------------------------------------------------------------------------
function SMARTBUFF_AddMsg(msg, force)
  if (DEFAULT_CHAT_FRAME and (force or not O.ToggleMsgNormal)) then
    DEFAULT_CHAT_FRAME:AddMessage(YLL .. msg .. "|r");
  end
end

function SMARTBUFF_AddMsgErr(msg, force)
  if (DEFAULT_CHAT_FRAME and (force or not O.ToggleMsgError)) then
    DEFAULT_CHAT_FRAME:AddMessage(RDL .. SMARTBUFF_TITLE .. ": " .. msg .. "|r");
  end
end

function SMARTBUFF_AddMsgWarn(msg, force)
  if (DEFAULT_CHAT_FRAME and (force or not O.ToggleMsgWarning)) then
    if (isParrot) then
      Parrot:ShowMessage(CY .. msg .. "|r");
    else
      DEFAULT_CHAT_FRAME:AddMessage(CY .. msg .. "|r");
    end
  end
end

function SMARTBUFF_AddMsgD(msg, r, g, b)
  if (r == nil) then r = 0.5; end
  if (g == nil) then g = 0.8; end
  if (b == nil) then b = 1; end
  if (DebugChatFrame and O and O.Debug) then
    DebugChatFrame:AddMessage(msg, r, g, b);
  end
end


-------------------------------------------------------------------------------------------------------------------------------------
--	SMARTBUFF_SetUnits()
--	Creates a array of units in a party or raid.
-------------------------------------------------------------------------------------------------------------------------------------

function SMARTBUFF_SetUnits()
  --if (not isInit or not O.Toggle) then return; end
  if (InCombatLockdown()) then
    isSetUnits = true;
    return;
  end    
  if (SmartBuffOptionsFrame:IsVisible()) then return; end 
  
  local i = 0;
  local n = 0;
  local j = 0;
  local s = nil;
  local psg = 0;
  local b = false;
  local iBFA = SMARTBUFF_IsActiveBattlefield();

  if (iBFA > 0) then
    SMARTBUFF_CheckLocation();
  end
  
  -- player
  -- pet
  -- party1-4
  -- partypet1-4
  -- raid1-40
  -- raidpet1-40
 
  iGroupSetup = -1;
  if (IsInRaid()) then
    iGroupSetup = 3;
  elseif (GetNumSubgroupMembers() ~= 0) then
    iGroupSetup = 2;
  else
    iGroupSetup = 1;
  end
  
  if (iGroupSetup ~= iLastGroupSetup) then
    iLastGroupSetup = iGroupSetup;
    wipe(cBlacklist);
    wipe(cBuffTimer);
    if (SMARTBUFF_TEMPLATES[iGroupSetup] == nil) then
      SMARTBUFF_SetBuffs();
    end
    local tmp = SMARTBUFF_TEMPLATES[iGroupSetup];
    if (O.AutoSwitchTemplate and currentTemplate ~= tmp and iBFA == 0) then
      SMARTBUFF_AddMsg(SMARTBUFF_OFT_AUTOSWITCHTMP .. ": " .. currentTemplate .. " -> " .. tmp); 
      currentTemplate = tmp;
      SMARTBUFF_SetBuffs();
    end
    SMARTBUFF_MiniGroup_Show();
  end 
  
  wipe(cUnits);
  wipe(cGroups);
  cClassGroups = nil;
  wipe(cAddUnitList);
  wipe(cIgnoreUnitList);

  -- Raid Setup  
  if (iGroupSetup == 3) then
    cClassGroups = { };
    local name, server, rank, subgroup, level, class, classeng, zone, online, isDead, role;
    local sRUnit = nil;
    
    j = 1;
    for n = 1, maxRaid, 1 do
	  -- GetRaidRosterInfo role returns "MAINTANK" or "MAINASSIST" 
      name, rank, subgroup, level, class, classeng, zone, online, isDead, role = GetRaidRosterInfo(n);
      if (name) then
		server = nil;
        i = string.find(name, "-", 1, true);
        if (i and i > 0) then
          server = string.sub(name, i + 1);
          name   = string.sub(name, 1, i - 1);
          SMARTBUFF_AddMsgD(name .. ", " .. server);
        end
        sRUnit = "raid"..n;
               
        SMARTBUFF_AddUnitToClass("raid", n, role);
        SmartBuff_AddToUnitList(1, sRUnit, subgroup);
        SmartBuff_AddToUnitList(2, sRUnit, subgroup);
        
        if (name == sPlayerName and not server) then
          psg = subgroup;
        end      
              
        if (O.ToggleGrp[subgroup]) then
          s = "";
          if (name == UnitName(sRUnit)) then
            if (cGroups[subgroup] == nil) then
              cGroups[subgroup] = { };
            end
            if (name == sPlayerName and not server) then b = true; end
            cGroups[subgroup][j] = sRUnit;
            j = j + 1;
          end
        end
		-- attempt to announce the addon version (if they have it)
        if online then SendSmartbuffVersion(name, sRUnit) end
      end
    end --end for
    
    if (not b or B[CS()][currentTemplate].SelfFirst) then
      SMARTBUFF_AddSoloSetup();
      iLastSubgroup = psg;
    end
  
    if (iLastSubgroup ~= psg) then
      SMARTBUFF_AddMsgWarn(SMARTBUFF_TITLE .. ": " .. SMARTBUFF_MSG_SUBGROUP);
      if (O.ToggleSubGrpChanged) then
        O.ToggleGrp[psg] = true;
        if (SmartBuffOptionsFrame:IsVisible()) then
          SMARTBUFF_ShowSubGroupsOptions();
        else
          SMARTBUFF_OptionsFrame_Open();
        end
      end
      iLastSubgroup = psg;
    end  
    
    SMARTBUFF_AddMsgD("Raid Unit-Setup finished");
  
  -- Party Setup
  elseif (iGroupSetup == 2) then    
  
    cClassGroups = { };	
    if (B[CS()][currentTemplate].SelfFirst) then
      SMARTBUFF_AddSoloSetup();
    end 	
    cGroups[1] = { };
    cGroups[1][0] = "player";
    SMARTBUFF_AddUnitToClass("player", 0, nil);
    for j = 1, 4, 1 do
      cGroups[1][j] = "party"..j;
      SMARTBUFF_AddUnitToClass("party", j, nil);      
      SmartBuff_AddToUnitList(1, "party"..j, 1);
      SmartBuff_AddToUnitList(2, "party"..j, 1);
	  name, _, _, _, _, _, _, online, _, _ = GetRaidRosterInfo(j);
	  if name and online then SendSmartbuffVersion(name, "party") end
    end
    SMARTBUFF_AddMsgD("Party Unit-Setup finished");
  
  -- Solo Setup
  else    
    SMARTBUFF_AddSoloSetup();
    SMARTBUFF_AddMsgD("Solo Unit-Setup finished");
  end
  
  collectgarbage();
end


-------------------------------------------------------------------------------------------------------------------------------------
--	SMARTBUFF_AddUnitToClass --------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------
function SMARTBUFF_AddUnitToClass(unit, i, proll)
  local u = unit;
  local up = "pet";
  if (unit ~= "player") then
    u = unit..i;
    up = unit.."pet"..i;
  end
  if (UnitExists(u)) then
    if (not cUnits[1]) then
      cUnits[1] = { };
    end
    cUnits[1][i] = u;
    SMARTBUFF_AddMsgD("Unit added: " .. UnitName(u) .. ", " .. u);
    
    local _, uc = UnitClass(u);
    if (uc and not cClassGroups[uc]) then
      cClassGroups[uc] = { };
	else
	  if u and uc then
		cClassGroups[uc][i] = u;
	  end
    end

	if uc and proll == "MAINTANK" then
	  if (not cClassGroups["TANK"]) then
        cClassGroups["TANK"] = { };
      end      
      cClassGroups["TANK"][i] = u;
	end;
  
    if (uc and uc == "HUNTER") then
      if (not cClassGroups["HPET"]) then
        cClassGroups["HPET"] = { };
      end      
      cClassGroups["HPET"][i] = up;

    elseif (uc and uc == "DEATHKNIGHT") then
      if (not cClassGroups["DKPET"]) then
        cClassGroups["DKPET"] = { };
      end
      cClassGroups["DKPET"][i] = up;

    elseif (uc and (uc == "WARLOCK" or uc == "MAGE")) then
      if (not cClassGroups["WPET"]) then
        cClassGroups["WPET"] = { };
      end
      cClassGroups["WPET"][i] = up;
    end
	
  end
end

function SMARTBUFF_AddSoloSetup()
  cGroups[0] = { };
  cGroups[0][0] = "player";
  cUnits[0] = { };
  cUnits[0][0] = "player";
  if (sPlayerClass == "HUNTER" or sPlayerClass == "WARLOCK" or sPlayerClass == "MAGE") then cGroups[0][1] = "pet"; end  
  if (B[CS()][currentTemplate] and B[CS()][currentTemplate].SelfFirst) then
    if (not cClassGroups) then
      cClassGroups = { };
    end  
    cClassGroups[0] = { };
    cClassGroups[0][0] = "player";
  end
end

-- END SMARTBUFF_SetUnits


-------------------------------------------------------------------------------------------------------------------------------------
--	SMARTBUFF_GetSpellID 
--	Read available spells / abilities from spell book including spellid's
-------------------------------------------------------------------------------------------------------------------------------------
function SMARTBUFF_GetSpellID(spellname)

  if (spellname) then spellname = string.lower(spellname); else return nil; end
  
  local i = 0;
  local nSpells = 0;
  local id = nil;
  local spellN, spellId, skillType;
  
  -- Get number of spells
  for i = 1, GetNumSpellTabs() do
    local _, _, _, n = GetSpellTabInfo(i);
    nSpells = nSpells + n;
  end  
  
  i = 0;
  while (i < nSpells) do
    i = i + 1;
    spellN = GetSpellBookItemName(i, BOOKTYPE_SPELL);
    skillType, spellId = GetSpellBookItemInfo(i, BOOKTYPE_SPELL);

    if (skillType == "FLYOUT") then
      for j = 1, GetNumFlyouts() do
        local fid = GetFlyoutID(j);
        local name, description, numSlots, isKnown = GetFlyoutInfo(fid)
        if (isKnown) then 
          for s = 1, numSlots do
            local flySpellID, overrideSpellID, isKnown, spellN, slotSpecID = GetFlyoutSlotInfo(fid, s);
            if (isKnown and string.lower(spellN) == spellname) then
              return flySpellID;
            end
          end
        end
      end
    end
    
    if (spellN ~= nil and string.lower(spellN) == spellname) then
      id = spellId;
      break;
    end
  end
  
  if (id) then
    if (IsPassiveSpell(id) or skillType == "FUTURESPELL" or not IsSpellKnown(id)) then
      id = nil;
      i = nil;
    end    
  end
  
  return id, i;
end


-------------------------------------------------------------------------------------------------------------------------------------
--	SMARTBUFF_SetBuffs() 
--	Setup the buff array
-------------------------------------------------------------------------------------------------------------------------------------
function SMARTBUFF_SetBuffs()

  if (B == nil) then return; end
  
  local n = 1;
  local buff = nil; 
  local ct = currentTemplate;
  
  if (B[CS()] == nil) then
    B[CS()] = { };
  end
  
  SMARTBUFF_InitItemList();
  SMARTBUFF_InitSpellList();
  
  if (B[CS()][ct] == nil) then
    B[CS()][ct] = { };
    B[CS()][ct].SelfFirst = false;
  end
  
  if (B[CS()][ct].GrpBuffSize == nil) then
    B[CS()][ct].GrpBuffSize = 3;
  end
  
  wipe(cBuffs);
  wipe(cBuffIndex);
  numBuffs = 0;
  
  for _, buff in pairs(SMARTBUFF_BUFFLIST) do
    n = SMARTBUFF_SetBuff(buff, n, true);
  end  

  for _, buff in pairs(SMARTBUFF_WEAPON) do
    n = SMARTBUFF_SetBuff(buff, n);
  end 

  for _, buff in pairs(SMARTBUFF_RACIAL) do
    n = SMARTBUFF_SetBuff(buff, n);
  end
      
  for _, buff in pairs(SMARTBUFF_TRACKING) do
    n = SMARTBUFF_SetBuff(buff, n);
  end
  
  for _, buff in pairs(SMARTBUFF_POTION) do	
    n = SMARTBUFF_SetBuff(buff, n);
  end  

  for _, buff in pairs(SMARTBUFF_SCROLL) do
    n = SMARTBUFF_SetBuff(buff, n);
  end

  for _, buff in pairs(SMARTBUFF_FOOD) do
    n = SMARTBUFF_SetBuff(buff, n);
  end
        
  wipe(cBuffsCombat);
  SMARTBUFF_SetInCombatBuffs();
  
  InitBuffOrder();
  
  numBuffs = n - 1;
  isSetBuffs = false;
end


-------------------------------------------------------------------------------------------------------------------------------------
--	SMARTBUFF_SetBuff
-------------------------------------------------------------------------------------------------------------------------------------
function SMARTBUFF_SetBuff(buff, i, ia)
  
  if (buff == nil or buff[1] == nil or i > maxScrollButtons) then return i; end  
  
  cBuffs[i] = nil;
  cBuffs[i] = { }; 
  cBuffs[i].BuffS = buff[1];
  cBuffs[i].DurationS = ceil(buff[2] * 60);
  cBuffs[i].Type = buff[3];
  cBuffs[i].CanCharge = false;  

  if (SMARTBUFF_IsSpell(cBuffs[i].Type) or cBuffs[i].Type == SMARTBUFF_CONST_TRACK) then
    cBuffs[i].IDS, cBuffs[i].BookID = SMARTBUFF_GetSpellID(cBuffs[i].BuffS);
  end
  
  if (cBuffs[i].IDS == nil and not(SMARTBUFF_IsItem(cBuffs[i].Type))) then
    cBuffs[i] = nil;
    return i;
  end

  if (buff[4] ~= nil) then cBuffs[i].LevelsS = buff[4] else cBuffs[i].LevelsS = nil end
  if (buff[5] ~= nil) then cBuffs[i].Params = buff[5] else cBuffs[i].Params = SG.NIL end
  
  if (cBuffs[i].IDS ~= nil) then
    cBuffs[i].IconS = GetSpellTexture(cBuffs[i].BuffS);
  else
    if (cBuffs[i].Type == SMARTBUFF_CONST_TRACK) then
  
      
    elseif (cBuffs[i].Type == SMARTBUFF_CONST_ITEMGROUP) then
      local _, _, _, _, minLevel, _, _, _, _, texture = GetItemInfo(cBuffs[i].BuffS);
      if (not IsMinLevel(minLevel)) then
        cBuffs[i] = nil;
        return i;      
      end
      cBuffs[i].IconS = texture;
      
    else
	  local itemsName, _, _, _, minLevel = GetItemInfo(cBuffs[i].BuffS);
      if (not IsMinLevel(minLevel)) then
        cBuffs[i] = nil;
        return i;      
      end
      
      local _, _, count, texture = SMARTBUFF_FindItem(cBuffs[i].BuffS, cBuffs[i].Chain);
      if (count <= 0) then        
        cBuffs[i] = nil;
        return i;
      else
--          print("Found: "..cBuffs[i].BuffS..", count: "..count)
      end    
      cBuffs[i].IconS = texture;
    end
  end
    
  cBuffs[i].Links = buff[6];
  cBuffs[i].Chain = buff[7];  
  cBuffs[i].BuffG = buff[8];

  cBuffs[i].IDG = SMARTBUFF_GetSpellID(cBuffs[i].BuffG);
  if (cBuffs[i].IDG ~= nil) then 
    cBuffs[i].IconG = GetSpellTexture(cBuffs[i].BuffG);
  else
    cBuffs[i].IconG = nil;
  end
  if (buff[9] ~= nil) then cBuffs[i].DurationG = ceil(buff[9] * 60); else cBuffs[i].DurationG = nil; end
  if (buff[10] ~= nil) then cBuffs[i].LevelsG = buff[10]; else cBuffs[i].LevelsG = nil; end
  if (buff[11] ~= nil) then cBuffs[i].ReagentG = buff[11]; else cBuffs[i].ReagentG = nil; end
  
  cBuffIndex[cBuffs[i].BuffS] = i;
  if (cBuffs[i].IDG ~= nil) then
    cBuffIndex[cBuffs[i].BuffG] = i;
  end
  
  InitBuffSettings(cBuffs[i]);
 
  return i + 1;
end


function SMARTBUFF_SetInCombatBuffs()
  local ct = currentTemplate;
  if (ct == nil or B[CS()] == nil or B[CS()][ct] == nil) then
    return;
  end
  for name, data in pairs(B[CS()][ct]) do
    if (type(data) == "table" and cBuffIndex[name] and (B[CS()][ct][name].EnableS or B[CS()][ct][name].EnableG) and B[CS()][ct][name].CIn) then
      if (cBuffsCombat[name]) then
        wipe(cBuffsCombat[name]);
      else
        cBuffsCombat[name] = { };
      end
      cBuffsCombat[name].Unit = "player";
      cBuffsCombat[name].Type = cBuffs[cBuffIndex[name]].Type;
      cBuffsCombat[name].ActionType = "spell";
      SMARTBUFF_AddMsgD("Set combat spell: " .. name);
      --break;
    end
  end
end
-- END SMARTBUFF_SetBuffs

function SMARTBUFF_IsTalentFrameVisible()
  return PlayerTalentFrame and PlayerTalentFrame:IsVisible();
end

-- Main Check functions
function SMARTBUFF_PreCheck(mode, force)
  if (not isInit) then return false end

  if (not isInitBtn) then
    SMARTBUFF_InitActionButtonPos();
  end

  if (not O.Toggle) then
    if (mode == 0) then
      SMARTBUFF_AddMsg(SMARTBUFF_MSG_DISABLED);
    end
    return false;
  end
    
  if (mode == 1 and not force) then
    if ((GetTime() - tLastCheck) < O.AutoTimer) then
      return false;
    end
  end

  tLastCheck = GetTime();  
  SMARTBUFF_ShowSAButton();
  --end
  
  SMARTBUFF_SetButtonTexture(SmartBuff_KeyButton, imgSB);
  if (SmartBuffOptionsFrame:IsVisible()) then return false; end  
  
  -- check for mount-spells
  if (sPlayerClass == "PALADIN" and (IsMounted() or IsFlying()) and not O.WarnWhileMounted and not SMARTBUFF_CheckBuff("player", SMARTBUFF_CRUSADERAURA)) then
    return true;
  end

  if ((mode == 1 and not O.ToggleAuto) or not O.WarnWhileMounted and (IsMounted() or IsFlying() or LootFrame:IsVisible())
    or UnitOnTaxi("player") or UnitIsDeadOrGhost("player") or UnitIsCorpse("player")
    or (mode ~= 1 and (SMARTBUFF_IsPicnic("player") or SMARTBUFF_IsFishing("player")))
    or (UnitInVehicle("player") or UnitHasVehicleUI("player"))
    or (not O.BuffInCities and IsResting() and not UnitIsPVP("player"))) then
    
    if (UnitIsDeadOrGhost("player")) then
      SMARTBUFF_CheckBuffTimers();
    end    
    
    return false;
  end
    
  if (UnitAffectingCombat("player")) then
    isCombat = true;
  else
    isCombat = false;
  end
  
  if (not isCombat and isSetBuffs) then
    SMARTBUFF_SetBuffs();
    isSyncReq = true;
  end  
  
  sMsgWarning = "";
  isFirstError = true;
  
  return true;
end

-- Bufftimer check functions
function SMARTBUFF_CheckBuffTimers()
  local n = 0;
  local ct = currentTemplate;    
  local cGrp = cUnits;
  for subgroup in pairs(cGrp) do
    n = 0;    
    if (cGrp[subgroup] ~= nil) then
      for _, unit in pairs(cGrp[subgroup]) do
        if (unit) then
          if (SMARTBUFF_CheckUnitBuffTimers(unit)) then
            n = n + 1;
          end
        end
      end
      if (cBuffTimer[subgroup]) then
        cBuffTimer[subgroup] = nil;
        SMARTBUFF_AddMsgD("Group " .. subgroup .. ": group timer reseted");
      end
    end
  end
end
-- END SMARTBUFF_CheckBuffTimers

-- if unit is dead, remove all timers
function SMARTBUFF_CheckUnitBuffTimers(unit)
  if (UnitExists(unit) and UnitIsConnected(unit) and UnitIsFriend("player", unit) and UnitIsPlayer(unit) and UnitIsDeadOrGhost(unit)) then
    local _, uc = UnitClass(unit);
    local fd = nil;
    if (uc == "HUNTER") then
      fd = SMARTBUFF_IsFeignDeath(unit);
    end 
    if (not fd) then
      if (cBuffTimer[unit]) then
        cBuffTimer[unit] = nil;
        SMARTBUFF_AddMsgD(UnitName(unit) .. ": unit timer reset");
      end
      if (cBuffTimer[uc]) then
        cBuffTimer[uc] = nil;
        SMARTBUFF_AddMsgD(uc .. ": class timer reset");
      end
      return true;
    end
  end
end

-- END SMARTBUFF_CheckUnitBuffTimers

-- Reset the buff timers and set them to running out soon
function SMARTBUFF_ResetBuffTimers()
  if (not isInit) then return; end
  
  local ct = currentTemplate;
  local t = GetTime();
  local rbTime = 0;
  local i = 0;
  local d = 0;
  local tl = 0;
  local buffS = nil;
  local buff = nil;
  local unit = nil;
  local obj = nil;
  local uc = nil;
  
  local cGrp = cGroups;
  for subgroup in pairs(cGrp) do
    n = 0;    
    if (cGrp[subgroup] ~= nil) then
    
      for _, unit in pairs(cGrp[subgroup]) do
        if (unit and UnitExists(unit) and UnitIsConnected(unit) and UnitIsFriend("player", unit) and UnitIsPlayer(unit) and not UnitIsDeadOrGhost(unit)) then
          _, uc = UnitClass(unit);
          i = 1;
          while (cBuffs[i] and cBuffs[i].BuffS) do
            d = -1;
            buff = nil;
            rbTime = 0;
            buffS = cBuffs[i].BuffS;
            
            rbTime = B[CS()][ct][buffS].RBTime;
            if (rbTime <= 0) then
              rbTime = O.RebuffTimer;
            end
                        
            if (cBuffs[i].BuffG and B[CS()][ct][buffS].EnableG and cBuffs[i].IDG ~= nil and cBuffs[i].DurationG > 0) then
              d = cBuffs[i].DurationG;
              buff = cBuffs[i].BuffG;
              obj = subgroup;
            end
            
            if (d > 0 and buff) then
              if (not cBuffTimer[obj]) then
                cBuffTimer[obj] = { };
              end
              cBuffTimer[obj][buff] = t - d + rbTime - 1;
            end            
            
            buff = nil;
            if (buffS and B[CS()][ct][buffS].EnableS and cBuffs[i].IDS ~= nil and cBuffs[i].DurationS > 0
              and uc and B[CS()][ct][buffS][uc]) then
              d = cBuffs[i].DurationS;
              buff = buffS;
              obj = unit;
            end
            
            if (d > 0 and buff) then
              if (not cBuffTimer[obj]) then
                cBuffTimer[obj] = { };
              end
              cBuffTimer[obj][buff] = t - d + rbTime - 1;
            end
            
            i = i + 1;
          end
        end
      end
    end
  end
  --isAuraChanged = true;
  SMARTBUFF_Check(1, true);
end

function SMARTBUFF_ShowBuffTimers()
  if (not isInit) then return; end
  
  local ct = currentTemplate;
  local t = GetTime();
  local rbTime = 0;
  local i = 0;
  local d = 0;
  local tl = 0;
  local buffS = nil;
  
  for unit in pairs(cBuffTimer) do
    for buff in pairs(cBuffTimer[unit]) do
      if (unit and buff and cBuffTimer[unit][buff]) then        
        
        d = -1;
        buffS = nil;
        if (cBuffIndex[buff]) then
          i = cBuffIndex[buff];
          if (cBuffs[i].BuffS == buff and cBuffs[i].DurationS > 0) then
            d = cBuffs[i].DurationS;
            buffS = cBuffs[i].BuffS;
          elseif (cBuffs[i].BuffG == buff and cBuffs[i].DurationG > 0) then
            d = cBuffs[i].DurationG;
            buffS = cBuffs[i].BuffS;
          end
          i = i + 1;
        end
        
        if (buffS and B[CS()][ct][buffS] ~= nil) then
          if (d > 0) then
            rbTime = B[CS()][ct][buffS].RBTime;
            if (rbTime <= 0) then
              rbTime = O.RebuffTimer;
            end
            tl = cBuffTimer[unit][buff] + d - t;
            if (tl >= 0) then              
              local s = "";
              if (string.find(unit, "^party") or string.find(unit, "^raid") or string.find(unit, "^player") or string.find(unit, "^pet")) then
                local un = UnitName(unit);
                if (un) then
                  un = " (" .. un .. ")";
                else
                  un = "";
                end
                s = "Unit " .. unit .. un;
              elseif (string.find(unit, "^%d$")) then
                s = "Grp " .. unit;
              else
                s = "Class " .. unit;
              end
              -- SMARTBUFF_AddMsg(string.format("%s: %s, time left: %.0f, rebuff time: %.0f", s, buff, tl, rbTime));
            else
              cBuffTimer[unit][buff] = nil;
            end
          else
            --SMARTBUFF_AddMsgD("Removed: " .. buff);
            cBuffTimer[unit][buff] = nil;
          end
        end
        
      end
    end
  end
  
end
-- END SMARTBUFF_ResetBuffTimers

-- Synchronize the internal buff timers with the UI timers
function SMARTBUFF_SyncBuffTimers()
  if (not isInit or isSync or isSetBuffs or SMARTBUFF_IsTalentFrameVisible()) then return; end
  isSync = true;
  tSync = GetTime();
  
  local ct = currentTemplate;  
  local rbTime = 0;
  local i = 0;
  local buffS = nil;
  local unit = nil;
  local uc = nil;
  
  local cGrp = nil;
  if (sPlayerClass == "PALADIN" and cClassGroups) then
    cGrp = cClassGroups;
  else
    cGrp = cGroups;
  end
  
  for subgroup in pairs(cGrp) do
    n = 0;    
    if (cGrp[subgroup] ~= nil) then
      for _, unit in pairs(cGrp[subgroup]) do
        if (unit and UnitExists(unit) and UnitIsConnected(unit) and UnitIsFriend("player", unit) and UnitIsPlayer(unit) and not UnitIsDeadOrGhost(unit)) then
          _, uc = UnitClass(unit);
          i = 1;
          while (cBuffs[i] and cBuffs[i].BuffS) do
            rbTime = 0;
            buffS = cBuffs[i].BuffS;
            
            rbTime = B[CS()][ct][buffS].RBTime;
            if (rbTime <= 0) then
              rbTime = O.RebuffTimer;
            end
            
            if (cBuffs[i].BuffG and B[CS()][ct][buffS].EnableG and cBuffs[i].IDG ~= nil and cBuffs[i].DurationG > 0) then
              SMARTBUFF_SyncBuffTimer(unit, subgroup, cBuffs[i], true);
            end
            
            if (buffS and B[CS()][ct][buffS].EnableS and cBuffs[i].IDS ~= nil and cBuffs[i].DurationS > 0) then
              if (cBuffs[i].Type ~= SMARTBUFF_CONST_SELF or (cBuffs[i].Type == SMARTBUFF_CONST_SELF and SMARTBUFF_IsPlayer(unit))) then
                SMARTBUFF_SyncBuffTimer(unit, unit, cBuffs[i], false);
              end
            end
            
            i = i + 1;
          end -- END while
        end
      end -- END for
    end
  end -- END for
  
  isSync = false;
  isSyncReq = false;
end


function SMARTBUFF_SyncBuffTimer(unit, grp, cBuff, isGrpBuff)
  if (not unit or not grp or not cBuff) then return end
  
  local buff, d;
  if (isGrpBuff) then
    d = cBuff.DurationG;
    buff = cBuff.BuffG;
  else
    d = cBuff.DurationS;
    buff = cBuff.BuffS;
  end
  
  if (d and d > 0 and buff) then
    local t = GetTime();
    local ret, _, _, timeleft = SMARTBUFF_CheckUnitBuffs(unit, buff, cBuff.Type, cBuff.Links, cBuff.Chain);
    if (ret == nil and timeleft ~= nil) then
      if (not cBuffTimer[grp]) then cBuffTimer[grp] = { } end
      st = Round(t - d + timeleft, 2);
      if (not cBuffTimer[grp][buff] or (cBuffTimer[grp][buff] and cBuffTimer[grp][buff] ~= st)) then
        cBuffTimer[grp][buff] = st;
        if (timeleft > 60) then
          SMARTBUFF_AddMsgD("Buff timer sync: " .. grp .. ", " .. buff .. ", " .. string.format("%.1f", timeleft/60) .. "min");
        else
          SMARTBUFF_AddMsgD("Buff timer sync: " .. grp .. ", " .. buff .. ", " .. string.format("%.1f", timeleft) .. "sec");
        end
      end
    end
  end
end


-- check if the player is shapeshifted
function SMARTBUFF_IsShapeshifted()
  if (sPlayerClass == "SHAMAN") then
    if (GetShapeshiftForm(true) > 0) then
      return true, "Ghost Wolf";
    end
  elseif (sPlayerClass == "DRUID") then
    local i;
    for i = 1, GetNumShapeshiftForms(), 1 do
      local icon, active, castable, spellId = GetShapeshiftFormInfo(i);
    local name = GetSpellInfo(spellId);
      if (active and castable and name ~= SMARTBUFF_DRUID_TREANT) then
        return true, name;
      end
    end  
  end
  return false, nil;
end
-- END SMARTBUFF_IsShapeshifted


local IsChecking = false;
function SMARTBUFF_Check(mode, force)
  if (IsChecking or not SMARTBUFF_PreCheck(mode, force)) then return; end

  IsChecking = true;
  
  local ct = currentTemplate;
  local unit = nil;
  local units = nil;
  local unitsGrp = nil;
  local unitB = nil;
  local unitL = nil;
  local unitU = nil;
  local uLevel = nil;
  local uLevelL = nil;
  local uLevelU = nil;
  local idL = nil;
  local idU = nil;
  local subgroup = 0;
  local i;
  local j;
  local n;
  local m;
  local rc;
  local rank;
  local reagent;
  local nGlobal = 0;
  local tmpDisabled = { };
  
  local buffs = nil;
  if (SMARTBUFF_Buffs[CS()]) then
    buffs = SMARTBUFF_Buffs[CS()][ct];
  end  
  
  SMARTBUFF_checkBlacklist();  
   
  -- 1. check in combat buffs
  if (InCombatLockdown()) then -- and O.InCombat
    for spell in pairs(cBuffsCombat) do
      if (spell) then
        local ret, actionType, spellName, slot, unit, buffType = SMARTBUFF_BuffUnit("player", 0, mode, spell)
        if (ret and ret == 0) then
          IsChecking = false;
          return;
        end
      end
    end  
  end
    
  -- 2. buff target, if enabled
  if ((mode == 0 or mode == 5) and O.BuffTarget) then
    local actionType, spellName, slot, buffType, rankText;
    i, actionType, spellName, slot, _, buffType, rankText = SMARTBUFF_BuffUnit("target", 0, mode);
    if (i <= 1) then
      if (i == 0) then
        --tLastCheck = GetTime() - O.AutoTimer + GlobalCd;
      end
      IsChecking = false;
      return i, actionType, spellName, slot, "target", buffType, rankText;
    end    
  end 
  
  -- 3. check groups
  local cGrp = nil;
  local cOrd = nil;
  cGrp = cGroups;
  cOrd = cOrderGrp;
  
  isMounted = (IsMounted() or IsFlying()) and not O.WarnWhileMounted;

  for _, subgroup in pairs(cOrd) do
    if (cGrp[subgroup] ~= nil or (type(subgroup) == "number" and subgroup == 1)) then
      
      if (cGrp[subgroup] ~= nil) then
        units = cGrp[subgroup];
      else
        units = nil;
      end
      
      if (cUnits and type(subgroup) == "number" and subgroup == 1) then
        unitsGrp = cUnits[1];
      else        
        unitsGrp = units;
      end
    
      -- check group buff
      if (buffs and unitsGrp and not isMounted) then

        i = 1;
        local rbTime = 0;
        while (cBuffs[i] and cBuffs[i].BuffS) do
          local cBuff = cBuffs[i];
          local buffnS = cBuff.BuffS;
          local buffnG = cBuff.BuffG;
          local bs = buffs[buffnS];
      
          if (buffnG and tmpDisabled[buffnG] == nil and bs and bs.EnableG and cBuff.IDG ~= nil
            and ((isCombat and bs.CIn) or (not isCombat and bs.COut)) and IsPowerLimitOk(bs)
            --and UnitMana("player") >= bs.ManaLimit
            and (sPlayerClass ~= "PALADIN" or not cClassGroups or (sPlayerClass == "PALADIN" and (bs[subgroup] or (type(subgroup) == "number" and subgroup == 0))))) then

              local tmpUnits = { };
              local btl = 9999;
              local bExp = false;
              local target = "";
              
              if (sPlayerClass == "PALADIN" and cClassGroups) then
                for _, unit in pairs(units) do
                  local u = UnitClass(unit);
                  if (u) then
                    target = SMARTBUFF_MSG_CLASS .. " " .. u;
                    SMARTBUFF_AddMsgD(target);
                    break;
                  end
                end
              else
                --target = SMARTBUFF_MSG_GROUP .. " " .. subgroup;
                target = SMARTBUFF_MSG_GROUP;
              end
                          
              if (type(subgroup) == "number" and subgroup == 0) then
                target = sPlayerName;
              end            
              
              rbTime = bs.RBTime;
              if (rbTime <= 0) then
                rbTime = SMARTBUFF_Options.RebuffTimer;
              end
              
              if (cBuffTimer[subgroup] ~= nil and cBuffTimer[subgroup][buffnG] ~= nil) then
                btl = cBuff.DurationG - (GetTime() - cBuffTimer[subgroup][buffnG]);
                if (rbTime > 0 and rbTime >= btl) then
                  bExp = true;
                  if (mode == 1) then
                    -- clean up buff timer, if expired
                    if (btl < 0) then
                      cBuffTimer[subgroup][buffnG] = nil;
                      tLastCheck = GetTime() - SMARTBUFF_Options.AutoTimer + 0.5;
                      return;
                    end
                  end
                end
              end            
              
              SMARTBUFF_AddMsgD("Checking0 " .. buffnG);
              n = 0;
              m = 0;
              j = 0;
              uLevelL = 100;
              uLevelU = 0;              
              unitL = nil;
              unitU = nil;
              unitB = nil;
              for _, unit in pairs(unitsGrp) do
                j = j + 1;
                SMARTBUFF_AddMsgD("Checking1 " .. buffnG .. " " .. unit);              
                if (unit and UnitIsPlayer(unit) and not SMARTBUFF_IsInList(unit, UnitName(unit), bs.IgnoreList)) then
                  SMARTBUFF_AddMsgD("Checking2 " .. buffnG .. " " .. unit);
                  n = n + 1;
				  if (UnitExists(unit) and not UnitIsDeadOrGhost(unit) and not UnitIsCorpse(unit) and UnitIsConnected(unit) and UnitIsVisible(unit) and not UnitOnTaxi(unit) and UnitInRange(unit) == 1) then
                    tmpUnits[n] = unit;
                    uLevel = UnitLevel(unit);
                    if (uLevel < uLevelL) then
                      uLevelL = uLevel;
                      unitL = unit;
                    end
                    if (uLevel > uLevelU) then
                      uLevelU = uLevel;
                      unitU = unit;
                      unitB = unit;
                    end
                    local ret, idx, buffname;
                    ret, idx, buffname = SMARTBUFF_CheckUnitBuffs(unit, nil, buffnG);
                    if (ret ~= nil or bExp) then
                      m = m + 1;
                    end
                  end
                end              
                
              end -- end for units
          
              if (mode == 1 and m >= buffs.GrpBuffSize and n >= buffs.GrpBuffSize) then
                SMARTBUFF_SetMissingBuffMessage(target, buffnG, false, 1, btl, bExp, false);
                SMARTBUFF_SetButtonTexture(SmartBuff_KeyButton, cBuff.IconG);
                return;
              end              
              
              if (unitL ~= nil and unitU ~=nil and unitB ~= nil and cBuff.IDG ~= nil) then
                idU, rank = SMARTBUFF_CheckUnitLevel(unitU, cBuff.IDG, cBuff.LevelsG);
                idL, rank = SMARTBUFF_CheckUnitLevel(unitL, cBuff.IDG, cBuff.LevelsG);
                
                if (idL ~= nil and idU ~= nil and idL == idU and rank > 0 and m >= buffs.GrpBuffSize and n >= buffs.GrpBuffSize) then
                  
                  reagent = cBuff.ReagentG[rank];
                  if (reagent and mode ~= 1) then
                    rc = SMARTBUFF_CountReagent(reagent);
                    if (rc > 0) then
                      currentUnit = nil;
                      currentSpell = nil;
                      
                      SMARTBUFF_AddMsgD("Buffing group (" .. unitB .. ") " .. subgroup .. ", " .. idU .. ", " .. j .. ", ");
                      j = SMARTBUFF_doCast(unitB, idU, buffnG, nil, SMARTBUFF_CONST_ALL)
                      
                       if (j == 0) then
                        SMARTBUFF_AddMsg(target .. ": " .. buffnG .. " " .. SMARTBUFF_MSG_BUFFED);
                        SMARTBUFF_AddMsg(SMARTBUFF_MSG_STOCK .. " " .. reagent .. " = " .. (rc - 1));
                                              
                        if (sPlayerClass == "PALADIN") then
                          local _, uc = UnitClass(unitB);
                          if (cBuffTimer[uc] == nil) then
                            cBuffTimer[uc] = { };
                          end
                          cBuffTimer[uc][buffnG] = GetTime();                      
                        else
                          if (cBuffTimer[subgroup] == nil) then
                            cBuffTimer[subgroup] = { };
                          end
                          cBuffTimer[subgroup][buffnG] = GetTime();
                        end
                        
                        -- cleanup single buff timer
                        for _, unit in pairs(tmpUnits) do
                          if (cBuffTimer[unit] and cBuffTimer[unit][buffnS]) then
                            cBuffTimer[unit][buffnS] = nil;
                          end
                        end
                        
                        --tLastCheck = GetTime() - SMARTBUFF_Options.AutoTimer + GlobalCd;
                        return 0, SMARTBUFF_ACTION_SPELL, buffnG, -1, unitB, cBuff.Type;
                      end
                    else
                      SMARTBUFF_AddMsgWarn(SMARTBUFF_MSG_NOREAGENT .. " " .. reagent .. "! " .. buffnG .. " " .. SMARTBUFF_MSG_DEACTIVATED);
                      tmpDisabled[buffnG] = true;
                      --tinsert(tmpDisabled, buffnG);
                      --bs.EnableG = false;
                    end
                  elseif (reagent and mode == 1) then
                    SMARTBUFF_SetMissingBuffMessage(target, buffnG, false, 1, btl, bExp, false);
                    SMARTBUFF_SetButtonTexture(SmartBuff_KeyButton, cBuff.IconG);
                    return;
                  else
                    --SMARTBUFF_AddMsgD("Reagent = nil");
                  end
                end
              end
            end

          i = i + 1;
        end -- END while buffs
      end
      
      -- check buffs
      if (units) then
        for _, unit in pairs(units) do
          if (isSetBuffs) then break; end
          if ((UnitInRange(unit) or unit == "player")) then  -- unit range checking doesnt work with "player", and only party or raid units.            
			  local spellName, actionType, slot, buffType, rankText;
              i, actionType, spellName, slot, _, buffType, rankText = SMARTBUFF_BuffUnit(unit, subgroup, mode);
              if (i <= 1) then
                if (i == 0 and mode ~= 1) then
                  --tLastCheck = GetTime() - O.AutoTimer + GlobalCd;
                  if (actionType == SMARTBUFF_ACTION_ITEM) then
                    --tLastCheck = tLastCheck + 2;
                  end
                end
                IsChecking = false;
                return i, actionType, spellName, slot, unit, buffType, rankText;
              end
		  end
        end
      end
    
    end
  end -- for groups
  
  if (mode == 0) then 
    if (sMsgWarning == "" or sMsgWarning == " ") then
      SMARTBUFF_AddMsg(SMARTBUFF_MSG_NOTHINGTODO);
    else
      SMARTBUFF_AddMsgWarn(sMsgWarning);
      sMsgWarning = "";
    end
  end
  --tLastCheck = GetTime();
  IsChecking = false;
end
-- END SMARTBUFF_Check


-- Buffs a unit
function SMARTBUFF_BuffUnit(unit, subgroup, mode, spell)
  local bs = nil;
  local buff = nil;
  local buffname = nil;
  local buffnS = nil;
  local uc = nil;
  local ur = "NONE";
  local un = nil;
  local uct = nil;
  local ucf = nil;
  local r;
  local rankText;
  local i;
  local bt = 0;
  local cd = 0;
  local cds = 0;
  local charges = 0;
  local handtype = "";
  local bExpire = false;
  local isPvP = false;
  local bufftarget = nil;
  local rbTime = 0;
  local bUsable = false;
  local time = GetTime();
  local cBuff = nil;
  local iId = nil;
  local iSlot = -1;
  
  if (UnitIsPVP("player")) then isPvP = true end
  
  SMARTBUFF_CheckUnitBuffTimers(unit);  
  
  --SMARTBUFF_AddMsgD("Checking " .. unit);
  
  if (UnitExists(unit) and UnitIsFriend("player", unit) and not UnitIsDeadOrGhost(unit) and not UnitIsCorpse(unit)
    and UnitIsConnected(unit) and UnitIsVisible(unit) and not UnitOnTaxi(unit) and not cBlacklist[unit]
    and ((not UnitIsPVP(unit) and (not isPvP or O.BuffPvP)) or (UnitIsPVP(unit) and (isPvP or O.BuffPvP)))) then
    --and not SmartBuff_UnitIsIgnored(unit)
    
    _, uc = UnitClass(unit);
    un = UnitName(unit);
    ur = UnitGroupRolesAssigned(unit);
    uct = UnitCreatureType(unit);
    ucf = UnitCreatureFamily(unit);
    if (uct == nil) then uct = ""; end
    if (ucf == nil) then ucf = ""; end    

    -- debug    
--    if (un) then SMARTBUFF_AddMsgD("Grp "..subgroup.." checking "..un.." ("..unit.."/"..uc.."/"..ur.."/"..uct.."/"..ucf..")", 0, 1, 0.5); end

    isShapeshifted, sShapename = SMARTBUFF_IsShapeshifted();
    --while (cBuffs[i] and cBuffs[i].BuffS) do
    for i, buffnS in pairs(B[CS()].Order) do    
      if (isSetBuffs or SmartBuffOptionsFrame:IsVisible()) then break; end
      cBuff = cBuffs[cBuffIndex[buffnS]];
      --buffnS = cBuff.BuffS;
      bs = GetBuffSettings(buffnS);
      bExpire = false;
      handtype = "";
      charges = -1;
      bufftarget = nil;
      bUsable = false;
      iId = nil;
      iSlot = -1;
      
      if (not cBuff or not bs) then bUsable = false end
      if (cBuff and bs) then bUsable = bs.EnableS end
      
      if (bUsable and spell and spell ~= buffnS) then
        bUsable = false;
      end

      if (bUsable and cBuff.Type == SMARTBUFF_CONST_SELF and not SMARTBUFF_IsPlayer(unit)) then bUsable = false end
      if (bUsable and not cBuff.Type == SMARTBUFF_CONST_TRACK and not SMARTBUFF_IsItem(cBuff.Type) and not IsUsableSpell(buffnS)) then bUsable = false end
      if (bUsable and bs.SelfNot and SMARTBUFF_IsPlayer(unit)) then bUsable = false end
      if (bUsable and cBuff.Params == SG.CheckFishingPole and SMARTBUFF_IsFishingPoleEquiped()) then bUsable = false end
     
      -- Check for power threshold
      if (bUsable) then
        bUsable = IsPowerLimitOk(bs);
      end
     
      -- Check for buffs which depends on a pet
      if (bUsable and cBuff.Params == SG.CheckPet and UnitExists("pet")) then bUsable = false end
      if (bUsable and cBuff.Params == SG.CheckPetNeeded and not UnitExists("pet")) then bUsable = false end
      
      -- Check for mount auras
        isMounted = false;
	  if (bUsable and sPlayerClass == "PALADIN") then
		  isMounted = (IsMounted() or IsFlying()) and not O.WarnWhileMounted;
		  if ((buffnS ~= SMARTBUFF_CRUSADERAURA and isMounted) or (buffnS == SMARTBUFF_CRUSADERAURA and not isMounted)) then
			bUsable = false;
		  end
	  end

      -- check for hunter pet spawn and ignore call pet if its already active
      if (bUsable and sPlayerClass == "HUNTER") then
        if (buffnS == SMARTBUFF_CALLPET and IsPetActive()) then
		    bUsable = false;
		end
      end  

      -- check if daily island buff is active
      if (bUsable and CheckForBuff(SMARTBUFF_KIRUSSOV) and (sPlayerClass == "PRIEST" or sPlayerClass == "MAGE")) then
        -- island buff is more powerful than the class buffs which prevents the addon moving past this.
	    if (buffnS == SMARTBUFF_AI or buffnS == SMARTBUFF_ABRB1 or buffnS == SMARTBUFF_PWF or buffnS == SMARTBUFF_POFRB1) then
		    bUsable = false;
		end
	  end

      -- check for Fel Intelligence
      if (bUsable and CheckForBuff(SMARTBUFF_FELINTELLIGENCE) and (sPlayerClass == "PRIEST" or sPlayerClass == "MAGE")) then
		if (buffnS == SMARTBUFF_AI or buffnS == SMARTBUFF_ABRB1 or buffnS == SMARTBUFF_DS or buffnS == SMARTBUFF_POSRB1) then
		  bUsable = false;
		end
      end

      if (bUsable and not (cBuff.Type == SMARTBUFF_CONST_TRACK or SMARTBUFF_IsItem(cBuff.Type))) then
        -- check if you have enough mana/rage/energy to cast
        local isUsable, notEnoughMana = IsUsableSpell(buffnS);
        if (notEnoughMana) then
          bUsable = false;
          --SMARTBUFF_AddMsgD("Buff " .. cBuff.BuffS .. ", not enough mana!");
        elseif (mode ~= 1 and isUsable == nil and buffnS ~= SMARTBUFF_PWS) then
          bUsable = false;
          --SMARTBUFF_AddMsgD("Buff " .. cBuff.BuffS .. " is not usable!");
        end
      end      
      
      if (bUsable and bs.EnableS and (cBuff.IDS ~= nil or SMARTBUFF_IsItem(cBuff.Type) or cBuff.Type == SMARTBUFF_CONST_TRACK)
        and ((mode ~= 1 and ((isCombat and bs.CIn) or (not isCombat and bs.COut)))
          or (mode == 1 and bs.Reminder and ((not isCombat and bs.COut) 
          or (isCombat and (bs.CIn or O.ToggleAutoCombat)))))) then
        
        --print("Check: "..buffnS)
        
        if (not bs.SelfOnly or (bs.SelfOnly and SMARTBUFF_IsPlayer(unit))) then
          -- get current spell cooldown
          cd = 0;
          cds = 0;
          if (cBuff.IDS) then
            cds, cd = GetSpellCooldown(buffnS);
            cd = (cds + cd) - time;
            if (cd < 0) then
              cd = 0;
            end
            --SMARTBUFF_AddMsgD(buffnS.." cd = "..cd);
          end
          
          -- check if spell has cooldown
          if (cd <= 0 or (mode == 1 and cd <= 1.5)) then
            if (cBuff.IDS and sMsgWarning == SMARTBUFF_MSG_CD) then
              sMsgWarning = " ";
            end
            
            rbTime = bs.RBTime;
            if (rbTime <= 0) then
              rbTime = O.RebuffTimer;
            end
          
            --SMARTBUFF_AddMsgD(uc.." "..CT());
            if (not SMARTBUFF_IsInList(unit, un, bs.IgnoreList) and (((cBuff.Type == SMARTBUFF_CONST_GROUP or cBuff.Type == SMARTBUFF_CONST_ITEMGROUP)
              and (bs[ur]
              or (bs.SelfOnly and SMARTBUFF_IsPlayer(unit))
              or (bs[uc] and (UnitIsPlayer(unit) or uct == SMARTBUFF_HUMANOID or (uc == "DRUID" and (uct == SMARTBUFF_BEAST or uct == SMARTBUFF_ELEMENTAL))))
              or (bs["HPET"] and uct == SMARTBUFF_BEAST and uc ~= "DRUID")
              or (bs["DKPET"] and utc == SMARTBUFF_UNDEAD)
              or (bs["WPET"] and (uct == SMARTBUFF_DEMON or (uc ~= "DRUID" and uct == SMARTBUFF_ELEMENTAL)) and ucf ~= SMARTBUFF_DEMONTYPE)))
              or (cBuff.Type ~= SMARTBUFF_CONST_GROUP and SMARTBUFF_IsPlayer(unit))
              or SMARTBUFF_IsInList(unit, un, bs.AddList))) then
              buff = nil;
                        
              --Tracking ability ------------------------------------------------------------------------

			  if (cBuff.Type == SMARTBUFF_CONST_TRACK) then   			        
				  if wowTOC >= 20502 then  
					  -- assume we are TBC Classic or higher
					  local count = (GetNumTrackingTypes())+1;	-- GetNumTrackingTypes doesnt count "none" so add one to include it.
					  local trackingFound;
					  for n = 1, count do 
						local trackN, trackT, trackA, trackC = GetTrackingInfo(n);
						if trackN == buffnS and trackA then 
						trackingFound = true;
						break;
						else
						trackingFound = false;
						end
					  end
					  if not trackingFound then
						if (sPlayerClass ~= "DRUID" or ((not isShapeshifted and buffnS ~= SMARTBUFF_DRUID_TRACK) or (isShapeshifted and buffnS ~= SMARTBUFF_DRUID_TRACK) or (isShapeshifted and buffnS == SMARTBUFF_DRUID_TRACK and sShapename == SMARTBUFF_DRUID_CAT))) then
							buff = buffnS;
						end
					  end
				  else
					-- we are below the minimal tbc build, assume its classic era / season of mastery.
					local iconTrack = GetTrackingTexture();        
					if (iconTrack ~= nil) then
					  SMARTBUFF_AddMsgD("Track already enabled: " .. iconTrack);
					else
					  if (sPlayerClass ~= "DRUID" or ((not isShapeshifted and buffnS ~= SMARTBUFF_DRUID_TRACK) or (isShapeshifted and buffnS ~= SMARTBUFF_DRUID_TRACK) or (isShapeshifted and buffnS == SMARTBUFF_DRUID_TRACK and sShapename == SMARTBUFF_DRUID_CAT))) then
						buff = buffnS;
						SMARTBUFF_AddMsgD("Missing tracking: "..buffnS);
					  end
					end
				  end
         
              -- Food, Scroll, Potion or conjured items ------------------------------------------------------------------------

              elseif (cBuff.Type == SMARTBUFF_CONST_FOOD or cBuff.Type == SMARTBUFF_CONST_SCROLL or cBuff.Type == SMARTBUFF_CONST_POTION or 
                      cBuff.Type == SMARTBUFF_CONST_ITEM or cBuff.Type == SMARTBUFF_CONST_ITEMGROUP) then
              
                if (cBuff.Type == SMARTBUFF_CONST_ITEM) then
                  bt = nil;
                  buff = nil;
                  if (cBuff.Params ~= SG.NIL) then
                    local cr = SMARTBUFF_CountReagent(cBuff.Params, cBuff.Chain);
                    if (cr == 0) then
                      buff = cBuff.Params;
                    end
                  end   
				
				-- only prompt / apply food when I am not moving - this would constantly use food
				-- in your bags if you were moving - bugfix 03/12/2021.

                elseif (cBuff.Type == SMARTBUFF_CONST_FOOD and isPlayerMoving == false) then
                  if (not SMARTBUFF_IsPicnic(unit)) then
                    buff, index, buffname, bt, charges = SMARTBUFF_CheckUnitBuffs(unit, SMARTBUFF_FOOD_AURA, cBuff.Type, cBuff.Links, cBuff.Chain);
                  end

                else
                  if (cBuff.Params ~= SG.NIL) then
                    if (cBuff.Links and cBuff.Links == SG.CheckFishingPole) then
                      if (SMARTBUFF_IsFishingPoleEquiped()) then
                        buff, index, buffname, bt, charges = SMARTBUFF_CheckUnitBuffs(unit, cBuff.Params, cBuff.Type);
                      else
                        buff = nil;
                      end
                    else
                      buff, index, buffname, bt, charges = SMARTBUFF_CheckUnitBuffs(unit, cBuff.Params, cBuff.Type, cBuff.Links, cBuff.Chain);
			        end
                  else
                    buff = nil;
                  end
                end
                
                if (buff == nil and cBuff.DurationS >= 1 and rbTime > 0) then
                  if (charges == nil) then charges = -1; end
                  if (charges > 1) then cBuff.CanCharge = true; end
                  bufftarget = nil;
                end
                
                if (bt and bt <= rbTime) then
                  buff = buffnS;
                  bExpire = true;
                end                
              
                if (buff) then
                  if (cBuff.Type ~= SMARTBUFF_CONST_ITEM) then
                    local cr, iid = SMARTBUFF_CountReagent(buffnS, cBuff.Chain);
                    if (cr > 0) then
                      buff = buffnS;
                      if (cBuff.Type == SMARTBUFF_CONST_ITEMGROUP or cBuff.Type == SMARTBUFF_CONST_SCROLL) then
                        cds, cd = GetItemCooldown(iid);
                        cd = (cds + cd) - time;
                        if (cd > 0) then
                          buff = nil;
                        end
                      end
                    else
                      buff = nil;
                      bExpire = false;
                    end
                  end
                end
                
              -- Weapon buff ------------------------------------------------------------------------

              elseif (cBuff.Type == SMARTBUFF_CONST_WEAPON or cBuff.Type == SMARTBUFF_CONST_INV) then                                
                local bMh, tMh, cMh, idMh, bOh, tOh, cOh, idOh = GetWeaponEnchantInfo();
                if (bs.MH) then
                  iSlot = 16;
                  iId = GetInventoryItemID("player", iSlot);
                  if (iId and SMARTBUFF_CanApplyWeaponBuff(buffnS, iSlot)) then
                    if (bMh) then
                      if (rbTime > 0 and cBuff.DurationS >= 1) then
                        --if (tMh == nil) then tMh = 0; end
                        tMh = floor(tMh/1000);
                        charges = cMh;
                        if (charges == nil) then charges = -1; end
                        if (charges > 1) then cBuff.CanCharge = true; end
                        --SMARTBUFF_AddMsgD(un .. " (WMH): " .. buffnS .. string.format(" %.0f sec left", tMh) .. ", " .. charges .. " charges left");
                        if (tMh <= rbTime or (O.CheckCharges and cBuff.CanCharge and charges > 0 and charges <= O.MinCharges)) then
                          buff = buffnS;
                          bt = tMh;
                          bExpire = true;
                        end
                      end
                    else
                      handtype = "main";
                      buff = buffnS;
                    end
                  else
                    SMARTBUFF_AddMsgD("Weapon Buff cannot be cast, no mainhand weapon equipped or wrong weapon/stone type");
                  end
                end
                
                if (bs.OH and not bExpire and handtype == "") then
                  iSlot = 17;
                  iId = GetInventoryItemID("player", iSlot);
                  if (iId and SMARTBUFF_CanApplyWeaponBuff(buffnS, iSlot)) then
                    if (bOh) then
                      if (rbTime > 0 and cBuff.DurationS >= 1) then
                        --if (tOh == nil) then tOh = 0; end
                        tOh = floor(tOh/1000);
                        charges = cOh;
                        if (charges == nil) then charges = -1; end
                        if (charges > 1) then cBuff.CanCharge = true; end
                        --SMARTBUFF_AddMsgD(un .. " (WOH): " .. buffnS .. string.format(" %.0f sec left", tOh) .. ", " .. charges .. " charges left");
                        if (tOh <= rbTime or (O.CheckCharges and cBuff.CanCharge and charges > 0 and charges <= O.MinCharges)) then
                          buff = buffnS;
                          bt = tOh;
                          bExpire = true;                          
                        end                      
                      end
                    else
                      handtype = "off";
                      buff = buffnS;
                    end
                  else
                    SMARTBUFF_AddMsgD("Weapon Buff cannot be cast, no offhand weapon equipped or wrong weapon/stone type");
                  end
                end

                if (buff and cBuff.Type == SMARTBUFF_CONST_INV) then
                  local cr = SMARTBUFF_CountReagent(buffnS, cBuff.Chain);
                  if (cr > 0) then
                    --SMARTBUFF_AddMsgD(cr .. " " .. buffnS .. " found");
                  else
                    --SMARTBUFF_AddMsgD("No " .. buffnS .. " found");
                    buff = nil;
                  end
                end                
                
              -- Normal buff ------------------------------------------------------------------------

              else
                local index = nil;                
                -- check timer object
                buff, index, buffname, bt, charges = SMARTBUFF_CheckUnitBuffs(unit, buffnS, cBuff.Type, cBuff.Links, cBuff.Chain);
                if (charges == nil) then charges = -1; end
                if (charges > 1) then cBuff.CanCharge = true; end                  
                if (unit ~= "target" and buff == nil and cBuff.DurationS >= 1 and rbTime > 0) then
                  if (SMARTBUFF_IsPlayer(unit)) then
                    if (cBuffTimer[unit] ~= nil and cBuffTimer[unit][buffnS] ~= nil) then
                      local tbt = cBuff.DurationS - (time - cBuffTimer[unit][buffnS]);
                      if (not bt or bt - tbt > rbTime) then
                        bt = tbt;
                      end
                    end                    
                    bufftarget = nil;
                    --SMARTBUFF_AddMsgD(un .. " (P): " .. index .. ". " .. GetPlayerBuffTexture(index) .. "(" .. charges .. ") - " .. buffnS .. string.format(" %.0f sec left", bt));
                  elseif (cBuffTimer[unit] ~= nil and cBuffTimer[unit][buffnS] ~= nil) then
					bt = cBuff.DurationS - (time - cBuffTimer[unit][buffnS]);
                    bufftarget = nil;
                    --SMARTBUFF_AddMsgD(un .. " (S): " .. buffnS .. string.format(" %.0f sec left", bt));
                  elseif (cBuff.BuffG ~= nil and cBuffTimer[subgroup] ~= nil and cBuffTimer[subgroup][cBuff.BuffG] ~= nil) then
                    bt = cBuff.DurationG - (time - cBuffTimer[subgroup][cBuff.BuffG]);
                    if (type(subgroup) == "number") then
                      bufftarget = SMARTBUFF_MSG_GROUP .. " " .. subgroup;
                    else
                      bufftarget = SMARTBUFF_MSG_CLASS .. " " .. UnitClass(unit);
                    end
                    --SMARTBUFF_AddMsgD(bufftarget .. ": " .. cBuff.BuffG .. string.format(" %.0f sec left", bt));
                  elseif (cBuff.BuffG ~= nil and cBuffTimer[uc] ~= nil and cBuffTimer[uc][cBuff.BuffG] ~= nil) then
                    bt = cBuff.DurationG - (time - cBuffTimer[uc][cBuff.BuffG]);
                    bufftarget = SMARTBUFF_MSG_CLASS .. " " .. UnitClass(unit);
                    --SMARTBUFF_AddMsgD(bufftarget .. ": " .. cBuff.BuffG .. string.format(" %.0f sec left", bt));
                  else
                    bt = nil;
                  end
                  
                  if ((bt and bt <= rbTime) or (O.CheckCharges and cBuff.CanCharge and charges > 0 and charges <= O.MinCharges)) then
                    if (buffname) then
                      buff = buffname;
                    else
                      buff = buffnS;
                    end
                    bExpire = true;
                  end
                end
                
                -- check if the group buff is active, in this case it is not possible to cast the single buff
                if (buffname and mode ~= 1 and buffname ~= buffnS) then
                  buff = nil;
                  --SMARTBUFF_AddMsgD("Group buff is active, single buff canceled!");
				  --print("Group buff is active, single buff canceled!");
                end

              end -- END normal buff

              -- check if shapeshifted and cancel buff if it is not possible to cast it
              if (buff and cBuff.Type ~= SMARTBUFF_CONST_TRACK and cBuff.Type ~= SMARTBUFF_CONST_FORCESELF) then
                --isShapeshifted = true;
                --sShapename = "Moonkingestalt";
                if (isShapeshifted) then
                  if (string.find(cBuff.Params, sShapename)) then
                    --SMARTBUFF_AddMsgD("Cast " .. buff .. " while shapeshifted");
                  else
                    if(cBuff.Params == SMARTBUFF_DRUID_CAT) then
                      buff = nil;
                    end                  
                    if (buff and mode ~= 1 and not O.InShapeshift and (sShapename ~= SMARTBUFF_DRUID_MOONKIN and sShapename ~= SMARTBUFF_DRUID_TREANT)) then
                      --sMsgWarning = SMARTBUFF_MSG_SHAPESHIFT .. ": " .. sShapename;
                      buff = nil;
                    end
                  end
                else
                  if(cBuff.Params == SMARTBUFF_DRUID_CAT) then
                    buff = nil;
                  end
                end
              end
                            
              if (buff) then              
                -- Cast mode ---------------------------------------------------------------------------------------
                if (mode == 0 or mode == 5) then
                  currentUnit = nil;
                  currentSpell = nil;
                  --try to apply weapon buffs on main/off hand
                  if (cBuff.Type == SMARTBUFF_CONST_INV) then                    
                    if (iSlot and (handtype ~= "" or bExpire)) then
                      local bag, slot, count = SMARTBUFF_FindItem(buffnS, cBuff.Chain);
                      if (count > 0) then
                        sMsgWarning = "";
                        return 0, SMARTBUFF_ACTION_ITEM, buffnS, iSlot, "player", cBuff.Type;
                      end
                    end
                    r = 50;
                  elseif (cBuff.Type == SMARTBUFF_CONST_WEAPON) then
                    if (iId and (handtype ~= "" or bExpire)) then
                      sMsgWarning = "";
                      return 0, SMARTBUFF_ACTION_SPELL, buffnS, iSlot, "player", cBuff.Type;
                      --return 0, SMARTBUFF_ACTION_SPELL, buffnS, iId, "player", cBuff.Type;
                    end                    
                    r = 50;                    
                  -- eat food or use scroll or potion
                  elseif (cBuff.Type == SMARTBUFF_CONST_FOOD or cBuff.Type == SMARTBUFF_CONST_SCROLL or cBuff.Type == SMARTBUFF_CONST_POTION) then
                    local bag, slot, count = SMARTBUFF_FindItem(buffnS, cBuff.Chain);
                    if (count > 0 or bExpire) then
                      sMsgWarning = "";
                      return 0, SMARTBUFF_ACTION_ITEM, buffnS, 0, "player", cBuff.Type;
                    end
                    r = 20;                    
                  -- use item on a unit
                  elseif (cBuff.Type == SMARTBUFF_CONST_ITEMGROUP) then
                    local bag, slot, count = SMARTBUFF_FindItem(buffnS, cBuff.Chain);
                    if (count > 0) then
                      sMsgWarning = "";
                      return 0, SMARTBUFF_ACTION_ITEM, buffnS, 0, unit, cBuff.Type;
                    end
                    r = 20;                  
                  -- create item
                  elseif (cBuff.Type == SMARTBUFF_CONST_ITEM) then
                    r = 20;
                    local bag, slot, count = SMARTBUFF_FindItem(buff, cBuff.Chain);                    
                    if (count == 0) then
                      r = SMARTBUFF_doCast(unit, cBuff.IDS, buffnS, cBuff.LevelsS, cBuff.Type);
                      if (r == 0) then
                        currentUnit = unit;
                        currentSpell = buffnS;
                      end
                    end                  
                  -- cast spell
                  else
                    r, _, rankText = SMARTBUFF_doCast(unit, cBuff.IDS, buffnS, cBuff.LevelsS, cBuff.Type);
					if (r == 0) then
                      currentUnit = unit;
                      currentSpell = buffnS;
                    end
                  end
                
                -- Check mode ---------------------------------------------------------------------------------------
                elseif (mode == 1) then
                  currentUnit = nil;
                  currentSpell = nil;
                  if (bufftarget == nil) then bufftarget = un; end
                  
                  if (SMARTBUFF_CheckUnitLevel(unit, cBuff.IDS, cBuff.LevelsS) ~= nil or cBuff.IDS ~= nil or SMARTBUFF_IsItem(cBuff.Type) or cBuff.Type == SMARTBUFF_CONST_TRACK) then
                    -- clean up buff timer, if expired
                    if (bt and bt < 0 and bExpire) then 
                      bt = 0;
                      if (cBuffTimer[unit] ~= nil and cBuffTimer[unit][buffnS] ~= nil) then
                        cBuffTimer[unit][buffnS] = nil;
                        --SMARTBUFF_AddMsgD(un .. " (S): " .. buffnS .. " timer reset");
                      end
                      if (cBuff.IDG ~= nil) then
                        if (cBuffTimer[subgroup] ~= nil and cBuffTimer[subgroup][cBuff.BuffG] ~= nil) then
                          cBuffTimer[subgroup][cBuff.BuffG] = nil;
                          --SMARTBUFF_AddMsgD("Group " .. subgroup .. ": " .. buffnS .. " timer reset");
                        end                  
                        if (cBuffTimer[uc] ~= nil and cBuffTimer[uc][cBuff.BuffG] ~= nil) then
                          cBuffTimer[uc][cBuff.BuffG] = nil;
                          --SMARTBUFF_AddMsgD("Class " .. uc .. ": " .. cBuff.BuffG .. " timer reset");
                        end
                      end
                      tLastCheck = time - O.AutoTimer + 0.5;
                      return 0;
                    end
                                       
                    SMARTBUFF_SetMissingBuffMessage(bufftarget, buff, cBuff.IconS, cBuff.CanCharge, charges, bt, bExpire);
                    SMARTBUFF_SetButtonTexture(SmartBuff_KeyButton, cBuff.IconS);
                    return 0;
                  end
                end
                
                if (r == 0) then
                  -- target buffed
                  -- Message will printed in the "SPELLCAST_STOP" event
                  sMsgWarning = "";
                  return 0, SMARTBUFF_ACTION_SPELL, buffnS, -1, unit, cBuff.Type, rankText;
                elseif (r == 1) then
                  -- spell cooldown
                  if (mode == 0) then SMARTBUFF_AddMsgWarn(buffnS .. " " .. SMARTBUFF_MSG_CD); end
                  return 1;
                elseif (r == 2) then
                  -- can not target
                  if (mode == 0 and ucf ~= SMARTBUFF_DEMONTYPE) then SMARTBUFF_AddMsgD("Can not target " .. un); end
                elseif (r == 3) then
                  -- target oor
                  if (mode == 0) then SMARTBUFF_AddMsgWarn(un .. " " .. SMARTBUFF_MSG_OOR); end
                  break;
                elseif (r == 4) then
                  -- spell cooldown > maxSkipCoolDown
                  if (mode == 0) then SMARTBUFF_AddMsgD(buffnS .. " " .. SMARTBUFF_MSG_CD .. " > " .. maxSkipCoolDown); end
                elseif (r == 5) then
                  -- target to low
                  if (mode == 0) then SMARTBUFF_AddMsgD(un .. " is to low to get buffed with " .. buffnS); end
                elseif (r == 6) then
                  -- not enough mana/rage/energy
                  sMsgWarning = SMARTBUFF_MSG_OOM;
                elseif (r == 7) then
                  -- tracking ability is already active
                  if (mode == 0) then SMARTBUFF_AddMsgD(buffnS .. " not used, other ability already active"); end
                elseif (r == 8) then
                  -- actionslot is not defined
                  if (mode == 0) then SMARTBUFF_AddMsgD(buffnS .. " has no actionslot"); end
                elseif (r == 9) then
                  -- spell ID not found
                  if (mode == 0) then SMARTBUFF_AddMsgD(buffnS .. " spellID not found"); end
                elseif (r == 10) then
                  -- target could not buffed
                  if (mode == 0) then SMARTBUFF_AddMsgD(buffnS .. " could not buffed on " .. un); end
                elseif (r == 20) then
                  -- item not found
                  if (mode == 0) then SMARTBUFF_AddMsgD(buffnS .. " could not used"); end
                elseif (r == 50) then
                  -- weapon buff could not applied
                  if (mode == 0) then SMARTBUFF_AddMsgD(buffnS .. " could not applied"); end
                else
                  -- no spell selected
                  if (mode == 0) then SMARTBUFF_AddMsgD(SMARTBUFF_MSG_CHAT); end
                end
              else
                -- finished
                if (mode == 0) then SMARTBUFF_AddMsgD(un .. " nothing to buff"); end
              end
            else
              -- target does not need this buff
              if (mode == 0) then SMARTBUFF_AddMsgD(un .. " does not need " .. buffnS); end            
            end
          else
            -- cooldown
            if (sMsgWarning == "") then
              sMsgWarning = SMARTBUFF_MSG_CD;
            end
            --SMARTBUFF_AddMsgD("Spell on cd: "..buffnS);
          end
        end -- group or self
      end
      --i = i + 1;
    end -- for buff
      
  end
  return 3;
end
-- END SMARTBUFF_BuffUnit


function SMARTBUFF_IsInList(unit, unitname, list)
  if (list ~= nil) then
    for un in pairs(list) do
      if (un ~= nil and UnitIsPlayer(unit) and un == unitname) then
        return true;
      end
    end
  end
  return false;
end


function SMARTBUFF_SetMissingBuffMessage(target, buff, icon, bCanCharge, nCharges, tBuffTimeLeft, bExpire)
  local f = SmartBuffSplashFrame;
  -- show splash buff message
  if (f and O.ToggleAutoSplash and not SmartBuffOptionsFrame:IsVisible()) then
    local s;
    local sd = O.SplashDuration;
    local si = "";
    
    if (OG.SplashIcon and icon) then 
      local n = O.SplashIconSize;
      if (n == nil or n <= 0) then
        n = O.CurrentFontSize;
      end
      si = string.format("\124T%s:%d:%d:1:0\124t ", icon, n, n) or "";
    end
    if (OG.SplashMsgShort and si == "") then si = buff end
    if (O.AutoTimer < 4) then
      sd = 1;
      f:Clear();
    end
    
    f:SetTimeVisible(sd);
    if (not nCharges) then nCharges = 0; end
    if (O.CheckCharges and bCanCharge and nCharges > 0 and nCharges <= O.MinCharges and bExpire) then
      if (OG.SplashMsgShort) then
        s = target.." > "..si.." < "..format(SMARTBUFF_ABBR_CHARGES_OL, nCharges);
      else
        s = target.."\n"..SMARTBUFF_MSG_REBUFF.." "..si..buff..": "..format(ITEM_SPELL_CHARGES, nCharges).." "..SMARTBUFF_MSG_LEFT;
      end
    elseif (bExpire) then
      if (OG.SplashMsgShort) then
        s = target.." > "..si.." < "..format(SECOND_ONELETTER_ABBR, tBuffTimeLeft);
      else
        s = target.."\n"..SMARTBUFF_MSG_REBUFF.." "..si..buff..": "..format(SECONDS_ABBR, tBuffTimeLeft).." "..SMARTBUFF_MSG_LEFT;
      end
    else
      if (OG.SplashMsgShort) then
        s = target.." > "..si;
      else
        s = target.." "..SMARTBUFF_MSG_NEEDS.." "..si..buff;
      end
    end
    f:AddMessage(s, O.ColSplashFont.r, O.ColSplashFont.g, O.ColSplashFont.b, 1.0);
  end
  
  -- show chat buff message
  if (O.ToggleAutoChat) then
    if (O.CheckCharges and bCanCharge and nCharges > 0 and nCharges <= O.MinCharges and bExpire) then
      SMARTBUFF_AddMsgWarn(target..": "..SMARTBUFF_MSG_REBUFF.." "..buff..", "..format(ITEM_SPELL_CHARGES, nCharges).." ".. SMARTBUFF_MSG_LEFT, true);
    elseif (bExpire) then
      SMARTBUFF_AddMsgWarn(target..": "..SMARTBUFF_MSG_REBUFF.." "..buff..format(SECONDS_ABBR, tBuffTimeLeft).." "..SMARTBUFF_MSG_LEFT, true);
    else
      SMARTBUFF_AddMsgWarn(target.." "..SMARTBUFF_MSG_NEEDS.." "..buff, true);
    end
  end
  
  -- play sound
  if (O.ToggleAutoSound) then
    PlaySound(Sounds[O.AutoSoundSelection]);
  end
end


local cWeaponStandard = {0, 1, 4, 5, 6, 7, 8, 10, 13, 15, 16}; -- "Daggers", "Axes", "Swords", "Maces", "Staves", "Fist Weapons", "Polearms", "Thrown"
local cWeaponBlunt = {4, 5, 10, 13}; -- "Maces", "Staves", "Fist Weapons"
local cWeaponSharp = {0, 1, 6, 7, 8, 15}; -- "Daggers", "Axes", "Swords", "Polearms"

-- check if a spell/reagent could applied on a weapon
function SMARTBUFF_CanApplyWeaponBuff(buff, slot)
  local cWeaponTypes = nil;
  if (string.find(buff, SMARTBUFF_WEAPON_SHARP_PATTERN)) then
    cWeaponTypes = cWeaponSharp;
  elseif (string.find(buff, SMARTBUFF_WEAPON_BLUNT_PATTERN)) then
    cWeaponTypes = cWeaponBlunt;
  else
    cWeaponTypes = cWeaponStandard;
  end
  
  local itemLink = GetInventoryItemLink("player", slot);
  if (itemLink == nil) then return false end
  
  local itemType, itemSubType, _, _, _, _, classId, subclassId = select(6, GetItemInfo(itemLink));
  --if (itemType and itemSubType) then
  --  SMARTBUFF_AddMsgD("Type: "..itemType..", Subtype: "..itemSubType);
  --end
  
  if (tcontains(cWeaponTypes, subclassId)) then
    return true, itemSubType;
  end

  return false;
end
-- END SMARTBUFF_CanApplyWeaponBuff


-- Check the unit blacklist
function SMARTBUFF_checkBlacklist()
  local t = GetTime();
  for unit in pairs(cBlacklist) do
    if (t > (cBlacklist[unit] + O.BlacklistTimer)) then
      cBlacklist[unit] = nil;
    end
  end
end
-- END SMARTBUFF_checkBlacklist


-- Casts a spell
function SMARTBUFF_doCast(unit, id, spellName, levels, type)
  if (id == nil) then return 9; end
  if (type == SMARTBUFF_CONST_TRACK) then  
    local iconTrack = GetTrackingTexture();
    if (iconTrack ~= nil and iconTrack ~= "Interface\\Minimap\\Tracking\\None") then
      SMARTBUFF_AddMsgD("Track already enabled: "..iconTrack);
      return 7; 
    end
  end
    
  -- check if spell has cooldown
  local _, cd = GetSpellCooldown(spellName)
  if (not cd) then
    -- move on
  elseif (cd > maxSkipCoolDown) then
    return 4;
  elseif (cd > 0) then 
    return 1;
  end

 -- switched to using the LibRangeCheck-2.0 library by mitchnull for range checking.
  if ((type == SMARTBUFF_CONST_GROUP or type == SMARTBUFF_CONST_ITEMGROUP)) then
    local minRange, maxRange = LRC:GetRange(unit)
	if (UnitInRange(unit) or unit == "player" or (unit == "target" and O.BuffTarget)) then
	    if (SpellHasRange(spellName)) then    
            if not minRange then
	            return 3;   -- unit is out of range for spell
			end
        end
    else
        -- unit is not in range
        return 3;
	end
  end
  
  -- check if target is to low for this spell
  local newId, rank, rankText = SMARTBUFF_CheckUnitLevel(unit, id, levels);
  if (newId == nil) then
    return 5;
  end

  -- check if you have enough mana/energy/rage to cast
  local isUsable, notEnoughMana = IsUsableSpell(spellName);
  if (notEnoughMana) then
    return 6;
  end
  
  return 0, rank, rankText;
end
-- END SMARTBUFF_doCast


-- checks if the unit is the player
function SMARTBUFF_IsPlayer(unit)
  if (unit and UnitIsUnit("player", unit)) then
    return true;
  end
  return false;
end
-- END SMARTBUFF_IsPlayer


function UnitBuffByBuffName(target,buffname,filter)
  for i = 1,40 do
    name = UnitBuff(target, i, filter);
    if not name then return end
    if name == buffname then
      return UnitBuff(target, i, filter);
    end
  end
end

--
--	SMARTBUFF_CheckUnitBuffs
--	Function to return the name of the buff to cast.	
--
function SMARTBUFF_CheckUnitBuffs(unit, buffN, buffT, buffL, buffC)
  if (not unit or (not buffN and not buffL)) then return end
  
  local i, n, v;
  local buff = nil;
  local defBuff = nil;
  local timeleft = nil;
  local duration = nil;
  local caster = nil;
  local count = nil;
  local icon = nil;
  local time = GetTime();
  local uname = UnitName(unit) or "?";
  
  if (buffN) then
    defBuff = buffN;
  else
    defBuff = buffL[1];
  end
    
  -- Stance/Presence/Seal check, these are not in the aura list
  n = cBuffIndex[defBuff];
  if (cBuffs[n] and cBuffs[n].Type == SMARTBUFF_CONST_STANCE) then
    if (defBuff and buffC and #buffC >= 1) then
      local t = B[CS()].Order;
      if (t and #t >= 1) then
        for i = 1, #t, 1 do
          if (t[i] and tfind(buffC, t[i])) then
            v = GetBuffSettings(t[i]);
            if (v and v.EnableS) then
              for n = 1, GetNumShapeshiftForms(), 1 do
                local _, name, active, castable = GetShapeshiftFormInfo(n);
                if (name and not active and castable and name == t[i]) then
                  return defBuff, nil, nil, nil, nil;
                elseif (name and active and castable and name == t[i]) then
                  return nil, i, defBuff, 1800, -1;
                end
              end
            end
          end
        end
      end
    end
    return defBuff, nil, nil, nil, nil;  
  end
  
  -- Check linked buffs
  if (buffL) then
    if (not O.LinkSelfBuffCheck and buffT == SMARTBUFF_CONST_SELF) then
      -- Do not check linked self buffs
    elseif (not O.LinkGrpBuffCheck and buffT == SMARTBUFF_CONST_GROUP) then
      -- Do not check linked group buffs
    else
      for n, v in pairs(buffL) do
        if (v and v ~= defBuff) then
          SMARTBUFF_AddMsgD("Check linked buff ("..uname.."): "..v);
          buff, icon, count, _, duration, timeleft, caster = UnitBuffByBuffName(unit, v);
          if (buff) then
            timeleft = timeleft - time;
            SMARTBUFF_AddMsgD("Linked buff found: "..buff..", "..timeleft..", "..icon);
            return nil, n, defBuff, timeleft, count;
          end
        end
      end
    end
  end
  
  -- Check chained buffs
  if (defBuff and buffC and #buffC > 1) then
    local t = B[CS()].Order;
    if (t and #t > 1) then
      for i = 1, #t, 1 do
        if (t[i] and tfind(buffC, t[i])) then
          v = GetBuffSettings(t[i]);
          if (v and v.EnableS) then
            local b, tl, im = SMARTBUFF_CheckBuff(unit, t[i]);
            if (b and im) then
              if (SMARTBUFF_CheckBuffLink(unit, t[i], v.Type, v.Links)) then
                return nil, i, defBuff, tl, -1;
              end
            elseif (not b and t[i] == defBuff) then
              return defBuff, nil, nil, nil, nil;
            end
          end
        end
      end
    end
  end
  
  -- Check default buff
  if (defBuff) then
    buff, icon, count, _, duration, timeleft, caster = UnitBuffByBuffName(unit, defBuff);
    if (buff) then
--	  print("Found buff:  "..buff.. " on unit: "..unit)
      timeleft = timeleft - time;
      if (SMARTBUFF_IsPlayer(caster)) then
        SMARTBUFF_UpdateBuffDuration(defBuff, duration);
      end
      SMARTBUFF_AddMsgD("Default buff found: "..buff..", "..timeleft..", "..icon);
      return nil, 0, defBuff, timeleft, count;
	else
--		print("Not Found Buff:  "..defBuff.. " on unit: "..unit)	
    end
  end  

  -- Buff not found, return default buff
  return defBuff, nil, nil, nil, nil;

end


-- Will return the lower Id of the spell, if the unit level is lower
function SMARTBUFF_CheckUnitLevel(unit, spellId, spellLevels)
  if (spellLevels == nil or spellId == nil) then
    return spellId;
  end

  local Id = spellId;
  local uLevel = UnitLevel(unit);  
  local spellName, _, icon, castTime, minRange, maxRange = GetSpellInfo(Id);
  local sRank = GetSpellSubtext(Id);
  if (sRank == nil or sRank == "") then
    return Id;
  end
  
  local _, _, spellRank = string.find(sRank, "(%d+)");
  if (spellRank == nil) then
    return Id;
  end  
  
  spellRank = tonumber(spellRank);
  local i = spellRank;
  
  --SMARTBUFF_AddMsgD(spellName .. sRank .. ":" .. spellRank .. ", " .. spellLevels[i]);

  while (i >= 1) do
    if (uLevel >= (spellLevels[i] - 10)) then
      break;
    end
    i = i - 1;
  end
  
  if (i == spellRank) then
    return Id;
  end
  
  local rankText;
  if (i > 0) then
    local n = spellRank - i;
    Id = Id - n;
    rankText = "("..string.gsub(sRank, "(%d+)", n)..")";
    --SMARTBUFF_AddMsgD(uLevel .. " " .. spellName .. " Rank " .. i .. " - ID = " .. Id);
  else
    Id = nil;
    --SMARTBUFF_AddMsgD(spellName .. ": no rank available for this level");
  end;
  
  return Id, i, rankText;
end
-- END SMARTBUFF_CheckUnitLevel



function SMARTBUFF_CheckBuffLink(unit, defBuff, buffT, buffL)
  -- Check linked buffs
  if (buffL) then
    if (not O.LinkSelfBuffCheck and buffT == SMARTBUFF_CONST_SELF) then
      -- Do not check linked self buffs
    elseif (not O.LinkGrpBuffCheck and buffT == SMARTBUFF_CONST_GROUP) then
      -- Do not check linked group buffs
    else
      for n, v in pairs(buffL) do
        if (v and v ~= defBuff) then
          SMARTBUFF_AddMsgD("Check linked buff ("..uname.."): "..v);
          buff, icon, count, _, duration, timeleft, caster = UnitBuffByBuffName(unit, v);
          if (buff) then
            timeleft = timeleft - time;
            SMARTBUFF_AddMsgD("Linked buff found: "..buff..", "..timeleft..", "..icon);
            return nil, n, defBuff, timeleft, count;
          end
        end
      end
    end
  end
  return defBuff;
end

function SMARTBUFF_CheckBuffChain(unit, buff, chain)
  local i;
  if (buff and chain and #chain > 1) then
    local t = B[CS()].Order;
    if (t and #t > 1) then
      SMARTBUFF_AddMsgD("Check chained buff: "..buff);
      for i = 1, #t, 1 do
        if (t[i] and t[i] ~= buff and tfind(chain, t[i])) then
          local b, tl, im = SMARTBUFF_CheckBuff(unit, t[i], true);
          if (b and im) then
            SMARTBUFF_AddMsgD("Chained buff found: "..t[i]);
            return nil, i, buff, tl, -1;
          end
        end
      end
    end
  end
  return buff;
end


function SMARTBUFF_UpdateBuffDuration(buff, duration)
  local i = cBuffIndex[buff];
  if (i ~= nil and cBuffs[i] ~= nil and buff == cBuffs[i].BuffS) then
    if (cBuffs[i].DurationS ~= nil and cBuffs[i].DurationS > 0 and cBuffs[i].DurationS ~= duration) then
      SMARTBUFF_AddMsgD("Updated buff duration: "..buff.." = "..duration.."sec, old = "..cBuffs[i].DurationS);
      cBuffs[i].DurationS = duration;      
    end
  end
end


function UnitAuraBySpellName(target, spellname, filter)
  for i = 1,40 do
    name = UnitAura(target, i, filter);
    if not name then return end
    if name == spellname then
      return UnitAuraFull(target, i, filter);
    end
  end
end

function SMARTBUFF_CheckBuff(unit, buffName, isMine) 
  if (not unit or not buffName) then
    return false, 0;
  end
  local buff, _, _, _, _, timeleft, caster = UnitAuraBySpellName(unit, buffName, "HELPFUL");
  if (buff) then
    SMARTBUFF_AddMsgD(UnitName(unit).." buff found: "..buff, 0, 1, 0.5);
    if (buff == buffName) then
      timeleft = timeleft - GetTime();
      if (isMine and caster) then
        if (SMARTBUFF_IsPlayer(caster)) then
          return true, timeleft, caster;
        end
        return false, 0, nil;
      end
      return true, timeleft, SMARTBUFF_IsPlayer(caster);
    end
  end
  return false, 0;
end
-- END SMARTBUFF_CheckUnitBuffs


-- Will return the name/description of the buff 
function SMARTBUFF_GetBuffName(unit, buffIndex, line)
  local i = buffIndex;
  local name = nil;
  if (i < 0 or i > maxBuffs) then
    return nil;
  end    
  --SmartBuffTooltip:SetOwner(SmartBuffFrame, "ANCHOR_NONE");
  SmartBuffTooltip:ClearLines();
  SmartBuffTooltip:SetUnitBuff(unit, i);
  local obj = _G["SmartBuffTooltipTextLeft" .. line];
  if (obj) then
    name = obj:GetText();
  end
  return name;
end
-- END SMARTBUFF_GetBuffName


-- IsFeignDeath(unit)
function SMARTBUFF_IsFeignDeath(unit)
  return UnitIsFeignDeath(unit);
end
-- END SMARTBUFF_IsFeignDeath


-- IsPicnic(unit)
function SMARTBUFF_IsPicnic(unit)
  if (not SMARTBUFF_CheckUnitBuffs(unit, SMARTBUFF_FOOD_SPELL, SMARTBUFF_CONST_FOOD, {SMARTBUFF_FOOD_SPELL, SMARTBUFF_DRINK_SPELL})) then
    return true;
  end
  return false;
end
-- END SMARTBUFF_IsPicnic


-- IsFishing(unit)
function SMARTBUFF_IsFishing(unit)
  -- spell, rank, displayName, icon, startTime, endTime, isTradeSkill = UnitChannelInfo("unit")
  local spell = UnitChannelInfo(unit);
  if (spell ~= nil and SMARTBUFF_FISHING ~= nil and spell == SMARTBUFF_FISHING) then
    --SMARTBUFF_AddMsgD("Channeling "..SMARTBUFF_FISHING);
    return true;
  end
  return false;
end

function SMARTBUFF_IsFishingPoleEquiped()
  if (not SG or not SG.FishingPole) then return false end
  
  local link = GetInventoryItemLink("player", GetInventorySlotInfo("MainHandSlot"));
  if (not link) then return false end
  
  local _, _, _, _, _, _, subType = GetItemInfo(link);
  if (not subType) then return false end
  
  --print(SG.FishingPole.." - "..subType);
  if (SG.FishingPole == subType) then return true end
  
  return false;
end
-- END SMARTBUFF_IsFishing

-- SMARTBUFF_IsSpell(sType)
function SMARTBUFF_IsSpell(sType)
  return sType == SMARTBUFF_CONST_GROUP or sType == SMARTBUFF_CONST_GROUPALL or sType == SMARTBUFF_CONST_SELF or sType == SMARTBUFF_CONST_FORCESELF or sType == SMARTBUFF_CONST_WEAPON or sType == SMARTBUFF_CONST_STANCE or sType == SMARTBUFF_CONST_ITEM;
end
-- END SMARTBUFF_IsSpell

-- SMARTBUFF_IsItem(sType)
function SMARTBUFF_IsItem(sType)
  return sType == SMARTBUFF_CONST_INV or sType == SMARTBUFF_CONST_FOOD or sType == SMARTBUFF_CONST_SCROLL or sType == SMARTBUFF_CONST_POTION or sType == SMARTBUFF_CONST_ITEMGROUP;
end
-- END SMARTBUFF_IsItem


-- Loops through all of the debuffs currently active looking for a texture string match
function SMARTBUFF_IsDebuffTexture(unit, debufftex)
  local active = false;
  local i = 1;
  local name, icon;
  -- name,rank,icon,count,type = UnitDebuff("unit", id or "name"[,"rank"])
  while (UnitDebuff(unit, i)) do
    name, icon, _, _ = UnitDebuff(unit, i);
    --SMARTBUFF_AddMsgD(i .. ". " .. name .. ", " .. icon);  
    if (string.find(icon, debufftex)) then
      active = true;
      break
    end
    i = i + 1;
  end
  return active;
end
-- END SMARTASPECT_IsDebuffTex


-- Returns the number of a reagent currently in player's bag
function SMARTBUFF_CountReagent(reagent, chain)
  if (reagent == nil) then
    return -1, nil;
  end
  
  local toy = SG.Toybox[reagent];
  if (toy) then
    return 1, toy[1];
  end

  local n = 0;
  local id = nil;
  local bag = 0;
  local slot = 0;
  local itemLink, itemName, count;
  if (chain == nil) then chain = { reagent }; end
  for bag = 0, NUM_BAG_FRAMES do
    for slot = 1, C_Container.GetContainerNumSlots(bag) do
      itemLink = C_Container.GetContainerItemLink(bag, slot); 
      if (itemLink ~= nil) then
        itemName = string.match(itemLink, "%[.-%]");
        --print(bag, slot, itemName);
        for i = 1, #chain, 1 do
          --print(chain[i]);
          if (chain[i] and string.find(itemName, chain[i], 1, true)) then
          --if (chain[i] and string.find(itemLink, "["..chain[i].."]", 1, true)) then
            --print("Item found: "..chain[i]);
            _, count = C_Container.GetContainerItemInfo(bag, slot);
            id = C_Container.GetContainerItemID(bag, slot);
            n = n + count;
          end
        end
      end
    end
  end
  return n, id;
end

function SMARTBUFF_FindItem(reagent, chain)
  if (reagent == nil) then
    return nil, nil, -1, nil;
  end
    
  local n = 0;
  local bag = 0;
  local slot = 0;
  local itemsInfo;
  local itemLink, itemName, texture, count;
  if (chain == nil) then chain = { reagent }; end

  for bag = 0, NUM_BAG_FRAMES do
    for slot = 1, C_Container.GetContainerNumSlots(bag) do
      itemLink = C_Container.GetContainerItemLink(bag, slot);
      if (itemLink ~= nil) then
        itemName = string.match(itemLink, "%[.-%]");
        for i = 1, #chain, 1 do
          if (chain[i] and string.find(itemLink, "["..chain[i].."]", 1, true)) then
            -- itemInfo now returns a table, thanks bliz  :)
            itemsInfo = C_Container.GetContainerItemInfo(bag, slot);
            if itemsInfo then
                return bag, slot, itemsInfo.stackCount, texture;
			else
			    return nil, nil, 0, nil;
			end
          end
        end
      end
    end
  end
  return nil, nil, 0, nil;
end
-- END Reagent functions


---------------------------------------------------------------------------------------------------
-- check the current zone and set buff template
---------------------------------------------------------------------------------------------------
function SMARTBUFF_CheckLocation()
  if (not O.AutoSwitchTemplate and not O.AutoSwitchTemplateInst) then return; end  
  
  local zone = GetRealZoneText();  
  if (zone == nil) then
    SMARTBUFF_AddMsgD("No zone found, try again...");
    tStartZone = GetTime();
    isSetZone = true;
    return;
  end

  isSetZone = false;
  local tmp = nil;
  local b = false;
  
  SMARTBUFF_AddMsgD("Current zone: "..zone..", last zone: "..sLastZone);
  if (zone ~= sLastZone) then
    sLastZone = zone;
    if (IsActiveBattlefieldArena()) then
      tmp = SMARTBUFF_TEMPLATES[5];
    elseif (SMARTBUFF_IsActiveBattlefield(zone) == 1) then
      tmp = SMARTBUFF_TEMPLATES[4];
    else
      if (O.AutoSwitchTemplateInst) then
        local i = 1;
        for _ in pairs(SMARTBUFF_INSTANCES) do
          if (string.find(string.lower(zone), string.lower(SMARTBUFF_INSTANCES[i]))) then
            b = true;
            break;
          end
          i = i + 1;
        end
        tmp = nil;
        if (b) then
          if (SMARTBUFF_TEMPLATES[i + 5] ~= nil) then
            tmp = SMARTBUFF_TEMPLATES[i + 5]
          end
        end
      end
    end    
    --SMARTBUFF_AddMsgD("Current tmpl: " .. currentTemplate .. " - new tmpl: " .. tmp);
    if (tmp and currentTemplate ~= tmp) then
      SMARTBUFF_AddMsg(SMARTBUFF_OFT_AUTOSWITCHTMP .. ": " .. currentTemplate .. " -> " .. tmp);
      currentTemplate = tmp;
      SMARTBUFF_SetBuffs();
    end
  end  
end



-- checks if the player is inside a battlefield
function SMARTBUFF_IsActiveBattlefield(zone)
  local i, status, map, instanceId, teamSize;
  for i = 1, GetMaxBattlefieldID() do
    status, map, instanceId, _, _, teamSize = GetBattlefieldStatus(i);
    if (status and status ~= "none") then
      SMARTBUFF_AddMsgD("Battlefield status = "..ChkS(status)..", Id = "..ChkS(instanceId)..", TS = "..ChkS(teamSize)..", Map = "..ChkS(map)..", Zone = "..ChkS(zone));
    else
      SMARTBUFF_AddMsgD("Battlefield status = none");
    end
    if (status and status == "active" and map) then
      if (teamSize and type(teamSize) == "number" and teamSize > 0) then
        return 2;      
      end
      return 1;
    end
  end
  return 0;
end
-- END IsActiveBattlefield


-- Helper functions ---------------------------------------------------------------------------------------
function SMARTBUFF_toggleBool(b, msg)
  if (not b or b == nil) then
    b = true;
    SMARTBUFF_AddMsg(SMARTBUFF_TITLE .. ": " .. msg .. GR .. "On", true);
  else
    b = false
    SMARTBUFF_AddMsg(SMARTBUFF_TITLE .. ": " .. msg .. RD .."Off", true);
  end
  return b;
end

function SMARTBUFF_BoolState(b, msg)
  if (b) then
    SMARTBUFF_AddMsg(SMARTBUFF_TITLE .. ": " .. msg .. GR .. "On", true);
  else
    SMARTBUFF_AddMsg(SMARTBUFF_TITLE .. ": " .. msg .. RD .."Off", true);
  end
end

function SMARTBUFF_Split(msg, char)
  local arr = { };
  while (string.find(msg, char)) do
    local iStart, iEnd = string.find(msg, char);
    tinsert(arr, strsub(msg, 1, iStart - 1));
    msg = strsub(msg, iEnd + 1, strlen(msg));
  end
  if (strlen(msg) > 0) then
    tinsert(arr, msg);
  end
  return arr;
end
-- END Bool helper functions


-- Init the SmartBuff variables ---------------------------------------------------------------------------------------
function SMARTBUFF_Options_Init(self)
  if (isInit) then return; end

  self:UnregisterEvent("CHAT_MSG_CHANNEL");
  self:UnregisterEvent("UPDATE_MOUSEOVER_UNIT");
  
  --DebugChatFrame:AddMessage("Starting init SB");
  
  _, sPlayerClass = UnitClass("player");
  sRealmName = GetRealmName();
  sPlayerName = UnitName("player");
  sID = sRealmName .. ":" .. sPlayerName;
  --AutoSelfCast = GetCVar("autoSelfCast");
  
  SMARTBUFF_PLAYERCLASS = sPlayerClass;
    
  if (not SMARTBUFF_Buffs) then SMARTBUFF_Buffs = { }; end
  B = SMARTBUFF_Buffs;
  if (not SMARTBUFF_Options) then SMARTBUFF_Options = { }; end
  O = SMARTBUFF_Options;
  
  SMARTBUFF_BROKER_SetIcon();	-- bug fix, credit: SunNova

  if (O.Toggle == nil) then O.Toggle = true; end  
  if (O.ToggleAuto == nil) then O.ToggleAuto = true; end
  if (O.AutoTimer == nil) then O.AutoTimer = 5; end
  if (O.BlacklistTimer == nil) then O.BlacklistTimer = 5; end
  if (O.ToggleAutoCombat == nil) then O.ToggleAutoCombat = false; end
  if (O.ToggleAutoChat == nil) then O.ToggleAutoChat = false; end
  if (O.ToggleAutoSplash == nil) then O.ToggleAutoSplash = true; end
  if (O.ToggleAutoSound == nil) then O.ToggleAutoSound = true; end
  if (O.AutoSoundSelection == nil) then O.AutoSoundSelection = 1; end;
  if (O.CheckCharges == nil) then O.CheckCharges = true; end
  --if (O.ToggleAutoRest == nil) then  O.ToggleAutoRest = true; end
  if (O.RebuffTimer == nil) then O.RebuffTimer = 20; end
  if (O.SplashDuration == nil) then O.SplashDuration = 2; end
  if (O.SplashIconSize == nil) then O.SplashIconSize = 12; end
  
  if (O.BuffTarget == nil) then O.BuffTarget = false; end
  if (O.BuffPvP == nil) then O.BuffPvP = false; end
  if (O.BuffInCities == nil) then O.BuffInCities = true; end
  if (O.LinkSelfBuffCheck == nil) then O.LinkSelfBuffCheck = true; end
  if (O.LinkGrpBuffCheck == nil) then O.LinkGrpBuffCheck = true; end
  if (O.AntiDaze == nil) then O.AntiDaze = true; end
  
  if (O.ScrollWheel ~= nil and O.ScrollWheelUp == nil) then O.ScrollWheelUp = O.ScrollWheel; end
  if (O.ScrollWheel ~= nil and O.ScrollWheelDown == nil) then O.ScrollWheelDown = O.ScrollWheel; end
  if (O.ScrollWheelUp == nil) then O.ScrollWheelUp = true; end
  if (O.ScrollWheelDown == nil) then O.ScrollWheelDown = true; end
  
  if (O.InCombat == nil) then O.InCombat = true; end
  if (O.AutoSwitchTemplate == nil) then O.AutoSwitchTemplate = true; end
  if (O.AutoSwitchTemplateInst == nil) then O.AutoSwitchTemplateInst = true; end
  if (O.InShapeshift == nil) then O.InShapeshift = true; end
  if (O.WarnWhileMounted == nil) then O.WarnWhileMounted = false; end

  if (O.ToggleGrp == nil) then O.ToggleGrp = {true, true, true, true, true, true, true, true}; end
  if (O.ToggleSubGrpChanged == nil) then  O.ToggleSubGrpChanged = false; end  
  
  if (O.ToggleMsgNormal == nil) then O.ToggleMsgNormal = false; end
  if (O.ToggleMsgWarning == nil) then O.ToggleMsgWarning = false; end
  if (O.ToggleMsgError == nil) then O.ToggleMsgError = false; end
  
  if (O.HideMmButton == nil) then  O.HideMmButton = false; end
  if (O.HideSAButton == nil) then  O.HideSAButton = false; end
  
  if (O.MinCharges == nil) then  
    if (sPlayerClass == "SHAMAN" or sPlayerClass == "PRIEST") then
      O.MinCharges = 1;
    else
      O.MinCharges = 3;
    end
  end
  
  if (O.ShowMiniGrp == nil) then
    if (sPlayerClass == "DRUID" or sPlayerClass == "MAGE" or sPlayerClass == "PRIEST") then
      O.ShowMiniGrp = true;
    else
      O.ShowMiniGrp = false;
    end
  end  
  
  if (not O.AddList) then O.AddList = { }; end
  if (not O.IgnoreList) then O.IgnoreList = { }; end
  
  if (O.LastTemplate == nil) then  O.LastTemplate = SMARTBUFF_TEMPLATES[1]; end
  local b = false;
  while (SMARTBUFF_TEMPLATES[i] ~= nil) do
    if (SMARTBUFF_TEMPLATES[i] == O.LastTemplate) then
      b = true;
      break;
    end
    i = i + 1;
  end
  if (not b) then 
    O.LastTemplate = SMARTBUFF_TEMPLATES[1];
  end 
  
  currentTemplate = O.LastTemplate;
  --currentSpec = GetSpecialization();  
  currentSpec = 1;  
   
  if (O.OldWheelUp == nil) then O.OldWheelUp = ""; end
  if (O.OldWheelDown == nil) then O.OldWheelDown = ""; end
  
  SMARTBUFF_InitActionButtonPos();
  
  if (O.SplashX == nil) then O.SplashX = 100; end
  if (O.SplashY == nil) then O.SplashY = -100; end
  if (O.CurrentFont == nil) then O.CurrentFont = 9; end
  if (O.ColSplashFont == nil) then
    O.ColSplashFont = { };
    O.ColSplashFont.r = 1.0;
    O.ColSplashFont.g = 1.0;
    O.ColSplashFont.b = 1.0;                
  end
  iCurrentFont = O.CurrentFont;
    
  if (O.Debug == nil) then O.Debug = false; end
  
  -- Cosmos support
  if(EarthFeature_AddButton) then 
    EarthFeature_AddButton(
      { id = SMARTBUFF_TITLE;
        name = SMARTBUFF_TITLE;
        subtext = SMARTBUFF_TITLE;
        tooltip = "";      
        icon = imgSB;
        callback = SMARTBUFF_OptionsFrame_Toggle;
        test = nil;
      } )
  elseif (Cosmos_RegisterButton) then
    Cosmos_RegisterButton(SMARTBUFF_TITLE, SMARTBUFF_TITLE, SMARTBUFF_TITLE, imgSB, SMARTBUFF_OptionsFrame_Toggle);
  end

  if (IsAddOnLoaded("Parrot")) then
    isParrot = true;    
  end
    
  SMARTBUFF_FindItem("ScanBagsForSBInit");  
    
  DEFAULT_CHAT_FRAME:AddMessage("|cff00e0ff"..SMARTBUFF_VERS_TITLE .. "|cffffffff " .. SMARTBUFF_MSG_LOADED.."|cffFFFF00  /sbm - |cffffffff"..SMARTBUFF_OFT_MENU);
  isInit = true;
  
  SMARTBUFF_CheckMiniMapButton();
  SMARTBUFF_MinimapButton_OnUpdate(SmartBuff_MiniMapButton);
  SMARTBUFF_ShowSAButton();
  SMARTBUFF_Splash_Hide();
  
  if (O.UpgradeToDualSpec == nil) then
    for n = 1, GetNumSpecGroups(), 1 do
      if (B[n] == nil) then
        B[n] = { };
      end
      for k, v in pairs(SMARTBUFF_TEMPLATES) do
        SMARTBUFF_AddMsgD(v);
        if (B[v] ~= nil) then
          B[n][v] = B[v];
        end
      end
    end
    for k, v in pairs(SMARTBUFF_TEMPLATES) do
      if (B[v] ~= nil) then
        wipe(B[v]);
        B[v] = nil;
      end
    end
    O.UpgradeToDualSpec = true;
    SMARTBUFF_AddMsg("Upgraded to dual spec", true);    
  end
  
  for k, v in pairs(cClasses) do
    if (SMARTBUFF_CLASSES[k] == nil) then
      SMARTBUFF_CLASSES[k] = v;
    end
  end
  
  if (O.VersionNr == nil or O.VersionNr < SMARTBUFF_VERSIONNR) then
    O.VersionNr = SMARTBUFF_VERSIONNR;
    SMARTBUFF_SetBuffs();
    InitBuffOrder(true);
    --print("Upgrade SmartBuff to "..SMARTBUFF_VERSION);
  end
  
  if (SMARTBUFF_OptionsGlobal == nil) then SMARTBUFF_OptionsGlobal = { }; end
  OG = SMARTBUFF_OptionsGlobal;
  if (OG.SplashIcon == nil) then OG.SplashIcon = true; end
  if (OG.SplashMsgShort == nil) then OG.SplashMsgShort = false; end
  if (OG.FirstStart == nil) then OG.FirstStart = "V0";  end
  
  SMARTBUFF_Splash_ChangeFont(0);
  if (OG.FirstStart ~= SMARTBUFF_VERSION) then
    OG.FirstStart = SMARTBUFF_VERSION;
    SMARTBUFF_OptionsFrame_Open(true);
    
    if (OG.Tutorial == nil) then
      OG.Tutorial = SMARTBUFF_VERSIONNR;
      SMARTBUFF_ToggleTutorial();
    end
    
    SmartBuffWNF_lblText:SetText(SMARTBUFF_WHATSNEW);
    SmartBuffWNF:Show();    
  else
    SMARTBUFF_SetBuffs();
  end

  if (not IsVisibleToPlayer(SmartBuff_KeyButton)) then
    SmartBuff_KeyButton:ClearAllPoints();
    SmartBuff_KeyButton:SetPoint("CENTER", UIParent, "CENTER", 0, 100);
  end
  
  SMARTBUFF_SetUnits();
  SMARTBUFF_RebindKeys();
  isSyncReq = true;

  -- finally, client version check
  if wowTOC > SMARTBUFF_VERSIONNR or wowTOC < SMARTBUFF_VERSIONMIN then
	  DEFAULT_CHAT_FRAME:AddMessage("|cff00e0ffSmartbuff : |cffff6060This version was NOT intended for client version ("..wowTOC..") - you may encounter lua errors or other issues so please check for an update! - Join Discord for all the latest information at |cffFFFF00https://discord.gg/R6EkZ94TKK.")
  end

end
-- END SMARTBUFF_Options_Init

function SMARTBUFF_InitActionButtonPos()  
  if (InCombatLockdown()) then return end
  
  isInitBtn = true;
  if (O.ActionBtnX == nil) then
    SMARTBUFF_SetButtonPos(SmartBuff_KeyButton);
  else
    SmartBuff_KeyButton:ClearAllPoints();
    SmartBuff_KeyButton:SetPoint("TOPLEFT", UIParent, "TOPLEFT", O.ActionBtnX, O.ActionBtnY);
  end
  --print(format("x = %.0f, y = %.0f", O.ActionBtnX, O.ActionBtnY));
end

function SMARTBUFF_ResetAll()  
  wipe(SMARTBUFF_Buffs);
  wipe(SMARTBUFF_Options);
  ReloadUI();
end

function SMARTBUFF_SetButtonPos(self)
  local x, y = self:GetLeft(), self:GetTop() - UIParent:GetHeight();
  O.ActionBtnX = x;
  O.ActionBtnY = y;
  --print(format("x = %.0f, y = %.0f", x, y));
end

function SMARTBUFF_RebindKeys()
  local i;
  isRebinding = true;
  for i = 1, GetNumBindings(), 1 do
    local s = "";
    local command, key1, key2 = GetBinding(i);
    
    --if (command and key1) then
    --  SMARTBUFF_AddMsgD(i .. " = " .. command .. " - " .. key1;
    --end
    
    if (key1 and key1 == "MOUSEWHEELUP" and command ~= "SmartBuff_KeyButton") then
      O.OldWheelUp = command;
      --SMARTBUFF_AddMsgD("Old wheel up: " .. command);
    elseif (key1 and key1 == "MOUSEWHEELDOWN" and command ~= "SmartBuff_KeyButton") then
      O.OldWheelDown = command;
      --SMARTBUFF_AddMsgD("Old wheel down: " .. command);
    end  
    
    if (command and command == "SMARTBUFF_BIND_TRIGGER") then
      --s = i .. " = " .. command;
      if (key1) then
        --s = s .. ", key1 = " .. key1 .. " rebound";
        SetBindingClick(key1, "SmartBuff_KeyButton");
      end
      if (key2) then
        --s = s .. ", key2 = " .. key2 .. " rebound";
        SetBindingClick(key2, "SmartBuff_KeyButton");
      end
      --SMARTBUFF_AddMsgD(s);
      break;
    end
  end
  
  if (O.ScrollWheelUp) then
    isKeyUpChanged = true;
    SetOverrideBindingClick(SmartBuffFrame, false, "MOUSEWHEELUP", "SmartBuff_KeyButton", "MOUSEWHEELUP");
    --SMARTBUFF_AddMsgD("Set wheel up");
  else
    if (isKeyUpChanged) then
      isKeyUpChanged = false;
      SetOverrideBinding(SmartBuffFrame, false, "MOUSEWHEELUP");
      --SMARTBUFF_AddMsgD("Set old wheel up: " .. O.OldWheelUp);
    end
  end
  
  if (O.ScrollWheelDown) then
    isKeyDownChanged = true;
    SetOverrideBindingClick(SmartBuffFrame, false, "MOUSEWHEELDOWN", "SmartBuff_KeyButton", "MOUSEWHEELDOWN");
    --SMARTBUFF_AddMsgD("Set wheel down");
  else
    if (isKeyDownChanged) then
      isKeyDownChanged = false;
      SetOverrideBinding(SmartBuffFrame, false, "MOUSEWHEELDOWN");
      --SMARTBUFF_AddMsgD("Set old wheel down: " .. O.OldWheelDown);
    end
  end
  isRebinding = false;
end

function SMARTBUFF_ResetBindings()
  if (not isRebinding) then
    isRebinding = true;
    if (O.OldWheelUp == "SmartBuff_KeyButton") then
      SetBinding("MOUSEWHEELUP", "CAMERAZOOMIN");
    else
      SetBinding("MOUSEWHEELUP", O.OldWheelUp);
    end
    if (O.OldWheelDown == "SmartBuff_KeyButton") then
      SetBinding("MOUSEWHEELDOWN", "CAMERAZOOMOUT");
    else
      SetBinding("MOUSEWHEELDOWN", O.OldWheelDown);
    end
    SaveBindings(GetCurrentBindingSet());
    SMARTBUFF_RebindKeys();
  end
end


-- SmartBuff commandline menu ---------------------------------------------------------------------------------------
function SMARTBUFF_command(msg)
  if (not isInit) then
    SMARTBUFF_AddMsgWarn(SMARTBUFF_VERS_TITLE.." not initialized correctly!", true);
    return;
  end
  
  if(msg == "toggle" or msg == "t") then
    SMARTBUFF_OToggle();
    SMARTBUFF_SetUnits();
  elseif (msg == "menu") then
    SMARTBUFF_OptionsFrame_Toggle();
  elseif (msg == "rbt") then
    SMARTBUFF_ResetBuffTimers();
  elseif (msg == "sbt") then
    SMARTBUFF_ShowBuffTimers();
  elseif (msg == "target") then
    if (SMARTBUFF_PreCheck(0)) then
      SMARTBUFF_checkBlacklist();
      SMARTBUFF_BuffUnit("target", 0, 0);
    end  
  elseif (msg == "debug") then
    O.Debug = SMARTBUFF_toggleBool(O.Debug, "Debug active = ");  
  elseif (msg == "open") then
    SMARTBUFF_OptionsFrame_Open(true);
  elseif (msg == "sync") then
    SMARTBUFF_SyncBuffTimers();
  elseif (msg == "rb") then
    SMARTBUFF_ResetBindings();
    SMARTBUFF_AddMsg("SmartBuff key and mouse bindings reset.", true);
  elseif (msg == "rafp") then
    SmartBuffSplashFrame:ClearAllPoints();
    SmartBuffSplashFrame:SetPoint("CENTER", UIParent, "CENTER");
    SmartBuff_MiniMapButton:ClearAllPoints();
    SmartBuff_MiniMapButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT");
    SmartBuff_KeyButton:ClearAllPoints();
    SmartBuff_KeyButton:SetPoint("CENTER", UIParent, "CENTER");
    SmartBuffOptionsFrame:ClearAllPoints();
    SmartBuffOptionsFrame:SetPoint("CENTER", UIParent, "CENTER");
    SmartBuff_MiniGroup:ClearAllPoints();
    SmartBuff_MiniGroup:SetPoint("CENTER", UIParent, "CENTER");
  elseif (msg == "tmg") then
    --SMARTBUFF_OToggleMiniGrp();
    O.ShowMiniGrp = SMARTBUFF_toggleBool(O.ShowMiniGrp, "MiniGrp active = ");
    SMARTBUFF_MiniGroup_Show();
    
  elseif (msg == "test") then
  
    -- Test Code ******************************************
    -- ****************************************************
  
    --SMARTBUFF_WEAPON_SHARP_PATTERN
    --Schwerer Gewichtsstein
    --Schwerer Wetzstein
    --local a, b = SMARTBUFF_CanApplyWeaponBuff("Schwerer Wetzstein", 16);
    --print(a);
    --print(b);
  
    --local spellname = "Mind--numbing Poison";
    --SMARTBUFF_AddMsg("Original: " .. spellname, true);
    --if (string.find(spellname, "%-%-") ~= nil) then
    --  spellname = string.gsub(spellname, "%-%-", "%-");
    --end
    --SMARTBUFF_AddMsg("Modified: " .. spellname, true);
    -- ****************************************************
    -- ****************************************************
    
  else
    --SMARTBUFF_Check(0);
    SMARTBUFF_AddMsg(SMARTBUFF_VERS_TITLE, true);
    SMARTBUFF_AddMsg("Syntax: /sbo [command] or /sbuff [command] or /smartbuff [command]", true);
    SMARTBUFF_AddMsg("toggle  -  " .. SMARTBUFF_OFT, true);
    SMARTBUFF_AddMsg("menu     -  " .. SMARTBUFF_OFT_MENU, true);
    SMARTBUFF_AddMsg("target  -  " .. SMARTBUFF_OFT_TARGET, true);
    SMARTBUFF_AddMsg("rbt      -  " .. "Reset buff timers", true);
    SMARTBUFF_AddMsg("sbt      -  " .. "Show buff timers", true);
    SMARTBUFF_AddMsg("rafp     -  " .. "Reset all frame positions", true);
    SMARTBUFF_AddMsg("sync     -  " .. "Sync buff timers with UI", true);
    SMARTBUFF_AddMsg("rb       -  " .. "Reset key/mouse bindings", true);
  end
end
-- END SMARTBUFF_command


-- SmartBuff options toggle ---------------------------------------------------------------------------------------
function SMARTBUFF_OToggle()
  if (not isInit) then return; end
  O.Toggle = SMARTBUFF_toggleBool(O.Toggle, "Active = ");
  SMARTBUFF_CheckMiniMapButton();
  if (O.Toggle) then
    SMARTBUFF_MiniGroup_Show();
    SMARTBUFF_SetUnits();
  else
    if (SmartBuff_MiniGroup:IsVisible()) then
      SmartBuff_MiniGroup:Hide();
    end
  end  
end

function SMARTBUFF_OToggleAuto()
  O.ToggleAuto = not O.ToggleAuto;
end
function SMARTBUFF_OToggleAutoCombat()
  O.ToggleAutoCombat = not O.ToggleAutoCombat;
end
function SMARTBUFF_OToggleAutoChat()
  O.ToggleAutoChat = not O.ToggleAutoChat;
end
function SMARTBUFF_OToggleAutoSplash()
  O.ToggleAutoSplash = not O.ToggleAutoSplash;
end
function SMARTBUFF_OToggleAutoSound()
  O.ToggleAutoSound = not O.ToggleAutoSound;
end

--function SMARTBUFF_OToggleCheckCharges()
--  O.ToggleCheckCharges = not O.ToggleCheckCharges;
--end
--function SMARTBUFF_OToggleAutoRest()
--  O.ToggleAutoRest = not O.ToggleAutoRest;
--end

function SMARTBUFF_OAutoSwitchTmp()
  O.AutoSwitchTemplate = not O.AutoSwitchTemplate;
end
function SMARTBUFF_OAutoSwitchTmpInst()
  O.AutoSwitchTemplateInst = not O.AutoSwitchTemplateInst;
end

function SMARTBUFF_OBuffTarget()
  O.BuffTarget = not O.BuffTarget;
end

function SMARTBUFF_OBuffPvP()
  O.BuffPvP = not O.BuffPvP;
end

function SMARTBUFF_OBuffInCities()
  O.BuffInCities = not O.BuffInCities;
end

function SMARTBUFF_OLinkSelfBuffCheck()
  O.LinkSelfBuffCheck = not O.LinkSelfBuffCheck;
end
function SMARTBUFF_OLinkGrpBuffCheck()
  O.LinkGrpBuffCheck = not O.LinkGrpBuffCheck;
end
function SMARTBUFF_OAntiDaze()
  O.AntiDaze = not O.AntiDaze;
end

function SMARTBUFF_OScrollWheelUp()
  O.ScrollWheelUp = not O.ScrollWheelUp;
  isKeyUpChanged = true;
end
function SMARTBUFF_OScrollWheelDown()
  O.ScrollWheelDown = not O.ScrollWheelDown;
  isKeyDownChanged = true;
end
function SMARTBUFF_OInShapeshift()
  O.InShapeshift = not O.InShapeshift;
end
function SMARTBUFF_OInCombat()
  O.InCombat = not O.InCombat;
end

function SMARTBUFF_OToggleGrp(i)
  O.ToggleGrp[i] = not O.ToggleGrp[i];
  if (SmartBuff_MiniGroup:IsVisible()) then
    SMARTBUFF_SetUnits();
  end
end
function SMARTBUFF_OToggleMiniGrp()
  O.ShowMiniGrp = not O.ShowMiniGrp;
end
function SMARTBUFF_OToggleSubGrpChanged()
  O.ToggleSubGrpChanged = not O.ToggleSubGrpChanged;
end

function SMARTBUFF_OToggleMsgNormal()
  O.ToggleMsgNormal = not O.ToggleMsgNormal;
end
function SMARTBUFF_OToggleMsgWarning()
  O.ToggleMsgWarning = not O.ToggleMsgWarning;
end
function SMARTBUFF_OToggleMsgError()
  O.ToggleMsgError = not O.ToggleMsgError;
end

function SMARTBUFF_OHideMmButton()
  O.HideMmButton = not O.HideMmButton;
  SMARTBUFF_CheckMiniMapButton();
end
function SMARTBUFF_OHideSAButton()
  O.HideSAButton = not O.HideSAButton;
  SMARTBUFF_ShowSAButton();
end
function SMARTBUFF_OSelfFirst()
  B[CS()][currentTemplate].SelfFirst = not B[CS()][currentTemplate].SelfFirst;
end
function SMARTBUFF_OWarnWhenMountedButton()
  O.WarnWhileMounted = not O.WarnWhileMounted;
end

function SMARTBUFF_OToggleBuff(s, i)
  local bs = GetBuffSettings(cBuffs[i].BuffS);
  if (bs == nil) then
    return;
  end    
  
  if (s == "S") then
    bs.EnableS = not bs.EnableS;
    if (bs.IDG ~= nil) then
      bs.EnableG = bs.EnableS;
    else
      bs.EnableG = false;
    end
    SMARTBUFF_AddMsgD("OToggleBuff = "..cBuffs[i].BuffS..", "..tostring(bs.EnableS)..", "..tostring(bs.EnableG));
  
    if (bs.EnableS) then
      SmartBuff_BuffSetup_Show(i);
    else
      SmartBuff_BuffSetup:Hide();
      iLastBuffSetup = -1;
      SmartBuff_PlayerSetup:Hide();
    end
  elseif (s == "G") then
    bs.EnableG = not bs.EnableG;
  end
  
end

function SMARTBUFF_OToggleDebug()
  O.Debug = not O.Debug;
end

function SMARTBUFF_OptionsFrame_Toggle()
  if (not isInit) then return; end
  
  if(SmartBuffOptionsFrame:IsVisible()) then
    if(iLastBuffSetup > 0) then
      SmartBuff_BuffSetup:Hide();
      iLastBuffSetup = -1;
      SmartBuff_PlayerSetup:Hide();
    end  
    SmartBuffOptionsFrame:Hide();
  else
    SmartBuffOptionsCredits_lblText:SetText(SMARTBUFF_CREDITS);
    SmartBuffOptionsFrame:Show();
    SmartBuff_PlayerSetup:Hide();
  end
  
  SMARTBUFF_MinimapButton_CheckPos();
end

function SMARTBUFF_OptionsFrame_Open(force)
  if (not isInit) then return; end
  if(not SmartBuffOptionsFrame:IsVisible() or force) then
    SmartBuffOptionsCredits_lblText:SetText(SMARTBUFF_CREDITS);
    SmartBuffOptionsFrame:Show();
  end
end

function SmartBuff_BuffSetup_Show(i)
  local icon1 = cBuffs[i].IconS;
  local icon2 = cBuffs[i].IconG;
  local name = cBuffs[i].BuffS;
  local btype = cBuffs[i].Type;
  local hidden = true;
  local n = 0;
  local bs = GetBuffSettings(name);

  if (name == nil or btype == SMARTBUFF_CONST_TRACK) then
    SmartBuff_BuffSetup:Hide();
    iLastBuffSetup = -1;
    SmartBuff_PlayerSetup:Hide();
    return;
  end
  
  if(SmartBuff_BuffSetup:IsVisible() and i == iLastBuffSetup) then
    SmartBuff_BuffSetup:Hide();
    iLastBuffSetup = -1;
    SmartBuff_PlayerSetup:Hide();
    return;
  else  
    if (btype == SMARTBUFF_CONST_GROUP or btype == SMARTBUFF_CONST_ITEMGROUP) then
      hidden = false;
    end
    
    if (icon2 and bs.EnableG) then
      SmartBuff_BuffSetup_BuffIcon2:SetNormalTexture(icon2);
      SmartBuff_BuffSetup_BuffIcon2:Show();
    else
      SmartBuff_BuffSetup_BuffIcon2:Hide();
    end
    if (icon1) then
      SmartBuff_BuffSetup_BuffIcon1:SetNormalTexture(icon1);
      if (icon2 and bs.EnableG) then
        SmartBuff_BuffSetup_BuffIcon1:SetPoint("TOPLEFT", 44, -30);
      else
        SmartBuff_BuffSetup_BuffIcon1:SetPoint("TOPLEFT", 64, -30);
      end
      SmartBuff_BuffSetup_BuffIcon1:Show();
    else
      SmartBuff_BuffSetup_BuffIcon1:SetPoint("TOPLEFT", 24, -30);
      SmartBuff_BuffSetup_BuffIcon1:Hide();
    end
    
    local obj = SmartBuff_BuffSetup_BuffText;
    if (name) then
      obj:SetText(name);
      --SMARTBUFF_AddMsgD(name);
    else
      obj:SetText("");
    end
    
    SmartBuff_BuffSetup_cbSelf:SetChecked(bs.SelfOnly);
    SmartBuff_BuffSetup_cbSelfNot:SetChecked(bs.SelfNot);
    SmartBuff_BuffSetup_cbCombatIn:SetChecked(bs.CIn);
    SmartBuff_BuffSetup_cbCombatOut:SetChecked(bs.COut);
    SmartBuff_BuffSetup_cbMH:SetChecked(bs.MH);
    SmartBuff_BuffSetup_cbOH:SetChecked(bs.OH);
    SmartBuff_BuffSetup_cbRH:SetChecked(bs.RH);
    SmartBuff_BuffSetup_cbReminder:SetChecked(bs.Reminder);
    SmartBuff_BuffSetup_txtManaLimit:SetNumber(bs.ManaLimit);
       
    --SMARTBUFF_AddMsgD("Test Buff setup show 1");    
    if (cBuffs[i].DurationS > 0) then
      SmartBuff_BuffSetup_RBTime:SetMinMaxValues(0, cBuffs[i].DurationS);
      _G[SmartBuff_BuffSetup_RBTime:GetName().."High"]:SetText(cBuffs[i].DurationS);
      if (cBuffs[i].DurationS <= 60) then
        SmartBuff_BuffSetup_RBTime:SetValueStep(1);
      elseif (cBuffs[i].DurationS <= 180) then
        SmartBuff_BuffSetup_RBTime:SetValueStep(5);
      elseif (cBuffs[i].DurationS <= 600) then
        SmartBuff_BuffSetup_RBTime:SetValueStep(10);
      else
        SmartBuff_BuffSetup_RBTime:SetValueStep(30);
      end
      SmartBuff_BuffSetup_RBTime:SetValue(bs.RBTime);
      _G[SmartBuff_BuffSetup_RBTime:GetName().."Text"]:SetText(bs.RBTime .. "\nsec");
      SmartBuff_BuffSetup_RBTime:Show();
    else
      SmartBuff_BuffSetup_RBTime:Hide();
    end
    --SMARTBUFF_AddMsgD("Test Buff setup show 2");
    
    SmartBuff_BuffSetup_txtManaLimit:Hide();
    if (cBuffs[i].Type == SMARTBUFF_CONST_INV or cBuffs[i].Type == SMARTBUFF_CONST_WEAPON) then
      SmartBuff_BuffSetup_cbMH:Show();
      SmartBuff_BuffSetup_cbOH:Show();
      SmartBuff_BuffSetup_cbRH:Hide();
    else
      SmartBuff_BuffSetup_cbMH:Hide();
      SmartBuff_BuffSetup_cbOH:Hide();
      SmartBuff_BuffSetup_cbRH:Hide();
      if (cBuffs[i].Type ~= SMARTBUFF_CONST_FOOD and cBuffs[i].Type ~= SMARTBUFF_CONST_SCROLL and cBuffs[i].Type ~= SMARTBUFF_CONST_POTION) then
        SmartBuff_BuffSetup_txtManaLimit:Show();
        --SMARTBUFF_AddMsgD("Show ManaLimit");
      end
    end
    
    if (cBuffs[i].Type == SMARTBUFF_CONST_GROUP or cBuffs[i].Type == SMARTBUFF_CONST_ITEMGROUP) then
      SmartBuff_BuffSetup_cbSelf:Show();
      SmartBuff_BuffSetup_cbSelfNot:Show();
      SmartBuff_BuffSetup_btnPriorityList:Show();
      SmartBuff_BuffSetup_btnIgnoreList:Show();    
    else
      SmartBuff_BuffSetup_cbSelf:Hide();
      SmartBuff_BuffSetup_cbSelfNot:Hide();
      SmartBuff_BuffSetup_btnPriorityList:Hide();
      SmartBuff_BuffSetup_btnIgnoreList:Hide();
      SmartBuff_PlayerSetup:Hide();
    end
  
    local cb = nil;
    local btn = nil;
    n = 0;
    --SMARTBUFF_AddMsgD("Test Buff setup show 3");
    for _ in pairs(cClasses) do
      n = n + 1;
      cb = _G["SmartBuff_BuffSetup_cbClass"..n];
      btn = _G["SmartBuff_BuffSetup_ClassIcon"..n];
      if (hidden or tcontains(cIgnoreClasses, n)) then
        cb:Hide();
        btn:Hide();
      else
        cb:SetChecked(bs[cClasses[n]]);
        cb:Show();
        btn:Show();
      end
    end
    iLastBuffSetup = i;
    --SMARTBUFF_AddMsgD("Test Buff setup show 4");
    SmartBuff_BuffSetup:Show();
    
    if (SmartBuff_PlayerSetup:IsVisible()) then
      SmartBuff_PS_Show(iCurrentList);
    end
  end  
end

function SmartBuff_BuffSetup_ManaLimitChanged(self)
  local i = iLastBuffSetup;
  if (i <= 0) then
    return;
  end
  local ct = currentTemplate;
  local name = cBuffs[i].BuffS;
  B[CS()][ct][name].ManaLimit = self:GetNumber();
end

function SmartBuff_BuffSetup_OnClick()
  local i = iLastBuffSetup;
  local ct = currentTemplate;
  if (i <= 0) then
    return;
  end
  local name = cBuffs[i].BuffS;
  local cBuff = GetBuffSettings(name);
 
  cBuff.SelfOnly = SmartBuff_BuffSetup_cbSelf:GetChecked();
  cBuff.SelfNot = SmartBuff_BuffSetup_cbSelfNot:GetChecked();
  cBuff.CIn  = SmartBuff_BuffSetup_cbCombatIn:GetChecked();
  cBuff.COut = SmartBuff_BuffSetup_cbCombatOut:GetChecked();
  cBuff.MH = SmartBuff_BuffSetup_cbMH:GetChecked();
  cBuff.OH = SmartBuff_BuffSetup_cbOH:GetChecked();
  cBuff.RH = SmartBuff_BuffSetup_cbRH:GetChecked();
  cBuff.Reminder = SmartBuff_BuffSetup_cbReminder:GetChecked();
  
  cBuff.RBTime = SmartBuff_BuffSetup_RBTime:GetValue();
  _G[SmartBuff_BuffSetup_RBTime:GetName().."Text"]:SetText(cBuff.RBTime .. "\nsec");
  
  if (cBuffs[i].Type == SMARTBUFF_CONST_GROUP or cBuffs[i].Type == SMARTBUFF_CONST_ITEMGROUP) then
    local n = 0;
    local cb = nil;
    for _ in pairs(cClasses) do
      n = n + 1;
      cb = _G["SmartBuff_BuffSetup_cbClass"..n];
      if (tcontains(cIgnoreClasses, n)) then
        cBuff[cClasses[n]] = false;
      else
        cBuff[cClasses[n]] = cb:GetChecked();
      end
    end
  end
  --SMARTBUFF_AddMsgD("Buff setup saved");
end

function SmartBuff_BuffSetup_ToolTip(mode)
  local i = iLastBuffSetup;
  if (i <= 0) then
    return;
  end
  local ids = cBuffs[i].IDS;
  local idg = cBuffs[i].IDG;
  local btype = cBuffs[i].Type
  
  GameTooltip:ClearLines();
  if (SMARTBUFF_IsItem(btype)) then
    local bag, slot, count, texture = SMARTBUFF_FindItem(cBuffs[i].BuffS, cBuffs[i].Chain);
    if (bag and slot) then
      if (bag == 999) then -- Toy
        GameTooltip:SetToyByItemID(slot);
      else
        GameTooltip:SetBagItem(bag, slot);
      end
    end
  else
    if (mode == 1 and ids) then
      GameTooltip:SetHyperlink("spell:" .. ids);
    elseif (mode == 2 and idg) then
      GameTooltip:SetHyperlink("spell:" .. idg);
    end
  end
  GameTooltip:Show();
end
-- END SmartBuff options toggle


-- Options frame functions ---------------------------------------------------------------------------------------
function SMARTBUFF_Options_OnLoad(self)
end

function SMARTBUFF_Options_OnShow()
  -- Check if the options frame is out of screen area
  local top    = GetScreenHeight() - math.abs(SmartBuffOptionsFrame:GetTop());
  local bottom = GetScreenHeight() - math.abs(SmartBuffOptionsFrame:GetBottom());
  local left   = SmartBuffOptionsFrame:GetLeft();
  local right  = SmartBuffOptionsFrame:GetRight();
  
  --SMARTBUFF_AddMsgD("X: " .. GetScreenWidth() .. ", " .. left .. ", " .. right);
  --SMARTBUFF_AddMsgD("Y: " .. GetScreenHeight() .. ", " .. top .. ", " .. bottom);
  
  if (GetScreenWidth() < left + 20 or GetScreenHeight() < top + 20 or right < 20 or bottom < 20) then
    SmartBuffOptionsFrame:SetPoint("TOPLEFT", UIParent, "CENTER", -SmartBuffOptionsFrame:GetWidth() / 2, SmartBuffOptionsFrame:GetHeight() / 2);
  end
  
  SmartBuff_ShowControls("SmartBuffOptionsFrame", true);
  
  SmartBuffOptionsFrame_cbSB:SetChecked(O.Toggle);
  SmartBuffOptionsFrame_cbAuto:SetChecked(O.ToggleAuto);
  SmartBuffOptionsFrameAutoTimer:SetValue(O.AutoTimer);
  SmartBuff_SetSliderText(SmartBuffOptionsFrameAutoTimer, SMARTBUFF_OFT_AUTOTIMER, O.AutoTimer, INT_SPELL_DURATION_SEC);
  SmartBuffOptionsFrame_cbAutoCombat:SetChecked(O.ToggleAutoCombat);
  SmartBuffOptionsFrame_cbAutoChat:SetChecked(O.ToggleAutoChat);
  SmartBuffOptionsFrame_cbAutoSplash:SetChecked(O.ToggleAutoSplash);
  SmartBuffOptionsFrame_cbAutoSound:SetChecked(O.ToggleAutoSound);
  --SmartBuffOptionsFrame_cbCheckCharges:SetChecked(O.ToggleCheckCharges);
  --SmartBuffOptionsFrame_cbAutoRest:SetChecked(O.ToggleAutoRest);
  SmartBuffOptionsFrame_cbAutoSwitchTmp:SetChecked(O.AutoSwitchTemplate);
  SmartBuffOptionsFrame_cbAutoSwitchTmpInst:SetChecked(O.AutoSwitchTemplateInst);
  SmartBuffOptionsFrame_cbBuffPvP:SetChecked(O.BuffPvP);
  SmartBuffOptionsFrame_cbBuffTarget:SetChecked(O.BuffTarget);
  SmartBuffOptionsFrame_cbBuffInCities:SetChecked(O.BuffInCities);
  SmartBuffOptionsFrame_cbInShapeshift:SetChecked(O.InShapeshift);  
  SmartBuffOptionsFrame_cbWarnWhenMounted:SetChecked(O.WarnWhileMounted);
  
  SmartBuffOptionsFrame_cbAntiDaze:SetChecked(O.AntiDaze);
  SmartBuffOptionsFrame_cbLinkGrpBuffCheck:SetChecked(O.LinkGrpBuffCheck);
  SmartBuffOptionsFrame_cbLinkSelfBuffCheck:SetChecked(O.LinkSelfBuffCheck);
  
  SmartBuffOptionsFrame_cbScrollWheelUp:SetChecked(O.ScrollWheelUp);
  SmartBuffOptionsFrame_cbScrollWheelDown:SetChecked(O.ScrollWheelDown);
  SmartBuffOptionsFrame_cbInCombat:SetChecked(O.InCombat);
  SmartBuffOptionsFrame_cbMsgNormal:SetChecked(O.ToggleMsgNormal);
  SmartBuffOptionsFrame_cbMsgWarning:SetChecked(O.ToggleMsgWarning);
  SmartBuffOptionsFrame_cbMsgError:SetChecked(O.ToggleMsgError);
  SmartBuffOptionsFrame_cbHideMmButton:SetChecked(O.HideMmButton);
  SmartBuffOptionsFrame_cbHideSAButton:SetChecked(O.HideSAButton);
  
  SmartBuffOptionsFrameRebuffTimer:SetValue(O.RebuffTimer);
  SmartBuff_SetSliderText(SmartBuffOptionsFrameRebuffTimer, SMARTBUFF_OFT_REBUFFTIMER, O.RebuffTimer, INT_SPELL_DURATION_SEC);
  SmartBuffOptionsFrameBLDuration:SetValue(O.BlacklistTimer);
  SmartBuff_SetSliderText(SmartBuffOptionsFrameBLDuration, SMARTBUFF_OFT_BLDURATION, O.BlacklistTimer, INT_SPELL_DURATION_SEC);

  SMARTBUFF_ShowSubGroupsOptions();
  SMARTBUFF_SetCheckButtonBuffs(0);

  SmartBuffOptionsFrame_cbSelfFirst:SetChecked(B[CS()][currentTemplate].SelfFirst);
    
  SMARTBUFF_Splash_Show();
  
  SMARTBUFF_AddMsgD("Option frame updated: " .. currentTemplate);
end

function SMARTBUFF_ShowSubGroupsMini()
  SMARTBUFF_ShowSubGroups("SmartBuff_MiniGroup", O.ToggleGrp);
end

function SMARTBUFF_ShowSubGroupsOptions()
  SMARTBUFF_ShowSubGroups("SmartBuffOptionsFrame", O.ToggleGrp);
end

function SMARTBUFF_ShowSubGroups(frame, grpTable)
  local i;
  for i = 1, 8, 1 do
    obj = _G[frame.."_cbGrp"..i];
    if (obj) then
      obj:SetChecked(grpTable[i]);
    end
  end
end

function SMARTBUFF_Options_OnHide()
  if (SmartBuffWNF:IsVisible()) then
    SmartBuffWNF:Hide();
  end
  SMARTBUFF_ToggleTutorial(true);
  SmartBuffOptionsFrame:SetHeight(SMARTBUFF_OPTIONSFRAME_HEIGHT);
  --SmartBuff_BuffSetup:SetHeight(SMARTBUFF_OPTIONSFRAME_HEIGHT);
  wipe(cBuffsCombat);
  SMARTBUFF_SetInCombatBuffs();  
  SmartBuff_BuffSetup:Hide();
  SmartBuff_PlayerSetup:Hide();
  SMARTBUFF_SetUnits();
  SMARTBUFF_Splash_Hide();
  SMARTBUFF_RebindKeys();
  --collectgarbage();
end

function SmartBuff_ShowControls(sName, bShow)
  local children = {_G[sName]:GetChildren()};
  for i, child in pairs(children) do
    --SMARTBUFF_AddMsgD(i .. ": " .. child:GetName());
    if (i > 1 and string.find(child:GetName(), "^"..sName..".+")) then
      if (bShow) then
        child:Show();
      else
        child:Hide();
      end
    end
  end
end

function SmartBuffOptionsFrameSlider_OnLoad(self, low, high, step, labels)
  _G[self:GetName().."Text"]:SetFontObject(GameFontNormalSmall);
  if (labels) then
    if (self:GetOrientation() ~= "VERTICAL") then
      _G[self:GetName().."Low"]:SetText(low);
    else
      _G[self:GetName().."Low"]:SetText("");
    end
    _G[self:GetName().."High"]:SetText(high);
  else
    _G[self:GetName().."Low"]:SetText("");
    _G[self:GetName().."High"]:SetText("");
  end
  self:SetMinMaxValues(low, high);
  self:SetValueStep(step);
  self:SetStepsPerPage(step);
  
  if (step < 1) then return; end
  
  self.GetValueBase = self.GetValue;
  self.GetValue = function()
    local n = self:GetValueBase();
    if (n) then
      local r = Round(n);
      if (r ~= n) then
        self:SetValue(n);
      end
      return r;
    end
    return low;
  end;  
end

function SmartBuff_SetSliderText(self, text, value, valformat, setval)
  if (not self or not value) then return end
  local s;
  if (setval) then self:SetValue(value) end
  if (valformat) then
    s = string.format(valformat, value);
  else
    s = tostring(value);
  end
  getglobal(self:GetName().."Text"):SetText(text.." "..WH..s.."|r");
end

function SmartBuff_BuffSetup_RBTime_OnValueChanged(self)
  _G[SmartBuff_BuffSetup_RBTime:GetName().."Text"]:SetText(WH..format("%.0f", self:GetValue()).."\nsec|r");
end

function SMARTBUFF_SetCheckButtonBuffs(mode) 
  local objS;
  local objG;
  local i = 1;
  local ct = currentTemplate;

  if (mode == 0) then
    SMARTBUFF_SetBuffs();
  end
    
  SmartBuffOptionsFrame_cbAntiDaze:Hide();
  
  if (sPlayerClass == "HUNTER" or sPlayerClass == "ROGUE" or sPlayerClass == "WARRIOR") then    
    SmartBuffOptionsFrameBLDuration:Hide();
    if (sPlayerClass == "HUNTER") then
      SmartBuffOptionsFrame_cbLinkGrpBuffCheck:Hide();
      SmartBuffOptionsFrame_cbAntiDaze:Show();
    end
  end
  
  if (sPlayerClass == "DRUID" or sPlayerClass == "SHAMAN") then
    SmartBuffOptionsFrame_cbInShapeshift:Show();
  else
    SmartBuffOptionsFrame_cbInShapeshift:Hide();
  end
  
  SMARTBUFF_BuffOrderOnScroll();  
end


function SMARTBUFF_DropDownTemplate_OnShow(self)
  local i = 0;
  for _, tmp in pairs(SMARTBUFF_TEMPLATES) do
    i = i + 1;
    --SMARTBUFF_AddMsgD(i .. "." .. tmp);
    if (tmp == currentTemplate) then
      break;
    end
  end
  UIDropDownMenu_Initialize(self, SMARTBUFF_DropDownTemplate_Initialize);
  UIDropDownMenu_SetSelectedValue(SmartBuffOptionsFrame_ddTemplates, i);
  UIDropDownMenu_SetWidth(SmartBuffOptionsFrame_ddTemplates, 135);
end

function SMARTBUFF_DropDownTemplate_Initialize()
  local info = UIDropDownMenu_CreateInfo();
  info.text = ALL;
  info.value = -1;
  info.func = SMARTBUFF_DropDownTemplate_OnClick;
  for k, v in pairs(SMARTBUFF_TEMPLATES) do
    info.text = SMARTBUFF_TEMPLATES[k];
    info.value = k;
    info.func = SMARTBUFF_DropDownTemplate_OnClick;
    info.checked = nil;
    UIDropDownMenu_AddButton(info);
  end
end

function SMARTBUFF_DropDownTemplate_OnClick(self)
  local i = self.value;
  local tmp = nil;
  UIDropDownMenu_SetSelectedValue(SmartBuffOptionsFrame_ddTemplates, i);  
  tmp = SMARTBUFF_TEMPLATES[i];
  --SMARTBUFF_AddMsgD("Selected/Current Buff-Template: " .. tmp .. "/" .. currentTemplate);
  if (currentTemplate ~= tmp) then
    SmartBuff_BuffSetup:Hide();
    iLastBuffSetup = -1;
    SmartBuff_PlayerSetup:Hide();
    
    currentTemplate = tmp;
    SMARTBUFF_Options_OnShow();
    O.LastTemplate = currentTemplate;
  end
end
-- END Options frame functions


-- Splash screen functions ---------------------------------------------------------------------------------------
function SMARTBUFF_Splash_Show()
  if (not isInit) then return; end 
  SMARTBUFF_Splash_ChangeFont(1);
  SmartBuffSplashFrame:EnableMouse(true);
  SmartBuffSplashFrame:Show();
  SmartBuffSplashFrame:SetTimeVisible(60);
  SmartBuffSplashFrameOptions:Show();
end

function SMARTBUFF_Splash_Hide()
  if (not isInit) then return; end 
  SMARTBUFF_Splash_Clear();
  SMARTBUFF_Splash_ChangePos();
  SmartBuffSplashFrame:EnableMouse(false);
  SmartBuffSplashFrame:SetFadeDuration(O.SplashDuration);
  SmartBuffSplashFrame:SetTimeVisible(O.SplashDuration);
  SmartBuffSplashFrameOptions:Hide();
end

function SMARTBUFF_Splash_Clear()
  SmartBuffSplashFrame:Clear();
end

function SMARTBUFF_Splash_ChangePos()
  local x, y = SmartBuffSplashFrame:GetLeft(), SmartBuffSplashFrame:GetTop() - UIParent:GetHeight();
  if (O) then
    O.SplashX = x;
    O.SplashY = y;
  end
end

function SMARTBUFF_Splash_ChangeFont(mode)
  local f = SmartBuffSplashFrame;
  
  if (mode > 1) then
    SMARTBUFF_Splash_ChangePos();    
    iCurrentFont = iCurrentFont + 1;
  end
  if (not cFonts[iCurrentFont]) then
    iCurrentFont = 1;
  end
  O.CurrentFont = iCurrentFont;
  f:ClearAllPoints();
  f:SetPoint("TOPLEFT", O.SplashX, O.SplashY);
  
  local fo = f:GetFontObject();
  local fName, fHeight, fFlags = _G[cFonts[iCurrentFont]]:GetFont();
  if (mode > 1 or O.CurrentFontSize == nil) then
    O.CurrentFontSize = fHeight;
  end
  fo:SetFont(fName, O.CurrentFontSize, fFlags);
  SmartBuffSplashFrameOptions.size:SetValue(O.CurrentFontSize);
  
  f:SetInsertMode("TOP");
  f:SetJustifyV("MIDDLE");
  if (mode > 0) then
    local si = "";
    if (OG.SplashIcon) then 
      local n = O.SplashIconSize;
      if (n == nil or n <= 0) then
        n = O.CurrentFontSize;
      end
      si = string.format(" \124T%s:%d:%d:1:0\124t", "Interface\\Icons\\INV_Misc_QuestionMark", n, n) or "";
    else
      si = " BuffXYZ";
    end
    SMARTBUFF_Splash_Clear();
    if (OG.SplashMsgShort) then
      f:AddMessage(cFonts[iCurrentFont].." >"..si.."\ndrag'n'drop to move", O.ColSplashFont.r, O.ColSplashFont.g, O.ColSplashFont.b, 1.0);
    else
      f:AddMessage(cFonts[iCurrentFont].." "..SMARTBUFF_MSG_NEEDS..si.."\ndrag'n'drop to move", O.ColSplashFont.r, O.ColSplashFont.g, O.ColSplashFont.b, 1.0);
    end
  end
end
-- END Splash screen events


-- Playerlist functions ---------------------------------------------------------------------------------------
function SmartBuff_PlayerSetup_OnShow()
end

function SmartBuff_PlayerSetup_OnHide()
end

function SmartBuff_PS_GetList()
  if (iLastBuffSetup <= 0) then return { } end
  
  local name = cBuffs[iLastBuffSetup].BuffS;
  if (name) then
    if (iCurrentList == 1) then
      return B[CS()][currentTemplate][name].AddList;
    else
      return B[CS()][currentTemplate][name].IgnoreList;
    end
  end
end

function SmartBuff_PS_GetUnitList()
  if (iCurrentList == 1) then
    return cAddUnitList;
  else
    return cIgnoreUnitList;
  end
end

function SmartBuff_UnitIsAdd(unit)
  if (unit and cAddUnitList[unit]) then return true end
  return false;
end

function SmartBuff_UnitIsIgnored(unit)
  if (unit and cIgnoreUnitList[unit]) then return true end
  return false;
end

function SmartBuff_PS_Show(i)
  iCurrentList = i;
  iLastPlayer = -1;
  local obj = SmartBuff_PlayerSetup_Title;
  if (iCurrentList == 1) then
    obj:SetText("Additional list");
  else
    obj:SetText("Ignore list");
  end
  obj:ClearFocus();
  SmartBuff_PlayerSetup_EditBox:ClearFocus();
  SmartBuff_PlayerSetup:Show();
  SmartBuff_PS_SelectPlayer(0);  
end

function SmartBuff_PS_AddPlayer()
  local cList = SmartBuff_PS_GetList();
  local un = UnitName("target");
  if (un and UnitIsPlayer("target") and (UnitInRaid("target") or UnitInParty("target") or O.Debug)) then
    if (not cList[un]) then
      cList[un] = true;
      SmartBuff_PS_SelectPlayer(0);    
    end
  end
end

function SmartBuff_PS_RemovePlayer()
  local n = 0;
  local cList = SmartBuff_PS_GetList();
  for player in pairs(cList) do
    n = n + 1;
    if (n == iLastPlayer) then
      cList[player] = nil;
      break;
    end
  end  
  SmartBuff_PS_SelectPlayer(0);  
end

function SmartBuff_AddToUnitList(idx, unit, subgroup)
  iCurrentList = idx;
  local cList = SmartBuff_PS_GetList();
  local cUnitList = SmartBuff_PS_GetUnitList(); 
  if (unit and subgroup) then
    local un = UnitName(unit);
    if (un and cList[un]) then
      cUnitList[unit] = subgroup;
      --print("Added to UnitList:" .. un .. "(" .. unit .. ")");
    end
  end
end

function SmartBuff_PS_SelectPlayer(iOp)
  local idx = iLastPlayer + iOp;
  local cList = SmartBuff_PS_GetList();
  local s = "";
  
  local tn = 0;
  for player in pairs(cList) do
    tn = tn + 1;
    s = s .. player .. "\n";
  end
  
  -- update list in textbox
  if (iOp == 0) then
    SmartBuff_PlayerSetup_EditBox:SetText(s);
    --SmartBuff_PlayerSetup_EditBox:ClearFocus();
  end
  
  -- highlight selected player
  if (tn > 0) then
    if (idx > tn) then idx = tn; end
    if (idx < 1)  then idx = 1; end
    iLastPlayer = idx;
    --SmartBuff_PlayerSetup_EditBox:ClearFocus();
    local n = 0;
    local i = 0;
    local w = 0;
    for player in pairs(cList) do
      n = n + 1;
      w = string.len(player);
      if (n == idx) then
        SmartBuff_PlayerSetup_EditBox:HighlightText(i + n - 1, i + n + w);
        break;
      end
      i = i + w;
    end
  end
end

function SmartBuff_PS_Resize()
  local h = SmartBuffOptionsFrame:GetHeight();
  local b = true;
  
  if (h < 200) then
    SmartBuffOptionsFrame:SetHeight(SMARTBUFF_OPTIONSFRAME_HEIGHT);
    --SmartBuff_BuffSetup:SetHeight(SMARTBUFF_OPTIONSFRAME_HEIGHT);
    b = true;
  else
    SmartBuffOptionsFrame:SetHeight(40);
    --SmartBuff_BuffSetup:SetHeight(40);
    b = false;
  end
  SmartBuff_ShowControls("SmartBuffOptionsFrame", b); 
  if (b) then
    SMARTBUFF_SetCheckButtonBuffs(1);
  end
end
-- END Playerlist functions


-- Mini group functions ---------------------------------------------------------------------------------------
function SMARTBUFF_MiniGroup_OnShow()
  SmartBuff_MiniGroup_Title:SetText(SMARTBUFF_TITLE.." - "..currentTemplate);
  SMARTBUFF_ShowSubGroupsMini();
end

function SMARTBUFF_MiniGroup_OnHide()
end

function SMARTBUFF_MiniGroup_Show()
  --if (O.ShowMiniGrp) then
  if (O.ShowMiniGrp and iGroupSetup == 3) then
    SmartBuff_MiniGroup:Show();
  else
    if (SmartBuff_MiniGroup:IsVisible()) then
      SmartBuff_MiniGroup:Hide();
    end
  end
end
-- END Mini group functions


-- Secure button functions, NEW TBC ---------------------------------------------------------------------------------------
function SMARTBUFF_ShowSAButton()
  if (not InCombatLockdown()) then
    if (O.HideSAButton) then
      SmartBuff_KeyButton:Hide();
    else
      SmartBuff_KeyButton:Show();
    end
  end
end

local sScript;
function SMARTBUFF_OnClick(obj)
  SMARTBUFF_AddMsgD("OnClick");
end


local lastBuffType = "";
function SMARTBUFF_OnPreClick(self, button, down)
  if (not isInit) then return end
  
  local mode = 0;
  if (button) then
    if (button == "MOUSEWHEELUP" or button == "MOUSEWHEELDOWN") then
      mode = 5;
    end
  end
    
  if (not InCombatLockdown()) then
    self:SetAttribute("type", nil);
    self:SetAttribute("unit", nil);
    self:SetAttribute("spell", nil);
    self:SetAttribute("item", nil);
    self:SetAttribute("macrotext", nil);
    self:SetAttribute("target-slot", nil); 
    self:SetAttribute("target-item", nil);
    self:SetAttribute("action", nil);
  end
  
  --sScript = self:GetScript("OnClick");
  --self:SetScript("OnClick", SMARTBUFF_OnClick);
  
  local td;
  if (lastBuffType == "") then
    td = 0.8;
  else
    td = GlobalCd;
  end
  --SMARTBUFF_AddMsgD("Last buff type: " .. lastBuffType .. ", set cd: " .. td);
    
  local casting = UnitCastingInfo("player") or UnitChannelInfo("player");
  --print(casting);
  if (casting ~= nil) then
    --print("Casting", casting, "-> Reset AutoBuff timer");
    tAutoBuff = GetTime() + 0.7;
    return;
  end
  
  if (GetTime() < (tAutoBuff + td)) then return end
  
  --SMARTBUFF_AddMsgD("next buff check");
  tAutoBuff = GetTime();
  lastBuffType = "";
  currentUnit = nil;
  currentSpell = nil;
  currentRank = nil;
  
  if (not InCombatLockdown()) then
    local ret, actionType, spellName, slot, unit, buffType, rankText = SMARTBUFF_Check(mode);
    if (ret and ret == 0 and actionType and spellName and unit) then
      lastBuffType = buffType;
      self:SetAttribute("type", actionType);
      self:SetAttribute("unit", unit);
      if (actionType == SMARTBUFF_ACTION_SPELL) then        
        if (slot and slot > 0 and unit == "player") then
          self:SetAttribute("type", "macro");
          self:SetAttribute("macrotext", string.format("/use %s\n/use %i\n/click StaticPopup1Button1", spellName, slot));
          --self:SetAttribute("target-item", slot);
          SMARTBUFF_AddMsgD("Weapon buff "..spellName..", "..slot);
        else
          --rankText = "(Rang 1)";
          local name = spellName;
          if (rankText ~= nil) then
            name = spellName..rankText;
          end
          SMARTBUFF_AddMsgD("SetAttribute 'spell' = "..name);
          self:SetAttribute("spell", name);
        end
        
        if (cBuffIndex[spellName]) then
          currentUnit = unit;
          currentSpell = spellName;
        end
              
      elseif (actionType == SMARTBUFF_ACTION_ITEM and slot) then
        --if (spellname ~= nil and string.find(spellname, "%-%-") ~= nil) then
        --  spellname = string.gsub(spellname, "%-%-", "%-");
        --end
        self:SetAttribute("item", spellName);
        if (slot > 0) then
          --self:SetAttribute("target-slot", slot);
          
          self:SetAttribute("type", "macro");
          self:SetAttribute("macrotext", string.format("/use %s\n/use %i\n/click StaticPopup1Button1", spellName, slot));
        end
      elseif (actionType == "action" and slot) then
        self:SetAttribute("action", slot);
      else
        SMARTBUFF_AddMsgD("Preclick: not supported actiontype -> " .. actionType);
      end
      
      --isClearSplash = true;
      tLastCheck = GetTime() - O.AutoTimer + GlobalCd;
    end
  end
end

function SMARTBUFF_OnPostClick(self, button, down)
  if (not isInit) then return end
    
  if (button) then
    if (button == "MOUSEWHEELUP") then
      CameraZoomIn(1);
    elseif (button == "MOUSEWHEELDOWN") then
      CameraZoomOut(1);
    end
  end
  
  if (InCombatLockdown()) then return end
  
  --[[
  if (O.Toggle) then
    if (O.InCombat) then
      for spell, data in pairs(cBuffsCombat) do
        if (data and data.Unit and data.ActionType) then
          SmartBuff_KeyButton:SetAttribute("unit", data.Unit);
          SmartBuff_KeyButton:SetAttribute("type", data.ActionType);
          SmartBuff_KeyButton:SetAttribute("spell", spell);
          SmartBuff_KeyButton:SetAttribute("item", nil);
          SmartBuff_KeyButton:SetAttribute("target-slot", nil); 
          SmartBuff_KeyButton:SetAttribute("action", nil);
          SMARTBUFF_AddMsgD("Enter Combat, set button: " .. spell .. " on " .. data.Unit .. ", " .. data.ActionType);
          break;
        end
      end
    end
  end
  ]]--
  
  --local posX, posY = GetPlayerMapPosition("player");
  --SMARTBUFF_AddMsgD("X = " .. posX .. ", Y = " .. posY);  
  --if (UnitCreatureType("target")) then
  --  SMARTBUFF_AddMsgD(UnitCreatureType("target"));
  --end
  
  --[[
  local r = IsSpellInRange("Nachwachsen", "target")
  if(r and r == 1) then
    SMARTBUFF_AddMsgD("Spell in range");
  elseif(r and r == 0) then
    SMARTBUFF_AddMsgD("OOR");
  end
  ]]--
  
  --[[
  local s = "";
  local button = SecureStateChild_GetEffectiveButton(self);
  local type  = SecureButton_GetModifiedAttribute(self, "type", button, "");
  local unit  = SecureButton_GetModifiedAttribute(self, "unit", button, "");
  local spell = SecureButton_GetModifiedAttribute(self, "spell", button, "");
  if (type and unit and spell) then
    s = s .. type .. ", " .. unit .. ", " .. spell;
  end
  ]]--
  
  self:SetAttribute("type", nil);
  self:SetAttribute("unit", nil);
  self:SetAttribute("spell", nil);
  self:SetAttribute("item", nil);
  self:SetAttribute("target-slot", nil);
  self:SetAttribute("target-item", nil);
  self:SetAttribute("macrotext", nil);
  self:SetAttribute("action", nil);
  
  SMARTBUFF_SetButtonTexture(SmartBuff_KeyButton, imgSB);
  --SMARTBUFF_AddMsgD("Button reseted, " .. button);
  --self:SetScript("OnClick", sScript);
end

function SMARTBUFF_SetButtonTexture(button, texture, text)
  --if (InCombatLockdown()) then return; end
  
  if (button and texture and texture ~= sLastTexture) then
    sLastTexture = texture;
    button:SetNormalTexture(texture);
    --SMARTBUFF_AddMsgD("Button slot texture set -> " .. texture);
    if (text) then
      --button.title:SetText(spell);
    end
  end
end
-- END secure button functions


-- Minimap button functions ---------------------------------------------------------------------------------------
-- Sets the correct icon on the minimap button
function SMARTBUFF_CheckMiniMapButton()
  if (O.Toggle) then
    SmartBuff_MiniMapButton:SetNormalTexture(imgIconOn);
  else
    SmartBuff_MiniMapButton:SetNormalTexture(imgIconOff);
  end
  
  if (O.HideMmButton) then
    SmartBuff_MiniMapButton:Hide();
  else
    SmartBuff_MiniMapButton:Show();
  end
  
  -- Update the Titan Panel icon
  if (TitanPanelBarButton and TitanPanelSmartBuffButton_SetIcon ~= nil) then
    TitanPanelSmartBuffButton_SetIcon();
  end
  
  -- Update the FuBar icon
  if (IsAddOnLoaded("FuBar") and IsAddOnLoaded("FuBar_SmartBuffFu") and SMARTBUFF_Fu_SetIcon ~= nil) then
    SMARTBUFF_Fu_SetIcon();
  end
  
  -- Update the Broker icon
  if (IsAddOnLoaded("Broker_SmartBuff") and SMARTBUFF_BROKER_SetIcon ~= nil) then
    SMARTBUFF_BROKER_SetIcon();
  end
  
end

function SMARTBUFF_MinimapButton_CheckPos()
  if (not isInit or not SmartBuff_MiniMapButton) then return; end
  local x = SmartBuff_MiniMapButton:GetLeft();
  local y = SmartBuff_MiniMapButton:GetTop();  
  if (x == nil or y == nil) then return; end
  x = x - Minimap:GetLeft();
  y = y - Minimap:GetTop();  
  if (math.abs(x) < 180 and math.abs(y) < 180) then
    O.MMCPosX = x;
    O.MMCPosY = y;
    --SMARTBUFF_AddMsgD("x = " .. O.MMCPosX .. ", y = " .. O.MMCPosY);  
  end
end

-- Function to move the minimap button arround the minimap
function SMARTBUFF_MinimapButton_OnUpdate(self, move)
  if (not isInit or self == nil or not self:IsVisible()) then
    return;
  end

  local xpos, ypos;
  self:ClearAllPoints();
  if (move or O.MMCPosX == nil) then
    local pos, r
    local xmin, ymin = Minimap:GetLeft(), Minimap:GetBottom();
    xpos, ypos = GetCursorPosition();
    xpos = xmin-xpos/Minimap:GetEffectiveScale()+70;
    ypos = ypos/Minimap:GetEffectiveScale()-ymin-70;
    pos  = math.deg(math.atan2(ypos,xpos));
    r    = math.sqrt(xpos*xpos + ypos*ypos);
    --SMARTBUFF_AddMsgD("x = " .. xpos .. ", y = " .. ypos .. ", r = " .. r .. ", pos = " .. pos);
    
    if (r < 75) then
      r = 75;
    elseif(r > 105) then
      r = 105;
    end
    
    xpos = 52-r*cos(pos);
    ypos = r*sin(pos)-52;
    O.MMCPosX = xpos;
    O.MMCPosY = ypos;
    --SMARTBUFF_AddMsgD("Update minimap button position");
  else
    xpos = O.MMCPosX;
    ypos = O.MMCPosY;
    --SMARTBUFF_AddMsgD("Load minimap button position");
  end
  self:ClearAllPoints();
  self:SetPoint("TOPLEFT", "Minimap", "TOPLEFT", xpos, ypos);
  --SMARTBUFF_AddMsgD("x = " .. O.MMCPosX .. ", y = " .. O.MMCPosY);
  --SmartBuff_MiniMapButton:SetUserPlaced(true);
  --SMARTBUFF_AddMsgD("Update minimap button");
end
-- END Minimap button functions



-- Scroll frame functions ---------------------------------------------------------------------------------------
local ScrBtnSize = 20;
local ScrLineHeight = 18;
local function SetPosScrollButtons(parent, cBtn)
  local btn;
  local name;
  for i = 1, #cBtn, 1 do
    btn = cBtn[i];
    btn:ClearAllPoints();
    btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 2, -2 - ScrLineHeight*(i-1));
  end
end

local StartY, EndY;
local function CreateScrollButton(name, parent, cBtn, onClick, onDragStop)
  local btn = CreateFrame("CheckButton", name, parent, "OptionsCheckButtonTemplate");
  btn:SetWidth(ScrBtnSize);
  btn:SetHeight(ScrBtnSize);
  --btn:RegisterForClicks("LeftButtonUp");
  btn:RegisterForClicks("AnyUp");
  btn:SetScript("OnClick", onClick);
  --btn:SetScript("OnMouseUp", onClick);
  
  if (onDragStop ~= nil) then
    btn:SetMovable(true);
    btn:RegisterForDrag("LeftButton");
    btn:SetScript("OnDragStart", function(self, b)    
      StartY = self:GetTop();
      self:StartMoving();
      end
    );
    btn:SetScript("OnDragStop", function(self, b)
      EndY = self:GetTop();
      local i = tonumber(self:GetID()) + FauxScrollFrame_GetOffset(parent);
      local n = math.floor((StartY-EndY) / ScrLineHeight);
      self:StopMovingOrSizing();
      SetPosScrollButtons(parent, cBtn);
      onDragStop(i, n);
      end
    );
  end

  local text = btn:CreateFontString(nil, nil, "GameFontNormal");
  text:SetJustifyH("LEFT");
  --text:SetAllPoints(btn);
  text:SetPoint("TOPLEFT", btn, "TOPLEFT", ScrBtnSize, 0);
  text:SetWidth(parent:GetWidth()-ScrBtnSize);
  text:SetHeight(ScrBtnSize);  
  btn:SetFontString(text);
  btn:SetHighlightFontObject("GameFontHighlight");

  local highlight = btn:CreateTexture();
  --highlight:SetAllPoints(btn);
  highlight:SetPoint("TOPLEFT", btn, "TOPLEFT", 0, -2);
  highlight:SetWidth(parent:GetWidth());
  highlight:SetHeight(ScrLineHeight-3);
  
  highlight:SetTexture("Interface/QuestFrame/UI-QuestTitleHighlight");
  btn:SetHighlightTexture(highlight);

  return btn;
end


local function CreateScrollButtons(self, cBtn, sBtnName, onClick, onDragStop)
  local btn, i;
  for i = 1, maxScrollButtons, 1 do
    btn = CreateScrollButton(sBtnName..i, self, cBtn, onClick, onDragStop);
    btn:SetID(i);
    cBtn[i] = btn;
  end
  SetPosScrollButtons(self, cBtn);
end


local function OnScroll(self, cData, sBtnName)
  local num = #cData;
  local n, numToDisplay;
  
  if (num <= maxScrollButtons) then
    numToDisplay = num-1;
  else
    numToDisplay = maxScrollButtons;
  end
  
  FauxScrollFrame_Update(self, num, numToDisplay, ScrLineHeight);
  local t = B[CS()][CT()];
  for i = 1, maxScrollButtons, 1 do
    n = i + FauxScrollFrame_GetOffset(self);
    btn = _G[sBtnName..i];
    if (btn) then
      if (n <= num) then
        btn:SetNormalFontObject("GameFontNormalSmall");
        btn:SetHighlightFontObject("GameFontHighlightSmall");      
        btn:SetText(cData[n]);
        btn:SetChecked(t[cData[n]].EnableS);
        btn:Show();
      else
        btn:Hide();
      end
    end
  end
end


function SMARTBUFF_BuffOrderOnScroll(self, arg1)
  if (not self) then
    self = SmartBuffOptionsFrame_ScrollFrameBuffs;
  end

  local name = "SMARTBUFF_BtnScrollBO";
  if (not cScrBtnBO and self) then
    cScrBtnBO = { };
    CreateScrollButtons(self, cScrBtnBO, name, SMARTBUFF_BuffOrderBtnOnClick, SMARTBUFF_BuffOrderBtnOnDragStop);
  end
  
  if (B[CS()].Order == nil) then
    B[CS()].Order = { };
  end  
  
  local t = { };
  for _, v in pairs(B[CS()].Order) do
    if (v) then
      tinsert(t, v);
    end
  end
  OnScroll(self, t, name);
end

function SMARTBUFF_BuffOrderBtnOnClick(self, button)
  local n = self:GetID() + FauxScrollFrame_GetOffset(self:GetParent());
  local i = cBuffIndex[B[CS()].Order[n]];
  --SMARTBUFF_AddMsgD("Buff OnClick = "..n..", "..button);
  if (button == "LeftButton") then
    SMARTBUFF_OToggleBuff("S", i);
  else
    local b = not self:GetChecked();
    self:SetChecked(b);
    SmartBuff_BuffSetup_Show(i);
  end
end

function SMARTBUFF_BuffOrderBtnOnDragStop(i, n)
  treorder(B[CS()].Order, i, n);
  SMARTBUFF_BuffOrderOnScroll();
end

function SMARTBUFF_BuffOrderReset()
  InitBuffOrder(true);
  SMARTBUFF_BuffOrderOnScroll();
end


-- Help plate functions ---------------------------------------------------------------------------------------

local HelpPlateList = {
  FramePos = { x = 20, y = -20 },
  FrameSize = { width = 480, height = 500 },
  [1] = { ButtonPos = { x = 344,  y = -80 },  HighLightBox = { x = 260, y = -50, width = 204, height = 410 },   ToolTipDir = "DOWN",  ToolTipText = "Spell list\nDrag'n'Drop to change the priority order" },
  [2] = { ButtonPos = { x = 105,  y = -110 }, HighLightBox = { x = 10, y = -30, width = 230, height = 125 },  ToolTipDir = "DOWN",   ToolTipText = "Buff reminder options" },
  [3] = { ButtonPos = { x = 105,  y = -250 }, HighLightBox = { x = 10, y = -165, width = 230, height = 135 },  ToolTipDir = "DOWN",   ToolTipText = "Character based options" },
  [4] = { ButtonPos = { x = 200,  y = -320 }, HighLightBox = { x = 10, y = -300, width = 230, height = 90 },  ToolTipDir = "RIGHT",   ToolTipText = "Additional UI options" },
}

function SMARTBUFF_ToggleTutorial(close)
end
