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
; WARNING:
; Don't make any function calls to or access any properties of the main Devious Framework script
; (_qFramework) except while the user is accessing the menu.  Because the main script accesses
; this MCM script often and at random times, deadlock can occur if this MCM script is also
; accessing the main script at the same time.
; In particular avoid calling functions of the main script during initialization.
;
; � Copyright 2016 legume-Vancouver of GitHub
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
String S_ERROR    = "Error"

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

; A flag to prevent initialization from happening twice.
Bool _bInitBegun

; Keeps track of the last page the user viewed.
String _szLastPage

; *** Private Options ***
Bool _bSecureHardcore
Bool _bInfoForPlayer

; *** Toggle Options ***
Bool Property bModLeashVisible        Auto
Bool Property bModLeashInterrupt      Auto
Bool Property bModFadeInUseDoor       Auto
Bool Property bModCrawlBlockActivate  Auto
Bool Property bBlockNipple            Auto
Bool Property bBlockVagina            Auto
Bool Property bBlockHobble            Auto
Bool Property bBlockShoes             Auto
Bool Property bBlockArmour            Auto
Bool Property bBlockArms              Auto
Bool Property bBlockLeash             Auto
Bool Property bSaveGameConfirm        Auto
Bool Property bConNativeSaves         Auto
Bool Property bModBlockOnGameLoad     Auto
Bool Property bSettingsDetectUnequip  Auto
Bool Property bEasternHouseIsWindhelm Auto
Bool Property bShutdownMod            Auto
Bool Property bShutdownSecure         Auto

; *** Float Slider Options ***
Float Property fSettingsPollTime Auto
Float Property fModSaveMinTime   Auto

; *** Integer Slider Options ***
Int Property iSettingsSecurity          Auto
Int Property iSettingsPollNearby        Auto
Int Property iSettingsNearbyDistance    Auto
Int Property iVulnerabilityNude         Auto
Int Property iVulnerabilityCollar       Auto
Int Property iVulnerabilityBinder       Auto
Int Property iVulnerabilityGagged       Auto
Int Property iVulnerabilityRestraints   Auto
Int Property iVulnerabilityLeashed      Auto
Int Property iVulnerabilityFurniture    Auto
Int Property iVulnerabilityNight        Auto
Int Property iDispWillingGuards         Auto
Int Property iDispWillingMerchants      Auto
Int Property iDispWillingBdsm           Auto
Int Property iModRapeRedressTimeout     Auto
Int Property iModNakedRedressTimeout    Auto
Int Property iModLeashCombatChance      Auto
Int Property iModLeashDamage            Auto
Int Property iModLeashMinLength         Auto
Int Property iModSlaThreshold           Auto
Int Property iModMultiPoleAnimation     Auto
Int Property iModMultiWallAnimation     Auto
Int Property iModSlaAdjustedMin         Auto
Int Property iModSlaAdjustedMax         Auto
Int Property iModDialogueTargetStyle    Auto
Int Property iModDialogueTargetRetries  Auto
Int Property iModTogglePoseKey          Auto
Int Property iModTogglePose             Auto
Int Property iModCyclePoseKey           Auto
Int Property iModCollectorSpecialCost   Auto
Int Property iModHelpKey                Auto
Int Property iModAttentionKey           Auto
Int Property iModCallTimeout            Auto
Int Property iModSaveGameStyle          Auto
Int Property iModSaveKey                Auto
Int Property iConConsoleVulnerability   Auto
Int Property iLogLevel                  Auto
Int Property iLogLevelScreenGeneral     Auto
Int Property iLogLevelScreenDebug       Auto
Int Property iLogLevelScreenStatus      Auto
Int Property iLogLevelScreenMaster      Auto
Int Property iLogLevelScreenNearby      Auto
Int Property iLogLevelScreenLeash       Auto
Int Property iLogLevelScreenEquip       Auto
Int Property iLogLevelScreenArousal     Auto
Int Property iLogLevelScreenInteraction Auto
Int Property iLogLevelScreenLocation    Auto
Int Property iLogLevelScreenRedress     Auto
Int Property iLogLevelScreenSave        Auto
Int Property iVulnerabilityNakedReduce  Auto

; *** Enumeration Options ***
Int Property iModLeashStyle Auto

; *** Lists and Advanced Options ***
String[] _aszDefSetSlotsChest
String[] _aszDefSetSlotsWaist
Int[] Property aiSettingsSlotsChest Auto
Int[] Property aiSettingsSlotsWaist Auto
Int[] Property aiBlockExceptionsHobble Auto

; A reference to the main framework quest script.
; Deadlock Warning: Don't use this except during menu access.  See file header for details.
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
Function UpdateScript(Int iUpgradeFrom=-1)
   ; If we weren't explicitly given a version to upgrade from, assume the current version.
   ; Note: We can't use CurrentVersion directly as it can be updated by the MCM scripts.
   ;       This happens if OnVersionUpdate() returns due to init already proceeding.
   If (-1 == iUpgradeFrom)
      iUpgradeFrom = CurrentVersion
   EndIf

   ; Hardcore mode is turned off on all script updates.
   _bSecureHardcore = False

   Debug.Trace("[DFW-MCM] Updating Script: " + iUpgradeFrom + " => " + GetVersion())
   Debug.Notification("[DFW-MCM] Updating Script: " + iUpgradeFrom + " => " + GetVersion())

   ; Very basic initialization.
   If (1 > iUpgradeFrom)
      _aPlayer = Game.GetPlayer()
      _qFramework = ((Self As Quest) As dfwDeviousFramework)
   EndIf

   ; Historical configuration...
   If (2 > iUpgradeFrom)
      fSettingsPollTime         =  1.0
      iSettingsPollNearby       =  5
      iSettingsNearbyDistance   = 65
      bSettingsDetectUnequip    = False
      bBlockNipple              = True
      bBlockVagina              = True
      bBlockHobble              = True
      bBlockShoes               = True
      bBlockArmour              = True
      bBlockArms                = True
      iVulnerabilityNude        = 15
      iVulnerabilityNakedReduce = 50
      iVulnerabilityCollar      = 25
      iVulnerabilityBinder      = 20
      iVulnerabilityGagged      = 20
      iVulnerabilityRestraints  = 10
      iVulnerabilityNight       =  5
      iModRapeRedressTimeout    = 90
      iModNakedRedressTimeout   = 20
      iLogLevel                 =  5

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

   If (3 > iUpgradeFrom)
      ; 0 = LS_AUTO
      ; Don't access LS_AUTO (from the main script) here to avoid deadlocks.
      iModLeashStyle        = 0
      bModLeashVisible      = True
      iVulnerabilityLeashed = 10
      bBlockLeash           = True

      _bInfoForPlayer = True

      ; Block List Exceptions
      _qDfwUtil = ((Self As Quest) As dfwUtil)
      aiSettingsSlotsChest = New Int[2]
      aiSettingsSlotsChest[0] = _qDfwUtil.ConvertStringToHex(_aszDefSetSlotsChest[0])
      aiSettingsSlotsChest[1] = _qDfwUtil.ConvertStringToHex(_aszDefSetSlotsChest[1])
      aiSettingsSlotsWaist = New Int[2]
      aiSettingsSlotsWaist[0] = _qDfwUtil.ConvertStringToHex(_aszDefSetSlotsWaist[0])
      aiSettingsSlotsWaist[1] = _qDfwUtil.ConvertStringToHex(_aszDefSetSlotsWaist[1])
   EndIf

   If (4 > iUpgradeFrom)
      bModLeashInterrupt = True
   EndIf

   ; Updated the default nearby distance from 40 to 65.
   If (5 > iUpgradeFrom)
      ; If the distance setting equals the previous default update it now.
      If (40 == iSettingsNearbyDistance)
         iSettingsNearbyDistance = 65
      EndIf

      ; Added SexLab Aroused (SLA) arousal adjustments in version 5.
      iModSlaThreshold   =  3
      iModSlaAdjustedMin =  5
      iModSlaAdjustedMax = 50

      ; Made leash damage configurable.
      iModLeashDamage  = 12
   EndIf

   ; Added a vulnerability configuration for BDSM furniture in version 6.
   If (6 > iUpgradeFrom)
      iVulnerabilityFurniture = 10
   EndIf

   ; Changed the default security setting to allow changing settings in new games where the
   ; player is already vulnerable in version 7.
   If (7 > iUpgradeFrom)
      ; Set the Security level to the maximum.  This does not prevent settings to be changed
      ; when installing the mod into games where the player is already vulnerable.
      iSettingsSecurity = 100

      ; Also in this version I added furniture status which come from the ZAZ Animation Pack.
      _qZbfPlayerSlot = zbfBondageShell.GetApi().FindPlayer()
   EndIf

   ; Separated logging into different classes.
   If (8 > iUpgradeFrom)
      iLogLevelScreenGeneral = 3
      iLogLevelScreenStatus  = 3
      iLogLevelScreenMaster  = 3
      iLogLevelScreenNearby  = 3
      iLogLevelScreenLeash   = 3
      iLogLevelScreenEquip   = 3
   EndIf

   If (9 > iUpgradeFrom)
      bModBlockOnGameLoad = False
   EndIf

   If (10 > iUpgradeFrom)
      ; 2 = DS_MANUAL
      ; Don't access DS_MANUAL (from the main script) here to avoid deadlocks.
      iModDialogueTargetStyle = 2
   EndIf

   If (11 > iUpgradeFrom)
      iDispWillingGuards        =  10
      iDispWillingMerchants     =   3
      iDispWillingBdsm          = -25
      iLogLevelScreenArousal    =   3
      iModDialogueTargetRetries =   0
   EndIf

   If (12 > iUpgradeFrom)
      iModHelpKey      = 0x00
      iModAttentionKey = 0x00

      iModCallTimeout            =  30
      iModLeashMinLength         = 550
      iLogLevelScreenRedress     =   3
      iLogLevelScreenDebug       =   3
      iLogLevelScreenInteraction =   3
      iLogLevelScreenLocation    =   3
   EndIf

   If (13 > iUpgradeFrom)
      iModLeashCombatChance  = 20
   EndIf

   If (14 > iUpgradeFrom)
      iModSaveGameStyle = 0
      bSaveGameConfirm  = False
   EndIf

   If (15 > iUpgradeFrom)
      iModSaveKey         = 0x00
      iLogLevelScreenSave = 3
      fModSaveMinTime     = 5.0
   EndIf

   If (16 > iUpgradeFrom)
      bEasternHouseIsWindhelm = False
   EndIf

   If (17 > iUpgradeFrom)
      Pages = New String[8]
      Pages[0] = "Framework Settings"
      Pages[1] = "Vulnerability"
      Pages[2] = "NPC Disposition"
      Pages[3] = "Mod Features"
      Pages[4] = "Game Control"
      Pages[5] = "Mod Compatibility"
      Pages[6] = "Status"
      Pages[7] = "Debug"

      iConConsoleVulnerability = 100
      bShutdownMod             = False
      bShutdownSecure          = False
   EndIf

   If (18 > iUpgradeFrom)
      bConNativeSaves = False
   EndIf

   If (19 > iUpgradeFrom)
      bModFadeInUseDoor = True
   EndIf

   If (20 > iUpgradeFrom)
      iModCollectorSpecialCost = 10000
      iModMultiPoleAnimation   =    -7
      iModMultiWallAnimation   =    -7
      iModTogglePoseKey        =  0x00
      iModTogglePose           =     1
      iModCyclePoseKey         =  0x00
      bModCrawlBlockActivate   =  True
   EndIf

   ; Any time the script is updated have the main script sync it's parameters.
   ; Give the main script some time to initialize first.
   Utility.Wait(3.0)
   SendSettingChangedEvent()
EndFunction

; Version of the MCM script.
; Unrelated to the Devious Framework Version.
Int Function GetVersion()
; zxc
If (7 != iConConsoleVulnerability)
   iConConsoleVulnerability = 7
EndIf
If (90 != iModCallTimeout)
   iModCallTimeout = 90
EndIf
   ; Reset the version number.
   If (19 < CurrentVersion)
      CurrentVersion = 19
   EndIf

   ; Update all quest variables upon loading each game.
   ; There are too many things that can cause them to become invalid.
   _qFramework = ((Self As Quest) As dfwDeviousFramework)
   _qDfwUtil = ((Self As Quest) As dfwUtil)
   _qZbfPlayerSlot = zbfBondageShell.GetApi().FindPlayer()

   Return 20
EndFunction

Event OnConfigInit()
   Debug.Trace("[DFW-MCM] TraceEvent OnConfigInit")

   If (_bInitBegun)
      Debug.Trace("[DFW-MCM] TraceEvent OnConfigInit: Done (Init Begun)")
      Return
   EndIf
   _bInitBegun = True
   UpdateScript(0)
   Debug.Trace("[DFW-MCM] TraceEvent OnConfigInit: Done")
EndEvent

Event OnVersionUpdate(Int iNewVersion)
   Debug.Trace("[DFW-MCM] TraceEvent OnVersionUpdate")

   If (_bInitBegun)
      Debug.Trace("[DFW-MCM] TraceEvent OnVersionUpdate: Done (Init Begun)")
      Return
   EndIf

   _bInitBegun = True
   UpdateScript()
   Debug.Trace("[DFW-MCM] TraceEvent OnVersionUpdate: Done")
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
   Return S_ERROR
EndFunction

String Function PoseToString(Int iPose)
   If (0 == iPose)
      Return "Default Idle"
   ElseIf (1 == iPose)
      Return "Kneeling"
   ElseIf (2 == iPose)
      Return "Kneeling Spread"
   ElseIf (3 == iPose)
      Return "Crawling"
   EndIf
   Return S_ERROR
EndFunction

String Function DialogueStyleToString(Int iStyle)
   If (_qFramework.DS_OFF == iStyle)
      Return "Off"
   ElseIf (_qFramework.DS_AUTO == iStyle)
      Return "Automatic"
   ElseIf (_qFramework.DS_MANUAL == iStyle)
      Return "Manual"
   EndIf
   Return S_ERROR
EndFunction

String Function SaveGameStyleToString(Int iStyle)
   If (0 == iStyle)
      Return "Off"
   ElseIf (1 == iStyle)
      Return "Overwrite"
   ElseIf (2 == iStyle)
      Return "Full Control"
   EndIf
   Return S_ERROR
EndFunction

String Function GetFactionName(Faction oFaction)
   String szFactionName = oFaction.GetName()
   If (!szFactionName)
      Int iFormId = oFaction.GetFormID()
      If (0x00000DB1 == iFormId)
         szFactionName = "Player Faction"
      ElseIf (0x0001BCC0 == iFormId)
         szFactionName = "Bandit Faction"
      ElseIf (0x00034B74 == iFormId)
         szFactionName = "Necromancer Faction"
      ElseIf (0x0009C754 == iFormId)
         szFactionName = "Windhelm Blacksmith"
      ElseIf (0x0009DA3C == iFormId)
         szFactionName = "Rustleif's House"
      ElseIf (0x0009DD4F == iFormId)
         szFactionName = "MS09 Player Ally"
      ElseIf (0x000E3609 == iFormId)
         szFactionName = "Druadach Redoubt"
      ElseIf (0x000F18E9 == iFormId)
         szFactionName = "Kolskeggr Pavo"
      ElseIf (0x000F18EA == iFormId)
         szFactionName = "Markarth Ghorza"
      ElseIf (0x000F2073 == iFormId)
         szFactionName = "Player Bed"
      ElseIf (0x000F7630 == iFormId)
         szFactionName = "Civil War Finale Allies"
      ElseIf (0x00105D13 == iFormId)
         szFactionName = "WE Aggressive Adventurer"
      ElseIf (0x0010F5A0 == iFormId)
         szFactionName = "Companions Training Special Combat Hate"
      ElseIf (0x0002817F == iFormId)
         szFactionName = "TownDawnstarFaction"
      ElseIf (0x0002817B == iFormId)
         szFactionName = "TownDragonBridgeFaction"
      ElseIf (0x00028177 == iFormId)
         szFactionName = "TownFalkreathFaction"
      ElseIf (0x00028185 == iFormId)
         szFactionName = "TownIvarsteadFaction"
      ElseIf (0x0002817A == iFormId)
         szFactionName = "TownKarthwastenFaction"
      ElseIf (0x00028178 == iFormId)
         szFactionName = "TownMarkarthFaction"
      ElseIf (0x0002817D == iFormId)
         szFactionName = "TownMorthalFaction"
      ElseIf (0x00028179 == iFormId)
         szFactionName = "TownOldHroldanFaction"
      ElseIf (0x00028186 == iFormId)
         szFactionName = "TownRiftenFaction"
      ElseIf (0x00013481 == iFormId)
         szFactionName = "TownRiverwoodFaction"
      ElseIf (0x00028174 == iFormId)
         szFactionName = "TownRoriksteadFaction"
      ElseIf (0x00028184 == iFormId)
         szFactionName = "TownShorsStoneFaction"
      ElseIf (0x0002817C == iFormId)
         szFactionName = "TownSolitudeFaction"
      ElseIf (0x00028172 == iFormId)
         szFactionName = "TownWhiterunFaction"
      ElseIf (0x00028173 == iFormId)
         szFactionName = "TownWindhelmFaction"
      ElseIf (0x00028181 == iFormId)
         szFactionName = "TownWinterholdFaction"
      Else
         szFactionName = "0x" + _qDfwUtil.ConvertHexToString(iFormId, 8)
      EndIf
   EndIf
   Return szFactionName
EndFunction

String Function GetMultiAnimationName(Int iAnimationIndex)
   If (-6 == iAnimationIndex)
      Return "Cycle Real"
   ElseIf (-5 == iAnimationIndex)
      Return "Cycle Alt"
   ElseIf (-4 == iAnimationIndex)
      Return "Cycle Both"
   ElseIf (-3 == iAnimationIndex)
      Return "Random Real"
   ElseIf (-2 == iAnimationIndex)
      Return "Random Alt"
   ElseIf (-1 == iAnimationIndex)
      Return "Random Both"
   ElseIf (0 == iAnimationIndex)
      Return "Arms Back"
   ElseIf (1 == iAnimationIndex)
      Return "Kneeling"
   ElseIf (2 == iAnimationIndex)
      Return "Arms Up"
   ElseIf (3 == iAnimationIndex)
      Return "Arms Overhead"
   ElseIf (4 == iAnimationIndex)
      Return "Upside Down"
   ElseIf (5 == iAnimationIndex)
      Return "Suspended"
   ElseIf (6 == iAnimationIndex)
      Return "Alt Standing Straight"
   ElseIf (7 == iAnimationIndex)
      Return "Alt Standing Spread"
   ElseIf (8 == iAnimationIndex)
      Return "Alt Hanging Spread"
   ElseIf (9 == iAnimationIndex)
      Return "Alt Hanging Weights"
   ElseIf (10 == iAnimationIndex)
      Return "Alt Bent Over"
   ElseIf (11 == iAnimationIndex)
      Return "Alt Standing Eagle"
   EndIf
   ; -7 == Recommended
   Return "Recommended"
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
   iSlotsChecked += (CS_RESERVED1 + CS_RESERVED2 + CS_RESERVED3)

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

; Checks if this mod needs to start registering for a newly defined key.  Also checks if the
; mod should deregister for keypresses.
; Handle key registration in this script.  Events should be sent to all scripts in the same quest.
Function RegisterNewKey(Int iOldKey, Int iNewKey)
   ; If the new key has been cleared we only need to consider deregistering.
   If (!iNewKey)
      If (iOldKey && ((iModTogglePoseKey != iOldKey) && (iModCyclePoseKey != iOldKey) && \
                      (iModHelpKey != iOldKey) &&       (iModAttentionKey != iOldKey) && \
                      (iModSaveKey != iOldKey)))
         UnregisterForKey(iOldKey)
      EndIf
      Return
   EndIf

   ; Register for the new event if it is not already registered.
   If ((iModTogglePoseKey != iNewKey) && (iModCyclePoseKey != iNewKey) && \
       (iModHelpKey != iNewKey) &&       (iModAttentionKey != iNewKey) && \
       (iModSaveKey != iNewKey))
      RegisterForKey(iNewKey)
   EndIf
EndFunction

Bool Function IsSecure()
   Return False

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

Function SendSettingChangedEvent(String sCategory="")
   Int iModEvent = ModEvent.Create("DFW_MCM_Changed")
   ModEvent.PushString(iModEvent, sCategory)
   ModEvent.Send(iModEvent)
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

      ; Show the information to the user.
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
   ElseIf ("NPC Disposition" == szPage)
      DisplayNpcDispositionPage(bSecure)
   ElseIf ("Mod Features" == szPage)
      DisplayModFeaturesPage(bSecure)
   ElseIf ("Game Control" == szPage)
      DisplayGameControlPage(bSecure)
   ElseIf ("Mod Compatibility" == szPage)
      DisplayModCompatibilityPage(bSecure)
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
   AddSliderOptionST("ST_FWK_POLL_TIME",     "Poll Time",             fSettingsPollTime, "{1}")
   AddSliderOptionST("ST_FWK_POLL_NEAR",     "Nearby Poll Frequency", iSettingsPollNearby)
   AddSliderOptionST("ST_FWK_POLL_DISTANCE", "Nearby Poll Distance",  iSettingsNearbyDistance)

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

   ; For each header find out if it is active and add a marker to indicate if it is so.
   String szTitle = "Nude"
   Int iNakedLevel = _qFramework.GetNakedLevel()
   If (_qFramework.NS_NAKED == iNakedLevel)
      ; Both slots are naked.
      szTitle += " *"
   ElseIf ((_qFramework.NS_WAIST_PARTIAL == iNakedLevel) || \
           (_qFramework.NS_CHEST_PARTIAL == iNakedLevel))
      ; One slot is naked and the other is reduced.
      szTitle += " (50% + " + (iVulnerabilityNakedReduce / 2) + "%)"
   ElseIf ((_qFramework.NS_WAIST_COVERED == iNakedLevel) || \
           (_qFramework.NS_WAIST_COVERED == iNakedLevel))
      ; One slot is naked.
      szTitle += " (50%)"
   ElseIf (_qFramework.NS_BOTH_PARTIAL == iNakedLevel)
      ; Both slots are worn but reduced.
      szTitle += "(" + iVulnerabilityNakedReduce + "%)"
   EndIf
   AddSliderOptionST("ST_VUL_NUDE",       szTitle, iVulnerabilityNude,       a_flags=iFlags)

   ; For each header find out if it is active and add a marker to indicate if it is so.
   szTitle = "Collar"
   If (_qFramework.IsPlayerCollared())
      szTitle += " *"
   EndIf
   AddSliderOptionST("ST_VUL_COLLAR",     szTitle, iVulnerabilityCollar,     a_flags=iFlags)

   ; For each header find out if it is active and add a marker to indicate if it is so.
   szTitle = "Arm Binder"
   If (_qFramework.IsPlayerArmLocked())
      szTitle += " *"
   EndIf
   AddSliderOptionST("ST_VUL_BINDER",     szTitle, iVulnerabilityBinder,     a_flags=iFlags)

   ; For each header find out if it is active and add a marker to indicate if it is so.
   szTitle = "Gag"
   If (_qFramework.IsPlayerGagged())
      szTitle += " *"
   EndIf
   AddSliderOptionST("ST_VUL_GAGGED",     szTitle, iVulnerabilityGagged,     a_flags=iFlags)

   ; For each header find out if it is active and add a marker to indicate if it is so.
   szTitle = "Other Restraints"
   Int iOtherRestraints = _qFramework.GetNumOtherRestraints()
   If (iOtherRestraints)
      szTitle += " (" + (iOtherRestraints * iVulnerabilityRestraints) + ")"
   EndIf
   AddSliderOptionST("ST_VUL_RESTRAINTS", szTitle, iVulnerabilityRestraints, a_flags=iFlags)

   ; For each header find out if it is active and add a marker to indicate if it is so.
   szTitle = "Leashed"
   If (_qFramework.GetLeashTarget())
      szTitle += " *"
   EndIf
   AddSliderOptionST("ST_VUL_LEASHED",    szTitle, iVulnerabilityLeashed,    a_flags=iFlags)

   ; For each header find out if it is active and add a marker to indicate if it is so.
   szTitle = "BDSM Furniture"
   If (_qFramework.GetBdsmFurniture())
      szTitle += " *"
   EndIf
   AddSliderOptionST("ST_VUL_FURNITURE",  szTitle, iVulnerabilityFurniture,  a_flags=iFlags)

   ; For each header find out if it is active and add a marker to indicate if it is so.
   szTitle = "Night Time"
   If (_qDfwUtil.IsNight())
      szTitle += " *"
   EndIf
   AddSliderOptionST("ST_VUL_NIGHT",      szTitle, iVulnerabilityNight,      a_flags=iFlags)

   ; Start on the second column.
   SetCursorPosition(1)

   AddSliderOptionST("ST_VUL_REDUCE", "Naked Armour Reduces Vulnerability", iVulnerabilityNakedReduce, a_flags=iFlags)
EndFunction

Function DisplayNpcDispositionPage(Bool bSecure)
   Int iFlags = OPTION_FLAG_NONE
   If (bSecure)
      iFlags = OPTION_FLAG_DISABLED
   EndIf

   AddHeaderOption("Willingness To Help")
   AddSliderOptionST("ST_DISP_WILL_GUARDS",    "Guard Adjustments",          iDispWillingGuards,    a_flags=iFlags)
   AddSliderOptionST("ST_DISP_WILL_MERCHANTS", "Merchant Adjustments",       iDispWillingMerchants, a_flags=iFlags)
   AddSliderOptionST("ST_DISP_WILL_BDSM",      "Slaver & slave Adjustments", iDispWillingBdsm,      a_flags=iFlags)

   ; Start on the second column.
   ;SetCursorPosition(1)
EndFunction

Function DisplayModFeaturesPage(Bool bSecure)
   Int iFlags = OPTION_FLAG_NONE
   If (bSecure)
      iFlags = OPTION_FLAG_DISABLED
   EndIf

   AddHeaderOption("Leash Configuration")
   AddTextOptionST("ST_MOD_LEASH_STYLE",        "Leash Style", LeashStyleToString(iModLeashStyle))
   AddToggleOptionST("ST_MOD_LEASH_VISIBLE",    "Leash Visible", bModLeashVisible)
   AddToggleOptionST("ST_MOD_LEASH_INTERRUPT",  "Leash Interrupt", bModLeashInterrupt)
   AddSliderOptionST("ST_MOD_LEASH_COMBAT",     "Combat Chance", iModLeashCombatChance,  a_flags=iFlags)
   AddSliderOptionST("ST_MOD_LEASH_DAMAGE",     "Damage When Jerked", iModLeashDamage,  a_flags=iFlags)
   AddSliderOptionST("ST_MOD_LEASH_LENGTH",     "Minimum Leash Length", iModLeashMinLength,  a_flags=iFlags)

   AddEmptyOption()
   AddHeaderOption("Miscellaneous")
   AddTextOptionST("ST_MOD_ENABLE_DIALOGUE",    "Greeting Dialogue Style",   DialogueStyleToString(iModDialogueTargetStyle))
   AddSliderOptionST("ST_MOD_DIALOGUE_RETRIES", "Dialogue Target Retries",   iModDialogueTargetRetries)
   AddToggleOptionST("ST_MOD_FADE_IN_USE_DOOR", "Move NPC Nearby Use Doors", bModFadeInUseDoor)

   AddEmptyOption()
   AddHeaderOption("Pose Management")
   AddKeyMapOptionST("ST_MOD_POSE_TOGGLE_KEY",     "Pose Toggle Key",       iModTogglePoseKey)
   AddMenuOptionST("ST_MOD_POSE_TOGGLE",           "Toggle Pose",           PoseToString(iModTogglePose))
   AddKeyMapOptionST("ST_MOD_POSE_CYCLE_KEY",      "Pose Cycle Key",        iModCyclePoseKey)
   AddToggleOptionST("ST_MOD_POSE_CRAWL_ACTIVATE", "Crawl Blocks Activate", bModCrawlBlockActivate)

   AddEmptyOption()
   AddHeaderOption("The Collector")
   AddTextOptionST("ST_COL_SPECIAL_COST", "Access Quest Items for ", iModCollectorSpecialCost + " gold")

   ; Start on the second column.
   SetCursorPosition(1)

   AddHeaderOption("Call For Help")
   AddKeyMapOptionST("ST_MOD_CALL_HELP",      "Help Key",              iModHelpKey)
   AddKeyMapOptionST("ST_MOD_CALL_ATTENTION", "Attention Key",         iModAttentionKey)
   AddSliderOptionST("ST_MOD_CALL_TIMEOUT",   "Call for Help Timeout", iModCallTimeout, a_flags=iFlags)

   ; I'm not sure this is the right mod to block armour but no other mods have the concept of
   ; "chest" and "waist" armour so let's keep it here for now.
   AddEmptyOption()
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
   AddMenuOptionST("ST_MOD_ADD_EXC_HOBBLE",  "Add Exception to Hobble Block", "Select", a_flags=iFlags)
   AddMenuOptionST("ST_MOD_REM_EXC_HOBBLE",  "Remove/View Hobble Exceptions", "Open")
EndFunction

Function DisplayGameControlPage(Bool bSecure)
   Int iFlags = OPTION_FLAG_NONE
   If (bSecure)
      iFlags = OPTION_FLAG_DISABLED
   EndIf

   AddHeaderOption("MCM Security")
   AddSliderOptionST("ST_CON_SECURE",         "Security Level",        iSettingsSecurity, a_flags=iFlags)
   AddToggleOptionST("ST_CON_HARDCORE",       "...Hardcore (Caution)", _bSecureHardcore, a_flags=iFlags)

   AddEmptyOption()
   AddHeaderOption("Save Game Control")
   AddTextOptionST("ST_CON_SAVE_TYPE",        "Save Game Control (Caution)", SaveGameStyleToString(iModSaveGameStyle), a_flags=iFlags)
   Int iTempFlags = iFlags
   If (0 == iModSaveGameStyle)
      iTempFlags = OPTION_FLAG_DISABLED
   EndIf
   AddToggleOptionST("ST_CON_SAVE_CONFIRM",   "...Are you Sure?",  bSaveGameConfirm, a_flags=iTempFlags)
   iTempFlags = iFlags
   If (!bSaveGameConfirm || (2 != iModSaveGameStyle))
      iTempFlags = OPTION_FLAG_DISABLED
   EndIf
   AddToggleOptionST("ST_CON_NATIVE_SAVES",   "Overwrite Normal Quick/Auto Games", bConNativeSaves, a_flags=iFlags)
   AddKeyMapOptionST("ST_CON_SAVE_KEY",       "Quick Save Key",                    iModSaveKey, a_flags=iTempFlags)
   AddSliderOptionST("ST_CON_SAVE_MIN_TIME",  "Minimum Save Time",                 fModSaveMinTime, "{0}min", a_flags=iTempFlags)
   AddSliderOptionST("ST_CON_CONSOLE_ACCESS", "Max Vulnerability for Console",     iConConsoleVulnerability, a_flags=iTempFlags)

   ; Start on the second column.
   SetCursorPosition(1)

   AddHeaderOption("Redress Timeouts")
   AddSliderOptionST("ST_CON_RAPE_REDRESS",   "Post Rape Redress Timeout", iModRapeRedressTimeout,  a_flags=iFlags)
   AddSliderOptionST("ST_CON_NAKED_REDRESS",  "Naked Redress Timeout",     iModNakedRedressTimeout, a_flags=iFlags)

   AddEmptyOption()
   AddHeaderOption("Miscellaneous")
   AddToggleOptionST("ST_CON_LOAD_BLOCK",     "Block Controls on Game Load", bModBlockOnGameLoad, a_flags=iFlags)
EndFunction

Function DisplayModCompatibilityPage(Bool bSecure)
   Int iFlags = OPTION_FLAG_NONE
   If (bSecure)
      iFlags = OPTION_FLAG_DISABLED
   EndIf

   AddHeaderOption("Devices")
   AddToggleOptionST("ST_COMP_DD_FIX", "Detect Device Unequips", bSettingsDetectUnequip)

   AddEmptyOption()
   AddHeaderOption("Zaz Multi-Furniture Animations")
   AddMenuOptionST("ST_MOD_MULTI_POLE_ANIM", "Mult-Pole", GetMultiAnimationName(iModMultiPoleAnimation), a_flags=iFlags)
   AddMenuOptionST("ST_MOD_MULTI_WALL_ANIM", "Mult-Wall", GetMultiAnimationName(iModMultiWallAnimation), a_flags=iFlags)

   AddEmptyOption()
   AddHeaderOption("SexLab Aroused Base")
   AddSliderOptionST("ST_COMP_SLA_THRESHOLD",    "Initial Threshold", iModSlaThreshold, a_flags=iFlags)
   AddSliderOptionST("ST_COMP_SLA_MIN",          "Minimum Adjusted Arousal", iModSlaAdjustedMin, a_flags=iFlags)
   AddSliderOptionST("ST_COMP_SLA_MAX",          "Maximum Adjusted Arousal", iModSlaAdjustedMax, a_flags=iFlags)

   AddEmptyOption()
   AddHeaderOption("Special Cells")
   AddTextOptionST("ST_COMP_RELOAD_CELLS",    "Reload Special Cells",           "Reload Now")
   AddToggleOptionST("ST_COMP_EASTERN_HOUSE", "Treat Easter House as Windhelm", bEasternHouseIsWindhelm)
EndFunction

Function DisplayStatusPage(Bool bSecure)
   Int iFlags = OPTION_FLAG_NONE
   If (bSecure)
      iFlags = OPTION_FLAG_DISABLED
   EndIf

   ; Report the name of the player's current cell.
   Cell oCurrCell = _aPlayer.GetParentCell()
   String szCellName = oCurrCell
   szCellName = Substring(szCellName, 7, GetLength(szCellName) - 20)
   If ("Wilderness" == szCellName)
      szCellName += " 0x" + _qDfwUtil.ConvertHexToString(oCurrCell.GetFormID(), 8)
   EndIf
   If (_aPlayer.IsInInterior())
      szCellName += " (I)"
   EndIf
   AddLabel("Current Cell: " + szCellName)

   ; Report the name of the player's current DFW Location.
   Location oCurrLocation = _qFramework.GetCurrentLocation()
   String szLocationName = "None"
   If (oCurrLocation)
      szLocationName = oCurrLocation.GetName()
   EndIf
   AddLabel("Current Location: " + szLocationName)

   ; Report the name of the player's current region and nearest region.
   Location oCurrRegion = _qFramework.GetCurrentRegion()
   String szRegion = "Wilderness"
   If (oCurrRegion)
      szRegion = oCurrRegion.GetName()
   EndIf
   AddLabel("Current Region: " + szRegion)
   If (!oCurrRegion)
      String szNearest = "Unknown"
      Location oNearestRegion = _qFramework.GetNearestRegion()
      If (oNearestRegion)
         szNearest = oNearestRegion.GetName()
      EndIf
      AddLabel("Nearest Region: " + szNearest)
   EndIf

   AddToggleOptionST("ST_INFO_FOR_PLAYER",  "Use Player for Info",       _bInfoForPlayer)
   AddToggleOptionST("ST_INFO_FACTIONS",    "Show Player Factions",      False)
   AddToggleOptionST("ST_INFO_REACTIONS",   "Show Faction Reactions",    False)
   AddToggleOptionST("ST_INFO_NEARBY",      "Show Nearby Actors",        False)
   AddToggleOptionST("ST_INFO_KNOWN",       "Show Known Actors",         False)
   AddToggleOptionST("ST_INFO_DIALOGUE",    "Show Last Dialogue Target", False)

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
   szAllowed = "Not Assisted"
   If (_qFramework.IsAllowed(_qFramework.AP_DRESSING_ASSISTED))
      szAllowed = "Allowed"
   EndIf
   AddTextOption("Dressing Assisted?", szAllowed, a_flags=OPTION_FLAG_DISABLED)

   ; Start on the second column.
   SetCursorPosition(1)

   AddHeaderOption("Vulnerability")
   String szNakedLevel = "0x" + _qDfwUtil.ConvertHexToString(_qFramework.GetNakedLevel(), 8)
   AddTextOption("Vulnerability", _qFramework.GetVulnerability(), a_flags=OPTION_FLAG_DISABLED)
   AddTextOptionST("ST_INFO_NAKED", "Naked", szNakedLevel,        a_flags=OPTION_FLAG_DISABLED)
   AddTextOption("Weapon Level",  _qFramework.GetWeaponLevel(),   a_flags=OPTION_FLAG_DISABLED)
   AddEmptyOption()

   AddHeaderOption("Active Scene")
   String szValue = _qFramework.GetCurrentScene()
   If (!szValue)
      szValue = "None"
   EndIf
   AddLabel("Current Scene: " + szValue)

   AddEmptyOption()
   AddHeaderOption("Furniture")
   ObjectReference oCurrFurniture = _qZbfPlayerSlot.GetFurniture()
   szValue = "None"
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
   iSlotsChecked += (CS_RESERVED1 + CS_RESERVED2 + CS_RESERVED3)

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
   AddMenuOptionST("ST_STA_KEYWORD", "Keyword Browsing", "Select Item")
EndFunction

Function DisplayDebugPage(Bool bSecure)
   Int iFlags = OPTION_FLAG_NONE
   If (bSecure)
      iFlags = OPTION_FLAG_DISABLED
   EndIf

   AddSliderOptionST("ST_DBG_LEVEL",       "Log Level (File)",            iLogLevel)
   AddSliderOptionST("ST_DBG_GENERAL",     "Screen - General",            iLogLevelScreenGeneral)
   AddSliderOptionST("ST_DBG_DEBUG",       "Screen - Debug",              iLogLevelScreenDebug)
   AddSliderOptionST("ST_DBG_STATUS",      "Screen - Player Status",      iLogLevelScreenStatus)
   AddSliderOptionST("ST_DBG_MASTER",      "Screen - Masters",            iLogLevelScreenMaster)
   AddSliderOptionST("ST_DBG_NEARBY",      "Screen - Nearby NPCs",        iLogLevelScreenNearby)
   AddSliderOptionST("ST_DBG_LEASH",       "Screen - Leash",              iLogLevelScreenLeash)
   AddSliderOptionST("ST_DBG_EQUIP",       "Screen - Equipping/Blocking", iLogLevelScreenEquip)
   AddSliderOptionST("ST_DBG_AROUSAL",     "Screen - NPC Arousal",        iLogLevelScreenArousal)
   AddSliderOptionST("ST_DBG_INTERACTION", "Screen - NPC Interaction",    iLogLevelScreenInteraction)
   AddSliderOptionST("ST_DBG_LOCATION",    "Screen - Location Changes",   iLogLevelScreenLocation)
   AddSliderOptionST("ST_DBG_REDRESS",     "Screen - Redress Timeouts",   iLogLevelScreenRedress)
   AddSliderOptionST("ST_DBG_SAVE",        "Screen - DFW Save Games",     iLogLevelScreenSave)

   ; Start on the second column.
   SetCursorPosition(1)

   AddLabel("Current Game Time: " + Utility.GetCurrentGameTime())
   AddLabel("Current Real Time: " + Utility.GetCurrentRealTime())

   Int iShutdownFlags = OPTION_FLAG_NONE
   If (bShutdownSecure)
      iShutdownFlags = iFlags
   EndIf
   AddEmptyOption()
   AddToggleOptionST("ST_DBG_SHUTDOWN",     "Shutdown Mod",            bShutdownMod, a_flags=iShutdownFlags)
   AddToggleOptionST("ST_DBG_SHUTDOWN_SEC", "...Make Shutdown Secure", bShutdownSecure, a_flags=iShutdownFlags)

   AddEmptyOption()
   AddTextOptionST("ST_DBG_YANK_LEASH", "Yank Leash",      "Do It Now")
   AddMenuOptionST("ST_DBG_TELEPORT",   "Teleport Player", "Destination..")

   String szTarget = "Player"
   If (!_bInfoForPlayer)
      Actor aNearby = _qFramework.GetNearestActor(0)
      szTarget = aNearby.GetDisplayName()
   EndIf
   AddMenuOptionST("ST_DBG_REM_FACTION",    "Remove From Faction",   szTarget)
   AddTextOptionST("ST_DBG_MCM_UPGRADE",    "Force MCM Upgrade",     "Upgrade Now")
   AddTextOptionST("ST_DBG_MOD_EVENTS",     "Fix Mod Events",        "Fix Now")
   AddTextOptionST("ST_DBG_CLEAR_HOVER",    "Clear Hovering Actors", "Clear Now")
   AddTextOptionST("ST_DBG_CLEAR_MOVEMENT", "Clear All Movement",    "Clear Now")
   AddTextOptionST("ST_SAFEWORD_FURNITURE", "Safeword: Furniture",   "Use Safeword", a_flags=iFlags)
   AddTextOptionST("ST_SAFEWORD_LEASH",     "Safeword: Leash",       "Use Safeword", a_flags=iFlags)
EndFunction


;***********************************************************************************************
;***                                  STATES: FRAMEWORK                                      ***
;***********************************************************************************************
State ST_FWK_POLL_TIME
   Event OnSliderOpenST()
      SetSliderDialogStartValue(fSettingsPollTime)
      SetSliderDialogDefaultValue(1.0)
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
      fSettingsPollTime = 1.0
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
      SetSliderDialogDefaultValue(5)
      SetSliderDialogRange(0, 10)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iSettingsPollNearby = (fValue As Int)
      SetSliderOptionValueST(iSettingsPollNearby)
   EndEvent

   Event OnDefaultST()
      iSettingsPollNearby = 5
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
      SetSliderDialogDefaultValue(65)
      SetSliderDialogRange(10, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iSettingsNearbyDistance = (fValue As Int)
      _qFramework.UpdatePollingDistance(iSettingsNearbyDistance)
      SetSliderOptionValueST(iSettingsNearbyDistance)
   EndEvent

   Event OnDefaultST()
      iSettingsNearbyDistance = 65
      SetSliderOptionValueST(iSettingsNearbyDistance)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Updates the range of the detect nearby actors feature.\n" +\
                  "Warning: Although untested, increasing this may slow down your game noticeably.")
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
      SetSliderDialogDefaultValue(15)
      SetSliderDialogRange(0, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iVulnerabilityNude = (fValue As Int)
      SetSliderOptionValueST(iVulnerabilityNude)
   EndEvent

   Event OnDefaultST()
      iVulnerabilityNude = 15
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
      SetSliderDialogDefaultValue(25)
      SetSliderDialogRange(0, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iVulnerabilityCollar = (fValue As Int)
      SetSliderOptionValueST(iVulnerabilityCollar)
   EndEvent

   Event OnDefaultST()
      iVulnerabilityCollar = 25
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
      SetSliderDialogDefaultValue(20)
      SetSliderDialogRange(0, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iVulnerabilityBinder = (fValue As Int)
      SetSliderOptionValueST(iVulnerabilityBinder)
   EndEvent

   Event OnDefaultST()
      iVulnerabilityBinder = 20
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
      SetSliderDialogDefaultValue(20)
      SetSliderDialogRange(0, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iVulnerabilityGagged = (fValue As Int)
      SetSliderOptionValueST(iVulnerabilityGagged)
   EndEvent

   Event OnDefaultST()
      iVulnerabilityGagged = 20
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
      SetSliderDialogDefaultValue(10)
      SetSliderDialogRange(0, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iVulnerabilityRestraints = (fValue As Int)
      SetSliderOptionValueST(iVulnerabilityRestraints)
   EndEvent

   Event OnDefaultST()
      iVulnerabilityRestraints = 10
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
      SetSliderDialogDefaultValue(10)
      SetSliderDialogRange(0, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iVulnerabilityLeashed = (fValue As Int)
      SetSliderOptionValueST(iVulnerabilityLeashed)
   EndEvent

   Event OnDefaultST()
      iVulnerabilityLeashed = 10
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
      SetSliderDialogDefaultValue(10)
      SetSliderDialogRange(0, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iVulnerabilityFurniture = (fValue As Int)
      SetSliderOptionValueST(iVulnerabilityFurniture)
   EndEvent

   Event OnDefaultST()
      iVulnerabilityFurniture = 10
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
      SetSliderDialogDefaultValue(5)
      SetSliderDialogRange(0, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iVulnerabilityNight = (fValue As Int)
      SetSliderOptionValueST(iVulnerabilityNight)
   EndEvent

   Event OnDefaultST()
      iVulnerabilityNight = 5
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
      SetSliderDialogDefaultValue(50)
      SetSliderDialogRange(0, 300)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iVulnerabilityNakedReduce = (fValue As Int)
      SetSliderOptionValueST(iVulnerabilityNakedReduce)
   EndEvent

   Event OnDefaultST()
      iVulnerabilityNakedReduce = 50
      SetSliderOptionValueST(iVulnerabilityNakedReduce)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Some armour/clothes can be considred \"Naked\" by the SexLab Aroused mod.\n" +\
                  "When worn this armour makes the player vulnerable as if they were naked but not by as much.\n" +\
                  "This sets the % of naked vulnerability to use.  At 100% this armour is the same as being naked.")
   EndEvent
EndState


;***********************************************************************************************
;***                                 STATES: NPC DISPOSITION                                 ***
;***********************************************************************************************
State ST_DISP_WILL_GUARDS
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iDispWillingGuards)
      SetSliderDialogDefaultValue(10)
      SetSliderDialogRange(-100, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iDispWillingGuards = (fValue As Int)
      SetSliderOptionValueST(iDispWillingGuards)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("NpcDisposition")
   EndEvent

   Event OnDefaultST()
      iDispWillingGuards = 10
      SetSliderOptionValueST(iDispWillingGuards)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("NpcDisposition")
   EndEvent

   Event OnHighlightST()
      SetInfoText("Guards tend to have a higher (or possibly lower) willingness to help value.\n" +\
                  "Use this slider to configure how much this is affected.")
   EndEvent
EndState

State ST_DISP_WILL_MERCHANTS
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iDispWillingMerchants)
      SetSliderDialogDefaultValue(3)
      SetSliderDialogRange(-100, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iDispWillingMerchants = (fValue As Int)
      SetSliderOptionValueST(iDispWillingMerchants)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("NpcDisposition")
   EndEvent

   Event OnDefaultST()
      iDispWillingMerchants = 3
      SetSliderOptionValueST(iDispWillingMerchants)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("NpcDisposition")
   EndEvent

   Event OnHighlightST()
      SetInfoText("Merchants tend to have a higher (or possibly lower) willingness to help value.\n" +\
                  "Use this slider to configure how much this is affected.")
   EndEvent
EndState

State ST_DISP_WILL_BDSM
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iDispWillingBdsm)
      SetSliderDialogDefaultValue(-25)
      SetSliderDialogRange(-100, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iDispWillingBdsm = (fValue As Int)
      SetSliderOptionValueST(iDispWillingBdsm)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("NpcDisposition")
   EndEvent

   Event OnDefaultST()
      iDispWillingBdsm = -25
      SetSliderOptionValueST(iDispWillingBdsm)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("NpcDisposition")
   EndEvent

   Event OnHighlightST()
      SetInfoText("Slavers tend to have a lower (or possibly higher) willingness to help value.\n" +\
                  "This value also includes slaves who are prone to following the desires of their Masters.\n" +\
                  "Use this slider to configure how much this is affected.")
   EndEvent
EndState


;***********************************************************************************************
;***                                  STATES: MOD FEATURES                                   ***
;***********************************************************************************************
State ST_MOD_LEASH_STYLE
   Event OnSelectST()
      iModLeashStyle += 1
      If (_qFramework.LS_TELEPORT < iModLeashStyle)
         iModLeashStyle = 0
      EndIf
      SetTextOptionValueST(LeashStyleToString(iModLeashStyle))
   EndEvent

   Event OnDefaultST()
      iModLeashStyle = _qFramework.LS_AUTO
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
      bModLeashVisible = True
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
      bModLeashInterrupt = True
      SetToggleOptionValueST(bModLeashInterrupt)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Toggles whether the leash interrupts scenes (in particular sex scenes) or not.")
   EndEvent
EndState

State ST_MOD_LEASH_COMBAT
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iModLeashCombatChance)
      SetSliderDialogDefaultValue(20)
      SetSliderDialogRange(0, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iModLeashCombatChance = (fValue As Int)
      SetSliderOptionValueST(iModLeashCombatChance)
   EndEvent

   Event OnDefaultST()
      iModLeashCombatChance = 20
      SetSliderOptionValueST(iModLeashCombatChance)
   EndEvent

   Event OnHighlightST()
      SetInfoText("If the player is in combat with the leash holder this is the chance the leash holder\n" +\
                  "will use the leash to throw the player off balance.")
   EndEvent
EndState

State ST_MOD_LEASH_DAMAGE
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iModLeashDamage)
      SetSliderDialogDefaultValue(12)
      SetSliderDialogRange(0, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iModLeashDamage = (fValue As Int)
      SetSliderOptionValueST(iModLeashDamage)
   EndEvent

   Event OnDefaultST()
      iModLeashDamage = 12
      SetSliderOptionValueST(iModLeashDamage)
   EndEvent

   Event OnHighlightST()
      SetInfoText("The percent of the player's current health as damage to the player when she is dragged via her leash.")
   EndEvent
EndState

State ST_MOD_LEASH_LENGTH
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iModLeashMinLength)
      SetSliderDialogDefaultValue(550)
      SetSliderDialogRange(0, 1000)
      SetSliderDialogInterval(10)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iModLeashMinLength = (fValue As Int)
      SetSliderOptionValueST(iModLeashMinLength)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("ModFeatures")
   EndEvent

   Event OnDefaultST()
      iModLeashMinLength = 550
      SetSliderOptionValueST(iModLeashMinLength)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("ModFeatures")
   EndEvent

   Event OnHighlightST()
      SetInfoText("The minimum length the leash can be.\n" +\
                  "The leash can be set shorter than this but will be treated as this length.\n" +\
                  "Setting this to zero turns off this feature and allows for any length.")
   EndEvent
EndState

State ST_MOD_ENABLE_DIALOGUE
   Event OnSelectST()
      iModDialogueTargetStyle += 1
      If (_qFramework.DS_MANUAL < iModDialogueTargetStyle)
         iModDialogueTargetStyle = 0
      EndIf
      SetTextOptionValueST(DialogueStyleToString(iModDialogueTargetStyle))

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("ModFeatures")
   EndEvent

   Event OnDefaultST()
      iModDialogueTargetStyle = _qFramework.DS_MANUAL
      SetTextOptionValueST(DialogueStyleToString(iModDialogueTargetStyle))

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("ModFeatures")
   EndEvent

   Event OnHighlightST()
      SetInfoText("Greetings dialogues gather a significant amout of information and make it available to all mod dialgoues.\n" +\
                  "Automatic: Each NPC will greet the player when he first starts talking to her.\n" +\
                  "Manual: The player must select \"Greetings\" before this info (and associated dialogues) become available.")
   EndEvent
EndState

State ST_MOD_DIALOGUE_RETRIES
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iModDialogueTargetRetries)
      SetSliderDialogDefaultValue(0)
      SetSliderDialogRange(0, 10)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iModDialogueTargetRetries = (fValue As Int)
      SetSliderOptionValueST(iModDialogueTargetRetries)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("ModFeatures")
   EndEvent

   Event OnDefaultST()
      iModDialogueTargetRetries = 0
      SetSliderOptionValueST(iModDialogueTargetRetries)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("ModFeatures")
   EndEvent

   Event OnHighlightST()
      SetInfoText("Dialogue targets are less effective if the NPC is not in the nearby actor list.\n" +\
                  "When speaking to an NPC not yet in list you may see the Greetings dialogue a couple of times retrying.\n" +\
                  "0: A single attempt only.  No retries.  Recommended: 2.")
   EndEvent
EndState

State ST_MOD_FADE_IN_USE_DOOR
   Event OnSelectST()
      bModFadeInUseDoor = !bModFadeInUseDoor
      SetToggleOptionValueST(bModFadeInUseDoor)
   EndEvent

   Event OnDefaultST()
      bModFadeInUseDoor = True
      SetToggleOptionValueST(bModFadeInUseDoor)
   EndEvent

   Event OnHighlightST()
      SetInfoText("This mod has a feature to move an NPC near a player without the NPC being near enough to be seen.\n" +\
                  "This allows NPCs to approach the player as if they are walking over from off screen somewhere.\n" +\
                  "When enabled and the player is indoors the NPC will \"fade in\" via the last door used by the player.")
   EndEvent
EndState

State ST_MOD_POSE_TOGGLE_KEY
   Event OnKeyMapChangeST(Int iKeyCode, String sConflictControl, String sConflictName)
      If (iModTogglePoseKey != iKeyCode)
         Int iOldKey = iModTogglePoseKey
         iModTogglePoseKey = 0x00
         RegisterNewKey(iOldKey, iKeyCode)
         iModTogglePoseKey = iKeyCode
         SetKeyMapOptionValueST(iModTogglePoseKey)
      EndIf
   EndEvent

   Event OnDefaultST()
      Int iOldKey = iModTogglePoseKey
      iModTogglePoseKey = 0x00
      RegisterNewKey(iOldKey, iModTogglePoseKey)
      SetKeyMapOptionValueST(iModTogglePoseKey)
   EndEvent

   Event OnHighlightST()
      SetInfoText("The pose feature allows the user to control the player's poses.  Pressing the toggle key\n" +\
                  "alternates between the player's default idle pose and the configured Toggle Pose.\n" +\
                  "Recommended Key: \"g\"  Set to default to turn off.")
   EndEvent
EndState

State ST_MOD_POSE_TOGGLE
   Event OnMenuOpenST()
      ; Create a new array to hold all of the options.
      Int iMaxPoses = 4
      String[] aszOptions = New String[4]
      Int iIndex
      While (iMaxPoses > iIndex)
         aszOptions[iIndex] = PoseToString(iIndex)
         iIndex += 1
      EndWhile

      SetMenuDialogStartIndex(iModTogglePose)
      SetMenuDialogDefaultIndex(1)
      SetMenuDialogOptions(aszOptions)
   EndEvent

   Event OnMenuAcceptST(Int iChosenIndex)
      iModTogglePose = iChosenIndex
      SetMenuOptionValueST(PoseToString(iModTogglePose))
   EndEvent

   Event OnDefaultST()
      iModTogglePose = 1
   EndEvent

   Event OnHighlightST()
      SetInfoText("Using the Pose Toggle Key will toggle this pose on and off.")
   EndEvent
EndState

State ST_MOD_POSE_CYCLE_KEY
   Event OnKeyMapChangeST(Int iKeyCode, String sConflictControl, String sConflictName)
      If (iModCyclePoseKey != iKeyCode)
         Int iOldKey = iModCyclePoseKey
         iModCyclePoseKey = 0x00
         RegisterNewKey(iOldKey, iKeyCode)
         iModCyclePoseKey = iKeyCode
         SetKeyMapOptionValueST(iModCyclePoseKey)
      EndIf
   EndEvent

   Event OnDefaultST()
      Int iOldKey = iModCyclePoseKey
      iModCyclePoseKey = 0x00
      RegisterNewKey(iOldKey, iModCyclePoseKey)
      SetKeyMapOptionValueST(iModCyclePoseKey)
   EndEvent

   Event OnHighlightST()
      SetInfoText("The pose feature allows the user to control the player's poses.  Pressing this key cycles through\n" +\
                  "all available poses, currently the user's default pose and kneeling.\n" +\
                  "Recommended Key: \"b\"  Set to default to turn off.")
   EndEvent
EndState

State ST_MOD_POSE_CRAWL_ACTIVATE
   Event OnSelectST()
      bModCrawlBlockActivate = !bModCrawlBlockActivate
      SetToggleOptionValueST(bModCrawlBlockActivate)

      ; Changing this setting requires the pose flags list to be modified in the main script.
      SendSettingChangedEvent("ModCrawlActivate")
   EndEvent

   Event OnDefaultST()
      If (!bModCrawlBlockActivate)
         bModCrawlBlockActivate = True
         SetToggleOptionValueST(bModCrawlBlockActivate)

         ; Changing this setting requires the pose flags list to be modified in the main script.
         SendSettingChangedEvent("ModCrawlActivate")
      EndIf
   EndEvent

   Event OnHighlightST()
      SetInfoText("The idea is when you are crawling around on a leash people aren't likely to treat you with respect or\n" +\
                  "engage in meaningful conversation with you.  Blocking activation is a way to simulate this, preventing\n" +\
                  "you from engaging in dialogue with people.  If you are able you can activate things by standing up first.")
   EndEvent
EndState


State ST_COL_SPECIAL_COST
   Event OnSelectST()
      If (0 == iModCollectorSpecialCost)
         iModCollectorSpecialCost = 1000
      ElseIf (1000 == iModCollectorSpecialCost)
         iModCollectorSpecialCost = 2500
      ElseIf (2500 == iModCollectorSpecialCost)
         iModCollectorSpecialCost = 10000
      ElseIf (10000 == iModCollectorSpecialCost)
         iModCollectorSpecialCost = 25000
      ElseIf (25000 == iModCollectorSpecialCost)
         iModCollectorSpecialCost = 50000
      Else
         iModCollectorSpecialCost = 0
      EndIf
      SetTextOptionValueST(iModCollectorSpecialCost + " gold")

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Collector")
   EndEvent

   Event OnDefaultST()
      iModCollectorSpecialCost = 10000
      SetTextOptionValueST(iModCollectorSpecialCost + " gold")

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Collector")
   EndEvent

   Event OnHighlightST()
      SetInfoText("The Dragonborn Collector lives in a cave near Froki's cabin and collects all things Dragonborn.  If you loose items\n" +\
                  "visit him and he may sell them back to you but be prepared.  He does want to collect all things Dragonborn after all.\n" +\
                  "Quest Items cannot be sold so they are kept in a separate chest.  This is the cost to access that chest.\n" +\
                  "This change will only take effect when the chest is empty.")
   EndEvent
EndState

State ST_MOD_CALL_HELP
   Event OnKeyMapChangeST(Int iKeyCode, String sConflictControl, String sConflictName)
      If (iModHelpKey != iKeyCode)
         Int iOldKey = iModHelpKey
         iModHelpKey = 0x00
         RegisterNewKey(iOldKey, iKeyCode)
         iModHelpKey = iKeyCode
         SetKeyMapOptionValueST(iModHelpKey)
      EndIf
   EndEvent

   Event OnDefaultST()
      Int iOldKey = iModHelpKey
      iModHelpKey = 0x00
      RegisterNewKey(iOldKey, iModHelpKey)
      SetKeyMapOptionValueST(iModHelpKey)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Calls out for help.  Use this if you really want those around you to help.\n" +\
                  "May not always get people's attention, especially if you are gagged.\n" +\
                  "Recommended Key: \",\"  Set to default to turn off.")
   EndEvent
EndState

State ST_MOD_CALL_ATTENTION
   Event OnKeyMapChangeST(Int iKeyCode, String sConflictControl, String sConflictName)
      If (iModAttentionKey != iKeyCode)
         Int iOldKey = iModAttentionKey
         iModAttentionKey = 0x00
         RegisterNewKey(iOldKey, iKeyCode)
         iModAttentionKey = iKeyCode
         SetKeyMapOptionValueST(iModAttentionKey)
      EndIf
   EndEvent

   Event OnDefaultST()
      Int iOldKey = iModAttentionKey
      iModAttentionKey = 0x00
      RegisterNewKey(iOldKey, iModAttentionKey)
      SetKeyMapOptionValueST(iModAttentionKey)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Calls out for attention.  Use this for a calmer, quieter interaction without alarming anyone.\n" +\
                  "May not always get people's attention, especially if you are gagged.\n" +\
                  "Recommended Key: \".\"  Set to default to turn off.")
   EndEvent
EndState

State ST_MOD_CALL_TIMEOUT
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iModCallTimeout)
      SetSliderDialogDefaultValue(30)
      SetSliderDialogRange(0, 300)
      SetSliderDialogInterval(5)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iModCallTimeout = (fValue As Int)
      SetSliderOptionValueST(iModCallTimeout)
   EndEvent

   Event OnDefaultST()
      iModCallTimeout = 30
      SetSliderOptionValueST(iModCallTimeout)
   EndEvent

   Event OnHighlightST()
      SetInfoText("A timeout to prevent the user from using the call for help feature too frequently.\n" +\
                  "Measured in real life seconds.  Half when calling for attention.")
   EndEvent
EndState

State ST_MOD_NIPPLE
   Event OnSelectST()
      bBlockNipple = !bBlockNipple
      SetToggleOptionValueST(bBlockNipple)
   EndEvent

   Event OnDefaultST()
      bBlockNipple = True
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
      bBlockVagina = True
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
      bBlockArmour = True
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
      bBlockHobble = True
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
      bBlockShoes = True
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
      bBlockArms = True
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
      bBlockLeash = True
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
;***                                  STATES: GAME CONTROL                                   ***
;***********************************************************************************************
State ST_CON_SECURE
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iSettingsSecurity)
      SetSliderDialogDefaultValue(5)
      SetSliderDialogRange(1, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iSettingsSecurity = (fValue As Int)
      SetSliderOptionValueST(iSettingsSecurity)
   EndEvent

   Event OnDefaultST()
      iSettingsSecurity = 5
      SetSliderOptionValueST(iSettingsSecurity)
   EndEvent

   Event OnHighlightST()
      SetInfoText("This is the maximum vulnerability the player can be at and still change the settings.\n" +\
                  "Recommend: " + iVulnerabilityNight + " so you can change settings at night.\n" +\
                  "Note: Hidden (or covered) restraints also lock the settings.  100 never locks the settings.")
   EndEvent
EndState

State ST_CON_HARDCORE
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

State ST_CON_SAVE_TYPE
   Event OnSelectST()
      iModSaveGameStyle += 1
      If (2 < iModSaveGameStyle)
         iModSaveGameStyle = 0
      EndIf
      SetTextOptionValueST(SaveGameStyleToString(iModSaveGameStyle))

      ; Reset the confirmation check box whenever the save game stlye changes.
      bSaveGameConfirm = False
      SetToggleOptionValueST(False, a_stateName="ST_CON_SAVE_CONFIRM")
      If (iModSaveGameStyle)
         SetOptionFlagsST(OPTION_FLAG_NONE, a_stateName="ST_CON_SAVE_CONFIRM")
      Else
         SetOptionFlagsST(OPTION_FLAG_DISABLED, a_stateName="ST_CON_SAVE_CONFIRM")
      EndIf

      ; Only enable the save game key for the full control style.
      If (2 == iModSaveGameStyle)
         SetOptionFlagsST(OPTION_FLAG_NONE, a_stateName="ST_CON_NATIVE_SAVES")
         SetOptionFlagsST(OPTION_FLAG_NONE, a_stateName="ST_CON_SAVE_KEY")
         SetOptionFlagsST(OPTION_FLAG_NONE, a_stateName="ST_CON_SAVE_MIN_TIME")
         SetOptionFlagsST(OPTION_FLAG_NONE, a_stateName="ST_CON_CONSOLE_ACCESS")
      Else
         SetOptionFlagsST(OPTION_FLAG_DISABLED, a_stateName="ST_CON_NATIVE_SAVES")
         SetOptionFlagsST(OPTION_FLAG_DISABLED, a_stateName="ST_CON_SAVE_KEY")
         SetOptionFlagsST(OPTION_FLAG_DISABLED, a_stateName="ST_CON_SAVE_MIN_TIME")
         SetOptionFlagsST(OPTION_FLAG_DISABLED, a_stateName="ST_CON_CONSOLE_ACCESS")
      EndIf

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("SaveControl")
   EndEvent

   Event OnDefaultST()
      iModSaveGameStyle = 0
      SetTextOptionValueST(SaveGameStyleToString(iModSaveGameStyle))

      ; Reset the confirmation check box whenever the save game stlye changes.
      bSaveGameConfirm = False
      SetToggleOptionValueST(False, a_stateName="ST_CON_SAVE_CONFIRM")
      SetOptionFlagsST(OPTION_FLAG_DISABLED, a_stateName="ST_CON_SAVE_CONFIRM")

      ; Only enable the save game key for the full control style.
      SetOptionFlagsST(OPTION_FLAG_DISABLED, a_stateName="ST_CON_NATIVE_SAVES")
      SetOptionFlagsST(OPTION_FLAG_DISABLED, a_stateName="ST_CON_SAVE_KEY")
      SetOptionFlagsST(OPTION_FLAG_DISABLED, a_stateName="ST_CON_SAVE_MIN_TIME")
      SetOptionFlagsST(OPTION_FLAG_DISABLED, a_stateName="ST_CON_CONSOLE_ACCESS")

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("SaveControl")
   EndEvent

   Event OnHighlightST()
      SetInfoText("Warning: This setting can overwrite your saved games!  Don't use unless you are sure it is what you want.\n" +\
                  "This feature makes it difficult to load games after you have been enslaved, forcing you to accept the enslavement.\n" +\
                  "Overwrite: Quick/Auto Saves are overwritten when enslaved.")
   EndEvent
EndState

State ST_CON_SAVE_CONFIRM
   Event OnSelectST()
      bSaveGameConfirm = !bSaveGameConfirm
      SetToggleOptionValueST(bSaveGameConfirm)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("SaveControl")
   EndEvent

   Event OnDefaultST()
      bSaveGameConfirm = False
      SetToggleOptionValueST(bSaveGameConfirm)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("SaveControl")
   EndEvent

   Event OnHighlightST()
      SetInfoText("The Save Game Control feature has the potential to be buggy and dangerous.\n" +\
                  "You must confirm you want to use the feature before it will be enabled.")
   EndEvent
EndState

State ST_CON_NATIVE_SAVES
   Event OnSelectST()
      bConNativeSaves = !bConNativeSaves
      SetToggleOptionValueST(bConNativeSaves)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("SaveControl")
   EndEvent

   Event OnDefaultST()
      bConNativeSaves = False
      SetToggleOptionValueST(bConNativeSaves)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("SaveControl")
   EndEvent

   Event OnHighlightST()
      SetInfoText("QuickSave and AutoSave games should use the same name as the games normal QuickSave and AutoSave1.\n" +\
                  "If disabled DFW saves will prefix the saved game names with Dfw to not interfere with the retular saves.")
   EndEvent
EndState

State ST_CON_SAVE_KEY
   Event OnKeyMapChangeST(Int iKeyCode, String sConflictControl, String sConflictName)
      If (iModSaveKey != iKeyCode)
         Int iOldKey = iModSaveKey
         iModSaveKey = 0x00
         RegisterNewKey(iOldKey, iKeyCode)
         iModSaveKey = iKeyCode
         SetKeyMapOptionValueST(iModSaveKey)
      EndIf
   EndEvent

   Event OnDefaultST()
      Int iOldKey = iModSaveKey
      iModSaveKey = 0x00
      RegisterNewKey(iOldKey, iModSaveKey)
      SetKeyMapOptionValueST(iModSaveKey)
   EndEvent

   Event OnHighlightST()
      SetInfoText("When using \"Full Control\" as the save game control method only games saved with this hotkey\n" +\
                  "or the DFW Auto Save can be loaded.")
   EndEvent
EndState

State ST_CON_SAVE_MIN_TIME
   Event OnSliderOpenST()
      SetSliderDialogStartValue(fModSaveMinTime)
      SetSliderDialogDefaultValue(5.0)
      SetSliderDialogRange(0, 30)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      fModSaveMinTime = (fValue As Int)
      SetSliderOptionValueST(fModSaveMinTime, "{0}min")
   EndEvent

   Event OnDefaultST()
      fModSaveMinTime = 5.0
      SetSliderOptionValueST(fModSaveMinTime, "{0}min")
   EndEvent

   Event OnHighlightST()
      SetInfoText("When \"Full Control\" is ensabled this is the minimum time (in Real Time Minutes)\n" +\
                  "that needs to pass after any quick or auto save before the next one can be made.\n" +\
                  "Intended to reduce too many auto saves but can be used to make saving more difficult.")
   EndEvent
EndState

State ST_CON_CONSOLE_ACCESS
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iConConsoleVulnerability)
      SetSliderDialogDefaultValue(100)
      SetSliderDialogRange(0, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iConConsoleVulnerability = (fValue As Int)
      SetSliderOptionValueST(iConConsoleVulnerability)

      ; The main script needs to (de)register for console access events.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("SaveControl")
   EndEvent

   Event OnDefaultST()
      iConConsoleVulnerability = 100
      SetSliderOptionValueST(iConConsoleVulnerability)

      ; The main script needs to (de)register for console access events.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("SaveControl")
   EndEvent

   Event OnHighlightST()
      SetInfoText("When \"Full Control\" is ensabled this is the maximum vulnerability the player can be at\n" +\
                  "and still open the debug console.  If the player is vulnerable and the console is opened the\n" +\
                  "control system will detect this and stop the game from being played further.\n" +\
                  "Recommended: 100 or 0 - Off.")
   EndEvent
EndState


State ST_CON_RAPE_REDRESS
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iModRapeRedressTimeout)
      SetSliderDialogDefaultValue(90)
      SetSliderDialogRange(0, 300)
      SetSliderDialogInterval(5)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iModRapeRedressTimeout = (fValue As Int)
      SetSliderOptionValueST(iModRapeRedressTimeout)
   EndEvent

   Event OnDefaultST()
      iModRapeRedressTimeout = 90
      SetSliderOptionValueST(iModRapeRedressTimeout)
   EndEvent

   Event OnHighlightST()
      SetInfoText("After the player has been raped it will take them some time to dress.\n" +\
                  "Attempts to dress in this time will be blocked and the timer will be reset.\n" +\
                  "Measured in game minutes.  0 turns off this feature.")
   EndEvent
EndState

State ST_CON_NAKED_REDRESS
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iModNakedRedressTimeout)
      SetSliderDialogDefaultValue(20)
      SetSliderDialogRange(0, 300)
      SetSliderDialogInterval(5)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iModNakedRedressTimeout = (fValue As Int)
      SetSliderOptionValueST(iModNakedRedressTimeout)
   EndEvent

   Event OnDefaultST()
      iModNakedRedressTimeout = 20
      SetSliderOptionValueST(iModNakedRedressTimeout)
   EndEvent

   Event OnHighlightST()
      SetInfoText("After the player has been detected as naked it will take them some time to dress.\n" +\
                  "Attempts to dress in this time will be blocked and the timer will be reset.\n" +\
                  "Measured in game minutes.  0 turns off this feature.")
   EndEvent
EndState

State ST_CON_LOAD_BLOCK
   Event OnSelectST()
      bModBlockOnGameLoad = !bModBlockOnGameLoad
      SetToggleOptionValueST(bModBlockOnGameLoad)
   EndEvent

   Event OnDefaultST()
      bModBlockOnGameLoad = False
      SetToggleOptionValueST(bModBlockOnGameLoad)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Toggles whether control features should be re-blocked on loading a game.\n" +\
                  "This applies to health/magika/stamina/fast travel/fighting/camera/sneaking/menus/activations/journal.\n" +\
                  "Controls will only be blocked if a feature blocked them before the save.  Disable if you are having problems.")
   EndEvent
EndState


;***********************************************************************************************
;***                                STATES: MOD COMPATIBILITY                                ***
;***********************************************************************************************
State ST_COMP_DD_FIX
   Event OnSelectST()
      bSettingsDetectUnequip = !bSettingsDetectUnequip
      SetToggleOptionValueST(bSettingsDetectUnequip)
   EndEvent

   Event OnDefaultST()
      bSettingsDetectUnequip = False
      SetToggleOptionValueST(bSettingsDetectUnequip)
   EndEvent

   Event OnHighlightST()
      SetInfoText("There is a certain game mechanic (I won't go into what it is) that allows\n" +\
                  "Devious Restraints to be errantly unequipped.\n" +\
                  "If you are experiencing this problem setting this might help.\n" +\
                  "Note: This may also work on some locked Zaz restraints as well but they are less tested.")
   EndEvent
EndState

State ST_MOD_MULTI_POLE_ANIM
   Event OnMenuOpenST()
      ; Create a new array to hold all of the options.
      String[] aszOptions = New String[19]
      aszOptions[0]  = GetMultiAnimationName(-7)
      aszOptions[1]  = GetMultiAnimationName(-6)
      aszOptions[2]  = GetMultiAnimationName(-5)
      aszOptions[3]  = GetMultiAnimationName(-4)
      aszOptions[4]  = GetMultiAnimationName(-3)
      aszOptions[5]  = GetMultiAnimationName(-2)
      aszOptions[6]  = GetMultiAnimationName(-1)
      aszOptions[7]  = GetMultiAnimationName(0)
      aszOptions[8]  = GetMultiAnimationName(1)
      aszOptions[9]  = GetMultiAnimationName(2)
      aszOptions[10] = GetMultiAnimationName(3)
      aszOptions[11] = GetMultiAnimationName(4)
      aszOptions[12] = GetMultiAnimationName(5)
      aszOptions[13] = GetMultiAnimationName(6)
      aszOptions[14] = GetMultiAnimationName(7)
      aszOptions[15] = GetMultiAnimationName(8)
      aszOptions[16] = GetMultiAnimationName(9)
      aszOptions[17] = GetMultiAnimationName(10)
      aszOptions[18] = GetMultiAnimationName(11)

      ; Display the options
      SetMenuDialogStartIndex(iModMultiPoleAnimation + 7)
      ; Index 0 = value -7 = Recommended
      SetMenuDialogDefaultIndex(0)
      SetMenuDialogOptions(aszOptions)
   EndEvent

   Event OnMenuAcceptST(Int iChosenIndex)
      ; -7: Recommended  -6: Cycle Real  -5: Cycle Alt     -4: Cycle Both
      ; -3: Random Real  -2: Random Alt  -1: Random Both  0-x: Indexable Animations
      iModMultiPoleAnimation = iChosenIndex - 7

      SetMenuOptionValueST(GetMultiAnimationName(iModMultiPoleAnimation))

      ; Send a setting changed event to the main script in case it needs to be applied immediately.
      SendSettingChangedEvent("ModMulti")
   EndEvent

   Event OnHighlightST()
      SetInfoText("Chose a default animation to play when sitting on Multi-Restraint poles.\n" +\
                  "Real poses look more real and are affixed to the pole.  Chains in the Alt poses go off into nowhere.\n" +\
                  "Recommended is a random pose chosen from all Real poses except Suspended.")
   EndEvent
EndState

State ST_MOD_MULTI_WALL_ANIM
   Event OnMenuOpenST()
      ; Create a new array to hold all of the options.
      String[] aszOptions = New String[19]
      aszOptions[0]  = GetMultiAnimationName(-7)
      aszOptions[1]  = GetMultiAnimationName(-6)
      aszOptions[2]  = GetMultiAnimationName(-5)
      aszOptions[3]  = GetMultiAnimationName(-4)
      aszOptions[4]  = GetMultiAnimationName(-3)
      aszOptions[5]  = GetMultiAnimationName(-2)
      aszOptions[6]  = GetMultiAnimationName(-1)
      aszOptions[7]  = GetMultiAnimationName(0)
      aszOptions[8]  = GetMultiAnimationName(1)
      aszOptions[9]  = GetMultiAnimationName(2)
      aszOptions[10] = GetMultiAnimationName(3)
      aszOptions[11] = GetMultiAnimationName(4)
      aszOptions[12] = GetMultiAnimationName(5)
      aszOptions[13] = GetMultiAnimationName(6)
      aszOptions[14] = GetMultiAnimationName(7)
      aszOptions[15] = GetMultiAnimationName(8)
      aszOptions[16] = GetMultiAnimationName(9)
      aszOptions[17] = GetMultiAnimationName(10)
      aszOptions[18] = GetMultiAnimationName(11)

      ; Display the options
      SetMenuDialogStartIndex(iModMultiWallAnimation + 7)
      ; Index 0 = value -7 = Recommended
      SetMenuDialogDefaultIndex(0)
      SetMenuDialogOptions(aszOptions)
   EndEvent

   Event OnMenuAcceptST(Int iChosenIndex)
      ; -7: Recommended  -6: Cycle Real  -5: Cycle Alt     -4: Cycle Both
      ; -3: Random Real  -2: Random Alt  -1: Random Both  0-x: Indexable Animations
      iModMultiWallAnimation = iChosenIndex - 7

      SetMenuOptionValueST(GetMultiAnimationName(iModMultiWallAnimation))

      ; Send a setting changed event to the main script in case it needs to be applied immediately.
      SendSettingChangedEvent("ModMulti")
   EndEvent

   Event OnHighlightST()
      SetInfoText("Chose a default animation to play when sitting on Multi-Restraint walls.\n" +\
                  "Real poses look more real and are affixed to the wall.  Chains in the Alt poses go off into nowhere.\n" +\
                  "Recommended is a random pose chosen from all Real poses except Suspended.")
   EndEvent
EndState

State ST_COMP_SLA_THRESHOLD
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iModSlaThreshold)
      SetSliderDialogDefaultValue(3)
      SetSliderDialogRange(0, 25)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iModSlaThreshold = (fValue As Int)
      SetSliderOptionValueST(iModSlaThreshold)
   EndEvent

   Event OnDefaultST()
      iModSlaThreshold = 3
      SetSliderOptionValueST(iModSlaThreshold)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Tired of people wandering around Skyrim unaroused?  With this feature\n" +\
                  "anyone you meet with an arousal below this threshold will be randomly increased.\n" +\
                  "0 turns off this feature.  Most arousal will be 0 so this can be a very low number.")
   EndEvent
EndState

State ST_COMP_SLA_MIN
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iModSlaAdjustedMin)
      SetSliderDialogDefaultValue(5)
      SetSliderDialogRange(0, 90)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iModSlaAdjustedMin = (fValue As Int)
      SetSliderOptionValueST(iModSlaAdjustedMin)
   EndEvent

   Event OnDefaultST()
      iModSlaAdjustedMin = 5
      SetSliderOptionValueST(iModSlaAdjustedMin)
   EndEvent

   Event OnHighlightST()
      SetInfoText("When you meet someone with an initial arousal below the threshold their arousal\n" +\
                  "will be randomly increased to a value between the minimum and maximum values.")
   EndEvent
EndState

State ST_COMP_SLA_MAX
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iModSlaAdjustedMax)
      SetSliderDialogDefaultValue(50)
      SetSliderDialogRange(0, 90)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iModSlaAdjustedMax = (fValue As Int)
      SetSliderOptionValueST(iModSlaAdjustedMax)
   EndEvent

   Event OnDefaultST()
      iModSlaAdjustedMax = 50
      SetSliderOptionValueST(iModSlaAdjustedMax)
   EndEvent

   Event OnHighlightST()
      SetInfoText("When you meet someone with an initial arousal below the threshold their arousal\n" +\
                  "will be randomly increased to a value between the minimum and maximum values.")
   EndEvent
EndState

State ST_COMP_RELOAD_CELLS
   Event OnSelectST()
      SetTextOptionValueST("Done")
      _qFramework.InitSpecialCells()
   EndEvent

   Event OnDefaultST()
      SetTextOptionValueST("Reload Now")
   EndEvent

   Event OnHighlightST()
      SetInfoText("Reload any cells that are treated specially as being in a particular location/region.\n" +\
                  "This needs to be called after installing/uninstalling a mod that contains special cells.\n" +\
                  "Initially only drlove33's house locations are treated as special cells.\n")
   EndEvent
EndState

State ST_COMP_EASTERN_HOUSE
   Event OnSelectST()
      bEasternHouseIsWindhelm = !bEasternHouseIsWindhelm
      SetToggleOptionValueST(bEasternHouseIsWindhelm)
      _qFramework.InitSpecialCells()
   EndEvent

   Event OnDefaultST()
      bEasternHouseIsWindhelm = False
      SetToggleOptionValueST(bEasternHouseIsWindhelm)
      _qFramework.InitSpecialCells()
   EndEvent

   Event OnHighlightST()
      SetInfoText("The Eastern House from drlove33's Eastern Holding Cells mod is rather far from Windhelm.\n" +\
                  "Set this option for Devious Framework to consider it part of Windhelm anyway.")
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
      ; Ignore the first option ("Exit")
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
      SetToggleOptionValueST(True)
      Actor aActor = _aPlayer
      String szTitle = "Player"
      If (!_bInfoForPlayer)
         Actor aNearby = _qFramework.GetNearestActor(0)
         If (aNearby)
            aActor = aNearby
            szTitle = aActor.GetDisplayName()
         EndIf
      EndIf

      String[] aszInfo

      ; Create a list of information to present to the user.
      Faction[] aoFaction = aActor.GetFactions(-128, 127)
      Int iIndex = (aoFaction.Length - 1)

      While (0 <= iIndex)
         Faction oFaction = aoFaction[iIndex]
         String szFormId = "0x" + _qDfwUtil.ConvertHexToString(oFaction.GetFormID(), 8)
         String szName = GetFactionName(oFaction)
         Int iRank = aActor.GetFactionRank(oFaction)
         Bool bInFaction = aActor.IsInFaction(oFaction)
         aszInfo = _qDfwUtil.AddStringToArray(aszInfo, szFormId + "-" + szName + ": " + iRank + " (" + bInFaction + ")")
         iIndex -= 1
      EndWhile

      ; Includ information in the title about how many factions the player/NPC is in.
      szTitle += " " + aoFaction.Length + " Factions"

      ; Display the information for the user.
      PresentInformation(aszInfo, szTitle)
      SetToggleOptionValueST(False)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Display the factions the player is in.")
   EndEvent
EndState

State ST_INFO_REACTIONS
   Event OnSelectST()
      SetToggleOptionValueST(True)
      String[] aszInfo

      ; Get factions for the player and for the nearest actor.
      Faction[] aoPlayerFactions = _aPlayer.GetFactions(-128, 127)
      Actor aNearest
      If (_bInfoForPlayer)
         aNearest = _qFramework.GetNearestActor(0)
      Else
         ; If info for player is not selected use the player's combat target instead of nearest actor.
         aNearest = _aPlayer.GetCombatTarget()
      EndIf
      Faction[] aoNearestFactions = aNearest.GetFactions(-128, 127)

      Int iNearestMaxIndex = aoNearestFactions.Length - 1
      Int iPlayerIndex = aoPlayerFactions.Length - 1
      While (0 <= iPlayerIndex)
         Faction oPlayerFaction = aoPlayerFactions[iPlayerIndex]
         String szPlayerFactionName = GetFactionName(oPlayerFaction)

         Bool bMatchFound = False
         Int iNearestIndex = iNearestMaxIndex
         While (0 <= iNearestIndex)
            Faction oNearestFaction = aoNearestFactions[iNearestIndex]
            String szNearestFactionName = GetFactionName(oNearestFaction)

            If ((oNearestFaction == oPlayerFaction) || \
                (oPlayerFaction.GetReaction(oNearestFaction) || oNearestFaction.GetReaction(oPlayerFaction)))
               If (!bMatchFound)
                  aszInfo = _qDfwUtil.AddStringToArray(aszInfo, "===" + szPlayerFactionName + "===")
                  bMatchFound = True
               EndIf
               aszInfo = _qDfwUtil.AddStringToArray(aszInfo, szNearestFactionName + \
                                                             " (" + oPlayerFaction.GetReaction(oNearestFaction) + "-" + \
                                                             oNearestFaction.GetReaction(oPlayerFaction) + ")")
            EndIf
            iNearestIndex -= 1
         EndWhile
         iPlayerIndex -= 1
      EndWhile

      ; Display the information for the user.
      PresentInformation(aszInfo, "Target: " + aNearest.GetDisplayName())
      SetToggleOptionValueST(False)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Display the faction reaction for each of the player's factions against those of the nearest actor.\n" +\
                  "Any faction combinations that are not dispalyed have a reaction of 0.\n" +\
                  "If \"Use Player for Info\" is un-selected the player's combat target will be used instead.")
   EndEvent
EndState

State ST_INFO_NEARBY
   Event OnSelectST()
      SetToggleOptionValueST(True)
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
      SetToggleOptionValueST(False)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Display Actors in the nearby actor's list and their actor flags:\n" +\
                  "0x001 Estimate  0x002 Important   0x004 Child  0x008 Guard  0x010 Merchant\n" +\
                  "0x080 Dominant  0x100 submissive  0x200 slave  0x400 Owner  0x800 Trader")
   EndEvent
EndState

State ST_INFO_KNOWN
   Event OnSelectST()
      SetToggleOptionValueST(True)
      String[] aszInfo

      ; Create a list of information to present to the user.
      Form[] aaKnown = _qFramework.GetKnownActors()

      Int iCount = aaKnown.Length
      Int iIndex
      While (iIndex < iCount)
         Actor aActor = (aaKnown[iIndex] As Actor)
         aszInfo = _qDfwUtil.AddStringToArray(aszInfo, iIndex + ": " + \
            aActor.GetDisplayName() + "-" + _qFramework.GetActorSignificance(aActor) + \
                                      " A:" + _qFramework.GetActorAnger(aActor, -1) + \
                                      " C:" + _qFramework.GetActorConfidence(aActor, -1) + \
                                      " D:" + _qFramework.GetActorDominance(aActor, -1) + \
                                      " I:" + _qFramework.GetActorInterest(aActor, -1) + \
                                      " K:" + _qFramework.GetActorKindness(aActor, -1))
         iIndex += 1
      EndWhile

      ; Display the information for the user.
      PresentInformation(aszInfo, "Known Actors")
      SetToggleOptionValueST(False)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Display disposition of actors who have recently been in contact with the player.\n" +\
                  "-Significance  A:Anger  C:Confidence  D:Dominance  I:Interest  K:Kindness")
   EndEvent
EndState

State ST_INFO_DIALOGUE
   Event OnSelectST()
      SetToggleOptionValueST(True)
      String[] aszInfo = _qFramework.GetDialogueTargetInfo()

      ; Display the information for the user.
      PresentInformation(aszInfo, "Dialogue Target Info")
      SetToggleOptionValueST(False)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Displays information the framework gathered for the last dialogue target.")
   EndEvent
EndState

State ST_INFO_NAKED
   Event OnHighlightST()
      SetInfoText("The naked level of the player.\n" +\
                  "0x00 Naked  0x01 Waist Partial  0x02 Waist Covered\n" +\
                  "0x04 Chest Partial  0x08 Chest Covered  0x10 Both Partial  0x20 Both Covered")
   EndEvent
EndState


;***********************************************************************************************
;***                                    STATES: DEBUG                                        ***
;***********************************************************************************************
State ST_DBG_LEVEL
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iLogLevel)
      SetSliderDialogDefaultValue(5)
      SetSliderDialogRange(0, 5)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iLogLevel = (fValue As Int)
      SetSliderOptionValueST(iLogLevel)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Logging")
   EndEvent

   Event OnDefaultST()
      iLogLevel = 5
      SetSliderOptionValueST(iLogLevel)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Logging")
   EndEvent

   Event OnHighlightST()
      SetInfoText("Set the level of messages that go to the papyrus log file.\n" +\
                  "(0 = Off)  (1 = Critical)  (2 = Error)  (3 = Information)  (4 = Debug)  (5 = Trace)\n" +\
                  "Recommended: 4 - Debug.  5 - Trace if you are having trouble.")
   EndEvent
EndState

State ST_DBG_GENERAL
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iLogLevelScreenGeneral)
      SetSliderDialogDefaultValue(3)
      SetSliderDialogRange(0, 5)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iLogLevelScreenGeneral = (fValue As Int)
      SetSliderOptionValueST(iLogLevelScreenGeneral)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Logging")
   EndEvent

   Event OnDefaultST()
      iLogLevelScreenGeneral = 3
      SetSliderOptionValueST(iLogLevelScreenGeneral)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Logging")
   EndEvent

   Event OnHighlightST()
      SetInfoText("Set the level on the screen for general messages.\n" +\
                  "(0 = Off)  (1 = Critical)  (2 = Error)  (3 = Information)  (4 = Debug)  (5 = Trace)\n" +\
                  "Recommended: 3 - Information")
   EndEvent
EndState

State ST_DBG_DEBUG
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iLogLevelScreenDebug)
      SetSliderDialogDefaultValue(3)
      SetSliderDialogRange(0, 5)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iLogLevelScreenDebug = (fValue As Int)
      SetSliderOptionValueST(iLogLevelScreenDebug)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Logging")
   EndEvent

   Event OnDefaultST()
      iLogLevelScreenDebug = 3
      SetSliderOptionValueST(iLogLevelScreenDebug)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Logging")
   EndEvent

   Event OnHighlightST()
      SetInfoText("Set the level on the screen for player status related messages.\n" +\
                  "(0 = Off)  (1 = Critical)  (2 = Error)  (3 = Information)  (4 = Debug)  (5 = Trace)\n" +\
                  "Recommended: 3 - Information.  4 - Debug turns on debug messages.")
   EndEvent
EndState

State ST_DBG_STATUS
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iLogLevelScreenStatus)
      SetSliderDialogDefaultValue(3)
      SetSliderDialogRange(0, 5)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iLogLevelScreenStatus = (fValue As Int)
      SetSliderOptionValueST(iLogLevelScreenStatus)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Logging")
   EndEvent

   Event OnDefaultST()
      iLogLevelScreenStatus = 3
      SetSliderOptionValueST(iLogLevelScreenStatus)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Logging")
   EndEvent

   Event OnHighlightST()
      SetInfoText("Set the level on the screen for player status related messages.\n" +\
                  "(0 = Off)  (1 = Critical)  (2 = Error)  (3 = Information)  (4 = Debug)  (5 = Trace)\n" +\
                  "Recommended: 3 - Information")
   EndEvent
EndState

State ST_DBG_MASTER
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iLogLevelScreenMaster)
      SetSliderDialogDefaultValue(3)
      SetSliderDialogRange(0, 5)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iLogLevelScreenMaster = (fValue As Int)
      SetSliderOptionValueST(iLogLevelScreenMaster)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Logging")
   EndEvent

   Event OnDefaultST()
      iLogLevelScreenMaster = 3
      SetSliderOptionValueST(iLogLevelScreenMaster)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Logging")
   EndEvent

   Event OnHighlightST()
      SetInfoText("Set the level on the screen for messages related to DFW registered Masters.\n" +\
                  "(0 = Off)  (1 = Critical)  (2 = Error)  (3 = Information)  (4 = Debug)  (5 = Trace)\n" +\
                  "Recommended: 3 - Information")
   EndEvent
EndState

State ST_DBG_NEARBY
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iLogLevelScreenNearby)
      SetSliderDialogDefaultValue(3)
      SetSliderDialogRange(0, 5)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iLogLevelScreenNearby = (fValue As Int)
      SetSliderOptionValueST(iLogLevelScreenNearby)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Logging")
   EndEvent

   Event OnDefaultST()
      iLogLevelScreenNearby = 3
      SetSliderOptionValueST(iLogLevelScreenNearby)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Logging")
   EndEvent

   Event OnHighlightST()
      SetInfoText("Set the level on the screen for messages related to nearby NPCs.\n" +\
                  "(0 = Off)  (1 = Critical)  (2 = Error)  (3 = Information)  (4 = Debug)  (5 = Trace)\n" +\
                  "Recommended: 3 - Information")
   EndEvent
EndState

State ST_DBG_LEASH
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iLogLevelScreenLeash)
      SetSliderDialogDefaultValue(3)
      SetSliderDialogRange(0, 5)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iLogLevelScreenLeash = (fValue As Int)
      SetSliderOptionValueST(iLogLevelScreenLeash)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Logging")
   EndEvent

   Event OnDefaultST()
      iLogLevelScreenLeash = 3
      SetSliderOptionValueST(iLogLevelScreenLeash)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Logging")
   EndEvent

   Event OnHighlightST()
      SetInfoText("Set the level on the screen for leash related messages.\n" +\
                  "(0 = Off)  (1 = Critical)  (2 = Error)  (3 = Information)  (4 = Debug)  (5 = Trace)\n" +\
                  "Recommended: 3 - Information")
   EndEvent
EndState

State ST_DBG_EQUIP
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iLogLevelScreenEquip)
      SetSliderDialogDefaultValue(3)
      SetSliderDialogRange(0, 5)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iLogLevelScreenEquip = (fValue As Int)
      SetSliderOptionValueST(iLogLevelScreenEquip)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Logging")
   EndEvent

   Event OnDefaultST()
      iLogLevelScreenEquip = 3
      SetSliderOptionValueST(iLogLevelScreenEquip)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Logging")
   EndEvent

   Event OnHighlightST()
      SetInfoText("Set the level on the screen for messages about equipment and equipment blocking.\n" +\
                  "(0 = Off)  (1 = Critical)  (2 = Error)  (3 = Information)  (4 = Debug)  (5 = Trace)\n" +\
                  "Recommended: 3 - Information")
   EndEvent
EndState

State ST_DBG_AROUSAL
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iLogLevelScreenArousal)
      SetSliderDialogDefaultValue(3)
      SetSliderDialogRange(0, 5)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iLogLevelScreenArousal = (fValue As Int)
      SetSliderOptionValueST(iLogLevelScreenArousal)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Logging")
   EndEvent

   Event OnDefaultST()
      iLogLevelScreenArousal = 3
      SetSliderOptionValueST(iLogLevelScreenArousal)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Logging")
   EndEvent

   Event OnHighlightST()
      SetInfoText("Set the level on the screen for messages about changing nearby NPC arousal.\n" +\
                  "(0 = Off)  (1 = Critical)  (2 = Error)  (3 = Information)  (4 = Debug)  (5 = Trace)\n" +\
                  "Recommended: 3 - Information")
   EndEvent
EndState

State ST_DBG_INTERACTION
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iLogLevelScreenInteraction)
      SetSliderDialogDefaultValue(3)
      SetSliderDialogRange(0, 5)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iLogLevelScreenInteraction = (fValue As Int)
      SetSliderOptionValueST(iLogLevelScreenInteraction)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Logging")
   EndEvent

   Event OnDefaultST()
      iLogLevelScreenInteraction = 3
      SetSliderOptionValueST(iLogLevelScreenInteraction)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Logging")
   EndEvent

   Event OnHighlightST()
      SetInfoText("Set the level on the screen for messages about NPC approach and calling for help.\n" +\
                  "(0 = Off)  (1 = Critical)  (2 = Error)  (3 = Information)  (4 = Debug)  (5 = Trace)\n" +\
                  "Recommended: 2 - Error")
   EndEvent
EndState

State ST_DBG_LOCATION
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iLogLevelScreenLocation)
      SetSliderDialogDefaultValue(3)
      SetSliderDialogRange(0, 5)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iLogLevelScreenLocation = (fValue As Int)
      SetSliderOptionValueST(iLogLevelScreenLocation)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Logging")
   EndEvent

   Event OnDefaultST()
      iLogLevelScreenLocation = 3
      SetSliderOptionValueST(iLogLevelScreenLocation)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Logging")
   EndEvent

   Event OnHighlightST()
      SetInfoText("Set the level on the screen for change of location messages.\n" +\
                  "(0 = Off)  (1 = Critical)  (2 = Error)  (3 = Information)  (4 = Debug)  (5 = Trace)\n" +\
                  "Recommended: 3 - Location Changes.  4 - Nearby Regions as well.  2 - Turn these off.")
   EndEvent
EndState

State ST_DBG_REDRESS
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iLogLevelScreenRedress)
      SetSliderDialogDefaultValue(3)
      SetSliderDialogRange(0, 5)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iLogLevelScreenRedress = (fValue As Int)
      SetSliderOptionValueST(iLogLevelScreenRedress)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Logging")
   EndEvent

   Event OnDefaultST()
      iLogLevelScreenRedress = 3
      SetSliderOptionValueST(iLogLevelScreenRedress)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Logging")
   EndEvent

   Event OnHighlightST()
      SetInfoText("Set the level on the screen for rape and redress timeouts expiring.\n" +\
                  "(0 = Off)  (1 = Critical)  (2 = Error)  (3 = Information)  (4 = Debug)  (5 = Trace)\n" +\
                  "Recommended: 3 - Information to see the messages.  2 - Error if you don't want to see them.")
   EndEvent
EndState

State ST_DBG_SAVE
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iLogLevelScreenSave)
      SetSliderDialogDefaultValue(3)
      SetSliderDialogRange(0, 5)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iLogLevelScreenSave = (fValue As Int)
      SetSliderOptionValueST(iLogLevelScreenSave)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Logging")
   EndEvent

   Event OnDefaultST()
      iLogLevelScreenSave = 3
      SetSliderOptionValueST(iLogLevelScreenSave)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Logging")
   EndEvent

   Event OnHighlightST()
      SetInfoText("Set the level on the screen for messages related to the DFW save game control feature.\n" +\
                  "(0 = Off)  (1 = Critical)  (2 = Error)  (3 = Information)  (4 = Debug)  (5 = Trace)\n" +\
                  "Recommended: 3 - Information")
   EndEvent
EndState

State ST_DBG_SHUTDOWN
   Event OnSelectST()
      bShutdownMod = !bShutdownMod
      SetToggleOptionValueST(bShutdownMod)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Debug")
   EndEvent

   Event OnDefaultST()
      bShutdownMod = False
      SetToggleOptionValueST(bShutdownMod)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Debug")
   EndEvent

   Event OnHighlightST()
      SetInfoText("Shut down the mod in preparation for uninstallation or a clean save before upgrading.\n" +\
                  "This does not stop any features/scenes already in progress.\n" +\
                  "Make sure to complete any scenes before using this feature.")
   EndEvent
EndState

State ST_DBG_SHUTDOWN_SEC
   Event OnSelectST()
      bShutdownSecure = !bShutdownSecure
      SetToggleOptionValueST(bShutdownSecure)

      ; If the settings are now secure disable access to them.
      If (bShutdownSecure && IsSecure())
         SetOptionFlagsST(OPTION_FLAG_DISABLED, a_stateName="ST_DBG_SHUTDOWN_SEC")
         SetOptionFlagsST(OPTION_FLAG_DISABLED, a_stateName="ST_DBG_SHUTDOWN")
      EndIf
   EndEvent

   Event OnDefaultST()
      bShutdownSecure = False
      SetToggleOptionValueST(bShutdownSecure)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Make the shutdown option inaccessible when vulnerable.\n" +\
                  "This makes uninstalling the mod to escape predicaments more difficult.")
   EndEvent
EndState

State ST_DBG_YANK_LEASH
   Event OnSelectST()
      SetTextOptionValueST("Done")
      _qFramework.YankLeash(0, _qFramework.LS_DRAG, bInterruptLeashTarget=True)
   EndEvent

   Event OnDefaultST()
      SetTextOptionValueST("Do It Now")
   EndEvent

   Event OnHighlightST()
      SetInfoText("Sometimes with the \"Drag\" leash the player can get caught bobbing back and forth.\n" + \
                  "Most of the time this issue will correct itself.  In the odd case that it doesn't, performing\n" +\
                  "a manual yank of the leash will should fix this issue.")
   EndEvent
EndState

State ST_DBG_TELEPORT
   Event OnMenuOpenST()
      String[] aszOptions = New String[15]
      aszOptions[0]  = "Cancel"
      aszOptions[1]  = "Dawnstar"
      aszOptions[2]  = "Dragon Bridge"
      aszOptions[3]  = "Falkreath"
      aszOptions[4]  = "Ivarstead"
      aszOptions[5]  = "Markarth"
      aszOptions[6]  = "Morthal"
      aszOptions[7]  = "Riften"
      aszOptions[8]  = "Riverwood"
      aszOptions[9]  = "Rorikstead"
      aszOptions[10] = "Shors Stone"
      aszOptions[11] = "Solitude"
      aszOptions[12] = "Whiterun"
      aszOptions[13] = "Windhelm"
      aszOptions[14] = "Winterhold"
      Actor aCurrMaster = _qFramework.GetMaster(_qFramework.MD_CLOSE)
      If (aCurrMaster)
         aszOptions = _qDfwUtil.AddStringToArray(aszOptions, aCurrMaster.GetDisplayName())
      EndIf

      SetMenuDialogStartIndex(0)
      SetMenuDialogDefaultIndex(0)
      SetMenuDialogOptions(aszOptions)
   EndEvent

   Event OnMenuAcceptST(Int iChosenIndex)
      ; Ignore the first option ("Cancel")
      If (!iChosenIndex)
         Return
      EndIf

      ; Use an <X, Y> offset to prevent the player teleporting to the wrong side of the door.
      Int iTargetId = 0
      Float fXOffset = 0.0
      Float fYOffset = 50.00
      If (1 == iChosenIndex)
         iTargetId = 0x00013D41   ; Dawnstar
      ElseIf (2 == iChosenIndex)
         iTargetId = 0x00013E40   ; Dragon Bridge
      ElseIf (3 == iChosenIndex)
         iTargetId = 0x0003A196   ; Falkreath
      ElseIf (4 == iChosenIndex)
         iTargetId = 0x00017066   ; Ivarstead
      ElseIf (5 == iChosenIndex)
         iTargetId = 0x000793A4   ; Markarth
      ElseIf (6 == iChosenIndex)
         iTargetId = 0x0001738C   ; Morthal
      ElseIf (7 == iChosenIndex)
         iTargetId = 0x00044BD7   ; Riften
         fXOffset = 50.0
      ElseIf (8 == iChosenIndex)
         iTargetId = 0x00013419   ; Riverwood
      ElseIf (9 == iChosenIndex)
         iTargetId = 0x000174AF   ; Rorikstead
      ElseIf (10 == iChosenIndex)
         iTargetId = 0x0004132A   ; Shors Stone
      ElseIf (11 == iChosenIndex)
         iTargetId = 0x00016A8A   ; Solitude
      ElseIf (12 == iChosenIndex)
         iTargetId = 0x00016072   ; Whiterun
      ElseIf (13 == iChosenIndex)
         iTargetId = 0x000D18B5   ; Windhelm
         fXOffset = -50.0
         fYOffset = 0.00
      ElseIf (14 == iChosenIndex)
         iTargetId = 0x0001759E   ; Winterhold
      ElseIf (15 == iChosenIndex)
         Actor aCurrMaster = _qFramework.GetMaster(_qFramework.MD_CLOSE)
         iTargetId = aCurrMaster.GetFormId()
         fXOffset = 50.0
      EndIf

      String szStatus = "Done"
      If (!_qFramework.GetMaster(_qFramework.MD_CLOSE))
         ; If the player is not currently controlled assume permission and perform the transfer.
         ObjectReference oTarget = (Game.GetFormFromFile(iTargetId, \
                                                         "Skyrim.esm") As ObjectReference)
         _aPlayer.MoveTo(oTarget, fXOffset, fYOffset)
      Else
         ; Otherwise send a mod event and assume the controlling mod will handle the transfer.
         Int iModEvent = ModEvent.Create("DFW_DebugMovePlayer")
         If (iModEvent)
            ModEvent.PushInt(iModEvent, iTargetId)
            ModEvent.PushFloat(iModEvent, fXOffset)
            ModEvent.PushFloat(iModEvent, fYOffset)
            ModEvent.Send(iModEvent)
         Else
            szStatus = "Failed"
         EndIf
      EndIf
      SetTextOptionValueST(szStatus)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Tries to move the player to the specified location.")
   EndEvent
EndState

State ST_DBG_REM_FACTION
   Event OnMenuOpenST()
      Actor aActor = _aPlayer
      If (!_bInfoForPlayer)
         Actor aNearby = _qFramework.GetNearestActor(0)
         If (aNearby)
            aActor = aNearby
         EndIf
      EndIf

      ; Get a list of all of the factions for the selected actor.
      Faction[] aoFaction = aActor.GetFactions(-128, 127)
      Int iCount = aoFaction.Length

      String[] aszOptions = Utility.CreateStringArray(iCount + 1)
      aszOptions[0] = S_REM_NONE

      ; Add a text value for each slot to the option array.
      Int iIndex = 0
      While (iIndex < iCount)
         Faction oFaction = aoFaction[iIndex]
         String szFormId = "0x" + _qDfwUtil.ConvertHexToString(oFaction.GetFormID(), 8)
         String szName = GetFactionName(oFaction)
         aszOptions[iIndex + 1] = szName + " (" + szFormId + ")"
         iIndex += 1
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

      ; Adjust the chosen index since the "Remove None" is no longer in the list.
      iChosenIndex -= 1

      ; Recreate the list of factions that was presented to the user.
      Actor aActor = _aPlayer
      If (!_bInfoForPlayer)
         Actor aNearby = _qFramework.GetNearestActor(0)
         If (aNearby)
            aActor = aNearby
         EndIf
      EndIf
      Faction[] aoFaction = aActor.GetFactions(-128, 127)
      Faction oFaction = aoFaction[iChosenIndex]
      aActor.RemoveFromFaction(oFaction) 
   EndEvent

   Event OnHighlightST()
      SetInfoText("Use this to remove the player or the nearest NPC from a faction.\n" +\
                  "\"Use Player for Info\" under \"Status\" determines whether the palyer or\n" +\
                  "the nearest NPC will be used.")
   EndEvent
EndState

State ST_DBG_MCM_UPGRADE
   Event OnSelectST()
      Int iLatestVersion = GetVersion()
      If (CurrentVersion >= iLatestVersion)
         SetTextOptionValueST("Not Needed")
         Return
      EndIf
      SetTextOptionValueST("Upgraded " + CurrentVersion + " to " + iLatestVersion)
      UpdateScript()
      CurrentVersion = iLatestVersion
   EndEvent

   Event OnDefaultST()
      SetTextOptionValueST("Upgrade Now")
   EndEvent

   Event OnHighlightST()
      SetInfoText("The MCM script upgrade system does not always check for script upgrades when the game is loaded.\n" +\
                  "If you suspect some new options are not at their default values try using this debug option.\n" +\
                  "It should be safe to perform this upgrade.  If no upgrade is needed nothing will change.")
   EndEvent
EndState

State ST_DBG_MOD_EVENTS
   Event OnSelectST()
      _qFramework.ReRegisterModEvents()
      SetTextOptionValueST("Done")
   EndEvent

   Event OnDefaultST()
      SetTextOptionValueST("Fix Now")
   EndEvent

   Event OnHighlightST()
      SetInfoText("Re-register for all mod events this mod should be registered for.\n" +\
                  "Registering for mod events does not always succeed, especially early after a game load.\n" +\
                  "This can be used to remedy this situation or if mod events are not being received for any reason.")
   EndEvent
EndState

State ST_DBG_CLEAR_HOVER
   Event OnSelectST()
      _qFramework.ClearHovering()
      SetTextOptionValueST("Done")
   EndEvent

   Event OnDefaultST()
      SetTextOptionValueST("Clear Now")
   EndEvent

   Event OnHighlightST()
      SetInfoText("Actors using the Hover At packages of this mod do not time out naturally.\n" +\
                  "If you notice an actor hovering around the player or another object with no scene running\n" +\
                  "clearing them manually may help.  It shouldn't hurt if no scenes are in progress.")
   EndEvent
EndState

State ST_DBG_CLEAR_MOVEMENT
   Event OnSelectST()
      _qFramework.ClearAllMovement()
      SetTextOptionValueST("Done")
   EndEvent

   Event OnDefaultST()
      SetTextOptionValueST("Clear Now")
   EndEvent

   Event OnHighlightST()
      SetInfoText("WARNING: Using this during a scene has a good chance to break the scene.\n" +\
                  "Only use this if you are certain no scenes are running or a scene is not progressing.\n" +\
                  "This clears all movement for scenes.  Intended to fix movement data leftover from a completed scene.")
   EndEvent
EndState


State ST_SAFEWORD_FURNITURE
   Event OnSelectST()
      ; Send an event to indicate the safeword has been invoked.
      SendSettingChangedEvent("SafewordFurniture")
      SetTextOptionValueST("Done")
   EndEvent

   Event OnDefaultST()
      SetTextOptionValueST("Use Safeword")
   EndEvent

   Event OnHighlightST()
      SetInfoText("Releases all locks and lock related status related to BDSM furniture.\n" +\
                  "Note: This only clears DFW status.  Mods that created the lock may need to be cleared separately.\n" +\
                  "Warning: This feature cannot be used when the mod's MCM security settings are used.")
   EndEvent
EndState

State ST_SAFEWORD_LEASH
   Event OnSelectST()
      ; Send an event to indicate the safeword has been invoked.
      SendSettingChangedEvent("SafewordLeash")
      SetTextOptionValueST("Done")
   EndEvent

   Event OnDefaultST()
      SetTextOptionValueST("Use Safeword")
   EndEvent

   Event OnHighlightST()
      SetInfoText("Releases all locks and lock related status related to the DFW leash.\n" +\
                  "Note: This only clears DFW status.  Mods that secured the leash may need to be cleared separately.\n" +\
                  "Warning: This feature cannot be used when the mod's MCM security settings are used.")
   EndEvent
EndState

