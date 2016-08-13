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
; History:
; 1.0 2016-06-10 by legume
; Initial version.
;***********************************************************************************************

Import StringUtil

;***********************************************************************************************
;***                                      CONSTANTS                                          ***
;***********************************************************************************************
String S_MOD = "DFWS"

; Standard status constants.
Int FAIL    = -1
Int SUCCESS = 0
Int WARNING = 1

; Debug Level (DL_) constants.
Int DL_NONE   = 0
Int DL_CRIT   = 1   ; Critical messages
Int DL_ERROR  = 2   ; Error messages
Int DL_INFO   = 3   ; Information messages
Int DL_DEBUG  = 4   ; Debug messages
Int DL_TRACE  = 5   ; Trace of everything that is happenning


;***********************************************************************************************
;***                                      VARIABLES                                          ***
;***********************************************************************************************
; A local variable to store a reference to the player for faster access.
Actor _aPlayer

; Version control for this script.
; Note: This is versioning control for the script.  It is unrelated to the mod version.
Float _fCurrVer = 0.00

; A reference to the MCM quest script.
dfwsMcm _qMcm

; A reference to the main framework quest script.
dfwDeviousFramework _qFramework

; A reference to the Devious Framework Util quest script.
dfwUtil _qDfwUtil

; A reference to the ZAZ Animation Pack (ZBF) slave control APIs.
zbfSlaveControl _qZbfSlave
zbfSlaveActions _qZbfSlaveActions

; A reference to the Devious Devices quest, Zadlibs.
Zadlibs _qZadLibs

; Lists of different restraints to use.  At least for now, Gags and Arm Restraints come from
; Devious Devices.
Armor[] _aoGags
Armor[] _aoArmRestraints
Armor[] _aoLegRestraints
Armor[] _aoCollars
Form[] _aoFavouriteFurniture
Form[] _aoFavouriteCell

; Quest Alias References.
; TODO: These could probably be script variables filled using GetAlias(iAliasId).
ReferenceAlias Property _aAliasLeashHolder     Auto
ReferenceAlias Property _aAliasLastLeashHolder Auto

; This is the short term goal of the leash holder.  What he is trying to accomplish via dialogue
; or his own actions.
; <0 = Delay after last goal.    0 = No goal.              1 = Diarm player.
;  2 = Undress player (armour).  3 = Take player weapons.  4 = Lock player's hands.
;  5 = Undress player fully.     6 = Gag player.           7 = Walk behind the slaver.
;  8 = Restrain the player.
Int Property _iLeashHolderGoal Auto Conditional

;----------------------------------------------------------------------------------------------
; Conditional state variables related to the leash game used by the quest dialogues.
Int  Property _iLeashHolderAnger      Auto Conditional
Bool Property _bIsPlayerGagged        Auto Conditional
Bool Property _bIsPlayerArmLocked     Auto Conditional

; The number of polls (give or take) the player has refused to cooperate with the current goal.
Int  Property _iLeashGoalRefusalCount Auto Conditional

; 0 = No weapons stolen.  1 = Equipped weapons stolen.  2 = All weapons stolen.
Int  Property _iWeaponsStolen         Auto Conditional
;----------

;----------------------------------------------------------------------------------------------
; Internal state variables about the leash holder.
Actor _aLeashHolder

; Has the player re-equipped her weapons after they were put away.
Bool _bReequipWeapons

; Is the leash holder upset enough to allow the player to be enslaved.
Bool _bIsEnslaveAllowed

; Is the leash holder in combat.
Bool _bIsInCombat

; Is the leash holder attempting to engage the player in one of our dialogues.
Int _iDialogueBusy

; Keep track of how long one of our scenes has been busy for.
Int _iSceneBusy

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

; A list of all items stolen from the player.
Form[] _oItemStolen

; A set of equipment we locked on the slave.
Armor _oGag
Armor _oArmRestraint
Armor _oLegRestraint
Armor _oCollar

; Keeps track of actions that should be taken during an assault:
; 0x0001 = Strip
; 0x0002 = Gag
; 0x0004 = Bind Arms
; 0x0008 = Take All Weapons
; 0x0010 = Return All Items
; 0x0020 = Unbind Arms
; 0x0040 = Strip Fully
; 0x0080 = Add Additional Restraint
; 0x0100 = UnGag
; 0x0200 = Restrain in Collar
; 0x8000 = Peaceful (the player is co-operating)
Int _iAssault

; Keeps track of when the last update poll was.
; This can be used to detect when the game has been loaded as the current real time is reset.
Float _fLastUpdatePoll

; Keep a count of how many polls since the game has been loaded.
; Some things cannot be initialized on game load so they must be initialized a certain number of
; poll loops after the game is loaded.  E.g. registration for the DFW_NewMaster event.
Int _iPollsSinceLoad

; Keeps track of whether the leash game is in effect and how long it will continue for.
Int _iLeashGameDuration
Int _iLeashGameCooldown

; Keep track of which BDSM furniture the player is sitting in when we begin messing with her.
ObjectReference _oBdsmFurniture

; A timer for keeping the player locked in BDSM furniture for a little while.
Float _fFurnitureReleaseTime

; The NPC who has locked the player in BDSM furniture.
Actor _aFurnitureLocker

; A variable to keep track of whether we think the player is enslaved by SD+.
Bool _bEnslavedSdPlus

; A reference to the SD+ mod's "_SD_state_caged" global variable.
GlobalVariable _gSdPlusStateCaged
Bool _bCagedSdPlus

; A variable to keep track of whether we have blocked fast travel.
Bool _bFastTravelBlocked


;***********************************************************************************************
;***                                    INITIALIZATION                                       ***
;***********************************************************************************************
; This is called once by the MCM script to initialize the mod and then on each update poll.
; This function is primarily to ensure new variables are initialized for new script versions.
Function UpdateScript()
   ; Reset the version number.
   ; _fCurrVer = 0.00

   ; Very basic initialization.
   ; Make sure this is done before logging so the MCM options are available.
   If (0.01 > _fCurrVer)
      _aPlayer = Game.GetPlayer()
      _qMcm = (Self As Quest) As dfwsMcm
      _qFramework = Quest.GetQuest("_dfwDeviousFramework") As dfwDeviousFramework
      _qDfwUtil = Quest.GetQuest("_dfwDeviousFramework") As dfwUtil
      _qZbfSlave = zbfSlaveControl.GetApi()
      _qZbfSlaveActions = zbfSlaveActions.GetApi()
   EndIf

   ; Always register for updates.  We want to make sure the periodic function is polling.
   If (_qMcm.fPollTime)
      RegisterForUpdate(_qMcm.fPollTime)
   EndIf

   ; If the script is at the current version we are done.
   ; Note: On updating the version number remember to update the OnUpdate() event too!
   Float fScriptVer = 0.03
   If (fScriptVer == _fCurrVer)
      Return
   EndIf
   Log("Updating Script " + _fCurrVer + " => " + fScriptVer, DL_CRIT, S_MOD)

   If (0.02 > _fCurrVer)
      _qZadLibs = Quest.GetQuest("zadQuest") As Zadlibs
      CreateRestraintsArrays()
   EndIf

   If (0.03 > _fCurrVer)
      _gSdPlusStateCaged = (Game.GetFormFromFile(0x000D1E79, "sanguinesDebauchery.esp") as GlobalVariable)  ;;; _SD_state_caged
   EndIf

   ; Finally update the version number.
   _fCurrVer = fScriptVer
EndFunction


;***********************************************************************************************
;***                                        EVENTS                                           ***
;***********************************************************************************************
Event OnUpdate()
   Float fCurrRealTime = Utility.GetCurrentRealTime()

   ; Game Loaded: If the current real time is low (has been reset) that indicates the game has
   ; just been loaded.  Do some processing at the beginning of the loaded game.
   If (_fLastUpdatePoll > fCurrRealTime)
      ; The game has been loaded.  Perform necessary actions here.
      _iPollsSinceLoad = 0
      UpdateScript()
   ElseIf (10 >= _iPollsSinceLoad)
      _iPollsSinceLoad += 1
      If (5 >= _iPollsSinceLoad)
         ;Log("Registering for events.", DL_TRACE, S_MOD)

         ; It seems registering for some events on game load doesn't take effect 100% of the
         ; time.  To account for this register for the events for all of the first few polls.
         UnregisterForAllModEvents()
         If (_qMcm.bCatchZazEvents)
            RegisterForModEvent("zbfSC_EnslaveActor", "ActorEnslaved")
            RegisterForModEvent("zbfSC_FreeSlave", "ActorFreed")
            RegisterForModEvent("zbfSC_ReleaseSlave", "ActorFreed")
         EndIf
         RegisterForModEvent("DFW_NewMaster", "DfwNewMaster")
         RegisterForModEvent("ZapSlaveActionDone", "OnSlaveActionDone")
         RegisterForModEvent("SDEnslavedStart", "EventSdPlusStart")
         RegisterForModEvent("SDEnslavedStop", "EventSdPlusStop")
      EndIf

      ; Near the start of each game load suspend deviously helpless assaults if needed.
      ; This is done here since the suspension is cleared on each load game.
      If ((5 == _iPollsSinceLoad) && _iLeashGameDuration && _qMcm.bBlockHelpless)
         SendModEvent("dhlp-Suspend")
      EndIf
   EndIf
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
      If (_qMcm.iBlockTravel > iVulnerability)
         _qFramework.RestoreFastTravel()
         _bFastTravelBlocked = True
      EndIf
   ElseIF (_qMcm.iBlockTravel <= iVulnerability)
      ; If fast travel is allowed but the player is vulnerable block it.
      _qFramework.BlockFastTravel()
      _bFastTravelBlocked = False
   EndIf

   ; Check if the player is enslaved by Sanguine's Debauchery (SD+).
   If (_qMcm.bCatchSdPlus && _bEnslavedSdPlus)
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
   ElseIf (_qMcm.bCatchSdPlus)
      If (0 < StorageUtil.GetIntValue(_aPlayer, "_SD_iEnslaved"))
         StartSdPlus()
      EndIf
   EndIf

   If (_aLeashHolder)
      ; Manage all the behaveiour of the leash game.
      PlayLeashGame()
   ElseIf (_iLeashGameCooldown)
      ; If the leash game is in cool down, deccrement the variable and don't consider playing.
      _iLeashGameCooldown -= 1
      If (0 > _iLeashGameCooldown)
         _iLeashGameCooldown = 0
      EndIf
   ElseIf (_qMcm.fLeashGameChance || _qMcm.iIncreaseWhenVulnerable)
      ; If the mod's leash game is enabled check if we should start the game.
      CheckStartLeashGame(iVulnerability)
   EndIf

   ObjectReference oCurrFurniture = _qFramework.GetBdsmFurniture()
   If (_oBdsmFurniture && !oCurrFurniture && !_qFramework.IsBdsmFurnitureLocked())
      ; We think the player is locked in BDSM furniture but she isn't.
      _aFurnitureLocker = None
      _oBdsmFurniture = None
   ElseIf (_oBdsmFurniture || oCurrFurniture)
      ; If the player is sitting in BDSM furniture, think about messing with her.

      If (_fFurnitureReleaseTime && (_fFurnitureReleaseTime < Utility.GetCurrentGameTime()))
         _fFurnitureReleaseTime = 0
         If (!_aFurnitureLocker)
            Log("You hear a click and the furniture unlocks.", DL_CRIT, S_MOD)
            _qFramework.SetBdsmFurnitureLocked(False)
            ;    EnablePlayerControls(Move,  Fight, Cam,   Look,  Sneak, Menu,  Activ, Journ)
            Game.EnablePlayerControls(True,  False, False, False, False, False, False, False)
         EndIf
      EndIf

      ; If the player is free to move and no one is messing with her think about starting to.
      If (!_aFurnitureLocker && Game.IsMovementControlsEnabled())
         ; If the player was not previously sitting in the furniture take some actions.
         If (!_oBdsmFurniture)
            ; Keep track of which furniture the player is sitting in.
            _oBdsmFurniture = oCurrFurniture

            ; Start a timer keeping the player locked for a minimum amount of time.
            If (_qMcm.iFurnitureMinLockTime)
               Log("The furniture automatically locks you in.", DL_CRIT, S_MOD)
               _fFurnitureReleaseTime = Utility.GetCurrentGameTime() + \
                                        ((_qMcm.iFurnitureMinLockTime As Float) / 1440.0)
               _qFramework.SetBdsmFurnitureLocked()
               ;    DisablePlayerControls(Move,  Fight, Cam,   Look,  Sneak, Menu,  Active, Journ)
               Game.DisablePlayerControls(True,  False, False, False, False, False, False,  False)
            EndIf
         EndIf

         If (_qMcm.fFurnitureLockChance > Utility.RandomFloat(0, 100))
            ; Find someone nearby to lock the player in the device.
            Actor aNearby = _qFramework.GetRandomActor(iIncludeFlags=_qFramework.AF_DOMINANT)
            If (aNearby && !_qFramework.SceneStarting(S_MOD, 60))
               _qFramework.SetBdsmFurnitureLocked()
               ;    DisablePlayerControls(Move,  Fight, Cam,   Look,  Sneak, Menu,  Active, Journ)
               Game.DisablePlayerControls(True,  False, False, False, False, False, False,  False)
               ImmobilizePlayer()
               _aFurnitureLocker = aNearby
               _qZbfSlaveActions.RestrainInDevice(None, aNearby, S_MOD + "_Lock")
            EndIf
         EndIf
      ; If the player is locked and we know who is messing with her think about freeing her.
      ElseIf (!Game.IsMovementControlsEnabled() && _aFurnitureLocker)
         Actor aHelper = _aFurnitureLocker
         Float fChance = _qMcm.fFurnitureReleaseChance
         ; If the locker is not nearby see if there is someone else who will help.
         If (!_qFramework.IsActorNearby(_aFurnitureLocker))
            aHelper = _qFramework.GetRandomActor(iIncludeFlags=_qFramework.AF_DOMINANT)
            fChance = fChance * _qMcm.iFurnitureAltRelease / 100
            If (!aHelper)
               fChance = 0
            EndIf
         EndIf
         If ((fChance > Utility.RandomFloat(0, 100)) && !_qFramework.SceneStarting(S_MOD, 60))
            ImmobilizePlayer()
            _qZbfSlaveActions.RestrainInDevice(None, aHelper, S_MOD + "_Unlock")
         EndIf
      EndIf
   EndIf
EndEvent

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
   If (_aFurnitureLocker)
      _aFurnitureLocker = None
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
   If (S_MOD != Substring(szMessage, 0, 4))
      Return
   EndIf

   Actor aMaster = (oMaster As Actor)
   String szName = aMaster.GetDisplayName()

   If (S_MOD + "_Assault" == szMessage)
      FinalizeAssault(szName)
      _qFramework.SceneDone(S_MOD)
   ElseIf (S_MOD + "_Lock" == szMessage)
      Log(szName + " quietly locks the device you are in.", DL_CRIT, S_MOD)

      _qZbfSlaveActions.RestrainInDevice(_oBdsmFurniture, aMaster, S_MOD)
   ElseIf ((S_MOD + "_Unlock" == szMessage) || (S_MOD + "_Release" == szMessage))
      Log(szName + " starts unlocking you from your device.", DL_CRIT, S_MOD)

      If ((S_MOD + "_Unlock" == szMessage) && \
          (_qMcm.iFurnitureTeaseChance >= Utility.RandomFloat(0, 100)))
         ; The NPC was just teasing the player and really keeps her locked up.
         _qZbfSlaveActions.RestrainInDevice(_oBdsmFurniture, aMaster, S_MOD + "_Teased")
      Else
         If (0 < _iMovementSafety)
            _iMovementSafety = 0
            ReMobilizePlayer()
         EndIf
         _aFurnitureLocker = None
         _oBdsmFurniture = None
         _qFramework.SetBdsmFurnitureLocked(False)
         _qFramework.SceneDone(S_MOD)
      EndIf
   ElseIf (S_MOD + "_Teased" == szMessage)
      Log(szName + " was teasing you and keeps you locked up.", DL_CRIT, S_MOD)
      If (0 < _iMovementSafety)
         _iMovementSafety = 0
         ReMobilizePlayer()
      EndIf
      _qFramework.SceneDone(S_MOD)
   ElseIf (S_MOD + "_FurnitureAssault" == szMessage)
      FinalizeAssault(szName)
      If (_bIsCompleteSlave && (_aLeashHolder == aMaster))
         ; If the player is now a complete slave and leashed don't lock her back up.
         _qFramework.SceneDone(S_MOD)
      Else
         ; Otherwise finish the assualt by making sure she is locked into the furniture.
         _qZbfSlaveActions.RestrainInDevice(_oBdsmFurniture, aMaster, S_MOD)
         ; Set dialog to busy 1 to allow for a short delay before the next conversation.
         _iDialogueBusy = 1
      EndIf
   ElseIf (S_MOD + "_PrepBdsm" == szMessage)
      Int iIndex = _aoFavouriteCell.Find(_aPlayer.GetParentCell())
      If (-1 != iIndex)
         _qFramework.SetBdsmFurnitureLocked()
         _aFurnitureLocker = aMaster
         UnbindPlayersArms()
         ObjectReference oFurniture = (_aoFavouriteFurniture[iIndex] As ObjectReference)
         _qZbfSlaveActions.RestrainInDevice(oFurniture, aMaster, S_MOD + "_LeashToBdsm")
      Else
         _qFramework.SceneDone(S_MOD)
      EndIf
   ElseIf (S_MOD + "_LeashToBdsm" == szMessage)
      Log(szName + " locks you up and walks away.", DL_CRIT, S_MOD)
      StopLeashGame()
      _qFramework.SceneDone(S_MOD)
   ElseIf (S_MOD + "_BdsmToLeash" == szMessage)
      Log(szName + " locks your device and slips a rope around your neck.", DL_CRIT, S_MOD)
      _qZbfSlaveActions.RestrainInDevice(_oBdsmFurniture, aMaster, S_MOD)
      StartLeashGame(aMaster)
   ElseIf (S_MOD == szMessage)
      If (0 < _iMovementSafety)
         _iMovementSafety = 0
         ReMobilizePlayer()
      EndIf
      _qFramework.SceneDone(S_MOD)
   EndIf
EndEvent

Event EventSdPlusStart(String szEventName, String szArg, Float fArg = 1.0, Form oSender)
   StartSdPlus()
EndEvent

Event EventSdPlusStop(String szEventName, String szArg, Float fArg = 1.0, Form oSender)
   StopSdPlus()
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

   _aoLegRestraints = New Armor[2]
   _aoLegRestraints[00] = (Game.GetFormFromFile(0x000116FA, "Devious Devices - Expansion.esm") as Armor)  ;;; zadx_XinWTLPonyBootsInventory
   _aoLegRestraints[01] = (Game.GetFormFromFile(0x000116FE, "Devious Devices - Expansion.esm") as Armor)  ;;; zadx_XinWTEbonitePonyBootsInventory

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
EndFunction

Function StopLeashGame(Bool bClearMaster=True)
   _iLeashGameDuration = 0
   _iLeashHolderGoal = 0
   _qFramework.RestoreHealthRegen()
   _qFramework.DisableMagicka(False)
   _qFramework.SetLeashTarget(None)
   If (bClearMaster)
      _qFramework.ClearMaster(_aLeashHolder)
   EndIf
   _aAliasLastLeashHolder.ForceRefTo(_aLeashHolder)
   _aLeashHolder = None
   _aAliasLeashHolder.Clear()

   ; Stop deviously helpless assaults if configured.
   If (_qMcm.bBlockHelpless)
      SendModEvent("dhlp-Resume")
   EndIf
EndFunction

Function Log(String szMessage, Int iLevel=0, String szClass="")
   If (szClass)
      szMessage = "[" + szClass + "] " + szMessage
   EndIf

   ; Log to the papyrus file.
   If (ilevel <= _qMcm.iLogLevel)
      Debug.Trace(szMessage)
   EndIf

   ; Also log to the Notification area of the screen.
   If (ilevel <= _qMcm.iLogLevelScreen)
      Debug.Notification(szMessage)
   EndIf
EndFunction

Function UpdatePollingInterval(Float fNewInterval)
   RegisterForUpdate(fNewInterval)
EndFunction

Function ImmobilizePlayer()
   If (0 >= _iMovementSafety)
      _iMovementSafety = 20
      _fMovementAmount = (_aPlayer.GetActorValue("SpeedMult") * 0.90)
      _aPlayer.ModActorValue("SpeedMult", 0.0 - _fMovementAmount)
      _aPlayer.ModActorValue("CarryWeight", 0.1)
   EndIf
EndFunction

Function ReMobilizePlayer()
   _aPlayer.ModActorValue("SpeedMult", _fMovementAmount)
   _aPlayer.ModActorValue("CarryWeight", -0.1)
EndFunction

Function AssaultPlayer(Float fHealthThreshold=1.0, Bool bUnquipWeapons=False, \
                       Bool bStealWeapons=False,   Bool bAddGag=False, \
                       Bool bStrip=False,          Bool bAddArmBinder=False)
   ; If the player is already below the health threshold don't bother damaging her more.
   Float fDamageMultiplier = 1
   If (fHealthThreshold >= _aPlayer.GetActorValuePercentage("Health"))
      fDamageMultiplier = 0
   EndIf

   ; If we are already in the middle of an animated assault ignore this request.
   If (_qFramework.GetCurrentScene())
      Return
   EndIf

   ; Yank the leash.
   _qFramework.YankLeash(fDamageMultiplier, _qFramework.LS_DRAG)

   ; If a health threshold is specified and the player is not below it, nothing more to do.
   If (1 != fHealthThreshold)
      If (fHealthThreshold < _aPlayer.GetActorValuePercentage("Health"))
         Return
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
         _oItemStolen = _qDfwUtil.AddFormToArray(_oItemStolen, oWeaponRight)
         _oItemStolen = _qDfwUtil.AddFormToArray(_oItemStolen, oWeaponLeft)
         If (1 > _iWeaponsStolen)
            _iWeaponsStolen = 1
         EndIf
      EndIf
   EndIf

   ; Figure out whether an animated assault should actually happen.
   _iAssault = 0x0000
   If (bStrip && (_qFramework.NS_NAKED != _qFramework.GetNakedLevel()))
      _iAssault += 0x0001
   EndIf

   If (bAddGag && !_qFramework.IsPlayerGagged())
      _iAssault += 0x0002
   EndIf

   If (bAddArmBinder && !_qFramework.IsPlayerArmLocked())
      _iAssault += 0x0004
   EndIf

   ; Play an animation for the slaver to approach the player.
   ; The assault will happen on the done event (OnSlaveActionDone).
   If (_iAssault)
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

Function UnbindPlayersArms()
   ; Unequip the player's arm restraints.
   If (!_oArmRestraint)
      _oArmRestraint = _qZadLibs.GetWornDevice(_aPlayer, _qZadLibs.zad_DeviousArmbinder)
   EndIf
   If (!_oArmRestraint)
      _oArmRestraint = _qZadLibs.GetWornDevice(_aPlayer, _qZadLibs.zad_DeviousYoke)
   EndIf
   If (!_oArmRestraint)
      _oArmRestraint = _qZadLibs.GetWornDevice(_aPlayer, _qZadLibs.zad_DeviousGloves)
   EndIf
   If (_oArmRestraint)
      Armor oArmRestraintRendered = _qZadLibs.GetRenderedDevice(_oArmRestraint)
      _qZadLibs.RemoveDevice(_aPlayer, _oArmRestraint, oArmRestraintRendered, \
                             _qZadLibs.zad_DeviousArmbinder)
   EndIf
EndFunction

Function FinalizeAssault(String szName)
   ; All assault values must be checked in descending order (highest numbers first).
   ; These flags can be used to control performing one action before another.
   Bool bUnlockArms
   Bool bReturnItems

   ; Keep track of whether this is a peaceful or forceful assault.
   Bool bPeaceful
   If (0x8000 <= _iAssault)
      bPeaceful = True
      _iAssault -= 0x8000
   EndIf

   ; 0x0200 = Restrain in Collar
   If (0x0200 <= _iAssault)
      If (!_oCollar)
         _oCollar = _aoCollars[Utility.RandomInt(0, _aoCollars.Length - 1)]
      EndIf
      Armor oRestraintRendered = _qZadLibs.GetRenderedDevice(_oCollar)
      _qZadLibs.EquipDevice(_aPlayer, _oCollar, oRestraintRendered, _qZadLibs.zad_DeviousCollar)

      _iAssault -= 0x0200
   EndIf

   ; 0x0100 = UnGag
   If (0x0100 <= _iAssault)
      ; Unequip the player's gag.
      If (!_oGag)
         _oGag = _qZadLibs.GetWornDevice(_aPlayer, _qZadLibs.zad_DeviousGag)
      EndIf
      If (_oGag)
         Armor oGagRendered = _qZadLibs.GetRenderedDevice(_oGag)
         _qZadLibs.RemoveDevice(_aPlayer, _oGag, oGagRendered, _qZadLibs.zad_DeviousGag)
      EndIf
      _bPlayerUngagged = True

      _iAssault -= 0x0100
   EndIf

   ; 0x0080 = Add Additional Restraint
   If (0x0080 <= _iAssault)
      ; Create a list of items that can be added so we can randomize which one is added.
      Int[] aiOptions
      If (!_qFramework.IsPlayerGagged())
         aiOptions = _qDfwUtil.AddIntToArray(aiOptions, 1)
      EndIf
      If (!_qFramework.IsPlayerArmLocked())
         aiOptions = _qDfwUtil.AddIntToArray(aiOptions, 2)
      EndIf
      If (!_qFramework.IsPlayerHobbled())
         aiOptions = _qDfwUtil.AddIntToArray(aiOptions, 3)
      EndIf
      If (!_qFramework.IsPlayerCollared())
         aiOptions = _qDfwUtil.AddIntToArray(aiOptions, 4)
      EndIf

      ; Choose one of the available optionis randomly.
      If (aiOptions.Length)
         Int iOption = aiOptions[Utility.RandomInt(0, aiOptions.Length - 1)]
         Armor oRestraint
         Keyword oKeyword
         If (1 == iOption)
            If (!_oGag)
               _oGag = _aoGags[Utility.RandomInt(0, _aoGags.Length - 1)]
            EndIf
            oRestraint = _oGag
            oKeyword = _qZadLibs.zad_DeviousGag
            _bIsPlayerGagged = True
            _bPlayerUngagged = False
         ElseIf (2 == iOption)
            If (!_oArmRestraint)
               Int iIndex = Utility.RandomInt(0, _aoArmRestraints.Length - 1)
               _oArmRestraint = _aoArmRestraints[iIndex]
            EndIf
            oRestraint = _oArmRestraint
            oKeyword = _qZadLibs.zad_DeviousArmbinder
         ElseIf (3 == iOption)
            If (!_oLegRestraint)
               Int iIndex = Utility.RandomInt(0, _aoLegRestraints.Length - 1)
               _oLegRestraint = _aoLegRestraints[iIndex]
            EndIf
            oRestraint = _oLegRestraint
            oKeyword = _qZadLibs.zad_DeviousBoots
         ElseIf (4 == iOption)
            If (!_oCollar)
               _oCollar = _aoCollars[Utility.RandomInt(0, _aoCollars.Length - 1)]
            EndIf
            oRestraint = _oCollar
            oKeyword = _qZadLibs.zad_DeviousCollar
         EndIf

         If (oRestraint)
            Armor oRestraintRendered = _qZadLibs.GetRenderedDevice(oRestraint)
            _qZadLibs.EquipDevice(_aPlayer, oRestraint, oRestraintRendered, oKeyword)
         EndIf
         CheckPlayerFullyBound()
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
            _aPlayer.RemoveItem(oInventoryItem, 999, akOtherContainer=_aLeashHolder)
            _oItemStolen = _qDfwUtil.AddFormToArray(_oItemStolen, oInventoryItem)
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

         If (!_oArmRestraint)
            Int iIndex = Utility.RandomInt(0, _aoArmRestraints.Length - 1)
            _oArmRestraint = _aoArmRestraints[iIndex]
         EndIf

         ; Unequip the player's gloves/forearms as they interact oddly with arm binders.
         _aPlayer.UnequipItemSlot(33) ; 0x00000008
         _aPlayer.UnequipItemSlot(34) ; 0x00000010

         Armor oArmRestraintRendered = _qZadLibs.GetRenderedDevice(_oArmRestraint)
         _qZadLibs.EquipDevice(_aPlayer, _oArmRestraint, oArmRestraintRendered, \
                               _qZadLibs.zad_DeviousArmbinder)
      EndIf
      _iAssault -= 0x0004
   EndIf

   ; 0x0002 = Gag
   If (0x0002 <= _iAssault)
      If (!_qFramework.IsPlayerGagged())
         If (bPeaceful)
            Log(szName + " slips a gag into your mouth and locks it in place.", DL_CRIT, S_MOD)
         Else
            Log(szName + " pulls you to the ground and forces a gag into your mouth.", \
                DL_CRIT, S_MOD)
         EndIf

         If (!_oGag)
            _oGag = _aoGags[Utility.RandomInt(0, _aoGags.Length - 1)]
         EndIf

         Armor oGagRendered = _qZadLibs.GetRenderedDevice(_oGag)
         _qZadLibs.EquipDevice(_aPlayer, _oGag, oGagRendered, _qZadLibs.zad_DeviousGag)
         _bIsPlayerGagged = True
         _bPlayerUngagged = False
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
      Log(aLastLeashHolder.GetDisplayName() + " locks up your arms and returns your things.", \
          DL_CRIT, S_MOD)
      Int iIndex = _oItemStolen.Length - 1
      While (0 <= iIndex)
         aLastLeashHolder.RemoveItem(_oItemStolen[iIndex], 999, akOtherContainer=_aPlayer)
         iIndex -=1
      EndWhile
      _oItemStolen = None
      _iWeaponsStolen = 0
   EndIf

   If (bUnlockArms)
      UnbindPlayersArms()
      _bFullyRestrained = False
      _bIsCompleteSlave = False
   EndIf
EndFunction

Function StartConversation(Actor aActor, Int iGoal=-1, Int iRefusalCount=-1)
   ; Teleport the leash holder to interrupt his current package.  For normal
   ; conversations the package is interrupted when the player clicks on (activates)
   ; the actor.  Activating the actor via the Activate() function seems to be
   ; different so we need to interrupt the package manually.
;   aActor.MoveTo(aActor)

   ; Activating the actor causes dialog problems.
   ; Make sure there is no conversation.
   ; This also resets the player's camera so let's not use it unless it is necessary.
   ;_aPlayer.MoveTo(_aPlayer)

   ; Setup the conversation topic variable used by the player dialogue.
   If (-1 != iGoal)
      _iLeashHolderGoal = iGoal
      ; If this is a new conversation we should set the refusal count.
      If (-1 == iRefusalCount)
         _iLeashGoalRefusalCount = 0
      EndIf
   EndIf

   ; If the refusal count is specified set it here.
   If (-1 != iRefusalCount)
      _iLeashGoalRefusalCount = iRefusalCount
   EndIf

   ; Update some conditional variables that may be needed by the dialog.
   _bIsPlayerGagged = _qFramework.IsPlayerGagged()
   _bIsPlayerArmLocked = _qFramework.IsPlayerArmLocked()
   _iLeashHolderAnger = _qFramework.GetActorAnger(_aLeashHolder)
   If (7 == _iLeashHolderGoal)
      _iLeashGoalRefusalCount = _iTotalWalkInFrontCount
   EndIf

   ; Wait for any leash yanking to complete before starting the conversation.
   _qFramework.YankLeashWait(500)

   ; Set a timeout to abandon the conversation in case it doesn't happen.
   _iDialogueBusy = 20
   If ((3 == iGoal) || (5 == iGoal) || (7 == iGoal) || (8 == iGoal))
      ; For One Liners (comments the player can't respond to) set a shorter timeout.
      _iDialogueBusy = 3
   EndIf

   ; Have the leash holder speak with the player about her weapons.
   aActor.Activate(_aPlayer)
EndFunction

Function CheckStartLeashGame(Int iVulnerability)
   ; Only play the leash game if the player does not have a current close Master.
   If (!_qFramework.GetMaster(_qFramework.MD_CLOSE) && \
       _qFramework.IsAllowed(_qFramework.AP_ENSLAVE) && \
       !_qFramework.IsPlayerCriticallyBusy())
      Float fMaxChance = _qMcm.fLeashGameChance
      If (_qMcm.iIncreaseWhenVulnerable)
         fMaxChance += ((_qMcm.iIncreaseWhenVulnerable As Float) * iVulnerability / 100)
      EndIf
      If (Utility.RandomFloat(0, 100) < fMaxChance)
         ; Find an actor to use as the Master in the leash game.
         Int iActorFlags = _qFramework.AF_SLAVE_TRADER
         If (_qMcm.bIncludeOwners)
            iActorFlags = Math.LogicalOr(_qFramework.AF_OWNER, iActorFlags)
         EndIf
         Actor aRandomActor = _qFramework.GetRandomActor(1000, iActorFlags)

         If (aRandomActor)
            Log(aRandomActor.GetDisplayName() + " lassos a rope around your neck.", \
                DL_CRIT, S_MOD)

            ; If the player is in BDSM furniture but not locked.  Lock it first.
            If (_qFramework.GetBdsmFurniture() && !_aFurnitureLocker)
               _qFramework.SetBdsmFurnitureLocked()
               ;    DisablePlayerControls(Move,  Fight, Cam,   Look,  Sneak, Menu,  Active, Journ)
               Game.DisablePlayerControls(True,  False, False, False, False, False, False,  False)
               ImmobilizePlayer()
               _aFurnitureLocker = aRandomActor
               _qZbfSlaveActions.RestrainInDevice(None, aRandomActor, S_MOD + "_BdsmToLeash")
            Else
               ; Start the game.
               StartLeashGame(aRandomActor)
            EndIf
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
         _bIsInCombat = True
         _qFramework.SetLeashLength(_qMcm.iLeashLength * 3)
      ElseIf (!_aLeashHolder.IsInCombat())
         _bIsInCombat = False
         _qFramework.SetLeashLength(_qMcm.iLeashLength)
      EndIf
      Return
   EndIf

   _iLeashGameDuration -= 1

   ; Don't do processing during an assault or one of our dialogues.
   If (0 < _iDialogueBusy)
      ;Log("In Dialogue.", DL_TRACE, S_MOD)
      _iDialogueBusy -= 1
      Return
   EndIf

   ; Don't do processing during an assault or one of our scenes.
   If (S_MOD == _qFramework.GetCurrentScene())
      ;Log("PlayLeashGame: In Scene.", DL_TRACE, S_MOD)

      ; Every so often yank the player's leash in case she is trying to run away.
;      _iSceneBusy += 1
;      If (!(_iSceneBusy % 5))
;         _qFramework.YankLeash(0)
;      EndIf
      Return
   EndIf
   _iSceneBusy = 0

   ; If the leash game is ending check that the slaver is willing to release the player.
   If (0 >= _iLeashGameDuration)
      ;Log("Leash Game Ending.", DL_TRACE, S_MOD)

      ; The slaver will only release the player if he is not particularly anger with her.
      If (_qMcm.iMaxAngerForRelease >= _qFramework.GetActorAnger(_aLeashHolder))
         Int iChance = _qMcm.iChanceOfRelease
         Int iDominance = _qFramework.GetActorDominance(_aLeashHolder)
         iChance -= (((iDominance - 50) * _qMcm.iDominanceAffectsRelease) / 50)
         If (iChance >= Utility.RandomFloat(0, 100))
            ; The leash game has ended.  The player will be set free.
            Log(_aLeashHolder.GetDisplayName() + " unties your leash and lets you go.", \
                DL_CRIT, S_MOD)
            StopLeashGame()
            Return
         EndIf
      EndIf

      ; The leash game has been extended for some reason.  Reset the duration.
      _iLeashGameDuration = GetLeashGameDuration(True)
   EndIf

   ; Next handle cases of the player being locked in BDSM furniture.
   If (oCurrFurniture)
      If (!_qFramework.IsPlayerGagged())
         _iAssault = 0x8000 + 0x0002
         ; Goal 8: Restrain the player.
         StartConversation(_aLeashHolder, 8)
      ElseIf (2 > _iWeaponsStolen)
         ; Goal 3: Take the player's weapons.
         StartConversation(_aLeashHolder, 3)
      ElseIf (_qFramework.GetNakedLevel())
         ; Goal 5: Strip the player fully.
         StartConversation(_aLeashHolder, 5)
      ElseIf (!_qFramework.IsPlayerCollared())
         _iAssault = 0x8000 + 0x0200
         ; Goal 8: Restrain the player.
         StartConversation(_aLeashHolder, 8)
      ElseIf (!_qFramework.IsPlayerArmLocked())
         _iAssault = 0x8000 + 0x0004
         ; Goal 8: Restrain the player.
         StartConversation(_aLeashHolder, 8)
      Else
         ; The player is all bound up (save collar and boots).  Release her from the furniture.
         _qZbfSlaveActions.RestrainInDevice(None, _aLeashHolder, S_MOD + "_Release")
      EndIf
      Return
   EndIf

   ; Next handle cases of the player acting aggressive toward the slaver.
   If (_aPlayer.IsWeaponDrawn() && _bReequipWeapons && _qFramework.GetWeaponLevel())
      ;Log("Player Agressive.", DL_TRACE, S_MOD)

      ; The player has re-equipped her weapons and drawn them.
      ; The leash holder should be alarmed at this.
      iAnger = _qFramework.IncActorAnger(_aLeashHolder, _iLeashGoalRefusalCount, 0, 100)

      If (65 < iAnger)
         ; The leash holder is fed up, yank the player's leash.
         AssaultPlayer(0.3, bStealWeapons=True)
      Else
         ; If we were trying to strip the player take back assisted dressing.
         If (2 == _iLeashHolderGoal)
            _qFramework.RemovePermission(_aLeashHolder, _qFramework.AP_DRESSING_ASSISTED)
         EndIf

         ; Identify with the dialog system the leash holder wants to disarm the player.
         If (3 > _iLeashGoalRefusalCount)
            _iLeashGoalRefusalCount = 3
         EndIf

         StartConversation(_aLeashHolder, 1)
      EndIf
      Return
   EndIf

   ; Goal 1: The slaver is trying to disarm the player.
   If (1 == _iLeashHolderGoal)
      ;Log("Goal 1: Disarm the player.", DL_TRACE, S_MOD)

      ; If the player has put away her weapons.  Relax a little.
      If (!_qFramework.GetWeaponLevel())
         _iLeashHolderGoal = -2
         _qFramework.IncActorAnger(_aLeashHolder, -3, 25, 100)
         ; If the player has weapons equipped again it's because she re-equipped them.
         _bReequipWeapons = True
         Return
      EndIf

      ; Increase the leash holder's annoyance at the player having her weapons out.
      _iLeashGoalRefusalCount += 1
      iAnger = _qFramework.IncActorAnger(_aLeashHolder, _iLeashGoalRefusalCount / 2, 0, 100)

      ; If the actor is overly annoyed yank the player's leash.
      If (65 < iAnger)
         AssaultPlayer(0.3, bStealWeapons=True)
      ElseIf ((50 < iAnger) && _aPlayer.IsWeaponDrawn())
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
         _qFramework.IncActorAnger(_aLeashHolder, -3, 25, 100)
         Return
      EndIf

      ; Increase the leash holder's annoyance at the player's not having undressed yet.
      _iLeashGoalRefusalCount += 1
      iAnger = _qFramework.IncActorAnger(_aLeashHolder, _iLeashGoalRefusalCount / 5, 0, 80)

      ; If the actor is overly annoyed yank the player's leash.
      If (65 < iAnger)
         _qFramework.RemovePermission(_aLeashHolder, _qFramework.AP_DRESSING_ASSISTED)
         AssaultPlayer(0.3, bStrip=True, bAddArmBinder=True)
      ElseIf (!(_iLeashGoalRefusalCount % 5))
         ; Otherwise just talk to the player about her behaviour.
         StartConversation(_aLeashHolder)
      EndIf
      Return
   EndIf

   ; Goal 4: The slaver is trying to equip an arm binder on the player.
   If (4 == _iLeashHolderGoal)
      ;Log("Goal 4: Restrain the player's arms.", DL_TRACE, S_MOD)

      ; If the player has put on the restraint.  Relax a little.
      If (_qFramework.IsPlayerArmLocked())
         _iLeashHolderGoal = -2
         _qFramework.IncActorAnger(_aLeashHolder, -3, 25, 100)
         Return
      EndIf

      ; Increase the leash holder's annoyance at the player's not having complied yet.
      _iLeashGoalRefusalCount += 1
      iAnger = _qFramework.IncActorAnger(_aLeashHolder, _iLeashGoalRefusalCount / 2, 0, 80)

      ; If the actor is overly annoyed yank the player's leash.
      If (65 < iAnger)
         AssaultPlayer(0.3, bAddGag=True, bStrip=False, bAddArmBinder=True)
      ElseIf (!(_iLeashGoalRefusalCount % 5))
         ; Otherwise just talk to the player about her behaviour.
         StartConversation(_aLeashHolder)
      EndIf
      Return
   EndIf

   ; Otherwise Goal <= 0: The slaver doesn't have any particular intentions right now.
   ;Log("Goal " + _iLeashHolderGoal + ": No goal.", DL_TRACE, S_MOD)

   ; Check how upset the slaver is with the player and whether he is open to slaving her out.
   Int iCurrAnger = _qFramework.GetActorAnger(_aLeashHolder)
   If (_bIsEnslaveAllowed && (50 >= iCurrAnger))
      ; The player has been behaving and the slaver won't slave her out.
      _bIsEnslaveAllowed = False
      _qFramework.RemovePermission(_aLeashHolder, _qFramework.AP_ENSLAVE)
   ElseIf (!_bIsEnslaveAllowed && (60 <= iCurrAnger))
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
         _qFramework.IncActorAnger(_aLeashHolder, 10, 0, 100)
      EndIf

      StartConversation(_aLeashHolder, 1)
      Return
   EndIf

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

      ; Have the slaver get upset at the player's behaviour.
      _iTotalWalkInFrontCount += 1
      _qFramework.IncActorAnger(_aLeashHolder, 3, 0, 70)

      ; Every so often the yank the player's leash and talk to her about her behaviour.
      If (!(_iTotalWalkInFrontCount % 3))
         _qFramework.YankLeash()
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

   ; Check if the slaver wants to start a new event (goal).
   Int iRandomEvent = Utility.RandomInt(1, 100)

   ; If the player is behaving increase the slaver's pleased state.
   If (!_iCurrWalkInFrontCount && (15 >= iRandomEvent))
      _qFramework.IncActorAnger(_aLeashHolder, -1, 40, 100)
      _iVerbalAnnoyance -= 1
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
      ; If the slaver has ungagged the player there is a chance he will want to gag her again.
      If (_bPlayerUngagged && (3 >= iRandomEvent))
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
      ; If there is a Favourite BDSM device nearby consider locking the player in it.
      If (_qMcm.fChanceFurnitureTransfer > Utility.RandomFloat(0, 100))
         Int iIndex = _aoFavouriteCell.Find(_aPlayer.GetParentCell())
         If (0 <= iIndex)
            If (oCurrFurniture)
               ; If the player is already in BDSM furniture simply stop the leash game.
               StopLeashGame()
            ElseIf (!_qFramework.SceneStarting(S_MOD, 60))
               ; Otherwise start a scene to unbind the player's arms first.
               ; We have to unbind the player's arms to avoid the game thinking we are standing
               ; when we are actually sitting in BDSM furniture.
               _qZbfSlaveActions.BindPlayer(akMaster=_aLeashHolder, \
                                            asMessage=S_MOD + "_PrepBdsm")
            EndIf
         EndIf
      EndIf
      Return
   EndIf

   iAnger = _qFramework.GetActorAnger(_aLeashHolder)
   ;Log("Checking events: Anger(" + iAnger + ") Random(" + iRandomEvent + ")", DL_TRACE, S_MOD)

   ; Check if the slaver wants to bind the player's arms based on how angry he is.
   ; Anger >= 75: 100%  Anger 50-65: 50%  Anger 40-50: 15%  Anger < 40: 8%
   If (((75 <= iAnger) || ((65 <= iAnger) && (50 >= iRandomEvent)) || \
        ((40 <= iAnger) && (15 >= iRandomEvent)) || ((40 > iAnger) && (8 >= iRandomEvent))) && \
       !_qFramework.IsPlayerArmLocked())
      ;Log("Starting Arm Restraints.", DL_TRACE, S_MOD)

      If (!_oArmRestraint)
         Int iIndex = Utility.RandomInt(0, _aoArmRestraints.Length - 1)
         _oArmRestraint = _aoArmRestraints[iIndex]
         _aPlayer.AddItem(_oArmRestraint)
      EndIf
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
   If (_qFramework.IsPlayerArmLocked() && (iRandomEvent <= _qMcm.iChanceIdleRestraints))
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

      If (_qFramework.IsAllowed(_qFramework.AP_ENSLAVE))
         Actor aMaster = (StorageUtil.GetFormValue(_aPlayer, "_SD_CurrentOwner") As Actor)
         If (SUCCESS <= _qFramework.SetMaster(aMaster, "SD+", _qFramework.AP_NO_BDSM, \
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
   EndIf
EndFunction

Function StopSdPlus()
   If (_bEnslavedSdPlus)
      Log("Player no longer SD+ Enslaved.", DL_CRIT, S_MOD)

      _qFramework.ClearMaster(_qFramework.GetMaster(_qFramework.MD_CLOSE))
      If (_qMcm.bLeashSdPlus)
         _qFramework.RestoreHealthRegen()
         _qFramework.RestoreMagickaRegen()
         _qFramework.SetLeashTarget(None)
      EndIf
      _bEnslavedSdPlus = False
   EndIf
EndFunction

; Called by dialog scripts to indicate the dialog is upsetting the speaker.
Function IncAnger(Actor aActor, Int iDelta)
   _iLeashHolderAnger = _qFramework.IncActorAnger(aActor, iDelta, 20, 80)

   ; Reset the dialogue timeout beacuse we are still in a dialogue.
   _iDialogueBusy = 20
EndFunction

; Called by dialog scripts to indicate the slaver is feeling more dominant toward the player.
Function IncDominance(Actor aActor, Int iDelta)
   _qFramework.IncActorDominance(aActor, iDelta, 20, 80)

   ; Reset the dialogue timeout beacuse we are still in a dialogue.
   _iDialogueBusy = 20
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

   _qFramework.YankLeashWait(500)
   If (_qFramework.GetBdsmFurniture())
      ImmobilizePlayer()
      _qZbfSlaveActions.RestrainInDevice(None, aNpc, asMessage=S_MOD + "_Furniture" + szMessage)
   Else
      _qZbfSlaveActions.BindPlayer(akMaster=aNpc, asMessage=S_MOD + "_" + szMessage)
   EndIf
EndFunction

; Called by dialog scripts to indicate the player has agreed to or refuses to cooperate.
; The level of cooperation: < 0 not cooperating, 0 = avoiding the subject, > 0 = cooperating.
Function Cooperation(Int iGoal, Int iLevel)
   ; Enticing the player's co-operation (or lack thereof) indicates the end of the conversation.
   _iDialogueBusy = 0

   If (0 < iLevel)
      _qFramework.IncActorAnger(_aLeashHolder, -1, 20, 80)
   ElseIf (-1 == iLevel)
      _qFramework.IncActorAnger(_aLeashHolder, 3, 20, 80)
   ElseIf (-1 > iLevel)
      _qFramework.IncActorAnger(_aLeashHolder, 5, 20, 80)
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
         If (60 < _qFramework.GetActorAnger(_aLeashHolder))
            _aPlayer.RemoveItem(oWeaponRight, 999, akOtherContainer=_aLeashHolder)
            _aPlayer.RemoveItem(oWeaponLeft, 999, akOtherContainer=_aLeashHolder)
            _oItemStolen = _qDfwUtil.AddFormToArray(_oItemStolen, oWeaponRight)
            _oItemStolen = _qDfwUtil.AddFormToArray(_oItemStolen, oWeaponLeft)
            If (1 > _iWeaponsStolen)
               _iWeaponsStolen = 1
            EndIf
         EndIf
      ElseIf (0 >= iLevel)
         If (((-2 == iLevel) || (-3 == iLevel)) && _aPlayer.IsWeaponDrawn())
            _qFramework.YankLeash(iOverrideLeashStyle=_qFramework.LS_DRAG)
         EndIf
      EndIf
   ElseIf (2 == iGoal)
      If (4 == iLevel)
         ; Before letting the player free of her arm binder the slaver will take her weapons.
         ; Play an animation for the slaver to approach the player.
         ; The assault (weapon stealing) will happen on the done event (OnSlaveActionDone).
         _iAssault = 0x8000 + 0x0020 + 0x0008
         PlayApproachAnimation(_aLeashHolder, "Assault")
      ElseIf (3 == iLevel)
         ; The player needs help unequipping her weapons.
         ; Play an animation for the slaver to approach the player.
         ; The assault (stripping) will happen on the done event (OnSlaveActionDone).
         _iAssault = 0x8000 + 0x0001
         PlayApproachAnimation(_aLeashHolder, "Assault")
      ElseIf (-2 >= iLevel)
         ; The slaver is done asking.  Forcibly strip the player.
         AssaultPlayer(bStrip=False)
      EndIf

      ; Set the player to have dressing assisted with the devious framework.  This is so the
      ; slaver can help the player equip sexy clothing over her leash.
      _qFramework.AddPermission(_aLeashHolder, _qFramework.AP_DRESSING_ASSISTED)
   ElseIf (3 == iGoal)
      ; Goal 3: Take the player's weapons.
      _iAssault = 0x8000 + 0x0008
      PlayApproachAnimation(_aLeashHolder, "Assault")
      _iLeashHolderGoal = 0
   ElseIf (4 == iGoal)
      If (3 == iLevel)
         ; The player needs help equipping her arm restraint.
         ; Play an animation for the slaver to approach the player.
         ; Restraining the player's arms will happen on the done event (OnSlaveActionDone).
         _iAssault = 0x8000 + 0x0004
         PlayApproachAnimation(_aLeashHolder, "Assault")
      EndIf
   ElseIf (5 == iGoal)
      ; Goal 5: Strip the player fully.
      _iAssault = 0x8000 + 0x0040
      PlayApproachAnimation(_aLeashHolder, "Assault")
      _iLeashHolderGoal = 0
   ElseIf (6 == iGoal)
      ; The slaver is fed up with the player's backtalk and is going to gag her.
      If (1 == iLevel)
         ; The player is co-operating.  Gag her peacefully.
         ; Play an animation for the slaver to approach the player.
         ; Gagging the player's arms will happen on the done event (OnSlaveActionDone).
         _iAssault = 0x8000 + 0x0002
         PlayApproachAnimation(_aLeashHolder, "Assault")
      Else
         ; The player is not co-operating.  Use force.
         AssaultPlayer(bAddGag=True)
      EndIf
      _iLeashHolderGoal = 0
   ElseIf (7 == iGoal)
      ; After we have spoken to the player about it, don't bring it up for a while.
      _iLeashHolderGoal = 0
   ElseIf (8 == iGoal)
      ; Goal 8: Restrain the player.
      If (!_iAssault)
         _iAssault = 0x8000 + 0x0080
      EndIf
      PlayApproachAnimation(_aLeashHolder, "Assault")
      _iLeashHolderGoal = 0
   ElseIf (-3 == iGoal)
      ; Post Leash game the player wants her weapons back but for safety reasons the slaver
      ; wants her locked up first.
      ; Play an animation for the slaver to approach the player.
      ; Restraining the player's arms will happen on the done event (OnSlaveActionDone).
      _iAssault = 0x8000 + 0x0010 + 0x0004
      Actor aLastLeashHolder = (_aAliasLastLeashHolder.GetReference() As Actor)
      PlayApproachAnimation(aLastLeashHolder, "Assault")
   ElseIf (-6 == iGoal)
      ; The player has been well behaved and is being ungagged.
      _iAssault = 0x8000 + 0x0100
      PlayApproachAnimation(_aLeashHolder, "Assault")
   EndIf
EndFunction

Int Function GetLeashGameDuration(Bool bExtend=False)
   ; Figure out how long the leash game will be played for.
   Int iDurationSeconds = (Utility.RandomInt(_qMcm.iDurationMin, _qMcm.iDurationMax) * 60)
   If (bExtend)
      iDurationSeconds = (iDurationSeconds / 2)
   EndIf
   Return ((iDurationSeconds / _qMcm.fPollTime) As Int)
EndFunction

Function FavouriteCurrentFurniture()
   ObjectReference oCurrFurniture = _qFramework.GetBdsmFurniture()
   If (!oCurrFurniture || (0 <= _aoFavouriteFurniture.Find(oCurrFurniture)))
      ; Ignore the request if the player is not in BDSM furniture or it is already favourited.
      Return
   EndIf

   _aoFavouriteFurniture = _qDfwUtil.AddFormToArray(_aoFavouriteFurniture, oCurrFurniture)
   _aoFavouriteCell = _qDfwUtil.AddFormToArray(_aoFavouriteCell, oCurrFurniture.GetParentCell())
EndFunction

Form[] Function GetFavouriteFurniture()
   Return _aoFavouriteFurniture
EndFunction

Form[] Function GetFavouriteCell()
   Return _aoFavouriteCell
EndFunction

Function RemoveFavourite(Int iIndex)
   _aoFavouriteFurniture = _qDfwUtil.RemoveFormFromArray(_aoFavouriteFurniture, None, iIndex)
   _aoFavouriteCell = _qDfwUtil.RemoveFormFromArray(_aoFavouriteCell, None, iIndex)
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
   Return "1.05"
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
      _iLeashGameDuration = ((iDurationSeconds / _qMcm.fPollTime) As Int)

      ; Establish an initial disposition for the leash holder.
      Int iCurrAnger = _qFramework.GetActorAnger(aActor, 20, 65, True)
      _qFramework.GetActorDominance(aActor, 40, 85, True)

      ; If the slaver is already angry with the player start with enslave allowed.
      If (50 < iCurrAnger)
         _qFramework.AddPermission(aActor, _qFramework.AP_ENSLAVE)
      EndIf

      _qFramework.BlockHealthRegen()
      _qFramework.DisableMagicka()
      _qFramework.SetLeashLength(_qMcm.iLeashLength)
      _qFramework.SetLeashTarget(aActor)
      _aLeashHolder = aActor
      _bIsEnslaveAllowed = False
      _bFullyRestrained = False
      _bIsCompleteSlave = False
      _iLeashHolderGoal = 0
      _bIsPlayerGagged = _qFramework.IsPlayerGagged()
      _bIsPlayerArmLocked = _qFramework.IsPlayerArmLocked()
      ; If this is not the last NPC to play the leash game reset some personalized stats.
      If (_aAliasLastLeashHolder && \
          (aActor != (_aAliasLastLeashHolder.GetReference() As Actor)))
         _iVerbalAnnoyance = 0
         _oItemStolen = None
         _oGag = None
         _oArmRestraint = None
         _oLegRestraint = None
         _oCollar = None
         _bPlayerUngagged = False
      EndIf
      _bReequipWeapons = False
      _aAliasLastLeashHolder.Clear()
      _aAliasLeashHolder.ForceRefTo(_aLeashHolder)
      Return SUCCESS
   EndIf
   Return FAIL
EndFunction

