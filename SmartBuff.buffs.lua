-------------------------------------------------------------------------------
-- SmartBuff
-- Originally created by Aeldra (EU-Proudmoore)
-- Classic versions by Codermik (Mik/Castanova/Amarantine EU-Mirage Raceway)
-- Discord: https://discord.gg/R6EkZ94TKK
-- Cast the most important buffs on you, tanks or party/raid members/pets.
-------------------------------------------------------------------------------

local _;
local S = SMARTBUFF_GLOBALS;

SMARTBUFF_PLAYERCLASS = nil;
SMARTBUFF_BUFFLIST = nil;

-- Buff types
SMARTBUFF_CONST_ALL       = "ALL";
SMARTBUFF_CONST_GROUP     = "GROUP";
SMARTBUFF_CONST_GROUPALL  = "GROUPALL";
SMARTBUFF_CONST_SELF      = "SELF";
SMARTBUFF_CONST_FORCESELF = "FORCESELF";
SMARTBUFF_CONST_TRACK     = "TRACK";
SMARTBUFF_CONST_WEAPON    = "WEAPON";
SMARTBUFF_CONST_INV       = "INVENTORY";
SMARTBUFF_CONST_FOOD      = "FOOD";
SMARTBUFF_CONST_SCROLL    = "SCROLL";
SMARTBUFF_CONST_POTION    = "POTION";
SMARTBUFF_CONST_STANCE    = "STANCE";
SMARTBUFF_CONST_ITEM      = "ITEM";
SMARTBUFF_CONST_ITEMGROUP = "ITEMGROUP";
SMARTBUFF_CONST_TOY       = "TOY";

S.CheckPet = "CHECKPET";
S.CheckPetNeeded = "CHECKPETNEEDED";
S.CheckFishingPole = "CHECKFISHINGPOLE";
S.NIL = "x";
S.Toybox = { };

local function GetItems(items)
  local t = { };
  for _, id in pairs(items) do
    local name = GetItemInfo(id);
    if (name) then
      --print("Item found: "..id..", "..name);
      tinsert(t, name);
    end
  end
  return t;
end

local function InsertItem(t, type, itemId, spellId, duration, link)
  local item = GetItemInfo(itemId);
  local spell = GetSpellInfo(spellId);
  if (item and spell) then
    --print("Item found: "..item..", "..spell);
    tinsert(t, {item, duration, type, nil, spell, link});
  end
end

local function AddItem(itemId, spellId, duration, link)
  InsertItem(SMARTBUFF_SCROLL, SMARTBUFF_CONST_SCROLL, itemId, spellId, duration, link);
end


----------------------------------------------------------------------------------------------------------------------------------
---
---	Initialise Item List
---
----------------------------------------------------------------------------------------------------------------------------------
function SMARTBUFF_InitItemList()

  -- Reagents
  SMARTBUFF_WILDBERRIES					= GetItemInfo(17021);					-- Wild Berries
  SMARTBUFF_WILDTHORNROOT				= GetItemInfo(17026);					-- Wild Thornroot
  SMARTBUFF_WILDQUILLVINE				= GetItemInfo(22148);					-- Wild Quillvine
  SMARTBUFF_ARCANEPOWDER				= GetItemInfo(17020);					-- Arcane Powder
  SMARTBUFF_HOLYCANDLE					= GetItemInfo(17028);					-- Holy Candle
  SMARTBUFF_SACREDCANDLE				= GetItemInfo(17029);					-- Sacred Candle
  SMARTBUFF_SYMBOLOFKINGS				= GetItemInfo(21177);					-- Symbol of Kings
  
  -- Stones and oils etc.
  SMARTBUFF_LESSERMANAOIL               = GetItemInfo(20747);                   -- Lesser Mana Oil
  SMARTBUFF_BRILLIANTMANAOIL			= GetItemInfo(20748);					-- Brilliant Mana Oil		
  SMARTBUFF_BRILLIANTWIZARDOIL			= GetItemInfo(20749);					-- Brilliant Wizard Oil		
  SMARTBUFF_SUPERIORMANAOIL				= GetItemInfo(22521);					-- Brilliant Mana Oil		
  SMARTBUFF_SUPERIORWIZARDOIL			= GetItemInfo(22522);					-- Superior Wizard Oil		
  SMARTBUFF_EXCEPTIONALWIZARDOIL		= GetItemInfo(36900);					-- Exceptional Wizard Oil		

  SMARTBUFF_OILOFIMMOLATION				= GetItemInfo(8956);					-- Oil of Immolation			
  SMARTBUFF_SOLIDWSTONE					= GetItemInfo(7965);					-- Solid Weighstone 
  SMARTBUFF_SOLIDSSTONE					= GetItemInfo(7964);					-- Solid Sharpening Stone 
  SMARTBUFF_ELEMENTALSSTONE				= GetItemInfo(18262);					-- Solid Weightstone 
  SMARTBUFF_ADAMANTITEWSTONE			= GetItemInfo(28421);					-- Adamantite Weightstone
  SMARTBUFF_ADAMANTITESSTONE			= GetItemInfo(23529);					-- Adamantite Sharpening Stone
  SMARTBUFF_HEAVYWSTONE					= GetItemInfo(3241);					-- Heavy Weighstone
  SMARTBUFF_HEAVYSSTONE					= GetItemInfo(2871);					-- Heavy Sharpening Stone
  SMARTBUFF_WEIGHSTONE					= GetItemInfo(28420);					-- Fel Weighstone
  SMARTBUFF_FELSHARPENINGSTONE			= GetItemInfo(23528);					-- Greater Rune of Warding

  -- Poisons (some 
  SMARTBUFF_INSTANTPOISON1				= GetItemInfo(6947);					-- Instant Poison
  SMARTBUFF_INSTANTPOISON2				= GetItemInfo(6949);					-- Instant Poison II
  SMARTBUFF_INSTANTPOISON3				= GetItemInfo(6950);					-- Instant Poison III
  SMARTBUFF_INSTANTPOISON4				= GetItemInfo(8926);					-- Instant Poison IV
  SMARTBUFF_INSTANTPOISON5				= GetItemInfo(8927);					-- Instant Poison V
  SMARTBUFF_INSTANTPOISON6				= GetItemInfo(8928);					-- Instant Poison VI
  SMARTBUFF_INSTANTPOISON7				= GetItemInfo(21927);					-- Instant Poison VII
  SMARTBUFF_WOUNDPOISON1				= GetItemInfo(10918);					-- Wound Poison
  SMARTBUFF_WOUNDPOISON2				= GetItemInfo(10920);					-- Wound Poison II
  SMARTBUFF_WOUNDPOISON3				= GetItemInfo(10921);					-- Wound Poison III
  SMARTBUFF_WOUNDPOISON4				= GetItemInfo(10922);					-- Wound Poison IV
  SMARTBUFF_WOUNDPOISON5				= GetItemInfo(22055);					-- Wound Poison V
  SMARTBUFF_MINDPOISON1					= GetItemInfo(5237);					-- Mind-numbing Poison
  SMARTBUFF_MINDPOISON2					= GetItemInfo(6951);					-- Mind-numbing Poison II
  SMARTBUFF_MINDPOISON3					= GetItemInfo(9186);					-- Mind-numbing Poison III
  SMARTBUFF_DEADLYPOISON1				= GetItemInfo(2892);					-- Deadly Poison
  SMARTBUFF_DEADLYPOISON2				= GetItemInfo(2893);					-- Deadly Poison II
  SMARTBUFF_DEADLYPOISON3				= GetItemInfo(8984);					-- Deadly Poison III
  SMARTBUFF_DEADLYPOISON4				= GetItemInfo(8985);					-- Deadly Poison IV
  SMARTBUFF_DEADLYPOISON5				= GetItemInfo(20844);					-- Deadly Poison V
  SMARTBUFF_DEADLYPOISON6				= GetItemInfo(22053);					-- Deadly Poison VI
  SMARTBUFF_DEADLYPOISON7				= GetItemInfo(22054);					-- Deadly Poison VII
  SMARTBUFF_CRIPPLINGPOISON1			= GetItemInfo(3775);					-- Crippling Poison
  SMARTBUFF_CRIPPLINGPOISON2			= GetItemInfo(3776);					-- Crippling Poison II
  SMARTBUFF_ANESTHETICPOISON1			= GetItemInfo(21835);					-- Anesthetic Poison

  -- Food
  SMARTBUFF_GOLDENFISHSTICKS_ITEM		= GetItemInfo(27666);					-- Golden Fish Sticks
  SMARTBUFF_FISHERMANSFEAST_ITEM		= GetItemInfo(33052);					-- Fisherman's Feast
  SMARTBUFF_SKULLFISHSOUP_ITEM			= GetItemInfo(33825);					-- Skullfish Soup
  SMARTBUFF_SPICYHOTTALBUK_ITEM			= GetItemInfo(33872);					-- Spicy Hot Talbuk
  SMARTBUFF_BLACKENEDBASILISK_ITEM		= GetItemInfo(27657);					-- Blackened Basilisk			
  SMARTBUFF_BLACKENEDSPOREFISH_ITEM		= GetItemInfo(27663);					-- Blackened Sporefish
  SMARTBUFF_BUZZARDBITES_ITEM			= GetItemInfo(27651);					-- Buzzard Bites
  SMARTBUFF_CLAMBAR_ITEM				= GetItemInfo(30155);					-- Clam Bar
  SMARTBUFF_CRUNCHYSERPENT_ITEM			= GetItemInfo(31673);					-- Crunchy Serpent
  SMARTBUFF_FELTAILDELIGHT_ITEM			= GetItemInfo(27662);					-- Feltail Delight
  SMARTBUFF_GRILLEDMUDFISH_ITEM			= GetItemInfo(27664);					-- Grilled Mudfish
  SMARTBUFF_HELBOARBACON_ITEM			= GetItemInfo(29292);					-- Hellboar Bacon
  SMARTBUFF_MOKNATHAKSHORTRIBS_ITEM		= GetItemInfo(31672);					-- Mok'Nathal Shortribs
  SMARTBUFF_POACHEDBLUEFISH_ITEM		= GetItemInfo(27665);					-- Poached Bluefish
  SMARTBUFF_RAVAGERDOG_ITEM				= GetItemInfo(27655);					-- Ravager Dog
  SMARTBUFF_ROASTEDCLEFTHOOF_ITEM		= GetItemInfo(27658);					-- Roasted Clefthoof
  SMARTBUFF_SPICYCRAWDAD_ITEM			= GetItemInfo(27667);					-- Spicy Crawdad
  SMARTBUFF_TALBUKSTEAK_ITEM			= GetItemInfo(27660);					-- Talbuk Steak
  SMARTBUFF_WARPBURGER_ITEM				= GetItemInfo(27659);					-- Warp Burger
  SMARTBUFF_CHARREDBEARKABOBS_ITEM		= GetItemInfo(35563);					-- Charred Bear Kabobs
  SMARTBUFF_ORONOKSTUBERSPELL_ITEM		= GetItemInfo(30361);					-- Oronok's Tuber of Spell Power
  SMARTBUFF_ORONOKSTUBERAGILITY_ITEM	= GetItemInfo(30358);					-- Oronok's Tuber of Agility
  SMARTBUFF_ORONOKSTUBERHEALS_ITEM		= GetItemInfo(30357);					-- Oronok's Tuber of Healing
  SMARTBUFF_ORONOKSTUBERSTRENGTH_ITEM	= GetItemInfo(30359);					-- Oronok's Tuber of Strength
  SMARTBUFF_HOTAPPLECIDER_ITEM			= GetItemInfo(34411);					-- Hot Apple Cider
  SMARTBUFF_SKYGUARDRATIONS_ITEM		= GetItemInfo(32721);					-- Skyguard Rations
  SMARTBUFF_DIRGESKICKINCHOPS_ITEM		= GetItemInfo(21023);					-- Dirge's Kickin' Chimaerok Chops
  SMARTBUFF_JUICYBEARBURGER_ITEM		= GetItemInfo(35565);					-- Juicy Bear Burger
  SMARTBUFF_NIGHTFINSOUP_ITEM			= GetItemInfo(13931);					-- Nightfin Soup

 -- Food item IDs
  S.FoodItems = GetItems({
    -- WotLK
    39691, 34125, 42779, 42997, 42998, 42999, 43000, 34767, 42995, 34769, 34754, 34758, 34766, 42994, 42996, 34756, 34768, 42993, 34755, 43001, 34757, 34752, 34751, 34750, 34749, 34764, 34765, 34763, 34762, 42942, 43268, 34748,
  });

  -- Conjured mage food / Water IDs
  S.FoodMage = GetItems({587, 597, 990, 6129, 10144, 10145, 28612, 33717 });
  S.WaterMage = GetItems({5504, 5505, 5506, 6127, 10138, 10139, 10140, 37420, 27090});
  S.MageManaBuscuit = ({34062});

  -- Scrolls
  SMARTBUFF_SOAGILITY1          = GetItemInfo(3012);				-- Scroll of Agility I 
  SMARTBUFF_SOAGILITY2          = GetItemInfo(1477);				-- Scroll of Agility II 
  SMARTBUFF_SOAGILITY3          = GetItemInfo(4425);				-- Scroll of Agility III 
  SMARTBUFF_SOAGILITY4          = GetItemInfo(10309);				-- Scroll of Agility IV 
  SMARTBUFF_SOAGILITY5          = GetItemInfo(27498);				-- Scroll of Agility V 
  SMARTBUFF_SOINTELLECT1        = GetItemInfo(955);					-- Scroll of Intellect I
  SMARTBUFF_SOINTELLECT2        = GetItemInfo(2290);				-- Scroll of Intellect II
  SMARTBUFF_SOINTELLECT3        = GetItemInfo(4419);				-- Scroll of Intellect III
  SMARTBUFF_SOINTELLECT4        = GetItemInfo(10308);				-- Scroll of Intellect IV
  SMARTBUFF_SOINTELLECT5        = GetItemInfo(27499);				-- Scroll of Intellect V
  SMARTBUFF_SOSTAMINA1          = GetItemInfo(1180);				-- Scroll of Stamina I 
  SMARTBUFF_SOSTAMINA2          = GetItemInfo(1711);				-- Scroll of Stamina II 
  SMARTBUFF_SOSTAMINA3          = GetItemInfo(4422);				-- Scroll of Stamina III 
  SMARTBUFF_SOSTAMINA4          = GetItemInfo(10307);				-- Scroll of Stamina IV 
  SMARTBUFF_SOSTAMINA5          = GetItemInfo(27502);				-- Scroll of Stamina V 
  SMARTBUFF_SOSPIRIT1           = GetItemInfo(1181);				-- Scroll of Spirit I
  SMARTBUFF_SOSPIRIT2           = GetItemInfo(1712);				-- Scroll of Spirit II
  SMARTBUFF_SOSPIRIT3           = GetItemInfo(4424);				-- Scroll of Spirit III
  SMARTBUFF_SOSPIRIT4           = GetItemInfo(10306);				-- Scroll of Spirit IV
  SMARTBUFF_SOSPIRIT5           = GetItemInfo(27501);				-- Scroll of Spirit V
  SMARTBUFF_SOSTRENGHT1         = GetItemInfo(954);					-- Scroll of Strength I
  SMARTBUFF_SOSTRENGHT2         = GetItemInfo(2289);				-- Scroll of Strength II
  SMARTBUFF_SOSTRENGHT3         = GetItemInfo(4426);				-- Scroll of Strength III
  SMARTBUFF_SOSTRENGHT4         = GetItemInfo(10310);				-- Scroll of Strength IV
  SMARTBUFF_SOSTRENGHT5         = GetItemInfo(27503);				-- Scroll of Strength V
  SMARTBUFF_SOPROTECTION1       = GetItemInfo(3013);				-- Scroll of Protection I
  SMARTBUFF_SOPROTECTION2       = GetItemInfo(1478);				-- Scroll of Protection II
  SMARTBUFF_SOPROTECTION3       = GetItemInfo(4421);				-- Scroll of Protection III
  SMARTBUFF_SOPROTECTION4       = GetItemInfo(10305);				-- Scroll of Protection IV 
  SMARTBUFF_SOPROTECTION5       = GetItemInfo(27500);				-- Scroll of Protection IV

  -- Potions / Elixirs / Flasks Items  
  SMARTBUFF_ADEPTELIXIR_ITEM		= GetItemInfo(28103);			-- Adept's Elixir 
  SMARTBUFF_MAJORDEFENSE_ITEM		= GetItemInfo(22834);			-- Major Defense
  SMARTBUFF_MAJORAGILITY_ITEM		= GetItemInfo(22831);			-- Major Agility
  SMARTBUFF_DRAENICWISDOM_ITEM		= GetItemInfo(32067);			-- Draenic Wisdom
  SMARTBUFF_MAJORFROSTPOWER_ITEM	= GetItemInfo(22827);			-- Major Frost Power
  SMARTBUFF_EARTHEN_ITEM			= GetItemInfo(32063);			-- Earthen Elixir
  SMARTBUFF_MASTERY_ITEM			= GetItemInfo(28104);			-- Elixir of Mastery
  SMARTBUFF_CAMOUFLAGE_ITEM			= GetItemInfo(22823);			-- Elixir of Camouflage
  SMARTBUFF_HEALINGPOWER_ITEM		= GetItemInfo(22825);			-- Elixir of Healing Power
  SMARTBUFF_MAJORFORTITUDE_ITEM		= GetItemInfo(32062);			-- Elixir of Major Fortitude
  SMARTBUFF_MAJORSTRENGTH_ITEM		= GetItemInfo(22824);			-- Elixir of Major Strength
  SMARTBUFF_ONSLAUGHTELIXIR_ITEM	= GetItemInfo(28102);			-- Onslaught Elixir
  SMARTBUFF_GREATERARCANE_ITEM		= GetItemInfo(13454);			-- Greater Arcane
  SMARTBUFF_MONGOOSEELIXIR_ITEM		= GetItemInfo(13452);			-- Elixir of Mongoose
  SMARTBUFF_BRUTEFORCE_ITEM			= GetItemInfo(13453);			-- Elixir of Brute Force
  SMARTBUFF_SAGESELIXIR_ITEM		= GetItemInfo(13447);			-- Elixir of Sages
  SMARTBUFF_SUPERIORDEFENSE_ITEM	= GetItemInfo(13445);			-- Elixir of Superior Defense
  SMARTBUFF_DEMONSLAYING_ITEM		= GetItemInfo(9224);			-- Elixir of Demon Slaying
  SMARTBUFF_MAJORFIREPOWER_ITEM		= GetItemInfo(22833);			-- Elixir of Major Fire Power
  SMARTBUFF_GREATERFIREPOWER_ITEM	= GetItemInfo(21546);			-- Elixir of Greater Fire Power
  SMARTBUFF_SHADOWPOWER_ITEM		= GetItemInfo(9264);			-- Elixir of Shadow Power
  SMARTBUFF_GIANTSELIXIR_ITEM		= GetItemInfo(9206);			-- Elixir of Giants
  SMARTBUFF_GREATERAGILITY_ITEM		= GetItemInfo(9187);			-- Elixir of Greater Agility
  SMARTBUFF_GIFTOFARTHAS_ITEM		= GetItemInfo(9088);			-- Gift of Arthas
  SMARTBUFF_ARANCEELIXIR_ITEM		= GetItemInfo(9155);			-- Arcane Elixir
  SMARTBUFF_GREATERINTELLECT_ITEM	= GetItemInfo(9179);			-- Elixir of Greater Intellect
  SMARTBUFF_MAJORNATUREPROT_ITEM	= GetItemInfo(22844);			-- Major Natur Protection Potion
  SMARTBUFF_MAJORMAGEBLOOD_ITEM		= GetItemInfo(22840);			-- Major Mageblood
  SMARTBUFF_MAJORSHADOWPWR_ITEM		= GetItemInfo(22835);			-- Major Shadow Power
  SMARTBUFF_MAJORIRONSKIN_ITEM		= GetItemInfo(32068);			-- Major Ironskin
  SMARTBUFF_BLINDINGLIGHTFLASK_ITEM	= GetItemInfo(22861);			-- Flask of Blinding Light
  SMARTBUFF_FORTIFICATIONFLASK_ITEM	= GetItemInfo(22851);			-- Flask of Fortification
  SMARTBUFF_RESTORATIONFLASK_ITEM	= GetItemInfo(22853);			-- Flask of Restoration
  SMARTBUFF_PUREDEATHFLASK_ITEM		= GetItemInfo(22866);			-- Flask of Pure Death
  SMARTBUFF_RELENTLESSFLASK_ITEM	= GetItemInfo(22854);			-- Flask of Relentless Assault
  SMARTBUFF_CHROMATICFLASK_ITEM		= GetItemInfo(13513);			-- Flask of Chromatic Resistance
  SMARTBUFF_DISTILLEDFLASK_ITEM		= GetItemInfo(13511);			-- Flask of Distilled Wisdom
  SMARTBUFF_SUPREMEPWRFLASK_ITEM	= GetItemInfo(13512);			-- Flask of Supreme Power

  SMARTBUFF_FLASKOFFROSTWYRM_ITEM	= GetItemInfo(46376);			-- Flask of Frost Wyrm
  SMARTBUFF_FLASKOFENDLESSRAGE_ITEM	= GetItemInfo(46377);			-- Flask of Endless Rage
  SMARTBUFF_FLASKOFTHENORTH_ITEM	= GetItemInfo(53901);			-- Flask of the North
  SMARTBUFF_FLASKOFSTONEBLOOD_ITEM	= GetItemInfo(46379);			-- Flask of Stoneblood


  -- Misc Items
  _, _, _, _, _, _, S.FishingPole = GetItemInfo(6256);  --"Fishing Pole"
    
  SMARTBUFF_AddMsgD(">>>> Item list's have been initialised.");
  
end


----------------------------------------------------------------------------------------------------------------------------------
---
---	Initialise Spell Id
---
----------------------------------------------------------------------------------------------------------------------------------
function SMARTBUFF_InitSpellIDs()
  
  -- Druid  
  SMARTBUFF_DRUID_CAT       = GetSpellInfo(768);   --"Cat Form"
  SMARTBUFF_DRUID_TREE      = GetSpellInfo(33891); --"Tree of Life"
  SMARTBUFF_DRUID_MOONKIN   = GetSpellInfo(24858); --"Moonkin Form"
  SMARTBUFF_DRUID_TRACK     = GetSpellInfo(5225);  --"Track Humanoids"
  SMARTBUFF_MOTW            = GetSpellInfo(1126);  --"Mark of the Wild"
  SMARTBUFF_GOTWRB1         = GetSpellInfo(21849); --"Gift of the Wild"
  SMARTBUFF_THORNS          = GetSpellInfo(467);   --"Thorns"
  SMARTBUFF_IMPTHORNS       = GetSpellInfo(16836); --"Improved Thorns"
  SMARTBUFF_BARKSKIN        = GetSpellInfo(22812); --"Barkskin"
  SMARTBUFF_NATURESGRASP    = GetSpellInfo(16689); --"Nature's Grasp"
  SMARTBUFF_TIGERSFURY      = GetSpellInfo(5217);  --"Tiger's Fury"
  SMARTBUFF_SAVAGEROAR      = GetSpellInfo(52610); --"Savage Roar"  
  SMARTBUFF_OMENOFCLARITY   = GetSpellInfo(16864); --"Omen of Clarity"  

  -- Druid linked
  S.LinkDruidThorns = { SMARTBUFF_THORNS, SMARTBUFF_IMPTHORNS };
  S.LinkDruidGOTW = { SMARTBUFF_MOTW, SMARTBUFF_GOTWRB1}
  
  -- Priest
  SMARTBUFF_PWF             = GetSpellInfo(1243);  --"Power Word: Fortitude"
  SMARTBUFF_POFRB1          = GetSpellInfo(21562); --"Prayer of Fortitude"
  SMARTBUFF_SP              = GetSpellInfo(976);   --"Shadow Protection"
  SMARTBUFF_POSPRB1         = GetSpellInfo(27683); --"Prayer of Shadow Protection"
  SMARTBUFF_INNERFIRE       = GetSpellInfo(588);   --"Inner Fire"
  SMARTBUFF_DS              = GetSpellInfo(14752); --"Divine Spirit"
  SMARTBUFF_POSRB1          = GetSpellInfo(27681); --"Prayer of Spirit"
  SMARTBUFF_PWS             = GetSpellInfo(17);    --"Power Word: Shield"
  SMARTBUFF_SHADOWFORM      = GetSpellInfo(15473); --"Shadowform"
  SMARTBUFF_FEARWARD        = GetSpellInfo(6346);  --"Fear Ward"
  SMARTBUFF_ELUNESGRACE     = GetSpellInfo(2651);  --"Elune's Grace"
  SMARTBUFF_FEEDBACK        = GetSpellInfo(13896); --"Feedback"
  SMARTBUFF_SHADOWGUARD     = GetSpellInfo(18137); --"Shadowguard"
  SMARTBUFF_TOUCHOFWEAKNESS = GetSpellInfo(2652);  --"Touch of Weakness"
  SMARTBUFF_INNERFOCUS      = GetSpellInfo(14751); --"Inner Focus"
  SMARTBUFF_RENEW           = GetSpellInfo(139);   --"Renew"
  SMARTBUFF_VAMPIRICEMB     = GetSpellInfo(15286); --"Vampiric Embrace"

  
  S.ChainPriestFortBuffs = { SMARTBUFF_PWF, SMARTBUFF_POFRB1};
  S.ChainPriestSpiritBuffs = { SMARTBUFF_DS, SMARTBUFF_POSRB1};
  S.ChainPriestShadowBuffs = { SMARTBUFF_SP, SMARTBUFF_POSPRB1};

  
  -- Mage
  SMARTBUFF_AI              = GetSpellInfo(1459);  --"Arcane Intellect"
  SMARTBUFF_ABRB1           = GetSpellInfo(23028); --"Arcane Brilliance"
  SMARTBUFF_ICEARMOR        = GetSpellInfo(7302);  --"Ice Armor"
  SMARTBUFF_FROSTARMOR      = GetSpellInfo(168);   --"Frost Armor"
  SMARTBUFF_MAGEARMOR       = GetSpellInfo(6117);  --"Mage Armor"
  SMARTBUFF_MOLTENARMOR     = GetSpellInfo(30482); --"Molten Armor"
  SMARTBUFF_DAMPENMAGIC     = GetSpellInfo(604);   --"Dampen Magic"
  SMARTBUFF_AMPLIFYMAGIC    = GetSpellInfo(1008);  --"Amplify Magic"
  SMARTBUFF_MANASHIELD      = GetSpellInfo(1463);  --"Mana Shield"
  SMARTBUFF_FIREWARD        = GetSpellInfo(543);   --"Fire Ward"
  SMARTBUFF_FROSTWARD       = GetSpellInfo(6143);  --"Frost Ward"
  SMARTBUFF_ICEBARRIER      = GetSpellInfo(11426); --"Ice Barrier"
  SMARTBUFF_COMBUSTION      = GetSpellInfo(11129); --"Combustion"
  SMARTBUFF_ARCANEPOWER     = GetSpellInfo(12042); --"Arcane Power"
  SMARTBUFF_PRESENCEOFMIND  = GetSpellInfo(12043); --"Presence of Mind"
  SMARTBUFF_ICYVEINS        = GetSpellInfo(12472); --"Icy Veins"
  SMARTBUFF_SUMMONWATERELE  = GetSpellInfo(31687); --"Summon Water Elemental"
  SMARTBUFF_FOCUSMAGIC      = GetSpellInfo(54646); --"Focus Magic"
  
  -- Mage chained
  S.ChainMageArmor = { SMARTBUFF_ICEARMOR, SMARTBUFF_FROSTARMOR, SMARTBUFF_MAGEARMOR, SMARTBUFF_MOLTENARMOR };
  S.ChainMageBuffs = { SMARTBUFF_AI, SMARTBUFF_ABRB1};
  
  -- Warlock
  SMARTBUFF_FELARMOR        = GetSpellInfo(28176); --"Fel Armor"
  SMARTBUFF_DEMONARMOR      = GetSpellInfo(706);   --"Demon Armor"
  SMARTBUFF_DEMONSKIN       = GetSpellInfo(687);   --"Demon Skin"
  SMARTBUFF_UNENDINGBREATH  = GetSpellInfo(5697);  --"Unending Breath"
  SMARTBUFF_DINVISIBILITY   = GetSpellInfo(132);   --"Detect Invisibility"
  SMARTBUFF_SOULLINK        = GetSpellInfo(19028); --"Soul Link"
  SMARTBUFF_SHADOWWARD      = GetSpellInfo(6229);  --"Shadow Ward"
  SMARTBUFF_DARKPACT        = GetSpellInfo(18220); --"Dark Pact"
  SMARTBUFF_LIFETAP         = GetSpellInfo(1454);  --"Life Tap"
  SMARTBUFF_CREATEHSMIN     = GetSpellInfo(6201);  --"Create Healthstone (Minor)"
  SMARTBUFF_CREATEHSLES     = GetSpellInfo(6202);  --"Create Healthstone (Lesser)"
  SMARTBUFF_CREATEHS        = GetSpellInfo(5699);  --"Create Healthstone"
  SMARTBUFF_CREATEHSGRE     = GetSpellInfo(11729); --"Create Healthstone (Greater)"
  SMARTBUFF_CREATEHSMAJ     = GetSpellInfo(11730); --"Create Healthstone (Major)"
  SMARTBUFF_SOULSTONE       = GetSpellInfo(20707); --"Soulstone"
  SMARTBUFF_CREATESSMIN     = GetSpellInfo(693);   --"Create Soulstone (Minor)"
  SMARTBUFF_CREATESSLES     = GetSpellInfo(20752); --"Create Soulstone (Lesser)"
  SMARTBUFF_CREATESS        = GetSpellInfo(20755); --"Create Soulstone"
  SMARTBUFF_CREATESSGRE     = GetSpellInfo(20756); --"Create Soulstone (Greater)"
  SMARTBUFF_CREATESSMAJ     = GetSpellInfo(20757); --"Create Soulstone (Major)"
  
  -- Warlock chained
  S.ChainWarlockArmor = { SMARTBUFF_DEMONSKIN, SMARTBUFF_DEMONARMOR, SMARTBUFF_FELARMOR };

  
  -- Hunter
  SMARTBUFF_TRUESHOTAURA    = GetSpellInfo(19506); --"Trueshot Aura"
  SMARTBUFF_RAPIDFIRE       = GetSpellInfo(3045);  --"Rapid Fire"
  SMARTBUFF_AOTH            = GetSpellInfo(13165); --"Aspect of the Hawk"
  SMARTBUFF_AOTM            = GetSpellInfo(13163); --"Aspect of the Monkey"
  SMARTBUFF_AOTW            = GetSpellInfo(20043); --"Aspect of the Wild"
  SMARTBUFF_AOTB            = GetSpellInfo(13161); --"Aspect of the Beast"
  SMARTBUFF_AOTC            = GetSpellInfo(5118);  --"Aspect of the Cheetah"
  SMARTBUFF_AOTP            = GetSpellInfo(13159); --"Aspect of the Pack"
  SMARTBUFF_AOTV            = GetSpellInfo(34074); --"Aspect of the Viper"
  SMARTBUFF_AOTDH           = GetSpellInfo(61846); --"Aspect of the Dragonhawk"
  
  -- Hunter chained
  S.ChainAspects  = { SMARTBUFF_AOTH,SMARTBUFF_AOTM,SMARTBUFF_AOTW,SMARTBUFF_AOTB,SMARTBUFF_AOTC,SMARTBUFF_AOTP,SMARTBUFF_AOTV,SMARTBUFF_AOTDH };

  
  -- Shaman
  SMARTBUFF_LIGHTNINGSHIELD = GetSpellInfo(324);   --"Lightning Shield"
  SMARTBUFF_WATERSHIELD     = GetSpellInfo(24398); --"Water Shield"
  SMARTBUFF_EARTHSHIELD     = GetSpellInfo(974);   --"Earth Shield"
  SMARTBUFF_ROCKBITERW      = GetSpellInfo(8017);  --"Rockbiter Weapon"
  SMARTBUFF_FROSTBRANDW     = GetSpellInfo(8033);  --"Frostbrand Weapon"
  SMARTBUFF_FLAMETONGUEW    = GetSpellInfo(8024);  --"Flametongue Weapon"
  SMARTBUFF_WINDFURYW       = GetSpellInfo(8232);  --"Windfury Weapon"
  SMARTBUFF_EARTHLIVINGW    = GetSpellInfo(51730); --"Earthliving Weapon"
  SMARTBUFF_WATERBREATHING  = GetSpellInfo(131);   --"Water Breathing"
  SMARTBUFF_WATERWALKING    = GetSpellInfo(546);   --"Water Walking"
  
  -- Shaman chained
  S.ChainShamanShield = { SMARTBUFF_LIGHTNINGSHIELD, SMARTBUFF_WATERSHIELD, SMARTBUFF_EARTHSHIELD };
  

  -- Warrior
  SMARTBUFF_BATTLESHOUT     = GetSpellInfo(6673);  --"Battle Shout"
  SMARTBUFF_COMMANDINGSHOUT = GetSpellInfo(469);   --"Commanding Shout"
  SMARTBUFF_BERSERKERRAGE   = GetSpellInfo(18499); --"Berserker Rage"
  SMARTBUFF_BLOODRAGE       = GetSpellInfo(2687);  --"Bloodrage"
  SMARTBUFF_RAMPAGE         = GetSpellInfo(29801); --"Rampage"
  SMARTBUFF_VIGILANCE       = GetSpellInfo(50720); --"Vigilance"
  SMARTBUFF_SHIELDBLOCK     = GetSpellInfo(2565);  --"Shield Block"
  
  -- Warrior chained
  S.ChainWarriorShout  = { SMARTBUFF_BATTLESHOUT, SMARTBUFF_COMMANDINGSHOUT };

  
  -- Rogue
  SMARTBUFF_BLADEFLURRY     = GetSpellInfo(13877); --"Blade Flurry"
  SMARTBUFF_SAD             = GetSpellInfo(5171);  --"Slice and Dice"
  SMARTBUFF_EVASION         = GetSpellInfo(5277);  --"Evasion"
  SMARTBUFF_HUNGERFORBLOOD  = GetSpellInfo(51662); --"Hunger For Blood"
  SMARTBUFF_STEALTH         = GetSpellInfo(1784);  --"Stealth"

  
  -- Paladin
  SMARTBUFF_RIGHTEOUSFURY         = GetSpellInfo(25780); --"Righteous Fury"
  SMARTBUFF_HOLYSHIELD            = GetSpellInfo(20925); --"Holy Shield"
  SMARTBUFF_BOM                   = GetSpellInfo(19740); --"Blessing of Might"
  SMARTBUFF_GBOM                  = GetSpellInfo(25782); --"Greater Blessing of Might"
  SMARTBUFF_BOW                   = GetSpellInfo(19742); --"Blessing of Wisdom"
  SMARTBUFF_GBOW                  = GetSpellInfo(25894); --"Greater Blessing of Wisdom"
  SMARTBUFF_BOSAL                 = GetSpellInfo(1038);  --"Blessing of Salvation"
  SMARTBUFF_GBOSAL                = GetSpellInfo(25895); --"Greater Blessing of Salvation"
  SMARTBUFF_BOK                   = GetSpellInfo(20217); --"Blessing of Kings"
  SMARTBUFF_GBOK                  = GetSpellInfo(25898); --"Greater Blessing of Kings"
  SMARTBUFF_BOSAN                 = GetSpellInfo(20911); --"Blessing of Sanctuary"
  SMARTBUFF_GBOSAN                = GetSpellInfo(25899); --"Greater Blessing of Sanctuary"
--  SMARTBUFF_BOF                   = GetSpellInfo(1044);  --"Blessing of Freedom"
--  SMARTBUFF_BOP                   = GetSpellInfo(1022);  --"Blessing of Protection"
  SMARTBUFF_SOCOMMAND             = GetSpellInfo(20375); --"Seal of Command"
  SMARTBUFF_SOJUSTICE             = GetSpellInfo(20164); --"Seal of Justice"
  SMARTBUFF_SOLIGHT               = GetSpellInfo(20165); --"Seal of Light"
  SMARTBUFF_SORIGHTEOUSNESS       = GetSpellInfo(21084); --"Seal of Righteousness"
  SMARTBUFF_SOWISDOM              = GetSpellInfo(20166); --"Seal of Wisdom"
  SMARTBUFF_SOTCRUSADER           = GetSpellInfo(21082); --"Seal of the Crusader"
  SMARTBUFF_SOVENGEANCE           = GetSpellInfo(31801); --"Seal of Vengeance"
  SMARTBUFF_SOBLOOD               = GetSpellInfo(31892); --"Seal of Blood"
  SMARTBUFF_SOCORRUPTION          = GetSpellInfo(53736); --"Seal of Corruption"
  SMARTBUFF_SOMARTYR              = GetSpellInfo(53720); --"Seal of the Martyr"
  SMARTBUFF_DEVOTIONAURA          = GetSpellInfo(465);   --"Devotion Aura"
  SMARTBUFF_RETRIBUTIONAURA       = GetSpellInfo(7294);  --"Retribution Aura"
  SMARTBUFF_CONCENTRATIONAURA     = GetSpellInfo(19746); --"Concentration Aura"
  SMARTBUFF_SHADOWRESISTANCEAURA  = GetSpellInfo(19876); --"Shadow Resistance Aura"
  SMARTBUFF_FROSTRESISTANCEAURA   = GetSpellInfo(19888); --"Frost Resistance Aura"
  SMARTBUFF_FIRERESISTANCEAURA    = GetSpellInfo(19891); --"Fire Resistance Aura"
  SMARTBUFF_SANCTITYAURA          = GetSpellInfo(20218); --"Sanctity Aura"
  SMARTBUFF_CRUSADERAURA          = GetSpellInfo(32223); --"Crusader Aura"  

  -- Paladin chained
  S.ChainPaladinBOM      = { SMARTBUFF_BOM, SMARTBUFF_GBOM };
  S.ChainPaladinBOW      = { SMARTBUFF_BOW, SMARTBUFF_GBOW };
  S.ChainPaladinSAL      = { SMARTBUFF_BOSAL, SMARTBUFF_GBOSAL };
  S.ChainPaladinBOK      = { SMARTBUFF_BOK, SMARTBUFF_GBOK };
  S.ChainPaladinSAN      = { SMARTBUFF_BOSAN, SMARTBUFF_GBOSAN }; 
  S.ChainPaladinSeal     = { SMARTBUFF_SOCOMMAND, SMARTBUFF_SOJUSTICE, SMARTBUFF_SOLIGHT, SMARTBUFF_SORIGHTEOUSNESS, SMARTBUFF_SOWISDOM, SMARTBUFF_SOTCRUSADER, SMARTBUFF_SOVENGEANCE, SMARTBUFF_SOBLOOD, SMARTBUFF_SOCORRUPTION, SMARTBUFF_SOMARTYR };
  S.ChainPaladinAura     = { SMARTBUFF_DEVOTIONAURA, SMARTBUFF_RETRIBUTIONAURA, SMARTBUFF_CONCENTRATIONAURA, SMARTBUFF_SHADOWRESISTANCEAURA, SMARTBUFF_FROSTRESISTANCEAURA, SMARTBUFF_FIRERESISTANCEAURA, SMARTBUFF_SANCTITYAURA, SMARTBUFF_CRUSADERAURA };
  
  -- Death Knight
  SMARTBUFF_DANCINGRW         = GetSpellInfo(49028); --"Dancing Rune Weapon"
--  SMARTBUFF_BLOODPRESENCE     = GetSpellInfo(48263); --"Blood Presence"
--  SMARTBUFF_FROSTPRESENCE     = GetSpellInfo(48266); --"Frost Presence"
--  SMARTBUFF_UNHOLYPRESENCE    = GetSpellInfo(48265); --"Unholy Presence"  
  SMARTBUFF_PATHOFFROST       = GetSpellInfo(3714);  --"Path of Frost"
--  SMARTBUFF_BONESHIELD        = GetSpellInfo(49222); --"Bone Shield"
  SMARTBUFF_HORNOFWINTER      = GetSpellInfo(57330); --"Horn of Winter"
  SMARTBUFF_RAISEDEAD         = GetSpellInfo(46584); --"Raise Dead"
--  SMARTBUFF_POTGRAVE          = GetSpellInfo(155522); --"Power of the Grave" (P)

  -- Death Knight buff links
  S.ChainDKPresence = { SMARTBUFF_BLOODPRESENCE, SMARTBUFF_FROSTPRESENCE, SMARTBUFF_UNHOLYPRESENCE };

  
  -- Tracking
  SMARTBUFF_FINDMINERALS    = GetSpellInfo(2580);  --"Find Minerals"
  SMARTBUFF_FINDHERBS       = GetSpellInfo(2383);  --"Find Herbs"
  SMARTBUFF_FINDTREASURE    = GetSpellInfo(2481);  --"Find Treasure"
  SMARTBUFF_TRACKHUMANOIDS  = GetSpellInfo(19883); --"Track Humanoids"
  SMARTBUFF_TRACKBEASTS     = GetSpellInfo(1494);  --"Track Beasts"
  SMARTBUFF_TRACKUNDEAD     = GetSpellInfo(19884); --"Track Undead"
  SMARTBUFF_TRACKHIDDEN     = GetSpellInfo(19885); --"Track Hidden"
  SMARTBUFF_TRACKELEMENTALS = GetSpellInfo(19880); --"Track Elementals"
  SMARTBUFF_TRACKDEMONS     = GetSpellInfo(19878); --"Track Demons"
  SMARTBUFF_TRACKGIANTS     = GetSpellInfo(19882); --"Track Giants"
  SMARTBUFF_TRACKDRAGONKIN  = GetSpellInfo(19879); --"Track Dragonkin"
  SMARTBUFF_SENSEDEMONS     = GetSpellInfo(5500);  --"Sense Demons"
  SMARTBUFF_SENSEUNDEAD     = GetSpellInfo(5502);  --"Sense Undead"

  -- Racial
  SMARTBUFF_STONEFORM       = GetSpellInfo(20594); --"Stoneform"
  SMARTBUFF_BLOODFURY       = GetSpellInfo(20572); --"Blood Fury" 33697, 33702
  SMARTBUFF_BERSERKING      = GetSpellInfo(26297); --"Berserking"
  SMARTBUFF_WOTFORSAKEN     = GetSpellInfo(7744);  --"Will of the Forsaken"
  SMARTBUFF_WarStomp        = GetSpellInfo(20549); --"War Stomp"
  
  -- Food
  SMARTBUFF_FOOD_AURA       = GetSpellInfo(19705); --"Well Fed"
  SMARTBUFF_FOOD_SPELL      = GetSpellInfo(433);   --"Food"
  SMARTBUFF_DRINK_SPELL     = GetSpellInfo(430);   --"Drink"
  
  -- Misc
  SMARTBUFF_KIRUSSOV        = GetSpellInfo(46302); --"K'iru's Song of Victory"
  SMARTBUFF_FISHING         = GetSpellInfo(7620) or GetSpellInfo(111541); --"Fishing"
  

  -- Scroll
  SMARTBUFF_SBAGILITY				= GetSpellInfo(8115);			-- Scroll buff: Agility
  SMARTBUFF_SBINTELLECT				= GetSpellInfo(8096);			-- Scroll buff: Intellect
  SMARTBUFF_SBSTAMINA				= GetSpellInfo(8099);			-- Scroll buff: Stamina
  SMARTBUFF_SBSPIRIT				= GetSpellInfo(8112);			-- Scroll buff: Spirit
  SMARTBUFF_SBSTRENGHT				= GetSpellInfo(8118);			-- Scroll buff: Strength
  SMARTBUFF_SBPROTECTION			= GetSpellInfo(89344);			-- Scroll buff: Armor

  ---	Classic - Potions / Flasks / Elixirs
  SMARTBUFF_ADEPTELIXIR_BUFF		= GetSpellInfo(33740);			-- Adept's Elixir
  SMARTBUFF_MAJORDEFENSE_BUFF		= GetSpellInfo(28557);			-- Major Defense
  SMARTBUFF_MAJORAGILITY_BUFF		= GetSpellInfo(28497);			-- Major Agility
  SMARTBUFF_DRAENICWISDOM_BUFF		= GetSpellInfo(39638);			-- Draenic Wisdom
  SMARTBUFF_MAJORFROSTPOWER_BUFF	= GetSpellInfo(28549);			-- Major Frost Power
  SMARTBUFF_EARTHEN_BUFF			= GetSpellInfo(39637);			-- Earthen Elixir
  SMARTBUFF_MASTERY_BUFF			= GetSpellInfo(33741);			-- Elixir of Mastery
  SMARTBUFF_CAMOUFLAGE_BUFF 		= GetSpellInfo(28543);			-- Elixir of Camouflage
  SMARTBUFF_HEALINGPOWER_BUFF		= GetSpellInfo(28545);			-- Elixir of Healing Power
  SMARTBUFF_MAJORFORTITUDE_BUFF		= GetSpellInfo(39636);			-- Elixir of Major Fortitude
  SMARTBUFF_MAJORSTRENGTH_BUFF		= GetSpellInfo(28544);			-- Elixir of Major Strength
  SMARTBUFF_ONSLAUGHTELIXIR_BUFF	= GetSpellInfo(33738);			-- Onslaught Elixir
  SMARTBUFF_GREATERARCANE_BUFF		= GetSpellInfo(17573);			-- Greater Arcane
  SMARTBUFF_MONGOOSEELIXIR_BUFF		= GetSpellInfo(17571);			-- Elixir of Mongoose
  SMARTBUFF_BRUTEFORCE_BUFF			= GetSpellInfo(17557);			-- Elixir of Brute Force
  SMARTBUFF_SAGESELIXIR_BUFF		= GetSpellInfo(17555);			-- Elixir of Sages
  SMARTBUFF_SUPERIORDEFENSE_BUFF	= GetSpellInfo(17554);			-- Elixir of Superior Defense
  SMARTBUFF_DEMONSLAYING_BUFF		= GetSpellInfo(11477);			-- Elixir of Demon Slaying
  SMARTBUFF_MAJORFIREPOWER_BUFF		= GetSpellInfo(28556);			-- Elixir of Major Fire Power
  SMARTBUFF_GREATERFIREPOWER_BUFF	= GetSpellInfo(26277);			-- Elixir of Greater Fire Power
  SMARTBUFF_SHADOWPOWER_BUFF		= GetSpellInfo(11476);			-- Elixir of Shadow Power
  SMARTBUFF_GIANTSELIXIR_BUFF		= GetSpellInfo(11472);			-- Elixir of Giants
  SMARTBUFF_GREATERAGILITY_BUFF		= GetSpellInfo(11467);			-- Elixir of Greater Agility
  SMARTBUFF_GIFTOFARTHAS_BUFF		= GetSpellInfo(11466);			-- Gift of Arthas
  SMARTBUFF_ARANCEELIXIR_BUFF		= GetSpellInfo(11461);			-- Arcane Elixir
  SMARTBUFF_GREATERINTELLECT_BUFF	= GetSpellInfo(11465);			-- Elixir of Greater Intellect
  SMARTBUFF_MAJORNATUREPROT_BUFF	= GetSpellInfo(28573);			-- Major Natur Protection Potion
  SMARTBUFF_MAJORMAGEBLOOD_BUFF		= GetSpellInfo(28570);			-- Major Mageblood
  SMARTBUFF_MAJORSHADOWPWR_BUFF		= GetSpellInfo(28558);			-- Major Shadow Power
  SMARTBUFF_MAJORIRONSKIN_BUFF		= GetSpellInfo(39639);			-- Major Ironskin
  SMARTBUFF_BLINDINGLIGHTFLASK_BUFF	= GetSpellInfo(28590);			-- Flask of Blinding Light
  SMARTBUFF_FORTIFICATIONFLASK_BUFF	= GetSpellInfo(28587);			-- Flask of Fortification
  SMARTBUFF_RESTORATIONFLASK_BUFF	= GetSpellInfo(28588);			-- Flask of Restoration
  SMARTBUFF_PUREDEATHFLASK_BUFF		= GetSpellInfo(28591);			-- Flask of Pure Death
  SMARTBUFF_RELENTLESSFLASK_BUFF	= GetSpellInfo(28589);			-- Flask of Relentless Assault
  SMARTBUFF_CHROMATICFLASK_BUFF		= GetSpellInfo(17638);			-- Flask of Chromatic Resistance
  SMARTBUFF_DISTILLEDFLASK_BUFF		= GetSpellInfo(17636);			-- Flask of Distilled Wisdom
  SMARTBUFF_SUPREMEPWRFLASK_BUFF	= GetSpellInfo(17637);			-- Flask of Supreme Power

  SMARTBUFF_FLASKOFFROSTWYRM_BUFF	= GetSpellInfo(53901);			-- Flask of Frost Wyrm
  SMARTBUFF_FLASKOFSTONEBLOOD_BUFF	= GetSpellInfo(53902);			-- Flask of Stoneblood
  SMARTBUFF_FLASKOFENDLESSRAGE_BUFF	= GetSpellInfo(53903);			-- Flask of Endless Rage
  SMARTBUFF_FLASKOFTHENORTH_BUFF	= GetSpellInfo(67025);			-- Flask of the North
  
  -- Buff map
  S.LinkStats = { SMARTBUFF_BOK, SMARTBUFF_MOTW, SMARTBUFF_LOTE, SMARTBUFF_LOTWT, SMARTBUFF_MOTWR1, SMARTBUFF_MOTWR2, SMARTBUFF_MOTWR3,
                  SMARTBUFF_MOTWR4, SMARTBUFF_MOTWR5, SMARTBUFF_MOTWR6, SMARTBUFF_MOTWR7, SMARTBUFF_GOTWR1, SMARTBUFF_GOTWR2,
                  GetSpellInfo(159988), -- Bark of the Wild
                  GetSpellInfo(203538), -- Greater Blessing of Kings
                  GetSpellInfo(90363),  -- Embrace of the Shale Spider
                  GetSpellInfo(160077),  -- Strength of the Earth
                  SMARTBUFF_DSR1, SMARTBUFF_DSR2, SMARTBUFF_DSR3, SMARTBUFF_DSR4, SMARTBUFF_SWPR1, SMARTBUFF_SWPR2, SMARTBUFF_SWPR3,
                  SMARTBUFF_PSWPR1, SMARTBUFF_POSR1,
                };

  S.LinkFlaskClassic = { SMARTBUFF_BLINDINGLIGHTFLASK_BUFF, SMARTBUFF_FORTIFICATIONFLASK_BUFF, SMARTBUFF_RESTORATIONFLASK_BUFF, SMARTBUFF_PUREDEATHFLASK_BUFF,
						SMARTBUFF_RELENTLESSFLASK_BUFF, SMARTBUFF_CHROMATICFLASK_BUFF, SMARTBUFF_DISTILLEDFLASK_BUFF, SMARTBUFF_SUPREMEPWRFLASK_BUFF,
                            SMARTBUFF_FLASKOFFROSTWYRM_BUFF, SMARTBUFF_FLASKOFSTONEBLOOD_BUFF, SMARTBUFF_FLASKOFENDLESSRAGE_BUFF, SMARTBUFF_FLASKOFTHENORTH_BUFF};

    
  S.LinkSp	  = { SMARTBUFF_POSPRB1, SMARTBUFF_POSPRB2 }
  S.LinkAp    = { SMARTBUFF_HORNOFWINTER, SMARTBUFF_BATTLESHOUT, SMARTBUFF_TRUESHOTAURA };
  
  S.LinkMa    = { SMARTBUFF_BOM, SMARTBUFF_DRUID_MKAURA, SMARTBUFF_GRACEOFAIR, SMARTBUFF_POTGRAVE,
                  GetSpellInfo(93435),  -- Roar of Courage
                  GetSpellInfo(160039), -- Keen Senses
                  GetSpellInfo(128997), -- Spirit Beast Blessing
                  GetSpellInfo(160073)  -- Plainswalking
                };
  
  S.LinkInt   = { SMARTBUFF_BOW, SMARTBUFF_ABRB1, SMARTBUFF_ABRB2, SMARTBUFF_ABR1, SMARTBUFF_AIR1, SMARTBUFF_AIR2, SMARTBUFF_AIR3, SMARTBUFF_AIR4, SMARTBUFF_AIR5, SMARTBUFF_DALARANB };
    
  SMARTBUFF_AddMsgD(">>>> Spell ID's have been initialised.");

end


----------------------------------------------------------------------------------------------------------------------------------
---
---	Initialise Spell List
---
----------------------------------------------------------------------------------------------------------------------------------
function SMARTBUFF_InitSpellList()
  if (SMARTBUFF_PLAYERCLASS == nil) then return; end
    
  -- Druid
  if (SMARTBUFF_PLAYERCLASS == "DRUID") then
    SMARTBUFF_BUFFLIST = {
	  {SMARTBUFF_MOTW, 30, SMARTBUFF_CONST_GROUP, {1,10,20,30,40,50,60,70,80}, "HPET;WPET", S.LinkDruidGOTW},
	  {SMARTBUFF_GOTWRB1, 60, SMARTBUFF_CONST_GROUP, {50,60,70,80}, "HPET;WPET", S.LinkDruidGOTW, {SMARTBUFF_WILDBERRIES,SMARTBUFF_WILDTHORNROOT}},
	  {SMARTBUFF_IMPTHORNS, 10, SMARTBUFF_CONST_GROUP, {6,14}, "HUNTER;ROGUE;MAGE;PRIEST;PALADIN;WARLOCK;WPET;DKPET", S.LinkDruidThorns},
      {SMARTBUFF_THORNS, 10, SMARTBUFF_CONST_GROUP, {6,14,24,34,44,54, 64, 74}, "HUNTER;ROGUE;MAGE;PRIEST;PALADIN;WARLOCK;WPET;DKPET", S.LinkDruidThorns},
      {SMARTBUFF_OMENOFCLARITY, 10, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_BARKSKIN, 0.25, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_NATURESGRASP, 0.75, SMARTBUFF_CONST_FORCESELF},
      {SMARTBUFF_TIGERSFURY, 0.1, SMARTBUFF_CONST_SELF, nil, SMARTBUFF_DRUID_CAT},
      {SMARTBUFF_SAVAGEROAR, 0.15, SMARTBUFF_CONST_SELF, nil, SMARTBUFF_DRUID_CAT},
      {SMARTBUFF_DRUID_MOONKIN, -1, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_DRUID_TREE, -1, SMARTBUFF_CONST_SELF}, 
      {SMARTBUFF_CENARIONWARD, 0.5, SMARTBUFF_CONST_GROUP, {1}, "WARRIOR;DRUID;SHAMAN;HUNTER;ROGUE;MAGE;PRIEST;PALADIN;WARLOCK;DEATHKNIGHT;MONK;DEMONHUNTER"},
    };
  end
  

  -- Priest
  if (SMARTBUFF_PLAYERCLASS == "PRIEST") then
    SMARTBUFF_BUFFLIST = {	
	  {SMARTBUFF_PWF, 30, SMARTBUFF_CONST_GROUP, {1,12,24,36,48,60,70,80}, "HPET;WPET", S.ChainPriestFortBuffs},
	  {SMARTBUFF_POFRB1, 60, SMARTBUFF_CONST_GROUP, {48,60,70,80}, "HPET;WPET", S.ChainPriestFortBuffs, {SMARTBUFF_SACREDCANDLE}},	  
	  {SMARTBUFF_SP, 30, SMARTBUFF_CONST_GROUP, {30,42,56,68,76}, "HPET;WPET", S.ChainPriestShadowBuffs},
	  {SMARTBUFF_POSPRB1, 60, SMARTBUFF_CONST_GROUP, {48,60,70,80}, "HPET;WPET", S.ChainPriestShadowBuffs, {SMARTBUFF_SACREDCANDLE}},	  
	  {SMARTBUFF_DS, 30, SMARTBUFF_CONST_GROUP, {30,40,50,60,70,80}, "HPET;WPET", S.ChainPriestSpiritBuffs},
	  {SMARTBUFF_POSRB1, 60, SMARTBUFF_CONST_GROUP, {48,60,70,80}, "HPET;WPET", S.ChainPriestSpiritBuffs, {SMARTBUFF_SACREDCANDLE}},
      {SMARTBUFF_VAMPIRICEMB, 30, SMARTBUFF_CONST_SELF},
	  {SMARTBUFF_INNERFIRE, 10, SMARTBUFF_CONST_SELF},      
	  {SMARTBUFF_DS, 30, SMARTBUFF_CONST_GROUP, {40,42,54,60,70,80}, "ROGUE;WARRIOR;HPET;WPET", nil, nil, SMARTBUFF_POSRB1, 60, {60}, {SMARTBUFF_SACREDCANDLE}},
      {SMARTBUFF_PWS, 0.5, SMARTBUFF_CONST_GROUP, {6,12,18,24,30,36,42,48,54,60,65,70,75,80}, "MAGE;WARLOCK;DEATHKNIGHT;ROGUE;PALADIN;WARRIOR;DRUID;HUNTER;SHAMAN;HPET;WPET"},
      {SMARTBUFF_SHADOWFORM, -1, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_FEARWARD, 10, SMARTBUFF_CONST_GROUP, {20}},
      {SMARTBUFF_ELUNESGRACE, 0.25, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_FEEDBACK, 0.25, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_SHADOWGUARD, 10, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_TOUCHOFWEAKNESS, 10, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_INNERFOCUS, -1, SMARTBUFF_CONST_SELF}  
    };
  end
  
  -- Mage
  if (SMARTBUFF_PLAYERCLASS == "MAGE") then
    SMARTBUFF_BUFFLIST = {
	  {SMARTBUFF_AI, 30, SMARTBUFF_CONST_GROUP, {1,14,28,42,56,70,80}, "ROGUE;WARRIOR;HPET;WPET", S.ChainMageBuffs},
	  {SMARTBUFF_ABRB1, 60, SMARTBUFF_CONST_GROUP, {56, 70, 80}, "ROGUE;WARRIOR;HPET;WPET", {SMARTBUFF_ARCANEPOWDER}, S.ChainMageBuffs},
      {SMARTBUFF_FOCUSMAGIC, 30, SMARTBUFF_CONST_GROUP, {20}, "WARRIOR;DRUID;SHAMAN;HUNTER;ROGUE;MAGE;PRIEST;PALADIN;WARLOCK;DEATHKNIGHT;HPET;WPET"},
      {SMARTBUFF_ICEARMOR, 30, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainMageArmor},
      {SMARTBUFF_FROSTARMOR, 30, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainMageArmor},
      {SMARTBUFF_MAGEARMOR, 30, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainMageArmor},
      {SMARTBUFF_MOLTENARMOR, 30, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainMageArmor},
      {SMARTBUFF_DAMPENMAGIC, 10, SMARTBUFF_CONST_GROUP, {12,24,36,48,60,67,76}, "HPET;WPET"},
      {SMARTBUFF_AMPLIFYMAGIC, 10, SMARTBUFF_CONST_GROUP, {18,30,42,54,63,69,77}, "HPET;WPET"},
      {SMARTBUFF_MANASHIELD, 1, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_FIREWARD, 0.5, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_FROSTWARD, 0.5, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_ICEBARRIER, 1, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_COMBUSTION, -1, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_ICYVEINS, 0.33, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_ARCANEPOWER, 0.25, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_PRESENCEOFMIND, 0.165, SMARTBUFF_CONST_SELF}
    };
  end
  
  -- Warlock
  if (SMARTBUFF_PLAYERCLASS == "WARLOCK") then
    SMARTBUFF_BUFFLIST = {
      {SMARTBUFF_FELARMOR, 30, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainWarlockArmor},
      {SMARTBUFF_DEMONARMOR, 30, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainWarlockArmor},
      {SMARTBUFF_DEMONSKIN, 30, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainWarlockArmor},
      {SMARTBUFF_SOULLINK, 0, SMARTBUFF_CONST_SELF, nil, S.CheckPetNeeded},
      {SMARTBUFF_DINVISIBILITY, 10, SMARTBUFF_CONST_GROUP, {26}, "HPET;WPET"},
      {SMARTBUFF_UNENDINGBREATH, 10, SMARTBUFF_CONST_GROUP, {16}, "HPET;WPET"},
      {SMARTBUFF_LIFETAP, 0.025, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_SHADOWWARD, 0.5, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_DARKPACT, 0.5, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_SOULSTONE, 15, SMARTBUFF_CONST_GROUP, {18}, "WARRIOR;DRUID;SHAMAN;HUNTER;ROGUE;MAGE;PRIEST;PALADIN;WARLOCK;DEATHKNIGHT;MONK;DEMONHUNTER;HPET;WPET;DKPET"},
      {SMARTBUFF_CREATEHSMAJ, 0.03, SMARTBUFF_CONST_ITEM, nil, SMARTBUFF_HEALTHSTONEGEM},
      {SMARTBUFF_CREATEHSGRE, 0.03, SMARTBUFF_CONST_ITEM, nil, SMARTBUFF_HEALTHSTONEGEM},
      {SMARTBUFF_CREATEHS, 0.03, SMARTBUFF_CONST_ITEM, nil, SMARTBUFF_HEALTHSTONEGEM},
      {SMARTBUFF_CREATEHSLES, 0.03, SMARTBUFF_CONST_ITEM, nil, SMARTBUFF_HEALTHSTONEGEM},
      {SMARTBUFF_CREATEHSMIN, 0.03, SMARTBUFF_CONST_ITEM, nil, SMARTBUFF_HEALTHSTONEGEM},
      {SMARTBUFF_CREATESSMAJ, 0.03, SMARTBUFF_CONST_ITEM, nil, SMARTBUFF_SOULSTONEGEM},
      {SMARTBUFF_CREATESSGRE, 0.03, SMARTBUFF_CONST_ITEM, nil, SMARTBUFF_SOULSTONEGEM},
      {SMARTBUFF_CREATESS, 0.03, SMARTBUFF_CONST_ITEM, nil, SMARTBUFF_SOULSTONEGEM},
      {SMARTBUFF_CREATESSLES, 0.03, SMARTBUFF_CONST_ITEM, nil, SMARTBUFF_SOULSTONEGEM},
      {SMARTBUFF_CREATESSMIN, 0.03, SMARTBUFF_CONST_ITEM, nil, SMARTBUFF_SOULSTONEGEM},
      {SMARTBUFF_SPELLSTONE6, 60, SMARTBUFF_CONST_INV},
      {SMARTBUFF_SPELLSTONE5, 60, SMARTBUFF_CONST_INV},
      {SMARTBUFF_SPELLSTONE4, 60, SMARTBUFF_CONST_INV},
      {SMARTBUFF_SPELLSTONE3, 60, SMARTBUFF_CONST_INV},
      {SMARTBUFF_SPELLSTONE2, 60, SMARTBUFF_CONST_INV},
      {SMARTBUFF_SPELLSTONE1, 60, SMARTBUFF_CONST_INV},
      {SMARTBUFF_FIRESTONE7, 60, SMARTBUFF_CONST_INV},
      {SMARTBUFF_FIRESTONE6, 60, SMARTBUFF_CONST_INV},
      {SMARTBUFF_FIRESTONE5, 60, SMARTBUFF_CONST_INV},
      {SMARTBUFF_FIRESTONE4, 60, SMARTBUFF_CONST_INV},
      {SMARTBUFF_FIRESTONE3, 60, SMARTBUFF_CONST_INV},
      {SMARTBUFF_FIRESTONE2, 60, SMARTBUFF_CONST_INV},
      {SMARTBUFF_FIRESTONE1, 60, SMARTBUFF_CONST_INV}
    };
  end

  -- Hunter
  if (SMARTBUFF_PLAYERCLASS == "HUNTER") then
    SMARTBUFF_BUFFLIST = {
      {SMARTBUFF_TRUESHOTAURA, -1, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_RAPIDFIRE, 0.2, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_AOTDH, -1, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainAspects},
      {SMARTBUFF_AOTH, -1, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainAspects},
      {SMARTBUFF_AOTM, -1, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainAspects},
      {SMARTBUFF_AOTV, -1, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainAspects},
      {SMARTBUFF_AOTW, -1, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainAspects},
      {SMARTBUFF_AOTB, -1, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainAspects},
      {SMARTBUFF_AOTC, -1, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainAspects},
      {SMARTBUFF_AOTP, -1, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainAspects}
    };
  end

  -- Shaman
  if (SMARTBUFF_PLAYERCLASS == "SHAMAN") then
    SMARTBUFF_BUFFLIST = {
      {SMARTBUFF_LIGHTNINGSHIELD, 10, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainShamanShield},
      {SMARTBUFF_WATERSHIELD, 10, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainShamanShield},
      {SMARTBUFF_EARTHSHIELD, 10, SMARTBUFF_CONST_GROUP, {50,60}, "WARRIOR;DEATHKNIGHT;DRUID;SHAMAN;HUNTER;ROGUE;MAGE;PRIEST;PALADIN;WARLOCK;HPET;WPET", nil, S.ChainShamanShield},
      {SMARTBUFF_WINDFURYW, 30, SMARTBUFF_CONST_WEAPON},
      {SMARTBUFF_FLAMETONGUEW, 30, SMARTBUFF_CONST_WEAPON},
      {SMARTBUFF_FROSTBRANDW, 30, SMARTBUFF_CONST_WEAPON},
      {SMARTBUFF_ROCKBITERW, 30, SMARTBUFF_CONST_WEAPON},
      {SMARTBUFF_EARTHLIVINGW, 30, SMARTBUFF_CONST_WEAPON},
      {SMARTBUFF_WATERBREATHING, 10, SMARTBUFF_CONST_GROUP, {22}},
      {SMARTBUFF_WATERWALKING, 10, SMARTBUFF_CONST_GROUP, {28}}
    };
  end

  -- Warrior
  if (SMARTBUFF_PLAYERCLASS == "WARRIOR") then
    SMARTBUFF_BUFFLIST = {
      {SMARTBUFF_BATTLESHOUT, 2, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainWarriorShout},
      {SMARTBUFF_COMMANDINGSHOUT, 2, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainWarriorShout},
      {SMARTBUFF_BERSERKERRAGE, 0.165, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_SHIELDBLOCK, 0.1666, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_BLOODRAGE, 0.165, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_RAMPAGE, 0.5, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_VIGILANCE, 30, SMARTBUFF_CONST_GROUP, {40}, "WARRIOR;DRUID;SHAMAN;HUNTER;ROGUE;MAGE;PRIEST;PALADIN;WARLOCK;DEATHKNIGHT;HPET;WPET"}
    };
  end
  
  -- Rogue
  if (SMARTBUFF_PLAYERCLASS == "ROGUE") then
    SMARTBUFF_BUFFLIST = {
      {SMARTBUFF_STEALTH, -1, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_BLADEFLURRY, 0.165, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_SAD, 0.2, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_HUNGERFORBLOOD, 0.5, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_EVASION, 0.2, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_INSTANTPOISON9, 60, SMARTBUFF_CONST_INV},
      {SMARTBUFF_INSTANTPOISON8, 60, SMARTBUFF_CONST_INV},
      {SMARTBUFF_INSTANTPOISON7, 60, SMARTBUFF_CONST_INV},
      {SMARTBUFF_INSTANTPOISON6, 60, SMARTBUFF_CONST_INV},
      {SMARTBUFF_INSTANTPOISON5, 60, SMARTBUFF_CONST_INV},
      {SMARTBUFF_INSTANTPOISON4, 60, SMARTBUFF_CONST_INV},
      {SMARTBUFF_INSTANTPOISON3, 60, SMARTBUFF_CONST_INV},
      {SMARTBUFF_INSTANTPOISON2, 60, SMARTBUFF_CONST_INV},
      {SMARTBUFF_INSTANTPOISON1, 60, SMARTBUFF_CONST_INV},
      {SMARTBUFF_WOUNDPOISON7, 60, SMARTBUFF_CONST_INV},
      {SMARTBUFF_WOUNDPOISON6, 60, SMARTBUFF_CONST_INV},
      {SMARTBUFF_WOUNDPOISON5, 60, SMARTBUFF_CONST_INV},
      {SMARTBUFF_WOUNDPOISON4, 60, SMARTBUFF_CONST_INV},
      {SMARTBUFF_WOUNDPOISON3, 60, SMARTBUFF_CONST_INV},
      {SMARTBUFF_WOUNDPOISON2, 60, SMARTBUFF_CONST_INV},
      {SMARTBUFF_WOUNDPOISON1, 60, SMARTBUFF_CONST_INV},
      {SMARTBUFF_MINDPOISON1, 60, SMARTBUFF_CONST_INV},
      {SMARTBUFF_DEADLYPOISON9, 60, SMARTBUFF_CONST_INV},
      {SMARTBUFF_DEADLYPOISON8, 60, SMARTBUFF_CONST_INV},
      {SMARTBUFF_DEADLYPOISON7, 60, SMARTBUFF_CONST_INV},
      {SMARTBUFF_DEADLYPOISON6, 60, SMARTBUFF_CONST_INV},
      {SMARTBUFF_DEADLYPOISON5, 60, SMARTBUFF_CONST_INV},
      {SMARTBUFF_DEADLYPOISON4, 60, SMARTBUFF_CONST_INV},
      {SMARTBUFF_DEADLYPOISON3, 60, SMARTBUFF_CONST_INV},
      {SMARTBUFF_DEADLYPOISON2, 60, SMARTBUFF_CONST_INV},
      {SMARTBUFF_DEADLYPOISON1, 60, SMARTBUFF_CONST_INV},
      {SMARTBUFF_CRIPPLINGPOISON1, 60, SMARTBUFF_CONST_INV},
      {SMARTBUFF_ANESTHETICPOISON2, 60, SMARTBUFF_CONST_INV},
      {SMARTBUFF_ANESTHETICPOISON1, 60, SMARTBUFF_CONST_INV}
    };
  end

  -- Paladin
  if (SMARTBUFF_PLAYERCLASS == "PALADIN") then
    SMARTBUFF_BUFFLIST = {
 
      {SMARTBUFF_RIGHTEOUSFURY, 30, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_HOLYSHIELD, 0.165, SMARTBUFF_CONST_SELF},

      {SMARTBUFF_BOW, 5, SMARTBUFF_CONST_GROUP, {14,24,34,44,54,60,65,71,77}, "ROGUE;WARRIOR;HPET;WPET", S.ChainPaladinBOW},
      {SMARTBUFF_GBOW, 15, SMARTBUFF_CONST_GROUP, {54,60,65,71,77}, "ROGUE;WARRIOR;HPET;WPET", S.ChainPaladinBOW, {SMARTBUFF_SYMBOLOFKINGS}},   
	  {SMARTBUFF_BOM, 5, SMARTBUFF_CONST_GROUP, {4,12,22,32,42,52,60,70,73,79}, "MAGE;PRIEST;WARLOCK;HPET;WPET", S.ChainPaladinBOM},
      {SMARTBUFF_GBOM, 15, SMARTBUFF_CONST_GROUP, {52,60,70,73,79}, "MAGE;PRIEST;WARLOCK;HPET;WPET", S.ChainPaladinBOM, {SMARTBUFF_SYMBOLOFKINGS}},
	  {SMARTBUFF_BOK, 5, SMARTBUFF_CONST_GROUP, {20}, "HPET;WPET", S.ChainPaladinBOK},
      {SMARTBUFF_GBOK, 15, SMARTBUFF_CONST_GROUP, {60}, "HPET;WPET", S.ChainPaladinBOK, {SMARTBUFF_SYMBOLOFKINGS}},
	  {SMARTBUFF_BOSAL, 5, SMARTBUFF_CONST_GROUP, {26}, "TANK;HPET;WPET", S.ChainPaladinSAL},
      {SMARTBUFF_GBOSAL, 15, SMARTBUFF_CONST_GROUP, {60}, "TANK;HPET;WPET", S.ChainPaladinSAL, {SMARTBUFF_SYMBOLOFKINGS}},
	  {SMARTBUFF_BOSAN, 5, SMARTBUFF_CONST_GROUP, {26,40,50,60}, "HPET;WPET", S.ChainPaladinSAN},
      {SMARTBUFF_GBOSAN, 15, SMARTBUFF_CONST_GROUP, {60}, "HPET;WPET", S.ChainPaladinSAN, {SMARTBUFF_SYMBOLOFKINGS}},

      {SMARTBUFF_SOCOMMAND, 2, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainPaladinSeal},
      {SMARTBUFF_SOFURY, 2, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainPaladinSeal},
      {SMARTBUFF_SOJUSTICE, 2, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainPaladinSeal},
      {SMARTBUFF_SOLIGHT, 2, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainPaladinSeal},
      {SMARTBUFF_SORIGHTEOUSNESS, 2, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainPaladinSeal},
      {SMARTBUFF_SOWISDOM, 2, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainPaladinSeal},
      {SMARTBUFF_SOTCRUSADER, 2, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainPaladinSeal},
      {SMARTBUFF_SOVENGEANCE, 2, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainPaladinSeal},
      {SMARTBUFF_SOBLOOD, 2, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainPaladinSeal},
      {SMARTBUFF_SOCORRUPTION, 2, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainPaladinSeal}, 
      {SMARTBUFF_SOMARTYR, 2, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainPaladinSeal},
      {SMARTBUFF_DEVOTIONAURA, -1, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainPaladinAura},
      {SMARTBUFF_RETRIBUTIONAURA, -1, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainPaladinAura},
      {SMARTBUFF_CONCENTRATIONAURA, -1, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainPaladinAura},
      {SMARTBUFF_SHADOWRESISTANCEAURA, -1, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainPaladinAura},
      {SMARTBUFF_FROSTRESISTANCEAURA, -1, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainPaladinAura},
      {SMARTBUFF_FIRERESISTANCEAURA, -1, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainPaladinAura},
      {SMARTBUFF_SANCTITYAURA, -1, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainPaladinAura},
      {SMARTBUFF_CRUSADERAURA, -1, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainPaladinAura}  

   };
  end

  -- Deathknight
  if (SMARTBUFF_PLAYERCLASS == "DEATHKNIGHT") then
    SMARTBUFF_BUFFLIST = {
      {SMARTBUFF_DANCINGRW, 0.2, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_BLOODPRESENCE, -1, SMARTBUFF_CONST_STANCE, nil, nil, nil, S.ChainDKPresence},
      {SMARTBUFF_FROSTPRESENCE, -1, SMARTBUFF_CONST_STANCE, nil, nil, nil, S.ChainDKPresence},
      {SMARTBUFF_UNHOLYPRESENCE, -1, SMARTBUFF_CONST_STANCE, nil, nil, nil, S.ChainDKPresence},
      {SMARTBUFF_HORNOFWINTER, 60, SMARTBUFF_CONST_SELF, nil, nil, S.LinkAp},
      {SMARTBUFF_BONESHIELD, 5, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_RAISEDEAD, 1, SMARTBUFF_CONST_SELF, nil, S.CheckPet},
      {SMARTBUFF_PATHOFFROST, -1, SMARTBUFF_CONST_SELF}
    };
  end


  -- Stones and oils
  SMARTBUFF_WEAPON = {
    {SMARTBUFF_LESSERMANAOIL, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_BRILLIANTMANAOIL, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_BRILLIANTWIZARDOIL, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_SUPERIORMANAOIL, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_SUPERIORWIZARDOIL, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_EXCEPTIONALWIZARDOIL, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_OILOFIMMOLATION, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_SOLIDWSTONE, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_SOLIDSSTONE, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_ELEMENTALSSTONE, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_ADAMANTITEWSTONE, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_ADAMANTITESSTONE, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_HEAVYWSTONE, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_HEAVYSSTONE, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_WEIGHSTONE, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_FELSHARPENINGSTONE, 60, SMARTBUFF_CONST_INV},
  };

  -- Tracking
  SMARTBUFF_TRACKING = {
    {SMARTBUFF_FINDMINERALS, -1, SMARTBUFF_CONST_TRACK},
    {SMARTBUFF_FINDHERBS, -1, SMARTBUFF_CONST_TRACK},
    {SMARTBUFF_FINDTREASURE, -1, SMARTBUFF_CONST_TRACK},
    {SMARTBUFF_TRACKHUMANOIDS, -1, SMARTBUFF_CONST_TRACK},
    {SMARTBUFF_TRACKBEASTS, -1, SMARTBUFF_CONST_TRACK},
    {SMARTBUFF_TRACKUNDEAD, -1, SMARTBUFF_CONST_TRACK},
    {SMARTBUFF_TRACKHIDDEN, -1, SMARTBUFF_CONST_TRACK},
    {SMARTBUFF_TRACKELEMENTALS, -1, SMARTBUFF_CONST_TRACK},
    {SMARTBUFF_TRACKDEMONS, -1, SMARTBUFF_CONST_TRACK},
    {SMARTBUFF_TRACKGIANTS, -1, SMARTBUFF_CONST_TRACK},
    {SMARTBUFF_TRACKDRAGONKIN, -1, SMARTBUFF_CONST_TRACK},
    {SMARTBUFF_SENSEDEMONS, -1, SMARTBUFF_CONST_TRACK},
    {SMARTBUFF_SENSEUNDEAD, -1, SMARTBUFF_CONST_TRACK}
  };

  -- Racial
  SMARTBUFF_RACIAL = {
    {SMARTBUFF_STONEFORM, 0.133, SMARTBUFF_CONST_SELF},  -- Dwarv
    --{SMARTBUFF_PRECEPTION, 0.333, SMARTBUFF_CONST_SELF}, -- Human
    {SMARTBUFF_BLOODFURY, 0.416, SMARTBUFF_CONST_SELF},  -- Orc
    {SMARTBUFF_BERSERKING, 0.166, SMARTBUFF_CONST_SELF}, -- Troll
    {SMARTBUFF_WOTFORSAKEN, 0.083, SMARTBUFF_CONST_SELF}, -- Undead
    {SMARTBUFF_WarStomp, 0.033, SMARTBUFF_CONST_SELF} -- Tauer
  };

  -- FOOD
 SMARTBUFF_FOOD = {
    {SMARTBUFF_GOLDENFISHSTICKS_ITEM, 30, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_FISHERMANSFEAST_ITEM, 30, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_SKULLFISHSOUP_ITEM, 30, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_SPICYHOTTALBUK_ITEM, 30, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_BLACKENEDBASILISK_ITEM, 30, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_BLACKENEDSPOREFISH_ITEM, 30, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_BUZZARDBITES_ITEM, 30, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_CLAMBAR_ITEM, 30, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_CRUNCHYSERPENT_ITEM, 30, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_FELTAILDELIGHT_ITEM, 30, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_GRILLEDMUDFISH_ITEM, 30, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_HELBOARBACON_ITEM, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_MOKNATHAKSHORTRIBS_ITEM, 30, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_POACHEDBLUEFISH_ITEM, 30, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_RAVAGERDOG_ITEM, 30, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_ROASTEDCLEFTHOOF_ITEM, 30, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_SPICYCRAWDAD_ITEM, 30, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_TALBUKSTEAK_ITEM, 30, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_WARPBURGER_ITEM, 30, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_CHARREDBEARKABOBS_ITEM, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_ORONOKSTUBERSPELL_ITEM, 30, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_ORONOKSTUBERAGILITY_ITEM, 30, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_ORONOKSTUBERHEALS_ITEM, 30, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_ORONOKSTUBERSTRENGTH_ITEM, 30, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_HOTAPPLECIDER_ITEM, 30, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_SKYGUARDRATIONS_ITEM, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_DIRGESKICKINCHOPS_ITEM, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_JUICYBEARBURGER_ITEM, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_NIGHTFINSOUP_ITEM, 10, SMARTBUFF_CONST_FOOD},
  };
  
  -- additional wotlk food.
  for n, name in pairs(S.FoodItems) do
    if (name) then
      tinsert(SMARTBUFF_FOOD, 1, {name, 60, SMARTBUFF_CONST_FOOD});
    end
  end

  -- Scrolls
  SMARTBUFF_SCROLL = {
    {SMARTBUFF_SOAGILITY5, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBAGILITY},
    {SMARTBUFF_SOAGILITY4, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBAGILITY},
    {SMARTBUFF_SOAGILITY3, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBAGILITY},
    {SMARTBUFF_SOAGILITY2, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBAGILITY},
    {SMARTBUFF_SOAGILITY1, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBAGILITY},
    
    {SMARTBUFF_SOINTELLECT5, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBINTELLECT},
    {SMARTBUFF_SOINTELLECT4, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBINTELLECT},
    {SMARTBUFF_SOINTELLECT3, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBINTELLECT},
    {SMARTBUFF_SOINTELLECT2, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBINTELLECT},
    {SMARTBUFF_SOINTELLECT1, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBINTELLECT},
    
    {SMARTBUFF_SOSTAMINA5, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSTAMINA},
    {SMARTBUFF_SOSTAMINA4, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSTAMINA},
    {SMARTBUFF_SOSTAMINA3, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSTAMINA},
    {SMARTBUFF_SOSTAMINA2, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSTAMINA},
    {SMARTBUFF_SOSTAMINA1, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSTAMINA},
    
    {SMARTBUFF_SOSPIRIT5, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSPIRIT},
    {SMARTBUFF_SOSPIRIT4, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSPIRIT},
    {SMARTBUFF_SOSPIRIT3, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSPIRIT},
    {SMARTBUFF_SOSPIRIT2, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSPIRIT},
    {SMARTBUFF_SOSPIRIT1, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSPIRIT},
    
    {SMARTBUFF_SOSTRENGHT5, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSTRENGHT},
    {SMARTBUFF_SOSTRENGHT4, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSTRENGHT},
    {SMARTBUFF_SOSTRENGHT3, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSTRENGHT},
    {SMARTBUFF_SOSTRENGHT2, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSTRENGHT},
    {SMARTBUFF_SOSTRENGHT1, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSTRENGHT},
  
    {SMARTBUFF_SOPROTECTION5, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBPROTECTION},
    {SMARTBUFF_SOPROTECTION4, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBPROTECTION},
    {SMARTBUFF_SOPROTECTION3, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBPROTECTION},
    {SMARTBUFF_SOPROTECTION2, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBPROTECTION},
    {SMARTBUFF_SOPROTECTION1, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBPROTECTION},
  };
  

  ---	Classic Potions / Elixirs / Flasks
  
  SMARTBUFF_POTION = {

	{SMARTBUFF_ADEPTELIXIR_ITEM, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_ADEPTELIXIR_BUFF},
	{SMARTBUFF_MAJORDEFENSE_ITEM, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_MAJORDEFENSE_BUFF},
	{SMARTBUFF_MAJORAGILITY_ITEM, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_MAJORAGILITY_BUFF},
	{SMARTBUFF_DRAENICWISDOM_ITEM, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_DRAENICWISDOM_BUFF},
	{SMARTBUFF_MAJORFROSTPOWER_ITEM, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_MAJORFROSTPOWER_BUFF},
	{SMARTBUFF_EARTHEN_ITEM, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_EARTHEN_BUFF},
	{SMARTBUFF_MASTERY_ITEM, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_MASTERY_BUFF},
	{SMARTBUFF_CAMOUFLAGE_ITEM, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_CAMOUFLAGE_BUFF},
	{SMARTBUFF_HEALINGPOWER_ITEM, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_HEALINGPOWER_BUFF},
	{SMARTBUFF_MAJORFORTITUDE_ITEM, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_MAJORFORTITUDE_BUFF},
	{SMARTBUFF_MAJORSTRENGTH_ITEM, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_MAJORSTRENGTH_BUFF},
	{SMARTBUFF_ONSLAUGHTELIXIR_ITEM, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_ONSLAUGHTELIXIR_BUFF},
	{SMARTBUFF_GREATERARCANE_ITEM, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_GREATERARCANE_BUFF},
	{SMARTBUFF_MONGOOSEELIXIR_ITEM, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_MONGOOSEELIXIR_BUFF},
	{SMARTBUFF_BRUTEFORCE_ITEM, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BRUTEFORCE_BUFF},
	{SMARTBUFF_SAGESELIXIR_ITEM, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_SAGESELIXIR_BUFF},
	{SMARTBUFF_SUPERIORDEFENSE_ITEM, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_SUPERIORDEFENSE_BUFF},
	{SMARTBUFF_DEMONSLAYING_ITEM, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_DEMONSLAYING_BUFF},
	{SMARTBUFF_MAJORFIREPOWER_ITEM, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_MAJORFIREPOWER_BUFF},
	{SMARTBUFF_GREATERFIREPOWER_ITEM, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_GREATERFIREPOWER_BUFF},
	{SMARTBUFF_SHADOWPOWER_ITEM, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_SHADOWPOWER_BUFF},
	{SMARTBUFF_GIANTSELIXIR_ITEM, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_GIANTSELIXIR_BUFF},
	{SMARTBUFF_GREATERAGILITY_ITEM, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_GREATERAGILITY_BUFF},
	{SMARTBUFF_GIFTOFARTHAS_ITEM, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_GIFTOFARTHAS_BUFF},
	{SMARTBUFF_ARANCEELIXIR_ITEM, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_ARANCEELIXIR_BUFF},
	{SMARTBUFF_GREATERINTELLECT_ITEM, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_GREATERINTELLECT_BUFF},
	{SMARTBUFF_MAJORNATUREPROT_ITEM, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_MAJORNATUREPROT_BUFF},
	{SMARTBUFF_MAJORMAGEBLOOD_ITEM, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_MAJORMAGEBLOOD_BUFF},
	{SMARTBUFF_MAJORSHADOWPWR_ITEM, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_MAJORSHADOWPWR_BUFF},
	{SMARTBUFF_MAJORIRONSKIN_ITEM, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_MAJORIRONSKIN_BUFF},

	{SMARTBUFF_BLINDINGLIGHTFLASK_ITEM, 120, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BLINDINGLIGHTFLASK_BUFF, S.LinkFlaskClassic},
	{SMARTBUFF_FORTIFICATIONFLASK_ITEM, 120, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_FORTIFICATIONFLASK_BUFF, S.LinkFlaskClassic},
	{SMARTBUFF_RESTORATIONFLASK_ITEM, 120, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_RESTORATIONFLASK_BUFF, S.LinkFlaskClassic},
	{SMARTBUFF_PUREDEATHFLASK_ITEM, 120, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_PUREDEATHFLASK_BUFF, S.LinkFlaskClassic},
	{SMARTBUFF_RELENTLESSFLASK_ITEM, 120, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_RELENTLESSFLASK_BUFF, S.LinkFlaskClassic},
	{SMARTBUFF_CHROMATICFLASK_ITEM, 120, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_CHROMATICFLASK_BUFF, S.LinkFlaskClassic},
	{SMARTBUFF_DISTILLEDFLASK_ITEM, 120, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_DISTILLEDFLASK_BUFF, S.LinkFlaskClassic},
	{SMARTBUFF_HEALINGPOWER_ITEM, 120, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_HEALINGPOWER_BUFF, S.LinkFlaskClassic},
	{SMARTBUFF_SUPREMEPWRFLASK_ITEM, 120, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_SUPREMEPWRFLASK_BUFF, S.LinkFlaskClassic},
	{SMARTBUFF_FLASKOFFROSTWYRM_ITEM, 120, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_FLASKOFFROSTWYRM_BUFF, S.LinkFlaskClassic},
	{SMARTBUFF_FLASKOFENDLESSRAGE_ITEM, 120, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_FLASKOFENDLESSRAGE_BUFF, S.LinkFlaskClassic},
	{SMARTBUFF_FLASKOFTHENORTH_ITEM, 120, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_FLASKOFTHENORTH_BUFF, S.LinkFlaskClassic},
	{SMARTBUFF_FLASKOFSTONEBLOOD_ITEM, 120, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_FLASKOFSTONEBLOOD_BUFF, S.LinkFlaskClassic},

  }
  
  SMARTBUFF_AddMsgD(">>>> Spell lists have been initialised.");

end
