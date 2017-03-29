Scriptname dfwsDfwSupport extends Quest Conditional
{An add-on mod for the Devious Framework mod.
 It helps the Framework work with other mods and adds a few little features to the game.}

;***********************************************************************************************
; Mod: DFW Support
;
; Script: Main Mod Script
;
; The primary external function set for the devious framework support mod.
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
; Notes:
; _qZadLibs.GetWornDevice() can be a very slow function.  Try to avoid using this.
;
; History:
; 1.0 2016-06-10 by legume
; Initial version.
;***********************************************************************************************

;***********************************************************************************************
;***                                      CONSTANTS                                          ***
;***********************************************************************************************
String S_MOD = "DFWS"
String S_MOD_SD = "SD+"

; Standard status constants.
Int FAIL    = -1
Int SUCCESS = 0
Int WARNING = 1

; Debug Level (DL_) constants.
Int DL_NONE  = 0
Int DL_CRIT  = 1    ; Critical messages
Int DL_ERROR = 2    ; Error messages
Int DL_INFO  = 3    ; Information messages
Int DL_DEBUG = 4    ; Debug messages
Int DL_TRACE = 5    ; Trace of everything that is happenning


;***********************************************************************************************
;***                                      VARIABLES                                          ***
;***********************************************************************************************
; A local variable to store a reference to the player for faster access.
Actor _aPlayer

; Version control for this script.
; Note: This is versioning control for the script.  It is unrelated to the mod version.
Float _fCurrVer = 0.00

; A flag to prevent initialization from happening twice.
Bool _bGameLoadInProgress

; A reference to the MCM quest script.
dfwsMcm _qMcm

; A reference to the main framework quest script.
dfwDeviousFramework _qFramework

; A reference to the Devious Framework Util quest script.
dfwUtil _qDfwUtil

; A reference to the SexLab Framework quest script.
SexLabFramework _qSexLab

; A reference to the ZAZ Animation Pack (ZBF) slave control APIs.
zbfBondageShell _qZbfShell
zbfSlaveControl _qZbfSlave
zbfSlaveActions _qZbfSlaveActions

; A reference to the Devious Devices quest, Zadlibs.
Zadlibs _qZadLibs
zadHeavyBondageQuestScript _qZadArmbinder

; A reference to the basic "gold" item.
MiscObject _oGold

; A set of variables to manage mutexes.
Int[] _aiMutex
String[] _aszMutexName
Int _iMutexNext

; Lists of different restraints to use.  At least for now, Gags and Arm Restraints come from
; Devious Devices.
Armor[] _aoGags
Armor[] _aoArmRestraints
Armor[] _aoLegRestraints
Armor[] _aoCollars
Armor[] _aoBlindfolds
Form[] _aoFavouriteFurniture
Form[] _aoFavouriteCell
Form[] _aoFavouriteLocation
Form[] _aoFavouriteRegion

; Lists of different Simple Slavery slave auction sites.
Location[] _aoSimpleSlaveryRegion
Location[] _aoSimpleSlaveryLocation
ObjectReference[] _aoSimpleSlaveryEntranceObject

; Internal objects in the simple slavery auction house.
ObjectReference _oSimpleSlaveryInternalDoor
Actor _aSimpleSlaveryAuctioneer

; Quest Alias References.
; TODO: These could probably be script variables filled using GetAlias(iAliasId).
ReferenceAlias Property _aAliasLeashHolder     Auto
ReferenceAlias Property _aAliasLastLeashHolder Auto
ReferenceAlias _aAliasFurnitureLocker

; A crime faction for the leash target so he can be protected if the player assaults him.
Faction _oFactionLeashTargetCrime

; This is the short term goal of the leash holder.
; What he is trying to accomplish via dialogue or his own actions.
; <0: Delay after last goal       0: No goal                 1: Diarm player
;  2: Undress player (armour)     3: Take player weapons     4: Lock player's hands
;  5: Undress player fully        6: Gag player              7: Walk behind the slaver
;  8: Restrain the player         9: Reel in the Player     10: Discipline Talking Escape
; 11: Punish/Leave in Furniture  12: Approach for Interest  13: Lying About Release
; 14: Punish Removing Restraints
Int _iLeashHolderGoal Conditional

; 0: Player is not controlled
; 1: Keep the player with no particular agenda
; 2: Dominate the player and make sure she is secure
; 3: Punish the player
; 4: Transfer the player from one form of control to another
; 5: Release the player or prepare her for release
Int _iLongTermAgenda Conditional

; The meaning of the details depend on the value of the long term agenda.
; LTA 4: 1: Transfer to BDSM furniture.
; LTA 4: 2: Transfer to the Simple Slavery auction house.
Int _iLongTermAgendaDetails Conditional

; A list of pending actions that we are waiting to happen.
; See AddPendingAction() for details.
Int _iPendingActionMutex
   Int[] _aiPendingAction
  Form[] _aoPendingActor
   Int[] _aiPendingDetails
String[] _aszPendingScene
   Int[] _aiPendingTimeout

; Keep track of everything the player is being punished for.
; 0x0001 = Talking of Escape
Int _iPunishments

;----------------------------------------------------------------------------------------------
; Conditional state variables related to the leash game used by the quest dialogues.
; The number of polls (give or take) the player has refused to cooperate with the current goal.
Int _iLeashGoalRefusalCount Conditional

; 0 = No weapons stolen.  1 = Equipped weapons stolen.  2 = All weapons stolen.
Int _iWeaponsStolen Conditional

Bool _bIsLeashHolderMale Conditional

; A measure of how likely it is for NPCs help you escape (MCM configurable).
Int _iChanceForAssistance Conditional
;----------

;----------------------------------------------------------------------------------------------
; Internal state variables about the leash holder.
Actor _aLeashHolder

; A leash holder with no confidence can cause trouble if he continually runs away.
; Keep track of the leash holder's original confidence before changing it.
Float _fPreviousConfidence

; Keep track of whether the leash holder's movement has been stopped.
Bool _bLeashHolderStopped

; Has the player re-equipped her weapons after they were put away.
Bool _bReequipWeapons

; Is the leash holder upset enough to allow the player to be enslaved.
Bool _bIsEnslaveAllowed

; Is the leash holder in combat.
Bool _bIsInCombat

; Is the leash holder attempting to engage the player in one of our dialogues.
Int _iDialogueBusy
Actor _aDialogueTarget

; The amount to reduce the player's movement speed when immobilizing her.
Float _fMovementAmount

; When movement is blocked this counts down and restores movement in case something goes wrong.
Int _iMovementSafety

; How often the player has been caught walking in front of the leash holder.
Int _iCurrWalkInFrontCount
Int _iTotalWalkInFrontCount

; How often the player has said something particularly annoying to the leash holder.
Int _iVerbalAnnoyance

; The last position of the leash holder to keep track of whether he is moving or not.
Float _fLastPosition
;----------

; Has the player been completely dressed and decorated as a slave.
Bool _bFullyRestrained
Bool _bIsCompleteSlave

; Keeps track of whether the slaver has willingly ungagged the player.
Bool _bPlayerUngagged

; Keeps track of how many times the player has performed repeat offences.
Int _iBadBehaviour
; DEPRECATED: This used to be called _iEscapeAttempts.
; Don't use this variable any more.
Int _iEscapeAttempts

; Keeps track of how long various punishments are to last for.
Int _iBlindfoldRemaining Conditional
Bool _bReleaseBlindfold
Int _iGagRemaining Conditional
Bool _bReleaseGag
Int _iFurnitureRemaining Conditional

; Keep track of the player's current furniture for various reasons.
ObjectReference _oPunishmentFurniture
ObjectReference _oTransferFurniture
ObjectReference _oHiddenFurniture

; A list of all items stolen from the player.
Form[] _aoItemStolen
; Old variable with the wrong name.  No longer used.
Form[] _oItemStolen

; A set of equipment we locked on the slave.
Bool _bFindItems
Armor _oGag
Armor _oArmRestraint
Armor _oLegRestraint
Armor _oCollar
Armor _oBlindfold

; Keeps track of actions that should be taken during an assault:
; 0x0001: Strip
; 0x0002: Gag
; 0x0004: Bind Arms
; 0x0008: Take All Weapons
; 0x0010: Return All Items
; 0x0020: Unbind Arms
; 0x0040: Strip Fully
; 0x0080: Add Additional Restraint
; 0x0100: UnGag
; 0x0200: Restrain in Collar
; 0x0400: Blindfold
; 0x0800: Release Blindfold
; 0x1000: Restore Leash Length
; 0x2000: Make sure the Gag is secure
; 0x4000: Restrain in Boots
; 0x40000000: Peaceful (the player is co-operating)
Int _iAssault
Int _iAssaultTakeGold

; A measure of how long the slaver will wait for the player to respond to an order.
Int _iExpectedResponseTime

; Keeps track of when the last update poll was.
; This can be used to detect when the game has been loaded as the current real time is reset.
Float _fLastUpdatePoll

; Keep a count of how many polls since the game has been loaded.
; Some things cannot be initialized on game load so they must be initialized a certain number of
; poll loops after the game is loaded.  E.g. registration for the DFW_NewMaster event.
Int _iPollsSinceLoad

; Keeps track of whether the leash game is in effect and how long it will continue for.
Int _iLeashGameDuration Conditional
Int _iLeashGameCooldown

; Keep track of which BDSM furniture the player is sitting in when we begin messing with her.
ObjectReference _oBdsmFurniture

; A timer for keeping the player locked in BDSM furniture for a little while.
Float _fFurnitureReleaseTime Conditional

; Keeps track of whether the BDSM furniture is randomly locked.
Bool _bFurnitureForFun Conditional

; Variables to keep track of the progress of BDSM furniture for fun scenes.
; 0x0001: Cooperating
; 0x0002: Release
; 0x0004: Ungag
; 0x0008: Sex
; 0x0010: Whip
; 0x0020: Secure Gag
; 0x0040: Gag
; 0x0080: Undress
; 0x0100: Add Restraints
; 0x0200: Play(Sex/Whip)
; 0x0400: Take the player's gold
; 0x0800: Restrain the player's arms
; 0x8000: Lock Furniture
Int _iFurnitureGoals

; The ZAZ Animation Pack Cane weapon used in whipping scenes.
Weapon _oWeaponZbfCane
Int _iZbfCaneBaseDamage
String _szZbfCaneResistance

; A variable to keep track of whether we think the player is enslaved by SD+.
Bool _bEnslavedSdPlus

; A reference to the SD+ mod's "_SD_state_caged" global variable.
GlobalVariable _gSdPlusStateCaged
Bool _bCagedSdPlus

; A variable to keep track of whether we have blocked fast travel.
Bool _bFastTravelBlocked

;----------------------------------------------------------------------------------------------
; Local copy of frequently used MCM settings.
; Accessing settings from other script is a little expensive as it can cause context switches.
; For MCM settings that are used often we will store a local copy of their values in this script
; for faster access.
Bool _bMcmCatchSdPlus
Bool _bMcmIncludeOwners
Bool _bMcmShutdownMod
Float _fMcmFurnitureReleaseChance
Float _fMcmFurnitureVisitorChance
Float _fMcmLeashGameChance
Float _fMcmPollTime
Int _iMcmBlockTravel
Int _iMcmChanceIdleRestraints
Int _iMcmFurnitureAltRelease
Int _iMcmIncreaseWhenVulnerable
; 0 = No Gag  1 = Regular  2 = Auto Remove
Int _iMcmGagMode
; 0 = Off  1 = Auto  2 = Protected  3 = Dialogue
Int _iMcmLeashGameStyle
Int _iMcmLogLevel
Int _iMcmLogLevelScreen
Int _iMcmMaxDistance
Int _iMcmLeashResist
Int _iMcmEscapeDetection
;----------

;----------------------------------------------------------------------------------------------
; Mod Compatability.
; Milk Mod Economy.  Some effort is needed to make sure scenes run smoothly.
Spell _oMmeBeingMilkedSpell
Bool _bMmeSuppressed

;----------


;***********************************************************************************************
;***                                    INITIALIZATION                                       ***
;***********************************************************************************************
; A new game has started, this script was added to an existing game, or the script was reset.
Event OnInit()
   ; Default the logging level to trace until we can contact the MCM script.
   _iMcmLogLevel = 5

   ; We shouldn't do anything here.  We rely on the MCM script to update our polling interval
   ; when it's ready.  Register for a polling interval anyway, in case the MCM script fails.
   Debug.Trace("[" + S_MOD + "] Script Initialized.")
   RegisterForSingleUpdate(90)
EndEvent

; This is called once by the MCM script to initialize the mod and then on each update poll.
; This function is primarily to ensure new variables are initialized for new script versions.
Function UpdateScript()
   ; Reset the version number.
   ;If (1.04 < _fCurrVer)
   ;   _fCurrVer = 1.04
   ;EndIf

   ; If the script is at the current version we are done.
   Float fScriptVer = 1.05
   If (fScriptVer == _fCurrVer)
      Return
   EndIf
   Log("Updating Script " + _fCurrVer + " => " + fScriptVer, DL_CRIT, S_MOD)

   ; When releasing the greeting dialogues (Version 2 of the mod) the script versions
   ; were all advanced to version 1.00.
   If (1.00 > _fCurrVer)
      ; Initialize basic variables.
      _aPlayer = Game.GetPlayer()

      ; Create arrays of the different restraints available for us to choose from.
      CreateRestraintsArrays()
   EndIf

   If (1.01 > _fCurrVer)
      _oGold = (Game.GetFormFromFile(0x0000000F, "Skyrim.esm") As MiscObject)

      ; CrimeFactionImperial (0x00028848)
      ;_oFactionLeashTargetCrime = (Game.GetFormFromFile(0x00028848, "Skyrim.esm") As Faction)
      ; CrimeFactionImperial (0x0002816C)
      _oFactionLeashTargetCrime = (Game.GetFormFromFile(0x0002816C, "Skyrim.esm") As Faction)

      ; Make sure the favourite furniture lists are all the same length.
      ; Use temporary variables because initializing the arrays to None causes them not to work
      ; in the AddFormToArray() functions.
      Form[] aoTempLocation
      Form[] aoTempRegion
      Int iIndex
      Int iTotalFurniture = _aoFavouriteFurniture.Length
      While (iIndex < iTotalFurniture)
         ObjectReference oFurniture = (_aoFavouriteFurniture[iIndex] As ObjectReference)
         Location oFurnitureLocation = oFurniture.GetCurrentLocation()
         aoTempLocation = _qDfwUtil.AddFormToArray(aoTempLocation, oFurnitureLocation)
         Location oFurnitureRegion = _qFramework.GetRegion(oFurnitureLocation, \
                                                           oFurniture.GetParentCell())
         aoTempRegion = _qDfwUtil.AddFormToArray(aoTempRegion, oFurnitureRegion)
         iIndex += 1
      EndWhile
      _aoFavouriteLocation = aoTempLocation
      _aoFavouriteRegion   = aoTempRegion
      _aAliasFurnitureLocker = (GetAlias(5) As ReferenceAlias)

      ; In this version it became a requirement that verbal annoyance is not < 0.
      If (0 > _iVerbalAnnoyance)
         _iVerbalAnnoyance = 0
      EndIf
   EndIf

   If (1.03 > _fCurrVer)
      If (_oItemStolen)
         _aoItemStolen = _oItemStolen
      EndIf

      If (0 < _iLeashGameDuration)
         _iLongTermAgenda = 1
         _iLongTermAgendaDetails = 0
      EndIf
   EndIf

   If (1.04 > _fCurrVer)
      InitSimpleSlaveryAuctions()
   EndIf

   If (1.05 > _fCurrVer)
      ; This variable has been renamed.
      _iBadBehaviour = _iEscapeAttempts

      UpdateLocalMcmSettings()

      ; I don't know the range of Confidence so use -100 as an invalid value.
      _fPreviousConfidence = -100.0

      ; Create an initial mutex for protecting the mutex list.
      _aiMutex      = New Int[1]
      _aszMutexName = New String[1]
      _aiMutex[0]      = 0
      _aszMutexName[0] = "Mutex List Mutex"
      _iMutexNext      = 1

      ; Create other mutexes for protecting data access.
      _iPendingActionMutex = iMutexCreate("DFWS Pending")

      ; Registering for events on game load almost always fails.  Always add a delay.
      Log("Delaying before mod event registration.", DL_CRIT, S_MOD)
      Utility.Wait(20)

      ; Perform all registrations in one place to avoid multiple delays.
      If (1.00 > _fCurrVer)
         ; If we are upgrading from a very old version or starting a new game make sure to
         ; include any mod events we should have registered for in those versions.
         ; Register for events indicating other mods have enslaved the player.
         RegisterForModEvent("zbfSC_EnslaveActor", "ActorEnslaved")
         RegisterForModEvent("zbfSC_FreeSlave", "ActorFreed")
         RegisterForModEvent("zbfSC_ReleaseSlave", "ActorFreed")

         ; Register for the ZAZ event indicating an animation is done.
         RegisterForModEvent("ZapSlaveActionDone", "OnSlaveActionDone")

         ; Register for a DFW event notifying us our Master has been overthrown.
         RegisterForModEvent("DFW_NewMaster", "DfwNewMaster")

         ; Register for SD+ events related to enslaving/freeing the player.
         RegisterForModEvent("SDEnslavedStart", "EventSdPlusStart")
         RegisterForModEvent("SDEnslavedStop", "EventSdPlusStop")

         ; Register for post sex events to adjust actor dispositions accordingly.
         RegisterForModEvent("AnimationEnd", "PostSexCallback")

         ; Register for game load events from the DFW mod.
         RegisterForModEvent("DFW_GameLoaded", "OnLoadGame")

         ; Register for the event indicating the DFW MCM values have changed.
         ; Note: This can indicate a DFW safeword has been triggered.
         RegisterForModEvent("DFW_MCM_Changed", "UpdateDfwMcm")
      EndIf

      ; Perform all registrations in one place to avoid multiple delays.
      If (1.01 > _fCurrVer)
         RegisterForModEvent("DFW_CallForHelp",      "HandleCallOut")
         RegisterForModEvent("DFW_CallForAttention", "HandleCallOut")
         RegisterForModEvent("DFW_MovementDone",     "MovementDone")
         RegisterForModEvent("AnimationStart",       "PreSexCallback")
         RegisterForModEvent("DFWS_MCM_Changed",     "UpdateLocalMcmSettings")
      EndIf

      ; Register for game load events from the DFW mod.
      RegisterForModEvent("DFW_DebugMovePlayer", "DebugMovePlayer")

      Log("Registering Mod Events Done", DL_CRIT, S_MOD)
   EndIf

   ; Finally update the version number.
   _fCurrVer = fScriptVer
EndFunction

Function OnLoadGame()
   ; Use a flag to prevent initialization from happening twice.
   If (_bGameLoadInProgress)
      Return
   EndIf
   _bGameLoadInProgress = True

   Float fCurrTime = Utility.GetCurrentRealTime()
   Log("Game Loaded.", DL_INFO, S_MOD)

   ; Update all quest variables upon loading each game.
   ; There are too many things that can cause them to become invalid.
   ; E.g. adding/removing conditional variables, converting from plugin to master file.
   _qMcm             = ((Self As Quest) As dfwsMcm)
   _qFramework       = (Quest.GetQuest("_dfwDeviousFramework") As dfwDeviousFramework)
   _qDfwUtil         = (Quest.GetQuest("_dfwDeviousFramework") As dfwUtil)
   _qSexLab          = (Quest.GetQuest("SexLabQuestFramework") As SexLabFramework)
   _qZadLibs         = (Quest.GetQuest("zadQuest") As Zadlibs)
   _qZadArmbinder    = (Quest.GetQuest("zadArmbinderQuest") As zadHeavyBondageQuestScript)
   _qZbfShell        = zbfBondageShell.GetApi()
   _qZbfSlave        = zbfSlaveControl.GetApi()
   _qZbfSlaveActions = zbfSlaveActions.GetApi()

   ; We need the caged state variable from Sanguine Debauchery plus to stop the leash when the
   ; player is caged.
   _gSdPlusStateCaged = None
   Int iModOrder = Game.GetModByName("sanguinesDebauchery.esp")
   If ((-1 < iModOrder) && (255 > iModOrder))
      _gSdPlusStateCaged = \
         (Game.GetFormFromFile(0x000D1E79, "sanguinesDebauchery.esp") as GlobalVariable)
   EndIf

   ; We need the Zaz Animation Pack cane to reduce it's damange during whipping scenens.
   _oWeaponZbfCane = None
   iModOrder = Game.GetModByName("ZaZAnimationPack.esm")
   If ((-1 < iModOrder) && (255 > iModOrder))
      _oWeaponZbfCane = (Game.GetFormFromFile(0x00006004, "ZaZAnimationPack.esm") As Weapon)
   EndIf

   ; We need to disable Milk Mod Animations when sitting in furniture.  We do this by adding
   ; the being milked spell to the player (which is a bit of a hack).
   _oMmeBeingMilkedSpell = None
   iModOrder = Game.GetModByName("MilkModNEW.esp")
   If ((-1 < iModOrder) && (255 > iModOrder))
      _oMmeBeingMilkedSpell = (Game.GetFormFromFile(0x000369A8, "MilkModNEW.esp") As Spell)
   EndIf

   ; The game has been loaded.  Perform necessary actions here.
   UpdateScript()

   _bGameLoadInProgress = False
   Log("Game Loaded Done: " + (Utility.GetCurrentRealTime() - fCurrTime), DL_TRACE, S_MOD)
EndFunction

Function ReRegisterModEvents()
   ; Re-register for all mod events.  Should be called from the MCM menu to fix issues.
   UnregisterForAllModEvents()
   RegisterForModEvent("AnimationStart",       "PreSexCallback")
   RegisterForModEvent("AnimationEnd",         "PostSexCallback")
   RegisterForModEvent("DFW_CallForAttention", "HandleCallOut")
   RegisterForModEvent("DFW_CallForHelp",      "HandleCallOut")
   RegisterForModEvent("DFW_DebugMovePlayer",  "DebugMovePlayer")
   RegisterForModEvent("DFW_GameLoaded",       "OnLoadGame")
   RegisterForModEvent("DFW_MCM_Changed",      "UpdateDfwMcm")
   RegisterForModEvent("DFW_MovementDone",     "MovementDone")
   RegisterForModEvent("DFW_NewMaster",        "DfwNewMaster")
   RegisterForModEvent("DFWS_MCM_Changed",     "UpdateLocalMcmSettings")
   RegisterForModEvent("SDEnslavedStart",      "EventSdPlusStart")
   RegisterForModEvent("SDEnslavedStop",       "EventSdPlusStop")
   RegisterForModEvent("ZapSlaveActionDone",   "OnSlaveActionDone")
   RegisterForModEvent("zbfSC_EnslaveActor",   "ActorEnslaved")
   RegisterForModEvent("zbfSC_FreeSlave",      "ActorFreed")
   RegisterForModEvent("zbfSC_ReleaseSlave",   "ActorFreed")

   ; Also reset the load game flag here in case it has gotten stuck.
   ; It should be safe since this function shouldn't be called during a load game.
   _bGameLoadInProgress = False
EndFunction

Function UpdateLocalMcmSettings(String sCategory="")
   ; If this is called before we have configured our MCM quest do so now.
   If (!_qMcm)
      _qMcm = ((Self As Quest) As dfwsMcm)
      If (!_qMcm)
         Log("Error: Failed to find MCM quest in UpdateLocalMcmSettings()", DL_ERROR, S_MOD)
         Return
      EndIf
   EndIf

   If (!sCategory || ("Compatability" == sCategory))
      _iMcmGagMode = _qMcm.iGagMode
   EndIf

   If (!sCategory || ("Leash" == sCategory))
      _bMcmIncludeOwners           = _qMcm.bIncludeOwners
      _fMcmLeashGameChance         = _qMcm.fLeashGameChance
      _iMcmChanceIdleRestraints    = _qMcm.iChanceIdleRestraints
      _iMcmFurnitureAltRelease     = _qMcm.iFurnitureAltRelease
      _iMcmIncreaseWhenVulnerable  = _qMcm.iIncreaseWhenVulnerable
      _iMcmLeashGameStyle          = _qMcm.iLeashGameStyle
      _iMcmMaxDistance             = _qMcm.iMaxDistance
      _iMcmLeashResist             = _qMcm.iLeashResist
      _iChanceForAssistance        = _qMcm.iChanceForAssistance
      _iMcmEscapeDetection         = _qMcm.iEscapeDetection
   EndIf

   If (!sCategory || ("Furniture" == sCategory))
      _fMcmFurnitureReleaseChance  = _qMcm.fFurnitureReleaseChance
      _fMcmFurnitureVisitorChance  = _qMcm.fFurnitureVisitorChance
   EndIf

   If (!sCategory || ("Compatibility" == sCategory))
      _bMcmCatchSdPlus             = _qMcm.bCatchSdPlus
   EndIf

   If (!sCategory || ("Mod" == sCategory))
      Float fTempPollTime = _qMcm.fPollTime
      ; If the polling interval has changed (or not been initialized) start the poll now.
      If (fTempPollTime != _fMcmPollTime)
         UpdatePollingInterval(fTempPollTime)
      EndIf
      _fMcmPollTime                = fTempPollTime
      _iMcmBlockTravel             = _qMcm.iBlockTravel
      _iMcmLogLevel                = _qMcm.iLogLevel
      _iMcmLogLevelScreen          = _qMcm.iLogLevelScreen
   EndIf

   If ("Mod" == sCategory)
      ; If we are re-enabling the mod make sure to start the poll.
      If (_bMcmShutdownMod && !_qMcm.bShutdownMod)
         UpdatePollingInterval(_fMcmPollTime)
      EndIf
      _bMcmShutdownMod = _qMcm.bShutdownMod
   EndIf
EndFunction

Function InitSimpleSlaveryAuctions()
   ; If Simple Slavery is not installed clear all locations.
   _oWeaponZbfCane = None
   Int iModOrder = Game.GetModByName("SimpleSlavery.esp")
   If ((-1 >= iModOrder) || (255 <= iModOrder))
      _oSimpleSlaveryInternalDoor = None
      _aSimpleSlaveryAuctioneer   = None
      _aoSimpleSlaveryRegion         = None
      _aoSimpleSlaveryLocation       = None
      _aoSimpleSlaveryEntranceObject = None
   EndIf

   ; Setup auction house internal markers.
   _oSimpleSlaveryInternalDoor = (Game.GetFormFromFile(0x00025108, "SimpleSlavery.esp") As ObjectReference)
   _aSimpleSlaveryAuctioneer   = (Game.GetFormFromFile(0x0002530A, "SimpleSlavery.esp") As Actor)

   ; Then make sure the region/location variables are set.
   _aoSimpleSlaveryRegion         = New Location[6]
   _aoSimpleSlaveryLocation       = New Location[6]
   _aoSimpleSlaveryEntranceObject = New ObjectReference[6]

   Int iRiftenOuterDoorId = 0x0004D7D0

   ; Riften
   _aoSimpleSlaveryEntranceObject[0] = (Game.GetFormFromFile(iRiftenOuterDoorId, "SimpleSlavery.esp") As ObjectReference)
   If (_aoSimpleSlaveryEntranceObject[0])
      _aoSimpleSlaveryRegion[0] = (Game.GetFormFromFile(0x00018A58, "Skyrim.esm") As Location)
      _aoSimpleSlaveryLocation[0] = _aoSimpleSlaveryRegion[0]
   EndIf

   ; High Hrothgar (moves to Riften)
   _aoSimpleSlaveryEntranceObject[1] = (Game.GetFormFromFile(iRiftenOuterDoorId, "SimpleSlavery.esp") As ObjectReference)
   If (_aoSimpleSlaveryEntranceObject[1])
      _aoSimpleSlaveryRegion[1] = (Game.GetFormFromFile(0x00018A34, "Skyrim.esm") As Location)
      _aoSimpleSlaveryLocation[1] = _aoSimpleSlaveryRegion[0]
   EndIf

   ; Ivarstead (moves to Riften)
   _aoSimpleSlaveryEntranceObject[2] = (Game.GetFormFromFile(iRiftenOuterDoorId, "SimpleSlavery.esp") As ObjectReference)
   If (_aoSimpleSlaveryEntranceObject[2])
      _aoSimpleSlaveryRegion[2] = (Game.GetFormFromFile(0x00018A4B, "Skyrim.esm") As Location)
      _aoSimpleSlaveryLocation[2] = _aoSimpleSlaveryRegion[0]
   EndIf

   ; Riverwood (moves to Riften)
   _aoSimpleSlaveryEntranceObject[3] = (Game.GetFormFromFile(iRiftenOuterDoorId, "SimpleSlavery.esp") As ObjectReference)
   If (_aoSimpleSlaveryEntranceObject[3])
      _aoSimpleSlaveryRegion[3] = (Game.GetFormFromFile(0x00013163, "Skyrim.esm") As Location)
      _aoSimpleSlaveryLocation[3] = _aoSimpleSlaveryRegion[0]
   EndIf

   ; Shors Stone (moves to Riften)
   _aoSimpleSlaveryEntranceObject[4] = (Game.GetFormFromFile(iRiftenOuterDoorId, "SimpleSlavery.esp") As ObjectReference)
   If (_aoSimpleSlaveryEntranceObject[4])
      _aoSimpleSlaveryRegion[4] = (Game.GetFormFromFile(0x00018A4C, "Skyrim.esm") As Location)
      _aoSimpleSlaveryLocation[4] = _aoSimpleSlaveryRegion[0]
   EndIf

   ; Windhelm (moves to Riften)
   _aoSimpleSlaveryEntranceObject[5] = (Game.GetFormFromFile(iRiftenOuterDoorId, "SimpleSlavery.esp") As ObjectReference)
   If (_aoSimpleSlaveryEntranceObject[5])
      _aoSimpleSlaveryRegion[5] = (Game.GetFormFromFile(0x00018A57, "Skyrim.esm") As Location)
      _aoSimpleSlaveryLocation[5] = _aoSimpleSlaveryRegion[0]
   EndIf
EndFunction


;***********************************************************************************************
;***                                        EVENTS                                           ***
;***********************************************************************************************
; The OnUpdate() code is in a wrapper, PerformOnUpdate().  This is to allow us to return from
; the function without having to add code to re-register for the update at each return point.
Event OnUpdate()
   ; If the script has not been initialized do that instead of performing the update.
   If (!_fCurrVer)
      OnLoadGame()
   ElseIf (_bMcmShutdownMod)
      ; If we are shutting down the mod don't process any requests/events.
      Self.Stop()
      Return
   Else
      PerformOnUpdate()

      ; If we haven't found all BDSM items search for one each update poll.
      If (_bFindItems)
         If (!_oGag)
            FindGag(_aLeashHolder)
         ElseIf (!_oArmRestraint)
            FindArmRestraint(_aLeashHolder)
         ElseIf (!_oLegRestraint)
            FindLegRestraint(_aLeashHolder)
         ElseIf (!_oCollar)
            FindCollar(_aLeashHolder)
         ElseIf (!_oBlindfold)
            FindBlindfold(_aLeashHolder)
         Else
            _bFindItems = False
         EndIf
      EndIf
   EndIf

   ; Register for our next update event.
   ; We are registering for each update individually after the previous processing has
   ; completed to avoid long updates causing multiple future updates to occur at the same time,
   ; thus, piling up.  This is a technique recommended by the community.
   RegisterForSingleUpdate(_fMcmPollTime)
EndEvent

Function PerformOnUpdate()
   Float fCurrRealTime = Utility.GetCurrentRealTime()

   ; Game Loaded: If the current real time is low (has been reset) that indicates the game has
   ; just been loaded.  Do some processing at the beginning of the loaded game.
;   If ((_fLastUpdatePoll > fCurrRealTime) || \
;       (_fLastUpdatePoll < (fCurrRealTime - (_fMcmPollTime * 10))))
;      OnLoadGame()
;   ElseIf (10 >= _iPollsSinceLoad)
;      _iPollsSinceLoad += 1
;      ; Near the start of each game load suspend deviously helpless assaults if needed.
;      ; This is done here since the suspension is cleared on each load game.
;      If ((5 == _iPollsSinceLoad) && _iLeashGameDuration && _qMcm.bBlockHelpless)
;         SendModEvent("dhlp-Suspend")
;      EndIf
;   EndIf
   _fLastUpdatePoll = fCurrRealTime

   ; Check if the player's movement has been blocked for too long.
   If (0 < _iMovementSafety)
      _iMovementSafety -= 1
      If (0 >= _iMovementSafety)
         ReMobilizePlayer()
      EndIf
   EndIf

   ; Check if fast travel should be toggled.
   Int iVulnerability = _qFramework.GetVulnerability(_aPlayer)
   If (_bFastTravelBlocked)
      ; If fast travel is blocked but the player is not that vulnerable enable it again.
      If (_iMcmBlockTravel > iVulnerability)
         _qFramework.RestoreFastTravel()
         _bFastTravelBlocked = True
      EndIf
   ElseIF (_iMcmBlockTravel <= iVulnerability)
      ; If fast travel is allowed but the player is vulnerable block it.
      _qFramework.BlockFastTravel()
      _bFastTravelBlocked = True
   EndIf

   ; Check if the player is enslaved by Sanguine's Debauchery (SD+).
   If (_bMcmCatchSdPlus && _bEnslavedSdPlus)
      ; We think the player is enslaved.  Verify that she actually is.
      If (0 >= StorageUtil.GetIntValue(_aPlayer, "_SD_iEnslaved"))
         StopSdPlus()
      ElseIf (_qMcm.bLeashSdPlus)
         ; The player is still enslaved.  Manage her leashed based on her SD+ caged state.

         If (_bCagedSdPlus)
            ; We think the player is caged.  Verify that she actually is.
            If (!_gSdPlusStateCaged.GetValue())
               ; The player does not seem to be caged any more.  Reconnect the leash.
               Actor aMaster = _qFramework.GetMaster(_qFramework.MD_CLOSE)
               If (aMaster)
                  _qFramework.SetLeashTarget(aMaster)
               EndIf
               _bCagedSdPlus = False
            EndIf
         ElseIf (_gSdPlusStateCaged.GetValue())
            ; We think the player is not caged but she now is.  Break her leash.
            _qFramework.SetLeashTarget(None)
            _bCagedSdPlus = True
         EndIf
      EndIf
   ElseIf (_bMcmCatchSdPlus)
      If (0 < StorageUtil.GetIntValue(_aPlayer, "_SD_iEnslaved"))
         StartSdPlus()
      EndIf
   EndIf

   ; Decrease the player's punishments if she has any.
   If (3 == _iLongTermAgenda)
      If (0 < _iBlindfoldRemaining)
         _iBlindfoldRemaining -= 1
         If (!_iBlindfoldRemaining)
            ; Don't release it now in case there are more important goals to take care of.
            ; Just set a flag and make sure it is released later on in the stack.
            _bReleaseBlindfold = True
         EndIf
      EndIf
      If (0 < _iGagRemaining)
         _iGagRemaining -= 1

         ; If gag mode is Auto Remove flag it for removal.
         ; Don't release it now in case there are more important goals to take care of.
         If (!_iGagRemaining && (2 == _iMcmGagMode))
            _bReleaseGag = True
         EndIf
      EndIf
      If (0 < _iFurnitureRemaining)
         _iFurnitureRemaining -= 1
         If (!_iFurnitureRemaining)
            ; Sex was allowed while the player was being punished.  Revoke that now.
            If (!_qMcm.bAllowSex)
               _qFramework.RemovePermission(_aLeashHolder, _qFramework.AP_SEX)
            EndIf
            _oPunishmentFurniture = None
            _qFramework.ApproachPlayer(_aLeashHolder, 300, 2, S_MOD + "_Return")
         EndIf
      EndIf
      If (!_iBlindfoldRemaining && !_iGagRemaining && !_iFurnitureRemaining)
         _iLongTermAgenda = 1
         _iLongTermAgendaDetails = 0
      EndIf
   EndIf

   If (_aLeashHolder)
      ; Manage all the behaveiour of the leash game.
      PlayLeashGame()
   Else
      ; If the player has been verbally annoying consider decrementing this over time.
      ; Note: This is handled separately if the leash game is being played.
      If ((0 < _iVerbalAnnoyance) && (2 >= Utility.RandomInt(1, 100)))
         _iVerbalAnnoyance -= 1
         If (2 == _iVerbalAnnoyance)
            Log("People arround you seem less annoyed by your behaviour.", DL_CRIT, S_MOD)
         EndIf
      EndIf

      ; If the player needs to be ungagged find someone to ungag her.
      If (_bReleaseGag)
         Actor aNpc = _aLeashHolder
         If (!aNpc)
            aNpc = (_aAliasFurnitureLocker.GetReference() As Actor)
            If (!aNpc)
               aNpc = _qFramework.GetRandomActor(iIncludeFlags=_qFramework.AF_DOMINANT)
               If (!aNpc)
                  aNpc = _qFramework.GetRandomActor()
               EndIf
            EndIf
         EndIf
         ; 0x40000000: Peaceful (the player is co-operating)
         ; 0x0100: UnGag
         _iAssault = Math.LogicalOr(0x40000000 + 0x0100, _iAssault)
         PlayApproachAnimation(aNpc, "Assault")

         _bReleaseGag = False
      EndIf

      If (_iLeashGameCooldown)
         ; If the leash game is in cool down deccrement the variable and don't consider playing.
         _iLeashGameCooldown -= 1
         If (0 > _iLeashGameCooldown)
            _iLeashGameCooldown = 0
         EndIf
      ElseIf (_iMcmLeashGameStyle)
         ; If the mod's leash game is enabled check if we should start the game.
         CheckStartLeashGame(iVulnerability)
      EndIf
   EndIf

   ; If Furniture For Fun can be started or is in progress also consider a conversation.
   Bool bConsiderDialogue

   ObjectReference oCurrFurniture = _qFramework.GetBdsmFurniture()
   If (_oBdsmFurniture && !oCurrFurniture && !_qFramework.IsBdsmFurnitureLocked())
      ; We think the player is locked in BDSM furniture but she isn't.
      _aAliasFurnitureLocker.Clear()
      _bFurnitureForFun = False
      _oBdsmFurniture = None
   ElseIf ((_oBdsmFurniture || oCurrFurniture) && !_oPunishmentFurniture)
      ; If the player is sitting in BDSM furniture, think about messing with her.

      If (_fFurnitureReleaseTime && (_fFurnitureReleaseTime < Utility.GetCurrentGameTime()))
         _fFurnitureReleaseTime = 0
         Log("You hear a click and the furniture unlocks.", DL_CRIT, S_MOD)
         _qFramework.SetBdsmFurnitureLocked(False)
         ;    EnablePlayerControls(Move,  Fight, Cam,   Look,  Sneak, Menu,  Activ, Journ)
         Game.EnablePlayerControls(True,  False, False, False, False, False, True,  False)
      EndIf

      ; If the player is free to move and no one is messing with her think about starting to.
      If (!_bFurnitureForFun && (Game.IsMovementControlsEnabled() || _fFurnitureReleaseTime))
         ; If the player was not previously sitting in the furniture take some actions.
         If (!_oBdsmFurniture)
            ; Keep track of which furniture the player is sitting in.
            _oBdsmFurniture = oCurrFurniture

            ; Start a timer keeping the player locked for a minimum amount of time.
            If (_qMcm.iFurnitureMinLockTime && _qFramework.IsAllowed(_qFramework.AP_ENSLAVE))
               Log("The furniture automatically locks you in.", DL_CRIT, S_MOD)
               _fFurnitureReleaseTime = Utility.GetCurrentGameTime() + \
                                        ((_qMcm.iFurnitureMinLockTime As Float) / 1440.0)
               _qFramework.SetBdsmFurnitureLocked()
               ;    DisablePlayerControls(Move,  Fight, Cam,   Look,  Sneak, Menu,  Active, Journ)
               Game.DisablePlayerControls(True,  False, False, False, False, False, True,   False)
            EndIf
         EndIf

         Float fMaxChance = _qMcm.fFurnitureLockChance
         Float fRoll = Utility.RandomFloat(0, 100)
         Log("Furniture Roll: " + fRoll + "/" + fMaxChance, DL_TRACE, S_MOD)
         If ((fMaxChance > fRoll) && !_qSexLab.IsActorActive(_aPlayer))
            ; Find someone nearby to lock the player in the device.
            Actor aNearby = _qFramework.GetRandomActor(iIncludeFlags=_qFramework.AF_DOMINANT, \
                                                       iExcludeFlags=_qFramework.AF_GUARDS)
            If (aNearby && !_qFramework.SceneStarting(S_MOD, 60))
               _qFramework.SetBdsmFurnitureLocked()
               ;    DisablePlayerControls(Move,  Fight, Cam,   Look,  Sneak, Menu,  Active, Journ)
               Game.DisablePlayerControls(True,  False, False, False, False, False, True,   False)
               ImmobilizePlayer()
               _aAliasFurnitureLocker.ForceRefTo(aNearby)
               _bFurnitureForFun = True
               _fFurnitureReleaseTime = 0

               ; Wait for the NPC if he is in the process of sitting or standing.
               ActorSitStateWait(aNearby)
               _qZbfSlaveActions.RestrainInDevice(None, aNearby, S_MOD + "_PreLock")
            EndIf
         Else
            bConsiderDialogue = True
         EndIf
      ; If the player is locked and we know who is messing with her think about freeing her.
      ElseIf (!Game.IsMovementControlsEnabled() && _bFurnitureForFun && \
              ("" == _qFramework.GetCurrentScene()) && !_qSexLab.IsActorActive(_aPlayer) && \
              (0 >= _iLeashGameDuration))
         Actor aHelper = (_aAliasFurnitureLocker.GetReference() As Actor)
         Float fChance = _fMcmFurnitureReleaseChance
         ; If the locker is not nearby see if there is someone else who will help.
         If (!aHelper || !_qFramework.IsActorNearby(aHelper))
            aHelper = _qFramework.GetRandomActor(iIncludeFlags=_qFramework.AF_DOMINANT)
            fChance = fChance * _iMcmFurnitureAltRelease / 100
            If (!aHelper)
               fChance = 0
            EndIf
         EndIf
         Float fRoll = Utility.RandomFloat(0, 100)
         Log("Furniture End Roll: " + fRoll + "/" + fChance, DL_TRACE, S_MOD)
         If ((fChance > fRoll) && !_qFramework.SceneStarting(S_MOD, 60))
            ImmobilizePlayer()
            ; Wait for the NPC if he is in the process of sitting or standing.
            ActorSitStateWait(aHelper)
            _qZbfSlaveActions.RestrainInDevice(None, aHelper, S_MOD + "_F_Unlock")
         Else
            bConsiderDialogue = True
         EndIf
      EndIf
   ElseIf (_oPunishmentFurniture && (3 == _iLongTermAgenda))
      ; The player is being punished in furniture.  She is available to be played with.
      bConsiderDialogue = True
   EndIf

   ; If the player is locked in furniture, maybe find someone nearby to start a conversation.
   If (bConsiderDialogue)
      Float fRoll = Utility.RandomFloat(0, 100)
      Log("Furniture Dialogue Roll: " + fRoll + "/" + _fMcmFurnitureVisitorChance, DL_TRACE, \
          S_MOD)
      If (_fMcmFurnitureVisitorChance > fRoll)
         ; By default the harraser should be the one who locked the furniture.
         Actor aAggressor = (_aAliasFurnitureLocker.GetReference() As Actor)

         ; Sometimes use a random nearby NPC instead of the original locker.
         If (!aAggressor || !_qFramework.IsActorNearby(aAggressor) || \
             (50 >= Utility.RandomInt(1, 100)))
            Actor aNearby = _qFramework.GetRandomActor(iIncludeFlags=_qFramework.AF_DOMINANT, \
                                                       iExcludeFlags=_qFramework.AF_GUARDS)
            If (aNearby)
               aAggressor = aNearby
            EndIf
         EndIf
   
         If (aAggressor && !_qFramework.GetPlayerTalkingTo() && \
             !_qFramework.SceneStarting(S_MOD + "_StartDialogue", 180))
            _qFramework.ApproachPlayer(aAggressor, 15, 2, S_MOD + "_StartDialogue")
         EndIf
      EndIf
   EndIf
EndFunction

Event ActorEnslaved(Form oActor, String szMod)
   Actor aActor = (oActor As Actor)
   If (_aPlayer != oActor)
      Return
   EndIf
   Log("Player Enslaved!", DL_CRIT, szMod)
   If ((szMod != _qFramework.GetMasterMod(_qFramework.MD_CLOSE)) && \
       (szMod != _qFramework.GetMasterMod(_qFramework.MD_DISTANT)))
      ; If this mod is not already registered as a player's controller try to find the player's
      ; Master in the narby player list.
      Log("Searching...", DL_CRIT, szMod)
      Form[] aoNearby = _qFramework.GetNearbyActorList()
      Int iIndex = aoNearby.Length
      While (0 <= iIndex)
         Actor aNearbyActor = (aoNearby[iIndex] As Actor)
         If (0 <= aNearbyActor.GetFactionRank(_qZbfSlave.zbfFactionPlayerMaster))
            Log("Master found: " + aNearbyActor.GetDisplayName(), DL_CRIT, szMod)
            If ((aNearbyActor != _qFramework.GetMaster(_qFramework.MD_CLOSE)) && \
                (aNearbyActor != _qFramework.GetMaster(_qFramework.MD_DISTANT)))
               _qFramework.SetMaster(aNearbyActor, szMod, _qFramework.AP_DRESSING, \
                                     bOverride=True)
            EndIf
            ; We found the Master.  Stop searching.
            iIndex = 0
         EndIf
         iIndex -= 1
      EndWhile
   EndIf
EndEvent

Event ActorFreed(Form oActor, String szMod)
   Actor aActor = (oActor As Actor)
   If (_aPlayer != oActor)
      Return
   EndIf
   Log("Player Freed!", DL_CRIT, szMod)
   Actor aCurrMaster = _qFramework.GetMaster(_qFramework.MD_CLOSE)
   If (aCurrMaster)
      _qFramework.ClearMaster(aCurrMaster)
   EndIf
EndEvent

Event DfwNewMaster(String szOldMod, Form oOldMaster)
   ; If any mod has taken control of the player stop our control of the BDSM furniture.
   ; The assumption here is any controlling mod will manage taking the player out of the
   ; furniture on it's own.
   If (_bFurnitureForFun)
      _aAliasFurnitureLocker.Clear()
      _bFurnitureForFun = False
      _oBdsmFurniture = None
      _qFramework.SetBdsmFurnitureLocked(False)
   EndIf

   Actor aOldMaster = (oOldMaster As Actor)
   If (aOldMaster == _aLeashHolder)
      StopLeashGame(False)
      ; If the leash game has been interrupted by a different mod, start a coolldown to prevent
      ; the game from being played again right away.
      _iLeashGameCooldown = 10
   EndIf
EndEvent

; This is the ZAZ Animation Pack (ZBF) event when an animation for approaching/restrainting
; the player has completed.
Event OnSlaveActionDone(String szType, String szMessage, Form oMaster, Int iSceneIndex)
   ;Log("ZAZ Slave Action Done: \"" + szMessage + "\"", DL_TRACE, S_MOD)

   ; We are only interested in animations that we started.
   If (S_MOD != StringUtil.Substring(szMessage, 0, 4))
      Return
   EndIf

   Bool bSceneContinuing
   Actor aMaster = (oMaster As Actor)
   String szName = aMaster.GetDisplayName()

   If (S_MOD + "_Assault" == szMessage)
      FinalizeAssault(aMaster, szName)
      _qFramework.SceneDone(S_MOD)
   ElseIf (S_MOD + "_PreLock" == szMessage)
      Log(szName + " quietly locks the device you are in.", DL_CRIT, S_MOD)

      ; If the lock hasn't been registered yet, do so now.
      If (!_aAliasFurnitureLocker.GetReference())
         _qFramework.SetBdsmFurnitureLocked()
         ;    DisablePlayerControls(Move,  Fight, Cam,   Look,  Sneak, Menu,  Active, Journ)
         Game.DisablePlayerControls(True,  False, False, False, False, False, True,   False)
         ImmobilizePlayer()
         _aAliasFurnitureLocker.ForceRefTo(aMaster)
         _bFurnitureForFun = True
         _fFurnitureReleaseTime = 0
      EndIf

      bSceneContinuing = True
      ; Disable Milk Mod Economy, preventing it from starting animations on the player.
      If (_oMmeBeingMilkedSpell && !_aPlayer.HasSpell(_oMmeBeingMilkedSpell))
         _aPlayer.AddSpell(_oMmeBeingMilkedSpell, False)
         _bMmeSuppressed = True
         ; Add a delay to make sure the spell has taken effect.
         Utility.Wait(0.5)
      EndIf
      _qZbfSlaveActions.RestrainInDevice(_oBdsmFurniture, aMaster, S_MOD)
   ElseIf ((S_MOD + "_F_Unlock" == szMessage) || (S_MOD + "_F_Release" == szMessage))
      Log(szName + " starts unlocking you from your device.", DL_CRIT, S_MOD)

      Int iMaxChance = _qMcm.iFurnitureTeaseChance
      Float fRoll = Utility.RandomFloat(0, 100)
      Log("Teasing Roll: " + fRoll + "/" + iMaxChance, DL_TRACE, S_MOD)
      If ((S_MOD + "_F_Unlock" == szMessage) && (iMaxChance > fRoll))
         ; The NPC was just teasing the player and really keeps her locked up.
         bSceneContinuing = True
         ; Disable Milk Mod Economy, preventing it from starting animations on the player.
         If (_oMmeBeingMilkedSpell && !_aPlayer.HasSpell(_oMmeBeingMilkedSpell))
            _aPlayer.AddSpell(_oMmeBeingMilkedSpell, False)
            _bMmeSuppressed = True
            ; Add a delay to make sure the spell has taken effect.
            Utility.Wait(0.5)
         EndIf
         _qZbfSlaveActions.RestrainInDevice(_oBdsmFurniture, aMaster, S_MOD + "_Teased")
      Else
         If (0 < _iMovementSafety)
            ReMobilizePlayer()
         EndIf
         _bFurnitureForFun = False
         _aAliasFurnitureLocker.Clear()
         _oBdsmFurniture = None
         _qFramework.SetBdsmFurnitureLocked(False)
         _qFramework.SceneDone(S_MOD)

         ; If this is a result of a furniture conversation clear the release flag.
         If (Math.LogicalAnd(_iFurnitureGoals, 0x0002))
            _iFurnitureGoals -= 0x0002
         EndIf
      EndIf
   ElseIf (S_MOD + "_Teased" == szMessage)
      Log(szName + " was teasing you and keeps you locked up.", DL_CRIT, S_MOD)
      If (0 < _iMovementSafety)
         ReMobilizePlayer()
      EndIf
      _qFramework.SceneDone(S_MOD)

      ; If this is a result of a furniture conversation make sure to continue it.
      If (Math.LogicalAnd(_iFurnitureGoals, 0x0002))
         _iFurnitureGoals -= 0x0002

         ; Goal 13: Lying About Release
         StartConversation(aMaster, 13)
      EndIf

      ; If we have suppressed Milk Mod Economy re-enable it.
      If (_bMmeSuppressed)
         If (_oMmeBeingMilkedSpell)
            _aPlayer.RemoveSpell(_oMmeBeingMilkedSpell)
         EndIf
         _bMmeSuppressed = False
      EndIf
   ElseIf (S_MOD + "_F_Assault" == szMessage)
      Int iNewItems = FinalizeAssault(aMaster, szName)

      ; If the player is now leashed and arm locked don't lock her back up.
      If ((_aLeashHolder == aMaster) && Math.LogicalAnd(0x04, iNewItems))
         _qFramework.SetLeashTarget(aMaster)
         _qFramework.SceneDone(S_MOD)

         ; Reset the leash holder's confidence any time the leash is attached in case he has
         ; been unloaded and thus reset.
         ; If the leash holder's confidence is too low increase it to avoid problems.
         If ((-100.0 != _fPreviousConfidence) && (1 > _fPreviousConfidence))
            _aLeashHolder.SetActorValue("Confidence", 1.0)
         EndIf
      Else
         ; Otherwise finish the assualt by making sure she is locked back into the furniture.
         bSceneContinuing = True
         ; Disable Milk Mod Economy, preventing it from starting animations on the player.
         If (_oMmeBeingMilkedSpell && !_aPlayer.HasSpell(_oMmeBeingMilkedSpell))
            _aPlayer.AddSpell(_oMmeBeingMilkedSpell, False)
            _bMmeSuppressed = True
            ; Add a delay to make sure the spell has taken effect.
            Utility.Wait(0.5)
         EndIf
         ObjectReference oFurniture = _oBdsmFurniture
         If (!oFurniture)
            oFurniture = _oPunishmentFurniture
            If (!oFurniture)
               oFurniture = _oTransferFurniture
            EndIf
         EndIf
         _qZbfSlaveActions.RestrainInDevice(oFurniture, aMaster, S_MOD)
         ; Set dialog to busy 1 to allow for a short delay before the next conversation.
         _iDialogueBusy = 1
      EndIf
   ElseIf (S_MOD + "_PrepBdsm" == szMessage)
      ; We are removing the player's arm binder before locking her in furniture.
      ; Find the furniture we are locking her in.
      ObjectReference oFurniture = _oPunishmentFurniture
      If (!oFurniture)
         oFurniture = _oTransferFurniture
         If (!oFurniture)
            Int iIndex = _aoFavouriteCell.Find(_aPlayer.GetParentCell())
            If (-1 != iIndex)
               oFurniture = (_aoFavouriteFurniture[iIndex] As ObjectReference)
            EndIf
         EndIf
      EndIf

      If (oFurniture)
         _qFramework.SetBdsmFurnitureLocked()
         _aAliasFurnitureLocker.ForceRefTo(aMaster)
         If (!_oPunishmentFurniture)
            _bFurnitureForFun = True
            _oBdsmFurniture = oFurniture
         EndIf
         _fFurnitureReleaseTime = 0
         UnequipBdsmItem(_aoArmRestraints, _qZadLibs.zad_DeviousArmbinder, aMaster)
         bSceneContinuing = True
         ; Disable Milk Mod Economy, preventing it from starting animations on the player.
         If (_oMmeBeingMilkedSpell && !_aPlayer.HasSpell(_oMmeBeingMilkedSpell))
            _aPlayer.AddSpell(_oMmeBeingMilkedSpell, False)
            _bMmeSuppressed = True
            ; Add a delay to make sure the spell has taken effect.
            Utility.Wait(0.5)
         EndIf
         _qZbfSlaveActions.RestrainInDevice(oFurniture, aMaster, S_MOD + "_LeashToBdsm")
      Else
         ; Something went wrong.  End the scene if possible.
         _qFramework.SceneDone(S_MOD)
      EndIf
   ElseIf (S_MOD + "_LeashToBdsm" == szMessage)
      If (_oPunishmentFurniture)
         ; The player is being locked in furniture as a punishment.  Don't stop the leash game.
         _qFramework.SceneDone(S_MOD + "_MoveToFurniture")
         _iFurnitureRemaining += ((180 + (180 * _iBadBehaviour)) / _fMcmPollTime As Int)

         ; Make sure the blindfold and gag punishment last until the player is released.
         If (_iBlindfoldRemaining < _iFurnitureRemaining)
            _iBlindfoldRemaining = _iFurnitureRemaining
         EndIf
         If (_iGagRemaining < _iFurnitureRemaining)
            _iGagRemaining = _iFurnitureRemaining
         EndIf

         _iLongTermAgenda = 3
         _iLongTermAgendaDetails = 0

         ; Allow sex while the player is being punished.
         _qFramework.AddPermission(aMaster, _qFramework.AP_SEX)
         _qFramework.SetLeashTarget(None)

         ; Whip the player as further punishment.
         _qFramework.IncActorDominance(aMaster, 1, 0, 100)
         If (!StartWhippingScene(aMaster, 120, S_MOD + "_WhipBdsmPunish"))
            bSceneContinuing = True
         EndIf
      Else
         ; The leash game is done.
         Log(szName + " locks you up and walks away.", DL_CRIT, S_MOD)
         StopLeashGame()
         _qFramework.SceneDone(S_MOD)
      EndIf

      ; If we have suppressed Milk Mod Economy re-enable it.
      If (_bMmeSuppressed)
         If (_oMmeBeingMilkedSpell)
            _aPlayer.RemoveSpell(_oMmeBeingMilkedSpell)
         EndIf
         _bMmeSuppressed = False
      EndIf
   ElseIf (S_MOD + "_BdsmToLeash" == szMessage)
      Log(szName + " locks your device and slips a rope around your neck.", DL_CRIT, S_MOD)
      bSceneContinuing = True
      ; Disable Milk Mod Economy, preventing it from starting animations on the player.
      If (_oMmeBeingMilkedSpell && !_aPlayer.HasSpell(_oMmeBeingMilkedSpell))
         _aPlayer.AddSpell(_oMmeBeingMilkedSpell, False)
         _bMmeSuppressed = True
         ; Add a delay to make sure the spell has taken effect.
         Utility.Wait(0.5)
      EndIf
      _qZbfSlaveActions.RestrainInDevice(_oBdsmFurniture, aMaster, S_MOD)
      StartLeashGame(aMaster)
   ElseIf ((S_MOD + "_Inspect" == szMessage) || (S_MOD + "_F_Inspect" == szMessage))
      Log(szName + " checks your restraints ensuring they are secure.", DL_CRIT, S_MOD)
      _qZadArmbinder.IsLocked = True
      _qZadArmbinder.IsLoose = False
      _qZadArmbinder.StruggleCount = 0

      ; If there are any outstanding assaults pending perfomr them now as well.
      If (_iAssault)
         FinalizeAssault(aMaster, szName)
      EndIf

      _qFramework.SceneDone(S_MOD)
   ElseIf (S_MOD + "_Whip" == StringUtil.Substring(szMessage, 0, 9))
      ; Restore the base damage for the punishment cane if it was adjusted.
      If (_oWeaponZbfCane && _iZbfCaneBaseDamage)
         _aPlayer.ModActorValue("DamageResist", -10000)
         _oWeaponZbfCane.SetBaseDamage(_iZbfCaneBaseDamage)
         _oWeaponZbfCane.SetResist(_szZbfCaneResistance)
         _iZbfCaneBaseDamage = 0
         _szZbfCaneResistance = ""

         ; Reduce the player's health as the whipping is not expected to have done any damage.
         ; Only do this if we were successful in adjusting the cane's base damage.
         Float fDamage = (_aPlayer.GetActorValue("Health") * 12 / 100) + \
                         (_aPlayer.GetLevel() / 2)
         _aPlayer.DamageActorValue("Health", fDamage)
      EndIf

      _qFramework.SceneDone(szMessage)

      ; Goal 11: Punish/Leave in Furniture
      If (S_MOD + "_WhipBdsmPunish" == szMessage)
         StartConversation(aMaster, 11)
      EndIf
   ElseIf (S_MOD == szMessage)
      If (0 < _iMovementSafety)
         ReMobilizePlayer()
      EndIf
      ; If we have suppressed Milk Mod Economy re-enable it.
      If (_bMmeSuppressed)
         If (_oMmeBeingMilkedSpell)
            _aPlayer.RemoveSpell(_oMmeBeingMilkedSpell)
         EndIf
         _bMmeSuppressed = False
      EndIf
      _qFramework.SceneDone(S_MOD)
   Else
      Log("Unknown Slave Action Event:  \"" + szMessage + "\"", DL_ERROR, S_MOD)
   EndIf

   ; If there are further pending actions perform them now.
   If (!bSceneContinuing)
      If (_iFurnitureGoals)
         ProcessFurnitureGoals(aMaster)

         ; If we have completed all short-term goals clear the variable.
         If (!_iFurnitureGoals && (0 < _iLeashHolderGoal))
            _iLeashHolderGoal = -2
         EndIf
      Else
         ProcessPendingAction()
      EndIf
   EndIf
EndEvent

Event PreSexCallback(String szEvent, String szArg, Float fNumArgs, Form oSender)
   ; If we are configured to hide the player's BDSM furniture during sex, do so.
   If (!_oHiddenFurniture && _qMcm.bFurnitureHide)
      _oHiddenFurniture = _qFramework.GetBdsmFurniture()
      If (_oHiddenFurniture)
         _oHiddenFurniture.Disable()
      EndIf
   EndIf

   ; Make sure the player is involved in this scene.
   Actor[] aaEventActors = _qSexLab.HookActors(szArg)
   If (-1 == aaEventActors.Find(_aPlayer))
      Return
   EndIf

   ; If the leash game is expected to handle sex events do so now.
   If ((0 < _iLeashGameDuration) && _qMcm.bAllowSex)
      _bLeashHolderStopped = True
      _aLeashHolder.EnableAI(False)
   EndIf
EndEvent

Event PostSexCallback(String szEvent, String szArg, Float fNumArgs, Form oSender)
   ; Make sure the player is involved in this scene.
   Actor[] aaEventActors = _qSexLab.HookActors(szArg)
   If (-1 == aaEventActors.Find(_aPlayer))
      Return
   EndIf

   If (_qMcm.bSexDispositions)
      Int iIndex = aaEventActors.Length - 1
      While (0 <= iIndex)
         Actor aPartner = aaEventActors[iIndex]
         Race oRace = aPartner.GetRace()
         ; Checking the playable race excludes animals from the processing.
         If ((_aPlayer != aPartner) && oRace.IsPlayable())
            Int iActorFlags = _qFramework.GetActorFlags(aPartner)
            Int iCurrDominance = _qFramework.GetActorDominance(aPartner, 0, 80, True, 1)
            Bool bDominant = (Math.LogicalAnd(_qFramework.AF_SLAVE_TRADER, iActorFlags) || \
                              Math.LogicalAnd(_qFramework.AF_OWNER, iActorFlags) || \
                              (Math.LogicalAnd(_qFramework.AF_DOMINANT, iActorFlags) && \
                               (50 <= iCurrDominance)))
            Actor aVictim = _qSexLab.HookVictim(szArg)
            Int iDeltaInterest = 1
            Int iDeltaDominance = 1
            If (aVictim == aPartner)
               ; The NPC was raped.
               iDeltaDominance = -3
               If (!bDominant)
                  ; The NPC is submissive.
                  iDeltaInterest = 3
               Else
                  iDeltaInterest = -3
               EndIf
            ElseIf ((_aPlayer == aVictim) || (30 <= _qFramework.GetVulnerability(_aPlayer)))
               ; The player was raped or at least locked in bondage for the sex.
               iDeltaDominance = 3
               If (bDominant)
                  ; The NPC is dominant.
                  iDeltaInterest = 3
               Else
                  iDeltaInterest = -1
               EndIf
            ElseIf (aVictim)
               ; A third party was raped.
               iDeltaDominance = 3
            EndIf
            _qFramework.IncActorInterest(aPartner, iDeltaInterest, 0, 100)
            _qFramework.IncActorDominance(aPartner, iDeltaDominance, 0, 100)
         EndIf

         iIndex -= 1
      EndWhile
   EndIf
   If (_bLeashHolderStopped)
      _bLeashHolderStopped = False
      _aLeashHolder.EnableAI()
   EndIf

   ; If we are still processing a furniture scene try to continue it.
   If (_iFurnitureGoals)
      Bool bProcessingDone = False
      Int iIndex = aaEventActors.Length - 1
      While (!bProcessingDone && (0 <= iIndex))
         If (_aPlayer != aaEventActors[iIndex])
            ProcessFurnitureGoals(aaEventActors[iIndex])
            bProcessingDone = True
         EndIf
         iIndex -= 1
      EndWhile

      ; If we have completed all short-term goals clear the variable.
      If (!_iFurnitureGoals && (0 < _iLeashHolderGoal))
         _iLeashHolderGoal = -2
      EndIf
   EndIf

   ; If there is furniture we have previously hidden, reveal it now.
   If (_oHiddenFurniture)
      _oHiddenFurniture.Enable()
      _oHiddenFurniture = None
   EndIf
EndEvent

Event EventSdPlusStart(String szEventName, String szArg, Float fArg = 1.0, Form oSender)
   StartSdPlus()
EndEvent

Event EventSdPlusStop(String szEventName, String szArg, Float fArg = 1.0, Form oSender)
   StopSdPlus()
EndEvent

Event UpdateDfwMcm(String sCategory="")
   If ("SafewordFurniture" == sCategory)
      Log("Safeword BDSM Furniture.", DL_CRIT, S_MOD)
      ReMobilizePlayer()
      _aAliasFurnitureLocker.Clear()
      _bFurnitureForFun = False
      _qFramework.SetBdsmFurnitureLocked(False)
      _qFramework.SceneDone(S_MOD)
   EndIf

   If ("SafewordLeash" == sCategory)
      Log("Safeword Leash.", DL_CRIT, S_MOD)
      StopLeashGame(bReturnItems=True, bUnequip=True)
      _qFramework.SceneDone(S_MOD)
   EndIf
EndEvent

Event DebugMovePlayer(Int iTarget, Float fXOffset, Float fYOffset)
   If (_aLeashHolder)
      Log("Handling DFW Move Player Event: 0x" + _qDfwUtil.ConvertHexToString(iTarget, 8), \
          DL_DEBUG, S_MOD)

      ; If we have a scene in progress clear it.
      String szCurrScene = _qFramework.GetCurrentScene()
      If (S_MOD == StringUtil.Substring(szCurrScene, 0, 4))
         _qFramework.SceneDone(szCurrScene)
      EndIf

      ; If the player is locked in furniture make sure to unlock her before the move.
      ObjectReference oCurrFurniture = _qFramework.GetBdsmFurniture()
      If (oCurrFurniture)
         ; Furniture for fun shouldn't be on at the same time as the leash game but clear it
         ; just in case.
         _bFurnitureForFun = False
         _aAliasFurnitureLocker.Clear()
         _qFramework.SetBdsmFurnitureLocked(False)
         ;    EnablePlayerControls(Move,  Fight, Cam,   Look,  Sneak, Menu,  Activ, Journ)
         Game.EnablePlayerControls(True,  False, False, False, False, False, True,  False)
         Utility.Wait(0.25)
         oCurrFurniture.Activate(_aPlayer)
      EndIf
      _oBdsmFurniture = None
      _oTransferFurniture = None

      ; If some furniture was hidden for a sex scene re-enable it.
      If (_oHiddenFurniture)
         _oHiddenFurniture.Enable()
         _oHiddenFurniture = None
      EndIf

      ; If the player has been imobilized for some reason restore movement.
      If (0 < _iMovementSafety)
         ReMobilizePlayer()
         Utility.Wait(5)
      EndIf

      ; Wait for the player and leash holder to not be sitting before moving them.
      Int iSafety = 25
      While (iSafety && (_aLeashHolder.GetSitState() || _aPlayer.GetSitState()))
         Utility.Wait(0.1)
      EndWhile

      ObjectReference oTarget = (Game.GetFormFromFile(iTarget, "Skyrim.esm") As ObjectReference)
      If (oTarget != _aLeashHolder)
         _aLeashHolder.MoveTo(oTarget, fXOffset, fYOffset)
      EndIf
      ;_aPlayer.MoveTo(oTarget, fXOffset, fYOffset)
      _aPlayer.MoveTo(_aLeashHolder)
      Utility.Wait(3)

      ; If the player is not leashed (for example during furniture punishment) restore it now.
      If (!_qFramework.GetLeashTarget())
         _qFramework.SetLeashTarget(_aLeashHolder)

         ; Reset the leash holder's confidence any time the leash is attached in case he has
         ; been unloaded and thus reset.
         ; If the leash holder's confidence is too low increase it to avoid problems.
         If ((-100.0 != _fPreviousConfidence) && (1 > _fPreviousConfidence))
            _aLeashHolder.SetActorValue("Confidence", 1.0)
         EndIf
      EndIf

      ; Make sure the player is gagged to prevent using this as easy access to guards.
      If (!_qFramework.IsPlayerGagged())
         ; 0x0002: Gag
         ; 0x2000: Make sure the Gag is secure
         _iAssault = Math.LogicalOr(0x2000 + 0x0002, _iAssault)
      EndIf

      ; If the player is not in an arm binder for some reason lock her up now.
      If (!_qFramework.IsPlayerArmLocked())
         ; 0x0004: Bind Arms
         _iAssault = Math.LogicalOr(0x0004, _iAssault)
      EndIf

      ; If there are any reasons to perform an assault scene on the player start it now.
      If (_iAssault)
         FinalizeAssault(_aLeashHolder, _aLeashHolder.GetDisplayName())
      EndIf

      ; If the player was previously in punishment furniture make sure to return her to it.
      If (_oPunishmentFurniture)
         _oPunishmentFurniture = None
         StartPunishmentFurniture(_aLeashHolder)
      EndIf

      ; Punish the player to discourage the use of this feature.
      _iGagRemaining += 180
      If (!_iLongTermAgenda)
         _iLongTermAgenda = 3
      EndIf
      If (_iFurnitureRemaining)
         _iFurnitureRemaining += 300
      EndIf
      If (_iLeashGameDuration)
         _iLeashGameDuration += 180
      EndIf
      If (_iBlindfoldRemaining)
         _iBlindfoldRemaining += 180
      EndIf
   EndIf
EndEvent

Event HandleCallOut(Int iCallType, Int iRange, Form oRecommendedActor)
   ; Don't handle call outs if we are shutting down the mod.
   If (_bMcmShutdownMod)
      Return
   EndIf

   Actor aActor = (oRecommendedActor As Actor)
   String szName = aActor.GetDisplayName()
   Bool bHandleCallOut

   ; If the hotkey has been hijacked for a debug feature perform that instead.
   If (2 == iCallType)
      If (_qMcm.bHotkeyPackage)
         If (_aLeashHolder)
            Log("Cycling Leash Holder AI Package.", DL_DEBUG, S_MOD)
            _qFramework.ReEvaluatePackage(_aLeashHolder)
         Endif
         _qFramework.HandleCallForAttention()
         _qFramework.CallOutDone()
         Return
      EndIf
   EndIf

   ; If there is no recommended actor (most likely no one nearby) don't handle it.
   ; Also don't try to handle the call for help if it is the leash holder and he is busy.
   If (!aActor || (_iLeashHolderGoal && (aActor == _aLeashHolder)))
      Return
   EndIf

   Bool bPreviouslyAnnoyed = (5 < _iVerbalAnnoyance)
   If ((1 == iCallType) && ((0 < _iLeashGameDuration) || \
                            (_qFramework.IsBdsmFurnitureLocked())))
      ; Add a random delay to allow other mods to maybe handle this call out.
      Utility.Wait(Utility.RandomFloat(0, 0.5))

      ; If no other mod is handling the call do so.
      If (("" == _qFramework.GetCurrentScene()) && _qFramework.HandleCallForHelp())
         bHandleCallOut = True
         _iVerbalAnnoyance += 2
      EndIf
   ElseIf ((2 == iCallType) && ((0 < _iLeashGameDuration) || \
                                (_qFramework.IsBdsmFurnitureLocked())))
      ; Add a random delay to allow other mods to maybe handle this call out.
      Utility.Wait(Utility.RandomFloat(0, 0.5))

      ; If no other mod is handling the call do so.
      If (_qFramework.HandleCallForAttention())
         bHandleCallOut = True
         _iVerbalAnnoyance += 1
      EndIf
   EndIf
   If (bHandleCallOut)
      Log("Handling CallOut: " + iCallType, DL_DEBUG, S_MOD)

      ; Let the player know when NPCs are becoming annoyed by the ruckus she is making.
      If ((5 < _iVerbalAnnoyance) && !bPreviouslyAnnoyed)
         Log(szName + " seems annoyed at your constant whining.", DL_CRIT, S_MOD)
      EndIf

      ; If the player is locked in furniture with no controller, try to find an actor who is not
      ; a guard to respond to the call out.  This is because guards do extra damage during
      ; whipping scenes and using them as furniture lockers should be avoided.
      If (!_iLeashGameDuration && !_bFurnitureForFun && aActor.IsGuard())
         Actor aNew = _qFramework.GetRandomActor(iRange, \
                                                 iIncludeFlags=_qFramework.AF_DOMINANT + \
                                                               _qFramework.AF_OWNER + \
                                                               _qFramework.AF_SLAVE_TRADER, \
                                                 iExcludeFlags=_qFramework.AF_GUARDS)
         If (!aNew)
            aNew = _qFramework.GetRandomActor(iRange, iExcludeFlags=_qFramework.AF_CHILD + \
                                                                    _qFramework.AF_GUARDS)
         EndIf
         If (aNew)
            aActor = aNew
         EndIf
      EndIf

      ; If the player has been causing a scene gag her instead of responding.
      If ((_iVerbalAnnoyance - 3) > Utility.RandomInt(1, 10))
         If (_qFramework.IsPlayerGagged())
            ; 0x2000: Make sure the Gag is secure
            _iAssault = Math.LogicalOr(0x2000, _iAssault)
            PlayApproachAnimation(aActor, "Assault")
         ElseIf (!_qFramework.IsGagStrict())
            ; 0x0002: Gag
            _iAssault = Math.LogicalOr(0x0002, _iAssault)
            PlayApproachAnimation(aActor, "Assault")
         Else
            Log(szName + " looks over at you looking annoyed.", DL_CRIT, S_MOD)
         EndIf
      Else
         _qFramework.SceneStarting(S_MOD + "_CallOut", 60)
         _qFramework.ApproachPlayer(aActor, 15, 2, S_MOD + "_CallOut")
      EndIf
   EndIf
EndEvent

; iType: 1: Approach Player  2: Move To Location  3: Move To Object
Event MovementDone(Int iType, Form oActor, Bool bSucceeded, String szModId)
   ; We are only interested in animations that we started.
   If (S_MOD != StringUtil.Substring(szModId, 0, 4))
      Return
   EndIf

   Actor aActor = (oActor As Actor)
   String szName = aActor.GetDisplayName()

   Log("Movement Done " + szModId + ": " + iType + ", " + szName + ", " + bSucceeded, \
       DL_DEBUG, S_MOD)

   ; On second thought, the scene seems to be ending in failure reasonably frequently.
   ; For now let's try to just keep going when that happens.
   ;; If the scene did not succeed, simply end the scene.
   ;If (!bSucceeded)
   ;   String szCurrScene = _qFramework.GetCurrentScene()
   ;   If (S_MOD == StringUtil.Substring(szCurrScene, 0, 4))
   ;      _qFramework.SceneDone(szCurrScene)

   ;      If (S_MOD + "_CallOut" == szModId)
   ;         _qFramework.CallOutDone()
   ;      EndIf
   ;   EndIf
   ;   Return
   ;EndIf

   If ((S_MOD + "_CallOut" == szModId) || (S_MOD + "_StartDialogue" == szModId))
      ; If the player is supposed to be restrained but is not discipline her for misbehaving.
      If ((_iGagRemaining && !_qFramework.IsPlayerGagged()) || \
          (_iBlindfoldRemaining && _aPlayer.WornHasKeyword(_qZadLibs.zad_DeviousBlindfold)))
         ; The slaver was interrupted from approaching the player for sex.  Make sure he does so
         ; afterward
         AddPendingAction(1, aActor, 12, S_MOD + "_StartDialogue", bPrepend=True)

         ; Goal 14: Punish Removing Restraints
         StartConversation(aActor, 14)
      Else
         ; Goal 12: Approach for Interest
         StartConversation(aActor, 12)
      EndIf
   ElseIf (S_MOD + "_LeashGame" == szModId)
      If (3 == _iMcmLeashGameStyle)
         Log("Dialogue Leash Game Style not yet supported.", DL_CRIT, S_MOD)
         _qFramework.SceneDone(S_MOD + "_LeashGame")
         Return
      EndIf

      ; If the slaver is no longer behind the player or the player's weapons are drawn have the
      ; slaver stand down.
      Float fSlaverPosition = _aPlayer.GetHeadingAngle(aActor)
      If ((((45 >= fSlaverPosition) && (-45 <= fSlaverPosition)) && \
           !_qFramework.IsPlayerArmLocked()) || \
          (_aPlayer.IsWeaponDrawn() && _qFramework.GetWeaponLevel()))
         Log(szName + " stares you down but decides against starting anything.", DL_CRIT, S_MOD)
         aActor.EnableAI(False)
         Utility.Wait(5)
         aActor.EnableAI()
         _qFramework.SceneDone(S_MOD + "_LeashGame")
         Return
      EndIf
      ; Otherwise the player is vulnerable.  Start the leash game.
      Log(szName + " lassos a rope around your neck.", DL_CRIT, S_MOD)
      StartLeashGame(aActor)
      _qFramework.SceneDone(S_MOD + "_LeashGame")
   ElseIf (S_MOD + "_Furniture" == szModId)
      ObjectReference oFurniture = _oPunishmentFurniture
      If (!oFurniture)
         oFurniture = _oTransferFurniture
      EndIf
      If (oFurniture)
         Log("Arrived at Location.  Moving to furniture." , DL_TRACE, S_MOD)
         If (2 == iType)
            ; We have arrived at the furniture's location.  Now move to the furniture.
            _qFramework.MoveToObject(_aLeashHolder, oFurniture, szModId)
         ElseIf (3 == iType)
            ; We have arrived at the furniture.  Lock the player in.
            ActorSitStateWait(_aLeashHolder)
            _qZbfSlaveActions.BindPlayer(akMaster=_aLeashHolder, asMessage=S_MOD + "_PrepBdsm")
         EndIf
      EndIf
   ElseIf (S_MOD + "_SimpleSlavery" == szModId)
      If (2 == iType)
         ; We have arrived at the auction's location.
         Location oCurrLocation = _qFramework.GetCurrentLocation()
         Int iIndex = -1
         If (_aoSimpleSlaveryLocation)
            iIndex = _aoSimpleSlaveryLocation.Find(oCurrLocation)
         EndIf
         If ((-1 != iIndex) && _aoSimpleSlaveryEntranceObject)
            ; We have arrived at the auction's location.  Move to the entrance door.
            _qFramework.MoveToObject(aActor, _aoSimpleSlaveryEntranceObject[iIndex], szModId)
         ElseIf (_aoSimpleSlaveryRegion)
            iIndex = _aoSimpleSlaveryRegion.Find(oCurrLocation)
            If (-1 != iIndex)
               ; We have arrived in the region.  Now move to the location.
               _qFramework.MoveToLocation(aActor, _aoSimpleSlaveryLocation[iIndex], szModId)
            Else
               Log("Error: Cannot Find SS Entrance.", DL_ERROR, S_MOD)
            EndIf
         Else
            Log("Error: Cannot Find SS Entrance.", DL_ERROR, S_MOD)
         EndIf
      ElseIf (3 == iType)
         If (_oSimpleSlaveryInternalDoor && _aSimpleSlaveryAuctioneer)
            aActor.MoveTo(_oSimpleSlaveryInternalDoor)
            _qFramework.MoveToObject(aActor, _aSimpleSlaveryAuctioneer, S_MOD + "_SS_Internal")
         Else
            ; We can't progress the scene inside the auction house.  Start Simple Slavery now.
            ; The short delay helps the player transfer with the proper equipment.
            StopLeashGame(bReturnItems=True, bUnequip=True)
            Utility.Wait(1)
            SendModEvent("SSLV Entry")
         EndIf
      EndIf
   ElseIf (S_MOD + "_SS_Internal" == szModId)
      ; We have arrived at the entrance.  For now start the auction from here.
      ; The short delay helps the player transfer with the proper equipment.
      StopLeashGame(bReturnItems=True, bUnequip=True)
      Utility.Wait(1)
      ; Move the leash holder to their package location so they are not in the auction house.
      aActor.EvaluatePackage()
      aActor.MoveToMyEditorLocation()
      aActor.MoveToPackageLocation()
      SendModEvent("SSLV Entry")
   EndIf
EndEvent


;***********************************************************************************************
;***                                  PRIVATE FUNCTIONS                                      ***
;***********************************************************************************************
Function CreateRestraintsArrays()
   _aoGags = New Armor[29]
   _aoGags[00] = (Game.GetFormFromFile(0x0002B073, "Devious Devices - Integration.esm") as Armor)  ;;; zad_gagBallInventory
   _aoGags[01] = (Game.GetFormFromFile(0x0002B075, "Devious Devices - Integration.esm") as Armor)  ;;; zad_gagPanelInventory
   _aoGags[02] = (Game.GetFormFromFile(0x0002B076, "Devious Devices - Integration.esm") as Armor)  ;;; zad_gagRingInventory
   _aoGags[03] = (Game.GetFormFromFile(0x00034253, "Devious Devices - Integration.esm") as Armor)  ;;; zad_gagStrapBallInventory
   _aoGags[04] = (Game.GetFormFromFile(0x00034255, "Devious Devices - Integration.esm") as Armor)  ;;; zad_gagStrapRingInventory
   _aoGags[05] = (Game.GetFormFromFile(0x0000D4EE, "Devious Devices - Expansion.esm") as Armor)    ;;; zadx_GagEboniteBallInventory
   _aoGags[06] = (Game.GetFormFromFile(0x0000D4F3, "Devious Devices - Expansion.esm") as Armor)    ;;; zadx_GagEbonitePanelInventory
   _aoGags[07] = (Game.GetFormFromFile(0x0000D4F0, "Devious Devices - Expansion.esm") as Armor)    ;;; zadx_GagEboniteRingInventory
   _aoGags[08] = (Game.GetFormFromFile(0x0000D4F6, "Devious Devices - Expansion.esm") as Armor)    ;;; zadx_GagEboniteStrapBallInventory
   _aoGags[09] = (Game.GetFormFromFile(0x0000D4F8, "Devious Devices - Expansion.esm") as Armor)    ;;; zadx_GagEboniteStrapRingInventory
   _aoGags[10] = (Game.GetFormFromFile(0x00011126, "Devious Devices - Expansion.esm") as Armor)    ;;; zadx_RDEGagEbBallInventory
   _aoGags[11] = (Game.GetFormFromFile(0x00011130, "Devious Devices - Expansion.esm") as Armor)    ;;; zadx_RDEGagEbHarnPanelInventory
   _aoGags[12] = (Game.GetFormFromFile(0x0001112A, "Devious Devices - Expansion.esm") as Armor)    ;;; zadx_RDEGagEbRingInventory
   _aoGags[13] = (Game.GetFormFromFile(0x00011146, "Devious Devices - Expansion.esm") as Armor)    ;;; zadx_RDEGagEbStrapBallInventory
   _aoGags[14] = (Game.GetFormFromFile(0x0001114A, "Devious Devices - Expansion.esm") as Armor)    ;;; zadx_RDEGagEbStrapRingInventory
   _aoGags[15] = (Game.GetFormFromFile(0x00011124, "Devious Devices - Expansion.esm") as Armor)    ;;; zadx_RDLgagBallInventory
   _aoGags[16] = (Game.GetFormFromFile(0x0001112D, "Devious Devices - Expansion.esm") as Armor)    ;;; zadx_RDLgagHarnPanelInventory
   _aoGags[17] = (Game.GetFormFromFile(0x00011128, "Devious Devices - Expansion.esm") as Armor)    ;;; zadx_RDLgagRingInventory
   _aoGags[18] = (Game.GetFormFromFile(0x00011144, "Devious Devices - Expansion.esm") as Armor)    ;;; zadx_RDLgagStrapBallInventory
   _aoGags[19] = (Game.GetFormFromFile(0x00011148, "Devious Devices - Expansion.esm") as Armor)    ;;; zadx_RDLgagStrapRingInventory
   _aoGags[20] = (Game.GetFormFromFile(0x0000F04A, "Devious Devices - Expansion.esm") as Armor)    ;;; zadx_WTEGagEbBallInventory
   _aoGags[21] = (Game.GetFormFromFile(0x0000F054, "Devious Devices - Expansion.esm") as Armor)    ;;; zadx_WTEGagEbHarnPanelInventory
   _aoGags[22] = (Game.GetFormFromFile(0x0000F04E, "Devious Devices - Expansion.esm") as Armor)    ;;; zadx_WTEGagEbRingInventory
   _aoGags[23] = (Game.GetFormFromFile(0x0000F062, "Devious Devices - Expansion.esm") as Armor)    ;;; zadx_WTEGagEbStrapRingInventory
   _aoGags[24] = (Game.GetFormFromFile(0x0000F048, "Devious Devices - Expansion.esm") as Armor)    ;;; zadx_WTLgagBallInventory
   _aoGags[25] = (Game.GetFormFromFile(0x0000F051, "Devious Devices - Expansion.esm") as Armor)    ;;; zadx_WTLgagHarnPanelInventory
   _aoGags[26] = (Game.GetFormFromFile(0x0000F04C, "Devious Devices - Expansion.esm") as Armor)    ;;; zadx_WTLgagRingInventory
   _aoGags[27] = (Game.GetFormFromFile(0x0000F05C, "Devious Devices - Expansion.esm") as Armor)    ;;; zadx_WTLgagStrapBallInventory
   _aoGags[28] = (Game.GetFormFromFile(0x0000F060, "Devious Devices - Expansion.esm") as Armor)    ;;; zadx_WTLgagStrapRingInventory

   _aoArmRestraints = New Armor[7]
   _aoArmRestraints[0] = (Game.GetFormFromFile(0x00028A5A, "Devious Devices - Integration.esm") as Armor)  ;;; zad_armBinderInventory
   _aoArmRestraints[1] = (Game.GetFormFromFile(0x0000D4D6, "Devious Devices - Expansion.esm") as Armor)    ;;; zadx_EboniteArmbinderInventory
   _aoArmRestraints[2] = (Game.GetFormFromFile(0x000110F2, "Devious Devices - Expansion.esm") as Armor)    ;;; zadx_RDEarmbinderInventory
   _aoArmRestraints[3] = (Game.GetFormFromFile(0x000110F0, "Devious Devices - Expansion.esm") as Armor)    ;;; zadx_RDLarmbinderInventory
   _aoArmRestraints[4] = (Game.GetFormFromFile(0x0000F016, "Devious Devices - Expansion.esm") as Armor)    ;;; zadx_WTEarmbinderInventory
   _aoArmRestraints[5] = (Game.GetFormFromFile(0x0000F013, "Devious Devices - Expansion.esm") as Armor)    ;;; zadx_WTLarmbinderInventory
   _aoArmRestraints[6] = (Game.GetFormFromFile(0x0004F18C, "Devious Devices - Integration.esm") as Armor)  ;;; zad_yokeInventory

   _aoLegRestraints = New Armor[6]
   _aoLegRestraints[00] = (Game.GetFormFromFile(0x000116FA, "Devious Devices - Expansion.esm") as Armor)  ;;; zadx_XinWTLPonyBootsInventory
   _aoLegRestraints[01] = (Game.GetFormFromFile(0x000116FE, "Devious Devices - Expansion.esm") as Armor)  ;;; zadx_XinWTEbonitePonyBootsInventory
   _aoLegRestraints[02] = (Game.GetFormFromFile(0x000116F1, "Devious Devices - Expansion.esm") as Armor)  ;;; zadx_XinPonyBootsInventory
   _aoLegRestraints[03] = (Game.GetFormFromFile(0x000116F6, "Devious Devices - Expansion.esm") as Armor)  ;;; zadx_XinEbonitePonyBootsInventory
   _aoLegRestraints[04] = (Game.GetFormFromFile(0x00011706, "Devious Devices - Expansion.esm") as Armor)  ;;; zadx_XinRDEbonitePonyBootsInventory
   _aoLegRestraints[05] = (Game.GetFormFromFile(0x000048B8, "Devious Devices - Expansion.esm") as Armor)  ;;; zadx_bootsLockingInventory

   _aoCollars = New Armor[14]
   _aoCollars[00] = (Game.GetFormFromFile(0x00017759, "Devious Devices - Integration.esm") as Armor)  ;;; zad_collarPostureSteelInventory
   _aoCollars[01] = (Game.GetFormFromFile(0x0001775C, "Devious Devices - Integration.esm") as Armor)  ;;; zad_cuffsPaddedCollarInventory
   _aoCollars[02] = (Game.GetFormFromFile(0x00032745, "Devious Devices - Integration.esm") as Armor)  ;;; zad_cuffsLeatherCollarInventory
   _aoCollars[03] = (Game.GetFormFromFile(0x00047002, "Devious Devices - Integration.esm") as Armor)  ;;; zad_collarPostureLeatherInventory
   _aoCollars[04] = (Game.GetFormFromFile(0x0000D4DF, "Devious Devices - Expansion.esm") as Armor)    ;;; zadx_CuffsEboniteCollarInventory
   _aoCollars[05] = (Game.GetFormFromFile(0x0000E538, "Devious Devices - Expansion.esm") as Armor)    ;;; zadx_CollarPostureEboniteInventory
   _aoCollars[06] = (Game.GetFormFromFile(0x0000F01D, "Devious Devices - Expansion.esm") as Armor)    ;;; zadx_WTLcuffsLCollarInventory
   _aoCollars[07] = (Game.GetFormFromFile(0x0000F020, "Devious Devices - Expansion.esm") as Armor)    ;;; zadx_WTECuffsECollarInventory
   _aoCollars[08] = (Game.GetFormFromFile(0x0000F06A, "Devious Devices - Expansion.esm") as Armor)    ;;; zadx_WTLCollarPostLeatherInventory
   _aoCollars[09] = (Game.GetFormFromFile(0x0000F06C, "Devious Devices - Expansion.esm") as Armor)    ;;; zadx_WTECollarPostEboniteInventory
   _aoCollars[10] = (Game.GetFormFromFile(0x000110FE, "Devious Devices - Expansion.esm") as Armor)    ;;; zadx_RDLcuffsLCollarInventory
   _aoCollars[11] = (Game.GetFormFromFile(0x00011100, "Devious Devices - Expansion.esm") as Armor)    ;;; zadx_RDECuffsECollarInventory
   _aoCollars[12] = (Game.GetFormFromFile(0x00011152, "Devious Devices - Expansion.esm") as Armor)    ;;; zadx_RDLCollarPostLeatherInventory
   _aoCollars[13] = (Game.GetFormFromFile(0x00011154, "Devious Devices - Expansion.esm") as Armor)    ;;; zadx_RDECollarPostEboniteInventory

   _aoBlindfolds = New Armor[6]
   _aoBlindfolds[00] = (Game.GetFormFromFile(0x00004E25, "Devious Devices - Expansion.esm") as Armor)    ;;; zadx_blindfoldBlockingInventory
   _aoBlindfolds[01] = (Game.GetFormFromFile(0x0001334E, "Devious Devices - Expansion.esm") as Armor)    ;;; zadx_EbblindfoldBlockingInventory
   _aoBlindfolds[02] = (Game.GetFormFromFile(0x00013356, "Devious Devices - Expansion.esm") as Armor)    ;;; zadx_RDEblindfoldBlockingInventory
   _aoBlindfolds[03] = (Game.GetFormFromFile(0x00013354, "Devious Devices - Expansion.esm") as Armor)    ;;; zadx_RDLblindfoldBlockingInventory
   _aoBlindfolds[04] = (Game.GetFormFromFile(0x00013352, "Devious Devices - Expansion.esm") as Armor)    ;;; zadx_WTEblindfoldBlockingInventory
   _aoBlindfolds[05] = (Game.GetFormFromFile(0x00013350, "Devious Devices - Expansion.esm") as Armor)    ;;; zadx_WTLblindfoldBlockingInventory
EndFunction

Function Log(String szMessage, Int iLevel=0, String szClass="")
   If (szClass)
      szMessage = "[" + szClass + "] " + szMessage
   EndIf

   ; Log to the papyrus file.
   If (ilevel <= _iMcmLogLevel)
      Debug.Trace(szMessage)
   EndIf

   ; Also log to the Notification area of the screen.
   If (ilevel <= _iMcmLogLevelScreen)
      Debug.Notification(szMessage)
   EndIf
EndFunction

; A special name for debug (non permanent) log messages making them easier to locate.
Function DebugLog(String szMessage, Int iLevel=3)
   Log(szMessage, iLevel, S_MOD)
EndFunction

Int Function iMutexCreate(String szName, Int iTimeoutMs=1000)
   Int iIndex = -1

   ; Lock the mutex protecting the mutex list to protect creating two at once.
   ; AddXxxToArray() can unlock the thread allowing this function to run again.
   If (MutexLock(0, iTimeoutMs))
      iIndex = _aszMutexName.Find(szName)
      If (0 <= iIndex)
         ; This mutex already exists clear it.
         _aiMutex[iIndex] = 0
      Else
         ; Otherwise create a new mutex entry.
         _aiMutex      = _qDfwUtil.AddIntToArray(_aiMutex, 0)
         _aszMutexName = _qDfwUtil.AddStringToArray(_aszMutexName, szName)
         iIndex = _iMutexNext
         _iMutexNext += 1
      EndIf

      ; Release the mutex protecting the mutex list.
      MutexRelease(0)
   EndIf
   Return iIndex
EndFunction

Bool Function MutexLock(Int iMutex, Int iTimeoutMs=1000)
   ; If this is not a valid mutex return a failure.
   If ((0 > iMutex) || (_iMutexNext <= iMutex))
      Return False
   EndIf

   Bool bUseTimeout = (iTimeoutMs As Bool)
   While (0 < _aiMutex[iMutex])
      Utility.Wait(0.1)
      If (bUseTimeout)
         iTimeoutMs -= 100
         If (0 >= iTimeoutMs)
            ; Locking Failed due to timeout.
            Return False
         EndIf
      EndIf
   EndWhile
   ; Locking succeeded.  Increment the mutex and return success.
   _aiMutex[iMutex] = _aiMutex[iMutex] + 1
   Return True
EndFunction

Function MutexRelease(Int iMutex)
   ; If this is a valid mutex decrement it.
   If ((0 <= iMutex) && (_iMutexNext > iMutex))
      _aiMutex[iMutex] = _aiMutex[iMutex] - 1
   EndIf
EndFunction

Int Function StartSex(Actor aNpc, Bool bRape)
   If ((0 >= _qSexLab.ValidateActor(_aPlayer)) || (0 >= _qSexLab.ValidateActor(aNpc)))
      Return FAIL
   EndIf

   ; Keep track of some bound animations as the dominant actor cannot be switched for them.
   Bool bBoundAnimation = False

   Actor aVictim
   String szTags
   If (bRape)
      aVictim = _aPlayer
      szTags = "Rape"
   EndIf

   ; If the player is in a pillory try to play only pillory sex.
   ObjectReference oCurrFurniture = _qFramework.GetBdsmFurniture()
   Int iType = _qZbfShell.GetFurnitureType(oCurrFurniture)
   If ((9 == iType) || (10 == iType))
      bBoundAnimation = True
      szTags = "Pillory"

      ; Adjust the actor positions to help the scene line up with the actual furniture.
      aNpc.MoveTo(_aPlayer, -70 * Math.Sin(_aPlayer.GetAngleZ()), \
                            -70 * Math.Cos(_aPlayer.GetAngleZ()), 0.0)
      _aPlayer.MoveTo(_aPlayer, -35 * Math.Sin(_aPlayer.GetAngleZ()), \
                                -35 * Math.Cos(_aPlayer.GetAngleZ()), 0.0)
   EndIf

   Actor aDom = aNpc
   Actor aSub = _aPlayer
   Bool bIsPlayerMale = (0 == _aPlayer.GetActorBase().GetSex())
   Bool bIsNpcMale = (0 == aNpc.GetActorBase().GetSex())
   Int iDominance = _qFramework.GetActorDominance(aNpc, 20, 80, True)
   If (!bBoundAnimation && (!bRape || (10 >= Utility.RandomInt(1, 100))))
      Int iChance = (100 - iDominance)
      If (!bIsNpcMale)
         iChance += 20
      ElseIf (bIsPlayerMale)
         iChance -= 10
      Else
         iChance -= 20
      Endif

      ; If the NPC is feeling sub set the player as the dominant actor in the scene.
      If (iChance >= Utility.RandomInt(1, 100))
         aDom = _aPlayer
         aSub = aNpc
      Endif
   Endif

   ;_qSexLab.QuickStart(aSub, aDom, Victim=aVictim, AnimationTags=szTags)

   ; Create the SexLab Thread for managing the whole scene.
   sslThreadModel oSexLabThread = _qSexLab.NewThread()

   ; Define the actors who will be in the scene.
   oSexLabThread.AddActor(aSub)
   oSexLabThread.AddActor(aDom)
   oSexLabThread.SetVictim(aVictim)

   ; Define the animation to use in the scene.
   sslBaseAnimation[] aoAnimations = _qSexLab.GetAnimationsByTags(2, szTags)
   oSexLabThread.SetAnimations(aoAnimations)

   ; Validate at least one animation is available matching the tags.
   Int iNumAnimations = aoAnimations.Length
   If (!iNumAnimations)
      Log("Error: No Sexlab Animations for tags: " + szTags, DL_ERROR, S_MOD)
      Log("Try using the Zaz Animation Pack MCM to register animations.", DL_DEBUG, S_MOD)
   EndIf

   ;; Print off the list of animations for diagnostics purposes.
   ;String szName = "None"
   ;If (aoAnimations && aoAnimations[0])
   ;   szName = aoAnimations[0].Name
   ;EndIf
   ;Log("SexLab Animations " + iNumAnimations + ": " + szName, DL_DEBUG, S_MOD)
   ;Int iIndex = 1
   ;While (iIndex < iNumAnimations)
   ;   szName = "None"
   ;   If (aoAnimations && aoAnimations[iIndex])
   ;      szName = aoAnimations[iIndex].Name
   ;   EndIf
   ;   Log("SexLab Animation[" + iIndex + "]: " +  szName, DL_DEBUG, S_MOD)
   ;   iIndex += 1
   ;EndWhile

   ; For now don't centre on anything.  QuickStart() doesn't so let's try that for now.
   oSexLabThread.CenterOnObject(None)

   ; For now don't disable bed use.  QuickStart() doesn't so let's try that for now.
   oSexLabThread.DisableBedUse(False)

   ; Is this needed?  Can we try removing it?
   oSexLabThread.SetHook("")

   ; Start the sex scene.
   If (!oSexLabThread.StartThread())
      Log("Failed to start SexLab thread.", DL_ERROR, S_MOD)
      Return FAIL
   EndIf

   Return SUCCESS
EndFunction

; Actions can be:
; 1: Start Conversation.  Details: the new leash holder goal.
; 2: Assault Player.      Details: The _iAssault mask.
; 3: Furniture Assault.   Details: The _iFurnitureGoals mask.
Function AddPendingAction(Int iAction, Actor aActor, Int iDetails=0x0000, String szScene="", \
                          Int iSceneTimeout=180, Bool bPrepend=False)
   If (MutexLock(_iPendingActionMutex))
      _aiPendingAction  = _qDfwUtil.AddIntToArray(_aiPendingAction, iAction, bPrepend)
      _aoPendingActor   = _qDfwUtil.AddFormToArray(_aoPendingActor, aActor, bPrepend)
      _aiPendingDetails = _qDfwUtil.AddIntToArray(_aiPendingDetails, iDetails, bPrepend)
      _aszPendingScene  = _qDfwUtil.AddStringToArray(_aszPendingScene, szScene, bPrepend)
      _aiPendingTimeout = _qDfwUtil.AddIntToArray(_aiPendingTimeout, iSceneTimeout, bPrepend)

      MutexRelease(_iPendingActionMutex)
   EndIf
EndFunction

Function ProcessPendingAction()
   Int    iAction
   Actor  aActor
   Int    iDetails
   String szScene
   Int    iSceneTimeout

   If (MutexLock(_iPendingActionMutex))
      If (_aiPendingAction && _aiPendingAction.Length)
         iAction       = _aiPendingAction[0]
         iDetails      = _aiPendingDetails[0]
         aActor        = (_aoPendingActor[0] As Actor)
         szScene       = _aszPendingScene[0]
         iSceneTimeout = _aiPendingTimeout[0]

         _aiPendingAction  = _qDfwUtil.RemoveIntFromArray(_aiPendingAction, 0, 0)
         _aoPendingActor   = _qDfwUtil.RemoveFormFromArray(_aoPendingActor, None, 0)
         _aiPendingDetails = _qDfwUtil.RemoveIntFromArray(_aiPendingDetails, 0, 0)
         _aszPendingScene  = _qDfwUtil.RemoveStringFromArray(_aszPendingScene, "", 0)
         _aiPendingTimeout = _qDfwUtil.RemoveIntFromArray(_aiPendingTimeout, 0, 0)
      EndIf

      MutexRelease(_iPendingActionMutex)
   EndIf

   ; If we did not find a pending action return.
   If (!iAction)
      Return
   EndIf

   ; If a scene name was specified make sure we can lock the scene before proceeding.
   If (szScene)
      If (szScene == _qFramework.GetCurrentScene())
         If (FAIL >= _qFramework.SceneContinue(szScene, iSceneTimeout))
            ; Can't start the scene now.  Add the action to do later.
            AddPendingAction(iAction, aActor, iDetails, szScene, iSceneTimeout, True)
            Return
         EndIf
      Else
         If (FAIL >= _qFramework.SceneStarting(szScene, iSceneTimeout))
            ; Can't start the scene now.  Add the action to do later.
            AddPendingAction(iAction, aActor, iDetails, szScene, iSceneTimeout, True)
            Return
         EndIf
      EndIf
   EndIf

   If (1 == iAction)
      ; 1: Start Conversation.  Details: the new leash holder goal.

      StartConversation(aActor, iDetails)
   ElseIf (2 == iAction)
      ; 2: Assault Player.      Details: The _iAssault mask.

      _iAssault = Math.LogicalOr(iDetails, _iAssault)
      ; Play an animation for the slaver to approach the player.
      ; The assault will happen on the done event (OnSlaveActionDone).
      PlayApproachAnimation(aActor, "Assault")
   ElseIf (3 == iAction)
      ; 3: Furniture Assault.   Details: The _iFurnitureGoals mask.

      _iFurnitureGoals = iDetails
      ProcessFurnitureGoals(aActor)
   EndIf
EndFunction

Function StopLeashGame(Bool bClearMaster=True, Bool bReturnItems=False, Bool bUnequip=False)
   If (bReturnItems)
      ReturnItems(_aLeashHolder)
   EndIf

   If (bUnequip)
      UnequipBdsmItem(_aoGags,          _qZadLibs.zad_DeviousGag,       _aLeashHolder)
      UnequipBdsmItem(_aoArmRestraints, _qZadLibs.zad_DeviousArmbinder, _aLeashHolder)
      UnequipBdsmItem(_aoLegRestraints, _qZadLibs.zad_DeviousBoots,     _aLeashHolder)
      UnequipBdsmItem(_aoCollars,       _qZadLibs.zad_DeviousCollar,    _aLeashHolder)
      UnequipBdsmItem(_aoBlindfolds,    _qZadLibs.zad_DeviousBlindfold, _aLeashHolder)
   EndIf

   ; If the leash holder's movement has been stopped for any reason restore it.
   If (_bLeashHolderStopped)
      _bLeashHolderStopped = False
      _aLeashHolder.EnableAI()
   EndIf

   _qFramework.RestoreHealthRegen()
   _qFramework.DisableMagicka(False)
   _qFramework.SetLeashTarget(None)

   If (bClearMaster)
      _qFramework.ClearMaster(_aLeashHolder)
   EndIf

   _aAliasLastLeashHolder.ForceRefTo(_aLeashHolder)
   _iLeashHolderGoal = 0
   _iLongTermAgenda = 0
   _iLongTermAgendaDetails = 0
   _iLeashGameDuration = 0

   ; If we previously adjusted the leash holder's confidence restore it now.
   If (-100.0 != _fPreviousConfidence)
      _aLeashHolder.SetActorValue("Confidence", _fPreviousConfidence)
      _fPreviousConfidence = -100.0
   EndIf

   _aLeashHolder = None
   _aAliasLeashHolder.Clear()

   ; Stop deviously helpless assaults if configured.
   If (_qMcm.bBlockHelpless)
      SendModEvent("dhlp-Resume")
   EndIf
EndFunction

Function UpdatePollingInterval(Float fNewInterval)
   ; Don't start the mod's polling interval if we are shutting down the mod.
   If (_bMcmShutdownMod)
      Return
   EndIf

   RegisterForSingleUpdate(fNewInterval)
EndFunction

; Waits for an actor to finish what they are doing while they are starting to sit or stand.
; Some functions of the game will not work when the actor is in this state.  The player speaking
; with the actor is one example.
Function ActorSitStateWait(Actor aActor, Int iMaxWaitMs=1500)
   Int iSitState = aActor.GetSitState()
   While ((0 < iMaxWaitMs) && ((2 == iSitState) || (4 == iSitState)))
      Utility.Wait(0.1)
      iMaxWaitMs -= 100
      iSitState = aActor.GetSitState()
   EndWhile
EndFunction

Function ImmobilizePlayer()
   If (0 >= _iMovementSafety)
      _iMovementSafety = 20
;      _fMovementAmount = (_aPlayer.GetActorValue("SpeedMult") * 0.90)
;      _aPlayer.ModActorValue("SpeedMult", 0.0 - _fMovementAmount)
;      _aPlayer.ModActorValue("CarryWeight", 0.1)
      _aPlayer.SetDontMove()
   EndIf
EndFunction

Function ReMobilizePlayer()
;   _aPlayer.ModActorValue("SpeedMult", _fMovementAmount)
;   _aPlayer.ModActorValue("CarryWeight", -0.1)
   _iMovementSafety = 0
   _aPlayer.SetDontMove(False)
EndFunction

Function AssaultPlayer(Float fHealthThreshold=1.0, Bool bUnquipWeapons=False, \
                       Bool bStealWeapons=False,   Bool bAddGag=False, \
                       Bool bStrip=False,          Bool bAddArmBinder=False)
   ; If we are already in the middle of an animated assault ignore this request.
   If (_qFramework.GetCurrentScene())
      Return
   EndIf

   ; If the player is already below the health threshold don't bother damaging her more.
   Float fDamageMultiplier = 1
   If (fHealthThreshold >= _aPlayer.GetActorValuePercentage("Health"))
      fDamageMultiplier = 0
   EndIf

   ; Yank the leash.
   If (!_qFramework.GetBdsmFurniture())
      If (!_iMcmLeashResist || (_iMcmLeashResist < Utility.RandomInt(1, 100)))
         _qFramework.YankLeash(fDamageMultiplier, _qFramework.LS_DRAG)
      EndIf

      ; If a health threshold is specified and the player is not below it, nothing more to do.
      If (1 != fHealthThreshold)
         If (fHealthThreshold < _aPlayer.GetActorValuePercentage("Health"))
            Return
         EndIf
      EndIf
   EndIf

   If (bUnquipWeapons || bStealWeapons)
      Log(_aLeashHolder.GetDisplayName() + " wrestles your weapons from you.", \
          DL_CRIT, S_MOD)
      Weapon oWeaponRight = _aPlayer.GetEquippedWeapon()
      Weapon oWeaponLeft = _aPlayer.GetEquippedWeapon(True)
      _aPlayer.UnequipItem(oWeaponRight)
      _aPlayer.UnequipItem(oWeaponLeft)
      If (bStealWeapons)
         _aPlayer.RemoveItem(oWeaponRight, 999, akOtherContainer=_aLeashHolder)
         _aPlayer.RemoveItem(oWeaponLeft, 999, akOtherContainer=_aLeashHolder)
         _aoItemStolen = _qDfwUtil.AddFormToArray(_aoItemStolen, oWeaponRight)
         _aoItemStolen = _qDfwUtil.AddFormToArray(_aoItemStolen, oWeaponLeft)
         If (1 > _iWeaponsStolen)
            _iWeaponsStolen = 1
         EndIf
      EndIf
   EndIf

   ; Add any goals to the assault that are requested.
   If (bStrip && (_qFramework.NS_NAKED != _qFramework.GetNakedLevel()))
      _iAssault = Math.LogicalOr(0x0001, _iAssault)
   EndIf
   If (bAddGag && !_qFramework.IsPlayerGagged())
      _iAssault = Math.LogicalOr(0x0002, _iAssault)
   EndIf
   If (bAddArmBinder && !_qFramework.IsPlayerArmLocked())
      _iAssault = Math.LogicalOr(0x0004, _iAssault)
   EndIf

   ; Play an animation for the slaver to approach the player.
   ; The assault will happen on the done event (OnSlaveActionDone).
   If (_iAssault || _iAssaultTakeGold)
      PlayApproachAnimation(_aLeashHolder, "Assault")
   EndIf
EndFunction

Bool Function CheckPlayerFullyBound()
   _bFullyRestrained = False
   _bIsCompleteSlave = False
   If ((_bPlayerUngagged || _qFramework.IsPlayerGagged()) && \
       _qFramework.IsPlayerArmLocked() && _qFramework.IsPlayerHobbled() && \
       _qFramework.IsPlayerCollared())
      ;Log("Fully Restrained.", DL_TRACE, S_MOD)
      _bFullyRestrained = True
      If (!_qFramework.GetNakedLevel())
         ;Log("Complete Slave.", DL_TRACE, S_MOD)
         _bIsCompleteSlave = True
      EndIf
   EndIf
   Return _bIsCompleteSlave
EndFunction

; Checks if an Inventory BDSM item is worn.
Bool Function IsWorn(Armor oInventoryDevice)
   Armor oItemRendered = _qZadLibs.GetRenderedDevice(oInventoryDevice)
   Return (oItemRendered && _aPlayer.GetItemCount(oItemRendered))
EndFunction

; Inventory searching has been tried using SKSE's GetNumItems/GetNthForm API; however, the
; mechanism used here has shown to be orders of magnitude faster than that function.
Function SearchInventory(Actor aNpc)
   ; Try to find an appropriate gag in the player's inventory.
   If (!_oGag)
      Int iIndex = _aoGags.Length - 1
      Armor oItemFound
      While (!_oGag && (0 <= iIndex))
         If (_aPlayer.GetItemCount(_aoGags[iIndex]))
            oItemFound = _aoGags[iIndex]
            If (IsWorn(oItemFound))
               _oGag = oItemFound
            EndIf
         EndIf
         iIndex -= 1
      EndWhile
      If (!_oGag && oItemFound)
         _oGag = oItemFound
      EndIf
   EndIf

   ; Try to find an appropriate arm restraint in the player's inventory.
   If (!_oArmRestraint)
      Int iIndex = _aoArmRestraints.Length - 1
      Armor oItemFound
      While (!_oArmRestraint && (0 <= iIndex))
         If (_aPlayer.GetItemCount(_aoArmRestraints[iIndex]))
            oItemFound = _aoArmRestraints[iIndex]
            If (IsWorn(oItemFound))
               _oArmRestraint = oItemFound
            EndIf
         EndIf
         iIndex -= 1
      EndWhile
      If (!_oArmRestraint && oItemFound)
         _oArmRestraint = oItemFound
      EndIf
   EndIf

   ; Try to find an appropriate hobble in the player's inventory.
   If (!_oLegRestraint)
      Int iIndex = _aoLegRestraints.Length - 1
      Armor oItemFound
      While (!_oLegRestraint && (0 <= iIndex))
         If (_aPlayer.GetItemCount(_aoLegRestraints[iIndex]))
            oItemFound = _aoLegRestraints[iIndex]
            If (IsWorn(oItemFound))
               _oLegRestraint = oItemFound
            EndIf
         EndIf
         iIndex -= 1
      EndWhile
      If (!_oLegRestraint && oItemFound)
         _oLegRestraint = oItemFound
      EndIf
   EndIf

   ; Try to find an appropriate collar in the player's inventory.
   If (!_oCollar)
      Int iIndex = _aoCollars.Length - 1
      Armor oItemFound
      While (!_oCollar && (0 <= iIndex))
         If (_aPlayer.GetItemCount(_aoCollars[iIndex]))
            oItemFound = _aoCollars[iIndex]
            If (IsWorn(oItemFound))
               _oCollar = oItemFound
            EndIf
         EndIf
         iIndex -= 1
      EndWhile
      If (!_oCollar && oItemFound)
         _oCollar = oItemFound
      EndIf
   EndIf

   ; Try to find an appropriate blindfold in the player's inventory.
   If (!_oBlindfold)
      Int iIndex = _aoBlindfolds.Length - 1
      Armor oItemFound
      While (!_oBlindfold && (0 <= iIndex))
         If (_aPlayer.GetItemCount(_aoBlindfolds[iIndex]))
            oItemFound = _aoBlindfolds[iIndex]
            If (IsWorn(oItemFound))
               _oBlindfold = oItemFound
            EndIf
         EndIf
         iIndex -= 1
      EndWhile
      If (!_oBlindfold && oItemFound)
         _oBlindfold = oItemFound
      EndIf
   EndIf
EndFunction

; This assumes the player's inventory has already been searched with SearchInventory().
Function FindGag(Actor aNpc)
   If (!_oGag)
      Int iIndex = _aoGags.Length - 1
      While (0 <= iIndex)
         If (aNpc.GetItemCount(_aoGags[iIndex]))
            _oGag = _aoGags[iIndex]
            Return
         EndIf
         iIndex -= 1
      EndWhile
      _oGag = _aoGags[Utility.RandomInt(0, _aoGags.Length - 1)]
   EndIf
EndFunction

; This assumes the player's inventory has already been searched with SearchInventory().
Function FindArmRestraint(Actor aNpc)
   If (!_oArmRestraint)
      Int iIndex = _aoArmRestraints.Length - 1
      While (0 <= iIndex)
         If (aNpc.GetItemCount(_aoArmRestraints[iIndex]))
            _oArmRestraint = _aoArmRestraints[iIndex]
            Return
         EndIf
         iIndex -= 1
      EndWhile
      _oArmRestraint = _aoArmRestraints[Utility.RandomInt(0, _aoArmRestraints.Length - 1)]
   EndIf
EndFunction

; This assumes the player's inventory has already been searched with SearchInventory().
Function FindLegRestraint(Actor aNpc)
   If (!_oLegRestraint)
      Int iIndex = _aoLegRestraints.Length - 1
      While (0 <= iIndex)
         If (aNpc.GetItemCount(_aoLegRestraints[iIndex]))
            _oLegRestraint = _aoLegRestraints[iIndex]
            Return
         EndIf
         iIndex -= 1
      EndWhile
      _oLegRestraint = _aoLegRestraints[Utility.RandomInt(0, _aoLegRestraints.Length - 1)]
   EndIf
EndFunction

; This assumes the player's inventory has already been searched with SearchInventory().
Function FindCollar(Actor aNpc)
   If (!_oCollar)
      Int iIndex = _aoCollars.Length - 1
      While (0 <= iIndex)
         If (aNpc.GetItemCount(_aoCollars[iIndex]))
            _oCollar = _aoCollars[iIndex]
            Return
         EndIf
         iIndex -= 1
      EndWhile
      _oCollar = _aoCollars[Utility.RandomInt(0, _aoCollars.Length - 1)]
   EndIf
EndFunction

; This assumes the player's inventory has already been searched with SearchInventory().
Function FindBlindfold(Actor aNpc)
   If (!_oBlindfold)
      Int iIndex = _aoBlindfolds.Length - 1
      While (0 <= iIndex)
         If (aNpc.GetItemCount(_aoBlindfolds[iIndex]))
            _oBlindfold = _aoBlindfolds[iIndex]
            Return
         EndIf
         iIndex -= 1
      EndWhile
      _oBlindfold = _aoBlindfolds[Utility.RandomInt(0, _aoBlindfolds.Length - 1)]
   EndIf
EndFunction

Function EquipBdsmItem(Armor oItem, Keyword oKeyword, Actor aNpc=None)
   If (oItem)
      Armor oItemRendered = _qZadLibs.GetRenderedDevice(oItem)
      _qZadLibs.EquipDevice(_aPlayer, oItem, oItemRendered, oKeyword)
      If (aNpc)
         aNpc.RemoveItem(oItem, 1)
      EndIf
   EndIf
EndFunction

Function UnequipBdsmItem(Armor[] _aoItemList, Keyword oKeyword, Actor aNpc=None)
   Armor oItem

   ; First check if the player is wearing one of the items from the list.
   If (_aoItemList)
      Int iIndex = _aoItemList.Length - 1
      While (!oItem && (0 <= iIndex))
         If (_aPlayer.GetItemCount(_aoItemList[iIndex]))
            If (IsWorn(_aoItemList[iIndex]))
               oItem = _aoItemList[iIndex]
            EndIf
         EndIf
         iIndex -= 1
      EndWhile
   EndIf

   ; If we found the item try to remove that.
   If (oItem)
      Armor oItemRendered = _qZadLibs.GetRenderedDevice(oItem)
      _qZadLibs.RemoveDevice(_aPlayer, oItem, oItemRendered, oKeyword)
      _aPlayer.RemoveItem(oItem, 1, akOtherContainer=aNpc)
   Else
      ; Otherwise use the Zad generic function to remove the device by keyword.
      _qZadLibs.ManipulateGenericDeviceByKeyword(_aPlayer, oKeyword, False)
   EndIf
EndFunction

Function ReturnItems(Actor aNpc)
   Log(aNpc.GetDisplayName() + " returns your things.", DL_CRIT, S_MOD)
   Int iIndex = _aoItemStolen.Length - 1
   While (0 <= iIndex)
      aNpc.RemoveItem(_aoItemStolen[iIndex], 999, akOtherContainer=_aPlayer)
      iIndex -=1
   EndWhile
   _aoItemStolen = None
   _iWeaponsStolen = 0
EndFunction

; TODO: The favourite furniture lists should be protected by a mutex.
ObjectReference Function FindFurniture(Location oRegion=None)
   If (!oRegion)
      oRegion = _qFramework.GetNearestRegion()
   EndIf

   Form[] aoFurniture
   Int iIndex = _aoFavouriteRegion.Length - 1
   While (iIndex)
      If (_aoFavouriteRegion[iIndex] == oRegion)
         aoFurniture = _qDfwUtil.AddFormToArray(aoFurniture, _aoFavouriteFurniture[iIndex])
      EndIf
      iIndex -= 1
   EndWhile
   Int iLength = aoFurniture.Length
   If (iLength)
      Return (aoFurniture[Utility.RandomInt(0, iLength - 1)] As ObjectReference)
   EndIf
   Return None
EndFunction

Int Function StartWhippingScene(Actor aActor, Int iDuration, String szMessage)
   Int iReturnCode = _qFramework.SceneStarting(szMessage, iDuration + 30)
   If (!iReturnCode)
      ; Adjust the punishment cane's base properties.  Otherwise it is impossible to control the
      ; whipping.  It does too much damage and ends due to the player's health much too quickly.
      If (_oWeaponZbfCane)
         If (!_iZbfCaneBaseDamage)
            _iZbfCaneBaseDamage = _oWeaponZbfCane.GetBaseDamage()
            _szZbfCaneResistance = _oWeaponZbfCane.GetResist()
            _oWeaponZbfCane.SetBaseDamage(0)
            _oWeaponZbfCane.SetResist("DamageResist")
            _aPlayer.ModActorValue("DamageResist", 10000)
         EndIf
      EndIf

      _qZbfSlaveActions.WhipPlayer(aActor, szMessage, iDuration)
   EndIf
   Return iReturnCode
EndFunction

; Returns any new items: 0x01: Collar     0x02: Gag  0x04: Arm Locked  0x08: Hobble
;                        0x10: Blindfold  0x20: Belt
Int Function FinalizeAssault(Actor aNpc, String szName)
   ; For effeciency assault values are checked in descending order (highest numbers first).
   ; These flags can be used to control performing one action before another.
   Bool bUnlockArms
   Bool bReleaseBlindfold
   Bool bReturnItems
   Bool bSecureGag
   Int iNewItems

   If (_iAssaultTakeGold)
      _aPlayer.RemoveItem(_oGold, _iAssaultTakeGold, akOtherContainer=aNpc)
   EndIf

   ; Keep track of whether this is a peaceful or forceful assault.
   Bool bPeaceful
   If (0x40000000 <= _iAssault)
      bPeaceful = True
      _iAssault -= 0x40000000
   EndIf

   ; 0x4000: Restrain in Boots
   If (0x4000 <= _iAssault)
      FindLegRestraint(aNpc)
      EquipBdsmItem(_oLegRestraint, _qZadLibs.zad_DeviousBoots, aNpc)
      iNewItems += 0x08

      _iAssault -= 0x4000
   EndIf

   ; 0x2000 = Make sure the Gag is secure
   If (0x2000 <= _iAssault)
      bSecureGag = True
      If (_qFramework.IsPlayerGagged())
         Log(szName + " tightens your gag making it very effective and uncomfortable.", \
             DL_CRIT, S_MOD)
         _qFramework.SetStrictGag()
      Else
         ; If the player is not already gagged make sure it happens further down.
         bSecureGag = True
      EndIf

      _iAssault -= 0x2000
   EndIf

   ; 0x1000 = Restore Leash Length
   If (0x1000 <= _iAssault)
      _qFramework.SetLeashLength(_qMcm.iLeashLength)

      _iAssault -= 0x1000
   EndIf

   ; 0x0800 = Release Blindfold
   If (0x0800 <= _iAssault)
      bReleaseBlindfold = True

      _iAssault -= 0x0800
   EndIf

   ; 0x0400 = Blindfold
   If (0x0400 <= _iAssault)
      If (bPeaceful)
         Log(szName + " secures a blindfold over your eyes.", DL_CRIT, S_MOD)
      Else
         Log(szName + " pulls you to the ground and locks you in a blindfold.", DL_CRIT, S_MOD)
      EndIf
      FindBlindfold(aNpc)
      EquipBdsmItem(_oBlindfold, _qZadLibs.zad_DeviousBlindfold, aNpc)
      iNewItems += 0x10

      _iAssault -= 0x0400
   EndIf

   ; 0x0200 = Restrain in Collar
   If (0x0200 <= _iAssault)
      FindCollar(aNpc)
      EquipBdsmItem(_oCollar, _qZadLibs.zad_DeviousCollar, aNpc)
      iNewItems += 0x01

      _iAssault -= 0x0200
   EndIf

   ; 0x0100 = UnGag
   If (0x0100 <= _iAssault)
      ; Unequip the player's gag.
      UnequipBdsmItem(_aoGags, _qZadLibs.zad_DeviousGag, aNpc)
      _bPlayerUngagged = True
      _iGagRemaining = 0

      _iAssault -= 0x0100
   EndIf

   ; 0x0080 = Add Additional Restraint
   If (0x0080 <= _iAssault)
      ; Create a list of items that can be added so we can randomize which one is added.
      Int[] aiOptions
      If (_iMcmGagMode && !_qFramework.IsPlayerGagged())
         aiOptions = _qDfwUtil.AddIntToArray(aiOptions, 1)
      EndIf
      If (!_bFurnitureForFun && !_qFramework.IsPlayerArmLocked())
         aiOptions = _qDfwUtil.AddIntToArray(aiOptions, 2)
      EndIf
      If (!_qFramework.IsPlayerHobbled())
         aiOptions = _qDfwUtil.AddIntToArray(aiOptions, 3)
      EndIf
      If (!_qFramework.IsPlayerCollared())
         aiOptions = _qDfwUtil.AddIntToArray(aiOptions, 4)
      EndIf

      ; Choose one of the available optionis randomly.
      Int iItem
      If (aiOptions.Length)
         Int iOption = aiOptions[Utility.RandomInt(0, aiOptions.Length - 1)]
         Armor oRestraint
         Keyword oKeyword
         If (1 == iOption)
            FindGag(aNpc)
            oRestraint = _oGag
            oKeyword = _qZadLibs.zad_DeviousGag
            iItem = 0x02
            _bPlayerUngagged = False
         ElseIf (2 == iOption)
            FindArmRestraint(aNpc)
            oRestraint = _oArmRestraint
            oKeyword = _qZadLibs.zad_DeviousArmbinder
            iItem = 0x04
         ElseIf (3 == iOption)
            FindLegRestraint(aNpc)
            oRestraint = _oLegRestraint
            oKeyword = _qZadLibs.zad_DeviousBoots
            iItem = 0x08
         ElseIf (4 == iOption)
            FindCollar(aNpc)
            oRestraint = _oCollar
            oKeyword = _qZadLibs.zad_DeviousCollar
            iItem = 0x01
         EndIf

         If (oRestraint)
            EquipBdsmItem(oRestraint, oKeyword, aNpc)
            iNewItems += iItem

            ; If the player is being gagged and gag mode is Auto Remove start a timer.
            If ((1 == iOption) && (2 == _iMcmGagMode))
               Int iBehaviour = _iBadBehaviour
               If (50 < _qFramework.GetActorAnger(aNpc))
                  iBehaviour += 3
               EndIf
               _iLongTermAgenda = 3
               _iLongTermAgendaDetails = 0
               _iGagRemaining += ((60 + (120 * iBehaviour)) / _fMcmPollTime As Int)
            EndIf
         EndIf
      EndIf
      _iAssault -= 0x0080
   EndIf

   ; 0x0040 = Strip Fully
   If (0x0040 <= _iAssault)
      ; Todo: Account for non-standard slots included in the DFW MCM menu.
      ; Todo: Verify there is actual clothing in each slot before stripping.
      _aPlayer.UnequipItemSlot(30) ; 0x00000001
      _aPlayer.UnequipItemSlot(32) ; 0x00000004
      _aPlayer.UnequipItemSlot(33) ; 0x00000008
      _aPlayer.UnequipItemSlot(34) ; 0x00000010
      _aPlayer.UnequipItemSlot(37) ; 0x00000080
      _aPlayer.UnequipItemSlot(38) ; 0x00000100
      _aPlayer.UnequipItemSlot(39) ; 0x00000200
      _aPlayer.UnequipItemSlot(42) ; 0x00001000
      _aPlayer.UnequipItemSlot(46) ; 0x00010000
      _aPlayer.UnequipItemSlot(47) ; 0x00020000
      _aPlayer.UnequipItemSlot(49) ; 0x00080000
      _aPlayer.UnequipItemSlot(52) ; 0x00400000
      _aPlayer.UnequipItemSlot(56) ; 0x04000000

      _iAssault -= 0x0040
   EndIf

   ; 0x0020 = Unbind Arms
   If (0x0020 <= _iAssault)
      bUnlockArms = True
      _iAssault -= 0x0020
   EndIf

   ; 0x0010 = Return All Items
   If (0x0010 <= _iAssault)
      bReturnItems = True
      _iAssault -= 0x0010
   EndIf

   ; 0x0008 = Take All Weapons
   If (0x0008 <= _iAssault)
      ; Search the inventory for any weapons and move them to the leash holder.
      ; Todo: Quest items taken this way should be made available at a new "Quest Item Vendor".
      Int iIndex = _aPlayer.GetNumItems() - 1
      While (0 <= iIndex)
         ; Check the item is an inventory item, is equipped and has the right keyword.
         Form oInventoryItem = _aPlayer.GetNthForm(iIndex)
         If (41 == oInventoryItem.GetType())
            _aPlayer.RemoveItem(oInventoryItem, 999, akOtherContainer=aNpc)
            _aoItemStolen = _qDfwUtil.AddFormToArray(_aoItemStolen, oInventoryItem)
         EndIf
         iIndex -= 1
      EndWhile
      _iWeaponsStolen = 2

      _iAssault -= 0x0008
   EndIf

   ; 0x0004 = Bind Arms
   If (0x0004 <= _iAssault)
      If (!_qFramework.IsPlayerArmLocked())
         If (bPeaceful)
            Log(szName + " locks up your arms.", DL_CRIT, S_MOD)
         Else
            Log(szName + " pulls you to the ground and locks up your arms.", DL_CRIT, S_MOD)
         EndIf
         FindArmRestraint(aNpc)
         ; Unequip the player's gloves/forearms as they interact oddly with arm binders.
         _aPlayer.UnequipItemSlot(33) ; 0x00000008
         _aPlayer.UnequipItemSlot(34) ; 0x00000010

         EquipBdsmItem(_oArmRestraint, _qZadLibs.zad_DeviousArmbinder, aNpc)
         iNewItems += 0x04
      EndIf
      _iAssault -= 0x0004
   EndIf

   ; 0x0002 = Gag
   If ((0x0002 <= _iAssault) || bSecureGag)
      If (!_qFramework.IsPlayerGagged())
         If (bPeaceful)
            Log(szName + " slips a gag into your mouth and locks it in place.", DL_CRIT, S_MOD)
         Else
            Log(szName + " pulls you to the ground and forces a gag into your mouth.", \
                DL_CRIT, S_MOD)
         EndIf

         FindGag(aNpc)
         EquipBdsmItem(_oGag, _qZadLibs.zad_DeviousGag, aNpc)
         iNewItems += 0x02

         ; If gag mode is Auto Remove start a timer.
         If (2 == _iMcmGagMode)
            Int iBehaviour = _iBadBehaviour
            If (50 < _qFramework.GetActorAnger(aNpc))
               iBehaviour += 3
            EndIf
            _iLongTermAgenda = 3
            _iLongTermAgendaDetails = 0
            _iGagRemaining += ((60 + (120 * iBehaviour)) / _fMcmPollTime As Int)
         EndIf

         _bPlayerUngagged = False
         If (bSecureGag)
            _qFramework.SetStrictGag()
         EndIf
      EndIf
      _iAssault -= 0x0002
   EndIf

   ; 0x0001 = Strip
   If (0x0001 <= _iAssault)
      If (bPeaceful)
         Log(szName + " holds you still and strips off your clothes.", DL_CRIT, S_MOD)
      Else
         Log(szName + " pulls you to the ground and strips off your clothes.", DL_CRIT, S_MOD)
      EndIf
      ; Todo: Account for non-standard slots included in the DFW MCM menu.
      ; Todo: Verify there is actual clothing in each slot before stripping.
      _aPlayer.UnequipItemSlot(30) ; 0x00000001
      _aPlayer.UnequipItemSlot(32) ; 0x00000004
      _aPlayer.UnequipItemSlot(39) ; 0x00000200
      _aPlayer.UnequipItemSlot(46) ; 0x00010000
      _aPlayer.UnequipItemSlot(49) ; 0x00080000
      _iAssault -= 0x0001
   EndIf

   If (bReturnItems)
      Actor aLastLeashHolder = (_aAliasLastLeashHolder.GetReference() As Actor)
      ReturnItems(aLastLeashHolder)
   EndIf

   If (bReleaseBlindfold)
      ; Unequip the player's blindfold.
      UnequipBdsmItem(_aoBlindfolds, _qZadLibs.zad_DeviousBlindfold, aNpc)
   EndIf

   If (bUnlockArms)
      UnequipBdsmItem(_aoArmRestraints, _qZadLibs.zad_DeviousArmbinder, aNpc)
      _bFullyRestrained = False
      _bIsCompleteSlave = False
   EndIf
   Return iNewItems
EndFunction

Function StartConversation(Actor aActor, Int iGoal=-1, Int iRefusalCount=-1, \
                           Bool bInterruptPlayer=False)
   ; Teleport the leash holder to interrupt his current package.  For normal
   ; conversations the package is interrupted when the player clicks on (activates)
   ; the actor.  Activating the actor via the Activate() function seems to be
   ; different so we need to interrupt the package manually.
   ; This doesn't appear to be necessary anymore.  I don't know why.
;   aActor.MoveTo(aActor)

   ; Activating the actor causes dialog problems.
   ; Make sure there is no conversation.
   ; This also resets the player's camera so let's not use it unless it is necessary.
   ; This also prevents the player from engaging in dialogue for a short time.  Needs a delay.
   If (bInterruptPlayer)
      _aPlayer.MoveTo(_aPlayer)

      ; This MoveTo() prevents the player from engaging in coversation for a short time.
      ; Add a delay to account for that.
      Utility.Wait(0.5)
   EndIf

   ; Setup the conversation topic variable used by the player dialogue.
   If (-1 != iGoal)
      _iLeashHolderGoal = iGoal
      ; If this is a new conversation we should reset the refusal count.
      If (-1 == iRefusalCount)
         _iLeashGoalRefusalCount = 0
      EndIf
   EndIf

   ; If the refusal count is specified set it here.
   If (-1 != iRefusalCount)
      _iLeashGoalRefusalCount = iRefusalCount
   EndIf
   If (7 == _iLeashHolderGoal)
      _iLeashGoalRefusalCount = _iTotalWalkInFrontCount
   EndIf

   ; Wait for any leash yanking to complete before starting the conversation.
   _qFramework.YankLeashWait(500)

   ; Don't try to talk to the actor while he is in the process of sitting or standing.
   ActorSitStateWait(aActor)

   ; Set a timeout in case the dialogue doesn't happen.
   _aDialogueTarget = aActor
   _iDialogueBusy = 20
   If ((3 == iGoal) || (5 == iGoal) || (7 == iGoal) || (8 == iGoal) || (9 == iGoal) || \
       (11 == iGoal))
      ; For One Liners (comments the player can't respond to) set a shorter timeout.
      _iDialogueBusy = 3
   EndIf

   ; Prepare the actor for DFW dialogue to ensure DFW conditions are available.
   _qFramework.PrepareActorDialogue(aActor)

   ; If the leash holder's movement has been stopped for any reason restore it.
   If (_bLeashHolderStopped)
      _bLeashHolderStopped = False
      _aLeashHolder.EnableAI()
   EndIf

   ; Have the actor speak with the player.
   aActor.Activate(_aPlayer)
EndFunction

Function CheckStartLeashGame(Int iVulnerability)
   ; Don't start the leash game if we are shutting down the mod.
   If (_bMcmShutdownMod)
      Return
   EndIf

   ; Only play the leash game if the player does not have a current close Master and she is not
   ; otherwise unavailable.
   If (!_qFramework.GetMaster(_qFramework.MD_CLOSE) && \
       _qFramework.IsAllowed(_qFramework.AP_ENSLAVE) && \
       !_qFramework.IsPlayerCriticallyBusy() && \
       ("" == _qFramework.GetCurrentScene()))
      Float fMaxChance = _fMcmLeashGameChance
      If (_iMcmIncreaseWhenVulnerable)
         fMaxChance += ((_iMcmIncreaseWhenVulnerable As Float) * iVulnerability / 100)
      EndIf
      Float fRoll = Utility.RandomFloat(0, 100)
      Log("Leash Game Roll: " + fRoll + "/" + fMaxChance, DL_TRACE, S_MOD)
      If (fMaxChance > fRoll)
         ; Find an actor to use as the Master in the leash game.
         Int iActorFlags = _qFramework.AF_SLAVE_TRADER
         If (_bMcmIncludeOwners)
            iActorFlags = Math.LogicalOr(_qFramework.AF_OWNER, iActorFlags)
         EndIf
         Actor aRandomActor = _qFramework.GetRandomActor(_iMcmMaxDistance, iActorFlags)

         If (aRandomActor)
            String szName = aRandomActor.GetDisplayName()

            ; If the player is in BDSM furniture but not locked.  Lock it first.
            If (_qFramework.GetBdsmFurniture())
               _qFramework.SetBdsmFurnitureLocked()
               ;    DisablePlayerControls(Move,  Fight, Cam,   Look,  Sneak, Menu,  Active, Journ)
               Game.DisablePlayerControls(True,  False, False, False, False, False, True,   False)
               ImmobilizePlayer()
               _aAliasFurnitureLocker.ForceRefTo(aRandomActor)
               _bFurnitureForFun = False
               _fFurnitureReleaseTime = 0
               _qZbfSlaveActions.RestrainInDevice(None, aRandomActor, S_MOD + "_BdsmToLeash")
               _qFramework.ForceSave()
            Else
               If (1 == _iMcmLeashGameStyle)
                  ; 1 = Auto.  Start the game.
                  Log(szName + " lassos a rope around your neck.", DL_CRIT, S_MOD)
                  StartLeashGame(aRandomActor)
               ElseIf (3 == _iMcmLeashGameStyle)
                  ; 3 = Dialogue.  Approach the player.
                  If (!_qFramework.SceneStarting(S_MOD + "_LeashGame", 60))
                     _qFramework.ApproachPlayer(aRandomActor, 15, 4, S_MOD + "_LeashGame")
                  EndIf
               Else
                  ; 2 = Protected.  Check if the slaver is behind the player.
                  Float fSlaverPosition = _aPlayer.GetHeadingAngle(aRandomActor)
                  If ((((80 <= fSlaverPosition) || (-80 >= fSlaverPosition)) || \
                       _qFramework.IsPlayerArmLocked()) && \
                      (!_aPlayer.IsWeaponDrawn() || !_qFramework.GetWeaponLevel()) && \
                      !_qFramework.SceneStarting(S_MOD + "_LeashGame", 60))
                     ; Give the player some warning.
                     If (Utility.RandomInt(1, 100) <= _qMcm.iLeashChanceToNotice)
                        Log(szName + " takes out a rope and approaches you suspiciously.", \
                            DL_CRIT, S_MOD)
                     EndIf
                     Int iDelay = _qMcm.iLeashProtectedDelay
                     If (iDelay)
                        aRandomActor.EnableAI(False)
                        Utility.Wait((iDelay As Float) / 1000)
                        aRandomActor.EnableAI()
                     EndIf
                     _qFramework.ApproachPlayer(aRandomActor, 15, 4, S_MOD + "_LeashGame")
                  EndIf
               EndIf
            EndIf
         Else
            Log("Leash Game No Actor.", DL_TRACE, S_MOD)
         EndIf
      EndIf
   EndIf
EndFunction

Function PlayLeashGame()
   ;Log("Leash Game On.", DL_TRACE, S_MOD)

   ; The leash holder's anger is used in a number of situation.  Create a variable for it here.
   Int iAnger

   ; Keep track of the furniture the player is in, if any.
   ObjectReference oCurrFurniture = _qFramework.GetBdsmFurniture()

   ; Make sure the player is not not too far away from the leash holder.
   Float fDistance = _aLeashHolder.GetDistance(_aPlayer)
   If ((1500 < fDistance) && !oCurrFurniture)
      ;Log("Vast Distance.", DL_TRACE, S_MOD)

      ; If the player is too far from the leash target and they are in a scene, this is most
      ; likely a post bleedout event so stop the leash game.
      If (_qFramework.IsPlayerCriticallyBusy(False))
         ; The player may also be in a local sex scene.
         ; Don't abandon the game unless they're really far.
         If (!_aLeashHolder.IsNearPlayer() && (10000 < fDistance))
            StopLeashGame()
         EndIf
      EndIf
   EndIf

   ; Handle the case of the slaver being deceased.
   If (_aLeashHolder.IsDead())
      ;Log("Leash Holder Dead.", DL_TRACE, S_MOD)
      _iLeashGameDuration -= 3
      If (0 >= _iLeashGameDuration)
         ; The leash game has ended.  The player will be set free.
         Log("Without the slaver keeping the rope its power soon disipates, releasing you.", \
             DL_CRIT, S_MOD)
         StopLeashGame()
      EndIf
      Return
   EndIf

   ; If the slaver is in combat don't try other processing.
   If (_bIsInCombat || _aLeashHolder.IsInCombat())
      ;Log("In Combat.", DL_TRACE, S_MOD)

      If (!_bIsInCombat)
         Log("Leash Holder Combat Starting.", DL_DEBUG, S_MOD)
         _bIsInCombat = True
         _qFramework.SetLeashLength(_qMcm.iLeashLength * 3)
      ElseIf (!_aLeashHolder.IsInCombat())
         Log("Leash Holder Combat Done.", DL_DEBUG, S_MOD)
         _bIsInCombat = False
         _qFramework.SetLeashLength(_qMcm.iLeashLength)
      EndIf
      Return
   EndIf

   _iLeashGameDuration -= 1

   ; If we are in a conversation count down the safety in case the conversation doesn't work.
   If (0 < _iDialogueBusy)
      ;Log("In Dialogue.", DL_TRACE, S_MOD)
      _iDialogueBusy -= 1

      If (0 == _iDialogueBusy)
         _aDialogueTarget = None
         ; For pure conversation goals, end them when the dialogue times out.
         If ((12 <= _iLeashHolderGoal) && (14 >= _iLeashHolderGoal))
            _iLeashHolderGoal = 0
         EndIf
      EndIf

      ; If this is a conversation with the leash holder don't try to process the leash game.
      If (_aLeashHolder == _aDialogueTarget)
         Return
      EndIf
   EndIf

   ; Don't do processing during one of our scenes.
   If (S_MOD == _qFramework.GetCurrentScene())
      ;Log("PlayLeashGame: In Scene.", DL_TRACE, S_MOD)
      Return
   EndIf

   ; If the leash game is ending check that the slaver is willing to release the player.
   If (0 >= _iLeashGameDuration)
      Log("Leash Game Duration Up.", DL_DEBUG, S_MOD)

      ; Only consider stopping the leash game if nothing else is going on.
      If ((0 >= _iLeashHolderGoal) && (1 == _iLongTermAgenda))
         ; The slaver will only release the player if he is not particularly angry with her.
         If (_qMcm.iMaxAngerForRelease >= _qFramework.GetActorAnger(_aLeashHolder))
            Int iChance = _qMcm.iChanceOfRelease
            Int iDominance = _qFramework.GetActorDominance(_aLeashHolder)
            iChance -= (((iDominance - 50) * _qMcm.iDominanceAffectsRelease) / 50)
            Float fRoll = Utility.RandomFloat(0, 100)
            Log("Leash Game End Roll: " + fRoll + "/" + iChance, DL_TRACE, S_MOD)
            If (iChance > fRoll)
               Int iRandom = Utility.RandomInt(1, 100)
               If (_qMcm.iChanceFurnitureTransfer >= iRandom)
                  ObjectReference oFurnitureNearby = FindFurniture()
                  If (!oCurrFurniture && oFurnitureNearby && \
                      !_qFramework.SceneStarting(S_MOD + "_MoveToFurniture", 60))
                     _iLongTermAgenda = 4
                     _iLongTermAgendaDetails = 1
                     _qFramework.ForceSave()

                     ; Try to narrow down where the furniture is.
                     _oTransferFurniture = oFurnitureNearby
                     Location oFurnitureLocation = _oTransferFurniture.GetCurrentLocation()

                     ; The furniture might be in a custom cell which doesn't have a location.
                     If (!oFurnitureLocation)
                        Int iIndex = _aoFavouriteFurniture.Find(_oTransferFurniture)
                        oFurnitureLocation = (_aoFavouriteLocation[iIndex] As Location)
                     EndIf

                     ; If the leash holder is not in the furniture's location move there first.
                     If (oFurnitureLocation && \
                         (oFurnitureLocation != _aLeashHolder.GetCurrentLocation()))
                        _qFramework.MoveToLocation(_aLeashHolder, oFurnitureLocation, \
                                                   S_MOD + "_Furniture")
                     Else
                        _qFramework.MoveToObject(_aLeashHolder, _oTransferFurniture, \
                                                 S_MOD + "_Furniture")
                     EndIf
                     Return
                  EndIf
               ElseIf (_aoSimpleSlaveryRegion && _aoSimpleSlaveryLocation && \
                       ((_qMcm.iChanceFurnitureTransfer + _qMcm.iLeashChanceSimple) >= iRandom))
                  _iLongTermAgenda = 4
                  _iLongTermAgendaDetails = 2
                  _qFramework.ForceSave()
                  Int iIndex = _aoSimpleSlaveryRegion.Find(_qFramework.GetNearestRegion())
                  If ((-1 != iIndex) && _qMcm.bWalkToSsAuction && \
                      (_qMcm.bWalkFarSsAuction || \
                       (_aoSimpleSlaveryLocation[iIndex] == _aoSimpleSlaveryRegion[iIndex])))
                     _qFramework.MoveToLocation(_aLeashHolder, \
                                                _aoSimpleSlaveryLocation[iIndex], \
                                                S_MOD + "_SimpleSlavery")
                  Else
                     StopLeashGame(bReturnItems=True, bUnequip=True)
                     ; The short delay helps the player transfer with the proper equipment.
                     Utility.Wait(1)
                     SendModEvent("SSLV Entry")
                  EndIf
                  Return
               EndIf
               ; The leash game has ended.  The player will be set free.
               Log(_aLeashHolder.GetDisplayName() + " unties your leash and lets you go.", \
                   DL_CRIT, S_MOD)
               StopLeashGame()
               Return
            EndIf
            Log("No Release.  Extending.", DL_DEBUG, S_MOD)
         Else
            Log("Leash Holder Upset.  Extending.", DL_DEBUG, S_MOD)
         EndIf

         ; The leash game has been extended for some reason.  Reset the duration.
         _iLeashGameDuration = GetLeashGameDuration(True)
      Else
         Log("Punishment Active.  Extending.", DL_DEBUG, S_MOD)
         ; A punishment or other activity is going on.  Extend the leash game by a small amount.
         _iLeashGameDuration = 30
      EndIf
   EndIf

   ; Don't process anything further if the player is locked in furniture as a punishement.
   ; For now the move to package doesn't allow other processing.
   If (_oPunishmentFurniture)
      Return
   EndIf

   ; Next handle cases of the player being locked in BDSM furniture.
   If (oCurrFurniture && ((4 != _iLongTermAgenda) || (1 != _iLongTermAgendaDetails)))
      ; For now if the player is talking to the guard just don't start a conversation.
      ; TODO: Eventually we want this to happen all the time.  Not just when in furniture;
      ; however, we need the slaver to be upset with the player when this happens.
      Actor aSpeakingNpc = _qFramework.GetPlayerTalkingTo()
      If (aSpeakingNpc && aSpeakingNpc.IsGuard())
         Return
      EndIf

      If (!_qFramework.IsPlayerGagged())
         ; 0x40000000: Peaceful (the player is co-operating)
         ; 0x0002: Gag
         _iAssault = Math.LogicalOr(0x40000000 + 0x0002, _iAssault)
         ; Goal 8: Restrain the player.
         StartConversation(_aLeashHolder, 8)
      ElseIf (2 > _iWeaponsStolen)
         ; Goal 3: Take the player's weapons.
         StartConversation(_aLeashHolder, 3)
      ElseIf (_qFramework.GetNakedLevel())
         ; Goal 5: Strip the player fully.
         StartConversation(_aLeashHolder, 5)
      ElseIf (!_qFramework.IsPlayerCollared())
         ; 0x40000000: Peaceful (the player is co-operating)
         ; 0x0200: Restrain in Collar
         _iAssault = Math.LogicalOr(0x40000000 + 0x0200, _iAssault)
         ; Goal 8: Restrain the player.
         StartConversation(_aLeashHolder, 8)
      ElseIf (!_qFramework.IsPlayerArmLocked())
         ; 0x40000000: Peaceful (the player is co-operating)
         ; 0x0004: Bind Arms
         _iAssault = Math.LogicalOr(0x40000000 + 0x0004, _iAssault)
         ; Goal 8: Restrain the player.
         StartConversation(_aLeashHolder, 8)
      Else
         ; The player is all bound up (save collar and boots).  Release her from the furniture.
         _qZbfSlaveActions.RestrainInDevice(None, _aLeashHolder, S_MOD + "_F_Release")
      EndIf
      Return
   EndIf

   ; Next handle cases of the player acting aggressive toward the slaver.
   If (_aPlayer.IsWeaponDrawn() && _bReequipWeapons && _qFramework.GetWeaponLevel())
      ;Log("Player Aggressive.", DL_TRACE, S_MOD)

      ; The player has re-equipped her weapons and drawn them.
      ; The leash holder should be alarmed at this.
      iAnger = _qFramework.IncActorAnger(_aLeashHolder, _iLeashGoalRefusalCount, 0, 100)

      ; If the slaver hasn't spoken to the player about putting her weapons away do so now.
      If (1 != _iLeashHolderGoal)
         ; If we were trying to strip the player take back assisted dressing.
         If (2 == _iLeashHolderGoal)
            _qFramework.RemovePermission(_aLeashHolder, _qFramework.AP_DRESSING_ASSISTED)
         EndIf
         StartConversation(_aLeashHolder, 1)
         Return
      EndIf

      ; For the slaver's protection he yanks the player's leash.
      AssaultPlayer(0.3, bStealWeapons=True)
      Return
   EndIf

   ; Goal 1: The slaver is trying to disarm the player.
   If (1 == _iLeashHolderGoal)
      ;Log("Goal 1: Disarm the player.", DL_TRACE, S_MOD)

      ; If the player has put away her weapons.  Relax a little.
      If (!_qFramework.GetWeaponLevel())
         _iLeashHolderGoal = -2
         _qFramework.IncActorAnger(_aLeashHolder, -3, 40, 100)
         ; If the player has weapons equipped again it's because she re-equipped them.
         _bReequipWeapons = True
         Return
      EndIf

      ; Increase the leash holder's annoyance at the player having her weapons out.
      _iLeashGoalRefusalCount += 1
      iAnger = _qFramework.IncActorAnger(_aLeashHolder, _iLeashGoalRefusalCount / 3, 0, 100)

      ; If the actor is overly annoyed yank the player's leash.
      If (50 < iAnger)
         AssaultPlayer(0.3, bStealWeapons=True)
      ElseIf ((40 < iAnger) && _aPlayer.IsWeaponDrawn())
         AssaultPlayer(0.3, bStealWeapons=True)
      ElseIf (!(_iLeashGoalRefusalCount % 4))
         ; Otherwise just talk to the player about her behaviour.
         StartConversation(_aLeashHolder)
      EndIf
      Return
   EndIf

   ; Goal 2: The slaver is trying to (partially) undress the player.
   If (2 == _iLeashHolderGoal)
      ;Log("Goal 2: Undress the player.", DL_TRACE, S_MOD)

      ; If the player has undressed.  Relax a little.
      If (_qFramework.NS_BOTH_PARTIAL >= _qFramework.GetNakedLevel())
         _qFramework.RemovePermission(_aLeashHolder, _qFramework.AP_DRESSING_ASSISTED)

         _iLeashHolderGoal = -2
         _qFramework.IncActorAnger(_aLeashHolder, -3, 30, 100)
         Return
      EndIf

      ; Increase the leash holder's annoyance at the player's not having undressed yet.
      _iLeashGoalRefusalCount += 1
      iAnger = _qFramework.IncActorAnger(_aLeashHolder, _iLeashGoalRefusalCount / 5, 0, 80)

      ; Only try to start something if the player is not already involved in a scene.
      If (!_qFramework.GetCurrentScene())
         ; If the actor is overly annoyed yank the player's leash.
         If (65 < iAnger)
            _qFramework.RemovePermission(_aLeashHolder, _qFramework.AP_DRESSING_ASSISTED)
            AssaultPlayer(0.3, bStrip=True, bAddArmBinder=True)
         ElseIf (!(_iLeashGoalRefusalCount % 5))
            ; Otherwise just talk to the player about her behaviour.
            StartConversation(_aLeashHolder)
         EndIf
      EndIf
      Return
   EndIf

   ; Goal 4: The slaver is trying to equip an arm binder on the player.
   If (4 == _iLeashHolderGoal)
      ;Log("Goal 4: Restrain the player's arms.", DL_TRACE, S_MOD)

      ; If the player has put on the restraint.  Relax a little.
      If (_qFramework.IsPlayerArmLocked())
         If (_aPlayer.WornHasKeyword(_qZadLibs.zad_DeviousArmbinder) && \
             !_qZadArmbinder.IsLocked && (75 >= Utility.RandomInt(1, 100)))
            PlayApproachAnimation(_aLeashHolder, "Inspect")
         EndIf

         _iLeashHolderGoal = -2
         _qFramework.IncActorAnger(_aLeashHolder, -3, 25, 100)
         Return
      EndIf

      ; Increase the leash holder's annoyance at the player's not having complied yet.
      _iLeashGoalRefusalCount += 1
      iAnger = _qFramework.IncActorAnger(_aLeashHolder, _iLeashGoalRefusalCount / 5, 0, 80)

      ; Only try to start something if the player is not already involved in a scene.
      If (!_qFramework.GetCurrentScene())
         ; If the actor is overly annoyed yank the player's leash.
         If (45 < iAnger)
            AssaultPlayer(0.3, bAddGag=True, bStrip=False, bAddArmBinder=True)
         ElseIf (!(_iLeashGoalRefusalCount % 5))
            ; Otherwise just talk to the player about her behaviour.
            StartConversation(_aLeashHolder)
         EndIf
      EndIf
      Return
   EndIf

   ; Otherwise Goal <= 0: The slaver doesn't have any particular intentions right now.
   ;Log("Goal " + _iLeashHolderGoal + ": No goal.", DL_TRACE, S_MOD)
   If (2 == _iLongTermAgenda)
      _iLongTermAgenda = 1
      _iLongTermAgendaDetails = 0

      ; If the gag is configured to be auto-remove, treat this as a punishment instead.
      If ((2 == _iMcmGagMode) && _qFramework.IsPlayerGagged())
         _iLongTermAgenda = 3
         _iGagRemaining += ((60 + (120 * _iBadBehaviour)) / _fMcmPollTime As Int)
      EndIf
   EndIf

   ; Check how upset the slaver is with the player and whether he is open to slaving her out.
   Int iCurrAnger = _qFramework.GetActorAnger(_aLeashHolder)
   If (_bIsEnslaveAllowed && (50 >= iCurrAnger))
      ; The player has been behaving and the slaver won't slave her out.
      _bIsEnslaveAllowed = False
      _qFramework.RemovePermission(_aLeashHolder, _qFramework.AP_ENSLAVE)
   ElseIf (!_bIsEnslaveAllowed && (70 <= iCurrAnger))
      ; The player has not been behaving and the slaver is okay with mods enslaving her.
      _bIsEnslaveAllowed = True
      _qFramework.AddPermission(_aLeashHolder, _qFramework.AP_ENSLAVE)
   EndIf

   ; If the player has re-equpped her weapons have the leash holder get angry.
   If (_qFramework.GetWeaponLevel())
      ;Log("Player has weapons!", DL_TRACE, S_MOD)

      If (_bReequipWeapons)
         ; Increase the refusal count to trigger a continuation dialogue.
         _iLeashGoalRefusalCount = 3
         _qFramework.IncActorAnger(_aLeashHolder, 5, 0, 100)
      EndIf

      StartConversation(_aLeashHolder, 1)
      Return
   EndIf
   ; The player doesn't have weapons.  If she does later they are considered "re-equipped".
   _bReequipWeapons = True

   ; Keep track of the slaver's position to determine moving, travelling, or stationary.
   Float fSlaverPosition = _aLeashHolder.X + _aLeashHolder.Y + _aLeashHolder.Z
   Bool bMoving = ((50 < _fLastPosition - fSlaverPosition) || \
                   (-50 > _fLastPosition - fSlaverPosition))
   _fLastPosition = fSlaverPosition

   ; Keep track of whether the player is in front of the slaver or not.
   Float fPlayerPosition = _aLeashHolder.GetHeadingAngle(_aPlayer)
   Bool bPlayerInFront = ((80 >= fPlayerPosition) && (-80 <= fPlayerPosition))

   ; If (The slaver is moving) && (This has been an issue for one poll already) &&
   ;    (The player is in font of the slaver)
   If (bMoving && (1 <= _iCurrWalkInFrontCount) && bPlayerInFront)
      ;Log("Walking in front.", DL_TRACE, S_MOD)

      ; Every so often the yank the player's leash and talk to her about her behaviour.
      If (!(_iCurrWalkInFrontCount % 3))
         ; Have the slaver get upset at the player's behaviour.
         _iTotalWalkInFrontCount += 1
         _qFramework.IncActorAnger(_aLeashHolder, 1, 0, 65)

         If (!_iMcmLeashResist || (_iMcmLeashResist < Utility.RandomInt(1, 100)))
            _qFramework.YankLeash()
         EndIf
         StartConversation(_aLeashHolder, 7)
      EndIf
      Return
   EndIf

   ; If the slaver is fed up with the player's backtalk.  Gag her.
   If ((5 <= _iVerbalAnnoyance) && !_qFramework.IsPlayerGagged())
      ;Log("Verbal annoyance.", DL_TRACE, S_MOD)
      StartConversation(_aLeashHolder, 6)
      Return
   EndIf

   ; Otherwise The player has been behaving.
   ;Log("Player behaving.", DL_TRACE, S_MOD)

   ; If the player is walking in front of the slaver make a note of it.
   ; Don't harass the player immediately as the slaver may have just turned.
   If (bPlayerInFront)
      _iCurrWalkInFrontCount += 1
   Else
      _iCurrWalkInFrontCount = 0
   EndIf

   ; If one of the player's punishments is up release her from it.
   If (_bReleaseBlindfold)
      ; 0x40000000: Peaceful (the player is co-operating)
      ; 0x0800: Release Blindfold
      _iAssault = Math.LogicalOr(0x40000000 + 0x0800, _iAssault)
      PlayApproachAnimation(_aLeashHolder, "Assault")

      _bReleaseBlindfold = False
   ElseIf (_bReleaseGag)
      ; 0x40000000: Peaceful (the player is co-operating)
      ; 0x0100: UnGag
      _iAssault = Math.LogicalOr(0x40000000 + 0x0100, _iAssault)
      PlayApproachAnimation(_aLeashHolder, "Assault")

      _bReleaseGag = False
   EndIf

   ; Check if the slaver wants to start a new event (goal).
   Int iRandomEvent = Utility.RandomInt(1, 100)

   ; If the player is behaving increase the slaver's pleased state.
   If (!_iCurrWalkInFrontCount && (15 >= iRandomEvent))
      _qFramework.IncActorAnger(_aLeashHolder, -1, 40, 100)
      If (0 < _iVerbalAnnoyance)
         _iVerbalAnnoyance -= 1
      EndIf
   EndIf

   ; The longer the player is enslaved, the more dominant the slaver feels.
   If (2 >= iRandomEvent)
      _qFramework.IncActorDominance(_aLeashHolder, 1, 0, 100)
   EndIf

   ; If the goal is set to less than 0 that indicates a delay.  Just increment it.
   If (0 > _iLeashHolderGoal)
      ;Log("Goal not zero yet.", DL_TRACE, S_MOD)
      _iLeashHolderGoal += 1
      Return
   EndIf

   ; If the player is already dressed and decorated as a slave don't process any more options.
   If (_bIsCompleteSlave && (2 <= _iWeaponsStolen))
      ; Inspect the player's restraints to make sure they are secure.
      If (3 >= iRandomEvent)
         If (_aPlayer.WornHasKeyword(_qZadLibs.zad_DeviousArmbinder) && \
             (_qZadArmbinder.StruggleCount || !_qZadArmbinder.IsLocked))
            PlayApproachAnimation(_aLeashHolder, "Inspect")
         EndIf
      EndIf

      ; If the slaver has ungagged the player there is a chance he will want to gag her again.
      If (_bPlayerUngagged && (3 < iRandomEvent) && (6 >= iRandomEvent))
         _bPlayerUngagged = False
         If (_qFramework.IsPlayerGagged())
            _bFullyRestrained = False
            _bIsCompleteSlave = False
         EndIf
      EndIf

      ; If the player has somehow escaped her arm binder she is no longer fully enslaved.
      If (!_qFramework.IsPlayerArmLocked())
         _bFullyRestrained = False
         _bIsCompleteSlave = False
      EndIf
      Return
   EndIf

   iAnger = _qFramework.GetActorAnger(_aLeashHolder)
   ;Log("Checking events: Anger(" + iAnger + ") Random(" + iRandomEvent + ")", DL_TRACE, S_MOD)

   ; Check if the slaver wants to bind the player's arms based on how angry he is.
   ; Anger >= 75: 100%  Anger 50-65: 50%  Anger 40-50: 15%  Anger < 40: 8%
   If (((75 <= iAnger) || ((65 <= iAnger) && (50 >= iRandomEvent)) || \
        ((40 <= iAnger) && (15 >= iRandomEvent)) || ((40 > iAnger) && (8 >= iRandomEvent))) && \
       _oArmRestraint && ((4 != _iLongTermAgenda) || (1 != _iLongTermAgendaDetails)) && \
       !_qFramework.IsPlayerArmLocked())
      ;Log("Starting Arm Restraints.", DL_TRACE, S_MOD)

      If (!_oArmRestraint)
         FindArmRestraint(_aLeashHolder)
      EndIf

      ; Remove any of these items the player may have and make sure she has a single one.
      _aPlayer.RemoveItem(_oArmRestraint, 999, abSilent=True)
      _aPlayer.AddItem(_oArmRestraint)

      StartConversation(_aLeashHolder, 4)
      Return
   EndIf

   ; Check if the slaver wants to strip the player.
   If ((10 < iRandomEvent) && (20 >= iRandomEvent) && \
       (_qFramework.NS_BOTH_PARTIAL < _qFramework.GetNakedLevel()))
      ;Log("Starting Stripping.", DL_TRACE, S_MOD)

      ; Goal 2: Get the player out of her armour.
      StartConversation(_aLeashHolder, 2)
      Return
   EndIf

   ; All of the following will only be considered if the player's arms are locked up.
   iRandomEvent = Utility.RandomInt(1, 100)
   If (_qFramework.IsPlayerArmLocked() && (iRandomEvent <= _iMcmChanceIdleRestraints))
      ;Log("Extra Events.", DL_TRACE, S_MOD)
      iRandomEvent = Utility.RandomInt(1, 100)

      If ((50 >= iRandomEvent) && (2 > _iWeaponsStolen))
         ;Log("Take Weapons.", DL_TRACE, S_MOD)
         ; Goal 3: Take the player's weapons.
         StartConversation(_aLeashHolder, 3)
         Return
      EndIf

      If ((50 < iRandomEvent) && (75 >= iRandomEvent) && _qFramework.GetNakedLevel())
         ;Log("Strip.", DL_TRACE, S_MOD)
         ; Goal 5: Strip the player fully.
         StartConversation(_aLeashHolder, 5)
         Return
      EndIf

      If ((75 < iRandomEvent) && !_bFullyRestrained)
         ;Log("Restrain.", DL_TRACE, S_MOD)
         ; Verify the player is not already restrained like a slave.
         ; Gag, Arms, Boots/Hobble, Collar
         If (!CheckPlayerFullyBound())
            ; Goal 8: Restrain the player.
            StartConversation(_aLeashHolder, 8)
            Return
         EndIf
      EndIf
   EndIf
EndFunction

Function StartSdPlus()
   If (!_bEnslavedSdPlus)
      Log("Player now SD+ Enslaved.", DL_CRIT, S_MOD)

      Actor aMaster = (StorageUtil.GetFormValue(_aPlayer, "_SD_CurrentOwner") As Actor)
      If (SUCCESS <= _qFramework.SetMaster(aMaster, S_MOD_SD, _qFramework.AP_NO_BDSM, \
                                           _qFramework.MD_CLOSE, True))
         ; Identify the plyaer is now SD+ enslaved.
         _bEnslavedSdPlus = True

         ; Check if the player is currently locked in her cage.
         _bCagedSdPlus = False
         If (_gSdPlusStateCaged.GetValue())
            _bCagedSdPlus = True
         EndIf

         ; If we are configured to leash the player do so now.
         If (_qMcm.bLeashSdPlus)
            _qFramework.BlockHealthRegen()
            _qFramework.BlockMagickaRegen()
            If (!_bCagedSdPlus)
               _qFramework.SetLeashTarget(aMaster)
            EndIf
         EndIf
      EndIf
   EndIf
EndFunction

Function StopSdPlus()
   If (_bEnslavedSdPlus)
      Log("Player no longer SD+ Enslaved.", DL_CRIT, S_MOD)

      _qFramework.ClearMaster(None, S_MOD_SD)
      If (_qMcm.bLeashSdPlus)
         _qFramework.RestoreHealthRegen()
         _qFramework.RestoreMagickaRegen()
         _qFramework.SetLeashTarget(None)
      EndIf
      _bEnslavedSdPlus = False
   EndIf
EndFunction

; This can be used to turn on or of the SD+ leash in the case that the MCM value changes.
Function UpdateSdPlusLeashState(Bool bNewValue)
   ; If the player is not SD+ enslaved or the SD+ master is not registered with DFW for some
   ; reason don't try to start/stop the leash.
   If (!_bEnslavedSdPlus || (S_MOD_SD != _qFramework.GetMasterMod(_qFramework.MD_CLOSE)))
      Return
   EndIf

   If (bNewValue)
      Actor aMaster = (StorageUtil.GetFormValue(_aPlayer, "_SD_CurrentOwner") As Actor)
      If (!_bCagedSdPlus)
         _qFramework.SetLeashTarget(aMaster)
      EndIf
      If (_qMcm.bLeashSdPlus)
         _qFramework.BlockHealthRegen()
         _qFramework.BlockMagickaRegen()
      EndIf
   Else
      _qFramework.SetLeashTarget(None)
      If (!_qMcm.bLeashSdPlus)
         _qFramework.RestoreHealthRegen()
         _qFramework.RestoreMagickaRegen()
      EndIf
   EndIf
EndFunction

; Called by dialog scripts to indicate the dialog is upsetting the speaker.
Function IncAnger(Actor aActor, Int iDelta)
   _qFramework.IncActorAnger(aActor, iDelta, 20, 80)

   ; Reset the dialogue timeout beacuse we are still in a dialogue.
   If (_iDialogueBusy)
      _iDialogueBusy = 20
   EndIf
EndFunction

; This is typically used to reduce an actor's kindness when the player "tries her luck" to
; to help ensure the actor doesn't change his mind and decide to help the player later.
Function ActorFailedToHelp(Actor aActor, Int iSeverity)
   If (1 == iSeverity)
      _qFramework.IncActorKindness(aActor, -3, 20, 80)
      _qFramework.IncActorAnger(aActor, 1, 20, 70)
   ElseIf (3 == iSeverity)
      _qFramework.IncActorKindness(aActor, -5, 20, 80)
      _qFramework.IncActorAnger(aActor, 3, 20, 70)
   EndIf

   ; Reset the dialogue timeout beacuse we are still in a dialogue.
   If (_iDialogueBusy)
      _iDialogueBusy = 20
   EndIf
EndFunction

; Called by dialog scripts to indicate the slaver is feeling more dominant toward the player.
Function IncDominance(Actor aActor, Int iDelta)
   _qFramework.IncActorDominance(aActor, iDelta, 20, 80)

   ; Reset the dialogue timeout beacuse we are still in a dialogue.
   If (_iDialogueBusy)
      _iDialogueBusy = 20
   EndIf
EndFunction

; The palyer has said something to verbally annoy the slaver.  Increase his annoyance count.
Function VerbalAnnoyance(Int iLevel=1)
   _iVerbalAnnoyance += iLevel
EndFunction

; Plays a dominant approaching the player choosing an animation based on whether the player is
; in BDSM furniture or not.
Function PlayApproachAnimation(Actor aNpc, String szMessage)
   ; If we can't lock the DFW scene flag don't try to start a scene.
   If (_qFramework.SceneStarting(S_MOD, 60))
      Return
   EndIf

   ; Wait for the NPC if he is in the process of sitting or standing.
   ActorSitStateWait(aNpc)

   _qFramework.YankLeashWait(500)
   If (_qFramework.GetBdsmFurniture())
      ImmobilizePlayer()
      _qZbfSlaveActions.RestrainInDevice(None, aNpc, asMessage=S_MOD + "_F_" + szMessage)
   Else
      _qZbfSlaveActions.BindPlayer(akMaster=aNpc, asMessage=S_MOD + "_" + szMessage)
   EndIf
EndFunction

; Called by dialog scripts to indicate the player has agreed to or refuses to cooperate.
; The level of cooperation: < 0 not cooperating, 0 = avoiding the subject, > 0 = cooperating.
Function Cooperation(Int iGoal, Int iLevel, Actor aNpc, Bool bWaitForEnd=True)
   ; If we are expected to wait for the dialogue to end, do so now.
   If (bWaitForEnd)
      Float fSecurity = 30
      While ((0 < fSecurity) && aNpc.IsInDialogueWithPlayer())
         Utility.Wait(0.05)
         fSecurity -= 0.05
      EndWhile
   EndIf

   If (0 < iLevel)
      _qFramework.IncActorAnger(aNpc, -1, 20, 80)
   ElseIf (-1 == iLevel)
      _qFramework.IncActorAnger(aNpc, 2, 20, 80)
   ElseIf (-1 > iLevel)
      _qFramework.IncActorAnger(aNpc, 4, 20, 80)
   EndIf

   If (0 == iGoal)
      ; Make sure there is a bit of delay before we start another dialogue.
      If (0 == _iLeashHolderGoal)
         _iLeashHolderGoal = -1
      EndIf
      If (-2 == iLevel)
         ; The player is getting rebellious.  Have the slaver forcibly gag her.
         AssaultPlayer(bAddGag=True)
      EndIf
   ElseIf (1 == iGoal)
      If (3 == iLevel)
         ; The player needs help unequipping her weapons.
         Weapon oWeaponRight = _aPlayer.GetEquippedWeapon()
         Weapon oWeaponLeft = _aPlayer.GetEquippedWeapon(True)
         _aPlayer.UnequipItem(oWeaponRight)
         _aPlayer.UnequipItem(oWeaponLeft)

         ; The leash holder is rather upset and will just take the weapons.
         If (60 < _qFramework.GetActorAnger(aNpc))
            _aPlayer.RemoveItem(oWeaponRight, 999, akOtherContainer=aNpc)
            _aPlayer.RemoveItem(oWeaponLeft, 999, akOtherContainer=aNpc)
            _aoItemStolen = _qDfwUtil.AddFormToArray(_aoItemStolen, oWeaponRight)
            _aoItemStolen = _qDfwUtil.AddFormToArray(_aoItemStolen, oWeaponLeft)
            If (1 > _iWeaponsStolen)
               _iWeaponsStolen = 1
            EndIf
         EndIf
      ElseIf (((-2 == iLevel) || (-3 == iLevel) || \
               (_aPlayer.IsWeaponDrawn() && _qFramework.GetWeaponLevel())) && \
              (!_iMcmLeashResist || (_iMcmLeashResist < Utility.RandomInt(1, 100))))
         _qFramework.YankLeash(iOverrideLeashStyle=_qFramework.LS_DRAG)
      EndIf
   ElseIf (2 == iGoal)
      If (4 == iLevel)
         ; Before letting the player free of her arm binder the slaver will take her weapons.
         ; Play an animation for the slaver to approach the player.
         ; The assault (weapon stealing) will happen on the done event (OnSlaveActionDone).
         ; 0x40000000: Peaceful (the player is co-operating)
         ; 0x0020: Unbind Arms
         ; 0x0008: Take All Weapons
         _iAssault = Math.LogicalOr(0x40000000 + 0x0020 + 0x0008, _iAssault)
         PlayApproachAnimation(aNpc, "Assault")
      ElseIf (3 == iLevel)
         ; The player needs help unequipping her weapons.
         ; Play an animation for the slaver to approach the player.
         ; The assault (stripping) will happen on the done event (OnSlaveActionDone).
         ; 0x40000000: Peaceful (the player is co-operating)
         ; 0x0001: Strip
         _iAssault = Math.LogicalOr(0x40000000 + 0x0001, _iAssault)
         PlayApproachAnimation(aNpc, "Assault")
      ElseIf (-2 >= iLevel)
         ; The slaver is done asking.  Forcibly strip the player.
         AssaultPlayer(bStrip=False)
      EndIf

      ; Set the player to have dressing assisted with the devious framework.  This is so the
      ; slaver can help the player equip sexy clothing over her leash.
      _qFramework.AddPermission(aNpc, _qFramework.AP_DRESSING_ASSISTED)
   ElseIf (3 == iGoal)
      ; Goal 3: Take the player's weapons.
      ; 0x40000000: Peaceful (the player is co-operating)
      ; 0x0008: Take All Weapons
      _iAssault = Math.LogicalOr(0x40000000 + 0x0008, _iAssault)
      PlayApproachAnimation(aNpc, "Assault")
      _iLeashHolderGoal = 0
   ElseIf (5 == iGoal)
      ; Goal 5: Strip the player fully.
      ; 0x40000000: Peaceful (the player is co-operating)
      ; 0x0040: Strip Fully
      _iAssault = Math.LogicalOr(0x40000000 + 0x0040, _iAssault)
      PlayApproachAnimation(aNpc, "Assault")
      _iLeashHolderGoal = 0
   ElseIf (7 == iGoal)
      ; After we have spoken to the player about it, don't bring it up for a while.
      _iLeashHolderGoal = 0
   ElseIf (8 == iGoal)
      ; Goal 8: Restrain the player.
      If (!_iAssault)
         ; 0x40000000: Peaceful (the player is co-operating)
         ; 0x0080: Add Additional Restraint
         _iAssault = Math.LogicalOr(0x40000000 + 0x0080, _iAssault)
      EndIf
      PlayApproachAnimation(aNpc, "Assault")
      _iLeashHolderGoal = 0
   ElseIf (9 == iGoal)
      ; Goal 9: Reel in the Player
      _iLeashHolderGoal = 0

      ; Give the player some time to respond and decrease the time she has for the future.
      Utility.Wait(_iExpectedResponseTime)
      If (3 < _iExpectedResponseTime)
         _iExpectedResponseTime -= 1
      EndIf

      ; Shorten the player's leash.
      _qFramework.SetLeashLength(200)

      ; 0x0001 = Talking of Escape
      If (Math.LogicalAnd(0x0001, _iPunishments))
         _iBadBehaviour += 1
         _iLongTermAgenda = 3
         _iLongTermAgendaDetails = 0
         _iBlindfoldRemaining += ((60 + (60 * _iBadBehaviour)) / _fMcmPollTime As Int)
         _iGagRemaining += ((60 + (120 * _iBadBehaviour)) / _fMcmPollTime As Int)

         ; Goal 10: Discipline Talking Escape
         StartConversation(aNpc, 10)
      EndIf
   ElseIf (10 == iGoal)
      ; Goal 10: Discipline Talking Escape

      Bool bRestrainedAssault = True
      ; 0x40000000: Peaceful (the player is co-operating)
      ; 0x1000: Restore Leash Length
      _iAssault = Math.LogicalOr(0x40000000 + 0x1000, _iAssault)

      ; If we were handling a callout end the scene (Note: a new assault scene may start).
      If (S_MOD + "_CallOut" == _qFramework.GetCurrentScene())
         _qFramework.CallOutDone()
         _qFramework.SceneDone(S_MOD + "_CallOut")
      EndIf

      _iBadBehaviour += 1
      _iLongTermAgenda = 3
      _iLongTermAgendaDetails = 0
      _iBlindfoldRemaining += ((60 + (60 * _iBadBehaviour)) / _fMcmPollTime As Int)
      _iGagRemaining += ((60 + (120 * _iBadBehaviour)) / _fMcmPollTime As Int)

      ; If the player's arms are not yet bound make sure they are secure.
      If (!_qFramework.IsPlayerArmLocked())
         _iLeashHolderGoal = 4
         If (_aPlayer.IsWeaponDrawn())
            _iLeashHolderGoal = 1
         EndIf
         ; The player can resist.  Perform an assault allowing for a struggle.
         bRestrainedAssault = False
         AssaultPlayer(0.3, bUnquipWeapons=True, bStealWeapons=False, bAddArmBinder=True, \
                       bAddGag=True)
      ElseIf (!_qFramework.IsPlayerGagged())
         ; 0x0002: Gag
         ; 0x2000: Make sure the Gag is secure
         _iAssault = Math.LogicalOr(0x2000 + 0x0002, _iAssault)

         ; If the player has been particularly misbehaving add an extra restraint.
         If (-1 >= iLevel)
            ; 0x0400: Blindfold
            _iAssault = Math.LogicalOr(0x0400, _iAssault)
         EndIf
      Else
         _qFramework.SetStrictGag()
         ; If the player is already blindfolded try locking her in nearby furniture.
         If (_aPlayer.WornHasKeyword(_qZadLibs.zad_DeviousBlindfold) && \
             (SUCCESS == StartPunishmentFurniture(aNpc)))
            _qFramework.ForceSave()
            bRestrainedAssault = False
         ElseIf (-1 >= iLevel)
            ; 0x0400: Blindfold
            _iAssault = Math.LogicalOr(0x0400, _iAssault)
         Else
            If (!_qFramework.IsPlayerCollared())
               ; 0x0200: Restrain in Collar
               _iAssault = Math.LogicalOr(0x0200, _iAssault)
            EndIf
            If (!_qFramework.IsPlayerHobbled())
               ; 0x0080: Add Additional Restraint
               _iAssault = Math.LogicalOr(0x0080, _iAssault)
            EndIf
         EndIf
      EndIf

      ; Make a note the slaver does not want the player ungagged.
      _bPlayerUngagged = False

      ; If the palyer is restrained and we can restrain/punish her further do so now.
      If (bRestrainedAssault)
         PlayApproachAnimation(aNpc, "Assault")
         _iLeashHolderGoal = 0
      EndIf
   ElseIf (-3 == iGoal)
      ; Post Leash game the player wants her weapons back.
      Actor aLastLeashHolder = (_aAliasLastLeashHolder.GetReference() As Actor)
      If (1 == iLevel)
         ; The player's arms are free.  The slaver wants her locked up before returning them.
         ; Play an animation for the slaver to approach the player.
         ; Restraining the player's arms will happen on the done event (OnSlaveActionDone).
         ; 0x40000000: Peaceful (the player is co-operating)
         ; 0x0010: Return All Items
         ; 0x0004: Bind Arms
         _iAssault = Math.LogicalOr(0x40000000 + 0x0010 + 0x0004, _iAssault)
         PlayApproachAnimation(aLastLeashHolder, "Assault")
      ElseIf (2 == iLevel)
         ; 0x40000000: Peaceful (the player is co-operating)
         ; 0x0010: Return All Items
         _iAssault = Math.LogicalOr(0x40000000 + 0x0010, _iAssault)
         FinalizeAssault(aLastLeashHolder, aLastLeashHolder.GetDisplayName())
      EndIf
   ElseIf (-6 == iGoal)
      ; The player has been well behaved and is being ungagged.
      ; 0x40000000: Peaceful (the player is co-operating)
      ; 0x0100: UnGag
      _iAssault = Math.LogicalOr(0x40000000 + 0x0100, _iAssault)
      PlayApproachAnimation(aNpc, "Assault")
   EndIf

   ; Enticing the NPC's co-operation (or lack thereof) indicates the end of the conversation.
   _iDialogueBusy = 0
   _aDialogueTarget = None
EndFunction

; Called by dialog scripts to indicate the player has received outside assistance.
; Note: The goal here is for Outside Assistance.  It does not match the leash holder goal.
Function OutsideAssistance(Actor aHelper, Int iGoal, Int iLevel)
   String szLeashHolder = _aLeashHolder.GetDisplayName()
   String szHelper = aHelper.GetDisplayName()

   If (1 == iGoal)
      ; Goal 1: Set the player free.
      ; Level 1: The helper tells the leash holder to release the player.
      ; Level 2: The helper finds a way to free the player.
      If (1 == iLevel)
         Log(szHelper + " convinces " + szLeashHolder + " to untie your leash.", DL_CRIT, S_MOD)
      ElseIf (2 == iLevel)
         Log(szHelper + " manages to untie your leash and free you.", DL_CRIT, S_MOD)
      EndIf
      ; If the player actually manages to escape, treat this as more than one escape attempt.
      ; This could matter if the same slaver catches the player again shortly.
      _iBadBehaviour += 3
      StopLeashGame()
   ElseIf (0 == iGoal)
      ; Goal 0: The player has not received assistance but a conversation is taking place.
      ; Figure out what is the chance she will be noticed.
      Int iMaxChance = _iMcmEscapeDetection
      ; Increase the chances if the player is close to the slaver.
      Float fModifier = 1 - (_aLeashHolder.GetDistance(_aPlayer) / _qMcm.iLeashLength)
      If (0.0 > fModifier)
         fModifier = 0.0
      EndIf
      ; Increase the chances if the slaver is looking toward the player.
      Float fPlayerPosition = _aLeashHolder.GetHeadingAngle(_aPlayer)
      If ((80 >= fPlayerPosition) && (-80 <= fPlayerPosition))
         fModifier += 0.25
         If ((40 >= fPlayerPosition) && (-40 <= fPlayerPosition))
            fModifier += 0.25
         EndIf
      EndIf
      iMaxChance += ((iMaxChance * fModifier) As Int)
      Int iRoll = Utility.RandomInt(1, 100)
      Log("Escape Detection Roll: " + iRoll + "/" + iMaxChance, DL_TRACE, S_MOD)

      If (!_iLeashHolderGoal && (iMaxChance >= iRoll))
         Log("You feel a tug on the rope around your neck.", DL_CRIT, S_MOD)
         _qFramework.IncActorAnger(_aLeashHolder, 2, 20, 80)
         _qFramework.IncActorDominance(_aLeashHolder, -3, 20, 80)

         ; Have the slaver give a warning that he is shortening the player's leash.
         ; Goal 9: Reel in the Player
         StartConversation(_aLeashHolder, 9, bInterruptPlayer=True)
         _iPunishments = Math.LogicalOr(0x0001, _iPunishments)
      EndIf
   ElseIf (-1 == iGoal)
      ; Goal -1: The NPC has actually tipped of the slaver that the player is misbehaving.
      If (!_iLeashHolderGoal)
         Log("You feel a tug on the rope around your neck.", DL_CRIT, S_MOD)
         _qFramework.IncActorAnger(_aLeashHolder, 5, 20, 80)

         ; Have the slaver give a warning that he is shortening the player's leash.
         ; Goal 9: Reel in the Player
         StartConversation(_aLeashHolder, 9, bInterruptPlayer=True)
         _iPunishments = Math.LogicalOr(0x0001, _iPunishments)
      EndIf
   EndIf
EndFunction

; SUCCESS means pending scenes were started.  WARNING means there is nothing left to process.
Int Function ProcessFurnitureGoals(Actor aNpc)
   Bool bHaveSex = False
   Bool bWhip    = False
   Bool bAlternateAssault = False
   _iAssaultTakeGold = 0
   Bool bCooperating = Math.LogicalAnd(_iFurnitureGoals, 0x0001)

   ; First check if the furniture needs to be locked.
   ; 0x8000: Lock Furniture
   If (0x8000 <= _iFurnitureGoals)
      If (0 < _fFurnitureReleaseTime)
         bAlternateAssault = True
         _qZbfSlaveActions.RestrainInDevice(None, aNpc, S_MOD + "_PreLock")
      EndIf

      _iFurnitureGoals -= 0x8000
      Return SUCCESS
   EndIf

   ; 0x0800: Restrain the player's arms
   If (0x0800 <= _iFurnitureGoals)
      _iAssault = Math.LogicalOr(0x0004, _iAssault)

      _iFurnitureGoals -= 0x0800
   EndIf

   ; 0x0400: Take the player's gold
   If (0x0400 <= _iFurnitureGoals)
      bAlternateAssault = True
      Int iLeveledMax = 100 * ((_aPlayer.GetLevel() / 10) + 1)
      _iAssaultTakeGold = _aPlayer.GetGoldAmount()
      If (iLeveledMax < _iAssaultTakeGold)
         _iAssaultTakeGold = iLeveledMax
      EndIf

      _iFurnitureGoals -= 0x0400
   EndIf

   ; 0x0200: Play(Sex/Whip)
   If (0x0200 <= _iFurnitureGoals)
      If (50 >= Utility.RandomInt(1, 100))
         bHaveSex = True
      Else
         bWhip    = True
      EndIf

      _iFurnitureGoals -= 0x0200
   EndIf

   ; 0x0100: Add Restraints
   If (0x0100 <= _iFurnitureGoals)
      _iAssault = Math.LogicalOr(0x0080, _iAssault)

      _iFurnitureGoals -= 0x0100
   EndIf

   ; 0x0080: Undress
   If (0x0080 <= _iFurnitureGoals)
      If (_qFramework.NS_NAKED != _qFramework.GetNakedLevel())
         _iAssault = Math.LogicalOr(0x0001, _iAssault)
      EndIf

      _iFurnitureGoals -= 0x0080
   EndIf

   ; 0x0040: Gag
   If (0x0040 <= _iFurnitureGoals)
      _iAssault = Math.LogicalOr(0x0002, _iAssault)

      Int iBehaviour = _iBadBehaviour + 1
      If (50 < _qFramework.GetActorAnger(aNpc))
         iBehaviour += 3
      EndIf
      _iGagRemaining += ((60 + (120 * iBehaviour)) / _fMcmPollTime As Int)

      _iFurnitureGoals -= 0x0040
   EndIf

   ; If we are processing an assault we want to do that to completion first.
   If (_iAssault || bAlternateAssault)
      ; Make sure the proper flags are set to Whipping and sex get processed later.
      If (bWhip && Math.LogicalAnd(_iFurnitureGoals, 0x0010))
         bWhip    = False
         bHaveSex = True
      ElseIf (bHaveSex && Math.LogicalAnd(_iFurnitureGoals, 0x0008))
         bWhip    = True
         bHaveSex = False
      EndIf
      If (bWhip)
         _iFurnitureGoals = Math.LogicalOr(_iFurnitureGoals, 0x0010)
      EndIf
      If (bHaveSex)
         _iFurnitureGoals = Math.LogicalOr(_iFurnitureGoals, 0x0008)
      EndIf

      ; Perform the assult now.
      ; The assault will happen on the done event (OnSlaveActionDone).
      If (bCooperating)
         ; 0x40000000: Peaceful (the player is co-operating)
         _iAssault = Math.LogicalOr(0x40000000, _iAssault)
         PlayApproachAnimation(aNpc, "Assault")
      Else
         ; The player is not co-operating.  Use force.
         AssaultPlayer()
      EndIf
      Return SUCCESS
   EndIf

   ; 0x0020: Secure Gag
   If (0x0020 <= _iFurnitureGoals)
      _qFramework.SetStrictGag()

      _iGagRemaining += ((_iGagRemaining * 0.5) As Int)

      _iFurnitureGoals -= 0x0020
   EndIf

   ; 0x0010: Whip
   If (bWhip || (0x0010 <= _iFurnitureGoals))
      _qFramework.IncActorDominance(aNpc, 1, 0, 100)
      StartWhippingScene(aNpc, 120, S_MOD + "_Whip")

      If (0x0010 <= _iFurnitureGoals)
         _iFurnitureGoals -= 0x0010
      EndIf
      Return SUCCESS
   EndIf

   ; 0x0008: Sex
   If (bHaveSex || (0x0008 <= _iFurnitureGoals))
      StartSex(aNpc, !bCooperating)

      If (0x0008 <= _iFurnitureGoals)
         _iFurnitureGoals -= 0x0008
      EndIf
      Return SUCCESS
   EndIf

   ; 0x0004: Ungag
   If (0x0004 <= _iFurnitureGoals)
      ; Perform an assault to ungag the player.
      ; The assault will happen on the done event (OnSlaveActionDone).
      ; 0x40000000: Peaceful (the player is co-operating)
      ; 0x0100: UnGag
      _iAssault = Math.LogicalOr(0x40000000 + 0x0100, _iAssault)
      PlayApproachAnimation(aNpc, "Assault")

      _iFurnitureGoals -= 0x0004
      Return SUCCESS
   EndIf

   ; 0x0002: Release
   If (0x0002 <= _iFurnitureGoals)
      Int iWillingnessToHelp = _qFramework.GetActorWillingnessToHelp(aNpc)
      If (Utility.RandomInt(1, 100) <= iWillingnessToHelp)
         PlayApproachAnimation(aNpc, "Unlock")
      Else
         ; Add a delay here because speaking again so soon after a conversation doesn't work.
         Utility.Wait(2)

         ; Goal 13: Lying About Release
         StartConversation(aNpc, 13)
         ; Only clear the release flag is the NPC is lying.  If the NPC is releasing the player
         ; we want to still know it is a result of these furniture goals as the scene ends.
         _iFurnitureGoals -= 0x0002
      EndIf
      Return SUCCESS
   EndIf

   ; 0x0001: Cooperating
   If (0x0001 <= _iFurnitureGoals)
      _iFurnitureGoals -= 0x0001
      Return SUCCESS
   EndIf
   Return WARNING
EndFunction

; Called by dialog scripts to indicate the player has completed a conversation.
; iContext: 0: No Relevant Context  1: Leash Game  2: Furniture
;           3: Intermediate Conversation.  The conversation ended but did not resolve any scene.
; iActions uses the same definition as _iFurnitureGoals.
; iSpecialActions: 0x0001: Permit Assisted Dressing
;                  0x0002: Resecure All Restraints
; iCooperation: How cooperative the player is.  Positive numbers indicate cooperation.
Function DialogueComplete(Int iContext, Int iActions, Actor aNpc, Int iCooperation=0, \
                          Int iSpecialActions=0, Bool bWaitForEnd=True)
   ; If we are expected to wait for the dialogue to end, do so now.
   If (bWaitForEnd)
      Float fSecurity = 30
      While ((0 < fSecurity) && aNpc.IsInDialogueWithPlayer())
         Utility.Wait(0.05)
         fSecurity -= 0.05
      EndWhile
   EndIf

   ; If we were handling a callout end the scene.
   String szCurrScene = _qFramework.GetCurrentScene()
   If (S_MOD + "_CallOut" == szCurrScene)
      _qFramework.CallOutDone()
      _qFramework.SceneDone(szCurrScene)
   ElseIf (S_MOD + "_StartDialogue" == szCurrScene)
      _qFramework.SceneDone(szCurrScene)
   EndIf

   ; If the conversation was a result of a conversation goal reset it.
   If ((12 <= _iLeashHolderGoal) && (14 >= _iLeashHolderGoal))
      _iLeashHolderGoal = -1
   EndIf

   ; Adjust the actor's disposition based on the cooperation of the player.
   If (0 > iCooperation)
      ; The player is not cooperating.  Consider adjusting the NPC's anger and kindness.
      Int iRandom = Utility.RandomInt(iCooperation, 0)
      If (iRandom)
         _qFramework.IncActorAnger(aNpc, 0 - iRandom, 0, 80)
         _qFramework.IncActorKindness(aNpc, 2 * iRandom, 0, 80)
      EndIf
      _iVerbalAnnoyance += 1
   ElseIf (0 < iCooperation)
      ; The player is cooperating.  Decrease the NPC's anger.
      _qFramework.IncActorAnger(aNpc, 0 - iCooperation, 0, 80)
      _iVerbalAnnoyance -= 1

      ; If the player is cooperating and not being released.  Increase the NPC's dominance.
      If (!Math.LogicalAnd(0x0002, iActions))
         Int iMax = 60 + (10 * iCooperation)
         Int iRandom = Utility.RandomInt(0, iCooperation)
         If (iRandom)
            _qFramework.IncActorDominance(aNpc, iRandom, 0, iMax)
         EndIf
      EndIf
   EndIf

   ; If there are any special actions process them first.
   If (iSpecialActions)
      ; 0x0002: Resecure All Restraints
      If (0x0002 <= iSpecialActions)
         If (!_qFramework.IsPlayerCollared())
            ; 0x0200: Restrain in Collar
            _iAssault = Math.LogicalOr(0x0200, _iAssault)
         EndIf
         If (_iGagRemaining && !_qFramework.IsPlayerGagged())
            ; 0x0002: Gag
            ; 0x2000: Make sure the Gag is secure
            _iAssault = Math.LogicalOr(0x2000 + 0x0002, _iAssault)
         EndIf
         If (_iBlindfoldRemaining && !_aPlayer.WornHasKeyword(_qZadLibs.zad_DeviousBlindfold))
            ; 0x0400: Blindfold
            _iAssault = Math.LogicalOr(0x0400, _iAssault)
         EndIf
         If (_bFullyRestrained && !_qFramework.IsPlayerHobbled())
            ; 0x4000: Restrain in Boots
            _iAssault = Math.LogicalOr(0x4000, _iAssault)
         EndIf

         ; If some restraints weren't added make sure to extend the player's punishment times.
         If (_iAssault)
            _iBadBehaviour += 1
            _iFurnitureRemaining += ((180 * _iBadBehaviour) / _fMcmPollTime As Int)
            _iBlindfoldRemaining += (( 60 * _iBadBehaviour) / _fMcmPollTime As Int)
            _iGagRemaining       += ((120 * _iBadBehaviour) / _fMcmPollTime As Int)
            If (_iBlindfoldRemaining < _iFurnitureRemaining)
               _iBlindfoldRemaining = _iFurnitureRemaining
            EndIf
            If (_iGagRemaining < _iFurnitureRemaining)
               _iGagRemaining = _iFurnitureRemaining
            EndIf
         EndIf

         iSpecialActions -= 0x0002
      EndIf

      ; 0x0001: Permit Assisted Dressing
      If (0x0001 <= iSpecialActions)
         _qFramework.AddPermission(aNpc, _qFramework.AP_DRESSING_ASSISTED)

         iSpecialActions -= 0x0001
      EndIf
   EndIf

   _iFurnitureGoals = Math.LogicalOr(iActions, _iFurnitureGoals)
   ; Keep track of the player's cooperation in the _iFurnitureGoals flags.
   If (0 < iCooperation)
      _iFurnitureGoals = Math.LogicalOr(0x0001, _iFurnitureGoals)
   EndIf

   ProcessFurnitureGoals(aNpc)

   ; If we have completed all short-term goals clear the variable.
   If ((1 == iContext) && !_iFurnitureGoals && (0 < _iLeashHolderGoal))
      _iLeashHolderGoal = -2
   EndIf

   ; Identify the dialogue is done.
   _iDialogueBusy = 0
   _aDialogueTarget = None
   If (3 == iContext)
      ; If the dialogue did not complete a scene set a small delay to allow for any extra
      ; actions that are needed as part of the dialogue/scene.
      _iDialogueBusy = 2
   EndIf
EndFunction

Int Function GetLeashGameDuration(Bool bExtend=False)
   ; Figure out how long the leash game will be played for.
   Int iDurationSeconds = (Utility.RandomInt(_qMcm.iDurationMin, _qMcm.iDurationMax) * 60)
   If (bExtend)
      iDurationSeconds = (iDurationSeconds / 2)
   EndIf
   Return ((iDurationSeconds / _fMcmPollTime) As Int)
EndFunction

Int Function StartPunishmentFurniture(Actor aMaster, ObjectReference oFurnitureNearby=None)
   ; If we can't find any nearby furniture or star the scene return a failure.
   If (!oFurnitureNearby)
      oFurnitureNearby = FindFurniture()
   EndIf

   If (!oFurnitureNearby && _qFramework.SceneStarting(S_MOD + "_MoveToFurniture", 300))
      Return FAIL
   EndIf

   _oPunishmentFurniture = oFurnitureNearby
   _fFurnitureReleaseTime = 0

   ; If the leash holder is not in the furniture's location move there first.
   Location oFurnitureLocation = _oPunishmentFurniture.GetCurrentLocation()
   If (oFurnitureLocation != aMaster.GetCurrentLocation())
      _qFramework.MoveToLocation(aMaster, oFurnitureLocation, S_MOD + "_Furniture")
   Else
      _qFramework.MoveToObject(aMaster, _oPunishmentFurniture, S_MOD + "_Furniture")
   EndIf
   Return SUCCESS
EndFunction

Function FavouriteCurrentFurniture()
   ObjectReference oCurrFurniture = _qFramework.GetBdsmFurniture()
   If (!oCurrFurniture || (0 <= _aoFavouriteFurniture.Find(oCurrFurniture)))
      ; Ignore the request if the player is not in BDSM furniture or it is already favourited.
      Return
   EndIf

   ; If the Location doesn't exist most likely we are in the wilderness.  If the Region is
   ; valid it means we are close enough for it to be counted so treat that as the location.
   Location oLocation = _qFramework.GetCurrentLocation()
   Location oRegion = _qFramework.GetCurrentRegion()
   If (!oLocation)
      oLocation = oRegion
   EndIf

   _aoFavouriteFurniture = _qDfwUtil.AddFormToArray(_aoFavouriteFurniture, oCurrFurniture)
   _aoFavouriteCell = _qDfwUtil.AddFormToArray(_aoFavouriteCell, oCurrFurniture.GetParentCell())
   _aoFavouriteLocation = _qDfwUtil.AddFormToArray(_aoFavouriteLocation, oLocation)
   _aoFavouriteRegion = _qDfwUtil.AddFormToArray(_aoFavouriteRegion, oRegion)
EndFunction

Form[] Function GetFavouriteFurniture()
   Return _aoFavouriteFurniture
EndFunction

Form[] Function GetFavouriteCell()
   Return _aoFavouriteCell
EndFunction

Form[] Function GetFavouriteLocation()
   Return _aoFavouriteLocation
EndFunction

Form[] Function GetFavouriteRegion()
   Return _aoFavouriteRegion
EndFunction

Function RemoveFavourite(Int iIndex)
   _aoFavouriteFurniture = _qDfwUtil.RemoveFormFromArray(_aoFavouriteFurniture, None, iIndex)
   _aoFavouriteCell      = _qDfwUtil.RemoveFormFromArray(_aoFavouriteCell,      None, iIndex)
   _aoFavouriteLocation  = _qDfwUtil.RemoveFormFromArray(_aoFavouriteLocation,  None, iIndex)
   _aoFavouriteRegion    = _qDfwUtil.RemoveFormFromArray(_aoFavouriteRegion,    None, iIndex)
EndFunction


;***********************************************************************************************
;***                                   PUBLIC FUNCTIONS                                      ***
;***********************************************************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Basic API Documentation:
; (Mostly used by the MCM menu).
; String GetModVersion()
;  Float GetLastUpdateTime()
;   Bool IsGameOn()
;    Int StartLeashGame(Actor aActor)
;

String Function GetModVersion()
   Return "2.06"
EndFunction

Float Function GetLastUpdateTime()
   Return _fLastUpdatePoll
EndFunction

Bool Function IsGameOn()
   Return _iLeashGameDuration
EndFunction

Int Function StartLeashGame(Actor aActor)
   ; Figure out how long the leash game will be played for.
   Int iDurationSeconds = GetLeashGameDuration()

   ; For now set the player as the "cause" of the leash holder's behaviour.  This may fix the
   ; problem of everyone attacking the leash holder when the player attacks him.
   aActor.SetActorCause(_aPlayer)

   If (SUCCESS <= _qFramework.SetMaster(aActor, S_MOD, _qFramework.AP_DRESSING_ALONE, \
                                        _qFramework.MD_CLOSE))
      ; Stop deviously helpless assaults if configured.
      If (_qMcm.bBlockHelpless)
         SendModEvent("dhlp-Suspend")
      EndIf

      ; Adjust the duration based on the length of a poll.
      _iLeashGameDuration = ((iDurationSeconds / _fMcmPollTime) As Int)

      ; Establish an initial disposition for the leash holder.
      Int iCurrAnger = _qFramework.GetActorAnger(aActor, 10, 70, True, 3)
      _qFramework.GetActorDominance(aActor, 40, 85, True)

      ; If sex is allowed, make sure it is registered with the framework mod.
      If (_qMcm.bAllowSex)
         _qFramework.AddPermission(aActor, _qFramework.AP_SEX)
      EndIf

      ; If the slaver is already angry with the player start with enslave allowed.
      _bIsEnslaveAllowed = False
      If (50 < iCurrAnger)
         _qFramework.AddPermission(aActor, _qFramework.AP_ENSLAVE)
         _bIsEnslaveAllowed = True
      EndIf

      _qFramework.BlockHealthRegen()
      _qFramework.DisableMagicka()
      _qFramework.SetLeashLength(_qMcm.iLeashLength)
      _qFramework.SetLeashTarget(aActor)
      _aLeashHolder = aActor

      ; If the leash holder's confidence is too low increase it to avoid problems.
      _fPreviousConfidence = _aLeashHolder.GetActorValue("Confidence")
      If (1 > _fPreviousConfidence)
         _aLeashHolder.SetActorValue("Confidence", 1.0)
      Else
         _fPreviousConfidence = -100.0
      EndIf

      _bIsLeashHolderMale = (1 != _aLeashHolder.GetActorBase().GetSex())
      _bFullyRestrained = False
      _bIsCompleteSlave = False
      _iLeashHolderGoal = 0
      _iLongTermAgenda = 2
      _iLongTermAgendaDetails = 0
      _iExpectedResponseTime = 8

      ; Make sure the leash holder is a member of a crime faction.
;DebugLog("Checking Faction: " + _aLeashHolder.GetCrimeFaction())
      If (None == _aLeashHolder.GetCrimeFaction())
;DebugLog("Adding Faction: " + _oFactionLeashTargetCrime)
         _aLeashHolder.SetCrimeFaction(_oFactionLeashTargetCrime)
      EndIf

      ; If this is not the last NPC to play the leash game reset some personalized stats.
      ObjectReference oLastAlias = _aAliasLastLeashHolder.GetReference()
      If (oLastAlias && (_aLeashHolder != (oLastAlias As Actor)))
         _oGag          = None
         _oArmRestraint = None
         _oLegRestraint = None
         _oCollar       = None
         _oBlindfold    = None

         _iBadBehaviour = 0
         _aoItemStolen = None
         _bPlayerUngagged = False
         _iGagRemaining = 0
         _iBlindfoldRemaining = 0
         _bReleaseBlindfold = False

         ; Identify any BDSM items the NPC will want to use during the leash game.
         SearchInventory(_aLeashHolder)
         _bFindItems = True
      EndIf

      _bReequipWeapons = False
      _aAliasLastLeashHolder.Clear()
      _aAliasLeashHolder.ForceRefTo(_aLeashHolder)
      Return SUCCESS
   EndIf
   Return FAIL
EndFunction

