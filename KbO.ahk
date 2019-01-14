#IfWinActive, ahk_exe gta_sa.exe
SetBatchLines, -1 ;Too fast
#UseHook
#InstallKeybdHook
#SingleInstance, Force
#Persistent
#HotString EndChars `n
#NoEnv
SetWorkingDir %A_AppData%\Bobo

;~ ############################################# TestArea




;~ ExitApp
;~ #############################################

If(!A_IsAdmin && A_IsCompiled) {
	Run *RunAs %A_ScriptFullPath%
	ExitApp
}

If(!A_IsCompiled) {
	IfExist, %A_ScriptDir%\KbO.exe
		{
		Run *RunAs %A_ScriptDir%\KbO.exe
		} else {
		Run *RunAs %A_ScriptDir%\KbO.exe.lnk
		}
	ExitApp
	}

IfExist, %A_ScriptDir%\OldBinder.Trash
	FileDelete, %A_ScriptDir%\OldBinder.Trash

IfExist, %A_AppData%\Bobo\ToDelete.ini
	{
	IniRead, ToDelete, %A_AppData%\Bobo\ToDelete.ini, Old, OldExe, 0
	if(ToDelete)
		FileDelete, %ToDelete%
	FileDelete, %A_AppData%\Bobo\ToDelete.ini
	}

IfNotExist, %A_AppData%\Bobo
	{
	FileCreateDir, %A_Appdata%\Bobo
	FileCreateDir, %A_Appdata%\Bobo\bin
	FileCreateDir, %A_Appdata%\Bobo\img
	}
IfNotExist, %A_AppData%\Bobo\KbO.exe 
	{
	OldPlace := A_ScriptFullPath
	FileMove, %A_ScriptFullPath%, %A_AppData%\Bobo\KbO.exe, 1
	StringReplace, OldPlace, OldPlace, ".exe"
	FileCreateShortcut, %A_AppData%\Bobo\KbO.exe, %OldPlace%.lnk
	inipath := A_AppData "\Bobo\config.ini"
	IniWrite, 3.2, %inipath%, Settings, Version
	IniWrite, 0, %inipath%, Kills, GesamteKills
	IniWrite, +1 Kill in [Zone] für [Name]!, %inipath%, Killbinds, KillbindText1
	IniWrite, /echo Das war der {ff0000}[GKills] {ffffff}Snack!, %inipath%, Killbinds, KillbindText2
	IniWrite, 3, %inipath%, Keybinds, KeybindHotkey1
	IniWrite, /use donut, %inipath%, Keybinds, KeybindText1
	IniWrite, SERVER: Willkommen, %inipath%, Autonom, AutonomReact1
	IniWrite, /echo Willkommen [Name]!, %inipath%, Autonom, AutonomAction1
	IniWrite, 1, %inipath%, Einstellungen, AutoEnableEngine
	FirstInstall := true
	}
IfNotExist, %A_Appdata%\Bobo\bin\Open-SAMP-API.dll
	{
	URLDownloadToFile, https://ourororo.de/killbinder/api/Open-SAMP-API.dll, API.dll
	FileMove, API.dll, %A_Appdata%\Bobo\bin\Open-SAMP-API.dll, 1
	}

UsedButtons := "button_activeautonom.png|button_activeeinstellungen.png|button_activefrakbinds.png|button_activeinformationen.png|button_activekeybinds.png|button_activekillbinds.png|button_activetextbinds.png|button_anmelden.png|button_autonom.png|button_einstellungen.png|button_frakbinds.png|button_gast.png|button_informationen.png|button_keybinds.png|button_killbinds.png|button_textbinds.png|button_speichern.png"
	
Loop, parse, UsedButtons, |
	{
	IfNotExist, %A_Appdata%\Bobo\img\%A_Loopfield%
		{
		URLDownloadToFile, https://ourororo.de/killbinder/img/%A_LoopField%, %A_Loopfield%
		FileMove, %A_Loopfield%, %A_Appdata%\Bobo\img\%A_Loopfield%, 1
		}
	}

IfNotExist, %A_AppData%\Bobo\gtasa.png
	URLDownloadToFile, https://ourororo.de/killbinder/img/gtasa.png, gtasa.png
IfNotExist, %A_AppData%\Bobo\playericon.png
	URLDownloadToFile, https://ourororo.de/killbinder/img/playericon.png, playericon.png
IfNotExist, %A_AppData%\Bobo\marker.png
	URLDownloadToFile, https://ourororo.de/killbinder/img/marker.png, marker.png

if(FirstInstall) {
	MsgBox, 48, Erste Installation, Willkommen!`nDanke`, dass du dich für den Killbinder by Ouro entschieden hast.`n`nDer Keybinder wird sich für die Installation einmal neustarten.`n`nLiebe Grüße`,`nBobo
	Run *RunAs %A_AppData%\Bobo\KbO.exe
	ExitApp
	}

if(A_ScriptFullpath != A_AppData "\Bobo\KbO.exe") {
	OldPlace := A_ScriptFullPath
	FileMove, %A_ScriptFullPath%, %A_AppData%\Bobo\KbO.exe, 1
	StringReplace, OldPlace, OldPlace, ".exe"
	FileCreateShortcut, %A_AppData%\Bobo\KbO.exe, %OldPlace%.lnk
	;~ IniWrite, %A_ScriptFullPath%, %A_AppData%\Bobo\ToDelete.ini, Old, OldExe
	IfExist, %A_AppData%\Bobo\KbO.exe
		Run *RunAs %A_AppData%\Bobo\KbO.exe
	ExitApp
	}

global DeclareVarsCount := 9
global DeclareVars := []
Loop, %DeclareVarsCount%
	DeclareVars.Push("")

global HitSound
global SoundInfo := "*-1"
global SoundWarn := "*16"
global Frak_Typ := {1: "Staat", 2: "Staat", 4: "Staat", 5: "Mafia", 6: "Mafia", 7: "Staat", 9: "Neutral", 11: "Gang", 13: "Gang", 14: "Gang",18: "Mafia", 19: "Gang"}
global ObjTyp := {1: "Container", 2: "Hanf", 3: "Gold", Container: "1", Hanf: "2", Gold: "3"}
global CareTyp := {1: "gegossen", 2: "gedüngt", 3: "Ammoniak nachgefüllt", 4: "Natronlauge nachgefüllt"}
global TruckSortArr := ["Erfahrung aufsteigend", "Geld aufsteigend", "Erfahrung absteigend", "Geld absteigend"]
global bobopath := A_AppData "\Bobo"
global inipath := A_AppData "\Bobo\config.ini"
global AnzKillbinds := 16
global AnzKeybinds := 16
global AnzTextbinds := 16
global AnzAutonom := 8
global AnzFrakbinds := 10
global AnzForum := 10
LoadIni()
global FastFoodIdleTimer := 10
global TruckerList := ["403", "413", "414", "455", "456", "478", "498", "499", "514", "515", "578"]
global Frak_Name := {1: "San Andreas Police Department", 2: "Federal Bureau of Investigation", 4: "San Andreas Rettungsdienst", 5: "La Cosa Nostra", 6: "Yakuza", 7: "Regierung", 9: "San Andreas Media AG", 11: "Scarfo Family", 13: "Purple Ice Ballas", 14: "Grove Street",18: "Triaden", 19: "Mara Salvatrucha"}
global Frak_RegEx := ["PD|Police|Polizei|LS|Los Santos|Bullen|Cops", "F\.?B\.?I\.?|Federal|Bureau|Investigation|Sniper","", "Krankenhaus|SA:?RD|Rettungsdienst|Arzt|Ärzte|Medic", "LCN|La Cosa Nostra|Cosa|Nostra", "Yakuza|YKZ|Yaki|Eis", "Regierung|Government|Gov|DMV|Motor|Fahrschule|Schule|Führerschein","", "SAM ?AG|Media|News|^SAM|Reporter|Ouro|nikk", "", "Aztec|Varrios|Scarfo|Racing|Auto|Car|Rifa|VLA","", "Ballas|Front Yard|Purple|Ice|PIB|Pokee", "GS|Grove Street|Grove","","","", "Shanghai|Syndikat|China|Triaden|Triad|Jiro", "Los|Vagos|Latino|Mara Salvatr?ucha|Mara|Salvatr?ucha|Salva|MS|13"]
global chatlogpath
global oCars := ["Landstalker", "Bravura", "Buttalo", "Linerunner", "Perennial", "Sentinel", "Dumper", "Firetruck", "Trashmaster", "Stretch", "Manana", "Infernus", "Voodoo", "Pony", "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam", "Esperanto", "Taxi", "Washington", "Bobcat", "Mr. Whoopee", "BF Injection", "Hunter", "Premier", "Enforcer", "Securicar", "Banshee", "Predator", "Bus", "PANZAH", "Barracks", "Hotknife", "Trailer", "Previon", "Coach", "Cabbie", "Stallion", "Rumpo", "RC Bandit", "Romero", "Packer", "Monster", "Admiral", "Squallo", "Seasparrow", "Pizzaboii", "Tram", "Trailer", "Turismo", "Speeder", "Reefer", "Tropic", "Flatbed", "Yankee", "Ich hab Cojones", "Solari", "Barkley's RC", "Skimmer", "PCJ-600", "Faggio", "Freeway", "RC Baron", "RC Raider", "Glendale", "Oceanic", "Sanchez", "Sparrow", "Patriot", "Quad", "Coastguard", "Dinghy", "Hermes", "Sabre", "Rustler", "ZR-350", "Walton", "Regina", "Comet", "BMX", "Burrito", "Mutterschiff", "Marquis", "Baggage", "Dozer", "Maverick", "News Heli", "Rancher", "FBI Rancher", "Virgo", "Greenwood", "Jetmax", "Hotring Ranger", "Sandking", "Blista Compact", "Police Heli", "Boxville", "Benson", "Mesa", "RC Goblin", "Hotring Racer A", "Hotring Racer B", "Bloodring Banger", "Rancher Lure", "Super GT", "Elegant", "Journey", "Bike", "Mountain Bike", "Beagle", "Cropduster", "Stuntplane", "Tanker", "Roadtrain", "Nebula", "Majestic", "Buccaneer", "Shamal", "Hydra", "FCR-900", "NRG-500", "HPV1000", "Cement Truck", "TowTruck", "Fortune", "Cadrona", "FBI Truck", "Willard", "Forklift", "Tractor", "Combine Harvester", "Fletzer", "Remington", "Slamvan", "Blade", "Train", "Train", "Vortex", "Vincent", "Bullet", "Clover", "Sadler", "Firetruck LA", "Hustler", "Intruder", "Primo", "Cargobob", "Tampa", "Sunrise", "Merit", "Utility Van", "Nevada", "Yosemite", "Windsor", "Monster A", "Monster B", "Uranus", "Jester", "Sultan", "Stratum", "Elegy", "Raindance", "RC Tiger", "Flash", "Tahoma", "Savanna", "Bandito", "Train Trailer", "Train Trailer", "Kart", "Mower", "Dune", "Sweeper", "Broadway", "Tornado", "AT400", "DFT-30", "Huntley", "Stafford", "BF-400", "Newsvan", "Tug", "Trailer", "Emperor", "Wayfarer", "Euros", "Hotdog", "Club", "Train Trailer", "Trailer", "Andromada", "Dodo", "RC Cam", "Launch", "LSPD-Car", "SFPD-Car", "LVPD-Car", "Police Ranger", "Picador", "S.W.A.T.", "Alpha", "Phoenix", "Glendale", "Sadler", "Baggage Trailer", "Baggage Trailer", "Tug Trailer", "Boxville", "Combine Gear", "Utility Trailer"]
global WeaponList := ["Faust", "Schlagring", "Golfschläger", "Schlagstock", "Schlitzer", "Baseballschläger", "Schaufel", "Pool Stock", "Katana", "Kettensäge", "Doppelpenetrator", "Penetrator", "Langer Vibrator", "Kurzer Vibrator", "Blumen", "Gehstock", "Granate", "Tränengas", "Molotiv Cocktail", "", "", "", "9mm", "Schallgedämpfte 9mm", "Deagle", "Schrotflinte", "Abgesägte Schrotflinte", "Automatische Schrotflinte", "SMG", "MP5", "AK-47", "M4", "Tec-9", "Jägdgewehr", "Scharfschützengewehr", "RPG", "Hitzesuchende Rakete", "HANZ GET ZE FLAMMENWERFER", "RATATATAT", "Fernzünder", "Fernzünder", "Spray", "Feuerlöscher", "Kamera", "Nachtsichtgerät", "Thermalgerät", "Fallschirm", "Fake Pistol", "Fahrzeug", "Rotor", "Explosion", "Ertrunken", "Schwerkraft"]
global EnableAPI
global DefaultAPI := 1
global CurrentChatCount := GetChatLineCount()
global EnableKillbinds := 1
global DisableKilltrigger := 0
global EnableKeybinds := 1
global UserName
global UserPass
global EnableStreaks := 1
global DisableChats := 0
global OldClip := ""
global RegMode
global DelVarIndex := 0
global BoboHeader := {"User-Agent": "Autohotkey/Killbinder/Ouro/" UserName, "Cache-Control": "no-cache, no-store"}
global GuiColor := "424242"
global MainColor := "60ff78" ;? "ffb760"
global SecondColor := "f0ff56" ;? "9536f9"
global TextColor := "ffd026"
global ChatColor := {Bobo: "cdff5b", Echo: "3aebff", Error: "ff0000", Success: "00ff00", Warning: "ff7800", White: "ffffff", Name: "e2ffb2", Level: "b2ffbe", Handy: "b2fdff"}
global LSDCounter := 90
global LSDWarn := 10
global StreakKills
global GesamteKills
global GesamteDeaths
global TaeglicheKills
global TaeglicheDeaths
global GesamteKD
global TaeglicheKD
global LoginState := -1
global LoginTyp := {0: "Gast", 1: "Angemeldet"}
global TextSize := {Label: "36", normal: "12", Desc: "20"}
global KillbinderTitelName := "Killbinder by Ouro REEEEEEmastered"
global OverlayList := "[LSD/Car/Plant/Cont/Skin/Livemap/Race/Use/Timer]"
global GuiMaxH := 570
global GuiMaxW := 1200
global ButtonY := 530
;~ global SkinDiff := (80/A_ScreenWidth*800)
;~ global TextDiff := (50/A_ScreenWidth*800)
global SkinDiff := (80/1920*800)
global TextDiff := (50/1920*800)
global SkinPosX
global SkinPosY
global BigMapX
global BigMapY
global BigMapCrop := 12
global RaceKeyOverlayX
global RaceKeyOverlayY
global ActiveMapOverlayX
global ActiveMapOverlayY
global HitPosX
global HitPosY
global ActiveMapSize := 1000
global ActivePlayerSize := 20
global ActiveMarkerSize := 64
global FuncNeedAPI := []
global FuncAddHover := []

global currentGUI := "Killbinds"
global elements := {"killbinds": [], "keybinds": [], "textbinds": [], "frakbinds": [], "autonom": [], "informationen": [], "informationen2": [], "einstellungen": [], "einstellungen2": [], "login": []}

SetTimer, HitOverlayLabel, 200
SetTimer, ChatLabel, 100
SetTimer, Settings, 500
SetTimer, 1STimer, 1000
SetTimer, RSSFeed, 60000
SetTimer, TruckTimer, 10000

if(InStr(chatlogpath, "A_MyDocuments")) { ;Bugfix
	chatlogpath := A_MyDocuments "\GTA San Andreas User Files\SAMP\chatlog.txt"
	SaveIni()
	}

#Include Funcs_KbO.ahk
#Include Include/WPHeader.ahk
#Include Include/rss_funcs.ahk

;~ ##############################
;~ ####### Funcs_KbO.ahk enthält folgende Funktionen:
;~ ####### BoboRequest - Verbindung mit der HP
;~ ####### HomepagePlayer - Lädt Spielerinformationen für Playerdata von der HP
;~ ####### HomepageFrak - Lädt die Fraktionsmember für Frakdata von der HP
;~ ####### inarray - Überprüft ob dieser Wert im Array enthalten ist
;~ ####### KBOPlayerpos - Gibt Skin/CarModelID, PositionX, PositionY, PositionZ zurück
;~ ####### KBOSend - Allgemeiner Sendbefehl, welcher den Text ohne API, mit API (SendChat) oder in AddChatMessage (Clientseitig) sendet
;~ ####### CalcKD - Berechnet die KD anhand von Kills / Deaths
;~ ####### floorDecimal - Abrunden von Komma-zahlen
;~ ####### IE - Erstellt ein IE-Objekt zur verwendung von DOM
;~ ####### WaitIE - Lässt den Keybinder warten, bis das IE-Objekt die Seite aufgerufen hat
;~ ####### Download - Lädt Informationen / Dateien herunter
;~ ####### SaveClip - Wird ohne API verwendet, wenn man etwas sendet. Speichert die aktuelle Zwischenablage
;~ ####### LoadClip - Wird ohne API verwendet, nachdem man etwas gesendet hat. Lädt die vorherige Zwischenablage
;~ ####### GetFreeze - Überprüft ob sich das Spiel aufgehängt hat
;~ ####### CalculateZone - Ermittelt die Zone anhand von XYZ-Daten
;~ ####### CalculateCity - Ermittelt die City anhand von XYZ-Daten
;~ ####### AddZone - Funktion für CalculateZone
;~ ####### AddCity - Funktion für CalculateCity
;~ ####### initZonesAndCities - Funktion für CalculateZone && CalculateCity
;~ ##############################

CarLocked := 0

UpdateSettings := KBO_DL("https://ourororo.de/killbinder/Version.ini?user=" UserName)
;KBO_DL("https://ourororo.de/killbinder/Version.ini?user=" UserName, "CheckUpdate.ini")
;IniRead, nVersion, CheckUpdate.ini, Settings, Version, 3.2
;IniRead, nDL, CheckUpdate.ini, Settings, DLink, https://ourororo.de/killbinder/KbO3.2.exe
;IniRead, nChangelog, CheckUpdate.ini, Settings, Changelog, NoChangelog
;FileDelete, CheckUpdate.ini
nVersion := ValRead(UpdateSettings, "Settings", "Version", "3.951")
nDL := ValRead(UpdateSettings, "Settings", "DLink", "https://ourororo.de/killbinder/KbO3.951.exe")
nChangelog := ValRead(UpdateSettings, "Settings", "Changelog", "NoChangelog")

IniRead, aVersion, %inipath%, Settings, Version, 3.2

if(nVersion != aVersion) {
	UpdateText := "Es wurde ein Update gefunden!`nDie aktuelle Version ist: [AktVersion]`nDie neue Version ist [NewVersion]`n`nMöchtest du jetzt das Update herunterladen und installieren?`n`nChangelog:`n•"
	StringReplace, UpdateText, UpdateText, [AktVersion], %aVersion%, All
	StringReplace, UpdateText, UpdateText, [NewVersion], %nVersion%, All
	StringReplace, nChangelog, nChangelog, [n], `n•%A_Space%, All
	StringReplace, nChangelog, nChangelog, [v], `n>%A_Space%, All
	
	MsgBox, 64, Killbinder Updater, %UpdateText% %nChangelog%
	FileMove, %A_ScriptFullPath%, %A_ScriptDir%\OldBinder.Trash, 1
	URLDownloadToFile, %nDL%, %A_AppData%\Bobo\KbO.exe
	IfExist, %A_AppData%\Bobo\KbO.exe
		Run *RunAs %A_AppData%\Bobo\KbO.exe
	IniWrite, %nVersion%, %inipath%, Settings, Version
	ExitApp
	}

Gui, main:color, %GuiColor%
font(TextSize["normal"])
KillbindDesc := "Hier können Killbinds eingetragen werden. Von den vorhandenen Killsprüchen wird einer Zufällig ausgewählt, derselbe Killspruch kann nicht 2x hintereinander erscheinen. Variablen stehen im Reiter ""Informationen"""
KeybindDesc := "Hier können Keybinds eingetragen werden. Auf der linken Seite wird der Hotkey eingetragen und rechts davon der zu sendende Text. Variablen stehen im Reiter ""Informationen"""
AutonomDesc := "Hier können Autonome Keybinds eingetragen werden. Auf der linken Seite wird eingetragen auf was der Keybinder reagieren soll. Steht die gesuchte Nachricht im Chat (ungeachtet Groß- & Kleinschreibung) wird der rechte Text gesendet."
InformationDesc := "Hier stehen Informationen zum " KillbinderTitelName "`n`nVersion: " aVersion
Information2Desc := "Hier stehen Informationen zum " KillbinderTitelName "`n`nVersion: " aVersion
FrakbindDesc := "Der Inhalt der Frakbinds werden von den Leadern über die Homepage eingestellt. Hier kann man dann die gewünschten Hotkeys zum Senden eintragen."
EinstellungenDesc := "Some Random I/O Stuff"
Einstellungen2Desc := "Some Random I/O Stuff"
TextbindDesc := "Hier können Textbinds eingetragen werden`nAuf der linken Seite wird der Befehl, z.B. ""/op"" eingetragen`nIn dem rechten Textfeld davon dann die Aktion wie ""/me wird zu einem Marshmallow"""

Gui, main:add, Text, x230 y10 h80 w960 vKillbindDesc c%TextColor% +Hidden, %KillbindDesc%
Gui, main:add, Text, x230 y10 h80 w960 vKeybindDesc c%TextColor% +Hidden, %KeybindDesc%
Gui, main:add, Text, x230 y10 h80 w960 vAutonomDesc c%TextColor% +Hidden, %AutonomDesc%
Gui, main:add, Text, x230 y10 h80 w960 vInformationDesc c%TextColor% +Hidden, %InformationDesc%
Gui, main:add, Text, x230 y10 h80 w960 vInformation2Desc c%TextColor% +Hidden, %Information2Desc%
Gui, main:add, Text, x230 y10 h80 w960 vFrakbindDesc c%TextColor% +Hidden, %FrakbindDesc%
Gui, main:add, Text, x230 y10 h80 w960 vEinstellungenDesc c%TextColor% +Hidden, %EinstellungenDesc%
Gui, main:add, Text, x230 y10 h80 w960 vEinstellungen2Desc c%TextColor% +Hidden, %Einstellungen2Desc%
Gui, main:add, Text, x230 y10 h80 w960 vTextbindDesc c%TextColor% +Hidden, %TextbindDesc%
elements["killbinds"].Push("KillbindDesc")
elements["keybinds"].Push("KeybindDesc")
elements["autonom"].Push("AutonomDesc")
elements["informationen"].Push("InformationDesc")
elements["informationen2"].Push("Information2Desc")
elements["frakbinds"].Push("FrakbindDesc")
elements["einstellungen"].Push("EinstellungenDesc")
elements["einstellungen2"].Push("Einstellungen2Desc")
elements["textbinds"].Push("TextbindDesc")

Gui, main:Add, Picture, x10 y10 gCallbackKillbinds vNavigationKillbinds, img/button_killbinds.png
Gui, main:Add, Picture, x10 y80 gCallbackKeybinds vNavigationKeybinds, img/button_keybinds.png
Gui, main:Add, Picture, x10 y150 gCallbackTextbinds vNavigationTextbinds, img/button_textbinds.png
Gui, main:Add, Picture, x10 y220 gCallbackFrakbinds vNavigationFrakbinds, img/button_frakbinds.png
Gui, main:Add, Picture, x10 y290 gCallbackAutonom vNavigationAutonom, img/button_autonom.png
Gui, main:Add, Picture, x10 y360 gCallbackInformationen vNavigationInformationen, img/button_informationen.png
Gui, main:Add, Picture, x10 y430 gCallbackEinstellungen vNavigationEinstellungen, img/button_einstellungen.png
Gui, main:Add, Picture, x10 y500 gCallbackSpeichern, img/button_speichern.png

font(TextSize["Label"])
Gui, main:add, Text, x230 y40 vLoginText c%TextColor%, Login
font(TextSize["Desc"])
Gui, main:add, Text, x280 y150 Right w150 vLoginNameText c%TextColor%, Benutzername
Gui, main:add, Text, x280 y200 Right w150 vLoginPassText c%TextColor%, Passwort
Gui, main:Add, Picture, x460 y250 gCallbackLoginUser vLoginUserPicAnmelden, img/button_anmelden.png
Gui, main:Add, Picture, x760 y250 gCallbackLoginGast vLoginUserPicGast, img/button_gast.png
font(TextSize["normal"])
Gui, main:Add, Button, x0 y0 h0 w0 gDefaultLogin vDefaultLogin +Hidden +Default, K
Gui, main:add, Edit, vLoginName x460 y150 w500, %UserName%
Gui, main:add, Edit, vLoginPass x460 y200 w500 Password*

Gui, main:Add, Text, x220 y0 w10 h%GuiMaxH% 0x11 c%SecondColor%, 
Gui, main:Add, Text, x221 y100 w979 0x10 c%SecondColor%, 


Gui, main:show, w%GuiMaxW% h%GuiMaxH%, %KillbinderTitelName%
;~ WinSet, Style, -0xC00000, a // Entfernt Kopfzeile

elements["login"].Push("LoginText")
elements["login"].Push("LoginName")
elements["login"].Push("LoginPass")
elements["login"].Push("LoginUserPicAnmelden")
elements["login"].Push("LoginUserPicGast")
elements["login"].Push("LoginNameText")
elements["login"].Push("LoginPassText")

Loop, %AnzKillbinds%
	{
	if(A_Index <= (AnzKillbinds/2)) {
		koordY := (50*A_Index)+60
		Gui, main:add, Edit, x230 y%koordY% w450 h30 vKillbindText%A_Index% -VScroll +Hidden, % KillbindText%A_Index%
		} else {
		koordY := (50*(A_Index-(AnzKillbinds/2)))+60
		Gui, main:add, Edit, x740 y%koordY% w450 h30 vKillbindText%A_Index% -VScroll +Hidden, % KillbindText%A_Index%
		}
	elements["killbinds"].Push("KillbindText" A_Index)
	}

InfoText11 := "Variablen:`n[GKills]`tGesamte Kills`n[GDeaths]`tGesamte Tode`n[GKD]`t`tGesamte KD`n[DKills]`tTägliche Kills`n[DDeaths]`tTägliche Tode`n[DKD]`t`tTägliche KD`n[Weapon]`tAktuelle Waffe`n[Zone]`t`tAktuelle Zone`n[City]`t`tAktuelles Stadtgebiet`n[Vehicle]`tAktuelles Fahrzeug!!`n[Screen]`tMacht einen Screen mit F8`n[WaitXXXX]`tWartet XXXX-Millisekunden`n[Streak]`tAktuelle Streak`n[GameText XXXX]`tSendet den Text als Label (Clientseitig) für XXX Millisekunden`n[ID XX]`tVor dem Senden kann man den Inhalt bestimmen`n[Heal]`t`tAktuelle HP`n[Armor]`tAktuelle Armor`n[Health]`tHeal+Armor`n[dVar 1-9]`tEnthält definierte Variablen`n[PID]`t`tEigene ID"
InfoText12 := "Special Autonomer Chat:`nLinks: `n[RegEx]`tSuchmuster als RegEx und nicht als Suchtext`n`nRechts: `n[ChatX]`tNimmt das X-te Wort aus dem Chat"
InfoText12 .= "`n`nweitere Variablen:`n[InputMode]`tInput-Modus (manuelles Abtippen) bis zur nächsten ~ aktiv`n[AllInput]`tInput-Modus (manuelles Abtippen) was ~ -übergreifend ist"
Gui, main:add, Text, x230 y110 vInfoText11 c%SecondColor% +Hidden, %InfoText11%
Gui, main:add, Text, x700 y110 vInfoText12 c%SecondColor% +Hidden, %InfoText12%

InfoText21 := "Befehle:`n/setvs`t`tLegt den Chat für /vs fest`n/vs`t`tSendet eine Nachfrage nach Verstärkung`n/hwd`t`tAutomatisches Housewithdraw`n/GetCont`tAbfrage über gespeicherte Plantagen etc`n/GetPlant`tAbfrage über gespeicherte Plantagen etc`n/SetKills`tSetzt die GKills`n/SetDeaths`tSetzt die GDeaths`n/DebugVisual`tEntfernt alle aktuellen Overlays`n/MoveOverlay`tÄndert die Position des Overlays`n/ResetOverlay`tSetzt die Position zurück`n/Math`t`tTaschenrechner`nDoppel M`t/mv /oldmv`n/DefMoney`tAm ATM das Bargeld festsetzen`n/Playerdata`tWie Playerinfo`n/Frakdata`tÜberprüft wer von einer Fraktion online ist`n/FrakdataID`tGibt die Mitglieder der Fraktion mit /id wieder"
InfoText22 := "`n/kflagpos`tAutomatisches /GetFlagPos`n/WPBinds`tZählt alle WP-Binds auf`n/WPSearch`tSucht in WPBinds`n/BizData`tZeigt Flaggenpositionen an`n/Relog`t`tSchnelles Reloggen`n/Wordmix`tShuffle!`n/RaceKey`tOverlay für WASD und Space`n/Killbind`tDeaktiviert die Chatausgabe bei Kills`n/Killtest`t`tSimuliert einen Kill`n/SetVar`t`tDefiniert die Variablen`n/Funktionstest`tÜberprüft die Funktionalität`n/Clear`t`tBereinigt den Chat`n/Truckdata`tGibt Truckermissionen zurück`n/Dealzone`tWie sich eine Dealzone zusammenstellt"
InfoText3 := "Mitwirkende:`n[NeS]Ouroboros`tAHK-Scripter`n[NeS]shoXy`t`tBereitstellung einer API`nPokee`t`t`tAHK Unterstützung"
Gui, main:add, Text, x230 y110 vInfoText21 c%SecondColor% +Hidden, %InfoText21%
Gui, main:add, Text, x650 y110 vInfoText22 c%SecondColor% +Hidden, %InfoText22%
Gui, main:add, Text, x900 y10 w500 vInfoTextBoth c%SecondColor% +Hidden, %InfoText3%

Gui, main:add, Button, x1070 y%ButtonY% h30 w120 gSwitchLabel vInformationen2 +Hidden, Informationen 2
Gui, main:add, Button, x1070 y%ButtonY% h30 w120 gSwitchLabel vInformationen1 +Hidden, Informationen 1

Gui, main:add, Button, x860 y%ButtonY% h30 w200 gStartSAMP vStartSAMP +Hidden, SAMP starten
Gui, main:add, Button, x860 y%ButtonY% h30 w200 gSelectSAMP vSelectSAMP +Hidden, SAMP auswählen

Gui, main:add, Button, x650 y%ButtonY% h30 w200 gChatOpen vChatOpen +Hidden, Chat öffnen
Gui, main:add, Button, x650 y%ButtonY% h30 w200 gChatSelect vChatSelect +Hidden, Chat auswählen

elements["informationen"].Push("InfoText11")
elements["informationen"].Push("InfoText12")
elements["informationen2"].Push("InfoText21")
elements["informationen2"].Push("InfoText22")
elements["informationen"].Push("InfoTextBoth")
elements["informationen2"].Push("InfoTextBoth")
elements["informationen"].Push("Informationen2")
elements["informationen2"].Push("Informationen1")
elements["informationen"].Push("StartSAMP")
elements["informationen2"].Push("SelectSAMP")
elements["informationen"].Push("ChatOpen")
elements["informationen2"].Push("ChatSelect")


Gui, main:add, Checkbox, x230 y110 vAutoEnableEngine Checked%AutoEnableEngine% c%TextColor% +Hidden, Automatisch Motor einschalten
Gui, main:add, Checkbox, x230 y160 vAutoEnableLights Checked%AutoEnableLights% c%TextColor% +Hidden, Automatisch Licht einschalten
Gui, main:add, Checkbox, x230 y210 vAutoSendWPs Checked%AutoSendWPs% c%TextColor% +Hidden, Erhaltene WPs in den /vs-Chat

Gui, main:add, Text, x700 y160 w150 vMouseText1 c%TextColor% +Hidden hwndhctrlMouseText1, Maus links kippen:
Gui, main:add, Text, x700 y210 w150 vMouseText2 c%TextColor% +Hidden hwndhctrlMouseText2, Maus rechts kippen:
Gui, main:add, Edit, x850 y160 w300 h30 vMouseButton1 -VScroll +Hidden, %MouseButton1%
Gui, main:add, Edit, x850 y210 w300 h30 vMouseButton2 -VScroll +Hidden, %MouseButton2%

Gui, main:add, CheckBox, x230 y260 vStartUpProg1 Checked%StartUpProg1% c%TextColor% +Hidden, Programm1 gleichzeigig starten
Gui, main:add, Checkbox, x230 y310 vStartUpProg2 Checked%StartUpProg2% c%TextColor% +Hidden, Programm2 gleichzeitig starten
Gui, main:add, Checkbox, x230 y360 vStartUpProg3 Checked%StartUpProg3% c%TextColor% +Hidden, Programm3 gleichzeitig starten

Gui, main:add, Button, x450 y250 w200 gStartUpProg1 vStartProgButton1 c%TextColor% +Hidden, %StartProgButton1%
Gui, main:add, Button, x450 y300 w200 gStartUpProg2 vStartProgButton2 c%TextColor% +Hidden, %StartProgButton2%
Gui, main:add, Button, x450 y350 w200 gStartUpProg3 vStartProgButton3 c%TextColor% +Hidden, %StartProgButton3%

Gui, main:add, Text, x800 y260 w100 vCallin c%TextColor% +Hidden, /p
Gui, main:add, Text, x800 y310 w100 vCallout c%TextColor% +Hidden, /h
Gui, main:add, Text, x800 y360 w100 vCallignore c%TextColor% +Hidden, /abw
Gui, main:add, Edit, x850 y260 w300 h30 vCallinText -VScroll +Hidden, %CallinText%
Gui, main:add, Edit, x850 y310 w300 h30 vCalloutText -VScroll +Hidden, %CalloutText%
Gui, main:add, Edit, x850 y360 w300 h30 vCallignoreText -VScroll +Hidden, %CallignoreText%

Gui, main:add, Text, x650 y110 w200 vActionOnLSD c%TextColor% +Hidden, Nach LSD Nebenwirkung:
Gui, main:add, Edit, x850 y110 w300 h30 vActionOnLSDText -VScroll +Hidden, %ActionOnLSDText%

Gui, main:add, Text, x700 y410 h30 w260 vHotkeyToggleText c%TextColor% +Hidden, Keybinder ein- / ausschalten
Gui, main:add, Hotkey, x920 y410 h30 w60 vHotkeyToggle -VScroll +Hidden, %HotkeyToggle%

Gui, main:add, Text, x1050 y410 h30 w60 vVSHotkeyText c%TextColor% +Hidden, /vs
Gui, main:add, Hotkey, x1090 y410 h30 w60 vVSHotkey -VScroll +Hidden, %VSHotkey%

Gui, main:add, CheckBox, x230 y410 vAutoSwitchGun Checked%AutoSwitchGun% c%TextColor% +Hidden, Automatisches Swapgun
Gui, main:add, CheckBox, x230 y460 vActivePremium Checked%ActivePremium% c%TextColor% +Hidden, Aktives Premium

Gui, main:add, Text, x800 y460 h30 vTruckingText c%TextColor% +Hidden, Sortierung von Trucking
Gui, main:add, DDL, x950 y460 w200 vTruckingChoice c%TextColor% +Hidden +AltSubmit Choose%TruckingChoice%, Erfahrung aufsteigend|Geld aufsteigend|Erfahrung absteigend|Geld absteigend

Gui, main:add, Button, x1090 y%ButtonY% h30 w100 gSwitchLabel vEinstellungen2 +Hidden, Einstellungen 2

FuncNeedAPI.Push("AutoEnableEngine")
FuncNeedAPI.Push("AutoEnableLights")
FuncNeedAPI.Push("AutoSwitchGun")
FuncAddHover.Push({"MouseText1": "Maustaste 4"})
FuncAddHover.Push({"MouseText2": "Maustaste 5"})
elements["einstellungen"].Push("MouseText1")
elements["einstellungen"].Push("MouseText2")
elements["einstellungen"].Push("MouseButton1")
elements["einstellungen"].Push("MouseButton2")
elements["einstellungen"].Push("AutoEnableEngine")
elements["einstellungen"].Push("AutoEnableLights")
elements["einstellungen"].Push("AutoSendWPs")
elements["einstellungen"].Push("StartUpProg1")
elements["einstellungen"].Push("StartUpProg2")
elements["einstellungen"].Push("StartUpProg3")
elements["einstellungen"].Push("StartProgButton1")
elements["einstellungen"].Push("StartProgButton2")
elements["einstellungen"].Push("StartProgButton3")
elements["einstellungen"].Push("Callin")
elements["einstellungen"].Push("Callout")
elements["einstellungen"].Push("Callignore")
elements["einstellungen"].Push("CallinText")
elements["einstellungen"].Push("CalloutText")
elements["einstellungen"].Push("CallignoreText")
elements["einstellungen"].Push("ActionOnLSD")
elements["einstellungen"].Push("ActionOnLSDText")
elements["einstellungen"].Push("HotkeyToggleText")
elements["einstellungen"].Push("HotkeyToggle")
elements["einstellungen"].Push("AutoSwitchGun")
elements["einstellungen"].Push("ActivePremium")
elements["einstellungen"].Push("VSHotkeyText")
elements["einstellungen"].Push("VSHotkey")
elements["einstellungen"].Push("Einstellungen2")
elements["einstellungen"].Push("TruckingChoice")
elements["einstellungen"].Push("TruckingText")

Gui, main:add, Button, x1090 y%ButtonY% h30 w100 gSwitchLabel vEinstellungen1 +Hidden, Einstellungen 1
Gui, main:add, Button, x950 y%ButtonY% h30 w130 gSelectHitsound vSelectHit +Hidden, Hitsound auswählen
Gui, main:add, Text, x230 y110 h30 vActiveMapOverlayDesc +Hidden c%TextColor%, Öffne MapOverlay
Gui, main:add, Hotkey, x400 y110 h30 w100 vActiveMapOverlayHotkey -VScroll +Hidden, %ActiveMapOverlayHotkey%

Gui, main:add, Checkbox, x230 y160 vEnableAPI Checked%EnableAPI% c%TextColor% +Hidden, API einschalten
Gui, main:add, CheckBox, x230 y210 vSaveHistory Checked%SaveHistory% c%TextColor% +Hidden, Chat protokollieren`, wenn SAMP gestartet wird
Gui, main:add, Checkbox, x230 y260 vEnableCarhealOverlay Checked%EnableCarhealOverlay% c%TextColor% +Hidden, Carheal Overlay einschalten
Gui, main:add, Checkbox, x230 y310 vEnableLSDOverlay Checked%EnableLSDOverlay% c%TextColor% +Hidden, LSD Overlay einschalten
Gui, main:add, Checkbox, x230 y360 vEnableUSEOverlay Checked%EnableUSEOverlay% c%TextColor% +Hidden, /Use Overlay einschalten
Gui, main:add, Checkbox, x230 y410 vEnableTimerOverlay Checked%EnableTimerOverlay% c%TextColor% +Hidden, Andere Timer anzeigen lassen
Gui, main:add, Checkbox, x230 y460 vEnableHitSound Checked%EnableHitSound% c%TextColor% +Hidden, Hitsound einschalten

Gui, main:add, Checkbox, x850 y110 vEnableRSSFeed Checked%EnableRSSFeed% c%TextColor% +Hidden, Forenbenachrichtigungen
Gui, main:add, Checkbox, x850 y160 vEnableAcceptFF Checked%EnableAcceptFF% c%TextColor% +Hidden, Automatisches Foodload

FuncNeedAPI.Push("EnableCarhealOverlay")
FuncNeedAPI.Push("ActiveMapOverlayHotkey")
elements["einstellungen2"].Push("EnableAPI")
elements["einstellungen2"].Push("ActiveMapOverlayHotkey")
elements["einstellungen2"].Push("ActiveMapOverlayDesc")
elements["einstellungen2"].Push("Einstellungen1")
elements["einstellungen2"].Push("SaveHistory")
elements["einstellungen2"].Push("EnableCarhealOverlay")
elements["einstellungen2"].Push("EnableLSDOverlay")
elements["einstellungen2"].Push("EnableUSEOverlay")
elements["einstellungen2"].Push("EnableHitSound")
elements["einstellungen2"].Push("EnableTimerOverlay")
elements["einstellungen2"].Push("SelectHit")
elements["einstellungen2"].Push("EnableRSSFeed")
elements["einstellungen2"].Push("EnableAcceptFF")


return

;############################################################################################################################################################# GUI Callbacks

ChatOpen:
LoadIni()
Run, %chatlogpath%
return
ChatSelect:
LoadIni()
FileSelectFile, nchatpath, 3, chatlog.txt, Wähle die richtige chatlog.txt aus, *.txt
if(nchatpath) {
	chatlogpath := nchatpath
	SaveIni()
	}
return

CloseSAMP:
BlockInput, On
KBOSend("[InputMode]{F6}/q{enter}")
BlockInput, Off
While(ProcessStatus("gta_sa.exe")) {
	Sleep, 100
	}
return
StartSAMP:
if(ProcessStatus("gta_sa.exe"))
	return
LoadIni()
if(!SAMPPath)
	return
if(SaveHistory) {
	IfNotExist, %A_MyDocuments%\GTA San Andreas User Files\SAMP\History
		FileCreateDir, %A_MyDocuments%\GTA San Andreas User Files\SAMP\History
	FileRead, OldChatlog, %chatlogpath%
	FileGetTime, ChatTime, %chatlogpath%, M
	FormatTime, ChatMonth,, yyyy.MM
	ChatTime := RegExReplace(ChatTime, "(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})", "$1.$2.$3 - $4:$5:$6")
	OldChatlog .= "`n"
	ChatSplit1 := "=====================================================================================================`n"
	ChatSplit2 := "============================= Chatlog vom: " ChatTime " ====================================`n"
	FileAppend, %ChatSplit1%, %A_MyDocuments%\GTA San Andreas User Files\SAMP\History\%ChatMonth%.txt
	FileAppend, %ChatSplit2%, %A_MyDocuments%\GTA San Andreas User Files\SAMP\History\%ChatMonth%.txt
	FileAppend, %ChatSplit1%, %A_MyDocuments%\GTA San Andreas User Files\SAMP\History\%ChatMonth%.txt
	FileAppend, %OldChatlog%, %A_MyDocuments%\GTA San Andreas User Files\SAMP\History\%ChatMonth%.txt
	OldChatlog := ""
	}
ProcessClose("gta_sa.exe")
RunWait, %SAMPPath% server.nes-newlife.de:7777
return

DefaultLogin:
if(LoginState != "-1")
	return
GuiControlGet, IssetPassword,, LoginPass
if(IssetPassword)
	GoTo, CallbackLoginUser
	else
	GoTo, CallbackLoginGast
return

SelectHitsound:
LoadIni()
FileSelectFile, HitSound, S3,, Wähle einen Hitsound aus
If(!HitSound)
	HitSound := "*-1"
SoundPlay, %HitSound%
SaveIni()
return

SelectSAMP:
LoadIni()
FileSelectFile, SAMPPath, S3,, Wähle die SAMP.exe aus, samp.exe
if(SAMPPath)
	SaveIni()
return

SwitchLabel:
CreateHotkey(currentGUI, 0)
Gui, main:submit, NoHide
CreateHotkey(currentGUI, 1)
if(currentGUI = "informationen") {
	ChangeTab("informationen2", 1)
	return
	}
if(currentGUI = "informationen2") {
	ChangeTab("informationen", 1)
	return
	}
if(currentGUI = "einstellungen") {
	ChangeTab("einstellungen2", 1)
	return
	}
if(currentGUI = "einstellungen2") {
	ChangeTab("einstellungen", 1)
	return
	}
SaveIni()
return

CallbackKillbinds:
CallbackKeybinds:
CallbackTextbinds:
CallbackFrakbinds:
CallbackAutonom:
CallbackInformationen:
CallbackEinstellungen:
CallbackSpeichern:
if(LoginState = "-1")
	return
CreateHotkey(currentGUI, 0)
Gui, main:submit, NoHide
CreateHotkey(currentGUI, 1)
SaveIni()
if(A_ThisLabel = "CallbackSpeichern") {
	ToolTip, Eingaben wurden gespeichert
	sleep, 500
	ToolTip,
	}
changeTab(SubStr(A_ThisLabel, 9))
return

StartUpProg1:
StartUpProg2:
StartUpProg3:
LoadIni()
ProgCount := SubStr(A_ThisLabel, 12)
FileSelectFile, Prog%ProgCount%, S3, %A_Desktop%, "Was soll der Keybinder beim Start mit ausführen?"
if(!Prog%ProgCount%) {
	Prog%ProgCount%Path := 0
	StartProgButton%ProgCount% := "Programm auswählen"
	} else {
	SplitPath, Prog%ProgCount%, StartProgButton%ProgCount%
	Prog%ProgCount%Path := Prog%ProgCount%
	}
GuiControl,, StartProgButton%ProgCount%, % StartProgButton%ProgCount%
SaveIni()
return

CallbackLoginUser:
if(LoginState != "-1")
	return
Gui, main:submit, NoHide
if(!LoginPass)
	return
SecureLogin := LoadStartUp(LoginName, LoginPass, 1)
if(SecureLogin) {
	LoginState := 1
	GoTo, StartGUI
	}
return

CallbackLoginGast:
if(LoginState != "-1")
	return
Gui, main:submit, NoHide
SecureLogin := LoadStartUp(LoginName,, 0)
if(SecureLogin) {
	LoginState := 0
	GoTo, StartGUI
	}
return

StartGUI:
Suspend, Off
UserName := LoginName
UserPass := LoginPass
SaveIni()
if(StartUpProg1)
	InitStartUp(1)
if(StartUpProg2)
	InitStartUp(2)
if(StartUpProg3)
	InitStartUp(3)

Loop, %AnzKeybinds%
	{
	if(A_Index <= (AnzKeybinds/2)) {
		koordY := (50*A_Index)+60
		Gui, main:add, Hotkey, x230 y%koordY% w60 vKeybindHotkey%A_Index% +Hidden, % KeybindHotkey%A_Index%
		Gui, main:add, Edit, x300 y%koordY% w380 h30 vKeybindText%A_Index% -VScroll +Hidden, % KeybindText%A_Index%
		} else {
		koordY := (50*(A_Index-(AnzKeybinds/2)))+60
		Gui, main:add, Hotkey, x740 y%koordY% w60 vKeybindHotkey%A_Index% +Hidden, % KeybindHotkey%A_Index%
		Gui, main:add, Edit, x810 y%koordY% w380 h30 vKeybindText%A_Index% -VScroll +Hidden, % KeybindText%A_Index%
		}
	elements["keybinds"].Push("KeybindHotkey" A_Index)
	elements["keybinds"].Push("KeybindText" A_Index)
	}

Loop, %AnzTextbinds%
	{
	if(A_Index <= (AnzTextbinds/2)) {
		koordY := (50*A_Index)+60
		Gui, main:add, Edit, x230 y%koordY% w100 vTextbindReact%A_Index% -VScroll +Hidden, % TextbindReact%A_Index%
		Gui, main:add, Edit, x340 y%koordY% w340 h30 vTextbindAct%A_Index% -VScroll +Hidden, % TextbindAct%A_Index%
		} else {
		koordY := (50*(A_Index-(AnzTextbinds/2)))+60
		Gui, main:add, Edit, x740 y%koordY% w100 vTextbindReact%A_Index% -VScroll +Hidden, % TextbindReact%A_Index%
		Gui, main:add, Edit, x850 y%koordY% w340 h30 vTextbindAct%A_Index% -VScroll +Hidden, % TextbindAct%A_Index%
		}
	elements["textbinds"].Push("TextbindReact" A_Index)
	elements["textbinds"].Push("TextbindAct" A_Index)
	}

Loop, %AnzAutonom%
	{
	koordY := (50*A_Index)+60
	Gui, main:add, Edit, x230 y%koordY% w450 h30 vAutonomReact%A_Index% -VScroll +Hidden, % AutonomReact%A_Index%
	Gui, main:add, Edit, x740 y%koordY% w450 h30 vAutonomAction%A_Index% -VScroll +Hidden, % AutonomAction%A_Index%
	elements["autonom"].Push("AutonomReact" A_Index)
	elements["autonom"].Push("AutonomAction" A_Index)
	}

Loop, %AnzFrakbinds%
	{
	if(A_Index <= (AnzFrakbinds/2)) {
		koordY := (50*A_Index)+60
		Gui, main:add, Hotkey, x230 y%koordY% w60 vFrakHotkey%A_Index% +Hidden, % FrakHotkey%A_Index%
		Gui, main:add, Edit, x300 y%koordY% w380 h30 vFrakbindText%A_Index% c%SecondColor% -VScroll +Hidden +ReadOnly, % FrakbindText%A_Index%
		} else {
		koordY := (50*(A_Index-(AnzFrakbinds/2)))+60
		Gui, main:add, Hotkey, x740 y%koordY% w60 vFrakHotkey%A_Index% +Hidden, % FrakHotkey%A_Index%
		Gui, main:add, Edit, x810 y%koordY% w380 h30 vFrakbindText%A_Index% c%SecondColor% -VScroll +Hidden +ReadOnly, % FrakbindText%A_Index%
		}
	elements["frakbinds"].Push("FrakbindText" A_Index)
	elements["frakbinds"].Push("FrakHotkey" A_Index)
	}
FrakID := BoboRequest(UserName,, "FraktionID")
if(FrakID != "0" && !InStr(FrakID, "ERROR")) {
	if(FrakID != FraktionID) {
		FraktionID := FrakID
		SaveIni()
		URLDownloadToFile, https://nes-newlife.de/image/fractions/%FraktionID%, FrakDisplay.png
		}
	Gui, main:add, Picture, x230 y350 h200 vFrakPic +Hidden, FrakDisplay.png
	elements["frakbinds"].Push("FrakPic")
	}
CreateHotkey("all", 1)

changeTab("killbinds")

FlagBizName := {9: "BSN Tankstelle", 10: "GS Tankstelle", 11: "Truckstop Tankstelle", 12: "Dillimore Tankstelle", 13: "SF Bahnhof Tankstelle", 14: "SFPD Tankstelle", 15: "SF Carshop Tankstelle", 16: "Prison Tankstelle", 17: "Angel Pine Tankstelle", 21: "Tankstelle Bayside"}
FlagBiz1 := {9: ["-1544", "-2737", "Angel Pine Tankstelle"], 10: ["1097", "1605", "LV Arena"], 11: ["-126", "2257", "Prison Grube"], 12: ["-1633", "-2239", "Angel Pine Holzhütte"], 13: ["-915", "2010", "Staudamm"], 14: ["-10", "-2515", "Ehemalige FBI Base"], 15: ["154", "2414", "Flugzeugfriedhof"], 16: ["303", "-1514", "Ehemaliges LCN Hotel"], 17: ["-1031", "460", "SF Airport Landebahn"], 21: ["-2132", "166", "Baustelle SF Bahnhof"]}
FlagBiz2 := {9: ["1369", "2195", "LV Baseballstadion"], 10: ["-1033", "-695", "San Fierro Kraftwerk"], 11: ["889", "-24", "Catalinas Hütte"], 12: ["2584", "2427", "Basketballplatz Rock Hotel"], 13: ["1999", "-2381", "LS Airport"], 14: ["-2227", "2325", "Bayside Heli-Plattform"], 15: ["-640", "865", "LV Fort Carson Steg"], 16: ["2937", "-2051", "East LS Strand"], 17: ["-1481", "2625", "El Quebrados"], 21: ["-552", "-192", "Holzhütte an der Farm"]}
FlagBiz3 := {9: ["-795", "1557", "Kuh-Gebiet"], 10: ["-42", "1082", "Fort Carson"], 11: ["-1431", "-964", "Hütte über SF Tunnel"], 12: ["-2458", "2513", "Bayside Campingplatz"], 13: ["2240", "-80", "Palomino Creek OC"], 14: ["947", "2069", "Ehemalige KF Base"], 15: ["1027", "-2179", "Aussichtsplattform weißes Haus"], 16: ["-1447", "-513", "SF Airport Hangar"], 17: ["389", "875", "Erzmine"], 21: ["1304", "339", "Montgomery"]}
GuiLoaded := 1

For k in FuncAddHover
	{
	For k2, v2 in FuncAddHover[k]
		{
		SetHoverText(hctrl%k2%, v2)
		}
	}

return

mainGuiClose:
mainGuiEscape:
SaveIni()
if(EnableAPI)
	DestroyAllVisual()
ExitApp
return

;############################################################################################################################################################# InGame Callbacks

Label_ToggleKey:
Suspend, Permit
if(A_IsSuspended) {
	KBOSend("/echo Keybinder wird nun {00ff00}aktiviert{ffffff}.")
	Suspend, Off
	} else {
	KBOSend("/echo Keybinder wird nun {ff0000}deaktiviert{ffffff}.")
	Suspend, On
	}
;~ ForceSuspend := A_IsSuspended
return

HotstringLabel1:
HotstringLabel2:
HotstringLabel3:
HotstringLabel4:
HotstringLabel5:
HotstringLabel6:
HotstringLabel7:
HotstringLabel8:
HotstringLabel9:
HotstringLabel10:
HotstringLabel11:
HotstringLabel12:
HotstringLabel13:
HotstringLabel14:
HotstringLabel15:
HotstringLabel16:
Suspend, Permit
if(LoginState = "-1") {
	Hotkey, enter, on
	return
	}
HotstringID := SubStr(A_ThisLabel, 15)
KeyReady()
KBOSend(TextbindAct%HotstringID%)
Hotkey, enter, on
return

Label_for_all_Hotkeys:
if(LoginState = "-1")
	return
if(A_ThisHotkey = "XButton1")
	KBOSend(MouseButton1)
if(A_ThisHotkey = "XButton2")
	KBOSend(MouseButton2)
Loop, %AnzKeybinds%
	{
	if(A_ThisHotkey = KeybindHotkey%A_Index% && StrLen(A_ThisHotkey) = StrLen(KeybindHotkey%A_Index%)) {
		KBOSend(KeybindText%A_Index%)
		return
		}
	}
Loop, %AnzFrakbinds%
	{
	if(A_ThisHotkey = FrakHotkey%A_Index% && StrLen(A_ThisHotkey) = StrLen(FrakHotkey%A_Index%)) {
		KBOSend(FrakbindText%A_Index%)
		return
		}
	}
return

FullMapOverlay:
if(!EnableAPI)
	return
if(!MapOverlay) {
	MapOverlay := 1
	KbOPlayerPos(Positions)
	ActiveMapPlayerPosX := CalcActiveMap(Positions[3],, ActivePlayerSize)
	ActiveMapPlayerPosY := CalcActiveMap(,Positions[4], ActivePlayerSize)
	ActiveMap := ImageCreate("gtasa.png", CalcScreenPos(ActiveMapOverlayX), CalcScreenPos(,ActiveMapOverlayY))
	ActivePlayer := ImageCreate("playericon.png", CalcScreenPos(ActiveMapPlayerPosX), CalcScreenPos(,ActiveMapPlayerPosY))
	SetTimer, UpdateMapOverlay, 500
	} else {
	MapOverlay := 0
	SetTimer, UpdateMapOverlay, off
	Sleep, 200
	ImageDestroy(ActiveMap)
	ImageDestroy(ActivePlayer)
	if(ActiveMapBIZ) {
		Loop, 3
			ImageDestroy(FlagBox%A_Index%)
		ActiveMapBIZ := 0
		}
	}
return

RaceKeyTimer:
if(!EnableAPI || !EnableRaceKeys)
	return
If(!IsWinActive("gta_sa.exe"))
	return
if(GetKeyState("W")) {
	TextSetColor(WRaceKey, "0xFF45ff30")
	} else {
	TextSetColor(WRaceKey, "0xffff0000")
	}
if(GetKeyState("A")) {
	TextSetColor(ARaceKey, "0xFF45ff30")
	} else {
	TextSetColor(ARaceKey, "0xffff0000")
	}
if(GetKeyState("S")) {
	TextSetColor(SRaceKey, "0xFF45ff30")
	} else {
	TextSetColor(SRaceKey, "0xffff0000")
	}
if(GetKeyState("D")) {
	TextSetColor(DRaceKey, "0xFF45ff30")
	} else {
	TextSetColor(DRaceKey, "0xffff0000")
	}
if(GetKeyState("Space")) {
	TextSetColor(SpaceRaceKey, "0xFF45ff30")
	} else {
	TextSetColor(SpaceRaceKey, "0xffff0000")
	}
return

DebugVisualLabel:
if(EnableAPI) {
	DestroyAllVisual()
	CarhealOverlayCreated := 0
	LSDOverlayCreate := 0
	USEOverlayCreate := 0
	}
return

HitOverlayLabel: ;Hitlog
if(!EnableAPI || LoginState = "-1" || IsWinActive("gta_sa.exe") = false)
	return
if(!EnableHitSound)
	return
PrevPlayerHealth := PlayerHealth
PrevPlayerArmor := PlayerArmor
PlayerHealth := GetPlayerHealth()
PlayerArmor := GetPlayerArmor()
HealthDiff := (PrevPlayerHealth + PrevPlayerArmor) - (PlayerHealth + PlayerArmor)
if(PlayerHealth = 25 || PrevPlayerHealth = 25 || !PlayerHealth || !PrevPlayerHealth || PlayerHealth > 300 || PrevPlayerHealth > 300 || PlayerHealth = "-1" || PrevPlayerHealth = "-1")
	return
if(HealthDiff >= 8) {
	SoundPlay, %HitSound%
	}
return

;############################################################################################################################################################# Hotkeys

;~ Hotkey, Enter, Off
;~ Hotkey, Escape, Off

~!F4::
ProcessClose("gta_sa.exe")
return

~t::
~+t::
Suspend On
Hotkey, ~NumpadEnter, On
Hotkey, ~Enter, On
Hotkey, ~Escape, On
return
~Escape::
~NumpadEnter::
~Enter::
Suspend Off
Hotkey, ~NumpadEnter, Off
Hotkey, ~Enter, Off
Hotkey, ~Escape, Off
return

/*
~+F6::
~F6::
~+T::
~t::
if(ForceSuspend)
	return
tsuspend := true
Sleep, 100
Suspend, On
Hotkey, Enter, On
Hotkey, Escape, On
Hotkey, t, Off
Hotkey, F6, Off
return

~Escape::
~Enter::
Suspend Permit
if(ForceSuspend)
	return
Suspend, Off
Hotkey, t, On
Hotkey, F6, On
Hotkey, Enter, Off
Hotkey, Escape, Off
tsuspend := false
return
*/
~M::
if(EnableAPI && IsChatOpen() || EnableAPI && IsMenuOpen())
	return
KeyWait, m
if(GetKeyWait("m", "200"))
	KBOSend("/mv~/oldmv")
return

~+F::
~F::
if(EnableAPI && IsChatOpen() || EnableAPI && IsMenuOpen())
	return
if(EnableAPI && IsPlayerDriver()) {
	;~ sleep, 500
	if(AutoEnableEngine && IsVehicleEngineEnabled()) {
		KBOSend("/cveh motor")
		}
	if(AutoEnableLights && IsVehicleLightEnabled()) {
		KBOSend("/cveh licht")
		}
	CarLocked := 1
	Sleep, 1000
	}
return

;############################################################################################################################################################# Timer
TruckTimer:
if(LoginState = "-1" || !EnableAcceptFF || !EnableAPI || IsWinActive("gta_sa.exe") = false)
	return
ActiveVehicle := GetVehicleModelId()
if(inarray(ActiveVehicle, TruckerList)) {
	if(!TruckR2)
		TruckR3 := IsPlayerInRange3D("-1804", "908", "25", "600")
	if(OnValueChange(TruckR3, "TruckKeyR3")) {
		if(TruckR3) {
			SetTimer, TruckTimer, 5000
			;~ KBOSend("/echo R3 betreten")
			} else {
			SetTimer, TruckTimer, 10000
			}
		return
		}
	if(!TruckR1)
		TruckR2 := IsPlayerInRange3D("-1804", "908", "25", "300")
	if(OnValueChange(TruckR2, "TruckKeyR2")) {
		if(TruckR2) {
			SetTimer, TruckTimer, 3000
			;~ KBOSend("/echo R2 betreten")
			} else {
			SetTimer, TruckTimer, 5000
			}
		return
		}
	if(!TruckR0)
		TruckR1 := IsPlayerInRange3D("-1804", "908", "25", "100")
	if(OnValueChange(TruckR1, "TruckKeyR1")) {
		if(TruckR1) {
			SetTimer, TruckTimer, 200
			;~ KBOSend("/echo R1 betreten")
			} else {
			SetTimer, TruckTimer, 3000
			}
		return
		}
	TruckR0 := IsPlayerInRange3D("-1804", "908", "25", "3")
	if(OnValueChange(TruckR0, "TruckKeyR0") && TruckR0) {
		KBOSend("/foodload~[InputMode][Wait 200]{esc}")
		}
	} else {
	SetTimer, TruckTimer, 15000
	}
return
RSSFeed:
if(LoginState = "-1" || !EnableRSSFeed || IsWinActive("gta_sa.exe") = false)
	return
OldFeedArray := NewFeedArray
NewFeedArray := RSS_GetFeed()
if(!OldFeedArray)
	return
ForenCalls := false
RSSArr := RSS_ArrayDifference(NewFeedArray, OldFeedArray)
Loop, % RSSArr.MaxIndex()
	{
	ForenCalls := true
	KBOSend("/echo Aktivität im Thread #" A_Index ": {74e1ed}" RSSArr[A_Index]["title"], 300)
	}
if(ForenCalls) {
	if(RSSArr.MaxIndex() = 1) {
		KBOSend("/echo Öffne den Thread mit ""/Forum""")
		} else {
		KBOSend("/echo Öffne den Thread mit ""/Forum (1 - " RSSArr.MaxIndex() ")""")
		}
	}
return

1STimer:
if(LoginState = "-1")
	return
if(!ProcessStatus("gta_sa.exe"))
	return
GetChatLine(0, FunktionsChat1)
if(InStr(FunktionsChat1, "#: Funktionstest 1"))
	SendInput, {F6}/echo Ja %VarIsPlayerDriver% %VarIsPlayerInAnyVehicle% %VarGetPlayerWeaponID% %CarLocked%{enter}
if(kGetFlagPos) {
	FlagPosIndex += 1
	if(FlagPosIndex >= 11) {
		FlagPosIndex := 0
		KBOSend("/GetFlagPos")
		}
	}
if(EnableAPI) {
	if(AutoSwitchGun && VarIsPlayerInAnyVehicle && !VarIsPlayerDriver && IsWinActive("gta_sa.exe")) {
		if(VarGetPlayerWeaponID = 0 || VarGetPlayerWeaponID = 1) {
			Sleep, 1000
			VarGetPlayerWeaponID := GetPlayerWeaponID()
			if(VarGetPlayerWeaponID = 0 || VarGetPlayerWeaponID = 1) {
				if(IsVehicleCar() || IsVehicleBike() && IsWinActive("gta_sa.exe")) {
					GetPlayerWeaponName("5", AutoWeapon1, 60)
					GetPlayerWeaponName("4", AutoWeapon2, 60)
					VarGetPlayerWeaponTotalClip5 := GetPlayerWeaponTotalClip("5")
					VarGetPlayerWeaponTotalClip4 := GetPlayerWeaponTotalClip("4")
					if(AutoWeapon1 = "M4" && VarGetPlayerWeaponTotalClip5 > 50 && ActivePremium) {
						DownTicks := 2
						} else if(AutoWeapon1 = "AK-47" && VarGetPlayerWeaponTotalClip5 > 50 && ActivePremium) {
						DownTicks := 3	
						} else if(AutoWeapon2 = "MP5" && VarGetPlayerWeaponTotalClip4 > 50) {
						DownTicks := 1
						} else {
						DownTicks := 0
						}
					if(DownTicks) {
						KBOSend("/swapgun")
						Sleep, 500
						SendInput, {Down %DownTicks%}{enter}
						Sleep, 500
						}
					}
				}
			}
		}
	;~ if(OnValueChange(A_IsSuspended, "SuspendKey")) {
		;~ KBOSend("/echo Suspended-Wert: " A_IsSuspended)
		;~ }
	}
if(EnableLSDOverlay && LSDIndex >= 1) {
	LSDIndex -= 1
	if(EnableAPI) {
		if(!LSDOverlayCreate) {
			LSDOverlay := TextCreate(,,,, CalcScreenPos(LSDOverlayX), CalcScreenPos(,LSDOverlayY),, "LSD Timer: " LSDIndex)
			LSDOverlayLine := LineCreate(CalcScreenPos(LSDOverlayX), CalcScreenPos(,LSDOverlayY)+17, CalcScreenPos(LSDOverlayX)+LSDIndex, CalcScreenPos(,LSDOverlayY)+17)
			LSDOverlayCreate := 1
			}
		if(LSDOverlayCreate) {
			LSDTimeLeft := "LSD Timer: " LSDIndex
			TextSetString(LSDOverlay, LSDTimeLeft)
			if(LSDIndex = 60) {
				TextSetColor(LSDOverlay, "0xffffef60")
				LineSetColor(LSDOverlayLine, "0xffffef60")
				}
			if(LSDIndex = 30) {
				TextSetColor(LSDOverlay, "0xffff9d1e")
				LineSetColor(LSDOverlayLine, "0xffff9d1e")
				}
			if(LSDIndex = 10) {
				TextSetColor(LSDOverlay, "0xffff0000")
				LineSetColor(LSDOverlayLine, "0xffff0000")
				}
			LineSetPos(LSDOverlayLine, CalcScreenPos(LSDOverlayX), CalcScreenPos(,LSDOverlayY)+17, CalcScreenPos(LSDOverlayX)+LSDIndex, CalcScreenPos(,LSDOverlayY)+17)
			}
		}
	if(!LSDIsCD) {
		if(LSDIndex = LSDWarn) {
			if(EnableAPI) {
				KBOSend("/echo Nebenwirkung in " LSDWarn " Sekunden!")
				} else {
				SoundPlay, %SoundInfo%
				}
			}
		if(LSDIndex = 1) {
			if(EnableAPI) {
				KBOSend("/echo Die Nebenwirkung tritt ein!")
				} else {
				SoundPlay, %SoundInfo%
				}
			}
		}
	if(LSDIndex = 0) {
		if(LSDOverlayCreate) {
			TextDestroy(LSDOverlay)
			LineDestroy(LSDOverlayLine)
			LSDOverlayCreate := 0
			}
		LSDIsCD := 0
		}
	}
if(EnableUSEOverlay && UseIndex >= 1) {
	UseIndex -= 1
	if(EnableAPI) {
		if(!USEOverlayCreate) {
			USEOverlay := TextCreate(,,,, CalcScreenPos(USEOverlayX), CalcScreenPos(,USEOverlayY),, "/Use Timer: " UseIndex)
			USEOverlayLine := LineCreate(CalcScreenPos(USEOverlayX), CalcScreenPos(,USEOverlayY)+17, CalcScreenPos(USEOverlayX)+UseIndex, CalcScreenPos(,USEOverlayY)+17)
			USEOverlayCreate := 1
			}
		if(USEOverlayCreate) {
			USETimeLeft := "/Use Timer: " UseIndex
			TextSetString(USEOverlay, USETimeleft)
			if(UseIndex = 60) {
				TextSetColor(USEOverlay, "0xffffef60")
				LineSetColor(USEOverlayLine, "0xffffef60")
				}
			if(UseIndex = 30) {
				TextSetColor(USEOverlay, "0xffff9d1e")
				LineSetColor(USEOverlayLine, "0xffff9d1e")
				}
			if(UseIndex = 10) {
				TextSetColor(USEOverlay, "0xffff0000")
				LineSetColor(USEOverlayLine, "0xffff0000")
				}
			LineSetPos(USEOverlayLine, CalcScreenPos(USEOverlayX), CalcScreenPos(,USEOverlayY)+17, CalcScreenPos(USEOverlayX)+UseIndex, CalcScreenPos(,USEOverlayY)+17)
			}
		}
	if(UseIndex = 0) {
		if(USEOverlayCreate) {
			TextDestroy(USEOverlay)
			LineDestroy(UseOverlayLine)
			USEOverlayCreate := 0
			}
		if(!EnableAPI) {
			SoundPlay, %SoundInfo%
			}
		}
	}
if(EnableTimerOverlay && OTIndex >= 1 && OTTitle) {
	OTIndex -= 1
	if(EnableAPI) {
		if(!OTCreate) {
			OTOverlay := TextCreate(,,,, CalcScreenPos(OtherTimerX), CalcScreenPos(,OtherTimerY),, OTTitle ": " OTIndex)
			OTCreate := 1
			}
		if(OTCreate) {
			TextSetString(OTOverlay, OTTitle ": " OTIndex)
			}
		} 
	if(OTIndex = 0) {
		if(EnableAPI) {
			if(OTCreate) {
				TextDestroy(OTOverlay)
				OTCreate := 0
				}
			} else {
				SoundPlay, %SoundInfo%
			}
		OTTitle := ""
		}
	}
return

Settings:
if(LoginState = "-1")
	return
;~ If(OnValueChange(IsWinActive("gta_sa.exe"), "KeyGTAWinActive")) {
	;~ if(IsWinActive("gta_sa.exe")) {
		;~ Suspend, Off
		;~ }
	;~ }
if(!ProcessStatus("gta_sa.exe"))
	{
	EnableRaceKeys := 0
	LSDOverlayCreate := 0
	CarhealOverlayCreated := 0
	USEOverlayCreate := 0
	SetTimer, RaceKeyTimer, off
	return
	}
GoSub, HookGTA
GetChatLine(0, FunktionsChat2)
if(InStr(FunktionsChat2, "#: Funktionstest 2"))
	SendInput, {F6}/echo Ja{enter}
FormatTime, Today,, yyyy.MM.dd
IniRead, IniDate, %inipath%, Settings, Date, 0
if(IniDate != Today) {
	IniWrite, %Today%, %inipath%, Settings, Date
	TaeglicheKills := 0
	TaeglicheDeaths := 0
	SaveIni()
	LoadIni()
	}
if(EnableAPI) {
	VarIsPlayerDriver := IsPlayerDriver()
	VarIsPlayerInAnyVehicle := IsPlayerInAnyVehicle()
	VarGetPlayerWeaponID := GetPlayerWeaponID()
	
	;~ if(!A_IsSuspended) {
		;~ if(IsChatOpen()) {
			;~ Suspend, On
			;~ } else {
			;~ Suspend, Off
			;~ }
		;~ }
	
	if(CarLocked && !VarIsPlayerDriver)
		CarLocked := 0
	if(VarIsPlayerDriver && !CarLocked) {
		if(RegStr(ChatOutput, "INFO: Motor ausgeschaltet."))
			Sleep, 3000
		if(IsVehicleLightEnabled() = 0 && AutoEnableLights && IsPlayerDriver())
			KBOSend("/cveh licht")
		if(IsVehicleEngineEnabled() = 0 && AutoEnableEngine && IsPlayerDriver())
			KBOSend("/cveh motor")
		}
		
	if(!VarIsPlayerInAnyVehicle && CarhealOverlayCreated) {
		CarhealOverlayCreated := 0
		TextDestroy(CarhealOverlay)
		}
		
	
	if(VarIsPlayerInAnyVehicle) {
		Carheal := RegExReplace(GetVehicleHealth(), "\.\d+")
		if(!CarhealOverlayCreated && EnableCarhealOverlay) {
			CarhealOverlay := TextCreate(,,,, CalcScreenPos(CarOverlayX), CalcScreenPos(,CarOverlayY),, "Carheal: " Carheal)
			CarhealOverlayCreated := 1
			}
		if(CarhealOverlayCreated && Carheal != "-1") {
			TextSetString(CarhealOverlay, "Carheal: " Carheal)
			if(Carheal > 700)
				TextSetColor(CarhealOverlay, "0xFF45ff30")
			if(Carheal <= 700 && Carheal > 400)
				TextSetColor(CarhealOverlay, "0xffff9d1e")
			if(Carheal <= 400)
				TextSetColor(CarhealOverlay, "0xffff0000")
			}
		}
	}
return

UpdateMapOverlay:
if(!MapOverlay)
	return
KbOPlayerPos(Positions)
ActiveMapPlayerPosX := CalcActiveMap(Positions[3],, ActivePlayerSize)
ActiveMapPlayerPosY := CalcActiveMap(,Positions[4], ActivePlayerSize)
if(MapOverlay)
	ImageSetPos(ActivePlayer, CalcScreenPos(ActiveMapPlayerPosX), CalcScreenPos(,ActiveMapPlayerPosY))
return

ChatLabel:
LatestChat(ChatOutput)
if(!ChatOutput)
	return
if(LoginState = "-1")
	return
if(RegStr(ChatOutput, "INFO: Gib /friedhof ein, um zu sehen wie lange du noch auf dem Friedhof bist.")) {
	LoadIni()
	GesamteDeaths += 1
	TaeglicheDeaths += 1
	StreakKills := 0
	LSDIsCD := 1
	LSDIndex := 1
	SaveIni()
	}
if(RegStr(ChatOutput, "Connecting to 195.201.70.37:7777...")) {
	GoSub, DebugVisualLabel
	Suspend, On
	}
if(RegStr(ChatOutput, "SERVER: Willkommen ") && !InStr(ChatOutput, "zurück")) {
	Suspend, Off
	Temp := StrSplit(ChatOutput, " ")
	UserName := Temp[Temp.MaxIndex()]
	IniWrite, %UserName%, %inipath%, Settings, UserName
	GoSub, EmergencyHook
	}
if(RegStr(ChatOutput, "Du hast ein Verbrechen begangen ( Vorsätzlicher Mord ). Reporter: Anonym.") || RegStr(ChatOutput, "SERVER: Du hast gerade einen Mord begangen. Achtung!") || RegStr(ChatOutput, "GANGWAR: Du hast einen Feind ausgeschaltet.") || RegStr(ChatOutput, "CASINO-EROBERUNG: Du hast einen Feind ausgeschaltet.") || RegStr(ChatOutput, "CRACKFESTUNG: Du hast einen Feind ausgeschaltet.") || RegStr(ChatOutput, "Du hast ein Verbrechen begangen ( Fahrerflucht ). Reporter: Anonym.") || RegStr(ChatOutput, "[" UserName " hat ", "getötet | Grund: Blacklisted]") || SimKill) {
	if(SimKill) {
		SimKill := ""
		StreakKills -= 1
		GesamteKills -= 1
		TaeglicheKills -= 1
		}
	SaveIni()
	LoadIni()
	
	StreakKills += 1
	GesamteKills += 1
	TaeglicheKills += 1
	
	if(DisableKilltrigger > 0) {
		DisableKilltrigger -= 1
		SoundPlay, %SoundInfo%
		} else {
		KillTextArray := []
		Loop, %AnzKillbinds%
			{
			if(KillbindText%A_Index%)
				KillTextArray.Push(KillbindText%A_Index%)
			}
		KillTextCounter := KillTextArray.MaxIndex()
		if(KillTextCounter >= 1) {
			if(KillTextCounter != 1) {
				Random, RandomKillText, 1, %KillTextCounter%
				While(RandomKillText = EarlierRandomKillText)
					Random, RandomKillText, 1, %KillTextCounter%
				EarlierRandomKillText := RandomKillText
				if(EnableKillbinds)
					KBOSend(KillTextArray[RandomKillText],, 0)
					else
					SoundPlay, %SoundInfo%
				} else {
				if(EnableKillbinds)
					KBOSend(KillTextArray[1],, 0)
					else
					SoundPlay, %SoundInfo%
				}
			}
		}
	SaveIni()
	}
if(RegStr(ChatOutput, "AGENTUR: Der Auftraggeber wünscht einen Beweis für den Mord, bitte lade diesen über den Laptop hoch.")) {
	SendInput, {F8}
	}
if(RegStr(ChatOutput, "AGENTUR: Du hast den Auftrag an ", " erfüllt (Verdienst ")) {
	DisableKilltrigger := 1
	Pos := RegExMatch(ChatOutput, "Ui)Auftrag an (.*) erfüllt", HitCon_Name)
	HitCon_Name := SubStr(HitCon_Name, 12, -8)
	}
if(RegStr(ChatOutput, "<< Ein Auftragskiller hat ein Mitglied", "getötet. Übrig: ", ">>") || RegStr(ChatOutput, "* Achtung: Auf dieser Fraktion liegt kein Gruppenauftrag mehr! *")) {
	DisableKilltrigger := 1
	}
if(RegStr(ChatOutput, "HQ: Gute Arbeit Agent", "Ihre Entlohnung von", "wird Ihnen zum Zahltag gutgeschrieben.")) {
	DisableKilltrigger := 1
	SendInput, {F8}
	}
if(HitCon_Name && RegStr(ChatOutput, "Screenshot Taken - sa-mp-", ".png")) {
	Pos := RegExMatch(ChatOutput, "Ui)sa-mp-\d+\.png", ScreenName)
	FormatTime, ScreenDate,, yyyy.MM.dd
	NewScreenName := "Hit - " ScreenDate " - " SubStr(ScreenName, 7, -4) " - " HitCon_Name ".png"
	sleep, 3000
	FileCopy, %A_MyDocuments%\GTA San Andreas User Files\SAMP\screens\%ScreenName%, %A_MyDocuments%\GTA San Andreas User Files\SAMP\screens\%NewScreenName%
	HitCon_Name := ""
	}
if(RegStr(ChatOutput, "INFO: Die Verarbeitung des Eisenerzes dauert 3 Minuten.") && !OTTitle) {
	OTIndex := 180
	OTTitle := "Waffenfabrik"
	}
if(RegStr(ChatOutput, ">> Systemalarm wurde ausgelöst...") && !OTTitle) {
	OTIndex := 1800
	OTTitle := "C4-Diebstahl"
	}
if(RegStr(ChatOutput, "Die Maske hält 20 Minuten, mit /maskinfo kannst du sehen wie viel Zeit verbleibt.") && !OTTitle) {
	OTIndex := 1200
	OTTitle := "Maske"
	}
if(RegStr(Chatoutput, "Du hast die Sturmhaube ausgezogen und bist somit wieder sichtbar.") && OTIndex && OTTitle = "Maske") {
	OTIndex := 1
	}
if(RegStr(ChatOutput, "Du hast LSD Pillen eingenommen (+150HP für wenige Sekunden).")) {
	LSDIndex := 90
	LSDIsCD := 0
	}
if(RegStr(ChatOutput, "Du hast 2g Hawaiian Green benutzt!") || RegStr(ChatOutput, "Du hast einen Donut gegessen (+80hp)!") || RegStr(ChatOutput, "Du hast 20g Acapulco Gold benutzt!") || RegStr(ChatOutput, "Du hast einen Brownie benutzt")) {
	if(InStr(ChatOutput, "Donut")) {
		UseIndex := 45
		}
	if(InStr(ChatOutput, "Green")) {
		UseIndex := 45
		}
	if(InStr(ChatOutput, "Acapulco Gold")) {
		UseIndex := 60
		}
	if(InStr(ChatOutput, "Brownie")) {
		UseIndex := 60
		LSDIndex := 240
		LSDIsCD := 1
		}
	}
if(RegStr(ChatOutput, "HQ:", "hat", "Wantedpunkte und somit Wantedlevel") && valAdd5WP) {
	valAdd5WP := ""
	Pos := RegExMatch(ChatOutput, "^HQ: (\S*) hat (\d*) Wantedpunkte und somit Wantedlevel: \d*\, over\.", AddWPRegEx)
	if(AddWPRegEx2 < 40) {
		KBOSend("/su " AddWPRegEx1 " " (AddWPRegEx2 >= 35 ? "40" : AddWPRegEx2 + 5) " +5 Flucht")
		}
	}
if(RegStr(ChatOutput, "Der LSD Rausch ist nun vorbei und die Nebenwirkung tritt ein (15HP)!")) {
	if(ActionOnLSDText) {
		KBOSend(ActionOnLSDText,,,, "1")
		}
	LSDIndex := 30
	LSDIsCD := 1
	}
if(RegStr(ChatOutput, "UNTERGRUND: Das Starten der LSD-Produktion hat den Einfluss deiner Fraktion im Untergrund steigen lassen") && LoginState) {
	Bobo_AddObj("1")
	}
if(RegStr(ChatOutput, "INFO: ", "hat eine Hawaiian Green Plantage angelegt.", UserName) && LoginState) {
	Bobo_AddObj("2")
	}
if(RegStr(ChatOutput, "INFO: ", "hat eine Acapulco Gold Plantage angelegt.", UserName) && LoginState) {
	Bobo_AddObj("3")
	}
if(RegStr(ChatOutput, "UNTERGRUND: Das Gießen der Plantage hat den Einfluss deiner Fraktion im Untergrund steigen lassen") && LoginState) {
	Bobo_AddCare("1")
	}
if(RegStr(ChatOutput, "UNTERGRUND: Das Düngen der Plantage hat den Einfluss deiner Fraktion im Untergrund steigen lassen") && LoginState) {
	Bobo_AddCare("2")
	}
if(RegStr(ChatOutput, "LSD: " UserName " hat den Ammoniak in einem der LSD-Labore nachgefüllt.") && LoginState) {
	Bobo_AddCare("3")
	}
if(RegStr(ChatOutput, "LSD: " UserName " hat die Natronlauge in einem der LSD-Labore nachgefüllt.") && LoginState) {
	Bobo_AddCare("4")
	}
if(RegStr(ChatOutput, "ACHTUNG: Dein Fang scheint sich zu wehren, drücke die Tasten um stärker zu ziehen!")) {
	SoundPlay, %SoundInfo%
	KBOSend("/ame Hat etwas am Haken")
	}
if(varSetMoney && RegStr(ChatOutput, "Level:", "Bargeld:", "Bank:")) {
	Pos := RegExMatch(ChatOutput, "Ui)Bargeld:\[.*\]", GeldMatch)
	GeldMatch := SubStr(GeldMatch, 11, -1)
	StringReplace, GeldMatch, GeldMatch, .,, All
	KBOSend("/bankmenu")
	sleep, 200
	if(GeldMatch > varSetMoney) {
		SendInput, {enter}
		varNewMoney := GeldMatch - varSetMoney
		} else {
		SendInput, {esc}
		varNewMoney := varSetMoney - GeldMatch
		}
		sleep, 200
		SendInput, %varNewMoney%{enter}
	varSetMoney := ""
	}
if(varHWD && RegStr(ChatOutput, "FEHLER: /housewithdraw [Betrag zwischen 1 -")) {
	Pos := RegExMatch(ChatOutput, "Ui)\d+\]$", varHWDMoney)
	if(SubStr(varHWDMoney, 1, -1))
		KBOSend("/housewithdraw " SubStr(varHWDMoney, 1, -1))
	varHWD := ""
	}
Loop, %AnzAutonom%
	ChatAutonom(ChatOutput, AutonomReact%A_Index%, AutonomAction%A_Index%)
if(RegStr(ChatOutput, "Momentanes Wantedlevel: ", " | Wantedpunkte: ") && AutoSendWPs) {
	Pos := RegExMatch(ChatOutput, "Wantedpunkte: \d+", GotWPs)
	GotWPs := SubStr(GotWPs, 15)
	KBOSend("/" vsChat " Habe " GotWPs " Wantedpunkte erhalten in [Zone] ([City])!")
	}
if(EnableAPI) {
	if(RegStr(ChatOutput, "Während des AFK-Modus geht deine Zeit zum Zahltag nicht mehr hoch.")) {
		VarIsPlayerDriver := IsPlayerDriver()
		VarIsPlayerInAnyVehicle := IsPlayerInAnyVehicle()
		if(AutoEnableEngine && VarIsPlayerInAnyVehicle && VarIsPlayerDriver) {
			if(IsVehicleEngineEnabled())
				SendChat("/cveh motor")
			}
		if(AutoEnableLights && VarIsPlayerInAnyVehicle && VarIsPlayerDriver) {
			if(IsVehicleLightEnabled())
				SendChat("/cveh licht")
			}
		}
	
	if(VarIsPlayerDriver) {
		If(RegStr(ChatOutput, "* Das Fraktionsfahrzeug kann nicht bewegt werden, da eine Parkkralle angeheftet wurde.")
			|| RegStr(ChatOutput, "* In der Werkstatt kann der Motor nicht gestartet werden.")
			|| RegStr(ChatOutput, "* Der Motor kann nicht gestartet werden, da der Tank leer ist!")
			|| RegStr(ChatOutput, "* Das Fahrzeug kann nicht bewegt werden, da eine Parkkralle angeheftet wurde.")
			|| RegStr(ChatOutput, "DIEBSTAHL: Das Fahrzeug wurde ausgeschlachtet und muss von einem Mechaniker repariert werden. (/mechaniker)")
			|| RegStr(ChatOutput, "* Der Motor kann nicht gestartet werden, da er defekt ist!")
			|| RegStr(ChatOutput, "* Der Motor springt nicht an...")
			|| RegStr(ChatOutput, "INFO: Motor ausgeschaltet.")
			|| RegStr(ChatOutput, "|____ VIELEN DANK FÜR IHR VERTRAUEN IN UNSERE TANKSTELLE ____|")) {
			CarLocked := 1
			}
		if(RegStr(ChatOutput, "SERVICE: Du hast die Gebühren in Höhe von ", " bezahlt und kannst nun wieder fahren.")
			|| RegStr(ChatOutput, "Du hast die Gebühren wegen Falschparkens bezahlt und kannst nun wieder fahren.")
			|| RegStr(ChatOutput, "INFO: Motor eingeschaltet.")
			|| RegStr(ChatOutput, "Deine Zeit zum Zahltag erhöht sich nun wieder mit der Onlinezeit.")) {
			CarLocked := 0
			}
		}
	
	if(RegStr(ChatOutput, UserName " hat das Rennen gewonnen!")) {
		KBOSend("[GameText]Winner Winner[n]Gasoline Dinner")
		}
	}

return

;############################################################################################################################################################# Hotstrings

:?:t/Forum::
:?:t/Forum 1::
:?:t/Forum 2::
:?:t/Forum 3::
:?:t/Forum 4::
:?:t/Forum 5::
:?:t/Forum 6::
:?:t/Forum 7::
:?:t/Forum 8::
:?:t/Forum 9::
:?:t/Forum 10::
Suspend, Permit
KeyReady()
if(StrLen(A_ThisLabel) = 10) {
	ForenID := 0
	} else {
	ForenID := SubStr(A_ThisLabel, 12)
	}
if(RSSArr.MaxIndex() = 1 && ForenID = 0) {
	ForenURL := RSSArr[1]["link"]
	Run, %ForenURL%
	return
	}
Loop, % RSSArr.MaxIndex()
	{
	if(A_Index = ForenID) {
		ForenURL := RSSArr[ForenID]["link"]
		Run, %ForenURL%
		}
	}
return

:?:t/SetVar::
:?:t/SetVar 1::
:?:t/SetVar 2::
:?:t/SetVar 3::
:?:t/SetVar 4::
:?:t/SetVar 5::
:?:t/SetVar 6::
:?:t/SetVar 7::
:?:t/SetVar 8::
:?:t/SetVar 9::
Suspend, Permit
KeyReady()
LoadIni()
if(StrLen(A_ThisLabel) = 11) {
	KBOSend("/echo Fehler: ""/SetVar [1 - " DeclareVarsCount "]""")
	Hotkey, enter, on
	return
	}
dvarID := SubStr(A_ThisLabel, 13)
if(dvarID > DeclareVarsCount) {
	KBOSend("/echo Fehler: ""/SetVar [1 - " DeclareVarsCount "]""")
	Hotkey, enter, on
	return
	}
Eingabeaufforderung(NewVar, "Definiere die Variable #" dvarID (DeclareVars[dvarID] ? " (" DeclareVars[dvarID] ")" : "") ": ")
if(NewVar = "-1") {
	DeclareVars[dvarID] := ""
	KBOSend("/echo Die Variable #" dvarID " wurde gelöscht.")
	} else if(NewVar != "") {
	DeclareVars[dvarID] := NewVar
	KBOSend("/echo Variable #" dvarID " wurde zu ""{[" DeclareVars[dvarID] "]}"" geändert.")
	} else {
	KBOSend("/echo Es wurde keine Eingabe erkannt.~/echo Gib zum löschen der Variable ""-1"" ein.")
	}
SaveIni()
NewVar := dvarID := ""
Hotkey, enter, on
return

:?:t/SearchLine::
Suspend, Permit
KeyReady()
Eingabeaufforderung(SearchVal, "Suchen nach: ")
if(SearchVal) {
	SearchVal := SearchLine(SearchVal)
	KBOSend("/echo Gefunden: " SearchVal)
	}
Hotkey, enter, On
return

:?:t/Bankraubmember::
Suspend, Permit
KeyReady()
if(!EnableAPI) {
	KBOSend("/echo {33CCFFAA}")
	KBOSend("/echo {33CCFFAA}Bankraubmitglieder Online:")
	KBOSend("/echo {BFC0C2FF}[NeS]nikk (Nr.: 14003)")
	} else {
	AddChatMessage("{48bcdb}")
	AddChatMessage("{48bcdb}Bankraubmitglieder Online:")
	AddChatMessage("{C0C2FF}[NeS]nikk (Nr.: 14003)")
	}
Hotkey, enter, on
return

:?:t/Killtest::
Suspend, Permit
KeyReady()
SimKill := 1
KBOSend("/echo Simulation wird durchgeführt.")
Hotkey, enter, on
return

:?:t/Killbind::
Suspend, Permit
KeyReady()
if(EnableKillbinds) {
	KBOSend("/echo Der Killbinder wurde nun {ff0000}deaktiviert{ffffff}.")
	EnableKillbinds := 0
	} else {
	KBOSend("/echo Der Killbinder wurde nun {00ff00}aktiviert{ffffff}.")
	EnableKillbinds := 1
	}
Hotkey, enter, on
return

:?:/kflagpos::
Suspend, Permit
KeyReady()
FlagPosIndex := 0
if(kGetFlagPos) {
	KBOSend("/echo Automatisches /GetFlagPos abgebrochen.")
	kGetFlagPos := 0
	} else {
	KBOSend("/echo Automatisches /GetFlagPos gestartet.~/GetFlagPos")
	kGetFlagPos := 1
	}
Hotkey, enter, on
return

:?:t/Relog::
Suspend, Permit
KeyReady()
GoSub, CloseSAMP
GoSub, StartSAMP
Hotkey, enter, on
return

:?:t/APIHook::
Suspend, Permit
KeyReady()
KBOSend("[InputMode]{F6}/echo Es wird versucht die API neu zu laden.{enter}")
GoSub, EmergencyHook
Hotkey, enter, on
return

:?:t/RaceKey::
Suspend, Permit
KeyReady()
if(!EnableAPI) {
	KBOSend("/echo API benötigt!")
	Hotkey, enter, on
	return
	}
if(EnableRaceKeys) {
	KBOSend("/echo Overlay deaktiviert!")
	EnableRaceKeys := 0
	SetTimer, RaceKeyTimer, off
	Sleep, 20
	TextDestroy(WRaceKey)
	TextDestroy(ARaceKey)
	TextDestroy(SRaceKey)
	TextDestroy(DRaceKey)
	TextDestroy(SpaceRaceKey)
	} else {
	KBOSend("/echo Overlay aktiviert!")
	EnableRaceKeys := 1
	WRaceKey := TextCreate(,,,, CalcScreenPos(RaceKeyOverlayX)-2, CalcScreenPos(,RaceKeyOverlayY)-13,, "W")
	ARaceKey := TextCreate(,,,, CalcScreenPos(RaceKeyOverlayX)-10, CalcScreenPos(,RaceKeyOverlayY),, "A")
	SRaceKey := TextCreate(,,,, CalcScreenPos(RaceKeyOverlayX), CalcScreenPos(,RaceKeyOverlayY),, "S")
	DRaceKey := TextCreate(,,,, CalcScreenPos(RaceKeyOverlayX)+10, CalcScreenPos(,RaceKeyOverlayY),, "D")
	SpaceRaceKey := TextCreate(,,,, CalcScreenPos(RaceKeyOverlayX)-10, CalcScreenPos(,RaceKeyOverlayY)+13,, "Space")
	SetTimer, RaceKeyTimer, 50
	}
Hotkey, enter, on
return

:?:t/vs::
Suspend, Permit
KeyReady()
Label_VS:
KBOSend("/" vsChat " Benötige Verstärkung in [Zone] ([City]), Fortbewegungsmittel: [Vehicle]",,1)
Hotkey, enter, on
return

:?:t/setvs::
Suspend, Permit
KeyReady()
Eingabeaufforderung(vsChat, "In welchen Chat soll /vs senden?", "/")
if(vsChat) {
	IniWrite, %vsChat%, %inipath%, Settings, vsChat
	KBOSend("/echo Verstärkung wird nun den den ""/" vsChat """-Chat gerufen")
	}
Hotkey, enter, on
return

:?:t/NoMath::
:?:t/Math::
Suspend, Permit
KeyReady()
Eingabeaufforderung(Math, "Rechnung: ")
if(!Math) {
	KBOSend("/echo Keine Eingabe erkannt!")
	Hotkey, enter, on
	return
	}
KBOSend("/echo " Math " = " (((MathResult := StrCalc(Math)) != "") ? floorDecimal(MathResult, 2) : "Fehler"))
Hotkey, enter, on
return

:?:t/BizData::
:?:t/BizData 9::
:?:t/BizData 10::
:?:t/BizData 11::
:?:t/BizData 12::
:?:t/BizData 13::
:?:t/BizData 14::
:?:t/BizData 15::
:?:t/BizData 16::
:?:t/BizData 17::
:?:t/BizData 21::
Suspend, Permit
KeyReady()
if(StrLen(A_ThisLabel) = "12") {
	for index, element in FlagBizName
		KBOSend("/echo ""/BizData " index """ => " element, 300)
	Hotkey, enter, on
	return
	}
ThisBiz := SubStr(A_ThisLabel, 14)
Loop, 3
	{
	1stLoop := A_Index
	Loop, 3
		{
		if(A_Index = 1)
			ThisBizFlag_%1stLoop%_%A_Index% := CalcActiveMap(FlagBiz%1stLoop%[ThisBiz][A_Index],, ActiveMarkerSize)
		if(A_Index = 2)
			ThisBizFlag_%1stLoop%_%A_Index% := CalcActiveMap(,FlagBiz%1stLoop%[ThisBiz][A_Index], ActiveMarkerSize)
		if(A_Index = 3)
			ThisBizFlag_%1stLoop%_%A_Index% := FlagBiz%1stLoop%[ThisBiz][A_Index]
		}
	}
if(EnableAPI) {
	if(ActiveMapOverlayHotkey) {
		if(!MapOverlay)
			GoSub, FullMapOverlay
		if(!ActiveMapBIZ) {
			KBOSend("/echo Es wurde ein Hotkey für die Livemap (" ActiveMapOverlayHotkey ") entdeckt.")
			;Erstellen
			Loop, 3
				FlagBox%A_Index% := ImageCreate("marker.png", CalcScreenPos(ThisBizFlag_%A_Index%_1), CalcScreenPos(,ThisBizFlag_%A_Index%_2))
			ActiveMapBIZ := 1
			} else {
			;Bewegen
			Loop, 3
				ImageSetPos(FlagBox%A_Index%, CalcScreenPos(ThisBizFlag_%A_Index%_1), CalcScreenPos(,ThisBizFlag_%A_Index%_2))
			}
		} else {
		KBOSend("/echo Für eine Map muss ein Hotkey für die Livemap festgelegt sein.")
		}
	}
KBOSend("/echo Flaggenpositionen für das BIZ: " FlagBizName[ThisBiz] "~/echo Flagge 1: " ThisBizFlag_1_3 "~/echo Flagge 2: " ThisBizFlag_2_3 "~/echo Flagge 3: " ThisBizFlag_3_3)
Hotkey, enter, on
return

:?:t/Wordmix::
Suspend, Permit
KeyReady()
Eingabeaufforderung(oString, "Folgendes Wort mischen: ")
Sleep, 200
if(oString) {
	BlockInput, On
	mString := mixchars(oString)
	KBOSend("[InputMode]{F6}/echo " oString " = " mString "{enter}")
	BlockInput, Off
	} else {
	KBOSend("/echo Es wurde keine Eingabe erkannt.")
	}
oString := mString := ""
Hotkey, enter, on
return

:?:t/ResetOverlay::
:?:t/ResetOverlay LSD::
:?:t/ResetOverlay Car::
:?:t/ResetOverlay Plant::
:?:t/ResetOverlay Cont::
:?:t/ResetOverlay Skin::
:?:t/ResetOverlay Livemap::
:?:t/ResetOverlay Race::
:?:t/ResetOverlay Use::
:?:t/ResetOverlay Timer::
Suspend, Permit
KeyReady()
if(!EnableAPI) {
	KBOSend("/echo Die Overlays sind nur mit API verfügbar.")
	Hotkey, enter, on
	return
	}
if(StrLen(A_ThisLabel) = 17) {
	KBOSend("/echo Fehler: /ResetOverlay " OverlayList)
	Hotkey, enter, on
	return
	}
LoadIni()
OverlayID := SubStr(A_ThisLabel, 19)
if(OverlayID = "LSD") {
	LSDOverlayX := A_ScreenWidth/2
	LSDOverlayY := A_ScreenHeight/2
	}
if(OverlayID = "Car") {
	CarOverlayX := A_ScreenWidth/2
	CarOverlayY := A_ScreenHeight/2
	}
if(OverlayID = "Plant" || OverlayID = "Cont") {
	BigMapX := A_ScreenWidth/2
	BigMapY := A_ScreenHeight/2
	}
if(OverlayID = "Skin") {
	SkinPosX := A_ScreenWidth/2
	SkinPosY := A_ScreenHeight/2
	}
if(OverlayID = "Livemap") {
	ActiveMapOverlayX := "10"
	ActiveMapOverlayY := "10"
	}
if(OverlayID = "Race") {
	RaceKeyOverlayX := A_ScreenWidth/2
	RaceKeyOverlayY := A_ScreenHeight/2
	}
if(OverlayID = "Use") {
	USEOverlayX := A_ScreenWidth/2
	USEOverlayY := A_ScreenHeight/2
	}
if(OverlayID = "Timer") {
	OtherTimerX := A_ScreenWidth/2
	OtherTimerY := A_ScreenHeight/2
	}
SaveIni()
KBOSend("/echo Overlay """ OverlayID """ wurde zurückgesetzt.")
Hotkey, enter, on
return

:?:t/MoveOverlay::
:?:t/MoveOverlay LSD::
:?:t/MoveOverlay Car::
:?:t/MoveOverlay Plant::
:?:t/MoveOverlay Cont::
:?:t/MoveOverlay Skin::
:?:t/MoveOverlay Livemap::
:?:t/MoveOverlay Race::
:?:t/MoveOverlay Use::
:?:t/MoveOverlay Timer::
Suspend, Permit
KeyReady()
if(!EnableAPI) {
	KBOSend("/echo Die Overlays sind nur mit API verfügbar.")
	Hotkey, enter, on
	return
	}
if(StrLen(A_ThisLabel) = 16) {
	KBOSend("/echo Fehler: /MoveOverlay " OverlayList)
	Hotkey, enter, on
	return
	}
LoadIni()
BlockInput, On
OverlayID := SubStr(A_ThisLabel, 18)
if(OverlayID = "LSD") {
	nOverlayPos := EditOverlay("LSD Timer: 90", LSDOverlayX, LSDOverlayY)
	if(nOverlayPos[1]) {
		LSDOverlayX := nOverlayPos[2]
		LSDOverlayY := nOverlayPos[3]
		}
	}
if(OverlayID = "Car") {
	nOverlayPos := EditOverlay("Carheal: 666", CarOverlayX, CarOverlayY)
	if(nOverlayPos[1]) {
		CarOverlayX := nOverlayPos[2]
		CarOverlayY := nOverlayPos[3]
		}
	}
if(OverlayID = "Plant" || OverlayID = "Cont") {
	nOverlayPos := EditOverlay("BigMap", BigMapX, BigMapY)
	if(nOverlayPos[1]) {
		BigMapX := nOverlayPos[2]
		BigMapY := nOverlayPos[3]
		}
	}
if(OverlayID = "Skin") {
	nOverlayPos := EditOverlay("Skin", SkinPosX, SkinPosY)
	if(nOverlayPos[1]) {
		SkinPosX := nOverlayPos[2]
		SkinPosY := nOverlayPos[3]
		}
	}
if(OverlayID = "Livemap") {
	nOverlayPos := EditOverlay("ActiveMap", ActiveMapOverlayX, ActiveMapOverlayY)
	if(nOverlayPos[1]) {
		ActiveMapOverlayX := nOverlayPos[2]
		ActiveMapOverlayY := nOverlayPos[3]
		}
	}
if(OverlayID = "Race") {
	nOverlayPos := EditOverlay("Race", RaceKeyOverlayX, RaceKeyOverlayY)
	if(nOverlayPos[1]) {
		RaceKeyOverlayX := nOverlayPos[2]
		RaceKeyOverlayY := nOverlayPos[3]
		}
	}
if(OverlayID = "Use") {
	nOverlayPos := EditOverlay("/Use Timer: 60", USEOverlayX, USEOverlayY)
	if(nOverlayPos[1]) {
		USEOverlayX := nOverlayPos[2]
		USEOverlayY := nOverlayPos[3]
		}
	}
if(OverlayID = "Timer") {
	nOverlayPos := EditOverlay("Waffenfabrik: 180", OtherTimerX, OtherTimerY)
	if(nOverlayPos[1]) {
		OtherTimerX := nOverlayPos[2]
		OtherTimerY := nOverlayPos[3]
		}
	}
if(nOverlayPos[1])
	SaveIni()
BlockInput, Off
Hotkey, enter, on
return

#Include Include/WPBinds.ahk

/*
BSN=	AngelPine + LV
NS=		Farm + Huhn
Pier=	BS + Docks
Glenpark=	OC Gebiet + Arena
SF=	SF + Kuh
*/

:?:t/Dealzone::
Suspend, Permit
KeyReady()
KBOSend("/echo Folgende Gebiete ergeben eine Dealzone:", 100)
KBOSend("/echo BSN = Angel Pine + Las Venturas", 100)
KBOSend("/echo Neulingsspawn = Farm + Huhn", 100)
KBOSend("/echo Pier = Bayside + LS Docks", 100)
KBOSend("/echo Glenpark = Palomino Creek + LS Arena", 100)
KBOSend("/echo San Fierro = San Fierro + Kuh")
Hotkey, enter, on
return

:?:t/join::
Suspend, Permit
KeyReady()
KBOSend("/join", 200)
KBOSend("/accept job", 200)
KBOSend("/quitjob")
Hotkey, enter, on
return

:?:t/SetKills::
Suspend, Permit
KeyReady()
Eingabeaufforderung(NewKills, "Ich habe so viele Morde (Aktuell: " GesamteKills "): ")
if(NewKills)
	IniWrite, %NewKills%, %inipath%, Kills, GesamteKills
LoadIni()
KBOSend("/echo Deine Kills wurden auf """ GesamteKills """ gesetzt.")
Hotkey, enter, on
return

:?:t/SetDeaths::
Suspend, Permit
KeyReady()
Eingabeaufforderung(NewDeaths, "Ich bin so oft gestorben (Aktuell: " GesamteDeaths "): ")
if(NewDeaths)
	IniWrite, %NewDeaths%, %inipath%, Kills, GesamteDeaths
LoadIni()
KBOSend("/echo Deine Tode wurden auf """ GesamteDeaths """ gesetzt.")
Hotkey, enter, on
return

:?:t/DefMoney::
Suspend, Permit
KeyReady()
Eingabeaufforderung(varSetMoney, "Wie viel Geld möchtest du auf der Hand haben: ")
Sleep, 200
if(EnableAPI) {
	NewMoney := GetPlayerMoney()
	KBOSend("/bankmenu")
	sleep, 500
	if(NewMoney > varSetMoney) {
		SendInput, {enter}
		varNewMoney := NewMoney - varSetMoney
		} else {
		SendInput, {esc}
		varNewMoney := varSetMoney - NewMoney
		}
		sleep, 500
		SendInput, %varNewMoney%{enter}
	varSetMoney := ""
	} else {
	if(varSetMoney)
		KBOSend("/oldstats")
	}
Hotkey, enter, on
return

:?:t/hwd::
Suspend, Permit
KeyReady()
KBOSend("/housewithdraw")
varHWD := 1
Hotkey, enter, on
return

:?:t/DebugVisual::
Suspend, Permit
KeyReady()
GoSub, DebugVisualLabel
KBOSend("/echo Overlays entfernt!")
Hotkey, enter, on
return

:?:t/GetCont::
:?:t/GetPlant::
Suspend, Permit
KeyReady()
if(!LoginState) {
	KBOSend("/echo Sie müssen für diese Funktion angemeldet sein.")
	Hotkey, enter, on
	return
	}
Bobo_GetObject()
Hotkey, enter, on
return

:?:t/p::
Suspend, Permit
KeyReady()
KBOSend("/p")
sleep, 100
if(CallinText)
	KBOSend(CallinText)
Hotkey, enter, on
return

:?:t/h::
Suspend, Permit
KeyReady()
if(CalloutText)
	KBOSend(CalloutText)
Sleep, 100
KBOSend("/h")
Hotkey, enter, on
return

:?:t/abw::
Suspend, Permit
KeyReady()
if(CallignoreText) {
	KBOSend("/p", 100)
	KBOSend(CallignoreText, 100)
	KBOSend("/h")
	}
Hotkey, enter, on
return

:?:t/PlayerData::
Suspend, Permit
KeyReady()
AskPlayerName(SearchPlayer, "ID oder Name des Spielers: ")
if(SearchPlayer) {
	Bobo_Playerdata(SearchPlayer, RegMode)
	}
Hotkey, enter, on
return

:?:t/FrakDataID::
Suspend, Permit
KeyReady()
SendOnlyID := 1
GoTo, FrakInfo
return

:?:t/FrakData::
Suspend, Permit
GetAllFrakData := 0
SendOnlyID := 0
FrakInfo:
KeyReady()
Eingabeaufforderung(FrakSearch, "Name der Fraktion: ")
if(!FrakSearch) {
	KBOSend("/echo Es wurde keine Eingabe entdeckt.")
	Hotkey, enter, on
	return
	}
FoundFrak := inarray(FrakSearch, Frak_RegEx)
if(!FoundFrak) {
	KBOSend("/echo Die Fraktion """ FrakSearch """ wurde leider nicht gefunden.")
	Hotkey, enter, on
	return
	}
KBOSend("/echo Die Mitglieder der Fraktion [" Frak_Name[FoundFrak] "] werden geladen...")
HomepageFrak(FoundFrak, SendOnlyID)
SendOnlyID := 0
GetAllFrakData := 0
Hotkey, enter, on
return

:?:t/Funktionstest::
Suspend, Permit
KeyReady()
FormatTime, tString,, yyyyMMdd
Result := BoboRequest(UserName,, "funktionstest")
if(Pos := RegExMatch(Result, "Ui)^\Q" tString "\E")) {
	KBOSend("/echo Verbindungstest mit Homepage -> Erfolgreich")
	verifyString := SubStr(Result, -9)
	KBOSend("/echo Bestätigungscode: " verifyString)
	Sleep, 1000
	if(Found := SearchLine("Bestätigungscode: " verifyString, false, true)) {
		KBOSend("/echo chatlog gefunden und lesbar.")
		} else {
			KBOSend("/echo Chatlog wurde nicht gefunden oder ist nicht lesbar.")
		}
	} else {
	KBOSend("/echo Verbindungstest mit Homepage -> Fehlgeschlagen")
	}
Hotkey, enter, on
return

:?:t/Clear::
Suspend, Permit
KeyReady()
cfgpath := A_MyDocuments "\GTA San Andreas User Files\SAMP\sa-mp.cfg"
FileRead, cfg, %cfgpath%
stdPageSize := 10
Loop, parse, cfg, `n, `r
	{
	if(InStr(A_LoopField, "pagesize=")) {
		Pos := RegExMatch(A_LoopField, "Ui)^\Qpagesize=\E\D*(\d*)\D*$", PageMatch)
		if(PageMatch1) {
			stdPageSize := PageMatch1
			}
		}
	}
Loop, %stdPageSize%
	{
	KBOSend("/echo \[T]/", 300)
	}
Hotkey, enter, on
return

:?:t/Truckdata::
Suspend, Permit
KeyReady()
TruckerFeed := GetTruckData(TruckingChoice)
Eingabeaufforderung(varTruckerLevelMin, "Von Truckerlevel: ")
if(!varTruckerLevelMin) {
	KBOSend("/echo Keine Eingabe erkannt!")
	Hotkey, enter, on
	return
	}
Eingabeaufforderung(varTruckerLevelMax, "Bis Truckerlevel: ")
if(!varTruckerLevelMax)
	varTruckerLevelMax := "10"
KBOSend("/echo Truckermissionen sortiert nach: " TruckSortArr[TruckingChoice], 300)
Loop, % TruckerFeed.MaxIndex()
	{
	if(TruckerFeed[A_Index]["level"] >= varTruckerLevelMin && TruckerFeed[A_Index]["level"] <= varTruckerLevelMax) {
		TruckerText1 := "{74e1ed}" TruckerFeed[A_Index]["titel"] "{" ChatColor["white"] "}"
		TruckerText2 := "Level: " TruckerFeed[A_Index]["level"]
		TruckerText3 := "{8eed74}Erf: " TruckerFeed[A_Index]["erfahrung"] "{" ChatColor["white"] "}"
		TruckerText4 := "Preis: $" TruckerFeed[A_Index]["einkaufspreis"]
		TruckerText5 := "Gewinn: $" TruckerFeed[A_Index]["gewinn"]
		KBOSend("/echo " TruckerText1 " " TruckerText2 " " TruckerText3 " " TruckerText4 " " TruckerText5, 300)
		}
	}
Hotkey, enter, on
return

;~ ##########################################
;~ ############ Own Functions ###############
;~ ##########################################

CreateHotkey(ThisHotkey, mode=1) {
	global
	if(mode) {
		if(ThisHotkey = "keybinds" || ThisHotkey = "all") {
			Loop, %AnzKeybinds%
				{
				if(KeybindHotkey%A_Index% != "")
					Hotkey, % KeybindHotkey%A_Index%, Label_for_all_Hotkeys, on
				}
			}
		if(ThisHotkey = "textbinds" || ThisHotkey = "all") {
			Loop, %AnzTextbinds%
				{
				if(TextbindReact%A_Index% != "" && TextbindAct%A_Index% != "")
					Hotstring(":X?:" TextbindReact%A_Index%, "HotstringLabel" A_Index, "On")
				}
			}
		if(ThisHotkey = "einstellungen" || ThisHotkey = "all") {
			if(MouseButton1)
				Hotkey, XButton1, Label_for_all_Hotkeys, on
			if(MouseButton2)
				Hotkey, XButton2, Label_for_all_Hotkeys, on
			if(HotkeyToggle)
				Hotkey, %HotkeyToggle%, Label_ToggleKey, on
			if(VSHotkey)
				Hotkey, %VSHotkey%, Label_VS, on
			}
		if(ThisHotkey = "frakbinds" || ThisHotkey = "all") {
			Loop, %AnzFrakbinds%
				{
				if(FrakHotkey%A_Index% != "")
					Hotkey, % FrakHotkey%A_Index%, Label_for_all_Hotkeys, on
				}
			}
		if(ThisHotkey = "einstellungen2" || ThisHotkey = "all") {
			if(ActiveMapOverlayHotkey)
				Hotkey, %ActiveMapOverlayHotkey%, FullMapOverlay, on
			}
		} else { ;###########################################################################################
		if(ThisHotkey = "keybinds" || ThisHotkey = "all") {
			Loop, %AnzKeybinds%
				{
				if(KeybindHotkey%A_Index% != "")
					Hotkey, % KeybindHotkey%A_Index%, Label_for_all_Hotkeys, off
				}
			}
		
		if(ThisHotkey = "textbinds" || ThisHotkey = "all") {
			Loop, %AnzTextbinds%
				{
				if(TextbindReact%A_Index% != "" && TextbindAct%A_Index% != "")
					Hotstring(":X?:" TextbindReact%A_Index%, "HotstringLabel" A_Index, "Off")
				}
			}
		
		if(ThisHotkey = "einstellungen" || ThisHotkey = "all") {
			if(MouseButton1)
				Hotkey, XButton1, Label_for_all_Hotkeys, off
			if(MouseButton2)
				Hotkey, XButton2, Label_for_all_Hotkeys, off
			if(HotkeyToggle)
				Hotkey, %HotkeyToggle%, Label_ToggleKey, off
			if(VSHotkey)
				Hotkey, %VSHotkey%, Label_VS, off
			}
		if(ThisHotkey = "frakbinds" || ThisHotkey = "all") {
			Loop, %AnzFrakbinds%
				{
				if(FrakHotkey%A_Index% != "")
					Hotkey, % FrakHotkey%A_Index%, Label_for_all_Hotkeys, off
				}
			}
		if(ThisHotkey = "einstellungen2" || ThisHotkey = "all") {
			if(ActiveMapOverlayHotkey)
				Hotkey, %ActiveMapOverlayHotkey%, FullMapOverlay, off
			}
		}
	}
LoadStartUp(LoginName, LoginPass=0, UoG=0) {
	global FrakbindText1, FrakbindText2, FrakbindText3, FrakbindText4, FrakbindText5, FrakbindText6, FrakbindText7, FrakbindText8, FrakbindText9, FrakbindText10
	if(UoG) {
		CheckLogin := Bobo_Login(LoginName, LoginPass)
		} else {
		CheckLogin := Bobo_Login(LoginName)
		}
	return CheckLogin
	}
InitStartUp(ProgTask) {
	IniRead, ProgPath, %inipath%, Einstellungen, Prog%ProgTask%Path, 0
	if(ProgPath != 0) {
		SplitPath, ProgPath, ProgDat
		If(!ProcessStatus(ProgDat))
			Run, %ProgPath%
		}
	return
	}
LoadIni() {
	global
	IniRead, UserName, %inipath%, Settings, UserName, NoName
	IniRead, StreakKills, %inipath%, Kills, StreakKills, 0
	IniRead, GesamteKills, %inipath%, Kills, GesamteKills, 0
	IniRead, GesamteDeaths, %inipath%, Kills, GesamteDeaths, 0
	IniRead, TaeglicheKills, %inipath%, Kills, TaeglicheKills, 0
	IniRead, TaeglicheDeaths, %inipath%, Kills, TaeglicheDeaths, 0
	IniRead, StreakKills, %inipath%, Kills, StreakKills, 0
	IniRead, EnableAPI, %inipath%, Settings, EnableAPI, 0
	
	
	IniRead, chatlogpath, %inipath%, Settings, chatlogpath, %A_MyDocuments%\GTA San Andreas User Files\SAMP\chatlog.txt
	IniRead, AutoEnableEngine, %inipath%, Settings, AutoEnableEngine, 0
	IniRead, vsChat, %inipath%, Settings, vsChat, f
	
	Loop, %AnzKillbinds%
		{
		IniRead, KillbindText%A_Index%, %inipath%, Killbinds, KillbindText%A_Index%, 0
		if(KillbindText%A_Index% = "0")
			KillbindText%A_Index% := ""
		}
	
	Loop, %AnzKeybinds%
		{
		IniRead, KeybindHotkey%A_Index%, %inipath%, Keybinds, KeybindHotkey%A_Index%, ERROR
		if(KeybindHotkey%A_Index% = "ERROR")
			KeybindHotkey%A_Index% := ""
		IniRead, KeybindText%A_Index%, %inipath%, Keybinds, KeybindText%A_Index%, 0
		if(KeybindText%A_Index% = "0")
			KeybindText%A_Index% := ""
		}
	
	Loop, %AnzTextbinds%
		{
		IniRead, TextbindReact%A_Index%, %inipath%, Textbinds, TextbindReact%A_Index%, ERROR
		if(TextbindReact%A_Index% = "ERROR")
			TextbindReact%A_Index% := ""
		IniRead, TextbindAct%A_Index%, %inipath%, Textbinds, TextbindAct%A_Index%, ERROR
		if(TextbindAct%A_Index% = "ERROR")
			TextbindAct%A_Index% := ""
		}
	
	Loop, %AnzAutonom%
		{
		IniRead, AutonomReact%A_Index%, %inipath%, Autonom, AutonomReact%A_Index%, 0
		if(AutonomReact%A_Index% = "0")
			AutonomReact%A_Index% := ""
		IniRead, AutonomAction%A_Index%, %inipath%, Autonom, AutonomAction%A_Index%, 0
		if(AutonomAction%A_Index% = "0")
			AutonomAction%A_Index% := ""
		}
	
	Loop, %AnzFrakbinds%
		{
		IniRead, FrakHotkey%A_Index%, %inipath%, Frakbinds, FrakHotkey%A_Index%, ERROR
		if(FrakHotkey%A_Index% = "ERROR")
			FrakHotkey%A_Index% := ""
		}
	Loop, %DeclareVarsCount%
		{
		IniRead, DV%A_Index%, %inipath%, Values, DeclareVars%A_Index%, ERROR
		if(DV%A_Index% = "ERROR")
			DV%A_Index% := ""
		DeclareVars[A_Index] := DV%A_Index%
		}
	
	IniRead, FraktionID, %inipath%, Einstellungen, FraktionID, 0
	IniRead, AutoEnableEngine, %inipath%, Einstellungen, AutoEnableEngine, 0
	IniRead, AutoEnableLights, %inipath%, Einstellungen, AutoEnableLights, 0
	IniRead, AutoSendWPs, %inipath%, Einstellungen, AutoSendWPs, 0
	
	IniRead, MouseButton1, %inipath%, Einstellungen, MouseButton1, 0
	if(MouseButton1 = 0)
		MouseButton1 := ""
	IniRead, MouseButton2, %inipath%, Einstellungen, MouseButton2, 0
	if(MouseButton2 = 0)
		MouseButton2 := ""
	
	IniRead, CallinText, %inipath%, Einstellungen, CallinText, 0
	if(!CallinText)
		CallinText := ""
	IniRead, CalloutText, %inipath%, Einstellungen, CalloutText, 0
	if(!CalloutText)
		CalloutText := ""
	IniRead, CallignoreText, %inipath%, Einstellungen, CallignoreText, 0
	if(!CallignoreText)
		CallignoreText := ""
	
	IniRead, ActionOnLSDText, %inipath%, Einstellungen, ActionOnLSDText, ERROR
	if(ActionOnLSDText = "ERROR")
		ActionOnLSDText := ""
	
	IniRead, HotkeyToggle, %inipath%, Einstellungen, HotkeyToggle, ERROR
	if(HotkeyToggle = "ERROR")
		HotkeyToggle := ""
	
	IniRead, SAMPPath, %inipath%, Einstellungen, SAMPPath, 0
	
	IniRead, ActivePremium, %inipath%, Einstellungen, ActivePremium, 0
	IniRead, AutoSwitchGun, %inipath%, Einstellungen, AutoSwitchGun, 0
	IniRead, VSHotkey, %inipath%, Einstellungen, VSHotkey, ERROR
	if(VSHotkey = "ERROR")
		VSHotkey := ""
	IniRead, ActiveMapOverlayHotkey, %inipath%, Einstellungen, ActiveMapOverlayHotkey, ERROR
	if(ActiveMapOverlayHotkey = "ERROR")
		ActiveMapOverlayHotkey := ""
	
	IniRead, SaveHistory, %inipath%, Einstellungen, SaveHistory, 0
	IniRead, EnableCarhealOverlay, %inipath%, Einstellungen, EnableCarhealOverlay, 1
	IniRead, EnableLSDOverlay, %inipath%, Einstellungen, EnableLSDOverlay, 1
	IniRead, EnableUSEOverlay, %inipath%, Einstellungen, EnableUSEOverlay, 1
	IniRead, EnableTimerOverlay, %inipath%, Einstellungen, EnableTimerOverlay, 1
	IniRead, EnableHitOverlay, %inipath%, Einstellungen, EnableHitOverlay, 0 ;Not in Use
	IniRead, EnableHitSound, %inipath%, Einstellungen, EnableHitSound, 0
	IniRead, EnableRSSFeed, %inipath%, Einstellungen, EnableRSSFeed, 0
	IniRead, EnableAcceptFF, %inipath%, Einstellungen, EnableAcceptFF, 0
	IniRead, EnableACH, %inipath%, Einstellungen, EnableACH, 0
	IniRead, HitSound, %inipath%, Einstellungen, HitSound, *-1
	
	IniRead, BigMapX, %inipath%, Overlay, BigMapX, 570
	IniRead, BigMapY, %inipath%, Overlay, BigMapY, 295
	IniRead, SkinPosX, %inipath%, Overlay, SkinPosX, 770
	IniRead, SkinPosY, %inipath%, Overlay, SkinPosY, 380
	IniRead, HitPosX, %inipath%, Overlay, HitPosX, 200
	IniRead, HitPosY, %inipath%, Overlay, HitPosY, 80	
	
	IniRead, TruckingChoice, %inipath%, Einstellungen, TruckingChoice, 1
	
	IniRead, CarOverlayX, %inipath%, Overlay, CarOverlayX, 180
	IniRead, CarOverlayY, %inipath%, Overlay, CarOverlayY, 480
	IniRead, LSDOverlayX, %inipath%, Overlay, LSDOverlayX, 180
	IniRead, LSDOverlayY, %inipath%, Overlay, LSDOverlayY, 460
	IniRead, OtherTimerX, %inipath%, Overlay, OtherTimerX, 200
	IniRead, OtherTimerY, %inipath%, Overlay, OtherTimerY, 500
	IniRead, USEOverlayX, %inipath%, Overlay, USEOverlayX, 500
	IniRead, USEOverlayY, %inipath%, Overlay, USEOverlayY, 100
	IniRead, ActiveMapOverlayX, %inipath%, Overlay, ActiveMapOverlayX, 0
	IniRead, ActiveMapOverlayY, %inipath%, Overlay, ActiveMapOverlayY, 0
	IniRead, RaceKeyOverlayX, %inipath%, Overlay, RaceKeyOverlayX, ERROR
	if(RaceKeyOverlayX = "ERROR")
		RaceKeyOverlayX := A_ScreenWidth-100
	IniRead, RaceKeyOverlayY, %inipath%, Overlay, RaceKeyOverlayY, ERROR
	if(RaceKeyOverlayY = "ERROR")
		RaceKeyOverlayY := A_ScreenHeight-200
	
	Loop, 3
		{
		IniRead, StartUpProg%A_Index%, %inipath%, Einstellungen, StartUpProg%A_Index%, 0
		IniRead, StartProgButton%A_Index%, %inipath%, Einstellungen, StartProgButton%A_Index%, Programm auswählen
		}
	return
	}
SaveIni() {
	global
	IniWrite, %UserName%, %inipath%, Settings, UserName
	IniWrite, %StreakKills%, %inipath%, Kills, StreakKills
	IniWrite, %GesamteKills%, %inipath%, Kills, GesamteKills
	IniWrite, %GesamteDeaths%, %inipath%, Kills, GesamteDeaths
	IniWrite, %TaeglicheKills%, %inipath%, Kills, TaeglicheKills
	IniWrite, %TaeglicheDeaths%, %inipath%, Kills, TaeglicheDeaths
	IniWrite, %StreakKills%, %inipath%, Kills, StreakKills
	IniWrite, %EnableAPI%, %inipath%, Settings, EnableAPI
	
	IniWrite, %chatlogpath%, %inipath%, Settings, chatlogpath
	IniWrite, %AutoEnableEngine%, %inipath%, Settings, AutoEnableEngine
	IniWrite, %vsChat%, %inipath%, Settings, vsChat
	
	Loop, %AnzKillbinds%
		IniWrite, % KillbindText%A_Index%, %inipath%, Killbinds, KillbindText%A_Index%
	
	Loop, %AnzKeybinds%
		{
		IniWrite, % KeybindHotkey%A_Index%, %inipath%, Keybinds, KeybindHotkey%A_Index%
		IniWrite, % KeybindText%A_Index%, %inipath%, Keybinds, KeybindText%A_Index%
		}
	
	Loop, %AnzTextbinds%
		{
		IniWrite, % TextbindReact%A_Index%, %inipath%, Textbinds, TextbindReact%A_Index%
		IniWrite, % TextbindAct%A_Index%, %inipath%, Textbinds, TextbindAct%A_Index%
		}
	
	Loop, %AnzAutonom%
		{
		IniWrite, % AutonomReact%A_Index%, %inipath%, Autonom, AutonomReact%A_Index%
		IniWrite, % AutonomAction%A_Index%, %inipath%, Autonom, AutonomAction%A_Index%
		}
	
	Loop, %AnzFrakbinds%
		{
		IniWrite, % FrakHotkey%A_Index%, %inipath%, Frakbinds, FrakHotkey%A_Index%
		}
	
	Loop, %DeclareVarsCount%
		{
		DV%A_Index% := DeclareVars[A_Index]
		IniWrite, % DV%A_Index%, %inipath%, Values, DeclareVars%A_Index%
		}
	
	IniWrite, %FraktionID%, %inipath%, Einstellungen, FraktionID
	IniWrite, %AutoEnableEngine%, %inipath%, Einstellungen, AutoEnableEngine
	IniWrite, %AutoEnableLights%, %inipath%, Einstellungen, AutoEnableLights
	IniWrite, %AutoSendWPs%, %inipath%, Einstellungen, AutoSendWPs
	
	IniWrite, %MouseButton1%, %inipath%, Einstellungen, MouseButton1
	IniWrite, %MouseButton2%, %inipath%, Einstellungen, MouseButton2
	
	IniWrite, %CallinText%, %inipath%, Einstellungen, CallinText
	IniWrite, %CalloutText%, %inipath%, Einstellungen, CalloutText
	IniWrite, %CallignoreText%, %inipath%, Einstellungen, CallignoreText
	
	IniWrite, %ActionOnLSDText%, %inipath%, Einstellungen, ActionOnLSDText
	
	IniWrite, %SAMPPath%, %inipath%, Einstellungen, SAMPPath
	
	IniWrite, %HotkeyToggle%, %inipath%, Einstellungen, HotkeyToggle
	IniWrite, %ActivePremium%, %inipath%, Einstellungen, ActivePremium
	IniWrite, %AutoSwitchGun%, %inipath%, Einstellungen, AutoSwitchGun
	IniWrite, %VSHotkey%, %inipath%, Einstellungen, VSHotkey
	IniWrite, %ActiveMapOverlayHotkey%, %inipath%, Einstellungen, ActiveMapOverlayHotkey
	
	IniWrite, %SaveHistory%, %inipath%, Einstellungen, SaveHistory
	IniWrite, %EnableCarhealOverlay%, %inipath%, Einstellungen, EnableCarhealOverlay
	IniWrite, %EnableLSDOverlay%, %inipath%, Einstellungen, EnableLSDOverlay
	IniWrite, %EnableUSEOverlay%, %inipath%, Einstellungen, EnableUSEOverlay
	IniWrite, %EnableTimerOverlay%, %inipath%, Einstellungen, EnableTimerOverlay
	IniWrite, %EnableHitOverlay%, %inipath%, Einstellungen, EnableHitOverlay ;Not in Use
	IniWrite, %EnableACH%, %inipath%, Einstellungen, EnableACH
	IniWrite, %EnableHitSound%, %inipath%, Einstellungen, EnableHitSound
	IniWrite, %EnableRSSFeed%, %inipath%, Einstellungen, EnableRSSFeed
	IniWrite, %EnableAcceptFF%, %inipath%, Einstellungen, EnableAcceptFF
	IniWrite, %HitSound%, %inipath%, Einstellungen, HitSound
	
	IniWrite, %TruckingChoice%, %inipath%, Einstellungen, TruckingChoice
	
	IniWrite, %CarOverlayX%, %inipath%, Overlay, CarOverlayX
	IniWrite, %CarOverlayY%, %inipath%, Overlay, CarOverlayY
	IniWrite, %LSDOverlayX%, %inipath%, Overlay, LSDOverlayX
	IniWrite, %LSDOverlayY%, %inipath%, Overlay, LSDOverlayY
	IniWrite, %OtherTimerX%, %inipath%, Overlay, OtherTimerX
	IniWrite, %OtherTimerY%, %inipath%, Overlay, OtherTimerY
	IniWrite, %USEOverlayX%, %inipath%, Overlay, USEOverlayX
	IniWrite, %USEOverlayY%, %inipath%, Overlay, USEOverlayY
	
	IniWrite, %BigMapX%, %inipath%, Overlay, BigMapX
	IniWrite, %BigMapY%, %inipath%, Overlay, BigMapY
	IniWrite, %SkinPosX%, %inipath%, Overlay, SkinPosX
	IniWrite, %SkinPosY%, %inipath%, Overlay, SkinPosY
	IniWrite, %HitPosX%, %inipath%, Overlay, HitPosX
	IniWrite, %HitPosY%, %inipath%, Overlay, HitPosY
	IniWrite, %ActiveMapOverlayX%, %inipath%, Overlay, ActiveMapOverlayX
	IniWrite, %ActiveMapOverlayY%, %inipath%, Overlay, ActiveMapOverlayY
	IniWrite, %RaceKeyOverlayX%, %inipath%, Overlay, RaceKeyOverlayX
	IniWrite, %RaceKeyOverlayY%, %inipath%, Overlay, RaceKeyOverlayY
	
	Loop, 3
		{
		IniWrite, % StartUpProg%A_Index%, %inipath%, Einstellungen, StartUpProg%A_Index%
		IniWrite, % StartProgButton%A_Index%, %inipath%, Einstellungen, StartProgButton%A_Index%
		}
	
	return
	}
LatestChat(ByRef output) {
	global DisableChats, DisableKilltrigger, MightKilled, HitCon_Name, varSetMoney, varHWD, valAdd5WP
	NewChatCount := GetChatLineCount()
	if(DisableChats > 0) {
		DisableChats -= 1
		CurrentChatCount += 1
		output := 0
		return
		}
	if((NewChatCount-CurrentChatCount)>100)
		CurrentChatCount := NewChatCount
	if(NewChatCount > CurrentChatCount) {
		CurrentChatCount += 1
		FileRead, cfile, %chatlogpath%
		Loop, parse, cfile, `n, `r
			{
			if(A_Index = CurrentChatCount) {
				LatestOutput := RegExReplace(A_LoopField, "U)^\[\d{2}:\d{2}:\d{2}\]")
				LatestOutput := RegExReplace(LatestOutput, "Ui)\{[a-f0-9]{6}\}")
				LatestOutput := Trim(LatestOutput, " ")
				break
				}
			}
		cfile := ""
		if(RegStr(LatestOutput, "[NeS]", "mit der ID", "flüstert dir:"))
			DisableChats := 1
		DelVarIndex := 0
		output := LatestOutput
		return
		}
	if(NewChatCount <= CurrentChatCount) {
		CurrentChatCount := NewChatCount
		DelVarIndex += 1
		if(DelVarIndex = 10) {
			DisableChats := 0
			DisableKilltrigger := 0
			MightKilled := 0
			HitCon_Name := 0
			varSetMoney := 0
			varHWD := 0
			valAdd5WP := ""
			}
		output := 0
		return
		}
	}
GetChatLineCount(){
	FileRead, file, %chatlogpath%
	StringReplace, file, file, `n, `n, UseErrorLevel
	return ErrorLevel
	}
GetChatLine(Line, ByRef Output, timestamp=0, color=0){
	chatindex := GetChatLineCount()
	FileRead, file, %chatlogpath%
	loop, Parse, file, `n, `r
		{
		if(A_Index = chatindex - line){
			output := A_LoopField
			break
			}
		}
	file := ""
	if(!timestamp)
		output := RegExReplace(output, "U)^\[\d{2}:\d{2}:\d{2}\]")
	if(!color)
		output := RegExReplace(output, "Ui)\{[a-f0-9]{6}\}")
	output := Trim(output, " ")
	return
	} 
Eingabeaufforderung(ByRef Output, DoClip="Eingabe: ", PreSend="") {
	sleep, 200
	SaveClip()
	Clipboard := "// " DoClip
	ClipWait, 1
	SendInput, {F6}^a^v
	SetKeyDelay, 200
	Suspend, Toggle
	if(PreSend)
		SendInput, %PreSend%
	Input, output, V, {enter}
	Suspend, Toggle
	SendInput, ^a{BackSpace}{enter}
	SetKeyDelay, -1
	LoadClip()
	Sleep, 200
	return output
	}
RegStr(String, Needle, Needle2="", Needle3="") {
	Pos := RegExMatch(String, "(:|\*|•).*\Q" Needle "\E", output)
	if(output)
		return 0
	if(!Needle2 AND !Needle3) {
		if(InStr(String, Needle, 1))
			return 1
		}
	if(Needle2 AND !Needle3) {
		if(InStr(String, Needle, 1) AND InStr(String, Needle2, 1))
			return 1
		}
	if(Needle2 AND Needle3) {
		if(InStr(String, Needle, 1) AND InStr(String, Needle2, 1) AND InStr(String, Needle3, 1))
			return 1
		}
	return 0
	}
AskPlayerName(ByRef FP_PlayerName, Question="ID oder Name des Spielers: ") {
Eingabeaufforderung(FP_PlayerName, Question)
if((TryStr := SubStr(FP_PlayerName, 1, 1)) = "#") {
	FP_PlayerName := SubStr(FP_PlayerName, 2)
	RegMode := 1
	} else {
	KBOSend("/id " FP_PlayerName)
	sleep, 200
	RegMode := 2
	Loop, 3
		{
		GetChatLine((3-A_Index), FP_Chat)
		If(InStr(FP_Chat, FP_PlayerName) AND InStr(FP_Chat, "Level: ") AND InStr(FP_Chat, "ID: ("))
			{
			FP_PH_PlayerName := StrSplit(FP_Chat, " ")
			FP_PlayerName := FP_PH_PlayerName[3]
			RegMode := 1
			break
			}
		}
	}
	return 
	}
changeTab(tabName:= "killbinds", silent="0") {
	tabNamePicture := RegExReplace(tabName, "\d+$")
	currentGUIPicture := RegExReplace(currentGUI, "\d+$")
	GuiControl,, Navigation%currentGUIPicture%, img/button_%currentGUIPicture%.png
	GuiControl,, Navigation%tabNamePicture%, img/button_active%tabNamePicture%.png
	currentGUI:= tabName
	For k in elements
		{
		for k2, v2 in elements[k]
			{
			GuiControl, Hide, %v2%
			}
		}
	For index, element in elements[tabName] 
		{
		GuiControl, Show, %element%
		GuiControl, Enable, %element%
		if(inarray(element, FuncNeedAPI) && !EnableAPI)
			GuiControl, Disable, %element%
		}
	if(tabName="Speichern")
		Gui, main:show, w220 h%GuiMaxH%, %KillbinderTitelName%
		else
		Gui, main:show, w%GuiMaxW% h%GuiMaxH%, %KillbinderTitelName%
	return
	}
font(fontSize:= 10, fontName:= "Times New Roman"){
sizeScaled:= round(96/A_ScreenDPI*fontSize)
Gui, main:Font, s%sizeScaled%, %fontName%
}
ProcessClose(Name) {
	Process, Exist, %Name%
	If (ErrorLevel) {
		Process, Close, %Name%
		}
	return
	}
ProcessStatus(Name) {
	Process, Exist, %Name%
	If(ErrorLevel)
		return true
	return false
	}
IsWinActive(Name) {
	IfWinActive, ahk_exe %Name%
		return true
	return false
	}
SearchLine(String, bRegEx=false, bBreakOnFind=false, bTimeStamp=false, bChatCode=false) {
	FileRead, file, %chatlogpath%
	loop, Parse, file, `n, `r
		{
		ThisLine := A_LoopField
		if(!bTimeStamp)
			ThisLine := RegExReplace(ThisLine, "U)^\[\d{2}:\d{2}:\d{2}\]")
		if(!bChatCode)
			ThisLine := RegExReplace(ThisLine, "Ui)\{[a-f0-9]{6}\}")
		ThisLine := Trim(ThisLine, " ")
		if(!ThisLine)
			continue
		if(!bRegEx) {
			If(InStr(ThisLine, String)) {
				output := ThisLine
				}
			} else {
			if((Pos := RegExMatch(ThisLine, "Ui)" String))) {
				output := ThisLine
				}
			}
		if(output && bBreakOnFind)
			break
		}
	file := ""
	if(!output)
		return 0
	return output
	}
CalcActiveMap(X=0, Y=0, Size=0) {
	if(X) {
		output := ActiveMapOverlayX+(ActiveMapSize/2) + (X/6000*ActiveMapSize)
		if(Size)
			output -= Size/3
		} else if(Y) {
		Y := Y * (-1)
		output := ActiveMapOverlayY+(ActiveMapSize/2) + (Y/6000*ActiveMapSize)
		if(Size)
			output -= Size/3
		}
	return output
	}
CalcScreenPos(X=0, Y=0) {
	if(X) {
		output := X/A_ScreenWidth*800
		} else if(Y){
		output := Y/A_ScreenHeight*600
		}
	return output
	}
KeyReady(taste="enter") {
	while(GetKeyState(taste, "P"))
		Sleep, 10
	}
HookGTA:
if(LoginState = "-1" || !GuiLoaded || !EnableAPI)
	return
if(!ProcessStatus("gta_sa.exe")) {
	InitHook := 0
	return
	}
if(InitHook)
	return
InitHook := 1
EmergencyHook:
#Include SAMP_API.ahk
return
#Include SAMP_API_Func.ahk
