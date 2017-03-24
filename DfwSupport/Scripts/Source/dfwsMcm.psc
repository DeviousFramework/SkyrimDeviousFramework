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

; *** Private Options ***
Bool _bSecureHardcore
Bool _bSecureSdPlusLeash

; *** Toggle Options ***
Bool _bIncludeOwners
Bool _bWalkToSsAuction
Bool _bWalkFarSsAuction
Bool _bSexDispositions
Bool _bCatchZazEvents
Bool _bCatchSdPlus
Bool _bLeashSdPlus
Bool _bBlockHelpless
Bool _bAllowSex
Bool _bFurnitureHide
Bool _bAutoAddFurniture
Bool _bHotkeyPackage
Bool Property bIncludeOwners    Auto
Bool Property bWalkToSsAuction  Auto
Bool Property bWalkFarSsAuction Auto
Bool Property bSexDispositions  Auto
Bool Property bCatchZazEvents   Auto
Bool Property bCatchSdPlus      Auto
Bool Property bLeashSdPlus      Auto
Bool Property bBlockHelpless    Auto
Bool Property bAllowSex         Auto
Bool Property bFurnitureHide    Auto
Bool Property bAutoAddFurniture Auto
Bool Property bHotkeyPackage    Auto

; *** Float Slider Options ***
Float _fPollTimeDef
Float _fLeashGameChanceDef
Float _fFurnitureLockChance
Float _fFurnitureReleaseChance
Float Property fPollTime                Auto
Float Property fLeashGameChance         Auto
Float Property fFurnitureLockChance     Auto
Float Property fFurnitureReleaseChance  Auto
Float Property fFurnitureVisitorChance  Auto

; *** Integer Slider Options ***
Int _iLeashGameStyle
Int _iLeashProtectedDelay
Int _iIncreaseWhenVulnerable
Int _iMaxDistance
Int _iLeashLength
Int _iLeashResist
Int _iSecurityLevel
Int _iBlockTravel
Int _iGagMode
Int _iFurnitureTeaseChance
Int _iFurnitureAltRelease
Int _iLogLevelDef
Int _iLogLevelScreenDef
Int _iDurationMin
Int _iDurationMax
Int _iChanceOfRelease
Int _iDominanceAffectsRelease
Int _iMaxAngerForRelease
Int _iChanceFurnitureTransfer
Int _iLeashChanceSimple
Int _iChanceIdleRestraints
Int _iFurnitureMinLockTime
Int Property iLeashGameStyle          Auto
Int Property iLeashChanceToNotice     Auto
Int Property iLeashProtectedDelay     Auto
Int Property iIncreaseWhenVulnerable  Auto
Int Property iMaxDistance             Auto
Int Property iLeashLength             Auto
Int Property iLeashResist             Auto
Int Property iBlockTravel             Auto
Int Property iGagMode                 Auto
Int Property iFurnitureTeaseChance    Auto
Int Property iFurnitureAltRelease     Auto
Int Property iLogLevel                Auto
Int Property iLogLevelScreen          Auto
Int Property iDurationMin             Auto
Int Property iDurationMax             Auto
Int Property iChanceOfRelease         Auto
Int Property iDominanceAffectsRelease Auto
Int Property iMaxAngerForRelease      Auto
Int Property iChanceFurnitureTransfer Auto
Int Property iLeashChanceSimple       Auto
Int Property iChanceIdleRestraints    Auto
Int Property iChanceForAssistance     Auto
Int Property iEscapeDetection         Auto
Int Property iFurnitureMinLockTime    Auto

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
Function UpdateScript()
   ; Hardcore mode is turned off on all script updates.
   _bSecureHardcore = False
   _bSecureSdPlusLeash = False

   Debug.Trace("[DFWS-MCM] Updating Script: " + CurrentVersion + " => " + GetVersion())
   Debug.Notification("[DFWS-MCM] Updating Script: " + CurrentVersion + " => " + GetVersion())

   ; Very basic initialization.
   If (1 > CurrentVersion)
      _aPlayer = Game.GetPlayer()
      _qFramework  = (Quest.GetQuest("_dfwDeviousFramework") As dfwDeviousFramework)
      _qDfwSupport = ((Self As Quest) As dfwsDfwSupport)
      _qDfwUtil    = (Quest.GetQuest("_dfwDeviousFramework") As dfwUtil)
      _qDfwMcm     = (Quest.GetQuest("_dfwDeviousFramework") As dfwMcm)
   EndIf

   ; Historical configuration...
   If (2 > CurrentVersion)
      ; Initialize all default values.
      _bIncludeOwners           = False
      _bCatchZazEvents          = True
      _bLeashSdPlus             = False
      _fPollTimeDef             =   3.0
      _iIncreaseWhenVulnerable  =  10
      _iLeashLength             = 700
      _iBlockTravel             =   1
      _iLogLevelDef             =   5
      _iDurationMin             =   5
      _iDurationMax             =  15
      _iChanceOfRelease         =  50
      _iDominanceAffectsRelease =  45
      _iMaxAngerForRelease      =  50

      bIncludeOwners           = _bIncludeOwners
      bCatchZazEvents          = _bCatchZazEvents
      bLeashSdPlus             = _bLeashSdPlus
      fPollTime                = _fPollTimeDef
      iIncreaseWhenVulnerable  = _iIncreaseWhenVulnerable
      iLeashLength             = _iLeashLength
      iBlockTravel             = _iBlockTravel
      iLogLevel                = _iLogLevelDef
      iDurationMin             = _iDurationMin
      iDurationMax             = _iDurationMax
      iChanceOfRelease         = _iChanceOfRelease
      iDominanceAffectsRelease = _iDominanceAffectsRelease
      iMaxAngerForRelease      = _iMaxAngerForRelease
   EndIf

   If (3 > CurrentVersion)
      _iChanceIdleRestraints   = 10
      _fFurnitureReleaseChance =  1
      _iFurnitureTeaseChance   = 75
      _iFurnitureAltRelease    = 20
      _bBlockHelpless          = False

      iChanceIdleRestraints   = _iChanceIdleRestraints
      fFurnitureReleaseChance = _fFurnitureReleaseChance
      iFurnitureTeaseChance   = _iFurnitureTeaseChance
      iFurnitureAltRelease    = _iFurnitureAltRelease
      bBlockHelpless          = _bBlockHelpless
   EndIf

   If (4 > CurrentVersion)
      _fLeashGameChanceDef  =   3.0
      _fFurnitureLockChance =  5.0
      fLeashGameChance      = _fLeashGameChanceDef
      fFurnitureLockChance  = _fFurnitureLockChance
   EndIf

   If (5 > CurrentVersion)
      _bAutoAddFurniture     = False
      _iFurnitureMinLockTime = 30
      _bCatchSdPlus          = False

      bAutoAddFurniture     = _bAutoAddFurniture
      iFurnitureMinLockTime = _iFurnitureMinLockTime
      bCatchSdPlus          = _bCatchSdPlus
   EndIf

   If (6 > CurrentVersion)
      ; Set the Security level to the maximum.  This does not prevent settings to be changed
      ; when installing the mod into games where the player is already vulnerable.
      _iSecurityLevel = 100

      _iLogLevelScreenDef = 2
      iLogLevelScreen     = _iLogLevelScreenDef
   EndIf

   If (7 > CurrentVersion)
      _bSexDispositions = True
      bSexDispositions = _bSexDispositions
   EndIf

   If (8 > CurrentVersion)
      Pages = New String[4]
      Pages[0] = "DFW Support"
      Pages[1] = "Leash Game"
      Pages[2] = "BDSM Furniture"
      Pages[3] = "Logging + Debug"

      _bAllowSex            = False
      _bHotkeyPackage       = False
      _iGagMode             = 1
      _iLeashGameStyle      = 2
      _iLeashProtectedDelay = 0
      _iMaxDistance         = 2000

      bAllowSex             = _bAllowSex
      bHotkeyPackage        = _bHotkeyPackage
      iGagMode              = _iGagMode
      iLeashGameStyle       = _iLeashGameStyle
      iLeashProtectedDelay  = _iLeashProtectedDelay
      iMaxDistance          = _iMaxDistance
   EndIf

   If (9 > CurrentVersion)
      _iChanceFurnitureTransfer = 25
      _iLeashChanceSimple       = 10
      _bWalkToSsAuction         = True

      iChanceFurnitureTransfer = _iChanceFurnitureTransfer
      iLeashChanceSimple       = _iLeashChanceSimple
      bWalkToSsAuction         = _bWalkToSsAuction
   EndIf

   If (10 > CurrentVersion)
      _bWalkFarSsAuction = True
      bWalkFarSsAuction  = _bWalkFarSsAuction
   EndIf

   If (11 > CurrentVersion)
      _bFurnitureHide = True
      bFurnitureHide  = _bFurnitureHide
   EndIf

   If (12 > CurrentVersion)
      _iLeashResist = 3
      iLeashResist  = _iLeashResist
   EndIf

   If (13 > CurrentVersion)
      iLeashChanceToNotice    = 95
      iChanceForAssistance    = 75
      iEscapeDetection        = 10
      fFurnitureVisitorChance = 1.0
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
   ;If (12 < CurrentVersion)
   ;   CurrentVersion = 12
   ;EndIf

   ; Update all quest variables upon loading each game.
   ; There are too many things that can cause them to become invalid.
   _qFramework  = (Quest.GetQuest("_dfwDeviousFramework") As dfwDeviousFramework)
   _qDfwSupport = ((Self As Quest) As dfwsDfwSupport)
   _qDfwUtil    = (Quest.GetQuest("_dfwDeviousFramework") As dfwUtil)
   _qDfwMcm     = (Quest.GetQuest("_dfwDeviousFramework") As dfwMcm)

   Return 13
EndFunction

Event OnConfigInit()
   Debug.Trace("[DFWS-MCM] Script Initialized.")

   If (!_bInitBegun)
      _bInitBegun = True
      UpdateScript()
   EndIf
EndEvent

Event OnVersionUpdate(Int iNewVersion)
   If (!_bInitBegun)
      _bInitBegun = True
      UpdateScript()
   EndIf
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
   AddSliderOptionST("ST_FWK_POLL_TIME",       "Poll Time",             fPollTime, "{1}")
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
   AddSliderOptionST("ST_LGM_LEASH_GAME",     "Leash Game Chance",            fLeashGameChance, "{1}", a_flags=iFlags)
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

   AddHeaderOption("Chances")
   AddSliderOptionST("ST_BDSMF_LOCK",     "Chance of Locking",  fFurnitureLockChance,    "{1}", a_flags=iFlags)
   AddSliderOptionST("ST_BDSMF_RELEASE",  "Chance of Release",  fFurnitureReleaseChance, "{1}", a_flags=iFlags)
   AddSliderOptionST("ST_BDSMF_TEASE",    "Teasing Chance",     iFurnitureTeaseChance,   a_flags=iFlags)
   AddSliderOptionST("ST_BDSMF_ALT",      "Alternate Release",  iFurnitureAltRelease,    a_flags=iFlags)
   AddSliderOptionST("ST_BDSMF_VISITOR",  "Chance of Visitors", fFurnitureVisitorChance, "{1}", a_flags=iFlags)

   AddEmptyOption()
   AddHeaderOption("Options")
   AddSliderOptionST("ST_BDSMF_MIN_TIME", "Initial Lock Time",         iFurnitureMinLockTime, a_flags=iFlags)
   AddToggleOptionST("ST_BDSMF_HIDE",     "Hide Furniture During Sex", bFurnitureHide)

   ; Start on the second column.
   SetCursorPosition(1)
   AddHeaderOption("Favourites")
   ObjectReference oCurrFurniture = _qFramework.GetBdsmFurniture()
   If (oCurrFurniture)
      AddTextOptionST("ST_BDSMF_FAV",     "Add Favourite:",     oCurrFurniture.GetDisplayName())
   EndIf
   AddToggleOptionST("ST_BDSMF_AUTO_FAV", "Auto Add Favourite", bAutoAddFurniture, a_flags=iFlags)
   AddMenuOptionST("ST_BDSMF_SHOW_LIST",  "Remove/View Favourite Furniture", "Open")
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

   AddTextOptionST("ST_DBG_MOD_EVENTS",      "Fix Mod Events",              "Fix Now")
   AddToggleOptionST("ST_DBG_CYCLE_PACKAGE", "Hotkey Cycle Slaver Package", bHotkeyPackage)
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
      SetSliderDialogDefaultValue(_fPollTimeDef)
      SetSliderDialogRange(1, 10)
      SetSliderDialogInterval(0.5)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      If (fPollTime != fValue)
         _qDfwSupport.UpdatePollingInterval(fValue)
      EndIf
      fPollTime = fValue
      SetSliderOptionValueST(fPollTime, "{1}")

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Mod")
   EndEvent

   Event OnDefaultST()
      fPollTime = _fPollTimeDef
      SetSliderOptionValueST(fPollTime, "{1}")

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
      SetSliderDialogDefaultValue(_iBlockTravel)
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
      iBlockTravel = _iBlockTravel
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
      bSexDispositions = _bSexDispositions
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
      bCatchZazEvents = _bCatchZazEvents
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
      bCatchSdPlus = _bCatchSdPlus
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
      bLeashSdPlus = _bLeashSdPlus
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
      SendSettingChangedEvent("Compatability")
   EndEvent

   Event OnDefaultST()
      iGagMode = _iGagMode
      SetTextOptionValueST(GagModeToString(iGagMode))

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Compatability")
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
      iLeashGameStyle = _iLeashGameStyle
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
      SetSliderDialogDefaultValue(_iLeashProtectedDelay)
      SetSliderDialogRange(0, 3000)
      SetSliderDialogInterval(100)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iLeashProtectedDelay = (fValue As Int)
      SetSliderOptionValueST(iLeashProtectedDelay, "{0}ms")
   EndEvent

   Event OnDefaultST()
      iLeashProtectedDelay = _iLeashProtectedDelay
      SetSliderOptionValueST(iLeashProtectedDelay, "{0}ms")
   EndEvent

   Event OnHighlightST()
      SetInfoText("Add a delay while starting a protected leash game making it easier to defend against.")
   EndEvent
EndState

State ST_LGM_LEASH_GAME
   Event OnSliderOpenST()
      SetSliderDialogStartValue(fLeashGameChance)
      SetSliderDialogDefaultValue(_fLeashGameChanceDef)
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
      SetSliderOptionValueST(fLeashGameChance, "{1}")

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Leash")
   EndEvent

   Event OnDefaultST()
      fLeashGameChance = _fLeashGameChanceDef
      SetSliderOptionValueST(fLeashGameChance, "{1}")

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
      SetSliderDialogDefaultValue(_iIncreaseWhenVulnerable)
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
      iIncreaseWhenVulnerable = _iIncreaseWhenVulnerable
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
      SetSliderDialogDefaultValue(_iMaxDistance)
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
      iMaxDistance = _iMaxDistance
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
      bIncludeOwners = _bIncludeOwners
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
      SetSliderDialogDefaultValue(_iLeashLength)
      SetSliderDialogRange(100, 1200)
      SetSliderDialogInterval(10)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iLeashLength = (fValue As Int)
      SetSliderOptionValueST(iLeashLength)
   EndEvent

   Event OnDefaultST()
      iLeashLength = _iLeashLength
      SetSliderOptionValueST(iLeashLength)
   EndEvent

   Event OnHighlightST()
      SetInfoText("The length of the player's leash.\n" +\
                  "Only set at the start of the leash game.\n" +\
                  "Warning: Many values are untested.  If unsure leave at " + _iLeashLength + ".")
   EndEvent
EndState

State ST_LGM_LEASH_RESIST
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iLeashResist)
      SetSliderDialogDefaultValue(_iLeashResist)
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
      iLeashResist = _iLeashResist
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
      bBlockHelpless = _bBlockHelpless
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
      bAllowSex = _bAllowSex
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
      SetSliderDialogDefaultValue(_iDurationMin)
      SetSliderDialogRange(1, iDurationMax)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iDurationMin = (fValue As Int)
      SetSliderOptionValueST(iDurationMin)
   EndEvent

   Event OnDefaultST()
      iDurationMin = _iDurationMin
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
      SetSliderDialogDefaultValue(_iDurationMax)
      SetSliderDialogRange(iDurationMin, 600)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iDurationMax = (fValue As Int)
      SetSliderOptionValueST(iDurationMax)
   EndEvent

   Event OnDefaultST()
      iDurationMax = _iDurationMax
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
      SetSliderDialogDefaultValue(_iChanceOfRelease)
      SetSliderDialogRange(0, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iChanceOfRelease = (fValue As Int)
      SetSliderOptionValueST(iChanceOfRelease)
   EndEvent

   Event OnDefaultST()
      iChanceOfRelease = _iChanceOfRelease
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
      SetSliderDialogDefaultValue(_iDominanceAffectsRelease)
      SetSliderDialogRange(0, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iDominanceAffectsRelease = (fValue As Int)
      SetSliderOptionValueST(iDominanceAffectsRelease)
   EndEvent

   Event OnDefaultST()
      iDominanceAffectsRelease = _iDominanceAffectsRelease
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
      SetSliderDialogDefaultValue(_iMaxAngerForRelease)
      SetSliderDialogRange(0, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iMaxAngerForRelease = (fValue As Int)
      SetSliderOptionValueST(iMaxAngerForRelease)
   EndEvent

   Event OnDefaultST()
      iMaxAngerForRelease = _iMaxAngerForRelease
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
      SetSliderDialogDefaultValue(_iChanceIdleRestraints)
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
      iChanceIdleRestraints = _iChanceIdleRestraints
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
      SetSliderDialogDefaultValue(_iChanceFurnitureTransfer)
      SetSliderDialogRange(0, (100 - iLeashChanceSimple))
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iChanceFurnitureTransfer = (fValue As Int)
      SetSliderOptionValueST(iChanceFurnitureTransfer)
   EndEvent

   Event OnDefaultST()
      iChanceFurnitureTransfer = _iChanceFurnitureTransfer
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
      SetSliderDialogDefaultValue(_iLeashChanceSimple)
      SetSliderDialogRange(0, (100 - iChanceFurnitureTransfer))
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iLeashChanceSimple = (fValue As Int)
      SetSliderOptionValueST(iLeashChanceSimple)
   EndEvent

   Event OnDefaultST()
      iLeashChanceSimple = _iLeashChanceSimple
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
      bWalkToSsAuction = _bWalkToSsAuction
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
      bWalkFarSsAuction = _bWalkFarSsAuction
      SetToggleOptionValueST(bWalkFarSsAuction)
   EndEvent

   Event OnHighlightST()
      SetInfoText("When walking to Simple Slavery auctions the slaver will walk from nearby towns as well.\n" +\
                  "The slaver will walk to Riften from towns as far away as Riverwood and Windhelm.")
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
      SetSliderDialogDefaultValue(_fFurnitureLockChance)
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
      SetSliderOptionValueST(fFurnitureLockChance, "{1}")
   EndEvent

   Event OnDefaultST()
      fFurnitureLockChance = _fFurnitureLockChance
      SetSliderOptionValueST(fFurnitureLockChance, "{1}")
   EndEvent

   Event OnHighlightST()
      SetInfoText("When sitting in unlocked BDSM furniture (a cross or pillory, etc.) this is the\n" +\
                  "chance (per poll event) a nearby NPC will decide to lock the furniture.")
   EndEvent
EndState

State ST_BDSMF_RELEASE
   Event OnSliderOpenST()
      SetSliderDialogStartValue(fFurnitureReleaseChance)
      SetSliderDialogDefaultValue(_fFurnitureReleaseChance)
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
      SetSliderOptionValueST(fFurnitureReleaseChance, "{1}")

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Furniture")
   EndEvent

   Event OnDefaultST()
      fFurnitureReleaseChance = _fFurnitureReleaseChance
      SetSliderOptionValueST(fFurnitureReleaseChance, "{1}")

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
      SetSliderDialogDefaultValue(_iFurnitureTeaseChance)
      SetSliderDialogRange(0, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iFurnitureTeaseChance = (fValue As Int)
      SetSliderOptionValueST(iFurnitureTeaseChance)
   EndEvent

   Event OnDefaultST()
      iFurnitureTeaseChance = _iFurnitureTeaseChance
      SetSliderOptionValueST(iFurnitureTeaseChance)
   EndEvent

   Event OnHighlightST()
      SetInfoText("The % chance the NPC is teasing the player each time he lets her go.")
   EndEvent
EndState

State ST_BDSMF_ALT
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iFurnitureAltRelease)
      SetSliderDialogDefaultValue(_iFurnitureAltRelease)
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
      iFurnitureAltRelease = _iFurnitureAltRelease
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
      SetSliderOptionValueST(fFurnitureVisitorChance, "{1}")

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Furniture")
   EndEvent

   Event OnDefaultST()
      fFurnitureVisitorChance = 1.0
      SetSliderOptionValueST(fFurnitureVisitorChance, "{1}")

      ; This setting is mirrored by the main script.  Send an event to indicate it must be updated.
      SendSettingChangedEvent("Furniture")
   EndEvent

   Event OnHighlightST()
      SetInfoText("If locked in BDSM furniture this is the chance (per poll event) that\n" +\
                  "someone will come by wanting to play with you.")
   EndEvent
EndState

State ST_BDSMF_MIN_TIME
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iFurnitureMinLockTime)
      SetSliderDialogDefaultValue(_iFurnitureMinLockTime)
      SetSliderDialogRange(0, 360)
      SetSliderDialogInterval(5)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iFurnitureMinLockTime = (fValue As Int)
      SetSliderOptionValueST(iFurnitureMinLockTime)
   EndEvent

   Event OnDefaultST()
      iFurnitureMinLockTime = _iFurnitureMinLockTime
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
      bFurnitureHide = _bFurnitureHide
      SetToggleOptionValueST(bFurnitureHide)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Hide BDSM furniture the player is sitting in during sex scenes.")
   EndEvent
EndState

State ST_BDSMF_FAV
   Event OnSelectST()
      _qDfwSupport.FavouriteCurrentFurniture()
      SetTextOptionValueST("Done")
   EndEvent

   Event OnDefaultST()
      ObjectReference oCurrFurniture = _qFramework.GetBdsmFurniture()
      String sValue = "None"
      If (oCurrFurniture)
         sValue = oCurrFurniture.GetDisplayName()
      EndIf
      SetTextOptionValueST(sValue)
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
      bAutoAddFurniture = _bAutoAddFurniture
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

      ; Adjust the chosen index since the "Remove None" is no longer in the list.
      iChosenIndex -= 1
 
      _qDfwSupport.RemoveFavourite(iChosenIndex)
   EndEvent

   Event OnHighlightST()
      SetInfoText("View the list of favourited furniture and remove one if desired.")
   EndEvent
EndState

;***********************************************************************************************
;***                                 STATES: LOGGING + DEBUG                                 ***
;***********************************************************************************************
State ST_DBG_LEVEL
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iLogLevel)
      SetSliderDialogDefaultValue(_iLogLevelDef)
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
      iLogLevel = _iLogLevelDef
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

State ST_DBG_CYCLE_PACKAGE
   Event OnSelectST()
      bHotkeyPackage = !bHotkeyPackage
      SetToggleOptionValueST(bHotkeyPackage)
   EndEvent

   Event OnDefaultST()
      bHotkeyPackage = _bHotkeyPackage
      SetToggleOptionValueST(bHotkeyPackage)
   EndEvent

   Event OnHighlightST()
      SetInfoText("When set the \"Call for Attention\" hotkey will reset the leash holder's AI package.\n" +\
                  "Zaz Animations scenes cause the AI package to be reset which can causes discontinuity issues.\n" +\
                  "This option can be used to cycle back to a more desireable package.")
   EndEvent
EndState

