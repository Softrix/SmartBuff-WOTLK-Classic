-------------------------------------------------------------------------------
-- SmartBuff
-- Originally created by Aeldra (EU-Proudmoore)
-- Classic & Retail versions by Codermik & Speedwaystar
-- Retail version fixes / improvements by Codermik & Speedwaystar
-- Discord: https://discord.gg/R6EkZ94TKK
-- Cast the most important buffs on you, tanks or party/raid members/pets.
-------------------------------------------------------------------------------

SMARTBUFF_DATE          = "071023";

SMARTBUFF_VERSION       = "r51."..SMARTBUFF_DATE;
SMARTBUFF_VERSIONNR     = 30402;
SMARTBUFF_TITLE         = "SmartBuff";
SMARTBUFF_SUBTITLE      = "Supports you in casting buffs";
SMARTBUFF_DESC          = "Cast the most important buffs on you, your tanks, party/raid members/pets";
SMARTBUFF_VERS_TITLE    = SMARTBUFF_TITLE .. " " .. SMARTBUFF_VERSION;
SMARTBUFF_OPTIONS_TITLE = SMARTBUFF_VERS_TITLE.." WOTLK ";

-- addon name
local addonName = ...
local SmartbuffPrefix = "SBC1.0";
local SmartbuffHeader = "Smartbuff";
local SmartbuffCommands = { "SBCVER", "SBCCMD", "SBCSYC" }
local SmartbuffSession = true;
local SmartbuffVerCheck = false;					-- for my use when checking guild users/testers versions  :)
local buildInfo = select(4, GetBuildInfo())
local SmartbuffRevision = 51;
local SmartbuffVerNotifyList = {}

-- Using LibRangeCheck-2.0 by Mitchnull
-- https://www.wowace.com/projects/librangecheck-2-0
local LRC = LibStub("LibRangeCheck-2.0")

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
local maxScrollButtons = 30;
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
local isKeyUpChanged = false;
local isKeyDownChanged = false;
local isAuraChanged = false;
local isClearSplash = false;
local isRebinding = false;
local isParrot = false;
local isSync = false;
local isSyncReq = false;
local isInitBtn = false;
local isPrompting = false

local isShapeshifted = false;
local sShapename = "";

local tStartZone = 0;
local tTicker = 0;
local tSync = 0;

local sRealmName = nil;
local sPlayerName = nil;
local sID = nil;
local sPlayerClass = nil;
local tLastCheck = 0;
local iLastBuffSetup = -1;
local sLastTexture = "";
local iLastGroupSetup = -99;
local sLastZone = "";
local tAutoBuff = 0;
local tDebuff = 0;
local sMsgWarning = "";
local iCurrentFont = 6;
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
local cSpellRankInfo = { };

local cScrBtnBO = nil;

local cAddUnitList = { };
local cIgnoreUnitList = { };
local cPlayerTrackers = { };
local cDisableTrackSwitch = false;
local cLootOpenedDisable = false;

local cClasses       = {"DRUID", "HUNTER", "MAGE", "PALADIN", "PRIEST", "ROGUE", "SHAMAN", "WARLOCK", "WARRIOR", "DEATHKNIGHT", "MONK", "DEMONHUNTER", "EVOKER", "HPET", "WPET", "DKPET", "TANK", "HEALER", "DAMAGER"};
local cIgnoreClasses = { 11, 12, 13, 19 };
local cOrderGrp      = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11};
local cFonts         = {"NumberFontNormal", "NumberFontNormalLarge", "NumberFontNormalHuge", "GameFontNormal", "GameFontNormalLarge", "GameFontNormalHuge", "ChatFontNormal", "QuestFont", "MailTextFontNormal", "QuestTitleFont"};

local currentUnit = nil;
local currentSpell = nil;
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
  ["EVOKER"]      = { IconPaths.Classes, 0.75, 1.00, 0.50, 0.75 },
  ["PET"]         = { IconPaths.Pet, 0.08, 0.92, 0.08, 0.92},
  ["TANK"]        = { IconPaths.Roles, 0.0, 19/64, 22/64, 41/64 },
  ["HEALER"]      = { IconPaths.Roles, 20/64, 39/64, 1/64, 20/64 },
  ["DAMAGER"]     = { IconPaths.Roles, 20/64, 39/64, 22/64, 41/64 },
  ["NONE"]        = { IconPaths.Roles, 20/64, 39/64, 22/64, 41/64 },
};

-- available sounds (34)
local Sounds = { 1141, 3784, 4574, 17318, 15262, 13830, 15273, 10042, 10720, 17316, 3337, 15263, 13267, 8698, 3660, 
	            15712, 9203, 12279, 3273, 13179, 13327, 9632, 10590, 3322, 718, 149, 15686, 6189, 7095, 6341, 6267,
	            7894, 7914, 10033 }

local DebugChatFrame = DEFAULT_CHAT_FRAME;

-- upvalues
local UnitCastingInfo = _G.UnitCastingInfo or _G.CastingInfo
local UnitChannelInfo = _G.UnitChannelInfo or _G.ChannelInfo
local GetNumSpecGroups = _G.GetNumSpecGroups or function(...) return 1 end
local IsActiveBattlefieldArena = _G.IsActiveBattlefieldArena or function(...) return false end

-- Popup to reset everything
StaticPopupDialogs["SMARTBUFF_DATA_PURGE"] = {
  text = SMARTBUFF_OFT_PURGE_DATA,
  button1 = SMARTBUFF_OFT_YES,
  button2 = SMARTBUFF_OFT_NO,
  OnAccept = function() SMARTBUFF_ResetAll() end,
  timeout = 0,
  whileDead = 1,
  hideOnEscape = 1
}

-- Popup to reloadui
StaticPopupDialogs["SMARTBUFF_GUI_RELOAD"] = {
  text = SMARTBUFF_OFT_REQ_RELOAD,
  button1 = SMARTBUFF_OFT_OKAY,
  OnAccept = function() ReloadUI() end,
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

function SMARTBUFF_ChooseSplashSound()
  local menu = {}
  local i = 1
  for sound, soundpath in pairs(sounds) do
    menu[i] = { text = sound, notCheckable = true, func = function() PlaySound(soundpath) end }
    i = i + 1
  end
  local dropDown = CreateFrame("Frame", "DropDownMenuFrame", UIParent, "UIDropDownMenuTemplate")
  dropDown:SetPoint("CENTER", UIParent, "CENTER")
  dropDown:SetScript("OnMouseUp", function (self, button, down)
    print("mousedown")
  end)
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

local function ChkS(text)
  if (text == nil) then
    text = "";
  end
  return text;
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
  if (currentSpec == nil) then
    currentSpec = GetActiveTalentGroup()
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
    cBuff.MH = true; -- default to checked
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
  if not B then B = {} end
  if not B[CS()] then B[CS()] = {} end
  if not B[CS()].Order then B[CS()].Order = {} end
  local b;
  local i;
  local ord = B[CS()].Order;

  if (reset) then
    wipe(ord);
  end

  -- Remove no longer existing buffs in the order list
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

local function IsPlayerInGuild()
    return IsInGuild() -- and GetGuildInfo("player")
end


local function IsTalentSkilled(t, i, name)
  local _, tName, _, _, tAvailable = GetTalentInfo(t, i);
  if (tName) then
    isTTreeLoaded = true;
    SMARTBUFF_AddMsgD("Talent: "..tName..", Points = "..tAvailable);
    if (name and name == tName and tAvailable > 0) then
      SMARTBUFF_AddMsgD("Debuff talent found: "..name..", Points = "..tAvailable);
      return true, tAvailable;
    end
  else
    SMARTBUFF_AddMsgD("Talent tree not available!");
    isTTreeLoaded = false;
  end
  return false, 0;
end

-- toggle the auto gathering switcher.
function ToggleAutoGatherer()
    if (not isInit) then return end
    O.TrackSwitchActive = not O.TrackSwitchActive;
    if not SmartBuffOptionsFrame:IsShown() then         -- quiet while in options
	    if O.TrackSwitchActive then 
            DEFAULT_CHAT_FRAME:AddMessage("|cff00e0ffSmartbuff Build "..SMARTBUFF_VERSION.." (Client: "..buildInfo..")|cffffffff "..SMARTBUFF_AUTOGATHERON)
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cff00e0ffSmartbuff Build "..SMARTBUFF_VERSION.." (Client: "..buildInfo..")|cffffffff "..SMARTBUFF_AUTOGATHEROFF)
	    end
	    PlaySound(15263);
	end    
end

-- Read number of tracking abilities
function ScanPlayerTrackers()
    if (not isInit) then return end
	local count = C_Minimap.GetNumTrackingTypes();
	local spellcount = 0;
	cPlayerTrackers = { };
	for i=1,count do 
		local name, texture, active, category = C_Minimap.GetTrackingInfo(i);
		if category == "spell" then
			-- only interested in minerals, herbs and fish here
			if name == SMARTBUFF_OFT_MINERALS or name == SMARTBUFF_OFT_HERBS or name == SMARTBUFF_OFT_FINDFISH then
				spellcount = spellcount + 1
				tinsert(cPlayerTrackers, {i, name})
			end
		end
	end
	O.TrackMaxPosition = spellcount
end

-- toggle trackers
local lastFire = GetTime()
function ToggleGatheringTrackers()
    if (not isInit) then return end
    local tmptable
	if O.TrackSwitchActive and not cDisableTrackSwitch and not cLootOpenedDisable then
		local currentTime = GetTime()
		if (currentTime - lastFire) >= O.TrackSwitchDelay and not InCombatLockdown() then
			ScanPlayerTrackers()
			currentTime = GetTime()
			lastFire = currentTime
            if not SmartBuffOptionsFrame:IsShown() then
			    tmptable = cPlayerTrackers[O.TrackPosition]
			    local tmptablesize = #cPlayerTrackers
			    if tmptablesize <= 1 then
                    -- turn the auto switch off, it will only benefit when more than one gathering tracking is available.
                    DEFAULT_CHAT_FRAME:AddMessage("|cff00e0ffSmartbuff Gathering Switcher : |cffffffff"..SMARTBUFF_TRACKINGDISABLE)
				    O.TrackSwitchActive = false
			    end
			    if tmptable then
				    if tmptable[2] == "Find Fish" and O.TrackSwitchFish then
					    C_Minimap.SetTracking(tmptable[1], true)
				    elseif tmptable[2] == "Find Fish" and not O.TrackSwitchFish then
					    O.TrackPosition = O.TrackPosition + 1
					    if O.TrackPosition > O.TrackMaxPosition then 
						    O.TrackPosition = 1 
					    end	
					    tmptable = cPlayerTrackers[O.TrackPosition]
					    C_Minimap.SetTracking(tmptable[1], true)
				    elseif tmptable[2] ~= "Find Fish" then
					    C_Minimap.SetTracking(tmptable[1], true)
				    end
				    O.TrackPosition = O.TrackPosition + 1
				    if O.TrackPosition > O.TrackMaxPosition then 
					    O.TrackPosition = 1 
				    end
			    end
			end
		end
	end
end


-- SMARTBUFF_OnLoad
function SMARTBUFF_OnLoad(self)
  self:RegisterEvent("ADDON_LOADED");
  self:RegisterEvent("PLAYER_LOGIN");
  self:RegisterEvent("PLAYER_ENTERING_WORLD");
  self:RegisterEvent("UNIT_NAME_UPDATE");
  self:RegisterEvent("PLAYER_REGEN_ENABLED");
  self:RegisterEvent("PLAYER_REGEN_DISABLED");
  self:RegisterEvent("PLAYER_STARTED_MOVING");
  self:RegisterEvent("PLAYER_STOPPED_MOVING");
  self:RegisterEvent("LOOT_OPENED")
  self:RegisterEvent("LOOT_CLOSED")
  self:RegisterEvent("PLAYER_TALENT_UPDATE");
  self:RegisterEvent("SPELLS_CHANGED");
  self:RegisterEvent("ACTIONBAR_HIDEGRID");
  self:RegisterEvent("UNIT_AURA");
  self:RegisterEvent("CHAT_MSG_ADDON");
  self:RegisterEvent("CHAT_MSG_CHANNEL");
  self:RegisterEvent("UPDATE_MOUSEOVER_UNIT");
  self:RegisterEvent("UNIT_SPELLCAST_FAILED");
  self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
  --auto template events
  self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
  self:RegisterEvent("GROUP_ROSTER_UPDATE")
  --One of them allows SmartBuff to be closed with the Escape key
  tinsert(UISpecialFrames, "SmartBuffOptionsFrame");
  UIPanelWindows["SmartBuffOptionsFrame"] = nil;

  SlashCmdList["SMARTBUFF"] = SMARTBUFF_command;
  SLASH_SMARTBUFF1 = "/sbo";
  SLASH_SMARTBUFF2 = "/sbuff";
  SLASH_SMARTBUFF3 = "/smartbuff";
  SLASH_SMARTBUFF4 = "/sb";

  SlashCmdList["SMARTBUFFMENU"] = SMARTBUFF_OptionsFrame_Toggle;
  SLASH_SMARTBUFFMENU1 = "/sbm";

  SlashCmdList["SmartReloadUI"] = function(msg) ReloadUI(); end;
  SLASH_SmartReloadUI1 = "/rui";

  SMARTBUFF_InitSpellIDs();
  
end
-- END SMARTBUFF_OnLoad


-- SMARTBUFF_OnEvent
function SMARTBUFF_OnEvent(self, event, ...)
  local arg1, arg2, arg3, arg4, arg5 = ...;

  if ((event == "UNIT_NAME_UPDATE" and arg1 == "player") or event == "PLAYER_ENTERING_WORLD") then
    if IsPlayerInGuild() and event == "PLAYER_ENTERING_WORLD" then
		C_ChatInfo.SendAddonMessage(SmartbuffPrefix, SmartbuffHeader.."¦"..SmartbuffCommands[1].."¦"..SmartbuffRevision.."¦"..SMARTBUFF_VERSION, "GUILD")
	end
	isPlayer = true;
    if  (event == "PLAYER_ENTERING_WORLD" and isInit and O.Toggle) then
      isSetZone = true;
      tStartZone = GetTime();
    end

  elseif(event == "ADDON_LOADED" and arg1 == SMARTBUFF_TITLE) then
    isLoaded = true;
  end

  -- PLAYER_LOGIN
  if event == "PLAYER_LOGIN" then
	local prefixResult = C_ChatInfo.RegisterAddonMessagePrefix(SmartbuffPrefix)
  end

  -- these two stop the tracking switcher when a loot window is opened
  -- otherwise if autoloot isnt on it can close the loot window when it
  -- does a switch.. gotta love these things..

  if event == "LOOT_OPENED" then
	  cLootOpenedDisable = true
      SMARTBUFF_AddMsgD("Loot window opened");
  end
  if event == "LOOT_CLOSED" then
	  cLootOpenedDisable = false
      SMARTBUFF_AddMsgD("Loot window closed");
  end

    -- CHAT_MSG_ADDON
  if event == "CHAT_MSG_ADDON" then
    local pktHeader, pktCmd, pktData1, pktData2
	if arg1 == SmartbuffPrefix then
		if arg2 then
            pktHeader, pktCmd, pktData1, pktData2 = strsplit("¦", arg2, 4)
            if pktHeader == SmartbuffHeader then
                if pktCmd == SmartbuffCommands[1] then  -- version packet
				    pktData1 = tonumber(pktData1)
                    if pktData1 > SmartbuffRevision and SmartbuffSession then
                        DEFAULT_CHAT_FRAME:AddMessage(SMARTBUFF_MSG_NEWVER1..SMARTBUFF_VERSION..SMARTBUFF_MSG_NEWVER2..pktData1..SMARTBUFF_MSG_NEWVER3)
					    SmartbuffSession = false
					end
                    if SmartbuffVerCheck then
					    if arg5 and arg5 ~= UnitName("player") then
						    DEFAULT_CHAT_FRAME:AddMessage("|cff00e0ffSmartbuff Versions: |cffFFFF00"..arg5.."|cffffffff has "..pktData2.." installed.") 
						end
					end
                elseif pktCmd == SmartbuffCommands[2] then  -- command packet   (future feature)
                elseif pktCmd == SmartbuffCommands[3] then  -- sync packet      (future feature)
                else
                    SMARTBUFF_AddMsgD("Warning: Received an unknown command packet to the addon.");
				end
            else
			    SMARTBUFF_AddMsgD("Warning: Not a valid packet header sent to the addon.");
            end 
		end
	end
  end

  if (event == "SMARTBUFF_UPDATE" and isLoaded and isPlayer and not isInit and not InCombatLockdown()) then
    SMARTBUFF_Options_Init(self);
  end

  if (not isInit or O == nil) then
    return;
  end;

  if (event == "PLAYER_REGEN_DISABLED") then
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
      if SMARTBUFF_IsFishingPoleEquiped() and O.WarnCombatFishingRod then   -- i'll add an option to turn this off later
	    -- warn the player he/she is in combat with a fishing pole equipped.
        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000Smartbuff Warning: |cffff6060"..SMARTBUFF_OFT_FRODWARN)
        PlaySound(12197);
	  end
    end

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

  elseif (event == "PLAYER_STARTED_MOVING") then
	isPlayerMoving = true;

  elseif (event == "PLAYER_STOPPED_MOVING") then
	isPlayerMoving = false;

  elseif (event == "PLAYER_TALENT_UPDATE") then
    if(SmartBuffOptionsFrame:IsVisible()) then
      SmartBuffOptionsFrame:Hide();
    end
    if (currentSpec ~= GetActiveTalentGroup()) then
      currentSpec = GetActiveTalentGroup();
      if (B[currentSpec] == nil) then
        B[currentSpec] = { };
      end
      SMARTBUFF_AddMsg(format(SMARTBUFF_MSG_SPECCHANGED, tostring(currentSpec)), true);
      isSetBuffs = true;
    end

  elseif (event == "SPELLS_CHANGED" or event == "ACTIONBAR_HIDEGRID") then
    isSetBuffs = true;
  end

  if (not O.Toggle) then
    return;
  end;

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

  if (event == "UI_ERROR_MESSAGE") then
    SMARTBUFF_AddMsgD(string.format("Error message: %s",arg1));
  end

  if (event == "UNIT_SPELLCAST_FAILED") then
    currentUnit = arg1;
    SMARTBUFF_AddMsgD(string.format("Spell failed: %s",arg1));
    if (currentUnit and (string.find(currentUnit, "party") or string.find(currentUnit, "raid") or (currentUnit == "target" and O.Debug))) then
      if (UnitName(currentUnit) ~= sPlayerName and O.BlacklistTimer > 0) then
        cBlacklist[currentUnit] = GetTime();
        if (currentUnit and UnitName(currentUnit)) then
        end
      end
    end
    currentUnit = nil;

  elseif (event == "UNIT_SPELLCAST_SUCCEEDED") then
    if (arg1 and arg1 == "player") then
      local unit = nil;
      local spell = nil;
      local target = nil;
      if (arg1 and arg2) then
        if (not arg3) then arg3 = ""; end
        if (not arg4) then arg4 = ""; end
        SMARTBUFF_AddMsgD("Spellcast succeeded: target " .. arg1 .. ", spellID " .. arg3 .. " (" ..GetSpellInfo(arg3) .. "), " .. arg4)
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
        end
      end
      if (isClearSplash) then
        isClearSplash = false;
        SMARTBUFF_Splash_Clear();
      end
    end
  end

  if event == "ZONE_CHANGED_NEW_AREA" or event == "GROUP_ROSTER_UPDATE" then
    SMARTBUFF_SetTemplate()
  end

end
-- END SMARTBUFF_OnEvent


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
      local specID = GetActiveTalentGroup()
      if (specID) then
        SMARTBUFF_OnEvent(self, "SMARTBUFF_UPDATE");
      end
    end
  else
    SMARTBUFF_Ticker();
    SMARTBUFF_Check(1);
    ToggleGatheringTrackers();
  end
end

function SMARTBUFF_Ticker(force)
  if (force or GetTime() > tTicker + 1) then
    tTicker = GetTime();
    if (isSyncReq or tTicker > tSync + 10) then
      SMARTBUFF_SyncBuffTimers();
    end
    if (isAuraChanged) then
      isAuraChanged = false;
      SMARTBUFF_Check(1, true);
    end
  end  
end

-- Will dump the value of msg to the default chat window
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

Enum.SmartBuffGroup = {
  Solo = 1,
  Party = 2,
  Raid = 3,
  Battleground = 4,
  Arena = 5,
  ICC = 6,
  TOC = 7,
  Ulduar = 7,
  Ony = 8,
  Naxx = 9,
  Custom1 = 10,
  Custom2 = 11,
  Custom3 = 12,
  Custom4 = 13,
  Custom5 = 14
}

-- Set the current template and create an array of units
local GatherDisableAnnounce = true
function SMARTBUFF_SetTemplate()
  if (InCombatLockdown()) then return end
  if (SmartBuffOptionsFrame:IsVisible()) then return end
  local newTemplate = currentTemplate 
  cDisableTrackSwitch = false;    -- on unless otherwise changed
  if O.AutoSwitchTemplate then
    newTemplate = SMARTBUFF_TEMPLATES[Enum.SmartBuffGroup.Solo];
    local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceID, instanceGroupSize, LfgDungeonID = GetInstanceInfo()
    if IsInRaid() then
      newTemplate = SMARTBUFF_TEMPLATES[Enum.SmartBuffGroup.Raid];
    elseif IsInGroup() then
      newTemplate = SMARTBUFF_TEMPLATES[Enum.SmartBuffGroup.Party];
    end
    -- check instance type (allows solo raid clearing, etc)
    if instanceType == "raid" then
      newTemplate = SMARTBUFF_TEMPLATES[Enum.SmartBuffGroup.Raid];
    elseif instanceType == "party" then
      newTemplate = SMARTBUFF_TEMPLATES[Enum.SmartBuffGroup.Party];
    end
  end
  -- if autoswitch on instance change is enabled, load new instance template if any
  local isRaidInstanceTemplate = false
  if O.AutoSwitchTemplateInst then
    local zone = GetRealZoneText()
    local instances = Enum.MakeEnumFromTable(SMARTBUFF_INSTANCES);
    local i = instances[zone]
    if i and SMARTBUFF_TEMPLATES[i + Enum.SmartBuffGroup.Arena] then
      newTemplate = SMARTBUFF_TEMPLATES[i + Enum.SmartBuffGroup.Arena]
      isRaidInstanceTemplate = true      
    end
  end
  if currentTemplate ~= newTemplate then
    SMARTBUFF_AddMsgD("Current tmpl: " .. currentTemplate or "nil" .. " - new tmpl: " .. newTemplate or "nil");
    SMARTBUFF_AddMsg(SMARTBUFF_TITLE.." :: "..SMARTBUFF_OFT_AUTOSWITCHTMP .. ": " .. currentTemplate .. " -> " .. newTemplate);
  end

  currentTemplate = newTemplate;

  SMARTBUFF_SetBuffs();
  wipe(cBlacklist);
  wipe(cBuffTimer);
  wipe(cUnits);
  wipe(cGroups);
  cClassGroups = nil;
  wipe(cAddUnitList);
  wipe(cIgnoreUnitList);

  -- Raid Setup, including smart instance templates
  if currentTemplate == (SMARTBUFF_TEMPLATES[Enum.SmartBuffGroup.Raid]) or isRaidInstanceTemplate then
    cClassGroups = { };
    local name, server, rank, subgroup, level, class, classeng, zone, online, isDead;
    local sRUnit = nil;
    -- do we want to disable the gathering switcher?
    if O.TrackDisableGrp and O.TrackSwitchActive then
        cDisableTrackSwitch = true;
        if GatherDisableAnnounce then   -- make sure we only announce the once for this session (unless a reloadui ofc)
            SMARTBUFF_AddMsg("Raid -> Auto gathering tracker disabled while in a raid, switching to preset (if any).");
            GatherDisableAnnounce = false
		end
	end
    -- do we have a fishing rod equipped and entered a raid?
    if SMARTBUFF_IsFishingPoleEquiped() and O.WarnGroupFishingRod then
      -- warn the player he/she has a fishing pole equipped.
      DEFAULT_CHAT_FRAME:AddMessage("|cffff0000Smartbuff Warning: |cffff6060"..SMARTBUFF_OFT_FRINSWARN)
      PlaySound(12197);
    end
    j = 1;
    for n = 1, maxRaid, 1 do
      name, rank, subgroup, level, class, classeng, zone, online, isDead = GetRaidRosterInfo(n);
      if (name) then
        server = nil;
        i = string.find(name, "-", 1, true);
        if (i and i > 0) then
          server = string.sub(name, i + 1);
          name   = string.sub(name, 1, i - 1);
          SMARTBUFF_AddMsgD(name .. ", " .. server);
        end
        sRUnit = "raid"..n;

        SMARTBUFF_AddUnitToClass("raid", n);
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
      end
    end --end for

    if (not b or B[CS()][currentTemplate].SelfFirst) then
      SMARTBUFF_AddSoloSetup();
    end

    SMARTBUFF_AddMsgD("Raid Unit-Setup finished");

  -- Party Setup
  elseif (currentTemplate == (SMARTBUFF_TEMPLATES[Enum.SmartBuffGroup.Party])) then
    cClassGroups = { };
    if O.TrackDisableGrp and O.TrackSwitchActive then
        cDisableTrackSwitch = true;
        SMARTBUFF_AddMsg("Party -> Auto gathering tracker disabled while in a party, switching to preset (if any).");
	end
    -- do we have a fishing rod equipped and entered a party?
    if SMARTBUFF_IsFishingPoleEquiped() and O.WarnGroupFishingRod then
      -- warn the player he/she is in combat with a fishing pole equipped.
      DEFAULT_CHAT_FRAME:AddMessage("|cffff0000Smartbuff Warning: |cffff6060"..SMARTBUFF_OFT_FRINSWARN)
      PlaySound(12197);
    end
    if (B[CS()][currentTemplate].SelfFirst) then
      SMARTBUFF_AddSoloSetup();
    end
    cGroups[1] = { };
    cGroups[1][0] = "player";
    SMARTBUFF_AddUnitToClass("player", 0);
    for j = 1, 4, 1 do
      cGroups[1][j] = "party"..j;
      SMARTBUFF_AddUnitToClass("party", j);
      SmartBuff_AddToUnitList(1, "party"..j, 1);
      SmartBuff_AddToUnitList(2, "party"..j, 1);
    end
    SMARTBUFF_AddMsgD("Party Unit-Setup finished");
  -- Solo Setup
  else
    SMARTBUFF_AddSoloSetup();
    SMARTBUFF_AddMsgD("Solo Unit-Setup finished");
  end
  --collectgarbage();
end


function SMARTBUFF_AddUnitToClass(unit, i)
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
    end
    if (uc) then
      cClassGroups[uc][i] = u;
    end
  end
end

function SMARTBUFF_AddSoloSetup()
  cGroups[0] = { };
  cGroups[0][0] = "player";
  cUnits[0] = { };
  cUnits[0][0] = "player";
  if (sPlayerClass == "HUNTER" or sPlayerClass == "WARLOCK" or sPlayerClass == "DEATHKNIGHT" or sPlayerClass == "MAGE") then cGroups[0][1] = "pet"; end
  if (B[CS()][currentTemplate] and B[CS()][currentTemplate].SelfFirst) then
    if (not cClassGroups) then
      cClassGroups = { };
    end
    cClassGroups[0] = { };
    cClassGroups[0][0] = "player";
  end
end
-- END SMARTBUFF_SetUnits


-- Get Spell ID from spellbook
function SMARTBUFF_GetSpellID(spellname)
  local i, id = 1, nil;
  local spellN, spellId, skillType;
  if (spellname) then
    spellname = string.lower(spellname);
  else
    return nil;
  end
  while GetSpellBookItemName(i, BOOKTYPE_SPELL) do
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
    i = i + 1;
  end
  if (id) then
    if (IsPassiveSpell(id) or skillType == "FUTURESPELL" or not IsSpellKnown(id)) then
      id = nil;
      i = nil;
    end
  end
  return id, i;
end
-- END SMARTBUFF_GetSpellID

-- Set the buff array
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

  InitBuffOrder(false);

  numBuffs = n - 1;
  isSetBuffs = false;
end

function SMARTBUFF_SetBuff(buff, i, ia)
  if (buff == nil or buff[1] == nil) then return i; end
  cBuffs[i] = nil;
  cBuffs[i] = { };
  cBuffs[i].BuffS = buff[1];
  cBuffs[i].DurationS = ceil(buff[2] * 60);
  cBuffs[i].Type = buff[3];
  cBuffs[i].CanCharge = false;

  if (SMARTBUFF_IsSpell(cBuffs[i].Type)) then
    cBuffs[i].IDS, cBuffs[i].BookID = SMARTBUFF_GetSpellID(cBuffs[i].BuffS);
  end

  if (cBuffs[i].IDS == nil and not(SMARTBUFF_IsItem(cBuffs[i].Type) or cBuffs[i].Type == SMARTBUFF_CONST_TRACK)) then
    cBuffs[i] = nil;
    return i;
  end

  if (buff[4] ~= nil) then cBuffs[i].LevelsS = buff[4] else cBuffs[i].LevelsS = nil end
  if (buff[5] ~= nil) then cBuffs[i].Params = buff[5] else cBuffs[i].Params = SG.NIL end
  cBuffs[i].Links = buff[6];
  cBuffs[i].Chain = buff[7];

  if (cBuffs[i].IDS ~= nil) then
    cBuffs[i].IconS = GetSpellTexture(cBuffs[i].BuffS);
  else
    if (cBuffs[i].Type == SMARTBUFF_CONST_TRACK) then
      local b = false;
      for n = 1, C_Minimap.GetNumTrackingTypes() do
	      local trackN, trackT, trackA, trackC = C_Minimap.GetTrackingInfo(n);
	      if (trackN ~= nil) then
	        if (trackN == cBuffs[i].BuffS) then
	          b = true;
	          cBuffs[i].IDS = nil;
	          cBuffs[i].IconS = trackT;
	        end
	      end
      end
      if (not b) then
        cBuffs[i] = nil;
        return i;
      end
    elseif (ia or cBuffs[i].Type == SMARTBUFF_CONST_ITEMGROUP) then
      local _, _, _, _, minLevel, _, _, _, _, texture = GetItemInfo(cBuffs[i].BuffS);
      if (not IsMinLevel(minLevel)) then
        cBuffs[i] = nil;
        return i;
      end
      cBuffs[i].IconS = texture;
    else
      local _, _, _, _, minLevel = GetItemInfo(cBuffs[i].BuffS);
      if (not IsMinLevel(minLevel)) then
        cBuffs[i] = nil;
        return i;
      end
      local _, _, count, texture = SMARTBUFF_FindItem(cBuffs[i].BuffS, cBuffs[i].Chain);

      if count then
	      if (count <= 0) then
            cBuffs[i] = nil;
            return i;
          end
      else
        cBuffs[i] = nil;
        return i;
      end
      cBuffs[i].IconS = texture;
    end
  end

  SMARTBUFF_AddMsgD("Add "..buff[1]);

  cBuffs[i].BuffG = nil; --buff[6]; -- Disabled for Cataclysm
  cBuffs[i].IDG = nil; --SMARTBUFF_GetSpellID(cBuffs[i].BuffG);
  if (cBuffs[i].IDG ~= nil) then
    cBuffs[i].IconG = GetSpellTexture(cBuffs[i].BuffG);
  else
    cBuffs[i].IconG = nil;
  end
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

  -- If buffs can't casted, hide UI elements
  if (UnitInVehicle("player") or UnitHasVehicleUI("player")) then
    if (not InCombatLockdown() and SmartBuff_KeyButton:IsVisible()) then
      SmartBuff_KeyButton:Hide();
    end
    return false;
  else
    SMARTBUFF_ShowSAButton();
  end

  SMARTBUFF_SetButtonTexture(SmartBuff_KeyButton, imgSB);
  if (SmartBuffOptionsFrame:IsVisible()) then return false; end

  -- check for mount-spells
  if (sPlayerClass == "PALADIN" and (IsMounted() or IsFlying()) and not SMARTBUFF_CheckBuff("player", SMARTBUFF_CRUSADERAURA)) then
    return true;
  elseif (sPlayerClass == "DEATHKNIGHT" and IsMounted() and not SMARTBUFF_CheckBuff("player", SMARTBUFF_PATHOFFROST)) then
    return true;
  end
  if ((mode == 1 and not O.ToggleAuto) or IsMounted() and not O.ToggleMountedPrompt or IsFlying() or LootFrame:IsVisible()
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
        SMARTBUFF_AddMsgD(UnitName(unit) .. ": unit timer reseted");
      end
      if (cBuffTimer[uc]) then
        cBuffTimer[uc] = nil;
        SMARTBUFF_AddMsgD(uc .. ": class timer reseted");
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
              SMARTBUFF_AddMsg(string.format("%s: %s, time left: %.0f, rebuff time: %.0f", s, buff, tl, rbTime));
            else
              cBuffTimer[unit][buff] = nil;
            end
          else
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

  local cGrp = cGroups;
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
            if (buffS and B[CS()][ct][buffS].EnableS and cBuffs[i].IDS ~= nil and cBuffs[i].DurationS > 0) then
              if (cBuffs[i].Type ~= SMARTBUFF_CONST_SELF or (cBuffs[i].Type == SMARTBUFF_CONST_SELF and SMARTBUFF_IsPlayer(unit))) then
                SMARTBUFF_SyncBuffTimer(unit, unit, cBuffs[i]);
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


function SMARTBUFF_SyncBuffTimer(unit, grp, cBuff)
  if (not unit or not grp or not cBuff) then return end
  local d = cBuff.DurationS;
  local buff = cBuff.BuffS;
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

-- build spell rank info.
local function buildSpellRankInfo(spell)
  local spellName, spellSubName, name, spellID;
  local rank = 1;
  cSpellRankInfo = {};  -- always clear it
  for i = 1, 300 do -- 300 is more than enough
    spellName, spellSubName = GetSpellBookItemName(i, BOOKTYPE_SPELL);
    if spellName == spell then
        name, _, _, _, _, _, spellID, _ = GetSpellInfo(spellName.."("..spellSubName..")");
        tinsert(cSpellRankInfo, {rank, spellName, spellSubName, spellName.."("..spellSubName..")", spellID});
        rank = rank + 1;
	end
  end  
end

-- get spell rank info
local function getSpellRankInfo(rank)
  for rankcount, ranks in ipairs(cSpellRankInfo) do 
      if ranks[1] == rank then
      return ranks[1], ranks[2], ranks[3], ranks[4], ranks[5];
      end
  end
end

-- make sure we have the correct rank to cast for unit.
local function SMARTBUFF_CheckSpellLevel(spell, unit, buffLevels)  
  if not buffLevels then return nil; end
  local uLevel = nil; 
  local bSpellRank = 0;  
  local rank, spellName, spellSubName, spellNameRank, spellID;
  uLevel = UnitLevel(unit);   
  if uLevel == 80 then return nil; end  -- no reason to down-rank on a max level, just exit.
  buildSpellRankInfo(spell);  
  -- get rank
  for count, levelrange in next, buffLevels do 
	  if uLevel >= levelrange then 
		  bSpellRank = count;
	  end 
  end
  rank, spellName, spellSubName, spellNameRank, spellID = getSpellRankInfo(bSpellRank)
  return rank, spellName, spellSubName, spellNameRank, spellID;
end

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

  SMARTBUFF_checkBlacklist();

  -- 1. check in combat buffs
  if (InCombatLockdown()) then -- and O.InCombat
    for spell in pairs(cBuffsCombat) do
      if (spell) then
        local ret, actionType, spellName, slot, unit, buffType = SMARTBUFF_BuffUnit("player", 0, mode, spell)
        SMARTBUFF_AddMsgD("Check combat spell: " .. spell .. ", ret = " .. ret);
        if (ret and ret == 0) then
          IsChecking = false;
          return;
        end
      end
    end
  end

  -- 2. buff target, if enabled
  if ((mode == 0 or mode == 5) and O.BuffTarget) then
    local actionType, spellName, slot, buffType;
    i, actionType, spellName, slot, _, buffType = SMARTBUFF_BuffUnit("target", 0, mode);
    if (i <= 1) then
      if (i == 0) then
        --tLastCheck = GetTime() - O.AutoTimer + GlobalCd;
      end
      IsChecking = false;
      return i, actionType, spellName, slot, "target", buffType;
    end
  end

  -- 3. check groups
  local cGrp = cGroups;
  local cOrd = cOrderGrp;
  isMounted = IsMounted() or IsFlying();

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

      -- check buffs
      if (units) then
        for _, unit in pairs(units) do
          if (isSetBuffs) then break; end
          SMARTBUFF_AddMsgD("Checking single unit = "..unit);
          local spellName, actionType, slot, buffType;
          i, actionType, spellName, slot, _, buffType = SMARTBUFF_BuffUnit(unit, subgroup, mode);

          if (i <= 1) then
            if (i == 0 and mode ~= 1) then
              --tLastCheck = GetTime() - O.AutoTimer + GlobalCd;
              if (actionType == SMARTBUFF_ACTION_ITEM) then
                --tLastCheck = tLastCheck + 2;
              end
            end
            IsChecking = false;
            return i, actionType, spellName, slot, unit, buffType;
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
  local spellNameRank = nil

  if (UnitIsPVP("player")) then isPvP = true end

  SMARTBUFF_CheckUnitBuffTimers(unit);
  
  isPrompting = false;

  if (UnitExists(unit) and UnitIsFriend("player", unit) and not UnitIsDeadOrGhost(unit) and not UnitIsCorpse(unit) and (UnitInRange(unit) or unit == "player" or unit == "target"))
    and UnitIsConnected(unit) and UnitIsVisible(unit) and not UnitOnTaxi(unit) and not cBlacklist[unit] and ((not UnitIsPVP(unit) and (not isPvP or O.BuffPvP)) or (UnitIsPVP(unit) 
	and (isPvP or O.BuffPvP))) then

    _, uc = UnitClass(unit);
    un = UnitName(unit);
    ur = UnitGroupRolesAssigned(unit);
    uct = UnitCreatureType(unit);
    ucf = UnitCreatureFamily(unit);
    if (uct == nil) then uct = ""; end
    if (ucf == nil) then ucf = ""; end

    isShapeshifted, sShapename = SMARTBUFF_IsShapeshifted();
    for i, buffnS in pairs(B[CS()].Order) do
      if (isSetBuffs or SmartBuffOptionsFrame:IsVisible()) then break; end
      cBuff = cBuffs[cBuffIndex[buffnS]];
      bs = GetBuffSettings(buffnS);
      bExpire = false;
      handtype = "";
      charges = -1;
      bufftarget = nil;
      bUsable = false;
      iId = nil;
      iSlot = -1;

      if (cBuff and bs) then bUsable = bs.EnableS end

      if (bUsable and spell and spell ~= buffnS) then
        bUsable = false;
        SMARTBUFF_AddMsgD("Exclusive check on " .. spell .. ", current spell = " .. buffnS);
      end
      if (bUsable and cBuff.Type == SMARTBUFF_CONST_SELF and not SMARTBUFF_IsPlayer(unit)) then bUsable = false end
      if (bUsable and not cBuff.Type == SMARTBUFF_CONST_TRACK and not SMARTBUFF_IsItem(cBuff.Type) and not IsUsableSpell(buffnS)) then bUsable = false end
      if (bUsable and bs.SelfNot and SMARTBUFF_IsPlayer(unit)) then bUsable = false end
      if (bUsable and cBuff.Params == SG.CheckFishingPole and SMARTBUFF_IsFishingPoleEquiped()) then bUsable = false end

      -- Check for buffs which depends on a pet
      if (bUsable and cBuff.Params == SG.CheckPet and UnitExists("pet")) then bUsable = false end
      if (bUsable and cBuff.Params == SG.CheckPetNeeded and not UnitExists("pet")) then bUsable = false end

      -- Check for mount auras
      if (bUsable and (sPlayerClass == "PALADIN" or sPlayerClass == "DEATHKNIGHT")) then
        isMounted = false;
        if (sPlayerClass == "PALADIN") then
          isMounted = IsMounted() or IsFlying();
          if ((buffnS ~= SMARTBUFF_CRUSADERAURA and isMounted) or (buffnS == SMARTBUFF_CRUSADERAURA and not isMounted)) then
            bUsable = false;
          end
        elseif (sPlayerClass == "DEATHKNIGHT") then
          isMounted = IsMounted();
          if (buffnS ~= SMARTBUFF_PATHOFFROST and isMounted) then
            bUsable = false;
          end
        end
      end

      -- tracking switching, check if we are active and not disabled while in a raid.
      if (bUsable and O.TrackSwitchActive and not cDisableTrackSwitch) and (buffnS == SMARTBUFF_FINDMINERALS or buffnS == SMARTBUFF_FINDHERBS or buffnS == SMARTBUFF_FINDFISH) then
        SMARTBUFF_AddMsgD(buffnS..SMARTBUFF_TRACKSWITCHMSG)
        bUsable = false;
      end

      -- check for mage conjured items
      if (bUsable and sPlayerClass == "MAGE") then
	    local lookupData
        if (buffnS == SMARTBUFF_CONJFOOD or buffnS == SMARTBUFF_CONJREFRESHMENT) then lookupData = ConjuredMageFood
		elseif (buffnS == SMARTBUFF_CONJWATER or buffnS == SMARTBUFF_CONJREFRESHMENT) then lookupData = ConjuredMageWater
		elseif buffnS == SMARTBUFF_CREATEMGEM then lookupData = ConjuredMageGems end
        if lookupData and isPlayerMoving == false then
	        for count, value in next, lookupData do  
		        if value then 
                    itemInfo = GetItemInfo(value)
                    if SMARTBUFF_CheckBagItem(itemInfo) then
				        bUsable = false;
				    end
		        end
	        end
        elseif lookupData and isPlayerMoving then
            bUsable = false;
		end
	  end
      
      -- check for warlock conjured items
      if (bUsable and sPlayerClass == "WARLOCK") then
          local itemInfo, bag, slot, count, maxHealth, currentHealth, lookupData
          itemInfo = GetItemInfo(6265)  -- 6265 is id for soul shards
          if SMARTBUFF_CheckBagItem(itemInfo) then  -- only if we have soul shards
              -- point to the correct data.
              if buffnS == SMARTBUFF_CREATEHS then lookupData = ConjuredLockHealthStones
			  elseif buffnS == SMARTBUFF_CREATESOULS then lookupData = ConjuredLockSoulstones
			  elseif buffnS == SMARTBUFF_CREATESPELLS then lookupData = ConjuredLockSpellstones
			  elseif buffnS == SMARTBUFF_CREATEFIRES then lookupData = ConjuredLockFirestones end
              if lookupData and isPlayerMoving == false then
	              for count, value in next, lookupData do  
		              if value then 
                          itemInfo = GetItemInfo(value)
                          if SMARTBUFF_CheckBagItem(itemInfo) then
				              bUsable = false;
				          end
		              end
	              end
              elseif lookupData and isPlayerMoving then
                bUsable = false;
			  end
          else
              SMARTBUFF_AddMsgD(itemInfo.." is missing in bag, cannot continue.");
		  end
          -- am i being prompted to use a healthstone,
          -- check my health so im not spammed.
          currentHealth = UnitHealth("player")
          maxHealth = UnitHealthMax("player");
          for count, value in next, ConjuredLockHealthStones do  
		    if value then 
                _,itemInfo = GetItemInfo(value)
                if buffnS == itemInfo and currentHealth == maxHealth then
				    bUsable = false;
				end
		    end
	      end
	  end

      -- extra testing for revive pet on hunters, 
	  -- only allow if the pet is actually dead
      if (bUsable and sPlayerClass == "HUNTER") and buffnS == SMARTBUFF_REVIVEPET then
	    if not UnitIsDead("pet") then
            SMARTBUFF_AddMsgD("Pet appears to be very much alive!");
		    bUsable = false;
        else
            SMARTBUFF_AddMsgD("Pet appears to be dead, revive available.");
		end
	  end


      if (bUsable and not (cBuff.Type == SMARTBUFF_CONST_TRACK or SMARTBUFF_IsItem(cBuff.Type))) then
        -- check if you have enough mana/rage/energy to cast
        local isUsable, notEnoughMana = IsUsableSpell(buffnS);
        if (notEnoughMana) then
          bUsable = false;
          SMARTBUFF_AddMsgD("Buff " .. cBuff.BuffS .. ", not enough mana!");
        elseif (mode ~= 1 and isUsable == nil and buffnS ~= SMARTBUFF_PWS) then
          bUsable = false;
          SMARTBUFF_AddMsgD("Buff " .. cBuff.BuffS .. " is not usable!");
        end
      end

      if (bUsable and bs.EnableS and (cBuff.IDS ~= nil or SMARTBUFF_IsItem(cBuff.Type) or cBuff.Type == SMARTBUFF_CONST_TRACK)
        and ((mode ~= 1 and ((isCombat and bs.CIn) or (not isCombat and bs.COut)))
        or (mode == 1 and bs.Reminder and ((not isCombat and bs.COut)
        or (isCombat and (bs.CIn or O.ToggleAutoCombat)))))) then

        -- do we want to have normal camera zoom when buffing?
        if not O.ScrollWheelZooming then isPrompting = true; end

        if (not bs.SelfOnly or (bs.SelfOnly and SMARTBUFF_IsPlayer(unit))) then
          -- get current spell cooldown
          cd = 0;
          cds = 0;
          if (cBuff.IDS) then
            cds, cd = GetSpellCooldown(buffnS);
            cd = (cds + cd) - GetTime();
            if (cd < 0) then
              cd = 0;
            end
            SMARTBUFF_AddMsgD(buffnS.." cd = "..cd);
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

            SMARTBUFF_AddMsgD(uc.." "..CT());

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

              -- Tracking ability ------------------------------------------------------------------------
              if (cBuff.Type == SMARTBUFF_CONST_TRACK) then
                local count = C_Minimap.GetNumTrackingTypes();
                for n = 1, C_Minimap.GetNumTrackingTypes() do
	                local trackN, trackT, trackA, trackC = C_Minimap.GetTrackingInfo(n);
	                if (trackN ~= nil and not trackA) then
	                  SMARTBUFF_AddMsgD(n..". "..trackN.." ("..trackC..")");
	                  if (trackN == buffnS) then
	                    if (sPlayerClass == "DRUID" and buffnS == SMARTBUFF_DRUID_TRACK) then
	                      if (isShapeshifted and sShapename == SMARTBUFF_DRUID_CAT) then
                          buff = buffnS;
                          C_Minimap.SetTracking(n, 1);      -- bugfix: not referencing C_Minimap. 7/5/2023
                        end
                      else
                        buff = buffnS;
                        C_Minimap.SetTracking(n, 1);
                      end
                      if (buff ~= nil) then
	                      SMARTBUFF_AddMsgD("Tracking enabled: "..buff);
	                      buff = nil;
	                    end
	                  end
	                end
                end

              -- Food, Scroll, Potion or conjured items ------------------------------------------------------------------------
              elseif (cBuff.Type == SMARTBUFF_CONST_FOOD or cBuff.Type == SMARTBUFF_CONST_SCROLL or cBuff.Type == SMARTBUFF_CONST_POTION or cBuff.Type == SMARTBUFF_CONST_ITEM or
                cBuff.Type == SMARTBUFF_CONST_ITEMGROUP) then

        				if (cBuff.Type == SMARTBUFF_CONST_ITEM) then
      				    bt = nil;
      				    buff = nil;
      				    if (cBuff.Params ~= SG.NIL) then
    				        local cr = SMARTBUFF_CountReagent(cBuff.Params, cBuff.Chain);
    				        SMARTBUFF_AddMsgD(cr.." "..cBuff.Params.." found");
    				        if (cr == 0) then
    				            buff = cBuff.Params;
    				        end
      				    end

                -- dont attempt to use food while moving or we will waste them.
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
      			        SMARTBUFF_AddMsgD("Buff time ("..cBuff.Params..") = "..tostring(bt));
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
                        cd = (cds + cd) - GetTime();
                        SMARTBUFF_AddMsgD(cr.." "..buffnS.." found, cd = "..cd);
                        if (cd > 0) then
                          buff = nil;
                        end
                      end
                      SMARTBUFF_AddMsgD(cr .. " " .. buffnS .. " found");
                    else
                      SMARTBUFF_AddMsgD("No " .. buffnS .. " found");
                      buff = nil;
                      bExpire = false;
                    end
                  end
                end

              -- Weapon buff ------------------------------------------------------------------------

              elseif (cBuff.Type == SMARTBUFF_CONST_WEAPON or cBuff.Type == SMARTBUFF_CONST_INV) then
                SMARTBUFF_AddMsgD("Check weapon Buff");
                hasMainHandEnchant, mainHandExpiration, mainHandCharges, mainHandEnchantID, hasOffHandEnchant, offHandExpiration, offHandCharges, offHandEnchantID = GetWeaponEnchantInfo();
                bMh = hasMainHandEnchant;
                tMh = mainHandExpiration;
                cMh = mainHandCharges;
                bOh = hasOffHandEnchant;
                tOh = offHandExpiration;
                cOh = offHandCharges;

                if (bs.MH) then
                  iSlot = 16;
                  iId = GetInventoryItemID("player", iSlot);
                  if (iId and SMARTBUFF_CanApplyWeaponBuff(buffnS, iSlot)) then
                    if (bMh) then
                      if (rbTime > 0 and cBuff.DurationS >= 1) then
                        tMh = floor(tMh/1000);
                        charges = cMh;
                        if (charges == nil) then charges = -1; end
                        if (charges > 1) then cBuff.CanCharge = true; end
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
                  iSlot = 17
                  iId = GetInventoryItemID("player", iSlot);
                  if (iId and SMARTBUFF_CanApplyWeaponBuff(buffnS, iSlot)) then
                    if (bOh) then
                      if (rbTime > 0 and cBuff.DurationS >= 1) then
                        tOh = floor(tOh/1000);
                        charges = cOh;
                        if (charges == nil) then charges = -1; end
                        if (charges > 1) then cBuff.CanCharge = true; end
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
                    SMARTBUFF_AddMsgD(cr .. " " .. buffnS .. " found");
                  else
                    SMARTBUFF_AddMsgD("No " .. buffnS .. " found");
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
                        if type(bt) ~= "number" then
                            bt = 0
                        end
                      if (not bt or bt - tbt > rbTime) then
                        bt = tbt;
                      end
                    end
                    bufftarget = nil;
                  elseif (cBuffTimer[unit] ~= nil and cBuffTimer[unit][buffnS] ~= nil) then
                    bt = cBuff.DurationS - (time - cBuffTimer[unit][buffnS]);
                    bufftarget = nil;
                  elseif (cBuff.BuffG ~= nil and cBuffTimer[subgroup] ~= nil and cBuffTimer[subgroup][cBuff.BuffG] ~= nil) then
                    bt = cBuff.DurationG - (time - cBuffTimer[subgroup][cBuff.BuffG]);
                    if (type(subgroup) == "number") then
                      bufftarget = SMARTBUFF_MSG_GROUP .. " " .. subgroup;
                    else
                      bufftarget = SMARTBUFF_MSG_CLASS .. " " .. UnitClass(unit);
                    end
                  elseif (cBuff.BuffG ~= nil and cBuffTimer[uc] ~= nil and cBuffTimer[uc][cBuff.BuffG] ~= nil) then
                    bt = cBuff.DurationG - (time - cBuffTimer[uc][cBuff.BuffG]);
                    bufftarget = SMARTBUFF_MSG_CLASS .. " " .. UnitClass(unit);
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
                end

              end -- END normal buff

              -- check if shapeshifted and cancel buff if it is not possible to cast it
              if (buff and cBuff.Type ~= SMARTBUFF_CONST_TRACK and cBuff.Type ~= SMARTBUFF_CONST_FORCESELF) then
                if (isShapeshifted) then
                  if (string.find(cBuff.Params, sShapename)) then
                  else
                    if(cBuff.Params == SMARTBUFF_DRUID_CAT) then
                      buff = nil;
                    end
                    if (buff and mode ~= 1 and not O.InShapeshift and (sShapename ~= SMARTBUFF_DRUID_MOONKIN and sShapename ~= SMARTBUFF_DRUID_TREANT)) then
                      buff = nil;
                    end
                  end
                elseif(cBuff.Params == SMARTBUFF_DRUID_CAT) then
                    buff = nil;
                end
              end

              if (buff) then 

                if (cBuff.IDS) then
                  SMARTBUFF_AddMsgD("Checking " ..i .. " - " .. cBuff.IDS .. " " .. buffnS);
                end

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
                        return 0, SMARTBUFF_ACTION_ITEM, GetItemInfo(buffnS), iSlot, "player", cBuff.Type;
                      end
                    end
                    r = 50;
                  elseif (cBuff.Type == SMARTBUFF_CONST_WEAPON) then
                    if (iId and (handtype ~= "" or bExpire)) then
                      sMsgWarning = "";
                      return 0, SMARTBUFF_ACTION_SPELL, buffnS, iSlot, "player", cBuff.Type;
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
                    r = SMARTBUFF_doCast(unit, cBuff.IDS, buffnS, cBuff.LevelsS, cBuff.Type);
                    if (r == 0) then
                      currentUnit = unit;
                      currentSpell = buffnS;
                    end
                  end

                -- Check mode ---------------------------------------------------------------------------------------
                elseif (mode == 1) then
                  currentUnit = nil;
                  currentSpell = nil;                  
                  if type(bt) ~= "number" then bt = 0; end    
                  if (bufftarget == nil) then bufftarget = un; end
                  if (cBuff.IDS ~= nil or SMARTBUFF_IsItem(cBuff.Type) or cBuff.Type == SMARTBUFF_CONST_TRACK) then
                    -- clean up buff timer, if expired
                    if (bt and bt < 0 and bExpire) then
                      bt = 0;
                      if (cBuffTimer[unit] ~= nil and cBuffTimer[unit][buffnS] ~= nil) then
                        cBuffTimer[unit][buffnS] = nil;
                      end
                      if (cBuff.IDG ~= nil) then
                        if (cBuffTimer[subgroup] ~= nil and cBuffTimer[subgroup][cBuff.BuffG] ~= nil) then
                          cBuffTimer[subgroup][cBuff.BuffG] = nil;
                        end
                        if (cBuffTimer[uc] ~= nil and cBuffTimer[uc][cBuff.BuffG] ~= nil) then
                          cBuffTimer[uc][cBuff.BuffG] = nil;
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
                  _, _, _, spellNameRank, _ = SMARTBUFF_CheckSpellLevel(buffnS, unit, cBuff.LevelsS)
                  if spellNameRank then
                    -- we have ranks, process them.
                    SMARTBUFF_AddMsgD("Buff down-ranked to: " .. spellNameRank);
                    return 0, SMARTBUFF_ACTION_SPELL, spellNameRank, -1, unit, cBuff.Type;
				  else
                    -- nothing special here, just continue.
                    return 0, SMARTBUFF_ACTION_SPELL, buffnS, -1, unit, cBuff.Type;
                  end
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
                  if (mode == 0) then SMARTBUFF_AddMsgD(buffnS .. " could not be buffed on " .. un); end
                elseif (r == 20) then
                  -- item not found
                  if (mode == 0) then SMARTBUFF_AddMsgD(buffnS .. " could not be used"); end
                elseif (r == 50) then
                  -- weapon buff could not applied
                  if (mode == 0) then SMARTBUFF_AddMsgD(buffnS .. " could not be applied"); end
                else
                  -- no spell selected
                  if (mode == 0) then SMARTBUFF_AddMsgD(SMARTBUFF_MSG_CHAT); end
                end
              end
            end
          else
            -- cooldown
            if (sMsgWarning == "") then
              sMsgWarning = SMARTBUFF_MSG_CD;
            end
          end
        end -- group or self
      end
    end -- for buff
  end
  isPrompting = false
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
  if (type == SMARTBUFF_CONST_TRACK and (GetTrackingTexture() ~= "Interface\\Minimap\\Tracking\\None")) then
    return 7;
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
  -- Rangecheck
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
  -- check if you have enough mana/energy/rage to cast
  local isUsable, notEnoughMana = IsUsableSpell(spellName);
  if (notEnoughMana) then
    return 6;
  end
  return 0;
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

-- Will return the name of the buff to cast
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
            timeleft = timeleft - GetTime();
            if (timeleft > 0) then
	            timeleft = timeleft;
            else
                timeleft = time;
            end
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
      --SMARTBUFF_AddMsgD("Check chained buff ("..uname.."): "..defBuff);
      for i = 1, #t, 1 do
        if (t[i] and tfind(buffC, t[i])) then
          v = GetBuffSettings(t[i]);
          if (v and v.EnableS) then
            local b, tl, im = SMARTBUFF_CheckBuff(unit, t[i]);
            if (b and im) then
              --SMARTBUFF_AddMsgD("Chained buff found: "..t[i]..", "..tl);
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
    SMARTBUFF_AddMsgD("Check default buff ("..uname.."): "..defBuff);
    buff, icon, count, _, duration, timeleft, caster = UnitBuffByBuffName(unit, defBuff);
    if (buff) then
      timeleft = timeleft - GetTime();
  if (timeleft > 0) then
	timeleft = timeleft;
  else
    timeleft = time;
  end
      if (SMARTBUFF_IsPlayer(caster)) then
        SMARTBUFF_UpdateBuffDuration(defBuff, duration);
      end
      SMARTBUFF_AddMsgD("Default buff found: "..buff..", "..timeleft..", "..icon);
      return nil, 0, defBuff, timeleft, count;
    end
  end
  -- Buff not found, return default buff
  return defBuff, nil, nil, nil, nil;
end


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
            timeleft = timeleft - GetTime();
            if (timeleft > 0) then
	          timeleft = timeleft;
            else
              timeleft = time;
            end
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


function UnitAuraBySpellName(target,spellname,filter)
  for i = 1,40 do
    name = UnitAura(target, i, filter);
    if not name then return end
    if name == spellname then
      return UnitAura(target, i, filter);
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
      if (timeleft > 0) then
        timeleft = timeleft;
      else
        timeleft = time;
      end
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
-- we now search on ItemLink in addition to itemText, in order to support Dragonflight item qualities
function SMARTBUFF_CountReagent(reagent, chain)
  if (reagent == nil) then
    return -1, nil;
  end
  local total = 0;
  local id = nil;
  local bag = 0;
  local slot = 0;
  if not (chain) then chain = { reagent }; end
  for bag = 0, NUM_BAG_FRAMES do
    for slot = 1, C_Container.GetContainerNumSlots(bag) do
      bagItemID = C_Container.GetContainerItemID(bag, slot)
      if bagItemID then
        containerInfo = C_Container.GetContainerItemInfo(bag, slot);
        --SMARTBUFF_AddMsgD("Reagent found: " .. C_Container.GetContainerItemLink(bag.slot));
        for i = 1, #chain, 1 do
          local buffItemID = tonumber(string.match(chain[i], "item:(%d+)"))
          if bagItemID == buffItemID then
            
            id = buffItemID
            total = total + containerInfo.stackCount;
          end
        end
      end
    end
  end
  return total, id;
end

-- these two functions are basically identical and should be merged
function SMARTBUFF_FindItem(reagent, chain)
  if (reagent == nil) then
    return nil, nil, -1, nil;
  end
  local n = 0;
  local bag = 0;
  local slot = 0;
  if not (chain) then chain = { reagent }; end
  for bag = 0, NUM_BAG_FRAMES do
    for slot = 1, C_Container.GetContainerNumSlots(bag) do
      bagItemID = C_Container.GetContainerItemID(bag, slot);
      if (bagItemID) then
        --SMARTBUFF_AddMsgD("Reagent found: " .. C_Container.GetContainerItemLink(bag.slot));
        for i = 1, #chain, 1 do
          if tonumber(string.match(chain[i], "item:(%d+)")) == bagItemID then
            containerInfo = C_Container.GetContainerItemInfo(bag, slot);
            return bag, slot, containerInfo.stackCount, containerInfo.iconFileID;
          end
        end
      end
    end
  end
  return nil, nil, 0, nil;
end
-- END Reagent functions


-- Locate item in the bags, used to locate conjured items etc.
function SMARTBUFF_CheckBagItem(itemName)
  local bag = 0;
  local slot = 0;
  local bagItemID, bagItemName, itemQuery; 
  if not itemName then return false; end
  itemQuery = itemName; itemName = { itemName };
  for bag = 0, NUM_BAG_FRAMES do
    for slot = 1, C_Container.GetContainerNumSlots(bag) do
      bagItemID = C_Container.GetContainerItemID(bag, slot);
      if (bagItemID) then
        bagItemName = GetItemInfo(bagItemID)
        if string.match(bagItemName, itemQuery) then
		    return true
		end
      end
    end
  end
  return false
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
local smVerWarn = true
function SMARTBUFF_Options_Init(self)

  if (isInit) then return; end

  -- test if this is the intended client
  if (buildInfo < SMARTBUFF_VERSIONNR) or (buildInfo > 100000) then    
    if smVerWarn then 
        DEFAULT_CHAT_FRAME:AddMessage("|cff00e0ffSmartbuff Build "..SMARTBUFF_VERSION.." (Client: "..buildInfo..")|cffffffff "..SMARTBUFF_NOTINTENDEDCLIENT)
	end
    smVerWarn = false;
    return
  end 

  self:UnregisterEvent("CHAT_MSG_CHANNEL");
  self:UnregisterEvent("UPDATE_MOUSEOVER_UNIT");

  _, sPlayerClass = UnitClass("player");
  sRealmName = GetRealmName();
  sPlayerName = UnitName("player");
  sID = sRealmName .. ":" .. sPlayerName;

  SMARTBUFF_PLAYERCLASS = sPlayerClass;


  if (not SMARTBUFF_Buffs) then SMARTBUFF_Buffs = { }; end
  B = SMARTBUFF_Buffs;
  if (not SMARTBUFF_Options) then SMARTBUFF_Options = { }; end
  O = SMARTBUFF_Options;

  SMARTBUFF_BROKER_SetIcon();

  if (O.Toggle == nil) then O.Toggle = true; end
  if (O.ToggleAuto == nil) then O.ToggleAuto = true; end
  if (O.AutoTimer == nil) then O.AutoTimer = 5; end
  if (O.BlacklistTimer == nil) then O.BlacklistTimer = 5; end
  if (O.ToggleAutoCombat == nil) then O.ToggleAutoCombat = false; end
  if (O.ToggleAutoChat == nil) then O.ToggleAutoChat = false; end
  if (O.ToggleAutoSplash == nil) then O.ToggleAutoSplash = true; end
  if (O.ToggleAutoSound == nil) then O.ToggleAutoSound = true; end
  if (O.ToggleMountedPrompt == nil) then O.ToggleMountedPrompt = true; end
  if (O.AutoSoundSelection == nil) then O.AutoSoundSelection = 4; end;
  if (O.CheckCharges == nil) then O.CheckCharges = true; end
  --if (O.ToggleAutoRest == nil) then  O.ToggleAutoRest = true; end
  if (O.RebuffTimer == nil) then O.RebuffTimer = 20; end
  if (O.SplashDuration == nil) then O.SplashDuration = 2; end
  if (O.SplashIconSize == nil) then O.SplashIconSize = 16; end
  if (O.BuffTarget == nil) then O.BuffTarget = false; end
  if (O.BuffPvP == nil) then O.BuffPvP = false; end
  if (O.BuffInCities == nil) then O.BuffInCities = true; end
  if (O.LinkSelfBuffCheck == nil) then O.LinkSelfBuffCheck = true; end
  if (O.LinkGrpBuffCheck == nil) then O.LinkGrpBuffCheck = true; end
  if (O.AntiDaze == nil) then O.AntiDaze = true; end
  if (O.WarnCombatFishingRod == nil) then O.WarnCombatFishingRod = true; end
  if (O.WarnGroupFishingRod == nil) then O.WarnGroupFishingRod = true; end
  if (O.ScrollWheel ~= nil and O.ScrollWheelUp == nil) then  O.ScrollWheelUp = O.ScrollWheel; end
  if (O.ScrollWheel ~= nil and O.ScrollWheelDown == nil) then  O.ScrollWheelDown = O.ScrollWheel; end
  if (O.ScrollWheelUp == nil) then O.ScrollWheelUp = true; end
  if (O.ScrollWheelDown == nil) then O.ScrollWheelDown = true; end
  if (O.ScrollWheelZooming == nil) then O.ScrollWheelZooming = false; end
  if (O.InCombat == nil) then  O.InCombat = true; end
  if (O.AutoSwitchTemplate == nil) then  O.AutoSwitchTemplate = true; end
  if (O.AutoSwitchTemplateInst == nil) then  O.AutoSwitchTemplateInst = true; end
  if (O.InShapeshift == nil) then  O.InShapeshift = true; end
  O.ToggleGrp = {true, true, true, true, true, true, true, true};
  if (O.ToggleMsgNormal == nil) then  O.ToggleMsgNormal = true; end
  if (O.ToggleMsgWarning == nil) then  O.ToggleMsgWarning = false; end
  if (O.ToggleMsgError == nil) then  O.ToggleMsgError = false; end
  if (O.HideMmButton == nil) then  O.HideMmButton = false; end
  if (O.HideSAButton == nil) then  O.HideSAButton = true; end
  -- tracking switcher, only works for herbs and minerals
  if (O.TrackSwitchActive == nil) then O.TrackSwitchActive = false; end
  if (O.TrackSwitchFish == nil) then O.TrackSwitchFish = false; end
  if (O.TrackSwitchDelay == nil) then O.TrackSwitchDelay = 2; end
  if (O.TrackMaxPosition == nil) then O.TrackMaxPosition = 1; end
  if (O.TrackPosition == nil) then O.TrackPosition = 1; end
  if (O.TrackDisableGrp == nil) then O.TrackDisableGrp = true; end
  -- leaving this here in classic just in case we even need it, its possible blizzard make the same
  -- changes to the secure action button as they did in the retail version.. 
  if (O.SBButtonFix == nil) then O.SBButtonFix = false; end
  if (O.SBButtonDownVal == nil) then O.SBButtonDownVal = GetCVarBool("ActionButtonUseKeyDown"); end

  if (O.MinCharges == nil) then
    if (sPlayerClass == "SHAMAN" or sPlayerClass == "PRIEST") then
      O.MinCharges = 1;
    else
      O.MinCharges = 3;
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
  currentSpec = GetActiveTalentGroup()

  if (O.OldWheelUp == nil) then O.OldWheelUp = ""; end
  if (O.OldWheelDown == nil) then O.OldWheelDown = ""; end

  SMARTBUFF_InitActionButtonPos();

  if (O.SplashX == nil) then O.SplashX = 100; end
  if (O.SplashY == nil) then O.SplashY = -100; end
  if (O.CurrentFont == nil) then O.CurrentFont = 6; end
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

  DEFAULT_CHAT_FRAME:AddMessage("|cff00e0ffSmartbuff Build "..SMARTBUFF_VERSION.." (Client: "..buildInfo..")|cffffffff "..SMARTBUFF_MSG_LOADED)

  -- check for DugisGuideViewerZ, this also attempts to update the tracker so
  -- make sure to turn off the auto switcher if this addon is loaded.
  -- Thanks TechnoHunter via Discord for the conflict report.
  if IsAddOnLoaded("DugisGuideViewerZ") then
    O.TrackSwitchActive = false;
  end
  
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
  end

  for k, v in pairs(cClasses) do
    if (SMARTBUFF_CLASSES[k] == nil) then
      SMARTBUFF_CLASSES[k] = v;
    end
  end

  -- major version changes are backwards incompatible by definition, so trigger a RESET ALL
  O.VersionNr = O.VersionNr or SMARTBUFF_VERSIONNR -- don't reset if O.VersionNr == nil
  if O.VersionNr < SMARTBUFF_VERSIONNR then
    O.VersionNr = SMARTBUFF_VERSIONNR;
    StaticPopup_Show("SMARTBUFF_DATA_PURGE");
    SMARTBUFF_SetTemplate();
    SMARTBUFF_SetBuffs();
    InitBuffOrder(true);
  end

  if (SMARTBUFF_OptionsGlobal == nil) then 
	  SMARTBUFF_OptionsGlobal = { }; 
      SMARTBUFF_BuffOrderReset();
  end
  OG = SMARTBUFF_OptionsGlobal;
  if (OG.SplashIcon == nil) then OG.SplashIcon = true; end
  if (OG.SplashMsgShort == nil) then OG.SplashMsgShort = false; end
  if (OG.FirstStart == nil) then OG.FirstStart = "V0";  end

  SMARTBUFF_Splash_ChangeFont(0);
  
  if (OG.FirstStart ~= SMARTBUFF_VERSION) then
    SmartBuffOptionsCredits_lblText:SetText(SMARTBUFF_CREDITS);
    SMARTBUFF_OptionsFrame_Open(true);
    SmartBuffWNF_lblText:SetText(SMARTBUFF_WHATSNEW);
    SmartBuffWNF:Show();
  else
    SMARTBUFF_SetBuffs();
  end

  if (not IsVisibleToPlayer(SmartBuff_KeyButton)) then
    SmartBuff_KeyButton:ClearAllPoints();
    SmartBuff_KeyButton:SetPoint("CENTER", UIParent, "CENTER", 0, 100);
  end

  SMARTBUFF_SetTemplate();
  SMARTBUFF_RebindKeys();

  -- regardless of the option in settings, grab info on gathering trackers
  ScanPlayerTrackers();

  isSyncReq = true;

end
-- END SMARTBUFF_Options_Init

function SMARTBUFF_ToggleWhatsNewWindow()
  SmartBuffWNF_lblText:SetText(SMARTBUFF_WHATSNEW);
  if SmartBuffWNF:IsShown() then 
    SmartBuffWNF:Hide();
  else
    SmartBuffWNF:Show();
  end   
end

function SMARTBUFF_InitActionButtonPos()
  if (InCombatLockdown()) then return end

  isInitBtn = true;
  if (O.ActionBtnX == nil) then
    SMARTBUFF_SetButtonPos(SmartBuff_KeyButton);
  else
    SmartBuff_KeyButton:ClearAllPoints();
    SmartBuff_KeyButton:SetPoint("TOPLEFT", UIParent, "TOPLEFT", O.ActionBtnX, O.ActionBtnY);
  end
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
end

function SMARTBUFF_RebindKeys()
  local i;
  isRebinding = true;
  for i = 1, GetNumBindings(), 1 do
    local s = "";
    local command, key1, key2 = GetBinding(i);
    if (key1 and key1 == "MOUSEWHEELUP" and command ~= "SmartBuff_KeyButton") then
      O.OldWheelUp = command;
    elseif (key1 and key1 == "MOUSEWHEELDOWN" and command ~= "SmartBuff_KeyButton") then
      O.OldWheelDown = command;
    end
    if (command and command == "SMARTBUFF_BIND_TRIGGER") then
      if (key1) then
        SetBindingClick(key1, "SmartBuff_KeyButton");
      end
      if (key2) then
        SetBindingClick(key2, "SmartBuff_KeyButton");
      end
      break;
    end
  end

  if (O.ScrollWheelUp) then
    isKeyUpChanged = true;
    SetOverrideBindingClick(SmartBuffFrame, false, "MOUSEWHEELUP", "SmartBuff_KeyButton", "MOUSEWHEELUP");
  else
    if (isKeyUpChanged) then
      isKeyUpChanged = false;
      SetOverrideBinding(SmartBuffFrame, false, "MOUSEWHEELUP");
    end
  end

  if (O.ScrollWheelDown) then
    isKeyDownChanged = true;
    SetOverrideBindingClick(SmartBuffFrame, false, "MOUSEWHEELDOWN", "SmartBuff_KeyButton", "MOUSEWHEELDOWN");
  else
    if (isKeyDownChanged) then
      isKeyDownChanged = false;
      SetOverrideBinding(SmartBuffFrame, false, "MOUSEWHEELDOWN");
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
    SMARTBUFF_SetTemplate();
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
  elseif (msg == "changes") then
    SMARTBUFF_OptionsFrame_Open(true);
    SmartBuffWNF_lblText:SetText(SMARTBUFF_WHATSNEW);
    SmartBuffWNF:Show();
  elseif (msg == "reload") then
    SMARTBUFF_BuffOrderReset();
    SMARTBUFF_OptionsFrame_Open(true);
  else
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
    SMARTBUFF_AddMsg("changes    -  " .. "Display changelog", true);
    SMARTBUFF_AddMsg("reload    -  " .. "Reset buff list", true)
  end
end
-- END SMARTBUFF_command


-- SmartBuff options toggle ---------------------------------------------------------------------------------------
function SMARTBUFF_OToggle()
  if (not isInit) then return; end
  O.Toggle = SMARTBUFF_toggleBool(O.Toggle, "Active = ");
  SMARTBUFF_CheckMiniMapButton();
  if (O.Toggle) then
    SMARTBUFF_SetTemplate();
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
function SMARTBUFF_OToggleMountedPrompt()
  O.ToggleMountedPrompt = not O.ToggleMountedPrompt;
end
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
function SMARTBUFF_OScrollWheelZoom()
  O.ScrollWheelZooming = not O.ScrollWheelZooming;
end
function SMARTBUFF_OInShapeshift()
  O.InShapeshift = not O.InShapeshift;
end
function SMARTBUFF_OInCombat()
  O.InCombat = not O.InCombat;
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
function SMARTBUFF_OTrackSwitchFish()
    O.TrackSwitchFish = not O.TrackSwitchFish;
end
function SMARTBUFF_OTrackDisableGrp()
    O.TrackDisableGrp = not O.TrackDisableGrp;
    if not O.TrackDisableGrp then
        cDisableTrackSwitch = false;
    end
end

function SMARTBUFF_OToggleBuff(s, i)
  local bs = GetBuffSettings(cBuffs[i].BuffS);
  if (bs == nil) then
    return;
  end

  if (s == "S") then
    bs.EnableS = not bs.EnableS;
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

function SMARTBUFF_ToggleFixBuffing()
    O.SBButtonFix = not O.SBButtonFix;
	if not O.SBButtonFix then SetCVar("ActionButtonUseKeyDown", O.SBButtonDownVal ); end
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
    -- if we were a new build then request a reloadui.
    if (OG.FirstStart ~= SMARTBUFF_VERSION) then
        OG.FirstStart = SMARTBUFF_VERSION;
        StaticPopup_Show("SMARTBUFF_GUI_RELOAD");
	end
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
      local link = GetSpellLink(ids);
      if (link) then GameTooltip:SetHyperlink(link); end
    elseif (mode == 2 and idg) then
      local link = GetSpellLink(idg);
      if (link) then GameTooltip:SetHyperlink(link); end
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
  SmartBuffOptionsFrame_cbWarnWhenMounted:SetChecked(O.ToggleMountedPrompt);

  SmartBuffOptionsFrame_cbAutoSwitchTmp:SetChecked(O.AutoSwitchTemplate);
  SmartBuffOptionsFrame_cbAutoSwitchTmpInst:SetChecked(O.AutoSwitchTemplateInst);
  SmartBuffOptionsFrame_cbBuffPvP:SetChecked(O.BuffPvP);
  SmartBuffOptionsFrame_cbBuffTarget:SetChecked(O.BuffTarget);
  SmartBuffOptionsFrame_cbBuffInCities:SetChecked(O.BuffInCities);
  SmartBuffOptionsFrame_cbInShapeshift:SetChecked(O.InShapeshift);
  SmartBuffOptionsFrame_cbFixBuffIssue:SetChecked(O.SBButtonFix);

  SmartBuffOptionsFrame_cbAntiDaze:SetChecked(O.AntiDaze);
  SmartBuffOptionsFrame_cbLinkGrpBuffCheck:SetChecked(O.LinkGrpBuffCheck);
  SmartBuffOptionsFrame_cbLinkSelfBuffCheck:SetChecked(O.LinkSelfBuffCheck);

  SmartBuffOptionsFrame_cbScrollWheelUp:SetChecked(O.ScrollWheelUp);
  SmartBuffOptionsFrame_cbScrollWheelDown:SetChecked(O.ScrollWheelDown);
  SmartBuffOptionsFrame_cbScrollWheelZoom:SetChecked(O.ScrollWheelZooming);
  SmartBuffOptionsFrame_cbInCombat:SetChecked(O.InCombat);
  SmartBuffOptionsFrame_cbMsgNormal:SetChecked(O.ToggleMsgNormal);
  SmartBuffOptionsFrame_cbMsgWarning:SetChecked(O.ToggleMsgWarning);
  SmartBuffOptionsFrame_cbMsgError:SetChecked(O.ToggleMsgError);
  SmartBuffOptionsFrame_cbHideMmButton:SetChecked(O.HideMmButton);
  SmartBuffOptionsFrame_cbHideSAButton:SetChecked(O.HideSAButton);

  SmartBuffOptionsFrame_cbGatherAutoSwitch:SetChecked(O.TrackSwitchActive);
  SmartBuffOptionsFrame_cbGatherAutoSwitchFish:SetChecked(O.TrackSwitchFish);
  SmartBuffOptionsFrame_cbGatherAutoDisableTracker:SetChecked(O.TrackDisableGrp);

  SmartBuffOptionsFrameRebuffTimer:SetValue(O.RebuffTimer);
  SmartBuff_SetSliderText(SmartBuffOptionsFrameRebuffTimer, SMARTBUFF_OFT_REBUFFTIMER, O.RebuffTimer, INT_SPELL_DURATION_SEC);
  SmartBuffOptionsFrameBLDuration:SetValue(O.BlacklistTimer);
  SmartBuff_SetSliderText(SmartBuffOptionsFrameBLDuration, SMARTBUFF_OFT_BLDURATION, O.BlacklistTimer, INT_SPELL_DURATION_SEC);

  SMARTBUFF_SetCheckButtonBuffs(0);

  SmartBuffOptionsFrame_cbSelfFirst:SetChecked(B[CS()][currentTemplate].SelfFirst);

  SMARTBUFF_Splash_Show();

  SMARTBUFF_AddMsgD("Option frame updated: " .. currentTemplate);
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
  SmartBuffOptionsFrame:SetHeight(SMARTBUFF_OPTIONSFRAME_HEIGHT);
  wipe(cBuffsCombat);
  SMARTBUFF_SetInCombatBuffs();
  SmartBuff_BuffSetup:Hide();
  SmartBuff_PlayerSetup:Hide();
  SMARTBUFF_Splash_Hide();
  SMARTBUFF_RebindKeys();
end

function SmartBuff_ShowControls(sName, bShow)
  local children = {_G[sName]:GetChildren()};
  for i, child in pairs(children) do
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
    b = true;
  else
    SmartBuffOptionsFrame:SetHeight(40);
    b = false;
  end
  SmartBuff_ShowControls("SmartBuffOptionsFrame", b);
  if (b) then
    SMARTBUFF_SetCheckButtonBuffs(1);
  end
end
-- END Playerlist functions

-- Secure button functions
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
  local unitsLevel = nil
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

  if O.SBButtonFix then
      if button == "LeftButton" or button == "RightButton" then  
          C_CVar.SetCVar("ActionButtonUseKeyDown", 0 ); 
      else 
          C_CVar.SetCVar("ActionButtonUseKeyDown", 1 );
      end
  end

  local td;
  if (lastBuffType == "") then
    td = 0.8;
  else
    td = GlobalCd;
  end

  if (UnitCastingInfo("player")) then
    tAutoBuff = GetTime() + 0.7;
    return;
  end

  if (GetTime() < (tAutoBuff + td)) then return end

  tAutoBuff = GetTime();
  lastBuffType = "";
  currentUnit = nil;
  currentSpell = nil;

  if (not InCombatLockdown()) then
    local ret, actionType, spellName, slot, unit, buffType = SMARTBUFF_Check(mode);
    if (ret and ret == 0 and actionType and spellName and unit) then
      lastBuffType = buffType;
      self:SetAttribute("type", actionType);
      self:SetAttribute("unit", unit);
      if (actionType == SMARTBUFF_ACTION_SPELL) then
        if (slot and slot > 0 and unit == "player") then
          self:SetAttribute("type", "macro");
          self:SetAttribute("macrotext", string.format("/use %s\n/use %i\n/click StaticPopup1Button1", spellName, slot));
          SMARTBUFF_AddMsgD("Weapon buff "..spellName..", "..slot);
        else
           self:SetAttribute("spell", spellName);
        end

        if (cBuffIndex[spellName]) then
          currentUnit = unit;
          currentSpell = spellName;
        end

      elseif (actionType == SMARTBUFF_ACTION_ITEM and slot) then
        self:SetAttribute("item", spellName);
        if (slot > 0) then
          self:SetAttribute("type", "macro");
          self:SetAttribute("macrotext", string.format("/use %s\n/use %i\n/click StaticPopup1Button1", spellName, slot));
        end
      elseif (actionType == "action" and slot) then
        self:SetAttribute("action", slot);
      else
        SMARTBUFF_AddMsgD("Preclick: not supported actiontype -> " .. actionType);
      end
      tLastCheck = GetTime() - O.AutoTimer + GlobalCd;
    end
  end
end

function SMARTBUFF_OnPostClick(self, button, down)
  if (not isInit) then return end
  if (button and not isPrompting) then
    if (button == "MOUSEWHEELUP") then
      CameraZoomIn(1);
    elseif (button == "MOUSEWHEELDOWN") then
      CameraZoomOut(1);
    end
  end

  if (InCombatLockdown()) then return end

  self:SetAttribute("type", nil);
  self:SetAttribute("unit", nil);
  self:SetAttribute("spell", nil);
  self:SetAttribute("item", nil);
  self:SetAttribute("target-slot", nil);
  self:SetAttribute("target-item", nil);
  self:SetAttribute("macrotext", nil);
  self:SetAttribute("action", nil);

  SMARTBUFF_SetButtonTexture(SmartBuff_KeyButton, imgSB);

  -- ensure we reset the cvar back to the original players setting
  -- if it was previously changed due to casting issues.
  if O.SBButtonFix then
    C_CVar.SetCVar("ActionButtonUseKeyDown", O.SBButtonDownVal );
  end

end

function SMARTBUFF_SetButtonTexture(button, texture, text)
  if (button and texture and texture ~= sLastTexture) then
    sLastTexture = texture;
    button:SetNormalTexture(texture);
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
    SMARTBUFF_BROKER_SetIcon();
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
  end
end

-- Function to move the minimap button arround the minimap
function SMARTBUFF_MinimapButton_OnUpdate(self, move)
  if (not isInit or self == nil or not self:IsVisible()) then
    return;
  end

  local xpos, ypos;
  self:ClearAllPoints()
  if (move or O.MMCPosX == nil) then
    local pos, r
    local xmin, ymin = Minimap:GetLeft(), Minimap:GetBottom();
    xpos, ypos = GetCursorPosition();
    xpos = xmin-xpos/Minimap:GetEffectiveScale()+70;
    ypos = ypos/Minimap:GetEffectiveScale()-ymin-70;
    pos  = math.deg(math.atan2(ypos,xpos));
    r    = math.sqrt(xpos*xpos + ypos*ypos);

    if (r < 75) then
      r = 75;
    elseif(r > 105) then
      r = 105;
    end

    xpos = 52-r*cos(pos);
    ypos = r*sin(pos)-52;
    O.MMCPosX = xpos;
    O.MMCPosY = ypos;
  else
    xpos = O.MMCPosX;
    ypos = O.MMCPosY;
  end
self:ClearAllPoints()
  self:SetPoint("TOPLEFT", "Minimap", "TOPLEFT", xpos, ypos);
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
	local btn = CreateFrame("CheckButton", name, parent, "UICheckButtonTemplate");
	btn:SetWidth(ScrBtnSize);
	btn:SetHeight(ScrBtnSize);
	btn:SetScript("OnClick", onClick);

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

  FauxScrollFrame_Update(self, num, floor(numToDisplay/3+0.5), ScrLineHeight);
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
  if (button == "LeftButton") then
    SMARTBUFF_OToggleBuff("S", i);
  else
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

