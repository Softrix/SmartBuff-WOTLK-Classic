-------------------------------------------------------------------------------
-- English localization (Default)
-------------------------------------------------------------------------------

-- Whats new info
SMARTBUFF_WHATSNEW = "\n\n"
  .."          |cff00e0ffClassic & Retail versions by Codermik with additional\n"
  .."          retail coding by Speedwaystar.\n\n"
  .."          |cffffffffChanges in r57.171023 (Classic):\n\n"
  .."             * Fixed a LUA error caused while in combat.\n\n"
  .."\n\n"
  .."          |cffffff00I currently play on the Mirage Raceway EU classic\n"
  .."          WOTLK server as Alliance, I play on Mik, Gabella,\n"
  .."          Castanova, Amarantine and various alts...\n\n"
  .."          ...too many actually  :)\n\n"
  .."          Please feel free to say hello!\n\n\n"
  .."          |cff00FF7FMany thanks to Chris S., Samantha R. and\n"
  .."          Twilight's Sundries for their kind donations.\n"
 .."\n\n"
;

SMARTBUFF_CREDITS = "|cffffffff"
  .."Classic & Retail versions by Codermik with additional programming and support by Speedwaystar.\n\nPlease join my discord server for support or chat:\n"
  .."|cff00e0ffhttps://discord.gg/R6EkZ94TKK\n\n"
  .."|cffffffffIf you want to help support me and the development of this addon then please always download from Curse or use one of the following links:\n\n"
  .."|cffffffffTwitch: |cff00e0ffhttps://www.twitch.tv/codermik\n"
  .."|cffffffffPayPal.Me: |cff00e0ffhttps://paypal.me/codermik\n\n"
;

-- Weapon types
SMARTBUFF_WEAPON_STANDARD = {"Daggers", "Axes", "Swords", "Maces", "Staves", "Fist Weapons", "Polearms", "Thrown", "Crossbows", "Bows"};
SMARTBUFF_WEAPON_BLUNT = {"Maces", "Staves", "Fist Weapons"};
SMARTBUFF_WEAPON_BLUNT_PATTERN = "Weightstone$";
SMARTBUFF_WEAPON_SHARP = {"Daggers", "Axes", "Swords", "Polearms"};
SMARTBUFF_WEAPON_SHARP_PATTERN = "Sharpening Stone$";

-- Creature types
SMARTBUFF_HUMANOID  = "Humanoid";
SMARTBUFF_DEMON     = "Demon";
SMARTBUFF_BEAST     = "Beast";
SMARTBUFF_ELEMENTAL = "Elemental";
SMARTBUFF_DEMONTYPE = "Imp";
SMARTBUFF_UNDEAD    = "Undead";

-- Classes
SMARTBUFF_CLASSES = {"Druid", "Hunter", "Mage", "Paladin", "Priest", "Rogue", "Shaman", "Warlock", "Warrior", "Death Knight", "Monk", "Demon Hunter", "Evoker", "Hunter Pet", "Warlock Pet", "Death Knight Pet", "Tank", "Healer", "Damage Dealer"};

-- Templates and Instances
SMARTBUFF_TEMPLATES = {"Solo", "Party", "Raid", "Battleground", "Arena", "ICC", "TOC", "Ulduar", "Ony", "Naxx", "Custom 1", "Custom 2", "Custom 3", "Custom 4", "Custom 5"};
SMARTBUFF_INSTANCES = {"Icecrown Citadel", "Trial of the Crusader", "Ulduar", "Onyxia's Lair", "Naxxramas"};

-- Mount
SMARTBUFF_MOUNT = "Increases speed by (%d+)%%.";

-- Abbreviations
SMARTBUFF_ABBR_CHARGES_OL = "%d c";

-- Bindings
BINDING_NAME_SMARTBUFF_BIND_TRIGGER = "Trigger";
BINDING_NAME_SMARTBUFF_BIND_TARGET  = "Target";
BINDING_NAME_SMARTBUFF_BIND_OPTIONS = "Option menu";
BINDING_NAME_SMARTBUFF_BIND_RESETBUFFTIMERS = "Reset buff timers";

-- wrong version
SMARTBUFF_NOTINTENDEDCLIENT	 = "This version of Smartbuff is not intended for this client, please download the correct version.";

-- Options Frame Text

-- Fix casting.
SMARTBUFF_OFT_FIXBUFF		 = "Fix Casting"
SMARTBUFF_OFTT_FIXBUFF		 = "Only tick this option if Smartbuff is failing to cast buffs while using the\nscroll mouse, action button or macro. Combat buffing will not work with\nthis setting active but you will be notified its missing for manual buffing.\n\n** This should not be needed in classic clients **"

-- tracking switcher
SMARTBUFF_TRACKSWITCHMSG	 = " has been detected but the auto switch find herbs, minerals and fish is turned on in the options. type /sbm to open options and either turn off the individual trackers or the automatic switching.";
SMARTBUFF_TRACKINGDISABLE	 = "You will only get benefit from this feature if you have 2 or more gathering tracking abilities, option has been disabled."
SMARTBUFF_AUTOGATHERON		 = "Automatic gathering switch is ON"
SMARTBUFF_AUTOGATHEROFF		 = "Automatic gathering switch is OFF"
SMARTBUFF_OFT_GATHERER		 = "Auto Switch Gathering Trackers"
SMARTBUFF_OFT_FINDFISH		 = "Find Fish"
SMARTBUFF_OFT_MINERALS		 = "Find Minerals"
SMARTBUFF_OFT_HERBS			 = "Find Herbs"
SMARTBUFF_OFTT_GATHERER		 = "Switches through your Find Herbs, Find Minerals and Find Fish (if available and selected). This feature\nwill disable automatically if you do not have two of the three listed."
SMARTBUFF_OFTT_GATHERERFISH	 = "Include Find Fish when switching through Gathering Trackers."
SMARTBUFF_OFT_AUTOGATHOFF	 = "Auto switch OFF in Party/Raids"
SMARTBUFF_OFTT_AUTOGATHOFF	 = "Automatically switch this feature OFF when in a party or raid and switch to your current template preference."

-- mounted warning
SMARTBUFF_OFT_MOUNTEDWARN	 = "Prompt while mounted";
SMARTBUFF_OFTT_MOUNTEDWARN	 = "Continue to remind me of missing buffs or abilities while I am mounted and automatically dismount to buff.";

-- show action button only when pending actions exist.
SMARTBUFF_OFT_HIDEABNOACTION = "Show only when needed";
SMARTBUFF_OFTT_HIDEABNOACTION = "Hide the action button when there are no missing buffs\non yourself, party members, raid or pets. Note that the\nAction Button must be enabled for this option to work.";

SMARTBUFF_OFT                = "SmartBuff On/Off";
SMARTBUFF_OFT_MENU           = "Show/hide options menu";
SMARTBUFF_OFT_AUTO           = "Reminder";
SMARTBUFF_OFT_AUTOTIMER      = "Check timer";
SMARTBUFF_OFT_AUTOCOMBAT     = "in combat";
SMARTBUFF_OFT_AUTOCHAT       = "Chat";
SMARTBUFF_OFT_AUTOSPLASH     = "Splash";
SMARTBUFF_OFT_AUTOSOUND      = "Sound";
SMARTBUFF_OFT_AUTOREST       = "Disable in cities";
SMARTBUFF_OFT_HUNTERPETS     = "Buff Hunter pets";
SMARTBUFF_OFT_WARLOCKPETS    = "Buff Warlock pets";
SMARTBUFF_OFT_ARULES         = "Advance rules";
SMARTBUFF_OFT_BUFFS          = "Buffs/Abilities";
SMARTBUFF_OFT_TARGET         = "Buffs the selected target";
SMARTBUFF_OFT_DONE           = "Done";
SMARTBUFF_OFT_APPLY          = "Apply";
SMARTBUFF_OFT_CLASSBUFFSIZE  = "Class size";
SMARTBUFF_OFT_MESSAGES       = "Disable messages";
SMARTBUFF_OFT_MSGNORMAL      = "normal";
SMARTBUFF_OFT_MSGWARNING     = "warning";
SMARTBUFF_OFT_MSGERROR       = "error";
SMARTBUFF_OFT_HIDEMMBUTTON   = "Hide minimap button";
SMARTBUFF_OFT_INCLUDETOYS	 = "Include toys";
SMARTBUFF_OFT_REBUFFTIMER    = "Rebuff Timer";
SMARTBUFF_OFT_AUTOSWITCHTMP  = "Switch template";
SMARTBUFF_OFT_SELFFIRST      = "Self first";
SMARTBUFF_OFT_SCROLLWHEELUP  = "Buff on scrollwheel up";
SMARTBUFF_OFT_SCROLLWHEELDOWN= "Down";
SMARTBUFF_OFT_SCROLLZOOMING	 = "Zoom";
SMARTBUFF_OFT_TARGETSWITCH   = "target change";
SMARTBUFF_OFT_BUFFTARGET     = "Buff target";
SMARTBUFF_OFT_BUFFPVP        = "Buff PvP";
SMARTBUFF_OFT_AUTOSWITCHTMPINST = "Instances";
SMARTBUFF_OFT_CHECKCHARGES   = "Check charges";
SMARTBUFF_OFT_RBT            = "Reset BT";
SMARTBUFF_OFT_BUFFINCITIES   = "Buff in cities";
SMARTBUFF_OFT_BLDURATION     = "Blacklisted";
SMARTBUFF_OFT_ANTIDAZE       = "Anti daze";
SMARTBUFF_OFT_HIDESABUTTON   = "Disable Action Button";
SMARTBUFF_OFT_INCOMBAT       = "in combat";
SMARTBUFF_OFT_SMARTDEBUFF    = "SmartDebuff";
SMARTBUFF_OFT_INSHAPESHIFT   = "Shapeshift";
SMARTBUFF_OFT_LINKGRPBUFFCHECK  = "Grp link";
SMARTBUFF_OFT_LINKSELFBUFFCHECK = "Self link";
SMARTBUFF_OFT_RESETALL       = "Reset All";
SMARTBUFF_OFT_RESETLIST      = "Reset List";
SMARTBUFF_OFT_YES            = "Yes";
SMARTBUFF_OFT_NO             = "No";
SMARTBUFF_OFT_OKAY			 = "Continue"
SMARTBUFF_OFT_PURGE_DATA     = "Are you sure you want to reset ALL SmartBuff data?\nThis action will force a reload of the UI!";
SMARTBUFF_OFT_REQ_RELOAD     = "New versions require a reload of the GUI\nClick Continue when ready.";
SMARTBUFF_OFT_SPLASHICON     = "Show Icon";
SMARTBUFF_OFT_SPLASHMSGSHORT = "Short Message";
SMARTBUFF_OFT_FONTSTYLE      = "Font";
SMARTBUFF_OFT_FONTSIZE       = "Font Size";
SMARTBUFF_OFT_ICONSIZE       = "Icon Size";
SMARTBUFF_OFT_FRODWARN		 = "You are in combat with your fishing rod equipped.";
SMARTBUFF_OFT_FRINSWARN		 = "You have entered a party or raid with your fishing rod equipped.";


-- Options Frame Tooltip Text
SMARTBUFF_OFTT               = "Toggles SmartBuff On/Off";
SMARTBUFF_OFTT_AUTO          = "Toggles the buff reminder On/Off";
SMARTBUFF_OFTT_AUTOTIMER     = "Delay in seconds between two checks.";
SMARTBUFF_OFTT_AUTOCOMBAT    = "Run the check also in combat.";
SMARTBUFF_OFTT_AUTOCHAT      = "Displays missing buffs as chat message.";
SMARTBUFF_OFTT_AUTOSPLASH    = "Displays missing buffs as splash message\nin the middle of the screen.";
SMARTBUFF_OFTT_AUTOSOUND     = "Plays a sound if buffs are missing.";
SMARTBUFF_OFTT_AUTOREST      = "Disable reminder in capital cities";
SMARTBUFF_OFTT_HUNTERPETS    = "Buff the Hunter pets as well.";
SMARTBUFF_OFTT_WARLOCKPETS   = "Buff the Warlock pets as well, except the " .. SMARTBUFF_DEMONTYPE .. ".";
SMARTBUFF_OFTT_ARULES        = "Does not cast:\n- Thorns on Mages, Priests and Warlocks\n- Arcane Intellect on units without Mana\n- Divine Spirit on units without Mana";
SMARTBUFF_OFTT_HIDEMMBUTTON  = "Hides the SmartBuff minimap button.";
SMARTBUFF_OFTT_INCLUDETOYS	 = "Include toys in the list alongside your spells and food.";
SMARTBUFF_OFTT_REBUFFTIMER   = "How many seconds before a buff expires,\nthe reminder should alert you.\n0 = Deactivated";
SMARTBUFF_OFTT_SELFFIRST     = "Buffs your character first of all others.";
SMARTBUFF_OFTT_SCROLLWHEELUP = "Cast buffs when you roll your\nscrollwheel forward.";
SMARTBUFF_OFTT_SCROLLWHEELDOWN = "Cast buffs when you roll your\nscrollwheel backward.";
SMARTBUFF_OFTT_SCROLLZOOMING = "Allow normal camera zooming while buffing missing buffs or abilities (original Smartbuff behaviour).\nNote that when this option is turned off its possible your camera zoom will be temporarily disabled\nwhen a buff or ability fails for whatever reason.";
SMARTBUFF_OFTT_TARGETSWITCH  = "Cast buffs when you switch your target.";
SMARTBUFF_OFTT_BUFFTARGET    = "Buffs first the current target,\nif it is friendly.";
SMARTBUFF_OFTT_BUFFPVP       = "Buff PvP flagged players,\nalso if you are not PvP flagged.";
SMARTBUFF_OFTT_AUTOSWITCHTMP = "Automatically switches the template,\nif the group type changes.";
SMARTBUFF_OFTT_AUTOSWITCHTMPINST = "Automatically switches the template,\nif the instance changes.";
SMARTBUFF_OFTT_CHECKCHARGES  = "Displays low amount of\ncharges on a buff.\n0 = Deactivated";
SMARTBUFF_OFTT_BUFFINCITIES  = "Buffs also if you are in capital cities.\nIf you are PvP flagged, it buffs in any case.";
SMARTBUFF_OFTT_BLDURATION    = "How many seconds, players will be blacklisted.\n0 = Deactivated";
SMARTBUFF_OFTT_ANTIDAZE      = "Automatically cancels the\naspect of the cheetah/pack\nif someone gets dazed\n(self or group).";
SMARTBUFF_OFTT_SPLASHSTYLE   = "Changes the font style of\nthe buff messages.";
SMARTBUFF_OFTT_HIDESABUTTON  = "Hides the SmartBuff action button.";
SMARTBUFF_OFTT_INCOMBAT      = "At the moment it only works on yourself.\nThe first buff you mark as in combat,\nwill set on the button before combat\nand you can use it in combat.\n!!! Warning !!!\nAll logic is disabled in combat!";
SMARTBUFF_OFTT_SMARTDEBUFF   = "Shows the SmartDebuff frame.";
SMARTBUFF_OFTT_SPLASHDURATION= "How many seconds the splash\nmessage will displayed,\nbefore it fades.";
SMARTBUFF_OFTT_INSHAPESHIFT  = "Cast buffs also if you\nare shapeshifted.";
SMARTBUFF_OFTT_LINKGRPBUFFCHECK  = "Checks if a buff of an other\nclass with similar effect\nis already active.";
SMARTBUFF_OFTT_LINKSELFBUFFCHECK = "Checks if a self buff is active,\nwhose only one can be\nactive at a time.";
SMARTBUFF_OFTT_SOUNDSELECT	 = "Select the required splash sound.";

-- Buffsetup Frame Text
SMARTBUFF_BST_SELFONLY       = "Myself only";
SMARTBUFF_BST_SELFNOT        = "Myself not";
SMARTBUFF_BST_COMBATIN       = "In combat";
SMARTBUFF_BST_COMBATOUT      = "Out of combat";
SMARTBUFF_BST_MAINHAND       = "Main Hand";
SMARTBUFF_BST_OFFHAND        = "Off Hand";
SMARTBUFF_BST_RANGED         = "Thrown";
SMARTBUFF_BST_REMINDER       = "Notification";
SMARTBUFF_BST_MANALIMIT      = "Lower bound";

-- Buffsetup Frame Tooltip Text
SMARTBUFF_BSTT_SELFONLY      = "Buffs only your character.";
SMARTBUFF_BSTT_SELFNOT       = "Buffs all other selected classes,\nexcept your character.";
SMARTBUFF_BSTT_COMBATIN      = "Buffs if you are in combat.";
SMARTBUFF_BSTT_COMBATOUT     = "Buffs if you are out of combat.";
SMARTBUFF_BSTT_MAINHAND      = "Buffs the Main Hand.";
SMARTBUFF_BSTT_OFFHAND       = "Buffs the Off Hand.";
SMARTBUFF_BSTT_RANGED        = "Buffs the ranged slot.";
SMARTBUFF_BSTT_REMINDER      = "Display reminder message.";
SMARTBUFF_BSTT_REBUFFTIMER   = "How many seconds before a buff expires,\nthe reminder should alert you.\n0 = global rebuff timer";
SMARTBUFF_BSTT_MANALIMIT     = "Mana/Rage/Energy threshold\nIf you are below this value\nit will not cast the buff.";

-- Playersetup Frame Tooltip Text
SMARTBUFF_PSTT_RESIZE        = "Minimize/maximize\nthe main options frame";

-- Messages
SMARTBUFF_MSG_LOADED         = "loaded! - Please report any problems on Curse or join discord at |cffffff00discord.gg/R6EkZ94TKK|cffffffff for improved support.";
SMARTBUFF_MSG_NEWVER1		 = "|cff00e0ffSmartbuff : |cffffffff There is a new version available, you are using |cffFFFF00";
SMARTBUFF_MSG_NEWVER2		 = "|cffffffff and revision |cffFFFF00r"
SMARTBUFF_MSG_NEWVER3		 = "|cffffffff is currently available for download.  Join Discord for all the latest information at https://discord.gg/R6EkZ94TKK.";
SMARTBUFF_MSG_DISABLED       = "SmartBuff is disabled!";
SMARTBUFF_MSG_SUBGROUP       = "You've joined a new subgroup, please check the options!";
SMARTBUFF_MSG_NOTHINGTODO    = "Nothing to do";
SMARTBUFF_MSG_BUFFED         = "buffed";
SMARTBUFF_MSG_OOR            = "is out of range to buff!";
--SMARTBUFF_MSG_CD             = "has cooldown!";
SMARTBUFF_MSG_CD             = "Global cooldown!";
SMARTBUFF_MSG_CHAT           = "not possible in chat mode!";
SMARTBUFF_MSG_SHAPESHIFT     = "Casting is not allowed in shapeshift form!";
SMARTBUFF_MSG_NOACTIONSLOT   = "needs a slot in an actionbar to working properly!";
SMARTBUFF_MSG_GROUP          = "Group";
SMARTBUFF_MSG_NEEDS          = "needs";
SMARTBUFF_MSG_OOM            = "Not enough mana/rage/energy!";
SMARTBUFF_MSG_STOCK          = "Actual stock of";
SMARTBUFF_MSG_NOREAGENT      = "Out of reagent:";
SMARTBUFF_MSG_DEACTIVATED    = "deactivated!";
SMARTBUFF_MSG_REBUFF         = "Rebuff";
SMARTBUFF_MSG_LEFT           = "left";
SMARTBUFF_MSG_CLASS          = "Class";
SMARTBUFF_MSG_CHARGES        = "charges";
SMARTBUFF_MSG_SOUNDS		 = "Splash Sound Selection: "
SMARTBUFF_MSG_SPECCHANGED    = "Spec changed (%s), loading buff templates...";

-- Support
SMARTBUFF_MINIMAP_TT         = "Left mouse for options\nRight mouse to toggle On/Off\nAlt-Left mouse to toggle auto tracking\nShift drag: Move button";
SMARTBUFF_TITAN_TT           = "Left mouse for options\nRight mouse to toggle On/Off\nAlt-Left mouse to toggle auto tracking";
SMARTBUFF_FUBAR_TT           = "\nLeft mouse for options\nRight mouse to toggle On/Off\nAlt-Right mouse to toggle mounted prompts\nAlt-Left mouse to toggle auto tracking";

SMARTBUFF_DEBUFF_TT          = "Shift-Left drag: Move frame\n|cff20d2ff- S button -|r\nLeft click: Show by classes\nShift-Left click: Class colors\nAlt-Left click: Highlight L/R\n|cff20d2ff- P button -|r\nLeft click: Hide pets on/off";


-- Code table
-- à : \195\160    è : \195\168    ì : \195\172    ò : \195\178    ù : \195\185
-- á : \195\161    é : \195\169    í : \195\173    ó : \195\179    ú : \195\186
-- â : \195\162    ê : \195\170    î : \195\174    ô : \195\180    û : \195\187
-- ã : \195\163    ë : \195\171    ï : \195\175    õ : \195\181    ü : \195\188
-- ä : \195\164                    ñ : \195\177    ö : \195\182
-- æ : \195\166                                    ø : \195\184
-- ç : \195\167                                     : \197\147
--
-- Ä : \195\132
-- Ö : \195\150
-- Ü : \195\156
-- ß : \195\159

