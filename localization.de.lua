-------------------------------------------------------------------------------
-- German localization
-------------------------------------------------------------------------------

if (GetLocale() == "deDE") then

-- credits
SMARTBUFF_CREDITS = "|cffffffff"
  .."Classic-Version von Codermik. Bitte melde alle Probleme auf CurseForge oder meinem Discord unter:\n\n"
  .."|cff00e0ffhttps://discord.gg/R6EkZ94TKK\n\n"
  .."|cffffffffWenn Sie den Arbeitsaufwand und die Zeit zu schätzen wissen, die erforderlich ist, um Ihnen diese verschiedenen Add-Ons zur Verfügung zu stellen, erwägen Sie bitte, mich zu unterstützen, indem Sie:\n\n"
  .."|cffffffffPatreon: |cff00e0ffhttps://www.patreon.com/codermik\n"
  .."|cffffffffTwitch: |cff00e0ffhttps://www.twitch.tv/codermik\n"
  .."|cffffffffPayPal.Me: |cff00e0ffhttps://paypal.me/codermik\n\n"
;

-- Weapon types
SMARTBUFF_WEAPON_STANDARD = {"Dolche", "äxte", "schwerter", "streitkolben", "Stäbe", "Faustwaffen", "Stangenwaffen", "Wurfwaffe"};
SMARTBUFF_WEAPON_BLUNT = {"streitkolben", "Faustwaffen", "Stäbe"};
SMARTBUFF_WEAPON_BLUNT_PATTERN = "ewichtsstein$";
SMARTBUFF_WEAPON_SHARP = {"Dolche", "äxte", "schwerter", "Stangenwaffen"};
SMARTBUFF_WEAPON_SHARP_PATTERN = "etzstein$";

-- Creature types
SMARTBUFF_HUMANOID  = "Humanoid";
SMARTBUFF_DEMON     = "Dämon";
SMARTBUFF_BEAST     = "Wildtier";
SMARTBUFF_ELEMENTAL = "Elementar";
SMARTBUFF_DEMONTYPE = "Wichtel";
SMARTBUFF_UNDEAD    = "Untot";

-- Classes
SMARTBUFF_CLASSES = {"Druide", "Jäger", "Magier", "Paladin", "Priester", "Schurke", "Schamane", "Hexenmeister", "Krieger", "Todesritter", "Mönch", "Dämonenjäger", "Evoker", "Jäger Pet", "Hexer Pet", "Todesritter Pet", "Tank", "Heiler", "Schadensverursacher"};

-- Templates and Instances
SMARTBUFF_TEMPLATES = {"Solo", "Gruppe", "Raid", "Schlachtfeld", "Arena", "ICC", "PDK", "Ulduar", "MC", "Ony", "BWL", "Naxx", "AQ", "ZG", "Custom 1", "Custom 2", "Custom 3", "Custom 4", "Custom 5"};
SMARTBUFF_INSTANCES = {"Eiskronenzitadelle", "Prüfung des Kreuzfahrers", "Ulduar", "geschmolzene Kern", "Onyxias Hort", "Pechschwingenhort", "Naxxramas", "Ahn'Qiraj", "Zul'Gurub"};

-- Mount
SMARTBUFF_MOUNT = "Erhöht Tempo um (%d+)%%.";

-- Abbreviations
SMARTBUFF_ABBR_CHARGES_OL = "%d a";

-- Bindings
BINDING_NAME_SMARTBUFF_BIND_TRIGGER = "Trigger";
BINDING_NAME_SMARTBUFF_BIND_TARGET  = "Ziel";
BINDING_NAME_SMARTBUFF_BIND_OPTIONS = "Optionen";
BINDING_NAME_SMARTBUFF_BIND_RESETBUFFTIMERS = "Buff Timer löschen";

-- mounted warning
SMARTBUFF_OFT_MOUNTEDWARN	 = "Beim Reiten vorzeigen";
SMARTBUFF_OFTT_MOUNTEDWARN	 = "Erinnere mich während des Reitens weiterhin an fehlende Buffs oder Fähigkeiten.";

-- purge/reload messages
SMARTBUFF_OFT_YES            = "Ja";
SMARTBUFF_OFT_NO             = "NEIN";
SMARTBUFF_OFT_OKAY			 = "Neu laden"
SMARTBUFF_OFT_PURGE_DATA     = "Sind Sie sicher, dass Sie ALLE SmartBuff-Daten zurücksetzen möchten?\nDiese Aktion erzwingt ein Neuladen der Benutzeroberfläche!";
SMARTBUFF_OFT_REQ_RELOAD     = "Neue Versionen erfordern ein Neuladen der GUI\nKlicke um Fortzufahren";

-- fishing rod check
SMARTBUFF_OFT_FRODWARN		 = "Sie befinden sich mit ausgerüsteter Angelrute im Kampf.";
SMARTBUFF_OFT_FRINSWARN		 = "Sie befinden sich in einer Gruppe mit ausgerüsteter Angelrute.";

-- tracking switcher
SMARTBUFF_TRACKSWITCHMSG	 = " wurde erkannt, aber die automatische Umschaltverfolgung ist aktiviert. Geben Sie /sbm ein, um Optionen anzuzeigen und die individuelle Nachverfolgung oder automatische Umschaltung zu deaktivieren.";
SMARTBUFF_TRACKINGDISABLE	 = "Sie profitieren von dieser Funktion nur, wenn Sie über zwei oder mehr Sammelfähigkeiten verfügen. Die Option wurde deaktiviert."
SMARTBUFF_AUTOGATHERON		 = "Die automatische Umschaltung ist eingeschaltet"
SMARTBUFF_AUTOGATHEROFF		 = "Die automatische Umschaltung ist AUS"
SMARTBUFF_OFT_GATHERER		 = "Automatischer Wechsel von Sammel-Trackern"
SMARTBUFF_OFT_FINDFISH		 = GetSpellInfo(43308)
SMARTBUFF_OFT_MINERALS		 = GetSpellInfo(2580)
SMARTBUFF_OFT_HERBS			 = GetSpellInfo(2383)
SMARTBUFF_OFTT_GATHERER		 = "Wechselt zwischen „Kräuter suchen“, „Mineralien suchen“ und „Fisch suchen“ (falls verfügbar und ausgewählt)."
SMARTBUFF_OFTT_GATHERERFISH	 = "Schließen Sie „Fische finden“ ein, wenn Sie durch Gathering Trackers wechseln."
SMARTBUFF_OFT_AUTOGATHOFF	 = "In der Gruppe AUSschalten"
SMARTBUFF_OFTT_AUTOGATHOFF	 = "Schalten Sie diese Funktion aus, wenn Sie sich in einer Gruppe oder einem Raid befinden, und wechseln Sie zu Ihrer aktuellen Vorlageneinstellung."

-- wrong version
SMARTBUFF_NOTINTENDEDCLIENT	 = "Diese Version von Smartbuff ist nicht für diesen Client gedacht. Bitte laden Sie die richtige Version herunter.";


-- Options Frame Text

-- show action button only when pending actions exist.
SMARTBUFF_OFT_HIDEABNOACTION = "Nur bei Bedarf anzeigen";
SMARTBUFF_OFTT_HIDEABNOACTION = "Blenden Sie die Aktionsschaltfläche aus, wenn keine Buffs für Sie selbst, Gruppenmitglieder, Raids oder Haustiere fehlen. Beachten Sie, dass die\nAktionsschaltfläche aktiviert sein muss, damit diese Option funktioniert.";

-- experimental feature - for testing.
SMARTBUFF_OFT_FIXBUFF		 = "Gießen reparieren"
SMARTBUFF_OFTT_FIXBUFF		 = "Ankreuzen, wenn Smartbuff keine Buffs wirkt."

SMARTBUFF_OFT                = "SmartBuff An/Aus";
SMARTBUFF_OFT_MENU           = "Zeige/verberge Optionen Menü";
SMARTBUFF_OFT_AUTO           = "Erinnerung";
SMARTBUFF_OFT_AUTOTIMER      = "Check Timer";
SMARTBUFF_OFT_AUTOCOMBAT     = "im Kampf";
SMARTBUFF_OFT_AUTOCHAT       = "Chat";
SMARTBUFF_OFT_AUTOSPLASH     = "Splash";
SMARTBUFF_OFT_AUTOSOUND      = "Ton";
SMARTBUFF_OFT_AUTOREST       = "Unterdrückt in Städten";
SMARTBUFF_OFT_HUNTERPETS     = "Jäger Pets buffen";
SMARTBUFF_OFT_WARLOCKPETS    = "Hexer Pets buffen";
SMARTBUFF_OFT_ARULES         = "Zusätzliche Regeln";
SMARTBUFF_OFT_GRP            = "Raid Sub-Gruppen zum Buffen";
SMARTBUFF_OFT_SUBGRPCHANGED  = "Öffne Menü";
SMARTBUFF_OFT_BUFFS          = "Buffs/Fähigkeiten";
SMARTBUFF_OFT_TARGET         = "Bufft das anvisierte Ziel";
SMARTBUFF_OFT_DONE           = "Fertig";
SMARTBUFF_OFT_APPLY          = "Übernehmen";
SMARTBUFF_OFT_GRPBUFFSIZE    = "Grp/Ra-Grösse";
SMARTBUFF_OFT_CLASSBUFFSIZE  = "Klassengrösse";
SMARTBUFF_OFT_MESSAGES       = "Unterdrücke Meldungen";
SMARTBUFF_OFT_MSGNORMAL      = "Normal";
SMARTBUFF_OFT_MSGWARNING     = "Warnung";
SMARTBUFF_OFT_MSGERROR       = "Fehler";
SMARTBUFF_OFT_HIDEMMBUTTON   = "Verberge Minimap-Knopf";
SMARTBUFF_OFT_INCLUDETOYS	 = "Spielzeug einbeziehen";
SMARTBUFF_OFT_REBUFFTIMER    = "Rebuff Timer";
SMARTBUFF_OFT_AUTOSWITCHTMP  = "Vorlagenwechsel";
SMARTBUFF_OFT_SELFFIRST      = "Mich zuerst";
SMARTBUFF_OFT_SCROLLWHEELUP  = "Bufft mit Mausrad hoch";
SMARTBUFF_OFT_SCROLLWHEELDOWN = "runter";
SMARTBUFF_OFT_SCROLLZOOMING	 = "Kamera";
SMARTBUFF_OFT_TARGETSWITCH   = "bei Zielwechsel";
SMARTBUFF_OFT_BUFFTARGET     = "Bufft das Ziel";
SMARTBUFF_OFT_BUFFPVP        = "Buff PvP";
SMARTBUFF_OFT_AUTOSWITCHTMPINST = "Instanzen";
SMARTBUFF_OFT_CHECKCHARGES   = "Aufladungen";
SMARTBUFF_OFT_RBT            = "Reset BT";
SMARTBUFF_OFT_BUFFINCITIES   = "Bufft in Städten";
SMARTBUFF_OFT_UISYNC         = "UI Sync";
SMARTBUFF_OFT_BLDURATION     = "Blacklisted";
SMARTBUFF_OFT_COMPMODE       = "Komp. Modus";
SMARTBUFF_OFT_MINIGRP        = "Mini Gruppe";
SMARTBUFF_OFT_ANTIDAZE       = "Anti-Daze";
SMARTBUFF_OFT_HIDESABUTTON   = "Verberge Action-Knopf";
SMARTBUFF_OFT_INCOMBAT       = "im Kampf";
SMARTBUFF_OFT_SMARTDEBUFF    = "SmartDebuff";
SMARTBUFF_OFT_INSHAPESHIFT   = "Verwandelt";
SMARTBUFF_OFT_LINKGRPBUFFCHECK  = "Grp Link";
SMARTBUFF_OFT_LINKSELFBUFFCHECK = "Selbst Link";
SMARTBUFF_OFT_RESETALL       = "Reset Alles";
SMARTBUFF_OFT_RESETLIST      = "Reset Liste";
SMARTBUFF_OFT_YES            = "Ja";
SMARTBUFF_OFT_NO             = "Nein";
SMARTBUFF_OFT_PURGE_DATA     = "Bist du sicher, dass du ALLE SmartBuff Daten zurücksetzen willst?\nDiese Aktion wird ein neu Laden des UI's durchführen!";
SMARTBUFF_OFT_SPLASHICON     = "Symbol anzeigen";
SMARTBUFF_OFT_SPLASHMSGSHORT = "Kurze Meldung";

-- Options Frame Tooltip Text
SMARTBUFF_OFTT               = "Schaltet SmartBuff An/Aus";
SMARTBUFF_OFTT_AUTO          = "Schaltet die Erinnerung an fehlende Buffs An/Aus";
SMARTBUFF_OFTT_AUTOTIMER     = "Verzögerung in Sekunden zwischen zwei Checks.";
SMARTBUFF_OFTT_AUTOCOMBAT    = "Check auch während dem Kampf durchführen.";
SMARTBUFF_OFTT_AUTOCHAT      = "Zeigt fehlende Buffs als Chat-Meldung an.";
SMARTBUFF_OFTT_AUTOSPLASH    = "Zeigt fehlende Buffs als Splash-Meldung\nin der mitte des Bildschirms an.";
SMARTBUFF_OFTT_AUTOSOUND     = "Bei fehlende Buffs erklingt ein Ton.";
SMARTBUFF_OFTT_AUTOREST      = "Erinnerung wird in den\nHauptstädten unterdrückt.";
SMARTBUFF_OFTT_HUNTERPETS    = "Bufft die Jäger Pets auch.";
SMARTBUFF_OFTT_WARLOCKPETS   = "Bufft die Hexer Pets auch,\nausser den " .. SMARTBUFF_DEMONTYPE .. ".";
SMARTBUFF_OFTT_ARULES        = "Bufft nicht:\n- Dornen auf Magier, Priester und Hexer\n- Arkane Intelligenz auf Klassen ohne Mana\n- Göttlicher Willen auf Klassen ohne Mana";
SMARTBUFF_OFTT_SUBGRPCHANGED = "Öffnet automatisch das SmartBuff Menü,\nwenn du die Sub-Gruppe gewechselt hast.";
SMARTBUFF_OFTT_GRPBUFFSIZE   = "Anzahl Spieler die in der Gruppe/Raid sein\nmüssen und den Gruppen-Buff nicht haben,\ndamit der Gruppen-Buff verwendet wird.";
SMARTBUFF_OFTT_HIDEMMBUTTON  = "Verbirgt den SmartBuff Minimap-Knopf.";
SMARTBUFF_OFTT_INCLUDETOYS	 = "Fügen Sie neben Ihren Zaubersprüchen und Lebensmitteln auch Spielzeuge in die Liste ein.";
SMARTBUFF_OFTT_REBUFFTIMER   = "Wieviele Sekunden vor Ablauf der Buffs,\nsoll daran erinnert werden.\n0 = Deaktivert";
SMARTBUFF_OFTT_SELFFIRST     = "Bufft den eigenen Charakter immer zuerst.";
SMARTBUFF_OFTT_SCROLLWHEELUP = "Bufft beim Bewegen des Scrollrads nach vorne.";
SMARTBUFF_OFTT_SCROLLWHEELDOWN = "Bufft beim Bewegen des Scrollrads zurück.";
SMARTBUFF_OFTT_SCROLLZOOMING = "Erlauben Sie das normale Zoomen der Kamera, wenn Sie fehlende Buffs oder Fähigkeiten anwenden (ursprüngliches Smartbuff-Verhalten).\nBeachten Sie, dass Ihr Kamerazoom möglicherweise vorübergehend deaktiviert wird, wenn diese Option deaktiviert ist,\nwenn ein Buff aus irgendeinem Grund fehlschlägt.";
SMARTBUFF_OFTT_TARGETSWITCH  = "Bufft beim Wechsel eines Ziels.";
SMARTBUFF_OFTT_BUFFTARGET    = "Bufft zuerst das aktuelle Ziel,\nfalls dies freundlich ist.";
SMARTBUFF_OFTT_BUFFPVP       = "Bufft auch Spieler im PvP Modus,\nwenn man selbst nicht im PvP ist.";
SMARTBUFF_OFTT_AUTOSWITCHTMP = "Wechselt automatisch die Buff-Vorlage,\nwenn der Gruppentyp sich ändert.";
SMARTBUFF_OFTT_AUTOSWITCHTMPINST = "Wechselt automatisch die Buff-Vorlage,\nwenn die Instanz sich ändert.";
SMARTBUFF_OFTT_CHECKCHARGES  = "Erinnerung wenn die Aufladungen\neines Buffs bald aufgebraucht sind.\n0 = Deaktivert";
SMARTBUFF_OFTT_BUFFINCITIES  = "Bufft auch in den Hauptstädten.\nWenn du PvP geflagged bist, bufft es immer.";
SMARTBUFF_OFTT_UISYNC        = "Aktiviert die Synchronisation mit dem UI,\num die Buff-Zeiten der anderen Spieler zu erhalten.";
SMARTBUFF_OFTT_BLDURATION    = "Wieviele Sekunden ein Spieler auf\ndie schwarze Liste gesetzt wird.\n0 = Deaktivert";
SMARTBUFF_OFTT_COMPMODE      = "Kompatibilitäts Modus\nWarnung!!!\nBenutzte diesen Modus nur, wenn Probleme auftreten\nBuffs auf sich selbst zu casten.";
SMARTBUFF_OFTT_MINIGRP       = "Zeigt die Raid-Subgruppen Einstellungen in einem\neigenen verschiebbaren Mini-Fenster an.";
SMARTBUFF_OFTT_ANTIDAZE      = "Bricht automatisch den\nAspekt des Geparden/Rudels ab,\nwenn jemand betäubt wird\n(Selbst oder Gruppe).";
SMARTBUFF_OFTT_SPLASHSTYLE   = "Wechselt die Schriftart\nder Buff-Meldungen.";
SMARTBUFF_OFTT_HIDESABUTTON  = "Verbirgt den SmartBuff Action-Knopf.";
SMARTBUFF_OFTT_INCOMBAT      = "Funktioniert nur auf dich selbst.\nDer erste Buff, welcher als 'im Kampf'\ngesetzt ist, wird verwendet\nund kann im Kampf benutzt werden.\n!!! Achtung !!!\nSämtliche Buff-Logik ist inaktiv im Kampf!";
SMARTBUFF_OFTT_SMARTDEBUFF   = "Zeigt das SmartDebuff Fenster.";
SMARTBUFF_OFTT_SPLASHDURATION= "Wieviele Sekunden die Splash Meldung angezeigt wird,\nbevor sie ausgeblendet wird.";
SMARTBUFF_OFTT_INSHAPESHIFT  = "Bufft auch wenn du\nverwandelt bist.";
SMARTBUFF_OFTT_LINKGRPBUFFCHECK  = "Prüft ob schon ein Buff\nmit gleichem Effekt von einer\nanderen Klasse aktiv ist.";
SMARTBUFF_OFTT_LINKSELFBUFFCHECK = "Prüft ob ein Eigen-Buff\naktiv ist, von welchen jeweils\nnur einer aktiv sein kann.";
SMARTBUFF_OFTT_SOUNDSELECT	 = "Wählen Sie den gewünschten Splash.";

-- Buffsetup Frame Text
SMARTBUFF_BST_SELFONLY       = "Nur mich";
SMARTBUFF_BST_SELFNOT        = "Mich nicht";
SMARTBUFF_BST_COMBATIN       = "Im Kampf";
SMARTBUFF_BST_COMBATOUT      = "Aus dem Kampf";
SMARTBUFF_BST_MAINHAND       = "Waffenhand";
SMARTBUFF_BST_OFFHAND        = "Schildhand";
SMARTBUFF_BST_RANGED         = "Wurfwaffe";
SMARTBUFF_BST_REMINDER       = "Benachrichtigung";
SMARTBUFF_BST_MANALIMIT      = "Grenzwert";

-- Buffsetup Frame Tooltip Text
SMARTBUFF_BSTT_SELFONLY      = "Bufft nur deinen eigenen Charakter."; 
SMARTBUFF_BSTT_SELFNOT       = "Bufft alle anderen selektierte Klassen,\nausser deinen eigenen Charakter.";
SMARTBUFF_BSTT_COMBATIN      = "Bufft innerhalb des Kampfes.";
SMARTBUFF_BSTT_COMBATOUT     = "Bufft ausserhalb des Kampfes.";
SMARTBUFF_BSTT_MAINHAND      = "Bufft die Haupthand.";
SMARTBUFF_BSTT_OFFHAND       = "Bufft die Schildhand.";
SMARTBUFF_BSTT_RANGED        = "Bufft die Wurfwaffe.";
SMARTBUFF_BSTT_REMINDER      = "Erinnerungs-Nachricht ausgeben.";
SMARTBUFF_BSTT_REBUFFTIMER   = "Wieviele Sekunden vor Ablauf des Buffs,\nsoll daran erinnert werden.\n0 = Globaler Rebuff Timer";
SMARTBUFF_BSTT_MANALIMIT     = "Mana/Wut/Energie Grenzwert\nWenn du unter diesen Wert fällst\nwird der Buff nicht mehr verwendet.";

-- Playersetup Frame Tooltip Text
SMARTBUFF_PSTT_RESIZE        = "Minimiert/Maximiert\ndas Optionenfenster";

-- Messages
SMARTBUFF_MSG_LOADED         = "geladen! - Bitte melden Sie alle Probleme auf Curse oder treten Sie Discord bei |cffffff00discord.gg/R6EkZ94TKK|cffffffff für eine verbesserte Unterstützung.";
SMARTBUFF_MSG_NEWVER1		 = "|cff00e0ffSmartbuff : |cffffffff Es ist eine neue Version verfügbar. Du benutzt |cffFFFF00";
SMARTBUFF_MSG_NEWVER2		 = "|cffffffff und Überarbeitung |cffFFFF00r"
SMARTBUFF_MSG_NEWVER3		 = "|cffffffff steht aktuell zum Download bereit. Tritt Discord bei, um die neuesten Informationen zu erhalten https://discord.gg/R6EkZ94TKK.";
SMARTBUFF_MSG_DISABLED       = "SmartBuff ist deaktiviert!";
SMARTBUFF_MSG_SUBGROUP       = "Du hast die Subgruppe gewechselt, bitte überprüfe die Einstellungen!";
SMARTBUFF_MSG_NOTHINGTODO    = "Nichts zu buffen";
SMARTBUFF_MSG_BUFFED         = "gebuffed";
SMARTBUFF_MSG_OOR            = "ist ausser Reichweite zum Buffen!";
--SMARTBUFF_MSG_CD             = "hat noch Cooldown";
SMARTBUFF_MSG_CD             = "Globaler Cooldown!";
SMARTBUFF_MSG_CHAT           = "nicht möglich über Chat-Befehl!";
SMARTBUFF_MSG_SHAPESHIFT     = "In Verwandlung kann nicht gebufft werden!";
SMARTBUFF_MSG_NOACTIONSLOT   = "muss in einem Slot auf der Aktionsleiste sein, dass es funktioniert!";
SMARTBUFF_MSG_GROUP          = "Gruppe";
SMARTBUFF_MSG_NEEDS          = "benötigt";
SMARTBUFF_MSG_OOM            = "Zuwenig Mana/Wut/Energie!";
SMARTBUFF_MSG_STOCK          = "Aktueller Bestand";
SMARTBUFF_MSG_NOREAGENT      = "Zuwenig";
SMARTBUFF_MSG_DEACTIVATED    = "deaktiviert!";
SMARTBUFF_MSG_REBUFF         = "ReBuff";
SMARTBUFF_MSG_LEFT           = "übrig";
SMARTBUFF_MSG_CLASS          = "Klasse";
SMARTBUFF_MSG_CHARGES        = "Aufladungen";
SMARTBUFF_MSG_SOUNDS		 = "Splash-Sound-Auswahl: "
SMARTBUFF_MSG_SPECCHANGED    = "Spec gewechselt (%s), lade Buff-Vorlagen...";

-- Support
SMARTBUFF_MINIMAP_TT         = "Linke Maustaste für Optionen\nRechte Maustaste zum Ein-/Ausschalten\nAlt-Links-Maustaste zum Umschalten der automatischen Verfolgung\nUmschalttaste ziehen: Schaltfläche „Verschieben“.";
SMARTBUFF_TITAN_TT           = "Linke Maustaste für Optionen\nRechte Maustaste zum Ein-/Ausschalten\nAlt-Links-Maustaste zum Umschalten der automatischen Verfolgung";
SMARTBUFF_FUBAR_TT           = "\nLinke Maustaste für Optionen\nRechte Maustaste zum Ein-/Ausschalten\nAlt-Links-Maustaste zum Umschalten der automatischen Verfolgung";

SMARTBUFF_DEBUFF_TT          = "Shift-Links ziehen: Fenster verschieben\n|cff20d2ff- S Knopf -|r\nLinks Klick: Ordne nach Klassen\nShift-Links Klick: Klassen-Farben\nAlt-Links Klick: Zeige L/R\n|cff20d2ff- P Knopf -|r\nLinks Klick: Verberge Pets";

end
