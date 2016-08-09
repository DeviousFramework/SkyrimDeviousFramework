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

; Keeps track of the last page the user viewed.
String _szLastPage

; *** Private Options ***
Bool _bSecureHardcore

; *** Toggle Options ***
Bool _bIncludeOwners
Bool _bCatchZazEvents
Bool _bCatchSdPlus
Bool _bLeashSdPlus
Bool _bBlockHelpless
Bool _bAutoAddFurniture
Bool Property bIncludeOwners    Auto
Bool Property bCatchZazEvents   Auto
Bool Property bCatchSdPlus      Auto
Bool Property bLeashSdPlus      Auto
Bool Property bBlockHelpless    Auto
Bool Property bAutoAddFurniture Auto


; *** Float Slider Options ***
Float _fPollTimeDef
Float _fChanceFurnitureTransfer
Float _fLeashGameChanceDef
Float _fFurnitureLockChance
Float _fFurnitureReleaseChance
Float Property fPollTime                Auto
Float Property fChanceFurnitureTransfer Auto
Float Property fLeashGameChance         Auto
Float Property fFurnitureLockChance     Auto
Float Property fFurnitureReleaseChance  Auto

; *** Integer Slider Options ***
Int _iIncreaseWhenVulnerable
Int _iLeashLength
Int _iSecurityLevel
Int _iBlockTravel
Int _iFurnitureTeaseChance
Int _iFurnitureAltRelease
Int _iLogLevelDef
Int _iLogLevelScreenDef
Int _iDurationMin
Int _iDurationMax
Int _iChanceOfRelease
Int _iDominanceAffectsRelease
Int _iMaxAngerForRelease
Int _iChanceIdleRestraints
Int _iFurnitureMinLockTime
Int Property iIncreaseWhenVulnerable  Auto
Int Property iLeashLength             Auto
Int Property iBlockTravel             Auto
Int Property iFurnitureTeaseChance    Auto
Int Property iFurnitureAltRelease     Auto
Int Property iLogLevel                Auto
Int Property iLogLevelScreen          Auto
Int Property iDurationMin             Auto
Int Property iDurationMax             Auto
Int Property iChanceOfRelease         Auto
Int Property iDominanceAffectsRelease Auto
Int Property iMaxAngerForRelease      Auto
Int Property iChanceIdleRestraints    Auto
Int Property iFurnitureMinLockTime    Auto

; *** Enumeration Options ***

; *** Lists and Advanced Options ***

; A reference to the main DFW Support quest script.
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

   Debug.Notification("[DFWS-MCM] Updating Script: " + CurrentVersion + " => " + GetVersion())

   ; Very basic initialization.
   If (1 > CurrentVersion)
      _aPlayer = Game.GetPlayer()
      _qDfwSupport = ((Self As Quest) As dfwsDfwSupport)
      _qFramework = (Quest.GetQuest("_dfwDeviousFramework") As dfwDeviousFramework)
      _qDfwUtil = (Quest.GetQuest("_dfwDeviousFramework") As dfwUtil)
      _qDfwMcm = (Quest.GetQuest("_dfwDeviousFramework") As dfwMcm)

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
      _iLogLevelScreenDef       =   4
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
      iLogLevelScreen          = _iLogLevelScreenDef
      iDurationMin             = _iDurationMin
      iDurationMax             = _iDurationMax
      iChanceOfRelease         = _iChanceOfRelease
      iDominanceAffectsRelease = _iDominanceAffectsRelease
      iMaxAngerForRelease      = _iMaxAngerForRelease

      ; Set the Security level to the level of night vulnerability.
      ; The primary purpose of the security level is to allow changing settings at night.
      _iSecurityLevel = _qDfwMcm.iVulnerabilityNight
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
      Pages = New String[3]
      Pages[0] = "DFW Support"
      Pages[1] = "Leash Game"
      Pages[2] = "BDSM Furniture"

      _bAutoAddFurniture        = False
      _iFurnitureMinLockTime    = 30
      _bCatchSdPlus             = False
      _fChanceFurnitureTransfer = 1.0

      bAutoAddFurniture        = _bAutoAddFurniture
      iFurnitureMinLockTime    = _iFurnitureMinLockTime
      bCatchSdPlus             = _bCatchSdPlus
      fChanceFurnitureTransfer = _fChanceFurnitureTransfer
   EndIf
EndFunction

Event OnConfigInit()
   UpdateScript()

   ; Make sure the DFW Support main script is initialized.
   ; Do this here so the main script can rely on our data having been initialized first.
   _qDfwSupport.UpdateScript()
EndEvent

; Version of the MCM script.
; Unrelated to the Devious Framework Version.
Int Function GetVersion()
   ; Reset the version number.
   ; This can be used to manage saves between releases.
   ;If (4 < CurrentVersion)
   ;   CurrentVersion = 4
   ;EndIf

   Return 5
EndFunction

Event OnVersionUpdate(Int iNewVersion)
   UpdateScript()
EndEvent


;***********************************************************************************************
;***                                  PRIVATE FUNCTIONS                                      ***
;***********************************************************************************************
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

   AddSliderOptionST("ST_FWK_SECURE",         "Security Level",        _iSecurityLevel, a_flags=iFlags)
   AddToggleOptionST("ST_FWK_HARDCORE",       "...Hardcore (Caution)", _bSecureHardcore, a_flags=iFlags)

   AddEmptyOption()
   AddSliderOptionST("ST_FWK_POLL_TIME",      "Poll Time",             fPollTime, "{1}")
   AddSliderOptionST("ST_MOD_BLOCK_TRAVEL",   "Block Travel",          iBlockTravel, a_flags=iFlags)

   ; Start on the second column.
   SetCursorPosition(1)

   AddTextOption("DFW Support Version", _qDfwSupport.GetModVersion(), a_flags=OPTION_FLAG_DISABLED)

   AddEmptyOption()
   AddHeaderOption("Mod Compatibility")
   AddToggleOptionST("ST_MOD_ZAZ_EVENTS", "Catch ZAZ Events",          bCatchZazEvents, a_flags=iFlags)
   AddToggleOptionST("ST_MOD_SDP_EVENTS", "Catch SD+ Enslavement",     bCatchSdPlus, a_flags=iFlags)
   AddToggleOptionST("ST_MOD_SDP_LEASH",  "Start SD+ Leash",           bLeashSdPlus, a_flags=iFlags)

   ; Make sure the poll function is updating as expected.
   Float fDelta = Utility.GetCurrentRealTime() - _qDfwSupport.GetLastUpdateTime()
   If ((fPollTime * 3) < fDelta)
      AddEmptyOption()
      AddTextOption("Warning: Poll has Stopped!", "", a_flags=OPTION_FLAG_DISABLED)
      AddTextOption("Seconds Since Update", (fDelta As Int), a_flags=OPTION_FLAG_DISABLED)
   EndIf

   AddEmptyOption()

   AddSliderOptionST("ST_DBG_LEVEL",  "Log Level",        iLogLevel)
   AddSliderOptionST("ST_DBG_SCREEN", "Log Level Screen", iLogLevelScreen)
EndFunction

Function DisplayLeashGamePage(Bool bSecure)
   Int iFlags = OPTION_FLAG_NONE
   If (bSecure)
      iFlags = OPTION_FLAG_DISABLED
   EndIf

   AddHeaderOption("Chance to Play")
   AddSliderOptionST("ST_MOD_LEASH_GAME",     "Leash Game Chance",            fLeashGameChance, "{1}", a_flags=iFlags)
   AddSliderOptionST("ST_LGM_INC_VULNERABLE", "Increase When Vulnerable",     iIncreaseWhenVulnerable, a_flags=iFlags)
   AddToggleOptionST("ST_LGM_INCLUD_OWNERS",  "Include Owners",               bIncludeOwners, a_flags=iFlags)

   AddEmptyOption()
   AddSliderOptionST("ST_LGM_LEASH_LENGTH",   "Leash Length",                 iLeashLength, a_flags=iFlags)
   AddToggleOptionST("ST_LGM_BLOCK_HELPLESS", "Block Deviously Helpless",     bBlockHelpless, a_flags=iFlags)

   AddSliderOptionST("ST_LGM_CHANCE_IDLE",    "Chance of Idle Restraints",    iChanceIdleRestraints, a_flags=iFlags)
   AddSliderOptionST("ST_LGM_CHANCE_XFER",    "Chance of Furniture Transfer", fChanceFurnitureTransfer, a_flags=iFlags)

   ; Start on the second column.
   SetCursorPosition(1)

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
   AddHeaderOption("Duration")
   AddSliderOptionST("ST_LGM_DURATION_MIN",   "Minimum Duration",          iDurationMin, a_flags=iFlags)
   AddSliderOptionST("ST_LGM_DURATION_MAX",   "Maximum Duration",          iDurationMax, a_flags=iFlags)
   AddSliderOptionST("ST_LGM_CHANCE_RELEASE", "Chance of Release",         iChanceOfRelease, a_flags=iFlags)
   AddSliderOptionST("ST_LGM_RELEASE_DOM",    "Dominance Affects Release", iDominanceAffectsRelease, a_flags=iFlags)
   AddSliderOptionST("ST_LGM_RELEASE_ANGER",  "Maximum Anger for Release", iMaxAngerForRelease, a_flags=iFlags)
EndFunction

Function DisplayBdsmFurniturePage(Bool bSecure)
   Int iFlags = OPTION_FLAG_NONE
   If (bSecure)
      iFlags = OPTION_FLAG_DISABLED
   EndIf

   AddEmptyOption()
   AddHeaderOption("Chances")
   AddSliderOptionST("ST_BDSMF_LOCK",     "Chance of Locking", fFurnitureLockChance, "{1}", a_flags=iFlags)
   AddSliderOptionST("ST_BDSMF_RELEASE",  "Chance of Release", fFurnitureReleaseChance, "{1}", a_flags=iFlags)
   AddSliderOptionST("ST_BDSMF_TEASE",    "Teasing Chance",    iFurnitureTeaseChance, a_flags=iFlags)
   AddSliderOptionST("ST_BDSMF_ALT",      "Alternate Release", iFurnitureAltRelease, a_flags=iFlags)

   AddEmptyOption()
   AddHeaderOption("Options")
   AddSliderOptionST("ST_BDSMF_MIN_TIME", "Initial Lock Time", iFurnitureMinLockTime, a_flags=iFlags)

   ; Start on the second column.
   SetCursorPosition(1)
   AddHeaderOption("Favourites")
   ObjectReference oCurrFurniture = _qFramework.GetBdsmFurniture()
   If (oCurrFurniture)
      AddTextOptionST("ST_BDSMF_FAV",     "Add Favourite:",     oCurrFurniture.GetDisplayName())
   EndIf
   AddToggleOptionST("ST_BDSMF_AUTO_FAV", "Auto Add Favourite", bAutoAddFurniture, a_flags=iFlags)
   AddMenuOptionST("ST_BDSMF_AUTO_SHOW",  "Remove/View Favourite Furniture", "Open")
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
   EndEvent

   Event OnDefaultST()
      fPollTime = _fPollTimeDef
      SetSliderOptionValueST(fPollTime, "{1}")
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
      If (iBlockTravel != fValue)
         _qDfwSupport.UpdatePollingInterval(fValue)
      EndIf
      iBlockTravel = (fValue As Int)
      SetSliderOptionValueST(iBlockTravel)
   EndEvent

   Event OnDefaultST()
      iBlockTravel = _iBlockTravel
      SetSliderOptionValueST(iBlockTravel)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Block fast travel when at least this vulnerable.\n" +\
                  "0 = Always block.  1 = Always block when vulnerable.  100 = Never block.")
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
   EndEvent

   Event OnDefaultST()
      bCatchSdPlus = _bCatchSdPlus
      SetToggleOptionValueST(bCatchSdPlus)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Detect when the player becomes enslaved via the Sanguine Debaucherty Plus mod\n" +\
                  "and register the Master with the Devious Framework mod.")
   EndEvent
EndState

State ST_MOD_SDP_LEASH
   Event OnSelectST()
      bLeashSdPlus = !bLeashSdPlus
      SetToggleOptionValueST(bLeashSdPlus)
   EndEvent

   Event OnDefaultST()
      bLeashSdPlus = _bLeashSdPlus
      SetToggleOptionValueST(bLeashSdPlus)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Also start a DFW leash between the Sanguine Debauchery Master and the player when enslaved\n" +\
                  "and clear the leash when the player is released.")
   EndEvent
EndState

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
   EndEvent

   Event OnDefaultST()
      iLogLevel = _iLogLevelDef
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
      SetSliderDialogDefaultValue(_iLogLevelScreenDef)
      SetSliderDialogRange(0, 5)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iLogLevelScreen = (fValue As Int)
      SetSliderOptionValueST(iLogLevelScreen)
   EndEvent

   Event OnDefaultST()
      iLogLevelScreen = _iLogLevelScreenDef
      SetSliderOptionValueST(iLogLevelScreen)
   EndEvent

   Event OnHighlightST()
      SetInfoText("Set the level of messages that go to the screen.\n" +\
                  "(0 = Off)  (1 = Critical)  (2 = Error)  (3 = Information)  (4 = Debug)  (5 = Trace)\n" +\
                  "This should be Critical to reduce clutter on your screen but still get event messages.")
   EndEvent
EndState


;***********************************************************************************************
;***                                  STATES: LEASH GAME                                     ***
;***********************************************************************************************
State ST_MOD_LEASH_GAME
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
      SetSliderOptionValueST(fLeashGameChance)
   EndEvent

   Event OnDefaultST()
      fLeashGameChance = _fLeashGameChanceDef
      SetSliderOptionValueST(fLeashGameChance)
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
      SetSliderDialogRange(1, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iIncreaseWhenVulnerable = (fValue As Int)
      SetSliderOptionValueST(iIncreaseWhenVulnerable)
   EndEvent

   Event OnDefaultST()
      iIncreaseWhenVulnerable = _iIncreaseWhenVulnerable
      SetSliderOptionValueST(iIncreaseWhenVulnerable)
   EndEvent

   Event OnHighlightST()
      SetInfoText("The amout to increase chances of playing the leash game when vulnerable.\n" +\
                  "Current chances + (This chance * Vulnerability / 100)")
   EndEvent
EndState

State ST_LGM_INCLUD_OWNERS
   Event OnSelectST()
      bIncludeOwners = !bIncludeOwners
      SetToggleOptionValueST(bIncludeOwners)
   EndEvent

   Event OnDefaultST()
      bIncludeOwners = _bIncludeOwners
      SetToggleOptionValueST(bIncludeOwners)
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
      SetInfoText("The minimum length of time in real game minutes to play the leash game.\n" +\
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
      SetInfoText("The maximum amount the slaver's dominance value affects the player's chance of release.\n" +\
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
   EndEvent

   Event OnDefaultST()
      iChanceIdleRestraints = _iChanceIdleRestraints
      SetSliderOptionValueST(iChanceIdleRestraints)
   EndEvent

   Event OnHighlightST()
      SetInfoText("The chance the slaver will decorate the player as a slave once she is fully under control.\n" +\
                  "This does not affect when the slaver is initially trying to control the player or is angered or upset.\n" +\
                  "It only affects decorating the player once she is under control (collar, stripping, boots).")
   EndEvent
EndState

State ST_LGM_CHANCE_XFER
   Event OnSliderOpenST()
      SetSliderDialogStartValue(fChanceFurnitureTransfer)
      SetSliderDialogDefaultValue(_fChanceFurnitureTransfer)
      If (10 <= fChanceFurnitureTransfer)
         SetSliderDialogRange(0, 100)
         SetSliderDialogInterval(1)
      Else
         SetSliderDialogRange(0, 10)
         SetSliderDialogInterval(0.1)
      EndIf
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      fChanceFurnitureTransfer = fValue
      SetSliderOptionValueST(fChanceFurnitureTransfer)
   EndEvent

   Event OnDefaultST()
      fChanceFurnitureTransfer = _fChanceFurnitureTransfer
      SetSliderOptionValueST(fChanceFurnitureTransfer)
   EndEvent

   Event OnHighlightST()
      SetInfoText("The chance the slaver will lock the player up in nearby Favourite BDSM furniture and leave her.\n" +\
                  "This will only happen if they are in the same \"cell\" as the furniture.\n" +\
                  "This will only happen if the player is all locked up.")
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
      String sValue = "None"
      If ((!_qDfwSupport.IsGameOn()) && aNearest)
         sValue = aNearest.GetDisplayName()
      EndIf
      SetTextOptionValueST(sValue)
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
      SetSliderOptionValueST(fFurnitureLockChance)
   EndEvent

   Event OnDefaultST()
      fFurnitureLockChance = _fFurnitureLockChance
      SetSliderOptionValueST(fFurnitureLockChance)
   EndEvent

   Event OnHighlightST()
      SetInfoText("When sitting in unlocked BDSM furniture (a cross or pillory, etc.) this is the\n" +\
                  "chance (per poll event) that a nearby NPC will decide to lock the furniture.")
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
      SetSliderOptionValueST(fFurnitureReleaseChance)
   EndEvent

   Event OnDefaultST()
      fFurnitureReleaseChance = _fFurnitureReleaseChance
      SetSliderOptionValueST(fFurnitureReleaseChance)
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
   EndEvent

   Event OnDefaultST()
      iFurnitureAltRelease = _iFurnitureAltRelease
      SetSliderOptionValueST(iFurnitureAltRelease)
   EndEvent

   Event OnHighlightST()
      SetInfoText("If the original locker of the furniture is not nearby another neraby NPC may unlock the furniture.\n" +\
                  "The chance of an alternate NPC releasing the player is expressed as a percent of the \"Chance of Release\".\n" +\
                  "If \"Chance of Release\" is 10% and this is 10, there will be a 1% chance when the original locker is not nearby.")
   EndEvent
EndState

State ST_BDSMF_MIN_TIME
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iFurnitureMinLockTime)
      SetSliderDialogDefaultValue(_iFurnitureMinLockTime)
      SetSliderDialogRange(0, 360)
      SetSliderDialogInterval(1)
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

State ST_BDSMF_AUTO_SHOW
   Event OnMenuOpenST()
      Form[] aoFavourites = _qDfwSupport.GetFavouriteFurniture()
      Form[] aoCells      = _qDfwSupport.GetFavouriteCell()
      ; Create a new array to hold all of the options.
      Int iIndex = aoFavourites.Length - 1
      String[] aszOptions = Utility.CreateStringArray(iIndex + 2)
      aszOptions[0] = S_REM_NONE

      ; Add a text value for each slot to the option array.
      While (0 <= iIndex)
         ObjectReference oFurniture = (aoFavourites[iIndex] As ObjectReference)
         Cell oCell = (aoCells[iIndex] As Cell)
         aszOptions[iIndex + 1] = oFurniture.GetDisplayName() + " In " + oCell
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

