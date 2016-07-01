Scriptname dfwsDfwSupport extends Quest  
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

; A reference to the ZAZ Animation Pack (ZBF) slave control API.
zbfSlaveControl _qZbfSlave

; Keeps track of when the last update poll was.
; This can be used to detect when the game has been loaded as the current real time is reset.
Float _fLastUpdatePoll

; Keeps track of whether the leash game is in effect and how long it will continue for.
Actor _aLeashHolder
Int _iLeashGameDuration

; A variable to keep track of whether we think the player is enslaved by SD+.
Bool _bEnslavedSDPlus


;***********************************************************************************************
;***                                    INITIALIZATION                                       ***
;***********************************************************************************************
; This is called once by the MCM script to initialize the mod and then on each update poll.
; This function is primarily to ensure new variables are initialized for new script versions.
Function UpdateScript()
   ; Reset the version number.
   ; _fCurrVer = 0.00

   ; Very basic initialization.
   If (0.01 > _fCurrVer)
      _aPlayer = Game.GetPlayer()
      _qMcm = (Self As Quest) As dfwsMcm
      _qFramework = Quest.GetQuest("_dfwDeviousFramework") As dfwDeviousFramework
      _qDfwUtil = Quest.GetQuest("_dfwDeviousFramework") As dfwUtil
      _qZbfSlave = zbfSlaveControl.GetApi()
   EndIf
_qZbfSlave = zbfSlaveControl.GetApi()


   ; Always register for updates.  We want to make sure the periodic function is polling.
   If (_qMcm.fPollTime)
      RegisterForUpdate(_qMcm.fPollTime)
   EndIf

   ; Always register for mod events.  These registrations are cleared when the game loads.
   If (_qMcm.bCatchZazEvents)
      RegisterForModEvent("zbfSC_EnslaveActor", "ActorEnslaved")
      RegisterForModEvent("zbfSC_FreeSlave", "ActorFreed")
      RegisterForModEvent("zbfSC_ReleaseSlave", "ActorFreed")
   EndIf

   ; If the script is at the current version we are done.
   ; Note: On updating the version number remember to update the OnUpdate() event too!
   Float fScriptVer = 0.02
   If (fScriptVer == _fCurrVer)
      Return
   EndIf
   Log("Updating Script " + _fCurrVer + " => " + fScriptVer, DL_CRIT, S_MOD)

   ; Finally update the version number.
   _fCurrVer = fScriptVer
EndFunction


;***********************************************************************************************
;***                                        EVENTS                                           ***
;***********************************************************************************************
Event OnUpdate()
   Float fCurrRealTime = Utility.GetCurrentRealTime()

   If (_fLastUpdatePoll > fCurrRealTime)
      ; The game has been loaded.  Perform necessary actions here.
      UpdateScript()
   EndIf
   _fLastUpdatePoll = fCurrRealTime

   ; If the player is leashed to a target make sure they are not too far away.
   If (_aLeashHolder)
      Float fDistance = _aLeashHolder.GetDistance(_aPlayer)
      If (1500 < fDistance)
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

      ; If we are playing the leash game check if the slaver will let the player go.
      If (_iLeashGameDuration)
         _iLeashGameDuration -= 1
         If (0 >= _iLeashGameDuration)
            Log(_aLeashHolder.GetDisplayName() + " unties your leash and lets you go.", \
                DL_CRIT, S_MOD)
            StopLeashGame()
         EndIf
      EndIf
   ElseIf (_qMcm.iLeashGameChance || _qMcm.iIncreaseWhenVulnerable)
      ; If the mod's leash game is enabled check for that now.

      ; Only play the leash game if there is no leash target or close current master.
      If (!_aLeashHolder && !_qFramework.GetMaster(_qFramework.MD_CLOSE) && \
          !_qFramework.IsPlayerCriticallyBusy())
         Float fMaxChance = _qMcm.iLeashGameChance
         If (_qMcm.iIncreaseWhenVulnerable)
            fMaxChance += ((_qMcm.iIncreaseWhenVulnerable As Float) * \
                            _qFramework.GetVulnerability(_aPlayer) / 100)
         EndIf
         If (Utility.RandomFloat(0, 100) < fMaxChance)
            ; Find an actor to use as the Master in the leash game.
            Int iActorFlags = _qFramework.AF_SLAVE_TRADER
            If (_qMcm.bIncludeOwners)
               iActorFlags = Math.LogicalOr(_qFramework.AF_OWNER, iActorFlags)
            EndIf
            Actor aRandomActor = _qFramework.GetRandomActor(1000, iActorFlags)

            If (aRandomActor)
               Log(aRandomActor.GetDisplayName() + " Lassos a rope around your neck.", \
                   DL_CRIT, S_MOD)

               ; Start the game.
               StartLeashGame(aRandomActor)
            EndIf
         EndIf
      EndIf
   EndIf

   ; Check if the player is enslaved by Sanguine's Debauchery (SD+).
   If (_qMcm.bCatchSdPlus && _bEnslavedSDPlus)
      ; We think the player is enslaved.  Check if she actually is.
      If (0 >= StorageUtil.GetIntValue(_aPlayer, "_SD_iEnslaved"))
         Log("Player no longer SD+ Enslaved.", DL_CRIT, S_MOD)
         _qFramework.ClearMaster(_qFramework.GetMaster(_qFramework.MD_CLOSE))
         If (_qMcm.bLeashSdPlus)
            _qFramework.RestoreHealthRegen()
            _qFramework.RestoreMagickaRegen()
            _qFramework.SetLeashTarget(None)
         EndIf
         _bEnslavedSDPlus = False
      EndIf
   ElseIf (_qMcm.bCatchSdPlus)
      If (0 < StorageUtil.GetIntValue(_aPlayer, "_SD_iEnslaved"))
         Log("Player now SD+ Enslaved.", DL_CRIT, S_MOD)

         If (_qFramework.IsAllowed(_qFramework.AP_ENSLAVE))
            Actor aMaster = (StorageUtil.GetFormValue(_aPlayer, "_SD_CurrentOwner") As Actor)
            If (FAIL != _qFramework.SetMaster(aMaster, "SD+", _qFramework.AP_NO_BDSM, \
                                              _qFramework.MD_CLOSE))
               If (_qMcm.bLeashSdPlus)
                  _qFramework.BlockHealthRegen()
                  _qFramework.BlockMagickaRegen()
                  _qFramework.SetLeashTarget(aMaster)
               EndIf
               _bEnslavedSDPlus = True
            EndIf
         EndIf
      EndIf
   EndIf
EndEvent

Event ActorEnslaved(Form oActor, String szMod)
   Actor aActor = (oActor As Actor)
   Log("Actor Enslaved: " + aActor.GetDisplayName(), DL_CRIT, szMod)
   If (_aPlayer != oActor)
      Return
   EndIf
   Log("Player Enslaved!", DL_CRIT, szMod)
   If ((szMod != _qFramework.GetMasterMod(_qFramework.MD_CLOSE)) && \
       (szMod != _qFramework.GetMasterMod(_qFramework.MD_DISTANT)))
      ; If this mod is not already registered as a player's controller try to find the player's
      ; master in the narby player list.
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
   Log("Actor Freed: " + aActor.GetDisplayName(), DL_CRIT, szMod)
   If (_aPlayer != oActor)
      Return
   EndIf
   Log("Player Freed!", DL_CRIT, szMod)
   Actor aCurrMaster = _qFramework.GetMaster(_qFramework.MD_CLOSE)
   If (aCurrMaster)
      _qFramework.ClearMaster(aCurrMaster)
   EndIf
EndEvent


;***********************************************************************************************
;***                                  PRIVATE FUNCTIONS                                      ***
;***********************************************************************************************
Function StopLeashGame()
   _iLeashGameDuration = 0
   _qFramework.RestoreHealthRegen()
   _qFramework.DisableMagicka(False)
   _qFramework.SetLeashTarget(None)
   _qFramework.ClearMaster(_aLeashHolder As Actor)
   _aLeashHolder = None
EndFunction

Function Log(String szMessage, Int iLevel=0, String szClass="")
   If (szClass)
      szMessage = "[" + szClass + "] " + szMessage
   EndIf

   ; Log to console.  Not sure why we would want this.
   ;If (_bLogToConsole)
   ;   MiscUtil.PrintConsole(msg)
   ;EndIf

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


;***********************************************************************************************
;***                                   PUBLIC FUNCTIONS                                      ***
;***********************************************************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Basic API Documentation:
; String GetModVersion()
;  Float GetLastUpdateTime()
;   Bool IsGameOn()
;    Int StartLeashGame(Actor aActor)
;

String Function GetModVersion()
   Return "0.0001"
EndFunction

Float Function GetLastUpdateTime()
   Return _fLastUpdatePoll
EndFunction

Bool Function IsGameOn()
   Return _iLeashGameDuration
EndFunction

Int Function StartLeashGame(Actor aActor)
   ; Figure out how long the leash game will be played for.
   Int iDurationSeconds = Utility.RandomInt(300 - 50, 600 + 100)
   If (650 < iDurationSeconds)
      iDurationSeconds = Utility.RandomInt(1800, 7200)
   ElseIf (600 < iDurationSeconds)
      iDurationSeconds = Utility.RandomInt(600, 1800)
   ElseIf (300 > iDurationSeconds)
      iDurationSeconds = Utility.RandomInt(60, 300)
   EndIf

   If (FAIL != _qFramework.SetMaster(aActor, S_MOD, _qFramework.AP_NO_SEX, \
                                     _qFramework.MD_CLOSE))
      ; Adjust the duration based on the length of a poll.
      _iLeashGameDuration = (iDurationSeconds / _qMcm.fPollTime) As Int

      _qFramework.BlockHealthRegen()
      _qFramework.DisableMagicka()
      _qFramework.SetLeashLength(_qMcm.iLeashLength)
      _qFramework.SetLeashTarget(aActor)
      _aLeashHolder = aActor
      Return SUCCESS
   EndIf
   Return FAIL
EndFunction

