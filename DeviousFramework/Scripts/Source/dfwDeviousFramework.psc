Scriptname dfwDeviousFramework extends Quest
{Framework intended for Devious device mods.
 Hopefully there is an API document somewhere.}

;***********************************************************************************************
; Mod: Devious Framework
;
; Script: External API
;
; The primary external function set for the devious framework mod.
;
; Many aspects of this mod are taken from the Deviously Enslaved and Deviously Enslaved
; Continued mods.
; Many thanks to Verstort and Chase Roxand for all of their work on that mod.
;
; TODO (In progress):
; TODO:
; 1. Look into using Armour.IsClothing/Light/HeavyArmour() functions.
; 2. Add profiling information.
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
;***********************************************************************************************

;***********************************************************************************************
;***                                      CONSTANTS                                          ***
;***********************************************************************************************
String S_MOD = "DFW"

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

; Item Type (IT_) constants.
Int Property IT_NONE              = 0x00000000 Auto
Int Property IT_RESTRAINT         = 0x00000001 Auto
Int Property IT_CLOTHES_BODY      = 0x00000002 Auto
Int Property IT_CLOTHES_CHEST     = 0x00000004 Auto
Int Property IT_CLOTHES_WAIST     = 0x00000008 Auto
Int Property IT_LIGHT_BODY        = 0x00000010 Auto
Int Property IT_LIGHT_CHEST       = 0x00000020 Auto
Int Property IT_LIGHT_WAIST       = 0x00000040 Auto
Int Property IT_HEAVY_BODY        = 0x00000080 Auto
Int Property IT_HEAVY_CHEST       = 0x00000100 Auto
Int Property IT_HEAVY_WAIST       = 0x00000200 Auto
Int Property IT_PARTIAL           = 0x00000400 Auto
Int Property IT_CLOTHES_OTHER     = 0x00000800 Auto
Int Property IT_LIGHT_OTHER       = 0x00001000 Auto
Int Property IT_HEAVY_OTHER       = 0x00002000 Auto
Int Property IT_CLOTHES           = 0x0000080E Auto
Int Property IT_LIGHT             = 0x00001070 Auto
Int Property IT_HEAVY             = 0x00002380 Auto
Int Property IT_COVERINGS         = 0x00003BFE Auto
Int Property IT_BODY_COVERINGS    = 0x00000092 Auto
Int Property IT_CHEST_COVERINGS   = 0x000001B6 Auto
Int Property IT_WAIST_COVERINGS   = 0x000002DA Auto

; Naked Status (NS_) constants.
Int Property NS_NAKED           = 0x00000000 Auto
Int Property NS_WAIST_PARTIAL   = 0x00000001 Auto
Int Property NS_WAIST_COVERED   = 0x00000002 Auto
Int Property NS_CHEST_PARTIAL   = 0x00000004 Auto
Int Property NS_CHEST_COVERED   = 0x00000008 Auto
Int Property NS_BOTH_PARTIAL    = 0x00000010 Auto
Int Property NS_BOTH_COVERED    = 0x00000020 Auto
Int Property NS_WAIST_PROTECTED = 0x00000032 Auto
Int Property NS_CHEST_PROTECTED = 0x00000038 Auto

; Action Permissions (AP_) constants.
Int Property AP_NONE              = 0x00000000 Auto
Int Property AP_SEX               = 0x00000001 Auto
Int Property AP_ENSLAVE           = 0x00000002 Auto
Int Property AP_RESTRAIN          = 0x00000004 Auto
Int Property AP_DRESSING_ALONE    = 0x00000010 Auto
Int Property AP_DRESSING_ASSISTED = 0x00000020 Auto
Int Property AP_DRESSING          = 0x00000030 Auto
Int Property AP_NO_SEX            = 0xFFFFFFFE Auto
Int Property AP_NO_BDSM           = 0xFFFFFFF9 Auto
Int Property AP_ALL               = 0xFFFFFFFF Auto

; Actor Flag (AF_) constants.
; Notes: The animal flag is not supported yet and may never be.
;        These flags are only intended for basic features.
;        For more advanced features the mod should get the enire list and process it manually.
Int Property AF_ESTIMATE     = 0x00000001 Auto
Int Property AF_IMPORTANT    = 0x00000002 Auto
Int Property AF_CHILD        = 0x00000004 Auto
Int Property AF_GUARDS       = 0x00000008 Auto
Int Property AF_MERCHANTS    = 0x00000010 Auto
Int Property AF_HOSTILE      = 0x00000020 Auto
Int Property AF_ANIMAL       = 0x00000040 Auto
Int Property AF_DOMINANT     = 0x00000080 Auto
Int Property AF_SUBMISSIVE   = 0x00000100 Auto
Int Property AF_SLAVE        = 0x00000200 Auto
Int Property AF_OWNER        = 0x00000400 Auto
Int Property AF_SLAVE_TRADER = 0x00000800 Auto
; Masks encompassing groups of the above masks.
Int Property AF_BDSM_AWARE   = 0x00000F00 Auto


; Master distances (MD_) constants.
; Note: These must remain backwards compatible.
Int Property MD_NONE    = 0x00000000 Auto
Int Property MD_ANY     = 0x00000001 Auto
Int Property MD_ALL     = 0x00000002 Auto
Int Property MD_CLOSE   = 0x00000004 Auto
Int Property MD_DISTANT = 0x00000008 Auto

; Leash Style (LS_) constants.
; Note: These must remain backwards compatible.
Int Property LS_AUTO     = 0 Auto
Int Property LS_DRAG     = 1 Auto
Int Property LS_TELEPORT = 2 Auto

; Properties from the script properties window in the creation kit.
Spell Property _oDfwLeashSpell          Auto
Spell Property _oDfwNearbyDetectorSpell Auto
Faction Property _oFactionMerchants     Auto


;***********************************************************************************************
;***                                      VARIABLES                                          ***
;***********************************************************************************************
; A local variable to store a reference to the player for faster access.
Actor _aPlayer

; Version control for this script.
; Note: This is versioning control for the script.  It is unrelated to the mod version.
Float _fCurrVer = 0.00

;*** Vulnerability Flags ***
Int _iNakedStatus
Bool _bChestCovered = False
Bool _bWaistCovered = False
Bool _bNakedReduced = False
Bool _bChestReduced = False
Bool _bWaistReduced = False
Bool _bIsCollared   = False
Bool _bIsArmLocked  = False
Bool _bIsGagged     = False
Bool _bIsHobbled    = False
Bool _bIsBelted     = False
Int _iNumOtherRestraints
Bool _bHiddenRestraints = False

; Flags to tell the poll function to update information.
Bool _bFlagSet            = True
Bool _bFlagCheckNaked     = True
Bool _bFlagCheckCollared  = True
Bool _bFlagCheckArmLocked = True
Bool _bFlagCheckGagged    = True
Bool _bFlagCheckHobbled   = True
Bool _bFlagCheckLockedUp  = True

;*** Keywords ***
; A local variable to store the SexLab Aroused "Is Naked" keyword for faster access.
; Note: This keyword doesn't appear to be used.
;       See the StorageUtil SLAroused.IsNakedArmor instead.
;Keyword _oKeywordIsNaked

; Keywords to identify clothing (Clothes, Light Armour, and Heavy Armour).
Keyword _oKeywordClothes
Keyword _oKeywordArmourLight
Keyword _oKeywordArmourHeavy

; Non-specific primary devious device keywords.
Keyword _oKeywordZadLockable
Keyword _oKeywordZadInventoryDevice
Keyword _oKeywordZbfWornDevice

; ZAD Devious Keywords.
Keyword _oKeywordZadArmBinder
Keyword _oKeywordZadArmCuffs
Keyword _oKeywordZadBelt
Keyword _oKeywordZadBlindfold
Keyword _oKeywordZadBoots
Keyword _oKeywordZadBra
Keyword _oKeywordZadClamps
Keyword _oKeywordZadCollar
Keyword _oKeywordZadCorset
Keyword _oKeywordZadGag
Keyword _oKeywordZadGloves
Keyword _oKeywordZadHarness
Keyword _oKeywordZadHood
Keyword _oKeywordZadLegCuffs
Keyword _oKeywordZadNipple
Keyword _oKeywordZadVagina
Keyword _oKeywordZadFullSuit
Keyword _oKeywordZadYoke

; ZBF Worn Keywords.
Keyword _oKeywordZbfWornAnkles
Keyword _oKeywordZbfWornBelt
Keyword _oKeywordZbfWornBlindfold
Keyword _oKeywordZbfWornBra
Keyword _oKeywordZbfWornCollar
Keyword _oKeywordZbfWornGag
Keyword _oKeywordZbfWornHood
Keyword _oKeywordZbfWornWrist
Keyword _oKeywordZbfWornYoke

; Other ZBF Keywords.
Keyword _oKeywordZbfEffectNoMove
Keyword _oKeywordZbfEffectNoSprint
Keyword _oKeywordZbfEffectSlowMove

; A reference to the MCM quest script.
dfwMcm _qMcm

; A reference to the Devious Framework Util quest script.
dfwUtil _qDfwUtil

; A reference to SexLab and SexLab Aroused Framework quest scripts.
SexLabFramework _qSexLab
slaFrameworkScr _qSexLabAroused
slaMainScr      _qSexLabArousedMain

; A reference to the Devious Devices quest, Zadlibs.
Zadlibs _qZadLibs

; A reference to the ZAZ Animation Pack (ZBF) slave control API.
zbfSlaveControl _qZbfSlave

; A list of nearby actors.
; The first is a list of known actors we have at least estimated some information about.
; The second is a list of new actors we don't know anything about.
; Gradually during polling intervals we will move actors from the new list to the known list.
Int _iNearbyMutex
Form[] _aoNearby
Int[] _aiNearbyFlags

; A list of Masters who are controlling the player.
Actor _aMasterClose
Actor _aMasterDistant
String _aMasterModClose
String _aMasterModDistant

; A set of flags to keep track of whether sex or enslavement is allowed.
Int _iPermissionsClose
Int _iPermissionsDistant

; A set of flags from related to actors from a recent call to GetNearbyActorList()
Int[] _aiRecentFlags

; Keeps track of the number of polls since the last NPC detection scan.
Int _iDetectPollCount

; Keep track of how long before the next cleanup is scheduled for the nearby actors list.
Float _fNearbyCleanupTime

; Timeouts to prevent redressing after becoming naked or being raped.
Float _fNakedRedressTimeout
Float _fRapeRedressTimeout

; The time we are expected to recover from a bleedout.
Float _iBleedoutTime

; An actor the player is to be leashed to.
ObjectReference _oLeashTarget
Int _iLeashLength

; Counts for how many mods have blocked stat regeneration.
Int _iBlockHealthRegen
Int _iBlockMagickaRegen
Int _iBlockStaminaRegen
Int _iDisableMagicka
Int _iDisableStamina

; Mechanisms to identify slavers.
Faction _oFactionHydraSlaver
Faction _oFactionHydraSlaverMisc

; A mutext to proect global data access.
; I suspect that simulaneous data writes from two different mods can crash the game.
Int _iGeneralDataMutex
; Use a separate mutex for the player status flags to reduce the amount of data on one mutex.
Int _iFlagsDataMutex


;***********************************************************************************************
;***                                        EVENTS                                           ***
;***********************************************************************************************
; This is called from the player monitor script when a game is loaded.
; This function is primarily to ensure new variables are initialized for new script versions.
Function OnPlayerLoadGame()
   ; Reset the version number.
   ; To make sure the Utility script is loaded.
   ; _fCurrVer = 0.00
   _fCurrVer = 0.03

   ; If any real time timers are active reset them to the current time because the real time
   ; clock is reset each time the game is loaded.
   If (_iBleedoutTime)
      _iBleedoutTime = Utility.GetCurrentRealTime() + 30
   EndIf
   ; The nearby cleanup timeout is always set.  Always reset it.
   If (_qDfwUtil.MutexLock(_iGeneralDataMutex))
      _fNearbyCleanupTime = Utility.GetCurrentRealTime() + 3
      _qDfwUtil.MutexRelease(_iGeneralDataMutex)
   EndIf

   ; Very basic initialization.
   If (0.01 > _fCurrVer)
      _aPlayer = Game.GetPlayer()
      _qMcm = (Self As Quest) As dfwMcm
      _qDfwUtil = (Self As Quest) As dfwUtil
      _qZadLibs = Quest.GetQuest("zadQuest") As Zadlibs
      _qSexLab = Quest.GetQuest("SexLabQuestFramework") As SexLabFramework
      _qSexLabArousedMain = Quest.GetQuest("sla_Main") As slaMainScr
      _qSexLabAroused = Quest.GetQuest("sla_Framework") As slaFrameworkScr
   EndIf

   ; Make sure the utility script gets updated as well.
   _qDfwUtil.OnPlayerLoadGame()

   ; Always register for updates.  We want to make sure the periodic function is polling.
   RegisterForUpdate(_qMcm.fSettingsPollTime)

   ; If the nearby actors lists are out of sync clear them completely.
   If (_aoNearby.Length != _aiNearbyFlags.Length)
      Log("Nearby Lists Out of Sync!  Cleaning.", DL_CRIT, S_MOD)
      If (_qDfwUtil.MutexLock(_iNearbyMutex))
         While (_aoNearby.Length)
            _aoNearby = _qDfwUtil.RemoveFormFromArray(_aoNearby, None, 0)
         EndWhile
         While (_aiNearbyFlags.Length)
            _aiNearbyFlags = _qDfwUtil.RemoveIntFromArray(_aiNearbyFlags, 0, 0)
         EndWhile

         _qDfwUtil.MutexRelease(_iNearbyMutex)
      EndIf
   EndIf

   ; If the script is at the current version we are done.
   Float fScriptVer = 0.04
   If (fScriptVer == _fCurrVer)
      Return
   EndIf
   Log("Updating Script " + _fCurrVer + " => " + fScriptVer, DL_CRIT, S_MOD)

   ; Historical configuration...
   If (0.02 > _fCurrVer)
      ; Note: This keyword doesn't appear to be used.
      ;       See the StorageUtil SLAroused.IsNakedArmor instead.
      ;_oKeywordIsNaked = Keyword.GetKeyword("EroticArmor")

      ; ZAD Devious Keywords.
      _oKeywordZadArmBinder = Keyword.GetKeyword("zad_DeviousArmbinder")
      _oKeywordZadArmCuffs  = Keyword.GetKeyword("zad_DeviousArmCuffs")
      _oKeywordZadBelt      = Keyword.GetKeyword("zad_DeviousBelt")
      _oKeywordZadBlindfold = Keyword.GetKeyword("zad_DeviousBlindfold")
      _oKeywordZadBoots     = Keyword.GetKeyword("zad_DeviousBoots")
      _oKeywordZadBra       = Keyword.GetKeyword("zad_DeviousBra")
      _oKeywordZadClamps    = Keyword.GetKeyword("zad_DeviousClamps")
      _oKeywordZadCollar    = Keyword.GetKeyword("zad_DeviousCollar")
      _oKeywordZadCorset    = Keyword.GetKeyword("zad_DeviousCorset")
      _oKeywordZadGag       = Keyword.GetKeyword("zad_DeviousGag")
      _oKeywordZadGloves    = Keyword.GetKeyword("zad_DeviousGloves")
      _oKeywordZadHarness   = Keyword.GetKeyword("zad_DeviousHarness")
      _oKeywordZadHood      = Keyword.GetKeyword("zad_DeviousHood")
      _oKeywordZadLegCuffs  = Keyword.GetKeyword("zad_DeviousLegCuffs")
      _oKeywordZadNipple    = Keyword.GetKeyword("zad_DeviousPiercingsNipple")
      _oKeywordZadVagina    = Keyword.GetKeyword("zad_DeviousPiercingsVaginal")
      _oKeywordZadFullSuit  = Keyword.GetKeyword("zad_DeviousSuit")
      _oKeywordZadYoke      = Keyword.GetKeyword("zad_DeviousYoke")

      ; ZBF Worn Keywords.
      _oKeywordZbfWornAnkles    = Keyword.GetKeyword("zbfWornAnkles")
      _oKeywordZbfWornBelt      = Keyword.GetKeyword("zbfWornBelt")
      _oKeywordZbfWornBlindfold = Keyword.GetKeyword("zbfWornBlindfold")
      _oKeywordZbfWornBra       = Keyword.GetKeyword("zbfWornBra")
      _oKeywordZbfWornCollar    = Keyword.GetKeyword("zbfWornCollar")
      _oKeywordZbfWornGag       = Keyword.GetKeyword("zbfWornGag")
      _oKeywordZbfWornHood      = Keyword.GetKeyword("zbfWornHood")
      _oKeywordZbfWornWrist     = Keyword.GetKeyword("zbfWornWrist")
      _oKeywordZbfWornYoke      = Keyword.GetKeyword("zbfWornYoke")

      ; Other ZBF Keywords.
      _oKeywordZbfEffectNoMove   = Keyword.GetKeyword("zbfEffectNoMove")
      _oKeywordZbfEffectNoSprint = Keyword.GetKeyword("zbfEffectNoSprint")
      _oKeywordZbfEffectSlowMove = Keyword.GetKeyword("zbfEffectSlowMove")

      ; Non-specific primary devious device keywords.
      _oKeywordZadLockable        = Keyword.GetKeyword("zad_Lockable")
      _oKeywordZadInventoryDevice = Keyword.GetKeyword("zad_InventoryDevice")
      _oKeywordZbfWornDevice      = Keyword.GetKeyword("zbfWornDevice")

      ; Keywords to identify clothing (Clothes, Light Armour, and Heavy Armour).
      _oKeywordClothes     = Keyword.GetKeyword("ArmorClothing")
      _oKeywordArmourLight = Keyword.GetKeyword("ArmorHeavy")
      _oKeywordArmourHeavy = Keyword.GetKeyword("ArmorLight")

      ; Getting this directly from the .ESP file prevents us from being dependent on the mod.
      _oFactionHydraSlaver = Game.GetFormFromFile(0x0000B670, "hydra_slavegirls.esp") as Faction
      _oFactionHydraSlaverMisc = \
         Game.GetFormFromFile(0x000122B6, "hydra_slavegirls.esp") as Faction

      ; Register for post sex events to detect rapes.
      RegisterForModEvent("AnimationEnd", "PostSexCallback")
   EndIf

   If (0.03 > _fCurrVer)
      _qZbfSlave = zbfSlaveControl.GetApi()
      _qSexLabArousedMain = Quest.GetQuest("sla_Main") As slaMainScr
      _qSexLabAroused = Quest.GetQuest("sla_Framework") As slaFrameworkScr
      _iNearbyMutex = _qDfwUtil.iMutexCreate("DFW Nearby")
   EndIf

   If (0.04 > _fCurrVer)
      _iLeashLength = 700
      _iGeneralDataMutex = _qDfwUtil.iMutexCreate("DFW General")
      _iFlagsDataMutex = _qDfwUtil.iMutexCreate("DFW Flags")
   EndIf

   ; Finally update the version number.
   _fCurrVer = fScriptVer
EndFunction

Event OnUpdate()
   ; If the bleedout time is past due reset it.
   If (_iBleedoutTime)
      If (Utility.GetCurrentRealTime() >= _iBleedoutTime)
         If (_qDfwUtil.MutexLock(_iGeneralDataMutex))
            _iBleedoutTime = 0
            _qDfwUtil.MutexRelease(_iGeneralDataMutex)
         EndIf
      EndIf
   EndIf

   ; If the player is leashed to a target make sure they are not too far away.
   If (_oLeashTarget)
      ; Play the leash effect to draw leash particles between the player and the leash holder.
      ; Good:   AuraWhisperProjectile
      ; Usable: AuraWhisperProjectile AlterPosProjectile   
      ; Not:    AbsorbBeam01
      If (_qMcm.bModLeashVisible)
         _oDfwLeashSpell.Cast(_oLeashTarget, _aPlayer)
      EndIf

      ; If the leash controller is hostile to the player there is a chance he will pull the
      ; player's leash to knock her off balance.
      If ((_oLeashTarget As Actor).IsHostileToActor(_aPlayer))
         If (Utility.RandomInt(0, 99) < 20)
            Log(_oLeashTarget + " yanks your leash and throws you off balance.", DL_CRIT, S_MOD)
            _oLeashTarget.PushActorAway(_aPlayer, -2)
            Utility.Wait(0.5)
            _aPlayer.ForceRemoveRagdollFromWorld()
         EndIf
      EndIf

      Float fDistance = _oLeashTarget.GetDistance(_aPlayer)
      _iLeashLength
      If (1500 < fDistance)
         If (CheckLeashInterruptScene())
            If (GetPlayerTalkingTo())
               ; Moving the player to her own location will end the conversation.
               _aPlayer.MoveTo(_aPlayer)
            EndIf

            Log("You feel a great tug on your leash as you are pulled along.", DL_CRIT, S_MOD)
            _aPlayer.MoveTo(_oLeashTarget, 100, 100, 100)
         EndIf
      ElseIf (_iLeashLength < fDistance)
         ; Only try to drag the player if she is not busy or we can interrupt the scene.
         If (CheckLeashInterruptScene())
            Log("You feel a jerk on your leash as you are pulled roughly.", DL_CRIT, S_MOD)
            YankLeash()
         EndIf
      EndIf
   EndIf

   ; Every so many poll iterations we need to detect nearby actors.
   If (_qMcm.iSettingsPollNearby)
      _iDetectPollCount += 1
      If (_iDetectPollCount >= _qMcm.iSettingsPollNearby)
         ; To detect nearby actors we cast a spell that hits everyone in the area.
         ; The "effect" of this spell is a script that calls NearbyActorSeen()
         _oDfwNearbyDetectorSpell.Cast(_aPlayer)

         _iDetectPollCount = 0
      EndIf
   EndIf

   If (!_bFlagSet)
      ; If there are no flags set clean up the nearby actor list.
      CleanupNearbyList()

      ; No flags are set so return here.
      Return
   EndIf
   If (_qDfwUtil.MutexLock(_iFlagsDataMutex))
      _bFlagSet = False
      _qDfwUtil.MutexRelease(_iFlagsDataMutex)
   EndIf

   If (_bFlagCheckNaked)
      If (_qDfwUtil.MutexLock(_iFlagsDataMutex))
         _bFlagCheckNaked = False
         _qDfwUtil.MutexRelease(_iFlagsDataMutex)
      EndIf

      Log("Checking Naked", DL_TRACE, S_MOD)

      Int iOldStatus = _iNakedStatus
      CheckIsNaked()
      ; Only do any processing if the dressed state has changed.
      If (iOldStatus != _iNakedStatus)
         ; Some restraints may have been (un)covered.  Make sure to re-check them.
         If (_qDfwUtil.MutexLock(_iFlagsDataMutex))
            _bFlagCheckLockedUp = True
            _qDfwUtil.MutexRelease(_iFlagsDataMutex)
         EndIf

         ; If the player has just become (more) naked start a redress timeout.
         If ((NS_BOTH_PARTIAL > _iNakedStatus) && (_iNakedStatus < iOldStatus) && \
             _qMcm.iModNakedRedressTimeout)
            If (_qDfwUtil.MutexLock(_iGeneralDataMutex))
               _fNakedRedressTimeout = Utility.GetCurrentGameTime() + \
                                       ((_qMcm.iModNakedRedressTimeout As Float) / 1440)
               _qDfwUtil.MutexRelease(_iGeneralDataMutex)
            EndIf
         EndIf

         ; Report the player's status.
         If (NS_NAKED == _iNakedStatus)
            Log("You are now naked.", DL_INFO, S_MOD)
         ElseIf (NS_BOTH_PARTIAL > _iNakedStatus)
            Log("You are (partially) naked.", DL_INFO, S_MOD)
         ElseIf (NS_BOTH_PARTIAL == _iNakedStatus)
            Log("You are seductively dressed.", DL_INFO, S_MOD)
         Else
            Log("You are now fully dressed.", DL_INFO, S_MOD)
         EndIf
      EndIf
   EndIf

   If (_bFlagCheckCollared)
      If (_qDfwUtil.MutexLock(_iFlagsDataMutex))
         _bFlagCheckCollared = False
         _qDfwUtil.MutexRelease(_iFlagsDataMutex)
      EndIf

      Log("Checking Collared", DL_TRACE, S_MOD)

      Bool bOldStatus = _bIsCollared
      _bIsCollared = False
      If (_aPlayer.WornHasKeyword(_oKeywordZadCollar) || \
          _aPlayer.WornHasKeyword(_oKeywordZbfWornCollar))
         _bIsCollared = True
      EndIf
      ReportStatus("Collared", _bIsCollared, bOldStatus)
   EndIf

   ; Sometimes ZBF restraints have wrist cuffs and ankle cuff combinations.  Keep track of the
   ; wrist cuff key word to check this situation as well.
   Bool bWristCuffsKeyword = False
   If (_bFlagCheckHobbled || _bFlagCheckArmLocked)
      bWristCuffsKeyword = _aPlayer.WornHasKeyword(_oKeywordZbfWornWrist)
   EndIf

   If (_bFlagCheckArmLocked)
      If (_qDfwUtil.MutexLock(_iFlagsDataMutex))
         _bFlagCheckArmLocked = False
         _qDfwUtil.MutexRelease(_iFlagsDataMutex)
      EndIf

      Log("Checking Arms Locked", DL_TRACE, S_MOD)

      Bool bOldStatus = _bIsArmLocked
      _bIsArmLocked = False
      If (bWristCuffsKeyword)
         _bIsArmLocked = True
      ElseIf (_aPlayer.WornHasKeyword(_oKeywordZadArmBinder) || \
              _aPlayer.WornHasKeyword(_oKeywordZadYoke) || \
              _aPlayer.WornHasKeyword(_oKeywordZbfWornYoke))
         _bIsArmLocked = True
      EndIf
      ReportStatus("Arm Locked", _bIsArmLocked, bOldStatus)
   EndIf

   If (_bFlagCheckGagged)
      If (_qDfwUtil.MutexLock(_iFlagsDataMutex))
         _bFlagCheckGagged = False
         _qDfwUtil.MutexRelease(_iFlagsDataMutex)
      EndIf

      Log("Checking Gagged", DL_TRACE, S_MOD)

      Bool bOldStatus = _bIsGagged
      _bIsGagged = False
      If (_aPlayer.WornHasKeyword(_oKeywordZadGag) || \
          _aPlayer.WornHasKeyword(_oKeywordZbfWornGag))
         _bIsGagged = True
      EndIf
      ReportStatus("Gagged", _bIsGagged, bOldStatus)
   EndIf

   ; The Leg Cuffs Keyword is used in Hobbled and other restraints.  Keep track of it.
   Bool bLegCuffsKeyword = False
   If (_bFlagCheckHobbled || _bFlagCheckLockedUp)
      bLegCuffsKeyword = _aPlayer.WornHasKeyword(_oKeywordZadLegCuffs)
   EndIf

   If (_bFlagCheckHobbled)
      If (_qDfwUtil.MutexLock(_iFlagsDataMutex))
         _bFlagCheckHobbled = False
         _qDfwUtil.MutexRelease(_iFlagsDataMutex)
      EndIf

      Log("Checking Hobbled", DL_TRACE, S_MOD)

      ; Note on the check below:
      ; Sometimes ZBF restraints have wrist cuffs and ankle cuff combinations.
      ; These restraints can be ankle cuff hobbles that use the wrist keyword.
      ; Note also that some regular (non-hobble) wrist cuffs add a no sprint keyword.

      ; Note: ZBF Worn Ankles can be true even for basic non-connected leg cuffs.
      ; _aPlayer.WornHasKeyword(_oKeywordZbfWornAnkles) || \

      Bool bOldStatus = _bIsHobbled
      _bIsHobbled = False
      If (_aPlayer.WornHasKeyword(_oKeywordZadBoots) || \
          (bWristCuffsKeyword && (_aPlayer.WornHasKeyword(_oKeywordZbfEffectNoMove) || \
                                  _aPlayer.WornHasKeyword(_oKeywordZbfEffectSlowMove))) || \
          (bLegCuffsKeyword && (_aPlayer.WornHasKeyword(_oKeywordZbfEffectNoMove) || \
                                _aPlayer.WornHasKeyword(_oKeywordZbfEffectNoSprint) || \
                                _aPlayer.WornHasKeyword(_oKeywordZbfEffectSlowMove))))
         _bIsHobbled = True
      EndIf
      ReportStatus("Hobbled", _bIsHobbled, bOldStatus)

      ; If the player is now hobbled and it should block footwear remove that now.
      If (_bIsHobbled && !bOldStatus && _qMcm.bBlockHobble && _qMcm.bBlockShoes)
         Armor oFootwear = _aPlayer.GetWornForm(CS_FEET) As Armor

         If (IT_COVERINGS == GetItemType(oFootwear))
            ; Make sure the footwear is not on the exception list and remove it.
            If (-1 == _qMcm.aiBlockExceptionsHobble.Find(oFootwear.GetFormID()))
               Log("Your hobble is interfering with your " + oFootwear.GetName() + ".", \
                   DL_CRIT, S_MOD)
               _aPlayer.UnequipItem(oFootwear, abSilent=True)
            EndIf
         EndIf
      EndIf
   EndIf

   If (_bFlagCheckLockedUp)
      If (_qDfwUtil.MutexLock(_iFlagsDataMutex))
         _bFlagCheckLockedUp = False
         _qDfwUtil.MutexRelease(_iFlagsDataMutex)
      EndIf

      Log("Checking Locked Up", DL_TRACE, S_MOD)

      Int iOldStatus = _iNumOtherRestraints
      _bHiddenRestraints = False
      _iNumOtherRestraints = 0

      String szMessage = ""
      If (_aPlayer.WornHasKeyword(_oKeywordZadArmCuffs) || \
          _aPlayer.WornHasKeyword(_oKeywordZadGloves))
         szMessage += "Arms "
         _iNumOtherRestraints += 1
      EndIf
      ; Belted should really be a separate check but leave it here until we do that.
      _bIsBelted = (_aPlayer.WornHasKeyword(_oKeywordZadBelt) || \
                    _aPlayer.WornHasKeyword(_oKeywordZbfWornBelt))
      If (_bIsBelted || _aPlayer.WornHasKeyword(_oKeywordZadVagina))
         If (_bWaistCovered)
            _bHiddenRestraints = True
         Else
            szMessage += "Waist "
            _iNumOtherRestraints += 1
         EndIf
      EndIf
      If (_aPlayer.WornHasKeyword(_oKeywordZadBlindfold) || \
          _aPlayer.WornHasKeyword(_oKeywordZadHood) || \
          _aPlayer.WornHasKeyword(_oKeywordZbfWornBlindfold) || \
          _aPlayer.WornHasKeyword(_oKeywordZbfWornHood))
         szMessage += "Face "
         _iNumOtherRestraints += 1
      EndIf
      If (_aPlayer.WornHasKeyword(_oKeywordZadBra) || \
          _aPlayer.WornHasKeyword(_oKeywordZbfWornBra) || \
          _aPlayer.WornHasKeyword(_oKeywordZadClamps) || \
          _aPlayer.WornHasKeyword(_oKeywordZadNipple))
         If (_bChestCovered)
            _bHiddenRestraints = True
         Else
            szMessage += "Chest "
            _iNumOtherRestraints += 1
         EndIf
      EndIf
      If (_aPlayer.WornHasKeyword(_oKeywordZadCorset) || \
          _aPlayer.WornHasKeyword(_oKeywordZadHarness))
         If (Math.LogicalAnd(_iNakedStatus, NS_CHEST_PROTECTED))
            _bHiddenRestraints = True
         Else
            szMessage += "Body "
            _iNumOtherRestraints += 1
         EndIf
      EndIf
      If (bLegCuffsKeyword && !_bIsHobbled)
         szMessage += "Legs "
         _iNumOtherRestraints += 1
      EndIf
      If (_aPlayer.WornHasKeyword(_oKeywordZadFullSuit))
         szMessage += "Suit "
         _iNumOtherRestraints += 1
      EndIf
      If (_iNumOtherRestraints != iOldStatus)
         Log("Wearing " + _iNumOtherRestraints + " other restraints.", DL_INFO, S_MOD)
         Log(szMessage, DL_DEBUG, S_MOD)
      EndIf
   EndIf
EndEvent

; This is called from the player monitor script when an item equipped event is seen.
Function ItemEquipped(Form oItem, ObjectReference oReference)
   Int iType = GetItemType(oItem)
   If (!iType)
      Return
   EndIf

   If (IT_RESTRAINT == iType)
      ; Only check each restraint if the player is not already restrained.
      If (_qDfwUtil.MutexLock(_iFlagsDataMutex))
         _bFlagCheckCollared  = SetCheckFlag(_bFlagCheckCollared,  _bIsCollared,  False)
         _bFlagCheckArmLocked = SetCheckFlag(_bFlagCheckArmLocked, _bIsArmLocked, False)
         _bFlagCheckGagged    = SetCheckFlag(_bFlagCheckGagged,    _bIsGagged,    False)
         _bFlagCheckHobbled   = SetCheckFlag(_bFlagCheckHobbled,   _bIsHobbled,   False)
         ; We always have to check for various "other" restraints.
         _bFlagSet = True
         _bFlagCheckLockedUp  = True
         _qDfwUtil.MutexRelease(_iFlagsDataMutex)
      EndIf
   ElseIf (IT_COVERINGS == iType)
      ; If the player's clothes have changed always recheck how naked she is.
      If (_qDfwUtil.MutexLock(_iFlagsDataMutex))
         _bFlagCheckNaked = True
         _bFlagSet = True
         _qDfwUtil.MutexRelease(_iFlagsDataMutex)
      EndIf

      ; If we are configured to block clothing check that now.
      ; If the nearby master is assisting the player to dress allow her to dress as normal.
      If (IsAllowed(AP_DRESSING_ASSISTED))
         Return
      EndIf

      ; Start by getting a more detailed description of the item.
      iType = GetClothingType(oItem)

      ; First check if we are in a naked or post rape redress timeout.
      If (_fRapeRedressTimeout)
         If (_fRapeRedressTimeout > Utility.GetCurrentGameTime())
            Log("You are too exhausted from being raped to dress right now.", DL_CRIT, S_MOD)
            If (_qDfwUtil.MutexLock(_iGeneralDataMutex))
               _fRapeRedressTimeout = Utility.GetCurrentGameTime() + \
                                      ((_qMcm.iModRapeRedressTimeout As Float) / 1440)
               _qDfwUtil.MutexRelease(_iGeneralDataMutex)
            EndIf
            _aPlayer.UnequipItem(oItem, abSilent=True)
            Return
         EndIf
         If (_qDfwUtil.MutexLock(_iGeneralDataMutex))
            _fRapeRedressTimeout = 0
            _qDfwUtil.MutexRelease(_iGeneralDataMutex)
         EndIf
      EndIf
      If (_fNakedRedressTimeout)
         If (_fNakedRedressTimeout > Utility.GetCurrentGameTime())
            Log("You tried to dress too fast.  Now you have to start again.", DL_CRIT, S_MOD)
            If (_qDfwUtil.MutexLock(_iGeneralDataMutex))
               _fNakedRedressTimeout = Utility.GetCurrentGameTime() + \
                                       ((_qMcm.iModNakedRedressTimeout As Float) / 1440)
               _qDfwUtil.MutexRelease(_iGeneralDataMutex)
            EndIf
            _aPlayer.UnequipItem(oItem, abSilent=True)
            Return
         EndIf
         If (_qDfwUtil.MutexLock(_iGeneralDataMutex))
            _fNakedRedressTimeout = 0
            _qDfwUtil.MutexRelease(_iGeneralDataMutex)
         EndIf
      EndIf

      Bool bUnequip = False
      String szBlockedBy = "piercings"

      ; Keep track of whether arms or nipples piercings should be block.
      Bool bBlockArms = (_bIsArmLocked && _qMcm.bBlockArms)
      Bool bBlockNipple = (_qMcm.bBlockNipple && \
                           (_aPlayer.WornHasKeyword(_oKeywordZadNipple) || \
                            _aPlayer.WornHasKeyword(_oKeywordZadClamps)))
      Bool bBlockNippleBody = (bBlockNipple && _qMcm.bBlockArmour)
      Bool bBlockLeash = (_oLeashTarget && _qMcm.bBlockLeash)

      ; Check if the item should be blocked based on arm and nipple restrictions.
      Bool bIsBodySlot = Math.LogicalAnd(iType, IT_BODY_COVERINGS)
      Bool bIsChestSlot = Math.LogicalAnd(iType, IT_CHEST_COVERINGS)
      If (((bBlockArms || bBlockLeash || bBlockNippleBody) && bIsBodySlot) || \
          ((bBlockArms || bBlockLeash || bBlockNipple) && bIsChestSlot))
         bUnequip = True
         If (bBlockArms)
            szBlockedBy = "locked arms"
         ElseIf (bBlockLeash)
            szBlockedBy = "leash"
         EndIf
      EndIf

      ; Check if waist clothing should be blocked.
      If (!bUnequip)
         ; If this item is on the hobble exception list don't consider it blockable.
         Bool bBlockHobble = (_bIsHobbled && _qMcm.bBlockHobble)
         If (0 <= _qMcm.aiBlockExceptionsHobble.Find(oItem.GetFormID()))
            bBlockHobble = False
         EndIf

         ; Keep track of whether whether the vaginal piercings should block.
         Bool bBlockVagina = (_qMcm.bBlockVagina && \
                              _aPlayer.WornHasKeyword(_oKeywordZadVagina))

         ; Check if the item should be blocked based on hobble and vagina restrictions.
         Bool bIsWaistSlot = Math.LogicalAnd(iType, IT_WAIST_COVERINGS)
         If ((bBlockHobble || bBlockVagina) && \
             ((bIsBodySlot && _qMcm.bBlockArmour) || bIsWaistSlot))
            bUnequip = True
            If (bBlockHobble)
               szBlockedBy = "hobble"
            EndIf
         EndIf
      EndIf

      ; Check if footwear should be blocked.
      If (!bUnequip)
         If (_bIsHobbled && _qMcm.bBlockHobble && _qMcm.bBlockShoes)
            bUnequip = _qDfwUtil.IsFeetSlot((oItem As Armor).GetSlotMask())
            szBlockedBy = "hobble"
         EndIf
      EndIf

      If (bUnequip)
         Log("You can't equip \"" + oItem.GetName() + "\" over your " + szBlockedBy + ".", \
             DL_CRIT, S_MOD)
         _aPlayer.UnequipItem(oItem, abSilent=True)
      EndIf
   EndIf
EndFunction

; This is called from the player monitor script when an item unequipped event is seen.
Function ItemUnequipped(Form oItem, ObjectReference oReference)
   Int iType = GetItemType(oItem)
   If (!iType)
      Return
   EndIf

   If (IT_RESTRAINT == iType)
      If (_qDfwUtil.MutexLock(_iFlagsDataMutex))
         _bFlagCheckCollared  = SetCheckFlag(_bFlagCheckCollared,  _bIsCollared,  True)
         _bFlagCheckArmLocked = SetCheckFlag(_bFlagCheckArmLocked, _bIsArmLocked, True)
         _bFlagCheckGagged    = SetCheckFlag(_bFlagCheckGagged,    _bIsGagged,    True)
         _bFlagCheckHobbled   = SetCheckFlag(_bFlagCheckHobbled,   _bIsHobbled,   True)
         If (_iNumOtherRestraints)
            _bFlagSet = True
            _bFlagCheckLockedUp  = True
         EndIf
         _qDfwUtil.MutexRelease(_iFlagsDataMutex)
      EndIf

      ; Try to fix Devious Devices being unequipped by the Favourites clear armour mechanism.
      If (_qMcm.bSettingsDetectUnequip && oItem.HasKeyword(_oKeywordZadLockable))
         ; Note about devious devices.  All functions work on inventory items.  There isn't
         ; really anything you can do with rendered (worn) devices.  As such we will be
         ; identifying the Keyword device manually.

         ; The problem is if the item is worn but not the keyword.  Check the keyword now.
         Keyword oDeviousKeyword = GetDeviousKeyword(oItem As Armor)
         If (oDeviousKeyword && !_aPlayer.WornHasKeyword(oDeviousKeyword))
            Log("Trying Devious Fix...", DL_DEBUG, S_MOD)

            ; Search the inventory for a "Devious Inventory" item with the same keyword.
            Int iIndex = _aPlayer.GetNumItems() - 1
            While (0 <= iIndex)
               ; Check the item is an inventory item, is equipped and has the right keyword.
               Form oInventoryItem = _aPlayer.GetNthForm(iIndex)
               If (oInventoryItem.HasKeyword(_oKeywordZadInventoryDevice))
                  If (oInventoryItem.HasKeyword(_oKeywordZadInventoryDevice) && \
                      _aPlayer.IsEquipped(oInventoryItem) && \
                      (oDeviousKeyword == _qZadLibs.GetDeviceKeyword(oInventoryItem As Armor)))
                     ; Re-equip the original item (Not the inventory item).
                     _aPlayer.EquipItem(oItem)
                  EndIf
               EndIf
               iIndex -= 1
            EndWhile
         EndIf
      EndIf
   ElseIf (IT_COVERINGS == iType)
      ; If the player's clothes have changed always recheck how naked she is.
      If (_qDfwUtil.MutexLock(_iFlagsDataMutex))
         _bFlagCheckNaked = True
         _bFlagSet = True
         _qDfwUtil.MutexRelease(_iFlagsDataMutex)
      EndIf
   EndIf
EndFunction

; This is called from the player monitor script when an enter bleedout event is seen.
Function EnteredBleedout()
   If (_qDfwUtil.MutexLock(_iGeneralDataMutex))
      _iBleedoutTime = Utility.GetCurrentRealTime() + 30
      _qDfwUtil.MutexRelease(_iGeneralDataMutex)
   EndIf
EndFunction

; This is called from the _dfwNearbyDetectorEffect magic effect when it starts.
Function NearbyActorSeen(Actor aActor)
   ; If this actor is already in the nearby actor list ignore him.
   Int iIndex = _aoNearby.Find(aActor)
   If (0 <= iIndex)
      Return
   EndIf

   ; Otherwise just add the actor to the nearby actor list.
   Log("Registering Nearby: " + aActor.GetDisplayName(), DL_TRACE, S_MOD)

   ; Perform some basic estimations for flags of this actor.
   Int iFlags = AF_ESTIMATE
   If (aActor.IsChild())
      iFlags = Math.LogicalOr(AF_CHILD, iFlags)
   ElseIf (aActor.IsGuard())
      iFlags = Math.LogicalOr(AF_GUARDS, iFlags)
   ElseIf (aActor.IsInFaction(_oFactionMerchants))
      iFlags = Math.LogicalOr(AF_MERCHANTS, iFlags)
   EndIf
   If (aActor.IsHostileToActor(_aPlayer))
      iFlags = Math.LogicalOr(AF_HOSTILE, iFlags)
   EndIf

   ; SLA definition of important: Unique or Essential or invulnerable or protected, etc.
   If (_qSexLabArousedMain.IsImportant(aActor))
      iFlags = Math.LogicalOr(AF_IMPORTANT, iFlags)
   EndIf

   ; Animals are now blocked at the spell effect stage.  We will never get them here.
   ; Race oRace = aActor.GetRace()
   ; If (!oRace.IsPlayable())
   ;    iFlags = Math.LogicalOr(AF_ANIMAL, iFlags)
   ; EndIf

   If (aActor.IsInFaction(_oFactionHydraSlaver) || _qZbfSlave.IsSlaver(aActor))
      ; Check if the actor deals in trading slaves.  Check this first as they can
      ; sometimes be wearing restraints too.
      iFlags = Math.LogicalOr(AF_DOMINANT, iFlags)
      iFlags = Math.LogicalOr(AF_SLAVE_TRADER, iFlags)
      iFlags = Math.LogicalOr(AF_OWNER, iFlags)
   ElseIf (_qZbfSlave.IsSlave(aActor))
      ; Check if the actor is a slave, first on Zbf status and then on worn items.
      iFlags = Math.LogicalOr(AF_SUBMISSIVE, iFlags)
      iFlags = Math.LogicalOr(AF_SLAVE, iFlags)
   ElseIf (aActor.WornHasKeyword(_oKeywordZadLockable) || \
           aActor.WornHasKeyword(_oKeywordZadInventoryDevice) || \
           aActor.WornHasKeyword(_oKeywordZbfWornDevice))
      iFlags = Math.LogicalOr(AF_SUBMISSIVE, iFlags)
      ; If they are wearing a collar or their arms are heavily restrained also identify
      ; them as a slave.
      If (aActor.WornHasKeyword(_oKeywordZadArmBinder) || \
          aActor.WornHasKeyword(_oKeywordZadCollar) || \
          aActor.WornHasKeyword(_oKeywordZadCorset) || \
          aActor.WornHasKeyword(_oKeywordZadHarness) || \
          aActor.WornHasKeyword(_oKeywordZadFullSuit) || \
          aActor.WornHasKeyword(_oKeywordZadYoke) || \
          aActor.WornHasKeyword(_oKeywordZbfWornCollar) || \
          aActor.WornHasKeyword(_oKeywordZbfWornWrist) || \
          aActor.WornHasKeyword(_oKeywordZbfWornYoke))
         iFlags = Math.LogicalOr(AF_SLAVE, iFlags)
      EndIf
   Else
      ; For now treat anyone not restrained as a dominant.
      iFlags = Math.LogicalOr(AF_DOMINANT, iFlags)

      ; If the actor owns a slave mark Him as a slave owner.
      If (_qZbfSlave.IsMaster(aActor))
         iFlags = Math.LogicalOr(AF_OWNER, iFlags)
      EndIf
   EndIf

   ; Add the actor to the known actors lists.
   If (_qDfwUtil.MutexLock(_iNearbyMutex))
      _aoNearby = _qDfwUtil.AddFormToArray(_aoNearby, aActor, True)
      _aiNearbyFlags = _qDfwUtil.AddIntToArray(_aiNearbyFlags, iFlags, True)

      _qDfwUtil.MutexRelease(_iNearbyMutex)
   EndIf

   If (_aoNearby.Length != _aiNearbyFlags.Length)
      Log("Nearby Added Wrong: " + _aoNearby.Length + " != " + _aiNearbyFlags.Length, DL_CRIT, \
          S_MOD)
   EndIf

   ; Send out a mod event to notify other modules there is a new nearby actor.
   Int iModEvent = ModEvent.Create("DFW_NearbyActor")
   If (iModEvent)
      ModEvent.PushInt(iModEvent, iFlags)
      ModEvent.PushForm(iModEvent, aActor)
      ModEvent.Send(iModEvent)
   EndIf

   If (_qMcm.iModSlaThreshold)
      Int iArousal = _qSexLabAroused.GetActorArousal(aActor)
      If ((0 <= iArousal) && (_qMcm.iModSlaThreshold > iArousal))
         ; For slaves, submissives, and owners increase the minimum arousal value.
         Int iMin = _qMcm.iModSlaAdjustedMin
         If (Math.LogicalOr(AF_BDSM_AWARE, iFlags))
            iMin = (_qMcm.iModSlaAdjustedMax + iMin) / 2
         EndIf

         Float fExposureRate = _qSexLabAroused.GetActorExposureRate(aActor)
         Float fNewArousal = Utility.RandomFloat(iMin, _qMcm.iModSlaAdjustedMax)

         Int iSlaExposureEvent = ModEvent.Create("slaUpdateExposure")
         ModEvent.PushForm(iSlaExposureEvent, aActor)
         ModEvent.PushFloat(iSlaExposureEvent, ((fNewArousal / fExposureRate) - iArousal))
         ModEvent.Send(iSlaExposureEvent)

         Log(aActor.GetDisplayName() + " not aroused (" + iArousal + ").  Adjusted: " + \
             fNewArousal, DL_DEBUG, S_MOD)
      EndIf
   EndIf
EndFunction

Event PostSexCallback(String szEvent, String szArg, Float fNumArgs, Form oSender)
   ; If the player is the victim start a post-rape redress timeout.
   If (_qMcm.iModRapeRedressTimeout && (_aPlayer == _qSexLab.HookVictim(szArg)))
      If (_qDfwUtil.MutexLock(_iGeneralDataMutex))
         _fRapeRedressTimeout = Utility.GetCurrentGameTime() + \
                                ((_qMcm.iModRapeRedressTimeout As Float) / 1440)
         _qDfwUtil.MutexRelease(_iGeneralDataMutex)
      EndIf
   EndIf
EndEvent


;***********************************************************************************************
;***                                  PRIVATE FUNCTIONS                                      ***
;***********************************************************************************************
Function ReportStatus(String szStatusType, Bool bStatus, Bool bOldStatus)
   ; If the status has changed log that information.
   If (bOldStatus && !bStatus)
      Log("You are no longer " + szStatusType + ".", DL_INFO, S_MOD)
   ElseIf (!bOldStatus && bStatus)
      Log("You are now " + szStatusType + ".", DL_INFO, S_MOD)
   EndIf
EndFunction

; Note about devious devices.  All functions work on inventory items.  There isn't really
; anything you can do with rendered (worn) devices.  As such we will be identifying the
; Keyword device manually.
Keyword Function GetDeviousKeyword(Armor oItem)
   If (oItem.HasKeyword(_oKeywordZadGag))
      Return _oKeywordZadGag
   ElseIf (oItem.HasKeyword(_oKeywordZadArmCuffs))
      Return _oKeywordZadArmCuffs
   ElseIf (oItem.HasKeyword(_oKeywordZadLegCuffs))
      Return _oKeywordZadLegCuffs
   ElseIf (oItem.HasKeyword(_oKeywordZadCollar))
      Return _oKeywordZadCollar
   ElseIf (oItem.HasKeyword(_oKeywordZadHarness))
      Return _oKeywordZadHarness
   ElseIf (oItem.HasKeyword(_oKeywordZadArmBinder))
      Return _oKeywordZadArmBinder
   ElseIf (oItem.HasKeyword(_oKeywordZadBelt))
      Return _oKeywordZadBelt
   ElseIf (oItem.HasKeyword(_oKeywordZadBlindfold))
      Return _oKeywordZadBlindfold
   ElseIf (oItem.HasKeyword(_oKeywordZadBoots))
      Return _oKeywordZadBoots
   ElseIf (oItem.HasKeyword(_oKeywordZadBra))
      Return _oKeywordZadBra
   ElseIf (oItem.HasKeyword(_oKeywordZadGloves))
      Return _oKeywordZadGloves
   ElseIf (oItem.HasKeyword(_oKeywordZadCorset))
      Return _oKeywordZadCorset
   ElseIf (oItem.HasKeyword(_oKeywordZadClamps))
      Return _oKeywordZadClamps
   ElseIf (oItem.HasKeyword(_oKeywordZadHood))
      Return _oKeywordZadHood
   ElseIf (oItem.HasKeyword(_oKeywordZadNipple))
      Return _oKeywordZadNipple
   ElseIf (oItem.HasKeyword(_oKeywordZadVagina))
      Return _oKeywordZadVagina
   ElseIf (oItem.HasKeyword(_oKeywordZadFullSuit))
      Return _oKeywordZadFullSuit
   ElseIf (oItem.HasKeyword(_oKeywordZadYoke))
      Return _oKeywordZadYoke
   EndIf
   Return None
EndFunction

Bool Function CheckLeashInterruptScene()
   ; If the player is not in a scene, nothing to worry about.
   If (!IsPlayerCriticallyBusy(False))
      Return True
   EndIf

   ; If we are supposed to interrupt SexLab Scenes try to do that now.
   If (_qMcm.bModLeashInterrupt)
      _qSexLab.GetPlayerController().EndAnimation(True)
      ; Try to give the SexLab mod a little time to end the scene.
      Utility.Wait(0.25)
   EndIf

   ; If the player is still busy report a failure.
   If (IsPlayerCriticallyBusy(False))
      Return False
   EndIf
   Return True
EndFunction

; This only identifies the type Clothing (including armour), restraints, or none.
; Other functions should provide more detailed information based on the type of item.
Int Function GetItemType(Form oItem)
   ; Make sure the item exists and is some form of "armour".
   If (!oItem && (26 == oItem.GetType()))
      Return IT_NONE
   EndIf

   ; Get the item's name and slot.
   String szName = oItem.GetName()
   Int iItemSlotMask = (oItem As Armor).GetSlotMask()

   ; Check to see if it is some form of restraint.
   If (oItem.HasKeyword(_oKeywordZadLockable) || oItem.HasKeyword(_oKeywordZbfWornDevice) || \
       oItem.HasKeyword(_oKeywordZadInventoryDevice))
      Log(szName + ": Restraint.", DL_DEBUG, S_MOD)
      Return IT_RESTRAINT
   EndIf

   ; Armour and clothing need to have a name and a slot.
   ; Items with no name or slot are assumed (at least at this point) to be unknown items.
   If (!szName || !iItemSlotMask)
      Return IT_NONE
   EndIf

   ; Otherwise check all clothing/armour keywords.
   If (oItem.HasKeyword(_oKeywordClothes) || oItem.HasKeyword(_oKeywordArmourLight) || \
       oItem.HasKeyword(_oKeywordArmourHeavy))
      Log(szName + ": Is Clothing/Armour.", DL_TRACE, S_MOD)
      Return IT_COVERINGS
   EndIf

   Log(szName + " Not Clothing.", DL_TRACE, S_MOD)
   Return IT_NONE
EndFunction

; This basic function runs a detailed analysis on the item.
; This returns a detailed identification of a "coverings" item (clothes, light or heavy armour).
; It is assumed that GetItemType() has already returned IT_COVERINGS for this item.
Int Function GetClothingType(Form oItem)
   ; Clothing comes in many forms: Body, chest, waist - Clothing, Light/Heavy Armour - Partial.
   Int iType = IT_NONE
   If (oItem.HasKeyword(_oKeywordClothes))
      iType = IT_CLOTHES_OTHER
   ElseIf (oItem.HasKeyword(_oKeywordArmourLight))
      iType = IT_LIGHT_OTHER
   ElseIf (oItem.HasKeyword(_oKeywordArmourHeavy))
      iType = IT_HEAVY_OTHER
   EndIf

   Int iItemSlotMask = (oItem As Armor).GetSlotMask()
   If (iType)
      ; Also check where it is worn based on the slot.
      If (_qDfwUtil.IsBodySlot(iItemSlotMask))
         If (IT_LIGHT_OTHER == iType)
            iType = IT_LIGHT_BODY
         ElseIf (IT_HEAVY_OTHER == iType)
            iType = IT_HEAVY_BODY
         Else
            iType = IT_CLOTHES_BODY
         EndIf
      ElseIf (_qDfwUtil.IsChestSlot(iItemSlotMask))
         If (IT_LIGHT_OTHER == iType)
            iType = IT_LIGHT_CHEST
         ElseIf (IT_HEAVY_OTHER == iType)
            iType = IT_HEAVY_CHEST
         Else
            iType = IT_CLOTHES_CHEST
         EndIf
      ElseIf (_qDfwUtil.IsWaistSlot(iItemSlotMask))
         If (IT_LIGHT_OTHER == iType)
            iType = IT_LIGHT_WAIST
         ElseIf (IT_HEAVY_OTHER == iType)
            iType = IT_HEAVY_WAIST
         Else
            iType = IT_CLOTHES_WAIST
         EndIf
      EndIf

      ; If it is considered "Naked" by SexLab Aroused make sure to mark it as "partial".
      If (StorageUtil.GetIntValue(oItem, "SLAroused.IsNakedArmor", 0))
         Return Math.LogicalOr(iType, IT_PARTIAL)
      EndIf
   EndIf
   Return iType
EndFunction

Function CheckIsNaked(Actor aActor=None)
   If (!aActor)
      aActor = _aPlayer
   EndIf

   ; As default set that no vulnerability reduction is in effect.
   _bNakedReduced = False
   _bChestReduced = False
   _bWaistReduced = False

   ; First check the player's body piece.  If one is worn they are not naked.
   Form oWornItem = aActor.GetWornForm(CS_BODY)
   If (oWornItem)
      Log("Body: \"" + oWornItem.GetName() + "\"", DL_DEBUG, S_MOD)
   EndIf
   If (IT_COVERINGS == GetItemType(oWornItem))
      _iNakedStatus = NS_BOTH_COVERED
      _bChestCovered = True
      _bWaistCovered = True

      ; If the clothing is "Naked" from SexLab Aroused consider it naked but reduced.
      If (StorageUtil.GetIntValue(oWornItem, "SLAroused.IsNakedArmor", 0))
         _iNakedStatus = NS_BOTH_PARTIAL
         _bChestReduced = True
         _bWaistReduced = True
      EndIf
      Return
   EndIf

   ; Then check chest slots if any are specified.
   _bChestCovered = False
   _bChestReduced = False
   Int iIndex = _qMcm.aiSettingsSlotsChest.Length - 1
   While (!_bChestCovered && (0 <= iIndex))
      oWornItem = aActor.GetWornForm(_qMcm.aiSettingsSlotsChest[iIndex])
      If (oWornItem)
         Log("Chest: \"" + oWornItem.GetName() + "\"", DL_DEBUG, S_MOD)
      EndIf
      If (IT_COVERINGS == GetItemType(oWornItem))
         ; If the clothing is "Naked" from SexLab Aroused consider it naked but reduced.
         _bChestCovered = True
         If (StorageUtil.GetIntValue(oWornItem, "SLAroused.IsNakedArmor", 0))
            _bChestReduced = True
         EndIf
      EndIf
      iIndex -= 1
   EndWhile

   ; Now check the waist.
   _bWaistCovered = False
   _bWaistReduced = False
   iIndex = _qMcm.aiSettingsSlotsWaist.Length - 1
   While (!_bWaistCovered && (0 <= iIndex))
      oWornItem = aActor.GetWornForm(_qMcm.aiSettingsSlotsWaist[iIndex])
      If (oWornItem)
         Log("Waist: \"" + oWornItem.GetName() + "\"", DL_DEBUG, S_MOD)
      EndIf
      If (IT_COVERINGS == GetItemType(oWornItem))
         ; If the clothing is "Naked" from SexLab Aroused consider it naked but reduced.
         _bWaistCovered = True
         If (StorageUtil.GetIntValue(oWornItem, "SLAroused.IsNakedArmor", 0))
            _bWaistReduced = True
         EndIf
      EndIf
      iIndex -= 1
   EndWhile


   ; If the player's chest is covered in seductive clothing only consider it valid if a waist
   ; piece is also worn.  The same is true of the player's waist coverings.
   If (_bChestCovered && _bChestReduced && !_bWaistCovered)
      _bChestCovered = False
   ElseIf (_bWaistCovered && _bWaistReduced && !_bChestCovered)
      _bWaistCovered = False
   EndIf

   If (_bChestCovered && _bWaistCovered)
      If (_bChestReduced || _bWaistReduced)
         _iNakedStatus = NS_BOTH_PARTIAL
      Else
         _iNakedStatus = NS_BOTH_COVERED
      EndIf
   ElseIf (_bChestReduced)
      _iNakedStatus = NS_CHEST_PARTIAL
   ElseIf (_bChestCovered)
      _iNakedStatus = NS_CHEST_COVERED
   ElseIf (_bWaistReduced)
      _iNakedStatus = NS_WAIST_PARTIAL
   ElseIf (_bWaistCovered)
      _iNakedStatus = NS_WAIST_COVERED
   Else
      Log("Player is Naked.", DL_TRACE, S_MOD)
      _iNakedStatus = NS_NAKED
   EndIf
EndFunction

Function CleanupNearbyList()
   ; If we have done a cleanup too recently don't try again.
   If (_fNearbyCleanupTime && (Utility.GetCurrentRealTime() < _fNearbyCleanupTime))
      Return
   EndIf

   Cell oPlayerCell = _aPlayer.GetParentCell()
   Int iIndex = _aoNearby.Length - 1
   While (0 <= iIndex)
      Actor aNearby = (_aoNearby[iIndex] As Actor)
      ; I'm not sure what distance spell ranges are in (iSettingsNearbyDistance) but it must be
      ; converted to the same units as GetDistance().  A rough estimate is 22.2 to 1.  Add extra
      ; so the actor is removed at a notably longer distance than he is added.
      If ((30 * _qMcm.iSettingsNearbyDistance) < aNearby.GetDistance(_aPlayer))
         Log("Clear Nearby: " + (_aoNearby[iIndex] As Actor).GetDisplayName(), DL_TRACE, S_MOD)
         ; This actor is too far from the player.  Remove him from the list.
         If (_qDfwUtil.MutexLock(_iNearbyMutex))
            _aoNearby = _qDfwUtil.RemoveFormFromArray(_aoNearby, None, iIndex)
            _aiNearbyFlags = _qDfwUtil.RemoveIntFromArray(_aiNearbyFlags, 0, iIndex)

            _qDfwUtil.MutexRelease(_iNearbyMutex)
         EndIf
         If (_aoNearby.Length != _aiNearbyFlags.Length)
            Log("Nearby Removed Wrong: " + _aoNearby.Length + " != " + _aiNearbyFlags.Length, \
                DL_CRIT, S_MOD)
         EndIf

         ; Dispel the current nearby detector spell so he can be detected again.
         aNearby.DispelSpell(_oDfwNearbyDetectorSpell)
      EndIf
      iIndex -= 1
   EndWhile

   ; Don't try to clean up the nearby list more than every three seconds.
   If (_qDfwUtil.MutexLock(_iGeneralDataMutex))
      _fNearbyCleanupTime = Utility.GetCurrentRealTime() + 3
      _qDfwUtil.MutexRelease(_iGeneralDataMutex)
   EndIf
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

Bool Function SetCheckFlag(Bool bFlagToSet, Bool bCurrStatus, Bool bExpectedStatus)
   ; If the player's status is as expected return that we need to permform the check.
   If (bCurrStatus == bExpectedStatus)
      ; Set the flag to indicate one of the status check flags has been set.
      If (_qDfwUtil.MutexLock(_iFlagsDataMutex))
         _bFlagSet = True
         _qDfwUtil.MutexRelease(_iFlagsDataMutex)
      EndIf
      Return True
   EndIf
   ; If the player's status isn't the desired status return the current status of the flag.
   Return bFlagToSet
EndFunction

Function UpdatePollingInterval(Float fNewInterval)
   RegisterForUpdate(fNewInterval)
EndFunction

Function UpdatePollingDistance(Int iNewDistance)
   _oDfwNearbyDetectorSpell.SetNthEffectArea(0, iNewDistance)
EndFunction

Int Function SetMasterClose(Actor aNewMaster, Int iPermissions, String szMod, Bool bOverride)
   If (!_aMasterClose || bOverride)
      Actor aOldMaster = _aMasterClose
      String szOldMod = _aMasterModClose
      If (_qDfwUtil.MutexLock(_iGeneralDataMutex))
         _aMasterClose = aNewMaster
         _aMasterModClose = szMod
         _iPermissionsClose = iPermissions
         _qDfwUtil.MutexRelease(_iGeneralDataMutex)
      EndIf
      If (aOldMaster)
         Log("Overriding " + aOldMaster.GetDisplayName() + " (" + szOldMod + ")", \
             DL_CRIT, S_MOD)
         ; If we were overriding a master send out a mod event to notify the old mod.
         Int iModEvent = ModEvent.Create("DFW_NewMaster")
         If (iModEvent)
            ModEvent.PushString(iModEvent, szOldMod)
            ModEvent.PushForm(iModEvent, aOldMaster)
            ModEvent.Send(iModEvent)
         EndIf
         Return WARNING
      EndIf
      Return SUCCESS
   EndIf
   Log("Existing Master " + _aMasterClose.GetDisplayName() + " (" + _aMasterModClose + ")", \
       DL_CRIT, S_MOD)
   Return FAIL
EndFunction

Int Function SetMasterDistant(Actor aNewMaster, Int iPermissions, String szMod, Bool bOverride)
   If (!_aMasterDistant || bOverride)
      Actor aOldMaster = _aMasterDistant
      String szOldMod = _aMasterModDistant
      If (_qDfwUtil.MutexLock(_iGeneralDataMutex))
         _aMasterDistant = aNewMaster
         _aMasterModDistant = szMod
         _iPermissionsDistant = iPermissions
         _qDfwUtil.MutexRelease(_iGeneralDataMutex)
      EndIf
      If (aOldMaster)
         Log("Overriding " + aOldMaster.GetDisplayName() + " (" + szOldMod + ")", \
             DL_CRIT, S_MOD)
         Return WARNING
      EndIf
      Return SUCCESS
   EndIf
   Log("Existing Master " + _aMasterDistant.GetDisplayName() + " (" + _aMasterModDistant \
       + ")", DL_CRIT, S_MOD)
   Return FAIL
EndFunction


;***********************************************************************************************
;***                                   PUBLIC FUNCTIONS                                      ***
;***********************************************************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Basic API Documentation:
;   String GetModVersion()
;    Actor GetMaster(Int iMasterDistance, Int iInstance)
;   String GetMasterMod(Int iMasterDistance, Int iInstance)
;      Int SetMaster(Actor aNewMaster, String szMod, Int iPermissions,
;                    Int iMasterDistance, Bool bOverride)
;      Int ClearMaster(Actor aMaster, Bool bEscaped)
;      Int ChangeMasterDistance(Actor aMaster, Bool bMoveToDistant, Bool bOverride)
;      Int GetNakedLevel()
;     Bool IsPlayerBound(Bool bIncludeHidden, Bool bOnlyLocked)
;     Bool IsPlayerArmLocked()
;     Bool IsPlayerBelted()
;     Bool IsPlayerCollared()
;     Bool IsPlayerGagged()
;     Bool IsPlayerHobbled()
;      Int GetVulnerability(Actor aActor)
;   Form[] GetNearbyActorList(Float fMaxDistance, Int iIncludeFlags, Int iExcludeFlags)
;    Int[] GetNearbyActorFlags()
;    Actor GetRandomActor(Float fMaxDistance, Int iIncludeFlags, Int iExcludeFlags)
;    Actor GetNearestActor(Float fMaxDistance, Int iIncludeFlags, Int iExcludeFlags)
;    Actor GetPlayerTalkingTo()
;          SetLeashTarget(ObjectReference oLeashTarget)
;          SetLeashLength(Int iLength)
;          YankLeash()
;     Bool IsPlayerCriticallyBusy(Bool bIncludeBleedout)
;          BlockHealthRegen()
;          RestoreHealthRegen()
;          BlockMagickaRegen()
;          RestoreMagickaRegen()
;          DisableMagicka(Bool bDisable)
;          BlockStaminaRegen()
;          RestoreStaminaRegen()
;          DisableStamina(Bool bDisable)
;     Bool IsAllowed(Int iAction)
;          AddPermission(Actor aMaster, Int iPermissionMask)
;          RemovePermission(Actor aMaster, Int iPermissionMask)
; ModEvent DFW_NewMaster(String szOldMod, Actor aOldMaster)
;          *** Warning: The following event is triggered often.  Handling it should be fast! ***
; ModEvent DFW_NearbyActor(Int iFlags, Actor aActor)
;

String Function GetModVersion()
   Return "0.0001"
EndFunction

; TODO: Support any and all distances.
Actor Function GetMaster(Int iMasterDistance=0x00000001, Int iInstance=1)
   If (MD_DISTANT == iMasterDistance)
      Return _aMasterDistant
   EndIf
   Return _aMasterClose
EndFunction

String Function GetMasterMod(Int iMasterDistance=0x00000001, Int iInstance=1)
   If (MD_DISTANT == iMasterDistance)
      If (_aMasterDistant)
         Return _aMasterModDistant
      EndIf
   ElseIf (_aMasterClose)
      Return _aMasterModClose
   EndIf
   Return ""
EndFunction

; szMod: Only used to display which Mod controls the Master.  Can be any short string.
; A mod should only allow sex if it can handle the player randomly and spontaneously being taken
; into a sex scene.  If a mod allows enslavement, register for the mod event (to be documented)
; to figure our when your mod looses control of the player.
Int Function SetMaster(Actor aNewMaster, String szMod, Int iPermissions, \
                       Int iMasterDistance=0x00000004, Bool bOverride=False)
   String szName = "None"
   If (aNewMaster)
      szName = aNewMaster.GetDisplayName()
   EndIf
   Log("New Master [" + szMod + "]-" + iMasterDistance + ": " + szName, DL_INFO, S_MOD)

   ; If a distant master is specified set our local "distant master" variable.
   Int iStatus
   If (MD_DISTANT == iMasterDistance)
      iStatus = SetMasterDistant(aNewMaster, iPermissions, szMod, bOverride)
   Else
      iStatus =  SetMasterClose(aNewMaster, iPermissions, szMod, bOverride)
   EndIf
   If (SUCCESS <= iStatus)
      ; Register the player enslavement with the ZAZ Animation Pack as well.
      aNewMaster.AddToFaction(_qZbfSlave.zbfFactionMaster)
      aNewMaster.AddToFaction(_qZbfSlave.zbfFactionPlayerMaster)
      _qZbfSlave.EnslaveActor(_aPlayer, szMod)
   EndIf
   Return iStatus
EndFunction

Int Function ClearMaster(Actor aMaster, Bool bEscaped=False)
   String szName = "None"
   If (aMaster)
      szName = aMaster.GetDisplayName()
   EndIf
   Log("Clearing Master: " + szName, DL_INFO, S_MOD)

   ; Clear the Master with the ZAZ Animation Pack as well.
   aMaster.RemoveFromFaction(_qZbfSlave.zbfFactionMaster)
   aMaster.RemoveFromFaction(_qZbfSlave.zbfFactionPlayerMaster)

   String szControllingMod
   Int iStatus = WARNING
   If (_aMasterClose == aMaster)
      If (_qDfwUtil.MutexLock(_iGeneralDataMutex))
         _aMasterClose = None
         _qDfwUtil.MutexRelease(_iGeneralDataMutex)
      EndIf
      szControllingMod = _aMasterModClose
      iStatus = SUCCESS
   EndIf
   If (_aMasterDistant == aMaster)
      If (_qDfwUtil.MutexLock(_iGeneralDataMutex))
         _aMasterDistant = None
         _qDfwUtil.MutexRelease(_iGeneralDataMutex)
      EndIf
      szControllingMod = _aMasterModDistant
      iStatus = SUCCESS
   EndIf

   ; Clear the player as a slave from the ZAZ Animation Pack if no one else is controlling her.
   If (szControllingMod && !_aMasterClose && !_aMasterDistant)
      _qZbfSlave.ReleaseSlave(_aPlayer, szControllingMod, bEscaped)
   EndIf
   Return iStatus
EndFunction

Int Function ChangeMasterDistance(Actor aMaster, Bool bMoveToDistant=True, Bool bOverride=False)
   String szName = "None"
   If (aMaster)
      szName = aMaster.GetDisplayName()
   EndIf
   Log("Changing Master Distance: " + szName, DL_INFO, S_MOD)

   If (bMoveToDistant)
      ; If the specified Master is not close we can't move him to a distant master.
      If (_aMasterClose != aMaster)
         If (_aMasterDistant != aMaster)
            Log("Current Master differs " + _aMasterClose.GetDisplayName() + " (" + \
                _aMasterModClose + ")", DL_ERROR, S_MOD)
            Return FAIL
         EndIf
         ; It is only a warning if the specified Master is already distant.
         Log("Already Distant.", DL_DEBUG, S_MOD)
         Return WARNING
      EndIf

      Int iStatus = SetMasterDistant(aMaster, _iPermissionsClose, _aMasterModClose, bOverride)
      If (SUCCESS <= iStatus)
         If (_qDfwUtil.MutexLock(_iGeneralDataMutex))
            _aMasterClose = None
            _qDfwUtil.MutexRelease(_iGeneralDataMutex)
         EndIf
      EndIf
      Return iStatus
   EndIf

   ; If the specified Master is not distant we can't move him to a close master.
   If (_aMasterDistant != aMaster)
      If (_aMasterClose != aMaster)
         Log("Current Master differs " + _aMasterDistant.GetDisplayName() + " (" + \
             _aMasterModDistant + ")", DL_ERROR, S_MOD)
         Return FAIL
      EndIf
      ; It is only a warning if the specified Master is already close.
      Log("Already Close.", DL_DEBUG, S_MOD)
      Return WARNING
   EndIf

   Int iStatus = SetMasterClose(aMaster, _iPermissionsDistant, _aMasterModDistant, bOverride)
   If (SUCCESS <= iStatus)
      If (_qDfwUtil.MutexLock(_iGeneralDataMutex))
         _aMasterDistant = None
         _qDfwUtil.MutexRelease(_iGeneralDataMutex)
      EndIf
   EndIf
   Return iStatus
EndFunction

Int Function GetNakedLevel()
   Return _iNakedStatus
EndFunction

; Note: Currently bOnlyLocked is not supported.
Bool Function IsPlayerBound(Bool bIncludeHidden=False, Bool bOnlyLocked=False)
   If (_bIsCollared || _bIsArmLocked        || _bIsGagged || \
       _bIsHobbled  || _iNumOtherRestraints || \
       (_bHiddenRestraints && bIncludeHidden))
      Return True
   EndIf
   Return False
EndFunction

Bool Function IsPlayerArmLocked()
   Return _bIsArmLocked
EndFunction

Bool Function IsPlayerBelted()
   Return _bIsBelted
EndFunction

Bool Function IsPlayerCollared()
   Return _bIsCollared
EndFunction

Bool Function IsPlayerGagged()
   Return _bIsGagged
EndFunction

Bool Function IsPlayerHobbled()
   Return _bIsHobbled
EndFunction

; Never returns more than 100.
Int Function GetVulnerability(Actor aActor=None)
   If (!aActor)
      aActor = _aPlayer
   EndIf

   Int iVulnerability = 0

   If (_aPlayer == aActor)
      If (NS_NAKED == _iNakedStatus)
         ; Both slots are naked.
         iVulnerability += _qMcm.iVulnerabilityNude
      ElseIf ((NS_WAIST_PARTIAL == _iNakedStatus) || (NS_CHEST_PARTIAL == _iNakedStatus))
         ; One slot is naked and the other is reduced.
         iVulnerability += _qMcm.iVulnerabilityNude / 2
         iVulnerability += (_qMcm.iVulnerabilityNude * _qMcm.iVulnerabilityNakedReduce / \
                            100 / 2)
      ElseIf ((NS_WAIST_COVERED == _iNakedStatus) || (NS_WAIST_COVERED == _iNakedStatus))
         ; One slot is naked.
         iVulnerability += _qMcm.iVulnerabilityNude / 2
      ElseIf (NS_BOTH_PARTIAL == _iNakedStatus)
         ; Both slots are worn but reduced.
         iVulnerability += (_qMcm.iVulnerabilityNude * _qMcm.iVulnerabilityNakedReduce / 100)
      EndIf
      If (_bIsCollared)
         iVulnerability += _qMcm.iVulnerabilityCollar
      EndIf
      If (_bIsArmLocked)
         iVulnerability += _qMcm.iVulnerabilityBinder
      EndIf
      If (_bIsGagged)
         iVulnerability += _qMcm.iVulnerabilityGagged
      EndIf
      Int iNumRestraints = _iNumOtherRestraints
      If (_bIsHobbled)
         iNumRestraints += 1
      EndIf
      iVulnerability += (iNumRestraints * _qMcm.iVulnerabilityRestraints)
      If (_oLeashTarget)
         iVulnerability += _qMcm.iVulnerabilityLeashed
      EndIf
      If (_qDfwUtil.IsNight())
         iVulnerability += _qMcm.iVulnerabilityNight
      EndIf
   Else
      Log("Vulnerability for NPCs not implemented.", DL_INFO, S_MOD)
   EndIf
   Log("Vulnerability: " + iVulnerability, DL_DEBUG, S_MOD)
   If (100 < iVulnerability)
      Return 100
   EndIf
   Return iVulnerability
EndFunction

; The distance should be about 750 - 1,000 (loud talking distance) in the city.
; New actors are excluded by default.
Form[] Function GetNearbyActorList(Float fMaxDistance=0.0, Int iIncludeFlags=0, \
                                   Int iExcludeFlags=0)
   ; Clean up the actor list before we return elements from it.
   ; Note: The cleanup has it's own throttle mechanism preventing it from running all the time.
   CleanupNearbyList()

   ; If there is no filtering just return the known list.
   If (!iIncludeFlags && !iExcludeFlags && !fMaxDistance)
      If (_qDfwUtil.MutexLock(_iGeneralDataMutex))
         _aiRecentFlags = _aiNearbyFlags
         _qDfwUtil.MutexRelease(_iGeneralDataMutex)
      EndIf
      Return _aoNearby
   EndIf

   ; Otherwise create a new list and only add filtered items.
   Form[] aoSubList

   ; I don't know how to assign an empty array so I'm going to declare an new empty array, fill
   ; it, and then copy it over.  Simply clearing _aiRecentFlags by setting it to None doesn't
   ; work because the value AddIntToArray() returns below is lost unwinding the stack.
   ; _aiRecentFlags = None
   Int[] aiTempFlags

   Int iCount = _aoNearby.Length
   Int iIndex
   While (iIndex < iCount)
      Actor aNearby = (_aoNearby[iIndex] As Actor)
      If (!iExcludeFlags || !Math.LogicalOr(_aiNearbyFlags[iIndex], iExcludeFlags))
         If (!iIncludeFlags || Math.LogicalAnd(_aiNearbyFlags[iIndex], iIncludeFlags))
            If (!fMaxDistance || (fMaxDistance > aNearby.GetDistance(_aPlayer)))
               aoSubList = _qDfwUtil.AddFormToArray(aoSubList, aNearby, True)
               aiTempFlags = _qDfwUtil.AddIntToArray(aiTempFlags, _aiNearbyFlags[iIndex], True)
            EndIf
         EndIf
      EndIf
      iIndex += 1
   EndWhile

   ; Fill in the flags from the recent GetNearbyActorsList() before returning.  See note above.
   If (_qDfwUtil.MutexLock(_iGeneralDataMutex))
      _aiRecentFlags = aiTempFlags
      _qDfwUtil.MutexRelease(_iGeneralDataMutex)
   EndIf

   Return aoSubList
EndFunction

; Be careful when using this.
; There is a race condition if the lists change between getting the actors and the flags.
; At the very least make sure the two lists are the same size.
; This function only works when getting an actor list with include/exclude parameters set to 0.
Int[] Function GetNearbyActorFlags()
   ; Return _aiNearbyFlags
   Return _aiRecentFlags
EndFunction

Actor Function GetRandomActor(Float fMaxDistance=0.0, Int iIncludeFlags=0, Int iExcludeFlags=0)
   Form[] aoNearbyList = GetNearbyActorList(fMaxDistance, iIncludeFlags, iExcludeFlags)
   Int iCount = aoNearbyList.Length
   If (iCount)
      Int iRandomIndex = Utility.RandomInt(0, iCount - 1)
      Return (aoNearbyList[iRandomIndex] As Actor)
   EndIf
   Return None
EndFunction

Actor Function GetNearestActor(Float fMaxDistance=0.0, Int iIncludeFlags=0, Int iExcludeFlags=0)
   Form[] aoNearbyList = GetNearbyActorList(fMaxDistance, iIncludeFlags, iExcludeFlags)
   Int iIndex = aoNearbyList.Length - 1
   If (0 > iIndex)
      Return None
   EndIf

   Actor aNearest = (aoNearbyList[iIndex] As Actor)
   Float fNearestDistance = aNearest.GetDistance(_aPlayer)
   While (0 < iIndex)
      ; We check the first element before the while loop so decrement the index at the start.
      iIndex -= 1
      Actor aCurrent = (aoNearbyList[iIndex] As Actor)
      Float fCurrentDistance = aCurrent.GetDistance(_aPlayer)
      If (fCurrentDistance < fNearestDistance)
         fNearestDistance = fCurrentDistance
         aNearest = aCurrent
      EndIf
   EndWhile
   Return aNearest
EndFunction

Actor Function GetPlayerTalkingTo()
   Int iIndex = _aoNearby.Length - 1
   While (0 <= iIndex)
      Actor aActor = (_aoNearby[iIndex] As Actor)
      If (aActor.IsInDialogueWithPlayer())
         Return aActor
      EndIf
      iIndex -= 1
   EndWhile
   Return None
EndFunction

; Leash target should be an in world object or an actor.
Function SetLeashTarget(ObjectReference oLeashTarget)
   If (_qDfwUtil.MutexLock(_iGeneralDataMutex))
      _oLeashTarget = oLeashTarget
      _qDfwUtil.MutexRelease(_iGeneralDataMutex)
   EndIf
EndFunction

Function SetLeashLength(Int iLength)
   If (_qDfwUtil.MutexLock(_iGeneralDataMutex))
      _iLeashLength = iLength
      _qDfwUtil.MutexRelease(_iGeneralDataMutex)
   EndIf
EndFunction

Function YankLeash()
   If (GetPlayerTalkingTo())
      ; Moving the player to her own location will end the conversation.
      _aPlayer.MoveTo(_aPlayer)
   EndIf

   ; Figure out which style of leash to use.
   Int iLeashStyle = _qMcm.iModLeashStyle
   If (LS_AUTO == iLeashStyle)
      ; If the player is at low health use the teleport leash (a little safer).
      iLeashStyle = LS_DRAG
      If (100 > _aPlayer.GetActorValue("Health"))
         iLeashStyle = LS_TELEPORT
      EndIf
   ElseIf (500 > _iLeashLength)
      ; The dragging leash doesn't work with distances less than 500 units.
      ; By the time the player stands up she is being dragged again.
      iLeashStyle = LS_TELEPORT
   EndIf

   If (LS_DRAG == iLeashStyle)
      ; Remove ragdoll from the player.  The first time fails so do it here before
      ; doing it later.
      _aPlayer.ForceRemoveRagdollFromWorld()

      ; While dragging the player via the leash make sure they are immune to damage.
      ; Otherwise getting stuck behind a rock would kill the player.
      Float fDamageResistance = _aPlayer.GetActorValue("DamageResist")
      _aPlayer.ModActorValue("DamageResist", 10000)

      Int iLoopCount = 1
      While (200 < _oLeashTarget.GetDistance(_aPlayer))
         _oLeashTarget.PushActorAway(_aPlayer, -2)

         If (!(iLoopCount))
            _aPlayer.ForceRemoveRagdollFromWorld()
            _qDfwUtil.TeleportToward(_oLeashTarget, 30)
         EndIf
         iLoopCount -= 1
      EndWhile
      ; You'll notice a lot of RemoveRagdoll() calls here.  Sometimes the player gets stuck
      ; standing and having all of these help.  I'm not sure which ones are really needed.
      _aPlayer.ForceRemoveRagdollFromWorld()
      Utility.Wait(0.25)
      _aPlayer.ForceRemoveRagdollFromWorld()
      _qDfwUtil.TeleportToward(_oLeashTarget, 10)
      _aPlayer.ForceRemoveRagdollFromWorld()

      ; Reset the player's damage resistance.
      _aPlayer.ModActorValue("DamageResist", -10000)

      ; If the leash holder is running the player can't keep up.  Drag her along but don't
      ; inflict damage.
      If (!(_oLeashTarget As Actor).IsRunning())
         Float fDamage = ((_aPlayer.GetActorValue("Health") * _qMcm.iModLeashDamage / 100) + \
                          _aPlayer.GetLevel())
         _aPlayer.DamageActorValue("Health", fDamage)
      EndIf
   Else ; LS_TELEPORT
      While ((_iLeashLength / 1.75) < _oLeashTarget.GetDistance(_aPlayer))
         _qDfwUtil.TeleportToward(_oLeashTarget, 40)

         Utility.Wait(0.5)
      EndWhile
      ; If the leash holder is running the player can't keep up.  Drag her along but
      ; don't inflict damage.
      Actor aLeashTarget = (_oLeashTarget As Actor)
      If (!aLeashTarget.IsRunning() && !aLeashTarget.IsSprinting())
         Float fDamage = ((_aPlayer.GetActorValue("Health") * _qMcm.iModLeashDamage / \
                           100) + _aPlayer.GetLevel())
         _aPlayer.DamageActorValue("Health", fDamage)
      EndIf
   EndIf
EndFunction

; Includes: In Bleedout, Controls Locked (i.e. When in a scene)
Bool Function IsPlayerCriticallyBusy(Bool bIncludeBleedout=True)
   If (_iBleedoutTime)
      ; If we are not supposed to consider bleedout as busy return false for anything during the
      ; bleedout.  Since bleedout locks player controls it is virtually impossible to
      ; distinguish it from other forms of being busy.
      If (!bIncludeBleedout)
         Return False
      EndIf

      If (Utility.GetCurrentRealTime() < _iBleedoutTime)
         Return True
      EndIf
      If (_qDfwUtil.MutexLock(_iGeneralDataMutex))
         _iBleedoutTime = 0
         _qDfwUtil.MutexRelease(_iGeneralDataMutex)
      EndIf
   EndIf

   If (!_aPlayer.GetPlayerControls())
      Return True
   EndIf

   Return False
EndFunction

Function BlockHealthRegen()
   ; If this is the first mod to block regeneration block it now.
   If (0 == _iBlockHealthRegen)
      _aPlayer.DamageActorValue("HealRate", _aPlayer.GetActorValue("HealRate") * 0.99)
   EndIf

   If (_qDfwUtil.MutexLock(_iGeneralDataMutex))
      _iBlockHealthRegen += 1
      _qDfwUtil.MutexRelease(_iGeneralDataMutex)
   EndIf
EndFunction

Function RestoreHealthRegen()
   If (_qDfwUtil.MutexLock(_iGeneralDataMutex))
      _iBlockHealthRegen -= 1
      _qDfwUtil.MutexRelease(_iGeneralDataMutex)
   EndIf

   ; If no more mods have regeneration blocked restore it completely.
   If (0 == _iBlockHealthRegen)
      _aPlayer.RestoreActorValue("HealRate", 10000)
   EndIf
EndFunction

Function BlockMagickaRegen()
   ; If this is the first mod to block regeneration block it now.
   If (0 == _iBlockMagickaRegen)
      _aPlayer.DamageActorValue("MagickaRate", _aPlayer.GetActorValue("MagickaRate") * 0.99)
   EndIf

   If (_qDfwUtil.MutexLock(_iGeneralDataMutex))
      _iBlockMagickaRegen += 1
      _qDfwUtil.MutexRelease(_iGeneralDataMutex)
   EndIf
EndFunction

Function RestoreMagickaRegen()
   If (_qDfwUtil.MutexLock(_iGeneralDataMutex))
      _iBlockMagickaRegen -= 1
      _qDfwUtil.MutexRelease(_iGeneralDataMutex)
   EndIf

   ; If no more mods have regeneration blocked restore it completely.
   If (0 == _iBlockMagickaRegen)
      _aPlayer.RestoreActorValue("MagickaRate", 10000)
   EndIf
EndFunction

Function DisableMagicka(Bool bDisable=True)
   If (bDisable)
      ; If this is the first mod to disable magica disable it now.
      If (0 == _iDisableMagicka)
         _aPlayer.SetActorValue("MagickaRate", 0)
         _aPlayer.DamageActorValue("Magicka", _aPlayer.GetActorValue("Magicka"))
      EndIf

      If (_qDfwUtil.MutexLock(_iGeneralDataMutex))
         _iDisableMagicka += 1
         _qDfwUtil.MutexRelease(_iGeneralDataMutex)
      EndIf
      Return
   EndIf
   If (_qDfwUtil.MutexLock(_iGeneralDataMutex))
      _iDisableMagicka -= 1
      _qDfwUtil.MutexRelease(_iGeneralDataMutex)
   EndIf

   ; If no more mods have regeneration blocked restore it completely.
   If (0 == _iDisableMagicka)
      _aPlayer.RestoreActorValue("MagickaRate", 10000)
      ; If some mods have regeneration blocked dampen it.
      If (_iBlockMagickaRegen)
         _aPlayer.DamageActorValue("MagickaRate", _aPlayer.GetActorValue("MagickaRate") * 0.99)
      EndIf
   EndIf
EndFunction

Function BlockStaminaRegen()
   ; If this is the first mod to block regeneration block it now.
   If (0 == _iBlockStaminaRegen)
      _aPlayer.DamageActorValue("StaminaRate", _aPlayer.GetActorValue("StaminaRate") * 0.99)
   EndIf

   If (_qDfwUtil.MutexLock(_iGeneralDataMutex))
      _iBlockStaminaRegen += 1
      _qDfwUtil.MutexRelease(_iGeneralDataMutex)
   EndIf
EndFunction

Function RestoreStaminaRegen()
   If (_qDfwUtil.MutexLock(_iGeneralDataMutex))
      _iBlockStaminaRegen -= 1
      _qDfwUtil.MutexRelease(_iGeneralDataMutex)
   EndIf

   ; If no more mods have regeneration blocked restore it completely.
   If (0 == _iBlockStaminaRegen)
      _aPlayer.RestoreActorValue("StaminaRate", 10000)
   EndIf
EndFunction

Function DisableStamina(Bool bDisable=True)
   If (bDisable)
      ; If this is the first mod to disable magica disable it now.
      If (0 == _iDisableStamina)
         _aPlayer.SetActorValue("StaminaRate", 0)
         _aPlayer.DamageActorValue("Stamina", _aPlayer.GetActorValue("Stamina"))
      EndIf

      If (_qDfwUtil.MutexLock(_iGeneralDataMutex))
         _iDisableStamina += 1
         _qDfwUtil.MutexRelease(_iGeneralDataMutex)
      EndIf
      Return
   EndIf
   If (_qDfwUtil.MutexLock(_iGeneralDataMutex))
      _iDisableStamina -= 1
      _qDfwUtil.MutexRelease(_iGeneralDataMutex)
   EndIf

   ; If no more mods have regeneration blocked restore it completely.
   If (0 == _iDisableStamina)
      _aPlayer.RestoreActorValue("MagickaRate", 10000)
      ; If some mods have regeneration blocked dampen it.
      If (_iBlockStaminaRegen)
         _aPlayer.DamageActorValue("StaminaRate", _aPlayer.GetActorValue("StaminaRate") * 0.99)
      EndIf
   EndIf
EndFunction

Bool Function IsAllowed(Int iAction)
   If ((_aMasterClose && !Math.LogicalAnd(_iPermissionsClose, iAction)) || \
       (_aMasterDistant && !Math.LogicalAnd(_iPermissionsDistant, iAction)))
      Return False
   EndIf
   Return True
EndFunction

Function AddPermission(Actor aMaster, Int iPermissionMask)
   If (_aMasterClose == aMaster)
      If (_qDfwUtil.MutexLock(_iGeneralDataMutex))
         _iPermissionsClose = Math.LogicalOr(_iPermissionsClose, iPermissionMask)
         _qDfwUtil.MutexRelease(_iGeneralDataMutex)
      EndIf
   ElseIf (_aMasterDistant == aMaster)
      If (_qDfwUtil.MutexLock(_iGeneralDataMutex))
         _iPermissionsDistant = Math.LogicalOr(_iPermissionsDistant, iPermissionMask)
         _qDfwUtil.MutexRelease(_iGeneralDataMutex)
      EndIf
   EndIf
EndFunction

Function RemovePermission(Actor aMaster, Int iPermissionMask)
   If (_aMasterClose == aMaster)
      If (_qDfwUtil.MutexLock(_iGeneralDataMutex))
         _iPermissionsClose = Math.LogicalXor(_iPermissionsClose, iPermissionMask)
         _qDfwUtil.MutexRelease(_iGeneralDataMutex)
      EndIf
   ElseIf (_aMasterDistant == aMaster)
      If (_qDfwUtil.MutexLock(_iGeneralDataMutex))
         _iPermissionsDistant = Math.LogicalXor(_iPermissionsDistant, iPermissionMask)
         _qDfwUtil.MutexRelease(_iGeneralDataMutex)
      EndIf
   EndIf
EndFunction

