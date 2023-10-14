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
SMARTBUFF_CONST_GATHERING = "GATHERING";
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

SBClassicGatherers = { 2580, 2383, 2481 }       -- classic era & hardcore only.

local function GetItems(items)
  local t = { };
  for _, id in pairs(items) do
    local _,name = GetItemInfo(id);
    if (name) then
      tinsert(t, name);
    end
  end
  return t;
end

local function InsertItem(t, type, itemId, spellId, duration, link)
  local _,item = GetItemInfo(itemId); -- item link
  local spell = GetSpellInfo(spellId);
  if (item and spell) then
    tinsert(t, {item, duration, type, nil, spell, link});
  end
end

local function AddItem(itemId, spellId, duration, link)
  InsertItem(SMARTBUFF_SCROLL, SMARTBUFF_CONST_SCROLL, itemId, spellId, duration, link);
end

--
--  Initialise Item Lists
--
function SMARTBUFF_InitItemList()
  -- Stones and oils  
  _,SMARTBUFF_LOCKHEALTHSTONE               = GetItemInfo(5512);        --"Healthstone"
  _,SMARTBUFF_LOCKSPELLSTONE                = GetItemInfo(41191);       --"Spellstone"
  _,SMARTBUFF_LOCKFIRESTONE                 = GetItemInfo(41170);       --"Firestone"   
  _,SMARTBUFF_HSMINOR                       = GetItemInfo(5512);        --"Minor Healthstone"
  _,SMARTBUFF_HSLESSER                      = GetItemInfo(5511);        --"Lesser Healthstone"
  _,SMARTBUFF_HSTONE                        = GetItemInfo(5509);        --"Healthstone"
  _,SMARTBUFF_HSGREATER                     = GetItemInfo(5510);        --"Greater Healthstone"
  _,SMARTBUFF_HSMAJOR                       = GetItemInfo(9421);        --"Major Healthstone"
  _,SMARTBUFF_HSMASTER                      = GetItemInfo(22103);       --"Master Healthstone"
  _,SMARTBUFF_HSDEMONIC                     = GetItemInfo(36889);       --"Demonic Healthstone"
  _,SMARTBUFF_HSFEL                         = GetItemInfo(36892);       --"Fel Healthstone"    
  _,SMARTBUFF_FIRESLESSER                   = GetItemInfo(41170);       --"Lesser Firestone"
  _,SMARTBUFF_FIRESSTONE                    = GetItemInfo(41169);       --"Firestone"
  _,SMARTBUFF_FIRESGREATER                  = GetItemInfo(41171);       --"Greater Firestone"
  _,SMARTBUFF_FIRESMAJOR                    = GetItemInfo(41172);       --"Major Firestone"
  _,SMARTBUFF_FIRESMASTER                   = GetItemInfo(40773);       --"Master Firestone"
  _,SMARTBUFF_FIRESFEL                      = GetItemInfo(41173);       --"Fel Firestone"
  _,SMARTBUFF_FIRESGRAND                    = GetItemInfo(41174);       --"Grand Firestone"      
  _,SMARTBUFF_SPELLSTONE                    = GetItemInfo(41191);       --"Spellstone"    
  _,SMARTBUFF_SPELLSGREATER                 = GetItemInfo(41192);       --"Greater Spellstone"
  _,SMARTBUFF_SPELLSMAJOR                   = GetItemInfo(41193);       --"Major Spellstone"
  _,SMARTBUFF_SPELLSMASTER                  = GetItemInfo(41194);       --"Master Spellstone"
  _,SMARTBUFF_SPELLSDEMONIC                 = GetItemInfo(41195);       --"Demonic Spellstone"
  _,SMARTBUFF_SPELLSGRAND                   = GetItemInfo(41196);       --"Grand Spellstone"  
--  _,SMARTBUFF_MANAGEM                       = GetItemInfo(36799);       --"Mana Gem"
--  _,SMARTBUFF_BRILLIANTMANAGEM              = GetItemInfo(81901);       --"Brilliant Mana Gem"
  _,SMARTBUFF_SSROUGH                       = GetItemInfo(2862);        --"Rough Sharpening Stone"
  _,SMARTBUFF_SSCOARSE                      = GetItemInfo(2863);        --"Coarse Sharpening Stone"
  _,SMARTBUFF_SSHEAVY                       = GetItemInfo(2871);        --"Heavy Sharpening Stone"
  _,SMARTBUFF_SSSOLID                       = GetItemInfo(7964);        --"Solid Sharpening Stone"
  _,SMARTBUFF_SSDENSE                       = GetItemInfo(12404);       --"Dense Sharpening Stone"
  _,SMARTBUFF_SSELEMENTAL                   = GetItemInfo(18262);       --"Elemental Sharpening Stone"
  _,SMARTBUFF_SSFEL                         = GetItemInfo(23528);       --"Fel Sharpening Stone"
  _,SMARTBUFF_SSADAMANTITE                  = GetItemInfo(23529);       --"Adamantite Sharpening Stone"
  _,SMARTBUFF_WSROUGH                       = GetItemInfo(3239);        --"Rough Weightstone"
  _,SMARTBUFF_WSCOARSE                      = GetItemInfo(3240);        --"Coarse Weightstone"
  _,SMARTBUFF_WSHEAVY                       = GetItemInfo(3241);        --"Heavy Weightstone"
  _,SMARTBUFF_WSSOLID                       = GetItemInfo(7965);        --"Solid Weightstone"
  _,SMARTBUFF_WSDENSE                       = GetItemInfo(12643);       --"Dense Weightstone"
  _,SMARTBUFF_WSFEL                         = GetItemInfo(28420);       --"Fel Weightstone"
  _,SMARTBUFF_WSADAMANTITE                  = GetItemInfo(28421);       --"Adamantite Weightstone"
  _,SMARTBUFF_SHADOWOIL                     = GetItemInfo(3824);        --"Shadow Oil"
  _,SMARTBUFF_FROSTOIL                      = GetItemInfo(3829);        --"Frost Oil"
  _,SMARTBUFF_MANAOIL1                      = GetItemInfo(20745);       --"Minor Mana Oil"
  _,SMARTBUFF_MANAOIL2                      = GetItemInfo(20747);       --"Lesser Mana Oil"
  _,SMARTBUFF_MANAOIL3                      = GetItemInfo(20748);       --"Brilliant Mana Oil"
  _,SMARTBUFF_MANAOIL4                      = GetItemInfo(22521);       --"Superior Mana Oil"
  _,SMARTBUFF_WIZARDOIL1                    = GetItemInfo(20744);       --"Minor Wizard Oil"
  _,SMARTBUFF_WIZARDOIL2                    = GetItemInfo(20746);       --"Lesser Wizard Oil"
  _,SMARTBUFF_WIZARDOIL3                    = GetItemInfo(20750);       --"Wizard Oil"
  _,SMARTBUFF_WIZARDOIL4                    = GetItemInfo(20749);       --"Brilliant Wizard Oil"
  _,SMARTBUFF_WIZARDOIL5                    = GetItemInfo(22522);       --"Superior Wizard Oil"  
  -- Food
  _,SMARTBUFF_BEERBASTEDBOARRIBS			= GetItemInfo(2888);		--Beer Basted Boar Ribs
  _,SMARTBUFF_CRISPYBATWING			        = GetItemInfo(12224);		--Crispy Bat Wing
  _,SMARTBUFF_KALDOREISPIDERKABOB		    = GetItemInfo(5472);		--Kaldorei Spider Kabob
  _,SMARTBUFF_ROASTEDKODOMEAT			    = GetItemInfo(5474);		--Roasted Kodo Meat
  _,SMARTBUFF_HERBBAKEDEGG			        = GetItemInfo(6888);		--Herb Baked Egg
  _,SMARTBUFF_SPICEDWOLFMEAT			    = GetItemInfo(2680);		--Spiced Wolf Meat
  _,SMARTBUFF_BOILEDCLAMS				    = GetItemInfo(5525);		--Boiled Clams
  _,SMARTBUFF_COYOTESTEAK				    = GetItemInfo(2684);		--Coyote Steak
  _,SMARTBUFF_CRABCAKE				        = GetItemInfo(2683);		--Crab Cake
  _,SMARTBUFF_DRYPORKRIBS				    = GetItemInfo(2687);		--Dry Pork Ribs
  _,SMARTBUFF_BLOODSAUSAGE			        = GetItemInfo(3220);		--Blood Sausage
  _,SMARTBUFF_CROCOLISKSTEAK			    = GetItemInfo(3662);		--Crocolisk Steak
  _,SMARTBUFF_FILLETOFFRENZY			    = GetItemInfo(5476);		--Fillet of Frenzy
  _,SMARTBUFF_GORETUSKLIVERPIE			    = GetItemInfo(724);		    --Goretusk Liver Pie
  _,SMARTBUFF_STRIDERSTEW				    = GetItemInfo(5477);		--Strider Stew
  _,SMARTBUFF_GOBLINDEVILEDCLAMS			= GetItemInfo(5527);		--Goblin Deviled Clams
  _,SMARTBUFF_BIGBEARSTEAK			        = GetItemInfo(3726);		--Big Bear Steak
  _,SMARTBUFF_CRISPYLIZARDTAIL			    = GetItemInfo(5479);		--Crispy Lizard Tail
  _,SMARTBUFF_CROCOLISKGUMBO			    = GetItemInfo(3664);		--Crocolisk Gumbo
  _,SMARTBUFF_CURIOUSLYTASTYOMELET		    = GetItemInfo(3665);		--Curiously Tasty Omelet
  _,SMARTBUFF_GOOEYSPIDERCAKE			    = GetItemInfo(3666);		--Gooey Spider Cake
  _,SMARTBUFF_HOTLIONCHOPS			        = GetItemInfo(3727);		--Hot Lion Chops
  _,SMARTBUFF_LEANVENISON				    = GetItemInfo(5480);		--Lean Venison
  _,SMARTBUFF_LEANWOLFSTEAK			        = GetItemInfo(12209);		--Lean Wolf Steak
  _,SMARTBUFF_MURLOCFINSOUP			        = GetItemInfo(3663);		--Murloc Fin Soup
  _,SMARTBUFF_REDRIDGEGOULASH			    = GetItemInfo(1082);		--Redridge Goulash
  _,SMARTBUFF_SEASONEDWOLFKABOB			    = GetItemInfo(1017);		--Seasoned Wolf Kabob
  _,SMARTBUFF_CARRIONSURPRISE			    = GetItemInfo(12213);		-- Carrion Surprise
  _,SMARTBUFF_ROASTRAPTOR			        = GetItemInfo(12210);		-- Roast Raptor
  _,SMARTBUFF_GIANTCLAMSCORCHO			    = GetItemInfo(6038);		-- Giant Clam Scorcho
  _,SMARTBUFF_HEAVYCROCOLISKSTEW		    = GetItemInfo(20074);		-- Heavy Crocolisk Stew
  _,SMARTBUFF_HOTWOLFRIBS				    = GetItemInfo(13851);		-- Hot Wolf Ribs 
  _,SMARTBUFF_JUNGLESTEW				    = GetItemInfo(12212);		-- Jungle Stew
  _,SMARTBUFF_MYSTERYSTEW				    = GetItemInfo(12214);		-- Mystery Stew
  _,SMARTBUFF_SOOTHINGTURTLEBISQUE		    = GetItemInfo(3729);		-- Soothing Turtle Bisque
  _,SMARTBUFF_TASTYLIONSTEAK			    = GetItemInfo(3728);		-- Tasty Lion Steak
  _,SMARTBUFF_SPIDERSAUSAGE			        = GetItemInfo(17222);		-- Spider Sausage
  _,SMARTBUFF_HEAVYKODOSTEW			        = GetItemInfo(12215);		-- Heavy Kodo Stew
  _,SMARTBUFF_MONSTEROMELET			        = GetItemInfo(12218);		-- Monster Omelet
  _,SMARTBUFF_SPICEDCHILICRAB			    = GetItemInfo(12216);		-- Spiced Chili Crab
  _,SMARTBUFF_TENDERWOLFSTEAK			    = GetItemInfo(18045);		-- Tender Wolf Steak  
  _,SMARTBUFF_JUICYBEARBURGER               = GetItemInfo(35565);       --"Juicy Bear Burger"
  _,SMARTBUFF_CRUNCHYSPIDER                 = GetItemInfo(22645);       --"Crunchy Spider Surprise"
  _,SMARTBUFF_LYNXSTEAK                     = GetItemInfo(27635);       --"Lynx Steak"
  _,SMARTBUFF_CHARREDBEARKABOBS             = GetItemInfo(35563);       --"Charred Bear Kabobs"
  _,SMARTBUFF_BATBITES                      = GetItemInfo(27636);       --"Bat Bites"
  _,SMARTBUFF_ROASTEDMOONGRAZE              = GetItemInfo(24105);       --"Roasted Moongraze Tenderloin"
  _,SMARTBUFF_MOKNATHALSHORTRIBS            = GetItemInfo(31672);       --"Mok'Nathal Shortribs"
  _,SMARTBUFF_CRUNCHYSERPENT                = GetItemInfo(31673);       --"Crunchy Serpent"
  _,SMARTBUFF_ROASTEDCLEFTHOOF              = GetItemInfo(27658);       --"Roasted Clefthoof"
  _,SMARTBUFF_FISHERMANSFEAST               = GetItemInfo(33052);       --"Fisherman's Feast"
  _,SMARTBUFF_WARPBURGER                    = GetItemInfo(27659);       --"Warp Burger"
  _,SMARTBUFF_RAVAGERDOG                    = GetItemInfo(27655);       --"Ravager Dog"
  _,SMARTBUFF_SKULLFISHSOUP                 = GetItemInfo(33825);       --"Skullfish Soup"
  _,SMARTBUFF_BUZZARDBITES                  = GetItemInfo(27651);       --"Buzzard Bites"
  _,SMARTBUFF_TALBUKSTEAK                   = GetItemInfo(27660);       --"Talbuk Steak"
  _,SMARTBUFF_GOLDENFISHSTICKS              = GetItemInfo(27666);       --"Golden Fish Sticks"
  _,SMARTBUFF_SPICYHOTTALBUK                = GetItemInfo(33872);       --"Spicy Hot Talbuk"
  _,SMARTBUFF_FELTAILDELIGHT                = GetItemInfo(27662);       --"Feltail Delight"
  _,SMARTBUFF_BLACKENEDSPOREFISH            = GetItemInfo(27663);       --"Blackened Sporefish"
  _,SMARTBUFF_HOTAPPLECIDER                 = GetItemInfo(34411);       --"Hot Apple Cider"
  _,SMARTBUFF_BROILEDBLOODFIN               = GetItemInfo(33867);       --"Broiled Bloodfin"
  _,SMARTBUFF_SPICYCRAWDAD                  = GetItemInfo(27667);       --"Spicy Crawdad"
  _,SMARTBUFF_POACHEDBLUEFISH               = GetItemInfo(27665);       --"Poached Bluefish"
  _,SMARTBUFF_BLACKENEDBASILISK             = GetItemInfo(27657);       --"Blackened Basilisk"
  _,SMARTBUFF_GRILLEDMUDFISH                = GetItemInfo(27664);       --"Grilled Mudfish"
  _,SMARTBUFF_CLAMBAR                       = GetItemInfo(30155);       --"Clam Bar"
  _,SMARTBUFF_SAGEFISHDELIGHT               = GetItemInfo(21217);       --"Sagefish Delight"  
  _,SMARTBUFF_STEAMINGCHICKENSOUP           = GetItemInfo(42779);       --"Steaming Chicken Soup"
  _,SMARTBUFF_GRILLEDSQUID                  = GetItemInfo(13928);       --"Grilled Squid"  
  _,SMARTBUFF_BARBECUEDBUZZARDWING          = GetItemInfo(4457);        --"Barbecued Buzzard Wing"  
  
  -- poisons
  _,SMARTBUFF_INSTANTPOISON1				= GetItemInfo(6947);	    -- Instant Poison
  _,SMARTBUFF_INSTANTPOISON2				= GetItemInfo(6949);	    -- Instant Poison II
  _,SMARTBUFF_INSTANTPOISON3				= GetItemInfo(6950);	    -- Instant Poison III
  _,SMARTBUFF_INSTANTPOISON4				= GetItemInfo(8926);	    -- Instant Poison IV
  _,SMARTBUFF_INSTANTPOISON5				= GetItemInfo(8927);	    -- Instant Poison V
  _,SMARTBUFF_INSTANTPOISON6				= GetItemInfo(8928);	    -- Instant Poison VI
  _,SMARTBUFF_INSTANTPOISON7				= GetItemInfo(21927);	    -- Instant Poison VII
  _,SMARTBUFF_INSTANTPOISON8				= GetItemInfo(43230);	    -- Instant Poison VIII
  _,SMARTBUFF_INSTANTPOISON9				= GetItemInfo(43231);	    -- Instant Poison IX  
  _,SMARTBUFF_WOUNDPOISON1				    = GetItemInfo(10918);	    -- Wound Poison
  _,SMARTBUFF_WOUNDPOISON2				    = GetItemInfo(10920);	    -- Wound Poison II
  _,SMARTBUFF_WOUNDPOISON3				    = GetItemInfo(10921);	    -- Wound Poison III
  _,SMARTBUFF_WOUNDPOISON4				    = GetItemInfo(10922);	    -- Wound Poison IV
  _,SMARTBUFF_WOUNDPOISON5				    = GetItemInfo(22055);	    -- Wound Poison V
  _,SMARTBUFF_WOUNDPOISON6				    = GetItemInfo(43234);	    -- Wound Poison VI
  _,SMARTBUFF_WOUNDPOISON7				    = GetItemInfo(43235);	    -- Wound Poison VII  
  _,SMARTBUFF_MINDPOISON1					= GetItemInfo(5237);	    -- Mind-numbing Poison
  _,SMARTBUFF_MINDPOISON2					= GetItemInfo(6951);	    -- Mind-numbing Poison II
  _,SMARTBUFF_MINDPOISON3					= GetItemInfo(9186);	    -- Mind-numbing Poison III    
  _,SMARTBUFF_DEADLYPOISON1				    = GetItemInfo(2892);	    -- Deadly Poison
  _,SMARTBUFF_DEADLYPOISON2				    = GetItemInfo(2893);	    -- Deadly Poison II
  _,SMARTBUFF_DEADLYPOISON3				    = GetItemInfo(8984);	    -- Deadly Poison III
  _,SMARTBUFF_DEADLYPOISON4				    = GetItemInfo(8985);	    -- Deadly Poison IV
  _,SMARTBUFF_DEADLYPOISON5				    = GetItemInfo(20844);	    -- Deadly Poison V
  _,SMARTBUFF_DEADLYPOISON6				    = GetItemInfo(22053);	    -- Deadly Poison VI
  _,SMARTBUFF_DEADLYPOISON7				    = GetItemInfo(22054);	    -- Deadly Poison VII
  _,SMARTBUFF_DEADLYPOISON8				    = GetItemInfo(43232);	    -- Deadly Poison VIII
  _,SMARTBUFF_DEADLYPOISON9				    = GetItemInfo(43233);	    -- Deadly Poison IX  
  _,SMARTBUFF_CRIPPLINGPOISON1			    = GetItemInfo(3775);	    -- Crippling Poison
  _,SMARTBUFF_CRIPPLINGPOISON2			    = GetItemInfo(3776);	    -- Crippling Poison II  
  _,SMARTBUFF_ANESTHETICPOISON1			    = GetItemInfo(21835);	    -- Anesthetic Poison  
  _,SMARTBUFF_ANESTHETICPOISON2			    = GetItemInfo(43237);	    -- Anesthetic Poison II 

  -- ignored under wotlk
  SMARTBUFF_MANAAGATE			            = GetItemInfo(5514);	    -- Mana Agate 
  SMARTBUFF_MANACITRINE		                = GetItemInfo(8007);	    -- Mana Citrine 
  SMARTBUFF_MANAJADE			            = GetItemInfo(5513);	    -- Mana Jade
  SMARTBUFF_MANARUBY			            = GetItemInfo(8008);	    -- Mana Ruby 
  
  -- Food item IDs
  S.FoodItems = GetItems({39691, 34125, 42997, 42998, 42999, 43000, 43015, 34767, 42995, 34769, 34753, 34754, 
                        34758, 34766, 42994, 42996, 34756, 34768, 42993, 34755, 43001, 34757, 34752, 34751, 
                        34750, 34749, 34764, 34765, 34763, 34762, 42942, 43268, 34748, 45279});

  -- Conjured items
  ConjuredMageFood = { 5349, 1113, 1114, 1487, 8075, 8076, 22895, 22019, 43518, 43523 };        -- classic > wotlk conjured mage food
  ConjuredMageWater = { 5350, 2288, 2136, 3772, 8077, 8078, 8079, 30703, 22018 };               -- classic > wotlk conjured mage water
  ConjuredMageGems = { 5514, 5513, 8007, 8008, 22044, 33312};                                   -- classic > wotlk conjured gems.
  ConjuredLockHealthStones = { 5512, 5511, 5509, 5510, 11730, 22103, 36889, 36892, 36894 };     -- classic > wotlk warlock healthstones
  ConjuredLockSoulstones = { 5232, 16892, 16893, 16895, 16896, 22116, 36895, };                 -- classic > wotlk warlock soulstones
  ConjuredLockSpellstones = { 41191, 41192, 41193, 41194, 41195, 41196 };                       -- classic > wotlk warlock spellstones
  ConjuredLockFirestones = { 41170, 41169, 41171, 41172, 40773, 41173, 41174 };                 -- classic > wotlk warlock firestones
  
  -- Scrolls
  _,SMARTBUFF_SOAGILITY1          = GetItemInfo(3012);  --"Scroll of Agility I"
  _,SMARTBUFF_SOAGILITY2          = GetItemInfo(1477);  --"Scroll of Agility II"
  _,SMARTBUFF_SOAGILITY3          = GetItemInfo(4425);  --"Scroll of Agility III"b
  _,SMARTBUFF_SOAGILITY4          = GetItemInfo(10309); --"Scroll of Agility IV"
  _,SMARTBUFF_SOAGILITY5          = GetItemInfo(27498); --"Scroll of Agility V"
  _,SMARTBUFF_SOAGILITY6          = GetItemInfo(33457); --"Scroll of Agility VI"
  _,SMARTBUFF_SOAGILITY7          = GetItemInfo(43463); --"Scroll of Agility VII"
  _,SMARTBUFF_SOAGILITY8          = GetItemInfo(43464); --"Scroll of Agility VIII"
  _,SMARTBUFF_SOAGILITY9          = GetItemInfo(63303); --"Scroll of Agility IX"
  _,SMARTBUFF_SOINTELLECT1        = GetItemInfo(955);   --"Scroll of Intellect I"
  _,SMARTBUFF_SOINTELLECT2        = GetItemInfo(2290);  --"Scroll of Intellect II"
  _,SMARTBUFF_SOINTELLECT3        = GetItemInfo(4419);  --"Scroll of Intellect III"
  _,SMARTBUFF_SOINTELLECT4        = GetItemInfo(10308); --"Scroll of Intellect IV"
  _,SMARTBUFF_SOINTELLECT5        = GetItemInfo(27499); --"Scroll of Intellect V"
  _,SMARTBUFF_SOINTELLECT6        = GetItemInfo(33458); --"Scroll of Intellect VI"
  _,SMARTBUFF_SOINTELLECT7        = GetItemInfo(37091); --"Scroll of Intellect VII"
  _,SMARTBUFF_SOINTELLECT8        = GetItemInfo(37092); --"Scroll of Intellect VIII"
  _,SMARTBUFF_SOINTELLECT9        = GetItemInfo(63305); --"Scroll of Intellect IX"
  _,SMARTBUFF_SOSTAMINA1          = GetItemInfo(1180);  --"Scroll of Stamina I"
  _,SMARTBUFF_SOSTAMINA2          = GetItemInfo(1711);  --"Scroll of Stamina II"
  _,SMARTBUFF_SOSTAMINA3          = GetItemInfo(4422);  --"Scroll of Stamina III"
  _,SMARTBUFF_SOSTAMINA4          = GetItemInfo(10307); --"Scroll of Stamina IV"
  _,SMARTBUFF_SOSTAMINA5          = GetItemInfo(27502); --"Scroll of Stamina V"
  _,SMARTBUFF_SOSTAMINA6          = GetItemInfo(33461); --"Scroll of Stamina VI"
  _,SMARTBUFF_SOSTAMINA7          = GetItemInfo(37093); --"Scroll of Stamina VII"
  _,SMARTBUFF_SOSTAMINA8          = GetItemInfo(37094); --"Scroll of Stamina VIII"
  _,SMARTBUFF_SOSTAMINA9          = GetItemInfo(63306); --"Scroll of Stamina IX"
  _,SMARTBUFF_SOSPIRIT1           = GetItemInfo(1181);  --"Scroll of Spirit I"
  _,SMARTBUFF_SOSPIRIT2           = GetItemInfo(1712);  --"Scroll of Spirit II"
  _,SMARTBUFF_SOSPIRIT3           = GetItemInfo(4424);  --"Scroll of Spirit III"
  _,SMARTBUFF_SOSPIRIT4           = GetItemInfo(10306); --"Scroll of Spirit IV"
  _,SMARTBUFF_SOSPIRIT5           = GetItemInfo(27501); --"Scroll of Spirit V"
  _,SMARTBUFF_SOSPIRIT6           = GetItemInfo(33460); --"Scroll of Spirit VI"
  _,SMARTBUFF_SOSPIRIT7           = GetItemInfo(37097); --"Scroll of Spirit VII"
  _,SMARTBUFF_SOSPIRIT8           = GetItemInfo(37098); --"Scroll of Spirit VIII"
  _,SMARTBUFF_SOSPIRIT9           = GetItemInfo(63307); --"Scroll of Spirit IX"
  _,SMARTBUFF_SOSTRENGHT1         = GetItemInfo(954);   --"Scroll of Strength I"
  _,SMARTBUFF_SOSTRENGHT2         = GetItemInfo(2289);  --"Scroll of Strength II"
  _,SMARTBUFF_SOSTRENGHT3         = GetItemInfo(4426);  --"Scroll of Strength III"
  _,SMARTBUFF_SOSTRENGHT4         = GetItemInfo(10310); --"Scroll of Strength IV"
  _,SMARTBUFF_SOSTRENGHT5         = GetItemInfo(27503); --"Scroll of Strength V"
  _,SMARTBUFF_SOSTRENGHT6         = GetItemInfo(33462); --"Scroll of Strength VI"
  _,SMARTBUFF_SOSTRENGHT7         = GetItemInfo(43465); --"Scroll of Strength VII"
  _,SMARTBUFF_SOSTRENGHT8         = GetItemInfo(43466); --"Scroll of Strength VIII"
  _,SMARTBUFF_FLASKTBC1           = GetItemInfo(22854);  --"Flask of Relentless Assault"
  _,SMARTBUFF_FLASKTBC2           = GetItemInfo(22866);  --"Flask of Pure Death"
  _,SMARTBUFF_FLASKTBC3           = GetItemInfo(22851);  --"Flask of Fortification"
  _,SMARTBUFF_FLASKTBC4           = GetItemInfo(22861);  --"Flask of Blinding Light"
  _,SMARTBUFF_FLASKTBC5           = GetItemInfo(22853);  --"Flask of Mighty Versatility"
  _,SMARTBUFF_FLASK1              = GetItemInfo(46377);  --"Flask of Endless Rage"
  _,SMARTBUFF_FLASK2              = GetItemInfo(46376);  --"Flask of the Frost Wyrm"
  _,SMARTBUFF_FLASK3              = GetItemInfo(46379);  --"Flask of Stoneblood"
  _,SMARTBUFF_FLASK4              = GetItemInfo(46378);  --"Flask of Pure Mojo"
  _,SMARTBUFF_FLASK5              = GetItemInfo(44939);  --"Lesser Flask of Resistance"
  _,SMARTBUFF_FLASK6              = GetItemInfo(40079);  --"Lesser Flask of Toughness"
  _,SMARTBUFF_ELIXIRTBC1          = GetItemInfo(22831);  --"Elixir of Major Agility"
  _,SMARTBUFF_ELIXIRTBC2          = GetItemInfo(28104);  --"Elixir of Mastery"
  _,SMARTBUFF_ELIXIRTBC3          = GetItemInfo(22825);  --"Elixir of Healing Power"
  _,SMARTBUFF_ELIXIRTBC4          = GetItemInfo(22834);  --"Elixir of Major Defense"
  _,SMARTBUFF_ELIXIRTBC5          = GetItemInfo(22824);  --"Elixir of Major Strangth"
  _,SMARTBUFF_ELIXIRTBC6          = GetItemInfo(32062);  --"Elixir of Major Fortitude"
  _,SMARTBUFF_ELIXIRTBC7          = GetItemInfo(22840);  --"Elixir of Major Mageblood"
  _,SMARTBUFF_ELIXIRTBC8          = GetItemInfo(32067);  --"Elixir of Draenic Wisdom"
  _,SMARTBUFF_ELIXIRTBC9          = GetItemInfo(28103);  --"Adept's Elixir"
  _,SMARTBUFF_ELIXIRTBC10         = GetItemInfo(22848);  --"Elixir of Empowerment"
  _,SMARTBUFF_ELIXIRTBC11         = GetItemInfo(28102);  --"Onslaught Elixir"
  _,SMARTBUFF_ELIXIRTBC12         = GetItemInfo(22835);  --"Elixir of Major Shadow Power"
  _,SMARTBUFF_ELIXIRTBC13         = GetItemInfo(32068);  --"Elixir of Ironskin"
  _,SMARTBUFF_ELIXIRTBC14         = GetItemInfo(32063);  --"Earthen Elixir"
  _,SMARTBUFF_ELIXIRTBC15         = GetItemInfo(22827);  --"Elixir of Major Frost Power"
  _,SMARTBUFF_ELIXIRTBC16         = GetItemInfo(31679);  --"Fel Strength Elixir"
  _,SMARTBUFF_ELIXIRTBC17         = GetItemInfo(22833);  --"Elixir of Major Firepower"
  _,SMARTBUFF_ELIXIR1             = GetItemInfo(8949);   --"Elixir of Agility"
  _,SMARTBUFF_ELIXIR2             = GetItemInfo(39666);  --"Elixir of Mighty Agility"
  _,SMARTBUFF_ELIXIR3             = GetItemInfo(44332);  --"Elixir of Mighty Thoughts"
  _,SMARTBUFF_ELIXIR4             = GetItemInfo(40078);  --"Elixir of Mighty Fortitude"
  _,SMARTBUFF_ELIXIR5             = GetItemInfo(40073);  --"Elixir of Mighty Strength"
  _,SMARTBUFF_ELIXIR6             = GetItemInfo(40072);  --"Elixir of Spirit"
  _,SMARTBUFF_ELIXIR7             = GetItemInfo(40097);  --"Elixir of Protection"
  _,SMARTBUFF_ELIXIR8             = GetItemInfo(44328);  --"Elixir of Mighty Defense"
  _,SMARTBUFF_ELIXIR9             = GetItemInfo(44331);  --"Elixir of Lightning Speed"
  _,SMARTBUFF_ELIXIR10            = GetItemInfo(44329);  --"Elixir of Expertise"
  _,SMARTBUFF_ELIXIR11            = GetItemInfo(44327);  --"Elixir of Deadly Strikes"
  _,SMARTBUFF_ELIXIR12            = GetItemInfo(44330);  --"Elixir of Armor Piercing"
  _,SMARTBUFF_ELIXIR13            = GetItemInfo(44325);  --"Elixir of Accuracy"
  _,SMARTBUFF_ELIXIR14            = GetItemInfo(40076);  --"Guru's Elixir"
  _,SMARTBUFF_ELIXIR15            = GetItemInfo(9187);   --"Elixir of Greater Agility"
  _,SMARTBUFF_ELIXIR16            = GetItemInfo(28103);  --"Adept's Elixir"
  _,SMARTBUFF_ELIXIR17            = GetItemInfo(40070);  --"Spellpower Elixir"
 
  -- fishing pole
  _, _, _, _, _, _, S.FishingPole = GetItemInfo(6256);  --"Fishing Pole"
  SMARTBUFF_AddMsgD("Item list initialized");
end

--
--  Initialise SpellId Lists
--
function SMARTBUFF_InitSpellIDs()

  SMARTBUFF_TESTSPELL       = GetSpellInfo(774);

  -- Paladin - Updated 7/5/2023 ------------------------------------------------------------------
  -- blessings
  SMARTBUFF_GBOM                    = GetSpellInfo(25782);    --"Greater Blessing of Might"
  SMARTBUFF_GBOK                    = GetSpellInfo(25898);    --"Greater Blessing of Kings"
  SMARTBUFF_GBOW                    = GetSpellInfo(25894);    --"Greater Blessing of Wisdom"
  SMARTBUFF_GBOS                    = GetSpellInfo(25899);    --"Greater Blessing of Sanctuary"
  SMARTBUFF_BOM                     = GetSpellInfo(19740);    --"Blessing of Might"
  SMARTBUFF_BOK                     = GetSpellInfo(20217);    --"Blessing of Kings"
  SMARTBUFF_BOW                     = GetSpellInfo(19742);    --"Blessing of Wisdom"
  SMARTBUFF_BOS                     = GetSpellInfo(20911);    --"Blessing of Sanctuary"
  -- hands
  SMARTBUFF_HOF                     = GetSpellInfo(1044);     --"Hand of Freedom"
  SMARTBUFF_HOP                     = GetSpellInfo(1022);     --"Hand of Protection"
  SMARTBUFF_HOSAL                   = GetSpellInfo(1038);     --"Hand of Salvation"
  SMARTBUFF_HOSAC                   = GetSpellInfo(6940);     --"Hand of Sacrifice"
  -- seals
  SMARTBUFF_SOCOMMAND               = GetSpellInfo(20375);    --"Seal of Command"
  SMARTBUFF_SOVENGEANCE             = GetSpellInfo(31801);    --"Seal of Vengeance"
  SMARTBUFF_SOCORRUPTION            = GetSpellInfo(53736);    --"Seal of Corruption" (Blood Elf)
  SMARTBUFF_SOJUSTICE               = GetSpellInfo(20164);    --"Seal of Justice"
  SMARTBUFF_SORIGHTEOUSNESS         = GetSpellInfo(21084);    --"Seal of Righteousness"
  SMARTBUFF_SOWISDOM                = GetSpellInfo(20166);    --"Seal of Wisdom"
  SMARTBUFF_SOLIGHT                 = GetSpellInfo(20165);    --"Seal of Light"
  -- auras
  SMARTBUFF_CRUSADERAURA            = GetSpellInfo(32223);    --"Crusader Aura"
  SMARTBUFF_DEVOTIONAURA            = GetSpellInfo(465);      --"Devotion Aura"
  SMARTBUFF_RETRIBUTIONAURA         = GetSpellInfo(7294);     --"Retribution Aura"
  SMARTBUFF_FIREAURA                = GetSpellInfo(19891);    --"Fire Resistance Aura"
  SMARTBUFF_FROSTAURA               = GetSpellInfo(19888);    --"Frost Resistance Aura"
  SMARTBUFF_SHADOWAURA              = GetSpellInfo(19876);    --"Shadow Resistance Aura"
  -- other
  SMARTBUFF_RIGHTEOUSFURY           = GetSpellInfo(25780);    --"Righteous Fury"
  SMARTBUFF_HOLYSHIELD              = GetSpellInfo(20925);    --"Holy Shield"
  SMARTBUFF_SACREDSHIELD            = GetSpellInfo(53601);    --"Sacred Shield"
  SMARTBUFF_AVENGINGWARTH           = GetSpellInfo(31884);    --"Avenging Wrath"
  SMARTBUFF_BEACONOFLIGHT           = GetSpellInfo(53563);    --"Beacon of Light"
  -- Paladin buff links
  S.ChainPaladinAura     = { SMARTBUFF_DEVOTIONAURA, SMARTBUFF_RETRIBUTIONAURA, SMARTBUFF_CRUSADERAURA, SMARTBUFF_FIREAURA, SMARTBUFF_FROSTAURA, SMARTBUFF_SHADOWAURA };   -- *
  S.ChainPaladinSeal     = { SMARTBUFF_SOCOMMAND, SMARTBUFF_SOVENGEANCE, SMARTBUFF_SOCORRUPTION, SMARTBUFF_SOJUSTICE, SMARTBUFF_SORIGHTEOUSNESS, SMARTBUFF_SOWISDOM, SMARTBUFF_SOLIGHT };  -- *
  S.ChainPaladinHand     = { SMARTBUFF_HOF, SMARTBUFF_HOP, SMARTBUFF_HOSAL, SMARTBUFF_HOSAC };  -- *
  S.ChainPaladinBlessing = { SMARTBUFF_GBOM, SMARTBUFF_GBOK, SMARTBUFF_GBOW, SMARTBUFF_BOS, SMARTBUFF_BOM, SMARTBUFF_BOK, SMARTBUFF_BOW, SMARTBUFF_BOS};    -- *

  -- Mage - Updated 7/5/2023 ------------------------------------------------------------------------
  -- buffs
  SMARTBUFF_AI                  = GetSpellInfo(1459);       --"Arcane Intellect"
  SMARTBUFF_AB                  = GetSpellInfo(23028);      --"Arcane Brilliance"
  SMARTBUFF_DALI                = GetSpellInfo(61024);      --"Dalaran Intellect"
  SMARTBUFF_DALARANB            = GetSpellInfo(61316);      --"Dalaran Brilliance"
  -- Armor
  SMARTBUFF_ICEARMOR            = GetSpellInfo(7302);       --"Ice Armor"
  SMARTBUFF_FROSTARMOR          = GetSpellInfo(168);        --"Frost Armor"
  SMARTBUFF_MAGEARMOR           = GetSpellInfo(6117);       --"Mage Armor"
  SMARTBUFF_MOLTENARMOR         = GetSpellInfo(30482);      --"Molten Armor"
  -- Shields
  SMARTBUFF_MANASHIELD          = GetSpellInfo(1463);       --"Mana Shield"
  SMARTBUFF_ICEBARRIER          = GetSpellInfo(11426);      --"Ice Barrier"
  -- wards
  SMARTBUFF_FIREWARD            = GetSpellInfo(543);        --"Fire Ward"
  SMARTBUFF_FROSTWARD           = GetSpellInfo(6143);       --"Frost Ward"
  -- other
  SMARTBUFF_FOCUSMAGIC          = GetSpellInfo(54648);      --"Focus Magic"
  SMARTBUFF_AMPLIFYMAGIC        = GetSpellInfo(1008);       --"Amplify Magic"
  SMARTBUFF_DAMPENMAGIC         = GetSpellInfo(604);        --"Dampen Magic"
  SMARTBUFF_SUMMONWATERELE      = GetSpellInfo(31687);      --"Summon Water Elemental"
  SMARTBUFF_COMBUSTION          = GetSpellInfo(11129);      --"Combustion"
  SMARTBUFF_ARCANEPOWER         = GetSpellInfo(12042);      --"Arcane Power"
  SMARTBUFF_PRESENCEOFMIND      = GetSpellInfo(12043);      --"Presence of Mind"
  SMARTBUFF_ICYVEINS            = GetSpellInfo(12472);      --"Icy Veins"
  -- food and drink
  SMARTBUFF_CONJFOOD            = GetSpellInfo(587);        --"Conjure Food"
  SMARTBUFF_CONJWATER           = GetSpellInfo(5504);       --"Conjure Water"
  SMARTBUFF_CONJREFRESHMENT     = GetSpellInfo(42955);      --"Conjure Refreshment"
  SMARTBUFF_RITUALREFRESHMENT   = GetSpellInfo(43987);      --"Ritual Refreshment"
  
  -- separated for the purpose of classic era where multiple gems can be created,
  -- but under wrath the highest is always created.
  SMARTBUFF_CREATEMGEM_AGATE    = GetSpellInfo(759);        --"Conjure Mana Agate under classic era but Conjure Mana Gem in WOTLK"
  SMARTBUFF_CREATEMGEM_CITRINE  = GetSpellInfo(10053);      --"Conjure Mana Citrine - ignored in Wrath"
  SMARTBUFF_CREATEMGEM_JADE     = GetSpellInfo(3552);       --"Conjure Mana Jade - ignored in wrath"
  SMARTBUFF_CREATEMGEM_RUBY     = GetSpellInfo(10054);      --"Conjure Mana Ruby - ignored in wrath"
  
  -- Mage buff links
  S.ChainMageArmor = { SMARTBUFF_ICEARMOR, SMARTBUFF_FROSTARMOR, SMARTBUFF_MAGEARMOR, SMARTBUFF_MOLTENARMOR };
  S.ChainMageBuffs = { SMARTBUFF_AI, SMARTBUFF_AB, SMARTBUFF_DALI, SMARTBUFF_DALARANB }


  -- Druid - Updated 7/5/2023 ------------------------------------------------------------------------
  -- buffs
  SMARTBUFF_MOTW                = GetSpellInfo(1126);       --"Mark of the Wild"
  SMARTBUFF_GOTW                = GetSpellInfo(21849);      --"Gift of the Wild"
  SMARTBUFF_THORNS              = GetSpellInfo(467);        --"Thorns"
  SMARTBUFF_BARKSKIN            = GetSpellInfo(22812);      --"Barkskin"
  SMARTBUFF_NATURESGRASP        = GetSpellInfo(16689);      --"Nature's Grasp"
  -- forms
  SMARTBUFF_DRUID_CAT           = GetSpellInfo(768);        --"Cat Form"
  SMARTBUFF_DRUID_TREE          = GetSpellInfo(33891);      --"Incarnation: Tree of Life"
  SMARTBUFF_DRUID_MOONKIN       = GetSpellInfo(24858);      --"Moonkin Form"
  SMARTBUFF_DRUID_BEAR          = GetSpellInfo(5487);       --"Bear Form"
  SMARTBUFF_DRUID_DIREBEAR      = GetSpellInfo(9634);       --"Dire Bear Form"
  -- track humanoids
  SMARTBUFF_DRUID_TRACK         = GetSpellInfo(5225);       --"Track Humanoids"
  
  S.ChainDruidBuffs = { SMARTBUFF_MOTW, SMARTBUFF_GOTW }; 


  -- Priest - Updated 8/5/2023 ----------------------------------------------------------------------
  -- buffs
  SMARTBUFF_PWFORTITUDE         = GetSpellInfo(1243);       --"Power Word: Fortitude"
  SMARTBUFF_PRAYERFORTITUDE     = GetSpellInfo(21562);      --"Prayer of Fortitude"
  SMARTBUFF_DIVINESPIRIT        = GetSpellInfo(14752);      --"Divine Spirit"
  SMARTBUFF_PRAYERSPIRIT        = GetSpellInfo(27681);      --"Prayer of Spirit"
  SMARTBUFF_SHADOWPROT          = GetSpellInfo(976);        --"Shadow Protection"
  SMARTBUFF_PRAYERSHADOWPROT    = GetSpellInfo(27683);      --"Prayer of Shadow Protection"
  SMARTBUFF_INNERFOCUS          = GetSpellInfo(14751);      --"Inner Focus"
  SMARTBUFF_INNERFIRE           = GetSpellInfo(588);        --"Inner Fire"
  SMARTBUFF_FEARWARD            = GetSpellInfo(6346);       --"Fear Ward"
  -- forms
  SMARTBUFF_SHADOWFORM          = GetSpellInfo(15473);      --"Shadowform"
  -- Shields
  SMARTBUFF_PWSHIELD            = GetSpellInfo(17);         --"Power Word: Shield"
  -- other
  SMARTBUFF_ELUNESGRACE         = GetSpellInfo(2651);       --"Elune's Grace"
  SMARTBUFF_FEEDBACK            = GetSpellInfo(13896);      --"Feedback"
  SMARTBUFF_SHADOWGUARD         = GetSpellInfo(18137);      --"Shadowguard"
  SMARTBUFF_TOUCHOFWEAKNESS     = GetSpellInfo(2652);       --"Touch of Weakness"
  SMARTBUFF_RENEW               = GetSpellInfo(139);        --"Renew"
  SMARTBUFF_VAMPIRICEMB         = GetSpellInfo(15286);      --"Vampiric Embrace"  
  -- Priest buff links
  S.LinkPriestSpirit            = { SMARTBUFF_DIVINESPIRIT, SMARTBUFF_PRAYERSPIRIT };
  S.LinkPriestShadow            = { SMARTBUFF_SHADOWPROT, SMARTBUFF_PRAYERSHADOWPROT };

  
  -- Warrior - Updated 8/5/2023 ----------------------------------------------------------------------
  -- shouts
  SMARTBUFF_BATTLESHOUT         = GetSpellInfo(6673);       --"Battle Shout"
  SMARTBUFF_COMMANDINGSHOUT     = GetSpellInfo(469);        --"Commanding Shout"
  -- stances
  SMARTBUFF_BATSTANCE           = GetSpellInfo(2457);       --"Battle Stance"
  SMARTBUFF_DEFSTANCE           = GetSpellInfo(71);         --"Defensive Stance"
  SMARTBUFF_BESSTANCE           = GetSpellInfo(2458);       --"Beserker Stance"
  -- other
  SMARTBUFF_BERSERKERRAGE       = GetSpellInfo(18499);      --"Berserker Rage"
  SMARTBUFF_BLOODRAGE           = GetSpellInfo(2687);       --"Bloodrage"
  SMARTBUFF_RAMPAGE             = GetSpellInfo(29801);      --"Rampage"
  SMARTBUFF_VIGILANCE           = GetSpellInfo(50720);      --"Vigilance"
  SMARTBUFF_SHIELDBLOCK         = GetSpellInfo(2565);       --"Shield Block"
  -- Warrior buff links
  S.ChainWarriorStance = { SMARTBUFF_BATSTANCE, SMARTBUFF_DEFSTANCE, SMARTBUFF_BESSTANCE };
  S.ChainWarriorShout  = { SMARTBUFF_BATTLESHOUT, SMARTBUFF_COMMANDINGSHOUT };
  
  
 -- Shaman - Updated 8/5/2023 ----------------------------------------------------------------------
  -- shields
  SMARTBUFF_LIGHTNINGSHIELD = GetSpellInfo(324);   --"Lightning Shield"
  SMARTBUFF_WATERSHIELD     = GetSpellInfo(24398); --"Water Shield"
  SMARTBUFF_EARTHSHIELD     = GetSpellInfo(974);   --"Earth Shield"
  -- weapons
  SMARTBUFF_ROCKBITERW      = GetSpellInfo(8017);  --"Rockbiter Weapon"
  SMARTBUFF_FROSTBRANDW     = GetSpellInfo(8033);  --"Frostbrand Weapon"
  SMARTBUFF_FLAMETONGUEW    = GetSpellInfo(8024);  --"Flametongue Weapon"
  SMARTBUFF_WINDFURYW       = GetSpellInfo(8232);  --"Windfury Weapon"
  SMARTBUFF_EARTHLIVINGW    = GetSpellInfo(51730); --"Earthliving Weapon"
  -- buffs
  SMARTBUFF_WATERBREATHING  = GetSpellInfo(131);   --"Water Breathing"
  SMARTBUFF_WATERWALKING    = GetSpellInfo(546);   --"Water Walking"  
  -- Shaman chained
  S.ChainShamanShield = { SMARTBUFF_LIGHTNINGSHIELD, SMARTBUFF_WATERSHIELD, SMARTBUFF_EARTHSHIELD };
  
  
  -- Hunter - Updated 10/5/2023 ----------------------------------------------------------------------
  SMARTBUFF_TRUESHOTAURA    = GetSpellInfo(19506); --"Trueshot Aura"
  SMARTBUFF_RAPIDFIRE       = GetSpellInfo(3045);  --"Rapid Fire"
  SMARTBUFF_CALLPET         = GetSpellInfo(883);   --"Call Pet"
  SMARTBUFF_REVIVEPET       = GetSpellInfo(982);   --"Revive Pet"
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


  -- warlock - Updated 19/5/2023 --------------------------------------------------------------------  
  -- armor
  SMARTBUFF_DEMONSKIN           = GetSpellInfo(687);            --"Demon Armor"
  SMARTBUFF_DEMONARMOR          = GetSpellInfo(706);            --"Demon Armor"
  SMARTBUFF_FELARMOR            = GetSpellInfo(28176);          --"Fel Armor"  
  -- pets
  SMARTBUFF_SUMMONINFERNAL	    = GetSpellInfo(1122);           --"Summon Inferno"
  SMARTBUFF_SUMMONFELHUNTER	    = GetSpellInfo(691);            --"Summon Fellhunter"
  SMARTBUFF_SUMMONIMP	        = GetSpellInfo(688);            --"Summon Imp"
  SMARTBUFF_SUMMONSUCCUBUS	    = GetSpellInfo(712);            --"Summon Succubus"
  SMARTBUFF_SUMMONINCUBUS	    = GetSpellInfo(713);            --"Summon Incubus"
  SMARTBUFF_SUMMONVOIDWALKER    = GetSpellInfo(697);            --"Summon Voidwalker"
  -- buffs
  SMARTBUFF_UNENDINGBREATH      = GetSpellInfo(5697);           --"Unending Breath"
  -- create stones
  SMARTBUFF_CREATEHS            = GetSpellInfo(6201);           --"Create Healthstone"
  SMARTBUFF_CREATESOULS         = GetSpellInfo(693);            --"Create Soulstone"
  SMARTBUFF_CREATESPELLS        = GetSpellInfo(2362);           --"Create Spellstone"
  SMARTBUFF_CREATEFIRES         = GetSpellInfo(6366);           --"Create Firestone"  
  -- other
  SMARTBUFF_LOCKLESSERINVIS     = GetSpellInfo(6512);           --"Detect Lesser Invisibility"
  SMARTBUFF_LOCKINVISIBILITY    = GetSpellInfo(132);            --"Detect Invisibility"
  SMARTBUFF_LOCKSENSEDEMONS     = GetSpellInfo(5500);           --"Sense Demons"
  SMARTBUFF_SOULLINK            = GetSpellInfo(19028);          --"Soul Link"


  -- Death Knight - Updated 20/5/2023 --------------------------------------------------------------------  
  SMARTBUFF_DANCINGRW           = GetSpellInfo(49028);          --"Dancing Rune Weapon"
  SMARTBUFF_BLOODPRESENCE       = GetSpellInfo(48263);          --"Blood Presence"
  SMARTBUFF_FROSTPRESENCE       = GetSpellInfo(48266);          --"Frost Presence"
  SMARTBUFF_UNHOLYPRESENCE      = GetSpellInfo(48265);          --"Unholy Presence"  
  SMARTBUFF_PATHOFFROST         = GetSpellInfo(3714);           --"Path of Frost"
  SMARTBUFF_BONESHIELD          = GetSpellInfo(49222);          --"Bone Shield"
  SMARTBUFF_HORNOFWINTER        = GetSpellInfo(57330);          --"Horn of Winter"
  SMARTBUFF_RAISEDEAD           = GetSpellInfo(46584);          --"Raise Dead"  

  -- Death Knight buff links
  S.ChainDKPresence = { SMARTBUFF_BLOODPRESENCE, SMARTBUFF_FROSTPRESENCE, SMARTBUFF_UNHOLYPRESENCE };  


  -- Rogue - Updated 20/5/2023 --------------------------------------------------------------------  
  SMARTBUFF_STEALTH             = GetSpellInfo(1784);           --"Stealth"
  SMARTBUFF_BLADEFLURRY         = GetSpellInfo(13877);          --"Blade Flurry"
  SMARTBUFF_SAD                 = GetSpellInfo(5171);           --"Slice and Dice"
  SMARTBUFF_EVASION             = GetSpellInfo(5277);           --"Evasion"
  SMARTBUFF_HUNGERFORBLOOD      = GetSpellInfo(60177);          --"Hunger For Blood"
  SMARTBUFF_TRICKS              = GetSpellInfo(57934);          --"Tricks of the Trade"
  SMARTBUFF_RECUPERATE          = GetSpellInfo(185311);         --"Crimson Vial
  -- Poisons
  SMARTBUFF_WOUNDPOISON         = GetSpellInfo(8679);           --"Wound Poison"
  SMARTBUFF_CRIPPLINGPOISON     = GetSpellInfo(3408);           --"Crippling Poison"
  SMARTBUFF_DEADLYPOISON        = GetSpellInfo(2823);           --"Deadly Poison"
  SMARTBUFF_LEECHINGPOISON      = GetSpellInfo(108211);         --"Leeching Poison"
  SMARTBUFF_INSTANTPOISON       = GetSpellInfo(315584);         --"Instant Poison"
  SMARTBUFF_NUMBINGPOISON       = GetSpellInfo(5761);           --"Numbing Poison"
  SMARTBUFF_AMPLIFYPOISON       = GetSpellInfo(381664);         --"Amplifying Poison"
  SMARTBUFF_ATROPHICPOISON      = GetSpellInfo(381637);         --"Atrophic Poison"

  -- Rogue buff links   -- todo (20/5/2023)
--  S.ChainRoguePoisonsLethal     = { SMARTBUFF_DEADLYPOISON, SMARTBUFF_WOUNDPOISON, SMARTBUFF_INSTANTPOISON, SMARTBUFF_AGONIZINGPOISON, SMARTBUFF_AMPLIFYPOISON };
--  S.ChainRoguePoisonsNonLethal  = { SMARTBUFF_CRIPPLINGPOISON, SMARTBUFF_LEECHINGPOISON, SMARTBUFF_NUMBINGPOISON, SMARTBUFF_ATROPHICPOISON };


  -- Tracking
  SMARTBUFF_FINDMINERALS    = GetSpellInfo(2580);  --"Find Minerals"
  SMARTBUFF_FINDHERBS       = GetSpellInfo(2383);  --"Find Herbs"
  SMARTBUFF_FINDTREASURE    = GetSpellInfo(2481);  --"Find Treasure"
  SMARTBUFF_FINDFISH        = GetSpellInfo(43308); --"Find Fish"
  SMARTBUFF_FINDTREASURE    = GetSpellInfo(2481);  --"Find Treasure"
  SMARTBUFF_TRACKHUMANOIDS  = GetSpellInfo(19883); --"Track Humanoids"
  SMARTBUFF_DTRACKHUMANOIDS = GetSpellInfo(5225);  --"Druid Track Humanoids"
  SMARTBUFF_TRACKBEASTS     = GetSpellInfo(1494);  --"Track Beasts"
  SMARTBUFF_TRACKUNDEAD     = GetSpellInfo(19884); --"Track Undead"
  SMARTBUFF_TRACKHIDDEN     = GetSpellInfo(19885); --"Track Hidden"
  SMARTBUFF_TRACKELEMENTALS = GetSpellInfo(19880); --"Track Elementals"
  SMARTBUFF_TRACKDEMONS     = GetSpellInfo(19878); --"Track Demons"
  SMARTBUFF_TRACKGIANTS     = GetSpellInfo(19882); --"Track Giants"
  SMARTBUFF_TRACKDRAGONKIN  = GetSpellInfo(19879); --"Track Dragonkin"

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
  SMARTBUFF_SBAGILITY       = GetSpellInfo(8115);   --"Scroll buff: Agility"
  SMARTBUFF_SBINTELLECT     = GetSpellInfo(8096);   --"Scroll buff: Intellect"
  SMARTBUFF_SBSTAMINA       = GetSpellInfo(8099);   --"Scroll buff: Stamina"
  SMARTBUFF_SBSPIRIT        = GetSpellInfo(8112);   --"Scroll buff: Spirit"
  SMARTBUFF_SBSTRENGTH      = GetSpellInfo(8118);   --"Scroll buff: Strength"
  SMARTBUFF_SBPROTECTION    = GetSpellInfo(89344);  --"Scroll buff: Armor"
  SMARTBUFF_BMiscItem1      = GetSpellInfo(326396); --"WoW's 16th Anniversary"
  SMARTBUFF_BMiscItem2      = GetSpellInfo(62574);  --"Warts-B-Gone Lip Balm"
  SMARTBUFF_BMiscItem3      = GetSpellInfo(98444);  --"Vrykul Drinking Horn"
  SMARTBUFF_BMiscItem4      = GetSpellInfo(127230); --"Visions of Insanity"
  SMARTBUFF_BMiscItem5      = GetSpellInfo(124036); --"Anglers Fishing Raft"
  SMARTBUFF_BMiscItem6      = GetSpellInfo(125167); --"Ancient Pandaren Fishing Charm"
  SMARTBUFF_BMiscItem7      = GetSpellInfo(138927); --"Burning Essence"
  SMARTBUFF_BMiscItem8      = GetSpellInfo(160331); --"Blood Elf Illusion"
  SMARTBUFF_BMiscItem9      = GetSpellInfo(158486); --"Safari Hat"
  SMARTBUFF_BMiscItem10     = GetSpellInfo(158474); --"Savage Safari Hat"
  SMARTBUFF_BMiscItem11     = GetSpellInfo(176151); --"Whispers of Insanity"
  SMARTBUFF_BMiscItem12     = GetSpellInfo(193456); --"Gaze of the Legion"
  SMARTBUFF_BMiscItem13     = GetSpellInfo(193547); --"Fel Crystal Infusion"
  SMARTBUFF_BMiscItem14     = GetSpellInfo(190668); --"Empower"
  SMARTBUFF_BMiscItem14_1   = GetSpellInfo(175457); --"Focus Augmentation"
  SMARTBUFF_BMiscItem14_2   = GetSpellInfo(175456); --"Hyper Augmentation"
  SMARTBUFF_BMiscItem14_3   = GetSpellInfo(175439); --"Stout Augmentation
  SMARTBUFF_BMiscItem16     = GetSpellInfo(181642); --"Bodyguard Miniaturization Device"
  SMARTBUFF_BMiscItem17     = GetSpellInfo(242551); --"Fel Focus"

  S.LinkSafariHat           = { SMARTBUFF_BMiscItem9, SMARTBUFF_BMiscItem10 };
  S.LinkAugment             = { SMARTBUFF_BMiscItem14, SMARTBUFF_BMiscItem14_1, SMARTBUFF_BMiscItem14_2, SMARTBUFF_BMiscItem14_3, SMARTBUFF_BAugmentRune,  SMARTBUFF_BVieledAugment, SMARTBUFF_BDraconicRune };

  -- Flasks & Elixirs
  SMARTBUFF_BFLASKTBC1      = GetSpellInfo(28520);  --"Flask of Relentless Assault"
  SMARTBUFF_BFLASKTBC2      = GetSpellInfo(28540);  --"Flask of Pure Death"
  SMARTBUFF_BFLASKTBC3      = GetSpellInfo(28518);  --"Flask of Fortification"
  SMARTBUFF_BFLASKTBC4      = GetSpellInfo(28521);  --"Flask of Blinding Light"
  SMARTBUFF_BFLASKTBC5      = GetSpellInfo(28519);  --"Flask of Mighty Versatility"
  SMARTBUFF_BFLASK1         = GetSpellInfo(53760);  --"Flask of Endless Rage"
  SMARTBUFF_BFLASK2         = GetSpellInfo(53755);  --"Flask of the Frost Wyrm"
  SMARTBUFF_BFLASK3         = GetSpellInfo(53758);  --"Flask of Stoneblood"
  SMARTBUFF_BFLASK4         = GetSpellInfo(54212);  --"Flask of Pure Mojo"
  SMARTBUFF_BFLASK5         = GetSpellInfo(62213);  --"Lesser Flask of Resistance"
  SMARTBUFF_BFLASK6         = GetSpellInfo(53899);  --"Lesser Flask of Toughness"
  SMARTBUFF_BFLASKCT1       = GetSpellInfo(79471);  --"Flask of the Winds"
  SMARTBUFF_BFLASKCT2       = GetSpellInfo(79472);  --"Flask of Titanic Strength"
  SMARTBUFF_BFLASKCT3       = GetSpellInfo(79470);  --"Flask of the Draconic Mind"
  SMARTBUFF_BFLASKCT4       = GetSpellInfo(79469);  --"Flask of Steelskin"
  SMARTBUFF_BFLASKCT5       = GetSpellInfo(94160);  --"Flask of Flowing Water"
  SMARTBUFF_BFLASKCT7       = GetSpellInfo(92679);  --"Flask of Battle"
  SMARTBUFF_BFLASKMOP1      = GetSpellInfo(105617); --"Alchemist's Flask"
  SMARTBUFF_BFLASKMOP2      = GetSpellInfo(105694); --"Flask of the Earth"
  SMARTBUFF_BFLASKMOP3      = GetSpellInfo(105693); --"Flask of Falling Leaves"
  SMARTBUFF_BFLASKMOP4      = GetSpellInfo(105689); --"Flask of Spring Blossoms"
  SMARTBUFF_BFLASKMOP5      = GetSpellInfo(105691); --"Flask of the Warm Sun"
  SMARTBUFF_BFLASKMOP6      = GetSpellInfo(105696); --"Flask of Winter's Bite"
  SMARTBUFF_BFLASKCT61      = GetSpellInfo(79640);  --"Enhanced Intellect"
  SMARTBUFF_BFLASKCT62      = GetSpellInfo(79639);  --"Enhanced Agility"
  SMARTBUFF_BFLASKCT63      = GetSpellInfo(79638);  --"Enhanced Strength"
  SMARTBUFF_BFLASKWOD1      = GetSpellInfo(156077); --"Draenic Stamina Flask"
  SMARTBUFF_BFLASKWOD2      = GetSpellInfo(156071); --"Draenic Strength Flask"
  SMARTBUFF_BFLASKWOD3      = GetSpellInfo(156070); --"Draenic Intellect Flask"
  SMARTBUFF_BFLASKWOD4      = GetSpellInfo(156073); --"Draenic Agility Flask"
  SMARTBUFF_BGRFLASKWOD1    = GetSpellInfo(156084); --"Greater Draenic Stamina Flask"
  SMARTBUFF_BGRFLASKWOD2    = GetSpellInfo(156080); --"Greater Draenic Strength Flask"
  SMARTBUFF_BGRFLASKWOD3    = GetSpellInfo(156079); --"Greater Draenic Intellect Flask"
  SMARTBUFF_BGRFLASKWOD4    = GetSpellInfo(156064); --"Greater Draenic Agility Flask"
  SMARTBUFF_BFLASKLEG1      = GetSpellInfo(188035); --"Flask of Ten Thousand Scars"
  SMARTBUFF_BFLASKLEG2      = GetSpellInfo(188034); --"Flask of the Countless Armies"
  SMARTBUFF_BFLASKLEG3      = GetSpellInfo(188031); --"Flask of the Whispered Pact"
  SMARTBUFF_BFLASKLEG4      = GetSpellInfo(188033); --"Flask of the Seventh Demon"
  SMARTBUFF_BFLASKBFA1      = GetSpellInfo(251837); --"Flask of Endless Fathoms"
  SMARTBUFF_BFLASKBFA2      = GetSpellInfo(251836); --"Flask of the Currents"
  SMARTBUFF_BFLASKBFA3      = GetSpellInfo(251839); --"Flask of the Undertow"
  SMARTBUFF_BFLASKBFA4      = GetSpellInfo(251838); --"Flask of the Vast Horizon"
  SMARTBUFF_BGRFLASKBFA1    = GetSpellInfo(298837); --"Greather Flask of Endless Fathoms"
  SMARTBUFF_BGRFLASKBFA2    = GetSpellInfo(298836); --"Greater Flask of the Currents"
  SMARTBUFF_BGRFLASKBFA3    = GetSpellInfo(298841); --"Greather Flask of teh Untertow"
  SMARTBUFF_BGRFLASKBFA4    = GetSpellInfo(298839); --"Greater Flask of the Vast Horizon"
  SMARTBUFF_BFLASKSL1       = GetSpellInfo(307185); --"Spectral Flask of Power"
  SMARTBUFF_BFLASKSL2       = GetSpellInfo(307187); --"Spectral Flask of Stamina"

  S.LinkFlaskTBC            = { SMARTBUFF_BFLASKTBC1, SMARTBUFF_BFLASKTBC2, SMARTBUFF_BFLASKTBC3, SMARTBUFF_BFLASKTBC4, SMARTBUFF_BFLASKTBC5 };
  S.LinkFlaskCT7            = { SMARTBUFF_BFLASKCT1, SMARTBUFF_BFLASKCT2, SMARTBUFF_BFLASKCT3, SMARTBUFF_BFLASKCT4, SMARTBUFF_BFLASKCT5 };
  S.LinkFlaskMoP            = { SMARTBUFF_BFLASKCT61, SMARTBUFF_BFLASKCT62, SMARTBUFF_BFLASKCT63, SMARTBUFF_BFLASKMOP2, SMARTBUFF_BFLASKMOP3, SMARTBUFF_BFLASKMOP4, SMARTBUFF_BFLASKMOP5, SMARTBUFF_BFLASKMOP6 };
  S.LinkFlaskWoD            = { SMARTBUFF_BFLASKWOD1, SMARTBUFF_BFLASKWOD2, SMARTBUFF_BFLASKWOD3, SMARTBUFF_BFLASKWOD4, SMARTBUFF_BGRFLASKWOD1, SMARTBUFF_BGRFLASKWOD2, SMARTBUFF_BGRFLASKWOD3, SMARTBUFF_BGRFLASKWOD4 };
  S.LinkFlaskLeg            = { SMARTBUFF_BFLASKLEG1, SMARTBUFF_BFLASKLEG2, SMARTBUFF_BFLASKLEG3, SMARTBUFF_BFLASKLEG4 };
  S.LinkFlaskBfA            = { SMARTBUFF_BFLASKBFA1, SMARTBUFF_BFLASKBFA2, SMARTBUFF_BFLASKBFA3, SMARTBUFF_BFLASKBFA4, SMARTBUFF_BGRFLASKBFA1, SMARTBUFF_BGRFLASKBFA2, SMARTBUFF_BGRFLASKBFA3, SMARTBUFF_BGRFLASKBFA4 };
  S.LinkFlaskSL             = { SMARTBUFF_BFLASKSL1, SMARTBUFF_BFLASKSL2 };
  S.LinkFlaskDF             = { SMARTBUFF_BFlaskDF1, SMARTBUFF_BFlaskDF2, SMARTBUFF_BFlaskDF3, SMARTBUFF_BFlaskDF4, SMARTBUFF_BFlaskDF5, SMARTBUFF_BFlaskDF6, SMARTBUFF_BFlaskDF7, SMARTBUFF_BFlaskDF8, SMARTBUFF_BFlaskDF9, SMARTBUFF_BFlaskDF10, SMARTBUFF_BFlaskDF11, SMARTBUFF_BFlaskDF12, SMARTBUFF_BFlaskDF13_1, SMARTBUFF_BFlaskDF13_2, SMARTBUFF_BFlaskDF13_3, SMARTBUFF_BFlaskDF13_4, SMARTBUFF_BFlaskDF14 };

  SMARTBUFF_BELIXIRTBC1     = GetSpellInfo(54494);  --"Major Agility" B
  SMARTBUFF_BELIXIRTBC2     = GetSpellInfo(33726);  --"Mastery" B
  SMARTBUFF_BELIXIRTBC3     = GetSpellInfo(28491);  --"Healing Power" B
  SMARTBUFF_BELIXIRTBC4     = GetSpellInfo(28502);  --"Major Defense" G
  SMARTBUFF_BELIXIRTBC5     = GetSpellInfo(28490);  --"Major Strength" B
  SMARTBUFF_BELIXIRTBC6     = GetSpellInfo(39625);  --"Major Fortitude" G
  SMARTBUFF_BELIXIRTBC7     = GetSpellInfo(28509);  --"Major Mageblood" B
  SMARTBUFF_BELIXIRTBC8     = GetSpellInfo(39627);  --"Draenic Wisdom" B
  SMARTBUFF_BELIXIRTBC9     = GetSpellInfo(54452);  --"Adept's Elixir" B
  SMARTBUFF_BELIXIRTBC10    = GetSpellInfo(134870); --"Empowerment" B
  SMARTBUFF_BELIXIRTBC11    = GetSpellInfo(33720);  --"Onslaught Elixir" B
  SMARTBUFF_BELIXIRTBC12    = GetSpellInfo(28503);  --"Major Shadow Power" B
  SMARTBUFF_BELIXIRTBC13    = GetSpellInfo(39628);  --"Ironskin" G
  SMARTBUFF_BELIXIRTBC14    = GetSpellInfo(39626);  --"Earthen Elixir" G
  SMARTBUFF_BELIXIRTBC15    = GetSpellInfo(28493);  --"Major Frost Power" B
  SMARTBUFF_BELIXIRTBC16    = GetSpellInfo(38954);  --"Fel Strength Elixir" B
  SMARTBUFF_BELIXIRTBC17    = GetSpellInfo(28501);  --"Major Firepower" B
  SMARTBUFF_BELIXIR1        = GetSpellInfo(28497);  --"Mighty Agility" B
  SMARTBUFF_BELIXIR2        = GetSpellInfo(60347);  --"Mighty Thoughts" G
  SMARTBUFF_BELIXIR3        = GetSpellInfo(53751);  --"Elixir of Mighty Fortitude" G
  SMARTBUFF_BELIXIR4        = GetSpellInfo(53748);  --"Mighty Strength" B
  SMARTBUFF_BELIXIR5        = GetSpellInfo(53747);  --"Elixir of Spirit" B
  SMARTBUFF_BELIXIR6        = GetSpellInfo(53763);  --"Protection" G
  SMARTBUFF_BELIXIR7        = GetSpellInfo(60343);  --"Mighty Defense" G
  SMARTBUFF_BELIXIR8        = GetSpellInfo(60346);  --"Lightning Speed" B
  SMARTBUFF_BELIXIR9        = GetSpellInfo(60344);  --"Expertise" B
  SMARTBUFF_BELIXIR10       = GetSpellInfo(60341);  --"Deadly Strikes" B
  SMARTBUFF_BELIXIR11       = GetSpellInfo(80532);  --"Armor Piercing"
  SMARTBUFF_BELIXIR12       = GetSpellInfo(60340);  --"Accuracy" B
  SMARTBUFF_BELIXIR13       = GetSpellInfo(53749);  --"Guru's Elixir" B
  SMARTBUFF_BELIXIR14       = GetSpellInfo(11334);  --"Elixir of Greater Agility" B
  SMARTBUFF_BELIXIR15       = GetSpellInfo(54452);  --"Adept's Elixir" B
  SMARTBUFF_BELIXIR16       = GetSpellInfo(33721);  --"Spellpower Elixir" B
  SMARTBUFF_BELIXIRCT1      = GetSpellInfo(79635);  --"Elixir of the Master" B
  SMARTBUFF_BELIXIRCT2      = GetSpellInfo(79632);  --"Elixir of Mighty Speed" B
  SMARTBUFF_BELIXIRCT3      = GetSpellInfo(79481);  --"Elixir of Impossible Accuracy" B
  SMARTBUFF_BELIXIRCT4      = GetSpellInfo(79631);  --"Prismatic Elixir" G
  SMARTBUFF_BELIXIRCT5      = GetSpellInfo(79480);  --"Elixir of Deep Earth" G
  SMARTBUFF_BELIXIRCT6      = GetSpellInfo(79477);  --"Elixir of the Cobra" B
  SMARTBUFF_BELIXIRCT7      = GetSpellInfo(79474);  --"Elixir of the Naga" B
  SMARTBUFF_BELIXIRCT8      = GetSpellInfo(79468);  --"Ghost Elixir" B
  SMARTBUFF_BELIXIRMOP1     = GetSpellInfo(105687); --"Elixir of Mirrors" G
  SMARTBUFF_BELIXIRMOP2     = GetSpellInfo(105685); --"Elixir of Peace" B
  SMARTBUFF_BELIXIRMOP3     = GetSpellInfo(105686); --"Elixir of Perfection" B
  SMARTBUFF_BELIXIRMOP4     = GetSpellInfo(105684); --"Elixir of the Rapids" B
  SMARTBUFF_BELIXIRMOP5     = GetSpellInfo(105683); --"Elixir of Weaponry" B
  SMARTBUFF_BELIXIRMOP6     = GetSpellInfo(105682); --"Mad Hozen Elixir" B
  SMARTBUFF_BELIXIRMOP7     = GetSpellInfo(105681); --"Mantid Elixir" G
  SMARTBUFF_BELIXIRMOP8     = GetSpellInfo(105688); --"Monk's Elixir" B
  -- Draught of Ten Lands
  SMARTBUFF_BEXP_POTION     = GetSpellInfo(289982); --Draught of Ten Lands

  --if (SMARTBUFF_GOTW) then
  --  SMARTBUFF_AddMsgD(SMARTBUFF_GOTW.." found");
  --end

  -- Buff map
  S.LinkStats = { SMARTBUFF_BOK, SMARTBUFF_GBOK, SMARTBUFF_MOTW, SMARTBUFF_GOTW, SMARTBUFF_LOTE, SMARTBUFF_LOTWT,
                  GetSpellInfo(159988), -- Bark of the Wild
                  GetSpellInfo(203538), -- Greater Blessing of Kings
                  GetSpellInfo(90363),  -- Embrace of the Shale Spider
                  GetSpellInfo(160077)  -- Strength of the Earth
                };

  S.LinkSta   = { SMARTBUFF_PWFORTITUDE, SMARTBUFF_PRAYERFORTITUDE, SMARTBUFF_COMMANDINGSHOUT, SMARTBUFF_BLOODPACT,
                  GetSpellInfo(50256),  -- Invigorating Roar
                  GetSpellInfo(90364),  -- Qiraji Fortitude
                  GetSpellInfo(160014), -- Sturdiness
                  GetSpellInfo(160003)  -- Savage Vigor
                };

  S.LinkAp    = { SMARTBUFF_HORNOFWINTER, SMARTBUFF_BATTLESHOUT, SMARTBUFF_TRUESHOTAURA };

  S.LinkMa    = { SMARTBUFF_BOM, SMARTBUFF_DRUID_MKAURA, SMARTBUFF_GRACEOFAIR, SMARTBUFF_POTGRAVE,
                  GetSpellInfo(93435),  -- Roar of Courage
                  GetSpellInfo(160039), -- Keen Senses
                  GetSpellInfo(128997), -- Spirit Beast Blessing
                  GetSpellInfo(160073)  -- Plainswalking
                };

  S.LinkInt   = { SMARTBUFF_BOW, SMARTBUFF_AI, SMARTBUFF_AB, SMARTBUFF_DALARANB };

  --SMARTBUFF_AddMsgD("Spell IDs initialized");
end


function SMARTBUFF_InitSpellList()

  if (SMARTBUFF_PLAYERCLASS == nil) then return; end

  -- Paladin
  if (SMARTBUFF_PLAYERCLASS == "PALADIN") then          -- updated 7/5/2023 Codermik
    SMARTBUFF_BUFFLIST = {
      -- blessings.
      {SMARTBUFF_GBOM, 60, SMARTBUFF_CONST_GROUP, {52, 60, 70, 73, 79}, nil, S.LinkMa},
      {SMARTBUFF_GBOK, 60, SMARTBUFF_CONST_GROUP, {52, 60, 70, 73, 79}, nil, S.LinkStats},
      {SMARTBUFF_GBOW, 60, SMARTBUFF_CONST_GROUP, {52, 60, 70, 73, 79}, nil, S.LinkInt},
      {SMARTBUFF_GBOS, 60, SMARTBUFF_CONST_GROUP, {60}, nil, S.ChainPaladinBlessing},
      {SMARTBUFF_BOM, 10, SMARTBUFF_CONST_GROUP, {52, 60, 70, 73, 79}, nil, S.LinkMa},
      {SMARTBUFF_BOK, 10, SMARTBUFF_CONST_GROUP, {52, 60, 70, 73, 79}, nil, S.LinkStats},
      {SMARTBUFF_BOW, 10, SMARTBUFF_CONST_GROUP, {52, 60, 70, 73, 79}, nil, S.LinkInt},
      {SMARTBUFF_BOS, 10, SMARTBUFF_CONST_GROUP, {60}, nil, S.ChainPaladinBlessing},
      -- hands
      {SMARTBUFF_HOF, 0.1, SMARTBUFF_CONST_GROUP, {26}, "WARRIOR;DEATHKNIGHT;DRUID;SHAMAN;HUNTER;ROGUE;MAGE;PRIEST;PALADIN;WARLOCK;HPET;WPET;DKPET", S.ChainPaladinHand},
      {SMARTBUFF_HOP, 0.1, SMARTBUFF_CONST_GROUP, {10, 24, 38}, "WARRIOR;DEATHKNIGHT;DRUID;SHAMAN;HUNTER;ROGUE;MAGE;PRIEST;PALADIN;WARLOCK;HPET;WPET;DKPET", S.ChainPaladinHand},
      {SMARTBUFF_HOSAL, 0.1, SMARTBUFF_CONST_GROUP, {26}, "WARRIOR;DEATHKNIGHT;DRUID;SHAMAN;HUNTER;ROGUE;MAGE;PRIEST;PALADIN;WARLOCK;HPET;WPET;DKPET", S.ChainPaladinHand},
      {SMARTBUFF_HOSAC, 0.1, SMARTBUFF_CONST_GROUP, {46}, "WARRIOR;DEATHKNIGHT;DRUID;SHAMAN;HUNTER;ROGUE;MAGE;PRIEST;PALADIN;WARLOCK;HPET;WPET;DKPET", S.ChainPaladinHand},
      -- seals
      {SMARTBUFF_SOCOMMAND, 30, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainPaladinSeal},     
      {SMARTBUFF_SOVENGEANCE, 30, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainPaladinSeal},     
      {SMARTBUFF_SOCORRUPTION, 30, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainPaladinSeal},     
      {SMARTBUFF_SOJUSTICE, 30, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainPaladinSeal},     
      {SMARTBUFF_SORIGHTEOUSNESS, 30, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainPaladinSeal},     
      {SMARTBUFF_SOWISDOM, 30, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainPaladinSeal},   
      {SMARTBUFF_SOLIGHT, 30, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainPaladinSeal}, 
      -- auras
      {SMARTBUFF_CRUSADERAURA, -1, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainPaladinAura},
      {SMARTBUFF_DEVOTIONAURA, -1, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainPaladinAura},
      {SMARTBUFF_RETRIBUTIONAURA, -1, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainPaladinAura},
      {SMARTBUFF_FIREAURA, -1, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainPaladinAura}, 
	  {SMARTBUFF_FROSTAURA, -1, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainPaladinAura}, 
	  {SMARTBUFF_SHADOWAURA, -1, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainPaladinAura},
      -- other
      {SMARTBUFF_RIGHTEOUSFURY, -1, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_HOLYSHIELD, 8, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_SACREDSHIELD, 12, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_AVENGINGWARTH, 180, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_BEACONOFLIGHT, 60, SMARTBUFF_CONST_GROUP, {60}, "WARRIOR;DEATHKNIGHT;DRUID;SHAMAN;HUNTER;ROGUE;MAGE;PRIEST;PALADIN;WARLOCK;HPET;WPET;DKPET"},
    };
  end

  -- Mage
  if (SMARTBUFF_PLAYERCLASS == "MAGE") then          -- updated 5/5/2023 Codermik
    SMARTBUFF_BUFFLIST = {      
      -- buffs
      {SMARTBUFF_AI, 30, SMARTBUFF_CONST_GROUP, {1,14,28,42,56,70,80}, "WARRIOR;DEATHKNIGHT;ROGUE;HPET;WPET;DKPET", S.ChainMageBuffs},
      {SMARTBUFF_AB, 60, SMARTBUFF_CONST_GROUP, {56, 70, 80}, "WARRIOR;DEATHKNIGHT;ROGUE;HPET;WPET;DKPET", S.ChainMageBuffs},
	  {SMARTBUFF_DALI, 30, SMARTBUFF_CONST_GROUP, {80}, "WARRIOR;DEATHKNIGHT;ROGUE;HPET;WPET;DKPET", S.ChainMageBuffs},
      {SMARTBUFF_DALARANB, 60, SMARTBUFF_CONST_GROUP, {80}, "WARRIOR;DEATHKNIGHT;ROGUE;HPET;WPET;DKPET", S.ChainMageBuffs},
      -- Armor
      {SMARTBUFF_ICEARMOR, -1, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainMageArmor},
      {SMARTBUFF_FROSTARMOR, -1, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainMageArmor},
      {SMARTBUFF_MAGEARMOR, -1, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainMageArmor},
      {SMARTBUFF_MOLTENARMOR, -1, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainMageArmor},
      -- Shields
      {SMARTBUFF_MANASHIELD, 0.5, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_ICEBARRIER, 0.5, SMARTBUFF_CONST_SELF},
      -- Wards
      {SMARTBUFF_FIREWARD, 30, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_FROSTWARD, 30, SMARTBUFF_CONST_SELF},
      -- other
      {SMARTBUFF_FOCUSMAGIC, 30, SMARTBUFF_CONST_GROUP},
      {SMARTBUFF_AMPLIFYMAGIC, 10, SMARTBUFF_CONST_GROUP, {18,30,42,63,69,77,80}, "WARRIOR;DEATHKNIGHT;ROGUE;HPET;WPET;DKPET"},
      {SMARTBUFF_DAMPENMAGIC, 10, SMARTBUFF_CONST_GROUP, {12,24,36,48,60,67,76}, "WARRIOR;DEATHKNIGHT;ROGUE;HPET;WPET;DKPET"},
      {SMARTBUFF_SUMMONWATERELE, -1, SMARTBUFF_CONST_SELF, nil, S.CheckPet},
      {SMARTBUFF_COMBUSTION, -1, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_ARCANEPOWER, 0.25, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_PRESENCEOFMIND, 0.165, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_ICYVEINS, 0.333, SMARTBUFF_CONST_SELF},
      -- food and drink
      {SMARTBUFF_CONJFOOD, -1, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_CONJWATER, -1, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_CONJREFRESHMENT, -1, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_RITUALREFRESHMENT, -1, SMARTBUFF_CONST_SELF},	  
      {SMARTBUFF_CREATEMGEM_AGATE, -1, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_CREATEMGEM_CITRINE, -1, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_CREATEMGEM_JADE, -1, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_CREATEMGEM_RUBY, -1, SMARTBUFF_CONST_SELF},
    };
  end

  -- Druid
  if (SMARTBUFF_PLAYERCLASS == "DRUID") then          -- updated 28/5/2023 Codermik
    SMARTBUFF_BUFFLIST = {
      -- buffs
      {SMARTBUFF_MOTW, 30, SMARTBUFF_CONST_GROUP, {1,10,20,30,40,50,60,70,80}, "HPET;WPET;DKPET", S.ChainDruidBuffs},
      {SMARTBUFF_GOTW, 60, SMARTBUFF_CONST_GROUP, {50,60,70,80}, "HPET;WPET;DKPET", S.ChainDruidBuffs},
      {SMARTBUFF_THORNS, 10, SMARTBUFF_CONST_GROUP, nil, "HPET;WPET;DKPET"},
      {SMARTBUFF_BARKSKIN, 0.25, SMARTBUFF_CONST_FORCESELF},
	  {SMARTBUFF_NATURESGRASP, 0.25, SMARTBUFF_CONST_FORCESELF},
      -- forms
      {SMARTBUFF_DRUID_CAT, -1, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_DRUID_TREE, -1, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_DRUID_MOONKIN, -1, SMARTBUFF_CONST_SELF},
      {SSMARTBUFF_DRUID_BEAR, -1, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_DRUID_DIREBEAR, -1, SMARTBUFF_CONST_SELF},
      -- tracking.
      {SMARTBUFF_DRUID_TRACK, -1, SMARTBUFF_CONST_SELF, nil, SMARTBUFF_DRUID_CAT}
    };
  end

  -- Priest
  if (SMARTBUFF_PLAYERCLASS == "PRIEST") then          -- updated 5/10/2023 Codermik  
    SMARTBUFF_BUFFLIST = {	
	  -- Buffs
	  {SMARTBUFF_PWFORTITUDE, 30, SMARTBUFF_CONST_GROUP, {1, 12, 24, 36, 48, 60, 70, 80}, "HPET;WPET;DKPET", S.LinkSta},
	  {SMARTBUFF_PRAYERFORTITUDE, 60, SMARTBUFF_CONST_GROUP, {48, 60, 70, 80}, "HPET;WPET;DKPET", S.LinkSta},
	  {SMARTBUFF_DIVINESPIRIT, 30, SMARTBUFF_CONST_GROUP, {30, 40, 50, 60, 70, 80}, "WARRIOR;DEATHKNIGHT;ROGUE;HPET;WPET;DKPET", S.LinkPriestSpirit},
	  {SMARTBUFF_PRAYERSPIRIT, 60, SMARTBUFF_CONST_GROUP, {60, 70, 80}, "WARRIOR;DEATHKNIGHT;ROGUE;HPET;WPET;DKPET", S.LinkPriestSpirit},
	  {SMARTBUFF_SHADOWPROT, 30, SMARTBUFF_CONST_GROUP, {30, 42, 56, 68, 76}, "HPET;WPET;DKPET", S.LinkPriestShadow},
	  {SMARTBUFF_PRAYERSHADOWPROT, 60, SMARTBUFF_CONST_GROUP, {56, 70, 77}, "HPET;WPET;DKPET", S.LinkPriestShadow},
	  {SMARTBUFF_FEARWARD, 3, SMARTBUFF_CONST_GROUP, {54}, "HPET;WPET;DKPET"},
      {SMARTBUFF_INNERFOCUS, -1, SMARTBUFF_CONST_SELF},
	  {SMARTBUFF_INNERFIRE, 30, SMARTBUFF_CONST_FORCESELF},
	  {SMARTBUFF_VAMPIRICEMB, 30, SMARTBUFF_CONST_SELF},
	  -- form
	  {SMARTBUFF_SHADOWFORM, -1, SMARTBUFF_CONST_FORCESELF},
	  -- shield
      {SMARTBUFF_PWSHIELD, 0.5, SMARTBUFF_CONST_GROUP, {6, 12, 18, 24, 30, 36, 42, 48, 54, 60, 65, 70, 75, 80}, "MAGE;WARLOCK;ROGUE;PALADIN;WARRIOR;DRUID;HUNTER;SHAMAN;DEATHKNIGHT;HPET;WPET;DKPET"},
	  -- other
	  {SMARTBUFF_ELUNESGRACE, 0.25, SMARTBUFF_CONST_SELF},
	  {SMARTBUFF_FEEDBACK, 0.25, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_SHADOWGUARD, 10, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_TOUCHOFWEAKNESS, 10, SMARTBUFF_CONST_SELF},
    };	
  end
    
  -- Warrior
  if (SMARTBUFF_PLAYERCLASS == "WARRIOR") then          -- updated 8/5/2023 Codermik  
    SMARTBUFF_BUFFLIST = {
     {SMARTBUFF_BATTLESHOUT, 2, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainWarriorShout},
      {SMARTBUFF_COMMANDINGSHOUT, 2, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainWarriorShout},
      {SMARTBUFF_BERSERKERRAGE, 0.165, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_SHIELDBLOCK, 0.1666, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_BLOODRAGE, 0.165, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_RAMPAGE, 0.5, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_VIGILANCE, 30, SMARTBUFF_CONST_GROUP, {40}, "WARRIOR;DRUID;SHAMAN;HUNTER;ROGUE;MAGE;PRIEST;PALADIN;WARLOCK;DEATHKNIGHT;HPET;WPET;DKPET"},
    };
  end

  -- Shaman
  if (SMARTBUFF_PLAYERCLASS == "SHAMAN") then           -- updated 8/5/2023 Codermik  
    SMARTBUFF_BUFFLIST = {
	  -- shields
      {SMARTBUFF_LIGHTNINGSHIELD, 10, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainShamanShield},
      {SMARTBUFF_WATERSHIELD, 10, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainShamanShield},
      {SMARTBUFF_EARTHSHIELD, 10, SMARTBUFF_CONST_GROUP, {50,60, 70, 75, 80}, "WARRIOR;DEATHKNIGHT;DRUID;SHAMAN;HUNTER;ROGUE;MAGE;PRIEST;PALADIN;WARLOCK;HPET;WPET;DKPET", nil, S.ChainShamanShield},
      -- weapons
      {SMARTBUFF_WINDFURYW, 30, SMARTBUFF_CONST_WEAPON},
      {SMARTBUFF_FLAMETONGUEW, 30, SMARTBUFF_CONST_WEAPON},
      {SMARTBUFF_FROSTBRANDW, 30, SMARTBUFF_CONST_WEAPON},
      {SMARTBUFF_ROCKBITERW, 30, SMARTBUFF_CONST_WEAPON},
      {SMARTBUFF_EARTHLIVINGW, 30, SMARTBUFF_CONST_WEAPON},
	  -- buffs
      {SMARTBUFF_WATERBREATHING, 10, SMARTBUFF_CONST_GROUP, {22}},
      {SMARTBUFF_WATERWALKING, 10, SMARTBUFF_CONST_GROUP, {28}}
    };
  end

  -- Hunter
  if (SMARTBUFF_PLAYERCLASS == "HUNTER") then          -- updated 10/5/2023
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
      {SMARTBUFF_AOTP, -1, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainAspects},
	  {SMARTBUFF_REVIVEPET, -1, SMARTBUFF_CONST_SELF}, 
      {SMARTBUFF_CALLPET, -1, SMARTBUFF_CONST_SELF, nil, S.CheckPet},
    };
  end
  
  
  -- Warlock
  if (SMARTBUFF_PLAYERCLASS == "WARLOCK") then          -- updated 20/5/2023 
    SMARTBUFF_BUFFLIST = {
      -- buffs
	  {SMARTBUFF_DEMONSKIN, -1, SMARTBUFF_CONST_SELF},
	  {SMARTBUFF_DEMONARMOR, -1, SMARTBUFF_CONST_SELF},
	  {SMARTBUFF_FELARMOR, -1, SMARTBUFF_CONST_SELF},
	  {SMARTBUFF_LOCKSENSEDEMONS, -1, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_UNENDINGBREATH, 10, SMARTBUFF_CONST_GROUP, {16}, "HPET;WPET;DKPET"},
	  {SMARTBUFF_LOCKLESSERINVIS, 10, SMARTBUFF_CONST_GROUP, {26}, "HPET;WPET;DKPET"},
	  {SMARTBUFF_LOCKINVISIBILITY, 10, SMARTBUFF_CONST_GROUP, {26}, "HPET;WPET;DKPET"},
	  -- pets
	  {SMARTBUFF_SUMMONINFERNAL, -1, SMARTBUFF_CONST_SELF, nil, S.CheckPet},
      {SMARTBUFF_SUMMONFELHUNTER, -1, SMARTBUFF_CONST_SELF, nil, S.CheckPet},
      {SMARTBUFF_SUMMONIMP, -1, SMARTBUFF_CONST_SELF, nil, S.CheckPet},
      {SMARTBUFF_SUMMONSUCCUBUS, -1, SMARTBUFF_CONST_SELF, nil, S.CheckPet},
      {SMARTBUFF_SUMMONINCUBUS, -1, SMARTBUFF_CONST_SELF, nil, S.CheckPet},
      {SMARTBUFF_SUMMONVOIDWALKER, -1, SMARTBUFF_CONST_SELF, nil, S.CheckPet},
	  {SMARTBUFF_SOULLINK, 0, SMARTBUFF_CONST_SELF, nil, S.CheckPet},
      -- create stones
	  {SMARTBUFF_CREATEHS, -1, SMARTBUFF_CONST_SELF},
	  {SMARTBUFF_CREATESOULS, -1, SMARTBUFF_CONST_SELF},
	  {SMARTBUFF_CREATESPELLS, -1, SMARTBUFF_CONST_SELF},
	  {SMARTBUFF_CREATEFIRES, -1, SMARTBUFF_CONST_SELF},
	  -- use healthstones
	  {SMARTBUFF_HSMINOR, -1, SMARTBUFF_CONST_ITEM},
	  {SMARTBUFF_HSLESSER, -1, SMARTBUFF_CONST_ITEM},
	  {SMARTBUFF_HSTONE, -1, SMARTBUFF_CONST_ITEM},
	  {SMARTBUFF_HSGREATER, -1, SMARTBUFF_CONST_ITEM},
	  {SMARTBUFF_HSMAJOR, -1, SMARTBUFF_CONST_ITEM},
	  {SMARTBUFF_HSMASTER, -1, SMARTBUFF_CONST_ITEM},
	  {SMARTBUFF_HSDEMONIC, -1, SMARTBUFF_CONST_ITEM},
	  {SMARTBUFF_HSFEL, -1, SMARTBUFF_CONST_INV},			  
    };
  end


  -- Deathknight
  if (SMARTBUFF_PLAYERCLASS == "DEATHKNIGHT") then          -- updated 20/5/2023 
    SMARTBUFF_BUFFLIST = {
      {SMARTBUFF_DANCINGRW, 0.2, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_BLOODPRESENCE, -1, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainDKPresence},
      {SMARTBUFF_FROSTPRESENCE, -1, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainDKPresence},
      {SMARTBUFF_UNHOLYPRESENCE, -1, SMARTBUFF_CONST_SELF, nil, nil, nil, S.ChainDKPresence},
      {SMARTBUFF_HORNOFWINTER, 60, SMARTBUFF_CONST_SELF, nil, nil, S.LinkAp},
      {SMARTBUFF_BONESHIELD, 5, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_RAISEDEAD, 1, SMARTBUFF_CONST_SELF, nil, S.CheckPet},
      {SMARTBUFF_PATHOFFROST, -1, SMARTBUFF_CONST_SELF}
    };
  end

  
  -- Rogue
  if (SMARTBUFF_PLAYERCLASS == "ROGUE") then          -- updated 20/5/2023 
    SMARTBUFF_BUFFLIST = {
      {SMARTBUFF_STEALTH, -1, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_BLADEFLURRY, -1, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_SAD, 0.2, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_TRICKS, 0.5, SMARTBUFF_CONST_GROUP, {75}, "WARRIOR;DEATHKNIGHT;DRUID;SHAMAN;HUNTER;ROGUE;MAGE;PRIEST;PALADIN;WARLOCK;HPET;WPET;DKPET"},
      {SMARTBUFF_HUNGERFORBLOOD, 0.5, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_RECUPERATE, 0.5, SMARTBUFF_CONST_SELF},
      {SMARTBUFF_EVASION, 0.2, SMARTBUFF_CONST_SELF},
    };
  end
  
  -- Stones and oils
  SMARTBUFF_WEAPON = {
    {SMARTBUFF_SSROUGH, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_SSCOARSE, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_SSHEAVY, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_SSSOLID, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_SSDENSE, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_SSELEMENTAL, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_SSFEL, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_SSADAMANTITE, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_WSROUGH, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_WSCOARSE, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_WSHEAVY, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_WSSOLID, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_WSDENSE, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_WSFEL, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_WSADAMANTITE, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_SHADOWOIL, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_FROSTOIL, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_MANAOIL4, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_MANAOIL3, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_MANAOIL2, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_MANAOIL1, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_WIZARDOIL5, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_WIZARDOIL4, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_WIZARDOIL3, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_WIZARDOIL2, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_WIZARDOIL1, 60, SMARTBUFF_CONST_INV},
	{SMARTBUFF_FIRESLESSER, 60, SMARTBUFF_CONST_INV},
	{SMARTBUFF_FIRESSTONE, 60, SMARTBUFF_CONST_INV},
	{SMARTBUFF_FIRESGREATER, 60, SMARTBUFF_CONST_INV},
	{SMARTBUFF_FIRESMAJOR, 60, SMARTBUFF_CONST_INV},
	{SMARTBUFF_FIRESMASTER, 60, SMARTBUFF_CONST_INV},
	{SMARTBUFF_FIRESFEL, 60, SMARTBUFF_CONST_INV},
	{SMARTBUFF_FIRESGRAND, 60, SMARTBUFF_CONST_INV},  	
    {SMARTBUFF_SPELLSTONE, 60, SMARTBUFF_CONST_INV},  
    {SMARTBUFF_SPELLSGREATER, 60, SMARTBUFF_CONST_INV},  
    {SMARTBUFF_SPELLSMAJOR, 60, SMARTBUFF_CONST_INV},  
    {SMARTBUFF_SPELLSMASTER, 60, SMARTBUFF_CONST_INV},  
    {SMARTBUFF_SPELLSDEMONIC, 60, SMARTBUFF_CONST_INV},  
    {SMARTBUFF_SPELLSGRAND, 60, SMARTBUFF_CONST_INV},  	
    {SMARTBUFF_INSTANTPOISON1, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_INSTANTPOISON2, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_INSTANTPOISON3, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_INSTANTPOISON4, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_INSTANTPOISON5, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_INSTANTPOISON6, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_INSTANTPOISON7, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_INSTANTPOISON8, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_INSTANTPOISON9, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_WOUNDPOISON1, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_WOUNDPOISON2, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_WOUNDPOISON3, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_WOUNDPOISON4, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_WOUNDPOISON5, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_WOUNDPOISON6, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_WOUNDPOISON7, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_MINDPOISON1, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_MINDPOISON2, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_MINDPOISON3, 60, SMARTBUFF_CONST_INV}, 
    {SMARTBUFF_DEADLYPOISON1, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_DEADLYPOISON2, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_DEADLYPOISON3, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_DEADLYPOISON4, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_DEADLYPOISON5, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_DEADLYPOISON6, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_DEADLYPOISON7, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_DEADLYPOISON8, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_DEADLYPOISON9, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_CRIPPLINGPOISON1, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_CRIPPLINGPOISON2, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_ANESTHETICPOISON1, 60, SMARTBUFF_CONST_INV},
    {SMARTBUFF_ANESTHETICPOISON2, 60, SMARTBUFF_CONST_INV},
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
	-- these are used under era and hardcore only.
    {SMARTBUFF_FINDMINERALS, -1, SMARTBUFF_CONST_GATHERING}, 
    {SMARTBUFF_FINDHERBS, -1, SMARTBUFF_CONST_GATHERING},	
    {SMARTBUFF_FINDTREASURE, -1, SMARTBUFF_CONST_GATHERING},
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
  	{SMARTBUFF_JUICYBEARBURGER,	15,	SMARTBUFF_CONST_FOOD},
	{SMARTBUFF_CRUNCHYSPIDER,	15,	SMARTBUFF_CONST_FOOD},
	{SMARTBUFF_LYNXSTEAK,	15,	SMARTBUFF_CONST_FOOD},
	{SMARTBUFF_CHARREDBEARKABOBS,	15,	SMARTBUFF_CONST_FOOD},
	{SMARTBUFF_BATBITES,	15,	SMARTBUFF_CONST_FOOD},
	{SMARTBUFF_ROASTEDMOONGRAZE,	15,	SMARTBUFF_CONST_FOOD},
	{SMARTBUFF_MOKNATHALSHORTRIBS, 30, SMARTBUFF_CONST_FOOD},
	{SMARTBUFF_CRUNCHYSERPENT, 30, SMARTBUFF_CONST_FOOD},
	{SMARTBUFF_ROASTEDCLEFTHOOF, 30, SMARTBUFF_CONST_FOOD},
	{SMARTBUFF_FISHERMANSFEAST, 30, SMARTBUFF_CONST_FOOD},
	{SMARTBUFF_WARPBURGER, 30, SMARTBUFF_CONST_FOOD},
	{SMARTBUFF_RAVAGERDOG, 30, SMARTBUFF_CONST_FOOD},
	{SMARTBUFF_SKULLFISHSOUP, 30, SMARTBUFF_CONST_FOOD},
	{SMARTBUFF_BUZZARDBITES, 30, SMARTBUFF_CONST_FOOD},
	{SMARTBUFF_TALBUKSTEAK, 30, SMARTBUFF_CONST_FOOD},
	{SMARTBUFF_GOLDENFISHSTICKS, 30, SMARTBUFF_CONST_FOOD},
	{SMARTBUFF_SPICYHOTTALBUK, 30, SMARTBUFF_CONST_FOOD},
	{SMARTBUFF_FELTAILDELIGHT, 30, SMARTBUFF_CONST_FOOD},
	{SMARTBUFF_BLACKENEDSPOREFISH, 30, SMARTBUFF_CONST_FOOD},
	{SMARTBUFF_HOTAPPLECIDER, 30, SMARTBUFF_CONST_FOOD},
	{SMARTBUFF_BROILEDBLOODFIN, 30, SMARTBUFF_CONST_FOOD},
	{SMARTBUFF_SPICYCRAWDAD, 30, SMARTBUFF_CONST_FOOD},
	{SMARTBUFF_POACHEDBLUEFISH, 30, SMARTBUFF_CONST_FOOD},
	{SMARTBUFF_BLACKENEDBASILISK, 30, SMARTBUFF_CONST_FOOD},
	{SMARTBUFF_GRILLEDMUDFISH, 30, SMARTBUFF_CONST_FOOD},
	{SMARTBUFF_CLAMBAR, 30, SMARTBUFF_CONST_FOOD},
	{SMARTBUFF_SAGEFISHDELIGHT, 15, SMARTBUFF_CONST_FOOD},	
    {SMARTBUFF_HERBBAKEDEGG, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_SPICEDWOLFMEAT, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_BEERBASTEDBIARRIBS, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_CRISPYBATWING, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_KALDOREISPIDERKABOB, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_ROASTEDKODOMEAT, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_BOILEDCLAMS, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_COYOTESTEAK, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_CRABCAKE, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_DRYPORKRIBS, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_BLOODSAUSAGE, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_CROCOLISKSTEAK, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_FILLETOFFRENZY, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_GORETUSKLIVERPIE, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_STRIDERSTEW, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_GOBLINDEVILEDCLAMS, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_BIGBEARSTEAK, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_CRISPYLIZARDTAIL, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_CROCOLISKGUMBO, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_CURIOUSLYTASTYOMELET, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_GOOEYSPIDERCAKE, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_HOTLIONCHOPS, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_LEANVENISON, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_LEANWOLFSTEAK, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_MURLOCFINSOUP, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_REDRIDGEGOULASH, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_SEASONEDWOLFKABOB, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_CARRIONSURPRISE, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_GIANTCLAMSCORCHO, 15, SMARTBUF_CONST_FOOD},
    {SMARTBUFF_HEAVYCROCOLISKSTEW, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_HOTWOLFRIBS, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_JUNGLESTEW, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_MYSTERYSTEW, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_SOOTHINGTURTLEBISQUE, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_TASTYLIONSTEAK, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_SPIDERSAUSAGE, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_HEAVYKODOSTEW, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_MONSTEROMELET, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_SPICEDCHILICRAB, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_TENDERWOLFSTEAK, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_SMOKEDSAGEFISH, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_SAGEFISHDELIGHT, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_NIGHTFINSOUP, 15, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_GRILLEDSQUID, 10, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_RUNNTUMTUBERSURPRISE, 10, SMARTBUFF_CONST_FOOD},
    {SMARTBUFF_SMOKEDDESERTDUMPLINGS, 15, SMARTBUFF_CONST_FOOD},	
    {SMARTBUFF_STEAMINGCHICKENSOUP, 15, SMARTBUFF_CONST_FOOD},   
    {SMARTBUFF_GRILLEDSQUID, 10, SMARTBUFF_CONST_FOOD}, 
    {SMARTBUFF_BARBECUEDBUZZARDWING, 15, SMARTBUFF_CONST_FOOD}, 
  };

  for n, name in pairs(S.FoodItems) do
    if (name) then
      --print("Adding: "..n..". "..name);
      tinsert(SMARTBUFF_FOOD, 1, {name, 60, SMARTBUFF_CONST_FOOD});
    end
  end


  -- Scrolls
  SMARTBUFF_SCROLL = {
    {SMARTBUFF_MiscItem17, 60, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_BMiscItem17, S.LinkFlaskLeg},
    {SMARTBUFF_MiscItem16, 60, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_BMiscItem16},
    {SMARTBUFF_MiscItem15, 60, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_BMiscItem14, S.LinkAugment},
    {SMARTBUFF_MiscItem14, 60, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_BMiscItem14, S.LinkAugment},
    {SMARTBUFF_MiscItem13, 10, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_BMiscItem13},
    {SMARTBUFF_MiscItem12, 60, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_BMiscItem12},
    {SMARTBUFF_MiscItem11, 60, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_BMiscItem11, S.LinkFlaskWoD},
    {SMARTBUFF_MiscItem10, -1, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_BMiscItem10, S.LinkSafariHat},
    {SMARTBUFF_MiscItem9, -1, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_BMiscItem9, S.LinkSafariHat},
    {SMARTBUFF_MiscItem1, -1, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_BMiscItem1},
    {SMARTBUFF_MiscItem2, -1, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_BMiscItem2},
    {SMARTBUFF_MiscItem3, 10, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_BMiscItem3},
    {SMARTBUFF_MiscItem4, 60, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_BMiscItem4, S.LinkFlaskMoP},
    {SMARTBUFF_MiscItem5, 10, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_BMiscItem5},
    {SMARTBUFF_MiscItem6, 60, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_BMiscItem6},
    {SMARTBUFF_MiscItem7, 60, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_BMiscItem7},
    {SMARTBUFF_MiscItem8, 5, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_BMiscItem8},
    {SMARTBUFF_AugmentRune, 60, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_BAugmentRune, S.LinkAugment},
    {SMARTBUFF_VieledAugment, 60, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_BVieledAugment, S.LinkAugment},

    {SMARTBUFF_SOAGILITY9, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBAGILITY},
    {SMARTBUFF_SOAGILITY8, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBAGILITY},
    {SMARTBUFF_SOAGILITY7, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBAGILITY},
    {SMARTBUFF_SOAGILITY6, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBAGILITY},
    {SMARTBUFF_SOAGILITY5, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBAGILITY},
    {SMARTBUFF_SOAGILITY4, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBAGILITY},
    {SMARTBUFF_SOAGILITY3, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBAGILITY},
    {SMARTBUFF_SOAGILITY2, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBAGILITY},
    {SMARTBUFF_SOAGILITY1, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBAGILITY},
    {SMARTBUFF_SOINTELLECT9, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBINTELLECT},
    {SMARTBUFF_SOINTELLECT8, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBINTELLECT},
    {SMARTBUFF_SOINTELLECT7, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBINTELLECT},
    {SMARTBUFF_SOINTELLECT6, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBINTELLECT},
    {SMARTBUFF_SOINTELLECT5, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBINTELLECT},
    {SMARTBUFF_SOINTELLECT4, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBINTELLECT},
    {SMARTBUFF_SOINTELLECT3, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBINTELLECT},
    {SMARTBUFF_SOINTELLECT2, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBINTELLECT},
    {SMARTBUFF_SOINTELLECT1, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBINTELLECT},
    {SMARTBUFF_SOSTAMINA9, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSTAMINA},
    {SMARTBUFF_SOSTAMINA8, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSTAMINA},
    {SMARTBUFF_SOSTAMINA7, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSTAMINA},
    {SMARTBUFF_SOSTAMINA6, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSTAMINA},
    {SMARTBUFF_SOSTAMINA5, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSTAMINA},
    {SMARTBUFF_SOSTAMINA4, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSTAMINA},
    {SMARTBUFF_SOSTAMINA3, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSTAMINA},
    {SMARTBUFF_SOSTAMINA2, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSTAMINA},
    {SMARTBUFF_SOSTAMINA1, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSTAMINA},
    {SMARTBUFF_SOSPIRIT9, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSPIRIT},
    {SMARTBUFF_SOSPIRIT8, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSPIRIT},
    {SMARTBUFF_SOSPIRIT7, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSPIRIT},
    {SMARTBUFF_SOSPIRIT6, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSPIRIT},
    {SMARTBUFF_SOSPIRIT5, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSPIRIT},
    {SMARTBUFF_SOSPIRIT4, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSPIRIT},
    {SMARTBUFF_SOSPIRIT3, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSPIRIT},
    {SMARTBUFF_SOSPIRIT2, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSPIRIT},
    {SMARTBUFF_SOSPIRIT1, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSPIRIT},
    {SMARTBUFF_SOSTRENGHT9, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSTRENGTH},
    {SMARTBUFF_SOSTRENGHT8, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSTRENGTH},
    {SMARTBUFF_SOSTRENGHT7, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSTRENGTH},
    {SMARTBUFF_SOSTRENGHT6, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSTRENGTH},
    {SMARTBUFF_SOSTRENGHT5, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSTRENGTH},
    {SMARTBUFF_SOSTRENGHT4, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSTRENGTH},
    {SMARTBUFF_SOSTRENGHT3, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSTRENGTH},
    {SMARTBUFF_SOSTRENGHT2, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSTRENGTH},
    {SMARTBUFF_SOSTRENGHT1, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBSTRENGTH},
    {SMARTBUFF_SOPROTECTION9, 30, SMARTBUFF_CONST_SCROLL, nil, SMARTBUFF_SBPROTECTION},
  };

  --      ItemId, SpellId, Duration [min]
  AddItem(174906, 270058,  60); -- Lightning-Forged Augment Rune
  AddItem(153023, 224001,  60); -- Lightforged Augment Rune
  AddItem(160053, 270058,  60); --Battle-Scarred Augment Rune
  AddItem(164375, 281303,  10); --Bad Mojo Banana
  AddItem(129165, 193345,  10); --Barnacle-Encrusted Gem
  AddItem(116115, 170869,  60); -- Blazing Wings
  AddItem(133997, 203533,   0); --Black Ice
  AddItem(122298, 181642,  60); --Bodyguard Miniaturization Device
  AddItem(163713, 279934,  30); --Brazier Cap
  AddItem(128310, 189363,  10); --Burning Blade
  AddItem(116440, 171554,  20); --Burning Defender's Medallion
  AddItem(128807, 192225,  60); -- Coin of Many Faces
  AddItem(138878, 217668,   5); --Copy of Daglop's Contract
  AddItem(143662, 232613,  60); --Crate of Bobbers: Pepe
  AddItem(142529, 231319,  60); --Crate of Bobbers: Cat Head
  AddItem(142530, 231338,  60); --Crate of Bobbers: Tugboat
  AddItem(142528, 231291,  60); --Crate of Bobbers: Can of Worms
  AddItem(142532, 231349,  60); --Crate of Bobbers: Murloc Head
  AddItem(147308, 240800,  60); --Crate of Bobbers: Enchanted Bobber
  AddItem(142531, 231341,  60); --Crate of Bobbers: Squeaky Duck
  AddItem(147312, 240801,  60); --Crate of Bobbers: Demon Noggin
  AddItem(147307, 240803,  60); --Crate of Bobbers: Carved Wooden Helm
  AddItem(147309, 240806,  60); --Crate of Bobbers: Face of the Forest
  AddItem(147310, 240802,  60); --Crate of Bobbers: Floating Totem
  AddItem(147311, 240804,  60); --Crate of Bobbers: Replica Gondola
  AddItem(122117, 179872,  15); --Cursed Feather of Ikzan
  AddItem( 54653,  75532,  30); -- Darkspear Pride
  AddItem(108743, 160688,  10); --Deceptia's Smoldering Boots
  AddItem(129149, 193333,  30); --Death's Door Charm
  AddItem(159753, 279366,   5); --Desert Flute
  AddItem(164373, 281298,  10); --Enchanted Soup Stone
  AddItem(140780, 224992,   5); --Fal'dorei Egg
  AddItem(122304, 138927,  10); -- Fandral's Seed Pouch
  AddItem(102463, 148429,  10); -- Fire-Watcher's Oath
  AddItem(128471, 190655,  30); --Frostwolf Grunt's Battlegear
  AddItem(128462, 190653,  30); --Karabor Councilor's Attire
  AddItem(161342, 275089,  30); --Gem of Acquiescence
  AddItem(127659, 188228,  60); --Ghostly Iron Buccaneer's Hat
  AddItem( 54651,  75531,  30); -- Gnomeregan Pride
  AddItem(118716, 175832,   5); --Goren Garb
  AddItem(138900, 217708,  10); --Gravil Goldbraid's Famous Sausage Hat
  AddItem(159749, 277572,   5); --Haw'li's Hot & Spicy Chili
  AddItem(163742, 279997,  60); --Heartsbane Grimoire
  AddItem(129149, 193333,  60); -- Helheim Spirit Memory
  AddItem(140325, 223446,  10); --Home Made Party Mask
  AddItem(136855, 210642,0.25); --Hunter's Call
  AddItem( 43499,  58501,  10); -- Iron Boot Flask
  AddItem(118244, 173956,  60); --Iron Buccaneer's Hat
  AddItem(170380, 304369, 120); --Jar of Sunwarmed Sand
  AddItem(127668, 187174,   5); --Jewel of Hellfire
  AddItem( 26571, 127261,  10); --Kang's Bindstone
  AddItem( 68806,  96312,  30); -- Kalytha's Haunted Locket
  AddItem(163750, 280121,  10); --Kovork Kostume
  AddItem(164347, 281302,  10); --Magic Monkey Banana
  AddItem(118938, 176180,  10); --Manastorm's Duplicator
  AddItem(163775, 280133,  10); --Molok Morion
  AddItem(101571, 144787,   0); --Moonfang Shroud
  AddItem(105898, 145255,  10); --Moonfang's Paw
  AddItem( 52201,  73320,  10); --Muradin's Favor
  AddItem(138873, 217597,   5); --Mystical Frosh Hat
  AddItem(163795, 280308,  10); --Oomgut Ritual Drum
  AddItem(  1973,  16739,   5); --Orb of Deception
  AddItem( 35275, 160331,  30); --Orb of the Sin'dorei
  AddItem(158149, 264091,  30); --Overtuned Corgi Goggles
  AddItem(130158, 195949,   5); --Path of Elothir
  AddItem(127864, 188172,  60); --Personal Spotlight
  AddItem(127394, 186842,   5); --Podling Camouflage
  AddItem(108739, 162402,   5); --Pretty Draenor Pearl
  AddItem(129093, 129999,  10); --Ravenbear Disguise
  AddItem(153179, 254485,   5); --Blue Conservatory Scroll
  AddItem(153180, 254486,   5); --Yellow Conservatory Scroll
  AddItem(153181, 254487,   5); --Red Conservatory Scroll
  AddItem(104294, 148529,  15); --Rime of the Time-Lost Mariner
  AddItem(119215, 176898,  10); --Robo-Gnomebobulator
  AddItem(119134, 176569,  30); --Sargerei Disguise
  AddItem(129055,  62089,  60); --Shoe Shine Kit
  AddItem(163436, 279977,  30); --Spectral Visage
  AddItem(156871, 261981,  60); --Spitzy
  AddItem( 66888,   6405,   3); --Stave of Fur and Claw
  AddItem(111476, 169291,   5); --Stolen Breath
  AddItem(140160, 222630,  10); --Stormforged Vrykul Horn
  AddItem(163738, 279983,  30); --Syndicate Mask
  AddItem(130147, 195509,   5); --Thistleleaf Branch
  AddItem(113375, 166592,   5); --Vindicator's Armor Polish Kit
  AddItem(163565, 279407,   5); --Vulpera Scrapper's Armor
  AddItem(163924, 280632,  30); --Whiskerwax Candle
  AddItem( 97919, 141917,   3); --Whole-Body Shrinka'
  AddItem(167698, 293671,  60); --Secret Fish Goggles
  AddItem(169109, 299445,  60); --Beeholder's Goggles
  AddItem(191341, 371172,  30); -- Tepid Q3

  -- Potions
  SMARTBUFF_POTION = {
    {SMARTBUFF_ELIXIRTBC1, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRTBC1},
    {SMARTBUFF_ELIXIRTBC2, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRTBC2},
    {SMARTBUFF_ELIXIRTBC3, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRTBC3},
    {SMARTBUFF_ELIXIRTBC4, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRTBC4},
    {SMARTBUFF_ELIXIRTBC5, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRTBC5},
    {SMARTBUFF_ELIXIRTBC6, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRTBC6},
    {SMARTBUFF_ELIXIRTBC7, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRTBC7},
    {SMARTBUFF_ELIXIRTBC8, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRTBC8},
    {SMARTBUFF_ELIXIRTBC9, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRTBC9},
    {SMARTBUFF_ELIXIRTBC10, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRTBC10},
    {SMARTBUFF_ELIXIRTBC11, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRTBC11},
    {SMARTBUFF_ELIXIRTBC12, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRTBC12},
    {SMARTBUFF_ELIXIRTBC13, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRTBC13},
    {SMARTBUFF_ELIXIRTBC14, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRTBC14},
    {SMARTBUFF_ELIXIRTBC15, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRTBC15},
    {SMARTBUFF_ELIXIRTBC16, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRTBC16},
    {SMARTBUFF_ELIXIRTBC17, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRTBC17},
    {SMARTBUFF_FLASKTBC1, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BFLASKTBC1}, --, S.LinkFlaskTBC},
    {SMARTBUFF_FLASKTBC2, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BFLASKTBC2},
    {SMARTBUFF_FLASKTBC3, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BFLASKTBC3},
    {SMARTBUFF_FLASKTBC4, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BFLASKTBC4},
    {SMARTBUFF_FLASKTBC5, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BFLASKTBC5},
    {SMARTBUFF_FLASKLEG1, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BFLASKLEG1, S.LinkFlaskLeg},
    {SMARTBUFF_FLASKLEG2, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BFLASKLEG2},
    {SMARTBUFF_FLASKLEG3, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BFLASKLEG3},
    {SMARTBUFF_FLASKLEG4, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BFLASKLEG4},
    {SMARTBUFF_FLASKWOD1, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BFLASKWOD1, S.LinkFlaskWoD},
    {SMARTBUFF_FLASKWOD2, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BFLASKWOD2},
    {SMARTBUFF_FLASKWOD3, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BFLASKWOD3},
    {SMARTBUFF_FLASKWOD4, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BFLASKWOD4},
    {SMARTBUFF_GRFLASKWOD1, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BGRFLASKWOD1},
    {SMARTBUFF_GRFLASKWOD2, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BGRFLASKWOD2},
    {SMARTBUFF_GRFLASKWOD3, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BGRFLASKWOD3},
    {SMARTBUFF_GRFLASKWOD4, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BGRFLASKWOD4},
    {SMARTBUFF_FLASKMOP1, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BFLASKMOP1, S.LinkFlaskMoP},
    {SMARTBUFF_FLASKMOP2, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BFLASKMOP2},
    {SMARTBUFF_FLASKMOP3, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BFLASKMOP3},
    {SMARTBUFF_FLASKMOP4, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BFLASKMOP4},
    {SMARTBUFF_FLASKMOP5, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BFLASKMOP5},
    {SMARTBUFF_FLASKMOP6, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BFLASKMOP6},
    {SMARTBUFF_ELIXIRMOP1, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRMOP1},
    {SMARTBUFF_ELIXIRMOP2, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRMOP2},
    {SMARTBUFF_ELIXIRMOP3, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRMOP3},
    {SMARTBUFF_ELIXIRMOP4, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRMOP4},
    {SMARTBUFF_ELIXIRMOP5, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRMOP5},
    {SMARTBUFF_ELIXIRMOP6, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRMOP6},
    {SMARTBUFF_ELIXIRMOP7, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRMOP7},
    {SMARTBUFF_ELIXIRMOP8, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRMOP8},
    {SMARTBUFF_EXP_POTION, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BEXP_POTION},
    {SMARTBUFF_FLASKCT1, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BFLASKCT1},
    {SMARTBUFF_FLASKCT2, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BFLASKCT2},
    {SMARTBUFF_FLASKCT3, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BFLASKCT3},
    {SMARTBUFF_FLASKCT4, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BFLASKCT4},
    {SMARTBUFF_FLASKCT5, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BFLASKCT5},
    {SMARTBUFF_FLASKCT7, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BFLASKCT7, S.LinkFlaskCT7},
    {SMARTBUFF_ELIXIRCT1, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRCT1},
    {SMARTBUFF_ELIXIRCT2, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRCT2},
    {SMARTBUFF_ELIXIRCT3, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRCT3},
    {SMARTBUFF_ELIXIRCT4, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRCT4},
    {SMARTBUFF_ELIXIRCT5, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRCT5},
    {SMARTBUFF_ELIXIRCT6, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRCT6},
    {SMARTBUFF_ELIXIRCT7, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRCT7},
    {SMARTBUFF_ELIXIRCT8, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIRCT8},
    {SMARTBUFF_FLASK1, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BFLASK1},
    {SMARTBUFF_FLASK2, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BFLASK2},
    {SMARTBUFF_FLASK3, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BFLASK3},
    {SMARTBUFF_FLASK4, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BFLASK4},
    {SMARTBUFF_FLASK5, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BFLASK5},
    {SMARTBUFF_FLASK6, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BFLASK6},
    {SMARTBUFF_ELIXIR1,  60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIR1},
    {SMARTBUFF_ELIXIR2,  60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIR2},
    {SMARTBUFF_ELIXIR3,  60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIR3},
    {SMARTBUFF_ELIXIR4,  60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIR4},
    {SMARTBUFF_ELIXIR5,  60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIR5},
    {SMARTBUFF_ELIXIR6,  60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIR6},
    {SMARTBUFF_ELIXIR7,  60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIR7},
    {SMARTBUFF_ELIXIR8,  60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIR8},
    {SMARTBUFF_ELIXIR9,  60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIR9},
    {SMARTBUFF_ELIXIR10, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIR10},
    {SMARTBUFF_ELIXIR11, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIR11},
    {SMARTBUFF_ELIXIR12, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIR12},
    {SMARTBUFF_ELIXIR13, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIR13},
    {SMARTBUFF_ELIXIR14, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIR14},
    {SMARTBUFF_ELIXIR15, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIR15},
    {SMARTBUFF_ELIXIR16, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BELIXIR16},
    {SMARTBUFF_FLASKBFA1, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BFLASKBFA1, S.LinkFlaskBfA},
    {SMARTBUFF_FLASKBFA2, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BFLASKBFA2},
    {SMARTBUFF_FLASKBFA3, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BFLASKBFA3},
    {SMARTBUFF_FLASKBFA4, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BFLASKBFA4},
    {SMARTBUFF_GRFLASKBFA1, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BGRFLASKBFA1},
    {SMARTBUFF_GRFLASKBFA2, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BGRFLASKBFA2},
    {SMARTBUFF_GRFLASKBFA3, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BGRFLASKBFA3},
    {SMARTBUFF_GRFLASKBFA4, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BGRFLASKBFA4},
    {SMARTBUFF_FLASKSL1, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BFLASKSL1, S.LinkFlaskSL},
    {SMARTBUFF_FLASKSL2, 60, SMARTBUFF_CONST_POTION, nil, SMARTBUFF_BFLASKSL2},

  }
  SMARTBUFF_AddMsgD("Spell list initialized");

--  LoadToys();

end
