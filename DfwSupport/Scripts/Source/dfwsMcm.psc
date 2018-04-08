Scriptname dfwsMcm extends SKI_ConfigBase
{Configuration script for the Devious Framework support mod.}

;***********************************************************************************************
; Mod: Devious Framework Support
;
; Script: MCM Menu
;
; Configuration script for the Devious Framework Support mod.
;
; The devious framework support mod contains features that utilize the support functions of the
; Devious Framework (DFW) mod and pair well with the mod.  It also contains additional support
; features that help bridge the gap of other mods working with DFW until DFW can become more
; widely used.
; And, of course, it contains a few features that I find fun.
; There should be a mechanism to disable each feature of the mod individually.
;
; WARNING:
; Don't make any function calls to or access any properties of the main DFW Support script
; (_qDfwSupport) except while the user is accessing the menu.  Because the main script accesses
; this MCM script often and at random times, deadlock can occur if this MCM script is also
; accessing the main script at the same time.
; In particular avoid calling functions of the main script during initialization.
;
; © Copyright 2016 legume-Vancouver of GitHub
; This file is part of the Devious Framework Skyrim support mod.
;
; The Devious Framework Skyrim support mod is free software: you can redistribute it and/or
; modify it under the terms of the GNU General Public License as published by the Free Software
; Foundation, either version 3 of the License, or (at your option) any later version.
;
; The Devious Framework Skyrim support mod is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
; A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License along with The Devious
; Framework Skyrim support mod.  If not, see <http://www.gnu.org/licenses/>.
;
; History:
; 1.0 2016-06-09 by legume
; Initial version.
;***********************************************************************************************

;***********************************************************************************************
;***                                      CONSTANTS                                          ***
;***********************************************************************************************
String S_REM_NONE = "Remove None"


;***********************************************************************************************
;***                                      VARIABLES                                          ***
;***********************************************************************************************
; A local variable to store a reference to the player for faster access.
Actor _aPlayer

; A flag to prevent initialization from happening twice.
Bool _bInitBegun

; Keeps track of the last page the user viewed.
String _szLastPage

; Keep track of which furniture is selected for use.
ObjectReference _oSelectedFurniture

; *** Private Options ***
Bool _bSecureHardcore
Bool _bSecureSdPlusLeash

; *** Toggle Options ***
Bool Property bIncludeOwners    Auto
Bool Property bWalkToSsAuction  Auto
Bool Property bWalkBreakEnabled Auto
Bool Property bWalkFarSsAuction Auto
Bool Property bSexDispositions  Auto
Bool Property bCatchZazEvents   Auto
Bool Property bCatchSdPlus      Auto
Bool Property bLeashSdPlus      Auto
Bool Property bBlockHelpless    Auto
Bool Property bAllowSex         Auto
Bool Property bFurnitureHide    Auto
Bool Property bAutoAddFurniture Auto
Bool Property bShutdownMod      Auto
Bool Property bShutdownSecure   Auto
Bool Property bHotkeyPackage    Auto
Bool Property bHotkeyMultiPose  Auto

; *** Float Slider Options ***
Float Property fPollTime                Auto
Float Property fLeashGameChance         Auto
Float Property fWalkBreakMinTime        Auto
Float Property fWalkBreakMaxTime        Auto
Float Property fWalkBreakMinDuration    Auto
Float Property fWalkBreakMaxDuration    Auto
Float Property fEventSellItems          Auto
Float Property fEventRemRestraints      Auto
Float Property fEventProposition        Auto
Float Property fEventPermanency         Auto
Float Property fEventMilkScene          Auto
Float Property fEventMilkThreshold      Auto
Float Property fEventEquipSlaver        Auto
Float Property fFurnitureLockChance     Auto
Float Property fFurnitureReleaseChance  Auto
Float Property fFurnitureVisitorChance  Auto
Float Property fFurnitureRemoteVisitor  Auto

; *** Integer Slider Options ***
Int _iSecurityLevel
Int _iLogLevelScreenDef
Int Property iLeashGameStyle           Auto
Int Property iLeashChanceToNotice      Auto
Int Property iLeashProtectedDelay      Auto
Int Property iIncreaseWhenVulnerable   Auto
Int Property iMaxDistance              Auto
Int Property iLeashLength              Auto
Int Property iLeashResist              Auto
Int Property iBlockTravel              Auto
Int Property iGagMode                  Auto
Int Property iFurnitureTeaseChance     Auto
Int Property iFurnitureAltRelease      Auto
Int Property iFurnitureTransferChance  Auto
Int Property iFurnitureRemoteSandbox   Auto
Int Property iLogLevel                 Auto
Int Property iLogLevelScreen           Auto
Int Property iDbgUtilKey               Auto
Int Property iDurationMin              Auto
Int Property iDurationMax              Auto
Int Property iChanceOfRelease          Auto
Int Property iDominanceAffectsRelease  Auto
Int Property iMaxAngerForRelease       Auto
Int Property iChanceFurnitureTransfer  Auto
Int Property iLeashChanceSimple        Auto
Int Property iLeashCoolDownAmount      Auto
Int Property iLeashCoolDownTime        Auto
Int Property iChanceIdleRestraints     Auto
Int Property iChanceForAssistance      Auto
Int Property iEscapeDetection          Auto
Int Property iFurnitureMinLockTime     Auto
Int Property iModPostSexMonitor        Auto
Int Property iEventPropArousal         Auto
Int Property iWeightPunishBasic        Auto
Int Property iWeightPunishFurn         Auto
Int Property iWeightPunishCrawl        Auto
Int Property iChancePunishBlindfold    Auto
Int Property iFWeightTransferDefault   Auto
Int Property iFWeightTransferFurn      Auto
Int Property iFWeightTransferCage      Auto
Int Property iFWeightTransferBed       Auto
Int Property iFWeightTransferStore     Auto
Int Property iFWeightTransferPublic    Auto
Int Property iFWeightTransferPrivate   Auto
Int Property iFWeightTransferRemote    Auto
Int Property iFWeightPunishDefault     Auto
Int Property iFWeightPunishFurn        Auto
Int Property iFWeightPunishCage        Auto
Int Property iFWeightPunishBed         Auto
Int Property iFWeightPunishStore       Auto
Int Property iFWeightPunishPublic      Auto
Int Property iFWeightPunishPrivate     Auto
Int Property iFWeightPunishRemote      Auto
Int Property iPunishMinBehaviourRemote Auto

; *** Enumeration Options ***

; *** Lists and Advanced Options ***

; A reference to the main DFW Support quest script.
; Deadlock Warning: Don't use this except during menu access.  See file header for details.
dfwsDfwSupport _qDfwSupport

; A reference to the main framework quest script.
dfwDeviousFramework _qFramework

; A reference to the Devious Framework Util quest script.
dfwUtil _qDfwUtil

; A reference to the Devious Framework MCM quest script.
dfwMcm _qDfwMcm

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
   _bSecureSdPlusLeash = False

   Debug.Trace("[DFWS-MCM] Updating Script: " + iUpgradeFrom + " => " + GetVersion())
   Debug.Notification("[DFWS-MCM] Updating Script: " + iUpgradeFrom + " => " + GetVersion())

   ; Very basic initialization.
   If (1 > iUpgradeFrom)
      _aPlayer = Game.GetPlayer()
      _qFramework  = (Quest.GetQuest("_dfwDeviousFramework") As dfwDeviousFramework)
      _qDfwSupport = ((Self As Quest) As dfwsDfwSupport)
      _qDfwUtil    = (Quest.GetQuest("_dfwDeviousFramework") As dfwUtil)
      _qDfwMcm     = (Quest.GetQuest("_dfwDeviousFramework") As dfwMcm)
   EndIf

   ; Historical configuration...
   If (2 > iUpgradeFrom)
      bIncludeOwners           = False
      bCatchZazEvents          = True
      bLeashSdPlus             = False
      fPollTime                =   3.0
      iIncreaseWhenVulnerable  =  10
      iLeashLength             = 700
      iBlockTravel             =   1
      iLogLevel                =   5
      iDurationMin             =   5
      iDurationMax             =  15
      iChanceOfRelease         =  50
      iDominanceAffectsRelease =  45
      iMaxAngerForRelease      =  50
   EndIf

   If (3 > iUpgradeFrom)
      iChanceIdleRestraints   = 10
      fFurnitureReleaseChance =  1.0
      iFurnitureTeaseChance   = 75
      iFurnitureAltRelease    = 20
      bBlockHelpless          = False
   EndIf

   If (4 > iUpgradeFrom)
      fLeashGameChance      = 3.0
      fFurnitureLockChance  = 5.0
   EndIf

   If (5 > iUpgradeFrom)
      bAutoAddFurniture     = False
      iFurnitureMinLockTime = 30
      bCatchSdPlus          = False
   EndIf

   If (6 > iUpgradeFrom)
      ; Set the Security level to the maximum.  This does not prevent settings to be changed
      ; when installing the mod into games where the player is already vulnerable.
      _iSecurityLevel = 100

      _iLogLevelScreenDef = 2
      iLogLevelScreen     = _iLogLevelScreenDef
   EndIf

   If (7 > iUpgradeFrom)
      bSexDispositions = True
   EndIf

   If (8 > iUpgradeFrom)
      bAllowSex             = False
      bHotkeyPackage        = False
      iGagMode              =    1
      iLeashGameStyle       =    2
      iLeashProtectedDelay  =    0
      iMaxDistance          = 2000
   EndIf

   If (9 > iUpgradeFrom)
      iChanceFurnitureTransfer = 25
      iLeashChanceSimple       = 10
      bWalkToSsAuction         = True
   EndIf

   If (10 > iUpgradeFrom)
      bWalkFarSsAuction = True
   EndIf

   If (11 > iUpgradeFrom)
      bFurnitureHide = True
   EndIf

   If (12 > iUpgradeFrom)
      iLeashResist = 3
   EndIf

   If (13 > iUpgradeFrom)
      iLeashChanceToNotice    = 95
      iChanceForAssistance    = 75
      iEscapeDetection        = 10
      fFurnitureVisitorChance = 1.0
      bShutdownMod            = False
      bShutdownSecure         = False
   EndIf

   If (14 > iUpgradeFrom)
      bWalkBreakEnabled = True
      fWalkBreakMinTime = 3.0
      fWalkBreakMaxTime = 6.0
      fWalkBreakMinDuration = 0.5
      fWalkBreakMaxDuration = 3.0
      iLeashCoolDownAmount =  5
      iLeashCoolDownTime   = 20
      _oSelectedFurniture  = None
fWalkBreakMinTime =  6.0
fWalkBreakMaxTime = 10.0
fWalkBreakMinDuration = 3.0
fWalkBreakMaxDuration = 6.0
      iFurnitureTransferChance = 20
      fFurnitureRemoteVisitor  =  5.0
      iFurnitureRemoteSandbox  = 50

      fEventSellItems     = 20.0
      fEventRemRestraints = 30.0
      fEventProposition   =  5.0
      iEventPropArousal   = 40
fEventSellItems = 100.0
fEventRemRestraints = 100.0
      fEventPermanency    =  5.0

      Pages = New String[5]
      Pages[0] = "DFW Support"
      Pages[1] = "Leash Game"
      Pages[2] = "BDSM Furniture"
      Pages[3] = "Events and Weights"
      Pages[4] = "Logging + Debug"

      iWeightPunishBasic        = 10
      iWeightPunishFurn         = 10
      iWeightPunishCrawl        = 10
iWeightPunishFurn  = 54
iWeightPunishCrawl = 36
      iChancePunishBlindfold    = 40

      iFWeightTransferDefault   = 10
      iFWeightTransferFurn      =  0
      iFWeightTransferCage      =  0
      iFWeightTransferBed       =  0
      iFWeightTransferStore     =  0
      iFWeightTransferPublic    =  0
      iFWeightTransferPrivate   =  0
      iFWeightTransferRemote    =  0

      iFWeightPunishDefault     = 10
      iFWeightPunishFurn        =  0
      iFWeightPunishCage        =  0
      iFWeightPunishBed         =  0
      iFWeightPunishStore       =  0
      iFWeightPunishPublic      =  0
      iFWeightPunishPrivate     =  0
      iFWeightPunishRemote      =  0
      iPunishMinBehaviourRemote = 5

iFWeightTransferDefault =   10
iFWeightTransferCage    =    5
iFWeightTransferPrivate = -100
iFWeightTransferRemote  =   10

iFWeightTransferCage    = -100

iFWeightPunishDefault   =    1
iFWeightPunishCage      =    1
iFWeightPunishRemote    =   10

      iModPostSexMonitor        =  8

      fEventMilkScene           = 0.0
      fEventMilkThreshold       = 3.0
fEventMilkScene         = 2.0
fEventMilkThreshold     = 3.3

      iDbgUtilKey               = 0x00
      bHotkeyMultiPose          = False
; zxc
iChanceFurnitureTransfer = 50
iLeashChanceSimple = 25

      fEventEquipSlaver         = 100.0
   EndIf

   ; Any time the script is updated have the main script sync it's parameters.
   ; Give the main script some time to initialize first.
   Utility.Wait(3.0)
   SendSettingChangedEvent()
EndFunction

; Version of the MCM script.
; Unrelated to the Devious Framework Version.
Int Function GetVersion()
   ; Reset the version number.
   ; This can be used to manage saves between releases.
;   If (13 < CurrentVersion)
      CurrentVersion = 13
;   EndIf

   ; Update all quest variables upon loading each game.
   ; There are too many things that can cause them to become invalid.
   _qFramework  = (Quest.GetQuest("_dfwDeviousFramework") As dfwDeviousFramework)
   _qDfwSupport = ((Self As Quest) As dfwsDfwSupport)
   _qDfwUtil    = (Quest.GetQuest("_dfwDeviousFramework") As dfwUtil)
   _qDfwMcm     = (Quest.GetQuest("_dfwDeviousFramework") As dfwMcm)

   Return 14
EndFunction

Event OnConfigInit()
   Debug.Trace("[DFWS-MCM] TraceEvent OnConfigInit")

   If (_bInitBegun)
      Debug.Trace("[DFWS-MCM] TraceEvent OnConfigInit: Done (Init Begun)")
      Return
   EndIf
   _bInitBegun = True
   UpdateScript(0)
   Debug.Trace("[DFWS-MCM] TraceEvent OnConfigInit: Done")
EndEvent

Event OnVersionUpdate(Int iNewVersion)
   Debug.Trace("[DFWS-MCM] TraceEvent OnVersionUpdate")

   If (_bInitBegun)
      Debug.Trace("[DFWS-MCM] TraceEvent OnVersionUpdate: Done (Init Begun)")
      Return
   EndIf

   _bInitBegun = True
   UpdateScript()
   Debug.Trace("[DFWS-MCM] TraceEvent OnVersionUpdate: Done")
EndEvent


;***********************************************************************************************
;***                                  PRIVATE FUNCTIONS                                      ***
;***********************************************************************************************
String Function LeashGameStyleToString(Int iValue)
   If (0 == iValue)
      Return "Off"
   ElseIf (1 == iValue)
      Return "Auto"
   ElseIf (2 == iValue)
      Return "Protected"
   ElseIf (3 == iValue)
      Return "Dialogue"
   EndIf
EndFunction

String Function GagModeToString(Int iValue)
   If (0 == iValue)
      Return "No Gag"
   ElseIf (1 == iValue)
      Return "Regular"
   ElseIf (2 == iValue)
      Return "Auto Remove"
   EndIf
EndFunction

String Function ChanceForAssistanceToString(Int iValue)
   If (25 == iValue)
      Return "Low"
   ElseIf (50 == iValue)
      Return "Mid"
   ElseIf (75 == iValue)
      Return "High"
   EndIf
EndFunction

Bool Function IsSecure()
   ; If the security setting is set to 100 don't lock the settings at all.
   If (100 == _iSecurityLevel)
      Return False
   EndIf

   ; If the hardcore flag is set the menus should be secure.
   If (_bSecureHardcore)
      Return True
   EndIf

   ; If the player is vulnerable the menus should be secure.
   Int iVulnerability = _qFramework.GetVulnerability()
   If (iVulnerability > _iSecurityLevel)
      Return True
   EndIf

   ; If the player has a Master the menus should be secure.
   If (_qFramework.GetMaster())
      Return True
   EndIf

   ; Otherwise the menus are secure if the player is bound.
   Return _qFramework.IsPlayerBound(True)
EndFunction

Function SendSettingChangedEvent(String sCategory="")
   Int iModEvent = ModEvent.Create("DFWS_MCM_Changed")
   ModEvent.PushString(iModEvent, sCategory)
   ModEvent.Send(iModEvent)
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

   ; For now there is only one page, "DFW Support"
   If ("Leash Game" == szPage)
      DisplayLeashGamePage(bSecure)
   ElseIf ("BDSM Furniture" == szPage)
      DisplayBdsmFurniturePage(bSecure)
   ElseIf ("Events and Weights" == szPage)
      DisplayEventsPage(bSecure)
   ElseIf ("Logging + Debug" == szPage)
      DisplayDebugPage(bSecure)
   Else
      ; Load this page if nothing else is set.  Initial page and "DFW Support".
      DisplayDfwSupportPage(bSecure)
   EndIf
EndEvent

Function DisplayDfwSupportPage(Bool bSecure)
   Int iFlags = OPTION_FLAG_NONE
   If (bSecure)
      iFlags = OPTION_FLAG_DISABLED
   EndIf

   AddSliderOptionST("ST_FWK_SECURE",          "Security Level",        _iSecurityLevel, a_flags=iFlags)
   AddToggleOptionST("ST_FWK_HARDCORE",        "...Hardcore (Caution)", _bSecureHardcore, a_flags=iFlags)
   AddToggleOptionST("ST_FWK_SECURE_LEASH",    "Secure SD+ Leash",      _bSecureSdPlusLeash, a_flags=iFlags)

   AddEmptyOption()
   AddSliderOptionST("ST_FWK_POLL_TIME",       "Poll Time",             fPollTime, "{1} s")
   AddSliderOptionST("ST_MOD_BLOCK_TRAVEL",    "Block Travel",          iBlockTravel, a_flags=iFlags)

   AddEmptyOption()
   AddToggleOptionST("ST_FWK_SEX_DISPOSITION", "Sex Dispositions",      bSexDispositions)

   ; Start on the second column.
   SetCursorPosition(1)

   AddTextOption("DFW Support Version", _qDfwSupport.GetModVersion(), a_flags=OPTION_FLAG_DISABLED)

   AddEmptyOption()
   AddHeaderOption("Mod Compatibility")
   AddToggleOptionST("ST_MOD_ZAZ_EVENTS", "Catch ZAZ Events",           bCatchZazEvents, a_flags=iFlags)
   AddToggleOptionST("ST_MOD_SDP_EVENTS", "Catch SD+ Enslavement",      bCatchSdPlus, a_flags=iFlags)

   ; For now always allow the SD+ leash to be disabled as it can have pretty significant consequences.
   Int iSdLeashFlags = OPTION_FLAG_NONE
   If (_bSecureSdPlusLeash)
      iSdLeashFlags = OPTION_FLAG_DISABLED
   EndIf
   AddToggleOptionST("ST_MOD_SDP_LEASH",  "Start SD+ Leash",            bLeashSdPlus, a_flags=iSdLeashFlags)
   AddTextOptionST("ST_MOD_GAG_MODE",     "Gag Mode:", GagModeToString(iGagMode), a_flags=iFlags)

   ; Make sure the poll function is updating as expected.
   Float fDelta = Utility.GetCurrentRealTime() - _qDfwSupport.GetLastUpdateTime()
   If ((fPollTime * 3) < fDelta)
      AddEmptyOption()
      AddTextOption("Warning: Poll May Have Stopped!", "", a_flags=OPTION_FLAG_DISABLED)
      AddTextOption("Seconds Since Update", (fDelta As Int), a_flags=OPTION_FLAG_DISABLED)
   EndIf
EndFunction

Function DisplayLeashGamePage(Bool bSecure)
   Int iFlags = OPTION_FLAG_NONE
   If (bSecure)
      iFlags = OPTION_FLAG_DISABLED
   EndIf

   AddHeaderOption("Starting the Leash Game")
   AddSliderOptionST("ST_LGM_LEASH_GAME",     "Leash Game Chance",            fLeashGameChance, "{1}%", a_flags=iFlags)
   AddSliderOptionST("ST_LGM_INC_VULNERABLE", "Increase When Vulnerable",     iIncreaseWhenVulnerable, a_flags=iFlags)
   AddSliderOptionST("ST_LGM_DISTANCE",       "Maximum Distance",             iMaxDistance, a_flags=iFlags)
   AddToggleOptionST("ST_LGM_INCLUD_OWNERS",  "Include Owners",               bIncludeOwners, a_flags=iFlags)

   AddEmptyOption()
   AddHeaderOption("Ending the Leash Game")
   AddSliderOptionST("ST_LGM_DURATION_MIN",   "Minimum Duration",             iDurationMin, a_flags=iFlags)
   AddSliderOptionST("ST_LGM_DURATION_MAX",   "Maximum Duration",             iDurationMax, a_flags=iFlags)
   AddSliderOptionST("ST_LGM_CHANCE_RELEASE", "Chance of Release",            iChanceOfRelease, a_flags=iFlags)
   AddSliderOptionST("ST_LGM_RELEASE_DOM",    "Dominance Affects Release",    iDominanceAffectsRelease, a_flags=iFlags)
   AddSliderOptionST("ST_LGM_RELEASE_ANGER",  "Maximum Anger for Release",    iMaxAngerForRelease, a_flags=iFlags)
   AddSliderOptionST("ST_LGM_CHANCE_XFER",    "Chance of Furniture Transfer", iChanceFurnitureTransfer, a_flags=iFlags)
   AddSliderOptionST("ST_LGM_CHANCE_SIMPLE",  "Chance of Simple Slavery",     iLeashChanceSimple, a_flags=iFlags)
   AddToggleOptionST("ST_LGM_WALK_TO_SS",     "Walk to SS Auction",           bWalkToSsAuction)
   AddToggleOptionST("ST_LGM_WALK_FAR_SS",    "Allow Travel",                 bWalkFarSsAuction)
   AddHeaderOption("Cool Down")
   AddSliderOptionST("ST_LGM_COOL_AMOUNT",    "Cool Down Reduction",          iLeashCoolDownAmount, "{0}%",      a_flags=iFlags)
   AddSliderOptionST("ST_LGM_COOL_TIME",      "Cool Down Duration",           iLeashCoolDownTime,   "{0} Hours", a_flags=iFlags)

   AddEmptyOption()
   AddHeaderOption("Walking Break")
   AddToggleOptionST("ST_LGM_BREAK_ENABLE",       "Enable Walking Break", bWalkBreakEnabled,                  a_flags=iFlags)
   AddSliderOptionST("ST_LGM_BREAK_MIN_DELAY",    "Minimum Time Until Break", fWalkBreakMinTime,     "{1} Hours", a_flags=iFlags)
   AddSliderOptionST("ST_LGM_BREAK_MAX_DELAY",    "Maximum Time Until Break", fWalkBreakMaxTime,     "{1} Hours", a_flags=iFlags)
   AddSliderOptionST("ST_LGM_BREAK_MIN_DURATION", "Minimum Break Duration",   fWalkBreakMinDuration, "{1} Hours", a_flags=iFlags)
   AddSliderOptionST("ST_LGM_BREAK_MAX_DURATION", "Maximum Break Duration",   fWalkBreakMaxDuration, "{1} Hours", a_flags=iFlags)

   ; Start on the second column.
   SetCursorPosition(1)

   AddTextOptionST("ST_LGM_STYLE",            "Leash Game Style:", LeashGameStyleToString(iLeashGameStyle), a_flags=iFlags)
   ; The following options are only valid if the leash game style is Protected (2).
   Int iDelayFlags = iFlags
   If (2 != iLeashGameStyle)
      iDelayFlags = OPTION_FLAG_DISABLED
   EndIf
   AddSliderOptionST("ST_LGM_CHANCE_NOTICE",  "Chance To Notice",  iLeashChanceToNotice, "{0}%", a_flags=iDelayFlags)
   AddSliderOptionST("ST_LGM_PROT_DELAY",     "Protected Delay",   iLeashProtectedDelay, "{0}ms", a_flags=iDelayFlags)

   String szActive = "Not On"
   If (_qDfwSupport.IsGameOn())
      szActive = "Active"
   EndIf
   AddTextOption("Leash Game", szActive, a_flags=OPTION_FLAG_DISABLED)

   Actor aNearest = _qFramework.GetNearestActor()
   If ((!_qDfwSupport.IsGameOn()) && aNearest)
      AddTextOptionST("ST_LEASH_TO", "Start Leash Game:", aNearest.GetDisplayName())
   EndIf

   AddEmptyOption()
   AddHeaderOption("Options")
   AddSliderOptionST("ST_LGM_LEASH_LENGTH",   "Leash Length",                 iLeashLength, a_flags=iFlags)
   AddSliderOptionST("ST_LGM_LEASH_RESIST",   "Chance to Resist",             iLeashResist, a_flags=iFlags)
   AddToggleOptionST("ST_LGM_BLOCK_HELPLESS", "Block Deviously Helpless",     bBlockHelpless, a_flags=iFlags)
   AddToggleOptionST("ST_LGM_ALLOW_SEX",      "Allow Sex",                    bAllowSex, a_flags=iFlags)
   AddSliderOptionST("ST_LGM_CHANCE_IDLE",    "Chance of Idle Restraints",    iChanceIdleRestraints, a_flags=iFlags)
   AddTextOptionST("ST_LGM_CHANCE_ASSIST",    "Chance for Assistance",        ChanceForAssistanceToString(iChanceForAssistance), a_flags=iFlags)
   AddSliderOptionST("ST_LGM_NOTICE_ESCAPE",  "Chance to Notice Escape",      iEscapeDetection, a_flags=iFlags)
EndFunction

Function DisplayBdsmFurniturePage(Bool bSecure)
   Int iFlags = OPTION_FLAG_NONE
   If (bSecure)
      iFlags = OPTION_FLAG_DISABLED
   EndIf

   AddHeaderOption("Furniture for Fun")
   AddSliderOptionST("ST_BDSMF_LOCK",     "Chance of Locking",  fFurnitureLockChance,     "{1}%", a_flags=iFlags)
   AddSliderOptionST("ST_BDSMF_RELEASE",  "Chance of Release",  fFurnitureReleaseChance,  "{1}%", a_flags=iFlags)
   AddSliderOptionST("ST_BDSMF_TEASE",    "Teasing Chance",     iFurnitureTeaseChance,    a_flags=iFlags)
   AddSliderOptionST("ST_BDSMF_ALT",      "Alternate Release",  iFurnitureAltRelease,     a_flags=iFlags)
   AddSliderOptionST("ST_BDSMF_VISITOR",  "Chance of Visitors", fFurnitureVisitorChance,  "{1}%", a_flags=iFlags)
   AddSliderOptionST("ST_BDSMF_TRANSFER", "Chance of Transfer", iFurnitureTransferChance, "{0}%", a_flags=iFlags)

   AddEmptyOption()
   AddHeaderOption("Remote Furniture")
   AddSliderOptionST("ST_BDSMFR_VISITOR", "Chance of Visitors", fFurnitureRemoteVisitor,  "{1}%", a_flags=iFlags)
   AddSliderOptionST("ST_BDSMFR_SANDBOX", "Chance to Linger",   iFurnitureRemoteSandbox,  "{0}%", a_flags=iFlags)

   AddEmptyOption()
   AddHeaderOption("Options")
   AddSliderOptionST("ST_BDSMF_MIN_TIME", "Initial Lock Time",         iFurnitureMinLockTime, a_flags=iFlags)
   AddToggleOptionST("ST_BDSMF_HIDE",     "Hide Furniture During Sex", bFurnitureHide)
   AddSliderOptionST("ST_BDSMF_POST_SEX", "Post Sex Monitoring",       iModPostSexMonitor, "{0} s", a_flags=iFlags)


   ; Start on the second column.
   SetCursorPosition(1)
   AddHeaderOption("Favourites")
   ObjectReference oCurrFurniture = _qFramework.GetBdsmFurniture()
   If (oCurrFurniture)
      AddTextOptionST("ST_BDSMF_FAV",     "Add Favourite:",     oCurrFurniture.GetDisplayName())
   EndIf
   AddToggleOptionST("ST_BDSMF_AUTO_FAV", "Auto Add Favourite", bAutoAddFurniture, a_flags=iFlags)
   AddMenuOptionST("ST_BDSMF_SHOW_LIST",  "Remove/View Favourite Furniture", "Open")

   AddEmptyOption()
   AddHeaderOption("Cages")
   ObjectReference oTarget = Game.GetCurrentCrosshairRef()
   String szCageName = "Target Door"
   String szLeverName = "Target Lever"
   If (oTarget)
      szCageName = oTarget.GetDisplayName()
      szLeverName = szCageName
   EndIf
   AddTextOptionST("ST_CAGE_FAV",         "Add Cage",     szCageName)
   If (_oSelectedFurniture)
      AddTextOptionST("ST_CAGE_LOC",      "Set Location", "Stand In Cage")
      If (oTarget != _oSelectedFurniture)
         AddTextOptionST("ST_CAGE_LEVER", "Set Lever",    szLeverName)
      EndIf
   EndIf

   AddEmptyOption()
   AddHeaderOption("Work Furniture")
   String szFurnitureName = "Target Furniture"
   If (oTarget)
      szFurnitureName = oTarget.GetDisplayName()
   EndIf
   AddTextOptionST("ST_WORKF_FAV", "Add Work Furniture", szFurnitureName)

   AddEmptyOption()
   AddMenuOptionST("ST_BDSMF_SELECT",   "Select Furniture", "Select")
   String szSelectedFurniture = "None"
   If (_oSelectedFurniture)
      szSelectedFurniture = _oSelectedFurniture.GetDisplayName()
      If (!szSelectedFurniture)
         szSelectedFurniture = _oSelectedFurniture.GetName()
      EndIf
   EndIf
   AddTextOptionST("ST_BDSMF_SELECTED", "Selected:",        szSelectedFurniture, a_flags=OPTION_FLAG_DISABLED)
   Int iCurrFlags
   If (_oSelectedFurniture)
      iCurrFlags = _qDfwSupport.ToggleFurnitureFlag(_oSelectedFurniture, 0x0000)
   EndIf
   AddTextOptionST("ST_BDSMF_VIEW_FLAGS",  "Current Flags: ", "0x" + _qDfwUtil.ConvertHexToString(iCurrFlags, 4), a_flags=OPTION_FLAG_DISABLED)
   AddMenuOptionST("ST_BDSMF_TOGGLE_FLAG", "Toggle Flag",     "Choose Flag")
EndFunction

Function DisplayEventsPage(Bool bSecure)
   Int iFlags = OPTION_FLAG_NONE
   If (bSecure)
      iFlags = OPTION_FLAG_DISABLED
   EndIf

   AddHeaderOption("Leash Game Events:")
   AddSliderOptionST("ST_EVENT_SELL_ITEMS",     "Sell Items",              fEventSellItems,     "{1}%", a_flags=iFlags)
   AddSliderOptionST("ST_EVENT_REM_RESTRAINTS", "Remove Restraints",       fEventRemRestraints, "{1}%")
   AddSliderOptionST("ST_EVENT_PROPOSITION",    "Chance to Proposition",   fEventProposition,   "{1}%", a_flags=iFlags)
   AddSliderOptionST("ST_EVENT_PROP_AROUSAL",   "Proposition Min Arousal", iEventPropArousal, a_flags=iFlags)
   AddSliderOptionST("ST_EVENT_PERMANENCY",     "Permanency",              fEventPermanency,    "{1}%", a_flags=iFlags)
   AddSliderOptionST("ST_EVENT_MILK_CHANCE",    "Milking Scene Chance",    fEventMilkScene,     "{1}%")
   AddSliderOptionST("ST_EVENT_MILK_MIN",       "Minimum Milk Threashold", fEventMilkThreshold, "Milk {1}")
   AddSliderOptionST("ST_EVENT_EQUIP_SLAVER",   "Equip Slaver",            fEventEquipSlaver,   "{1}%", a_flags=iFlags)

   AddEmptyOption()
   AddHeaderOption("Punishment Weights:")
   AddSliderOptionST("ST_WEIGHT_PUNISH_BASIC", "Weight Basic",     iWeightPunishBasic, a_flags=iFlags)
   AddSliderOptionST("ST_WEIGHT_PUNISH_FURN",  "Weight Furniture", iWeightPunishFurn,  a_flags=iFlags)
   AddSliderOptionST("ST_WEIGHT_PUNISH_CRAWL", "Weight Crawling",  iWeightPunishCrawl, a_flags=iFlags)
   AddSliderOptionST("ST_WEIGHT_PUNISH_BLIND", "Chance Blindfold", iChancePunishBlindfold, "{0}%", a_flags=iFlags)

   ; Start on the second column.
   SetCursorPosition(1)

   AddHeaderOption("Furniture Weight (Leash Game End):")
   AddSliderOptionST("ST_WEIGHT_FTAG_TRANS_DEFAULT", "Default",        iFWeightTransferDefault, a_flags=iFlags)
   AddSliderOptionST("ST_WEIGHT_FTAG_TRANS_FURN",    "BDSM Furniture", iFWeightTransferFurn,    a_flags=iFlags)
   AddSliderOptionST("ST_WEIGHT_FTAG_TRANS_CAGE",    "Cage",           iFWeightTransferCage,    a_flags=iFlags)
   AddSliderOptionST("ST_WEIGHT_FTAG_TRANS_BED",     "Bed",            iFWeightTransferBed,     a_flags=iFlags)
   AddSliderOptionST("ST_WEIGHT_FTAG_TRANS_STORE",   "Store",          iFWeightTransferStore,   a_flags=iFlags)
   AddSliderOptionST("ST_WEIGHT_FTAG_TRANS_PUBLIC",  "Public",         iFWeightTransferPublic,  a_flags=iFlags)
   AddSliderOptionST("ST_WEIGHT_FTAG_TRANS_PRIVATE", "Private",        iFWeightTransferPrivate, a_flags=iFlags)
   AddSliderOptionST("ST_WEIGHT_FTAG_TRANS_REMOTE",  "Remote",         iFWeightTransferRemote,  a_flags=iFlags)

   AddEmptyOption()
   AddHeaderOption("Furniture Weight (Punishment):")
   AddSliderOptionST("ST_WEIGHT_FTAG_PUNISH_DEFAULT",  "Default",         iFWeightPunishDefault, a_flags=iFlags)
   AddSliderOptionST("ST_WEIGHT_FTAG_PUNISH_FURN",     "BDSM Furniture",  iFWeightPunishFurn,    a_flags=iFlags)
   AddSliderOptionST("ST_WEIGHT_FTAG_PUNISH_CAGE",     "Cage",            iFWeightPunishCage,    a_flags=iFlags)
   AddSliderOptionST("ST_WEIGHT_FTAG_PUNISH_BED",      "Bed",             iFWeightPunishBed,     a_flags=iFlags)
   AddSliderOptionST("ST_WEIGHT_FTAG_PUNISH_STORE",    "Store",           iFWeightPunishStore,   a_flags=iFlags)
   AddSliderOptionST("ST_WEIGHT_FTAG_PUNISH_PUBLIC",   "Public",          iFWeightPunishPublic,  a_flags=iFlags)
   AddSliderOptionST("ST_WEIGHT_FTAG_PUNISH_PRIVATE",  "Private",         iFWeightPunishPrivate, a_flags=iFlags)
   AddSliderOptionST("ST_WEIGHT_FTAG_PUNISH_REMOTE",   "Remote",          iFWeightPunishRemote,  a_flags=iFlags)
   AddSliderOptionST("ST_PUNISH_MIN_BEHAVIOUR_REMOTE", "Min Time Remote", iPunishMinBehaviourRemote, a_flags=iFlags)
EndFunction

Function DisplayDebugPage(Bool bSecure)
   Int iFlags = OPTION_FLAG_NONE
   If (bSecure)
      iFlags = OPTION_FLAG_DISABLED
   EndIf

   AddSliderOptionST("ST_DBG_LEVEL",    "Log Level",        iLogLevel)
   AddSliderOptionST("ST_DBG_SCREEN",   "Log Level Screen", iLogLevelScreen)

   ; Start on the second column.
   SetCursorPosition(1)

   Int iShutdownFlags = OPTION_FLAG_NONE
   If (bShutdownSecure)
      iShutdownFlags = iFlags
   EndIf
   AddToggleOptionST("ST_DBG_SHUTDOWN",      "Shutdown Mod",            bShutdownMod, a_flags=iShutdownFlags)
   AddToggleOptionST("ST_DBG_SHUTDOWN_SEC",  "...Make Shutdown Secure", bShutdownSecure, a_flags=iShutdownFlags)

   AddEmptyOption()
   AddTextOptionST("ST_DBG_MCM_UPGRADE",     "Force MCM Upgrade",    "Upgrade Now")
   AddTextOptionST("ST_DBG_DUMP_VARS",       "Dump Quest Variables", "Dump Now")
   AddTextOptionST("ST_DBG_MOD_EVENTS",      "Fix Mod Events",       "Fix Now")
   AddTextOptionST("ST_DBG_FIX_MUTEXES",     "Fix Mutexes",          "Fix Now")

   AddEmptyOption()
   AddHeaderOption("Utility Key:")
   AddKeyMapOptionST("ST_DBG_UTIL_KEY",         "Utility Key",          iDbgUtilKey)
   AddToggleOptionST("ST_DBG_CYCLE_PACKAGE",    "Cycle Slaver Package", bHotkeyPackage)
   AddToggleOptionST("ST_DBG_CYCLE_MULTI_POSE", "Multi Furniture Pose", bHotkeyMultiPose)
EndFunction


;***********************************************************************************************
;***                                        STATES                                           ***
;***********************************************************************************************
State ST_FWK_SECURE
   Event OnSliderOpenST()
      SetSliderDialogStartValue(_iSecurityLevel)
      SetSliderDialogDefaultValue(_qDfwMcm.iVulnerabilityNight)
      SetSliderDialogRange(1, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      _iSecurityLevel = (fValue As Int)
      SetSliderOptionValueST(_iSecurityLevel)
   EndEvent

   Event OnDefaultST()
      _iSecurityLevel = _qDfwMcm.iVulnerabilityNight
      SetSliderOptionValueST(_iSecurityLevel)
   EndEvent

   Event OnHighlightST()
      SetInfoText("This is the maximum vulnerability the player can be at and still change the settings.\n" +\
                  "Recommend: " + _qDfwMcm.iVulnerabilityNight + " so you can change settings at night.\n" +\
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
                  "Caution: Once set it can't be turned off.")
   EndEvent
EndState

State ST_FWK_SECURE_LEASH
   Event OnSelectST()
      _bSecureSdPlusLeash = !_bSecureSdPlusLeash
      SetToggleOptionValueST(_bSecureSdPlusLeash)
   EndEvent

   Event OnDefaultST()
      _bSecureSdPlusLeash = False
      SetToggleOptionValueST(_bSecureSdPlusLeash)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Locks the SD+ leash setting so it cannot be changed when vulnerable.\n" +\
                  "Caution: Being stuck in an SD+ leash can break the game.  Don't make this secure until\n" +\
                  "you have thoroughly tested the leash behaviour with SD+.  And keep a save!")
   EndEvent
EndState

State ST_FWK_POLL_TIME
   Event OnSliderOpenST()
      SetSliderDialogStartValue(fPollTime)
      SetSliderDialogDefaultValue(3.0)
      SetSliderDialogRange(1, 10)
      SetSliderDialogInterval(0.5)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      If (fPollTime != fValue)
         _qDfwSupport.UpdatePollingInterval(fValue)
      EndIf
      fPollTime = fValue
      SetSliderOptionValueST(fPollTime, "{1} s")

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Mod")
   EndEvent

   Event OnDefaultST()
      fPollTime = 3.0
      SetSliderOptionValueST(fPollTime, "{1} s")

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Mod")
   EndEvent

   Event OnHighlightST()
      SetInfoText("How frequently the mod should check for work to be done.")
   EndEvent
EndState

State ST_MOD_BLOCK_TRAVEL
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iBlockTravel)
      SetSliderDialogDefaultValue(1)
      SetSliderDialogRange(0, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iBlockTravel = (fValue As Int)
      SetSliderOptionValueST(iBlockTravel)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Mod")
   EndEvent

   Event OnDefaultST()
      iBlockTravel = 1
      SetSliderOptionValueST(iBlockTravel)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Mod")
   EndEvent

   Event OnHighlightST()
      SetInfoText("Block fast travel when at least this vulnerable.\n" +\
                  "0 = Always block.  1 = Always block when vulnerable.  100 = Never block.")
   EndEvent
EndState

State ST_FWK_SEX_DISPOSITION
   Event OnSelectST()
      bSexDispositions = !bSexDispositions
      SetToggleOptionValueST(bSexDispositions)
   EndEvent

   Event OnDefaultST()
      bSexDispositions = True
      SetToggleOptionValueST(bSexDispositions)
   EndEvent

   Event OnHighlightST()
      SetInfoText("When enabled sex events involving the player increase the DFW interest of the actors.\n" +\
                  "Depending on the situation the NPC's dominance value may increase as well.")
   EndEvent
EndState

State ST_MOD_ZAZ_EVENTS
   Event OnSelectST()
      bCatchZazEvents = !bCatchZazEvents
      SetToggleOptionValueST(bCatchZazEvents)
   EndEvent

   Event OnDefaultST()
      bCatchZazEvents = True
      SetToggleOptionValueST(bCatchZazEvents)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Catch any ZAZ Enslave/Free events realted to the player and update the\n" +\
                  "Devious Framework Master information accordingly.")
   EndEvent
EndState

State ST_MOD_SDP_EVENTS
   Event OnSelectST()
      bCatchSdPlus = !bCatchSdPlus
      SetToggleOptionValueST(bCatchSdPlus)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Compatibility")
   EndEvent

   Event OnDefaultST()
      bCatchSdPlus = False
      SetToggleOptionValueST(bCatchSdPlus)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Compatibility")
   EndEvent

   Event OnHighlightST()
      SetInfoText("Detect when the player becomes enslaved via the Sanguine Debaucherty Plus mod\n" +\
                  "and register the Master with the Devious Framework mod.")
   EndEvent
EndState

State ST_MOD_SDP_LEASH
   Event OnSelectST()
      bLeashSdPlus = !bLeashSdPlus
      ; Call the Support Mod function to update the the leash state in case it is active.
      _qDfwSupport.UpdateSdPlusLeashState(bLeashSdPlus)
      SetToggleOptionValueST(bLeashSdPlus)
   EndEvent

   Event OnDefaultST()
      bLeashSdPlus = False
      ; Call the Support Mod function to update the the leash state in case it is active.
      _qDfwSupport.UpdateSdPlusLeashState(bLeashSdPlus)
      SetToggleOptionValueST(bLeashSdPlus)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Also start a DFW leash between the Sanguine Debauchery Master and the player when enslaved\n" +\
                  "and clear the leash when the player is released.\n" +\
                  "Note: This option is only disabled when \"Hardcore\" security is set.")
   EndEvent
EndState

State ST_MOD_GAG_MODE
   Event OnSelectST()
      iGagMode += 1
      If (2 < iGagMode)
         iGagMode = 0
      EndIf
      SetTextOptionValueST(GagModeToString(iGagMode))

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Compatibility")
   EndEvent

   Event OnDefaultST()
      iGagMode = 1
      SetTextOptionValueST(GagModeToString(iGagMode))

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Compatibility")
   EndEvent

   Event OnHighlightST()
      SetInfoText("Special behaviour for gags, intended for compatibility with Maria Eden where the player cannot speak.\n" +\
                  "\"No Gag\": Never gag the player.  \"Regular\": Apply the gag and remove it based on mod decisions.\n" +\
                  "\"Auto Remove\": Start a timer based on the player's behaviour remove the gag when the timer expires.")
   EndEvent
EndState


;***********************************************************************************************
;***                                  STATES: LEASH GAME                                     ***
;***********************************************************************************************
State ST_LGM_STYLE
   Event OnSelectST()
      iLeashGameStyle += 1
      If (3 < iLeashGameStyle)
         iLeashGameStyle = 0
      EndIf
      If (3 == iLeashGameStyle)
         ShowMessage("Dialogue Not Yet Supported.", False)
      EndIf
      SetTextOptionValueST(LeashGameStyleToString(iLeashGameStyle))

      ; Enable/Disable other options only available for specific leash game styles.
      If (2 != iLeashGameStyle)
         SetOptionFlagsST(OPTION_FLAG_DISABLED, a_stateName="ST_LGM_CHANCE_NOTICE")
         SetOptionFlagsST(OPTION_FLAG_DISABLED, a_stateName="ST_LGM_PROT_DELAY")
      Else
         SetOptionFlagsST(OPTION_FLAG_NONE, a_stateName="ST_LGM_CHANCE_NOTICE")
         SetOptionFlagsST(OPTION_FLAG_NONE, a_stateName="ST_LGM_PROT_DELAY")
      EndIf

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Leash")
   EndEvent

   Event OnDefaultST()
      iLeashGameStyle = 2
      SetTextOptionValueST(LeashGameStyleToString(iLeashGameStyle))

      ; Enable/Disable other options only available for specific leash game styles.
      SetOptionFlagsST(OPTION_FLAG_NONE, a_stateName="ST_LGM_CHANCE_NOTICE")
      SetOptionFlagsST(OPTION_FLAG_NONE, a_stateName="ST_LGM_PROT_DELAY")

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Leash")
   EndEvent

   Event OnHighlightST()
      SetInfoText("How the leash game starts.  \"Off\": Do not play.  \"Auto\": The slaver will simply lasso you.\n" +\
                  "\"Protected\": The slaver will approach you from behind.  Facing him or drawing weapons protects you.\n" +\
                  "\"Dialogue\": Not supported yet.")
   EndEvent
EndState

State ST_LGM_CHANCE_NOTICE
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iLeashChanceToNotice)
      SetSliderDialogDefaultValue(95)
      SetSliderDialogRange(0, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iLeashChanceToNotice = (fValue As Int)
      SetSliderOptionValueST(iLeashChanceToNotice, "{0}%")
   EndEvent

   Event OnDefaultST()
      iLeashChanceToNotice = 95
      SetSliderOptionValueST(iLeashChanceToNotice, "{0}%")
   EndEvent

   Event OnHighlightST()
      SetInfoText("The chance for you to notice when the slaver is aproaching you suspiciously.")
   EndEvent
EndState

State ST_LGM_PROT_DELAY
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iLeashProtectedDelay)
      SetSliderDialogDefaultValue(0)
      SetSliderDialogRange(0, 3000)
      SetSliderDialogInterval(100)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iLeashProtectedDelay = (fValue As Int)
      SetSliderOptionValueST(iLeashProtectedDelay, "{0}ms")
   EndEvent

   Event OnDefaultST()
      iLeashProtectedDelay = 0
      SetSliderOptionValueST(iLeashProtectedDelay, "{0}ms")
   EndEvent

   Event OnHighlightST()
      SetInfoText("Add a delay while starting a protected leash game making it easier to defend against.")
   EndEvent
EndState

State ST_LGM_LEASH_GAME
   Event OnSliderOpenST()
      SetSliderDialogStartValue(fLeashGameChance)
      SetSliderDialogDefaultValue(3.0)
      If (10 <= fLeashGameChance)
         SetSliderDialogRange(0, 100)
         SetSliderDialogInterval(1)
      Else
         SetSliderDialogRange(0, 10)
         SetSliderDialogInterval(0.1)
      EndIf
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      fLeashGameChance = fValue
      SetSliderOptionValueST(fLeashGameChance, "{1}%")

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Leash")
   EndEvent

   Event OnDefaultST()
      fLeashGameChance = 3.0
      SetSliderOptionValueST(fLeashGameChance, "{1}%")

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Leash")
   EndEvent

   Event OnHighlightST()
      SetInfoText("A rudamentary leash game.  When you encounter slavers they may drag you around for a time.\n" +\
                  "Requires \"slave traders\".  Currently only Slave Girls by hydragorgon slavers are tested.\n" +\
                  "Does not trigger if you have a nearby Master.")
   EndEvent
EndState

State ST_LGM_INC_VULNERABLE
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iIncreaseWhenVulnerable)
      SetSliderDialogDefaultValue(10)
      SetSliderDialogRange(0, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iIncreaseWhenVulnerable = (fValue As Int)
      SetSliderOptionValueST(iIncreaseWhenVulnerable)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Leash")
   EndEvent

   Event OnDefaultST()
      iIncreaseWhenVulnerable = 10
      SetSliderOptionValueST(iIncreaseWhenVulnerable)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Leash")
   EndEvent

   Event OnHighlightST()
      SetInfoText("The amout to increase chances of playing the leash game when vulnerable.\n" +\
                  "Current chances + (This chance * Vulnerability / 100)")
   EndEvent
EndState

State ST_LGM_DISTANCE
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iMaxDistance)
      SetSliderDialogDefaultValue(2000)
      SetSliderDialogRange(0, 5000)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iMaxDistance = (fValue As Int)
      SetSliderOptionValueST(iMaxDistance)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Leash")
   EndEvent

   Event OnDefaultST()
      iMaxDistance = 2000
      SetSliderOptionValueST(iMaxDistance)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Leash")
   EndEvent

   Event OnHighlightST()
      SetInfoText("The maximum distance the slaver can be from the player to start the leash game.\n" +\
                  "Set to 0 to search all actors in the DFW nearby actor list.\n" +\
                  "This would limit the range to the range of the DFW nearby actor scan.")
   EndEvent
EndState

State ST_LGM_INCLUD_OWNERS
   Event OnSelectST()
      bIncludeOwners = !bIncludeOwners
      SetToggleOptionValueST(bIncludeOwners)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Leash")
   EndEvent

   Event OnDefaultST()
      bIncludeOwners = False
      SetToggleOptionValueST(bIncludeOwners)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Leash")
   EndEvent

   Event OnHighlightST()
      SetInfoText("Typically the leash game will only be triggered by nearby slave traders.\n" +\
                  "With this option set nearby slave owners will also trigger the game.")
   EndEvent
EndState

State ST_LGM_LEASH_LENGTH
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iLeashLength)
      SetSliderDialogDefaultValue(700)
      SetSliderDialogRange(100, 1200)
      SetSliderDialogInterval(10)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iLeashLength = (fValue As Int)
      SetSliderOptionValueST(iLeashLength)
   EndEvent

   Event OnDefaultST()
      iLeashLength = 700
      SetSliderOptionValueST(iLeashLength)
   EndEvent

   Event OnHighlightST()
      SetInfoText("The length of the player's leash.\n" +\
                  "Only set at the start of the leash game.\n" +\
                  "Warning: Many values are untested.  If unsure leave at the default value.")
   EndEvent
EndState

State ST_LGM_LEASH_RESIST
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iLeashResist)
      SetSliderDialogDefaultValue(3)
      SetSliderDialogRange(0, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iLeashResist = (fValue As Int)
      SetSliderOptionValueST(iLeashResist)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Leash")
   EndEvent

   Event OnDefaultST()
      iLeashResist = 3
      SetSliderOptionValueST(iLeashResist)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Leash")
   EndEvent

   Event OnHighlightST()
      SetInfoText("The % chance of resisting the leash when it is yanked.\n" +\
                  "Note: This only applies to the leash game.")
   EndEvent
EndState


State ST_LGM_BLOCK_HELPLESS
   Event OnSelectST()
      bBlockHelpless = !bBlockHelpless
      SetToggleOptionValueST(bBlockHelpless)
   EndEvent

   Event OnDefaultST()
      bBlockHelpless = False
      SetToggleOptionValueST(bBlockHelpless)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Block deviously helpless assaults while the leash game is playing?\n" +\
                  "Leave this off if the deviously helpless mod is not installed.")
   EndEvent
EndState

State ST_LGM_ALLOW_SEX
   Event OnSelectST()
      bAllowSex = !bAllowSex
      SetToggleOptionValueST(bAllowSex)
   EndEvent

   Event OnDefaultST()
      bAllowSex = False
      SetToggleOptionValueST(bAllowSex)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Allow sex from other mods while the leash game is in effect.\n" +\
                  "The slaver will stand around and wait whenever the player is engaged in sex.")
   EndEvent
EndState

State ST_LGM_DURATION_MIN
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iDurationMin)
      SetSliderDialogDefaultValue(5)
      SetSliderDialogRange(1, iDurationMax)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iDurationMin = (fValue As Int)
      SetSliderOptionValueST(iDurationMin)
   EndEvent

   Event OnDefaultST()
      iDurationMin = 5
      SetSliderOptionValueST(iDurationMin)
   EndEvent

   Event OnHighlightST()
      SetInfoText("The minimum length of time in real game minutes to play the leash game.\n" +\
                  "When the game is started a random time between min and max is selected for the game duration.")
   EndEvent
EndState

State ST_LGM_DURATION_MAX
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iDurationMax)
      SetSliderDialogDefaultValue(15)
      SetSliderDialogRange(iDurationMin, 600)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iDurationMax = (fValue As Int)
      SetSliderOptionValueST(iDurationMax)
   EndEvent

   Event OnDefaultST()
      iDurationMax = 15
      SetSliderOptionValueST(iDurationMax)
   EndEvent

   Event OnHighlightST()
      SetInfoText("The maximum length of time in real game minutes to play the leash game.\n" +\
                  "When the game is started a random time between min and max is selected for the game duration.\n" +\
                  "Note: The game can be played for longer if the player is not released (See below).")
   EndEvent
EndState

State ST_LGM_CHANCE_RELEASE
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iChanceOfRelease)
      SetSliderDialogDefaultValue(50)
      SetSliderDialogRange(0, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iChanceOfRelease = (fValue As Int)
      SetSliderOptionValueST(iChanceOfRelease)
   EndEvent

   Event OnDefaultST()
      iChanceOfRelease = 50
      SetSliderOptionValueST(iChanceOfRelease)
   EndEvent

   Event OnHighlightST()
      SetInfoText("The chance the player will be released at the end of the leash game.\n" +\
                  "If the player is not released the timer will restart with a random duration half as long.\n" +\
                  "Note: The slaver's DFW dominance value also affects the player's chance of release (See below).")
   EndEvent
EndState

State ST_LGM_RELEASE_DOM
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iDominanceAffectsRelease)
      SetSliderDialogDefaultValue(45)
      SetSliderDialogRange(0, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iDominanceAffectsRelease = (fValue As Int)
      SetSliderOptionValueST(iDominanceAffectsRelease)
   EndEvent

   Event OnDefaultST()
      iDominanceAffectsRelease = 45
      SetSliderOptionValueST(iDominanceAffectsRelease)
   EndEvent

   Event OnHighlightST()
      SetInfoText("The amount the slaver's dominance value affects the player's chance of release.\n" +\
                  "Total Chance of Release = Base Chance above - ((Slaver Dominance - 50) / 50 * This).\n" +\
                  "Warning: If this is more than the base chance the player will never be freed by a dominant slaver.")
   EndEvent
EndState

State ST_LGM_RELEASE_ANGER
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iMaxAngerForRelease)
      SetSliderDialogDefaultValue(50)
      SetSliderDialogRange(0, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iMaxAngerForRelease = (fValue As Int)
      SetSliderOptionValueST(iMaxAngerForRelease)
   EndEvent

   Event OnDefaultST()
      iMaxAngerForRelease = 50
      SetSliderOptionValueST(iMaxAngerForRelease)
   EndEvent

   Event OnHighlightST()
      SetInfoText("The maximum amount of DFW anger the slaver can have toward the player in order for him to release her.\n" +\
                  "If the slaver is more angry than this at the end of the game the game's release timer will be reset.\n" +\
                  "Warning: The slaver's anger can't naturally be reduced to zero so it is not recommended to set this low.")
   EndEvent
EndState

State ST_LGM_CHANCE_IDLE
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iChanceIdleRestraints)
      SetSliderDialogDefaultValue(10)
      SetSliderDialogRange(0, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iChanceIdleRestraints = (fValue As Int)
      SetSliderOptionValueST(iChanceIdleRestraints)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Leash")
   EndEvent

   Event OnDefaultST()
      iChanceIdleRestraints = 10
      SetSliderOptionValueST(iChanceIdleRestraints)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Leash")
   EndEvent

   Event OnHighlightST()
      SetInfoText("The chance the slaver will decorate the player as a slave once she is fully under control.\n" +\
                  "This does not affect when the slaver is initially trying to control the player or is angered or upset.\n" +\
                  "It only affects decorating the player once she is under control (collar, stripping, boots).")
   EndEvent
EndState

State ST_LGM_CHANCE_ASSIST
   Event OnSelectST()
      iChanceForAssistance += 25
      If (75 < iChanceForAssistance)
         iChanceForAssistance = 25
      EndIf
      SetTextOptionValueST(ChanceForAssistanceToString(iChanceForAssistance))

      ; This is needed by the dialogue system.  Update the conditional in the main script.
      SendSettingChangedEvent("Leash")
   EndEvent

   Event OnDefaultST()
      iChanceForAssistance = 75
      SetTextOptionValueST(ChanceForAssistanceToString(iChanceForAssistance))

      ; This is needed by the dialogue system.  Update the conditional in the main script.
      SendSettingChangedEvent("Leash")
   EndEvent

   Event OnHighlightST()
      SetInfoText("This can be used to adjust how likely it is NPCs will help you escape when asking for help.")
   EndEvent
EndState

State ST_LGM_NOTICE_ESCAPE
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iEscapeDetection)
      SetSliderDialogDefaultValue(10)
      SetSliderDialogRange(0, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iEscapeDetection = (fValue As Int)
      SetSliderOptionValueST(iEscapeDetection)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Leash")
   EndEvent

   Event OnDefaultST()
      iEscapeDetection = 10
      SetSliderOptionValueST(iEscapeDetection)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Leash")
   EndEvent

   Event OnHighlightST()
      SetInfoText("The % chance the slaver will notice you are trying to get help escaping when talking to others.\n" +\
                  "Note: The chances increase if you are close to the slaver and if he is looking at you.\n" +\
                  "Recommended: 10 - 30.")
   EndEvent
EndState

State ST_LGM_CHANCE_XFER
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iChanceFurnitureTransfer)
      SetSliderDialogDefaultValue(25)
      SetSliderDialogRange(0, (100 - iLeashChanceSimple))
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iChanceFurnitureTransfer = (fValue As Int)
      SetSliderOptionValueST(iChanceFurnitureTransfer)
   EndEvent

   Event OnDefaultST()
      iChanceFurnitureTransfer = 25
      SetSliderOptionValueST(iChanceFurnitureTransfer)
   EndEvent

   Event OnHighlightST()
      SetInfoText("As the leash game ends this is the chance the slaver will lock the player in nearby furniture\n" +\
                  "instead of simply releasing her.")
   EndEvent
EndState

State ST_LGM_CHANCE_SIMPLE
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iLeashChanceSimple)
      SetSliderDialogDefaultValue(10)
      SetSliderDialogRange(0, (100 - iChanceFurnitureTransfer))
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iLeashChanceSimple = (fValue As Int)
      SetSliderOptionValueST(iLeashChanceSimple)
   EndEvent

   Event OnDefaultST()
      iLeashChanceSimple = 10
      SetSliderOptionValueST(iLeashChanceSimple)
   EndEvent

   Event OnHighlightST()
      SetInfoText("As the leash game ends this is the chance the slaver will sell the player to the Simple Slavery auction\n" +\
                  "instead of simply releasing her.")
   EndEvent
EndState

State ST_LGM_WALK_TO_SS
   Event OnSelectST()
      bWalkToSsAuction = !bWalkToSsAuction
      SetToggleOptionValueST(bWalkToSsAuction)
   EndEvent

   Event OnDefaultST()
      bWalkToSsAuction = True
      SetToggleOptionValueST(bWalkToSsAuction)
   EndEvent

   Event OnHighlightST()
      SetInfoText("When transferring the player to a Simple Slavery auction the slavery will walk to the auction before\n" +\
                  "starting the Simple Slavery mod.  If disabled the normal blank screen transition will occur.\n" +\
                  "This will only occur if the player is in the same DFW region as a Simple Slavery auction house.")
   EndEvent
EndState

State ST_LGM_WALK_FAR_SS
   Event OnSelectST()
      bWalkFarSsAuction = !bWalkFarSsAuction
      SetToggleOptionValueST(bWalkFarSsAuction)
   EndEvent

   Event OnDefaultST()
      bWalkFarSsAuction = True
      SetToggleOptionValueST(bWalkFarSsAuction)
   EndEvent

   Event OnHighlightST()
      SetInfoText("When walking to Simple Slavery auctions the slaver will walk from nearby towns as well.\n" +\
                  "The slaver will walk to Riften from towns as far away as Riverwood and Windhelm.")
   EndEvent
EndState

State ST_LGM_COOL_AMOUNT
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iLeashCoolDownAmount)
      SetSliderDialogDefaultValue(6)
      SetSliderDialogRange(0, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iLeashCoolDownAmount = (fValue As Int)
      SetSliderOptionValueST(iLeashCoolDownAmount, "{0}%")
   EndEvent

   Event OnDefaultST()
      iLeashCoolDownAmount = 6
      SetSliderOptionValueST(iLeashCoolDownAmount, "{0}%")
   EndEvent

   Event OnHighlightST()
      SetInfoText("Once a leash game ends the chances of it starting again will be reduced by this %.\n" +\
                  "Over time (the duration) the chances will slowly (and evenly) return to normal.")
   EndEvent
EndState

State ST_LGM_COOL_TIME
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iLeashCoolDownTime)
      SetSliderDialogDefaultValue(24)
      SetSliderDialogRange(1, 96)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iLeashCoolDownTime = (fValue As Int)
      SetSliderOptionValueST(iLeashCoolDownTime, "{0} Hours")
   EndEvent

   Event OnDefaultST()
      iLeashCoolDownTime = 24
      SetSliderOptionValueST(iLeashCoolDownTime, "{0} Hours")
   EndEvent

   Event OnHighlightST()
      SetInfoText("Once a leash game ends the chances of it starting again will be reduced by a % (the amount).\n" +\
                  "Over this time (in game hours) the chances will slowly return to normal, at an even rate.")
   EndEvent
EndState

State ST_LGM_BREAK_ENABLE
   Event OnSelectST()
      bWalkBreakEnabled = !bWalkBreakEnabled
      SetToggleOptionValueST(bWalkBreakEnabled)
   EndEvent

   Event OnDefaultST()
      bWalkBreakEnabled = True
      SetToggleOptionValueST(bWalkBreakEnabled)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Sometimes slavers can walk forever during the leash game.  Turning this on tries\n" +\
                  "to force the slaver to take a break from walking every few hours when in town.")
   EndEvent
EndState

State ST_LGM_BREAK_MIN_DELAY
   Event OnSliderOpenST()
      SetSliderDialogStartValue(fWalkBreakMinTime)
      SetSliderDialogDefaultValue(3.0)
      SetSliderDialogRange(3.0, 24.0)
      SetSliderDialogInterval(0.5)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      fWalkBreakMinTime = fValue
      SetSliderOptionValueST(fWalkBreakMinTime, "{1} Hours")
   EndEvent

   Event OnDefaultST()
      fWalkBreakMinTime = 3.0
      SetSliderOptionValueST(fWalkBreakMinTime, "{1} Hours")
   EndEvent

   Event OnHighlightST()
      SetInfoText("When the slaver starts walking a random time is chosen between the minimum and maximum Time Until Break.\n" +\
                  "If the slaver continues to walk non-stop until that time and end up in a town he will take a break.")
   EndEvent
EndState

State ST_LGM_BREAK_MAX_DELAY
   Event OnSliderOpenST()
      SetSliderDialogStartValue(fWalkBreakMaxTime)
      SetSliderDialogDefaultValue(6.0)
      SetSliderDialogRange(3.0, 48.0)
      SetSliderDialogInterval(0.5)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      fWalkBreakMaxTime = fValue
      SetSliderOptionValueST(fWalkBreakMaxTime, "{1} Hours")
   EndEvent

   Event OnDefaultST()
      fWalkBreakMaxTime = 6.0
      SetSliderOptionValueST(fWalkBreakMaxTime, "{1} Hours")
   EndEvent

   Event OnHighlightST()
      SetInfoText("When the slaver starts walking a random time is chosen between the minimum and maximum Time Until Break.\n" +\
                  "If the slaver continues to walk non-stop until that time and end up in a town he will take a break.")
   EndEvent
EndState

State ST_LGM_BREAK_MIN_DURATION
   Event OnSliderOpenST()
      SetSliderDialogStartValue(fWalkBreakMinDuration)
      SetSliderDialogDefaultValue(0.5)
      SetSliderDialogRange(0.5, 6.0)
      SetSliderDialogInterval(0.5)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      fWalkBreakMinDuration = fValue
      SetSliderOptionValueST(fWalkBreakMinDuration, "{1} Hours")
   EndEvent

   Event OnDefaultST()
      fWalkBreakMinDuration = 0.5
      SetSliderOptionValueST(fWalkBreakMinDuration, "{1} Hours")
   EndEvent

   Event OnHighlightST()
      SetInfoText("Once the slaver starts a walking break a random time is chosen between " +\
                  "the minimum and maximum Break Duration to limit how long the break lasts.")
   EndEvent
EndState

State ST_LGM_BREAK_MAX_DURATION
   Event OnSliderOpenST()
      SetSliderDialogStartValue(fWalkBreakMaxDuration)
      SetSliderDialogDefaultValue(3.0)
      SetSliderDialogRange(0.5, 6.0)
      SetSliderDialogInterval(0.5)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      fWalkBreakMaxDuration = fValue
      SetSliderOptionValueST(fWalkBreakMaxDuration, "{1} Hours")
   EndEvent

   Event OnDefaultST()
      fWalkBreakMaxDuration = 3.0
      SetSliderOptionValueST(fWalkBreakMaxDuration, "{1} Hours")
   EndEvent

   Event OnHighlightST()
      SetInfoText("Once the slaver starts a walking break a random time is chosen between " +\
                  "the minimum and maximum Break Duration to limit how long the break lasts.")
   EndEvent
EndState

State ST_LEASH_TO
   Event OnSelectST()
      Actor aNearest = _qFramework.GetNearestActor()
      If ((!_qDfwSupport.IsGameOn()) && aNearest)
         _qDfwSupport.StartLeashGame(aNearest)
         SetTextOptionValueST("Done")
      EndIf
   EndEvent

   Event OnDefaultST()
      Actor aNearest = _qFramework.GetNearestActor()
      String szValue = "None"
      If ((!_qDfwSupport.IsGameOn()) && aNearest)
         szValue = aNearest.GetDisplayName()
      EndIf
      SetTextOptionValueST(szValue)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Starts the leash game with the nearest NPC.")
   EndEvent
EndState


;***********************************************************************************************
;***                                 STATES: BDSM FURNITURE                                  ***
;***********************************************************************************************
State ST_BDSMF_LOCK
   Event OnSliderOpenST()
      SetSliderDialogStartValue(fFurnitureLockChance)
      SetSliderDialogDefaultValue(5.0)
      If (10 <= fFurnitureLockChance)
         SetSliderDialogRange(0, 100)
         SetSliderDialogInterval(1)
      Else
         SetSliderDialogRange(0, 10)
         SetSliderDialogInterval(0.1)
      EndIf
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      fFurnitureLockChance = fValue
      SetSliderOptionValueST(fFurnitureLockChance, "{1}%")
   EndEvent

   Event OnDefaultST()
      fFurnitureLockChance = 5.0
      SetSliderOptionValueST(fFurnitureLockChance, "{1}%")
   EndEvent

   Event OnHighlightST()
      SetInfoText("When sitting in unlocked BDSM furniture (a cross or pillory, etc.) this is the\n" +\
                  "chance (per poll event) a nearby NPC will decide to lock the furniture.")
   EndEvent
EndState

State ST_BDSMF_RELEASE
   Event OnSliderOpenST()
      SetSliderDialogStartValue(fFurnitureReleaseChance)
      SetSliderDialogDefaultValue(1)
      If (10 <= fFurnitureReleaseChance)
         SetSliderDialogRange(0, 100)
         SetSliderDialogInterval(1)
      Else
         SetSliderDialogRange(0, 10)
         SetSliderDialogInterval(0.1)
      EndIf
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      fFurnitureReleaseChance = fValue
      SetSliderOptionValueST(fFurnitureReleaseChance, "{1}%")

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Furniture")
   EndEvent

   Event OnDefaultST()
      fFurnitureReleaseChance = 1.0
      SetSliderOptionValueST(fFurnitureReleaseChance, "{1}%")

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Furniture")
   EndEvent

   Event OnHighlightST()
      SetInfoText("If locked in BDSM furniture by this mod, this is the chance (per poll event) that\n" +\
                  "the original locker of the furniture will unlock it.")
   EndEvent
EndState

State ST_BDSMF_TEASE
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iFurnitureTeaseChance)
      SetSliderDialogDefaultValue(75)
      SetSliderDialogRange(0, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iFurnitureTeaseChance = (fValue As Int)
      SetSliderOptionValueST(iFurnitureTeaseChance)
   EndEvent

   Event OnDefaultST()
      iFurnitureTeaseChance = 75
      SetSliderOptionValueST(iFurnitureTeaseChance)
   EndEvent

   Event OnHighlightST()
      SetInfoText("The % chance the NPC is teasing the player each time he lets her go.")
   EndEvent
EndState

State ST_BDSMF_ALT
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iFurnitureAltRelease)
      SetSliderDialogDefaultValue(20)
      If (100 <= iFurnitureAltRelease)
         SetSliderDialogRange(0, 500)
         SetSliderDialogInterval(10)
      Else
         SetSliderDialogRange(0, 100)
         SetSliderDialogInterval(1)
      EndIf
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iFurnitureAltRelease = (fValue As Int)
      SetSliderOptionValueST(iFurnitureAltRelease)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Leash")
   EndEvent

   Event OnDefaultST()
      iFurnitureAltRelease = 20
      SetSliderOptionValueST(iFurnitureAltRelease)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Leash")
   EndEvent

   Event OnHighlightST()
      SetInfoText("If the original locker of the furniture is not nearby another neraby NPC may unlock the furniture.\n" +\
                  "The chance of an alternate NPC releasing the player is expressed as a percent of the \"Chance of Release\".\n" +\
                  "If \"Chance of Release\" is 10% and this is 10, there will be a 1% chance when the original locker is not nearby.")
   EndEvent
EndState

State ST_BDSMF_VISITOR
   Event OnSliderOpenST()
      SetSliderDialogStartValue(fFurnitureVisitorChance)
      SetSliderDialogDefaultValue(1.0)
      If (10 <= fFurnitureVisitorChance)
         SetSliderDialogRange(0, 100)
         SetSliderDialogInterval(1)
      Else
         SetSliderDialogRange(0, 10)
         SetSliderDialogInterval(0.1)
      EndIf
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      fFurnitureVisitorChance = fValue
      SetSliderOptionValueST(fFurnitureVisitorChance, "{1}%")

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Furniture")
   EndEvent

   Event OnDefaultST()
      fFurnitureVisitorChance = 1.0
      SetSliderOptionValueST(fFurnitureVisitorChance, "{1}%")

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Furniture")
   EndEvent

   Event OnHighlightST()
      SetInfoText("If locked in BDSM furniture this is the chance (per poll event) that\n" +\
                  "someone will come by wanting to play with you.")
   EndEvent
EndState

State ST_BDSMF_TRANSFER
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iFurnitureTransferChance)
      SetSliderDialogDefaultValue(20)
      SetSliderDialogRange(0, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iFurnitureTransferChance = (fValue As Int)
      SetSliderOptionValueST(iFurnitureTransferChance, "{0}%")
   EndEvent

   Event OnDefaultST()
      iFurnitureTransferChance = 20
      SetSliderOptionValueST(iFurnitureTransferChance, "{0}%")
   EndEvent

   Event OnHighlightST()
      SetInfoText("When a visitor comes this is the chance he will want to transfer the player into nearby furniture.")
   EndEvent
EndState

State ST_BDSMFR_VISITOR
   Event OnSliderOpenST()
      SetSliderDialogStartValue(fFurnitureRemoteVisitor)
      SetSliderDialogDefaultValue(5.0)
      If (10 <= fFurnitureRemoteVisitor)
         SetSliderDialogRange(0, 100)
         SetSliderDialogInterval(1)
      Else
         SetSliderDialogRange(0, 10)
         SetSliderDialogInterval(0.1)
      EndIf
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      fFurnitureRemoteVisitor = fValue
      SetSliderOptionValueST(fFurnitureRemoteVisitor, "{1}%")

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Furniture")
   EndEvent

   Event OnDefaultST()
      fFurnitureRemoteVisitor = 5.0
      SetSliderOptionValueST(fFurnitureRemoteVisitor, "{1}%")

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Furniture")
   EndEvent

   Event OnHighlightST()
      SetInfoText("This is the chance a visitor will come by to play if the player is locked in remote furniture.\n" +\
                  "Even in remote areas regular chances will be used if someone is nearby.")
   EndEvent
EndState

State ST_BDSMFR_SANDBOX
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iFurnitureRemoteSandbox)
      SetSliderDialogDefaultValue(50)
      SetSliderDialogRange(0, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iFurnitureRemoteSandbox = (fValue As Int)
      SetSliderOptionValueST(iFurnitureRemoteSandbox, "{0}%")
   EndEvent

   Event OnDefaultST()
      iFurnitureRemoteSandbox = 50
      SetSliderOptionValueST(iFurnitureRemoteSandbox, "{0}%")
   EndEvent

   Event OnHighlightST()
      SetInfoText("This is the chacnce the furniture locker will linger nearby (sandbox) after he comes for a visit.\n" +\
                  "This \"lingering\" follows the same characteristics as the leash holder's \"break\".\n" +\
                  "This lingering is only valid in areas (furniture) tagged as \"Remote\".")
   EndEvent
EndState

State ST_BDSMF_MIN_TIME
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iFurnitureMinLockTime)
      SetSliderDialogDefaultValue(30)
      SetSliderDialogRange(0, 360)
      SetSliderDialogInterval(5)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iFurnitureMinLockTime = (fValue As Int)
      SetSliderOptionValueST(iFurnitureMinLockTime)
   EndEvent

   Event OnDefaultST()
      iFurnitureMinLockTime = 30
      SetSliderOptionValueST(iFurnitureMinLockTime)
   EndEvent

   Event OnHighlightST()
      SetInfoText("If the player sits in furniture she will be locked in it for this amount of time.\n" +\
                  "This is measured in Game Minutes.")
   EndEvent
EndState

State ST_BDSMF_HIDE
   Event OnSelectST()
      bFurnitureHide = !bFurnitureHide
      SetToggleOptionValueST(bFurnitureHide)
   EndEvent

   Event OnDefaultST()
      bFurnitureHide = True
      SetToggleOptionValueST(bFurnitureHide)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Hide BDSM furniture the player is sitting in during sex scenes.")
   EndEvent
EndState

State ST_BDSMF_POST_SEX
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iModPostSexMonitor)
      SetSliderDialogDefaultValue(8)
      SetSliderDialogRange(0, 20)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iModPostSexMonitor = (fValue As Int)
      SetSliderOptionValueST(iModPostSexMonitor, "{0} s")
   EndEvent

   Event OnDefaultST()
      iModPostSexMonitor = 8
      SetSliderOptionValueST(iModPostSexMonitor, "{0} s")
   EndEvent

   Event OnHighlightST()
      SetInfoText("After sex scenes in a cage another mod will sometimes teleport you to a random location.\n" +\
                  "This will monitor your position and teleport you back into the cage if this is detected.\n" +\
                  "This option prevents being accidentally released from the cage but increases the chance of interfering with \n" +\
                  "scenes and crashing after sex.  If the player is teleported twice at the same time the game may crash.")
   EndEvent
EndState

State ST_BDSMF_FAV
   Event OnSelectST()
      _qDfwSupport.FavouriteCurrentFurniture()
      SetTextOptionValueST("Done")
   EndEvent

   Event OnDefaultST()
      ObjectReference oCurrFurniture = _qFramework.GetBdsmFurniture()
      String szValue = "None"
      If (oCurrFurniture)
         szValue = oCurrFurniture.GetDisplayName()
      EndIf
      SetTextOptionValueST(szValue)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Add the furniture the player is currently sitting in to the favourite list.")
   EndEvent
EndState

State ST_BDSMF_AUTO_FAV
   Event OnSelectST()
      bAutoAddFurniture = !bAutoAddFurniture
      SetToggleOptionValueST(bAutoAddFurniture)
   EndEvent

   Event OnDefaultST()
      bAutoAddFurniture = False
      SetToggleOptionValueST(bAutoAddFurniture)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Automatically add BDSM furniture the player sits in to the favourite furniture list.")
   EndEvent
EndState

State ST_BDSMF_SHOW_LIST
   Event OnMenuOpenST()
      Form[] aoFavourites = _qDfwSupport.GetFavouriteFurniture()
      Form[] aoCells      = _qDfwSupport.GetFavouriteCell()
      Form[] aoLocations  = _qDfwSupport.GetFavouriteLocation()
      Form[] aoRegions    = _qDfwSupport.GetFavouriteRegion()
      ; Create a new array to hold all of the options.
      Int iIndex = aoFavourites.Length - 1
      String[] aszOptions = Utility.CreateStringArray(iIndex + 2)
      aszOptions[0] = S_REM_NONE

      ; Add a text value for each slot to the option array.
      While (0 <= iIndex)
         ObjectReference oFurniture = (aoFavourites[iIndex] As ObjectReference)
         Cell oCell = (aoCells[iIndex] As Cell)
         String szCell = "No Cell"
         If (oCell)
            szCell = oCell.GetName()
         EndIf
         Location oLocation = (aoLocations[iIndex] As Location)
         String szLocation = "No Location"
         If (oLocation)
            szLocation = oLocation.GetName()
         EndIf
         Location oRegion = (aoRegions[iIndex] As Location)
         String szRegion = "Wilderness"
         If (oRegion)
            szRegion = oRegion.GetName()
         EndIf
         aszOptions[iIndex + 1] = oFurniture.GetDisplayName() + ": " + szCell + "(" + szLocation + "-" + szRegion + ")"
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

      ; Adjust the chosen index since the "Remove None" is not really in the list.
      iChosenIndex -= 1
 
      _qDfwSupport.RemoveFavourite(iChosenIndex)
   EndEvent

   Event OnHighlightST()
      SetInfoText("View the list of favourited furniture and remove one if desired.")
   EndEvent
EndState

State ST_CAGE_FAV
   Event OnSelectST()
      ObjectReference oCage = Game.GetCurrentCrosshairRef()
      If (!oCage)
         SetTextOptionValueST("Invalid Door")
         Return
      EndIf
      _qDfwSupport.FavouriteCurrentFurniture(oCage)
      _oSelectedFurniture = oCage
      SetTextOptionValueST("Done")
   EndEvent

   Event OnDefaultST()
      ObjectReference oCage = Game.GetCurrentCrosshairRef()
      String szValue = "Target Door"
      If (oCage)
         szValue = oCage.GetDisplayName()
      EndIf
      SetTextOptionValueST(szValue)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Cages are a new feature that are meant to work interchangably with BDSM furniture.\n" +\
                  "To add a cage: target the door and add it here, then stand inside the cage and set the location.\n" +\
                  "Warning: Cages haven't been well tested.  They are not recommended for use.")
   EndEvent
EndState

State ST_CAGE_LOC
   Event OnSelectST()
      _qDfwSupport.SetFavouriteCageLocation(_oSelectedFurniture)
      SetTextOptionValueST("Done")
   EndEvent

   Event OnDefaultST()
      SetTextOptionValueST("Stand In Cage")
   EndEvent

   Event OnHighlightST()
      SetInfoText("First: Set the door as the \"cage\".\n" +\
                  "Then: Stand in a location inside the cage and set the location here.\n" +\
                  "This can only be used to set up the last cage added to the favourite system.\n" +\
                  "Warning: Cages haven't been well tested.  They are not recommended for use.")
   EndEvent
EndState

State ST_CAGE_LEVER
   Event OnSelectST()
      ObjectReference oLever = Game.GetCurrentCrosshairRef()
      If (!oLever)
         SetTextOptionValueST("Invalid Lever")
         Return
      EndIf
      _qDfwSupport.SetFavouriteCageLever(_oSelectedFurniture, oLever)
      SetTextOptionValueST("Done")
   EndEvent

   Event OnDefaultST()
      ObjectReference oLever = Game.GetCurrentCrosshairRef()
      String szValue = "Target Lever"
      If (oLever)
         szValue = oLever.GetDisplayName()
      EndIf
      SetTextOptionValueST(szValue)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Some cage doors have levers to open them.\n" +\
                  "If this is the case target the lever in your crosshairs and used this to set the lever.\n" +\
                  "This can only be used to set up the last cage added to the favourite system.\n" +\
                  "Warning: Cages haven't been well tested.  They are not recommended for use.")
   EndEvent
EndState

State ST_WORKF_FAV
   Event OnSelectST()
      ObjectReference oFurniture = Game.GetCurrentCrosshairRef()
      If (!oFurniture)
         SetTextOptionValueST("Invalid Furniture")
         Return
      EndIf
      _qDfwSupport.FavouriteCurrentFurniture(oFurniture, True)
      _oSelectedFurniture = oFurniture
      SetTextOptionValueST("Done")
   EndEvent

   Event OnDefaultST()
      ObjectReference oFurniture = Game.GetCurrentCrosshairRef()
      String szValue = "Target Furniture"
      If (oFurniture)
         szValue = oFurniture.GetDisplayName()
      EndIf
      SetTextOptionValueST(szValue)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Add work furniture, Forges, Enchanting/Alchemy Table, Grain Mills, Beds.")
   EndEvent
EndState

State ST_BDSMF_SELECT
   Event OnMenuOpenST()
      Form[] aoFavourites = _qDfwSupport.GetFavouriteFurniture()
      Form[] aoCells      = _qDfwSupport.GetFavouriteCell()
      Form[] aoLocations  = _qDfwSupport.GetFavouriteLocation()
      Form[] aoRegions    = _qDfwSupport.GetFavouriteRegion()
      ; Create a new array to hold all of the options.
      Int iIndex = aoFavourites.Length - 1
      String[] aszOptions = Utility.CreateStringArray(iIndex + 2)
      aszOptions[0] = "Select None"

      ; Add a text value for each slot to the option array.
      While (0 <= iIndex)
         ObjectReference oFurniture = (aoFavourites[iIndex] As ObjectReference)
         Cell oCell = (aoCells[iIndex] As Cell)
         String szCell = "No Cell"
         If (oCell)
            szCell = oCell.GetName()
         EndIf
         Location oLocation = (aoLocations[iIndex] As Location)
         String szLocation = "No Location"
         If (oLocation)
            szLocation = oLocation.GetName()
         EndIf
         Location oRegion = (aoRegions[iIndex] As Location)
         String szRegion = "Wilderness"
         If (oRegion)
            szRegion = oRegion.GetName()
         EndIf
         aszOptions[iIndex + 1] = oFurniture.GetDisplayName() + ": " + szCell + "(" + szLocation + "-" + szRegion + ")"
         iIndex -= 1
      EndWhile

      ; Display the options
      SetMenuDialogStartIndex(0)
      SetMenuDialogDefaultIndex(0)
      SetMenuDialogOptions(aszOptions)
   EndEvent

   Event OnMenuAcceptST(Int iChosenIndex)
      ; Ignore the first option ("Select None")
      ; If None was selected clear the selected furniture.
      If (!iChosenIndex)
         _oSelectedFurniture = None
         SetOptionFlagsST(OPTION_FLAG_DISABLED, a_stateName="ST_BDSMF_TOGGLE_FLAG")
         SetTextOptionValueST("None", a_stateName="ST_BDSMF_SELECTED")
         SetTextOptionValueST("0x0000", a_stateName="ST_BDSMF_VIEW_FLAGS")
         Return
      EndIf

      ; Adjust the chosen index since the "Select None" is not really in the list.
      iChosenIndex -= 1
 
      Form[] aoFavourites = _qDfwSupport.GetFavouriteFurniture()
      _oSelectedFurniture = (aoFavourites[iChosenIndex] As ObjectReference)
      String szSelectedFurniture = "None"
      If (_oSelectedFurniture)
         szSelectedFurniture = _oSelectedFurniture.GetDisplayName()
         If (!szSelectedFurniture)
            szSelectedFurniture = _oSelectedFurniture.GetName()
         EndIf
      EndIf
      SetTextOptionValueST(szSelectedFurniture, a_stateName="ST_BDSMF_SELECTED")
      Int iCurrFlags = _qDfwSupport.ToggleFurnitureFlag(_oSelectedFurniture, 0x0000)
      SetTextOptionValueST("0x" + _qDfwUtil.ConvertHexToString(iCurrFlags, 4), a_stateName="ST_BDSMF_VIEW_FLAGS")
   EndEvent

   Event OnHighlightST()
      SetInfoText("A few options can only be performed on one furniture at a time.\n" +\
                  "Use this to select which furniture these options will work on.")
   EndEvent
EndState

State ST_BDSMF_TOGGLE_FLAG
   Event OnMenuOpenST()
      ; Create a new array to hold all of the options.
      String[] aszOptions = New String[17]
      aszOptions[0]  = "Add None"
      aszOptions[1]  =    "BDSM Furniture (0x0001)"
      aszOptions[2]  =              "Cage (0x0002)"
      aszOptions[3]  =               "Bed (0x0004)"
      aszOptions[4]  =    "Work Furniture (0x0008)"
      aszOptions[5]  =             "Store (0x0010)"
      aszOptions[6]  =            "Public (0x0020)"
      aszOptions[7]  =           "Private (0x0040)"
      aszOptions[8]  =            "Remote (0x0080)"
      aszOptions[9]  =  "Activity/Sandbox (0x0100)"
      aszOptions[10] =           "Milking (0x0200)"
      aszOptions[11] = "Closed by Default (0x0400)"
      aszOptions[12] =         "Dangerous (0x0800)"
      aszOptions[13] =        "Grain Mill (0x1000)"
      aszOptions[14] =             "Forge (0x2000)"
      aszOptions[15] =  "Enchanting Table (0x4000)"
      aszOptions[16] =     "Alchemy Table (0x8000)"

      ; Display the options
      SetMenuDialogStartIndex(0)
      SetMenuDialogDefaultIndex(0)
      SetMenuDialogOptions(aszOptions)
   EndEvent

   Event OnMenuAcceptST(Int iChosenIndex)
      ; Ignore the first option ("Add None")
      If (!iChosenIndex)
         Return
      EndIf

      ; Adjust the chosen index since the "Select None" is not really in the list.
      iChosenIndex -= 1

      ; Convert the index into it's corresponding bitmask.
      int iFlag = Math.LeftShift(0x0001, iChosenIndex)
 
      Int iNewFlags = _qDfwSupport.ToggleFurnitureFlag(_oSelectedFurniture, iFlag)
      SetTextOptionValueST("0x" + _qDfwUtil.ConvertHexToString(iNewFlags, 4), a_stateName="ST_BDSMF_VIEW_FLAGS")
   EndEvent

   Event OnHighlightST()
      SetInfoText("Add a flag to identify characteristics of the furniture.\n" +\
                  "Eventually these flags will influence how a furniture is used.\n" +\
                  "As of version 2.07 only Cage and Remote are used.")
   EndEvent
EndState


;***********************************************************************************************
;***                                STATES: EVENTS AND WEIGHTS                               ***
;***********************************************************************************************
State ST_EVENT_SELL_ITEMS
   Event OnSliderOpenST()
      SetSliderDialogStartValue(fEventSellItems)
      SetSliderDialogDefaultValue(20.0)
      If (10 <= fEventSellItems)
         SetSliderDialogRange(0, 100)
         SetSliderDialogInterval(1)
      Else
         SetSliderDialogRange(0, 10)
         SetSliderDialogInterval(0.1)
      EndIf
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      fEventSellItems = fValue
      SetSliderOptionValueST(fEventSellItems, "{1}%")
   EndEvent

   Event OnDefaultST()
      fEventSellItems = 20.0
      SetSliderOptionValueST(fEventSellItems, "{1}%")
   EndEvent

   Event OnHighlightST()
      SetInfoText("While playing the leash game this is the chance (per day) the slaver will sell all of your items.\n" +\
                  "Note: The slaver may also sell all of your items if the leash game ever becomes permanent.\n" +\
                  "Note: Items sold in this manner may be retrieved from the collector in a cave near Froki's Shack.")
   EndEvent
EndState

State ST_EVENT_REM_RESTRAINTS
   Event OnSliderOpenST()
      SetSliderDialogStartValue(fEventRemRestraints)
      SetSliderDialogDefaultValue(30.0)
      If (10 <= fEventRemRestraints)
         SetSliderDialogRange(0, 100)
         SetSliderDialogInterval(1)
      Else
         SetSliderDialogRange(0, 10)
         SetSliderDialogInterval(0.1)
      EndIf
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      fEventRemRestraints = fValue
      SetSliderOptionValueST(fEventRemRestraints, "{1}%")
   EndEvent

   Event OnDefaultST()
      fEventRemRestraints = 30.0
      SetSliderOptionValueST(fEventRemRestraints, "{1}%")
   EndEvent

   Event OnHighlightST()
      SetInfoText("Often the player will be wearing restraints the slaver doesn't have the key for (mostly these are\n" +\
                  "restraints from other mods).  Such restraints can cause difficulty in some scenes or prevent them altogether.\n" +\
                  "This is the chance (per day) the slaver will take the player to the blacksmith to try to get them removed.\n" +\
                  "Only some restraints can be removed realistically.  If you find others please provide details in the forum.")
   EndEvent
EndState

State ST_EVENT_PROPOSITION
   Event OnSliderOpenST()
      SetSliderDialogStartValue(fEventProposition)
      SetSliderDialogDefaultValue(10.0)
      If (10 <= fEventProposition)
         SetSliderDialogRange(0, 100)
         SetSliderDialogInterval(1)
      Else
         SetSliderDialogRange(0, 10)
         SetSliderDialogInterval(0.1)
      EndIf
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      fEventProposition = fValue
      SetSliderOptionValueST(fEventProposition, "{1}%")

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Events")
   EndEvent

   Event OnDefaultST()
      fEventProposition = 5.0
      SetSliderOptionValueST(fEventProposition, "{1}%")

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Events")
   EndEvent

   Event OnHighlightST()
      SetInfoText("This is the chance a dominant approach the slaver with an interest in using the player sexualy.\n" +\
                  "This event is checked every poll interval and is based on the NPC's arousal.  At 100% arousal the" +\
                  "there is this % of a chance the NPC will request sex with the player.")
   EndEvent
EndState

State ST_EVENT_PROP_AROUSAL
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iEventPropArousal)
      SetSliderDialogDefaultValue(40)
      SetSliderDialogRange(0, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iEventPropArousal = (fValue As Int)
      SetSliderOptionValueST(iEventPropArousal)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Events")
   EndEvent

   Event OnDefaultST()
      iEventPropArousal = 40
      SetSliderOptionValueST(iEventPropArousal)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Events")
   EndEvent

   Event OnHighlightST()
      SetInfoText("This is the minimum arousal an NPC needs before he will request sex with the player.")
   EndEvent
EndState

State ST_EVENT_PERMANENCY
   Event OnSliderOpenST()
      SetSliderDialogStartValue(fEventPermanency)
      SetSliderDialogDefaultValue(5.0)
      If (10 <= fEventPermanency)
         SetSliderDialogRange(0, 100)
         SetSliderDialogInterval(1)
      Else
         SetSliderDialogRange(0, 10)
         SetSliderDialogInterval(0.1)
      EndIf
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      fEventPermanency = fValue
      SetSliderOptionValueST(fEventPermanency, "{1}%")
   EndEvent

   Event OnDefaultST()
      fEventPermanency = 5.0
      SetSliderOptionValueST(fEventPermanency, "{1}%")
   EndEvent

   Event OnHighlightST()
      SetInfoText("While playing the leash game this is the chance (per day) the slaver will decide to keep the player\n" +\
                  "as a permanent slave and never release her.\n" +\
                  "Note: There are a lot of features related to permanent slavery that have not been completed.\n" +\
                  "I recommend this feature not be used.")
   EndEvent
EndState

State ST_EVENT_MILK_CHANCE
   Event OnSliderOpenST()
      SetSliderDialogStartValue(fEventMilkScene)
      SetSliderDialogDefaultValue(0.0)
      If (10 <= fEventMilkScene)
         SetSliderDialogRange(0, 100)
         SetSliderDialogInterval(1)
      Else
         SetSliderDialogRange(0, 10)
         SetSliderDialogInterval(0.1)
      EndIf
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      fEventMilkScene = fValue
      SetSliderOptionValueST(fEventMilkScene, "{1}%")

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Events")
   EndEvent

   Event OnDefaultST()
      fEventMilkScene = 0.0
      SetSliderOptionValueST(fEventMilkScene, "{1}%")

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Events")
   EndEvent

   Event OnHighlightST()
      SetInfoText("The Milk Mod Economy mod is required and the player is required to be a maid for this scene to trigger.\n" +\
                  "This is the chance (per poll interval) during the leash game for the slaver to milk the player \n" +\
                  "if she is ready to be milked.  A nearby milking machine is needed for this to happen.")
   EndEvent
EndState

State ST_EVENT_MILK_MIN
   Event OnSliderOpenST()
      SetSliderDialogStartValue(fEventMilkThreshold)
      SetSliderDialogDefaultValue(3.0)
      SetSliderDialogRange(0, 5)
      SetSliderDialogInterval(0.1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      fEventMilkThreshold = fValue
      SetSliderOptionValueST(fEventMilkThreshold, "Milk {1}")
   EndEvent

   Event OnDefaultST()
      fEventMilkThreshold = 3.0
      SetSliderOptionValueST(fEventMilkThreshold, "Milk {1}")
   EndEvent

   Event OnHighlightST()
      SetInfoText("The Milk Mod Economy mod is required and the player is required to be a maid for this scene to trigger.\n" +\
                  "If the player is a maid the Milk Mod Economy mod keeps track of the player's milk ready to be milked.\n" +\
                  "This is the minimum level of the player's milk value required for a milking scene to trigger.")
   EndEvent
EndState

State ST_EVENT_EQUIP_SLAVER
   Event OnSliderOpenST()
      SetSliderDialogStartValue(fEventEquipSlaver)
      SetSliderDialogDefaultValue(100.0)
      If (10 <= fEventEquipSlaver)
         SetSliderDialogRange(0, 100)
         SetSliderDialogInterval(1)
      Else
         SetSliderDialogRange(0, 10)
         SetSliderDialogInterval(0.1)
      EndIf
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      fEventEquipSlaver = fValue
      SetSliderOptionValueST(fEventEquipSlaver, "{1}%")
   EndEvent

   Event OnDefaultST()
      fEventEquipSlaver = 100.0
      SetSliderOptionValueST(fEventEquipSlaver, "{1}%")
   EndEvent

   Event OnHighlightST()
      SetInfoText("This is the chance per working hour the slaver will force the player to craft better equipment from him.\n" +\
                  "Note: The player must be secure, all of her items taken, and the player must have the skill to craft\n" +\
                  "better items.  This is a basic scene that still needs a lot of work.")
   EndEvent
EndState

State ST_WEIGHT_PUNISH_BASIC
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iWeightPunishBasic)
      SetSliderDialogDefaultValue(10)
      SetSliderDialogRange(0, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iWeightPunishBasic = (fValue As Int)
      SetSliderOptionValueST(iWeightPunishBasic)
   EndEvent

   Event OnDefaultST()
      iWeightPunishBasic = 10
      SetSliderOptionValueST(iWeightPunishBasic)
   EndEvent

   Event OnHighlightST()
      SetInfoText("When choosing a punishment for the player this is the chance a basic punishment will be selected.\n" +\
                  "If no basic punishment can be applied (gag, blindfold, collar, hobble, etc.) this option will not be selected\n" +\
                  "regardless of this value.  Also the more the player misbehaves the less this option will be chosen.")
   EndEvent
EndState

State ST_WEIGHT_PUNISH_FURN
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iWeightPunishFurn)
      SetSliderDialogDefaultValue(10)
      SetSliderDialogRange(0, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iWeightPunishFurn = (fValue As Int)
      SetSliderOptionValueST(iWeightPunishFurn)
   EndEvent

   Event OnDefaultST()
      iWeightPunishFurn = 10
      SetSliderOptionValueST(iWeightPunishFurn)
   EndEvent

   Event OnHighlightST()
      SetInfoText("When choosing a punishment for the player this is the chance a furniture punishment will be selected.\n" +\
                  "Note: These chances will increase by two for each time the player misbehaves regardless of what is configured here.")
   EndEvent
EndState

State ST_WEIGHT_PUNISH_CRAWL
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iWeightPunishCrawl)
      SetSliderDialogDefaultValue(10)
      SetSliderDialogRange(0, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iWeightPunishCrawl = (fValue As Int)
      SetSliderOptionValueST(iWeightPunishCrawl)
   EndEvent

   Event OnDefaultST()
      iWeightPunishCrawl = 10
      SetSliderOptionValueST(iWeightPunishCrawl)
   EndEvent

   Event OnHighlightST()
      SetInfoText("When choosing a punishment for the player this is the chance she will be forced to crawl for a period of time.\n" +\
                  "Note: These chances will increase by one for each time the player misbehaves regardless of what is configured here.")
   EndEvent
EndState

State ST_WEIGHT_PUNISH_BLIND
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iChancePunishBlindfold)
      SetSliderDialogDefaultValue(40)
      SetSliderDialogRange(0, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iChancePunishBlindfold = (fValue As Int)
      SetSliderOptionValueST(iChancePunishBlindfold)
   EndEvent

   Event OnDefaultST()
      iChancePunishBlindfold = 40
      SetSliderOptionValueST(iChancePunishBlindfold)
   EndEvent

   Event OnHighlightST()
      SetInfoText("This is the chance the basic punishment will included a blindfold when other restraints are already being added.\n" +\
                  "Note: A blindfold is always chosen as a basic punishment when no other restraints are added.\n" +\
                  "Tip: To avoid blindfold as a punishment set the basic punishment weight to 0.")
   EndEvent
EndState

State ST_WEIGHT_FTAG_TRANS_DEFAULT
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iFWeightTransferDefault)
      SetSliderDialogDefaultValue(10)
      SetSliderDialogRange(-100, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iFWeightTransferDefault = (fValue As Int)
      SetSliderOptionValueST(iFWeightTransferDefault)
   EndEvent

   Event OnDefaultST()
      iFWeightTransferDefault = 10
      SetSliderOptionValueST(iFWeightTransferDefault)
   EndEvent

   Event OnHighlightST()
      SetInfoText("The probability a furniture will be chosen to transfer the player to at the end of the leash game is based on\n" +\
                  "a weight system.  This is the base weight for all furniture, regardless of whether they have a tag or not.\n" +\
                  "A furniture's weight is the Default + a value for each tag associated with that furniture.\n" +\
                  "If all weights are 0 a furniture will be chosen at random.  Otherwise a furniture with weight of 0 won't be selected.")
   EndEvent
EndState

State ST_WEIGHT_FTAG_TRANS_FURN
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iFWeightTransferFurn)
      SetSliderDialogDefaultValue(0)
      SetSliderDialogRange(-100, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iFWeightTransferFurn = (fValue As Int)
      SetSliderOptionValueST(iFWeightTransferFurn)
   EndEvent

   Event OnDefaultST()
      iFWeightTransferFurn = 0
      SetSliderOptionValueST(iFWeightTransferFurn)
   EndEvent

   Event OnHighlightST()
      SetInfoText("This weight is added to a peice of furniture if it is regular BDSM furniture (not a cage).")
   EndEvent
EndState

State ST_WEIGHT_FTAG_TRANS_CAGE
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iFWeightTransferCage)
      SetSliderDialogDefaultValue(0)
      SetSliderDialogRange(-100, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iFWeightTransferCage = (fValue As Int)
      SetSliderOptionValueST(iFWeightTransferCage)
   EndEvent

   Event OnDefaultST()
      iFWeightTransferCage = 0
      SetSliderOptionValueST(iFWeightTransferCage)
   EndEvent

   Event OnHighlightST()
      SetInfoText("This weight is added to a peice of furniture if it is flagged as a cage.")
   EndEvent
EndState

State ST_WEIGHT_FTAG_TRANS_BED
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iFWeightTransferBed)
      SetSliderDialogDefaultValue(0)
      SetSliderDialogRange(-100, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iFWeightTransferBed = (fValue As Int)
      SetSliderOptionValueST(iFWeightTransferBed)
   EndEvent

   Event OnDefaultST()
      iFWeightTransferBed = 0
      SetSliderOptionValueST(iFWeightTransferBed)
   EndEvent

   Event OnHighlightST()
      SetInfoText("This weight is added to a peice of furniture if it is flagged as a bed.")
   EndEvent
EndState

State ST_WEIGHT_FTAG_TRANS_STORE
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iFWeightTransferStore)
      SetSliderDialogDefaultValue(0)
      SetSliderDialogRange(-100, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iFWeightTransferStore = (fValue As Int)
      SetSliderOptionValueST(iFWeightTransferStore)
   EndEvent

   Event OnDefaultST()
      iFWeightTransferStore = 0
      SetSliderOptionValueST(iFWeightTransferStore)
   EndEvent

   Event OnHighlightST()
      SetInfoText("This weight is added to a peice of furniture if it is flagged as being in a store.")
   EndEvent
EndState

State ST_WEIGHT_FTAG_TRANS_PUBLIC
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iFWeightTransferPublic)
      SetSliderDialogDefaultValue(0)
      SetSliderDialogRange(-100, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iFWeightTransferPublic = (fValue As Int)
      SetSliderOptionValueST(iFWeightTransferPublic)
   EndEvent

   Event OnDefaultST()
      iFWeightTransferPublic = 0
      SetSliderOptionValueST(iFWeightTransferPublic)
   EndEvent

   Event OnHighlightST()
      SetInfoText("This weight is added to a peice of furniture if it is flagged as public.")
   EndEvent
EndState

State ST_WEIGHT_FTAG_TRANS_PRIVATE
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iFWeightTransferPrivate)
      SetSliderDialogDefaultValue(0)
      SetSliderDialogRange(-100, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iFWeightTransferPrivate = (fValue As Int)
      SetSliderOptionValueST(iFWeightTransferPrivate)
   EndEvent

   Event OnDefaultST()
      iFWeightTransferPrivate = 0
      SetSliderOptionValueST(iFWeightTransferPrivate)
   EndEvent

   Event OnHighlightST()
      SetInfoText("This weight is added to a peice of furniture if it is flagged as private.")
   EndEvent
EndState

State ST_WEIGHT_FTAG_TRANS_REMOTE
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iFWeightTransferRemote)
      SetSliderDialogDefaultValue(0)
      SetSliderDialogRange(-100, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iFWeightTransferRemote = (fValue As Int)
      SetSliderOptionValueST(iFWeightTransferRemote)
   EndEvent

   Event OnDefaultST()
      iFWeightTransferRemote = 0
      SetSliderOptionValueST(iFWeightTransferRemote)
   EndEvent

   Event OnHighlightST()
      SetInfoText("This weight is added to a peice of furniture if it is flagged as remote.")
   EndEvent
EndState

State ST_WEIGHT_FTAG_PUNISH_DEFAULT
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iFWeightPunishDefault)
      SetSliderDialogDefaultValue(10)
      SetSliderDialogRange(-100, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iFWeightPunishDefault = (fValue As Int)
      SetSliderOptionValueST(iFWeightPunishDefault)
   EndEvent

   Event OnDefaultST()
      iFWeightPunishDefault = 10
      SetSliderOptionValueST(iFWeightPunishDefault)
   EndEvent

   Event OnHighlightST()
      SetInfoText("The probability a furniture will be chosen when punishing the player is based on a weight system.\n" +\
                  "This is the base weight for all furniture, regardless of whether they have a tag or not.\n" +\
                  "A furniture's weight is the Default + a value for each tag associated with that furniture.\n" +\
                  "If all weights are 0 a furniture will be chosen at random.  Otherwise a furniture with weight of 0 won't be selected.")
   EndEvent
EndState

State ST_WEIGHT_FTAG_PUNISH_FURN
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iFWeightPunishFurn)
      SetSliderDialogDefaultValue(0)
      SetSliderDialogRange(-100, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iFWeightPunishFurn = (fValue As Int)
      SetSliderOptionValueST(iFWeightPunishFurn)
   EndEvent

   Event OnDefaultST()
      iFWeightPunishFurn = 0
      SetSliderOptionValueST(iFWeightPunishFurn)
   EndEvent

   Event OnHighlightST()
      SetInfoText("This weight is added to a peice of furniture if it is regular BDSM furniture (not a cage).")
   EndEvent
EndState

State ST_WEIGHT_FTAG_PUNISH_CAGE
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iFWeightPunishCage)
      SetSliderDialogDefaultValue(0)
      SetSliderDialogRange(-100, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iFWeightPunishCage = (fValue As Int)
      SetSliderOptionValueST(iFWeightPunishCage)
   EndEvent

   Event OnDefaultST()
      iFWeightPunishCage = 0
      SetSliderOptionValueST(iFWeightPunishCage)
   EndEvent

   Event OnHighlightST()
      SetInfoText("This weight is added to a peice of furniture if it is flagged as a cage.")
   EndEvent
EndState

State ST_WEIGHT_FTAG_PUNISH_BED
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iFWeightPunishBed)
      SetSliderDialogDefaultValue(0)
      SetSliderDialogRange(-100, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iFWeightPunishBed = (fValue As Int)
      SetSliderOptionValueST(iFWeightPunishBed)
   EndEvent

   Event OnDefaultST()
      iFWeightPunishBed = 0
      SetSliderOptionValueST(iFWeightPunishBed)
   EndEvent

   Event OnHighlightST()
      SetInfoText("This weight is added to a peice of furniture if it is flagged as a bed.")
   EndEvent
EndState

State ST_WEIGHT_FTAG_PUNISH_STORE
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iFWeightPunishStore)
      SetSliderDialogDefaultValue(0)
      SetSliderDialogRange(-100, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iFWeightPunishStore = (fValue As Int)
      SetSliderOptionValueST(iFWeightPunishStore)
   EndEvent

   Event OnDefaultST()
      iFWeightPunishStore = 0
      SetSliderOptionValueST(iFWeightPunishStore)
   EndEvent

   Event OnHighlightST()
      SetInfoText("This weight is added to a peice of furniture if it is flagged as being in a store.")
   EndEvent
EndState

State ST_WEIGHT_FTAG_PUNISH_PUBLIC
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iFWeightPunishPublic)
      SetSliderDialogDefaultValue(0)
      SetSliderDialogRange(-100, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iFWeightPunishPublic = (fValue As Int)
      SetSliderOptionValueST(iFWeightPunishPublic)
   EndEvent

   Event OnDefaultST()
      iFWeightPunishPublic = 0
      SetSliderOptionValueST(iFWeightPunishPublic)
   EndEvent

   Event OnHighlightST()
      SetInfoText("This weight is added to a peice of furniture if it is flagged as public.")
   EndEvent
EndState

State ST_WEIGHT_FTAG_PUNISH_PRIVATE
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iFWeightPunishPrivate)
      SetSliderDialogDefaultValue(0)
      SetSliderDialogRange(-100, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iFWeightPunishPrivate = (fValue As Int)
      SetSliderOptionValueST(iFWeightPunishPrivate)
   EndEvent

   Event OnDefaultST()
      iFWeightPunishPrivate = 0
      SetSliderOptionValueST(iFWeightPunishPrivate)
   EndEvent

   Event OnHighlightST()
      SetInfoText("This weight is added to a peice of furniture if it is flagged as private.")
   EndEvent
EndState

State ST_WEIGHT_FTAG_PUNISH_REMOTE
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iFWeightPunishRemote)
      SetSliderDialogDefaultValue(0)
      SetSliderDialogRange(-100, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iFWeightPunishRemote = (fValue As Int)
      SetSliderOptionValueST(iFWeightPunishRemote)
   EndEvent

   Event OnDefaultST()
      iFWeightPunishRemote = 0
      SetSliderOptionValueST(iFWeightPunishRemote)
   EndEvent

   Event OnHighlightST()
      SetInfoText("This weight is added to a peice of furniture if it is flagged as remote.")
   EndEvent
EndState

State ST_PUNISH_MIN_BEHAVIOUR_REMOTE
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iPunishMinBehaviourRemote)
      SetSliderDialogDefaultValue(5)
      SetSliderDialogRange(0, 25)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iPunishMinBehaviourRemote = (fValue As Int)
      SetSliderOptionValueST(iPunishMinBehaviourRemote)
   EndEvent

   Event OnDefaultST()
      iPunishMinBehaviourRemote = 5
      SetSliderOptionValueST(iPunishMinBehaviourRemote)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Remote furniture can take time to travel to.  It's not worth it time if the player will only be locked\n" +\
                  "up for a brief time.  This option can be used to prevent using Remote furniture for short punishments.\n" +\
                  "The unit is a measure of how badly the player is behaving (1 = roughly 3 minutes real time).")
   EndEvent
EndState


;***********************************************************************************************
;***                                 STATES: LOGGING + DEBUG                                 ***
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
      SendSettingChangedEvent("Mod")
   EndEvent

   Event OnDefaultST()
      iLogLevel = 5
      SetSliderOptionValueST(iLogLevel)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Mod")
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
      SetSliderDialogDefaultValue(_iLogLevelScreenDef)
      SetSliderDialogRange(0, 5)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iLogLevelScreen = (fValue As Int)
      SetSliderOptionValueST(iLogLevelScreen)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Mod")
   EndEvent

   Event OnDefaultST()
      iLogLevelScreen = _iLogLevelScreenDef
      SetSliderOptionValueST(iLogLevelScreen)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Mod")
   EndEvent

   Event OnHighlightST()
      SetInfoText("Set the level of messages that go to the screen.\n" +\
                  "(0 = Off)  (1 = Critical)  (2 = Error)  (3 = Information)  (4 = Debug)  (5 = Trace)\n" +\
                  "This should be Critical to reduce clutter on your screen but still get event messages.")
   EndEvent
EndState

State ST_DBG_UTIL_KEY
   Event OnKeyMapChangeST(Int iKeyCode, String sConflictControl, String sConflictName)
      ; Handle key registration here.  Events should be sent to all scripts in the same quest.
      If (iDbgUtilKey)
         UnregisterForKey(iDbgUtilKey)
      EndIf
      iDbgUtilKey = iKeyCode
      RegisterForKey(iDbgUtilKey)
      SetKeyMapOptionValueST(iDbgUtilKey)
   EndEvent

   Event OnDefaultST()
      If (iDbgUtilKey)
         UnregisterForKey(iDbgUtilKey)
      EndIf
      iDbgUtilKey = 0x00
      SetKeyMapOptionValueST(iDbgUtilKey)
   EndEvent

   Event OnHighlightST()
      SetInfoText("A utility key that can used to trigger user initiated features of the mod, such as\n" +\
                  "resetting the leash holder's AI package.\n" +\
                  "Recommended Key: \"\\\"  Set to default to turn off.")
   EndEvent
EndState

State ST_DBG_SHUTDOWN
   Event OnSelectST()
      bShutdownMod = !bShutdownMod
      SetToggleOptionValueST(bShutdownMod)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Mod")
   EndEvent

   Event OnDefaultST()
      bShutdownMod = False
      SetToggleOptionValueST(bShutdownMod)

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Mod")
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
                  "It should be safe to perform this upgrade.  If no upgrade is needed nothing will change.\n" +\
                  "Warning: You must exit the MCM menu after performing an upgrade (it will appear to freeze).")
   EndEvent
EndState

State ST_DBG_DUMP_VARS
   Event OnSelectST()
      SetTextOptionValueST("Please Wait...")
      _qDfwSupport.DebugDumpVariables()
      SetTextOptionValueST("Done")
   EndEvent

   Event OnDefaultST()
      SetTextOptionValueST("Dump Now")
   EndEvent

   Event OnHighlightST()
      SetInfoText("This prints key quest variables to the Papyrus log file.\n" +\
                  "If you need to get game state variable information to the mod author you can dump this information\n" +\
                  "to a file, locate the information in the file and send it to the mod author.\n" +\
                  "Search for \"DFWS_Variable_Dump\" in the file.")
   EndEvent
EndState

State ST_DBG_MOD_EVENTS
   Event OnSelectST()
      _qDfwSupport.ReRegisterModEvents()
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

State ST_DBG_FIX_MUTEXES
   Event OnSelectST()
      SetTextOptionValueST("Please Exit Menu...")
      String szMessage = _qDfwSupport.DebugFixMutexes()
   EndEvent

   Event OnDefaultST()
      SetTextOptionValueST("Fix Now")
   EndEvent

   Event OnHighlightST()
      SetInfoText("Mutexes should toggle on and off quickly.  If they become permanently set the feature they protect will\n" +\
                  "likely become unusable.  This scans each mutex for ten seconds each.  Any mutex that does not clear during\n" +\
                  "that ten seconds will be reset.  Each broken mutex will take 10 seconds but there shouldn't be more than one.")
   EndEvent
EndState

State ST_DBG_CYCLE_PACKAGE
   Event OnSelectST()
      bHotkeyPackage = !bHotkeyPackage
      SetToggleOptionValueST(bHotkeyPackage)
   EndEvent

   Event OnDefaultST()
      bHotkeyPackage = False
      SetToggleOptionValueST(bHotkeyPackage)
   EndEvent

   Event OnHighlightST()
      SetInfoText("When set the Utility hotkey will reset the leash holder's AI package.  Various scenes and\n" +\
                  "in game events cause the AI package to be reset which can causes discontinuity issues.\n" +\
                  "This option can be used to cycle back to a more desireable or seamless package.")
   EndEvent
EndState

State ST_DBG_CYCLE_MULTI_POSE
   Event OnSelectST()
      bHotkeyMultiPose = !bHotkeyMultiPose
      SetToggleOptionValueST(bHotkeyMultiPose)
   EndEvent

   Event OnDefaultST()
      bHotkeyMultiPose = False
      SetToggleOptionValueST(bHotkeyMultiPose)
   EndEvent

   Event OnHighlightST()
      SetInfoText("When sitting in a Zaz multi-pose furniture (pole or wall) if set\n" +\
                  "the Utility hotkey can be used to cycle to the next pose.\n" +\
                  "TBD: At time of creation this only stops pose cycling.")
   EndEvent
EndState

