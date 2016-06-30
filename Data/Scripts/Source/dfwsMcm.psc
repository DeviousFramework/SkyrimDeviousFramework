Scriptname dfwsMcm extends SKI_ConfigBase
{Configuration script for the Devious Framework support mod.}

;***********************************************************************************************
; Mod: Devious Framework Support
;
; Script: MCM Menu
;
; Configuration script for the Devious Framework Support mod.
;
; Created by legume
;
; The devious framework support mod contains features that utilize the support functions of the
; Devious Framework (DFW) mod and pair well with the mod.  It also contains additional support
; features that help bridge the gap of other mods working with DFW until DFW can become more
; widely used.
; And, of course, it contains a few features that I find fun.
; There should be a mechanism to disable each feature of the mod individually.
;
; History:
; 1.0 2016-06-09 by legume
; Initial version.
;***********************************************************************************************

;***********************************************************************************************
;***                                      CONSTANTS                                          ***
;***********************************************************************************************

;***********************************************************************************************
;***                                      VARIABLES                                          ***
;***********************************************************************************************
; A local variable to store a reference to the player for faster access.
Actor _aPlayer

; *** Private Options ***
Bool _bSecureHardcore

; *** Toggle Options ***
Bool _bIncludeOwners
Bool _bCatchZazEvents
Bool _bCatchSdPlus
Bool _bLeashSdPlus
Bool Property bIncludeOwners Auto
Bool Property bCatchZazEvents Auto
Bool Property bCatchSdPlus Auto
Bool Property bLeashSdPlus Auto

; *** Float Slider Options ***
Float _fPollTimeDef
Float Property fPollTime Auto

; *** Integer Slider Options ***
Int _iLeashGameChanceDef
Int _iIncreaseWhenVulnerable
Int _iLeashLength
Int _iSecurityLevel
Int _iLogLevelDef
Int _iLogLevelScreenDef
Int Property iLeashGameChance        Auto
Int Property iIncreaseWhenVulnerable Auto
Int Property iLeashLength            Auto
Int Property iLogLevel               Auto
Int Property iLogLevelScreen         Auto

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
Function InitScript()
   ; Hardcore mode is turned off on all script updates.
   _bSecureHardcore = False

   Debug.Notification("[DFWS-MCM] Updating Script: " + CurrentVersion + " => " + GetVersion())

   ; Very basic initialization.
   If (1 > CurrentVersion)
      _aPlayer = Game.GetPlayer()
      _qDfwSupport = (Self As Quest) As dfwsDfwSupport
      _qFramework = Quest.GetQuest("_dfwDeviousFramework") As dfwDeviousFramework
      _qDfwUtil = Quest.GetQuest("_dfwDeviousFramework") As dfwUtil
      _qDfwMcm = Quest.GetQuest("_dfwDeviousFramework") As dfwMcm

      Pages = New String[1]
      Pages[0] = "DFW Support"
   EndIf

   ; Historical configuration...
   If (2 > CurrentVersion)
      ; Initialize all default values.
      _fPollTimeDef        = 3.0
      _iLeashGameChanceDef = 3
      _iLogLevelDef        = 5
      _iLogLevelScreenDef  = 4

      fPollTime = _fPollTimeDef
      iLeashGameChance = _iLeashGameChanceDef

      ; Set the Security level to the level of night vulnerability.
      ; The primary purpose of the security level is to allow changing settings at night.
      _iSecurityLevel = _qDfwMcm.iVulnerabilityNight

      iLogLevel       = _iLogLevelDef
      iLogLevelScreen = _iLogLevelScreenDef

      ; Make sure the main mod is also initialized.
      ; Note: This needs to be done after all basic configuration is done.
      _qDfwSupport .UpdateScript()
   EndIf

   If (3 > CurrentVersion)
      _iIncreaseWhenVulnerable = 10
      _bIncludeOwners          = False
      _iLeashLength            = 700
      _bCatchZazEvents         = True
      _bCatchSdPlus            = True
      _bLeashSdPlus            = False
      iIncreaseWhenVulnerable = _iIncreaseWhenVulnerable
      bIncludeOwners          = _bIncludeOwners
      iLeashLength            = _iLeashLength
      bCatchZazEvents         = _bCatchZazEvents
      bCatchSdPlus            = _bCatchSdPlus
      bLeashSdPlus            = _bLeashSdPlus
   EndIf
EndFunction


Event OnConfigInit()
   InitScript()
EndEvent

; Version of the MCM script.
; Unrelated to the Devious Framework Version.
Int Function GetVersion()
   ; Reset the version number.
   ; CurrentVersion = 0

   Return 3
EndFunction

Event OnVersionUpdate(Int iNewVersion)
   InitScript()
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
Event OnPageReset(String szPage)
   {Called when a new page is selected, including the initial empty page}

   ; On the menu being opened reset the debug mechanism.
   _bDebug = True

   ; Find out if the settings should be secure (Unmodifiable when Vulnerable).
   Bool bSecure = IsSecure()

   ; Unless overridden by each page fill mode is top to bottom.
   SetCursorFillMode(TOP_TO_BOTTOM)

   ; For now there is only one page, "DFW Support"
   DisplayDfwSupportPage(bSecure)
EndEvent

Function DisplayDfwSupportPage(Bool bSecure)
   Int iFlags = OPTION_FLAG_NONE
   If (bSecure)
      iFlags = OPTION_FLAG_DISABLED
   EndIf

   AddTextOption("DFW Support Version", _qDfwSupport.GetModVersion(), a_flags=OPTION_FLAG_DISABLED)

   AddEmptyOption()
   AddSliderOptionST("ST_FWK_SECURE",         "Security Level",           _iSecurityLevel, a_flags=iFlags)
   AddToggleOptionST("ST_FWK_HARDCORE",       "...Hardcore (Caution)",    _bSecureHardcore, a_flags=iFlags)
   AddEmptyOption()
   AddSliderOptionST("ST_FWK_POLL_TIME",      "Poll Time",                fPollTime, "{1}")
   AddSliderOptionST("ST_MOD_LEASH_GAME",     "Leash Game Chance",        iLeashGameChance, a_flags=iFlags)
   AddSliderOptionST("ST_LGM_INC_VULNERABLE", "Increase When Vulnerable", iIncreaseWhenVulnerable, a_flags=iFlags)
   AddToggleOptionST("ST_LGM_INCLUD_OWNERS",  "Include Owners",           bIncludeOwners, a_flags=iFlags)
   AddSliderOptionST("ST_LGM_LEASH_LENGTH",   "Leash Length",             iLeashLength, a_flags=iFlags)
   AddEmptyOption()

   String szActive = "Not On"
   If (_qDfwSupport.IsGameOn())
      szActive = "Active"
   EndIf
   AddTextOption("Leash Game", szActive, a_flags=OPTION_FLAG_DISABLED)

   Actor aNearest = _qFramework.GetNearestActor()
   If ((!_qDfwSupport.IsGameOn()) && aNearest)
      AddTextOptionST("ST_LEASH_TO", "Start Leash Game:", aNearest.GetDisplayName())
   EndIf

   ; Start on the second column.
   SetCursorPosition(1)

   AddToggleOptionST("ST_MOD_ZAZ_EVENTS", "Catch ZAZ Events",      bCatchZazEvents, a_flags=iFlags)
   AddToggleOptionST("ST_MOD_SDP_EVENTS", "Catch SD+ Enslavement", bCatchSdPlus, a_flags=iFlags)
   AddToggleOptionST("ST_MOD_SDP_LEASH",  "Start SD+ Leash",       bLeashSdPlus, a_flags=iFlags)
      bCatchSdPlus            = _bCatchSdPlus
      bLeashSdPlus            = _bLeashSdPlus

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
      _iSecurityLevel = fValue As Int
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


;***********************************************************************************************
;***                                STATES: VULNERABILITY                                    ***
;***********************************************************************************************

;***********************************************************************************************
;***                                 STATES: MOD FEATURES                                    ***
;***********************************************************************************************
State ST_MOD_LEASH_GAME
   Event OnSliderOpenST()
      SetSliderDialogStartValue(iLeashGameChance)
      SetSliderDialogDefaultValue(_iLeashGameChanceDef)
      SetSliderDialogRange(0, 100)
      SetSliderDialogInterval(1)
   EndEvent

   Event OnSliderAcceptST(Float fValue)
      iLeashGameChance = fValue As Int
      SetSliderOptionValueST(iLeashGameChance)
   EndEvent

   Event OnDefaultST()
      iLeashGameChance = _iLeashGameChanceDef
      SetSliderOptionValueST(iLeashGameChance)
   EndEvent

   Event OnHighlightST()
      SetInfoText("A very rudamentary leash game.  When you encounter slavers they may drag you around for a time.\n" +\
                  "Requires \"slave traders\".  Currently only Slave Girls by hydragorgon slavers are supported.\n" +\
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
      iIncreaseWhenVulnerable = fValue As Int
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
      iLeashLength = fValue As Int
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
      iLogLevel = fValue As Int
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
      iLogLevelScreen = fValue As Int
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

