Scriptname dfwMcm extends SKI_ConfigBase
{Configuration script for the Devious Framework mod.}

;***********************************************************************************************
; Mod: Devious Framework
;
; Script: MCM Menu
;
; Configuration script for the Devious Framework mod.
;
; Note: All Properties are exported and should reamin backward compatible.
;       Nothing else from this script is public and should not be relied on.
;
; © Copyright 2016 legume-Vancouver of GitHub
; This file is part of the Devious Framework Skyrim mod.
;
; The Devious Framework Skyrim mod is free software: you can redistribute it and/or modify it
; under the terms of the GNU General Public License as published by the Free Software
; Foundation, either version 3 of the License, or (at your option) any later version.
;
; The Devious Framework Skyrim mod is distributed in the hope that it will be useful, but
; WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
; PARTICULAR PURPOSE.  See the GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License along with The Devious
; Framework Skyrim mod.  If not, see <http://www.gnu.org/licenses/>.
;
; History:
; 1.0 2016-05-26 by legume
; Initial version.
; Added basic vulnerability options.
;***********************************************************************************************

Import StringUtil


;***********************************************************************************************
;***                                      CONSTANTS                                          ***
;***********************************************************************************************
; Constants for the add/remove menu items.
String S_ADD_NONE = "Add None"
String S_REM_NONE = "Remove None"

; Clothing slot (CS_) constants.
Int CS_START     = 0x00000001
Int CS_HEAD      = 0x00000001
Int CS_HAIR      = 0x00000002
Int CS_BODY      = 0x00000004
Int CS_HANDS     = 0x00000008
Int CS_FOREARMS  = 0x00000010
Int CS_AMULET    = 0x00000020
Int CS_RING      = 0x00000040
Int CS_FEET      = 0x00000080
Int CS_CALVES    = 0x00000100
Int CS_SHIELD    = 0x00000200
Int CS_TAIL      = 0x00000400
Int CS_LONG_HAIR = 0x00000800
Int CS_CIRCLET   = 0x00001000
Int CS_EARS      = 0x00002000
Int CS_RESERVED1 = 0x00100000
Int CS_RESERVED2 = 0x00200000
Int CS_RESERVED3 = 0x80000000
Int CS_MAX       = 0x80000000


;***********************************************************************************************
;***                                      VARIABLES                                          ***
;***********************************************************************************************
; A local variable to store a reference to the player for faster access.
Actor _aPlayer

; Keeps track of the last page the user viewed.
String _szLastPage

; *** Private Options ***
Bool _bSecureHardcore
Bool _bInfoForPlayer

; *** Toggle Options ***
Bool _bDefBlockNipple
Bool _bDefBlockVagina
Bool _bDefBlockHobble
Bool _bDefBlockShoes
Bool _bDefBlockArmour
Bool _bDefBlockArms
Bool _bDefBlockLeash
Bool _bDefSetDeviousFix
Bool _bDefModLeashVisible
Bool _bDefLeashInterrupt
Bool Property bBlockNipple Auto
Bool Property bBlockVagina Auto
Bool Property bBlockHobble Auto
Bool Property bBlockShoes  Auto
Bool Property bBlockArmour Auto
Bool Property bBlockArms   Auto
Bool Property bBlockLeash  Auto
Bool Property bSettingsDetectUnequip Auto
Bool Property bModLeashVisible       Auto
Bool Property bModLeashInterrupt     Auto

; *** Float Slider Options ***
Float _fDefSetPollTime
Float Property fSettingsPollTime Auto

; *** Integer Slider Options ***
Int _iDefSetPollNearby
Int _iDefSetNearbyDistance
Int _iDefVulNude
Int _iDefVulCollar
Int _iDefVulBinder
Int _iDefVulGagged
Int _iDefVulRestraints
Int _iDefVulLeashed
Int _iDefVulFurniture
Int _iDefVulNight
Int _iDefNakedRedressTimeout
Int _iDefRapeRedressTimeout
Int _iDefSlaThreshold
Int _iDefSlaAdjustedMin
Int _iDefSlaAdjustedMax
Int _iDefLeashDamage
Int _iDefLogLevel
Int _iDefLogLevelScreen
Int _iDefVulNakedReduce
Int Property iSettingsSecurity         Auto
Int Property iSettingsPollNearby       Auto
Int Property iSettingsNearbyDistance   Auto
Int Property iVulnerabilityNude        Auto
Int Property iVulnerabilityCollar      Auto
Int Property iVulnerabilityBinder      Auto
Int Property iVulnerabilityGagged      Auto
Int Property iVulnerabilityRestraints  Auto
Int Property iVulnerabilityLeashed     Auto
Int Property iVulnerabilityFurniture   Auto
Int Property iVulnerabilityNight       Auto
Int Property iModNakedRedressTimeout   Auto
Int Property iModRapeRedressTimeout    Auto
Int Property iModSlaThreshold          Auto
Int Property iModSlaAdjustedMin        Auto
Int Property iModSlaAdjustedMax        Auto
Int Property iModLeashDamage           Auto
Int Property iLogLevel                 Auto
Int Property iLogLevelScreen           Auto
Int Property iVulnerabilityNakedReduce Auto

; *** Enumeration Options ***
Int _iDefModLeashStyle
Int Property iModLeashStyle Auto

; *** Lists and Advanced Options ***
String[] _aszDefSetSlotsChest
String[] _aszDefSetSlotsWaist
Int[] Property aiSettingsSlotsChest Auto
Int[] Property aiSettingsSlotsWaist Auto
Int[] Property aiBlockExceptionsHobble Auto

; A reference to the main framework quest script.
dfwDeviousFramework _qFramework

; A reference to the Devious Framework Util quest script.
dfwUtil _qDfwUtil

; A reference to the ZAZ Animation Pack (ZBF) slave control APIs.
zbfSlot _qZbfPlayerSlot

; A list of slots to choose from.
String[] _aszSlotList

; Can cleared to turn off debug dialog boxes for a while.
; Is enabled each time the menu is opened.
; Turned off automatically when the user selects to stop showing debug messages.
Bool _bDebug


;***********************************************************************************************
;***                                    INITIALIZATION                                       ***
;***********************************************************************************************
Function InitScript()
   ; Hardcore mode is turned off on all script updates.
   _bSecureHardcore = False

   Debug.Notification("[DFW-MCM] Updating Script: " + CurrentVersion + " => " + GetVersion())

   ; Very basic initialization.
   If (1 > CurrentVersion)
      _aPlayer = Game.GetPlayer()
      _qFramework = (Self As Quest) As dfwDeviousFramework

      Pages = New String[6]
      Pages[0] = "Framework Settings"
      Pages[1] = "Vulnerability"
      Pages[2] = "NPC Confidence"
      Pages[3] = "Mod Features"
      Pages[4] = "Status"
      Pages[5] = "Debug"
   EndIf

   ; Historical configuration...
   If (2 > CurrentVersion)
      ; Initialize all default values.
      _bDefSetDeviousFix       = False
      _bDefBlockNipple         = True
      _bDefBlockVagina         = True
      _bDefBlockHobble         = True
      _bDefBlockShoes          = True
      _bDefBlockArmour         = True
      _bDefBlockArms           = True
      _fDefSetPollTime         = 1.0
      _iDefSetPollNearby       = 5
      _iDefSetNearbyDistance   = 40
      _iDefVulNude             = 15
      _iDefVulNakedReduce      = 50
      _iDefVulCollar           = 25
      _iDefVulBinder           = 20
      _iDefVulGagged           = 20
      _iDefVulRestraints       = 10
      _iDefVulNight            =  5
      _iDefLogLevel            =  5
      _iDefNakedRedressTimeout = 20
      _iDefRapeRedressTimeout  = 90

      fSettingsPollTime = _fDefSetPollTime

      iSettingsPollNearby = _iDefSetPollNearby
      iSettingsNearbyDistance = _iDefSetNearbyDistance
      bSettingsDetectUnequip    = _bDefSetDeviousFix
      bBlockNipple              = _bDefBlockNipple
      bBlockVagina              = _bDefBlockVagina
      bBlockHobble              = _bDefBlockHobble
      bBlockShoes               = _bDefBlockShoes
      bBlockArmour              = _bDefBlockArmour
      bBlockArms                = _bDefBlockArms
      iVulnerabilityNude        = _iDefVulNude
      iVulnerabilityNakedReduce = _iDefVulNakedReduce
      iVulnerabilityCollar      = _iDefVulCollar
      iVulnerabilityBinder      = _iDefVulBinder
      iVulnerabilityGagged      = _iDefVulGagged
      iVulnerabilityRestraints  = _iDefVulRestraints
      iVulnerabilityNight       = _iDefVulNight
      iModNakedRedressTimeout   = _iDefNakedRedressTimeout
      iModRapeRedressTimeout    = _iDefRapeRedressTimeout
      iLogLevel                 = _iDefLogLevel

      _aszSlotList = New String[32]
      _aszSlotList[0]  = "Head           0x00000001"   ; 30
      _aszSlotList[1]  = "Hair           0x00000002"   ; 31
      _aszSlotList[2]  = "Body           0x00000004"   ; 32
      _aszSlotList[3]  = "Hands          0x00000008"   ; 33
      _aszSlotList[4]  = "Forearms       0x00000010"   ; 34
      _aszSlotList[5]  = "Amulet         0x00000020"   ; 35
      _aszSlotList[6]  = "Ring           0x00000040"   ; 36
      _aszSlotList[7]  = "Feet           0x00000080"   ; 37
      _aszSlotList[8]  = "Calves         0x00000100"   ; 38
      _aszSlotList[9]  = "Shield         0x00000200"   ; 39
      _aszSlotList[10] = "Tail           0x00000400"   ; 40
      _aszSlotList[11] = "Long Hair      0x00000800"   ; 41
      _aszSlotList[12] = "Circlet        0x00001000"   ; 42
      _aszSlotList[13] = "Ears           0x00002000"   ; 43
      _aszSlotList[14] = "Face-Mouth     0x00004000"   ; 44
      _aszSlotList[15] = "Neck           0x00008000"   ; 45
      _aszSlotList[16] = "Chest          0x00010000"   ; 46
      _aszSlotList[17] = "Back           0x00020000"   ; 47
      _aszSlotList[18] = "Misc1          0x00040000"   ; 48
      _aszSlotList[19] = "Pelvis         0x00080000"   ; 49
      _aszSlotList[20] = "Decapitated    0x00100000"   ; 50
      _aszSlotList[21] = "Decapitate     0x00200000"   ; 51
      _aszSlotList[22] = "Pelvis-Under   0x00400000"   ; 52
      _aszSlotList[23] = "Leg-Main/Right 0x00800000"   ; 53
      _aszSlotList[24] = "Leg-Alt/Left   0x01000000"   ; 54
      _aszSlotList[25] = "Face-Alt       0x02000000"   ; 55
      _aszSlotList[26] = "Chest-Under    0x04000000"   ; 56
      _aszSlotList[27] = "Shoulder       0x08000000"   ; 57
      _aszSlotList[28] = "Arm-Alt/Left   0x10000000"   ; 58
      _aszSlotList[29] = "Arm-Main/Right 0x20000000"   ; 59
      _aszSlotList[30] = "Misc2          0x40000000"   ; 60
      _aszSlotList[31] = "FX01           0x80000000"   ; 61

      _aszDefSetSlotsChest = New String[2]
      _aszDefSetSlotsChest[0] = _aszSlotList[16]
      _aszDefSetSlotsChest[1] = _aszSlotList[26]

      _aszDefSetSlotsWaist = New String[2]
      _aszDefSetSlotsWaist[0] = _aszSlotList[19]
      _aszDefSetSlotsWaist[1] = _aszSlotList[22]
   EndIf

   If (3 > CurrentVersion)
      _iDefModLeashStyle = _qFramework.LS_AUTO
      iModLeashStyle = _iDefModLeashStyle
      _bDefModLeashVisible = True
      bModLeashVisible = _bDefModLeashVisible
      _iDefVulLeashed = 10
      iVulnerabilityLeashed = _iDefVulLeashed
      _bDefBlockLeash = True
      bBlockLeash = _bDefBlockLeash
      _bInfoForPlayer = True

      ; Block List Exceptions
      _qDfwUtil = (Self As Quest) As dfwUtil
      aiSettingsSlotsChest = New Int[2]
      aiSettingsSlotsChest[0] = _qDfwUtil.ConvertStringToHex(_aszDefSetSlotsChest[0])
      aiSettingsSlotsChest[1] = _qDfwUtil.ConvertStringToHex(_aszDefSetSlotsChest[1])
      aiSettingsSlotsWaist = New Int[2]
      aiSettingsSlotsWaist[0] = _qDfwUtil.ConvertStringToHex(_aszDefSetSlotsWaist[0])
      aiSettingsSlotsWaist[1] = _qDfwUtil.ConvertStringToHex(_aszDefSetSlotsWaist[1])

      aiBlockExceptionsHobble = None
   EndIf

   If (4 > CurrentVersion)
      _bDefLeashInterrupt = True
      bModLeashInterrupt = _bDefLeashInterrupt
   EndIf

   ; Updated the default nearby distance from 40 to 65.
   If (5 > CurrentVersion)
      _iDefSetNearbyDistance   = 65
      If (40 == iSettingsNearbyDistance)
         iSettingsNearbyDistance = _iDefSetNearbyDistance
         _qFramework.UpdatePollingDistance(iSettingsNearbyDistance)
      EndIf

      ; Added SexLab Aroused (SLA) arousal adjustments in version 5.
      _iDefSlaThreshold   =  3
      _iDefSlaAdjustedMin =  5
      _iDefSlaAdjustedMax = 50
      iModSlaThreshold   = _iDefSlaThreshold
      iModSlaAdjustedMin = _iDefSlaAdjustedMin
      iModSlaAdjustedMax = _iDefSlaAdjustedMax

      ; Made leash damage configurable.
      _iDefLeashDamage = 12
      iModLeashDamage  = _iDefLeashDamage
   EndIf

   ; Added a vulnerability configuration for BDSM furniture in version 6.
   If (6 > CurrentVersion)
      _iDefVulFurniture       = 10
      iVulnerabilityFurniture = _iDefVulFurniture
   EndIf

   ; Changed the default security setting to allow changing settings in new games where the
   ; player is already vulnerable in version 7.
   If (7 > CurrentVersion)
      ; Set the Security level to the maximum.  This does not prevent settings to be changed
      ; when installing the mod into games where the player is already vulnerable.
      iSettingsSecurity = 100

      ; Also in this version I added furniture status which come from the ZAZ Animation Pack.
      _qZbfPlayerSlot = zbfBondageShell.GetApi().FindPlayer()

      ; Also decrease the screen logging level.
      _iDefLogLevelScreen = 2
      iLogLevelScreen     = _iDefLogLevelScreen
   EndIf
EndFunction


Event OnConfigInit()
   InitScript()

   ; Make sure the Devious Framework polling interval is running.
   ; The first polling interval should configure the script.
   ; Do this here so the main script can rely on our data having been initialized first.
   _qFramework.UpdatePollingInterval(fSettingsPollTime)
EndEvent

; Version of the MCM script.
; Unrelated to the Devious Framework Version.
Int Function GetVersion()
   ; Reset the version number.
   ; CurrentVersion = 2

   Return 7
EndFunction

Event OnVersionUpdate(Int iNewVersion)
   InitScript()
EndEvent


;***********************************************************************************************
;***                                  PRIVATE FUNCTIONS                                      ***
;***********************************************************************************************
Function AddLabel(String szLabel)
   AddTextOption(szLabel, "", a_flags=OPTION_FLAG_DISABLED)
EndFunction

String Function LeashStyleToString(Int iStyle)
   If (_qFramework.LS_AUTO == iStyle)
      Return "Auto"
   ElseIf (_qFramework.LS_DRAG == iStyle)
      Return "Drag"
   ElseIf (_qFramework.LS_TELEPORT == iStyle)
      Return "Teleport"
   EndIf
EndFunction

String[] Function CreateWornOptions(String szFirstEntry, Actor oActor=None, \
                                    Bool bClothingOnly=True, Bool bIncludeRestraints=False)
   If (!oActor)
      oActor = _aPlayer
   EndIf

   String[] aszOptions
   If (szFirstEntry)
      aszOptions = New String[1]
      aszOptions[0] = szFirstEntry
   EndIf

   ; Keep track of which slots we've already checked.
   Int iSlotsChecked

   ; Ignore items that would be in reserved slots.
   iSlotsChecked += CS_RESERVED1
   iSlotsChecked += CS_RESERVED2
   iSlotsChecked += CS_RESERVED3

   Int iSearchMask = CS_START
   While (iSearchMask < CS_MAX)
      ; Only search slots we haven't found something in already.
      If (!Math.LogicalAnd(iSlotsChecked, iSearchMask))
         Armor oItem = oActor.GetWornForm(iSearchMask) as Armor
         If (oItem)
            Int iType = _qFramework.GetItemType(oItem)
            If (!bClothingOnly || (_qFramework.IT_COVERINGS == iType) || \
                (bIncludeRestraints && (_qFramework.IT_RESTRAINT == iType)))
               String szName = oItem.GetName()
               If (!szName)
                  szName = "Unknown"
               EndIf

               String szId = "0x" + _qDfwUtil.ConvertHexToString(oItem.GetFormID(), 8)
               aszOptions = _qDfwUtil.AddStringToArray(aszOptions, szId + ": " + szName)
            EndIf
            ; Add all slots this armour covers to the checked list.
            iSlotsChecked += oItem.GetSlotMask()
         Else
            ; No armour was found in the slot.  Only add the slot checked to the list.
            iSlotsChecked += iSearchMask
         EndIf
      Endif
      ; Shift the slot one bit to search the next mask.
      iSearchMask *= 2
   EndWhile
   Return aszOptions
EndFunction

String Function GetSlotString(Int iSlot, Bool bFancyInfo=False)
   String szPureHex = "0x" + _qDfwUtil.ConvertHexToString(iSlot, 8)

   ; If we are to retun the string with location information find it now. 
   If (bFancyInfo)
      Int iLength = _aszSlotList.Length
      Int iIndex
      While (iIndex < iLength)
         If (0 <= StringUtil.Find(_aszSlotList[iIndex], szPureHex))
            Return _aszSlotList[iIndex]
         EndIf
         iIndex += 1
      EndWhile
   EndIf
   Return szPureHex
EndFunction

Bool Function IsSecure()
   ; If the security setting is set to 100 don't lock the settings at all.
   If (100 == iSettingsSecurity)
      Return False
   EndIf

   ; If the hardcore flag is set the menus should be secure.
   If (_bSecureHardcore)
      Return True
   EndIf

   ; If the player is vulnerable the menus should be secure.
   Int iVulnerability = _qFramework.GetVulnerability()
   If (iVulnerability > iSettingsSecurity)
      Return True
   EndIf

   ; If the player has a master the menus should be secure.
   If (_qFramework.GetMaster())
      Return True
   EndIf

   ; Otherwise the menus are secure if the player is bound.
   Return _qFramework.IsPlayerBound(True)
EndFunction

Function PresentInformation(String[] aszInfo, String szHeader)
   String aszOptions
   Int iLength = aszInfo.Length
   Int iTotalPages = ((iLength / 10) + 1)
   Int iPage = 1
   Int iIndex = 0

   If (!iLength)
      ShowMessage(szHeader + "\nNo Elements.", True, "Exit", "Exit")
   EndIf

   While (True)
      ; Get the first index for the current page.
      iIndex = ((iPage - 1) * 10)

      ; If the user has progressed passed the end of the list they have quite the display.
      If ((0 > iIndex) || (iLength <= iIndex))
         Return
      EndIf

      ; Fill the information to present to the user with only one page of data.
      String szMessage = szHeader + " Page " + iPage + "/" + iTotalPages
      While ((iIndex < iLength) && (iIndex < (iPage * 10)))
         szMessage += "\n" + aszInfo[iIndex]
         iIndex += 1
      EndWhile

      ; Setup the next and back buttons for the message box.
      String szNext = "Next"
      String szBack = "Back"
      If (1 == iPage)
         szBack = "Exit"
      EndIf
      If (iTotalPages == iPage)
         szNext = "Exit"
      EndIf

      ; Display the information to the user.
      If (ShowMessage(szMessage, True, szBack, szNext))
         iPage -= 1
      Else
         iPage += 1
      EndIf
   EndWhile
EndFunction

; Debug/Development function to present a message in a message box.
; Further messages can be stopped by cancelling the messge.
Function DebugBox(String szMessage)
   If (_bDebug)
      _bDebug = ShowMessage(szMessage, True, "Continue", "Stop")
   EndIf
EndFunction


;***********************************************************************************************
;***                                    DISPLAY PAGES                                        ***
;***********************************************************************************************
Event OnPageReset(String szRequestedPage)
   {Called when a new page is selected, including the initial empty page}

   ; On the menu being opened reset the debug mechanism.
   _bDebug = True

   ; Find out if the settings should be secure (Unmodifiable when Vulnerable).
   Bool bSecure = IsSecure()

   ; Unless overridden by each page fill mode is top to bottom.
   SetCursorFillMode(TOP_TO_BOTTOM)

   ; If no page is requested (the menu is just opened) default to the last page opened.
   String szPage = szRequestedPage
   If ("" == szPage)
      szPage = _szLastPage
   Else
      _szLastPage = szRequestedPage
   EndIf

   If ("Vulnerability" == szPage)
      DisplayVulnerabilityPage(bSecure)
   ElseIf ("NPC Confidence" == szPage)
      DisplayVulnerabilityPage(bSecure)
   ElseIf ("Mod Features" == szPage)
      DisplayModFeaturesPage(bSecure)
   ElseIf ("Status" == szPage)
      DisplayStatusPage(bSecure)
   ElseIf ("Debug" == szPage)
      DisplayDebugPage(bSecure)
   Else
      ; Load this page if nothing else is set.  Initial page and "Framework Settings".
      DisplayFrameworkPage(bSecure)
   EndIf
EndEvent

Function DisplayFrameworkPage(Bool bSecure)
   Int iFlags = OPTION_FLAG_NONE
   If (bSecure)
      iFlags = OPTION_FLAG_DISABLED
   EndIf

   AddTextOption("Devious Framework Version", _qFramework.GetModVersion(), a_flags=OPTION_FLAG_DISABLED)

   AddEmptyOption()

   AddSliderOptionST("ST_FWK_SECURE",        "Security Level",        iSettingsSecurity, a_flags=iFlags)
   AddToggleOptionST("ST_FWK_HARDCORE",      "...Hardcore (Caution)", _bSecureHardcore, a_flags=iFlags)
   AddSliderOptionST("ST_FWK_POLL_TIME",     "Poll Time",             fSettingsPollTime, "{1}")
   AddSliderOptionST("ST_FWK_POLL_NEAR",     "Nearby Poll Frequency", iSettingsPollNearby)
   AddSliderOptionST("ST_FWK_POLL_DISTANCE", "Nearby Poll Distance",  iSettingsNearbyDistance)

   AddEmptyOption()

   AddToggleOptionST("ST_FWK_DD_FIX", "Detect Devious Device Unequips", bSettingsDetectUnequip)

   ; Start on the second column.
   SetCursorPosition(1)

   AddHeaderOption("Alternate Clothing Slots")
   AddMenuOptionST("ST_FWK_ADD_CHEST", "Add Alternate Chest Slot", "Select", a_flags=iFlags)
   AddMenuOptionST("ST_FWK_ADD_WAIST", "Add Alternate Waist Slot", "Select", a_flags=iFlags)
   AddMenuOptionST("ST_FWK_REM_CHEST", "Remove/View Chest Slots", "Open")
   AddMenuOptionST("ST_FWK_REM_WAIST", "Remove/View Waist Slots", "Open")
EndFunction

Function DisplayVulnerabilityPage(Bool bSecure)
   Int iFlags = OPTION_FLAG_NONE
   If (bSecure)
      iFlags = OPTION_FLAG_DISABLED
   EndIf

   AddSliderOptionST("ST_VUL_NUDE",       "Nude",           iVulnerabilityNude,       a_flags=iFlags)
   AddSliderOptionST("ST_VUL_COLLAR",     "Collar",         iVulnerabilityCollar,     a_flags=iFlags)
   AddSliderOptionST("ST_VUL_BINDER",     "Arm Binder",     iVulnerabilityBinder,     a_flags=iFlags)
   AddSliderOptionST("ST_VUL_GAGGED",     "Gag",            iVulnerabilityGagged,     a_flags=iFlags)
   AddSliderOptionST("ST_VUL_RESTRAINTS", "Restraints",     iVulnerabilityRestraints, a_flags=iFlags)
   AddSliderOptionST("ST_VUL_LEASHED",    "Leashed",        iVulnerabilityLeashed,    a_flags=iFlags)
   AddSliderOptionST("ST_VUL_FURNITURE",  "BDSM Furniture", iVulnerabilityFurniture,  a_flags=iFlags)
   AddSliderOptionST("ST_VUL_NIGHT",      "Night Time",     iVulnerabilityNight,      a_flags=iFlags)

   ; Start on the second column.
   SetCursorPosition(1)

   AddSliderOptionST("ST_VUL_REDUCE", "Naked Armour Reduces Vulnerability", iVulnerabilityNakedReduce, a_flags=iFlags)
EndFunction

Function DisplayModFeaturesPage(Bool bSecure)
   Int iFlags = OPTION_FLAG_NONE
   If (bSecure)
      iFlags = OPTION_FLAG_DISABLED
   EndIf

   AddHeaderOption("Redress Timeouts")
   AddSliderOptionST("ST_MOD_RAPE_REDRESS",    "Post Rape Redress Timeout", iModRapeRedressTimeout,  a_flags=iFlags)
   AddSliderOptionST("ST_MOD_NAKED_REDRESS",   "Naked Redress Timeout",     iModNakedRedressTimeout, a_flags=iFlags)
   AddHeaderOption("Leash Configuration")
   AddTextOptionST("ST_MOD_LEASH_STYLE",       "Leash Style", LeashStyleToString(iModLeashStyle))
   AddToggleOptionST("ST_MOD_LEASH_VISIBLE",   "Leash Visible", bModLeashVisible)
   AddToggleOptionST("ST_MOD_LEASH_INTERRUPT", "Leash Interrupt", bModLeashInterrupt)
   AddSliderOptionST("ST_MOD_LEASH_DAMAGE",    "Damage When Jerked", iModLeashDamage,  a_flags=iFlags)

   AddEmptyOption()
   AddHeaderOption("SexLab Aroused Base")
   AddSliderOptionST("ST_MOD_SLA_THRESHOLD", "Initial Threshold", iModSlaThreshold, a_flags=iFlags)
   AddSliderOptionST("ST_MOD_SLA_MIN",       "Minimum Adjusted Arousal", iModSlaAdjustedMin, a_flags=iFlags)
   AddSliderOptionST("ST_MOD_SLA_MAX",       "Maximum Adjusted Arousal", iModSlaAdjustedMax, a_flags=iFlags)

   ; Start on the second column.
   SetCursorPosition(1)

   ; I'm not sure this is the right mod to block armour but no other mods have the concept of
   ; "chest" and "waist" armour so let's keep it here for now.
   AddHeaderOption("Armour Blocking")
   AddToggleOptionST("ST_MOD_NIPPLE", "Blocking Nipple Piercing", bBlockNipple, a_flags=iFlags)
   AddToggleOptionST("ST_MOD_VAGINA", "Blocking Vagina Piercing", bBlockVagina, a_flags=iFlags)
   AddToggleOptionST("ST_MOD_ARMOUR", "Also Block Body Armour",   bBlockArmour, a_flags=iFlags)
   AddToggleOptionST("ST_MOD_HOBBLE", "Blocking Hobble/Boots",    bBlockHobble, a_flags=iFlags)
   AddToggleOptionST("ST_MOD_SHOES",  "Hobble/Boots Also Block Shoes", bBlockShoes, a_flags=iFlags)
   AddToggleOptionST("ST_MOD_ARMS",   "Blocking Locked Arms",     bBlockArms,   a_flags=iFlags)
   AddToggleOptionST("ST_MOD_BLOCK_LEASH",   "Blocking Leash",    bBlockLeash,  a_flags=iFlags)

   AddEmptyOption()
   AddHeaderOption("Blocking Exceptions")
   AddMenuOptionST("ST_MOD_ADD_EXC_HOBBLE", "Add Exception to Hobble Block", "Select", a_flags=iFlags)
   AddMenuOptionST("ST_MOD_REM_EXC_HOBBLE", "Remove/View Hobble Exceptions", "Open")
EndFunction

Function DisplayStatusPage(Bool bSecure)
   Int iFlags = OPTION_FLAG_NONE
   If (bSecure)
      iFlags = OPTION_FLAG_DISABLED
   EndIf

   AddToggleOptionST("ST_INFO_FOR_PLAYER", "Use Player for Info",    _bInfoForPlayer)
   AddToggleOptionST("ST_INFO_FACTIONS",   "Show Player Factions",   False)
   AddToggleOptionST("ST_INFO_NEARBY",     "Show Nearby Actors",     False)
   AddToggleOptionST("ST_INFO_KNOWN",      "Show Known Actors",      False)
   AddToggleOptionST("ST_INFO_DEBUG",      "Show Debug Information", False)

   AddEmptyOption()
   AddHeaderOption("Vulnerability")
   String szNakedLevel = "0x" + _qDfwUtil.ConvertHexToString(_qFramework.GetNakedLevel(), 8)
   AddTextOption("Vulnerability", _qFramework.GetVulnerability(), a_flags=OPTION_FLAG_DISABLED)
   AddTextOption("Naked",         szNakedLevel,                   a_flags=OPTION_FLAG_DISABLED)
   AddTextOption("Weapon Level",  _qFramework.GetWeaponLevel(),   a_flags=OPTION_FLAG_DISABLED)

   AddEmptyOption()
   AddHeaderOption("Current Masters")
   Actor aMasterClose   = _qFramework.GetMaster(_qFramework.MD_CLOSE)
   Actor aMasterDistant = _qFramework.GetMaster(_qFramework.MD_DISTANT)

   If (aMasterClose || aMasterDistant)
      If (aMasterClose)
         String szMod = _qFramework.GetMasterMod(_qFramework.MD_CLOSE)
         AddLabel("Close [" + szMod + "]: " + aMasterClose.GetDisplayName())
      EndIf
      If (aMasterDistant)
         String szMod = _qFramework.GetMasterMod(_qFramework.MD_DISTANT)
         AddLabel("Distant [" + szMod + "]: " + aMasterDistant.GetDisplayName())
      EndIf
   EndIf

   String szAllowed = "Not Allowed"
   If (_qFramework.IsAllowed(_qFramework.AP_SEX))
      szAllowed = "Allowed"
   EndIf
   AddTextOption("Sex Allowed?", szAllowed, a_flags=OPTION_FLAG_DISABLED)
   szAllowed = "Not Allowed"
   If (_qFramework.IsAllowed(_qFramework.AP_ENSLAVE))
      szAllowed = "Allowed"
   EndIf
   AddTextOption("Enslavement Allowed?", szAllowed, a_flags=OPTION_FLAG_DISABLED)
   szAllowed = "Not Allowed"
   If (_qFramework.IsAllowed(_qFramework.AP_RESTRAIN))
      szAllowed = "Allowed"
   EndIf
   AddTextOption("Restraints Allowed?", szAllowed, a_flags=OPTION_FLAG_DISABLED)
   szAllowed = "Not Allowed"
   If (_qFramework.IsAllowed(_qFramework.AP_DRESSING_ALONE))
      szAllowed = "Allowed"
   EndIf
   AddTextOption("Dressing Alone?", szAllowed, a_flags=OPTION_FLAG_DISABLED)
   szAllowed = "Not Allowed"
   If (_qFramework.IsAllowed(_qFramework.AP_DRESSING_ASSISTED))
      szAllowed = "Allowed"
   EndIf
   AddTextOption("Dressing Assisted?", szAllowed, a_flags=OPTION_FLAG_DISABLED)

   ; Start on the second column.
   SetCursorPosition(1)

   ; Report the name of the player's current cell.
   String szCellName = _aPlayer.GetParentCell()
   szCellName = Substring(szCellName, 7, GetLength(szCellName) - 20)
   If (_aPlayer.IsInInterior())
      szCellName += " (I)"
   EndIf
   AddLabel("Current Cell: " + szCellName)

   AddMenuOptionST("ST_STA_KEYWORD", "Keyword Browsing", "Select Item")

   AddEmptyOption()
   AddHeaderOption("Furniture")
   ObjectReference oCurrFurniture = _qZbfPlayerSlot.GetFurniture()
   String szValue = "None"
   If (oCurrFurniture)
      szValue = oCurrFurniture.GetDisplayName()
   EndIf
   AddLabel("ZAZ Furniture: " + szValue)

   oCurrFurniture = _qFramework.GetBdsmFurniture()
   szValue = "None"
   If (oCurrFurniture)
      szValue = oCurrFurniture.GetDisplayName()
   EndIf
   AddLabel("DFW Furniture: " + szValue)

   AddEmptyOption()
   AddHeaderOption("Slots Worn")
   ; Keep track of which slots we've already checked.
   Int iSlotsChecked

   ; Ignore items that would be in reserved slots.
   iSlotsChecked += CS_RESERVED1
   iSlotsChecked += CS_RESERVED2
   iSlotsChecked += CS_RESERVED3

   Actor aActor = _aPlayer
   If (!_bInfoForPlayer)
      aActor = _qFramework.GetNearestActor(0)
   EndIf

   Int iSearchMask = CS_START
   While (iSearchMask < CS_MAX)
      ; Only search slots we haven't found something in already.
      If (!Math.LogicalAnd(iSlotsChecked, iSearchMask))
         Armor oItem = aActor.GetWornForm(iSearchMask) as Armor
         If (oItem)
            Int iItemSlots = oItem.GetSlotMask()

            String szName = oItem.GetName()
            If (!szName)
               szName = "Unknown"
            EndIf
            AddLabel(GetSlotString(iItemSlots) + ": " + szName)

            ; Add all slots this armour covers to the checked list.
            iSlotsChecked += iItemSlots
         Else
            ; No armour was found in the slot.  Only add the slot checked to the list.
            iSlotsChecked += iSearchMask
         EndIf
      Endif
      ; Shift the slot one bit to search the next mask.
      iSearchMask *= 2
   EndWhile
EndFunction

Function DisplayDebugPage(Bool bSecure)
   Int iFlags = OPTION_FLAG_NONE
   If (bSecure)
      iFlags = OPTION_FLAG_DISABLED
   EndIf

   AddSliderOptionST("ST_DBG_LEVEL",  "Log Level",        iLogLevel)
   AddSliderOptionST("ST_DBG_SCREEN", "Log Level Screen", iLogLevelScreen)
EndFunction


;***********************************************************************************************
;***                                  STATES: FRAMEWORK                                      ***
;***********************************************************************************************
State ST_FWK_SECURE
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iSettingsSecurity)
      SetSliderDialogDefaultValue(_iDefVulNight)
      SetSliderDialogRange(1, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iSettingsSecurity = fValue As Int
      SetSliderOptionValueST(iSettingsSecurity)
   EndEvent

   Event OnDefaultST()
      iSettingsSecurity = _iDefVulNight
      SetSliderOptionValueST(iSettingsSecurity)
   EndEvent

   Event OnHighlightST()
      SetInfoText("This is the maximum vulnerability the player can be at and still change the settings.\n" +\
                  "Recommend: " + iVulnerabilityNight + " so you can change settings at night.\n" +\
                  "Note: Hidden (or covered) restraints also lock the settings.  100 never locks the settings.")
   EndEvent
EndState

State ST_FWK_HARDCORE
   Event OnSelectST()
      _bSecureHardcore = !_bSecureHardcore
      SetToggleOptionValueST(_bSecureHardcore)
   EndEvent

   Event OnDefaultST()
      _bSecureHardcore = False
      SetToggleOptionValueST(_bSecureHardcore)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Locks all secure settings until the next mod upgrade.\n" +\
                  "Note: This includes clothing slots.  Make sure they are right first.\n" +\
                  "Caution: Once set it can't be turned off.")
   EndEvent
EndState

State ST_FWK_POLL_TIME
   Event OnSliderOpenST()
      SetSliderDialogStartValue(fSettingsPollTime)
      SetSliderDialogDefaultValue(_fDefSetPollTime)
      SetSliderDialogRange(1, 5)
      SetSliderDialogInterval(0.5)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      If (fSettingsPollTime != fValue)
         _qFramework.UpdatePollingInterval(fValue)
      EndIf
      fSettingsPollTime = fValue
      SetSliderOptionValueST(fSettingsPollTime, "{1}")
   EndEvent

   Event OnDefaultST()
      fSettingsPollTime = _fDefSetPollTime
      SetSliderOptionValueST(fSettingsPollTime, "{1}")
   EndEvent

   Event OnHighlightST()
      SetInfoText("The amount of time in seconds between poll events.\n" +\
                  "Many statuses (such as naked detection) will not update between poll events.\n" +\
                  "Except when work is needed polls should be very fast so a short time is recommended.")
   EndEvent
EndState

State ST_FWK_POLL_NEAR
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iSettingsPollNearby)
      SetSliderDialogDefaultValue(_iDefSetPollNearby)
      SetSliderDialogRange(0, 10)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iSettingsPollNearby = fValue As Int
      SetSliderOptionValueST(iSettingsPollNearby)
   EndEvent

   Event OnDefaultST()
      iSettingsPollNearby = _iDefSetPollNearby
      SetSliderOptionValueST(iSettingsPollNearby)
   EndEvent

   Event OnHighlightST()
      SetInfoText("How often Devious Framework should poll nearby actors for their status.\n" +\
                  "This is counted in the number of poll events (configured above).  0 turns off detection.\n" +\
                  "This process more script intensive than a regular poll so should be performed less often.")
   EndEvent
EndState

State ST_FWK_POLL_DISTANCE
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iSettingsNearbyDistance)
      SetSliderDialogDefaultValue(_iDefSetNearbyDistance)
      SetSliderDialogRange(10, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iSettingsNearbyDistance = fValue As Int
      _qFramework.UpdatePollingDistance(iSettingsNearbyDistance)
      SetSliderOptionValueST(iSettingsNearbyDistance)
   EndEvent

   Event OnDefaultST()
      iSettingsNearbyDistance = _iDefSetNearbyDistance
      SetSliderOptionValueST(iSettingsNearbyDistance)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Updates the range of the detect nearby actors feature.\n" +\
                  "Warning: Although untested, increasing this may slow down your game noticeably.")
   EndEvent
EndState

State ST_FWK_DD_FIX
   Event OnSelectST()
      bSettingsDetectUnequip = !bSettingsDetectUnequip
      SetToggleOptionValueST(bSettingsDetectUnequip)
   EndEvent

   Event OnDefaultST()
      bSettingsDetectUnequip = _bDefSetDeviousFix
      SetToggleOptionValueST(bSettingsDetectUnequip)
   EndEvent

   Event OnHighlightST()
      SetInfoText("There is a certain game mechanic (I won't go into what it is) that allows\n" +\
                  "Devious Restraints to be errantly unequipped.\n" +\
                  "If you are experiencing this problem setting this might help.")
   EndEvent
EndState

State ST_FWK_ADD_CHEST
   Event OnMenuOpenST()
      String[] aszOptions = _qDfwUtil.AddStringToArray(_aszSlotList, S_ADD_NONE, True)
      SetMenuDialogStartIndex(0)
      SetMenuDialogDefaultIndex(0)
      SetMenuDialogOptions(aszOptions)
   EndEvent

   Event OnMenuAcceptST(Int iChosenIndex)
      ; Ignore the first option ("Add None")
      If (!iChosenIndex)
         Return
      EndIf

      ; Adjust the chosen index since the "Add None" is no longer in the list.
      iChosenIndex -= 1
 
      ; If the item is already in the list don't add it.
      Int iHexSlot = _qDfwUtil.ConvertStringToHex(_aszSlotList[iChosenIndex])
      If (0 <= aiSettingsSlotsChest.Find(iHexSlot))
         Return
      EndIf

      aiSettingsSlotsChest = _qDfwUtil.AddIntToArray(aiSettingsSlotsChest, iHexSlot)
   EndEvent

   Event OnDefaultST()
      Int iIndex = _aszDefSetSlotsChest.Length - 1
      aiSettingsSlotsChest = Utility.CreateIntArray(iIndex + 1)
      While (iIndex >= 0)
         aiSettingsSlotsChest[iIndex] = _qDfwUtil.ConvertStringToHex(_aszDefSetSlotsChest[iIndex])
         iIndex -= 1
      EndWhile
   EndEvent

   Event OnHighlightST()
      SetInfoText("Select an alternate slot considered as clothing to cover the chest.\n" +\
                  "This should match what is in the status menu.\n" +\
                  "Warning: Adding too many of these may slow down the game.")
   EndEvent
EndState

State ST_FWK_ADD_WAIST
   Event OnMenuOpenST()
      String[] aszOptions = _qDfwUtil.AddStringToArray(_aszSlotList, S_ADD_NONE, True)
      SetMenuDialogStartIndex(0)
      SetMenuDialogDefaultIndex(0)
      SetMenuDialogOptions(aszOptions)
   EndEvent

   Event OnMenuAcceptST(Int iChosenIndex)
      ; Ignore the first option ("Add None")
      If (!iChosenIndex)
         Return
      EndIf

      ; Adjust the chosen index since the "Add None" is no longer in the list.
      iChosenIndex -= 1
 
      ; If the item is already in the list don't add it.
      Int iHexSlot = _qDfwUtil.ConvertStringToHex(_aszSlotList[iChosenIndex])
      If (0 <= aiSettingsSlotsWaist.Find(iHexSlot))
         Return
      EndIf

      aiSettingsSlotsWaist = _qDfwUtil.AddIntToArray(aiSettingsSlotsWaist, iHexSlot)
   EndEvent

   Event OnDefaultST()
      Int iIndex = _aszDefSetSlotsWaist.Length - 1
      aiSettingsSlotsWaist = Utility.CreateIntArray(iIndex + 1)
      While (iIndex >= 0)
         aiSettingsSlotsWaist[iIndex] = _qDfwUtil.ConvertStringToHex(_aszDefSetSlotsWaist[iIndex])
         iIndex -= 1
      EndWhile
   EndEvent

   Event OnHighlightST()
      SetInfoText("Select an alternate slot considered as clothing to cover the waist.\n" +\
                  "This should match what is in the status menu.\n" +\
                  "Warning: Adding too many of these may slow down the game.")
   EndEvent
EndState

State ST_FWK_REM_CHEST
   Event OnMenuOpenST()
      ; Create a new array to hold all of the options.
      Int iIndex = aiSettingsSlotsChest.Length - 1
      String[] aszOptions = Utility.CreateStringArray(iIndex + 2)
      aszOptions[0] = S_REM_NONE

      ; Add a text value for each slot to the option array.
      While (0 <= iIndex)
         aszOptions[iIndex + 1] = GetSlotString(aiSettingsSlotsChest[iIndex], True)
         iIndex -= 1
      EndWhile

      ; Display the options
      SetMenuDialogStartIndex(0)
      SetMenuDialogDefaultIndex(0)
      SetMenuDialogOptions(aszOptions)
   EndEvent

   Event OnMenuAcceptST(Int iChosenIndex)
      ; Ignore the first option ("Remove None")
      If (!iChosenIndex)
         Return
      EndIf

      ; Don't allow this to be changed (but it can be viewed) if vulnerable.
      If (IsSecure())
         Return
      EndIf

      ; Adjust the chosen index since the "Remove None" is no longer in the list.
      iChosenIndex -= 1
 
      aiSettingsSlotsChest = _qDfwUtil.RemoveIntFromArray(aiSettingsSlotsChest, 0, iChosenIndex)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Remove an alternate chest clothing slot from the list.")
   EndEvent
EndState

State ST_FWK_REM_WAIST
   Event OnMenuOpenST()
      ; Create a new array to hold all of the options.
      Int iIndex = aiSettingsSlotsWaist.Length - 1
      String[] aszOptions = Utility.CreateStringArray(iIndex + 2)
      aszOptions[0] = S_REM_NONE

      ; Add a text value for each slot to the option array.
      While (0 <= iIndex)
         aszOptions[iIndex + 1] = GetSlotString(aiSettingsSlotsWaist[iIndex], True)
         iIndex -= 1
      EndWhile

      ; Display the options
      SetMenuDialogStartIndex(0)
      SetMenuDialogDefaultIndex(0)
      SetMenuDialogOptions(aszOptions)
   EndEvent

   Event OnMenuAcceptST(Int iChosenIndex)
      ; Ignore the first option ("Remove None")
      If (!iChosenIndex)
         Return
      EndIf

      ; Don't allow this to be changed (but it can be viewed) if vulnerable.
      If (IsSecure())
         Return
      EndIf

      ; Adjust the chosen index since the "Remove None" is no longer in the list.
      iChosenIndex -= 1
 
      aiSettingsSlotsWaist = _qDfwUtil.RemoveIntFromArray(aiSettingsSlotsWaist, 0, iChosenIndex)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Remove an alternate waist clothing slot from the list.")
   EndEvent
EndState


;***********************************************************************************************
;***                                STATES: VULNERABILITY                                    ***
;***********************************************************************************************
State ST_VUL_NUDE
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iVulnerabilityNude)
      SetSliderDialogDefaultValue(_iDefVulNude)
      SetSliderDialogRange(0, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iVulnerabilityNude = fValue As Int
      SetSliderOptionValueST(iVulnerabilityNude)
   EndEvent

   Event OnDefaultST()
      iVulnerabilityNude = _iDefVulNude
      SetSliderOptionValueST(iVulnerabilityNude)
   EndEvent

   Event OnHighlightST()
      SetInfoText("When naked the player will be reported as " + iVulnerabilityNude + "% vulnerable.\n" +\
                  "It is up to individual mods to decide what this vulnerability means.\n" +\
                  "Cumulative with other vulnerabilities.  Partial credit for partial coverage.")
   EndEvent
EndState

State ST_VUL_COLLAR
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iVulnerabilityCollar)
      SetSliderDialogDefaultValue(_iDefVulCollar)
      SetSliderDialogRange(0, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iVulnerabilityCollar = fValue As Int
      SetSliderOptionValueST(iVulnerabilityCollar)
   EndEvent

   Event OnDefaultST()
      iVulnerabilityCollar = _iDefVulCollar
      SetSliderOptionValueST(iVulnerabilityCollar)
   EndEvent

   Event OnHighlightST()
      SetInfoText("When the player is locked in a collar she will be reported as " + iVulnerabilityCollar + "% vulnerable.\n" +\
                  "It is up to individual mods to decide what this vulnerability means.\n" +\
                  "Cumulative with other vulnerabilities.")
   EndEvent
EndState

State ST_VUL_BINDER
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iVulnerabilityBinder)
      SetSliderDialogDefaultValue(_iDefVulBinder)
      SetSliderDialogRange(0, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iVulnerabilityBinder = fValue As Int
      SetSliderOptionValueST(iVulnerabilityBinder)
   EndEvent

   Event OnDefaultST()
      iVulnerabilityBinder = _iDefVulBinder
      SetSliderOptionValueST(iVulnerabilityBinder)
   EndEvent

   Event OnHighlightST()
      SetInfoText("When the player is locked in an arm binder she will be reported as " + iVulnerabilityBinder + "% vulnerable.\n" +\
                  "It is up to individual mods to decide what this vulnerability means.\n" +\
                  "Cumulative with other vulnerabilities.")
   EndEvent
EndState

State ST_VUL_GAGGED
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iVulnerabilityGagged)
      SetSliderDialogDefaultValue(_iDefVulGagged)
      SetSliderDialogRange(0, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iVulnerabilityGagged = fValue As Int
      SetSliderOptionValueST(iVulnerabilityGagged)
   EndEvent

   Event OnDefaultST()
      iVulnerabilityGagged = _iDefVulGagged
      SetSliderOptionValueST(iVulnerabilityGagged)
   EndEvent

   Event OnHighlightST()
      SetInfoText("When the player is gagged she will be reported as " + iVulnerabilityGagged + "% vulnerable.\n" +\
                  "It is up to individual mods to decide what this vulnerability means.\n" +\
                  "Cumulative with other vulnerabilities.")
   EndEvent
EndState

State ST_VUL_RESTRAINTS
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iVulnerabilityRestraints)
      SetSliderDialogDefaultValue(_iDefVulRestraints)
      SetSliderDialogRange(0, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iVulnerabilityRestraints = fValue As Int
      SetSliderOptionValueST(iVulnerabilityRestraints)
   EndEvent

   Event OnDefaultST()
      iVulnerabilityRestraints = _iDefVulRestraints
      SetSliderOptionValueST(iVulnerabilityRestraints)
   EndEvent

   Event OnHighlightST()
      SetInfoText("When the player is locked in other visible restraints she will be reported as " + iVulnerabilityRestraints + "% vulnerable.\n" +\
                  "It is up to individual mods to decide what this vulnerability means.\n" +\
                  "Cumulative with other vulnerabilities.  There are limited additioinal restraints (e.g. blindfold and hood are the same).")
   EndEvent
EndState

State ST_VUL_LEASHED
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iVulnerabilityLeashed)
      SetSliderDialogDefaultValue(_iDefVulLeashed)
      SetSliderDialogRange(0, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iVulnerabilityLeashed = fValue As Int
      SetSliderOptionValueST(iVulnerabilityLeashed)
   EndEvent

   Event OnDefaultST()
      iVulnerabilityLeashed = _iDefVulLeashed
      SetSliderOptionValueST(iVulnerabilityLeashed)
   EndEvent

   Event OnHighlightST()
      SetInfoText("When the player is gagged she will be reported as " + iVulnerabilityLeashed + "% vulnerable.\n" +\
                  "It is up to individual mods to decide what this vulnerability means.\n" +\
                  "Cumulative with other vulnerabilities.")
   EndEvent
EndState

State ST_VUL_FURNITURE
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iVulnerabilityFurniture)
      SetSliderDialogDefaultValue(_iDefVulFurniture)
      SetSliderDialogRange(0, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iVulnerabilityFurniture = fValue As Int
      SetSliderOptionValueST(iVulnerabilityFurniture)
   EndEvent

   Event OnDefaultST()
      iVulnerabilityFurniture = _iDefVulFurniture
      SetSliderOptionValueST(iVulnerabilityFurniture)
   EndEvent

   Event OnHighlightST()
      SetInfoText("When the player is sitting in BDSM furniture (a cross, a pillory, etc) she will be reported as " + iVulnerabilityFurniture + "% vulnerable.\n" +\
                  "It is up to individual mods to decide what this vulnerability means.\n" +\
                  "Cumulative with other vulnerabilities.")
   EndEvent
EndState

State ST_VUL_NIGHT
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iVulnerabilityNight)
      SetSliderDialogDefaultValue(_iDefVulNight)
      SetSliderDialogRange(0, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iVulnerabilityNight = fValue As Int
      SetSliderOptionValueST(iVulnerabilityNight)
   EndEvent

   Event OnDefaultST()
      iVulnerabilityNight = _iDefVulNight
      SetSliderOptionValueST(iVulnerabilityNight)
   EndEvent

   Event OnHighlightST()
      SetInfoText("After the sun has gone down the player will be reported as " + iVulnerabilityNight + "% vulnerable.\n" +\
                  "It is up to individual mods to decide what this vulnerability means.\n" +\
                  "Cumulative with other vulnerabilities.")
   EndEvent
EndState

State ST_VUL_REDUCE
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iVulnerabilityNakedReduce)
      SetSliderDialogDefaultValue(_iDefVulNakedReduce)
      SetSliderDialogRange(0, 300)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iVulnerabilityNakedReduce = fValue As Int
      SetSliderOptionValueST(iVulnerabilityNakedReduce)
   EndEvent

   Event OnDefaultST()
      iVulnerabilityNakedReduce = _iDefVulNakedReduce
      SetSliderOptionValueST(iVulnerabilityNakedReduce)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Some armour/clothes can be considred \"Naked\" by the SexLab Aroused mod.\n" +\
                  "When worn this armour makes the player vulnerable as if they were naked but not by as much.\n" +\
                  "This sets the % of naked vulnerability to use.  At 100% this armour is the same as being naked.")
   EndEvent
EndState


;***********************************************************************************************
;***                                 STATES: MOD FEATURES                                    ***
;***********************************************************************************************
State ST_MOD_RAPE_REDRESS
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iModRapeRedressTimeout)
      SetSliderDialogDefaultValue(_iDefRapeRedressTimeout)
      SetSliderDialogRange(0, 300)
      SetSliderDialogInterval(5)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iModRapeRedressTimeout = fValue As Int
      SetSliderOptionValueST(iModRapeRedressTimeout)
   EndEvent

   Event OnDefaultST()
      iModRapeRedressTimeout = _iDefRapeRedressTimeout
      SetSliderOptionValueST(iModRapeRedressTimeout)
   EndEvent

   Event OnHighlightST()
      SetInfoText("After the player has been raped it will take them some time to dress.\n" +\
                  "Attempts to dress in this time will be blocked and the timer will be reset.\n" +\
                  "Measured in game minutes.  0 turns off this feature.")
   EndEvent
EndState

State ST_MOD_NAKED_REDRESS
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iModNakedRedressTimeout)
      SetSliderDialogDefaultValue(_iDefNakedRedressTimeout)
      SetSliderDialogRange(0, 300)
      SetSliderDialogInterval(5)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iModNakedRedressTimeout = fValue As Int
      SetSliderOptionValueST(iModNakedRedressTimeout)
   EndEvent

   Event OnDefaultST()
      iModNakedRedressTimeout = _iDefNakedRedressTimeout
      SetSliderOptionValueST(iModNakedRedressTimeout)
   EndEvent

   Event OnHighlightST()
      SetInfoText("After the player has been detected as naked it will take them some time to dress.\n" +\
                  "Attempts to dress in this time will be blocked and the timer will be reset.\n" +\
                  "Measured in game minutes.  0 turns off this feature.")
   EndEvent
EndState

State ST_MOD_LEASH_STYLE
   Event OnSelectST()
      iModLeashStyle += 1
      If (_qFramework.LS_TELEPORT < iModLeashStyle)
         iModLeashStyle = 0
      EndIf
      SetTextOptionValueST(LeashStyleToString(iModLeashStyle))
   EndEvent

   Event OnDefaultST()
      iModLeashStyle = _iDefModLeashStyle
      SetTextOptionValueST(LeashStyleToString(iModLeashStyle))
   EndEvent

   Event OnHighlightST()
      SetInfoText("This mod has a rudamentary leash feature that modders can use.\n" +\
                  "For mods that use short leashes the \"Teleport\" style will always be used.\n" +\
                  "Drag: Can die when stuck.  Teleport: Can get stuck in walls.")
   EndEvent
EndState

State ST_MOD_LEASH_VISIBLE
   Event OnSelectST()
      bModLeashVisible = !bModLeashVisible
      SetToggleOptionValueST(bModLeashVisible)
   EndEvent

   Event OnDefaultST()
      bModLeashVisible = _bDefModLeashVisible
      SetToggleOptionValueST(bModLeashVisible)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Turn on or off the projectile which visually reprents the leash.")
   EndEvent
EndState

State ST_MOD_LEASH_INTERRUPT
   Event OnSelectST()
      bModLeashInterrupt = !bModLeashInterrupt
      SetToggleOptionValueST(bModLeashInterrupt)
   EndEvent

   Event OnDefaultST()
      bModLeashInterrupt = _bDefLeashInterrupt
      SetToggleOptionValueST(bModLeashInterrupt)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Toggles whether the leash interrupts scenes (in particular sex scenes) or not.")
   EndEvent
EndState

State ST_MOD_LEASH_DAMAGE
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iModLeashDamage)
      SetSliderDialogDefaultValue(_iDefLeashDamage)
      SetSliderDialogRange(0, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iModLeashDamage = fValue As Int
      SetSliderOptionValueST(iModLeashDamage)
   EndEvent

   Event OnDefaultST()
      iModLeashDamage = _iDefLeashDamage
      SetSliderOptionValueST(iModLeashDamage)
   EndEvent

   Event OnHighlightST()
      SetInfoText("The percent of the player's current health as damage to the player when she is dragged via her leash.")
   EndEvent
EndState

State ST_MOD_SLA_THRESHOLD
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iModSlaThreshold)
      SetSliderDialogDefaultValue(_iDefSlaThreshold)
      SetSliderDialogRange(0, 25)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iModSlaThreshold = fValue As Int
      SetSliderOptionValueST(iModSlaThreshold)
   EndEvent

   Event OnDefaultST()
      iModSlaThreshold = _iDefSlaThreshold
      SetSliderOptionValueST(iModSlaThreshold)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Tired of people wandering around Skyrim unaroused?  With this feature\n" +\
                  "anyone you meet with an arousal below this threshold will be randomly increased.\n" +\
                  "0 turns off this feature.  Most arousal will be 0 so this can be a very low number.")
   EndEvent
EndState

State ST_MOD_SLA_MIN
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iModSlaAdjustedMin)
      SetSliderDialogDefaultValue(_iDefSlaAdjustedMin)
      SetSliderDialogRange(0, 90)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iModSlaAdjustedMin = fValue As Int
      SetSliderOptionValueST(iModSlaAdjustedMin)
   EndEvent

   Event OnDefaultST()
      iModSlaAdjustedMin = _iDefSlaAdjustedMin
      SetSliderOptionValueST(iModSlaAdjustedMin)
   EndEvent

   Event OnHighlightST()
      SetInfoText("When you meet someone with an initial arousal below the threshold their arousal\n" +\
                  "will be randomly increased to a value between the minimum and maximum values.")
   EndEvent
EndState

State ST_MOD_SLA_MAX
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iModSlaAdjustedMax)
      SetSliderDialogDefaultValue(_iDefSlaAdjustedMax)
      SetSliderDialogRange(0, 90)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iModSlaAdjustedMax = fValue As Int
      SetSliderOptionValueST(iModSlaAdjustedMax)
   EndEvent

   Event OnDefaultST()
      iModSlaAdjustedMax = _iDefSlaAdjustedMax
      SetSliderOptionValueST(iModSlaAdjustedMax)
   EndEvent

   Event OnHighlightST()
      SetInfoText("When you meet someone with an initial arousal below the threshold their arousal\n" +\
                  "will be randomly increased to a value between the minimum and maximum values.")
   EndEvent
EndState

State ST_MOD_NIPPLE
   Event OnSelectST()
      bBlockNipple = !bBlockNipple
      SetToggleOptionValueST(bBlockNipple)
   EndEvent

   Event OnDefaultST()
      bBlockNipple = _bDefBlockNipple
      SetToggleOptionValueST(bBlockNipple)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Block equipping clothing to chest slots when nipple piercings are worn.")
   EndEvent
EndState

State ST_MOD_VAGINA
   Event OnSelectST()
      bBlockVagina = !bBlockVagina
      SetToggleOptionValueST(bBlockVagina)
   EndEvent

   Event OnDefaultST()
      bBlockVagina = _bDefBlockVagina
      SetToggleOptionValueST(bBlockVagina)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Block equipping clothing to waist slots when vaginal piercings are worn.")
   EndEvent
EndState

State ST_MOD_ARMOUR
   Event OnSelectST()
      bBlockArmour = !bBlockArmour
      SetToggleOptionValueST(bBlockArmour)
   EndEvent

   Event OnDefaultST()
      bBlockArmour = _bDefBlockArmour
      SetToggleOptionValueST(bBlockArmour)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Also block body armour on slot 0x00000004 when either piercings are worn.")
   EndEvent
EndState

State ST_MOD_HOBBLE
   Event OnSelectST()
      bBlockHobble = !bBlockHobble
      SetToggleOptionValueST(bBlockHobble)
   EndEvent

   Event OnDefaultST()
      bBlockHobble = _bDefBlockHobble
      SetToggleOptionValueST(bBlockHobble)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Block equipping clothing to waist slots when hobbled.")
   EndEvent
EndState

State ST_MOD_SHOES
   Event OnSelectST()
      bBlockShoes = !bBlockShoes
      SetToggleOptionValueST(bBlockShoes)
   EndEvent

   Event OnDefaultST()
      bBlockShoes = _bDefBlockShoes
      SetToggleOptionValueST(bBlockShoes)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Wearing a hobble/boots also prevents wearing armour/clothing footwear.")
   EndEvent
EndState

State ST_MOD_ARMS
   Event OnSelectST()
      bBlockArms = !bBlockArms
      SetToggleOptionValueST(bBlockArms)
   EndEvent

   Event OnDefaultST()
      bBlockArms = _bDefBlockArms
      SetToggleOptionValueST(bBlockArms)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Block chest clothing and armour when your arms are locked." +\
                  "(e.g. in an arm binder or yoke)")
   EndEvent
EndState

State ST_MOD_BLOCK_LEASH
   Event OnSelectST()
      bBlockLeash = !bBlockLeash
      SetToggleOptionValueST(bBlockLeash)
   EndEvent

   Event OnDefaultST()
      bBlockLeash = _bDefBlockLeash
      SetToggleOptionValueST(bBlockLeash)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Block chest clothing and armour when you are leashed.")
   EndEvent
EndState

State ST_MOD_ADD_EXC_HOBBLE
   Event OnMenuOpenST()
      String[] aszOptions = CreateWornOptions(S_ADD_NONE)
      SetMenuDialogStartIndex(0)
      SetMenuDialogDefaultIndex(0)
      SetMenuDialogOptions(aszOptions)
   EndEvent

   Event OnMenuAcceptST(Int iChosenIndex)
      ; Ignore the first option ("Add None")
      If (!iChosenIndex)
         Return
      EndIf

      ; Recreate the list to get the indexed value.
      ; With the user being in the menu we should have some time for this wasteful operation.
      String[] aszOptions = CreateWornOptions(S_ADD_NONE)

      ; The item is in the form "0x00000000: <Name>".  Use the first ten characters.
      Int iFormId = _qDfwUtil.ConvertStringToHex(StringUtil.Substring(aszOptions[iChosenIndex], 0, 10))

      ; If the item is already in the list don't add it.
      If (0 <= aiBlockExceptionsHobble.Find(iFormId))
         Return
      EndIf

      aiBlockExceptionsHobble = _qDfwUtil.AddIntToArray(aiBlockExceptionsHobble, iFormId)
   EndEvent

   Event OnDefaultST()
      aiBlockExceptionsHobble = None
   EndEvent

   Event OnHighlightST()
      SetInfoText("Some items should not be blocked by a hobble (Dresses for example).\n" +\
                  "Note: The item must be worn and setting security must be allowed to use this feature.")
   EndEvent
EndState

State ST_MOD_REM_EXC_HOBBLE
   Event OnMenuOpenST()
      ; Create a new array to hold all of the options.
      Int iIndex = aiBlockExceptionsHobble.Length - 1
      String[] aszOptions = Utility.CreateStringArray(iIndex + 2)
      aszOptions[0] = S_REM_NONE

      ; Add a text value for each slot to the option array.
      While (0 <= iIndex)
         aszOptions[iIndex + 1] = "0x" + _qDfwUtil.ConvertHexToString(aiBlockExceptionsHobble[iIndex], 8)
         iIndex -= 1
      EndWhile

      ; Display the options
      SetMenuDialogStartIndex(0)
      SetMenuDialogDefaultIndex(0)
      SetMenuDialogOptions(aszOptions)
   EndEvent

   Event OnMenuAcceptST(Int iChosenIndex)
      ; Ignore the first option ("Remove None")
      If (!iChosenIndex)
         Return
      EndIf

      ; Don't allow this to be changed (but it can be viewed) if vulnerable.
      If (IsSecure())
         Return
      EndIf

      ; Adjust the chosen index since the "Remove None" is no longer in the list.
      iChosenIndex -= 1
 
      aiBlockExceptionsHobble = _qDfwUtil.RemoveIntFromArray(aiBlockExceptionsHobble, 0, iChosenIndex)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Remove an exception for clothing blocked by the hobble.")
   EndEvent
EndState


;***********************************************************************************************
;***                                    STATES: STATUS                                       ***
;***********************************************************************************************
State ST_STA_KEYWORD
   Event OnMenuOpenST()
      Actor aActor = _aPlayer
      If (!_bInfoForPlayer)
         aActor = _qFramework.GetNearestActor(0)
      EndIf

      String[] aszOptions = CreateWornOptions("Exit", aActor, False, True)
      SetMenuDialogStartIndex(0)
      SetMenuDialogDefaultIndex(0)
      SetMenuDialogOptions(aszOptions)
   EndEvent

   Event OnMenuAcceptST(Int iChosenIndex)
      ; Ignore the first option ("Remove None")
      If (!iChosenIndex)
         Return
      EndIf

      Actor aActor = _aPlayer
      If (!_bInfoForPlayer)
         aActor = _qFramework.GetNearestActor(0)
      EndIf

      ; Recreate the list to get the indexed value.
      ; With the user being in the menu we should have some time for this wasteful operation.
      String[] aszOptions = CreateWornOptions("Exit", aActor, False, True)

      String szFormId = StringUtil.Substring(aszOptions[iChosenIndex], 0, 10)
      Int iFormId = _qDfwUtil.ConvertStringToHex(szFormId)
      Form oForm = Game.GetForm(iFormId)

      ; Get all of the keywords for the form.
      Int iIndex = oForm.GetNumKeywords() - 1
      String szDisplayString = "(" + (iIndex + 1) + ") " + szFormId + " - " + oForm.GetName() + "\n"
      While (0 <= iIndex)
         szDisplayString += oForm.GetNthKeyword(iIndex) + "\n"
         iIndex -= 1
      EndWhile

      ShowMessage(szDisplayString, False)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Select this to get all keywords for an item.")
   EndEvent
EndState

State ST_INFO_FOR_PLAYER
   Event OnSelectST()
      _bInfoForPlayer = !_bInfoForPlayer
      SetToggleOptionValueST(_bInfoForPlayer)
   EndEvent

   Event OnDefaultST()
      _bInfoForPlayer = True
      SetToggleOptionValueST(_bInfoForPlayer)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Use the player as the actor for the varius status information features.\n" +\
                  "When off the nearest actor to the player will be used instead if possible.")
   EndEvent
EndState

State ST_INFO_FACTIONS
   Event OnSelectST()
      Actor aActor = _aPlayer
      If (!_bInfoForPlayer)
         aActor = _qFramework.GetNearestActor(0)
      EndIf

      String[] aszInfo

      ; Create a list of information to present to the user.
      Faction[] aoFaction = aActor.GetFactions(-128, 127)
      Int iIndex = (aoFaction.Length - 1)

      While (0 <= iIndex)
         Faction oFaction = aoFaction[iIndex]
         String szFormId = "0x" + _qDfwUtil.ConvertHexToString(oFaction.GetFormID(), 8)
         String szName = oFaction.GetName()
         Int iRank = aActor.GetFactionRank(oFaction)
         Bool bInFaction = aActor.IsInFaction(oFaction)
         aszInfo = _qDfwUtil.AddStringToArray(aszInfo, szFormId + "-" + szName + ": " + iRank + " (" + bInFaction + ")")
         iIndex -= 1
      EndWhile

      ; Display the information for the user.
      PresentInformation(aszInfo, "Player Factions")
   EndEvent

   Event OnHighlightST()
      SetInfoText("Display the factions the player is in.")
   EndEvent
EndState

State ST_INFO_NEARBY
   Event OnSelectST()
      String[] aszInfo

      ; Create a list of information to present to the user.
      Form[] aaNearby = _qFramework.GetNearbyActorList(0)
      Int[] aiFlags =  _qFramework.GetNearbyActorFlags()
      Int iSafety = 5
      While (iSafety && (aaNearby.Length != aiFlags.Length))
         ; The lists change between getting the actors and the flags.  Try again.
         iSafety -= 1
         aaNearby = _qFramework.GetNearbyActorList(0)
         aiFlags =  _qFramework.GetNearbyActorFlags()
      EndWhile

      If (!iSafety)
         aszInfo = _qDfwUtil.AddStringToArray(aszInfo, "Error Getting Nearby List: " + aaNearby.Length + "-" + aiFlags.Length + "!")
      Else
         Int iCount = aiFlags.Length
         Int iIndex
         While (iIndex < iCount)
            Actor aActor = (aaNearby[iIndex] As Actor)
            aszInfo = _qDfwUtil.AddStringToArray(aszInfo, "0x" + _qDfwUtil.ConvertHexToString(aiFlags[iIndex], 8) + " " + aActor.GetDisplayName())
            iIndex += 1
         EndWhile
      EndIf

      ; Display the information for the user.
      PresentInformation(aszInfo, "Nearby Actors")
   EndEvent

   Event OnHighlightST()
      SetInfoText("Display Actors in the nearby actor's list and their actor flags:\n" +\
                  "0x001 Estimate  0x002 Important   0x004 Child  0x008 Guard  0x010 Merchant\n" +\
                  "0x080 Dominant  0x100 submissive  0x200 slave  0x400 Owner  0x800 Trader\n")
   EndEvent
EndState

State ST_INFO_KNOWN
   Event OnSelectST()
      String[] aszInfo

      ; Create a list of information to present to the user.
      Form[] aaKnown = _qFramework.GetKnownActors()

      Int iCount = aaKnown.Length
      Int iIndex
      While (iIndex < iCount)
         Actor aActor = (aaKnown[iIndex] As Actor)
         aszInfo = _qDfwUtil.AddStringToArray(aszInfo, iIndex + ": " + \
            aActor.GetDisplayName() + " A(" + _qFramework.GetActorAnger(aActor, -1) + \
                                     ") C(" + _qFramework.GetActorConfidence(aActor, -1) + \
                                     ") D(" + _qFramework.GetActorDominance(aActor, -1) + \
                                     ") I(" + _qFramework.GetActorInterest(aActor, -1) + ")")
         iIndex += 1
      EndWhile

      ; Display the information for the user.
      PresentInformation(aszInfo, "Known Actors")
   EndEvent

   Event OnHighlightST()
      SetInfoText("Display disposition of actors who have recently been in contact with the player.\n" +\
                  "A: Anger  C: Confidence  D: Dominance  I: Interest")
   EndEvent
EndState

State ST_INFO_DEBUG
   Event OnSelectST()
      String[] aszInfo

      ; Create a list of information to present to the user.
      ActorBase abPlayer = _aPlayer.GetActorBase()
      Int iCount = abPlayer.GetSpellCount()
      Int iIndex
      While (iIndex < iCount)
         Spell oSpell = abPlayer.GetNthSpell(iIndex)
         aszInfo = _qDfwUtil.AddStringToArray(aszInfo, oSpell.GetName())
         iIndex += 1
      EndWhile

      ; Display the information for the user.
      PresentInformation(aszInfo, "Actor Base Spells")
   EndEvent

   Event OnHighlightST()
      SetInfoText("Display debug information.")
   EndEvent
EndState


;***********************************************************************************************
;***                                    STATES: DEBUG                                        ***
;***********************************************************************************************
State ST_DBG_LEVEL
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iLogLevel)
      SetSliderDialogDefaultValue(_iDefLogLevel)
      SetSliderDialogRange(0, 5)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iLogLevel = fValue As Int
      SetSliderOptionValueST(iLogLevel)
   EndEvent

   Event OnDefaultST()
      iLogLevel = _iDefLogLevel
      SetSliderOptionValueST(iLogLevel)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Set the level of messages that go to the papyrus log file.\n" +\
                  "(0 = Off)  (1 = Critical)  (2 = Error)  (3 = Information)  (4 = Debug)  (5 = Trace)\n" +\
                  "This should be set to the maximum value to have a complete log file.")
   EndEvent
EndState

State ST_DBG_SCREEN
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iLogLevelScreen)
      SetSliderDialogDefaultValue(_iDefLogLevelScreen)
      SetSliderDialogRange(0, 5)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iLogLevelScreen = fValue As Int
      SetSliderOptionValueST(iLogLevelScreen)
   EndEvent

   Event OnDefaultST()
      iLogLevelScreen = _iDefLogLevelScreen
      SetSliderOptionValueST(iLogLevelScreen)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Set the level of messages that go to the screen.\n" +\
                  "(0 = Off)  (1 = Critical)  (2 = Error)  (3 = Information)  (4 = Debug)  (5 = Trace)\n" +\
                  "This should be Critical to reduce clutter on your screen but still get event messages.")
   EndEvent
EndState

