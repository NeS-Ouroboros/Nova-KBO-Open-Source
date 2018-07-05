#IfWinActive, ahk_exe gta_sa.exe
#UseHook
#SingleInstance, Force
#Persistent
#HotString EndChars `n
;~ FileEncoding, CP65001

If Not A_IsAdmin {
	Run *RunAs %A_ScriptFullPath%
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
		}
	
	URLDownloadToFile, https://ourororo.de/killbinder/api/Open-SAMP-API.dll, API.dll
	FileMove, API.dll, %A_Appdata%\Bobo\bin\Open-SAMP-API.dll, 1
	
	UsedButtons := "button_activeautonom.png|button_activeeinstellungen.png|button_activefrakbinds.png|button_activeinformationen.png|button_activekeybinds.png|button_activekillbinds.png|button_anmelden.png|button_autonom.png|button_einstellungen.png|button_frakbinds.png|button_gast.png|button_informationen.png|button_keybinds.png|button_killbinds.png|button_speichern.png"
	
	Loop, parse, UsedButtons, |
		{
		IfNotExist, %A_Appdata%\Bobo\img\%A_Loopfield%
			{
			URLDownloadToFile, https://ourororo.de/killbinder/img/%A_LoopField%, %A_Loopfield%
			FileMove, %A_Loopfield%, %A_Appdata%\Bobo\img\%A_Loopfield%, 1
			}
		}
	IniWrite, %OldPlace%, %A_AppData%\Bobo\ToDelete.ini, Old, OldExe
	IfExist, %A_AppData%\Bobo\KbO.exe
		Run *RunAs %A_AppData%\Bobo\KbO.exe
	ExitApp
	}
SetWorkingDir %A_AppData%\Bobo

global SoundInfo := "*-1"
global SoundWarn := "*16"
global Frak_Typ := {1: "Staat", 2: "Staat", 4: "Staat", 5: "Mafia", 6: "Mafia", 7: "Staat", 9: "Neutral", 11: "Gang", 13: "Gang", 14: "Gang",18: "Mafia", 19: "Gang"}
global ObjTyp := {1: "Container", 2: "Hanf", 3: "Gold", Container: "1", Hanf: "2", Gold: "3"}
global CareTyp := {1: "gegossen", 2: "gedüngt"}
global bobopath := A_AppData "\Bobo"
global inipath := A_AppData "\Bobo\config.ini"
global AnzKillbinds := 16
global AnzKeybinds := 16
global AnzAutonom := 8
global AnzFrakbinds := 10
LoadIni()
global Frak_Name := {1: "San Andreas Police Department", 2: "Federal Bureau of Investigation", 4: "San Andreas Rettungsdienst", 5: "La Cosa Nostra", 6: "Yakuza", 7: "Regierung", 9: "San Andreas Media AG", 11: "Scarfo Family", 13: "Purple Ice Ballas", 14: "Grove Street",18: "Triaden", 19: "Los Vagos"}
global Frak_RegEx := ["PD|Police|Polizei|LS|Los Santos|Bullen|Cops", "F\.?B\.?I\.?|Federal|Bureau|Investigation|Sniper","", "Krankenhaus|SA:?RD|Rettungsdienst|Arzt|Ärzte|Medic", "LCN|La Cosa Nostra|Cosa|Nostra", "Yakuza|YKZ|Yaki|Eis", "Regierung|Government|Gov|DMV|Motor|Fahrschule|Schule|Führerschein","", "SAM ?AG|Media|News|^SAM|Reporter|Ouro|nikk", "", "Aztec|Varrios|Scarfo|Racing|Auto|Car|Rifa|VLA","", "Ballas|Front Yard|Purple|Ice|PIB|Pokee", "GS|Grove Street|Grove","","","", "Shanghai|Syndikat|China|Triaden|Triad|Jiro", "Los|Vagos|Latino"]
global chatlogpath := A_MyDocuments "\GTA San Andreas User Files\SAMP\chatlog.txt"
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
global ChatColor := {Bobo: "cdff5b", Echo: "3aebff", Error: "ff0000", Success: "00ff00", Warning: "ff7800", White: "ffffff"}
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
global KillbinderTitelName := "Killbinder by Ouro R2"
global GuiMaxH := 500
global GuiMaxW := 1200
global BigMapX
global BigMapY
global BigMapCrop := 12
global SkinPosX
global SkinPosY
global DialogIndex := 13296

global currentGUI := "Killbinds"
global elements := {killbinds: [], keybinds: [], frakbinds: [], autonom: [], informationen: [], informationen2: [], einstellungen: [], einstellungen2: [], login: []}

SetTimer, ChatLabel, 100
SetTimer, Settings, 500

#Include SAMP_API.ahk
#Include Funcs_KbO.ahk

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

if(!DefaultAPI)
	EnableAPI := 0

if(A_ScriptFullpath != A_AppData "\Bobo\KbO.exe") {
	FileMove, %A_ScriptFullPath%, %A_AppData%\Bobo\KbO.exe, 1
	IniWrite, %A_ScriptFullPath%, %A_AppData%\Bobo\ToDelete.ini, Old, OldExe
	IfExist, %A_AppData%\Bobo\KbO.exe
		Run *RunAs %A_AppData%\Bobo\KbO.exe
	ExitApp
	}

URLDownloadToFile, https://ourororo.de/killbinder/Version.ini, CheckUpdate.ini
IniRead, nVersion, CheckUpdate.ini, Settings, Version, 3.2
IniRead, nDL, CheckUpdate.ini, Settings, DLink, https://ourororo.de/killbinder/KbO3.2.exe
IniRead, nChangelog, CheckUpdate.ini, Settings, Changelog, NoChangelog

IniRead, aVersion, %inipath%, Settings, Version, 3.2
FileDelete, CheckUpdate.ini

if(nVersion != aVersion) {
	UpdateText := "Es wurde ein Update gefunden!`nDie aktuelle Version ist: [AktVersion]`nDie neue Version ist [NewVersion]`n`nMöchtest du jetzt das Update herunterladen und installieren?`n`nChangelog:`n•"
	StringReplace, UpdateText, UpdateText, [AktVersion], %aVersion%, All
	StringReplace, UpdateText, UpdateText, [NewVersion], %nVersion%, All
	StringReplace, nChangelog, nChangelog, [n], `n•%A_Space%, All
	StringReplace, nChangelog, nChangelog, [v], `n>%A_Space%, All
	
	MsgBox, 0, Killbinder Updater, %UpdateText% %nChangelog%
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
FrakbindDesc := "Der Inhalt der Frakbinds werden von den Leadern über die Homepage eingestellt. Hier kann man dann die gewünschten Hotkeys zum Senden eintragen."
EinstellungenDesc := "Some Random I/O Stuff`n`nWenn die Funktion nicht benötigt wird, das Textfeld einfach leer lassen."
Einstellungen2Desc := "#ComingSoon"

Gui, main:add, Text, x230 y10 h80 w960 vKillbindDesc c%TextColor% +Hidden, %KillbindDesc%
elements["killbinds"].Push("KillbindDesc")
Gui, main:add, Text, x230 y10 h80 w960 vKeybindDesc c%TextColor% +Hidden, %KeybindDesc%
elements["keybinds"].Push("KeybindDesc")
Gui, main:add, Text, x230 y10 h80 w960 vAutonomDesc c%TextColor% +Hidden, %AutonomDesc%
elements["autonom"].Push("AutonomDesc")
Gui, main:add, Text, x230 y10 h80 w960 vInformationDesc c%TextColor% +Hidden, %InformationDesc%
elements["informationen"].Push("InformationDesc")
elements["informationen2"].Push("InformationDesc")
Gui, main:add, Text, x230 y10 h80 w960 vFrakbindDesc c%TextColor% +Hidden, %FrakbindDesc%
elements["frakbinds"].Push("FrakbindDesc")
Gui, main:add, Text, x230 y10 h80 w960 vEinstellungenDesc c%TextColor% +Hidden, %EinstellungenDesc%
elements["einstellungen"].Push("EinstellungenDesc")
Gui, main:add, Text, x230 y10 h80 w960 vEinstellungen2Desc c%TextColor% +Hidden, %Einstellungen2Desc%
elements["einstellungen2"].Push("Einstellungen2Desc")

Gui, main:Add, Picture, x10 y10 gCallbackKillbinds vNavigationKillbinds, img/button_killbinds.png
Gui, main:Add, Picture, x10 y80 gCallbackKeybinds vNavigationKeybinds, img/button_keybinds.png
Gui, main:Add, Picture, x10 y150 gCallbackFrakbinds vNavigationFrakbinds, img/button_frakbinds.png
Gui, main:Add, Picture, x10 y220 gCallbackAutonom vNavigationAutonom, img/button_autonom.png
Gui, main:Add, Picture, x10 y290 gCallbackInformationen vNavigationInformationen, img/button_informationen.png
Gui, main:Add, Picture, x10 y360 gCallbackEinstellungen vNavigationEinstellungen, img/button_einstellungen.png
Gui, main:Add, Picture, x10 y430 gCallbackSpeichern, img/button_speichern.png

font(TextSize["Label"])
Gui, main:add, Text, x230 y40 vLoginText c%TextColor%, Login
font(TextSize["Desc"])
Gui, main:add, Text, x280 y150 Right w150 vLoginNameText c%TextColor%, Benutzername
Gui, main:add, Text, x280 y200 Right w150 vLoginPassText c%TextColor%, Passwort
Gui, main:Add, Picture, x460 y250 gCallbackLoginUser vLoginUserPicAnmelden, img/button_anmelden.png
Gui, main:Add, Picture, x760 y250 gCallbackLoginGast vLoginUserPicGast, img/button_gast.png
font(TextSize["normal"])
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

font(TextSize["normal"])

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

font(TextSize["normal"])
InfoText11 := "Variablen:`n[GKills]`tGesamte Kills`n[GDeaths]`tGesamte Tode`n[GKD]`t`tGesamte KD`n[DKills]`tTägliche Kills`n[DDeaths]`tTägliche Tode`n[DKD]`t`tTägliche KD`n[Weapon]`tAktuelle Waffe`n[Zone]`t`tAktuelle Zone`n[City]`t`tAktuelles Stadtgebiet`n[Vehicle]`tAktuelles Fahrzeug!!`n[Screen]`tMacht einen Screen mit F8`n[WaitXXXX]`tWartet XXXX-Millisekunden`n[Streak]`tAktulle Streak"
InfoText12 := "Special Autonomer Chat:`nLinks: [(Möglichkeit1|Möglichkeit2|Möglichkeit3|...)]`n`t`tEs ist ein Platzhalter`nRechts: [ChatX]`n`t`tNimmt das X-te Wort aus dem Chat"
Gui, main:add, Text, x230 y110 vInfoText11 c%SecondColor% +Hidden, %InfoText11%
Gui, main:add, Text, x700 y110 vInfoText12 c%SecondColor% +Hidden, %InfoText12%

InfoText21 := "Befehle:`n/setvs`t`tLegt den Chat für /vs fest`n/vs`t`tSendet eine Nachfrage nach Verstärkung`n/hwd`t`tAutomatisches Housewithdraw`n/GetCont`tAbfrage über gespeicherte Plantagen etc`n/GetPlant`tAbfrage über gespeicherte Plantagen etc`n/SetKills`tSetzt die GKills`n/SetDeaths`tSetzt die GDeaths`n/DebugVisual`tEntfernt alle aktuellen Overlays`n/MoveOverlay`tÄndert die Position des Overlays`n/Math`t`tTaschenrechner`n/api`t`tDe-/aktiviert die API`nDoppel M`t/mv /oldmv`n/DefMoney`tAm ATM das Bargeld festsetzen`n/Playerdata`tWie Playerinfo`n/Frakdata`tÜberprüft wer von einer Fraktion online ist`n/FrakdataID`tGibt die Mitglieder der Fraktion mit /id wieder"
InfoText3 := "Mitwirkende:`n[NeS]Ouroboros`tAHK-Scripter`n[NeS]shoXy`t`tBereitstellung einer API`nPokee`t`t`tAHK Unterstützung"
Gui, main:add, Text, x230 y110 vInfoText21 c%SecondColor% +Hidden, %InfoText21%
Gui, main:add, Text, x900 y10 w500 vInfoTextBoth c%SecondColor% +Hidden, %InfoText3%

Gui, main:add, Button, x1070 y460 h30 w120 gSwitchLabel vInformationen2 +Hidden, Informationen 2
Gui, main:add, Button, x1070 y460 h30 w120 gSwitchLabel vInformationen1 +Hidden, Informationen 1
elements["informationen"].Push("InfoText11")
elements["informationen"].Push("InfoText12")
elements["informationen2"].Push("InfoText21")
elements["informationen"].Push("InfoTextBoth")
elements["informationen2"].Push("InfoTextBoth")
elements["informationen"].Push("Informationen2")
elements["informationen2"].Push("Informationen1")

Gui, main:add, Checkbox, x230 y110 vAutoEnableEngine Checked%AutoEnableEngine% c%TextColor% +Hidden, Automatisch Motor einschalten
Gui, main:add, Checkbox, x230 y160 vAutoEnableLights Checked%AutoEnableLights% c%TextColor% +Hidden, Automatisch Licht einschalten
Gui, main:add, Checkbox, x230 y210 vAutoSendWPs Checked%AutoSendWPs% c%TextColor% +Hidden, Erhaltene WPs in den /vs-Chat

Gui, main:add, Text, x700 y160 w160 vMouseText1 c%TextColor% +Hidden, Maus links kippen:
Gui, main:add, Text, x700 y210 w160 vMouseText2 c%TextColor% +Hidden, Maus rechts kippen:
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
Gui, main:add, Edit, x850 y260 w300 h30 vCallinText -VScroll +Hidden, %CallinText%
Gui, main:add, Edit, x850 y310 w300 h30 vCalloutText -VScroll +Hidden, %CalloutText%

Gui, main:add, Text, x650 y110 w200 vActionOnLSD c%TextColor% +Hidden, Nach LSD Nebenwirkung:
Gui, main:add, Edit, x850 y110 w300 h30 vActionOnLSDText -VScroll +Hidden, %ActionOnLSDText%

Gui, main:add, Text, x700 y360 h30 w260 vHotkeyToggleText c%TextColor% +Hidden, Keybinder ein- / ausschalten
Gui, main:add, Hotkey, x920 y360 h30 w60 vHotkeyToggle -VScroll +Hidden, %HotkeyToggle%

Gui, main:add, Text, x1050 y360 h30 w60 vVSHotkeyText c%TextColor% +Hidden, /vs
Gui, main:add, Hotkey, x1090 y360 h30 w60 vVSHotkey -VScroll +Hidden, %VSHotkey%

Gui, main:add, CheckBox, x230 y410 vAutoSwitchGun Checked%AutoSwitchGun% c%TextColor% +Hidden, Automatisches Swapgun
Gui, main:add, CheckBox, x230 y460 vActivePremium Checked%ActivePremium% c%TextColor% +Hidden, Aktives Premium

Gui, main:add, Button, x1090 y460 h30 w100 gSwitchLabel vEinstellungen2 +Hidden, Einstellungen 2
Gui, main:add, Button, x1090 y460 h30 w100 gSwitchLabel vEinstellungen1 +Hidden, Einstellungen 1

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
elements["einstellungen"].Push("CallinText")
elements["einstellungen"].Push("CalloutText")
elements["einstellungen"].Push("ActionOnLSD")
elements["einstellungen"].Push("ActionOnLSDText")
elements["einstellungen"].Push("HotkeyToggleText")
elements["einstellungen"].Push("HotkeyToggle")
elements["einstellungen"].Push("AutoSwitchGun")
elements["einstellungen"].Push("ActivePremium")
elements["einstellungen"].Push("VSHotkeyText")
elements["einstellungen"].Push("VSHotkey")
elements["einstellungen"].Push("Einstellungen2")
elements["einstellungen2"].Push("Einstellungen1")



return

Label_ToggleKey:
Suspend, Permit
if(A_IsSuspended) {
	KBOSend("/echo Keybinder wird nun {00ff00}aktiviert{ffffff}.")
	ForceSuspend := 0
	Suspend, Off
	} else {
	KBOSend("/echo Keybinder wird nun {ff0000}deaktiviert{ffffff}.")
	ForceSuspend := 1
	Suspend, On
	}
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
	if(A_ThisHotkey = KeybindHotkey%A_Index%)
		KBOSend(KeybindText%A_Index%)
	}
Loop, %AnzFrakbinds%
	{
	if(A_ThisHotkey = FrakHotkey%A_Index%)
		KBOSend(FrakbindText%A_Index%)
	}
return

SwitchLabel:
if(currentGUI = "Einstellungen") {
	if(MouseButton1)
		Hotkey, XButton1, Label_for_all_Hotkeys, off
	if(MouseButton2)
		Hotkey, XButton2, Label_for_all_Hotkeys, off
	if(HotkeyToggle)
		Hotkey, %HotkeyToggle%, Label_ToggleKey, off
	if(VSHotkey)
		Hotkey, %VSHotkey%, Label_VS, off
	}
Gui, main:submit, NoHide
if(currentGUI = "Einstellungen") {
	if(MouseButton1)
		Hotkey, XButton1, Label_for_all_Hotkeys, On
	if(MouseButton2)
		Hotkey, XButton2, Label_for_all_Hotkeys, On
	if(HotkeyToggle)
		Hotkey, %HotkeyToggle%, Label_ToggleKey, On
	if(VSHotkey)
		Hotkey, %VSHotkey%, Label_VS, On
	}
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
CallbackFrakbinds:
CallbackAutonom:
CallbackInformationen:
CallbackEinstellungen:
CallbackSpeichern:
if(LoginState = "-1")
	return

if(currentGUI = "Keybinds") {
	Loop, %AnzKeybinds%
		{
		if(KeybindHotkey%A_Index% != "")
			Hotkey, % KeybindHotkey%A_Index%, Label_for_all_Hotkeys, off
		}
	}
if(currentGUI = "Einstellungen") {
	if(MouseButton1)
		Hotkey, XButton1, Label_for_all_Hotkeys, off
	if(MouseButton2)
		Hotkey, XButton2, Label_for_all_Hotkeys, off
	if(HotkeyToggle)
		Hotkey, %HotkeyToggle%, Label_ToggleKey, off
	if(VSHotkey)
		Hotkey, %VSHotkey%, Label_VS, off
	}
if(currentGUI = "Frakbinds") {
	Loop, %AnzFrakbinds%
		{
		if(FrakHotkey%A_Index% != "")
			Hotkey, % FrakHotkey%A_Index%, Label_for_all_Hotkeys, off
		}
	}

Gui, main:submit, NoHide


if(currentGUI = "Keybinds") {
	Loop, %AnzKeybinds%
		{
		if(KeybindHotkey%A_Index% != "")
			Hotkey, % KeybindHotkey%A_Index%, Label_for_all_Hotkeys, on
		}
	}
if(currentGUI = "Einstellungen") {
	if(MouseButton1)
		Hotkey, XButton1, Label_for_all_Hotkeys, on
	if(MouseButton2)
		Hotkey, XButton2, Label_for_all_Hotkeys, on
	if(HotkeyToggle)
		Hotkey, %HotkeyToggle%, Label_ToggleKey, on
	if(VSHotkey)
		Hotkey, %VSHotkey%, Label_VS, on
	}
if(currentGUI = "Frakbinds") {
	Loop, %AnzFrakbinds%
		{
		if(FrakHotkey%A_Index% != "")
			Hotkey, % FrakHotkey%A_Index%, Label_for_all_Hotkeys, on
		}
	}
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
ProgCount := SubStr(A_ThisLabel, 12)
FileSelectFile, Prog%ProgCount%, S3, %A_Desktop%, "Was soll der Keybinder beim Start mit ausführen?", .exe
if(!Prog%ProgCount%)
	return
IniWrite, % Prog%ProgCount%, %inipath%, Einstellungen, Prog%ProgCount%Path
SplitPath, Prog%ProgCount%, StartProgButton%ProgCount%
IniWrite, % StartProgButton%ProgCount%, %inipath%, Einstellungen, StartProgButton%ProgCount%
GuiControl,, StartProgButton1, % StartProgButton%ProgCount%
return

CallbackLoginUser:
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
Gui, main:submit, NoHide
SecureLogin := LoadStartUp(LoginName,, 0)
if(SecureLogin) {
	LoginState := 0
	GoTo, StartGUI
	}
return

LoadStartUp(LoginName, LoginPass=0, UoG=0) {
	if(UoG) {
		CheckLogin := BoboRequest(LoginName, LoginPass, "login")
		} else {
		CheckLogin := BoboRequest(LoginName,, "login")
		}
	if(!CheckLogin[2]) {
		ErrorCode := CheckLogin[3]
		MsgBox, 16, Login, Benutzername und/oder Passwort stimmen nicht überein!`n%ErrorCode%
		return 0
		}
	if(CheckLogin[3]) {
		Loop, 10
			{
			TextIndex := A_Index+3
			FrakbindText%A_Index% := CheckLogin[TextIndex]
			IniWrite, % FrakbindText%A_Index%, Temp.ini, Frakbinds, FrakbindText%A_Index%
			}
		}
	return 1
	}

StartGUI:
UserName := LoginName
UserPass := LoginPass
SaveIni()
if(StartUpProg1)
	InitStartUp(1)
if(StartUpProg2)
	InitStartUp(2)
if(StartUpProg3)
	InitStartUp(3)
IfExist, temp.ini
	{
	Loop, %AnzFrakbinds%
		{
		IniRead, FrakbindText%A_Index%, Temp.ini, Frakbinds, FrakbindText%A_Index%, 0
		if(!FrakbindText%A_Index%)
			FrakbindText%A_Index% := ""
		if(InStr(FrakbindText%A_Index%, "[S1]")) {
			StringReplace, FrakbindText%A_Index%, FrakbindText%A_Index%, [S1], ×, All
			}
		if(InStr(FrakbindText%A_Index%, "[oe]", 1)) {
			StringReplace, FrakbindText%A_Index%, FrakbindText%A_Index%, [oe], ö, All
			}
		if(InStr(FrakbindText%A_Index%, "[ae]", 1)) {
			StringReplace, FrakbindText%A_Index%, FrakbindText%A_Index%, [ae], ä, All
			}
		if(InStr(FrakbindText%A_Index%, "[ue]", 1)) {
			StringReplace, FrakbindText%A_Index%, FrakbindText%A_Index%, [ue], ü, All
			}
		if(InStr(FrakbindText%A_Index%, "[Ue]", 1)) {
			StringReplace, FrakbindText%A_Index%, FrakbindText%A_Index%, [Oe], Ö, All
			}
		if(InStr(FrakbindText%A_Index%, "[Ae]", 1)) {
			StringReplace, FrakbindText%A_Index%, FrakbindText%A_Index%, [Ae], Ä, All
			}
		if(InStr(FrakbindText%A_Index%, "[Ue]", 1)) {
			StringReplace, FrakbindText%A_Index%, FrakbindText%A_Index%, [Ue], Ü, All
			}
		}
	FileDelete, Temp.ini
	}

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
	if(KeybindHotkey%A_Index% != "")
		Hotkey, % KeybindHotkey%A_Index%, Label_for_all_Hotkeys, on
	elements["keybinds"].Push("KeybindHotkey" A_Index)
	elements["keybinds"].Push("KeybindText" A_Index)
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
	if(FrakHotkey%A_Index% != "")
		Hotkey, % FrakHotkey%A_Index%, Label_for_all_Hotkeys, on
	}

changeTab("killbinds")

FlagBizName := {9: "BSN Tankstelle", 10: "Grove Street Tankstelle", 11: "Truckstop Tankstelle", 12: "Dillimore Tankstelle", 13: "SF Bahnhof Tankstelle", 14: "SFPD Tankstelle", 15: "SF Carshop Tankstelle", 16: "Prison Tankstelle", 17: "Angel Pine Tankstelle", 21: "Tankstelle Bayside"}
FlagBiz1 := {9: ["", "", "Angel Pine Tankstelle"], 10: ["", "", "LV Arena"], 11: ["", "", "Prison Tankstelle"], 12: ["", "", "Angel Pine Holzhütte"], 13: ["", "", "Staudamm"], 14: ["", "", "Ehemalige FBI Base"], 15: ["", "", "Flugzeugfriedhof"], 16: ["", "", "Alte Fahrschule"], 17: ["", "", "SF Airport Landebahn"], 21: ["", "", "Baustelle SF Bahnhof"]}
FlagBiz2 := {9: ["", "", "LV Baseballstadion"], 10: ["", "", "San Fierro Kraftwerk"], 11: ["", "", "Catalinas Hütte"], 12: ["", "", "Basketballplatz Rock Hotel"], 13: ["", "", "LS Airport"], 14: ["", "", "Bayside Heli-Plattform"], 15: ["", "", "LV Fort Carson Steg"], 16: ["", "", "East LS Strand"], 17: ["", "", "El Quebrados"], 21: ["", "", "Holzhütte an der Farm"]}
FlagBiz3 := {9: ["", "", "Kuh-Gebiet"], 10: ["", "", "Fort Carson"], 11: ["", "", "Hütte über SF Tunnel"], 12: ["", "", "Bayside Campingplatz"], 13: ["", "", "Palomino Creek OC"], 14: ["", "", "Ehemalige KF Base"], 15: ["", "", "Aussichtsplattform weißes Haus"], 16: ["", "", "SF Airport Hangar"], 17: ["", "", "Erzmine"], 21: ["", "", "Montgomery"]}




return

mainGuiClose:
mainGuiEscape:
SaveIni()
if(EnableAPI)
	DestroyAllVisual()
ExitApp
return

Hotkey, Enter, Off
Hotkey, Escape, Off

+T::
~t::
if(!ForceSuspend)
	Suspend On
Hotkey, Enter, On
Hotkey, Escape, On
Hotkey, t, Off
return

~Enter::
Suspend Permit
if(!ForceSuspend)
	Suspend Off
Hotkey, t, On
Hotkey, Enter, Off
Hotkey, Escape, Off
return

~Escape::
Suspend Permit
if(!ForceSuspend)
	Suspend Off
Hotkey, t, On
Hotkey, Enter, Off
Hotkey, Escape, Off
return

~M::
if(EnableAPI && IsChatOpen() || EnableAPI && IsDialogOpen() || EnableAPI && IsMenuOpen())
	return
KeyWait, m
KeyWait, m, D T0.2
if(ErrorLevel)
	return
KBOSend("/mv~/oldmv")
return

+F::
~F::
if(EnableAPI && IsChatOpen() || EnableAPI && IsDialogOpen() || EnableAPI && IsMenuOpen())
	return
if(EnableAPI && IsPlayerDriver()) {
	sleep, 500
	if(AutoEnableEngine && IsVehicleEngineEnabled()) {
		KBOSend("/cveh motor")
		}
	if(AutoEnableLights && IsVehicleLightEnabled()) {
		KBOSend("/cveh licht")
		}
	CarLocked := 1
	}
return

LSDTime:
LSDIndex += 1
if(EnableAPI && LSDOverlayCreate) {
	LSDTimeLeft := "LSD Timer: " 90-LSDIndex
	if(TextSetString(LSDOverlay, LSDTimeLeft) == 0) {
		TextDestroy(LSDOverlay)
		}
	if(LSDTimeLeft = 60)
		TextSetColor(LSDOverlay, "0xffffef60")
	if(LSDTimeLeft = 30)
		TextSetColor(LSDOverlay, "0xffff9d1e")
	if(LSDTimeLeft = 10)
		TextSetColor(LSDOverlay, "0xffff0000")
	}
if((LSDCounter - LSDIndex) = LSDWarn) {
	if(EnableAPI)
		KBOSend("/echo Nebenwirkung in 10 Sekunden!")
		else
		SoundPlay, %SoundInfo%
}
if(LSDCounter = LSDIndex-1) {
	if(EnableAPI && LSDOverlayCreate)
		KBOSend("/echo Die Nebenwirkung tritt ein!")
		else
		SoundPlay, %SoundInfo%
	SetTimer, LSDTime, Off
	TextDestroy(LSDOverlay)
}
return

Settings:
if(LoginState = "-1")
	return
FormatTime, Today,, yyyy.MM.dd
IniRead, IniDate, %inipath%, Settings, Date, 0
if(IniDate != Today) {
	IniWrite, %Today%, %inipath%, Settings, Date
	IniWrite, 0, %inipath%, Kills, TaeglicheKills
	IniWrite, 0, %inipath%, Kills, TaeglicheDeaths
	}
if(EnableAPI && IsPlayerDriver() && !CarLocked) {
	if(AutoEnableEngine)
		StartEngine()
	if(AutoEnableLights)
		StartLights()
	}

if(EnableAPI) {
	if(IsPlayerInAnyVehicle()) {
		Carheal := RegExReplace(GetVehicleHealth(), "\.\d+")
		if(!CarhealOverlayCreated) {
			CarhealOverlay := TextCreate("Times New Roman", 12, false, false, CarOverlayX, CarOverlayY, 0xFF45ff30, "Carheal: " Carheal, true, true)
			CarhealOverlayCreated := 1
			}
		if(CarhealOverlayCreated) {
			TextSetString(CarhealOverlay, "Carheal: " Carheal)
			if(Carheal > 700)
				TextSetColor(CarhealOverlay, "0xFF45ff30")
			if(Carheal <= 700 && Carheal > 400)
				TextSetColor(CarhealOverlay, "0xffff9d1e")
			if(Carheal <= 400)
				TextSetColor(CarhealOverlay, "0xffff0000")
			}
		}
	if(IsPlayerInAnyVehicle() = 0 && CarhealOverlayCreated) {
		TextDestroy(CarhealOverlay)
		CarhealOverlayCreated := 0
		}
	}
if(EnableAPI && AutoSwitchGun && IsPlayerInAnyVehicle() && IsPlayerPassenger() && GetPlayerWeaponID() = 0) {
	Sleep, 1000
	if(GetPlayerWeaponID() = 0 && IsVehicleCar() || GetPlayerWeaponID() = 0 && IsVehicleBike()) {
		GetPlayerWeaponName("5", AutoWeapon1, 255)
		GetPlayerWeaponName("4", AutoWeapon2, 255)
		if(AutoWeapon1 = "M4" && GetPlayerWeaponTotalClip("5") > 50 && ActivePremium) {
			DownTicks := 2
			} else if(AutoWeapon1 = "AK-47" && GetPlayerWeaponTotalClip("5") > 50 && ActivePremium) {
			DownTicks := 3
			} else if(AutoWeapon2 = "MP5" && GetPlayerWeaponTotalClip("4") > 50) {
			DownTicks := 1
			} else {
			DownTicks := 0
			}
		if(DownTicks) {
			KBOSend("/swapgun")
			sleep, 500
			SendInput, {Down %DownTicks%}{enter}
			while(GetPlayerWeaponID() = 0)
				sleep, 100
			}
		}
	}
if(EnableAPI && IsChatOpen() && !ForceSuspend || EnableAPI && IsDialogOpen() && !ForceSuspend || EnableAPI && IsMenuOpen() && !ForceSuspend)
	Suspend, On
if(EnableAPI && IsChatOpen() = 0 && IsDialogOpen() = 0 && IsMenuOpen() = 0 && !ForceSuspend)
	Suspend, Off
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
	SaveIni()
	}
if(RegStr(ChatOutput, "SERVER: Willkommen ")) {
	Suspend, Off
	Temp := StrSplit(ChatOutput, " ")
	UserName := Temp[Temp.MaxIndex()]
	IniWrite, %UserName%, %inipath%, Settings, UserName
	}
if(RegStr(ChatOutput, "Du hast ein Verbrechen begangen ( Vorsätzlicher Mord ). Reporter: Anonym.") || RegStr(ChatOutput, "SERVER: Du hast gerade einen Mord begangen. Achtung!") || RegStr(ChatOutput, "GANGWAR: Du hast einen Feind ausgeschaltet.") || RegStr(ChatOutput, "CASINO-EROBERUNG: Du hast einen Feind ausgeschaltet.") || RegStr(ChatOutput, "CRACKFESTUNG: Du hast einen Feind ausgeschaltet.") || RegStr(ChatOutput, "Du hast ein Verbrechen begangen ( Fahrerflucht ). Reporter: Anonym.")) {
	if(!EnableKillbinds)
		return
	SaveIni()
	LoadIni()
	
	StreakKills += 1
	GesamteKills += 1
	TaeglicheKills += 1
	
	if(DisableKilltrigger > 0) {
		DisableKilltrigger -= 1
		SoundPlay, %SoundInfo%
		} else {
		KillTextCounter := 0
		KillTextArray := []
		Loop, %AnzKillbinds%
			{
			if(KillbindText%A_Index%) {
				KillTextCounter += 1
				KillTextArray.Push(KillbindText%A_Index%)
				}
			}
		
		while(RandomKillText = EarlierRandomKillText && KillTextCounter != 1 && KillTextCounter != 0) 
			Random, RandomKillText, 1, %KillTextCounter%
		EarlierRandomKillText := RandomKillText
		
		if(KillTextCounter = 1)
			RandomKillText := 1
		
		if(KillTextCounter != 0)
			KBOSend(KillTextArray[RandomKillText])
		
		}
	SaveIni()
	}
	
if(RegStr(ChatOutput, "AGENTUR: Der Auftraggeber wünscht einen Beweis für den Mord, bitte lade diesen über den Laptop hoch."))
	SendInput, {F8}

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
	}

if(HitCon_Name && RegStr(ChatOutput, "Screenshot Taken - sa-mp-", ".png")) {
	Pos := RegExMatch(ChatOutput, "Ui)sa-mp-\d+\.png", ScreenName)
	FormatTime, ScreenDate,, yyyy.MM.dd
	NewScreenName := "Hit - " ScreenDate " - " SubStr(ScreenName, 7, -4) " - " HitCon_Name ".png"
	sleep, 3000
	FileCopy, %A_MyDocuments%\GTA San Andreas User Files\SAMP\screens\%ScreenName%, %A_MyDocuments%\GTA San Andreas User Files\SAMP\screens\%NewScreenName%
	HitCon_Name := ""
	}

if(RegStr(ChatOutput, "Du hast LSD Pillen eingenommen (+150HP für wenige Sekunden).")) {
	LSDIndex := 0
	SetTimer, LSDTime, 1000
	if(EnableAPI) {
		LSDOverlay := TextCreate("Times New Roman", 12, false, false, LSDOverlayX, LSDOverlayY, 0xFF45ff30, "LSD Timer: 90", true, true)
		LSDOverlayCreate := 1
		}
	}
if(RegStr(ChatOutput, "Der LSD Rausch ist nun vorbei und die Nebenwirkung tritt ein (15HP)!") && ActionOnLSDText) {
	ActionOnLSDText := RegExReplace(ActionOnLSDText, "i)\/use\b")
	KBOSend(ActionOnLSDText)
	}

if(RegStr(ChatOutput, "UNTERGRUND: Das Starten der LSD-Produktion hat den Einfluss deiner Fraktion im Untergrund steigen lassen") && LoginState) {
	KbOPlayerPos(NewPositions)
	Fam := BoboRequest(UserName, UserPass, "AddObject", NewPositions[3], NewPositions[4], "1")
	}

if(RegStr(ChatOutput, "INFO: ", "hat eine Hawaiian Green Plantage angelegt.", UserName) && LoginState) {
	KbOPlayerPos(NewPositions)
	Fam := BoboRequest(UserName, UserPass, "AddObject", NewPositions[3], NewPositions[4], "2")
	}

if(RegStr(ChatOutput, "INFO: ", "hat eine Acapulco Gold Plantage angelegt.", UserName) && LoginState) {
	KbOPlayerPos(NewPositions)
	Fam := BoboRequest(UserName, UserPass, "AddObject", NewPositions[3], NewPositions[4], "3")
	}

if(RegStr(ChatOutput, "UNTERGRUND: Das Gießen der Plantage hat den Einfluss deiner Fraktion im Untergrund steigen lassen") && LoginState) {
	KbOPlayerPos(NewPositions)
	Fam := BoboRequest(UserName, UserPass, "AddCare", NewPositions[3], NewPositions[4], "1")
	}

if(RegStr(ChatOutput, "UNTERGRUND: Das Düngen der Plantage hat den Einfluss deiner Fraktion im Untergrund steigen lassen") && LoginState) {
	KbOPlayerPos(NewPositions)
	Fam := BoboRequest(UserName, UserPass, "AddCare", NewPositions[3], NewPositions[4], "2")
	}
if(RegStr(ChatOutput, "ACHTUNG: Dein Fang scheint sich zu wehren, drücke die Tasten um stärker zu ziehen!"))
	SoundPlay, %SoundInfo%
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
if(RegStr(ChatOutput, "Connecting to 195.201.70.37:7777..."))
	Suspend, On
Loop, %AnzAutonom%
	ChatAutonom(ChatOutput, AutonomReact%A_Index%, AutonomAction%A_Index%)
if(RegStr(ChatOutput, "Momentanes Wantedlevel: ", " | Wantedpunkte: ") && AutoSendWPs) {
	Pos := RegExMatch(ChatOutput, "Wantedpunkte: \d+", GotWPs)
	GotWPs := SubStr(GotWPs, 15)
	KBOSend("/" vsChat " Habe " GotWPs " Wantedpunkte erhalten in [Zone] ([City])!")
	}
if(RegStr(ChatOutput, "Während des AFK-Modus geht deine Zeit zum Zahltag nicht mehr hoch.") && EnableAPI) {
	if(IsPlayerInAnyVehicle() && IsPlayerDriver() && IsVehicleEngineEnabled() && AutoEnableEngine)
		SendChat("/cveh motor")
	if(IsPlayerInAnyVehicle() && IsPlayerDriver() && IsVehicleLightEnabled() && AutoEnableLights)
		SendChat("/cveh licht")
	}
if(RegStr(ChatOutput, "* Das Fraktionsfahrzeug kann nicht bewegt werden, da eine Parkkralle angeheftet wurde.") && EnableAPI && IsPlayerDriver())
	CarLocked := 1
if(RegStr(ChatOutput, "* Das Fahrzeug kann nicht bewegt werden, da eine Parkkralle angeheftet wurde.") && EnableAPI && IsPlayerDriver())
	CarLocked := 1
if(RegStr(ChatOutput, "SERVICE: Du hast die Gebühren in Höhe von ", " bezahlt und kannst nun wieder fahren.") && EnableAPI && IsPlayerDriver())
	CarLocked := 0
if(RegStr(ChatOutput, "Du hast die Gebühren wegen Falschparkens bezahlt und kannst nun wieder fahren.") && EnableAPI && IsPlayerDriver())
	CarLocked := 0
if(CarLocked && IsPlayerDriver() = 0 && EnableAPI)
	CarLocked := 0

return

:?:t/Killbind::
Suspend, Permit
Sleep, 200
if(EnableKillbinds) {
	KBOSend("/echo Der Killbinder wurde nun {ff0000}deaktiviert{ffffff}.")
	EnableKillbinds := 0
	} else {
	KBOSend("/echo Der Killbinder wurd nun {00ff00}aktiviert{ffffff}.")
	EnableKillbinds := 1
	}
Hotkey, enter, on
return

:?:t/vs::
Suspend, Permit
sleep, 200
Label_VS:
KBOSend("/" vsChat " Benötige Verstärkung in [Zone] ([City]), Fortbewegungsmittel: [Vehicle]",,1)
Hotkey, enter, on
return

:?:t/setvs::
Suspend, Permit
sleep, 200
Eingabeaufforderung(vsChat, "In welchen Chat soll /vs senden?", "/")
if(vsChat) {
	IniWrite, %vsChat%, %inipath%, Settings, vsChat
	KBOSend("/echo Verstärkung wird nun den den " (EnableAPI ? """" : """/" ) vsChat """-Chat gerufen")
	}
Hotkey, enter, on
return

:?:t/NoMath::
:?:t/Math::
Suspend, Permit
Sleep, 200
Eingabeaufforderung(Math, "Rechnung: ")
if(!Math) {
	KBOSend("/echo Keine Eingabe erkannt!")
	Hotkey, enter, on
	return
	}
KBOSend("/echo " Math " = " (((MathResult := StrCalc(Math)) != "") ? floorDecimal(MathResult, 2) : "Fehler"))
Hotkey, enter, on
return

:?:t/MoveOverlay::
:?:t/MoveOverlay LSD::
:?:t/MoveOverlay Car::
:?:t/MoveOverlay Plant::
:?:t/MoveOverlay Cont::
:?:t/MoveOverlay Skin::
Suspend, Permit
sleep, 200
if(!EnableAPI) {
	KBOSend("/echo Die Overlays sind nur mit API verfügbar.")
	Hotkey, enter, on
	return
	}
if(StrLen(A_ThisLabel) = 16) {
	KBOSend("/echo Fehler: /MoveOverlay [LSD/Car/Plant/Cont/Skin]")
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
if(nOverlayPos[1])
	SaveIni()
BlockInput, Off
Hotkey, enter, on
return

:?:t/join::
Suspend, Permit
sleep, 200
KBOSend("/join", 200)
KBOSend("/accept job", 200)
KBOSend("/quitjob")
Hotkey, enter, on
return

:?:t/SetKills::
Suspend, Permit
Sleep, 200
Eingabeaufforderung(NewKills, "Ich habe so viele Morde: ")
if(NewKills)
	IniWrite, %NewKills%, %inipath%, Kills, GesamteKills
LoadIni()
Hotkey, enter, on
return

:?:t/SetDeaths::
Suspend, Permit
sleep, 200
Eingabeaufforderung(NewDeaths, "Ich bin so oft gestorben: ")
if(NewDeaths)
	IniWrite, %NewDeaths%, %inipath%, Kills, GesamteDeaths
LoadIni()
Hotkey, enter, on
return

:?:t/API::
Suspend, Permit
sleep, 200
if(!DefaultAPI) {
	KBOSend("/echo Die API lässt sich nicht aktivieren.")
	EnableAPI := 0
	return
	}
IniRead, EnableAPI, %inipath%, Settings, EnableAPI, 0
if(EnableAPI) {
	SendInput, {F6}/echo API deaktiviert.{enter}
	EnableAPI := 0
	} else {
	SendInput, {F6}/echo API aktiviert.{enter}
	EnableAPI := 1
	}
IniWrite, %EnableAPI%, %inipath%, Settings, EnableAPI
Hotkey, enter, on
return

:?:t/DefMoney::
Suspend, Permit
sleep, 200
Eingabeaufforderung(varSetMoney, "Wie viel Geld möchtest du auf der Hand haben: ")
if(EnableAPI) {
	NewMoney := GetPlayerMoney()
	KBOSend("/bankmenu")
	sleep, 200
	if(NewMoney > varSetMoney) {
		SendInput, {enter}
		varNewMoney := NewMoney - varSetMoney
		} else {
		SendInput, {esc}
		varNewMoney := varSetMoney - NewMoney
		}
		sleep, 200
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
sleep, 200
KBOSend("/housewithdraw")
varHWD := 1
Hotkey, enter, on
return

:?:t/DebugVisual::
Suspend, Permit
sleep, 200
if(EnableAPI) {
	DestroyAllVisual()
	KBOSend("/echo Overlays entfernt!")
	CarhealOverlayCreate := 0
	LSDOverlayCreate := 0
	}
Hotkey, enter, on
return

:?:t/GetCont::
:?:t/GetPlant::
Suspend, Permit
sleep, 200
if(!LoginState) {
	KBOSend("/echo Sie müssen für diese Funktion angemeldet sein.")
	Hotkey, enter, on
	return
	}
Farm := BoboRequest(UserName, UserPass, "GetObject")
Hotkey, enter, on
return

:?:t/p::
Suspend, Permit
sleep, 200
KBOSend("/p")
sleep, 100
if(CallinText)
	KBOSend(CallinText)
Hotkey, enter, on
return

:?:t/h::
Suspend, Permit
sleep, 200
if(CalloutText)
	KBOSend(CalloutText)
Sleep, 100
KBOSend("/h")
Hotkey, enter, on
return

:?:t/PlayerData::
Suspend, Permit
sleep, 200
AskPlayerName(SearchPlayer, "ID oder Name des Spielers: ")
LoadPlayerData := BoboRequest(UserName,,,,,,,SearchPlayer,RegMode)
HomepagePlayer(LoadPlayerData[1], LoadPlayerData[2], LoadPlayerData[3])
Hotkey, enter, on
return

:?:t/FrakDataID::
Suspend, Permit
sleep, 200
SendOnlyID := 1
GoTo, FrakInfo
return

:?:t/AllFrakData::
Suspend, Permit
GetAllFrakData := 1
GoTo, FrakInfo
return

:?:t/FrakData::
Suspend, Permit
GetAllFrakData := 0
SendOnlyID := 0
FrakInfo:
sleep, 200
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
KBOSend("/echo Die Mitglieder der Fraktion " Frak_Name[FoundFrak] " werden geladen...")
if(GetAllFrakData) {
	LoadFrakData := BoboRequest(UserName,, "frakinfo",,,,FoundFrak)
	} else {
	HomepageFrak(FoundFrak, SendOnlyID)
	}
SendOnlyID := 0
GetAllFrakData := 0
Hotkey, enter, on
return



;~ ##########################################
;~ ############ Own Functions ###############
;~ ##########################################

InitStartUp(ProgTask) {
	IniRead, ProgPath, %inipath%, Einstellungen, Prog%ProgTask%Path, 0
	if(ProgPath != 0) {
		SplitPath, ProgPath, ProgDat
		IfWinNotExist, ahk_exe %pProgDat%
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
	IniRead, Callin, %inipath%, Einstellungen, Callin, 0
	IniRead, Callout, %inipath%, Einstellungen, Callout, 0
	
	IniRead, ActionOnLSDText, %inipath%, Einstellungen, ActionOnLSDText, ERROR
	if(ActionOnLSDText = "ERROR")
		ActionOnLSDText := ""
	
	IniRead, HotkeyToggle, %inipath%, Einstellungen, HotkeyToggle, ERROR
	if(HotkeyToggle = "ERROR")
		HotkeyToggle := ""
	
	IniRead, ActivePremium, %inipath%, Einstellungen, ActivePremium, 0
	IniRead, AutoSwitchGun, %inipath%, Einstellungen, AutoSwitchGun, 0
	IniRead, VSHotkey, %inipath%, Einstellungen, VSHotkey, ERROR
	if(VSHotkey = "ERROR")
		VSHotkey := ""

	IniRead, BigMapX, %inipath%, Overlay, BigMapX, 570
	IniRead, BigMapY, %inipath%, Overlay, BigMapY, 295
	IniRead, SkinPosX, %inipath%, Overlay, SkinPosX, 770
	IniRead, SkinPosY, %inipath%, Overlay, SkinPosY, 380
	
	IniRead, CarOverlayX, %inipath%, Overlay, CarOverlayX, 180
	IniRead, CarOverlayY, %inipath%, Overlay, CarOverlayY, 480
	IniRead, LSDOverlayX, %inipath%, Overlay, LSDOverlayX, 180
	IniRead, LSDOverlayY, %inipath%, Overlay, LSDOverlayY, 460
	
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
	
	IniWrite, %AutoEnableEngine%, %inipath%, Settings, AutoEnableEngine
	IniWrite, %vsChat%, %inipath%, Settings, vsChat
	
	Loop, %AnzKillbinds%
		IniWrite, % KillbindText%A_Index%, %inipath%, Killbinds, KillbindText%A_Index%
	
	Loop, %AnzKeybinds%
		{
		IniWrite, % KeybindHotkey%A_Index%, %inipath%, Keybinds, KeybindHotkey%A_Index%
		IniWrite, % KeybindText%A_Index%, %inipath%, Keybinds, KeybindText%A_Index%
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
	
	IniWrite, %AutoEnableEngine%, %inipath%, Einstellungen, AutoEnableEngine
	IniWrite, %AutoEnableLights%, %inipath%, Einstellungen, AutoEnableLights
	IniWrite, %AutoSendWPs%, %inipath%, Einstellungen, AutoSendWPs
	
	IniWrite, %MouseButton1%, %inipath%, Einstellungen, MouseButton1
	IniWrite, %MouseButton2%, %inipath%, Einstellungen, MouseButton2
	
	IniWrite, %CallinText%, %inipath%, Einstellungen, CallinText
	IniWrite, %CalloutText%, %inipath%, Einstellungen, CalloutText
	IniWrite, %Callin%, %inipath%, Einstellungen, Callin
	IniWrite, %Callout%, %inipath%, Einstellungen, Callout
	
	IniWrite, %ActionOnLSDText%, %inipath%, Einstellungen, ActionOnLSDText
	
	IniWrite, %HotkeyToggle%, %inipath%, Einstellungen, HotkeyToggle
	IniWrite, %ActivePremium%, %inipath%, Einstellungen, ActivePremium
	IniWrite, %AutoSwitchGun%, %inipath%, Einstellungen, AutoSwitchGun
	IniWrite, %VSHotkey%, %inipath%, Einstellungen, VSHotkey
	
	IniWrite, %CarOverlayX%, %inipath%, Overlay, CarOverlayX
	IniWrite, %CarOverlayY%, %inipath%, Overlay, CarOverlayY
	IniWrite, %LSDOverlayX%, %inipath%, Overlay, LSDOverlayX
	IniWrite, %LSDOverlayY%, %inipath%, Overlay, LSDOverlayY
	
	IniWrite, %BigMapX%, %inipath%, Overlay, BigMapX
	IniWrite, %BigMapY%, %inipath%, Overlay, BigMapY
	IniWrite, %SkinPosX%, %inipath%, Overlay, SkinPosX
	IniWrite, %SkinPosY%, %inipath%, Overlay, SkinPosY
	
	Loop, 3
		{
		IniWrite, % StartUpProg%A_Index%, %inipath%, Einstellungen, StartUpProg%A_Index%
		IniWrite, % StartProgButton%A_Index%, %inipath%, Einstellungen, StartProgButton%A_Index%
		}
	
	return
	}

StartEngine() {
	if(!EnableAPI)
		return
	IfWinNotActive, ahk_exe gta_sa.exe
		return
	if(IsPlayerInAnyVehicle() && IsPlayerDriver() && IsVehicleEngineEnabled() = 0) {
		KBOSend("/cveh motor")
		}
	sleep, 200
	return
	}
StartLights() {
	if(!EnableAPI)
		return
	IfWinNotActive, ahk_exe gta_sa.exe
		return
	if(IsPlayerInAnyVehicle() && IsPlayerDriver() && IsVehicleLightEnabled() = 0) {
		KBOSend("/cveh licht")
		}
	sleep, 200
	}
LatestChat(ByRef output) {
	global DisableChats, DisableKilltrigger, MightKilled, HitCon_Name, varSetMoney, varHWD
	NewChatCount := GetChatLineCount()
	if(DisableChats > 0) {
		DisableChats -= 1
		CurrentChatCount += 1
		output := 0
		return
		}
	if(NewChatCount > CurrentChatCount) {
		NewLine := NewChatCount - CurrentChatCount -1
		GetChatLine(NewLine, LatestOutput)
		if(InStr(LatestOutput, "mit der ID ") && InStr(LatestOutput, "flüstert dir"))
			DisableChats := 1
		CurrentChatCount += 1
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
	if(EnableAPI) {
		SaveClip()
		DoClip .= "`nBestätigen mit Enter, leerlassen bricht ab"
		ShowDialog(DialogIndex, 1, "Eingabeaufforderung", DoClip, "Drücke Enter", "")
		DialogIndex += 1
		Suspend, Toggle
		SetKeyDelay, 200
		if(PreSend)
			SendInput, %PreSend%
		KeyWait, enter, D
		Suspend, Toggle
		SendInput, ^a^c
		while(!Clipboard)
			Sleep, 2
		output := Clipboard
		SendInput, {backspace}
		SetKeyDelay, -1
		LoadClip()
		} else {
		sleep, 200
		SaveClip()
		Clipboard := "/echo " DoClip
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
		}
	return output
	}

RegStr(String, Needle, Needle2="", Needle3="") {
	Pos := RegExMatch(String, "(:|\*).*\Q" Needle "\E", output)
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
	if(!silent) {
		StringLower, currentGUILower, currentGUI
		GuiControl,, Navigation%currentGUI%, img/button_%currentGUILower%.png
		GuiControl,, Navigation%tabName%, img/button_active%tabName%.png
		if(currentGUI = "einstellungen2")
			GuiControl,, NavigationEinstellungen, img/button_einstellungen.png
		if(currentGUI = "informationen2")
			GuiControl,, vNavigationInformationen, img/button_informationen.png
		}
	currentGUI:= tabName
	Loop, 10
		{
		i:= A_Index
		section:= (i == 1 ? "killbinds" : (i == 2 ? "keybinds" : (i == 3 ? "frakbinds" : (i == 4 ? "autonom" : (i == 5 ? "informationen" : (i == 6 ? "informationen2" : (i == 7 ? "einstellungen" : (i == 8 ? "einstellungen2" : (i == 9 ? "login" : (i == 10 ? "speichern" : "wtfahkduarsch"))))))))))
		 ;~ {killbinds: [], keybinds: [], frakbinds: [], autonom: [], informationen: [], informationen2: [], einstellungen: [], einstellungen2: [], login: []}
		For, index, element in elements[section] {
			GuiControl, Hide, %element%
			}
		}
	For, index, element in elements[tabName] {
		GuiControl, Show, %element%
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
