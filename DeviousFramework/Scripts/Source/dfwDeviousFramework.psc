Scriptname dfwDeviousFramework extends Quest Conditional
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
String S_NONE = "None"

; Standard status constants.
Int FAIL    = -1
Int SUCCESS = 0
Int WARNING = 1

; Debug Class (DC_) constants.
Int DC_GENERAL     =  0
Int DC_DEBUG       =  1
Int DC_STATUS      =  2
Int DC_MASTER      =  3
Int DC_NEARBY      =  4
Int DC_LEASH       =  5
Int DC_EQUIP       =  6
Int DC_NPC_AROUSAL =  7
Int DC_INTERACTION =  8
Int DC_LOCATION    =  9
Int DC_REDRESS     = 10
Int DC_SAVE        = 11

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
Int Property AF_NONE         = 0x00000000 Auto
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

; Regions of Skyrim.
Location[] REGIONS_INDEXED
Location    REGION_DAWNSTAR
Location[] SUBURBS_DAWNSTAR
Location    REGION_DRAGON_BRIDGE
Location[] SUBURBS_DRAGON_BRIDGE
Location    REGION_FALKREATH
Location[] SUBURBS_FALKREATH
Location    REGION_HIGH_HROTHGAR
Location[] SUBURBS_HIGH_HROTHGAR
Location    REGION_IVARSTEAD
Location[] SUBURBS_IVARSTEAD
Location    REGION_KARTHWASTEN
Location[] SUBURBS_KARTHWASTEN
Location    REGION_MARKARTH
Location[] SUBURBS_MARKARTH
Location    REGION_MORTHAL
Location[] SUBURBS_MORTHAL
Location    REGION_OLD_HROLDAN
Location[] SUBURBS_OLD_HROLDAN
Location    REGION_RIFTEN
Location[] SUBURBS_RIFTEN
Location    REGION_RIVERWOOD
Location[] SUBURBS_RIVERWOOD
Location    REGION_RORIKSTEAD
Location[] SUBURBS_RORIKSTEAD
Location    REGION_SHORS_STONE
Location[] SUBURBS_SHORS_STONE
Location    REGION_SKY_HAVEN
Location[] SUBURBS_SKY_HAVEN
Location    REGION_SOLITUDE
Location    SUBURB_SOLITUDE_WELLS
Location    SUBURB_SOLITUDE_AVENUES
Location[] SUBURBS_SOLITUDE
Location    REGION_THALMOR_EMBASSY
Location[] SUBURBS_THALMOR_EMBASSY
Location    REGION_WHITERUN
Location[] SUBURBS_WHITERUN
Location    REGION_WINDHELM
Location[] SUBURBS_WINDHELM
Location    REGION_WINTERHOLD
Location    SUBURB_WINTERHOLD_COLLEGE
Location[] SUBURBS_WINTERHOLD
Form[]     SPECIAL_CELLS
Form[]     SPECIAL_CELL_LOCATIONS

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

; Dialogue Style (DS_) constants.
; Note: These must remain backwards compatible.
Int Property DS_OFF    = 0 Auto
Int Property DS_AUTO   = 1 Auto
Int Property DS_MANUAL = 2 Auto

; Properties from the script properties window in the creation kit.
Spell   Property _oDfwLeashSpell          Auto
Spell   Property _oDfwNearbyDetectorSpell Auto
Faction Property _oFactionMerchants       Auto
Idle    Property _oIdleStop_Loose         Auto

; Quest Alias References.
ReferenceAlias _aAliasApproachPlayer
LocationAlias _aAliasLocationTarget
ReferenceAlias _aAliasMoveToLocation
ReferenceAlias _aAliasObjectTarget
ReferenceAlias _aAliasMoveToObject
ReferenceAlias[] _aaAliasHoverTarget
ReferenceAlias[] _aaAliasHover
ReferenceAlias _aAliasGiveSpaceTarget
ReferenceAlias _aAliasGiveSpace1
ReferenceAlias _aAliasGiveSpace2
ReferenceAlias _aAliasGiveSpace3


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

;----------------------------------------------------------------------------------------------
; Conditional variables available to Dialogues.
; Use PrepareActorDialogue() to set the variables before using them.
Bool  _bCallingForAttention     Conditional
Bool  _bCallingForHelp          Conditional
Bool  _bInScene                 Conditional
Bool  _bIsActorDominant         Conditional
Bool  _bIsActorLeashHolder      Conditional
Bool  _bIsActorOwner            Conditional
Bool  _bIsActorSlave            Conditional
Bool  _bIsActorSlaver           Conditional
Bool  _bIsActorSubmissive       Conditional
Bool  _bIsGagStrict             Conditional
Bool  _bIsLastRapeAggressor     Conditional
Bool  _bIsPlayerArmLocked       Conditional
Bool  _bIsPlayerBelted          Conditional
Bool  _bIsPlayerBound           Conditional
Bool  _bIsPlayerBoundVisible    Conditional
Bool  _bIsPlayerCollared        Conditional
Bool  _bIsPlayerFurnitureLocked Conditional
Bool  _bIsPlayerGagged          Conditional
Bool  _bIsPlayerHobbled         Conditional
Bool  _bIsPlayersMaster         Conditional
Bool  _bIsPreviousMaster        Conditional
Int   _iActorAnger              Conditional
Int   _iActorArousal            Conditional
Int   _iActorConfidence         Conditional
Int   _iActorDominance          Conditional
Int   _iActorInterest           Conditional
Int   _iActorKindness           Conditional
Int   _iNakedLevel              Conditional
Int   _iVulnerability           Conditional
Int   _iWillingnessToHelp       Conditional
Float _fActorDistance           Conditional
Float _fHoursSinceLastRape      Conditional
Float _fMasterDistance          Conditional

; Keep a counter so we don't prepare a dialogue with the same actor too many times.
Int _iDialogRetries             Conditional
;----------

;----------------------------------------------------------------------------------------------
; Conditional variables available to Packages.
; A conditional to tell the approach package(s) how fast to move.
; 2 Walk Fast  3 Jog  4 Run
Int _iApproachSpeed Conditional

; Range 0 - 100.
; Currently only two values, <50 and >50, are supported.
Int _iMoveToObjectDistance Conditional
;----------

; Basic game objects.
MiscObject _oGold
MiscObject _oLockpick

; Game objects from other mods.
Armor _oZazRestraintHider
Armor _oZbfRestraintHider
; Devious Device Keys.
Key _oDeviousKeyChastity
Key _oDeviousKeyPiercings
Key _oDeviousKeyRestraints
; Devious Devices - For the Masses (fake) restraint keys.
Key _oFtmChastityKey
Key _oFtmRestraintKey
Key _oFtmPiercingTool
; Deviously Cursed Loot special keys.
Key _oDclKeyBody
Key _oDclKeyHand
Key _oDclKeyHead
Key _oDclKeyHighSecurity
Key _oDclKeyLeg

;*** Vulnerability Flags ***
Int _iNakedStatus
Bool _bChestCovered = False
Bool _bWaistCovered = False
Bool _bNakedReduced = False
Bool _bChestReduced = False
Bool _bWaistReduced = False
Int _iNumOtherRestraints
Bool _bHiddenRestraints = False
Bool _bInventoryLocked = False

; Keep track of the player's location as this information is not otherwise available.
Location _oCurrLocation
Location _oCurrRegion
Location _oLastNearestRegion
Bool _bIsPlayerInterior
Int[] _aiLastDoorLocation

; Variables for controlling saved games.
Bool _bBlockLoad
Int _iBlockLoadTimer
Int _iBlockConsoleTimer
Float _fLastSave
; 0: Unknown  1: Auto  2: Quick  3: Force
Int _iLastSaveType

;*** Pose Management ***
; An array of all known poses.
String[] _aszKnownPoses
; Information about each pose.
; 0x0001: A default idle.
; 0x0002: An idle but not a default.
; 0x0004: A toggle pose.  It must be turned on and off.
; 0x0008: This pose prevents movement.
; 0x0010: This pose prevents activation.
; 0x0020: This pose prevents inventory.
; 0x0040: This pose prevents fighting.
; 0x0080: The pose is considred kneeling.
; 0x0100: The pose is considred crawling.
; 0x0200: The pose is considred exposed.
; 0x8000: A complex pose which can't be handled via the standard funcitons.
Int[] _aiKnownPoseFlags
; An index into the array of known poses.
Int _iCurrPose

; BDSM furniture related flags.  What furniture the player is sitting on and if it is locked.
; Note that if the furniture is locked the player should be locked back up after sex.
ObjectReference _oBdsmFurniture = None
Bool _bIsFurnitureLocked

; Flags to tell the poll function to update status information.
; 0: No flags to check.  1-2: Time to check flags.  >2: A timer before performing checks.
Int _iFlagSet               = 5
Bool _bFlagItemEqupped      = True
Bool _bFlagItemUnequpped    = True
Bool _bFlagClothesEqupped   = True
Bool _bFlagClothesUnequpped = True

; A flag to indicate we should check if a move to location has been completed.
Int _iFlagCheckMoveTo

; Variables for monitoring move packages to ensure the NPCs keep moving.
Int _iMonitorMoveTo
; 0-2: Approach [X,Y,Z]  3-5: MoveToLocation [X,Y,Z]  6-8: MoveToObject [X,Y,Z]
Int[] _aiMoveToCurrPos
; 0: Approach  1: MoveToLocation  2: MoveToObject
Int[] _aiMoveToStallCount
; 6: North-West  7: North        8: North-East
; 3:       West  4: No Movement  5:       East
; 0: South-West  1: South        2: South-East
; <=2: South  >=6: North (X%3)==0: West (X%3)==2: East
Int[] _aiMoveToDirection

; A variable to store the actual loaction target during a pathing fix.
Location _oKynesgrovePathingFixOriginalLocation

;*** Keywords ***
; A local variable to store the SexLab Aroused "Is Naked" keyword for faster access.
; Note: This keyword doesn't appear to be used.
;       See the StorageUtil SLAroused.IsNakedArmor instead.
;Keyword _oKeywordIsNaked = Keyword.GetKeyword("EroticArmor")

; Keywords to identify clothing (Clothes, Light Armour, and Heavy Armour).
Keyword _oKeywordClothes
Keyword _oKeywordArmourLight
Keyword _oKeywordArmourHeavy

; Basic Native Game Keywords.
Keyword _oKeywordVendorNoSale
Keyword _oKeywordVendorItemKey

; SexLab No Strip keyword to prevent unequipping certain items.
Keyword _oKeywordSexLabNoStrip

; Non-specific primary devious device keywords.
Keyword _oKeywordZadLockable
Keyword _oKeywordZadInventoryDevice
Keyword _oKeywordZbfWornDevice

; ZAD Devious Keywords.
Keyword _oKeywordZadArmBinder
Keyword _oKeywordZadArmCuffs
Keyword _oKeywordZadBelt
Keyword _oKeywordZadBlindfold
Keyword _oKeywordZadBondageMittens
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
Keyword _oKeywordZbfFurniture
Keyword _oKeywordZbfFurnitureMulti

; A reference to the MCM quest script.
dfwMcm _qMcm

; A reference to the Devious Framework Util quest script.
dfwUtil _qDfwUtil

; A reference to SexLab and SexLab Aroused Framework quest scripts.
SexLabFramework _qSexLab
slaMainScr      _qSexLabArousedMain
slaFrameworkScr _qSexLabAroused

; A reference to the Devious Devices quest, Zadlibs.
Zadlibs _qZadLibs

; A reference to the ZAZ Animation Pack (ZBF) slave control APIs.
zbfSlaveControl _qZbfSlave
zbfSlaveActions _qZbfSlaveActions
zbfSlot _qZbfPlayerSlot

; The names to use for QuickSave/AutoSave game files.
String _szQuickSaveName
String _szAutoSaveName

; A list of nearby actors and their accompanying characteristic flags.
Int _iNearbyMutex
Form[] _aoNearby
Int[] _aiNearbyFlags


; A list of actors we have added to the Zaz Animation Pack slotted actors.
; The Zaz Animation Pack has few slots so we want to remove any actors we have added.
Int _iZazSlottedMutex
Int _iZazSlottedCount
Form[] _aoZazSlottedActors

; Some information about recently seen actors
Int _iKnownMutex
Form[] _aoKnown
Float[] _afKnownLastSeen
Int[] _aiKnownSignificant
Int[] _aiKnownAnger
Int[] _aiKnownConfidence
Int[] _aiKnownDominance
Int[] _aiKnownInterest
Int[] _aiKnownKindness

; A list of Masters who are controlling the player.
Actor _aMasterClose
Actor _aMasterDistant
String _aMasterModClose
String _aMasterModDistant

; Also keep a list of actors who have previously been the player's Master.
Form[] _aaPreviousMasters

; A set of flags to keep track of whether sex or enslavement is allowed.
Int _iPermissionsClose
Int _iPermissionsDistant

; A set of flags from related to actors from a recent call to GetNearbyActorList()
Int[] _aiRecentFlags

; Keeps track of the number of polls since the last NPC detection scan.
Int _iDetectPollCount

; Keep track of the number of items unequipped in a second to prevent it going infinite.
Int _iNumItemsUnequipped

; Keep track of whether a scene is running and how long to wait for a call to scene done.
Float _fSceneTimeout
String _szCurrentScene
; The callout timeout should not decrease in shorter scenes and scenes that directly handle the
; callout; however, for extended scenes and scenes that are unrelated to the callout the timeout
; needs to decrement as normal.  This flag keeps track of which type of scene is active.
Bool _bSceneExtendsCallout

; For moving aliases, keep track of the mods/features performing the movement.
String _szApproachModId
String _szMoveToLocationModId
String _szMoveToObjectModId
String[] _aszHoverAtModId
String _szGiveSpaceModId

; Keep track of how long the times movement packages should be in effect.
; zxc-TODO: Change the name of this variable.  It is an Array.
Int[] _iHoverAtTimeout
Int _iGiveSpaceTimeout

; Keep track of how long before the next cleanup is scheduled for the nearby actors list.
Float _fNearbyCleanupTime

; Timeouts to prevent redressing after becoming naked or being raped.
Float _fNakedRedressTimeout
Float _fRapeRedressTimeout

; A timeout preventing the player from calling for help too frequently.
Int _iCallOutTimeout

; A flag to identify we are waiting for someone to respond to a call out.
; This is used to prevent multiple mods from responding to a call out.
Int _iCallOutType
Int _iCallOutResponse

; Information about the most recent rape or assault.
Actor _aLastAssaultActor
Float _fLastAssaultTime

; The time we are expected to recover from a bleedout.
Float _iBleedoutTime

; An actor the player is to be leashed to.
ObjectReference _oLeashTarget
Int _iLeashLength
Bool _bYankingLeash

; Keep track of the collector's chests for quicker access.
ObjectReference _oCollectorsChest
ObjectReference _oCollectorsSpecialChest
ObjectReference _oCollectorsNewItemChest
; The temporary chest is used to separate quest items from not quest items.
ObjectReference _oPlayerItemTemporaryChest

; Counts for how many mods have blocked stat regeneration.
Int _iBlockHealthRegen
Int _iBlockMagickaRegen
Int _iBlockStaminaRegen
Int _iDisableMagicka
Int _iDisableStamina

; A count for how many times various game features have been blocked.
Int _iBlockFastTravel
Int _iBlockMovement
Int _iBlockFighting
Int _iBlockCameraSwitch
Int _iBlockLooking
Int _iBlockSneaking
Int _iBlockMenu
Int _iBlockActivate
Int _iBlockJournal

; The faction the NPC is added to when he becomes the DFW Dialogue Target.
Int _iDialogueTargetStyle Conditional
Actor _aCurrTarget
Faction _oFactionDfwDialogueTarget

; Mechanisms to identify slavers.
Faction _oFactionHydraSlaver
Faction _oFactionHydraCaravanSlaver
Faction _oFactionHydraSlaverMisc

; A mutex to restrict access to the player's MoveTo() function.
Int _iMovePlayerMutex

; A set of variables to manage mutexes.
Int[] _aiMutex
String[] _aszMutexName
Int _iMutexNext

Float _fDebugNextClockTick

;----------------------------------------------------------------------------------------------
; Local copy of frequently used MCM settings.
; Accessing settings from other script is a little expensive as it can cause context switches.
; For MCM settings that are used often we will store a local copy of their values in this script
; for faster access.
Int _iMcmLogLevel = 5 ; DL_TRACE
Int[] _aiMcmScreenLogLevel
Float _fMcmPollTime
Int _iMcmDispWillingGuards
Int _iMcmDispWillingMerchants
Int _iMcmDispWillingBdsm
Int _iMcmDialogueRetries
Int _iMcmLeashMinLength
Int _iMcmNearbyDistance
Int _iMcmCollectorSpecialCost
Int _iMcmSaveGameControlStyle
Bool _bMcmShutdownMod
;----------

;----------------------------------------------------------------------------------------------
; Mod Compatability.
; Skyrim Perk Enhancements and Rebalanced Gameplay (SPERG) unarmed "fists" that should not be
; considered weapons.
Weapon _oSpergFist1
Weapon _oSpergFist2

; StrapOn - CBBEv3 - StandAlone - Craftable - ADULT CONTENT by aeon is identified as a Curass.
Armor _oStraponByAeon

; Milk Mod Economy.  Some effort is needed to make sure scenes run smoothly.
Spell _oMmeBeingMilkedSpell
Bool _bMmeSuppressed

; Indicates if the Papyrus Util (Modder's Scripting Utility Functions) mod is installed.
Bool _bModPapyrusUtil

; Indicates if the Sanguine Debauchery Plus (SD+) mod is installed.
Bool _bModSdPlus

; Crawl idles from SD+
Idle _oSdCrawlMoveBackward
Idle _oSdCrawlMoveForward
Idle _oSdCrawlTurnLeft
Idle _oSdCrawlTurnRight
Idle _oSdCrawlStrafeBackLeft
Idle _oSdCrawlStrafeBackRight
Idle _oSdCrawlStrafeStartLeft
Idle _oSdCrawlStrafeStartRight
;----------


;***********************************************************************************************
;***                                    INITIALIZATION                                       ***
;***********************************************************************************************
; A new game has started, this script was added to an existing game, or the script was reset.
Event OnInit()
   ; Delay before starting the mod.  This should give the MCM script time to initialize.
   Debug.Trace("[" + S_MOD + "] Script Initialized.")
   RegisterForSingleUpdate(15)
EndEvent

; This is called from the player monitor script when a game is loaded.
; This function is primarily to ensure new variables are initialized for new script versions.
Function UpdateScript()
   DebugTrace("TraceEvent UpdateScript")

   ; Reset the version number.
   If (1.11 < _fCurrVer)
      _fCurrVer = 1.11
   EndIf

   ; If the script is at the current version we are done.
   Float fScriptVer = 1.12
   If (fScriptVer == _fCurrVer)
      DebugTrace("TraceEvent UpdateScript: Done (Latest Version)")
      Return
   EndIf
   Log("Updating Script " + _fCurrVer + " => " + fScriptVer, DL_INFO, DC_GENERAL)

   ; On any script upgrade make sure to refresh any settings from the MCM script.
   UpdateLocalMcmSettings()

   ; When releasing the greeting dialogues (Version 2 of the mod) the script versions
   ; were all advanced to version 1.00.
   If (1.00 > _fCurrVer)
      ; Initialize basic variables.
      _aPlayer = Game.GetPlayer()
      _iLeashLength = 700
      _iDialogueTargetStyle = DS_MANUAL

      ; Create an initial mutex for protecting the mutex list.
      _aiMutex      = New Int[1]
      _aszMutexName = New String[1]
      _aiMutex[0]      = 0
      _aszMutexName[0] = "Mutex List Mutex"
      _iMutexNext      = 1

      ; Create other mutexes for protecting data access.
      _iNearbyMutex = iMutexCreate("DFW Nearby")
      _iKnownMutex = iMutexCreate("DFW Known")

      ; ZAD Devious Keywords.
      _oKeywordZadArmBinder      = Keyword.GetKeyword("zad_DeviousArmbinder")
      _oKeywordZadArmCuffs       = Keyword.GetKeyword("zad_DeviousArmCuffs")
      _oKeywordZadBelt           = Keyword.GetKeyword("zad_DeviousBelt")
      _oKeywordZadBlindfold      = Keyword.GetKeyword("zad_DeviousBlindfold")
      _oKeywordZadBoots          = Keyword.GetKeyword("zad_DeviousBoots")
      _oKeywordZadBra            = Keyword.GetKeyword("zad_DeviousBra")
      _oKeywordZadClamps         = Keyword.GetKeyword("zad_DeviousClamps")
      _oKeywordZadCollar         = Keyword.GetKeyword("zad_DeviousCollar")
      _oKeywordZadCorset         = Keyword.GetKeyword("zad_DeviousCorset")
      _oKeywordZadGag            = Keyword.GetKeyword("zad_DeviousGag")
      _oKeywordZadGloves         = Keyword.GetKeyword("zad_DeviousGloves")
      _oKeywordZadHarness        = Keyword.GetKeyword("zad_DeviousHarness")
      _oKeywordZadHood           = Keyword.GetKeyword("zad_DeviousHood")
      _oKeywordZadLegCuffs       = Keyword.GetKeyword("zad_DeviousLegCuffs")
      _oKeywordZadNipple         = Keyword.GetKeyword("zad_DeviousPiercingsNipple")
      _oKeywordZadVagina         = Keyword.GetKeyword("zad_DeviousPiercingsVaginal")
      _oKeywordZadFullSuit       = Keyword.GetKeyword("zad_DeviousSuit")
      _oKeywordZadYoke           = Keyword.GetKeyword("zad_DeviousYoke")

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
      _oKeywordArmourLight = Keyword.GetKeyword("ArmorLight")
      _oKeywordArmourHeavy = Keyword.GetKeyword("ArmorHeavy")

      ; BDSM Furniture Keyword.
      _oKeywordZbfFurniture = \
         (Game.GetFormFromFile(0x0000762B, "ZaZAnimationPack.esm") As Keyword)

      ; A keyword to identify SexLab No Strip items.
      _oKeywordSexLabNoStrip = Keyword.GetKeyword("SexLabNoStrip")

      ; Getting factions from the .ESP file prevents us from being dependent on the mod.
      Int iModOrder = Game.GetModByName("hydra_slavegirls.esp")
      If ((-1 < iModOrder) && (255 > iModOrder))
         _oFactionHydraSlaver     = \
            (Game.GetFormFromFile(0x0000B670, "hydra_slavegirls.esp") As Faction)
         _oFactionHydraSlaverMisc = \
            (Game.GetFormFromFile(0x000122B6, "hydra_slavegirls.esp") As Faction)
         _oFactionHydraCaravanSlaver = \
            (Game.GetFormFromFile(0x00072F71, "hydra_slavegirls.esp") As Faction)
      EndIf

      ; Get out own faction for managing dialogue target information.
      _oFactionDfwDialogueTarget = \
         (Game.GetFormFromFile(0x000083D6, "DeviousFramework.esm") As Faction)
   EndIf

   If (1.01 > _fCurrVer)
      _aAliasApproachPlayer = (GetAlias(1) As ReferenceAlias)
      _aAliasLocationTarget = (GetAlias(2) As LocationAlias)
      _aAliasMoveToLocation = (GetAlias(3) As ReferenceAlias)
      _aAliasObjectTarget = (GetAlias(4) As ReferenceAlias)
      _aAliasMoveToObject = (GetAlias(5) As ReferenceAlias)
   EndIf

   If (1.03 > _fCurrVer)
      ; Logging constants were changed in a recent version.
      DC_GENERAL     =  0
      DC_DEBUG       =  1
      DC_STATUS      =  2
      DC_MASTER      =  3
      DC_NEARBY      =  4
      DC_LEASH       =  5
      DC_EQUIP       =  6
      DC_NPC_AROUSAL =  7
      DC_INTERACTION =  8
      DC_LOCATION    =  9
      DC_REDRESS     = 10
   EndIf

   If (1.05 > _fCurrVer)
      ; Registering for events on game load almost always fails.  Always add a delay.
      Log("Delaying before mod event registration.", DL_CRIT, DC_GENERAL)
      Utility.Wait(20)

      ; Perform all registrations in one place to avoid multiple delays.
      If (1.00 > _fCurrVer)
         ; Register for post sex events to detect rapes.
         RegisterForModEvent("AnimationEnd", "PostSexCallback")

         ; Register for notification when MCM settings change.
         RegisterForModEvent("DFW_MCM_Changed", "UpdateLocalMcmSettings")
      EndIf

      ; Register for post sex events to detect rapes.
      RegisterForModEvent("ZapSlaveActionDone", "OnSlaveActionDone")

      Log("Registering Mod Events Done", DL_CRIT, DC_GENERAL)
   EndIf

   If (1.07 > _fCurrVer)
      _aiMoveToDirection = New Int[3]
      _aiMoveToDirection[0] = 4
      _aiMoveToDirection[1] = 4
      _aiMoveToDirection[2] = 4

      _aiMoveToCurrPos    = New Int[9]
      _aiMoveToStallCount = New Int[3]
      Actor aMovingNpc = (_aAliasApproachPlayer.GetReference() As Actor)
      If (aMovingNpc && !aMovingNpc.IsInDialogueWithPlayer())
         _iMonitorMoveTo = 3
         ; 0-2: Approach [X,Y,Z]  3-5: MoveToLocation [X,Y,Z]  6-8: MoveToObject [X,Y,Z]
         _aiMoveToCurrPos[0] = (aMovingNpc.X As Int)
         _aiMoveToCurrPos[1] = (aMovingNpc.Y As Int)
         _aiMoveToCurrPos[2] = (aMovingNpc.Z As Int)
      EndIf
      aMovingNpc = (_aAliasMoveToLocation.GetReference() As Actor)
      If (aMovingNpc && !aMovingNpc.IsInDialogueWithPlayer())
         _iMonitorMoveTo = 3
         ; 0-2: Approach [X,Y,Z]  3-5: MoveToLocation [X,Y,Z]  6-8: MoveToObject [X,Y,Z]
         _aiMoveToCurrPos[3] = (aMovingNpc.X As Int)
         _aiMoveToCurrPos[4] = (aMovingNpc.Y As Int)
         _aiMoveToCurrPos[5] = (aMovingNpc.Z As Int)
      EndIf
      aMovingNpc = (_aAliasMoveToObject.GetReference() As Actor)
      If (aMovingNpc && !aMovingNpc.IsInDialogueWithPlayer())
         _iMonitorMoveTo = 3
         ; 0-2: Approach [X,Y,Z]  3-5: MoveToLocation [X,Y,Z]  6-8: MoveToObject [X,Y,Z]
         _aiMoveToCurrPos[6] = (aMovingNpc.X As Int)
         _aiMoveToCurrPos[7] = (aMovingNpc.Y As Int)
         _aiMoveToCurrPos[8] = (aMovingNpc.Z As Int)
      EndIf
   EndIf

   If (1.09 > _fCurrVer)
      _szQuickSaveName = "DfwQuickSave"
      _szAutoSaveName = "DfwAutoSave"
   EndIf

   If (1.10 > _fCurrVer)
      _aiLastDoorLocation = New Int[3]
      _aiLastDoorLocation[0] = 0
      _aiLastDoorLocation[1] = 0
      _aiLastDoorLocation[2] = 0
   EndIf

   If (1.12 > _fCurrVer)
      InitRegions()

      _oGold     = (Game.GetFormFromFile(0x0000000F, "Skyrim.esm") As MiscObject)
      _oLockpick = (Game.GetFormFromFile(0x0000000A, "Skyrim.esm") As MiscObject)

      _oZazRestraintHider = \
         (Game.GetFormFromFile(0x00040F0C, "Devious Devices - Integration.esm") As Armor)
      _oZbfRestraintHider = (Game.GetFormFromFile(0x00022749, "ZaZAnimationPack.esm") As Armor)

      _oDeviousKeyChastity = \
         (Game.GetFormFromFile(0x00008A4F, "Devious Devices - Integration.esm") As Key)
      _oDeviousKeyPiercings = \
         (Game.GetFormFromFile(0x000409A4, "Devious Devices - Integration.esm") As Key)
      _oDeviousKeyRestraints = \
         (Game.GetFormFromFile(0x0001775F, "Devious Devices - Integration.esm") As Key)

      _oFtmChastityKey  = (Game.GetFormFromFile(0x0800538B, "FtM_3.esp") As Key)
      _oFtmRestraintKey = (Game.GetFormFromFile(0x0000538C, "FtM_3.esp") As Key)
      _oFtmPiercingTool = (Game.GetFormFromFile(0x0000538D, "FtM_3.esp") As Key)

      _oDclKeyBody = (Game.GetFormFromFile(0x0004BB4D, "Deviously Cursed Loot.esp") As Key)
      _oDclKeyHand = (Game.GetFormFromFile(0x0004BB4B, "Deviously Cursed Loot.esp") As Key)
      _oDclKeyHead = (Game.GetFormFromFile(0x0004BB4C, "Deviously Cursed Loot.esp") As Key)
      _oDclKeyHighSecurity = \
         (Game.GetFormFromFile(0x00017CA4, "Deviously Cursed Loot.esp") As Key)
      _oDclKeyLeg = (Game.GetFormFromFile(0x0004BB4E, "Deviously Cursed Loot.esp") As Key)

      _oKeywordVendorNoSale  = Keyword.GetKeyword("VendorNoSale")
      _oKeywordVendorItemKey = Keyword.GetKeyword("VendorItemKey")

      ; Initialize this MCM variable.  There are some situations where it isn't updated.
      _iMcmCollectorSpecialCost = 10000

      ; Extract all of the chests from aliases into local variables for easy access.
      ; Note: Persistent items can be taken from the mod using GetFormFromFile().
      ;       The Collector's Merchant chest is a persistent object and does not need an alias;
      ;       however, the other two chest do not have any other references and cannot be
      ;       accessed using GetFormFromFile().  Aliases are needed to access them here.
      ReferenceAlias aAlias = (GetAlias(8) As ReferenceAlias)
      If (!aAlias.GetReference())
         ; Make sure the alias is filled.  It will not be except for new games.
         aAlias.ForceRefIfEmpty(Game.GetFormFromFile(0x000105F0, "DeviousFramework.esm") \
                                As ObjectReference)
      EndIf
      _oCollectorsChest = (aAlias.GetReference() As ObjectReference)
      aAlias = (GetAlias(9) As ReferenceAlias)
      If (!aAlias.GetReference())
         ; Make sure the alias is filled.  It will not be except for new games.
         aAlias.ForceRefIfEmpty(Game.GetFormFromFile(0x000120EA, "DeviousFramework.esm") \
                                As ObjectReference)
      EndIf
      _oCollectorsSpecialChest = (aAlias.GetReference() As ObjectReference)
      aAlias = (GetAlias(10) As ReferenceAlias)
      If (!aAlias.GetReference())
         ; Make sure the alias is filled.  It will not be except for new games.
         aAlias.ForceRefIfEmpty(Game.GetFormFromFile(0x00012BAF, "DeviousFramework.esm") \
                                As ObjectReference)
      EndIf
      _oCollectorsNewItemChest = (aAlias.GetReference() As ObjectReference)
      aAlias = (GetAlias(11) As ReferenceAlias)
      If (!aAlias.GetReference())
         ; Make sure the alias is filled.  It will not be except for new games.
         aAlias.ForceRefIfEmpty(Game.GetFormFromFile(0x00014148, "DeviousFramework.esm") \
                                As ObjectReference)
      EndIf
      _oPlayerItemTemporaryChest = (aAlias.GetReference() As ObjectReference)

      _iZazSlottedMutex = iMutexCreate("DFW Zaz Slotted")
      _iZazSlottedCount = 0

      _iMovePlayerMutex = iMutexCreate("DFW MovePlayer")

      _oKeywordZadBondageMittens = Keyword.GetKeyword("zad_DeviousBondageMittens")
      _oKeywordZbfFurnitureMulti = Keyword.GetKeyword("zbfFurnitureMultiRestraint")

      _aAliasGiveSpaceTarget = (GetAlias(12) As ReferenceAlias)
      _aAliasGiveSpace1      = (GetAlias(13) As ReferenceAlias)
      _aAliasGiveSpace2      = (GetAlias(14) As ReferenceAlias)
      _aAliasGiveSpace3      = (GetAlias(15) As ReferenceAlias)

      _aaAliasHoverTarget = New ReferenceAlias[3]
      _aaAliasHover       = New ReferenceAlias[3]
      _aszHoverAtModId    = New String[3]

      _iHoverAtTimeout    = New Int[3]
      _aaAliasHoverTarget[0] = (GetAlias(6) As ReferenceAlias)
      _aaAliasHoverTarget[1] = (GetAlias(16) As ReferenceAlias)
      _aaAliasHoverTarget[2] = (GetAlias(18) As ReferenceAlias)
      _aaAliasHover[0]       = (GetAlias(7) As ReferenceAlias)
      _aaAliasHover[1]       = (GetAlias(17) As ReferenceAlias)
      _aaAliasHover[2]       = (GetAlias(19) As ReferenceAlias)

      InitKnownPoses()
; zxc
_qMcm.iModTogglePoseKey = 34
_qMcm.iModCyclePoseKey = 48
_qMcm.iModTogglePose = 3
   EndIf

   ; Finally update the version number.
   _fCurrVer = fScriptVer
   DebugTrace("TraceEvent UpdateScript: Done")
EndFunction

Function InitKnownPoses()
   _aszKnownPoses    = New String[4]
   _aiKnownPoseFlags = New Int[4]

   ; "Default Idle"
   _aszKnownPoses[0] = ""
   ; 0x0001: A default idle.
   _aiKnownPoseFlags[0] = 0x0001

   ; "Kneeling"
   _aszKnownPoses[1] = "ZazAPC018"
   ; 0x0004: A toggle pose.  It must be turned on and off.
   ; 0x0078: This pose prevents movement, activation, inventory, and fighting.
   ; 0x0080: The pose is considred kneeling.
   _aiKnownPoseFlags[1] = 0x0004 + 0x0078 + 0x0080

   ; "Kneeling Spread"
   _aszKnownPoses[2] = "ZazAPC019"
   ; 0x0004: A toggle pose.  It must be turned on and off.
   ; 0x0078: This pose prevents movement, activation, inventory, and fighting.
   ; 0x0280: The pose is considred kneeling and exposed.
   _aiKnownPoseFlags[2] = 0x0004 + 0x0078 + 0x0280

   ; "Crawling"
   _aszKnownPoses[3] = "SD_Crawl"
   ; 0x8000: A complex pose which can't be handled via the standard funcitons.
   ; 0x0002: An idle but not a default.
   ; 0x0070: This pose prevents activation, inventory, and fighting.
   ; 0x0100: The pose is considred crawling.
   _aiKnownPoseFlags[3] = 0x8000 + 0x0002 + 0x0070 + 0x0100
EndFunction

Function InitRegions()
   DebugTrace("TraceEvent InitRegions")
    REGION_DAWNSTAR = (Game.GetFormFromFile(0x00018A50, "Skyrim.esm") As Location)
   SUBURBS_DAWNSTAR = New Location[1]
   SUBURBS_DAWNSTAR[0] = (Game.GetFormFromFile(0x00019429, "Skyrim.esm") As Location) ; DawnstarSanctuaryLocation

    REGION_DRAGON_BRIDGE = (Game.GetFormFromFile(0x00018A46, "Skyrim.esm") As Location)

    REGION_FALKREATH = (Game.GetFormFromFile(0x00018A49, "Skyrim.esm") As Location)
   SUBURBS_FALKREATH = New Location[3]
   SUBURBS_FALKREATH[0] = (Game.GetFormFromFile(0x000479B3, "Skyrim.esm") As Location) ; FalkreathWatchtowerLocation
   SUBURBS_FALKREATH[1] = (Game.GetFormFromFile(0x00018E3E, "Skyrim.esm") As Location) ; HalfmoonMillLocation
   SUBURBS_FALKREATH[2] = (Game.GetFormFromFile(0x000200AB, "Skyrim.esm") As Location) ; HalfMoonLumberMillLocation

    REGION_HIGH_HROTHGAR = (Game.GetFormFromFile(0x00018E34, "Skyrim.esm") As Location)
   SUBURBS_HIGH_HROTHGAR = New Location[1]
   SUBURBS_HIGH_HROTHGAR[0] = (Game.GetFormFromFile(0x000192BB, "Skyrim.esm") As Location) ; ThroatoftheWorldLocation

    REGION_IVARSTEAD = (Game.GetFormFromFile(0x00018A4B, "Skyrim.esm") As Location)

    REGION_KARTHWASTEN = (Game.GetFormFromFile(0x00018A54, "Skyrim.esm") As Location)

    REGION_MARKARTH = (Game.GetFormFromFile(0x00018A59, "Skyrim.esm") As Location)
   SUBURBS_MARKARTH = New Location[7]
   SUBURBS_MARKARTH[0] = (Game.GetFormFromFile(0x00018E3A, "Skyrim.esm") As Location) ; LeftHandMineLocation
   SUBURBS_MARKARTH[1] = (Game.GetFormFromFile(0x0001F7B8, "Skyrim.esm") As Location) ; LeftHandMineDaighresHouseLocation
   SUBURBS_MARKARTH[2] = (Game.GetFormFromFile(0x0001F7B6, "Skyrim.esm") As Location) ; LeftHandMineMineLocation
   SUBURBS_MARKARTH[3] = (Game.GetFormFromFile(0x0001F7B7, "Skyrim.esm") As Location) ; LeftHandMineMinersBarracksLocation
   SUBURBS_MARKARTH[4] = (Game.GetFormFromFile(0x0001F7B5, "Skyrim.esm") As Location) ; LeftHandMineSkaggisHouseLocation
   SUBURBS_MARKARTH[5] = (Game.GetFormFromFile(0x00018E40, "Skyrim.esm") As Location) ; SalviusFarmLocation
   SUBURBS_MARKARTH[6] = (Game.GetFormFromFile(0x0001F805, "Skyrim.esm") As Location) ; SalviusFarmhouseLocation

    REGION_MORTHAL = (Game.GetFormFromFile(0x00018A53, "Skyrim.esm") As Location)

    REGION_OLD_HROLDAN = (Game.GetFormFromFile(0x00018A55, "Skyrim.esm") As Location)

    REGION_RIFTEN = (Game.GetFormFromFile(0x00018A58, "Skyrim.esm") As Location)
   SUBURBS_RIFTEN = New Location[6]
   SUBURBS_RIFTEN[0] = (Game.GetFormFromFile(0x00018E32, "Skyrim.esm") As Location) ; GoldenglowEstateLocation
   SUBURBS_RIFTEN[1] = (Game.GetFormFromFile(0x00018E33, "Skyrim.esm") As Location) ; HeartwoodMillLocation
   SUBURBS_RIFTEN[2] = (Game.GetFormFromFile(0x0005E0FB, "Skyrim.esm") As Location) ; HeartwoodMillInteriorLocation
   SUBURBS_RIFTEN[3] = (Game.GetFormFromFile(0x00018E3C, "Skyrim.esm") As Location) ; MerryfairFarmLocation
   SUBURBS_RIFTEN[4] = (Game.GetFormFromFile(0x00018E41, "Skyrim.esm") As Location) ; SarethiFarmLocation
   SUBURBS_RIFTEN[5] = (Game.GetFormFromFile(0x00018E43, "Skyrim.esm") As Location) ; SnowShodFarmLocation

    REGION_RIVERWOOD = (Game.GetFormFromFile(0x00013163, "Skyrim.esm") As Location)

    REGION_RORIKSTEAD = (Game.GetFormFromFile(0x00018A47, "Skyrim.esm") As Location)
   SUBURBS_RORIKSTEAD = New Location[1]
   SUBURBS_RORIKSTEAD[0] = (Game.GetFormFromFile(0x000E66A5, "Skyrim.esm") As Location) ; LundsHutLocation

    REGION_SHORS_STONE = (Game.GetFormFromFile(0x00018A4C, "Skyrim.esm") As Location)
   SUBURBS_SHORS_STONE = New Location[1]
   SUBURBS_SHORS_STONE[0] = (Game.GetFormFromFile(0x000D5669, "Skyrim.esm") As Location) ; ShorsWatchtowerLocation

    REGION_SKY_HAVEN = (Game.GetFormFromFile(0x00018E42, "Skyrim.esm") As Location)

    REGION_SOLITUDE         = (Game.GetFormFromFile(0x00018A5A, "Skyrim.esm") As Location)
    SUBURB_SOLITUDE_AVENUES = (Game.GetFormFromFile(0x000358B8, "Skyrim.esm") As Location)
    SUBURB_SOLITUDE_WELLS   = (Game.GetFormFromFile(0x000358B7, "Skyrim.esm") As Location)
   SUBURBS_SOLITUDE = New Location[6]
   SUBURBS_SOLITUDE[0] = (Game.GetFormFromFile(0x0002008E, "Skyrim.esm") As Location) ; EastEmpireWarehouseLocation
   SUBURBS_SOLITUDE[1] = (Game.GetFormFromFile(0x0004FEF1, "Skyrim.esm") As Location) ; SolitudeEastEmpireWarehouseLocation
   SUBURBS_SOLITUDE[2] = (Game.GetFormFromFile(0x00018E44, "Skyrim.esm") As Location) ; SolitudeSawmillLocation
   SUBURBS_SOLITUDE[3] = (Game.GetFormFromFile(0x0010FE2C, "Skyrim.esm") As Location) ; SolitudeSawmillInteriorLocation
   SUBURBS_SOLITUDE[4] = (Game.GetFormFromFile(0x0001914A, "Skyrim.esm") As Location) ; BluePalaceWingLocation
   SUBURBS_SOLITUDE[5] = (Game.GetFormFromFile(0x00018E38, "Skyrim.esm") As Location) ; KatlasFarmLocation

    REGION_THALMOR_EMBASSY = (Game.GetFormFromFile(0x00018C92, "Skyrim.esm") As Location)

    REGION_WHITERUN = (Game.GetFormFromFile(0x00018A56, "Skyrim.esm") As Location)
   SUBURBS_WHITERUN = New Location[9]
   SUBURBS_WHITERUN[0] = (Game.GetFormFromFile(0x00049B60, "Skyrim.esm") As Location) ; WhiterunHonningbrewMeaderyInteriorLocation
   SUBURBS_WHITERUN[1] = (Game.GetFormFromFile(0x00023E5D, "Skyrim.esm") As Location) ; WhiterunJorrvaskrBasementLocation
   SUBURBS_WHITERUN[2] = (Game.GetFormFromFile(0x000D9079, "Skyrim.esm") As Location) ; WhiterunWatchtowerLocation
   SUBURBS_WHITERUN[3] = (Game.GetFormFromFile(0x000E66A0, "Skyrim.esm") As Location) ; WhitewatchTowerLocation
   SUBURBS_WHITERUN[4] = (Game.GetFormFromFile(0x00018C8C, "Skyrim.esm") As Location) ; BarleydarkFarmLocation
   SUBURBS_WHITERUN[5] = (Game.GetFormFromFile(0x00018C8D, "Skyrim.esm") As Location) ; BattleBornFarmLocation
   SUBURBS_WHITERUN[6] = (Game.GetFormFromFile(0x00018C90, "Skyrim.esm") As Location) ; ChillfurrowFarmLocation
   SUBURBS_WHITERUN[7] = (Game.GetFormFromFile(0x000674F0, "Skyrim.esm") As Location) ; CWCampsiteWhiterunLocation
   SUBURBS_WHITERUN[8] = (Game.GetFormFromFile(0x00018E3F, "Skyrim.esm") As Location) ; PelagiaFarmLocation

    REGION_WINDHELM = (Game.GetFormFromFile(0x00018A57, "Skyrim.esm") As Location)
   SUBURBS_WINDHELM = New Location[10]
   SUBURBS_WINDHELM[0] = (Game.GetFormFromFile(0x00018C8F, "Skyrim.esm") As Location) ; BrandyMugFarmLocation
   SUBURBS_WINDHELM[1] = (Game.GetFormFromFile(0x000BEDEE, "Skyrim.esm") As Location) ; BrandyMugFarmInteriorLocation
   SUBURBS_WINDHELM[2] = (Game.GetFormFromFile(0x00018E35, "Skyrim.esm") As Location) ; HlaaluFarmLocation
   SUBURBS_WINDHELM[3] = (Game.GetFormFromFile(0x0001705D, "Skyrim.esm") As Location) ; HlaaluFarmInteriorLocation
   SUBURBS_WINDHELM[4] = (Game.GetFormFromFile(0x00018E36, "Skyrim.esm") As Location) ; HollyfrostFarmLocation
   SUBURBS_WINDHELM[5] = (Game.GetFormFromFile(0x0001705B, "Skyrim.esm") As Location) ; HollyfrostFarmInteriorLocation
   SUBURBS_WINDHELM[6] = (Game.GetFormFromFile(0x000EF572, "Skyrim.esm") As Location) ; RefugeesRestLocation
   SUBURBS_WINDHELM[7] = (Game.GetFormFromFile(0x00018A4E, "Skyrim.esm") As Location) ; KynesgroveLocation
   SUBURBS_WINDHELM[8] = (Game.GetFormFromFile(0x00020A02, "Skyrim.esm") As Location) ; KynesgroveBraidwoodInnLocation
   SUBURBS_WINDHELM[9] = (Game.GetFormFromFile(0x00020A07, "Skyrim.esm") As Location) ; KynesgroveSteamscorchGullyMineLocation

    REGION_WINTERHOLD = (Game.GetFormFromFile(0x00018A51, "Skyrim.esm") As Location)
    SUBURB_WINTERHOLD_COLLEGE = (Game.GetFormFromFile(0x00076F3A, "Skyrim.esm") As Location)
   SUBURBS_WINTERHOLD = New Location[1]
   SUBURBS_WINTERHOLD[0] = (Game.GetFormFromFile(0x00018E45, "Skyrim.esm") As Location) ; WhistlingMineLocation

   InitSpecialCells()

   REGIONS_INDEXED = New Location[19]
   REGIONS_INDEXED[0]  = REGION_DAWNSTAR
   REGIONS_INDEXED[1]  = REGION_DRAGON_BRIDGE
   REGIONS_INDEXED[2]  = REGION_FALKREATH
   REGIONS_INDEXED[3]  = REGION_HIGH_HROTHGAR
   REGIONS_INDEXED[4]  = REGION_IVARSTEAD
   REGIONS_INDEXED[5]  = REGION_KARTHWASTEN
   REGIONS_INDEXED[6]  = REGION_MARKARTH
   REGIONS_INDEXED[7]  = REGION_MORTHAL
   REGIONS_INDEXED[8]  = REGION_OLD_HROLDAN
   REGIONS_INDEXED[9]  = REGION_RIFTEN
   REGIONS_INDEXED[10] = REGION_RIVERWOOD
   REGIONS_INDEXED[11] = REGION_RORIKSTEAD
   REGIONS_INDEXED[12] = REGION_SHORS_STONE
   REGIONS_INDEXED[13] = REGION_SKY_HAVEN
   REGIONS_INDEXED[14] = REGION_SOLITUDE
   REGIONS_INDEXED[15] = REGION_THALMOR_EMBASSY
   REGIONS_INDEXED[16] = REGION_WHITERUN
   REGIONS_INDEXED[17] = REGION_WINDHELM
   REGIONS_INDEXED[18] = REGION_WINTERHOLD

   DebugTrace("TraceEvent InitRegions: Done")
EndFunction

Function InitSpecialCells()
   DebugTrace("TraceEvent InitSpecialCells")
   SPECIAL_CELLS = New Form[2]
   SPECIAL_CELL_LOCATIONS = New Form[2]

   ; This cell is at the back of the houses of Dragon's Bridge.  It holds a Pilory from the
   ; Slavegirls by hydragorgon mod.
   SPECIAL_CELLS[0] = Game.GetFormFromFile(0x00009307, "Skyrim.esm")
   SPECIAL_CELL_LOCATIONS[0] = REGION_DRAGON_BRIDGE

   ; This cell is a hut beside the lumber mill at the Half Moon Mill.  It holds a Pilory from
   ; the Slavegirls by hydragorgon mod.
   SPECIAL_CELLS[1] = Game.GetFormFromFile(0x00009B7A, "Skyrim.esm")
   SPECIAL_CELL_LOCATIONS[1] = SUBURBS_FALKREATH[2]

   ; Check for any locations from drlove33's Slave Den mod.
   Int iModOrder = Game.GetModByName("_SHC2.esp")
   If ((-1 < iModOrder) && (255 > iModOrder))
      Cell oModCell =  (Game.GetFormFromFile(0x000012E9, "_SHC2.esp") As Cell) ; _SimpleFarm
      If (oModCell)
         SPECIAL_CELLS = _qDfwUtil.AddFormToArray(SPECIAL_CELLS, oModCell)
         SPECIAL_CELL_LOCATIONS = _qDfwUtil.AddFormToArray(SPECIAL_CELL_LOCATIONS, \
                                                           SUBURBS_WHITERUN[2])
      EndIf
      oModCell =  (Game.GetFormFromFile(0x0000160A, "_SHC2.esp") As Cell) ; _guardroom
      If (oModCell)
         SPECIAL_CELLS = _qDfwUtil.AddFormToArray(SPECIAL_CELLS, oModCell)
         SPECIAL_CELL_LOCATIONS = _qDfwUtil.AddFormToArray(SPECIAL_CELL_LOCATIONS, \
                                                           SUBURBS_WHITERUN[2])
      EndIf
      oModCell =  (Game.GetFormFromFile(0x000013E7, "_SHC2.esp") As Cell) ; _Shc2
      If (oModCell)
         SPECIAL_CELLS = _qDfwUtil.AddFormToArray(SPECIAL_CELLS, oModCell)
         SPECIAL_CELL_LOCATIONS = _qDfwUtil.AddFormToArray(SPECIAL_CELL_LOCATIONS, \
                                                           SUBURBS_WHITERUN[2])
      EndIf
   EndIf

   ; Check for any locations from drlove33's Eastern Holding Cells mod.
   If (_qMcm.bEasternHouseIsWindhelm)
      iModOrder = Game.GetModByName("shc3.esm.esp")
      If ((-1 < iModOrder) && (255 > iModOrder))
         Cell oModCell =  \
            (Game.GetFormFromFile(0x0000AB60, "shc3.esm.esp") As Cell) ; _holdingcells
         If (oModCell)
            SPECIAL_CELLS = _qDfwUtil.AddFormToArray(SPECIAL_CELLS, oModCell)
            SPECIAL_CELL_LOCATIONS = _qDfwUtil.AddFormToArray(SPECIAL_CELL_LOCATIONS, \
                                                              SUBURBS_WINDHELM[7])
         EndIf
         oModCell =  (Game.GetFormFromFile(0x0000AA76, "shc3.esm.esp") As Cell) ; _Easternhc
         If (oModCell)
            SPECIAL_CELLS = _qDfwUtil.AddFormToArray(SPECIAL_CELLS, oModCell)
            SPECIAL_CELL_LOCATIONS = _qDfwUtil.AddFormToArray(SPECIAL_CELL_LOCATIONS, \
                                                              SUBURBS_WINDHELM[7])
         EndIf
      EndIf
   EndIf
   DebugTrace("TraceEvent InitSpecialCells: Done")
EndFunction

Function OnPlayerLoadGame()
   DebugTrace("TraceEvent OnPlayerLoadGame")
   ; Use a flag to prevent initialization from happening twice.
   If (_bGameLoadInProgress)
      DebugTrace("TraceEvent OnPlayerLoadGame: Done (In Progress)")
      Return
   EndIf
   _bGameLoadInProgress = True

; zxc
_iHoverAtTimeout = New Int[3]
_iHoverAtTimeout[0] = 10
_iHoverAtTimeout[1] = 10
_iHoverAtTimeout[2] = 10
UpdateLocalMcmSettings()

   Float fCurrTime = Utility.GetCurrentRealTime()
   Log("Game Loaded.", DL_INFO, DC_GENERAL)

   If (_bBlockLoad && !_iBlockLoadTimer)
      Utility.Wait(15)
      Log("Save Game Control: Invalid Game Detected.", DL_CRIT, DC_SAVE)
      _iBlockLoadTimer = 15
   EndIf

   If (_iBlockConsoleTimer)
      Utility.Wait(15)
      Log("Save Game Control: Invalid Game Detected.", DL_CRIT, DC_SAVE)
      _iBlockConsoleTimer = 15
   EndIf

   ; If any real time timers are active reset them to the current time because the real time
   ; clock is reset each time the game is loaded.
   If (_iBleedoutTime)
      _iBleedoutTime = fCurrTime + 30
   EndIf
   ; The nearby cleanup timeout is always set.  Always reset it.
   _fNearbyCleanupTime = fCurrTime + 3
   _fSceneTimeout = 0
   _szCurrentScene = ""
   _bInScene = False
   _bSceneExtendsCallout = False

   ; Update all quest variables upon loading each game.
   ; There are too many things that can cause them to become invalid.
   _qMcm               = ((Self As Quest) As dfwMcm)
   _qDfwUtil           = ((Self As Quest) As dfwUtil)
   _qZadLibs           = (Quest.GetQuest("zadQuest") As Zadlibs)
   _qSexLab            = (Quest.GetQuest("SexLabQuestFramework") As SexLabFramework)
   _qSexLabArousedMain = (Quest.GetQuest("sla_Main") As slaMainScr)
   _qSexLabAroused     = (Quest.GetQuest("sla_Framework") As slaFrameworkScr)
   _qZbfSlave          = zbfSlaveControl.GetApi()
   _qZbfSlaveActions   = zbfSlaveActions.GetApi()
   _qZbfPlayerSlot     = zbfBondageShell.GetApi().FindPlayer()

   ; On each load game make sure to re-apply any blocked effects.
   If (_qMcm.bModBlockOnGameLoad)
      If (0 > _iBlockHealthRegen)
         RestoreHealthRegen()
         _iBlockHealthRegen = 0
      EndIf
      If (0 > _iBlockMagickaRegen)
         RestoreMagickaRegen()
         _iBlockMagickaRegen = 0
      EndIf
      If (0 > _iBlockStaminaRegen)
         RestoreStaminaRegen()
         _iBlockStaminaRegen = 0
      EndIf
      If (0 > _iDisableMagicka)
         DisableMagicka(False)
         _iDisableMagicka = 0
      EndIf
      If (0 > _iDisableStamina)
         DisableStamina(False)
         _iDisableStamina = 0
      EndIf
      If (0 > _iBlockFastTravel)
         RestoreFastTravel()
         _iBlockFastTravel = 0
      EndIf
      If (0 > _iBlockMovement)
         RestoreMovement()
         _iBlockMovement = 0
      EndIf
      If (0 > _iBlockFighting)
         RestoreFighting()
         _iBlockFighting = 0
      EndIf
      If (0 > _iBlockCameraSwitch)
         RestoreCameraSwitch()
         _iBlockCameraSwitch = 0
      EndIf
      If (0 > _iBlockLooking)
         RestoreLooking()
         _iBlockLooking = 0
      EndIf
      If (0 > _iBlockSneaking)
         RestoreSneaking()
         _iBlockSneaking = 0
      EndIf
      If (0 > _iBlockMenu)
         RestoreMenu()
         _iBlockMenu = 0
      EndIf
      If (0 > _iBlockActivate)
         RestoreActivate()
         _iBlockActivate = 0
      EndIf
      If (0 > _iBlockJournal)
         RestoreJournal()
         _iBlockJournal = 0
      EndIf

      If (_iBlockHealthRegen)
         _aPlayer.DamageActorValue("HealRate", _aPlayer.GetActorValue("HealRate") * 0.99)
      EndIf
      If (_iDisableMagicka)
         _aPlayer.DamageActorValue("MagickaRate", _aPlayer.GetActorValue("MagickaRate"))
         _aPlayer.DamageActorValue("Magicka", _aPlayer.GetActorValue("Magicka"))
      ElseIf (_iBlockMagickaRegen)
         _aPlayer.DamageActorValue("MagickaRate", _aPlayer.GetActorValue("MagickaRate") * 0.99)
      EndIf
      If (_iDisableStamina)
         _aPlayer.DamageActorValue("StaminaRate", _aPlayer.GetActorValue("StaminaRate"))
         _aPlayer.DamageActorValue("Stamina", _aPlayer.GetActorValue("Stamina"))
      ElseIf (_iBlockStaminaRegen)
         _aPlayer.DamageActorValue("StaminaRate", _aPlayer.GetActorValue("StaminaRate") * 0.99)
      EndIf
      If (_iBlockFastTravel)
         Game.EnableFastTravel(False)
      EndIf
      Bool bMove     = (0 != _iBlockMovement)
      Bool bFight    = (0 != _iBlockFighting)
      Bool bCam      = (0 != _iBlockCameraSwitch)
      Bool bLook     = (0 != _iBlockLooking)
      Bool bSneak    = (0 != _iBlockSneaking)
      Bool bMenu     = (0 != _iBlockMenu)
      Bool bActivate = (0 != _iBlockActivate)
      Bool bJournal  = (0 != _iBlockJournal)
      If (bMove || bFight || bCam || bLook || bSneak || bMenu || bActivate || bJournal)
         Game.DisablePlayerControls(bMove, bFight, bCam, bLook, bSneak, bMenu, bActivate, \
                                    bJournal)
      EndIf
   EndIf

   ; If the nearby actors lists are out of sync clear them completely.
   If (_aoNearby.Length != _aiNearbyFlags.Length)
      Log("Nearby Lists Out of Sync!  Cleaning.", DL_ERROR, DC_NEARBY)
      If (MutexLock(_iNearbyMutex))
         While (_aoNearby.Length)
            _aoNearby = _qDfwUtil.RemoveFormFromArray(_aoNearby, None, 0)
         EndWhile
         While (_aiNearbyFlags.Length)
            _aiNearbyFlags = _qDfwUtil.RemoveIntFromArray(_aiNearbyFlags, 0, 0)
         EndWhile

         MutexRelease(_iNearbyMutex)
      EndIf
   EndIf

   ; Validate the known actors list.
   Int iCount = _aoKnown.Length
   If ((iCount != _afKnownLastSeen.Length)  || (iCount != _aiKnownSignificant.Length) || \
       (iCount != _aiKnownAnger.Length)     || (iCount != _aiKnownConfidence.Length) || \
       (iCount != _aiKnownDominance.Length) || (iCount != _aiKnownInterest.Length) || \
       (iCount != _aiKnownKindness.Length))
      Log("Error in Known Actors.  Resetting.", DL_ERROR, DC_NEARBY)
      While (_aoKnown.Length)
         _aoKnown = _qDfwUtil.RemoveFormFromArray(_aoKnown, None, 0)
      EndWhile
      While (_afKnownLastSeen.Length)
         _afKnownLastSeen = _qDfwUtil.RemoveFloatFromArray(_afKnownLastSeen, 0.0, 0)
      EndWhile
      While (_aiKnownSignificant.Length)
         _aiKnownSignificant = _qDfwUtil.RemoveIntFromArray(_aiKnownSignificant, 0, 0)
      EndWhile
      While (_aiKnownAnger.Length)
         _aiKnownAnger = _qDfwUtil.RemoveIntFromArray(_aiKnownAnger, 0, 0)
      EndWhile
      While (_aiKnownConfidence.Length)
         _aiKnownConfidence = _qDfwUtil.RemoveIntFromArray(_aiKnownConfidence, 0, 0)
      EndWhile
      While (_aiKnownDominance.Length)
         _aiKnownDominance = _qDfwUtil.RemoveIntFromArray(_aiKnownDominance, 0, 0)
      EndWhile
      While (_aiKnownInterest.Length)
         _aiKnownInterest = _qDfwUtil.RemoveIntFromArray(_aiKnownInterest, 0, 0)
      EndWhile
      While (_aiKnownKindness.Length)
         _aiKnownKindness = _qDfwUtil.RemoveIntFromArray(_aiKnownKindness, 0, 0)
      EndWhile
   EndIf

   ; Get objects from other mods.  Check each game load in case the mod has been added/removed.
   ; Skyrim Perk Enhancements and Rebalanced Gameplay (SPERG) unarmed "fists"
   _oSpergFist1 = None
   _oSpergFist2 = None
   Int iModOrder = Game.GetModByName("SPERG.esm")
   If ((-1 < iModOrder) && (255 > iModOrder))
      _oSpergFist1 = (Game.GetFormFromFile(0x00024689, "SPERG.esm") As Weapon)
      _oSpergFist2 = (Game.GetFormFromFile(0x00035A8E, "SPERG.esm") As Weapon)
   EndIf

   ; Check if the Papyrus Util mod is installed.
   Int iModVersion = PapyrusUtil.GetVersion()
   _bModPapyrusUtil = (0 != iModVersion)
   If (!_bModPapyrusUtil)
      Log("Papyrus Util not installed.  Ignore the above message.", DL_TRACE, DC_GENERAL)
   EndIf

   ; Check if the Sanguine Debuachery+ mod is installed.
   iModOrder = Game.GetModByName("sanguinesDebauchery.esp")
   _bModSdPlus = ((-1 < iModOrder) && (255 > iModOrder))

   ; Extract SD+ crawl idles from the mod.
   _oSdCrawlMoveBackward     = None
   _oSdCrawlMoveForward      = None
   _oSdCrawlTurnLeft         = None
   _oSdCrawlTurnRight        = None
   _oSdCrawlStrafeBackLeft   = None
   _oSdCrawlStrafeBackRight  = None
   _oSdCrawlStrafeStartLeft  = None
   _oSdCrawlStrafeStartRight = None
   If (_bModSdPlus)
      _oSdCrawlMoveBackward = \
         (Game.GetFormFromFile(0x00161B11, "sanguinesDebauchery.esp") as Idle)
      _oSdCrawlMoveForward = \
         (Game.GetFormFromFile(0x00161B14, "sanguinesDebauchery.esp") as Idle)
      _oSdCrawlTurnLeft = \
         (Game.GetFormFromFile(0x00161B17, "sanguinesDebauchery.esp") as Idle)
      _oSdCrawlTurnRight = \
         (Game.GetFormFromFile(0x00161B18, "sanguinesDebauchery.esp") as Idle)
      _oSdCrawlStrafeBackLeft = \
         (Game.GetFormFromFile(0x00161B12, "sanguinesDebauchery.esp") as Idle)
      _oSdCrawlStrafeBackRight = \
         (Game.GetFormFromFile(0x00161B13, "sanguinesDebauchery.esp") as Idle)
      _oSdCrawlStrafeStartLeft = \
         (Game.GetFormFromFile(0x00161B16, "sanguinesDebauchery.esp") as Idle)
      _oSdCrawlStrafeStartRight = \
         (Game.GetFormFromFile(0x00161B15, "sanguinesDebauchery.esp") as Idle)
   EndIf

   ; Strap On by aeon is considered clothing.
   _oStraponByAeon = None
   iModOrder = Game.GetModByName("StrapOnbyaeonv1.1.esp")
   If ((-1 < iModOrder) && (255 > iModOrder))
      _oStraponByAeon = (Game.GetFormFromFile(0x00000D65, "StrapOnbyaeonv1.1.esp") As Armor)
   EndIf

   ; We need to disable Milk Mod Animations when sitting in furniture.  We do this by adding
   ; the being milked spell to the player (which is a bit of a hack).
   _oMmeBeingMilkedSpell = None
   iModOrder = Game.GetModByName("MilkModNEW.esp")
   If ((-1 < iModOrder) && (255 > iModOrder))
      _oMmeBeingMilkedSpell = (Game.GetFormFromFile(0x000369A8, "MilkModNEW.esp") As Spell)
   EndIf

   ; Make sure the utility script gets updated as well.
   _qDfwUtil.OnPlayerLoadGame()

   UpdateScript()

   ; Update the distance for polling nearby actors.  This seems to reset on game load.
   ; Perform this here, after the MCM settings have been loaded (in UpdateScript()).
   UpdatePollingDistance(_iMcmNearbyDistance)

   ; Send out a mod event so other scripts don't have to create a player alias just to get the
   ; on load game event.
   ModEvent.Send(ModEvent.Create("DFW_GameLoaded"))

   _bGameLoadInProgress = False
   Log("Game Loaded Done: " + (Utility.GetCurrentRealTime() - fCurrTime), DL_TRACE, DC_GENERAL)
   DebugTrace("TraceEvent OnPlayerLoadGame: Done")
EndFunction

Function ReRegisterModEvents()
   DebugTrace("TraceEvent ReRegisterModEvents")
   ; Re-register for all mod events.  Should be called from the MCM menu to fix issues.
   RegisterForModEvent("AnimationEnd",       "PostSexCallback")
   RegisterForModEvent("DFW_MCM_Changed",    "UpdateLocalMcmSettings")
   RegisterForModEvent("ZapSlaveActionDone", "OnSlaveActionDone")

   ; Also reset the load game flag here in case it has gotten stuck.
   ; It should be safe since this function shouldn't be called during a load game.
   _bGameLoadInProgress = False
   DebugTrace("TraceEvent ReRegisterModEvents: Done")
EndFunction

Function ClearHovering()
   Int iIndex
   While (iIndex < 3)
      HoverAtClear(_aszHoverAtModId[iIndex])

      iIndex += 1
   EndWhile
EndFunction

Function ClearAllMovement()
   ; Clear Approach data.
   _szApproachModId = ""
   _aAliasApproachPlayer.Clear()

   ; Clear MoveToLocation data.
   _szMoveToLocationModId = ""
   _aAliasMoveToLocation.Clear()
   _aAliasLocationTarget.Clear()

   ; Clear MoveToObject data.
   _szMoveToObjectModId = ""
   _aAliasObjectTarget.Clear()
   _aAliasMoveToObject.Clear()

   ; Clear Hovering data.
   ClearHovering()

   ; Figure out if movement needs to still be monitored.
   _iMonitorMoveTo = 3
   If (!_aAliasApproachPlayer.GetReference() && !_aAliasMoveToLocation.GetReference() && \
       !_aAliasMoveToObject.GetReference())
      _iMonitorMoveTo = 0
   EndIf
EndFunction

Function UpdateLocalMcmSettings(String sCategory="")
   DebugTrace("TraceEvent UpdateLocalMcmSettings")

   ; If this is called before we have configured our MCM quest do so now.
   If (!_qMcm)
      _qMcm = ((Self As Quest) As dfwMcm)
      If (!_qMcm)
         Log("Error: Failed to find MCM quest in UpdateLocalMcmSettings()", DL_ERROR, \
             DC_GENERAL)
         DebugTrace("TraceEvent UpdateLocalMcmSettings: Done (Failed to Get Quest)")
         Return
      EndIf
   EndIf

   If (!sCategory || ("Logging" == sCategory))
      _iMcmLogLevel = _qMcm.iLogLevel

      _aiMcmScreenLogLevel = New Int[12]
      _aiMcmScreenLogLevel[DC_GENERAL]     = _qMcm.iLogLevelScreenGeneral
      _aiMcmScreenLogLevel[DC_DEBUG]       = _qMcm.iLogLevelScreenDebug
      _aiMcmScreenLogLevel[DC_STATUS]      = _qMcm.iLogLevelScreenStatus
      _aiMcmScreenLogLevel[DC_MASTER]      = _qMcm.iLogLevelScreenMaster
      _aiMcmScreenLogLevel[DC_NEARBY]      = _qMcm.iLogLevelScreenNearby
      _aiMcmScreenLogLevel[DC_LEASH]       = _qMcm.iLogLevelScreenLeash
      _aiMcmScreenLogLevel[DC_EQUIP]       = _qMcm.iLogLevelScreenEquip
      _aiMcmScreenLogLevel[DC_NPC_AROUSAL] = _qMcm.iLogLevelScreenArousal
      _aiMcmScreenLogLevel[DC_INTERACTION] = _qMcm.iLogLevelScreenInteraction
      _aiMcmScreenLogLevel[DC_LOCATION]    = _qMcm.iLogLevelScreenLocation
      _aiMcmScreenLogLevel[DC_REDRESS]     = _qMcm.iLogLevelScreenRedress
      _aiMcmScreenLogLevel[DC_SAVE]        = _qMcm.iLogLevelScreenSave
   EndIf

   If (!sCategory || ("ModFeatures" == sCategory))
      _iDialogueTargetStyle = _qMcm.iModDialogueTargetStyle
      _iMcmDialogueRetries  = _qMcm.iModDialogueTargetRetries
      _iMcmLeashMinLength   = _qMcm.iModLeashMinLength
      _iMcmNearbyDistance   = _qMcm.iSettingsNearbyDistance
   EndIf

   If ("ModCrawlActivate" == sCategory)
      ; Go through all crawl poses in the pose list and (un)set the activate flag.
      Int iIndex = _aiKnownPoseFlags.Length - 1
      Bool bOn = _qMcm.bModCrawlBlockActivate
      While (0 <= iIndex)
         ; 0x0100: The pose is considred crawling.
         If (Math.LogicalAnd(_aiKnownPoseFlags[iIndex], 0x0100))
            If (bOn)
               ; 0x0010: This pose prevents activation.
               _aiKnownPoseFlags[iIndex] = Math.LogicalOr(_aiKnownPoseFlags[iIndex], 0x0010)
            Else
               ; 0x0010: This pose prevents activation.
               _aiKnownPoseFlags[iIndex] = Math.LogicalAnd(_aiKnownPoseFlags[iIndex], \
                                                           Math.LogicalNot(0x0010))
            EndIf
         EndIf

         iIndex -= 1
      EndWhile
   EndIf

   If (!sCategory || ("Collector" == sCategory))
      ; Don't allow the local cost to change while items are in the chest.
      If (!_oCollectorsSpecialChest || (0 == _oCollectorsSpecialChest.GetNumItems()))
         _iMcmCollectorSpecialCost = _qMcm.iModCollectorSpecialCost
      EndIf
   EndIf

   If (!sCategory || ("SaveControl" == sCategory))
      _bBlockLoad = False
      If (!_qMcm.iModSaveGameStyle || !_qMcm.bSaveGameConfirm)
         _iMcmSaveGameControlStyle = 0
      Else
         ; Keep track of the name we should use for QuickSave/AutoSave game files.
         If (_qMcm.bConNativeSaves)
            _szQuickSaveName = "QuickSave"
            _szAutoSaveName = "AutoSave1"
         Else
            _szQuickSaveName = "DfwQuickSave"
            _szAutoSaveName = "DfwAutoSave"
         EndIf

         ; Only update the save game control style if it has changed to pevent changing control
         ; status variables that are in use on game load.
         Int iNewStyle = _qMcm.iModSaveGameStyle
         If (iNewStyle != _iMcmSaveGameControlStyle)
            _iMcmSaveGameControlStyle = _qMcm.iModSaveGameStyle
            If (2 == _iMcmSaveGameControlStyle)
               _bBlockLoad = True
               Int iConsoleVulnerability = _qMcm.iConConsoleVulnerability
               If (iConsoleVulnerability && (100 != iConsoleVulnerability))
                  ; Register for detection of the console being opened to detect invalid access.
                  RegisterForMenu("Console")
               Else
                  ; Deregister for detection of the console being opened.
                  UnregisterForMenu("Console")
               EndIf
            EndIf
         EndIf
      EndIf
   EndIf

   If (!sCategory || ("NpcDisposition" == sCategory))
      _iMcmDispWillingGuards    = _qMcm.iDispWillingGuards
      _iMcmDispWillingMerchants = _qMcm.iDispWillingMerchants
      _iMcmDispWillingBdsm      = _qMcm.iDispWillingBdsm
   Endif

   If (_bIsFurnitureLocked && ("SafewordFurniture" == sCategory))
      Log("Safeword BDSM Furniture.", DL_CRIT, DC_GENERAL)
      _bIsFurnitureLocked = False
      _qZbfPlayerSlot.SetFurniture(None)

      ; Release the player's inventory.  Because this is a safeword do it unconditionally.
      _bInventoryLocked = False
      ;    EnablePlayerControls(Move,  Fight, Cam,   Look,  Sneak, Menu,  Active, Journ)
      Game.EnablePlayerControls(False, False, False, False, False, True,  False,  False)
   EndIf

   If ("SafewordLeash" == sCategory)
      Log("Safeword Leash.", DL_CRIT, DC_LEASH)
      _oLeashTarget = None
      _iLeashLength = 700
      _bYankingLeash = False
   EndIf

   ; Process any settings that don't fit into a category.
   If (!sCategory)
      UpdatePollingDistance(_iMcmNearbyDistance)

      Float fNewPollTime = _qMcm.fSettingsPollTime
      ; If the polling interval has changed (or not been initialized) start the poll now.
      If (fNewPollTime != _fMcmPollTime)
         UpdatePollingInterval(fNewPollTime)
      EndIf
   EndIf

   If ("Debug" == sCategory)
      ; If we are re-enabling the mod make sure to start the poll.
      If (_bMcmShutdownMod && !_qMcm.bShutdownMod)
         UpdatePollingInterval(_fMcmPollTime)
      EndIf
      _bMcmShutdownMod = _qMcm.bShutdownMod
   EndIf

   If ("ModMulti" == sCategory)
      SetMultiAnimation()
   EndIf

   DebugTrace("TraceEvent UpdateLocalMcmSettings: Done")
EndFunction


;***********************************************************************************************
;***                                        EVENTS                                           ***
;***********************************************************************************************
; The OnUpdate() code is in a wrapper, PerformOnUpdate().  This is to allow us to return from
; the function without having to add code to re-register for the update at each return point.
Event OnUpdate()
   DebugTrace("TraceEvent OnUpdate")

   ; Print off a clock every five minutes.  Mostly for debugging purposes.
   Float fCurrGameTime = Utility.GetCurrentGameTime()
   If (_fDebugNextClockTick < fCurrGameTime)
      If (_fDebugNextClockTick)
         String sCurrGameTime = Utility.GameTimeToString(fCurrGameTime)
         Debug.Notification("[" + S_MOD + "] " + StringUtil.Substring(sCurrGameTime, 11))
      EndIf
      _fDebugNextClockTick = fCurrGameTime + 0.003472222
      Float fRemainder = _fDebugNextClockTick
      While (0.003472222 < fRemainder)
         If (34.72222 < fRemainder)
            fRemainder -= 34.72222
         ElseIf (3.472222 < fRemainder)
            fRemainder -= 3.472222
         ElseIf (0.3472222 < fRemainder)
            fRemainder -= 0.3472222
         ElseIf (0.03472222 < fRemainder)
            fRemainder -= 0.03472222
         ElseIf (0.003472222 < fRemainder)
            fRemainder -= 0.003472222
         EndIf
      EndWhile
      _fDebugNextClockTick -= fRemainder
   EndIf

   If (!_fCurrVer)
      ; If the script has not been initialized do that instead of processing the update.
      OnPlayerLoadGame()
   ElseIf (0 < _iBlockLoadTimer)
      If (0 == (_iBlockLoadTimer % 5))
         Log("Save Game Control: Shutting Down.", DL_CRIT, DC_SAVE)
      EndIf
      _iBlockLoadTimer -= 1
      If (0 == _iBlockLoadTimer)
         _iBlockLoadTimer = 15
         Game.QuitToMainMenu()
      EndIf
   ElseIf (0 < _iBlockConsoleTimer)
      If (0 == (_iBlockConsoleTimer % 5))
         Log("Save Game Control: Shutting Down.", DL_CRIT, DC_SAVE)
      EndIf
      _iBlockConsoleTimer -= 1
      If (0 == _iBlockConsoleTimer)
         _iBlockConsoleTimer = 15
         Game.QuitToMainMenu()
      EndIf
   ElseIf (_bMcmShutdownMod)
      ; If we are shutting down the mod don't process any requests/events.
      Self.Stop()
      DebugTrace("TraceEvent OnUpdate: Done (Mod Shutting Down)")
      Return
   Else
      PerformOnUpdate()
      Log("Update Done: " + Utility.GetCurrentRealTime(), DL_TRACE, DC_GENERAL)
   EndIf

   ; Register for our next update event.
   ; We are registering for each update individually after the previous processing has
   ; completed to avoid long updates causing multiple future updates to occur at the same time,
   ; thus, piling up.  This is a technique recommended by the community.
   RegisterForSingleUpdate(_fMcmPollTime)
   DebugTrace("TraceEvent OnUpdate: Done")
EndEvent

; DEBUG: Every so often get the player's weapon level to test the GetWeaponLevel() function in
; various situations.
;Int _iWeaponScanCount = 10

Function PerformOnUpdate()
   DebugTrace("TraceEvent PerformOnUpdate")
   Float fCurrTime = Utility.GetCurrentRealTime()
   Log("Update Event: " + fCurrTime, DL_TRACE, DC_GENERAL)

   ; DEBUG: Every so often get the player's weapon level to test the GetWeaponLevel() function
   ; in various situations.
;   _iWeaponScanCount -= 1
;   If (0 >= _iWeaponScanCount)
;      _iWeaponScanCount = 10
;      GetWeaponLevel()
;   EndIf

   ; If the player is not in a city, check for an interior/exterior change to do an auto save.
   If (!_oCurrRegion)
      If (_bIsPlayerInterior != _aPlayer.IsInInterior())
         _bIsPlayerInterior = !_bIsPlayerInterior
         AutoSave()
      EndIf
   EndIf

   ; If the bleedout time is past due reset it.
   If (_iBleedoutTime)
      If (fCurrTime >= _iBleedoutTime)
         _iBleedoutTime = 0
      EndIf
   EndIf

   ; If a scene has run too long abandon it.
   If (_fSceneTimeout)
      If (fCurrTime >= _fSceneTimeout)
         Log("Scene Timeout: " + _szCurrentScene, DL_INFO, DC_INTERACTION)
         _fSceneTimeout = 0
         _szCurrentScene = ""
         _bInScene = False
         _bSceneExtendsCallout = False
      EndIf
   EndIf

   ; Reset the number of items unequipped as we unequip more each poll interval.
   _iNumItemsUnequipped = 0

   ; If we are monitoring a move package make sure the NPC is moving toward his location.
DebugTrace("PerformOnUpdate-CP: Movement Monitor")
   If (1 < _iMonitorMoveTo)
      ; Only monitor movement every 3 polls to reduce Papyrus load.
      _iMonitorMoveTo -= 1
   ElseIf (1 == _iMonitorMoveTo)
      Actor aMovingNpc = (_aAliasApproachPlayer.GetReference() As Actor)
DebugTrace("Monitor Movement - Approach")
      If (aMovingNpc && !aMovingNpc.IsInCombat() && !aMovingNpc.IsInDialogueWithPlayer() && \
          !_qSexLab.IsActorActive(aMovingNpc))
         If (!aMovingNpc.Is3DLoaded() || (150000 < aMovingNpc.GetDistance(_aPlayer)))
            ; If the actor is not near the player have him "fade in" to the player's area.
            NpcMoveNearbyHidden(aMovingNpc)
         Else
            ; Figure out which direction the NPC is moving in.
            Int iDirection = GetDirection(aMovingNpc, _aiMoveToCurrPos[0], _aiMoveToCurrPos[1])

            ; Check if the NPC is moving or not.
            If (4 != iDirection)
               ; The NPC is moving.  Reset the NPC's not moving count.
               ; 0: Approach  1: MoveToLocation  2: MoveToObject
               _aiMoveToStallCount[0] = 0
               _aiMoveToDirection[0] = iDirection
            Else
               ; The NPC is not moving.  Increase the number of times this has happened.
               _aiMoveToStallCount[0] = _aiMoveToStallCount[0] + 1

               ; If this is the third poll the NPC has not moved try to fix the situation.
               If (!(_aiMoveToStallCount[0] % 3))
                  If (500 >= aMovingNpc.GetDistance(_aPlayer))
                     PlayerApproachComplete()
                  Else
                     _qDfwUtil.TeleportToward(aMovingNpc, _aPlayer, 50)
                  EndIf
               EndIf
            EndIf
         EndIf

         ; Mark the NPC's new position.
         ; 0-2: Approach [X,Y,Z]  3-5: MoveToLocation [X,Y,Z]  6-8: MoveToObject [X,Y,Z]
         _aiMoveToCurrPos[0] = (aMovingNpc.X As Int)
         _aiMoveToCurrPos[1] = (aMovingNpc.Y As Int)
         _aiMoveToCurrPos[2] = (aMovingNpc.Z As Int)
      EndIf

      aMovingNpc = (_aAliasMoveToLocation.GetReference() As Actor)
DebugTrace("Monitor Movement - Location")
      If (aMovingNpc && !aMovingNpc.IsInCombat() && !aMovingNpc.IsInDialogueWithPlayer() && \
          !_qSexLab.IsActorActive(aMovingNpc))
         If (!aMovingNpc.Is3DLoaded())
            ; If the actor does not have 3D loaded we know he will fail to arrive.
            MoveToLocationComplete()
         Else
            ; Figure out which direction the NPC is moving in.
            Int iDirection = GetDirection(aMovingNpc, _aiMoveToCurrPos[3], _aiMoveToCurrPos[4])

            ; Check if the NPC is moving or not.
            If (4 != iDirection)
               ; The NPC is moving.  Reset the NPC's not moving count.
               ; 0: Approach  1: MoveToLocation  2: MoveToObject
               _aiMoveToStallCount[1] = 0

               ; Handle any pathing failures in various parts of the world.
               If (_oKynesgrovePathingFixOriginalLocation && (-30000 > aMovingNpc.Y))
                  ; We have passed the problem area.  Restore target to the original location.
                  _aAliasLocationTarget.ForceLocationTo(_oKynesgrovePathingFixOriginalLocation)
                  _oKynesgrovePathingFixOriginalLocation = None

                  ; Reset the actor's package to pick up the original move to target.
                  _aAliasMoveToLocation.Clear()
                  aMovingNpc.EvaluatePackage()
                  _aAliasMoveToLocation.ForceRefTo(aMovingNpc)
                  aMovingNpc.EvaluatePackage()
               ElseIf ((145500 < aMovingNpc.X) && (146500 > aMovingNpc.X) && \
                       ( -3500 < aMovingNpc.Y) && ( -2500 > aMovingNpc.Y) && (2 >= iDirection))
                  ; There is a certain location south of Kynesgrove where the NavMesh is bad.
                  ; Detect if the NPC is in this locaiton and try to get them past it.
                  ; For this pathing fix, path to Ansilvund for a while and then restore the
                  ; original location.
                  Location oAnsilvund = \
                     (Game.GetFormFromFile(0x0001BDFD, "Skyrim.esm") As Location)
                  If (oAnsilvund && !_oKynesgrovePathingFixOriginalLocation)
                     _oKynesgrovePathingFixOriginalLocation = \
                        _aAliasLocationTarget.GetLocation()
                     _aAliasLocationTarget.ForceLocationTo(oAnsilvund)

                     ; Reset the actor's package to pick up the new move to target.
                     _aAliasMoveToLocation.Clear()
                     aMovingNpc.EvaluatePackage()
                     _aAliasMoveToLocation.ForceRefTo(aMovingNpc)
                     aMovingNpc.EvaluatePackage()
                  EndIf
               EndIf
               _aiMoveToDirection[1] = iDirection
            Else
               ; The NPC is not moving.  Increase the number of times this has happened.
               _aiMoveToStallCount[1] = _aiMoveToStallCount[1] + 1

               ; If this is the third poll the NPC has not moved try to fix the situation.
               If (!(_aiMoveToStallCount[1] % 3))
                  If (_aAliasLocationTarget.GetLocation() == aMovingNpc.GetCurrentLocation())
                     MoveToLocationComplete(True)
                  Else
                     _qDfwUtil.TeleportToward(aMovingNpc, _aPlayer, 50)
                  EndIf
               EndIf
            EndIf

            ; Mark the NPC's new position.
            ; 0-2: Approach [X,Y,Z]  3-5: MoveToLocation [X,Y,Z]  6-8: MoveToObject [X,Y,Z]
            _aiMoveToCurrPos[3] = (aMovingNpc.X As Int)
            _aiMoveToCurrPos[4] = (aMovingNpc.Y As Int)
            _aiMoveToCurrPos[5] = (aMovingNpc.Z As Int)
         EndIf
      EndIf

      aMovingNpc = (_aAliasMoveToObject.GetReference() As Actor)
DebugTrace("Monitor Movement - MoveTo")
      If (aMovingNpc && !aMovingNpc.IsInCombat() && !aMovingNpc.IsInDialogueWithPlayer() && \
          !_qSexLab.IsActorActive(aMovingNpc))

         ; If the actor is not near the player but the object is have him "fade in".
         ObjectReference oTargetObject = _aAliasObjectTarget.GetReference()
         If (!aMovingNpc.Is3DLoaded() && oTargetObject.Is3DLoaded())
            NpcMoveNearbyHidden(aMovingNpc)
         EndIf

         ; Figure out which direction the NPC is moving in.
         Int iDirection = GetDirection(aMovingNpc, _aiMoveToCurrPos[6], _aiMoveToCurrPos[7])

         ; Check if the NPC is moving or not.
         If (4 != iDirection)
            ; The NPC is moving.  Reset the NPC's not moving count.
            ; 0: Approach  1: MoveToLocation  2: MoveToObject
            _aiMoveToStallCount[2] = 0
            _aiMoveToDirection[2] = iDirection
         Else
            ; The NPC is not moving.  Increase the number of times this has happened.
            _aiMoveToStallCount[2] = _aiMoveToStallCount[2] + 1

            ; If this is the third poll the NPC has not moved try to fix the situation.
            If (!(_aiMoveToStallCount[2] % 3))
               If (500 >= aMovingNpc.GetDistance(oTargetObject))
                  MoveToObjectComplete()
               Else
                  _qDfwUtil.TeleportToward(aMovingNpc, _aPlayer, 50)
               EndIf
            EndIf
         EndIf

         ; Mark the NPC's new position.
         ; 0-2: Approach [X,Y,Z]  3-5: MoveToLocation [X,Y,Z]  6-8: MoveToObject [X,Y,Z]
         _aiMoveToCurrPos[6] = (aMovingNpc.X As Int)
         _aiMoveToCurrPos[7] = (aMovingNpc.Y As Int)
         _aiMoveToCurrPos[8] = (aMovingNpc.Z As Int)
      EndIf
DebugTrace("Monitor Movement - Done")
      _iMonitorMoveTo = 3
   EndIf

   ; Also check if the hover at packages have timed out.
   Int iIndex
DebugTrace("Monitor Movement - Hover")
   While (iIndex < 3)
      If (0 < _iHoverAtTimeout[iIndex])
         _iHoverAtTimeout[iIndex] = _iHoverAtTimeout[iIndex] - 1
         If (0 == _iHoverAtTimeout[iIndex])
            ; The package has timed out.  Send an event to report the package is done.
            Int iModEvent = ModEvent.Create("DFW_MovementDone")
            If (iModEvent)
               ModEvent.PushInt(iModEvent, 4)
               ModEvent.PushForm(iModEvent, (_aaAliasHover[iIndex].GetReference() As Actor))
               ModEvent.PushBool(iModEvent, True)
               ModEvent.PushString(iModEvent, _aszHoverAtModId[iIndex])
               If (!ModEvent.Send(iModEvent))
                  Log("Failed to send Event DFW_MovementDone(4, True, " + \
                      _aszHoverAtModId[iIndex] + ")", DL_ERROR, DC_INTERACTION)
               EndIf
            EndIf
            HoverAtClear(_aszHoverAtModId[iIndex])
         EndIf
      EndIf
      ; For hover at packages reset the actor's package to force them to continually move closer
      ; to their target.
      Actor aHoveringActor = (_aaAliasHover[iIndex].GetReference() As Actor)
      If (aHoveringActor)
         _aaAliasHover[iIndex].Clear()
         _aaAliasHover[iIndex].ForceRefTo(aHoveringActor)
         aHoveringActor.EvaluatePackage()
      EndIf

      iIndex += 1
   EndWhile

DebugTrace("Monitor Movement - Give Space")
   If (0 < _iGiveSpaceTimeout)
      _iGiveSpaceTimeout -= 1
      If (0 == _iGiveSpaceTimeout)
         GiveSpaceClear(_szGiveSpaceModId)
      EndIf
   EndIf
DebugTrace("Monitor Movement - Done.")

   ; Reduce the timeout for allowing the player to call out.
   ; Don't include scene time or sex time in the call out timeout.
   If ((0 < _iCallOutTimeout) && (_bSceneExtendsCallout || !_szCurrentScene) && \
       !_qSexLab.IsActorActive(_aPlayer))

      _iCallOutTimeout -= 1
      If (0 < _iCallOutResponse)
         _iCallOutResponse -= 1
         If (!_iCallOutResponse)
            If ((1 == _iCallOutType) && _aMasterClose && \
                (300 > _aMasterClose.GetDistance(_aPlayer)))
               Log(_aMasterClose.GetDisplayName() + \
                   " grabs you and stops you from making a scene.", DL_CRIT, DC_INTERACTION)
            ElseIf (_bIsPlayerGagged)
               Log("You don't manage to get anyone's attention.", DL_CRIT, DC_INTERACTION)
            Else
               Log("No one seems to pay much attention to you.", DL_CRIT, DC_INTERACTION)
            EndIf
            _bCallingForAttention = False
            _bCallingForHelp      = False
         EndIf
      EndIf
   EndIf

   If (0 < _iZazSlottedCount)
      ; If we have some actors slotted with the Zaz Animation Pack check if we can remove them.
      If (MutexLock(_iZazSlottedMutex))
         _iZazSlottedCount -= 1
         If (0 == _iZazSlottedCount)
            ; If we have timed out, unslot all actors we previously slotted.
            While (_aoZazSlottedActors.Length)
               zbfBondageShell.GetApi().UnSlotActor((_aoZazSlottedActors[0] As Actor))
               _aoZazSlottedActors = _qDfwUtil.RemoveFormFromArray(_aoZazSlottedActors, None, 0)
            EndWhile
         EndIf

         MutexRelease(_iZazSlottedMutex)
      EndIf
   EndIf

   ; If the player is leashed to a target make sure they are not too far away.
DebugTrace("PerformOnUpdate-CP: Checking Leash")
   If (_oLeashTarget)
      ; Play the leash effect to draw leash particles between the player and the leash holder.
      ; Good:   AuraWhisperProjectile
      ; Usable: AuraWhisperProjectile AlterPosProjectile
      ; Not:    AbsorbBeam01
      If (_qMcm.bModLeashVisible && _oLeashTarget.Is3DLoaded())
         _oDfwLeashSpell.Cast(_oLeashTarget, _aPlayer)
      EndIf

      ; Convert the leash target to an actor.  This will be set to None if it is an object.
      Actor _aLeashTarget = (_oLeashTarget As Actor)

      ; If the leash controller is hostile to the player there is a chance he will pull the
      ; player's leash to knock her off balance.
      If (_aLeashTarget && _aLeashTarget.IsHostileToActor(_aPlayer))
         If (Utility.RandomInt(0, 99) < _qMcm.iModLeashCombatChance)
            Log(_oLeashTarget + " yanks your leash and throws you off balance.", DL_CRIT, \
                DC_LEASH)
            _oLeashTarget.PushActorAway(_aPlayer, -2)
            Utility.Wait(0.5)
            _aPlayer.ForceRemoveRagdollFromWorld()

            ; Damage the player a small amount when this happens.
            _aPlayer.DamageActorValue("Health", _aPlayer.GetActorValue("Health") * 0.05)
         EndIf
      EndIf

      ; Keep track of whether the player is being yanked across a loading screen.  This doesn't
      ; cover all conditions.  It misses external areas to external areas but for now it will
      ; have to do.  This will be considered a leash yank across a great distance.
      Bool bCellTransition = ((_oLeashTarget.GetParentCell() != _aPlayer.GetParentCell()) && \
                              (_oLeashTarget.IsInInterior() || _aPlayer.IsInInterior()))

      Float fDistance = _oLeashTarget.GetDistance(_aPlayer)
      Int iLeashLength = _iLeashLength
      If (_iMcmLeashMinLength && (_iMcmLeashMinLength > iLeashLength))
         iLeashLength = _iMcmLeashMinLength
      EndIf
      If (bCellTransition || (1500 < fDistance))
         If ((!GetBdsmFurniture() || !_bIsFurnitureLocked) && \
             CheckLeashInterruptScene())
            MovePlayer(_oLeashTarget, 25, 25, 50)
            Log("You feel a great tug on your leash as you are pulled along.", DL_CRIT, \
                DC_LEASH)
            ; Teleporting doesn't seem to trigger a change location event.  Change it manually.
            OnLocationChange(None, None)
         EndIf
         DebugTrace("TraceEvent PerformOnUpdate: Done (Leash Yanked)")
         Return
      ElseIf (iLeashLength < fDistance)
         ; Only try to drag the player if she is not busy or we can interrupt the scene.
         If (CheckLeashInterruptScene())
            If (!YankLeash())
               Log("You feel a jerk on your leash as you are pulled roughly.", DL_CRIT, \
                   DC_LEASH)
               ; If the leash target is an actor have him hover at the player momentarily.
               If (IsActor(_oLeashTarget))
                  Actor aLeashTarget = (_oLeashTarget As Actor)
                  If (!aLeashTarget.IsInCombat())
                     HoverAt((_oLeashTarget As Actor), _aPlayer, S_MOD + "_LeashYank", 2)
                  EndIf
               EndIf
            EndIf
         EndIf
      EndIf
   EndIf

   ; Every so many poll iterations we need to detect nearby actors.
DebugTrace("PerformOnUpdate-CP: Nearby Detection")
   If (_qMcm.iSettingsPollNearby)
      _iDetectPollCount += 1
      If (_iDetectPollCount >= _qMcm.iSettingsPollNearby)
         ; To detect nearby actors we cast a spell that hits everyone in the area.
         ; The "effect" of this spell is a script that calls NearbyActorSeen()
         _oDfwNearbyDetectorSpell.Cast(_aPlayer)

         _iDetectPollCount = 0
      EndIf
   EndIf

   ; If we recently changed to the target location, check if the "move to" package is complete.
   If (0 < _iFlagCheckMoveTo)
      Actor aMovingNpc = (_aAliasMoveToLocation.GetReference() As Actor)
      If (_aAliasLocationTarget.GetLocation() == aMovingNpc.GetCurrentLocation())
         MoveToLocationComplete(True)
      EndIf
      _iFlagCheckMoveTo -= 1
   EndIf

   If (!_iFlagSet)
      ; If there are no flags set clean up the nearby actor list.
      CleanupNearbyList()

      ; No flags are set so return here.
      DebugTrace("TraceEvent PerformOnUpdate: Done (No Flags)")
      Return
   EndIf

   ; Decrease the delay before checking the flags.
   _iFlagSet -= 1
   If (2 < _iFlagSet)
      ; If there is still time before checking the flags don't do so now.
      Return
   EndIf

   If (_fNakedRedressTimeout || _fRapeRedressTimeout)
      Float fCurrGameTime = Utility.GetCurrentGameTime()
      If (_fRapeRedressTimeout && (fCurrGameTime > _fRapeRedressTimeout))
         Log("You are now feeling better and recovered from being raped.", DL_INFO, DC_REDRESS)
         _fRapeRedressTimeout = 0
      EndIf
      If (_fNakedRedressTimeout && (fCurrGameTime > _fNakedRedressTimeout))
         Log("You have finished undressing and are ready to dress again.", DL_INFO, DC_REDRESS)
         _fNakedRedressTimeout = 0
      EndIf
   EndIf

   ; Keep track of whether we want to check for additional restraints.
   Bool bCheckLockedUp = False
   If (_bFlagItemEqupped || (_bFlagItemUnequpped && _iNumOtherRestraints))
      bCheckLockedUp = True
   EndIf

DebugTrace("PerformOnUpdate-CP: Checking Clothes")
   If (_bFlagClothesEqupped || _bFlagClothesUnequpped)
      Log("Checking Naked", DL_TRACE, DC_STATUS)

      Int iOldStatus = _iNakedStatus
      CheckIsNaked()
      ; Only do any processing if the dressed state has changed.
      If (iOldStatus != _iNakedStatus)
         ; Some restraints may have been (un)covered.  Make sure to re-check them.
         bCheckLockedUp = True

         ; If the player has just become (more) naked start a redress timeout.
         If ((NS_BOTH_PARTIAL > _iNakedStatus) && (_iNakedStatus < iOldStatus) && \
             _qMcm.iModNakedRedressTimeout)
            _fNakedRedressTimeout = Utility.GetCurrentGameTime() + \
                                    ((_qMcm.iModNakedRedressTimeout As Float) / 1440)
         EndIf

         ; Report the player's status.
         If (NS_NAKED == _iNakedStatus)
            Log("You are now naked.", DL_INFO, DC_STATUS)
         ElseIf (NS_BOTH_PARTIAL > _iNakedStatus)
            Log("You are (partially) naked.", DL_INFO, DC_STATUS)
         ElseIf (NS_BOTH_PARTIAL == _iNakedStatus)
            Log("You are seductively dressed.", DL_INFO, DC_STATUS)
         Else
            Log("You are now fully dressed.", DL_INFO, DC_STATUS)
         EndIf
      EndIf
   EndIf

   If ((_bIsPlayerCollared && _bFlagItemUnequpped) || \
       (!_bIsPlayerCollared && _bFlagItemEqupped))
      Log("Checking Collared", DL_TRACE, DC_STATUS)

      Bool bOldStatus = _bIsPlayerCollared
      _bIsPlayerCollared = False
      If (_aPlayer.WornHasKeyword(_oKeywordZadCollar) || \
          _aPlayer.WornHasKeyword(_oKeywordZbfWornCollar))
         _bIsPlayerCollared = True
      EndIf
      ReportStatus("Collared", _bIsPlayerCollared, bOldStatus)
   EndIf

   ; Keep track of whether we will be checking wrist and ankle bondage.
   Bool bCheckArmLocked = False
   If ((_bIsPlayerArmLocked && _bFlagItemUnequpped) || \
       (!_bIsPlayerArmLocked && _bFlagItemEqupped))
      bCheckArmLocked = True
   EndIf
   Bool bCheckHobbled   = False
   If ((_bIsPlayerHobbled && _bFlagItemUnequpped) || \
       (!_bIsPlayerHobbled && _bFlagItemEqupped))
      bCheckHobbled = True
   EndIf

   ; Sometimes ZBF restraints have wrist cuffs and ankle cuff combinations.  Keep track of the
   ; wrist cuff key word to check this situation as well.
   Bool bWristCuffsKeyword = False
   If (bCheckArmLocked || bCheckHobbled)
      bWristCuffsKeyword = _aPlayer.WornHasKeyword(_oKeywordZbfWornWrist)
   EndIf

   If (bCheckArmLocked)
      Log("Checking Arms Locked", DL_TRACE, DC_STATUS)

      Bool bOldStatus = _bIsPlayerArmLocked
      _bIsPlayerArmLocked = False
      If (bWristCuffsKeyword)
         _bIsPlayerArmLocked = True
      ElseIf (_aPlayer.WornHasKeyword(_oKeywordZadArmBinder) || \
              _aPlayer.WornHasKeyword(_oKeywordZadBondageMittens) || \
              _aPlayer.WornHasKeyword(_oKeywordZadYoke) || \
              _aPlayer.WornHasKeyword(_oKeywordZbfWornYoke))
         _bIsPlayerArmLocked = True
      EndIf
      ReportStatus("Arm Locked", _bIsPlayerArmLocked, bOldStatus)
   EndIf

   If ((_bIsPlayerGagged && _bFlagItemUnequpped) || (!_bIsPlayerGagged && _bFlagItemEqupped))
      Log("Checking Gagged", DL_TRACE, DC_STATUS)

      Bool bOldStatus = _bIsPlayerGagged
      _bIsPlayerGagged = False
      If (_aPlayer.WornHasKeyword(_oKeywordZadGag) || \
          _aPlayer.WornHasKeyword(_oKeywordZbfWornGag))
         _bIsPlayerGagged = True
      Else
         _bIsGagStrict = False
      EndIf
      ReportStatus("Gagged", _bIsPlayerGagged, bOldStatus)
   EndIf

   ; The Leg Cuffs Keyword is used in Hobbled and other restraints.  Keep track of it.
   Bool bLegCuffsKeyword = False
   If (bCheckHobbled || bCheckLockedUp)
      bLegCuffsKeyword = _aPlayer.WornHasKeyword(_oKeywordZadLegCuffs)
   EndIf

   If (bCheckHobbled)
      Log("Checking Hobbled", DL_TRACE, DC_STATUS)

      ; Note on the check below:
      ; Sometimes ZBF restraints have wrist cuffs and ankle cuff combinations.
      ; These restraints can be ankle cuff hobbles that use the wrist keyword.
      ; Note also that some regular (non-hobble) wrist cuffs add a no sprint keyword.

      ; Note: ZBF Worn Ankles can be true even for basic non-connected leg cuffs.
      ; _aPlayer.WornHasKeyword(_oKeywordZbfWornAnkles) || \

      Bool bOldStatus = _bIsPlayerHobbled
      _bIsPlayerHobbled = False
      If (_aPlayer.WornHasKeyword(_oKeywordZadBoots) || \
          (bWristCuffsKeyword && (_aPlayer.WornHasKeyword(_oKeywordZbfEffectNoMove) || \
                                  _aPlayer.WornHasKeyword(_oKeywordZbfEffectSlowMove))) || \
          (bLegCuffsKeyword && (_aPlayer.WornHasKeyword(_oKeywordZbfEffectNoMove) || \
                                _aPlayer.WornHasKeyword(_oKeywordZbfEffectNoSprint) || \
                                _aPlayer.WornHasKeyword(_oKeywordZbfEffectSlowMove))))
         _bIsPlayerHobbled = True
      EndIf
      ReportStatus("Hobbled", _bIsPlayerHobbled, bOldStatus)

      ; If the player is now hobbled and it should block footwear remove that now.
      If (_bIsPlayerHobbled && !bOldStatus && _qMcm.bBlockHobble && _qMcm.bBlockShoes)
         Armor oFootwear = _aPlayer.GetWornForm(CS_FEET) As Armor

         If (IT_COVERINGS == GetItemType(oFootwear))
            ; Make sure the footwear is not on the exception list and remove it.
            If (-1 == _qMcm.aiBlockExceptionsHobble.Find(oFootwear.GetFormID()))
               Log("Your hobble is interfering with your " + oFootwear.GetName() + ".", \
                   DL_CRIT, DC_EQUIP)
               If (50 > _iNumItemsUnequipped)
                  _aPlayer.UnequipItem(oFootwear, abSilent=True)
                  _iNumItemsUnequipped += 1
               EndIf
            EndIf
         EndIf
      EndIf
   EndIf

   If (bCheckLockedUp)
      Log("Checking Locked Up", DL_TRACE, DC_STATUS)

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
      _bIsPlayerBelted = (_aPlayer.WornHasKeyword(_oKeywordZadBelt) || \
                          _aPlayer.WornHasKeyword(_oKeywordZbfWornBelt))
      If (_bIsPlayerBelted || _aPlayer.WornHasKeyword(_oKeywordZadVagina))
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
      If (bLegCuffsKeyword && !_bIsPlayerHobbled)
         szMessage += "Legs "
         _iNumOtherRestraints += 1
      EndIf
      If (_aPlayer.WornHasKeyword(_oKeywordZadFullSuit))
         szMessage += "Suit "
         _iNumOtherRestraints += 1
      EndIf
      If (_iNumOtherRestraints != iOldStatus)
         Log("Wearing " + _iNumOtherRestraints + " other restraints.", DL_INFO, DC_STATUS)
         Log(szMessage, DL_DEBUG, DC_STATUS)
      EndIf
   EndIf

   ; If the main control flag has not been reset, clear all the minor flags.
   If (!_iFlagSet)
      ; Reset all of the flags.
      _bFlagItemEqupped      = False
      _bFlagItemUnequpped    = False
      _bFlagClothesEqupped   = False
      _bFlagClothesUnequpped = False
   EndIf
   DebugTrace("TraceEvent PerformOnUpdate: Done")
EndFunction

; This is called from the player monitor script when an item equipped event is seen.
Function ItemEquipped(Form oItem, ObjectReference oReference)
   DebugTrace("TraceEvent ItemEquipped - " + Utility.GetCurrentRealTime())

   Int iType = GetItemType(oItem)
   If (!iType)
      DebugTrace("TraceEvent ItemEquipped: Done (No Item Type) - " + \
                 Utility.GetCurrentRealTime())
      Return
   EndIf

   If (IT_RESTRAINT == iType)
      _iFlagSet         = 2
      _bFlagItemEqupped = True
   ElseIf (IT_COVERINGS == iType)
      ; If we are configured to block clothing check that now.
      ; If the nearby master is assisting the player to dress allow her to dress as normal.
      If (IsAllowed(AP_DRESSING_ASSISTED))
         DebugTrace("TraceEvent ItemEquipped: Done (Dressing Allowed) - " + \
                    Utility.GetCurrentRealTime())
         Return
      EndIf

      ; Start by getting a more detailed description of the item.
      iType = GetClothingType(oItem)

      ; First check if we are in a naked or post rape redress timeout.
      If (_fRapeRedressTimeout)
         If (Utility.GetCurrentGameTime() < _fRapeRedressTimeout)
            Log("You are too exhausted from being raped to dress right now.", DL_CRIT, DC_EQUIP)
            _fRapeRedressTimeout = Utility.GetCurrentGameTime() + \
                                   ((_qMcm.iModRapeRedressTimeout As Float) / 1440)
            If (50 > _iNumItemsUnequipped)
               _aPlayer.UnequipItem(oItem, abSilent=True)
               _iNumItemsUnequipped += 1
            EndIf
            DebugTrace("TraceEvent ItemEquipped: Done (Post-Rape) - " + \
                       Utility.GetCurrentRealTime())
            Return
         EndIf
         _fRapeRedressTimeout = 0
      EndIf
      If (_fNakedRedressTimeout)
         If (Utility.GetCurrentGameTime() < _fRapeRedressTimeout)
            Log("You tried to dress too fast.  Now you have to start again.", DL_CRIT, DC_EQUIP)
            _fNakedRedressTimeout = Utility.GetCurrentGameTime() + \
                                    ((_qMcm.iModNakedRedressTimeout As Float) / 1440)
            If (50 > _iNumItemsUnequipped)
               _aPlayer.UnequipItem(oItem, abSilent=True)
               _iNumItemsUnequipped += 1
            EndIf
            DebugTrace("TraceEvent ItemEquipped: Done (Post-Redress) - " + \
                       Utility.GetCurrentRealTime())
            Return
         EndIf
         _fNakedRedressTimeout = 0
      EndIf

      Bool bUnequip = False
      String szBlockedBy = "piercings"

      ; Keep track of whether arms or nipples piercings should be block.
      Bool bBlockArms = (_bIsPlayerArmLocked && _qMcm.bBlockArms)
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
         Bool bBlockHobble = (_bIsPlayerHobbled && _qMcm.bBlockHobble)
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
         If (_bIsPlayerHobbled && _qMcm.bBlockHobble && _qMcm.bBlockShoes)
            bUnequip = _qDfwUtil.IsFeetSlot((oItem As Armor).GetSlotMask())
            szBlockedBy = "hobble"
         EndIf
      EndIf

      If (bUnequip)
         Log("You can't equip \"" + oItem.GetName() + "\" over your " + szBlockedBy + ".", \
             DL_CRIT, DC_EQUIP)
         If (50 > _iNumItemsUnequipped)
            _aPlayer.UnequipItem(oItem, abSilent=True)
            _iNumItemsUnequipped += 1
         EndIf
      EndIf

      _iFlagSet            = 2
      _bFlagClothesEqupped = False
   EndIf
   DebugTrace("TraceEvent ItemEquipped: Done - " + Utility.GetCurrentRealTime())
EndFunction

; This is called from the player monitor script when an item unequipped event is seen.
Function ItemUnequipped(Form oItem, ObjectReference oReference)
   DebugTrace("TraceEvent ItemUnequipped - " + Utility.GetCurrentRealTime())
   Int iType = GetItemType(oItem)
   If (!iType)
      Log("Unequip Done (None): " + Utility.GetCurrentRealTime(), DL_TRACE, DC_EQUIP)
      DebugTrace("TraceEvent ItemUnequipped: Done (No Item Type) - " + \
                 Utility.GetCurrentRealTime())
      Return
   EndIf

   If (IT_RESTRAINT == iType)
      ; Try to fix Devious Devices being unequipped by the Favourites clear armour mechanism.
      If (_qMcm.bSettingsDetectUnequip && oItem.HasKeyword(_oKeywordZadLockable))
         ; Note about devious devices.  All functions work on inventory items.  There isn't
         ; really anything you can do with rendered (worn) devices.  As such we will be
         ; identifying the Keyword device manually.

         ; The problem is if the item is worn but not the keyword.  Check the keyword now.
         Keyword oDeviousKeyword = GetDeviousKeyword(oItem As Armor)
         If (oDeviousKeyword && !_aPlayer.WornHasKeyword(oDeviousKeyword))
            Log("Trying Devious Fix...", DL_DEBUG, DC_EQUIP)

            ; Search the inventory for a "Devious Inventory" item with the same keyword.
            Int iIndex = _aPlayer.GetNumItems() - 1
            While (0 <= iIndex)
               ; Check the item is an inventory item, is equipped and has the right keyword.
               Form oInventoryItem = _aPlayer.GetNthForm(iIndex)
               If (oInventoryItem && oInventoryItem.HasKeyword(_oKeywordZadInventoryDevice))
                  If (_aPlayer.IsEquipped(oInventoryItem) && \
                      (oDeviousKeyword == _qZadLibs.GetDeviceKeyword(oInventoryItem As Armor)))
                     ; Re-equip the original item (Not the inventory item).
                     _aPlayer.EquipItem(oItem)
                  EndIf
               EndIf
               iIndex -= 1
            EndWhile
         EndIf
      ElseIf (_qMcm.bSettingsDetectUnequip && oItem.HasKeyword(_oKeywordZbfWornDevice))
         ; Zaz Animation Pack devices can also be removed.  There is no way outside the Zaz
         ; script to detect if they are locked.  Instead we call the event from that script
         ; that handles item removal.  This should already be called for the item; however,
         ; sometimes it is not so we will call it again.
         _qZbfPlayerSlot.OnItemRemoved(oItem, 1, oReference, None)
      EndIf

      _iFlagSet           = 2
      _bFlagItemUnequpped = True
   ElseIf (IT_COVERINGS == iType)
      ; If the player's clothes have changed always recheck how naked she is.
      _iFlagSet              = 2
      _bFlagClothesUnequpped = True
   EndIf
   DebugTrace("TraceEvent ItemUnequipped: Done - " + Utility.GetCurrentRealTime())
EndFunction

; This is called from the player monitor script when an enter bleedout event is seen.
Function EnteredBleedout()
   DebugTrace("TraceEvent EnteredBleedout")
   _iBleedoutTime = Utility.GetCurrentRealTime() + 30
   DebugTrace("TraceEvent EnteredBleedout: Done")
EndFunction

; This is called from the player monitor script when an on sit event is seen.
Function OnSit(ObjectReference oFurniture)
   DebugTrace("TraceEvent OnSit")
   If (oFurniture.HasKeyword(_oKeywordZbfFurniture))
      _oBdsmFurniture = oFurniture
      ; If the player's inventory is not locked lock it now.
      If (Game.IsMenuControlsEnabled())
         _bInventoryLocked = True
         ;    DisablePlayerControls(Move,  Fight, Cam,   Look,  Sneak, Menu,  Active, Journ)
         Game.DisablePlayerControls(False, False, False, False, False, True,  False,  False)
      EndIf

      ; If this is a Zaz Multi-Pose furniture see if we should select one specific pose.
      If (oFurniture.HasKeyword(_oKeywordZbfFurnitureMulti))
         Utility.Wait(1.0)
         SetMultiAnimation()
      EndIf
   EndIf
   DebugTrace("TraceEvent OnSit: Done")
EndFunction

; This is called from the player monitor script when an on get up event is seen.
Function OnGetUp(ObjectReference oFurniture)
   DebugTrace("TraceEvent OnGetUp")
   ; TODO: Maybe check for a sex scene in addition to checking if the furniture is locked?
   If (!_bIsFurnitureLocked)
      _oBdsmFurniture = None
      ; If we previously disabled the player's inventory, release it now.
      If (_bInventoryLocked)
         _bInventoryLocked = False
         ;    EnablePlayerControls(Move,  Fight, Cam,   Look,  Sneak, Menu,  Active, Journ)
         Game.EnablePlayerControls(False, False, False, False, False, True,  False,  False)
      EndIf
      If (oFurniture.HasKeyword(_oKeywordZbfFurniture))
         _qZbfPlayerSlot.SetFurniture(None)
      EndIf
   EndIf
   DebugTrace("TraceEvent OnGetUp: Done")
EndFunction

Function OnLocationChange(Location oOldLocation, Location oNewLocation)
   DebugTrace("TraceEvent OnLocationChange")
   If (!oOldLocation)
      oOldLocation = _oCurrLocation
   EndIf
   If (!oNewLocation)
      oNewLocation = _aPlayer.GetCurrentLocation()
   EndIf
   _oCurrLocation = oNewLocation

   ; Figure out which "Region" we are now in.
   Location oNewRegion = GetRegion(oNewLocation)
   _oLastNearestRegion = GetNearestRegion()

   ; Load screen can reset the actor animations.  Keep track of whether we should reset them.
   Bool bResetPose
   If (_bIsPlayerInterior || _aPlayer.IsInInterior())
      bResetPose = True
   EndIf

   ; Make sure the player's interior status is up to date.
   _bIsPlayerInterior = _aPlayer.IsInInterior()

   ; If we might need to use the last door the player entered keep track of her position.
   If (_bIsPlayerInterior && _qMcm.bModFadeInUseDoor && _aPlayer.X)
DebugLog("Setting Door: (" + _aPlayer.X + "," + _aPlayer.Y + "," + _aPlayer.Z + ")", DL_CRIT)
      _aiLastDoorLocation[0] = (_aPlayer.X As Int)
      _aiLastDoorLocation[1] = (_aPlayer.Y As Int)
      _aiLastDoorLocation[2] = (_aPlayer.Z As Int)
   Else
      _aiLastDoorLocation[0] = 0
      _aiLastDoorLocation[1] = 0
      _aiLastDoorLocation[2] = 0
   EndIf

   ; If we are configured for full save game control check if the game should be auto-saved.
   If (2 == _iMcmSaveGameControlStyle)
      ; If the player has just changed into or out of a region (city) save the game.
      If (_oCurrRegion != oNewRegion)
         AutoSave()
      EndIf
   EndIf
   _oCurrRegion = oNewRegion

   String szRegion = "Wilderness"
   If (_oCurrRegion)
      szRegion = _oCurrRegion.GetName()
   ElseIf (_oLastNearestRegion && (DL_DEBUG == _aiMcmScreenLogLevel[DC_LOCATION]))
      szRegion += " (Near " + _oLastNearestRegion.GetName() + ")"
   EndIf

   String szOldLocation = "Wilderness"
   If (oOldLocation)
      szOldLocation = oOldLocation.GetName()
   EndIf
   String szNewLocation = "Wilderness"
   If (oNewLocation)
      szNewLocation = oNewLocation.GetName()

      ; When reach the location the NPC is moving to check if the NPC has arrived as well.
      Location oTargetLocation = _aAliasLocationTarget.GetLocation()
      If (oTargetLocation == oNewLocation)
         _iFlagCheckMoveTo = 5
      EndIf
   EndIf
   Log("Location Change: " + szOldLocation + " => " + szNewLocation + " (" + szRegion + ")", \
       DL_INFO, DC_LOCATION)

   ; If we crossed a load screen try to reset nearby actor animations.
   If (bResetPose)
      ; Resetting the pose needs a delay.  I believe the Zaz Animation pack is also "fixing"
      ; their animations on location change.  We need to reset our poses after they do.
      ; TODO: Work with their system?  Reset our pose to default?  MCM Configurable?
      Utility.Wait(0.75)
      If (_iCurrPose)
         SetPose(0, _aiKnownPoseFlags[0], _iCurrPose, _aiKnownPoseFlags[_iCurrPose], False)
      EndIf

      Form[] aoNearbySlaves = GetNearbyActorList(iIncludeFlags=AF_SUBMISSIVE)
      Int iIndex = aoNearbySlaves.Length - 1
      While (0 <= iIndex)
         Actor aSubmissive = (aoNearbySlaves[iIndex] As Actor)
         If (aSubmissive && aSubmissive.Is3DLoaded())
; zxc
Log("Resetting Slave Animation: " + aSubmissive.GetDisplayName(), DL_DEBUG, DC_NEARBY)
            zbfSlot qZbfActorSlot = zbfBondageShell.GetApi().SlotActor(aSubmissive)
            If (qZbfActorSlot)
               If (qZbfActorSlot.GetCurrentArmBindings())
                  ; Valid offset (wrist) animations? ZapWriOffset01, ZapYokeOffset01,
                  ;                                  ZapArmbOffset01
                  qZbfActorSlot.SetOffsetAnim("ZapWriOffset01", True)
               EndIf
               Form oGag = qZbfActorSlot.GetCurrentGag()
               If (oGag)
                  qZbfActorSlot.RemoveBinding(oGag)
                  qZbfActorSlot.SetBinding(oGag)
               EndIf

               If (MutexLock(_iZazSlottedMutex))
                  ; The count is a count down delay giving time for the slot to take effect
                  ; before we clear the actor from the slot.
                  _iZazSlottedCount = 5
                  _aoZazSlottedActors = _qDfwUtil.AddFormToArray(_aoZazSlottedActors, \
                                                                 aSubmissive)

                  MutexRelease(_iZazSlottedMutex)
               EndIf
            EndIf
         EndIf

         iIndex -= 1
      EndWhile
   EndIf

   DebugTrace("TraceEvent OnLocationChange: Done")
EndFunction

; This is called from the _dfwNearbyDetectorEffect magic effect when it starts.
Function NearbyActorSeen(Actor aActor)
   DebugTrace("TraceEvent NearbyActorSeen")
   ; Ignore any new nearby actors if we are shutting down the mod.
   If (_bMcmShutdownMod)
      DebugTrace("TraceEvent NearbyActorSeen: Done (Mod Shutting Down)")
      Return
   EndIf

   ; If this actor is already in the nearby actor list ignore him.
   Int iIndex = _aoNearby.Find(aActor)
   If (0 <= iIndex)
      ; Add a log here to debug magic effect script isntances that are becoming stray.
      Log("TraceEvent NearbyActorSeen: Done (Not Registered) - 0x" + \
          _qDfwUtil.ConvertHexToString(aActor.GetFormId(), 8) + ": " + \
          aActor.GetDisplayName(), DL_TRACE, DC_NEARBY)
      Return
   EndIf

   ; Otherwise just add the actor to the nearby actor list.
   ; Note: Converting the form ID to hex is a little bit expensive for something triggered by
   ;       every nearby actor; however, for now it will help diagnose which magic effect script
   ;       instances are becoming stray.
   ;Off-DebugTrace("Registering Nearby 0x" + \
   ;           _qDfwUtil.ConvertHexToString(aActor.GetFormId(), 8) + ": " + \
   ;           aActor.GetDisplayName(), DL_TRACE, DC_NEARBY)

   ; Perform some basic estimations for flags of this actor.
   Int iFlags = AF_ESTIMATE
   Bool bIsSlave = False
   Bool bIsChild = False
   If (aActor.IsChild())
      iFlags = Math.LogicalOr(AF_CHILD, iFlags)
      bIsChild = True
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

   If (_qZbfSlave.IsSlave(aActor))
      ; Check if the actor is a slave, first on Zbf status.  A check later can also identify the
      ; NPC as a slave based on items worn.  Check this first as some hydra slave girl slaves
      ; are also in the CaravanSlaver faction.
      iFlags = Math.LogicalOr(AF_SUBMISSIVE, iFlags)
      iFlags = Math.LogicalOr(AF_SLAVE, iFlags)
      bIsSlave = True
   ElseIf (_qZbfSlave.IsSlaver(aActor) || aActor.IsInFaction(_oFactionHydraSlaver) || \
       aActor.IsInFaction(_oFactionHydraCaravanSlaver))
      Log("Nearby Slaver: " + aActor.GetDisplayName(), DL_DEBUG, DC_NEARBY)

      ; Check if the actor deals in trading slaves.  Check this before bondage items as they can
      ; sometimes be wearing restraints too.
      iFlags = Math.LogicalOr(AF_DOMINANT, iFlags)
      iFlags = Math.LogicalOr(AF_SLAVE_TRADER, iFlags)
      iFlags = Math.LogicalOr(AF_OWNER, iFlags)
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
         bIsSlave = True
      EndIf
   ElseIf (!aActor.WornHasKeyword(_oKeywordClothes) && \
           !aActor.WornHasKeyword(_oKeywordArmourLight) && \
           !aActor.WornHasKeyword(_oKeywordArmourHeavy))
      ; The actor is naked.  Consider her submissive.
      iFlags = Math.LogicalOr(AF_SUBMISSIVE, iFlags)
   ElseIf (!bIsChild)
      ; For now treat anyone not restrained as a dominant (other than children of course).
      iFlags = Math.LogicalOr(AF_DOMINANT, iFlags)

      ; If the actor owns a slave mark Him as a slave owner.
      If (_qZbfSlave.IsMaster(aActor))
         Log("Nearby Slave Owner: " + aActor.GetDisplayName(), DL_DEBUG, DC_NEARBY)

         iFlags = Math.LogicalOr(AF_OWNER, iFlags)
      EndIf
   EndIf

   If (bIsSlave)
; zxc
Log("Resetting Slave Animation: " + aActor.GetDisplayName(), DL_DEBUG, DC_NEARBY)
      zbfSlot qZbfActorSlot = zbfBondageShell.GetApi().SlotActor(aActor)
      If (qZbfActorSlot)
         If (qZbfActorSlot.GetCurrentArmBindings())
            ; Valid offset (wrist) animations? ZapWriOffset01, ZapYokeOffset01, ZapArmbOffset01
            qZbfActorSlot.SetOffsetAnim("ZapWriOffset01", True)
         EndIf
         Form oGag = qZbfActorSlot.GetCurrentGag()
         If (oGag)
            qZbfActorSlot.RemoveBinding(oGag)
            qZbfActorSlot.SetBinding(oGag)
         EndIf

         If (MutexLock(_iZazSlottedMutex))
            ; The count is a count down delay giving time for the slot to take effect before
            ; we clear the actor from the slot.
            _iZazSlottedCount = 5
            _aoZazSlottedActors = _qDfwUtil.AddFormToArray(_aoZazSlottedActors, aActor)

            MutexRelease(_iZazSlottedMutex)
         EndIf
      EndIf
   EndIf

   ; Add the actor to the known actors lists.
   If (MutexLock(_iNearbyMutex))
      _aoNearby = _qDfwUtil.AddFormToArray(_aoNearby, aActor, True)
      _aiNearbyFlags = _qDfwUtil.AddIntToArray(_aiNearbyFlags, iFlags, True)

      If (_aoNearby.Length != _aiNearbyFlags.Length)
         Log("Nearby Added Wrong: " + _aoNearby.Length + " != " + _aiNearbyFlags.Length, \
             DL_ERROR, DC_NEARBY)
      EndIf

      MutexRelease(_iNearbyMutex)
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
             fNewArousal, DL_DEBUG, DC_NPC_AROUSAL)
      EndIf
   EndIf
   DebugTrace("TraceEvent NearbyActorSeen: Done")
EndFunction

Event PostSexCallback(String szEvent, String szArg, Float fNumArgs, Form oSender)
   DebugTrace("TraceEvent PostSexCallback")

   ; Make sure the player is involved in this scene.
   Bool bPlayerFound = False
   Actor aPartner = None
   Actor[] aaEventActors = _qSexLab.HookActors(szArg)
   Int iIndex = aaEventActors.Length - 1
   While (0 <= iIndex)
      If (_aPlayer == aaEventActors[iIndex])
         bPlayerFound = True
      Else
         aPartner = aaEventActors[iIndex]
      EndIf
      iIndex -= 1
   EndWhile
   If (!bPlayerFound)
      DebugTrace("TraceEvent PostSexCallback: Done (No Player)")
      Return
   EndIf

   ; If the player was locked in furniture before the sex make sure she is locked back up.
   If (_bIsFurnitureLocked)
      ObjectReference oFurniture = GetBdsmFurniture()
      If (oFurniture)
         ; If there is no partner (this is a glitch?  How did the player get out of the
         ; furniture?) have the nearest actor lock her back up.
         If (!aPartner)
            aPartner = GetNearestActor(iExcludeFlags=AF_SUBMISSIVE + AF_SLAVE)
            If (!aPartner)
               aPartner = GetNearestActor(iExcludeFlags=AF_SLAVE)
               If (!aPartner)
                  aPartner = GetNearestActor()
               EndIf
            EndIf
         EndIf

         If (aPartner)
            Log(aPartner.GetDisplayName() + " locks you back up in your device.", DL_CRIT, \
                DC_GENERAL)
            ; Disable Milk Mod Economy, preventing it from starting animations on the player.
            If (_oMmeBeingMilkedSpell && !_aPlayer.HasSpell(_oMmeBeingMilkedSpell))
               _aPlayer.AddSpell(_oMmeBeingMilkedSpell, False)
               _bMmeSuppressed = True
               ; Add a delay to make sure the spell has taken effect.
               Utility.Wait(0.5)
            EndIf
            _qZbfSlaveActions.RestrainInDevice(oFurniture, aPartner, S_MOD)
         EndIf
      EndIf
   EndIf

   ; If the player is the victim start a post-rape redress timeout.
   If (_qMcm.iModRapeRedressTimeout && (_aPlayer == _qSexLab.HookVictim(szArg)))
      _fRapeRedressTimeout = Utility.GetCurrentGameTime() + \
                             ((_qMcm.iModRapeRedressTimeout As Float) / 1440)
      If (aPartner)
         _aLastAssaultActor = aPartner
         _fLastAssaultTime = Utility.GetCurrentGameTime()
      EndIf
   EndIf
   DebugTrace("TraceEvent PostSexCallback: Done")
EndEvent

; This is the ZAZ Animation Pack (ZBF) event when an animation for approaching/restrainting
; the player has completed.
Event OnSlaveActionDone(String szType, String szMessage, Form oMaster, Int iSceneIndex)
   DebugTrace("TraceEvent OnSlaveActionDone")
   ; We are only interested in animations that we started.
   If (S_MOD + "_" != StringUtil.Substring(szMessage, 0, 4))
      DebugTrace("TraceEvent OnSlaveActionDone: Done (Not Our Mod)")
      Return
   EndIf

   If (S_MOD == szMessage)
      ; If we have suppressed Milk Mod Economy re-enable it.
      If (_bMmeSuppressed && _oMmeBeingMilkedSpell)
         _aPlayer.RemoveSpell(_oMmeBeingMilkedSpell)
         _bMmeSuppressed = False
      EndIf
   Else
      Log("Unknown Slave Action Event:  \"" + szMessage + "\"", DL_ERROR, DC_GENERAL)
   EndIf
   DebugTrace("TraceEvent OnSlaveActionDone: Done")
EndEvent

Function SetPose(Int iOldPose, Int iOldFlags, Int iNewPose, Int iNewFlags, Bool bSetStatus=True)
   _iCurrPose = iNewPose

   If (bSetStatus)
      ; 0x0008: This pose prevents movement.
      Bool bOldStatus = Math.LogicalAnd(iOldFlags, 0x0008)
      Bool bNewStatus = Math.LogicalAnd(iNewFlags, 0x0008)
      If (bNewStatus)
         If (!bOldStatus)
            BlockMovement()
         EndIf
      ElseIf (bOldStatus)
         RestoreMovement()
      EndIf

      ; 0x0010: This pose prevents activation.
      bOldStatus = Math.LogicalAnd(iOldFlags, 0x0010)
      bNewStatus = Math.LogicalAnd(iNewFlags, 0x0010)
      If (bNewStatus)
         If (!bOldStatus)
            BlockActivate()
         EndIf
      ElseIf (bOldStatus)
         RestoreActivate()
      EndIf

      ; 0x0020: This pose prevents inventory.
      bOldStatus = Math.LogicalAnd(iOldFlags, 0x0020)
      bNewStatus = Math.LogicalAnd(iNewFlags, 0x0020)
      If (bNewStatus)
         If (!bOldStatus)
            BlockMenu()
         EndIf
      ElseIf (bOldStatus)
         RestoreMenu()
      EndIf

      ; 0x0040: This pose prevents fighting.
      bOldStatus = Math.LogicalAnd(iOldFlags, 0x0040)
      bNewStatus = Math.LogicalAnd(iNewFlags, 0x0040)
      If (bNewStatus)
         If (!bOldStatus)
            BlockFighting()
         EndIf
      ElseIf (bOldStatus)
         RestoreFighting()
      EndIf
   EndIf

   ; Clean up any complex behaviour from the previous pose.
   ; 0x8000: A complex pose which can't be handled via the standard funcitons.
   If (Math.LogicalAnd(iOldFlags, 0x8000))
      If ("SD_Crawl" == _aszKnownPoses[iOldPose])
         ; Clear our previous FNIS Alternate Animation idles.
         FNIS_aa.SetAnimGroup(_aPlayer, "_mtidle", 0, 0, "DeviousFramework")
         FNIS_aa.SetAnimGroup(_aPlayer, "_mt",     0, 0, "DeviousFramework")
         FNIS_aa.SetAnimGroup(_aPlayer, "_mtx",    0, 0, "DeviousFramework")
      EndIf
   EndIf

   If (Math.LogicalAnd(iNewFlags, 0x0001))
      ; 0x0001: A default idle.

      ; If this is a default idle clear any current poses.
      If (Math.LogicalAnd(iOldFlags, 0x0004))
         Debug.SendAnimationEvent(_aPlayer, "JumpLand")
      EndIf
   ElseIf (Math.LogicalAnd(iNewFlags, 0x0004))
      ; 0x0004: A toggle pose.  It must be turned on and off.

      ; This is a toggle pose.  Turn it on.
      ; Note: Turning it off is done by changing the pose to a different one.
      Debug.SendAnimationEvent(_aPlayer, _aszKnownPoses[iNewPose])
   ElseIf (Math.LogicalAnd(iNewFlags, 0x8000))
      ; 0x8000: A complex pose which can't be handled via the standard funcitons.

      ; If the last pose was a toggle pose turn it off.
      If (Math.LogicalAnd(iOldFlags, 0x0004))
         Debug.SendAnimationEvent(_aPlayer, "JumpLand")
      EndIf

      ; This pose requires special processing to setup.
      If ("SD_Crawl" == _aszKnownPoses[iNewPose])
         ; Piggyback on the Sanguine Debauchery+ FNIS Alternate Animation crawl.
         ; Use DeviousFramework as the mod ID so anyone looking through logs or errors will
         ; know this mod is intiating the animation.
         Int iSdPlusFnisId = FNIS_aa.GetAAModID("sdc", "DeviousFramework")
         Int iSdPlusMtIdle = FNIS_aa.GetGroupBaseValue(iSdPlusFnisId, FNIS_aa._mtidle(), \
                                                       "DeviousFramework")
         Int iSdPlusMtBase = FNIS_aa.GetGroupBaseValue(iSdPlusFnisId, FNIS_aa._mt(), \
                                                       "DeviousFramework")
         Int iSdPlusMtX =    FNIS_aa.GetGroupBaseValue(iSdPlusFnisId, FNIS_aa._mtx(), \
                                                       "DeviousFramework")

         FNIS_aa.SetAnimGroup(_aPlayer, "_mtidle", iSdPlusMtIdle, 0, "DeviousFramework")
         FNIS_aa.SetAnimGroup(_aPlayer, "_mt",     iSdPlusMtBase, 0, "DeviousFramework")
         FNIS_aa.SetAnimGroup(_aPlayer, "_mtx",    iSdPlusMtX,    0, "DeviousFramework")
      EndIf
   EndIf
EndFunction

Event OnKeyUp(Int iKeyCode, Float fHoldTime)
   DebugTrace("TraceEvent OnKeyUp: " + iKeyCode)
   ; Ignore any user keypresses if we are shutting down the mod.
   If (_bMcmShutdownMod)
      Log("Key Ignored.  Mod in shutdown mode.", DL_CRIT, DC_GENERAL)
      DebugTrace("TraceEvent OnKeyUp: Done (Mod Shutting Down)")
      Return
   EndIf

   If ((_qMcm.iModHelpKey == iKeyCode) || (_qMcm.iModAttentionKey == iKeyCode))
      ; If a menu is open (e.g. the console or inventory) ignore KeyPress events.
      If (Utility.IsInMenuMode())
         DebugTrace("TraceEvent OnKeyUp: Done (Menu Open)")
         Return
      EndIf

      ; If the player has called out too recently ignore this attempt.
      If (_iCallOutTimeout)
         DebugTrace("TraceEvent OnKeyUp: Done (Too Soon)")
         Return
      EndIf

      ; The two calls are handled very similar with a few changes in details.
      ; Keep track of the details in these variables.
      String sEvent = "DFW_CallForHelp"
      Int iRange = 2000
      Int iIncludeFlags = AF_GUARDS + AF_OWNER + AF_SLAVE_TRADER
      Int iExcludeFlags = AF_CHILD + AF_SUBMISSIVE + AF_SLAVE
      Int iChance = 20
      ; Call Type: 1 for Help, 2 for Assistance
      _iCallOutType = 1
      _iCallOutTimeout = _qMcm.iModCallTimeout
      _bCallingForAttention = False
      _bCallingForHelp      = True
      _iCallOutResponse = 3
      If (_qMcm.iModAttentionKey == iKeyCode)
         sEvent = "DFW_CallForAttention"
         iRange = 1000
         iIncludeFlags = AF_NONE
         iChance = 10
         _iCallOutType = 2
         _iCallOutTimeout /= 2
         _bCallingForAttention = True
         _bCallingForHelp      = False
      EndIf
      ; Convert the call out timeout and response from seconds into number of polls.
      _iCallOutTimeout = ((_iCallOutTimeout / _fMcmPollTime) As Int) + 1
      _iCallOutResponse = ((_iCallOutResponse / _fMcmPollTime) As Int) + 1

      ; If the player is gagged the range is less and chance of Master interaction more.
      If (_bIsPlayerGagged)
         iRange = ((iRange * 0.5) As Int)
         iChance *= 2

         ; If the player is wearing a strict gag reduce the range even further.
         If (_bIsGagStrict)
            Log("You are effectively gagged and can't make much sound.", DL_CRIT, \
                DC_INTERACTION)
            iRange = ((iRange * 0.5) As Int)
         Else
            Log("You mumble through your gag as best you can.", DL_CRIT, DC_INTERACTION)
         EndIf
      ElseIf (1 == _iCallOutType)
         Log("You call out for help.", DL_CRIT, DC_INTERACTION)
      Else
         Log("You subtly try to get someone to notice you.", DL_CRIT, DC_INTERACTION)
      EndIf

      ; Find a suitable actor nearby to recommend to handle the call for help.
      Actor aNearby = GetRandomActor(iRange, iIncludeFlags, iExcludeFlags)

      ; If the player's Master is nearby consider recommending him instead.
      If (_aMasterClose && (iRange >= _aMasterClose.GetDistance(_aPlayer)) && \
          (!aNearby || (Utility.RandomInt(0, 99) < iChance)))
         aNearby = _aMasterClose
      EndIf

      ; If we did not find anyone try one last search without any actor flags.
      If (!aNearby && (iIncludeFlags || iExcludeFlags))
         ; Start by removing any include flags.
         If (iIncludeFlags)
            aNearby = GetRandomActor(iRange, iExcludeFlags=iExcludeFlags)
         EndIf
         ; If we still haven't found anyone remove the exclude flags as well.
         If (!aNearby && iExcludeFlags)
            aNearby = GetRandomActor(iRange, iExcludeFlags=AF_CHILD)
         EndIf
      EndIf

      ; Send the event.
      Int iModEvent = ModEvent.Create(sEvent)
      If (iModEvent)
         ModEvent.PushInt(iModEvent, _iCallOutType)
         ModEvent.PushInt(iModEvent, iRange)
         ModEvent.PushForm(iModEvent, aNearby)
         If (!ModEvent.Send(iModEvent))
            Log("Failed to send Event " + sEvent + "(" + aNearby.GetDisplayName() + ")", \
                DL_ERROR, DC_INTERACTION)
         EndIf
      EndIf
   ElseIf (_qMcm.iModSaveKey == iKeyCode)
      ; If a menu is open (e.g. the console or inventory) ignore KeyPress events.
      If (Utility.IsInMenuMode())
         DebugTrace("TraceEvent OnKeyUp: Done (Cannot Save-Menu)")
         Return
      EndIf

      QuickSave()
   ElseIf ((_qMcm.iModTogglePoseKey == iKeyCode) || (_qMcm.iModCyclePoseKey == iKeyCode))
      ; If a menu is open (e.g. the console or inventory) ignore KeyPress events.
      If (Utility.IsInMenuMode())
         DebugTrace("TraceEvent OnKeyUp: Done (Cannot Pose-Menu)")
         Return
      EndIf

      ; Don't try to change poses while in a sex scene.
      If (_qSexLab.IsActorActive(_aPlayer))
         DebugTrace("TraceEvent OnKeyUp: Done (Cannot Pose-SexLab)")
         Return
      EndIf

      ; Keep track of the pose we are leaving in case it needs some clean up.
      Int iOldPose = _iCurrPose
      Int iOldFlags = _aiKnownPoseFlags[iOldPose]

      ; Find the new pose.
      Int iNewPose
      Int iNewFlags
      If (_qMcm.iModTogglePoseKey == iKeyCode)
         If (_iCurrPose)
            iNewPose = 0
         Else
            iNewPose = _qMcm.iModTogglePose
         EndIf
         iNewFlags = _aiKnownPoseFlags[iNewPose]
      Else
         iNewPose = _iCurrPose + 1
         Int iMaxPoses = _aszKnownPoses.Length
         Bool bValidPoseFound
         While (!bValidPoseFound)
            If (iNewPose == iOldPose)
               ; We have tried all other poses.  Stick with the one we have.
               bValidPoseFound = True
            ElseIf (iMaxPoses <= iNewPose)
               ; We reached the last pose.  Loop around to the first pose.
               iNewPose = 0
            EndIf

            iNewFlags = _aiKnownPoseFlags[iNewPose]

            ; Check if the non-standard poses are supported.
            ; 0x8000: A complex pose which can't be handled via the standard funcitons.
            bValidPoseFound = True
            If (Math.LogicalAnd(iNewFlags, 0x8000))
               ; Assume each non-standard pose isn't valid until we create a check for it.
               bValidPoseFound = False

               ; Check if the SD+ crawling pose is valid.
               If ("SD_Crawl" == _aszKnownPoses[iNewPose])
                  bValidPoseFound = (_bModPapyrusUtil && _bModSdPlus)
               EndIf
            EndIf

            ; If this pose isn't one we can use try the next one.
            If (!bValidPoseFound)
               iNewPose += 1
            EndIf
         EndWhile
      EndIf
      SetPose(iOldPose, iOldFlags, iNewPose, iNewFlags)
   EndIf
   DebugTrace("TraceEvent OnKeyUp: Done")
EndEvent

; Called from the approach package to indicate the approach is done (passed for failed).
Function PlayerApproachComplete()
   DebugTrace("TraceEvent PlayerApproachComplete")
   Log("PlayerApproachComplete (" + _szApproachModId + ")", DL_DEBUG, DC_INTERACTION)
   Actor aApproachNpc = (_aAliasApproachPlayer.GetReference() As Actor)
   String szModId = _szApproachModId
   _szApproachModId = ""
   _aAliasApproachPlayer.Clear()
   Bool bSuccess = (1000 > aApproachNpc.GetDistance(_aPlayer))

   Int iModEvent = ModEvent.Create("DFW_MovementDone")
   If (iModEvent)
      ModEvent.PushInt(iModEvent, 1)
      ModEvent.PushForm(iModEvent, aApproachNpc)
      ModEvent.PushBool(iModEvent, bSuccess)
      ModEvent.PushString(iModEvent, szModId)
      If (!ModEvent.Send(iModEvent))
         Log("Failed to send Event DFW_MovementDone(1, " + bSuccess + ", " + szModId + ")", \
             DL_ERROR, DC_INTERACTION)
      EndIf
   EndIf
   ; If no other move to packages are running stop monitoring them.
   If (!_aAliasMoveToLocation.GetReference() && !_aAliasMoveToObject.GetReference())
      _iMonitorMoveTo = 0
   EndIf
   DebugTrace("TraceEvent PlayerApproachComplete: Done")
EndFunction

Function MoveToLocationComplete(Bool bForceSuccess=False)
   DebugTrace("TraceEvent MoveToLocationComplete")
   Log("MoveToLocationComplete (" + _szMoveToLocationModId + ")", DL_DEBUG, DC_INTERACTION)
   _iFlagCheckMoveTo = 0
   Actor aMovingNpc = (_aAliasMoveToLocation.GetReference() As Actor)
   Location oTargetLocation = _aAliasLocationTarget.GetLocation()
   String szModId = _szMoveToLocationModId
   _szMoveToLocationModId = ""
   _aAliasMoveToLocation.Clear()
   _aAliasLocationTarget.Clear()
   Bool bSuccess = (bForceSuccess || (oTargetLocation == aMovingNpc.GetCurrentLocation()))
   If (!bSuccess)
      String szTargetHexId = "0x00000000"
      If (oTargetLocation)
         szTargetHexId = "0x" + _qDfwUtil.ConvertHexToString(oTargetLocation.GetFormId(), 8)
      EndIf
      Log("MoveToLocation Failed: " + szTargetHexId + " != 0x" + \
          _qDfwUtil.ConvertHexToString(aMovingNpc.GetCurrentLocation().GetFormId(), 8), \
          DL_INFO, DC_INTERACTION)
   EndIf

   Int iModEvent = ModEvent.Create("DFW_MovementDone")
   If (iModEvent)
      ModEvent.PushInt(iModEvent, 2)
      ModEvent.PushForm(iModEvent, aMovingNpc)
      ModEvent.PushBool(iModEvent, bSuccess)
      ModEvent.PushString(iModEvent, szModId)
      If (!ModEvent.Send(iModEvent))
         Log("Failed to send Event DFW_MovementDone(2, " + bSuccess + ", " + szModId + ")", \
             DL_ERROR, DC_INTERACTION)
      EndIf
   EndIf
   ; If no other move to packages are running stop monitoring them.
   If (!_aAliasApproachPlayer.GetReference() && !_aAliasMoveToObject.GetReference())
      _iMonitorMoveTo = 0
   EndIf
   DebugTrace("TraceEvent MoveToLocationComplete: Done")
EndFunction

Function MoveToObjectComplete()
   DebugTrace("TraceEvent MoveToObjectComplete")
   Log("MoveToObjectComplete (" + _szMoveToObjectModId + ")", DL_DEBUG, DC_INTERACTION)
   Actor aMovingNpc = (_aAliasMoveToObject.GetReference() As Actor)
   ObjectReference oTargetObject = _aAliasObjectTarget.GetReference()
   String szModId = _szMoveToObjectModId
   _szMoveToObjectModId = ""
   _aAliasMoveToObject.Clear()
   _aAliasObjectTarget.Clear()
   Bool bSuccess = (1000 > aMovingNpc.GetDistance(oTargetObject))

   Int iModEvent = ModEvent.Create("DFW_MovementDone")
   If (iModEvent)
      ModEvent.PushInt(iModEvent, 3)
      ModEvent.PushForm(iModEvent, aMovingNpc)
      ModEvent.PushBool(iModEvent, bSuccess)
      ModEvent.PushString(iModEvent, szModId)
      If (!ModEvent.Send(iModEvent))
         Log("Failed to send Event DFW_MovementDone(3, " + bSuccess + ", " + szModId + ")", \
             DL_ERROR, DC_INTERACTION)
      EndIf
   EndIf
   ; If no other move to packages are running stop monitoring them.
   If (!_aAliasApproachPlayer.GetReference() && !_aAliasMoveToLocation.GetReference())
      _iMonitorMoveTo = 0
   EndIf
   DebugTrace("TraceEvent MoveToObjectComplete: Done")
EndFunction


;***********************************************************************************************
;***                                  PRIVATE FUNCTIONS                                      ***
;***********************************************************************************************
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

; iTimeoutMs: 0: Wait forever.  <0: Fail, don't wait.
Bool Function MutexLock(Int iMutex, Int iTimeoutMs=1000)
   ; If this is not a valid mutex return a failure.
   If ((0 > iMutex) || (_iMutexNext <= iMutex))
      Return False
   EndIf

   ; If we aren't going to wait on the mutex check immediately.
   If ((0 > iTimeoutMs) && (0 < _aiMutex[iMutex]))
      ; Locking Failed, mutex busy.
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

String Function GetDisplayName(ObjectReference oObject, Bool bIncludeFormId=False)
   If (!oObject)
      Return S_NONE
   EndIf

   If (bIncludeFormId)
      Return "0x" + _qDfwUtil.ConvertHexToString(oObject.GetFormId(), 8) + " " + \
             oObject.GetDisplayName()
   EndIf
   Return oObject.GetDisplayName()
EndFunction

String Function GetFormName(Form oForm, Bool bIncludeFormId=False)
   If (!oForm)
      Return S_NONE
   EndIf

   If (bIncludeFormId)
      Return "0x" + _qDfwUtil.ConvertHexToString(oForm.GetFormId(), 8) + " " + oForm.GetName()
   EndIf
   Return oForm.GetName()
EndFunction

; Waits for an actor to finish what they are doing while they are starting to sit or stand.
; Some functions of the game will not work when the actor is in this state.  The player speaking
; with the actor is one example.
Function ActorSitStateWait(Actor aActor, Int iMaxWaitMs=1500)
   DebugTrace("TraceEvent ActorSitStateWait")
   Int iSitState = aActor.GetSitState()
   While ((0 < iMaxWaitMs) && ((2 == iSitState) || (4 == iSitState)))
      Utility.Wait(0.1)
      iMaxWaitMs -= 100
      iSitState = aActor.GetSitState()
   EndWhile
   DebugTrace("TraceEvent ActorSitStateWait: Done")
EndFunction

Function ReportStatus(String szStatusType, Bool bStatus, Bool bOldStatus)
   ; If the status has changed log that information.
   If (bOldStatus && !bStatus)
      Log("You are no longer " + szStatusType + ".", DL_INFO, DC_STATUS)
   ElseIf (!bOldStatus && bStatus)
      Log("You are now " + szStatusType + ".", DL_INFO, DC_STATUS)
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

Bool Function IsActor(Form oForm)
   Int iType = oForm.GetType()
   ; 43 (kNPC) 44 (kLeveledCharacter) 62 (kCharacter)
   Return ((43 == iType) || (44 == iType) || (62 == iType))
EndFunction

; Figures out the actor's direction based on current position and last <X, Y> coordinates.
; 6: North-West  7: North        8: North-East
; 3:       West  4: No Movement  5:       East
; 0: South-West  1: South        2: South-East
; <=2: South  >=6: North (X%3)==0: West (X%3)==2: East
Int Function GetDirection(Actor aActor, Int iLastX, Int iLastY)
   ; Start with a direction of not moving.
   Int iDirection = 4
   ; Adjust for North/South movement.
   If (aActor.Y < (iLastY - 100))
      iDirection -= 3
   ElseIf (aActor.Y > (iLastY + 100))
      iDirection += 3
   EndIf
   ; Adjust for East/West movement.
   If (aActor.X < (iLastX - 100))
      iDirection -= 1
   ElseIf (aActor.X > (iLastX + 100))
      iDirection += 1
   EndIf
   Return iDirection
EndFunction

Bool Function CheckLeashInterruptScene()
   DebugTrace("TraceEvent CheckLeashInterruptScene")
   ; If the player is not in a scene, nothing to worry about.
   If (!IsPlayerCriticallyBusy(False))
      DebugTrace("TraceEvent CheckLeashInterruptScene: Done (Not Busy)")
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
      DebugTrace("TraceEvent CheckLeashInterruptScene: Done (Still Busy)")
      Return False
   EndIf
   DebugTrace("TraceEvent CheckLeashInterruptScene: Done")
   Return True
EndFunction

; This only identifies the type Clothing (including armour), restraints, or none.
; Other functions should provide more detailed information based on the type of item.
Int Function GetItemType(Form oItem)
   ; Make sure the item exists and is some form of "armour".
   If (!oItem || (26 != oItem.GetType()))
      Return IT_NONE
   EndIf

   ; Get the item's name and slot.
   String szName = oItem.GetName()
   Int iItemSlotMask = (oItem As Armor).GetSlotMask()

   ; Check to see if it is some form of restraint.
   If (oItem.HasKeyword(_oKeywordZadLockable) || oItem.HasKeyword(_oKeywordZbfWornDevice) || \
       oItem.HasKeyword(_oKeywordZadInventoryDevice))
      Return IT_RESTRAINT
   EndIf

   ; Armour and clothing need to have a name and a slot.
   ; Items with no name or slot are assumed (at least at this point) to be unknown items.
   If (!szName || !iItemSlotMask)
      Return IT_NONE
   EndIf

   ; If the item has the SexLab No Strip keyword, assume that it is not regular clothing.
   ; For any coverings, SexLab should be able to strip them as normal.
   If (oItem.HasKeyword(_oKeywordSexLabNoStrip))
      Return IT_NONE
   EndIf

   ; StrapOns are neither restraints, nor clothing and should be identified as IT_NONE.
   If (_oStraponByAeon == oItem)
      Return IT_NONE
   EndIf

   ; Otherwise check all clothing/armour keywords.
   If (oItem.HasKeyword(_oKeywordClothes) || oItem.HasKeyword(_oKeywordArmourLight) || \
       oItem.HasKeyword(_oKeywordArmourHeavy))
      Return IT_COVERINGS
   EndIf

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

Bool Function IsWeapon(Weapon oWeapon)
   If (!oWeapon || \
       (_oSpergFist1 && (_oSpergFist1 == oWeapon)) || \
       (_oSpergFist2 && (_oSpergFist2 == oWeapon)))
      Return False
   EndIf
   Return True
EndFunction

Function CheckIsNaked(Actor aActor=None)
   DebugTrace("TraceEvent CheckIsNaked - " + Utility.GetCurrentRealTime())
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
      Log("Body: \"" + oWornItem.GetName() + "\"", DL_DEBUG, DC_STATUS)
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
      DebugTrace("TraceEvent CheckIsNaked: Done (Covered) - " + Utility.GetCurrentRealTime())
      Return
   EndIf

   ; Then check chest slots if any are specified.
   _bChestCovered = False
   _bChestReduced = False
   Int iIndex = _qMcm.aiSettingsSlotsChest.Length - 1
   While (!_bChestCovered && (0 <= iIndex))
      oWornItem = aActor.GetWornForm(_qMcm.aiSettingsSlotsChest[iIndex])
      If (oWornItem)
         Log("Chest: \"" + oWornItem.GetName() + "\"", DL_DEBUG, DC_STATUS)
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
         Log("Waist: \"" + oWornItem.GetName() + "\"", DL_DEBUG, DC_STATUS)
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
      _iNakedStatus = NS_NAKED
   EndIf
   DebugTrace("TraceEvent CheckIsNaked: Done - " + Utility.GetCurrentRealTime())
EndFunction

Bool Function MoveNpcCheckForGround(Actor aNpc, Float fXAdjustment, Float fYAdjustment)
   DebugTrace("TraceEvent MoveNpcCheckForGround")
   ; Move the NPC to the specified location.
   aNpc.MoveTo(_aPlayer, fXAdjustment, fYAdjustment, 0, False)

   ; If the NPC's 3D is not loaded don't try anything further.
   ; Note that sometimes it takes a few move attempts before the 3D is loaded.  Not sure why.
   If (!aNpc.Is3DLoaded())
      DebugTrace("TraceEvent MoveNpcCheckForGround: Done (No 3D)")
      Return False
   EndIf

   ; Disable the NPC's AI so the only movement we detect is from falling.
   aNpc.EnableAI(False)

   ; Make sure the NPC is moving via the Havok system so we can check if he is falling.
   aNpc.ApplyHavokImpulse(0.0, 0.0, -1.0, 0)

   ; Reenable the NPC's AI as he might need it.
   aNpc.EnableAI()

   ; Compare the NPC's Z value at two points in time to see if he is falling.
   Float fZValue = aNpc.Z
   Utility.Wait(0.1)
   Float fNewZValue = aNpc.Z

   If (fNewZValue == fZValue)
      ; If the values are the same it most likely means the NPC is too far away?
      ; And not on solid ground?
      DebugTrace("TraceEvent MoveNpcCheckForGround: Done (Same Z-Value)")
      Return False
   EndIf

   ; If the NPC has not moved downward more than one unit, most likely he is on solid ground.
   ; TODO: Needs more testing.
   If (-1 < (fNewZValue - fZValue))
      ; Perform a second, longer check to verify the NPC really isn't moving downward.
      Utility.Wait(0.25)
      fNewZValue = aNpc.Z

      If (-1 < (fNewZValue - fZValue))
         DebugTrace("TraceEvent MoveNpcCheckForGround: Done (Solid Ground)")
         Return True
      EndIf
   EndIf

   ; Otherwise the NPC is falling.  He is not on solid ground.  Consider it a failure.
   DebugTrace("TraceEvent MoveNpcCheckForGround: Done")
   Return False
EndFunction

Function SetMultiAnimation()
   ObjectReference oCurrFurniture = _qZbfPlayerSlot.GetFurniture()
   If (oCurrFurniture && oCurrFurniture.HasKeyword(_oKeywordZbfFurniture) && \
       oCurrFurniture.HasKeyword(_oKeywordZbfFurnitureMulti))

      ; Figure out if we are dealing with a multi=pole or a multi-wall.
      ; iAnimIndex: -7: Recommended  -6: Cycle Real  -5: Cycle Alt     -4: Cycle Both
      ;                  -3: Random Real  -2: Random Alt  -1: Random Both  0-x: Indexable Animations
      Int iAnimIndex = -7
      If ("Multi Restraint Wall" == oCurrFurniture.GetName())
         iAnimIndex = _qMcm.iModMultiWallAnimation
      Else
         iAnimIndex = _qMcm.iModMultiPoleAnimation
      EndIf

      ; Keep an array of all of the animations we are expecting.
      ; See also:
      ;  Data\Meshes\actors\character\animations\ZaZAnimationPack\FNIS_ZaZAnimationPack_List.txt
      ;  zbfBondageShell.psc => GetPoseAnimList() => iFurnitureMultiRestraint
      String[] aiAnimationName = New String[12]
      aiAnimationName[0]  = "ZaZAPFMPP01"
      aiAnimationName[1]  = "ZaZAPFMPP02"
      aiAnimationName[2]  = "ZaZAPFMPP03"
      aiAnimationName[3]  = "ZaZAPFMPP04"
      aiAnimationName[4]  = "ZaZAPFMPP05"
      aiAnimationName[5]  = "ZaZAPFMPP06"
      aiAnimationName[6]  = "ZazAPCAO301"
      aiAnimationName[7]  = "ZazAPCAO302"
      aiAnimationName[8]  = "ZazAPCAO303"
      aiAnimationName[9]  = "ZazAPCAO304"
      aiAnimationName[10] = "ZazAPCAO305"
      aiAnimationName[11] = "ZazAPCAO306"

      If ((-6 <= iAnimIndex) && (-4 >= iAnimIndex))
         ; -6: Cycle Real  -5: Cycle Alt     -4: Cycle Both

         Int iFirstIndex = 0
         Int iIndex = 11
         If (-6 == iAnimIndex)
            iIndex = 5
         ElseIf (-5 == iAnimIndex)
            iFirstIndex = 6
         EndIf

         ; Create a comma separated string of all of the animations.
         String szAllAnims
         While (iFirstIndex <= iIndex)
            If (szAllAnims)
               szAllAnims += ","
            EndIf
            szAllAnims += aiAnimationName[iIndex]
            iIndex -= 1
         EndWhile

         _qZbfPlayerSlot.SetAnimSet(szAllAnims, 15)
      Else
         ;  -7: Recommended  -3: Random Real  -2: Random Alt  -1: Random Both
         ; 0-x: Indexable Animations

         If (-7 == iAnimIndex)
            iAnimIndex = Utility.RandomInt(0, 4)
         ElseIf (-3 == iAnimIndex)
            iAnimIndex = Utility.RandomInt(0, 5)
         ElseIf (-2 == iAnimIndex)
            iAnimIndex = Utility.RandomInt(6, 11)
         ElseIf (-1 == iAnimIndex)
            iAnimIndex = Utility.RandomInt(0, 11)
         EndIf

         _qZbfPlayerSlot.StopIdleAnim()
         _qZbfPlayerSlot.SetAnim(aiAnimationName[iAnimIndex])
      EndIf
   EndIf
EndFunction

Function CleanupNearbyList()
   ; If we have done a cleanup too recently don't try again.
   If (_fNearbyCleanupTime && (Utility.GetCurrentRealTime() < _fNearbyCleanupTime))
      Return
   EndIf
   Float fCurrTime = Utility.GetCurrentRealTime()
   _fNearbyCleanupTime = fCurrTime + 3
   DebugTrace("TraceEvent CleanupNearbyList - " + fCurrTime)

   Cell oPlayerCell = _aPlayer.GetParentCell()
   Int iIndex = _aoNearby.Length - 1
   While (0 <= iIndex)
      Actor aNearby = None
      If (MutexLock(_iNearbyMutex))
         ; Performing the whole cleanup involves more context switching than I would like to put
         ; into a mutex lock so we must lock the mutex multiple times.  By doing so we must also
         ; validate that the list has not changed in the process.  Make sure the index is valid.
         If (iIndex <= _aoNearby.Length - 1)
            aNearby = (_aoNearby[iIndex] As Actor)
         EndIf

         MutexRelease(_iNearbyMutex)
      EndIf

      ; I'm not sure what distance spell ranges are in (_iMcmNearbyDistance) but it must be
      ; converted to the same units as GetDistance().  A rough estimate is 22.2 to 1.  Add extra
      ; so the actor is removed at a notably longer distance than he is added.
      If (aNearby && (aNearby.IsDead() || \
                      ((30 * _iMcmNearbyDistance) < aNearby.GetDistance(_aPlayer))))
         ; Note: Converting the form ID to hex is a little bit expensive for something triggered
         ;       by every nearby actor; however, for now it will help diagnose which magic
         ;       effect script instances are becoming stray.
         Log("Clear Nearby 0x" + \
             _qDfwUtil.ConvertHexToString(aNearby.GetFormId(), 8) + ": " + \
             aNearby.GetDisplayName(), DL_TRACE, DC_NEARBY)

         ; This actor is too far from the player.  Remove him from the list.
         If (MutexLock(_iNearbyMutex))
            ; Find the actor in the list again in case the list has changed.
            ; Performing the whole cleanup involves more context switching than I would like to
            ; put into a mutex lock so we must lock the mutex multiple times.  By doing so we
            ; must also validate that the list has not changed in the process.  Only remove the
            ; actor if he is still in the list.
            Int iActorIndex = _aoNearby.Find(aNearby)
            If (-1 != iActorIndex)
               iIndex = iActorIndex
               _aoNearby = _qDfwUtil.RemoveFormFromArray(_aoNearby, None, iIndex)
               _aiNearbyFlags = _qDfwUtil.RemoveIntFromArray(_aiNearbyFlags, 0, iIndex)

               If (_aoNearby.Length != _aiNearbyFlags.Length)
                  Log("Nearby Removed Wrong: " + _aoNearby.Length + " != " + \
                      _aiNearbyFlags.Length, DL_CRIT, DC_NEARBY)
               EndIf
            EndIf

            MutexRelease(_iNearbyMutex)
         EndIf
         ; Dispel the current nearby detector spell so he can be detected again.
         aNearby.DispelSpell(_oDfwNearbyDetectorSpell)
      EndIf
      iIndex -= 1
   EndWhile

   ; Don't try to clean up the nearby list more than every three seconds.
   DebugTrace("TraceEvent CleanupNearbyList: Done - " + Utility.GetCurrentRealTime())
EndFunction

; This must be called internally as it requires the known list mutex to be locked!
Function RemoveKnownActor(Int iIndex)
   _aoKnown            = _qDfwUtil.RemoveFormFromArray(_aoKnown,         None, iIndex)
   _afKnownLastSeen    = _qDfwUtil.RemoveFloatFromArray(_afKnownLastSeen, 0.0, iIndex)
   _aiKnownSignificant = _qDfwUtil.RemoveIntFromArray(_aiKnownSignificant,  0, iIndex)
   _aiKnownAnger       = _qDfwUtil.RemoveIntFromArray(_aiKnownAnger,        0, iIndex)
   _aiKnownConfidence  = _qDfwUtil.RemoveIntFromArray(_aiKnownConfidence,   0, iIndex)
   _aiKnownDominance   = _qDfwUtil.RemoveIntFromArray(_aiKnownDominance,    0, iIndex)
   _aiKnownInterest    = _qDfwUtil.RemoveIntFromArray(_aiKnownInterest,     0, iIndex)
   _aiKnownKindness    = _qDfwUtil.RemoveIntFromArray(_aiKnownKindness,     0, iIndex)
EndFunction

; This must be called internally as it requires the known list mutex to be locked!
Function CleanupKnownList()
   DebugTrace("TraceEvent CleanupKnownList - " + Utility.GetCurrentRealTime())
   Float fCurrTime = Utility.GetCurrentGameTime()

   ; On the first pass keep track of the max significance seen.
   ; We can use this in future passes to keep actors that are interacted with often.
   Int iMaxSignificance = 0

   ; First remove any NPCs that have not been involved in a significant interaction.
   Int iIndex = _aoKnown.Length - 1
   While (0 <= iIndex)
      ; Remove any NPCs over 3 hours old which have not been in a significant encounter.
      If (!_aiKnownSignificant[iIndex] && ((3 / 24) < (fCurrTime - _afKnownLastSeen[iIndex])))
         RemoveKnownActor(iIndex)
      ElseIf (iMaxSignificance < _aiKnownSignificant[iIndex])
         ; Keep track of the highest significance value seen.
         If (10 <= (_aiKnownSignificant[iIndex] - iMaxSignificance))
            ; Put a cap on how much we increase this to try to account for outliers.
            iMaxSignificance += 10
         Else
            iMaxSignificance = _aiKnownSignificant[iIndex]
         EndIf
      EndIf
      iIndex -= 1
   EndWhile

   ; For the next pass start with less significant NPCs and steadily increase it.
   Int iSignificance = 0
   While ((iSignificance < iMaxSignificance) && (20 <= _aoKnown.Length))
      ; While we are still above 20 NPCs remove NPCs who are X days old.
      Int iDays = 6
      While (iDays && (20 <= _aoKnown.Length))
         iIndex = _aoKnown.Length - 1
         While (iIndex)
            Float fDeltaTime = fCurrTime - _afKnownLastSeen[iIndex]
            If ((iDays <= fDeltaTime) && ((iSignificance >= !_aiKnownSignificant[iIndex]) && \
                                          ((3 / 24) < fDeltaTime)))
               RemoveKnownActor(iIndex)
            EndIf
            iIndex -= 1
         EndWhile
         iDays -= 1
      EndWhile

      ; Increase the significance we are looking for for the next pass.
      If (5 > (iMaxSignificance - iSignificance))
         iSignificance += 1
      ElseIf (10 > (iMaxSignificance - iSignificance))
         iSignificance += 3
      Else
         iSignificance += ((iMaxSignificance - iSignificance) / 2)
      EndIf
   EndWhile

   ; Finally continue to remove the oldest NPC until the list is down to 20.
   While (20 <= _aoKnown.Length)
      RemoveKnownActor(_aoKnown.Length - 1)
   EndWhile
   DebugTrace("TraceEvent CleanupKnownList: Done - " + Utility.GetCurrentRealTime())
EndFunction

Function Log(String szMessage, Int iLevel=0, Int iClass=0)
   szMessage = "[" + S_MOD + "] " + szMessage

   ; Log to console.  Not sure why we would want this.
   ;If (_bLogToConsole)
   ;   MiscUtil.PrintConsole(szMessage)
   ;EndIf

   ; Log to the papyrus file.
;   If (ilevel <= _iMcmLogLevel)
      Debug.Trace(szMessage)
;   EndIf

   ; Also log to the Notification area of the screen.
   If (_aiMcmScreenLogLevel && (ilevel <= _aiMcmScreenLogLevel[iClass]))
      Debug.Notification(szMessage)
   EndIf
EndFunction

; A special name for debug (non permanent) log messages making them easier to locate.
Function DebugLog(String szMessage, Int iLevel=4)
   Log(szMessage, iLevel, DC_DEBUG)
EndFunction

; A special name for function trace log messages making them easier to locate.
Function DebugTrace(String szMessage, Int iLevel=0, Int iClass=0)
   szMessage = "[" + S_MOD + "] " + szMessage

   ; Log to the papyrus file only.
   Debug.Trace(szMessage)
EndFunction

; For status purposes only to be called by the MCM status menu.
Form[] Function GetKnownActors()
   Return _aoKnown
EndFunction

Function UpdatePollingInterval(Float fNewInterval)
   _fMcmPollTime = fNewInterval
   RegisterForSingleUpdate(fNewInterval)
EndFunction

Function UpdatePollingDistance(Int iNewDistance)
   _oDfwNearbyDetectorSpell.SetNthEffectArea(0, iNewDistance)
EndFunction

; Returns an array of string information about the last dialogue target.
; This is inteded to be displayed by the MCM menu for diagnostics information.
String[] Function GetDialogueTargetInfo()
   String[] szInfo = New String[31]
   szInfo[00] = "Actor: " + _aCurrTarget.GetDisplayName()
   szInfo[01] = "_bCallingForAttention: " + _bCallingForAttention
   szInfo[02] = "_bCallingForHelp: " + _bCallingForHelp
   szInfo[03] = "_bIsActorDominant: " + _bIsActorDominant
   szInfo[04] = "_bIsActorLeashHolder: " + _bIsActorLeashHolder
   szInfo[05] = "_bIsActorOwner: " + _bIsActorOwner
   szInfo[06] = "_bIsActorSlave: " + _bIsActorSlave
   szInfo[07] = "_bIsActorSlaver: " + _bIsActorSlaver
   szInfo[08] = "_bIsActorSubmissive: " + _bIsActorSubmissive
   szInfo[09] = "_bIsGagStrict: " + _bIsGagStrict
   szInfo[10] = "_bIsLastRapeAggressor: " + _bIsLastRapeAggressor
   szInfo[11] = "_bIsPlayerArmLocked: " + _bIsPlayerArmLocked
   szInfo[12] = "_bIsPlayerBelted: " + _bIsPlayerBelted
   szInfo[13] = "_bIsPlayerBound: " + _bIsPlayerBound
   szInfo[14] = "_bIsPlayerBoundVisible: " + _bIsPlayerBoundVisible
   szInfo[15] = "_bIsPlayerCollared: " + _bIsPlayerCollared
   szInfo[16] = "_bIsPlayerFurnitureLocked: " + _bIsPlayerFurnitureLocked
   szInfo[17] = "_bIsPlayerGagged: " + _bIsPlayerGagged
   szInfo[18] = "_bIsPlayerHobbled: " + _bIsPlayerHobbled
   szInfo[19] = "_bIsPlayersMaster: " + _bIsPlayersMaster
   szInfo[20] = "_bIsPreviousMaster: " + _bIsPreviousMaster
   szInfo[21] = "_iActorAnger: " + _iActorAnger
   szInfo[21] = "_iActorArousal: " + _iActorArousal
   szInfo[22] = "_iActorConfidence: " + _iActorConfidence
   szInfo[23] = "_iActorDominance: " + _iActorDominance
   szInfo[24] = "_iActorInterest: " + _iActorInterest
   szInfo[25] = "_iActorKindness: " + _iActorKindness
   szInfo[26] = "_iNakedLevel: " + _iNakedLevel
   szInfo[27] = "_iWillingnessToHelp: " + _iWillingnessToHelp
   szInfo[28] = "_fActorDistance: " + _fActorDistance
   szInfo[29] = "_fHoursSinceLastRape: " + _fHoursSinceLastRape
   szInfo[30] = "_fMasterDistance: " + _fMasterDistance
   Return szInfo
EndFunction

Int Function MoveToObjectHelper(Actor aActor, ObjectReference oTarget, String szModId, \
                                Int iDistance, Bool bForce)
   DebugTrace("TraceEvent MoveToObjectHelper")
   ; Don't start any movement packages if we are shutting down the mod.
   If (_bMcmShutdownMod)
      DebugTrace("TraceEvent MoveToObjectHelper: Done (Mod Shutting Down)")
      Return FAIL
   EndIf

   Int iReturnCode = SUCCESS

   ; Check if there already is an NPC performing the movement.
   Actor aMovingNpc = (_aAliasMoveToObject.GetReference() As Actor)
   If (aMovingNpc)
      If (!bForce)
         ; If we are not told to override the current NPC fail the request.
         Log("MoveToObject Failed (" + szModId + "): In use by " + _szMoveToObjectModId, \
             DL_DEBUG, DC_INTERACTION)
         DebugTrace("TraceEvent MoveToObjectHelper: Done (Busy)")
         Return FAIL
      EndIf
      iReturnCode = WARNING

      ; Otherwise send an event to report the current NPC approach failed.
      Int iModEvent = ModEvent.Create("DFW_MovementDone")
      If (iModEvent)
         ModEvent.PushInt(iModEvent, 3)
         ModEvent.PushForm(iModEvent, aMovingNpc)
         ModEvent.PushBool(iModEvent, False)
         ModEvent.PushString(iModEvent, _szMoveToObjectModId)
         If (!ModEvent.Send(iModEvent))
            Log("Failed to send Event DFW_MovementDone(3, False, " + _szMoveToObjectModId + \
                ")", DL_ERROR, DC_INTERACTION)
         EndIf
      EndIf
   EndIf

   ; If the NPC is nowhere nearby and the object is in the same cell as the player, bring him
   ; close by before starting the approach package.
   If ((!aActor.Is3DLoaded() || (150000 < aActor.GetDistance(oTarget))) && \
       (oTarget.GetParentCell() == _aPlayer.GetParentCell()))
      NpcMoveNearbyHidden(aActor)
   EndIf

   _iMoveToObjectDistance = iDistance

   Log("MoveToObjectHelper (" + szModId + "," + GetDisplayName(aActor) + "," + \
       GetDisplayName(oTarget) + ")", DL_DEBUG, DC_INTERACTION)

   _szMoveToObjectModId = szModId
   _aAliasObjectTarget.ForceRefTo(oTarget)
   _aAliasMoveToObject.ForceRefTo(aActor)
   _iMonitorMoveTo = 3

   ; If we are forcing the same actor to the same package be sure to re-calculate his package.
   If (aMovingNpc && (aMovingNpc == aActor))
      ReEvaluatePackage(aActor)
   EndIf
   DebugTrace("TraceEvent MoveToObjectHelper: Done")
   Return iReturnCode
EndFunction

; Called by dialog scripts to indicate the player has completed a conversation.
; iContext: 0: No Relevant Context  1: Speaking with the collector.
; iActions: Unused.  Represents generic actions, e.g. restraining the player.
; iSpecialActions: 0x0001: Access the collector's special items chest.
; iCooperation: Unused.  How cooperative the player is.  Positive numbers indicate cooperation.
Function DialogueComplete(Int iContext, Int iActions, Actor aNpc, Int iCooperation=0, \
                          Int iSpecialActions=0, Bool bWaitForEnd=True)
   DebugTrace("TraceEvent DialogueComplete")
   If (iSpecialActions)
      ; 0x0001: Access the collector's special items chest.
      If (0x0001 <= iSpecialActions)
         If (_iMcmCollectorSpecialCost <= _aPlayer.GetItemCount(_oGold))
            _aPlayer.RemoveItem(_oGold, _iMcmCollectorSpecialCost, akOtherContainer=aNpc)
            _oCollectorsSpecialChest.Lock(False)
            _oCollectorsSpecialChest.Activate(_aPlayer)
            Utility.Wait(1.0)
            _oCollectorsSpecialChest.Lock()
         Else
            Log("You can't afford the collector's fee of " + _iMcmCollectorSpecialCost + \
                " gold.", DL_CRIT, DC_SAVE)
         EndIf
      EndIf
   EndIf
   DebugTrace("TraceEvent DialogueComplete: Done")
EndFunction

Int Function SetMasterClose(Actor aNewMaster, Int iPermissions, String szMod, Bool bOverride)
   DebugTrace("TraceEvent SetMasterClose")
   If (!_aMasterClose || bOverride)
      Actor aOldMaster = _aMasterClose
      String szOldMod = _aMasterModClose
      _aMasterClose = aNewMaster

      Int iIndex = _aaPreviousMasters.Find(_aMasterClose)
      If (-1 != iIndex)
         _aaPreviousMasters = _qDfwUtil.RemoveFormFromArray(_aaPreviousMasters, None, iIndex)
      EndIf
      _aaPreviousMasters = _qDfwUtil.AddFormToArray(_aaPreviousMasters, _aMasterClose)

      _aMasterModClose = szMod
      _iPermissionsClose = iPermissions
      If (aOldMaster)
         Log("Overriding " + aOldMaster.GetDisplayName() + " (" + szOldMod + ")", \
             DL_INFO, DC_MASTER)
         ; If we were overriding a master send out a mod event to notify the old mod.
         Int iModEvent = ModEvent.Create("DFW_NewMaster")
         If (iModEvent)
            ModEvent.PushString(iModEvent, szOldMod)
            ModEvent.PushForm(iModEvent, aOldMaster)
            If (ModEvent.Send(iModEvent))
               ; Give the overthrown mod a little time time process the event.
               Utility.Wait(0.1)
            Else
               Log("Failed to send Event DFW_NewMaster(" + szOldMod + ", " + \
                   aOldMaster.GetDisplayName() + ")", DL_ERROR, DC_MASTER)
            EndIf
         EndIf
         DebugTrace("TraceEvent SetMasterClose: Done (Overridden)")
         Return WARNING
      EndIf
      DebugTrace("TraceEvent SetMasterClose: Done (Master Set)")
      Return SUCCESS
   EndIf
   Log("Existing Master " + _aMasterClose.GetDisplayName() + " (" + _aMasterModClose + ")", \
       DL_ERROR, DC_MASTER)
   DebugTrace("TraceEvent SetMasterClose: Done")
   Return FAIL
EndFunction

Int Function SetMasterDistant(Actor aNewMaster, Int iPermissions, String szMod, Bool bOverride)
   DebugTrace("TraceEvent SetMasterDistant")
   If (!_aMasterDistant || bOverride)
      Actor aOldMaster = _aMasterDistant
      String szOldMod = _aMasterModDistant
      _aMasterDistant = aNewMaster

      Int iIndex = _aaPreviousMasters.Find(_aMasterDistant)
      If (-1 != iIndex)
         _aaPreviousMasters = _qDfwUtil.RemoveFormFromArray(_aaPreviousMasters, None, iIndex)
      EndIf
      _aaPreviousMasters = _qDfwUtil.AddFormToArray(_aaPreviousMasters, _aMasterDistant)

      _aMasterModDistant = szMod
      _iPermissionsDistant = iPermissions
      If (aOldMaster)
         Log("Overriding " + aOldMaster.GetDisplayName() + " (" + szOldMod + ")", \
             DL_INFO, DC_MASTER)
         DebugTrace("TraceEvent SetMasterDistant: Done (Overridden)")
         Return WARNING
      EndIf
      DebugTrace("TraceEvent SetMasterDistant: Done (Master Set)")
      Return SUCCESS
   EndIf
   Log("Existing Master " + _aMasterDistant.GetDisplayName() + " (" + _aMasterModDistant \
       + ")", DL_ERROR, DC_MASTER)
   DebugTrace("TraceEvent SetMasterDistant: Done")
   Return FAIL
EndFunction


;***********************************************************************************************
;***                                   PUBLIC FUNCTIONS                                      ***
;***********************************************************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Basic API Documentation:
;          --- General Functions ---
;          String GetModVersion()
;            Bool IsPlayerCriticallyBusy(Bool bIncludeBleedout)
;            Bool IsPlayerBusy(Bool bIncludeCritical, Bool bIncludeDialogue,
;                              Bool bIncludeDfwScenes, Bool bIncludeSex, Bool bIncludeCombat,
;                              Bool bIncludeBleedout)
;             Int SceneStarting(String szSceneName, Int iSceneTimeout, Int iWaitMs,
;                               Bool bExtendCallout)
;             Int SceneContinue(String szSceneName, Int iSceneTimeout, String szPrevName)
;                 SceneDone(String szSceneName)
;          String GetCurrentScene()
;        Location GetRegion(Location oLocation, Cell oCell)
;             Int GetNearestRegionIndex(Location oNearestRegion, Int iVersion)
;             Int MovePlayer(ObjectReference oTarget, Float fOffsetX, Float fOffsetY,
;                            Float fOffsetZ, Int iTimeoutMs, Int iBusyBehaviour)
;                 BlockHealthRegen()
;                 RestoreHealthRegen()
;                 BlockMagickaRegen()
;                 RestoreMagickaRegen()
;                 DisableMagicka(Bool bDisable)
;                 BlockStaminaRegen()
;                 RestoreStaminaRegen()
;                 DisableStamina(Bool bDisable)
;                 BlockFastTravel()
;                 RestoreFastTravel()
;                 BlockMovement()
;                 RestoreMovement()
;                 BlockFighting()
;                 RestoreFighting()
;                 BlockCameraSwitch()
;                 RestoreCameraSwitch()
;                 BlockLooking()
;                 RestoreLooking()
;                 BlockSneaking()
;                 RestoreSneaking()
;                 BlockMenu()
;                 RestoreMenu()
;                 BlockActivate()
;                 RestoreActivate()
;                 BlockJournal()
;                 RestoreJournal()
;                 ForceSave()
;                 QuickSave()
;                 AutoSave()
;          --- Master ---
;           Actor GetMaster(Int iMasterDistance, Int iInstance)
;          String GetMasterMod(Int iMasterDistance, Int iInstance)
;             Int SetMaster(Actor aNewMaster, String szMod, Int iPermissions,
;                           Int iMasterDistance, Bool bOverride)
;             Int ClearMaster(Actor aMaster, String szMod, Bool bEscaped)
;             Int ChangeMasterDistance(Actor aMaster, Bool bMoveToDistant, Bool bOverride)
;                 AddPermission(Actor aMaster, Int iPermissionMask)
;                 RemovePermission(Actor aMaster, Int iPermissionMask)
;            Bool IsAllowed(Int iAction)
;          --- Player Status ---
;        Location GetCurrentLocation()
;        Location GetCurrentRegion()
;             Int GetNakedLevel()
;            Bool IsPlayerBound(Bool bIncludeHidden, Bool bOnlyLocked)
;            Bool IsPlayerArmLocked()
;            Bool IsPlayerBelted()
;            Bool IsPlayerCollared()
;            Bool IsPlayerGagged()
;            Bool IsPlayerHobbled()
;             Int GetNumOtherRestraints()
;                 SetStrictGag(Bool bIsStrict)
;            Bool IsGagStrict()
; ObjectReference GetBdsmFurniture()
;                 SetBdsmFurnitureLocked(Bool bLocked)
;            Bool IsBdsmFurnitureLocked()
;             Int GetVulnerability(Actor aActor)
;             Int GetWeaponLevel()
;             Int GetCurrPoseFlags()
;          --- Nearby Actors ---
;          Form[] GetNearbyActorList(Float fMaxDistance, Int iIncludeFlags, Int iExcludeFlags)
;           Int[] GetNearbyActorFlags()
;             Int GetActorFlags(Actor aNearby)
;           Actor GetRandomActor(Float fMaxDistance, Int iIncludeFlags, Int iExcludeFlags)
;           Actor GetNearestActor(Float fMaxDistance, Int iIncludeFlags, Int iExcludeFlags)
;            Bool IsActorNearby(Actor aActor)
;           Actor GetPlayerTalkingTo()
;           Actor GetPlayerInCombatWith()
;          --- Leash ---
;                 SetLeashTarget(ObjectReference oLeashTarget)
; ObjectReference GetLeashTarget()
;                 SetLeashLength(Int iLength)
;                 YankLeash()
;             Int YankLeash(Float fDamageMultiplier, Int iOverrideLeashStyle,
;                           Bool bInterruptScene, Bool bInterruptLeashTargetFalse,
;                           Bool bForceDamage)
;             Int YankLeashWait(Int iTimeoutMs)
;          --- NPC Disposition ---
;             Int GetActorAnger(Actor aActor, Int iMinValue, Int iMaxValue,
;                               Bool bCreateAsNeeded, Int iSignificant)
;             Int IncActorAnger(Actor aActor, Int iDelta, Int iMinValue, Int iMaxValue,
;                               Bool bCreateAsNeeded, Int iSignificant)
;             Int GetActorConfidence(Actor aActor, Int iMinValue, Int iMaxValue,
;                                    Bool bCreateAsNeeded, Int iSignificant)
;             Int IncActorConfidence(Actor aActor, Int iDelta, Int iMinValue, Int iMaxValue,
;                                    Bool bCreateAsNeeded, Int iSignificant)
;             Int GetActorDominance(Actor aActor, Int iMinValue, Int iMaxValue,
;                                   Bool bCreateAsNeeded, Int iSignificant)
;             Int IncActorDominance(Actor aActor, Int iDelta, Int iMinValue, Int iMaxValue,
;                                   Bool bCreateAsNeeded, Int iSignificant)
;             Int GetActorInterest(Actor aActor, Int iMinValue, Int iMaxValue,
;                                  Bool bCreateAsNeeded, Int iSignificant)
;             Int IncActorInterest(Actor aActor, Int iDelta, Int iMinValue, Int iMaxValue,
;                                  Bool bCreateAsNeeded, Int iSignificant)
;             Int GetActorKindness(Actor aActor, Int iMinValue, Int iMaxValue,
;                                  Bool bCreateAsNeeded, Int iSignificant)
;             Int IncActorKindness(Actor aActor, Int iDelta, Int iMinValue, Int iMaxValue,
;                                  Bool bCreateAsNeeded, Int iSignificant)
;             Int GetActorSignificance(Actor aActor)
;             Int GetActorWillingnessToHelp(Actor aActor)
;                 PrepareActorDialogue(Actor aActor)
;          --- NPC Interactions ---
;                 NpcMoveNearbyHidden(aActor)
;            Bool IsMoving(Actor aActor, String szModId, Int iMovementType)
;             Int ApproachPlayer(Actor aActor, Int iTimeoutSeconds, Int iSpeed, String szModId,
;                                Bool bForce)
;             Int MoveToLocation(Actor aActor, Location oTarget, String szModId,
;                                Bool bForce)
;             Int MoveToObject(Actor aActor, ObjectReference oTarget, String szModId,
;                              Bool bForce)
;             Int MoveToObjectClose(Actor aActor, ObjectReference oTarget, String szModId,
;                                   Int iDistance, Bool bForce)
;             Int HoverAt(Actor aActor, ObjectReference oTarget, String szModId, Int iTimeout,
;                         Bool bForce)
;                 HoverAtClear(String szModId)
;             Int GiveSpace(Actor aActor, ObjectReference oTarget, String szModId, Int iTimeout,
;                           Bool bForce)
;                 GiveSpaceClear(String szModId)
;          String GetApproachModId()
;          String GetMoveToLocationModId()
;          String GetMoveToObjectModId()
;          String GetGiveSpaceModId()
;            Bool HandleCallForHelp()
;            Bool HandleCallForAttention()
;            Bool WasCallOutRecent(Bool bAttention, Bool bHelp)
;                 CallOutDone()
;                 CallOutReset()
;                 ReEvaluatePackage(Actor aActor)
;          --- Player Items (The Collector) ---
;                 TransferItems(ObjectReference oItem, Int iCount, Bool bSilent)
;          --- Mod Events ---
;        ModEvent DFW_NewMaster(String szOldMod, Actor aOldMaster)
;        *** Warning: The following event is triggered often.  Handling should be fast! ***
;        ModEvent DFW_NearbyActor(Int iFlags, Actor aActor)
;        ModEvent DFW_MovementDone(Int iType, Actor aActor, Bool bSucceeded, String szModId)
;        ModEvent DFW_CallForHelp(Int iCallType, Int iRange, Actor aRecommendedActor)
;        ModEvent DFW_CallForAttention(Int iCallType, Int iRange, Actor aRecommendedActor)
;        ModEvent DFW_DialogueTarget(Actor aActor)
;

;----------------------------------------------------------------------------------------------
; API: General Functions
String Function GetModVersion()
   Return "3.00"
EndFunction

; Includes: In Bleedout, Controls Locked (i.e. When in a scene)
Bool Function IsPlayerCriticallyBusy(Bool bIncludeBleedout=True)
   DebugTrace("TraceEvent IsPlayerCriticallyBusy")
   If (_iBleedoutTime)
      ; If we are not supposed to consider bleedout as busy return false for anything during the
      ; bleedout.  Since bleedout locks player controls it is virtually impossible to
      ; distinguish it from other forms of being busy.
      If (!bIncludeBleedout)
         DebugTrace("TraceEvent IsPlayerCriticallyBusy: Done (Bleedout Not Busy)")
         Return False
      EndIf

      If (Utility.GetCurrentRealTime() < _iBleedoutTime)
         DebugTrace("TraceEvent IsPlayerCriticallyBusy: Done (Bleedout Busy)")
         Return True
      EndIf
      _iBleedoutTime = 0
   EndIf

   If (!_aPlayer.GetPlayerControls())
      DebugTrace("TraceEvent IsPlayerCriticallyBusy: Done (Controls Locked)")
      Return True
   EndIf

   DebugTrace("TraceEvent IsPlayerCriticallyBusy: Done")
   Return False
EndFunction

; Includes: In Bleedout, Controls Locked (i.e. When in a scene)
Bool Function IsPlayerBusy(Bool bIncludeCritical=True, Bool bIncludeDialogue=True, \
                           Bool bIncludeDfwScenes=True, Bool bIncludeSex=True, \
                           Bool bIncludeCombat=True, Bool bIncludeBleedout=True)
   DebugTrace("TraceEvent IsPlayerBusy")
   If (bIncludeCritical && IsPlayerCriticallyBusy(bIncludeBleedout))
      DebugTrace("TraceEvent IsPlayerBusy: Done (Critically)")
      Return True
   EndIf

   If (bIncludeDfwScenes && ("" != _szCurrentScene))
      DebugTrace("TraceEvent IsPlayerBusy: Done (Scene)")
      Return True
   EndIf

   If (bIncludeCombat && _aPlayer.IsInCombat())
      DebugTrace("TraceEvent IsPlayerBusy: Done (Combat)")
      Return True
   EndIf

   If (bIncludeSex && _qSexLab.IsActorActive(_aPlayer))
      DebugTrace("TraceEvent IsPlayerBusy: Done (SexLab)")
      Return True
   EndIf

   If (bIncludeDialogue && GetPlayerTalkingTo())
      DebugTrace("TraceEvent IsPlayerBusy: Done (Dialogue)")
      Return True
   EndIf

   DebugTrace("TraceEvent IsPlayerBusy: Done")
   Return False
EndFunction

; szSceneName can be anything.
; iSceneTimeout is in seconds.  The amount of time before giving up waiting for the scene done.
Int Function SceneStarting(String szSceneName, Int iSceneTimeout, Int iWaitMs=0, \
                           Bool bExtendCallout=True)
   DebugTrace("TraceEvent SceneStarting")
   ; Don't start any scenes if we are shutting down the mod.
   If (_bMcmShutdownMod)
      DebugTrace("TraceEvent SceneStarting: Done (Mod Shutting Down)")
      Return FAIL
   EndIf

   While (_szCurrentScene && (0 < iWaitMs))
      Utility.Wait(0.1)
      iWaitMs -= 100
   EndWhile
   If (_szCurrentScene)
      Log("Scene " + szSceneName + " failed due to " + _szCurrentScene, DL_DEBUG, \
          DC_INTERACTION)
      DebugTrace("TraceEvent SceneStarting: Done (Scene Busy)")
      Return FAIL
   EndIf
   Log("Scene Starting: " + szSceneName, DL_DEBUG, DC_INTERACTION)
   _bInScene = True
   _szCurrentScene = szSceneName
   _fSceneTimeout = Utility.GetCurrentRealTime() + iSceneTimeout
   _bSceneExtendsCallout = bExtendCallout
   DebugTrace("TraceEvent SceneStarting: Done")
   Return SUCCESS
EndFunction

Int Function SceneContinue(String szSceneName, Int iSceneTimeout, String szPrevName="")
   DebugTrace("TraceEvent SceneContinue")
   If (_szCurrentScene && (_szCurrentScene != szSceneName) && (_szCurrentScene != szPrevName))
      Log("Scene Cannot Continue: " + szSceneName + " != " + _szCurrentScene, DL_DEBUG, \
          DC_INTERACTION)
      DebugTrace("TraceEvent SceneContinue: Done (Scene Busy)")
      Return FAIL
   EndIf
   Log("Scene Continuing: " + szPrevName + " => " + szSceneName, DL_DEBUG, DC_INTERACTION)
   Int iReturnCode = SUCCESS
   If (!_szCurrentScene)
      iReturnCode = WARNING
   EndIf
   _bInScene = True
   _szCurrentScene = szSceneName
   _fSceneTimeout = Utility.GetCurrentRealTime() + iSceneTimeout
   DebugTrace("TraceEvent SceneContinue: Done")
   Return iReturnCode
EndFunction

Function SceneDone(String szSceneName)
   DebugTrace("TraceEvent SceneDone")
   Log("Scene Done: " + szSceneName, DL_DEBUG, DC_INTERACTION)
   If (_szCurrentScene == szSceneName)
      _fSceneTimeout = 0
      _bInScene = False
      _szCurrentScene = ""
      _bSceneExtendsCallout = False
   EndIf
   DebugTrace("TraceEvent SceneDone: Done")
EndFunction

String Function GetCurrentScene()
   Return _szCurrentScene
EndFunction

; Returns a location represnting the region (or town area) the location is close to.
; Regions not close to a town or civilization are None (considered "Wilderness").
; Note: This is not likely a particularly fast function and should be used sparingly.
Location Function GetRegion(Location oLocation, Cell oCell=None)
   DebugTrace("TraceEvent GetRegion")
   If (!oLocation)
      If (!oCell)
         DebugTrace("TraceEvent GetRegion: Done (No Cell)")
         Return None
      EndIf

      Int iIndex = SPECIAL_CELLS.Find(oCell)
      If (-1 == iIndex)
         DebugTrace("TraceEvent GetRegion: Done (Cannot Find Location)")
         Return None
      EndIf
      oLocation = (SPECIAL_CELL_LOCATIONS[iIndex] As Location)
   EndIf

   ; Check for the base regions first as they are quickest to search.
   Location oCurrLocation = None
   If ((oLocation == REGION_DAWNSTAR)    || (oLocation == REGION_DRAGON_BRIDGE)   || \
       (oLocation == REGION_FALKREATH)   || (oLocation == REGION_HIGH_HROTHGAR)   || \
       (oLocation == REGION_IVARSTEAD)   || (oLocation == REGION_KARTHWASTEN)     || \
       (oLocation == REGION_MARKARTH)    || (oLocation == REGION_MORTHAL)         || \
       (oLocation == REGION_OLD_HROLDAN) || (oLocation == REGION_RIFTEN)          || \
       (oLocation == REGION_RIVERWOOD)   || (oLocation == REGION_RORIKSTEAD)      || \
       (oLocation == REGION_SHORS_STONE) || (oLocation == REGION_SKY_HAVEN)       || \
       (oLocation == REGION_SOLITUDE)    || (oLocation == REGION_THALMOR_EMBASSY) || \
       (oLocation == REGION_WHITERUN)    || (oLocation == REGION_WINDHELM)        || \
       (oLocation == REGION_WINTERHOLD))
      oCurrLocation = oLocation
   ; Next check for any special suburbs of the region.
   ElseIf ((oLocation == SUBURB_SOLITUDE_WELLS) || (oLocation == SUBURB_SOLITUDE_AVENUES))
      oCurrLocation = REGION_SOLITUDE
   ElseIf (oLocation == SUBURB_WINTERHOLD_COLLEGE)
      oCurrLocation = REGION_WINTERHOLD
   ; Next check if the location is in one of the suburb lists.
   ElseIf (SUBURBS_DAWNSTAR && (-1 != SUBURBS_DAWNSTAR.Find(oLocation)))
      oCurrLocation = REGION_DAWNSTAR
   ElseIf (SUBURBS_DRAGON_BRIDGE && (-1 != SUBURBS_DRAGON_BRIDGE.Find(oLocation)))
      oCurrLocation = REGION_DRAGON_BRIDGE
   ElseIf (SUBURBS_FALKREATH && (-1 != SUBURBS_FALKREATH.Find(oLocation)))
      oCurrLocation = REGION_FALKREATH
   ElseIf (SUBURBS_HIGH_HROTHGAR && (-1 != SUBURBS_HIGH_HROTHGAR.Find(oLocation)))
      oCurrLocation = REGION_HIGH_HROTHGAR
   ElseIf (SUBURBS_IVARSTEAD && (-1 != SUBURBS_IVARSTEAD.Find(oLocation)))
      oCurrLocation = REGION_IVARSTEAD
   ElseIf (SUBURBS_KARTHWASTEN && (-1 != SUBURBS_KARTHWASTEN.Find(oLocation)))
      oCurrLocation = REGION_KARTHWASTEN
   ElseIf (SUBURBS_MARKARTH && (-1 != SUBURBS_MARKARTH.Find(oLocation)))
      oCurrLocation = REGION_MARKARTH
   ElseIf (SUBURBS_MORTHAL && (-1 != SUBURBS_MORTHAL.Find(oLocation)))
      oCurrLocation = REGION_MORTHAL
   ElseIf (SUBURBS_OLD_HROLDAN && (-1 != SUBURBS_OLD_HROLDAN.Find(oLocation)))
      oCurrLocation = REGION_OLD_HROLDAN
   ElseIf (SUBURBS_RIFTEN && (-1 != SUBURBS_RIFTEN.Find(oLocation)))
      oCurrLocation = REGION_RIFTEN
   ElseIf (SUBURBS_RIVERWOOD && (-1 != SUBURBS_RIVERWOOD.Find(oLocation)))
      oCurrLocation = REGION_RIVERWOOD
   ElseIf (SUBURBS_RORIKSTEAD && (-1 != SUBURBS_RORIKSTEAD.Find(oLocation)))
      oCurrLocation = REGION_RORIKSTEAD
   ElseIf (SUBURBS_SHORS_STONE && (-1 != SUBURBS_SHORS_STONE.Find(oLocation)))
      oCurrLocation = REGION_SHORS_STONE
   ElseIf (SUBURBS_SKY_HAVEN && (-1 != SUBURBS_SKY_HAVEN.Find(oLocation)))
      oCurrLocation = REGION_SKY_HAVEN
   ElseIf (SUBURBS_SOLITUDE && (-1 != SUBURBS_SOLITUDE.Find(oLocation)))
      oCurrLocation = REGION_SOLITUDE
   ElseIf (SUBURBS_THALMOR_EMBASSY && (-1 != SUBURBS_THALMOR_EMBASSY.Find(oLocation)))
      oCurrLocation = REGION_THALMOR_EMBASSY
   ElseIf (SUBURBS_WHITERUN && (-1 != SUBURBS_WHITERUN.Find(oLocation)))
      oCurrLocation = REGION_WHITERUN
   ElseIf (SUBURBS_WINDHELM && (-1 != SUBURBS_WINDHELM.Find(oLocation)))
      oCurrLocation = REGION_WINDHELM
   ElseIf (SUBURBS_WINTERHOLD && (-1 != SUBURBS_WINTERHOLD.Find(oLocation)))
      oCurrLocation = REGION_WINTERHOLD
   ; Finally check if a base region is a parent of the new location.
   ElseIf (REGION_DAWNSTAR.IsChild(oLocation))
      oCurrLocation = REGION_DAWNSTAR
   ElseIf (REGION_DRAGON_BRIDGE.IsChild(oLocation))
      oCurrLocation = REGION_DRAGON_BRIDGE
   ElseIf (REGION_FALKREATH.IsChild(oLocation))
      oCurrLocation = REGION_FALKREATH
   ElseIf (REGION_HIGH_HROTHGAR.IsChild(oLocation))
      oCurrLocation = REGION_HIGH_HROTHGAR
   ElseIf (REGION_IVARSTEAD.IsChild(oLocation))
      oCurrLocation = REGION_IVARSTEAD
   ElseIf (REGION_KARTHWASTEN.IsChild(oLocation))
      oCurrLocation = REGION_KARTHWASTEN
   ElseIf (REGION_MARKARTH.IsChild(oLocation))
      oCurrLocation = REGION_MARKARTH
   ElseIf (REGION_MORTHAL.IsChild(oLocation))
      oCurrLocation = REGION_MORTHAL
   ElseIf (REGION_OLD_HROLDAN.IsChild(oLocation))
      oCurrLocation = REGION_OLD_HROLDAN
   ElseIf (REGION_RIFTEN.IsChild(oLocation))
      oCurrLocation = REGION_RIFTEN
   ElseIf (REGION_RIVERWOOD.IsChild(oLocation))
      oCurrLocation = REGION_RIVERWOOD
   ElseIf (REGION_RORIKSTEAD.IsChild(oLocation))
      oCurrLocation = REGION_RORIKSTEAD
   ElseIf (REGION_SHORS_STONE.IsChild(oLocation))
      oCurrLocation = REGION_SHORS_STONE
   ElseIf (REGION_SKY_HAVEN.IsChild(oLocation))
      oCurrLocation = REGION_SKY_HAVEN
   ElseIf (REGION_SOLITUDE.IsChild(oLocation) || \
           SUBURB_SOLITUDE_WELLS.IsChild(oLocation) || \
           SUBURB_SOLITUDE_AVENUES.IsChild(oLocation))
      oCurrLocation = REGION_SOLITUDE
   ElseIf (REGION_THALMOR_EMBASSY.IsChild(oLocation))
      oCurrLocation = REGION_THALMOR_EMBASSY
   ElseIf (REGION_WHITERUN.IsChild(oLocation))
      oCurrLocation = REGION_WHITERUN
   ElseIf (REGION_WINDHELM.IsChild(oLocation))
      oCurrLocation = REGION_WINDHELM
   ElseIf (REGION_WINTERHOLD.IsChild(oLocation) || \
           SUBURB_WINTERHOLD_COLLEGE.IsChild(oLocation))
      oCurrLocation = REGION_WINTERHOLD
   EndIf
   DebugTrace("TraceEvent GetRegion: Done")
   Return oCurrLocation
EndFunction

; iVersion: In the future regions may be added to this mod.  If the calling code will not
;           support greater indexes that are returned the calling code needs to specify the
;           version of this function that they do support (which is currently 1).
Int Function GetNearestRegionIndex(Location oNearestRegion=None, Int iVersion=0)
   If (!iVersion)
      iVersion = 1
   EndIf
   If (!oNearestRegion)
      oNearestRegion = GetNearestRegion()
   EndIf

   Return REGIONS_INDEXED.Find(oNearestRegion)
EndFunction

; I am fairly certain that two mods using _aPlayer.MoveTo() at the same time causes the game to
; crash.  The intent of this function is to guarantee there is a delay between MoveTo() calls
; that move the player.
;
; fTimeout: In Seconds.
; iBusyBehaviour: 0: Wait until complete  1: Return FAIL  2: Move anyway (Not recommended).
Int Function MovePlayer(ObjectReference oTarget, Float fOffsetX=0.0, Float fOffsetY=0.0, \
                        Float fOffsetZ=0.0, Float fTimeout=2.0, Int iBusyBehaviour=0)
   If ((2 != iBusyBehaviour) && (_qSexLab.IsActorActive(_aPlayer) || IsPlayerCriticallyBusy()))
      If (iBusyBehaviour)
         Return FAIL
      EndIf
      While (_qSexLab.IsActorActive(_aPlayer) || IsPlayerCriticallyBusy())
         Utility.Wait(1.5)
      EndWhile
   EndIf

   ; Try to lock the mutex.  Keep track of whether the mutex is currently locked.  If another
   ; request is moving the player we want to add an extra delay to space them out.
   Float fOriginalTimeout = fTimeout
   Bool bLockedByUs = MutexLock(_iMovePlayerMutex, -1)
   While (!bLockedByUs && (0.0 < fTimeout))
      Utility.Wait(0.1)
      fTimeout -= 0.1
      bLockedByUs = MutexLock(_iMovePlayerMutex, -1)
   EndWhile

   ; If we did not procure the mutex fail the move request.
   If (!bLockedByUs)
      Return FAIL
   EndIf

   ; We now have the mutex locked.
   ; If the timeout has changed we did not procure the mutex on the first try.
   If (fOriginalTimeout != fTimeout)
      ; Add a delay to space out the attempts to move the player.
      Utility.Wait(1.2)
   EndIf

   ActorSitStateWait(_aPlayer)
   _aPlayer.MoveTo(oTarget, fOffsetX, fOffsetY, fOffsetZ)
   MutexRelease(_iMovePlayerMutex)

   ; MoveTo enables fast travel.  Disable it again if necessary.
   If (_iBlockFastTravel)
      Game.EnableFastTravel(False)
   EndIf
EndFunction

Function BlockHealthRegen()
   ; If this is the first mod to block regeneration block it now.
   If (0 == _iBlockHealthRegen)
      _aPlayer.DamageActorValue("HealRate", _aPlayer.GetActorValue("HealRate") * 0.99)
   EndIf

   _iBlockHealthRegen += 1
EndFunction

Function RestoreHealthRegen()
   _iBlockHealthRegen -= 1

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

   _iBlockMagickaRegen += 1
EndFunction

Function RestoreMagickaRegen()
   _iBlockMagickaRegen -= 1

   ; If no more mods have regeneration blocked restore it completely.
   If (0 == _iBlockMagickaRegen)
      _aPlayer.RestoreActorValue("MagickaRate", 10000)
   EndIf
EndFunction

Function DisableMagicka(Bool bDisable=True)
   If (bDisable)
      ; If this is the first mod to disable magica disable it now.
      If (0 == _iDisableMagicka)
         _aPlayer.DamageActorValue("MagickaRate", _aPlayer.GetActorValue("MagickaRate"))
         _aPlayer.DamageActorValue("Magicka", _aPlayer.GetActorValue("Magicka"))
      EndIf

      _iDisableMagicka += 1
      Return
   EndIf
   _iDisableMagicka -= 1

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

   _iBlockStaminaRegen += 1
EndFunction

Function RestoreStaminaRegen()
   _iBlockStaminaRegen -= 1

   ; If no more mods have regeneration blocked restore it completely.
   If (0 == _iBlockStaminaRegen)
      _aPlayer.RestoreActorValue("StaminaRate", 10000)
   EndIf
EndFunction

Function DisableStamina(Bool bDisable=True)
   If (bDisable)
      ; If this is the first mod to disable magica disable it now.
      If (0 == _iDisableStamina)
         _aPlayer.DamageActorValue("StaminaRate", _aPlayer.GetActorValue("StaminaRate"))
         _aPlayer.DamageActorValue("Stamina", _aPlayer.GetActorValue("Stamina"))
      EndIf

      _iDisableStamina += 1
      Return
   EndIf
   _iDisableStamina -= 1

   ; If no more mods have regeneration blocked restore it completely.
   If (0 == _iDisableStamina)
      _aPlayer.RestoreActorValue("StaminaRate", 10000)
      ; If some mods have regeneration blocked dampen it.
      If (_iBlockStaminaRegen)
         _aPlayer.DamageActorValue("StaminaRate", _aPlayer.GetActorValue("StaminaRate") * 0.99)
      EndIf
   EndIf
EndFunction

Function BlockFastTravel()
   ; If this is the first mod to block fast travel block it now.
   If (0 == _iBlockFastTravel)
      Game.EnableFastTravel(False)
   EndIf

   _iBlockFastTravel += 1
EndFunction

Function RestoreFastTravel()
   _iBlockFastTravel -= 1

   ; If no more mods have fast travel blocked restore it completely.
   If (0 == _iBlockFastTravel)
      Game.EnableFastTravel()
   EndIf
EndFunction

Function BlockMovement()
   ; If this is the first mod to block fast travel block it now.
   If (0 == _iBlockMovement)
      ;    DisablePlayerControls(Move,  Fight, Cam,   Look,  Sneak, Menu,  Active, Journ)
      Game.DisablePlayerControls(True,  False, False, False, False, False, False,  False)
   EndIf

   ; Make sure controls are disabled in the Zaz Animation Pack as well.
   _qZbfPlayerSlot.SetPlayerControlMask(Math.LogicalOr(0x0001, \
                                                       _qZbfPlayerSlot.iPlayerControlMask))

   _iBlockMovement += 1
EndFunction

Function RestoreMovement()
   _iBlockMovement -= 1

   ; If no more mods have fast travel blocked restore it completely.
   If (0 == _iBlockMovement)
      ;    EnablePlayerControls(Move,  Fight, Cam,   Look,  Sneak, Menu,  Activ, Journ)
      Game.EnablePlayerControls(True,  False, False, False, False, False, False, False)

      ; Make sure controls are re-enabled in the Zaz Animation Pack as well.
      _qZbfPlayerSlot.SetPlayerControlMask(Math.LogicalAnd(Math.LogicalNot(0x0001), \
                                                           _qZbfPlayerSlot.iPlayerControlMask))
   EndIf
EndFunction

Function BlockFighting()
   ; If this is the first mod to block fast travel block it now.
   If (0 == _iBlockFighting)
      ;    DisablePlayerControls(Move,  Fight, Cam,   Look,  Sneak, Menu,  Active, Journ)
      Game.DisablePlayerControls(False, True,  False, False, False, False, False,  False)
   EndIf

   ; Make sure controls are disabled in the Zaz Animation Pack as well.
   _qZbfPlayerSlot.SetPlayerControlMask(Math.LogicalOr(0x0002, \
                                                       _qZbfPlayerSlot.iPlayerControlMask))

   _iBlockFighting += 1
EndFunction

Function RestoreFighting()
   _iBlockFighting -= 1

   ; If no more mods have fast travel blocked restore it completely.
   If (0 == _iBlockFighting)
      ;    EnablePlayerControls(Move,  Fight, Cam,   Look,  Sneak, Menu,  Activ, Journ)
      Game.EnablePlayerControls(False, True,  False, False, False, False, False, False)

      ; Make sure controls are re-enabled in the Zaz Animation Pack as well.
      _qZbfPlayerSlot.SetPlayerControlMask(Math.LogicalAnd(Math.LogicalNot(0x0002), \
                                                           _qZbfPlayerSlot.iPlayerControlMask))
   EndIf
EndFunction

Function BlockCameraSwitch()
   ; If this is the first mod to block fast travel block it now.
   If (0 == _iBlockCameraSwitch)
      ;    DisablePlayerControls(Move,  Fight, Cam,   Look,  Sneak, Menu,  Active, Journ)
      Game.DisablePlayerControls(False, False, True,  False, False, False, False,  False)
   EndIf

   _iBlockCameraSwitch += 1
EndFunction

Function RestoreCameraSwitch()
   _iBlockCameraSwitch -= 1

   ; If no more mods have fast travel blocked restore it completely.
   If (0 == _iBlockCameraSwitch)
      ;    EnablePlayerControls(Move,  Fight, Cam,   Look,  Sneak, Menu,  Activ, Journ)
      Game.EnablePlayerControls(False, False, True,  False, False, False, False, False)
   EndIf
EndFunction

Function BlockLooking()
   ; If this is the first mod to block fast travel block it now.
   If (0 == _iBlockLooking)
      ;    DisablePlayerControls(Move,  Fight, Cam,   Look,  Sneak, Menu,  Active, Journ)
      Game.DisablePlayerControls(False, False, False, True,  False, False, False,  False)
   EndIf

   _iBlockLooking += 1
EndFunction

Function RestoreLooking()
   _iBlockLooking -= 1

   ; If no more mods have fast travel blocked restore it completely.
   If (0 == _iBlockLooking)
      ;    EnablePlayerControls(Move,  Fight, Cam,   Look,  Sneak, Menu,  Activ, Journ)
      Game.EnablePlayerControls(False, False, False, True,  False, False, False, False)
   EndIf
EndFunction

Function BlockSneaking()
   ; If this is the first mod to block fast travel block it now.
   If (0 == _iBlockSneaking)
      ;    DisablePlayerControls(Move,  Fight, Cam,   Look,  Sneak, Menu,  Active, Journ)
      Game.DisablePlayerControls(False, False, False, False, True,  False, False,  False)
   EndIf

   ; Make sure controls are disabled in the Zaz Animation Pack as well.
   _qZbfPlayerSlot.SetPlayerControlMask(Math.LogicalOr(0x0004, \
                                                       _qZbfPlayerSlot.iPlayerControlMask))

   _iBlockSneaking += 1
EndFunction

Function RestoreSneaking()
   _iBlockSneaking -= 1

   ; If no more mods have fast travel blocked restore it completely.
   If (0 == _iBlockSneaking)
      ;    EnablePlayerControls(Move,  Fight, Cam,   Look,  Sneak, Menu,  Activ, Journ)
      Game.EnablePlayerControls(False, False, False, False, True,  False, False, False)

      ; Make sure controls are re-enabled in the Zaz Animation Pack as well.
      _qZbfPlayerSlot.SetPlayerControlMask(Math.LogicalAnd(Math.LogicalNot(0x0004), \
                                                           _qZbfPlayerSlot.iPlayerControlMask))
   EndIf
EndFunction

Function BlockMenu()
   ; If this is the first mod to block fast travel block it now.
   If (0 == _iBlockMenu)
      ;    DisablePlayerControls(Move,  Fight, Cam,   Look,  Sneak, Menu,  Active, Journ)
      Game.DisablePlayerControls(False, False, False, False, False, True,  False,  False)
   EndIf

   ; Make sure controls are disabled in the Zaz Animation Pack as well.
   _qZbfPlayerSlot.SetPlayerControlMask(Math.LogicalOr(0x0008, \
                                                       _qZbfPlayerSlot.iPlayerControlMask))

   _iBlockMenu += 1
EndFunction

Function RestoreMenu()
   _iBlockMenu -= 1

   ; If no more mods have fast travel blocked restore it completely.
   If (0 == _iBlockMenu)
      ;    EnablePlayerControls(Move,  Fight, Cam,   Look,  Sneak, Menu,  Activ, Journ)
      Game.EnablePlayerControls(False, False, False, False, False, True,  False, False)

      ; Make sure controls are re-enabled in the Zaz Animation Pack as well.
      _qZbfPlayerSlot.SetPlayerControlMask(Math.LogicalAnd(Math.LogicalNot(0x0008), \
                                                           _qZbfPlayerSlot.iPlayerControlMask))
   EndIf
EndFunction

Function BlockActivate()
   ; If this is the first mod to block fast travel block it now.
   If (0 == _iBlockActivate)
      ;    DisablePlayerControls(Move,  Fight, Cam,   Look,  Sneak, Menu,  Active, Journ)
      Game.DisablePlayerControls(False, False, False, False, False, False, True,   False)
   EndIf

   ; Make sure controls are disabled in the Zaz Animation Pack as well.
   _qZbfPlayerSlot.SetPlayerControlMask(Math.LogicalOr(0x0010, \
                                                       _qZbfPlayerSlot.iPlayerControlMask))

   _iBlockActivate += 1
EndFunction

Function RestoreActivate()
   _iBlockActivate -= 1

   ; If no more mods have fast travel blocked restore it completely.
   If (0 == _iBlockActivate)
      ;    EnablePlayerControls(Move,  Fight, Cam,   Look,  Sneak, Menu,  Activ, Journ)
      Game.EnablePlayerControls(False, False, False, False, False, False, True,  False)

      ; Make sure controls are re-enabled in the Zaz Animation Pack as well.
      _qZbfPlayerSlot.SetPlayerControlMask(Math.LogicalAnd(Math.LogicalNot(0x0010), \
                                                           _qZbfPlayerSlot.iPlayerControlMask))
   EndIf
EndFunction

Function BlockJournal()
   ; If this is the first mod to block fast travel block it now.
   If (0 == _iBlockJournal)
      ;    DisablePlayerControls(Move,  Fight, Cam,   Look,  Sneak, Menu,  Active, Journ)
      Game.DisablePlayerControls(False, False, False, False, False, False, False,  True)
   EndIf

   _iBlockJournal += 1
EndFunction

Function RestoreJournal()
   _iBlockJournal -= 1

   ; If no more mods have fast travel blocked restore it completely.
   If (0 == _iBlockJournal)
      ;    EnablePlayerControls(Move,  Fight, Cam,   Look,  Sneak, Menu,  Activ, Journ)
      Game.EnablePlayerControls(False, False, False, False, False, False, False, True)
   EndIf
EndFunction

Function ForceSave()
   DebugTrace("TraceEvent ForceSave")
   ; Don't perform any game saves if we are shutting down the mod.
   If (_bMcmShutdownMod)
      DebugTrace("TraceEvent ForceSave: Done (Mod Shutting Down)")
      Return
   EndIf

   ; Make sure save games are allowed.
   Game.SetInChargen(False, False, True)

   If (1 == _iMcmSaveGameControlStyle)
      Log("Forced Save", DL_INFO, DC_SAVE)
      ActorSitStateWait(_aPlayer)
      ; Add a delay for the game to print the saving message.
      Utility.Wait(0.4)
      Game.SaveGame("QuickSave")
      Utility.Wait(0.01)
      Game.SaveGame("AutoSave1")
      Utility.Wait(0.01)
      Game.SaveGame("AutoSave2")
      Utility.Wait(0.01)
      Game.SaveGame("AutoSave3")
   ElseIf (2 == _iMcmSaveGameControlStyle)
      Float fCurrTime = Game.GetRealHoursPassed()
      If ((fCurrTime < (_fLastSave + 1.0/60.0)) && (3 == _iLastSaveType))
         ; We don't want to force save too often.  Not less than a minute between them.
         Log("Force Save Failed: Too Soon.", DL_DEBUG, DC_SAVE)
      Else
         Log("Forced Save", DL_INFO, DC_SAVE)
         _fLastSave = fCurrTime
         ActorSitStateWait(_aPlayer)
         _bBlockLoad = False
         ; Add a delay for the game to print the saving message.
         Utility.Wait(0.4)
         If (2 == _iLastSaveType)
            ; 0: Unknown  1: Auto  2: Quick  3: Force
            _iLastSaveType = 3
            Game.SaveGame(_szQuickSaveName)
            Utility.Wait(0.01)
            Game.SaveGame(_szAutoSaveName)
         Else
            ; 0: Unknown  1: Auto  2: Quick  3: Force
            _iLastSaveType = 3
            Game.SaveGame(_szAutoSaveName)
            Utility.Wait(0.01)
            Game.SaveGame(_szQuickSaveName)
         EndIf
         ; Add a delay before resetting _bBlockLoad as the Save doesn't happen immediately.
         Utility.Wait(0.5)
         _bBlockLoad = True
      EndIf
   EndIf

   ; Reset player control state in case we enabled save games that shouldn't be allowed.
   zbfBondageShell qBondageShell = zbfBondageShell.GetApi()
   If (qBondageShell)
      qBondageShell.ReapplyPlayerControls()
   EndIf
   DebugTrace("TraceEvent ForceSave: Done")
EndFunction

Function QuickSave()
   DebugTrace("TraceEvent QuickSave")
   ; Don't perform any game saves if we are shutting down the mod.
   If (_bMcmShutdownMod)
      DebugTrace("TraceEvent QuickSave: Done (Mod Shutting Down)")
      Return
   EndIf

   Float fCurrTime = Game.GetRealHoursPassed()
;   If (fCurrTime < (_fLastSave + (_qMcm.fModSaveMinTime / 60.0)))
;      Log("Cannot Save: Too Soon.", DL_INFO, DC_SAVE)
;   Else
      Log("QuickSave", DL_INFO, DC_SAVE)
      ; Add a delay for the game to print the saving message.
      Utility.Wait(0.4)

      ; You cannot save while the player is changing from sitting to standing or vice versa.
      ActorSitStateWait(_aPlayer)

      ; 0: Unknown  1: Auto  2: Quick  3: Force
      _iLastSaveType = 2
      _bBlockLoad = False
      _fLastSave = fCurrTime
      Game.SaveGame(_szQuickSaveName)

      ; Add a delay before resetting _bBlockLoad as the Save doesn't happen immediately.
      Utility.Wait(0.5)
      If (2 == _iMcmSaveGameControlStyle)
         _bBlockLoad = True
      EndIf
;   EndIf
   DebugTrace("TraceEvent QuickSave: Done")
EndFunction

Function AutoSave()
   DebugTrace("TraceEvent AutoSave")
   ; Don't perform any game saves if we are shutting down the mod.
   If (_bMcmShutdownMod)
      DebugTrace("TraceEvent AutoSave: Done (Mod Shutting Down)")
      Return
   EndIf

   ; Autosave should only be done with the Full Control save game style.
   If (2 != _iMcmSaveGameControlStyle)
      DebugTrace("TraceEvent AutoSave: Done (Not Configured)")
      Return
   EndIf

   Float fCurrTime = Game.GetRealHoursPassed()
   If (fCurrTime < (_fLastSave + (_qMcm.fModSaveMinTime / 60.0)))
      Log("Cannot Save: Too Soon.", DL_DEBUG, DC_SAVE)
   Else
      Log("Autosave", DL_INFO, DC_SAVE)
      ; Add a delay for the game to print the saving message.
      Utility.Wait(0.4)

      ; You cannot save while the player is changing from sitting to standing or vice versa.
      ActorSitStateWait(_aPlayer)

      ; 0: Unknown  1: Auto  2: Quick  3: Force
      _iLastSaveType = 1
      _bBlockLoad = False
      _fLastSave = fCurrTime
      Game.SaveGame(_szAutoSaveName)

      ; Add a delay before resetting _bBlockLoad as the Save doesn't happen immediately.
      Utility.Wait(0.5)
      _bBlockLoad = True
   EndIf
   DebugTrace("TraceEvent AutoSave: Done")
EndFunction


;----------------------------------------------------------------------------------------------
; API: Master
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

; This event is used to block menu access when quick and auto saves are being overwritten.
; TODO: Move this event to the *** EVENTS *** section of the file.
Event OnMenuOpen(String szMenu)
   If ("Journal Menu" == szMenu)
      Actor aAlvor = (Game.GetForm(0x00013482) As Actor)
      MovePlayer(aAlvor)
   ElseIf ("Console" == szMenu)
      ; If the player is accessing the console but is too vulnerable shut down the game.
      Int iConsoleVulnerability = _qMcm.iConConsoleVulnerability
      If ((2 == _iMcmSaveGameControlStyle) && iConsoleVulnerability && \
          (iConsoleVulnerability < GetVulnerability()) && !_iBlockConsoleTimer)
         Log("Save Game Control: Unauthorized Console Access Detected.", DL_CRIT, DC_SAVE)
         _iBlockConsoleTimer = 15
      EndIf
   EndIf
EndEvent

; szMod: Only used to display which Mod controls the Master.  Can be any short string.
; A mod should only allow sex if it can handle the player randomly and spontaneously being taken
; into a sex scene.  If a mod allows enslavement, register for the mod event (to be documented)
; to figure our when your mod looses control of the player.
; Set aNewMaster=None as a transition period between two Masters.
Int Function SetMaster(Actor aNewMaster, String szMod, Int iPermissions, \
                       Int iMasterDistance=0x00000004, Bool bOverride=False)
   DebugTrace("TraceEvent SetMaster")
   String szName = "None"
   If (aNewMaster)
      szName = aNewMaster.GetDisplayName()
   EndIf
   Log("New Master [" + szMod + "]-" + iMasterDistance + ": " + szName, DL_INFO, DC_MASTER)

   ; If a distant master is specified set our local "distant master" variable.
   Int iStatus
   If (MD_DISTANT == iMasterDistance)
      iStatus = SetMasterDistant(aNewMaster, iPermissions, szMod, bOverride)
   Else
      iStatus =  SetMasterClose(aNewMaster, iPermissions, szMod, bOverride)
   EndIf
   If ((SUCCESS <= iStatus) && aNewMaster)
      ; Register the player enslavement with the ZAZ Animation Pack as well.
      aNewMaster.AddToFaction(_qZbfSlave.zbfFactionMaster)
      aNewMaster.AddToFaction(_qZbfSlave.zbfFactionPlayerMaster)
      _qZbfSlave.EnslaveActor(_aPlayer, szMod)

      ; Overwrite the quck and auto saves to force the player to accept her slavery.
      ; Disable menus to prevent the player from stopping the games being overwritten.
      BlockMenu()
      BlockJournal()

      ; Register for detection of the main menu being opened (recorded as a Journal Menu).
      ; The main menu would allow the player to load a recent game.
      RegisterForMenu("Journal Menu")

      ; Force a save making the player accept her enslavement.
      ForceSave()

      ; Restore the player's access to her menus.
      UnregisterForMenu("Journal Menu")
      RestoreJournal()
      RestoreMenu()
   EndIf
   DebugTrace("TraceEvent SetMaster: Done")
   Return iStatus
EndFunction

Int Function ClearMaster(Actor aMaster, String szMod="", Bool bEscaped=False)
   DebugTrace("TraceEvent ClearMaster")
   String szName = "None"
   If (aMaster)
      szName = aMaster.GetDisplayName()

      ; Clear the Master with the ZAZ Animation Pack as well.
      aMaster.RemoveFromFaction(_qZbfSlave.zbfFactionMaster)
      aMaster.RemoveFromFaction(_qZbfSlave.zbfFactionPlayerMaster)
   EndIf
   Log("Clearing Master: " + szName, DL_INFO, DC_MASTER)

   String szControllingMod
   Int iStatus = WARNING
   If ((aMaster && (_aMasterClose == aMaster)) || (!aMaster && (_aMasterModClose == szMod)))
      _aMasterClose = None
      szControllingMod = _aMasterModClose
      _aMasterModClose = ""
      _iPermissionsClose = 0
      iStatus = SUCCESS
   EndIf
   If ((aMaster && (_aMasterDistant == aMaster)) || (!aMaster && (_aMasterModDistant == szMod)))
      _aMasterDistant = None
      szControllingMod = _aMasterModDistant
      _aMasterModDistant = ""
      _iPermissionsDistant = 0
      iStatus = SUCCESS
   EndIf

   ; Clear the player as a slave from the ZAZ Animation Pack if no one else is controlling her.
   If (szControllingMod && !_aMasterClose && !_aMasterDistant)
      _qZbfSlave.ReleaseSlave(_aPlayer, szControllingMod, bEscaped)
   EndIf
   DebugTrace("TraceEvent ClearMaster: Done")
   Return iStatus
EndFunction

Int Function ChangeMasterDistance(Actor aMaster, Bool bMoveToDistant=True, Bool bOverride=False)
   DebugTrace("TraceEvent ChangeMasterDistance")
   String szName = "None"
   If (aMaster)
      szName = aMaster.GetDisplayName()
   EndIf
   Log("Changing Master Distance: " + szName, DL_INFO, DC_MASTER)

   If (bMoveToDistant)
      ; If the specified Master is not close we can't move him to a distant master.
      If (_aMasterClose != aMaster)
         If (_aMasterDistant != aMaster)
            Log("Current Master differs " + _aMasterClose.GetDisplayName() + " (" + \
                _aMasterModClose + ")", DL_ERROR, DC_MASTER)
            DebugTrace("TraceEvent ChangeMasterDistance: Done (Wrong Master Close)")
            Return FAIL
         EndIf
         ; It is only a warning if the specified Master is already distant.
         Log("Already Distant.", DL_DEBUG, DC_MASTER)
            DebugTrace("TraceEvent ChangeMasterDistance: Done (Already Distant)")
         Return WARNING
      EndIf

      Int iStatus = SetMasterDistant(aMaster, _iPermissionsClose, _aMasterModClose, bOverride)
      _iPermissionsClose = 0
      If (SUCCESS <= iStatus)
         _aMasterClose = None
      EndIf
      DebugTrace("TraceEvent ChangeMasterDistance: Done (Set Distant)")
      Return iStatus
   EndIf

   ; If the specified Master is not distant we can't move him to a close master.
   If (_aMasterDistant != aMaster)
      If (_aMasterClose != aMaster)
         Log("Current Master differs " + _aMasterDistant.GetDisplayName() + " (" + \
             _aMasterModDistant + ")", DL_ERROR, DC_MASTER)
         DebugTrace("TraceEvent ChangeMasterDistance: Done (Wrong Master Distant)")
         Return FAIL
      EndIf
      ; It is only a warning if the specified Master is already close.
      Log("Already Close.", DL_DEBUG, DC_MASTER)
      DebugTrace("TraceEvent ChangeMasterDistance: Done (Already Close)")
      Return WARNING
   EndIf

   Int iStatus = SetMasterClose(aMaster, _iPermissionsDistant, _aMasterModDistant, bOverride)
   _iPermissionsDistant = 0
   If (SUCCESS <= iStatus)
      _aMasterDistant = None
   EndIf
   DebugTrace("TraceEvent ChangeMasterDistance: Done")
   Return iStatus
EndFunction

Function AddPermission(Actor aMaster, Int iPermissionMask)
   If (_aMasterClose == aMaster)
      _iPermissionsClose = Math.LogicalOr(_iPermissionsClose, iPermissionMask)
   ElseIf (_aMasterDistant == aMaster)
      _iPermissionsDistant = Math.LogicalOr(_iPermissionsDistant, iPermissionMask)
   EndIf
EndFunction

Function RemovePermission(Actor aMaster, Int iPermissionMask)
   If (_aMasterClose == aMaster)
      _iPermissionsClose = Math.LogicalXor(_iPermissionsClose, iPermissionMask)
   ElseIf (_aMasterDistant == aMaster)
      _iPermissionsDistant = Math.LogicalXor(_iPermissionsDistant, iPermissionMask)
   EndIf
EndFunction

Bool Function IsAllowed(Int iAction)
   ; Only a nearby master can assist dressing.
   If ((AP_DRESSING_ASSISTED == iAction) && !_iPermissionsClose)
      Return False
   EndIf

   If ((_aMasterClose && !Math.LogicalAnd(_iPermissionsClose, iAction)) || \
       (_aMasterDistant && !Math.LogicalAnd(_iPermissionsDistant, iAction)))
      Return False
   EndIf
   Return True
EndFunction


;----------------------------------------------------------------------------------------------
; API: Player Status
; Returns the current location of the player as that information is not available for actors.
; May return None before a location change has occurred.
Location Function GetCurrentLocation()
   If (_oCurrLocation)
      Return _oCurrLocation
   EndIf

   ; If we haven't identified the location yet check if the player is a special cell.
   Cell oCell = _aPlayer.GetParentCell()
   Int iIndex = SPECIAL_CELLS.Find(oCell)
   If (-1 != iIndex)
      Return (SPECIAL_CELL_LOCATIONS[iIndex] As Location)
   EndIf
   Return None
EndFunction

; A region is like a hold.  For cities it is the city location as well inner locations and
; suburbs around the city (for example, Salvius' Farm outside of Markarth). Unlike Holds most
; of the wilderness in the holds are not included.
Location Function GetCurrentRegion()
   If (_oCurrRegion)
      Return _oCurrRegion
   EndIf
   Cell oCell = _aPlayer.GetParentCell()
   ; If we haven't already identified the region try based on the player's current cell.
   Return GetRegion(None, oCell)
EndFunction

; Returns the nearest region to the player.
Location Function GetNearestRegion()
   ; If the player is in a known region return that.
   Location oRegion = GetCurrentRegion()
   If (oRegion)
      Return oRegion
   EndIf

   ; Otherwise the nearest region is calculated based on map coordinates of the world map.  This
   ; doesn't work for internal areas.  For internal areas we use the last known external region
   ; and assume it is correct.
   If (_aPlayer.IsInInterior())
      Return _oLastNearestRegion
   EndIf

   ; Otherwise, try to guess based on map coordinates.
   Int iX = (_aPlayer.X As Int)
   Int iY = (_aPlayer.Y As Int)
   If (-149000 > iX)
      If (49000 > iY)
         Return REGION_MARKARTH
      Else
         Return REGION_DRAGON_BRIDGE
      EndIf
   ElseIf (-110000 > iX)
      If (23000 > iY)
         Return REGION_MARKARTH
      ElseIf (49000 > iY)
         Return REGION_KARTHWASTEN
      Else
         Return REGION_DRAGON_BRIDGE
      EndIf
   ElseIf (-99000 > iX)
      If (-35000 > iY)
         Return REGION_FALKREATH
      ElseIf (46000 > iY)
         Return REGION_RORIKSTEAD
      Else
         Return REGION_DRAGON_BRIDGE
      EndIf
   ElseIf (-51000 > iX)
      If (-35000 > iY)
         Return REGION_FALKREATH
      ElseIf (46000 > iY)
         Return REGION_RORIKSTEAD
      Else
         Return REGION_SOLITUDE
      EndIf
   ElseIf (-9000 > iX)
      If (-35000 > iY)
         Return REGION_FALKREATH
      ElseIf (38000 > iY)
         Return REGION_WHITERUN
      ElseIf (89000 > iY)
         Return REGION_MORTHAL
      Else
         Return REGION_SOLITUDE
      EndIf
   ElseIf (0 > iX)
      If (-35000 > iY)
         Return REGION_FALKREATH
      ElseIf (38000 > iY)
         Return REGION_WHITERUN
      Else
         Return REGION_DAWNSTAR
      EndIf
   ElseIf (51000 > iX)
      If (-35000 > iY)
         Return REGION_RIVERWOOD
      ElseIf (38000 > iY)
         Return REGION_WHITERUN
      Else
         Return REGION_DAWNSTAR
      EndIf
   ElseIf (76000 > iX)
      If (-35000 > iY)
         Return REGION_IVARSTEAD
      ElseIf (38000 > iY)
         Return REGION_WHITERUN
      Else
         Return REGION_DAWNSTAR
      EndIf
   ElseIf (74000 > iX)
      If (-35000 > iY)
         Return REGION_IVARSTEAD
      ElseIf (48000 > iY)
         Return REGION_WHITERUN
      Else
         Return REGION_WINTERHOLD
      EndIf
   ElseIf (103000 > iX)
      If (-35000 > iY)
         Return REGION_IVARSTEAD
      ElseIf (48000 > iY)
         Return REGION_WINDHELM
      Else
         Return REGION_WINTERHOLD
      EndIf
   ElseIf (148000 > iX)
      If (-35000 > iY)
         Return REGION_RIFTEN
      ElseIf (48000 > iY)
         Return REGION_WINDHELM
      Else
         Return REGION_WINTERHOLD
      EndIf
   Else
      If (-73000 > iY)
         Return REGION_RIFTEN
      ElseIf (-35000 > iY)
         Return REGION_SHORS_STONE
      ElseIf (48000 > iY)
         Return REGION_WINDHELM
      Else
         Return REGION_WINTERHOLD
      EndIf
   EndIf
EndFunction

Int Function GetNakedLevel()
   Return _iNakedStatus
EndFunction

; Note: Currently bOnlyLocked is not supported.
Bool Function IsPlayerBound(Bool bIncludeHidden=False, Bool bOnlyLocked=False)
   If (_bIsPlayerCollared || _bIsPlayerArmLocked  || _bIsPlayerGagged || \
       _bIsPlayerHobbled  || _iNumOtherRestraints || \
       (_bHiddenRestraints && bIncludeHidden))
      Return True
   EndIf
   Return False
EndFunction

Bool Function IsPlayerArmLocked()
   Return _bIsPlayerArmLocked
EndFunction

Bool Function IsPlayerBelted()
   Return _bIsPlayerBelted
EndFunction

Bool Function IsPlayerCollared()
   Return _bIsPlayerCollared
EndFunction

Bool Function IsPlayerGagged()
   Return _bIsPlayerGagged
EndFunction

Bool Function IsPlayerHobbled()
   Return _bIsPlayerHobbled
EndFunction

Int Function GetNumOtherRestraints()
   If (_bIsPlayerHobbled)
      Return _iNumOtherRestraints + 1
   EndIf
   Return _iNumOtherRestraints
EndFunction

; Used to identify the gag the player is wearing is strict and effectively muffles sound.
Function SetStrictGag(Bool bIsStrict=True)
   _bIsGagStrict = bIsStrict
EndFunction

Bool Function IsGagStrict()
   Return _bIsGagStrict
EndFunction

; The DFW uses OnSit() and OnGetUp() events to keep track of _oBdsmFurniture.  There are some
; cases where this doesn't work.  In particular after some ZAZ Animation Pack scenes.  The ZAZ
; Animation Pack (zbf) GetFurniture() does not always seem to work when sitting with the
; RestrainInDevice() interface (Is this right?  Maybe we can very it).
; Use a combination of both to get the best coverage.
ObjectReference Function GetBdsmFurniture()
   If (_oBdsmFurniture)
      Return _oBdsmFurniture
   EndIf
   ObjectReference oCurrFurniture = _qZbfPlayerSlot.GetFurniture()
   If (oCurrFurniture && oCurrFurniture.HasKeyword(_oKeywordZbfFurniture))
      Return oCurrFurniture
   EndIf
   Return None
EndFunction

Function SetBdsmFurnitureLocked(Bool bLocked=True)
   DebugTrace("TraceEvent SetBdsmFurnitureLocked")
   _bIsFurnitureLocked = bLocked
   If (!_bIsFurnitureLocked && (3 > _aPlayer.GetSitState()))
      _oBdsmFurniture = None
      _qZbfPlayerSlot.SetFurniture(None)
   EndIf

   ; If the player is actively in furniture register this with the Zaz Animation Pack as well.
   If (_bIsFurnitureLocked)
      ObjectReference oCurrFurniture = _qZbfPlayerSlot.GetFurniture()
      If (oCurrFurniture && oCurrFurniture.HasKeyword(_oKeywordZbfFurniture))
         _qZbfPlayerSlot.SetFurniture(oCurrFurniture)

         ; If this is a multi-restraint furniture, try to identify the pose to use.
         If (oCurrFurniture.HasKeyword(_oKeywordZbfFurnitureMulti))
            SetMultiAnimation()
;
;             String szFirstAnim = _qZbfPlayerSlot.sCurrentAnim
;             Log("First Animation: " + szFirstAnim, DL_DEBUG, DC_DEBUG)
;             _qZbfPlayerSlot.PlayNext()
;             While (szFirstAnim != _qZbfPlayerSlot.sCurrentAnim)
;                Log("Next Animation: " + _qZbfPlayerSlot.sCurrentAnim, DL_DEBUG, DC_DEBUG)
; First Animation:
;  Next Animation: ZazAPCAO301
;  Next Animation: ZazAPCAO302
;  Next Animation: ZazAPCAO303
;  Next Animation: ZazAPCAO304
;  Next Animation: ZazAPCAO305
;  Next Animation: ZazAPCAO306
; Example: _qZbfPlayerSlot.SetAnim("ZazAPCAO301")
; Default: _qZbfPlayerSlot.SetAnimSet(None) or _qZbfPlayerSlot.StopIdleAnim()
;
;                _qZbfPlayerSlot.PlayNext()
;             EndWhile
         EndIf
      EndIf
   EndIf

   ; If we previously disabled the player's inventory, release it now.
   ; TODO: This should check if the player is no longer on the furniture.
   If (!_bIsFurnitureLocked && _bInventoryLocked)
      _bInventoryLocked = False
      ;    EnablePlayerControls(Move,  Fight, Cam,   Look,  Sneak, Menu,  Activ, Journ)
      Game.EnablePlayerControls(False, False, False, False, False, True,  False, False)
   Endif

   ; Make sure the dialogue conditional is updated in case it has changed.
   _bIsPlayerFurnitureLocked = (_bIsFurnitureLocked && GetBdsmFurniture())

   DebugTrace("TraceEvent SetBdsmFurnitureLocked: Done")
EndFunction

Bool Function IsBdsmFurnitureLocked()
   Return _bIsFurnitureLocked
EndFunction

; Never returns more than 100.
Int Function GetVulnerability(Actor aActor=None)
   ; Don't process any vulnerability requests if we are shutting down the mod.
   If (_bMcmShutdownMod)
      Return 0
   EndIf

   ;Off-DebugTrace("Get Vulnerability: " + Utility.GetCurrentRealTime(), DL_TRACE, DC_STATUS)
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
      If (_bIsPlayerCollared)
         iVulnerability += _qMcm.iVulnerabilityCollar
      EndIf
      If (_bIsPlayerArmLocked)
         iVulnerability += _qMcm.iVulnerabilityBinder
      EndIf
      If (_bIsPlayerGagged)
         iVulnerability += _qMcm.iVulnerabilityGagged
      EndIf
      Int iNumRestraints = _iNumOtherRestraints
      If (_bIsPlayerHobbled)
         iNumRestraints += 1
      EndIf
      iVulnerability += (iNumRestraints * _qMcm.iVulnerabilityRestraints)
      If (_oLeashTarget)
         iVulnerability += _qMcm.iVulnerabilityLeashed
      EndIf
      If (GetBdsmFurniture())
         iVulnerability += _qMcm.iVulnerabilityFurniture
      EndIf
      If (_qDfwUtil.IsNight())
         iVulnerability += _qMcm.iVulnerabilityNight
      EndIf
   Else
      Log("Vulnerability for NPCs not implemented.", DL_ERROR, DC_STATUS)
   EndIf

   ;Off-DebugTrace("Vulnerability: " + iVulnerability, DL_TRACE, DC_STATUS)
   If (100 < iVulnerability)
      iVulnerability = 100
   EndIf
   ; Set the condition variable so quest dialogues have access to how vulnerble the player is.
   _iVulnerability = iVulnerability
   Return iVulnerability
EndFunction

; Includes spells.  Returns 0 - 100.  50 should be "well equipped" for the player's level.
; Needs calibration.
Int Function GetWeaponLevel()
   Float fRightHand
   Float fLeftHand

   Weapon oWeaponRight = _aPlayer.GetEquippedWeapon()
   If (IsWeapon(oWeaponRight))
      Float fSkill = _aPlayer.GetActorValue(oWeaponRight.GetSkill())
;      Log("W-R: E(" + oWeaponRight.GetEnchantmentValue() + ") D(" + oWeaponRight.GetBaseDamage() + ") " + oWeaponRight.GetSkill() + "(" + fSkill + ")", DL_CRIT, DC_STATUS)
      fRightHand = ((25 As Float) * (oWeaponRight.GetBaseDamage() * fSkill / 10) / (_aPlayer.GetLevel() * 2))
   EndIf

   Weapon oWeaponLeft = _aPlayer.GetEquippedWeapon(True)
   If (IsWeapon(oWeaponLeft))
      Float fSkill = _aPlayer.GetActorValue(oWeaponLeft.GetSkill())
;      Log("W-R: E(" + oWeaponLeft.GetEnchantmentValue() + ") D(" + oWeaponLeft.GetBaseDamage() + ") " + oWeaponLeft.GetSkill() + "(" + fSkill + ")", DL_CRIT, DC_STATUS)
      fLeftHand = ((25 As Float) * (oWeaponLeft.GetBaseDamage() * fSkill / 10) / (_aPlayer.GetLevel() * 2))
   EndIf

   Float fTotalValue = fRightHand + fLeftHand

   Armor oShield = _aPlayer.GetEquippedShield()
   If (oShield)
      Enchantment oEnchantment = oShield.GetEnchantment()
      Int iTotalEffects = oEnchantment.GetNumEffects()
      Float fTotalMagnitude
      While (iTotalEffects)
         fTotalMagnitude = oEnchantment.GetNthEffectMagnitude(iTotalEffects)
         iTotalEffects -= 1
      EndWhile

;      Log("Shl: E(" + fTotalMagnitude + ") A(" + oShield.GetArmorRating() + ") S(" + _aPlayer.GetActorValue("Block") + ")", DL_CRIT, DC_STATUS)
      fTotalValue += ((10 As Float) * oShield.GetArmorRating() / (_aPlayer.GetLevel() * 2))
      fTotalValue += ((15 As Float) * _aPlayer.GetActorValue("Block") / (_aPlayer.GetLevel() * 2))
   EndIf
;   If (fTotalValue)
;      Log("Weapon Level: " + fLeftHand + " + " + fRightHand + " = " + fTotalValue, DL_CRIT, DC_STATUS)
;   EndIf
   Return (fTotalValue As Int)
EndFunction

Int Function GetCurrPoseFlags()
   Return _aiKnownPoseFlags[_iCurrPose]
EndFunction


;----------------------------------------------------------------------------------------------
; API: Nearby Actors
; The distance should be about 750 - 1,000 (loud talking distance) in the city.
; New actors are excluded by default.
Form[] Function GetNearbyActorList(Float fMaxDistance=0.0, Int iIncludeFlags=0, \
                                   Int iExcludeFlags=0)
   DebugTrace("TraceEvent GetNearbyActorList - " + Utility.GetCurrentRealTime())
   ; Clean up the actor list before we return elements from it.
   ; Note: The cleanup has it's own throttle mechanism preventing it from running all the time.
   CleanupNearbyList()

   ; If there is no filtering just return the known list.
   If (!iIncludeFlags && !iExcludeFlags && !fMaxDistance)
      _aiRecentFlags = _aiNearbyFlags
      DebugTrace("TraceEvent GetNearbyActorList: Done (Simple) - " + \
                 Utility.GetCurrentRealTime())
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
      If (!aNearby.IsDead() && \
          (!iExcludeFlags || !Math.LogicalAnd(_aiNearbyFlags[iIndex], iExcludeFlags)))
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
   _aiRecentFlags = aiTempFlags

   DebugTrace("TraceEvent GetNearbyActorList: Done - " + Utility.GetCurrentRealTime())
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

; Gets the actor flags for a specific actor if nearby.  0x00000000 otherwise.
Int Function GetActorFlags(Actor aNearby)
   Int iFlags = 0x00000000
   If (MutexLock(_iNearbyMutex))
      Int iIndex = _aoNearby.Find(aNearby)
      If (-1 != iIndex)
         iFlags = _aiNearbyFlags[iIndex]
      EndIf

      MutexRelease(_iNearbyMutex)
   EndIf
   Return iFlags
EndFunction

Actor Function GetRandomActor(Float fMaxDistance=0.0, Int iIncludeFlags=0, Int iExcludeFlags=0)
   DebugTrace("TraceEvent GetRandomActor - " + Utility.GetCurrentRealTime())
   Form[] aoNearbyList = GetNearbyActorList(fMaxDistance, iIncludeFlags, iExcludeFlags)
   Int iCount = aoNearbyList.Length
   If (iCount)
      Int iRandomIndex = Utility.RandomInt(0, iCount - 1)
      DebugTrace("TraceEvent GetRandomActor: Done (Actor) - " + Utility.GetCurrentRealTime())
      Return (aoNearbyList[iRandomIndex] As Actor)
   EndIf
   DebugTrace("TraceEvent GetRandomActor: Done - " + Utility.GetCurrentRealTime())
   Return None
EndFunction

Actor Function GetNearestActor(Float fMaxDistance=0.0, Int iIncludeFlags=0, Int iExcludeFlags=0)
   DebugTrace("TraceEvent GetNearestActor - " + Utility.GetCurrentRealTime())
   Form[] aoNearbyList = GetNearbyActorList(fMaxDistance, iIncludeFlags, iExcludeFlags)
   Int iIndex = aoNearbyList.Length - 1
   If (0 > iIndex)
      DebugTrace("TraceEvent GetNearestActor: Done - (None) " + Utility.GetCurrentRealTime())
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
   DebugTrace("TraceEvent GetNearestActor: Done - " + Utility.GetCurrentRealTime())
   Return aNearest
EndFunction

Bool Function IsActorNearby(Actor aActor)
   CleanupNearbyList()

   Bool bIsNearby = False
   If (MutexLock(_iNearbyMutex))
      bIsNearby = (-1 != _aoNearby.Find(aActor))

      MutexRelease(_iNearbyMutex)
   EndIf

   Return bIsNearby
EndFunction

Actor Function GetPlayerTalkingTo()
   DebugTrace("TraceEvent GetPlayerTalkingTo - " + Utility.GetCurrentRealTime())
   Actor aMatchFound = None

   If (MutexLock(_iNearbyMutex))
      Int iIndex = _aoNearby.Length - 1
      While (!aMatchFound && (0 <= iIndex))
         Actor aActor = (_aoNearby[iIndex] As Actor)
         If (aActor.IsInDialogueWithPlayer())
            aMatchFound = aActor
         EndIf
         iIndex -= 1
      EndWhile

      MutexRelease(_iNearbyMutex)
   EndIf
   DebugTrace("TraceEvent GetPlayerTalkingTo: Done - " + Utility.GetCurrentRealTime())
   Return aMatchFound
EndFunction

Actor Function GetPlayerInCombatWith()
   DebugTrace("TraceEvent GetPlayerInCombatWith - " + Utility.GetCurrentRealTime())
   Actor aMatchFound = None

   If (MutexLock(_iNearbyMutex))
      Int iIndex = _aoNearby.Length - 1
      While (!aMatchFound && (0 <= iIndex))
         Actor aActor = (_aoNearby[iIndex] As Actor)
         If (_aPlayer == aActor.GetCombatTarget())
            aMatchFound = aActor
         EndIf
         iIndex -= 1
      EndWhile

      MutexRelease(_iNearbyMutex)
   EndIf
   DebugTrace("TraceEvent GetPlayerInCombatWith: Done - " + Utility.GetCurrentRealTime())
   Return None
EndFunction


;----------------------------------------------------------------------------------------------
; API: Leash
; Leash target should be an in world object or an actor.
Function SetLeashTarget(ObjectReference oLeashTarget)
   _oLeashTarget = oLeashTarget
EndFunction

ObjectReference Function GetLeashTarget()
   Return _oLeashTarget
EndFunction

Function SetLeashLength(Int iLength)
   _iLeashLength = iLength
EndFunction

Int Function YankLeash(Float fDamageMultiplier=1.0, Int iOverrideLeashStyle=0, \
                       Bool bInterruptScene=True, Bool bInterruptLeashTarget=False, \
                       Bool bForceDamage=False)
   DebugTrace("TraceEvent YankLeash")
   ; Use a simplified mutex to make sure the leash isn't yanked twice at the same time.
   ; Also fail the request if there is no current leash target.
   If (_bYankingLeash || !_oLeashTarget)
      DebugTrace("TraceEvent YankLeash: Done (Busy/No Target)")
      Return FAIL
   EndIf
   _bYankingLeash = True

   ; If the player is locked in BDSM furniture she cannot be yanked with the leash.
   ; TODO: This should be an MCM setting to decide if she should be yanked from the furniture.
   If (GetBdsmFurniture() && _bIsFurnitureLocked)
      _bYankingLeash = False
      DebugTrace("TraceEvent YankLeash: Done (In Furniture)")
      Return WARNING
   EndIf

   ; If the player is AI driven she is being controlled by some mod.  Don't try to yank her
   ; leash if the user is not in control of her movements.
;   If (_aPlayer.IsAIEnabled())
;   If (!_aPlayer.GetPlayerControls())
;   If (Math.LogicalAnd(_qZbfPlayerSlot.iPlayerControlMask, 0x0001))
   zbfBondageShell qBondageShell = zbfBondageShell.GetApi()
   If (qBondageShell && qBondageShell.GetAiRef())
      _bYankingLeash = False
      DebugTrace("TraceEvent YankLeash: Done (AI)")
      Return WARNING
   EndIf

   ; If the player is in conversation with the leash target don't yank the leash.
   ; It would interrupt the conversation.
   Actor aLeashTarget = (_oLeashTarget As Actor)
   Actor aPlayerTalkingTo = GetPlayerTalkingTo()
   If (!bInterruptLeashTarget && aLeashTarget && (aLeashTarget == aPlayerTalkingTo))
      _bYankingLeash = False
      DebugTrace("TraceEvent YankLeash: Done (Conversation)")
      Return WARNING
   EndIf

   If (aPlayerTalkingTo && (aPlayerTalkingTo != _oLeashTarget))
      ; Moving the player to her own location will end the conversation.
      MovePlayer(_aPlayer)
   EndIf

   ; Keep track of whether there are movement issues with the leash (player hobbled, etc.).
   Bool bMovementIssues = (IsActor(_oLeashTarget) && \
                           (aLeashTarget.IsRunning() || aLeashTarget.IsSprinting() || \
                            _aPlayer.WornHasKeyword(_oKeywordZbfEffectNoMove) || \
                            _aPlayer.WornHasKeyword(_oKeywordZbfEffectSlowMove) || \
                            _aPlayer.GetActorValue("CarryWeight") < \
                               _aPlayer.GetTotalItemWeight()))

   ; Figure out which style of leash to use.
   Int iLeashStyle = _qMcm.iModLeashStyle
   Int iLeashLength = _iLeashLength
   If (_iMcmLeashMinLength && (_iMcmLeashMinLength > iLeashLength))
      iLeashLength = _iMcmLeashMinLength
   EndIf
   If (500 > iLeashLength)
      ; The dragging leash doesn't work with leash lengths of less than 500 units.
      ; By the time the player stands up she is being dragged again.
      iLeashStyle = LS_TELEPORT
   ElseIf (LS_AUTO == iLeashStyle)
      ; If the player is at low health use the teleport leash (a little safer).
      iLeashStyle = LS_DRAG
      If (bMovementIssues || (100 > _aPlayer.GetActorValue("Health")))
         iLeashStyle = LS_TELEPORT
      EndIf
   EndIf
   If (iOverrideLeashStyle)
      iLeashStyle = iOverrideLeashStyle
   EndIf

   If (LS_DRAG == iLeashStyle)
      ; While dragging the player via the leash make sure they are immune to damage.
      ; Otherwise getting stuck behind a rock would kill the player.
      _aPlayer.ModActorValue("DamageResist", 10000)

      Int iLoopCount = 19
      _oLeashTarget.PushActorAway(_aPlayer, -2)
      While ((1 == iLoopCount) || (75 < _oLeashTarget.GetDistance(_aPlayer)))
         _oLeashTarget.PushActorAway(_aPlayer, -2)

         If (!(iLoopCount % 5))
            Utility.Wait(0.1)
            _qDfwUtil.TeleportToward(_aPlayer, _oLeashTarget, 50)
         EndIf
         iLoopCount -= 1
      EndWhile

      _aPlayer.ForceRemoveRagdollFromWorld()
      _qDfwUtil.TeleportToward(_aPlayer, _oLeashTarget, 10)
      Utility.Wait(0.25)
      _aPlayer.StopTranslation()
      _aPlayer.PlayIdle(_oIdleStop_Loose)

      ; Reset the player's damage resistance.
      _aPlayer.ModActorValue("DamageResist", -10000)

      ; Do damage if there are no movement issues.  Otherwise just drag the player along.
      If (!bMovementIssues || bForceDamage)
         Float fDamage = ((_aPlayer.GetActorValue("Health") * _qMcm.iModLeashDamage / 100) + \
                          (_aPlayer.GetLevel() / 2))
         fDamage *= fDamageMultiplier
         _aPlayer.DamageActorValue("Health", fDamage)
      EndIf
   Else ; LS_TELEPORT
      ; Figure out how close to teleport the player to the target.  try not to set this maximum
      ; to less than 100 units so there is some space between her and the target.
      Float fTargetLength = ((iLeashLength As Float) / 1.75)
      If (100.0 > fTargetLength)
         fTargetLength = 100.0
      EndIf

      While (fTargetLength < _oLeashTarget.GetDistance(_aPlayer))
         _qDfwUtil.TeleportToward(_aPlayer, _oLeashTarget, 40)

         Utility.Wait(0.5)
      EndWhile
      ; Do damage if there are no movement issues.  Otherwise just drag the player along.
      If (!bMovementIssues || bForceDamage)
         Float fDamage = ((_aPlayer.GetActorValue("Health") * _qMcm.iModLeashDamage / \
                           100) + (_aPlayer.GetLevel() / 2))
         fDamage *= fDamageMultiplier
         _aPlayer.DamageActorValue("Health", fDamage)
      EndIf
   EndIf
   _bYankingLeash = False
   DebugTrace("TraceEvent YankLeash: Done")
   Return SUCCESS
EndFunction

; Waits for any yank leash in progress to complete before returning.
Int Function YankLeashWait(Int iTimeoutMs)
   DebugTrace("TraceEvent YankLeashWait")
   Bool bUseTimeout = (iTimeoutMs As Bool)

   While (_bYankingLeash)
      Utility.Wait(0.1)
      If (bUseTimeout)
         iTimeoutMs -= 100
         If (0 >= iTimeoutMs)
            DebugTrace("TraceEvent YankLeashWait: Done (Timed Out)")
            Return FAIL
         EndIf
      EndIf
   EndWhile
   DebugTrace("TraceEvent YankLeashWait: Done")
   Return SUCCESS
EndFunction


;----------------------------------------------------------------------------------------------
; API: NPC Disposition
Int Function GetActorAnger(Actor aActor, Int iMinValue=50, Int iMaxValue=50, \
                           Bool bCreateAsNeeded=False, Int iSignificant=0)
   Return IncActorAnger(aActor, 0, iMinValue, iMaxValue, bCreateAsNeeded, iSignificant)
EndFunction

Int Function IncActorAnger(Actor aActor, Int iDelta, Int iMinValue=50, Int iMaxValue=50, \
                           Bool bCreateAsNeeded=False, Int iSignificant=0)
   DebugTrace("TraceEvent IncActorAnger")
   Float fCurrTime = Utility.GetCurrentGameTime()
   Int iValue = 50
   If (MutexLock(_iKnownMutex))
      Int iIndex = _aoKnown.Find(aActor)
      If (-1 == iIndex)
         If (bCreateAsNeeded)
            ; If there are 30 known actors, trim the list.
            If (30 <= _aoKnown.Length)
               CleanupKnownList()
            EndIf

            iValue = Utility.RandomInt(iMinValue, iMaxValue) + iDelta

            _aoKnown           = _qDfwUtil.AddFormToArray(_aoKnown,            aActor,    True)
            _afKnownLastSeen   = _qDfwUtil.AddFloatToArray(_afKnownLastSeen,   fCurrTime, True)
            _aiKnownAnger      = _qDfwUtil.AddIntToArray(_aiKnownAnger,        iValue,    True)
            _aiKnownConfidence = _qDfwUtil.AddIntToArray(_aiKnownConfidence,   -1,        True)
            _aiKnownDominance  = _qDfwUtil.AddIntToArray(_aiKnownDominance,    -1,        True)
            _aiKnownInterest   = _qDfwUtil.AddIntToArray(_aiKnownInterest,     -1,        True)
            _aiKnownKindness   = _qDfwUtil.AddIntToArray(_aiKnownKindness,     -1,        True)
            _aiKnownSignificant = _qDfwUtil.AddIntToArray(_aiKnownSignificant, iSignificant, \
                                                          True)
         EndIf
      Else
         ; If this is a significant interaction make a note of it.
         _aiKnownSignificant[iIndex] = _aiKnownSignificant[iIndex] + iSignificant

         ; Keep track of when this NPC was last seen.
         _afKnownLastSeen[iIndex]  = fCurrTime

         ; Keep track of the disposition value to be returned.
         iValue = _aiKnownAnger[iIndex]

         If (-1 != iValue)
            ; Only try to modify the value if it starts within the min/max range.
            If ((iMinValue < iValue) && (iMaxValue > iValue))
               iValue += iDelta
               If (iMinValue > iValue)
                  iValue = iMinValue
               ElseIf (iMaxValue < iValue)
                  iValue = iMaxValue
               EndIf
               _aiKnownAnger[iIndex] = iValue
            EndIf
         ElseIf (-1 != iMinValue)
            ; If we have not evaluated the actor's disposition yet do so now.
            iValue = Utility.RandomInt(iMinValue, iMaxValue) + iDelta
            _aiKnownAnger[iIndex] = iValue
         EndIf
      EndIf

      MutexRelease(_iKnownMutex)
   EndIf
   DebugTrace("TraceEvent IncActorAnger: Done")
   Return iValue
EndFunction

Int Function GetActorConfidence(Actor aActor, Int iMinValue=50, Int iMaxValue=50, \
                                Bool bCreateAsNeeded=False, Int iSignificant=0)
   Return IncActorConfidence(aActor, 0, iMinValue, iMaxValue, bCreateAsNeeded, iSignificant)
EndFunction

Int Function IncActorConfidence(Actor aActor, Int iDelta, Int iMinValue=50, Int iMaxValue=50, \
                                Bool bCreateAsNeeded=False, Int iSignificant=0)
   Float fCurrTime = Utility.GetCurrentGameTime()
   Int iValue = 50
   If (MutexLock(_iKnownMutex))
      Int iIndex = _aoKnown.Find(aActor)
      If (-1 == iIndex)
         If (bCreateAsNeeded)
            ; If there are 30 known actors, trim the list.
            If (30 <= _aoKnown.Length)
               CleanupKnownList()
            EndIf

            iValue = Utility.RandomInt(iMinValue, iMaxValue) + iDelta

            _aoKnown           = _qDfwUtil.AddFormToArray(_aoKnown,            aActor,    True)
            _afKnownLastSeen   = _qDfwUtil.AddFloatToArray(_afKnownLastSeen,   fCurrTime, True)
            _aiKnownAnger      = _qDfwUtil.AddIntToArray(_aiKnownAnger,        -1,        True)
            _aiKnownConfidence = _qDfwUtil.AddIntToArray(_aiKnownConfidence,   iValue,    True)
            _aiKnownDominance  = _qDfwUtil.AddIntToArray(_aiKnownDominance,    -1,        True)
            _aiKnownInterest   = _qDfwUtil.AddIntToArray(_aiKnownInterest,     -1,        True)
            _aiKnownKindness   = _qDfwUtil.AddIntToArray(_aiKnownKindness,     -1,        True)
            _aiKnownSignificant = _qDfwUtil.AddIntToArray(_aiKnownSignificant, iSignificant, \
                                                          True)
         EndIf
      Else
         ; If this is a significant interaction make a note of it.
         _aiKnownSignificant[iIndex] = _aiKnownSignificant[iIndex] + iSignificant

         ; Keep track of when this NPC was last seen.
         _afKnownLastSeen[iIndex]  = fCurrTime

         ; Keep track of the disposition value to be returned.
         iValue = _aiKnownConfidence[iIndex]

         If (-1 != iValue)
            ; Only try to modify the value if it starts within the min/max range.
            If ((iMinValue < iValue) && (iMaxValue > iValue))
               iValue += iDelta
               If (iMinValue > iValue)
                  iValue = iMinValue
               ElseIf (iMaxValue < iValue)
                  iValue = iMaxValue
               EndIf
               _aiKnownConfidence[iIndex] = iValue
            EndIf
         ElseIf (-1 != iMinValue)
            ; If we have not evaluated the actor's disposition yet do so now.
            iValue = Utility.RandomInt(iMinValue, iMaxValue) + iDelta
            _aiKnownConfidence[iIndex] = iValue
         EndIf
      EndIf

      MutexRelease(_iKnownMutex)
   EndIf
   Return iValue
EndFunction

Int Function GetActorDominance(Actor aActor, Int iMinValue=50, Int iMaxValue=50, \
                               Bool bCreateAsNeeded=False, Int iSignificant=0)
   Return IncActorDominance(aActor, 0, iMinValue, iMaxValue, bCreateAsNeeded, iSignificant)
EndFunction

Int Function IncActorDominance(Actor aActor, Int iDelta, Int iMinValue=50, Int iMaxValue=50, \
                               Bool bCreateAsNeeded=False, Int iSignificant=0)
   Float fCurrTime = Utility.GetCurrentGameTime()
   Int iValue = 50
   If (MutexLock(_iKnownMutex))
      Int iIndex = _aoKnown.Find(aActor)
      If (-1 == iIndex)
         If (bCreateAsNeeded)
            ; If there are 30 known actors, trim the list.
            If (30 <= _aoKnown.Length)
               CleanupKnownList()
            EndIf

            iValue = Utility.RandomInt(iMinValue, iMaxValue) + iDelta

            _aoKnown           = _qDfwUtil.AddFormToArray(_aoKnown,            aActor,    True)
            _afKnownLastSeen   = _qDfwUtil.AddFloatToArray(_afKnownLastSeen,   fCurrTime, True)
            _aiKnownAnger      = _qDfwUtil.AddIntToArray(_aiKnownAnger,        -1,        True)
            _aiKnownConfidence = _qDfwUtil.AddIntToArray(_aiKnownConfidence,   -1,        True)
            _aiKnownDominance  = _qDfwUtil.AddIntToArray(_aiKnownDominance,    iValue,    True)
            _aiKnownInterest   = _qDfwUtil.AddIntToArray(_aiKnownInterest,     -1,        True)
            _aiKnownKindness   = _qDfwUtil.AddIntToArray(_aiKnownKindness,     -1,        True)
            _aiKnownSignificant = _qDfwUtil.AddIntToArray(_aiKnownSignificant, iSignificant, \
                                                          True)
         EndIf
      Else
         ; If this is a significant interaction make a note of it.
         _aiKnownSignificant[iIndex] = _aiKnownSignificant[iIndex] + iSignificant

         ; Keep track of when this NPC was last seen.
         _afKnownLastSeen[iIndex]  = fCurrTime

         ; Keep track of the disposition value to be returned.
         iValue = _aiKnownDominance[iIndex]

         If (-1 != iValue)
            ; Only try to modify the value if it starts within the min/max range.
            If ((iMinValue < iValue) && (iMaxValue > iValue))
               iValue += iDelta
               If (iMinValue > iValue)
                  iValue = iMinValue
               ElseIf (iMaxValue < iValue)
                  iValue = iMaxValue
               EndIf
               _aiKnownDominance[iIndex] = iValue
            EndIf
         ElseIf (-1 != iMinValue)
            ; If we have not evaluated the actor's disposition yet do so now.
            iValue = Utility.RandomInt(iMinValue, iMaxValue) + iDelta
            _aiKnownDominance[iIndex] = iValue
         EndIf
      EndIf

      MutexRelease(_iKnownMutex)
   EndIf
   Return iValue
EndFunction

Int Function GetActorInterest(Actor aActor, Int iMinValue=50, Int iMaxValue=50, \
                              Bool bCreateAsNeeded=False, Int iSignificant=0)
   Return IncActorInterest(aActor, 0, iMinValue, iMaxValue, bCreateAsNeeded, iSignificant)
EndFunction

Int Function IncActorInterest(Actor aActor, Int iDelta, Int iMinValue=50, Int iMaxValue=50, \
                              Bool bCreateAsNeeded=False, Int iSignificant=0)
   Float fCurrTime = Utility.GetCurrentGameTime()
   Int iValue = 50
   If (MutexLock(_iKnownMutex))
      Int iIndex = _aoKnown.Find(aActor)
      If (-1 == iIndex)
         If (bCreateAsNeeded)
            ; If there are 30 known actors, trim the list.
            If (30 <= _aoKnown.Length)
               CleanupKnownList()
            EndIf

            iValue = Utility.RandomInt(iMinValue, iMaxValue) + iDelta

            _aoKnown           = _qDfwUtil.AddFormToArray(_aoKnown,            aActor,    True)
            _afKnownLastSeen   = _qDfwUtil.AddFloatToArray(_afKnownLastSeen,   fCurrTime, True)
            _aiKnownAnger      = _qDfwUtil.AddIntToArray(_aiKnownAnger,        -1,        True)
            _aiKnownConfidence = _qDfwUtil.AddIntToArray(_aiKnownConfidence,   -1,        True)
            _aiKnownDominance  = _qDfwUtil.AddIntToArray(_aiKnownDominance,    -1,        True)
            _aiKnownInterest   = _qDfwUtil.AddIntToArray(_aiKnownInterest,     iValue,    True)
            _aiKnownKindness   = _qDfwUtil.AddIntToArray(_aiKnownKindness,     -1,        True)
            _aiKnownSignificant = _qDfwUtil.AddIntToArray(_aiKnownSignificant, iSignificant, \
                                                          True)
         EndIf
      Else
         ; If this is a significant interaction make a note of it.
         _aiKnownSignificant[iIndex] = _aiKnownSignificant[iIndex] + iSignificant

         ; Keep track of when this NPC was last seen.
         _afKnownLastSeen[iIndex]  = fCurrTime

         ; Keep track of the disposition value to be returned.
         iValue = _aiKnownInterest[iIndex]

         If (-1 != iValue)
            ; Only try to modify the value if it starts within the min/max range.
            If ((iMinValue < iValue) && (iMaxValue > iValue))
               iValue += iDelta
               If (iMinValue > iValue)
                  iValue = iMinValue
               ElseIf (iMaxValue < iValue)
                  iValue = iMaxValue
               EndIf
               _aiKnownInterest[iIndex] = iValue
            EndIf
         ElseIf (-1 != iMinValue)
            ; If we have not evaluated the actor's disposition yet do so now.
            iValue = Utility.RandomInt(iMinValue, iMaxValue) + iDelta
            _aiKnownInterest[iIndex] = iValue
         EndIf
      EndIf

      MutexRelease(_iKnownMutex)
   EndIf
   Return iValue
EndFunction

Int Function GetActorKindness(Actor aActor, Int iMinValue=50, Int iMaxValue=50, \
                              Bool bCreateAsNeeded=False, Int iSignificant=0)
   Return IncActorKindness(aActor, 0, iMinValue, iMaxValue, bCreateAsNeeded, iSignificant)
EndFunction

Int Function IncActorKindness(Actor aActor, Int iDelta, Int iMinValue=50, Int iMaxValue=50, \
                              Bool bCreateAsNeeded=False, Int iSignificant=0)
   Float fCurrTime = Utility.GetCurrentGameTime()
   Int iValue = 50
   If (MutexLock(_iKnownMutex))
      Int iIndex = _aoKnown.Find(aActor)
      If (-1 == iIndex)
         If (bCreateAsNeeded)
            ; If there are 30 known actors, trim the list.
            If (30 <= _aoKnown.Length)
               CleanupKnownList()
            EndIf

            iValue = Utility.RandomInt(iMinValue, iMaxValue) + iDelta

            _aoKnown           = _qDfwUtil.AddFormToArray(_aoKnown,            aActor,    True)
            _afKnownLastSeen   = _qDfwUtil.AddFloatToArray(_afKnownLastSeen,   fCurrTime, True)
            _aiKnownAnger      = _qDfwUtil.AddIntToArray(_aiKnownAnger,        -1,        True)
            _aiKnownConfidence = _qDfwUtil.AddIntToArray(_aiKnownConfidence,   -1,        True)
            _aiKnownDominance  = _qDfwUtil.AddIntToArray(_aiKnownDominance,    -1,        True)
            _aiKnownInterest   = _qDfwUtil.AddIntToArray(_aiKnownInterest,     -1,        True)
            _aiKnownKindness   = _qDfwUtil.AddIntToArray(_aiKnownKindness,     iValue,    True)
            _aiKnownSignificant = _qDfwUtil.AddIntToArray(_aiKnownSignificant, iSignificant, \
                                                          True)
         EndIf
      Else
         ; If this is a significant interaction make a note of it.
         _aiKnownSignificant[iIndex] = _aiKnownSignificant[iIndex] + iSignificant

         ; Keep track of when this NPC was last seen.
         _afKnownLastSeen[iIndex]  = fCurrTime

         ; Keep track of the disposition value to be returned.
         iValue = _aiKnownKindness[iIndex]

         If (-1 != iValue)
            ; Only try to modify the value if it starts within the min/max range.
            If ((iMinValue < iValue) && (iMaxValue > iValue))
               iValue += iDelta
               If (iMinValue > iValue)
                  iValue = iMinValue
               ElseIf (iMaxValue < iValue)
                  iValue = iMaxValue
               EndIf
               _aiKnownKindness[iIndex] = iValue
            EndIf
         ElseIf (-1 != iMinValue)
            ; If we have not evaluated the actor's disposition yet do so now.
            iValue = Utility.RandomInt(iMinValue, iMaxValue) + iDelta
            _aiKnownKindness[iIndex] = iValue
         EndIf
      EndIf

      MutexRelease(_iKnownMutex)
   EndIf
   Return iValue
EndFunction

; Returns how many times this actor has been flagged as "significant".
Int Function GetActorSignificance(Actor aActor)
   Int iValue = 0
   If (MutexLock(_iKnownMutex))
      Int iIndex = _aoKnown.Find(aActor)
      If (-1 != iIndex)
         iValue = _aiKnownSignificant[iIndex]
      EndIf
      MutexRelease(_iKnownMutex)
   EndIf
   Return iValue
EndFunction

Int Function GetActorWillingnessToHelp(Actor aActor, Bool bCreateAsNeeded=True)
   Int iAnger      = GetActorAnger(aActor,      20, 80, bCreateAsNeeded=bCreateAsNeeded)
   Int iConfidence = GetActorConfidence(aActor, 20, 80, bCreateAsNeeded=bCreateAsNeeded)
   Int iDominance  = GetActorDominance(aActor,  20, 80, bCreateAsNeeded=bCreateAsNeeded)
   Int iKindness   = GetActorKindness(aActor,   20, 80, bCreateAsNeeded=bCreateAsNeeded)

   ; Note: This calculation duplicates the same one in PrepareActorDialogue (for speed
   ; reasons).  If this calculation is modified the duplicate must be modified as well.
   Return ((iKindness * 40)          + ((100 - iAnger) * 25) + \
           ((100 - iDominance) * 20) + ((100 - iConfidence) * 15)) / 100
EndFunction

; Fills in all dialogue condition variables based on the actor specified.
Function PrepareActorDialogue(ObjectReference oActor)
   DebugTrace("TraceEvent PrepareActorDialogue")
   Actor aActor = (oActor As Actor)

   ; First set all variables that don't depend on the other actor.
   Log("Preparing Dialog: " + aActor.GetDisplayName(), DL_DEBUG, DC_GENERAL)
   _bIsPlayerBound           = IsPlayerBound(True)
   _bIsPlayerBoundVisible    = IsPlayerBound()
   _bIsPlayerFurnitureLocked = (_bIsFurnitureLocked && GetBdsmFurniture())
   _iNakedLevel              = _iNakedStatus

   ; Information regarding the last assault on the player.
   _bIsLastRapeAggressor = (aActor == _aLastAssaultActor)
   _fHoursSinceLastRape = (Utility.GetCurrentGameTime() - _fLastAssaultTime) * 24
   If ((0 > _fHoursSinceLastRape) || (4 < _fHoursSinceLastRape))
      _fHoursSinceLastRape = 0
   EndIf

   ; Then try to get actor information from the nearby actor list.
   Int iActorFlags = GetActorFlags(aActor)

   ; If the actor is not yet resgistered nearby wait until he is.
   _iDialogRetries -= 1
   If (!iActorFlags)
      DebugTrace("TraceEvent PrepareActorDialogue: Done (Not Nearby)")
      Return
   EndIf
   _iDialogRetries = _iMcmDialogueRetries + 1

   ; Identify this actor as the current dialogue target.
   If (_aCurrTarget)
      _aCurrTarget.RemoveFromFaction(_oFactionDfwDialogueTarget)
   EndIf
   _aCurrTarget = aActor
   aActor.AddToFaction(_oFactionDfwDialogueTarget)

   _bIsPlayersMaster    = ((aActor == GetMaster(MD_CLOSE)) || \
                           (aActor == GetMaster(MD_DISTANT)))
   _bIsPreviousMaster = False
   If (!_bIsPlayersMaster)
      _bIsPreviousMaster = (-1 != _aaPreviousMasters.Find(aActor))
   EndIf
   _bIsActorLeashHolder = (aActor == _oLeashTarget)
   _iActorAnger         = GetActorAnger(aActor,      20, 80, bCreateAsNeeded=True)
   _iActorArousal       = _qSexLabAroused.GetActorArousal(aActor)
   _iActorConfidence    = GetActorConfidence(aActor, 20, 80, bCreateAsNeeded=True)
   _iActorDominance     = GetActorDominance(aActor,  20, 80, bCreateAsNeeded=True)
   _iActorInterest      = GetActorInterest(aActor,   20, 80, bCreateAsNeeded=True)
   _iActorKindness      = GetActorKindness(aActor,   20, 80, bCreateAsNeeded=True)

   ; Note: This calculation duplicates the same one in GetActorWillingnessToHelp (for speed
   ; reasons).  If this calculation is modified the duplicate must be modified as well.
   _iWillingnessToHelp = ((_iActorKindness * 40) + \
                          ((100 - _iActorAnger) * 25) + \
                          ((100 - _iActorDominance) * 20) + \
                          ((100 - _iActorConfidence) * 15)) / 100

   _fActorDistance      = aActor.GetDistance(_aPlayer)
   _fMasterDistance     = 99999
   If (_aMasterClose)
      _fMasterDistance  = aActor.GetDistance(_aMasterClose)
   EndIf

   _bIsActorSlaver      = False
   _bIsActorOwner       = False
   _bIsActorDominant    = (50 <= _iActorDominance)
   _bIsActorSubmissive  = !_bIsActorDominant
   _bIsActorSlave       = (30 > _iActorDominance)

   _bCallingForAttention = ((0 < _iCallOutTimeout) && (2 == _iCallOutType))
   _bCallingForHelp      = ((0 < _iCallOutTimeout) && (1 == _iCallOutType))

   If (iActorFlags)
      _bIsActorSlaver     = (Math.LogicalAnd(iActorFlags, AF_SLAVE_TRADER) As Bool)
      _bIsActorOwner      = (Math.LogicalAnd(iActorFlags, AF_OWNER) As Bool)
      _bIsActorDominant   = (Math.LogicalAnd(iActorFlags, AF_DOMINANT) As Bool)
      _bIsActorSubmissive = (Math.LogicalAnd(iActorFlags, AF_SUBMISSIVE) As Bool)
      _bIsActorSlave      = (Math.LogicalAnd(iActorFlags, AF_SLAVE) As Bool)

      ; Some NPCs are more willing to help the player than others.
      If (Math.LogicalAnd(iActorFlags, AF_GUARDS))
         _iWillingnessToHelp += _iMcmDispWillingGuards
      EndIf
      If (Math.LogicalAnd(iActorFlags, AF_MERCHANTS))
         _iWillingnessToHelp += _iMcmDispWillingMerchants
      EndIf
      If (Math.LogicalAnd(iActorFlags, AF_BDSM_AWARE))
         _iWillingnessToHelp += _iMcmDispWillingBdsm
      EndIf
   EndIf

   ; Send out an even so other mods can set their own dialogue target information.
   Int iModEvent = ModEvent.Create("DFW_DialogueTarget")
   If (iModEvent)
      ModEvent.PushForm(iModEvent, oActor)
      If (!ModEvent.Send(iModEvent))
         Log("Failed to send Event DFW_DialogueTarget()", DL_ERROR, DC_GENERAL)
      EndIf
   EndIf

   DebugTrace("TraceEvent PrepareActorDialogue: Done")
EndFunction


;----------------------------------------------------------------------------------------------
; API: NPC Interactions
Function NpcMoveNearbyHidden(Actor aActor)
   DebugTrace("TraceEvent NpcMoveNearbyHidden")
   String szName = "None"
   If (aActor)
      szName = aActor.GetDisplayName()
   EndIf

   If (_qMcm.bModFadeInUseDoor && _aiLastDoorLocation[0])
      Int iDeltaX = _aiLastDoorLocation[0] - (_aPlayer.X As Int)
      Int iDeltaY = _aiLastDoorLocation[1] - (_aPlayer.Y As Int)
      Int iDeltaZ = _aiLastDoorLocation[2] - (_aPlayer.Z As Int)
DebugTrace("Player(" + (_aPlayer.X As Int) + "," + (_aPlayer.Y As Int) + "," + (_aPlayer.Z As Int) + ") " +\
           "Door(" + _aiLastDoorLocation[0] + "," + _aiLastDoorLocation[1] + "," + _aiLastDoorLocation[2] + ") " +\
           "Delta(" + iDeltaX + "," + iDeltaY + "," + iDeltaZ + ")")
      aActor.MoveTo(_aPlayer, iDeltaX, iDeltaY, iDeltaZ, False)

      ; Wait for a while to make sure the actor is loaded.
      Float fSecurity = 1.0
      While (0 < fSecurity)
         ; If the actor's 3D data is loaded consider it a success.  We are done.
         If (aActor.Is3DLoaded())
            DebugTrace("TraceEvent NpcMoveNearbyHidden: Done (Using Door)")
            Return
         EndIf
         Utility.Wait(0.1)
         fSecurity -= 0.1
      EndWhile
      DebugLog("NpcMoveNearbyHidden: Door failed.  Trying location.")
   EndIf

   Int iDistance = 10000
   While (iDistance)
      Log("Trying Distance: " + iDistance, DL_TRACE, DC_INTERACTION)
      ; Try to move the NPC to a distance away from the player.  Then wait a moment.
      ; If the NPC is falling he has not landed on a solid floor.  Try a different direction.
      ; First of all try directly forward.
      If (MoveNpcCheckForGround(aActor, iDistance, 0))
         iDistance = 0
      ; Then try forward with a slight offset.
      ElseIf (MoveNpcCheckForGround(aActor, iDistance, 250))
         iDistance = 0
      ElseIf (MoveNpcCheckForGround(aActor, iDistance, -250))
         iDistance = 0
      ; Next try backwards and then with a slight offset.
      ElseIf (MoveNpcCheckForGround(aActor, -iDistance, 0))
         iDistance = 0
      ElseIf (MoveNpcCheckForGround(aActor, -iDistance, 250))
         iDistance = 0
      ElseIf (MoveNpcCheckForGround(aActor, -iDistance, -250))
         iDistance = 0
      ; Then try to one side followed by a slight offset.
      ElseIf (MoveNpcCheckForGround(aActor, 0, iDistance))
         iDistance = 0
      ElseIf (MoveNpcCheckForGround(aActor, 250, iDistance))
         iDistance = 0
      ElseIf (MoveNpcCheckForGround(aActor, -250, iDistance))
         iDistance = 0
      ; Then try the other side followed by a slight offset.
      ElseIf (MoveNpcCheckForGround(aActor, 0, -iDistance))
         iDistance = 0
      ElseIf (MoveNpcCheckForGround(aActor, 250, -iDistance))
         iDistance = 0
      ElseIf (MoveNpcCheckForGround(aActor, -250, -iDistance))
         iDistance = 0
      EndIf

      ; If we failed all directions reduce the range.
      If (1000 < iDistance)
         iDistance -= 1000
         If (4000 < iDistance)
            iDistance -= 1000
         EndIf
      ElseIf (iDistance)
         iDistance -= 100
      EndIf
   EndWhile
   DebugTrace("TraceEvent NpcMoveNearbyHidden: Done")
EndFunction

; iMovementType: 0: Any (1-4).        1: Player Approach.  2: Move To Location.
;                3: Move To Object.   4: Hover At.         5: Clear Space.
Bool Function IsMoving(Actor aActor=None, String szModId="", Int iMovementType=0)
   If ((0 == iMovementType) || (1 == iMovementType))
      If ((aActor && (aActor == (_aAliasApproachPlayer.GetReference() As Actor))) || \
          (szModId && (szModId == _szApproachModId)))
         Return True
      EndIf
   EndIf
   If ((0 == iMovementType) || (2 == iMovementType))
      If ((aActor && (aActor == (_aAliasMoveToLocation.GetReference() As Actor))) || \
          (szModId && (szModId == _szMoveToLocationModId)))
         Return True
      EndIf
   EndIf
   If ((0 == iMovementType) || (3 == iMovementType))
      If ((aActor && (aActor == (_aAliasMoveToObject.GetReference() As Actor))) || \
          (szModId && (szModId == _szMoveToObjectModId)))
         Return True
      EndIf
   EndIf
   If ((0 == iMovementType) || (4 == iMovementType))
      Int iIndex
      While (iIndex < 3)
         If ((aActor && (aActor == (_aaAliasHover[iIndex].GetReference() As Actor))) || \
             (szModId && (szModId == _aszHoverAtModId[iIndex])))
            Return True
         EndIf

         iIndex += 1
      EndWhile
   EndIf
   If (5 == iMovementType)
      If ((aActor && ((aActor == (_aAliasGiveSpace1.GetReference() As Actor)) || \
                      (aActor == (_aAliasGiveSpace2.GetReference() As Actor)) || \
                      (aActor == (_aAliasGiveSpace3.GetReference() As Actor)))) || \
          (szModId && (szModId == _szGiveSpaceModId)))
         Return True
      EndIf
   EndIf
   Return False
EndFunction

; iSpeed: 2 Walk Fast  3 Jog  4 Run
Int Function ApproachPlayer(Actor aActor, Int iTimeoutSeconds, Int iSpeed, String szModId, \
                            Bool bForce=False)
   DebugTrace("TraceEvent ApproachPlayer")
   ; Don't start any movement packages if we are shutting down the mod.
   If (_bMcmShutdownMod)
      DebugTrace("TraceEvent ApproachPlayer: Done (Mod Shutting Down)")
      Return FAIL
   EndIf

   Int iReturnCode = SUCCESS

   ; Check if there already is an NPC approaching the player.
   Actor aApproachNpc = (_aAliasApproachPlayer.GetReference() As Actor)
   If (aApproachNpc)
      If (!bForce)
         ; If we are not told to override the current NPC fail the request.
         Log("Approach Failed (" + szModId + "): In use by " + _szApproachModId, DL_DEBUG, \
             DC_INTERACTION)
         DebugTrace("TraceEvent ApproachPlayer: Done (Busy)")
         Return FAIL
      EndIf
      iReturnCode = WARNING

      ; Otherwise send an event to report the current NPC approach failed.
      Int iModEvent = ModEvent.Create("DFW_MovementDone")
      If (iModEvent)
         ModEvent.PushInt(iModEvent, 1)
         ModEvent.PushForm(iModEvent, aApproachNpc)
         ModEvent.PushBool(iModEvent, False)
         ModEvent.PushString(iModEvent, _szApproachModId)
         If (!ModEvent.Send(iModEvent))
            Log("Failed to send Event DFW_MovementDone(1, False, " + _szApproachModId + ")", \
                DL_ERROR, DC_INTERACTION)
         EndIf
      EndIf
   EndIf

   ; If the NPC is nowhere nearby, bring him close by before starting the approach package.
   If (!aActor.Is3DLoaded() || (150000 < aActor.GetDistance(_aPlayer)))
      NpcMoveNearbyHidden(aActor)
   EndIf

   Log("ApproachPlayer (" + szModId + ")", DL_DEBUG, DC_INTERACTION)
   _szApproachModId = szModId
   _iApproachSpeed = iSpeed
   _aAliasApproachPlayer.ForceRefTo(aActor)
   aActor.EvaluatePackage()
   _iMonitorMoveTo = 3

   DebugTrace("TraceEvent ApproachPlayer: Done")
   Return iReturnCode
EndFunction

Int Function MoveToLocation(Actor aActor, Location oTarget, String szModId, Bool bForce=False)
   DebugTrace("TraceEvent MoveToLocation")
   ; Don't start any movement packages if we are shutting down the mod.
   If (_bMcmShutdownMod)
      DebugTrace("TraceEvent MoveToLocation: Done (Mod Shutting Down)")
      Return FAIL
   EndIf

   Int iReturnCode = SUCCESS

   ; Check if there already is an NPC performing the movement.
   Actor aMovingNpc = (_aAliasMoveToLocation.GetReference() As Actor)
   If (aMovingNpc)
      If (!bForce)
         ; If we are not told to override the current NPC fail the request.
         Log("MoveToLocation Failed (" + szModId + "): In use by " + _szMoveToLocationModId, \
             DL_DEBUG, DC_INTERACTION)
         DebugTrace("TraceEvent MoveToLocation: Done (Busy)")
         Return FAIL
      EndIf
      iReturnCode = WARNING

      ; Otherwise send an event to report the current NPC approach failed.
      Int iModEvent = ModEvent.Create("DFW_MovementDone")
      If (iModEvent)
         ModEvent.PushInt(iModEvent, 2)
         ModEvent.PushForm(iModEvent, aMovingNpc)
         ModEvent.PushBool(iModEvent, False)
         ModEvent.PushString(iModEvent, _szMoveToLocationModId)
         If (!ModEvent.Send(iModEvent))
            Log("Failed to send Event DFW_MovementDone(2, False, " + _szMoveToLocationModId + \
                ")", DL_ERROR, DC_INTERACTION)
         EndIf
      EndIf
   EndIf

   Log("MoveToLocation (" + szModId + ")", DL_DEBUG, DC_INTERACTION)
   _szMoveToLocationModId = szModId
   _aAliasLocationTarget.ForceLocationTo(oTarget)
   _aAliasMoveToLocation.ForceRefTo(aActor)
   _iMonitorMoveTo = 3

   ; If the NPC is already in the right location set a flag to verify that in our next update.
   ; We don't want to do it here in case the calling mod receives the event before we return
   ; from this function.
   If (oTarget == aActor.GetCurrentLocation())
      _iFlagCheckMoveTo = 3
   EndIf

   DebugTrace("TraceEvent MoveToLocation: Done")
   Return iReturnCode
EndFunction

Int Function MoveToObject(Actor aActor, ObjectReference oTarget, String szModId, \
                          Bool bForce=False)
   Return MoveToObjectHelper(aActor, oTarget, szModId, 75, bForce)
EndFunction

; This is the same as MoveToObject() but move the NPC closer to the target.
; It is created as a separate interface to maintain backwards compatibility.
Int Function MoveToObjectClose(Actor aActor, ObjectReference oTarget, String szModId, \
                               Int iDistance=25, Bool bForce=False)
   Return MoveToObjectHelper(aActor, oTarget, szModId, iDistance, bForce)
EndFunction

; This is simlar to the MoveToObject() feature with a couple of differences:
; The package does not stop when the NPC arrives.  It continues until cleared or it times out.
; Movement of the NPC is not monitored.  It should only be used for nearby objects.
; Timeout is in Real Time seconds.  If 0 it will continue until cleared.
Int Function HoverAt(Actor aActor, ObjectReference oTarget, String szModId, Int iTimeout=0, \
                     Bool bForce=False)
   ;Off-DebugTrace("TraceEvent HoverAt")
   ; Don't start any movement packages if we are shutting down the mod.
   If (_bMcmShutdownMod)
      ;Off-DebugTrace("TraceEvent HoverAt: Done Mod Shutting Down)")
      Return FAIL
   EndIf

   Int iReturnCode = SUCCESS

   ; Find an empty hover at alias.
   Int iIndex
   Actor aMovingNpc = (_aaAliasHover[iIndex].GetReference() As Actor)
   While (aMovingNpc && (iIndex < 2))
      iIndex += 1
      aMovingNpc = (_aaAliasHover[iIndex].GetReference() As Actor)
   EndWhile

   ; Check if all of the aliases are already in use.
   If (aMovingNpc)
      ; Use the first alias.  It is most likely to be closest to complete.
      iIndex = 0
      aMovingNpc = (_aaAliasHover[iIndex].GetReference() As Actor)

      If (!bForce)
         ; If we are not told to override the current NPC fail the request.
         Log("HoverAt Failed (" + szModId + "): In use by " + _aszHoverAtModId[iIndex], \
             DL_TRACE, DC_INTERACTION)
         ;Off-DebugTrace("TraceEvent HoverAt: Done (Busy)")
         Return FAIL
      EndIf
      iReturnCode = WARNING

      ; Otherwise send an event to report the current hover at package has ended.
      Int iModEvent = ModEvent.Create("DFW_MovementDone")
      If (iModEvent)
         ModEvent.PushInt(iModEvent, 4)
         ModEvent.PushForm(iModEvent, aMovingNpc)
         ModEvent.PushBool(iModEvent, False)
         ModEvent.PushString(iModEvent, _aszHoverAtModId[iIndex])
         If (!ModEvent.Send(iModEvent))
            Log("Failed to send Event DFW_MovementDone(4, False, " + \
                _aszHoverAtModId[iIndex] + ")", DL_ERROR, DC_INTERACTION)
         EndIf
      EndIf
   EndIf

   ; Convert the timeout from seconds into number of polls.
   _iHoverAtTimeout[iIndex] = 0
   If (iTimeout)
      _iHoverAtTimeout[iIndex] = ((iTimeout / _fMcmPollTime) As Int) + 1
   EndIf

   _aszHoverAtModId[iIndex] = szModId
   _aaAliasHoverTarget[iIndex].ForceRefTo(oTarget)
   _aaAliasHover[iIndex].ForceRefTo(aActor)

   ; If we are forcing the same actor to the same package be sure to re-calculate his package.
   If (aMovingNpc && (aMovingNpc == aActor))
      ReEvaluatePackage(aActor)
   EndIf
   ;Off-DebugTrace("TraceEvent HoverAt: Done")
   Return iReturnCode
EndFunction

Function HoverAtClear(String szModId)
   Int iIndex
   While (iIndex < 3)
      If (szModId == _aszHoverAtModId[iIndex])
         _iHoverAtTimeout[iIndex] = 0
         _aszHoverAtModId[iIndex] = ""
         _aaAliasHoverTarget[iIndex].Clear()
         _aaAliasHover[iIndex].Clear()
      EndIf

      iIndex += 1
   EndWhile
EndFunction

Int Function GiveSpace(Actor aActor, ObjectReference oTarget, String szModId, Int iTimeout=4, \
                       Bool bForce=False)
   ;Off-DebugTrace("TraceEvent GiveSpace")
   ; Don't start any movement packages if we are shutting down the mod.
   If (_bMcmShutdownMod)
      ;Off-DebugTrace("TraceEvent GiveSpace: Done Mod Shutting Down)")
      Return FAIL
   EndIf

   Int iReturnCode = SUCCESS

   ; Check if all of the give space aliases are in use.
   Actor aMovingNpc = (_aAliasGiveSpace1.GetReference() As Actor)
   Int iAlias = 1
   If (aMovingNpc)
      aMovingNpc = (_aAliasGiveSpace2.GetReference() As Actor)
      iAlias = 2
      If (aMovingNpc)
         aMovingNpc = (_aAliasGiveSpace3.GetReference() As Actor)
         iAlias = 3
      EndIf
   EndIf

   ; Consider failing the request if all of the aliases are in use.
   If (aMovingNpc)
      If (!bForce)
         ; If we are not told to override the current NPC fail the request.
         Log("GiveSpace Failed (" + szModId + "): In use by " + _szGiveSpaceModId, DL_TRACE, \
             DC_INTERACTION)
         ;Off-DebugTrace("TraceEvent GiveSpace: Done (Busy)")
         Return FAIL
      EndIf
      iReturnCode = WARNING

      ; Otherwise send an event to report the current give space package has ended.
      Int iModEvent = ModEvent.Create("DFW_MovementDone")
      If (iModEvent)
         ModEvent.PushInt(iModEvent, 5)
         ModEvent.PushForm(iModEvent, aMovingNpc)
         ModEvent.PushBool(iModEvent, False)
         ModEvent.PushString(iModEvent, _szGiveSpaceModId)
         If (!ModEvent.Send(iModEvent))
            Log("Failed to send Event DFW_MovementDone(5, False, " + _szGiveSpaceModId + ")", \
                DL_ERROR, DC_INTERACTION)
         EndIf
      EndIf
   EndIf

   ; Convert the timeout from seconds into number of polls.
   _iGiveSpaceTimeout = 0
   If (iTimeout)
      _iGiveSpaceTimeout = ((iTimeout / _fMcmPollTime) As Int) + 1
   EndIf

   _szGiveSpaceModId = szModId
   _aAliasGiveSpaceTarget.ForceRefTo(oTarget)
   If (1 == iAlias)
      _aAliasGiveSpace1.ForceRefTo(aActor)
   ElseIf (2 == iAlias)
      _aAliasGiveSpace2.ForceRefTo(aActor)
   Else
      _aAliasGiveSpace3.ForceRefTo(aActor)
   EndIf

   ; If we are forcing the same actor to the same package be sure to re-calculate his package.
   If (aMovingNpc && (aMovingNpc == aActor))
      ReEvaluatePackage(aActor)
   EndIf
   ;Off-DebugTrace("TraceEvent GiveSpace: Done")
   Return iReturnCode
EndFunction

Function GiveSpaceClear(String szModId)
   If (szModId != _szGiveSpaceModId)
      Return
   EndIf
   _iGiveSpaceTimeout = 0
   _szGiveSpaceModId = ""
   _aAliasGiveSpaceTarget.Clear()
   _aAliasGiveSpace1.Clear()
   _aAliasGiveSpace2.Clear()
   _aAliasGiveSpace3.Clear()
EndFunction

String Function GetApproachModId()
   Return _szApproachModId
EndFunction

String Function GetMoveToLocationModId()
   Return _szMoveToLocationModId
EndFunction

String Function GetMoveToObjectModId()
   Return _szMoveToObjectModId
EndFunction

String Function GetGiveSpaceModId()
   Return _szGiveSpaceModId
EndFunction

; This function prevents multiple mods from handling a DFW_CallForHelp event.  Only handle the
; event if you call this function and it returns true.  If it returns false the event has
; already been handled by another mod.
; Upon receiving the event you should delay for a random time between 0 and 0.5 seconds which
; will allow different mods to respond to call for help events if able.
Bool Function HandleCallForHelp()
   If ((1 == _iCallOutType) && (0 < _iCallOutResponse))
      _iCallOutResponse = 0
      Return True
   EndIf
   Return False
EndFunction

; This function prevents multiple mods from handling a DFW_CallForAttention event.  Only handle
; the event if you call this function and it returns true.  If it returns false the event has
; already been handled by another mod.
; Upon receiving the event you should delay for a random time between 0 and 0.5 seconds which
; will allow different mods to respond to call for attention events if able.
Bool Function HandleCallForAttention()
   If ((2 == _iCallOutType) && (0 < _iCallOutResponse))
      _iCallOutResponse = 0
      Return True
   EndIf
   Return False
EndFunction

; Indicates if a callout was made recently.
Bool Function WasCallOutRecent(Bool bAttention=True, Bool bHelp=True)
   Return ((bAttention && _bCallingForAttention) || (bHelp && _bCallingForHelp) || \
           _iCallOutTimeout)
EndFunction

; Indicates the call for help or attention has been handled and should no longer be considered
; in progress.
Function CallOutDone()
   _iCallOutType = 0
   _iCallOutResponse = 0
   _bCallingForAttention = False
   _bCallingForHelp      = False
EndFunction

; Resets the timeout for the player calling out.  This is intended for when the player is
; calling out/protesting during a scene.  By resetting the timeout we can detect if the player
; continues protesting or not.
Function CallOutReset()
   _iCallOutTimeout = 0
EndFunction

; Forces an actor to re-evaluate his AI package by forcing him into an alias and then removing
; him, thereby changing his package stack.  A dedicated alias should really be used for this
; but for now we will rely on one of our current aliases being available.
Function ReEvaluatePackage(Actor aActor)
   If (_aAliasApproachPlayer.ForceRefIfEmpty(aActor))
      _aAliasApproachPlayer.Clear()
   ElseIf (_aAliasMoveToLocation.ForceRefIfEmpty(aActor))
      _aAliasMoveToLocation.Clear()
   ElseIf (_aAliasMoveToObject.ForceRefIfEmpty(aActor))
      _aAliasMoveToObject.Clear()
   ElseIf (_aaAliasHover[0].ForceRefIfEmpty(aActor))
      _aaAliasHover[0].Clear()
   ElseIf (_aaAliasHover[1].ForceRefIfEmpty(aActor))
      _aaAliasHover[1].Clear()
   ElseIf (_aaAliasHover[2].ForceRefIfEmpty(aActor))
      _aaAliasHover[2].Clear()
   EndIf
   aActor.EvaluatePackage()
EndFunction

Function TransferItemsProcessItem(Form oItem=None, Int iCount=0, Bool bSilent=True)
   ; Check for invalid items, gold and restraints.
   If (!oItem || (_oGold == oItem) || (_oZazRestraintHider == oItem) || \
       (_oZbfRestraintHider == oItem) || oItem.HasKeyword(_oKeywordZadInventoryDevice) || \
        oItem.HasKeyword(_oKeywordZadLockable) || oItem.HasKeyword(_oKeywordZbfWornDevice))
      Return
   EndIf

   ; TODO: Ignore any items that are worn.

   ; Make sure we know how many items to process.
   If (!iCount)
      iCount = _aPlayer.GetItemCount(oItem)
   EndIf

   If (_oLockpick == oItem)
      ; Dispose of any lock picks the player may have.
      _aPlayer.RemoveItem(oItem, iCount, abSilent=bSilent)
      Return
   EndIf

   ; Handle keys and no sale items separately.
   If (oItem.HasKeyword(_oKeywordVendorNoSale) || oItem.HasKeyword(_oKeywordVendorItemKey))
      ObjectReference oChest = _oCollectorsSpecialChest
      If ((_oDeviousKeyChastity == oItem) || (_oDeviousKeyPiercings == oItem) || \
          (_oDeviousKeyRestraints == oItem) || (_oFtmChastityKey == oItem) || \
          (_oFtmRestraintKey == oItem) || (_oFtmPiercingTool == oItem) || \
          (_oDclKeyBody == oItem) || (_oDclKeyHand == oItem) || \
          (_oDclKeyHead == oItem) || (_oDclKeyHighSecurity == oItem) || \
          (_oDclKeyLeg == oItem))
         ; Restraint keys should be disposed of.
         oChest = None
      EndIf
      _aPlayer.RemoveItem(oItem, iCount, akOtherContainer=oChest, abSilent=bSilent)
      Return
   EndIf

   ; Regular items (Anything remaining) go to the new items chest.
   _aPlayer.RemoveItem(oItem, iCount, akOtherContainer=_oCollectorsNewItemChest, \
                       abSilent=bSilent)
EndFunction

; WARNING: This function only handles quest items correctly when oItem is set to None and all
;          of the player's items are transferred to the collector.
; Transfers items to The Collector's New Items chests.
;  - Gold and worn items are left alone.
;  - Unworn BDSM items are disposed of.
;  - Keys and no-sale items are moved directly into the Special Items chest.
;  - Others are moved to the New Items chest where they will be shearched for quest items later.
; oItem: If set to None all of the player's items will be processed.
; iCount: If set to 0 all of the specified items in the player's inventory will be transferred.
; bSilent: If oItem is set to None all items will be transferred silently regardless of this.
Function TransferItems(Form oItem=None, Int iCount=0, Bool bSilent=True)
   If (!oItem)
      Int iIndex = _aPlayer.GetNumItems() - 1
      Log("Moving " + (iIndex + 1) + " items.", DL_CRIT, DC_GENERAL)
      While (0 <= iIndex)
         oItem = _aPlayer.GetNthForm(iIndex)

Int iKeywordIndex = oItem.GetNumKeywords() - 1
String szDisplayString = "Moving " + (iIndex + 1) + ": 0x" + _qDfwUtil.ConvertHexToString(oItem.GetFormId(), 8) + " - " + oItem.GetName() + "\n"
While (0 <= iKeywordIndex)
   szDisplayString += iKeywordIndex + "-" + oItem.GetNthKeyword(iKeywordIndex) + "\n"
   iKeywordIndex -= 1
EndWhile
Debug.Trace(szDisplayString)

         ; Use a helper function to process each item.
         TransferItemsProcessItem(oItem, iCount, bSilent)

         iIndex -= 1
      EndWhile
      Log("Done moving items.", DL_CRIT, DC_GENERAL)
      Return
   EndIf

   ; Use a helper function to process the item.
   TransferItemsProcessItem(oItem, iCount, bSilent)
EndFunction

;Function CheckForQuestItems()
;The basic idea is:
;   Maybe fade out the screen so the user doesn't see what is going on?
;   Move all of the player's items to a temporary player item chest.
;   Move all items from the new items chest into the player's inventory where they can be
;      affected by the quest item related function.
;   Run the quest item related function to move all non quest items to the merchant chest.
;      _aPlayer.RemoveAllItems(akTransferTo=_oCollectorsNewItemChest, abRemoveQuestItems=False)
;   Move all remaining (quest) items to the collector's special items chest.
;EndFunction
