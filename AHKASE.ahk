/*
Ark Survival Evolved - Auto Hot Key Script 1.01
By BitJunky 1/1/2016
Install https://autohotkey.com/ and run this script to use and hit F10 in Ark, F11 to run Example Macro to load Items
See end of script to customize hotkeys.
Some nice Maps to SetPlayerPos  http://xose.net/arkmap/ http://jdimensional.com/ark-map/
1/24/16 - Added CrossHair
*/

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

bCrossHair = 0
SplashImage, ahkase.jpg, b fs18, Auto Hot Key Script `n for Ark Survival Evolved v1.0 `n by BitJunky 2016
SetTimer, SplashOff, 3000


; *** Global Variables ***

; parses csv and loads DropDown

ae := {} ;arkEntityIDs
EntityIDs :=
DinoIds :=
ArkPOIs:=

Loop, read, ArkEnitityIDs.csv
{
    LineNumber = %A_Index% 
    Loop, parse, A_LoopReadLine, CSV
    {
    	if(A_Index = 1)
		id = %A_LoopField%
	else if(A_Index = 2)
		name = %A_LoopField%
	else if(A_Index = 3)
		type = %A_LoopField%
	else if(A_Index = 4)
		size = %A_LoopField%
	else if(A_Index = 5)
		path = %A_LoopField%
    
}
    if(name <> "name") ;skip 1st line heading
	ae[name] := { id: id, type: type, size: size, path: path  }
    EntityIDs .= name "|"
}
Sort EntityIDs, UD| ; sort created index
StringReplace, EntityIDs, EntityIDs, |, || ; set first entry as preselected

ad := {} ;ArkDinoIds

Loop, read, ArkDinoIDs.csv
{
    LineNumber = %A_Index% 
    Loop, parse, A_LoopReadLine, CSV
    {
    	if(A_Index = 1)
		name = %A_LoopField%
	else if(A_Index = 2)
		id = %A_LoopField%
	else if(A_Index = 3)
		path = %A_LoopField%
    
    }
    if(name <> "Entity Name")
	ad[name] := { id: id,  path: path  }
    DinoIDs .= name "|"
}

Sort DinoIDs, UD| ; sort created index
StringReplace, DinoIDs, DinoIDs, |, || ; set first entry as preselected


ap := {} ;Ark Points of Interest Cordinates

Loop, read, ArkPOIs.csv
{
    LineNumber = %A_Index% 
    Loop, parse, A_LoopReadLine, CSV
    {
    	if(A_Index = 1)
		name = %A_LoopField%
	else if(A_Index = 2)
		x = %A_LoopField%
	else if(A_Index = 3)
		y = %A_LoopField%
	else if(A_Index = 4)
		z = %A_LoopField%
    
    }
    if(name <> "Name")
    {
	ap[name] := { name: name,  x: x, y: y, z: z  }
	ArkPOIs .= name "|"
    }
}


Sort ArkPOIs, UD| ; sort created index
StringReplace, ArkPOIs, ArkPOIs, |, || ; set first entry as preselected

ScrW := (A_ScreenWidth // 2)  -55
ScrH := (A_ScreenHeight // 2) -50

Gui, GuiCrossHair:Default
Gui +LastFound +AlwaysOnTop -Caption +ToolWindow  ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
Gui, Color, cWhite
Gui, Font, s32
Gui, Add, Text, vCrossHairText cRed altsubmit gToggleCrossHair, X 
WinSet, TransColor, cWhite 150 ; Make all pixels of this color transparent and make the text itself translucent (150):
;Gui, Show, x%ScrW% y%ScrH% NoActivate  ; NoActivate avoids deactivating the currently active window.

; *** GuiSummon ***
Gui, GuiSummon:Default
Gui +AlwaysOnTop +ToolWindow  ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
Gui, Font, s16
Gui, Add, Text,, Tame:

Gui, Add, Radio, vDoTame, Do
Gui, Add, Radio, vForceTame, Force
Gui, Add, Radio, vNoTame, None

Gui, Add, Text,, Dino:
Gui, Add, DropDownList, w450 vDinoChoice, %DinoIDs%

Gui, Add, Text,, Level:
Gui, Add, Edit
Gui, Add, UpDown, vSpawnLevel Range1-999, 300


Gui, Add, Button, Default, OK  ; The label GuiSummonButtonOK (if it exists) will be run when the button is pressed.

; *** Gui Give Item ***			
Gui, GuiGiveItem:Default
Gui +AlwaysOnTop +ToolWindow  ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
Gui, Font, s16
Gui, Add, Text,, Item:
Gui, Add, DropDownList, w450 vEntityID, %EntityIDs%

Gui, Add, Text,, Quantity:
Gui, Add, Edit
Gui, Add, UpDown, vQuantity Range1-999, 1

Gui, Add, Text,, Quality:
Gui, Add, Edit
Gui, Add, UpDown, vQuality, Range1-999, 0

Gui, Add, Checkbox, vForceBlueprint, Force as Blueprint?

Gui, Add, Button, Default, OK  ; The label ButtonOK (if it exists) will be run when the button is pressed.


; *** GuiCordinates ***
Gui, GuiCordinates:Default
Gui, Font, s16
Gui +AlwaysOnTop +ToolWindow  ; +ToolWindow avoids a taskbar button and an alt-tab menu item.

Gui, Add, DropDownList,AltSubmit gonPOIChanged w450 vPOI, %ArkPOIs%
;Gui, Add, DropDownList, w450 vPOI, %ArkPOIs%

Gui, Add, Checkbox, vbGPS altSubmit gToggleGPS Checked, Use GPS Cordinates

Gui, Add, Text,, X:
Gui, Add, Edit, vX w100, 0
;Gui, Add, UpDown, vX, 0

Gui, Add, Text,, Y:
Gui, Add, Edit, vY w100, 0
;Gui, Add, UpDown, vY, 0

Gui, Add, Text,, Z:
Gui, Add, Edit, w100
Gui, Add, UpDown, vZ Range-50000-50000, -12000
Gui, Add, Button, Default, OK  ; The label ButtonOK (if it exists) will be run when the button is pressed.

; *** Menu ***
Menu, MyMenu, Add, Add Experience, AddExperience
Menu, MyMenu, Add, Spawn/Summon,  ShowGuiSummon
Menu, MyMenu, Add, Give Item, ShowGuiGiveItem
Menu, MyMenu, Add, Run Macro, RunMacro
Menu, MyMenu, Add, SetPlayerPos, ShowGuiCordinates

Menu, MyMenu, Add  ; Add a separator line.

Menu, Player, Add, EnemyInvisible true, arkCmd
Menu, Player, Add, EnemyInvisible false, arkCmd
Menu, Player, Add, Fly, ArkCmd
Menu, Player, Add, Walk, ArkCmd
Menu, Player, Add, GiveAllStructure, arkCmd
Menu, Player, Add, GiveEngrams, arkCmd
Menu, Player, Add, GiveToMe, ArkCmd
Menu, Player, Add, Ghost, arkCmd
Menu, Player, Add, God, ArkCmd
Menu, Player, Add, HurtMe 500, ArkCmd
Menu, Player, Add, InfiniteStats, ArkCmd
Menu, Player, Add, Suicide, arkCmd
Menu, Player, Add, ToggleInfiniteAmmo, arkCmd
Menu, Player, Add, Teleport, arkCmd

Menu, MyMenu, Add, Player, :Player

; Create another menu destined to become a submenu of the above menu.
Menu, Gamma, Add, 1, Gamma
Menu, Gamma, Add, 2, Gamma
Menu, Gamma, Add, 3, Gamma
Menu, Gamma, Add, 4, Gamma

; Create a submenu in the first menu (a right-arrow indicator). When the user selects it, the second menu is displayed.
Menu, MyMenu, Add, Gamma, :Gamma

Menu, MyMenu, Add, Cross Hair,  ToggleCrossHair

Gui +LastFound 
hWnd := WinExist()
DllCall( "RegisterShellHookWindow", UInt,Hwnd )
MsgNum := DllCall( "RegisterWindowMessage", Str,"SHELLHOOK" )
OnMessage( MsgNum, "ShellMessage" )

Return  ; End of script's auto-execute section.

ShellMessage( wParam,lParam )
{
	global bCrossHair

	WinGetTitle, title, ahk_id %lParam%
	If (bCrossHair && wParam = 32772) {
		
		if(Title="ARK: Survival Evolved") 
			Gui, GuiCrossHair:Show, NoActivate
		 else 
			Gui, GuiCrossHair:Hide
		
		;ToolTip WinActivated`n%Title% %bCrossHair%
		;sleep 1000
		;ToolTip
	}
}

SplashOff() {
	SplashImage, Off
}

RunMacro()
{
	FileSelectFile, SelectedFile, 3, , Open a Ahkase Macro, Ahkase Macro (ahkase-*.txt)
	if SelectedFile <> ""
		ArkMacro(SelectedFile)
}

Gamma(GammaLevel) {
	Send,{Tab}Gamma %GammaLevel%{enter}
}

ArkCmd(Cmd) {
	Send,{Tab}Cheat %Cmd%{enter}
}

AddExperience()
{
   ArkCmd("AddExperience 100000 0 1")
}

ShowGuiSummon()
{
   Gui, GuiSummon:Show,, Summon
}

ShowGuiGiveItem()
{
   Gui, GuiGiveItem:Show,, Give Item
}

ShowGuiCordinates()
{
   Gui, GuiCordinates:Show,, Cordinates
}


; ***** Button Call Backs ****

GuiSummonButtonOK:
	Gui, GuiSummon:Default
	Gui, Submit  ; Save the input from the user to each control's associated variable.
	;MsgBox You entered "%DinoChoice% %DoTame% %ForceTame% %NoTame%".
	;Send,{Tab}Cheat Summon %DinoChoice%_Character_BP_C{Enter}

	path := % ad[DinoChoice].path
	id := % ad[DinoChoice].id

	if(path<>"")
		ArkCmd = {Tab}Cheat SpawnDino %path% 1 1 1 %SpawnLevel%{enter}
	else
		ArkCmd = {Tab}Cheat Summon %id%{enter}

		Send,%ArkCmd%
	
	if %ForceTame%
		send,{Tab}Cheat ForceTame{Enter}
	else if %DoTame%
		send,{Tab}Cheat DoTame{Enter}
	
	Gui, Hide	
return

GuiGiveItemButtonOK:
	Gui, GuiGiveItem:Default
	Gui, Submit  ; Save the input from the user to each control's associated variable.
	guicontrolget, EntityName, , EntityID, text
	;MsgBox Cheat GiveItemNum EntitiyID %EntityID%  Quantity %Quantity%  Quality %Quality% ForceBlueprint %ForceBlueprint%. - %EntityName%
	;MsgBox % ae[EntityName].path
	;Send,{Tab}Cheat GiveItemNum %EntityID% %Quantity% %Quality% %ForceBlueprint% - %EntityName% %EntityID%{enter}
	path := % ae[EntityName].path
	id := % ae[EntityName].id
	if(path<>"")
		ArkCmd = {Tab}Cheat GiveItem %path% %Quantity% %Quality% %ForceBlueprint% - %EntityName% %EntityID%{enter}
	else
		ArkCmd = {Tab}Cheat GiveItemNum %id% %Quantity% %Quality% %ForceBlueprint% - %EntityName% %EntityID%{enter}
	
	Send,%ArkCmd%

	;Log( Cheat GiveItemNum %EntityID% %Quantity% %Quality% - %ForceBlueprint%)
	Log(ArkCmd)
	Gui, Hide
return


GuiCordinatesButtonOK() {
	global arkCmd, bGPS, POIName, X, Y, Z
	Gui, GuiCordinates:Default
	Gui, Submit
	if(bGPS){
		X := Round((X-50) * 8000)
		Y := Round((Y-50) * 8000)
	}
		
	ArkCmd = {Tab}Cheat SetPlayerPos %X% %Y% %Z% - %POIName%{enter}
	Send,%ArkCmd%
	Log(ArkCmd)

	Gui, Hide
}

onPOIChanged:

	guicontrolget, POIName, , POI, text
	X := % ap[POIName].x
	Y := % ap[POIName].y
	Z := % ap[POIName].z
	
	;msgbox Selected %POIName% X %X% Y: %Y% Z: %Z%

	Gui, GuiCordinates:Default
	GuiControl,, bGPS, 0
	GuiControl,, X, %X%
	GuiControl,, Y, %Y%
	GuiControl,, Z, %Z%

return

ToggleGPS()
{
	global bGPS, X, Y ,Z
	GuiControlGet, bGPS, , bGPS,

	if(bGPS){
		X := Round(50 + (X / 8000), 2)
		Y := Round(50 + (Y / 8000), 2)
	}
	else{
		X := Round((X-50) * 8000)
		Y := Round((Y-50) * 8000)
	}

	Gui, GuiCordinates:Default
	GuiControl,, X, %X%
	GuiControl,, Y, %Y%
	GuiControl,, Z, %Z%

}


ArkMacro(FileName)
{
	;TrayTip, Ark AHK, Loading %FileName%, 5, 17
	Loop, Read, %FileName%
	{
		SendInput, %A_LoopReadLine%
		sleep 10
	}
}

Log(Msg)
{
	FileAppend, %Msg%.`n, bahkase-log.txt
}

ToggleCrossHair() {
	global bCrossHair, ScrW, ScrH
	if (bCrossHair := !bCrossHair) {
		Gui, GuiCrossHair:Show, x%ScrW% y%ScrH% NoActivate  ; NoActivate avoids deactivating the currently active window.
	} else {
		Gui, GuiCrossHair:Hide
	}
}

; **** HotKeys - Customize below for your preferences ****

#IfWinActive ahk_exe ShooterGame.exe
F10::Menu, MyMenu, Show  ; i.e. press the Win-Z hotkey to show the menu.
#IfWinActive ahk_exe ShooterGame.exe
F11::ArkMacro("F11.txt")

; Middle Mouse Button will hold down w key to move foward, Mouse Button 5 Holds down left button
MButton:: Send % "{w " . ( GetKeyState("w") ? "Up}" : "Down}" )
XButton1:: Send % "{Click " . ( GetKeyState("LButton") ? "Up}" : "Down}" )
;no need, use right shift instead
;XButton2:: Send % "{shift " . ( GetKeyState("shift") ? "Up}" : "Down}" )

return

;*** Dev/Debug ***
;f12::reload
#singleinstance force
