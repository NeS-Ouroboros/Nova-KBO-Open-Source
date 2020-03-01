OVERSION := "5.0.1"
BoboPath := A_AppData "\Bobo"
IfNotExist, %BoboPath%
{
    FileCreateDir, %BoboPath%
    FileCreateDir, %BoboPath%\bin
    FileCreateDir, %BoboPath%\img
    FileCreateDir, %BoboPath%\audio
}
SetWorkingDir %BoboPath%
inipath := A_WorkingDir "\config.ini"
IfNotExist, %inipath%
{
    IniWrite, +1 Kill in [Zone] für [Name]!, %inipath%, Killbinds, KillbindText1
    IniWrite, /echo Das war der {ff0000}[GKills] {ffffff}Snack!, %inipath%, Killbinds, KillbindText2
    IniWrite, 3, %inipath%, Keybinds, KeybindHotkey1
    IniWrite, /use donut, %inipath%, Keybinds, KeybindText1
    IniWrite, SERVER: Willkommen, %inipath%, Autonom, AutonomReact1
    IniWrite, /echo Willkommen [Name]!, %inipath%, Autonom, AutonomAction1
}
global PROZESSNAME
GroupAdd, ProzessGroup, ahk_exe gta_sa.exe
#IfWinActive, ahk_group ProzessGroup
#UseHook
#InstallKeybdHook
#SingleInstance, Force
#Persistent
#HotString EndChars `n
#HotString ?
HotstringHead := ":X:"
#NoEnv
SetBatchLines, -1
StringCaseSense, Off
/*

ToDo:
Plant-Overlay #TEXTAUSGABE

Interaktives Overlay #erweitern

Hinweismeldungen #needed?

#MOD ZEUGS
reeveh
afksuche

*/

OS := GetOS()

if (!A_IsCompiled) {
    Run %A_ScriptDir%\OB.exe
    ExitApp
}

if (!A_IsAdmin) {
    try {
        Run *RunAs %A_ScriptFullPath%
    } catch {
        MsgBox, 68, % gVars["gui"]["title"], % "Bitte führe den Keybinder als Admin aus`nNur so kann die Funktionalität gewahrt werden"
        IfMsgBox, Yes
        {
            Reload
        }
    }
}

IfNotExist, %A_WorkingDir%\bin\Open-SAMP-API.dll
{
    URLDownloadToFile, https://ourororo.de/killbinder/api/Open-SAMP-API.dll, API.dll
    FileMove, API.dll, %A_WorkingDir%\bin\Open-SAMP-API.dll, 1
}
UsedButtons := []
UsedButtons.Push("gtasa.png")
UsedButtons.Push("playericon.png")
UsedButtons.Push("marker.png")
UsedButtons.Push("button_anmelden.png")
UsedButtons.Push("button_gast.png")
UsedButtons.Push("button_speichern.png")
UsedButtons.Push("button_autonom.png")
UsedButtons.Push("button_einstellungen.png")
UsedButtons.Push("button_frakbinds.png")
UsedButtons.Push("button_informationen.png")
UsedButtons.Push("button_keybinds.png")
UsedButtons.Push("button_killbinds.png")
UsedButtons.Push("button_textbinds.png")
UsedButtons.Push("button_groupbinds.png")
UsedButtons.Push("button_activeautonom.png")
UsedButtons.Push("button_activeeinstellungen.png")
UsedButtons.Push("button_activefrakbinds.png")
UsedButtons.Push("button_activeinformationen.png")
UsedButtons.Push("button_activekeybinds.png")
UsedButtons.Push("button_activekillbinds.png")
UsedButtons.Push("button_activetextbinds.png")
UsedButtons.Push("button_activegroupbinds.png")
Loop % UsedButtons.MaxIndex()
{
    IfNotExist, % A_WorkingDir "\img\" UsedButtons[A_Index]
    URLDownloadToFile, % "https://ourororo.de/killbinder/img/" UsedButtons[A_Index], % A_WorkingDir "\img\" UsedButtons[A_Index]
}

if (A_ScriptDir != A_WorkingDir) {
    OldPlace := RegExReplace(A_ScriptFullPath, "\.exe$", ".lnk")
    FileCreateShortcut, %A_WorkingDir%\KbO.exe, %OldPlace%
    FileMove, %A_ScriptFullPath%, %A_WorkingDir%\KbO.exe, 1
    Run *RunAs %A_WorkingDir%\KbO.exe
    ExitApp
}

IfExist, %A_WorkingDir%\OldBinder.Trash
FileDelete, %A_WorkingDir%\OldBinder.Trash

IfExist, %A_WorkingDir%\ToDelete.ini
{
    IniRead, ToDelete, %A_WorkingDir%\ToDelete.ini, Old, OldExe, 0
    if (ToDelete)
        FileDelete, %ToDelete%
    FileDelete, %A_WorkingDir%\ToDelete.ini
}

global gVars := {}
gVars["user"] := {}
gVars["kills"] := {}
gVars["general"] := {}
gVars["general"]["version"] := OVERSION
gVars["general"]["CarLocked"] := 0
gVars["general"]["loop"] := {"cmd": [], "timer": "", "index": 0}
gVars["dVar"] := {"count": 100, "content": {}}
Loop % gVars["dVar"]["count"]
{
    Hotstring(HotstringHead "t/SetVar " A_Index, "Set_dVar", "On")
}
Loop 20
{
    HotString(HotstringHead "t/Forum " A_Index, "AcceptForum", "On")
}
gVars["chat"] := {"content": 0
, "currentLine": 0
, "DisableChat": 0
, "DisableKill": 0
, "SimKill": 0
, "hit_name": 0
, "addwanted": {"limit": 0, "value": 0, "desc": 0}
, "SetBank": 0
, "GetURL": 0}
gVars["gui"] := {"title": "OBinder"
, "kill": {"count": 16, "page": 1, "content": []}
, "key": {"count": 16, "page": 3, "content": []}
, "text": {"count": 16, "page": 3, "content": []}
, "auto": {"count": 8, "page": 3, "content": []}
, "frak": {"count": 10, "page": 1, "content": []}
, "group": {"count": 10, "page": 1, "content": []}
, "settings": {"count": 0, "page": 3}
, "info": {"count": 0, "page": 1}
, "font": {"type": "Times New Roman", "size": {Label: "36", normal: "12", Desc: "20"}}
, "color": {"bg": "424242", "main": "60ff78", "second": "f0ff56", "text": "ffd026"}
, "ig_color": { "Bobo": "cdff5b", "Echo": "3aebff", "Error": "ff0000", "Success": "00ff00", "Warning": "ff7800", "White": "ffffff", "Name": "e2ffb2", "Level": "b2ffbe"
, "Handy": "b2fdff", "Info": "ffbb00", "debug": "ff5100", "highlight": "74e1ed"}
, "position": {"w": 1200, "h": 640, "btn-y": 600}
, "elements": {"login": [], "pager": []}
, "siteelements": []
, "needapi": []
, "addhover": []
, "currentGUI": "login"}
gVars["counts"] := {"forum": 10, "posbind": 150}
gVars["pos"] := []
gVars["fixpos"] := []
gVars["sound"] := {"info": "*-1", "warn": "*16"}
gVars["plant_obj"] := {"typ": {1: "Container", 2: "Hanf", 3: "Gold", 4: "Brauerei", "Container": "1", "Hanf": "2", "Gold": "3", "Brauerei": "4"}
, "care": {1: "gegossen.", 2: "gedüngt.", 3: "mit Ammoniak versorgt.", 4: "mit Natronlauge versorgt.", 5: "mit Wasser versorgt.", 6: "mit Mais versorgt."}}

Loop % (gVars["gui"]["kill"]["count"] * gVars["gui"]["kill"]["page"])
{
    gVars["gui"]["kill"]["content"].Push({})
}
Loop % (gVars["gui"]["key"]["count"] * gVars["gui"]["key"]["page"])
{
    gVars["gui"]["key"]["content"].Push({})
}
Loop % (gVars["gui"]["text"]["count"] * gVars["gui"]["text"]["page"])
{
    gVars["gui"]["text"]["content"].Push({})
}
Loop % (gVars["gui"]["auto"]["count"] * gVars["gui"]["auto"]["page"])
{
    gVars["gui"]["auto"]["content"].Push({})
}
Loop % (gVars["gui"]["frak"]["count"] * gVars["gui"]["frak"]["page"])
{
    gVars["gui"]["frak"]["content"].Push({})
}
Loop % (gVars["gui"]["group"]["count"] * gVars["gui"]["group"]["page"])
{
    gVars["gui"]["group"]["content"].Push({})
}

truckerlist := ["403", "413", "414", "455", "456", "478", "498", "499", "514", "515", "578"]
gVars["vehicles"] := {"all": ["Landstalker", "Bravura", "Buttalo", "Linerunner", "Perennial", "Sentinel", "Dumper", "Firetruck", "Trashmaster", "Stretch"
, "Manana", "Infernus", "Voodoo", "Pony", "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam", "Esperanto", "Taxi", "Washington", "Bobcat", "Mr. Whoopee"
, "BF Injection", "Hunter", "Premier", "Enforcer", "Securicar", "Banshee", "Predator", "Bus", "PANZAH", "Barracks", "Hotknife", "Trailer", "Previon", "Coach"
, "Cabbie", "Stallion", "Rumpo", "RC Bandit", "Romero", "Packer", "Monster", "Admiral", "Squallo", "Seasparrow", "Pizzaboii", "Tram", "Trailer", "Turismo"
, "Speeder", "Reefer", "Tropic", "Flatbed", "Yankee", "Ich hab Cojones", "Solari", "Barkley's RC", "Skimmer", "PCJ-600", "Faggio", "Freeway", "RC Baron"
, "RC Raider", "Glendale", "Oceanic", "Sanchez", "Sparrow", "Patriot", "Quad", "Coastguard", "Dinghy", "Hermes", "Sabre", "Rustler", "ZR-350", "Walton"
, "Regina", "Comet", "BMX", "Burrito", "Mutterschiff", "Marquis", "Baggage", "Dozer", "Maverick", "News Heli", "Rancher", "FBI Rancher", "Virgo", "Greenwood"
, "Jetmax", "Hotring Ranger", "Sandking", "Blista Compact", "Police Heli", "Boxville", "Benson", "Mesa", "RC Goblin", "Hotring Racer A", "Hotring Racer B"
, "Bloodring Banger", "Rancher Lure", "Super GT", "Elegant", "Journey", "Bike", "Mountain Bike", "Beagle", "Cropduster", "Stuntplane", "Tanker", "Roadtrain"
, "Nebula", "Majestic", "Buccaneer", "Shamal", "Hydra", "FCR-900", "NRG-500", "HPV1000", "Cement Truck", "TowTruck", "Fortune", "Cadrona", "FBI Truck", "Willard"
, "Forklift", "Tractor", "Combine Harvester", "Fletzer", "Remington", "Slamvan", "Blade", "Train", "Train", "Vortex", "Vincent", "Bullet", "Clover", "Sadler"
, "Firetruck LA", "Hustler", "Intruder", "Primo", "Cargobob", "Tampa", "Sunrise", "Merit", "Utility Van", "Nevada", "Yosemite", "Windsor", "Monster A", "Monster B"
, "Uranus", "Jester", "Sultan", "Stratum", "Elegy", "Raindance", "RC Tiger", "Flash", "Tahoma", "Savanna", "Bandito", "Train Trailer", "Train Trailer", "Kart"
, "Mower", "Dune", "Sweeper", "Broadway", "Tornado", "AT400", "DFT-30", "Huntley", "Stafford", "BF-400", "Newsvan", "Tug", "Trailer", "Emperor", "Wayfarer", "Euros"
, "Hotdog", "Club", "Train Trailer", "Trailer", "Andromada", "Dodo", "RC Cam", "Launch", "LSPD-Car", "SFPD-Car", "LVPD-Car", "Police Ranger", "Picador", "S.W.A.T."
, "Alpha", "Phönix", "Glendale", "Sadler", "Baggage Trailer", "Baggage Trailer", "Tug Trailer", "Boxville", "Combine Gear", "Utility Trailer"]
, "trucks": truckerlist}
gVars["weapons"] := ["Faust", "Schlagring", "Golfschläger", "Schlagstock", "Schlitzer", "Baseballschläger", "Schaufel", "Pool Stock", "Katana", "Kettensäge"
, "Doppelpenetrator", "Penetrator", "Langer Vibrator", "Kurzer Vibrator", "Blumen", "Gehstock", "Granate", "Tränengas", "Molotiv Cocktail", "", "", "", "9mm"
, "Schallgedämpfte 9mm", "Deagle", "Schrotflinte", "Abgesägte Schrotflinte", "Automatische Schrotflinte", "SMG", "MP5", "AK-47", "M4", "Tec-9", "Jägdgewehr"
, "Scharfschützengewehr", "RPG", "Hitzesuchende Rakete", "HANZ GET ZE FLAMMENWERFER", "RATATATAT", "Fernzünder", "Fernz" _üe "nder", "Spray", "Feuerlöscher", "Kamera"
, "Nachtsichtgerät", "Thermalgerät", "Fallschirm", "Fake Pistol", "Fahrzeug", "Rotor", "Explosion", "Ertrunken", "Schwerkraft"]
gVars["sard"] := {"list": ["Firetruck", "Ambulance", "Police Heli", "Premier", "Yankee", "Raindance", "Police Ranger", "Bullet"], "saved": []}
gVars["login"] := {0: "Gast", 1: "Angemeldet"}
gVars["truck"] := {"list": truckerlist, "sort": ["Erfahrung aufsteigend", "Geld aufsteigend", "Erfahrung absteigend", "Geld absteigend"], "ddl": "Erfahrung aufsteigend|Geld aufsteigend|Erfahrung absteigend|Geld absteigend"}
gVars["path"] := {"bobo": BoboPath, "ini": inipath, "chat": 0, "samp": 0}
OVERSION := BoboPath := inipath := truckerlist := ""
TransferConfig()
gVars["overlay"] := {"font": {"type": "Times New Roman", "size": 14}
, "car": new overlay("car")
, "use": new overlay("use")
, "lsd": new overlay("lsd")
, "ot": new overlay("ot")
, "map": new overlay("map")
, "race": new overlay("race")
, "skin": new overlay("skin")
, "plant": new overlay("plant")
, "wanted": new overlay("wanted")
, "inv": new overlay("inv")}

gVars["api"] := new api()
gVars["web"] := new bobocon(gVars["user"]["name"], gVars["user"]["key"])
gVars["marks"] := new mark()
LoadIni()

UpdateSettings := gVars["web"].rawdownload("https://ourororo.de/killbinder/Version.ini?user=" gVars["user"]["name"])
nVersion := ValRead(UpdateSettings, "Settings", "Version", "3.951")
nDL := ValRead(UpdateSettings, "Settings", "DLink", "https://ourororo.de/killbinder/KbO3.951.exe")
nChangelog := ValRead(UpdateSettings, "Settings", "Changelog", "NoChangelog")
if (nVersion != gVars["general"]["version"]) {
    UpdateText := "Es wurde ein Update gefunden!`nDie aktuelle Version ist: [AktVersion]`nDie neue Version ist [NewVersion]`n`n"
    UpdateText .= "Möchtest du jetzt das Update herunterladen und installieren?`n`nChangelog:`n•"
    UpdateText := RegExReplace(RegExReplace(UpdateText, "Ui)\Q[AktVersion]\E", gVars["general"]["version"]), "Ui)\Q[NewVersion]\E", nVersion)
    nChangelog := RegExReplace(RegExReplace(nChangelog, "Ui)\Q[n]\E", "`n• "), "Ui)\Q[v]\E", "`n> ")
    MsgBox, 68, % gVars["gui"]["title"] " - Updater", % UpdateText nChangelog
    IfMsgBox, Yes
    {
        force_dl: ;
        FileMove, %A_WorkingDir%\KbO.exe, %A_WorkingDir%\OldBinder.Trash, 1
        URLDownloadToFile, % nDL, % A_WorkingDir "\KbO.exe"
        IfExist, %A_WorkingDir%\KbO.exe
        {
            Run *RunAs %A_WorkingDir%\KbO.exe
        } else {
            FileMove, %A_WorkingDir%\OldBinder.Trash, %A_WorkingDir%\KbO.exe, 1
            ;HOPPLA
        }
        ExitApp
    }
}

Gui, main:color, % gVars["gui"]["color"]["bg"]
setFont(gVars["gui"]["font"]["size"]["normal"])
KillbindDesc := "Hier können Killbinds eingetragen werden. Von den vorhandenen Killspr" _üe "chen wird einer Zufällig ausgewählt, derselbe Killspruch kann nicht 2x "
KillbindDesc .= "hintereinander erscheinen. Variablen stehen im Reiter ""Informationen"""
KeybindDesc := "Hier können Keybinds eingetragen werden. Auf der linken Seite wird der Hotkey eingetragen und rechts davon der zu sendende Text. "
KeybindDesc .= "Variablen stehen im Reiter ""Informationen"""
AutonomDesc := "Hier können Autonome Keybinds eingetragen werden. Auf der linken Seite wird eingetragen auf was der Keybinder reagieren soll. "
AutonomDesc .= "Steht die gesuchte Nachricht im Chat (ungeachtet Groß- & Kleinschreibung) wird der rechte Text gesendet."
InformationDesc := "Hier stehen Informationen zum " gVars["gui"]["title"] "`n`nVersion: " gVars["general"]["version"]
InformationHomepage := "Der Link zur Homepage ist https://ourororo.de (klick mich)"
FrakbindDesc := "Der Inhalt der Frakbinds werden von den Leadern über die Homepage eingestellt. Hier kann man dann die gewänschten Hotkeys zum Senden eintragen.`n`n"
FrakbindDesc .= "ACHTUNG: Die Frakbinds können sich immer ändern! Überprüfe vor der Nutzung ob die Keybinds richtig sind!"
GroupbindDesc := "Der Inhalt der Groupbinds werden von den Leadern über die Homepage eingestellt. Hier kann man dann die gewänschten Hotkeys zum Senden eintragen.`n`n"
GroupbindDesc .= "ACHTUNG: Die Groupbinds können sich immer ändern! Überprüfe vor der Nutzung ob die Keybinds richtig sind!"
EinstellungenDesc := "Some Random I/O Stuff"
TextbindDesc := "Hier können Textbinds eingetragen werden`nAuf der linken Seite wird der Befehl, z.B. ""/op"" eingetragen`nIn dem rechten Textfeld davon dann die "
TextbindDesc .= "Aktion wie ""/me wird zu einem Marshmallow"""

Gui, main:add, Text, % "x" 230 " y" 10 " h" 80 " w" 960 " vKillbindDesc c" gVars["gui"]["color"]["text"] " +Hidden", % KillbindDesc
Gui, main:add, Text, % "x" 230 " y" 10 " h" 80 " w" 960 " vKeybindDesc c" gVars["gui"]["color"]["text"] " +Hidden", % KeybindDesc
Gui, main:add, Text, % "x" 230 " y" 10 " h" 80 " w" 960 " vAutonomDesc c" gVars["gui"]["color"]["text"] " +Hidden", % AutonomDesc
Gui, main:add, Text, % "x" 230 " y" 10 " h" 80 " w" 960 " vInformationDesc c" gVars["gui"]["color"]["text"] " +Hidden", % InformationDesc
Gui, main:add, Text, % "x" 230 " y" 80 " h" 30 " w" 960 " vInformationHomepage c" gVars["gui"]["color"]["text"] " +Hidden gInformationHomepage", % InformationHomepage
Gui, main:add, Text, % "x" 230 " y" 10 " h" 80 " w" 960 " vFrakbindDesc c" gVars["gui"]["color"]["text"] " +Hidden", % FrakbindDesc
Gui, main:add, Text, % "x" 230 " y" 10 " h" 80 " w" 960 " vGroupbindDesc c" gVars["gui"]["color"]["text"] " +Hidden", % GroupbindDesc
Gui, main:add, Text, % "x" 230 " y" 10 " h" 80 " w" 960 " vEinstellungenDesc c" gVars["gui"]["color"]["text"] " +Hidden", % EinstellungenDesc
Gui, main:add, Text, % "x" 230 " y" 10 " h" 80 " w" 960 " vTextbindDesc c" gVars["gui"]["color"]["text"] " +Hidden", % TextbindDesc
Gui, main:add, activeX, % "x" 230 " y" 80 " h" (620 - 80) " w" (1190 - 230) " vInfoWB +Hidden", Shell.Explorer
InfoWB.navigate("https://ourororo.de/killbinder/help")
InfoWB.silent := True

Loop % gVars["gui"]["kill"]["page"]
{
    gVars["gui"]["elements"]["killbinds" A_Index] := []
    gVars["gui"]["elements"]["killbinds" A_Index].Push("KillbindDesc")
    gVars["gui"]["siteelements"].Push("killbinds" A_Index)
}
Loop % gVars["gui"]["key"]["page"]
{
    gVars["gui"]["elements"]["keybinds" A_Index] := []
    gVars["gui"]["elements"]["keybinds" A_Index].Push("KeybindDesc")
    gVars["gui"]["siteelements"].Push("keybinds" A_Index)
}
Loop % gVars["gui"]["text"]["page"]
{
    gVars["gui"]["elements"]["textbinds" A_Index] := []
    gVars["gui"]["elements"]["textbinds" A_Index].Push("TextbindDesc")
    gVars["gui"]["siteelements"].Push("textbinds" A_Index)
}
Loop % gVars["gui"]["auto"]["page"]
{
    gVars["gui"]["elements"]["autonom" A_Index] := []
    gVars["gui"]["elements"]["autonom" A_Index].Push("AutonomDesc")
    gVars["gui"]["siteelements"].Push("autonom" A_Index)
}
Loop % gVars["gui"]["frak"]["page"]
{
    gVars["gui"]["elements"]["frakbinds" A_Index] := []
    gVars["gui"]["elements"]["frakbinds" A_Index].Push("FrakbindDesc")
    gVars["gui"]["siteelements"].Push("frakbinds" A_Index)
}
Loop % gVars["gui"]["group"]["page"]
{
    gVars["gui"]["elements"]["groupbinds" A_Index] := []
    gVars["gui"]["elements"]["groupbinds" A_Index].Push("GroupbindDesc")
    gVars["gui"]["siteelements"].Push("groupbinds" A_Index)
}
Loop % gVars["gui"]["settings"]["page"]
{
    gVars["gui"]["elements"]["einstellungen" A_Index] := []
    gVars["gui"]["elements"]["einstellungen" A_Index].Push("EinstellungenDesc")
    gVars["gui"]["siteelements"].Push("einstellungen" A_Index)
}
Loop % gVars["gui"]["info"]["page"]
{
    gVars["gui"]["elements"]["informationen" A_Index] := []
    gVars["gui"]["elements"]["informationen" A_Index].Push("InformationDesc")
    gVars["gui"]["elements"]["informationen" A_Index].Push("InformationHomepage")
    gVars["gui"]["elements"]["informationen" A_Index].Push("InfoWB")
    gVars["gui"]["siteelements"].Push("informationen" A_Index)
}

Gui, main:Add, Picture, % "x" 10 " y" 10 " vNavigationKillbinds gCallbackKillbinds", img/button_killbinds.png
Gui, main:Add, Picture, % "x" 10 " y" 80 " vNavigationKeybinds gCallbackKeybinds", img/button_keybinds.png
Gui, main:Add, Picture, % "x" 10 " y" 150 " vNavigationTextbinds gCallbackTextbinds", img/button_textbinds.png
Gui, main:Add, Picture, % "x" 10 " y" 220 " vNavigationFrakbinds gCallbackFrakbinds", img/button_frakbinds.png
Gui, main:add, Picture, % "x" 10 " y" 290 " vNavigationGroupbinds gCallbackGroupbinds", img/button_groupbinds.png
Gui, main:Add, Picture, % "x" 10 " y" 360 " vNavigationAutonom gCallbackAutonom", img/button_autonom.png
Gui, main:Add, Picture, % "x" 10 " y" 430 " vNavigationInformationen gCallbackInformationen", img/button_informationen.png
Gui, main:Add, Picture, % "x" 10 " y" 500 " vNavigationEinstellungen gCallbackEinstellungen", img/button_einstellungen.png
Gui, main:Add, Picture, % "x" 10 " y" 570 " gCallbackSpeichern", img/button_speichern.png

setFont(gVars["gui"]["font"]["size"]["Label"])
Gui, main:add, Text, % "x" 230 " y" 40 " vLoginText c" gVars["gui"]["color"]["text"], Login
setFont(gVars["gui"]["font"]["size"]["Desc"])
Gui, main:add, Text, % "x" 280 " y" 150 " w" 150 " vLoginNameText c" gVars["gui"]["color"]["text"] " +Right", Benutzername
Gui, main:add, Text, % "x" 280 " y" 200 " w" 150 " vLoginPassText c" gVars["gui"]["color"]["text"] " +Right", Passwort
Gui, main:Add, Picture, % "x" 460 " y" 250 " vLoginUserPicAnmelden gCallbackLoginUser", img/button_anmelden.png
Gui, main:Add, Picture, % "x" 760 " y" 250 " vLoginUserPicGast gCallbackLoginGast", img/button_gast.png
setFont(gVars["gui"]["font"]["size"]["normal"])
Gui, main:Add, Button, % "x" 0 " y" 0 " h" 0 " w" 0 " vDefaultLogin gDefaultLogin +Hidden +Default", K
Gui, main:add, Edit, % "x" 460 " y" 150 " w" 500 " vLoginName", % gVars["user"]["name"]
Gui, main:add, Edit, % "x" 460 " y" 200 " w" 500 " vLoginPass +Password*"

Gui, main:Add, Text, % "x" 220 " y" 0 " w" 10 " h" gVars["gui"]["position"]["h"] " c" gVars["gui"]["color"]["second"] " +0x11", ;Vertikale Linie
Gui, main:Add, Text, % "x" 221 " y" 100 " w" 979 " c" gVars["gui"]["color"]["second"] " +0x10", ;Horizontale Linie

gVars["gui"]["elements"]["login"].Push("LoginText")
gVars["gui"]["elements"]["login"].Push("LoginNameText")
gVars["gui"]["elements"]["login"].Push("LoginPassText")
gVars["gui"]["elements"]["login"].Push("LoginUserPicAnmelden")
gVars["gui"]["elements"]["login"].Push("LoginUserPicGast")
gVars["gui"]["elements"]["login"].Push("DefaultLogin")
gVars["gui"]["elements"]["login"].Push("LoginName")
gVars["gui"]["elements"]["login"].Push("LoginPass")
gVars["user"]["login"] := -1

Gui, main:add, Text, % "x" 1070 " y" (gVars["gui"]["position"]["btn-y"] - 20) " h" 30 " vPagerDesc  c" gVars["gui"]["color"]["text"] " +Hidden", Seiten:
Gui, main:add, Button, % "x" 1070 " y" gVars["gui"]["position"]["btn-y"] " h" 30 " w" 30 " vBtnPager1 gPager1 +Hidden", 1
Gui, main:add, Button, % "x" 1100 " y" gVars["gui"]["position"]["btn-y"] " h" 30 " w" 30 " vBtnPager2 gPager2 +Hidden", 2
Gui, main:add, Button, % "x" 1130 " y" gVars["gui"]["position"]["btn-y"] " h" 30 " w" 30 " vBtnPager3 gPager3 +Hidden", 3
Gui, main:add, Button, % "x" 1160 " y" gVars["gui"]["position"]["btn-y"] " h" 30 " w" 30 " vBtnPager4 gPager4 +Hidden", 4

gVars["gui"]["elements"]["pager"].Push("PagerDesc")
gVars["gui"]["elements"]["pager"].Push("BtnPager1")
gVars["gui"]["elements"]["pager"].Push("BtnPager2")
gVars["gui"]["elements"]["pager"].Push("BtnPager3")
gVars["gui"]["elements"]["pager"].Push("BtnPager4")

Loop % gVars["gui"]["kill"]["page"]
{
    1stIndex := A_Index
    Loop % gVars["gui"]["kill"]["count"]
    {
        kIndex := ((1stIndex - 1) * gVars["gui"]["kill"]["count"]) + A_Index
        if (A_Index <= (gVars["gui"]["kill"]["count"]/2)) {
            koordY := (50*A_Index)+60
            Gui, main:add, Edit, % "x" 230 " y" koordY " w" 450 " h" 30 " v_gui_kill_text_" kIndex " -VScroll +Hidden", % gVars["gui"]["kill"]["content"][kIndex]["Text"]
        } else {
            koordY := (50*(A_Index - (gVars["gui"]["kill"]["count"]/2)))+60
            Gui, main:add, Edit, % "x" 740 " y" koordY " w" 450 " h" 30 " v_gui_kill_text_" kIndex " -VScroll +Hidden", % gVars["gui"]["kill"]["content"][kIndex]["Text"]
        }
        gVars["gui"]["elements"]["killbinds" 1stIndex].Push("_gui_kill_text_" kIndex)
    }
}

Loop % gVars["gui"]["key"]["page"]
{
    1stIndex := A_Index
    Loop % gVars["gui"]["key"]["count"]
    {
        kIndex := ((1stIndex - 1) * gVars["gui"]["key"]["count"]) + A_Index
        if (A_Index <= (gVars["gui"]["key"]["count"]/2)) {
            koordY := (50*A_Index)+60
            Gui, main:add, Hotkey, % "x" 230 " y" koordY " w" 60 " h" 30 " v_gui_key_key_" kIndex " -VScroll +Hidden", % gVars["gui"]["key"]["content"][kIndex]["Key"]
            Gui, main:add, Edit, % "x" 300 " y" koordY " w" 380 " h" 30 " v_gui_key_text_" kIndex " -VScroll +Hidden", % gVars["gui"]["key"]["content"][kIndex]["Text"]
        } else {
            koordY := (50*(A_Index - (gVars["gui"]["key"]["count"]/2)))+60
            Gui, main:add, Hotkey, % "x" 740 " y" koordY " w" 60 " h" 30 " v_gui_key_key_" kIndex " -VScroll +Hidden", % gVars["gui"]["key"]["content"][kIndex]["Key"]
            Gui, main:add, Edit, % "x" 810 " y" koordY " w" 380 " h" 30 " v_gui_key_text_" kIndex " -VScroll +Hidden", % gVars["gui"]["key"]["content"][kIndex]["Text"]
        }
        gVars["gui"]["elements"]["keybinds" 1stIndex].Push("_gui_key_key_" kIndex)
        gVars["gui"]["elements"]["keybinds" 1stIndex].Push("_gui_key_text_" kIndex)
    }
}

Loop % gVars["gui"]["text"]["page"]
{
    1stIndex := A_Index
    Loop % gVars["gui"]["text"]["count"]
    {
        kIndex := ((1stIndex - 1) * gVars["gui"]["text"]["count"]) + A_Index
        if (A_Index <= (gVars["gui"]["text"]["count"]/2)) {
            koordY := (50*A_Index)+60
            Gui, main:add, Edit, % "x" 230 " y" koordY " w" 100 " h" 30 " v_gui_text_react_" kIndex " -VScroll +Hidden", % gVars["gui"]["text"]["content"][kIndex]["React"]
            Gui, main:add, Edit, % "x" 340 " y" koordY " w" 340 " h" 30 " v_gui_text_act_" kIndex " -VScroll +Hidden", % gVars["gui"]["text"]["content"][kIndex]["Act"]
        } else {
            koordY := (50*(A_Index - (gVars["gui"]["text"]["count"]/2)))+60
            Gui, main:add, Edit, % "x" 740 " y" koordY " w" 100 " h" 30 " v_gui_text_react_" kIndex " -VScroll +Hidden", % gVars["gui"]["text"]["content"][kIndex]["React"]
            Gui, main:add, Edit, % "x" 850 " y" koordY " w" 340 " h" 30 " v_gui_text_act_" kIndex " -VScroll +Hidden", % gVars["gui"]["text"]["content"][kIndex]["Act"]
        }
        gVars["gui"]["elements"]["textbinds" 1stIndex].Push("_gui_text_react_" kIndex)
        gVars["gui"]["elements"]["textbinds" 1stIndex].Push("_gui_text_act_" kIndex)
    }
}

Loop % gVars["gui"]["auto"]["page"]
{
    1stIndex := A_Index
    Loop % gVars["gui"]["auto"]["count"]
    {
        kIndex := ((1stIndex - 1) * gVars["gui"]["auto"]["count"]) + A_Index
        Gui, main:add, Edit, % "x" 230 " y" (50*A_Index)+60 " w" 450 " h" 30 " v_gui_auto_react_" kIndex " -VScroll +Hidden", % gVars["gui"]["auto"]["content"][kIndex]["React"]
        Gui, main:add, Edit, % "x" 740 " y" (50*A_Index)+60 " w" 450 " h" 30 " v_gui_auto_act_" kIndex " -VScroll +Hidden", % gVars["gui"]["auto"]["content"][kIndex]["Act"]
        gVars["gui"]["elements"]["autonom" 1stIndex].Push("_gui_auto_react_" kIndex)
        gVars["gui"]["elements"]["autonom" 1stIndex].Push("_gui_auto_act_" kIndex)
    }
}

Gui, main:show, % "w" gVars["gui"]["position"]["w"] " h" gVars["gui"]["position"]["h"], % gVars["gui"]["title"]
if (EnableAutoLogin && gVars["user"]["remember"]) {
    GoTo, CallbackLoginUser
}
return
StartGUI: ;

gVars["fraktions"] := gVars["web"].download("loadfraktions")
loop, % gVars["fraktions"].MaxIndex()
{
    gVars["fraktions"][A_Index]["color"] := StrSplit(gVars["fraktions"][A_Index]["color"], "|")
}

gVars["user"]["login"] := gVars["user"]["lcon"]["login"]
if (gVars["user"]["lcon"]["frakid"] != 0) {
    if (gVars["user"]["frakid"] != gVars["user"]["lcon"]["frakid"]) {
        URLDownloadToFile, % "https://nes-newlife.de/image/fractions/" gVars["user"]["lcon"]["frakid"], % A_WorkingDir "\img\FraktionSplashArt.png"
    }
    Gui, main:add, Picture, % "x" 230 " y" gVars["gui"]["position"]["btn-y"] - 230 " h" 200 " w" 960 " vImg_Fraktion +Hidden", % A_WorkingDir "\img\FraktionSplashArt.png"
    gVars["gui"]["elements"]["frakbinds1"].Push("Img_Fraktion")
}
gVars["user"]["frakid"] := gVars["user"]["lcon"]["frakid"]
SaveIni()
gVars["general"]["fraktion_chat"] := (InStr(FraktionInArray(gVars["user"]["frakid"], "ID", "Typ"), "Staat") ? "/r" : (gVars["user"]["frakid"] = 0 ? "/echo" : "/f"))

Loop % (gVars["gui"]["frak"]["count"] * gVars["gui"]["frak"]["page"])
{
    gVars["gui"]["frak"]["content"][A_Index]["Text"] := gVars["user"]["lcon"]["f" A_Index]
}
Loop % (gVars["gui"]["group"]["count"] * gVars["gui"]["group"]["page"])
{
    gVars["gui"]["group"]["content"][A_Index]["Text"] := gVars["user"]["lcon"]["g" A_Index]
}

gVars["user"]["name"] := LoginName
gVars["user"]["key"] := gVars["user"]["remember"] := gVars["user"]["lcon"]["rem"]
if (!gVars["user"]["remember"]) {
    gVars["user"]["key"] := LoginPass
}
LoginName := LoginPass := ""
SaveIni()

gVars["wpbinds"] := gVars["web"].download("wpbinds")

gVars["bizdata"] := {}
gVars["bizdata"][9] := {"name": "BSN Tankstelle"
, "Flag1": {"name": "Angel Pine Tankstelle", "x": -1544, "y": -2737, "z": 100}
, "Flag2": {"name": "LV Baseballstadion", "x": 1369, "y": 2195, "z": 100}
, "Flag3": {"name": "Kuh-Gebiet", "x": -795, "y": 1557, "z": 100}}
gVars["bizdata"][10] := {"name": "GS Tankstelle"
, "Flag1": {"name": "LV Arena", "x": 1097, "y": 1605, "z": 100}
, "Flag2": {"name": "San Fierro Kraftwerk", "x": -1033, "y": -695, "z": 100}
, "Flag3": {"name": "Fort Carson", "x": -42, "y": 1082, "z": 100}}
gVars["bizdata"][11] := {"name": "Truckstop Tankstelle"
, "Flag1": {"name": "Prison Grube", "x": -126, "y": 2257, "z": 100}
, "Flag2": {"name": "Catalinas Hütte", "x": 889, "y": -24, "z": 100}
, "Flag3": {"name": "Hütte über SF Tunnel", "x": -1431, "y": -964, "z": 100}}
gVars["bizdata"][12] := {"name": "Dillimore Tankstelle"
, "Flag1": {"name": "Angel Pine Holzhütte", "x": -1633, "y": -2239, "z": 100}
, "Flag2": {"name": "Basketballplatz Rock Hotel", "x": 2584, "y": 2427, "z": 100}
, "Flag3": {"name": "Bayside Campingplatz", "x": -2458, "y": 2513, "z": 100}}
gVars["bizdata"][13] := {"name": "SF Bahnhof Tankstelle"
, "Flag1": {"name": "Staudamm", "x": -915, "y": 2010, "z": 100}
, "Flag2": {"name": "LS Airport", "x": 1999, "y": -2381, "z": 100}
, "Flag3": {"name": "Palomino Creek OC", "x": 2240, "y": -80, "z": 100}}
gVars["bizdata"][14] := {"name": "SFPD Tankstelle"
, "Flag1": {"name": "Ehemalige FBI Base", "x": -10, "y": -2515, "z": 100}
, "Flag2": {"name": "Bayside Heli-Plattform", "x": -2227, "y": 2325, "z": 100}
, "Flag3": {"name": "Ehemalige KF Base", "x": 947, "y": 2069, "z": 100}}
gVars["bizdata"][15] := {"name": "SF Carshop Tankstelle"
, "Flag1": {"name": "Flugzeugfriedhof", "x": 154, "y": 2414, "z": 100}
, "Flag2": {"name": "LV Fort Carson Steg", "x": -640, "y": 865, "z": 100}
, "Flag3": {"name": "Aussichtsplattform weißes Haus", "x": 1027, "y": -2179, "z": 100}}
gVars["bizdata"][16] := {"name": "Prison Tankstelle"
, "Flag1": {"name": "Ehemaliges LCN Hotel", "x": 303, "y": -1514, "z": 100}
, "Flag2": {"name": "East LS Strand", "x": 2937, "y": -2051, "z": 100}
, "Flag3": {"name": "SF Airport Hangar", "x": -1447, "y": -513, "z": 100}}
gVars["bizdata"][17] := {"name": "Angel Pine Tankstelle"
, "Flag1": {"name": "SF Airport Landebahn", "x": -1031, "y": 460, "z": 100}
, "Flag2": {"name": "El Quebrados", "x": -1481, "y": 2625, "z": 100}
, "Flag3": {"name": "Erzmine", "x": 389, "y": 875, "z": 100}}
gVars["bizdata"][20] := {"name": "4Dragons Tankstelle"
, "Flag1": {"name": "Hangar Toter Flughafen", "x": 325, "y": 2543, "z": 100}
, "Flag2": {"name": "Blueberry Apartments", "x": 183, "y": -107, "z": 100}
, "Flag3": {"name": "Heilige Makrele", "x": -1378, "y": 2111, "z": 100}}
gVars["bizdata"][21] := {"name": "Tankstelle Bayside"
, "Flag1": {"name": "Baustelle SF Bahnhof", "x": -2132, "y": 166, "z": 100}
, "Flag2": {"name": "Holzhütte an der Farm", "x": -552, "y": -192, "z": 100}
, "Flag3": {"name": "Montgomery", "x": 1304, "y": 339, "z": 100}}

for key_name, key_value in gVars["bizdata"]
{
    Hotstring(HotstringHead "t/BizData " key_name, "bizlabel", "On")
}

Loop % gVars["gui"]["frak"]["page"]
{
    1stIndex := A_Index
    Loop % gVars["gui"]["frak"]["count"]
    {
        kIndex := ((1stIndex - 1) * gVars["gui"]["frak"]["count"]) + A_Index
        if (A_Index <= (gVars["gui"]["frak"]["count"]/2)) {
            koordY := (50*A_Index)+60
            Gui, main:add, Hotkey, % "x" 230 " y" koordY " w" 60 " h" 30 " v_gui_frak_key_" kIndex " +Hidden", % gVars["gui"]["frak"]["content"][kIndex]["Key"]
            Gui, main:add, Edit, % "x" 300 " y" koordY " w" 380 " h" 30 " v_gui_frak_text_" kIndex " c" gVars["gui"]["color"]["second"] " -VScroll +Hidden +ReadOnly", % gVars["gui"]["frak"]["content"][kIndex]["Text"]
        } else {
            koordY := (50*(A_Index - (gVars["gui"]["frak"]["count"]/2)))+60
            Gui, main:add, Hotkey, % "x" 740 " y" koordY " w" 60 " h" 30 " v_gui_frak_key_" kIndex " +Hidden", % gVars["gui"]["frak"]["content"][kIndex]["Key"]
            Gui, main:add, Edit, % "x" 810 " y" koordY " w" 380 " h" 30 " v_gui_frak_text_" kIndex " c" gVars["gui"]["color"]["second"] " -VScroll +Hidden +ReadOnly", % gVars["gui"]["frak"]["content"][kIndex]["Text"]
        }
        gVars["gui"]["elements"]["frakbinds" 1stIndex].Push("_gui_frak_key_" kIndex)
        gVars["gui"]["elements"]["frakbinds" 1stIndex].Push("_gui_frak_text_" kIndex)
    }
}

Loop % gVars["gui"]["group"]["page"]
{
    1stIndex := A_Index
    Loop % gVars["gui"]["group"]["count"]
    {
        kIndex := ((1stIndex - 1) * gVars["gui"]["group"]["count"]) + A_Index
        if (A_Index <= (gVars["gui"]["group"]["count"]/2)) {
            koordY := (50*A_Index)+60
            Gui, main:add, Hotkey, % "x" 230 " y" koordY " w" 60 " h" 30 " v_gui_group_key_" kIndex " +Hidden", % gVars["gui"]["group"]["content"][kIndex]["Key"]
            Gui, main:add, Edit, % "x" 300 " y" koordY " w" 380 " h" 30 " v_gui_group_text_" kIndex " c" gVars["gui"]["color"]["second"] " -VScroll +Hidden +ReadOnly", % gVars["gui"]["group"]["content"][kIndex]["Text"]
        } else {
            koordY := (50*(A_Index - (gVars["gui"]["group"]["count"]/2)))+60
            Gui, main:add, Hotkey, % "x" 740 " y" koordY " w" 60 " h" 30 " v_gui_group_key_" kIndex " +Hidden", % gVars["gui"]["group"]["content"][kIndex]["Key"]
            Gui, main:add, Edit, % "x" 810 " y" koordY " w" 380 " h" 30 " v_gui_group_text_" kIndex " c" gVars["gui"]["color"]["second"] " -VScroll +Hidden +ReadOnly", % gVars["gui"]["group"]["content"][kIndex]["Text"]
        }
        gVars["gui"]["elements"]["groupbinds" 1stIndex].Push("_gui_group_key_" kIndex)
        gVars["gui"]["elements"]["groupbinds" 1stIndex].Push("_gui_group_text_" kIndex)
    }
}

Gui, main:add, Checkbox, % "x" 230 " y" 110 " w" 450 " h" 30 " vEnableAPI checked" EnableAPI " c" gVars["gui"]["color"]["text"] " +Hidden", % "API einschalten"
Gui, main:add, Checkbox, % "x" 230 " y" 140 " w" 450 " h" 30 " vEnableAutoLogin checked" EnableAutoLogin " c" gVars["gui"]["color"]["text"] " +Hidden", % "Automatisch in Keybinder einloggen"
Gui, main:add, Checkbox, % "x" 230 " y" 170 " w" 450 " h" 30 " vEnableTelegram checked" EnableTelegram " c" gVars["gui"]["color"]["text"] " +Hidden", % "Telegram verwenden"
Gui, main:add, Checkbox, % "x" 230 " y" 200 " w" 450 " h" 30 " vEnableAutoGun checked" EnableAutoGun " c" gVars["gui"]["color"]["text"] " +Hidden", % "Als Beifahrer automatisch /swapgun"
Gui, main:add, Checkbox, % "x" 230 " y" 230 " w" 450 " h" 30 " vEnablePremium checked" EnablePremium " c" gVars["gui"]["color"]["text"] " +Hidden", % "Du hast einen Nova-eSports Premiumaccount"
Gui, main:add, Checkbox, % "x" 230 " y" 260 " w" 450 " h" 30 " vEnableAutoEngine checked" EnableAutoEngine " c" gVars["gui"]["color"]["text"] " +Hidden", % "Automatisch Motor einschalten"
Gui, main:add, Checkbox, % "x" 230 " y" 290 " w" 450 " h" 30 " vEnableAutoLight checked" EnableAutoLight " c" gVars["gui"]["color"]["text"] " +Hidden", % "Automatisch Licht einschalten"
Gui, main:add, Checkbox, % "x" 230 " y" 320 " w" 450 " h" 30 " vEnableWPChat checked" EnableWPChat " c" gVars["gui"]["color"]["text"] " +Hidden", % "WP-Vergabe in den Verstärkungschat"
Gui, main:add, Checkbox, % "x" 230 " y" 350 " w" 450 " h" 30 " vEnableKillbinder checked" EnableKillbinder " c" gVars["gui"]["color"]["text"] " +Hidden", % "Killbinder aktivieren"
Gui, main:add, Checkbox, % "x" 230 " y" 380 " w" 450 " h" 30 " vEnableArtefakt checked" EnableArtefakt " c" gVars["gui"]["color"]["text"] " +Hidden", % "Artefaktfundorte hochladen"
Gui, main:add, Checkbox, % "x" 230 " y" 410 " w" 450 " h" 30 " vEnableHistory checked" EnableHistory " c" gVars["gui"]["color"]["text"] " +Hidden", % "Chatlogs protokollieren"
Gui, main:add, Checkbox, % "x" 230 " y" 440 " w" 450 " h" 30 " vEnableFGet checked" EnableFGet " c" gVars["gui"]["color"]["text"] " +Hidden", % "Automatisches /accept fget [Rang 4+]"
Gui, main:add, Checkbox, % "x" 250 " y" 470 " w" 450 " h" 30 " vEnableDeskFGet checked" EnableDeskFGet " c" gVars["gui"]["color"]["text"] " +Hidden", % "accept fget vom Desktop aus erlauben"
Gui, main:add, Checkbox, % "x" 230 " y" 500 " w" 450 " h" 30 " vEnableForenThreads checked" EnableForenThreads " c" gVars["gui"]["color"]["text"] " +Hidden", % "InGame-Benachrichtung bei neuen Forenbeiträgen"
Gui, main:add, Checkbox, % "x" 230 " y" 530 " w" 450 " h" 30 " vEnableTeamspeak checked" EnableTeamspeak " c" gVars["gui"]["color"]["text"] " +Hidden", % "InGame-Benachrichtigung bei neuen Teamspeak-Nachrichten"

Gui, main:add, Checkbox, % "x" 740 " y" 110 " w" 450 " h" 30 " v_overlay_enable_mmss checked" _overlay_enable_mmss " c" gVars["gui"]["color"]["text"] " +Hidden", % "Timer in Minuten statt Sekunden anzeigen"
Gui, main:add, Checkbox, % "x" 740 " y" 140 " w" 450 " h" 30 " v_overlay_enable_use checked" gVars["overlay"]["use"]["enable"] " c" gVars["gui"]["color"]["text"] " +Hidden", % "/USE-Overlay einschalten"
Gui, main:add, Checkbox, % "x" 740 " y" 170 " w" 450 " h" 30 " v_overlay_enable_lsd checked" gVars["overlay"]["lsd"]["enable"] " c" gVars["gui"]["color"]["text"] " +Hidden", % "LSD-Overlay einschalten"
Gui, main:add, Checkbox, % "x" 740 " y" 200 " w" 450 " h" 30 " v_overlay_enable_car checked" gVars["overlay"]["car"]["enable"] " c" gVars["gui"]["color"]["text"] " +Hidden", % "Carheal-Overlay einschalten"
Gui, main:add, Checkbox, % "x" 740 " y" 230 " w" 450 " h" 30 " v_overlay_enable_ot checked" gVars["overlay"]["ot"]["enable"] " c" gVars["gui"]["color"]["text"] " +Hidden", % "Variablen-Timer-Overlay einschalten"
Gui, main:add, Checkbox, % "x" 740 " y" 260 " w" 450 " h" 30 " v_overlay_enable_inv checked" gVars["overlay"]["inv"]["enable"] " c" gVars["gui"]["color"]["text"] " +Hidden", % "Inventar-Overlay einschalten"
Gui, main:add, Checkbox, % "x" 740 " y" 290 " w" 450 " h" 30 " v_overlay_enable_wanted checked" gVars["overlay"]["wanted"]["enable"] " c" gVars["gui"]["color"]["text"] " +Hidden", % "Wanted-Overlay einschalten"
Gui, main:add, Checkbox, % "x" 740 " y" 350 " w" 450 " h" 30 " vEnableHitsound checked" EnableHitsound " c" gVars["gui"]["color"]["text"] " +Hidden", % "Hitsound aktivieren (selber getroffen werden)"

Gui, main:add, Button, % "x" 230 " y" 600 " w" 240 " h" 30 " vStartSAMP gStartSAMP c" gVars["gui"]["color"]["text"] " +Hidden", % "SAMP starten"
Gui, main:add, Button, % "x" 480 " y" 600 " w" 240 " h" 30 " vStartCHAT gStartCHAT c" gVars["gui"]["color"]["text"] " +Hidden", % "Chatlog öffnen"
Gui, main:add, Button, % "x" 730 " y" 600 " w" 240 " h" 30 " vforce_dl gforce_dl c" gVars["gui"]["color"]["text"] " +Hidden", % "Update erzwingen"

gVars["gui"]["elements"]["einstellungen1"].Push("EnableAPI")
gVars["gui"]["elements"]["einstellungen1"].Push("EnableAutoLogin")
gVars["gui"]["elements"]["einstellungen1"].Push("EnableTelegram")
gVars["gui"]["elements"]["einstellungen1"].Push("EnableAutoGun")
gVars["gui"]["elements"]["einstellungen1"].Push("EnablePremium")
gVars["gui"]["elements"]["einstellungen1"].Push("EnableAutoEngine")
gVars["gui"]["elements"]["einstellungen1"].Push("EnableAutoLight")
gVars["gui"]["elements"]["einstellungen1"].Push("EnableWPChat")
gVars["gui"]["elements"]["einstellungen1"].Push("EnableKillbinder")
gVars["gui"]["elements"]["einstellungen1"].Push("EnableArtefakt")
gVars["gui"]["elements"]["einstellungen1"].Push("EnableHistory")
gVars["gui"]["elements"]["einstellungen1"].Push("EnableFGet")
gVars["gui"]["elements"]["einstellungen1"].Push("EnableDeskFGet")
gVars["gui"]["elements"]["einstellungen1"].Push("EnableForenThreads")
gVars["gui"]["elements"]["einstellungen1"].Push("EnableTeamspeak")
gVars["gui"]["needapi"].Push("EnableAutoGun")
gVars["gui"]["needapi"].Push("EnableAutoEngine")
gVars["gui"]["needapi"].Push("EnableAutoLight")
gVars["gui"]["needapi"].Push("EnableDeskFGet")
gVars["gui"]["needapi"].Push("EnableForenThreads")
gVars["gui"]["needapi"].Push("EnableTeamspeak")

gVars["gui"]["elements"]["einstellungen1"].Push("_overlay_enable_use")
gVars["gui"]["elements"]["einstellungen1"].Push("_overlay_enable_lsd")
gVars["gui"]["elements"]["einstellungen1"].Push("_overlay_enable_car")
gVars["gui"]["elements"]["einstellungen1"].Push("_overlay_enable_ot")
gVars["gui"]["elements"]["einstellungen1"].Push("_overlay_enable_inv")
gVars["gui"]["elements"]["einstellungen1"].Push("_overlay_enable_wanted")
gVars["gui"]["elements"]["einstellungen1"].Push("_overlay_enable_mmss")
gVars["gui"]["elements"]["einstellungen1"].Push("EnableHitsound")
gVars["gui"]["needapi"].Push("_overlay_enable_use")
gVars["gui"]["needapi"].Push("_overlay_enable_lsd")
gVars["gui"]["needapi"].Push("_overlay_enable_car")
gVars["gui"]["needapi"].Push("_overlay_enable_ot")
gVars["gui"]["needapi"].Push("_overlay_enable_inv")
gVars["gui"]["needapi"].Push("_overlay_enable_wanted")
gVars["gui"]["needapi"].Push("EnableHitsound")

gVars["gui"]["elements"]["einstellungen1"].Push("StartSAMP")
gVars["gui"]["elements"]["einstellungen1"].Push("StartCHAT")
gVars["gui"]["elements"]["einstellungen1"].Push("force_dl")

Gui, main:add, Hotkey, % "x" 740 " y" 110 " w" 60 " h" 30 " v_suspend_toggle_hotkey +Hidden +Limit0", % _suspend_toggle_hotkey
Gui, main:add, Text, % "x" 810 " y" 115 " w" 380 " h" 30 " v_suspend_toggle_text c" gVars["gui"]["color"]["text"] " +Hidden", % "Hotkey für: Keybinder de-/aktivieren"
Gui, main:add, Hotkey, % "x" 740 " y" 150 " w" 60 " h" 30 " v_walksim_activate_key +Hidden +Limit0", % _walksim_activate_key
Gui, main:add, Text, % "x" 810 " y" 155 " w" 380 " h" 30 " v_walksim_activate_text c" gVars["gui"]["color"]["text"] " +Hidden", % "Hotkey für: Laufskript de-/aktivieren"
Gui, main:add, Hotkey, % "x" 740 " y" 190 " w" 60 " h" 30 " v_walksim_trigger_key +Hidden +Limit0", % _walksim_trigger_key
Gui, main:add, Text, % "x" 810 " y" 195 " w" 380 " h" 30 " v_walksim_trigger_text c" gVars["gui"]["color"]["text"] " +Hidden", % "Deine Sprinttaste"
Gui, main:add, Button, % "x" 1160 " y" 150 " w" 30 " h" 70 " v_walksim_help_btn c" gVars["gui"]["color"]["text"] " g_walksim_help_btn +Hidden", % "?"
Gui, main:add, Hotkey, % "x" 740 " y" 230 " w" 60 " h" 30 " v_toggle_map_key +Hidden +Limit0", % _toggle_map_key
Gui, main:add, Text, % "x" 810 " y" 235 " w" 380 " h" 30 " v_toggle_map_text c" gVars["gui"]["color"]["text"] " +Hidden", % "Mapoverlay de-/aktivieren"
Gui, main:add, Hotkey, % "x" 740 " y" 270 " w" 60 " h" 30 " v_open_mv_key +Hidden +Limit0", % _open_mv_key
Gui, main:add, Text, % "x" 810 " y" 275 " w" 380 " h" 30 " v_open_mv_text c" gVars["gui"]["color"]["text"] " +Hidden", % "Doppeldrück für /mv + /oldmv"

Gui, main:add, Edit, % "x" 230 " y" 110 " w" 200 " h" 30 " v_trucker_level +Hidden +Number", % _trucker_level
Gui, main:add, Text, % "x" 440 " y" 115 " w" 240 " h" 30 " v_trucker_text c" gVars["gui"]["color"]["text"] " +Hidden", % "Dein Truckerlevel"
Gui, main:add, DDL, % "x" 230 " y" 150 " w" 200 " h" 30 " v_trucker_sort_ddl c" gVars["gui"]["color"]["text"] "+Hidden +R10 +AltSubmit Choose" _trucker_sort_ddl, % gVars["truck"]["ddl"]
Gui, main:add, Text, % "x" 440 " y" 155 " w" 240 " h" 30 " v_trucker_sort_text c" gVars["gui"]["color"]["text"] " +Hidden", % "Deine /Truckdata-Sortierung"
Gui, main:add, Edit, % "x" 230 " y" 190 " w" 200 " h" 30 " v_process_name +Hidden", % PROZESSNAME
Gui, main:add, Text, % "x" 440 " y" 195 " w" 240 " h" 30 " v_process_text c" gVars["gui"]["color"]["text"] " +Hidden", % "Dein GTA Prozessname"
Gui, main:add, Edit, % "x" 230 " y" 230 " w" 200 " h" 30 " v_mouse_4_edit +Hidden", % _mouse_4_edit
Gui, main:add, Text, % "x" 440 " y" 235 " w" 240 " h" 30 " v_mouse_4_text c" gVars["gui"]["color"]["text"] " +Hidden", % "Maustaste 4"
Gui, main:add, Edit, % "x" 230 " y" 270 " w" 200 " h" 30 " v_mouse_5_edit +Hidden", % _mouse_5_edit
Gui, main:add, Text, % "x" 440 " y" 275 " w" 240 " h" 30 " v_mouse_5_text c" gVars["gui"]["color"]["text"] " +Hidden", % "Maustaste 5"
Gui, main:add, Edit, % "x" 230 " y" 310 " w" 200 " h" 30 " v_call_p_edit +Hidden", % _call_p_edit
Gui, main:add, Text, % "x" 440 " y" 315 " w" 240 " h" 30 " v_call_p_text c" gVars["gui"]["color"]["text"] " +Hidden", % "Anruf annehmen (/p)"
Gui, main:add, Edit, % "x" 230 " y" 350 " w" 200 " h" 30 " v_call_h_edit +Hidden", % _call_h_edit
Gui, main:add, Text, % "x" 440 " y" 355 " w" 240 " h" 30 " v_call_h_text c" gVars["gui"]["color"]["text"] " +Hidden", % "Anruf ablehnen (/h)"
Gui, main:add, Edit, % "x" 230 " y" 390 " w" 200 " h" 30 " v_call_abw_edit +Hidden", % _call_abw_edit
Gui, main:add, Text, % "x" 440 " y" 395 " w" 240 " h" 30 " v_call_abw_text c" gVars["gui"]["color"]["text"] " +Hidden", % "Anrufbeantworter (/abw)"
Gui, main:add, Edit, % "x" 230 " y" 430 " w" 200 " h" 30 " v_vs_setvs_edit +Hidden", % gVars["general"]["vs"]
Gui, main:add, Text, % "x" 440 " y" 435 " w" 240 " h" 30 " v_vs_setvs_text c" gVars["gui"]["color"]["text"] " +Hidden", % "Chat für /vs (wie /f, /gr oder /d)"

gVars["gui"]["elements"]["einstellungen2"].Push("_suspend_toggle_hotkey")
gVars["gui"]["elements"]["einstellungen2"].Push("_suspend_toggle_text")
gVars["gui"]["elements"]["einstellungen2"].Push("_walksim_activate_key")
gVars["gui"]["elements"]["einstellungen2"].Push("_walksim_activate_text")
gVars["gui"]["elements"]["einstellungen2"].Push("_walksim_trigger_key")
gVars["gui"]["elements"]["einstellungen2"].Push("_walksim_trigger_text")
gVars["gui"]["elements"]["einstellungen2"].Push("_walksim_help_btn")
gVars["gui"]["elements"]["einstellungen2"].Push("_toggle_map_key")
gVars["gui"]["elements"]["einstellungen2"].Push("_toggle_map_text")
gVars["gui"]["elements"]["einstellungen2"].Push("_open_mv_key")
gVars["gui"]["elements"]["einstellungen2"].Push("_open_mv_text")

gVars["gui"]["elements"]["einstellungen2"].Push("_trucker_level")
gVars["gui"]["elements"]["einstellungen2"].Push("_trucker_text")
gVars["gui"]["elements"]["einstellungen2"].Push("_trucker_sort_ddl")
gVars["gui"]["elements"]["einstellungen2"].Push("_trucker_sort_text")
gVars["gui"]["elements"]["einstellungen2"].Push("_process_name")
gVars["gui"]["elements"]["einstellungen2"].Push("_process_text")
gVars["gui"]["elements"]["einstellungen2"].Push("_mouse_4_edit")
gVars["gui"]["elements"]["einstellungen2"].Push("_mouse_4_text")
gVars["gui"]["elements"]["einstellungen2"].Push("_mouse_5_edit")
gVars["gui"]["elements"]["einstellungen2"].Push("_mouse_5_text")
gVars["gui"]["elements"]["einstellungen2"].Push("_call_p_edit")
gVars["gui"]["elements"]["einstellungen2"].Push("_call_p_text")
gVars["gui"]["elements"]["einstellungen2"].Push("_call_h_edit")
gVars["gui"]["elements"]["einstellungen2"].Push("_call_h_text")
gVars["gui"]["elements"]["einstellungen2"].Push("_call_abw_edit")
gVars["gui"]["elements"]["einstellungen2"].Push("_call_abw_text")
gVars["gui"]["elements"]["einstellungen2"].Push("_vs_setvs_edit")
gVars["gui"]["elements"]["einstellungen2"].Push("_vs_setvs_text")

Gui, main:add, Checkbox, % "x" 230 " y" 110 " w" 450 " h" 30 " vEnableDestroyObj checked" EnableDestroyObj " c" gVars["gui"]["color"]["text"] " +Hidden", % "[Staat] Plantagen/Container Zerstörung hochladen"
Gui, main:add, Checkbox, % "x" 230 " y" 140 " w" 450 " h" 30 " vEnableACH checked" EnableACH " c" gVars["gui"]["color"]["text"] " +hidden", % "Cheaterreports in den /a-Chat"

Gui, main:add, Edit, % "x" 230 " y" gVars["gui"]["position"]["btn-y"] - 100 " w" 200 " h" 30 " vSelectChat c" gVars["gui"]["color"]["second"] " +Hidden +ReadOnly +Right", % gVars["path"]["chat"]
Gui, main:add, Button, % "x" 440 " y" gVars["gui"]["position"]["btn-y"] - 100 " w" 240 " h" 30 " v_chat_btn gSelectCHAT c" gVars["gui"]["color"]["text"] " +Hidden", % "Dein Chatlog-Pfad"
Gui, main:add, Edit, % "x" 230 " y" gVars["gui"]["position"]["btn-y"] - 60 " w" 200 " h" 30 " vSelectSAMP c" gVars["gui"]["color"]["second"] " +Hidden +ReadOnly +Right", % gVars["path"]["samp"]
Gui, main:add, Button, % "x" 440 " y" gVars["gui"]["position"]["btn-y"] - 60 " w" 240 " h" 30 " v_samp_btn gSelectSAMP c" gVars["gui"]["color"]["text"] " +Hidden", % "Dein SAMP-Pfad"

Gui, main:add, Edit, % "x" 740 " y" 110 " w" 200 " h" 30 " v_sard_code +Hidden", % gVars["general"]["SardCode"]
Gui, main:add, Text, % "x" 950 " y" 115 " w" 240 " h" 30 " v_sard_text c" gVars["gui"]["color"]["text"] " +Hidden", % "[SARD] Dein FunkCode"

DLL_List := DDLFonts(gVars["overlay"]["font"]["type"])
Gui, main:add, DDL, % "x" 740 " y" gVars["gui"]["position"]["btn-y"] - 100 " w" 200 " h" 30 " v_ov_get_font_ddl gSafeFont c" gVars["gui"]["color"]["text"] " +Hidden +R10 +Sort", % DLL_List
Gui, main:add, Text, % "x" 950 " y" gVars["gui"]["position"]["btn-y"] - 100 " w" 240 " h" 30 " v_ov_get_font_text c" gVars["gui"]["color"]["text"] " +Hidden", % "Schriftart des InGame Overlays"
if (!gVars["overlay"]["font"]["size"]) {
    gVars["overlay"]["font"]["size"] := _ov_get_size_edit := 20
    SaveIni()
}
Gui, main:add, Edit, % "x" 740 " y" gVars["gui"]["position"]["btn-y"] - 60 " w" 200 " h" 30 " v_ov_get_size_edit gSafeSize +Hidden +Number", % gVars["overlay"]["font"]["size"]
Gui, main:add, Text, % "x" 950 " y" gVars["gui"]["position"]["btn-y"] - 60 " w" 240 " h" 30 " v_ov_get_size_text c" gVars["gui"]["color"]["text"] " +Hidden", % "Schriftgröße des InGame Overlays"

gVars["gui"]["elements"]["einstellungen3"].Push("EnableDestroyObj")
if (gVars["user"]["lcon"]["arang"] >= 2) {
    gVars["gui"]["elements"]["einstellungen3"].Push("EnableACH")
}

gVars["gui"]["elements"]["einstellungen3"].Push("SelectCHAT")
gVars["gui"]["elements"]["einstellungen3"].Push("_chat_btn")
gVars["gui"]["elements"]["einstellungen3"].Push("SelectSAMP")
gVars["gui"]["elements"]["einstellungen3"].Push("_samp_btn")

gVars["gui"]["elements"]["einstellungen3"].Push("_sard_code")
gVars["gui"]["elements"]["einstellungen3"].Push("_sard_text")

gVars["gui"]["elements"]["einstellungen3"].Push("_ov_get_font_ddl")
gVars["gui"]["elements"]["einstellungen3"].Push("_ov_get_font_text")
gVars["gui"]["elements"]["einstellungen3"].Push("_ov_get_size_edit")
gVars["gui"]["elements"]["einstellungen3"].Push("_ov_get_size_text")

CreateHotkey(true)
changeTab()
SetTimer, OverallTimer, 100
return
CreateHotkey(aStatus)
{
    global
    local tmpvar
    Loop % (gVars["gui"]["key"]["count"] * gVars["gui"]["key"]["page"])
    {
        if (gVars["gui"]["key"]["content"][A_Index]["Key"] != "") {
            if (aStatus) {
                Hotkey, % gVars["gui"]["key"]["content"][A_Index]["Key"], Label_for_all_Hotkeys, on
            } else {
                Hotkey, % gVars["gui"]["key"]["content"][A_Index]["Key"], Label_for_all_Hotkeys, off
            }
        }
    }
    Loop % (gVars["gui"]["text"]["count"] * gVars["gui"]["text"]["page"])
    {
        if (gVars["gui"]["text"]["content"][A_Index]["React"] != "" && gVars["gui"]["text"]["content"][A_Index]["Act"] != "") {
            if (aStatus) {
                Hotstring(HotstringHead gVars["gui"]["text"]["content"][A_Index]["React"], "HotstringLabel", "On")
            } else {
                Hotstring(HotstringHead gVars["gui"]["text"]["content"][A_Index]["React"], "HotstringLabel", "Off")
            }
        }
    }
    Loop % (gVars["gui"]["frak"]["count"] * gVars["gui"]["frak"]["page"])
    {
        if (gVars["gui"]["frak"]["content"][A_Index]["Key"] != "") {
            if (aStatus) {
                Hotkey, % gVars["gui"]["frak"]["content"][A_Index]["Key"], Label_for_all_Hotkeys, on
            } else {
                Hotkey, % gVars["gui"]["frak"]["content"][A_Index]["Key"], Label_for_all_Hotkeys, off
            }
        }
    }
    Loop % (gVars["gui"]["group"]["count"] * gVars["gui"]["group"]["page"])
    {
        if (gVars["gui"]["group"]["content"][A_Index]["Key"] != "") {
            if (aStatus) {
                Hotkey, % gVars["gui"]["group"]["content"][A_Index]["Key"], Label_for_all_Hotkeys, on
            } else {
                Hotkey, % gVars["gui"]["group"]["content"][A_Index]["Key"], Label_for_all_Hotkeys, off
            }
        }
    }
    Loop % gVars["wpbinds"].MaxIndex()
    {
        if (gVars["wpbinds"][A_Index]["Hotstring1"] != "") {
            if (aStatus) {
                Hotstring(HotstringHead gVars["wpbinds"][A_Index]["Hotstring1"], "HotstringLabel", "On")
            } else {
                Hotstring(HotstringHead gVars["wpbinds"][A_Index]["Hotstring1"], "HotstringLabel", "Off")
            }
        }
        if (gVars["wpbinds"][A_Index]["Hotstring2"] != "") {
            if (aStatus) {
                Hotstring(HotstringHead gVars["wpbinds"][A_Index]["Hotstring2"], "HotstringLabel", "On")
            } else {
                Hotstring(HotstringHead gVars["wpbinds"][A_Index]["Hotstring2"], "HotstringLabel", "Off")
            }
        }
    }
    if (_suspend_toggle_hotkey != "") {
        if (aStatus) {
            Hotkey, % _suspend_toggle_hotkey, ToggleSuspend, on
        } else {
            Hotkey, % _suspend_toggle_hotkey, ToggleSuspend, off
        }
    }
    if (_mouse_4_edit != "") {
        if (aStatus) {
            Hotkey, % "XButton1", Label_for_all_Hotkeys, on
        } else {
            Hotkey, % "XButton1", Label_for_all_Hotkeys, off
        }
    }
    if (_mouse_5_edit != "") {
        if (aStatus) {
            Hotkey, % "XButton2", Label_for_all_Hotkeys, on
        } else {
            Hotkey, % "XButton2", Label_for_all_Hotkeys, off
        }
    }
    if (_walksim_activate_key != "") {
        if (aStatus) {
            Hotkey, % _walksim_activate_key, Label_for_walksim, on
        } else {
            Hotkey, % _walksim_activate_key, Label_for_walksim, off
        }
    }
    if (_walksim_activate_key != "") {
        tmpvar := FixHotkey(_walksim_activate_key)
        if (aStatus) {
            Hotkey, % tmpvar, Label_for_walksim, on
        } else {
            Hotkey, % tmpvar, Label_for_walksim, off
        }
    }
    if (_toggle_map_key != "") {
        if (aStatus) {
            Hotkey, % _toggle_map_key, togglemap, on
        } else {
            Hotkey, % _toggle_map_key, togglemap, off
        }
    }
    if (_open_mv_key != "") {
        if (aStatus) {
            Hotkey, % _open_mv_key, open_mv, on
        } else {
            Hotkey, % _open_mv_key, open_mv, off
        }
    }
}
LoadIni()
{
    global
    local tempvar
    for unused_key, ov_obj in gVars["overlay"]
    {
        ov_obj.load()
    }
    EnableAPI := ReadFunc("Settings", "EnableAPI", 0)
    EnableAutoLogin := ReadFunc("Settings", "EnableAutoLogin", 1)
    if (!EnableAutoLogin) {
        gVars["user"]["remember"] := 0
    }
    EnableTelegram := ReadFunc("Settings", "EnableTelegram", 1)
    EnableAutoGun := ReadFunc("Settings", "EnableAutoGun", 0)
    EnablePremium := ReadFunc("Settings", "EnablePremium", 0)
    EnableAutoEngine := ReadFunc("Settings", "AutoEnableEngine", 1)
    EnableAutoLight := ReadFunc("Settings", "EnableAutoLight", 0)
    EnableWPChat := ReadFunc("Settings", "EnableWPChat", 1)
    EnableKillbinder := ReadFunc("Settings", "EnableKillbinder", 1)
    EnableArtefakt := ReadFunc("Settings", "EnableArtefakt", 1)
    EnableDestroyObj := ReadFunc("Settings", "EnableDestroyObj", 1)
    EnableHistory := ReadFunc("Settings", "EnableHistory", 1)
    EnableFGet := ReadFunc("Settings", "EnableFGet", 1)
    EnableDeskFGet := ReadFunc("Settings", "EnableDeskFGet", 0)
    EnableForenThreads := ReadFunc("Settings", "EnableForenThreads", 0)
    EnableHitsound := ReadFunc("Settings", "EnableHitsound", 0)
    EnableACH := ReadFunc("Settings", "EnableACH", 0)
    EnableTeamspeak := ReadFunc("Settings", "EnableTeamspeak", 0)
    
    _suspend_toggle_hotkey := ReadFunc("Settings", "_suspend_toggle_hotkey", "Nothing")
    _trucker_level := ReadFunc("Settings", "_trucker_level", 1)
    _trucker_sort_ddl := ReadFunc("Settings", "_trucker_sort_ddl", 4)
    _trucker_prev_diff := ReadFunc("Settings", "_trucker_prev_diff", 0)
    PROZESSNAME := ReadFunc("Settings", "PROZESSNAME", "gta_sa.exe")
    
    
    Loop % gVars["dVar"]["count"]
    {
        gVars["dVar"]["content"][A_Index] := ReadFunc("defined vars", "dVar" A_Index, "Nothing")
    }
    
    gVars["user"]["name"] := ReadFunc("Settings", "UserName", "NoName")
    if (gVars["user"]["name"] == "NoName" || !gVars["user"]["name"]) {
        RegRead, tempvar, HKEY_CURRENT_USER\Software\SAMP, PlayerName
        WriteFunc(tempvar, "Settings", "UserName")
        LoadIni()
        return
    }
    
    gVars["user"]["remember"] := ReadFunc("Settings", "RememberCode", 0)
    if (gVars["user"]["remember"]) {
        gVars["user"]["key"] := gVars["user"]["remember"]
    }
    gVars["web"].update(gVars["user"]["name"], gVars["user"]["key"])
    
    gVars["kills"]["gkills"] := ReadFunc("Kills", "GesamteKills", 0)
    gVars["kills"]["gdeaths"] := ReadFunc("Kills", "GesamteDeaths", 0)
    gVars["kills"]["dkills"] := ReadFunc("Kills", "TaeglicheKills", 0)
    gVars["kills"]["ddeaths"] := ReadFunc("Kills", "TaeglicheDeaths", 0)
    gVars["kills"]["streak"] := ReadFunc("Kills", "StreakKills", 0)
    
    gVars["path"]["chat"] := ReadFunc("Settings", "chatlogpath", A_MyDocuments "\GTA San Andreas User Files\SAMP\chatlog.txt")
    gVars["path"]["samp"] := ReadFunc("Settings", "samppath", "Nothing")
    gVars["general"]["vs"] := ReadFunc("Settings", "vsChat", "/f")
    gVars["general"]["SardCode"] := ReadFunc("Frakbinds", "FrakSardCode", "Nothing")
    gVars["user"]["frakid"] := ReadFunc("Settings", "img_frakid", 0)
    gVars["overlay"]["font"]["type"] := ReadFunc("Settings", "ov_font_type", "Times New Roman")
    gVars["overlay"]["font"]["size"] := ReadFunc("Settings", "ov_font_size", 20)
    
    _mouse_4_edit := ReadFunc("mousebinds", "xb1", "Nothing")
    _mouse_5_edit := ReadFunc("mousebinds", "xb2", "Nothing")
    _call_p_edit := ReadFunc("Settings", "_call_p_edit", "Nothing")
    _call_h_edit := ReadFunc("Settings", "_call_h_edit", "Nothing")
    _call_abw_edit := ReadFunc("Settings", "_call_abw_edit", "Nothing")
    _overlay_enable_mmss := ReadFunc("Settings", "_overlay_enable_mmss", "Nothing")
    _walksim_activate_key := ReadFunc("Settings", "_walksim_activate_key", "Nothing")
    _walksim_trigger_key := ReadFunc("Settings", "_walksim_trigger_key", "Nothing")
    _toggle_map_key := ReadFunc("Settings", "_toggle_map_key", "Nothing")
    _open_mv_key := ReadFunc("Settings", "_open_mv_key", "Nothing")
    
    Loop % (gVars["gui"]["kill"]["count"] * gVars["gui"]["kill"]["page"])
    {
        gVars["gui"]["kill"]["content"][A_Index] := {"Text": ReadFunc("Killbinds", "KillbindText" A_Index, "Nothing")}
    }
    Loop % (gVars["gui"]["key"]["count"] * gVars["gui"]["key"]["page"])
    {
        gVars["gui"]["key"]["content"][A_Index] := {"Key": ReadFunc("Keybinds", "KeybindHotkey" A_Index, "Nothing")
        , "Text": ReadFunc("Keybinds", "KeybindText" A_Index, "Nothing")}
    }
    Loop % (gVars["gui"]["text"]["count"] * gVars["gui"]["text"]["page"])
    {
        gVars["gui"]["text"]["content"][A_Index] := {"Act": ReadFunc("Textbinds", "TextbindAct" A_Index, "Nothing")
        , "React": ReadFunc("Textbinds", "TextbindReact" A_Index, "Nothing")}
    }
    Loop % (gVars["gui"]["auto"]["count"] * gVars["gui"]["auto"]["page"])
    {
        gVars["gui"]["auto"]["content"][A_Index] := {"Act": ReadFunc("Autonom", "AutonomAction" A_Index, "Nothing")
        , "React": ReadFunc("Autonom", "AutonomReact" A_Index, "Nothing")}
    }
    Loop % (gVars["gui"]["frak"]["count"] * gVars["gui"]["frak"]["page"])
    {
        gVars["gui"]["frak"]["content"][A_Index]["Key"] := ReadFunc("Frakbinds", "FrakHotkey" A_Index, "Nothing")
    }
    Loop % (gVars["gui"]["group"]["count"] * gVars["gui"]["group"]["page"])
    {
        gVars["gui"]["group"]["content"][A_Index]["Key"] := ReadFunc("Groupbinds", "GroupHotkey" A_Index, "Nothing")
    }
    
    gVars["pos"] := []
    Loop {
        tempvar := ReadFunc("PosBinds", "PosBind" A_Index "_t", "Nothing")
        if (!tempvar) {
            break
        }
        tempvar := {}
        tempvar["x"] := ReadFunc("PosBinds", "PosBind" A_Index "_x", "Nothing")
        tempvar["y"] := ReadFunc("PosBinds", "PosBind" A_Index "_y", "Nothing")
        tempvar["z"] := ReadFunc("PosBinds", "PosBind" A_Index "_z", "Nothing")
        tempvar["r"] := ReadFunc("PosBinds", "PosBind" A_Index "_r", "Nothing")
        tempvar["t"] := ReadFunc("PosBinds", "PosBind" A_Index "_t", "Nothing")
        tempvar["c"] := ReadFunc("PosBinds", "PosBind" A_Index "_c", "Nothing")
        gVars["pos"].Push(tempvar)
    }
    
}
SaveIni()
{
    global
    local tempvar
    for unused_key, ov_obj in gVars["overlay"]
    {
        ov_obj.save()
    }
    WriteFunc(EnableAPI, "Settings", "EnableAPI")
    WriteFunc(EnableAutoLogin, "Settings", "EnableAutoLogin")
    WriteFunc(EnableTelegram, "Settings", "EnableTelegram")
    WriteFunc(EnableAutoGun, "Settings", "EnableAutoGun")
    WriteFunc(EnablePremium, "Settings", "EnablePremium")
    WriteFunc(EnableAutoEngine, "Settings", "AutoEnableEngine")
    WriteFunc(EnableAutoLight, "Settings", "EnableAutoLight")
    WriteFunc(EnableWPChat, "Settings", "EnableWPChat")
    WriteFunc(EnableKillbinder, "Settings", "EnableKillbinder")
    WriteFunc(EnableArtefakt, "Settings", "EnableArtefakt")
    WriteFunc(EnableDestroyObj, "Settings", "EnableDestroyObj")
    WriteFunc(EnableHistory, "Settings", "EnableHistory")
    WriteFunc(EnableFGet, "Settings", "EnableFGet")
    WriteFunc(EnableDeskFGet, "Settings", "EnableDeskFGet")
    WriteFunc(EnableForenThreads, "Settings", "EnableForenThreads")
    WriteFunc(EnableHitsound, "Settings", "EnableHitsound")
    WriteFunc(EnableACH, "Settings", "EnableACH")
    WriteFunc(EnableTeamspeak, "Settings", "EnableTeamspeak")
    
    WriteFunc(_suspend_toggle_hotkey, "Settings", "_suspend_toggle_hotkey")
    WriteFunc(_trucker_level, "Settings", "_trucker_level")
    WriteFunc(_trucker_sort_ddl, "Settings", "_trucker_sort_ddl")
    WriteFunc(_trucker_prev_diff, "Settings", "_trucker_prev_diff")
    
    
    WriteFunc(gVars["user"]["name"], "Settings", "UserName")
    WriteFunc(gVars["user"]["remember"], "Settings", "RememberCode")
    
    WriteFunc(gVars["kills"]["gkills"], "Kills", "GesamteKills")
    WriteFunc(gVars["kills"]["gdeaths"], "Kills", "GesamteDeaths")
    WriteFunc(gVars["kills"]["dkills"], "Kills", "TaeglicheKills")
    WriteFunc(gVars["kills"]["ddeaths"], "Kills", "TaeglicheDeaths")
    WriteFunc(gVars["kills"]["streak"], "Kills", "StreakKills")
    
    WriteFunc(gVars["path"]["chat"], "Settings", "chatlogpath")
    WriteFunc(gVars["path"]["samp"], "Settings", "samppath")
    WriteFunc(gVars["general"]["vs"], "Settings", "vsChat")
    WriteFunc(gVars["general"]["SardCode"], "Frakbinds", "FrakSardCode")
    WriteFunc(gVars["user"]["frakid"], "Settings", "img_frakid")
    if (_process_name != PROZESSNAME && _process_name) {
        PROZESSNAME := _process_name
        WriteFunc(PROZESSNAME, "Settings", "PROZESSNAME")
        GroupAdd, ProzessGroup, ahk_exe %PROZESSNAME%
        gVars["api"].deletevisual()
    }
    WriteFunc(gVars["overlay"]["font"]["type"], "Settings", "ov_font_type")
    WriteFunc(gVars["overlay"]["font"]["size"], "Settings", "ov_font_size")
    
    WriteFunc(_mouse_4_edit, "mousebinds", "xb1")
    WriteFunc(_mouse_5_edit, "mousebinds", "xb2")
    WriteFunc(_call_p_edit, "Settings", "_call_p_edit")
    WriteFunc(_call_h_edit, "Settings", "_call_h_edit")
    WriteFunc(_call_abw_edit, "Settings", "_call_abw_edit")
    WriteFunc(_overlay_enable_mmss, "Settings", "_overlay_enable_mmss")
    WriteFunc(_walksim_activate_key, "Settings", "_walksim_activate_key")
    WriteFunc(_walksim_trigger_key, "Settings", "_walksim_trigger_key")
    WriteFunc(_toggle_map_key, "Settings", "_toggle_map_key")
    WriteFunc(_open_mv_key, "Settings", "_open_mv_key")
    
    Loop % gVars["dVar"]["count"]
    {
        WriteFunc(gVars["dVar"]["content"][A_Index], "defined vars", "dVar" A_Index)
    }
    
    gVars["web"].update(gVars["user"]["name"], gVars["user"]["key"])
    Loop % (gVars["gui"]["kill"]["count"] * gVars["gui"]["kill"]["page"])
    {
        WriteFunc(gVars["gui"]["kill"]["content"][A_Index]["Text"], "Killbinds", "KillbindText" A_Index)
    }
    Loop % (gVars["gui"]["key"]["count"] * gVars["gui"]["key"]["page"])
    {
        WriteFunc(gVars["gui"]["key"]["content"][A_Index]["Key"], "Keybinds", "KeybindHotkey" A_Index)
        WriteFunc(gVars["gui"]["key"]["content"][A_Index]["Text"], "Keybinds", "KeybindText" A_Index)
    }
    Loop % (gVars["gui"]["text"]["count"] * gVars["gui"]["text"]["page"])
    {
        WriteFunc(gVars["gui"]["text"]["content"][A_Index]["Act"], "Textbinds", "TextbindAct" A_Index)
        WriteFunc(gVars["gui"]["text"]["content"][A_Index]["React"], "Textbinds", "TextbindReact" A_Index)
    }
    Loop % (gVars["gui"]["auto"]["count"] * gVars["gui"]["auto"]["page"])
    {
        WriteFunc(gVars["gui"]["auto"]["content"][A_Index]["Act"], "Autonom", "AutonomAction" A_Index)
        WriteFunc(gVars["gui"]["auto"]["content"][A_Index]["React"], "Autonom", "AutonomReact" A_Index)
    }
    Loop % (gVars["gui"]["frak"]["count"] * gVars["gui"]["frak"]["page"])
    {
        WriteFunc(gVars["gui"]["frak"]["content"][A_Index]["Key"], "Frakbinds", "FrakHotkey" A_Index)
    }
    Loop % (gVars["gui"]["group"]["count"] * gVars["gui"]["group"]["page"])
    {
        WriteFunc(gVars["gui"]["group"]["content"][A_Index]["Key"], "Groupbinds", "GroupHotkey" A_Index)
    }
    
    IniDelete, % gVars["path"]["ini"], posbinds
    Loop % gVars["pos"].MaxIndex()
    {
        WriteFunc(gVars["pos"][A_Index]["x"], "PosBinds", "PosBind" A_Index "_x")
        WriteFunc(gVars["pos"][A_Index]["y"], "PosBinds", "PosBind" A_Index "_y")
        WriteFunc(gVars["pos"][A_Index]["z"], "PosBinds", "PosBind" A_Index "_z")
        WriteFunc(gVars["pos"][A_Index]["r"], "PosBinds", "PosBind" A_Index "_r")
        WriteFunc(gVars["pos"][A_Index]["t"], "PosBinds", "PosBind" A_Index "_t")
        WriteFunc(gVars["pos"][A_Index]["c"], "PosBinds", "PosBind" A_Index "_c")
    }
    
}

#Include OB_funcs.ahk
#Include OB_commands.ahk
#Include OB_classes.ahk
#Include samp_api.ahk
#Include OB_labels.ahk
