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
; Exclusive Dialogue Branches must be used with care.  An Exclusive Dialogue becomes the
; "active" dialogue until the NPC "says a line of dialogue from a non-Exclusive branch".
; Exclusive Dialogues are also reset when the conversation ends but there are common conditions
; when a dialogue does not end properly.  I suspect this problem only happens when dialogue
; is selected (i.e. the player does not walk away) and possibly only when the selected response
; has multiple lines of text.
; See https://www.creationkit.com/index.php?title=Dialogue_Branch section Exclusive Branches.
;
; TODO: Use a script called "ObjectUtil.psc" to replce default animaitons (such as replacing
; the default idle with crawling).  See the Sanguine Debauchery+ _sdqs_fcts_constraints script
; for examples of this.  We also need to figure out what this "ObjectUtil.psc" is, where it
; comes from and what the implications are of our using it.
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
String S_NONE = "None"

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

; Empty (None) arrays of different types.
Bool[]   _abNone
Float[]  _afNone
Form[]   _aoNone
String[] _aszNone

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

; A reference to SexLab and SexLab Aroused Framework quest scripts.
SexLabFramework _qSexLab
slaFrameworkScr _qSexLabAroused

; A reference to the ZAZ Animation Pack (ZBF) slave control APIs.
zbfBondageShell _qZbfShell
zbfSlaveControl _qZbfSlave
zbfSlaveActions _qZbfSlaveActions
; Note: This is a reference alias.  Not a quest.
zbfSlot _qZbfPlayerSlot

; A reference to the Devious Devices quest, Zadlibs.
Zadlibs _qZadLibs
zadHeavyBondageQuestScript _qZadArmbinder

; Basic game objects.
MiscObject _oGold
Potion _oVigorousHealing
Form[] _aoIngredientList
Int[] _aoIngredientPrices

; TODO: -1: Any item is allowed.
; -2: User created potion.
Int[] _aoRecipeItemId
Int[] _aiIngredientArray
Int[] _aiRecipeFirstItem
Int[] _aiRecipeLastItem
; These arrays are larger than Papyrus' 128 element limit.  The data must be kept in two arrays.
Int[] _aiRecipeIngredient0
Int[] _aiRecipeQuantity0
Int[] _aiRecipeIngredient1
Int[] _aiRecipeQuantity1

Perk[] _aoSetRequiredPerk
Int[] _aoSetFirstItem
Int[] _aoSetLastItem


; Skill Perks
Perk _oPerkSmithDragon
Perk _oPerkSmithDaedric
Perk _oPerkSmithGlass
Perk _oPerkSmithEbony
Perk _oPerkSmithElven
Perk _oPerkSmithOrcish
Perk _oPerkSmithSteel


;*** Keywords ***
; Non-specific primary devious device keywords.
Keyword _oKeywordZbfWornDevice

; A list of all ZAD keywords used to identify the type of device.
Keyword[] _aoZadDeviceKeyword


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
Armor[] _aoMittens

; Lists of favourite furniture, their types, locations, and parameters.
Int _iFavouriteFurnitureMutex
Form[] _aoFavouriteFurniture
Form[] _aoFavouriteCell
Form[] _aoFavouriteLocation
Form[] _aoFavouriteRegion
; 0x0001: BDSM Furniture
; 0x0002: Cage
; 0x0004: Bed
; 0x0008: Work Furniture
; 0x0010: Store
; 0x0020: Public
; 0x0040: Private
; 0x0080: Remote
; 0x0100: Activity/Sandbox (NPCs can sandbox nearby)
; 0x0200: Milking Furniture
; 0x0400: Default Closed (Cage doors that start closed)
; 0x0800: Dangerous (Needs to be well equiped before travelling to it).
; 0x1000: Grain Mill
; 0x2000: Forge
; 0x4000: Enchanting Table
; 0x8000: Alchemy Table
Int[]   _aiFavouriteFlags
Float[] _afFavouriteCageLocations
Form[]  _aoFavouriteCageLevers

; Lists of different Simple Slavery slave auction sites.
Location[] _aoSimpleSlaveryRegion
Location[] _aoSimpleSlaveryLocation
ObjectReference[] _aoSimpleSlaveryEntranceObject

; Internal objects in the simple slavery auction house.
ObjectReference _oSimpleSlaveryInternalDoor
Actor _aSimpleSlaveryAuctioneer

; Quest Alias References.
; TODO: These first two should be filled using GetAlias(iAliasId).
ReferenceAlias Property _aAliasLeashHolder     Auto
ReferenceAlias Property _aAliasLastLeashHolder Auto
ReferenceAlias _aAliasPlayer
ReferenceAlias _aAliasFurnitureLocker
ReferenceAlias _aAliasQuestActor1
ReferenceAlias _aAliasQuestActor2
ReferenceAlias _aAliasQuestActor3
ReferenceAlias _aAliasPlayerActor

; A crime faction for the leash target so he can be protected if the player assaults him.
Faction _oFactionLeashTargetCrime

; Variables to indicate if one time actions have been completed.
; 0 = No weapons stolen.  1 = Equipped weapons stolen.  2 = All weapons stolen.
Int _iWeaponsStolen Conditional
Int _iGoldStolen
; All the player's items sold to a vendor.
Bool _bAllItemsTaken
; We have at least tried to remove restraints from other mods from the player.
Bool _bOtherRestraintsRemoved

; This keeps track of the scene/activity being run by the mod.
;  1: Transfer Furniture.
;  2: Release the player.
;  3: Sell the player's items.
;  4: Assault the player.
;  5: Milk the player (Milk Maid Economy).
;  6: Ask the blacksmith to remove restraints from other mods.
;  7: Return to the leash game.
;  8: Whip the Player.
;  9: Start Furniture Punishment.
; 10: Proposition the slaver for sex.
; 11: Force the player to craft armour.
; 12: Force the player to enchant armour.
; 13: Force the player to craft healing potions.
Int _iCurrSceneMutex
Bool _bSceneThreadControl
Int _iCurrScene Conditional
Int _iCurrSceneStage Conditional
Actor _aCurrSceneAgressor
Int _iCurrSceneTimeout
String _szCurrSceneName
Bool[]   _abCurrSceneParameter
Float[]  _afCurrSceneParameter
Form[]   _aoCurrSceneParameter
String[] _aszCurrSceneParameter
Bool _bSceneReadyToEnd
; The last scene stage can be used to detect when we enter a stage for the first time.
Int _iLastSceneStage
Int _iLastModuleStage

; Scene modules.  These are like subroutines that can be used in any scene.
; Since only one of them can be active at any time they do not need data protection.
; 1: Leash the player to an object.
; 2: Secure player for being left.
; 3: Move to the player for a conversation.
; 4: Move to an object.
Int _iSceneModule
Int _iSceneModuleStage
Bool[]   _abSceneModuleParameter
Float[]  _afSceneModuleParameter
Form[]   _aoSceneModuleParameter
String[] _aszSceneModuleParameter
; Remember to reset the output before each use.
Int _iSceneModuleOutput

; This is the short term goal of the leash holder.
; What he is trying to accomplish via dialogue or his own actions.
; <0: Delay after last goal       0: No goal                 1: Diarm player
;  2: Undress player (armour)     3: Take player weapons     4: Lock player's hands
;  5: Undress player fully        6: Gag player              7: Walk behind the slaver
;  8: Restrain the player         9: Reel in the Player     10: Discipline Talking Escape
; 11: Unused                     12: Approach for Interest  13: Lying About Release
; 14: Punish Removing Restraints
Int _iAgendaShortTerm Conditional

; 0: No particular agenda.
; 1: Take a break (Sandbox)
; 2: Dominate the player and make sure she is secure
Int _iAgendaMidTerm Conditional

; TODO: Distinguish between long term agendas and permanent agendas.  We need another level.

; 0: Player is not controlled
; 1: Keep the player with no particular agenda
; 2: -Unused-
; 3: Punish the player
; 4: Transfer the player from one form of control to another
; 5: Release the player or prepare her for release
Int _iAgendaLongTerm Conditional

; The meaning of the details depend on the value of the long term agenda.
; AgendaLongTerm 4: 1: Transfer to BDSM furniture.
; AgendaLongTerm 4: 2: Transfer to the Simple Slavery auction house.
Int _iDetailsLongTerm Conditional

; This should really be part of the long term agenda but the long term agenda is being used as
; short term agendas for now (punish the player) which would reset the permanency status so keep
; it separate for now.
Bool _bPermanency Conditional

; The hour of our last event check.
Int _iEventCheckLastHour

; A list of pending actions that we are waiting to happen.
; See AddPendingAction() (Unique Tag: AddPendingActionFunction) for details.
Int _iPendingActionMutex
   Int[] _aiPendingAction
  Form[] _aoPendingActor
   Int[] _aiPendingDetails
 Float[] _afPendingDetails
String[] _aszPendingScene
   Int[] _aiPendingTimeout

; Keep track of everything the player is being punished for.
; 0x0001 = Talking of Escape
; 0x0002 = Not Accepting her slavery
Int _iPunishments

;----------------------------------------------------------------------------------------------
; Conditional state variables related to the leash game used by the quest dialogues.
; The number of polls (give or take) the player has refused to cooperate with the current goal.
Int _iLeashGoalRefusalCount Conditional

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

; Keep track of whether the leash holder is moving or has stopped.
; 0-2: Leash Holder Current/Last Known Position [X,Y,Z]
Int[] _aiLeashHolderCurrPos
Int _iLeashHolderMoving
Int _iLeashHolderStationary
Bool _bLeashHolderStopped

; Keep track of how long the player's Master will sandboxing for (or when the next one starts).
Float _fMasterSandboxTime
Bool _bMasterSandboxIsSitting

; Has the player re-equipped her weapons after they were put away.
Bool _bReequipWeapons

; Is the leash holder upset enough to allow the player to be enslaved.
Bool _bIsEnslaveAllowed

; Is the leash holder in combat.
Bool _bIsInCombat

; Is the leash holder attempting to engage the player in one of our dialogues.
Int _iDialogueBusy
Actor _aDialogueTarget

; When movement is blocked this counts down and restores movement in case something goes wrong.
Int _iMovementSafety

; How often the player has been caught walking in front of the leash holder.
Int _iCurrWalkInFrontCount
Int _iTotalWalkInFrontCount

; How often the player has said something particularly annoying to the leash holder.
Int _iVerbalAnnoyance Conditional
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
Int _iCrawlRemaining Conditional

; Times are in real seconds.
Float _fTimeEnslaved Conditional
; TODO: Fix this.  This value is recorded incorrectly!
Float _fTimePunished Conditional
Float _fTimeLastPunished

;  0 -  9: Untrained
; 10 - 24: New Slave
; 25 - 49: Obedient and Respectful
; 50 - 74: Docile, Eager, Willing, and Always Controlled
; 75 - 99: Always a Perfect Slave.  Fully Controlled.
; 100: Permanent Slavery.
Float _fTrainingLevel Conditional

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
Armor _oMittens

; Keeps track of actions that should be taken during an assault:
; 0x0001: Strip
; 0x0002: Gag
; 0x0004: Bind Arms (implies Unbind Mittens)
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
; 0x8000: Unbind Boots
; 0x00010000: Restrain in Bondage Mittens (implies Unbind Arms)
; 0x00020000: Release from Bondage Mittens
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

; Some variables to reduce or temporary stop the leash game from re-starting.
Int _iLeashGameCooldown
Int _iLeashGameReduction
Float _fLeashCoolDownStart
Float _fLeashCoolDownTotal

; An excuse or made up scenario to justify the player being enslaved.
; 1: The player is a bandit and has been captured to pay for her crimes.
; 2: The player is an enemy in the war and has been captured to pay for her crimes.
; 3: The player's spouse is an enemy in the war.  She is being held to convince him to quit.
; 4: The player has voluntarily been asked to be enslaved.
; 5: The player was so helpless in bondage the slaver deemed she could not take care of herself.
Int _iLeashGameExcuse Conditional

; Keep track of which BDSM furniture the player is sitting in when we begin messing with her.
ObjectReference _oBdsmFurniture

; The reasons (made up or otherwise) the player is locked in furniture.
; 1: Self inflicted.  The player entered the furniture of her own accord.
; 2: The player is being punished for bad behaviour.
; 3: The player's controller/owner simply wants her locked up in furniture.
; 4: Work.
; 5: Public display.
; 6: Available for sale.
Int _iFurnitureExcuse Conditional

; A timer for keeping the player locked in BDSM furniture for a little while.
Float _fFurnitureReleaseTime Conditional

; Keeps track of whether the BDSM furniture is randomly locked.
Bool _bFurnitureForFun Conditional
Bool _bIsPlayerCaged

; Keeps track of whether the player is being kept in a remote, secluded area.
Bool _bIsPlayerRemote Conditional

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

; A numeric ID for the dialogue we are expecting the player to be in.
; This dialogue can progress in stages, synchronizing the script with the Creation Kit.
; The path is generally a random number between 1 and 100 which can be used to add a random
; element to each dialogue stage allowing random responses to mach with previous dialogue.
;  1: Discipline - CallOut
;  2: Discipline - Misbehaving while selling items (_dfwsDisciplineSellItems).
;  3: Start the leash game: Would you like to leash me?
;     0: Saying Hello.  1: Committed to admitting (dominant personality).
;     2: Admission to bad behaviour.
;  4: Introduction to the leash game: What is going on?
;     0: Asking what is going on.  1: After being told about the leash game.
;     99: The player needs to be punished at the end of the dialogue.
;     Path=101: The player has been warned about watching her speech.
;  5: Milking the player scene.
;     Stages are determined by the scene (_iCurrSceneStage).
;  6: Remove Restraint Scene Blacksmith Dialogues.
;  7: Order the player to crawl.
;  8: Order the player to kneel.
;  9: Order the player to spread her knees.
; 10: Order the player to come.
; 11: Player touching herself without permission.
; 12: Player removed her arm binder.
; 13: Order the player to turn around.
; 14: Ask the player if she will behave.
; 15: Tell the player to think about her behaviour.
; 16: Beckon the player to come along.
; 17: Thank the player for crafting a required item.
; 18: Discipline the player for picking up contraban.
; 19: Crafting Instructions.
Int _iCurrDialogue      Conditional
; Stage: {99, 98, ...} represent things to happen at the end of the dialogue.
Int _iCurrDialogueStage Conditional
Int _iCurrDialoguePath  Conditional
Int _iCurrDialogueResults
Actor _aCurrDialogueTarget
; A flag to indicate the scripts are being called to end the current dialogue.
Bool _bCurrDialogueEnding

; Flags to keep track of when occasional dialogues are available.
Bool _bDialogueFirstEnslaved   Conditional
; Only valid at 1 to give a delay before the dialogue becomes available.
Int  _iDialogueFurnitureLocked Conditional

; A delay between checks to verify the player is crawling.
Int _iResistCrawlCount

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
; Variables related to equipping the slaver in better gear.
Perk _oEquipForgePerk
Int _iEquipEnchantLevel
Int _iEquipPotionLevel

Int _iLeashHolderWealth

Bool _bLeashHolderOutfitActive
Outfit _oLeashHolderOutfit
LeveledItem _oLeashHolderOutfitContents

Actor _aContrabanMonitor
; 0x0001: Whip the player.
; 0x0002: Sternly warn the player.
; 0x0004: Force the player to stand.
; 0x8000: Take contraban.
Int _iContrabanFlags
; 0x0001: Equip allowed items.
; 0x0002: Compliment the player.
; 0x0004: Force the player to stand.
; 0x8000: Take allowed items.
Int _iAllowdItemsFlags
Form[] _aoContraban
Int[] _aiAllowedItems
Int[] _aiAllowedQuantity

;----------

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
Float _fMcmFurnitureRemoteVisitor
Float _fMcmLeashGameChance
Float _fMcmEventProposition
Float _fMcmPollTime
Float _fMcmEventMilkScene
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
Int _iMcmEventPropArousal
;----------

;----------------------------------------------------------------------------------------------
; Mod Compatibility.
; Milk Mod Economy.  Some effort is needed to make sure scenes run smoothly.
Spell _oMmeBeingMilkedSpell
Bool _bMmeSuppressed

; SexLab Cooldown:  After a SexLab sex scene the actors are considered available for sex right
; away (via IsActorActive()) but SexLab still hasn't finished cleaning up the scene.  If you
; start a new scene right away the actors will be considered active for the new scene but clean
; up of the first scene will then clear this flag indicating the actors are available for sex
; even though they are still involved in the next scene.  Use a cooldown to make sure no new sex
; scene starts until the previous scene has completed.
Float _fSexLabCooldown
;----------


;***********************************************************************************************
;***                                    INITIALIZATION                                       ***
;***********************************************************************************************
; A new game has started, this script was added to an existing game, or the script was reset.
Event OnInit()
   DebugTrace("TraceEvent OnInit")
   ; Default the logging level to trace until we can contact the MCM script.
   _iMcmLogLevel = 5

   ; Delay before starting the mod.  This should give the MCM script time to initialize.
   Debug.Trace("[" + S_MOD + "] Script Initialized.")
   RegisterForSingleUpdate(15)
   DebugTrace("TraceEvent OnInit: Done")
EndEvent

; This is called once by the MCM script to initialize the mod and then on each update poll.
; This function is primarily to ensure new variables are initialized for new script versions.
Function UpdateScript()
   DebugTrace("TraceEvent UpdateScript")
   ; Reset the version number.
   If (1.08 < _fCurrVer)
      _fCurrVer = 1.08
   EndIf

   ; If the script is at the current version we are done.
   Float fScriptVer = 1.09
   If (fScriptVer == _fCurrVer)
      DebugTrace("TraceEvent UpdateScript: Done (Latest Version)")
      Return
   EndIf
   Log("Updating Script " + _fCurrVer + " => " + fScriptVer, DL_CRIT, S_MOD)

   ; When releasing the greeting dialogues (Version 2 of the mod) the script versions
   ; were all advanced to version 1.00.
   If (1.00 > _fCurrVer)
      ; Initialize basic variables.
      _aPlayer = Game.GetPlayer()
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
      If (MutexLock(_iFavouriteFurnitureMutex))
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

         MutexRelease(_iFavouriteFurnitureMutex)
      EndIf
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
         _iAgendaLongTerm = 1
         _iDetailsLongTerm = 0
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
      Utility.Wait(20.0)

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

   If (1.06 > _fCurrVer)
      _aiLeashHolderCurrPos = New Int[3]
   EndIf

   If (1.07 > _fCurrVer)
      Int[] aiTempFlags
      Int iIndex
      If (MutexLock(_iFavouriteFurnitureMutex))
      Int iTotalFurniture = _aoFavouriteFurniture.Length
         While (iIndex < iTotalFurniture)
            aiTempFlags = _qDfwUtil.AddIntToArray(aiTempFlags, 0x0001)
            iIndex += 1
         EndWhile
         _aiFavouriteFlags = aiTempFlags

         MutexRelease(_iFavouriteFurnitureMutex)
      EndIf
   EndIf

   If (1.08 > _fCurrVer)
      ; We need a mutex to access to current sceen information.
      _iCurrSceneMutex = iMutexCreate("DFWS Scenes")
      _iFavouriteFurnitureMutex = iMutexCreate("DFWS Furniture")
   EndIf

   If (1.09 > _fCurrVer)
If (!_aAliasQuestActor1)
      _aAliasQuestActor1 = (GetAlias(6) As ReferenceAlias)
      _aAliasQuestActor2 = (GetAlias(8) As ReferenceAlias)
      _aAliasQuestActor3 = (GetAlias(7) As ReferenceAlias)
EndIf
If (!_aAliasPlayerActor)
      _aAliasPlayerActor = (GetAlias(9) As ReferenceAlias)

      ; Make sure the player actor alias is filled with the correct reference.
      ; This will not happen automatically if the quest has already started.
      Actor aPlayerActor = (Game.GetFormFromFile(0x0002C70C, "DfwSupport.esp") As Actor)
      _aAliasPlayerActor.ForceRefTo(aPlayerActor)
PrepPlayerActorForScene()
EndIf

      ; If the leash game is already underway make sure these variables are set.
If (!_iLeashGameExcuse)
      If (_iLeashGameDuration)
         _iLeashGameExcuse = LeashGameFindExcuse(_aLeashHolder)
         _bDialogueFirstEnslaved = True
      EndIf
EndIf
      ; If the player is locked in furniture make sure that dialogue is available.
If (!_iFurnitureExcuse)
      If (_oBdsmFurniture)
         If (!_iDialogueFurnitureLocked)
            _iDialogueFurnitureLocked = ((300 / _fMcmPollTime) As Int)
            ; 3: The player controller/owner simply wants her locked up in furniture.
            _iFurnitureExcuse = 3
            If (_iFurnitureRemaining)
               ; 2: The player is being punished for bad behaviour.
               _iFurnitureExcuse = 2
            EndIf
         EndIf
      EndIf
EndIf

      _oKeywordZbfWornDevice = Keyword.GetKeyword("zbfWornDevice")

      ; Keep a local reference to all ZAD device keywords we use.  This allows for quicker
      ; access and prevents possible context switching each time we try to reference them.
      _aoZadDeviceKeyword = New Keyword[23]
      _aoZadDeviceKeyword[0]  = _qZadLibs.zad_DeviousBelt
      _aoZadDeviceKeyword[1]  = _qZadLibs.zad_DeviousBra
      _aoZadDeviceKeyword[2]  = _qZadLibs.zad_DeviousCollar
      _aoZadDeviceKeyword[3]  = _qZadLibs.zad_DeviousArmCuffs
      _aoZadDeviceKeyword[4]  = _qZadLibs.zad_DeviousLegCuffs
      _aoZadDeviceKeyword[5]  = _qZadLibs.zad_DeviousArmbinder
      _aoZadDeviceKeyword[6]  = _qZadLibs.zad_DeviousHobbleSkirt
      _aoZadDeviceKeyword[7]  = _qZadLibs.zad_DeviousAnkleShackles
      _aoZadDeviceKeyword[8]  = _qZadLibs.zad_DeviousYoke
      _aoZadDeviceKeyword[9]  = _qZadLibs.zad_DeviousCorset
      _aoZadDeviceKeyword[10] = _qZadLibs.zad_DeviousClamps
      _aoZadDeviceKeyword[11] = _qZadLibs.zad_DeviousGloves
      _aoZadDeviceKeyword[12] = _qZadLibs.zad_DeviousHood
      _aoZadDeviceKeyword[13] = _qZadLibs.zad_DeviousSuit
      _aoZadDeviceKeyword[14] = _qZadLibs.zad_DeviousGag
      _aoZadDeviceKeyword[15] = _qZadLibs.zad_DeviousPlugVaginal
      _aoZadDeviceKeyword[16] = _qZadLibs.zad_DeviousPlugAnal
      _aoZadDeviceKeyword[17] = _qZadLibs.zad_DeviousHarness
      _aoZadDeviceKeyword[18] = _qZadLibs.zad_DeviousBlindfold
      _aoZadDeviceKeyword[19] = _qZadLibs.zad_DeviousBoots
      _aoZadDeviceKeyword[20] = _qZadLibs.zad_DeviousPiercingsNipple
      _aoZadDeviceKeyword[21] = _qZadLibs.zad_DeviousPiercingsVaginal
      _aoZadDeviceKeyword[22] = _qZadLibs.zad_DeviousBondageMittens

      ; Mittens have been added to the created restraints.
      CreateRestraintsArrays()

      _oPerkSmithDragon  = (Game.GetFormFromFile(0x00052190, "Skyrim.esm") As Perk)
      _oPerkSmithDaedric = (Game.GetFormFromFile(0x000CB413, "Skyrim.esm") As Perk)
      _oPerkSmithGlass   = (Game.GetFormFromFile(0x000CB411, "Skyrim.esm") As Perk)
      _oPerkSmithEbony   = (Game.GetFormFromFile(0x000CB412, "Skyrim.esm") As Perk)
      _oPerkSmithElven   = (Game.GetFormFromFile(0x000CB40F, "Skyrim.esm") As Perk)
      _oPerkSmithOrcish  = (Game.GetFormFromFile(0x000CB410, "Skyrim.esm") As Perk)
      _oPerkSmithSteel   = (Game.GetFormFromFile(0x000CB40D, "Skyrim.esm") As Perk)

      _aAliasPlayer = (GetAlias(1) As ReferenceAlias)

      CreateItemLists()
      If (!_iLeashHolderWealth && _aLeashHolder)
         _iLeashHolderWealth = _aLeashHolder.GetItemCount(_oGold)
      EndIf

      _oVigorousHealing = (Game.GetFormFromFile(0x0003EAE3, "Skyrim.esm") As Potion)

If (!_oLeashHolderOutfit)
      _oLeashHolderOutfit = (Game.GetFormFromFile(0x00036955, "DfwSupport.esp") As Outfit)
      _oLeashHolderOutfitContents = \
         (Game.GetFormFromFile(0x00036954, "DfwSupport.esp") As LeveledItem)
EndIf

      ; Registering for events on game load almost always fails.  Always add a delay.
      Log("Delaying before mod event registration.", DL_CRIT, S_MOD)
      Utility.Wait(20.0)

      ; Register for a DFW event notifying us our Master has been overthrown.
      RegisterForModEvent("DFW_DialogueTarget", "NewDialogueTarget")

      Log("Registering Mod Events Done", DL_CRIT, S_MOD)
   EndIf

   ; Finally update the version number.
   _fCurrVer = fScriptVer
   DebugTrace("TraceEvent UpdateScript: Done")
EndFunction

Function OnLoadGame()
   DebugTrace("TraceEvent OnLoadGame")
   ; Use a flag to prevent initialization from happening twice.
; zxc
; Increase the bad behaviour so we can test remote furniture punishments.
_iBadBehaviour = 10
_iBlindfoldRemaining = 0
; 18: zad_DeviousBlindfold
UnequipBdsmItem(_aoBlindfolds, _aoZadDeviceKeyword[18], _aLeashHolder)
; For some reason these are not being set in some games.  Force set it here.
_qMcm.fEventEquipSlaver = 100.0
_qMcm.iPunishMinBehaviourRemote = 5
_qMcm.fEventProposition = 5.0
_fMcmEventProposition   = 5.0
_qMcm.iEventPropArousal = 40
_iMcmEventPropArousal   = 40

; Oops.  Bad code caused bad behaviour (and related values) to slip below 0 in some games.
If (0 > _iBadBehaviour)
   _iBadBehaviour = 1
EndIf
If (0 > _iFurnitureRemaining)
   _iFurnitureRemaining = 1
EndIf
If (0 > _iGagRemaining)
   _iGagRemaining = 1
EndIf

If (_oPunishmentFurniture && !_aLeashHolder)
   _oPunishmentFurniture = None
EndIf

; Fix the pilory in the Whiterun farms indicating it is remote.
; 0x0001: BDSM Furniture
; 0x0020: Public
; 0x0080: Remote
_aiFavouriteFlags[23] = 0x0001 + 0x0020 + 0x0080
; Default the agenda to making the player secure (unless there is no leash game of course).
_bIsPlayerRemote = True
If (0 < _iLeashGameDuration)
   _iAgendaMidTerm = 2
Else
   _iAgendaMidTerm = 0
EndIf
If (11 == _iAgendaShortTerm)
   _iAgendaShortTerm = 0
EndIf
If (!_aoMittens.Length)
   CreateRestraintsArrays()
EndIf
If ((6 == _iCurrScene) && (3 <= _iCurrSceneStage))
   _oTransferFurniture = None
EndIf
If (S_MOD + "_RemoveRestraints" == _qFramework.GetCurrentScene())
   _qFramework.SceneDone(S_MOD + "_RemoveRestraints")
   _qFramework.SceneStarting(S_MOD + "_RemoveRestraints", 180, bExtendCallout=False)
EndIf
   If (_bGameLoadInProgress)
      DebugTrace("TraceEvent OnLoadGame: Done (In Progress)")
      Return
   EndIf
   _bGameLoadInProgress = True

   Float fCurrRealTime = Utility.GetCurrentRealTime()
   Log("Game Loaded.", DL_INFO, S_MOD)

   ; Update all quest variables upon loading each game.
   ; There are too many things that can cause them to become invalid.
   ; E.g. adding/removing conditional variables, converting from plugin to master file.
   _qMcm             = ((Self As Quest) As dfwsMcm)
   _qFramework       = (Quest.GetQuest("_dfwDeviousFramework") As dfwDeviousFramework)
   _qDfwUtil         = (Quest.GetQuest("_dfwDeviousFramework") As dfwUtil)
   _qSexLab          = (Quest.GetQuest("SexLabQuestFramework") As SexLabFramework)
   _qSexLabAroused   = (Quest.GetQuest("sla_Framework") As slaFrameworkScr)
   _qZadLibs         = (Quest.GetQuest("zadQuest") As Zadlibs)
   _qZadArmbinder    = (Quest.GetQuest("zadArmbinderQuest") As zadHeavyBondageQuestScript)
   _qZbfShell        = zbfBondageShell.GetApi()
   _qZbfSlave        = zbfSlaveControl.GetApi()
   _qZbfSlaveActions = zbfSlaveActions.GetApi()
   _qZbfPlayerSlot   = zbfBondageShell.GetApi().FindPlayer()

   ; If there is no one monitoring the player's items make sure we have an inventory filter.
   If (!_aContrabanMonitor)
      _aAliasPlayer.RemoveAllInventoryEventFilters()
      FormList lEmpty
      _aAliasPlayer.AddInventoryEventFilter(lEmpty)
   EndIf

; zxc
Log("Temp Code: Changing Sandbox Probability.", DL_DEBUG, S_MOD)
_aAliasQuestActor1 = (GetAlias(6) As ReferenceAlias)
_aAliasQuestActor2 = (GetAlias(8) As ReferenceAlias)
_aAliasQuestActor3 = (GetAlias(7) As ReferenceAlias)
_qMcm.iFurnitureRemoteSandbox  =  33
_qMcm.fFurnitureRemoteVisitor  =   2.2
_qMcm.fFurnitureReleaseChance  =   0.7
_qMcm.iDominanceAffectsRelease =  45
_qMcm.iModPostSexMonitor       =  15
_qMcm.iLeashCoolDownAmount     =   5
_fMcmFurnitureRemoteVisitor   = _qMcm.fFurnitureRemoteVisitor
_bDialogueFirstEnslaved = True

   ; We need the caged state variable from Sanguine Debauchery plus to stop the leash when the
   ; player is caged.
   _gSdPlusStateCaged = None
   Int iModOrder = Game.GetModByName("sanguinesDebauchery.esp")
   If ((-1 < iModOrder) && (255 > iModOrder))
      _gSdPlusStateCaged = \
         (Game.GetFormFromFile(0x000D1E79, "sanguinesDebauchery.esp") As GlobalVariable)
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

; Make sure the outfit variables get loaded.
If (!_oLeashHolderOutfit)
   _oLeashHolderOutfit = (Game.GetFormFromFile(0x00036955, "DfwSupport.esp") As Outfit)
   _oLeashHolderOutfitContents = (Game.GetFormFromFile(0x00036954, "DfwSupport.esp") As LeveledItem)
EndIf


; Somehow the slaver's outfit lost it's equipment.  If it is gone, reset it.
; This is no longer accurate as the player has been freed and may not have created the armour yet.
_bLeashHolderOutfitActive = False
;If (!_oLeashHolderOutfitContents.GetNumForms())
;   Log("Resetting Outfit!!! (" + _bLeashHolderOutfitActive + ")", DL_ERROR, S_MOD)
;   _bLeashHolderOutfitActive = True
;
;   Form oItem = Game.GetForm(_aoRecipeItemId[42])
;   Log("Adding: " + GetFormName(oItem, True), DL_CRIT, S_MOD)
;   _oLeashHolderOutfitContents.AddForm(oItem, 1, 1)
;   oItem = Game.GetForm(_aoRecipeItemId[43])
;   Log("Adding: " + GetFormName(oItem, True), DL_CRIT, S_MOD)
;   _oLeashHolderOutfitContents.AddForm(oItem, 1, 1)
;   oItem = Game.GetForm(_aoRecipeItemId[44])
;   Log("Adding: " + GetFormName(oItem, True), DL_CRIT, S_MOD)
;   _oLeashHolderOutfitContents.AddForm(oItem, 1, 1)
;   oItem = Game.GetForm(_aoRecipeItemId[45])
;   Log("Adding: " + GetFormName(oItem, True), DL_CRIT, S_MOD)
;   _oLeashHolderOutfitContents.AddForm(oItem, 1, 1)
;
;
;Int iNumForms = _oLeashHolderOutfitContents.GetNumForms()
;DebugLog("Contents Forms: " + iNumForms, DL_CRIT)
;While (iNumForms)
;   Form oForm = _oLeashHolderOutfitContents.GetNthForm(iNumForms - 1)
;   Log("Form " + iNumForms + ": " + GetFormName(oForm, True), DL_CRIT, S_MOD)
;
;   iNumForms -= 1
;EndWhile
;EndIf


; zxc: Add the three cages from the slave holding cell for testing purposes.
If (MutexLock(_iFavouriteFurnitureMutex))
If (3 <= _afFavouriteCageLocations.Length)
   _afFavouriteCageLocations[0] = 1950.00
   _afFavouriteCageLocations[1] = 1400.00
   _afFavouriteCageLocations[2] = -703.31
EndIf
If (6 <= _afFavouriteCageLocations.Length)
   _afFavouriteCageLocations[3] = 1660.00
   _afFavouriteCageLocations[4] = 1400.00
   _afFavouriteCageLocations[5] = -703.31
EndIf
If (9 <= _afFavouriteCageLocations.Length)
   _afFavouriteCageLocations[6] = 1375.00
   _afFavouriteCageLocations[7] = 1400.00
   _afFavouriteCageLocations[8] = -703.31
EndIf
; First new cage will be index 33.
If (33 == _aiFavouriteFlags.Length)
   _aiFavouriteFlags = _qDfwUtil.AddIntToArray(_aiFavouriteFlags, 0x0400 + 0x0002)
   _afFavouriteCageLocations = New Float[3]
   _afFavouriteCageLocations[0] = 1950.00
   _afFavouriteCageLocations[1] = 1400.00
   _afFavouriteCageLocations[2] = -703.31
   ObjectReference oCageDoor  = (Game.GetForm(0x3E0013EE) As ObjectReference)
   ObjectReference oPullChain = (Game.GetForm(0x3E007804) As ObjectReference)
   _aoFavouriteCageLevers = New Form[2]
   _aoFavouriteCageLevers[0] = oCageDoor
   _aoFavouriteCageLevers[1] = oPullChain
   _aoFavouriteFurniture = _qDfwUtil.AddFormToArray(_aoFavouriteFurniture, oCageDoor)
   _aoFavouriteCell      = _qDfwUtil.AddFormToArray(_aoFavouriteCell,      _aoFavouriteCell[29])
   _aoFavouriteLocation  = _qDfwUtil.AddFormToArray(_aoFavouriteLocation,  _aoFavouriteLocation[29])
   _aoFavouriteRegion    = _qDfwUtil.AddFormToArray(_aoFavouriteRegion,    _aoFavouriteRegion[29])
EndIf

If (34 == _aiFavouriteFlags.Length)
   _aiFavouriteFlags = _qDfwUtil.AddIntToArray(_aiFavouriteFlags, 0x0400 + 0x0002)
   _afFavouriteCageLocations = _qDfwUtil.AddFloatToArray(_afFavouriteCageLocations, 1660.00)
   _afFavouriteCageLocations = _qDfwUtil.AddFloatToArray(_afFavouriteCageLocations, 1400.00)
   _afFavouriteCageLocations = _qDfwUtil.AddFloatToArray(_afFavouriteCageLocations, -703.31)
   ObjectReference oCageDoor  = (Game.GetForm(0x3E0015F7) As ObjectReference)
   ObjectReference oPullChain = (Game.GetForm(0x3E007805) As ObjectReference)
   _aoFavouriteCageLevers = _qDfwUtil.AddFormToArray(_aoFavouriteCageLevers, oCageDoor)
   _aoFavouriteCageLevers = _qDfwUtil.AddFormToArray(_aoFavouriteCageLevers, oPullChain)
   _aoFavouriteFurniture = _qDfwUtil.AddFormToArray(_aoFavouriteFurniture, oCageDoor)
   _aoFavouriteCell      = _qDfwUtil.AddFormToArray(_aoFavouriteCell,      _aoFavouriteCell[29])
   _aoFavouriteLocation  = _qDfwUtil.AddFormToArray(_aoFavouriteLocation,  _aoFavouriteLocation[29])
   _aoFavouriteRegion    = _qDfwUtil.AddFormToArray(_aoFavouriteRegion,    _aoFavouriteRegion[29])
EndIf

If (35 == _aiFavouriteFlags.Length)
   _aiFavouriteFlags = _qDfwUtil.AddIntToArray(_aiFavouriteFlags, 0x0400 + 0x0002)
   _afFavouriteCageLocations = _qDfwUtil.AddFloatToArray(_afFavouriteCageLocations, 1375.00)
   _afFavouriteCageLocations = _qDfwUtil.AddFloatToArray(_afFavouriteCageLocations, 1400.00)
   _afFavouriteCageLocations = _qDfwUtil.AddFloatToArray(_afFavouriteCageLocations, -703.31)
   ObjectReference oCageDoor  = (Game.GetForm(0x3E0015F6) As ObjectReference)
   ObjectReference oPullChain = (Game.GetForm(0x3E007806) As ObjectReference)
   _aoFavouriteCageLevers = _qDfwUtil.AddFormToArray(_aoFavouriteCageLevers, oCageDoor)
   _aoFavouriteCageLevers = _qDfwUtil.AddFormToArray(_aoFavouriteCageLevers, oPullChain)
   _aoFavouriteFurniture = _qDfwUtil.AddFormToArray(_aoFavouriteFurniture, oCageDoor)
   _aoFavouriteCell      = _qDfwUtil.AddFormToArray(_aoFavouriteCell,      _aoFavouriteCell[29])
   _aoFavouriteLocation  = _qDfwUtil.AddFormToArray(_aoFavouriteLocation,  _aoFavouriteLocation[29])
   _aoFavouriteRegion    = _qDfwUtil.AddFormToArray(_aoFavouriteRegion,    _aoFavouriteRegion[29])
EndIf

If (36 == _aiFavouriteFlags.Length)
   ; 0x0001: BDSM Furniture
   ; 0x0100: Activity/Sandbox (NPCs can sandbox nearby)
   ; 0x0200: Milking Furniture
   _aiFavouriteFlags = _qDfwUtil.AddIntToArray(_aiFavouriteFlags, 0x0200 + 0x0100 + 0x0001)
   ObjectReference oFurniture = (Game.GetForm(0x32013DA9) As ObjectReference)
   Cell oCell = (Game.GetForm(0x0001A278) As Cell)
   _aoFavouriteFurniture = _qDfwUtil.AddFormToArray(_aoFavouriteFurniture, oFurniture)
   _aoFavouriteCell      = _qDfwUtil.AddFormToArray(_aoFavouriteCell,      oCell)
   _aoFavouriteLocation  = _qDfwUtil.AddFormToArray(_aoFavouriteLocation,  (Game.GetFormFromFile(0x00018A56, "Skyrim.esm") As Location))
   _aoFavouriteRegion    = _qDfwUtil.AddFormToArray(_aoFavouriteRegion,    (Game.GetFormFromFile(0x00018A56, "Skyrim.esm") As Location))
EndIf

If (37 == _aiFavouriteFlags.Length)
   ; 0x0001: BDSM Furniture
   ; 0x0100: Activity/Sandbox (NPCs can sandbox nearby)
   ; 0x0200: Milking Furniture
   _aiFavouriteFlags = _qDfwUtil.AddIntToArray(_aiFavouriteFlags, 0x0200 + 0x0100 + 0x0001)
   ObjectReference oFurniture = (Game.GetForm(0x32013DAA) As ObjectReference)
   Cell oCell = (Game.GetForm(0x0001A278) As Cell)
   _aoFavouriteFurniture = _qDfwUtil.AddFormToArray(_aoFavouriteFurniture, oFurniture)
   _aoFavouriteCell      = _qDfwUtil.AddFormToArray(_aoFavouriteCell,      oCell)
   _aoFavouriteLocation  = _qDfwUtil.AddFormToArray(_aoFavouriteLocation,  (Game.GetFormFromFile(0x00018A56, "Skyrim.esm") As Location))
   _aoFavouriteRegion    = _qDfwUtil.AddFormToArray(_aoFavouriteRegion,    (Game.GetFormFromFile(0x00018A56, "Skyrim.esm") As Location))
EndIf

   MutexRelease(_iFavouriteFurnitureMutex)
EndIf

; The levers have been moved in game but having them in the variable prevents them from being affected.
; Try resetting their editor locations.
(Game.GetForm(0x3E007804) As ObjectReference).MoveToMyEditorLocation()
(Game.GetForm(0x3E007805) As ObjectReference).MoveToMyEditorLocation()
(Game.GetForm(0x3E007806) As ObjectReference).MoveToMyEditorLocation()
; Same with the pilory in the Easter Holding Cells.
(Game.GetForm(0x3F00AC31) As ObjectReference).MoveToMyEditorLocation()

If (33 < _aiFavouriteFlags.Length)
   ;                       Cage   + Private + Remote + Sandbox + Closed
   _aiFavouriteFlags[33] = 0x0002 + 0x0040  + 0x0080 + 0x0100  + 0x0400
   ;                       BDSM   + Private + Remote + Sandbox
   _aiFavouriteFlags[28] = 0x0001 + 0x0040  + 0x0080 + 0x0100
   _aiFavouriteFlags[29] = 0x0001 + 0x0040  + 0x0080 + 0x0100
EndIf

If (34 < _aiFavouriteFlags.Length)
   ;                       Cage   + Private + Remote + Sandbox + Closed
   _aiFavouriteFlags[34] = 0x0002 + 0x0040  + 0x0080 + 0x0100  + 0x0400
EndIf

If (35 < _aiFavouriteFlags.Length)
   ;                       Cage   + Private + Remote + Sandbox + Closed
   _aiFavouriteFlags[35] = 0x0002 + 0x0040  + 0x0080 + 0x0100  + 0x0400
EndIf

; January 2, 2018: Dumping the quest variables has revealed quite a few errors in the furniture
; lists.  These changes should clean up the list.
If (MutexLock(_iFavouriteFurnitureMutex))
   DebugLog("Fixing Furniture.", DL_ERROR)

   ; 29: 0x01C1-0x00000000 ***                  L:0x00018A4E Kynesgrove         R:0x00018A57 Windhelm           C:0x00000000***
   If (!_aoFavouriteFurniture[29])
      _aoFavouriteFurniture = _qDfwUtil.RemoveFormFromArray(_aoFavouriteFurniture, None, 29)
      _aoFavouriteCell      = _qDfwUtil.RemoveFormFromArray(_aoFavouriteCell,      None, 29)
      _aoFavouriteLocation  = _qDfwUtil.RemoveFormFromArray(_aoFavouriteLocation,  None, 29)
      _aoFavouriteRegion    = _qDfwUtil.RemoveFormFromArray(_aoFavouriteRegion,    None, 29)
      _aiFavouriteFlags     = _qDfwUtil.RemoveIntFromArray(_aiFavouriteFlags,      0,    29)
   EndIf

   ; 30: 0x0001-0x00000000 ***                  L:0x00018A4E Kynesgrove         R:0x00018A57 Windhelm           C:0x00000000***
   ; Remember index 29 has been removed by now so 30 is now 29.
   If (!_aoFavouriteFurniture[29])
      _aoFavouriteFurniture = _qDfwUtil.RemoveFormFromArray(_aoFavouriteFurniture, None, 29)
      _aoFavouriteCell      = _qDfwUtil.RemoveFormFromArray(_aoFavouriteCell,      None, 29)
      _aoFavouriteLocation  = _qDfwUtil.RemoveFormFromArray(_aoFavouriteLocation,  None, 29)
      _aoFavouriteRegion    = _qDfwUtil.RemoveFormFromArray(_aoFavouriteRegion,    None, 29)
      _aiFavouriteFlags     = _qDfwUtil.RemoveIntFromArray(_aiFavouriteFlags,      0,    29)
   EndIf

   ; The Milk Pump in Whiterun is BDSM furniture, not a cage.  Fix its flags.
   ; Remember index 29 and 30 have been removed by now so 35 is now 33.
   ; 3-35: 0x05C2-0x32013DA9         Milk Pump<18096.406250,  -5238.165527, -4140.573242> 0x3E007805 L:0x00018A56 Whiterun           R:0x00018A56 Whiterun C:0x0001A278
   If (0x05C2 == _aiFavouriteFlags[33])
      ; 0x0100: Activity/Sandbox (NPCs can sandbox nearby)
      ; 0x0200: Milking Furniture
      ; 0x0001: BDSM Furniture
      _aiFavouriteFlags[33] = 0x0301
   EndIf

   ; The cage arrays are rather messed up.  Try to clean them up.
   ; Remember index 29 and 30 have been removed by now so furniture indexes are two smaller.
   ; Array Sizes: ........... 65/65/65/65/65/21/10
   ; 0-32: 0x05C2-0x3E0013EE         Door     < 1950.000000,   1400.000000,  -703.309998> 0x3E0013EE L:0x000D9079 Western Watchtower R:0x00018A56 Whiterun C:0x3E0013E7 SlaveDen
   ; 1-33: 0x05C2-0x3E0015F7         Door     < 1660.000000,   1400.000000,  -703.309998> 0x3E007804 L:0x000D9079 Western Watchtower R:0x00018A56 Whiterun C:0x3E0013E7 SlaveDen
   ; 2-34: 0x05C2-0x3E0015F6         Door     < 1375.000000,   1400.000000,  -703.309998> 0x3E0015F7 L:0x000D9079 Western Watchtower R:0x00018A56 Whiterun C:0x3E0013E7 SlaveDen
   ; 4-46: 0x0022-0x-15-15-15-1-6-15 Cage Gate<18096.406250,  -5238.165527, -4140.573242> 0x3E007805 L:0x00018A56 Whiterun           R:0x00018A56 Whiterun C:0x000095FC
   ; 5-48: 0x0122-0x0010C010         gate     <18801.457031, -10812.763672, -4591.266602> 0x3E0015F6 L:0x00018A56 Whiterun           R:0x00018A56 Whiterun C:0x0000961B
   ; 6-58: 0x05A2-0x3F00AC25         Door     <  540.000000,    575.000000,     0.000000> 0x3E007806 L:0x00018A4E Kynesgrove         R:0x00018A57 Windhelm C:0x3F00AB60 Holding Cells
   ; 7-60: 0x05A2-0x3F00AC27         Cage Gate< 1440.000000,    -35.000000,     0.000000> 0x3F00AC25 L:0x00018A4E Kynesgrove         R:0x00018A57 Windhelm C:0x3F00AB60 Holding Cells
   ;                                                                                      0x3F00AC2B

   ; There are too many levers.  I don't know where they all came from or which ones to use but
   ; try associated the latest levers with the latest cages.
   If ((21 == _afFavouriteCageLocations.Length) && (10 == _aoFavouriteCageLevers.Length))
      _aoFavouriteCageLevers[6] = _aoFavouriteCageLevers[8]
      _aoFavouriteCageLevers[7] = _aoFavouriteCageLevers[9]
      _aoFavouriteCageLevers    = _qDfwUtil.RemoveFormFromArray(_aoFavouriteCageLevers, None, 8)
      _aoFavouriteCageLevers    = _qDfwUtil.RemoveFormFromArray(_aoFavouriteCageLevers, None, 8)
   EndIf

   ; These cage locations were entered wrong.  Fix them.
   If (17 < _afFavouriteCageLocations.Length)
      _afFavouriteCageLocations[15] =  540.00
      _afFavouriteCageLocations[16] =  575.00
      _afFavouriteCageLocations[17] =    0.00
   EndIf
   If (20 < _afFavouriteCageLocations.Length)
      _afFavouriteCageLocations[18] = 1440.00
      _afFavouriteCageLocations[19] =  -35.00
      _afFavouriteCageLocations[20] =    0.00
   EndIf

   MutexRelease(_iFavouriteFurnitureMutex)
EndIf

;;; [01/01/2018 - 09:48:34AM] [DFWS] DFWS_Variable_Dump - Faviourite Furniture:
;;; Array Sizes: ........... 65/65/65/65/65/21/10
;;;  0: 0x0001-0x160DD432 Pillory              L:0x00018E40 Salvius Farm       R:0x00018A59 Markarth           C:0x00007178
;;;  1: 0x0001-0x160DD42F Pillory              L:0x00018A46 Dragon Bridge      R:0x00018A46 Dragon Bridge      C:0x00009307
;;;  2: 0x0001-0x16060BB7 Multi Restraint Pole L:0x00018E38 Katla's Farm       R:0x00018A5A Solitude           C:0x000092BF
;;;  3: 0x0001-0x2900AA51 X Cross              L:0x00018A5A Solitude           R:0x00018A5A Solitude           C:0x00037EE7
;;;  4: 0x0001-0x2B03A905 Pillory              L:0x00018A5A Solitude           R:0x00018A5A Solitude           C:0x00037EE5
;;;  5: 0x0001-0x2B03A906 Pillory              L:0x00018A5A Solitude           R:0x00018A5A Solitude           C:0x00037EE5
;;;  6: 0x0001-0x160DD43B Pillory              L:0x00018E44 Solitude Sawmill   R:0x00018A5A Solitude           C:0x000092E0
;;;  7: 0x0001-0x160A53B8 Tilted Wheel         L:0x0001EB9A Highmoon Hall      R:0x00018A53 Morthal            C:0x000138CC Highmoon Hall
;;;  8: 0x0001-0x1605E077 Tilted Wheel         L:0x00020062 The White Hall     R:0x00018A50 Dawnstar           C:0x00013A80 The White Hall
;;;  9: 0x0001-0x2B03A907 X Cross              L:0x000209E7 Bloodworks         R:0x00018A57 Windhelm           C:0x0001677A Windhelm Barracks
;;; 10: 0x0001-0x2B03A900 X Cross              L:0x00018A58 Riften             R:0x00018A58 Riften             C:0x00042247
;;; 11: 0x0001-0x2B03A392 Pillory              L:0x00018A58 Riften             R:0x00018A58 Riften             C:0x00042247
;;; 12: 0x0001-0x160DD434 Pillory              L:0x00013163 Riverwood          R:0x00013163 Riverwood          C:0x00000000***
;;; 13: 0x0001-0x160DD435 Pillory              L:0x00013163 Riverwood          R:0x00013163 Riverwood          C:0x00009731
;;; 14: 0x0001-0x2B03A393 Pillory              L:0x00018A58 Riften             R:0x00018A58 Riften             C:0x00042247
;;; 15: 0x0001-0x160DD430 Pillory              L:0x00018E33 Heartwood Mill     R:0x00018A58 Riften             C:0x0000BCDA
;;; 16: 0x0001-0x16060BBA Pillory              L:0x00018A4B Ivarstead          R:0x00018A4B Ivarstead          C:0x000097A0
;;; 17: 0x0001-0x16060BB8 Vertical Stocks X    L:0x00018A4B Ivarstead          R:0x00018A4B Ivarstead          C:0x00009781
;;; 18: 0x0001-0x2B03A903 Pillory              L:0x00018A49 Falkreath          R:0x00018A49 Falkreath          C:0x00009C80
;;; 19: 0x0001-0x2B03A904 Pillory              L:0x00018A49 Falkreath          R:0x00018A49 Falkreath          C:0x00009C80
;;; 20: 0x0001-0x160DD431 Pillory              L:0x000200AB Half-Moon Mill     R:0x00018A49 Falkreath          C:0x00000000***
;;; 21: 0x0001-0x160DD42E Pillory              L:0x00018A4D Darkwater Crossing R:None                          C:0x00000000***
;;; 22: 0x00A1-0x160DD453 Pillory              L:0x00018C8D Battle-Born Farm   R:0x00018A56 Whiterun           C:0x000095D9
;;; 23: 0x00A1-0x32023094 Milk Pump            L:0x00018A53 Morthal            R:0x00018A53 Morthal            C:0x0000939C
;;; 24: 0x0001-0x320225BF Milk Pump            L:0x00018A59 Markarth           R:0x00018A59 Markarth           C:0x00020EE7
;;; 25: 0x0001-0x320225C7 Milk Pump            L:0x00018A5A Solitude           R:0x00018A5A Solitude           C:0x00037EE9
;;; 26: 0x0001-0x3202309A Milk Pump            L:0x00013163 Riverwood          R:0x00013163 Riverwood          C:0x00009731
;;; 27: 0x01C1-0x3E007807 Rack                 L:0x000D9079 Western Watchtower R:0x00018A56 Whiterun           C:0x3E0013E7 SlaveDen
;;; 28: 0x01C1-0x3E007808 Multi Restraint Pole L:0x000D9079 Western Watchtower R:0x00018A56 Whiterun           C:0x3E0013E7 SlaveDen
;;; 29: 0x01C1-0x00000000 ***                  L:0x00018A4E Kynesgrove         R:0x00018A57 Windhelm           C:0x00000000***
;;; 30: 0x0001-0x00000000 ***                  L:0x00018A4E Kynesgrove         R:0x00018A57 Windhelm           C:0x00000000***
;;; 31: 0x0001-0x3204CFD2 Milk Pump            L:0x00018A58 Riften             R:0x00018A58 Riften             C:0x00042247
;;; 36: 0x0301-0x32013DAA Milk Pump            L:0x00018A56 Whiterun           R:0x00018A56 Whiterun           C:0x0001A278
;;; 37: 0x0121-0x1C00437F Pillory              L:0x00018A56 Whiterun           R:0x00018A56 Whiterun           C:0x0001A27A
;;; 38: 0x00A1-0x16023F75 Tilted Wheel         L:0x00018A56 Whiterun           R:0x00018A56 Whiterun           C:0x0001A27B
;;; 39: 0x0021-0x1C004386 Vertical Stocks X    L:0x00018A56 Whiterun           R:0x00018A56 Whiterun           C:0x0001A274
;;; 40: 0x0021-0x1C004385 Vertical Stocks X    L:0x00018A56 Whiterun           R:0x00018A56 Whiterun           C:0x0001A274
;;; 41: 0x0121-0x1C004384 Cross Roped Pose 02  L:0x00018A56 Whiterun           R:0x00018A56 Whiterun           C:0x0001A273
;;; 42: 0x0121-0x1C004383 Low Wheel            L:0x00018A56 Whiterun           R:0x00018A56 Whiterun           C:0x0001A273
;;; 43: 0x0121-0x2B03A901 Pillory              L:0x00018A56 Whiterun           R:0x00018A56 Whiterun           C:0x0001A276
;;; 44: 0x0121-0x2B03A902 Pillory              L:0x00018A56 Whiterun           R:0x00018A56 Whiterun           C:0x0001A276
;;; 45: 0x0021-0x1C0038BA Pillory              L:0x00018A56 Whiterun           R:0x00018A56 Whiterun           C:0x0000961B
;;; 47: 0x0121-0x1C0038B9 Cross Roped Pose 02  L:0x00018A56 Whiterun           R:0x00018A56 Whiterun           C:0x0000961B
;;; 49: 0x0121-0x1C00287E Tilted Wheel         L:0x00013163 Riverwood          R:0x00013163 Riverwood          C:0x00009731
;;; 50: 0x0121-0x1C00287D Pillory              L:0x00013163 Riverwood          R:0x00013163 Riverwood          C:0x00009732
;;; 51: 0x0121-0x1C004387 Tilted Wheel         L:0x00018A57 Windhelm           R:0x00018A57 Windhelm           C:0x0000B4FC
;;; 52: 0x0121-0x1C004388 X Cross II Comfy     L:0x00018A57 Windhelm           R:0x00018A57 Windhelm           C:0x0000B4DB
;;; 53: 0x0121-0x1C00438A Vertical Stocks X    L:0x00018A57 Windhelm           R:0x00018A57 Windhelm           C:0x0000B4DC
;;; 54: 0x0121-0x1C0048FF Pillory              L:0x00018A57 Windhelm           R:0x00018A57 Windhelm           C:0x00038382
;;; 55: 0x0121-0x1C0048FE Pillory              L:0x00018A57 Windhelm           R:0x00018A57 Windhelm           C:0x00038382
;;; 56: 0x0121-0x1C0048F1 Cross Roped Pose 03  L:0x00018A57 Windhelm           R:0x00018A57 Windhelm           C:0x0003837C
;;; 57: 0x00A1-0x1C004900 Vertical Stocks      L:0x00018A57 Windhelm           R:0x00018A57 Windhelm           C:0x00038384
;;; 59: 0x01A1-0x3F00AC2F Multi Restraint Wall L:0x00018A4E Kynesgrove         R:0x00018A57 Windhelm           C:0x3F00AB60 Holding Cells
;;; 61: 0x01A1-0x3F00AC34 Low Wheel            L:0x00018A4E Kynesgrove         R:0x00018A57 Windhelm           C:0x3F00AB60 Holding Cells
;;; 62: 0x01A1-0x3F00AC31 Pillory              L:0x00018A4E Kynesgrove         R:0x00018A57 Windhelm           C:0x3F00AB60 Holding Cells
;;; 63: 0x01A1-0x3F00AC30 Multi Restraint Pole L:0x00018A4E Kynesgrove         R:0x00018A57 Windhelm           C:0x3F00AB60 Holding Cells
;;; 64: 0x0321-0x320225B7 Milk Pump            L:0x00018A57 Windhelm           R:0x00018A57 Windhelm           C:0x00038381
;;;
;;; Array Sizes: ........... 65/65/65/65/65/21/10
;;; 0-32: 0x05C2-0x3E0013EE         Door     < 1950.000000,   1400.000000,  -703.309998> 0x3E0013EE L:0x000D9079 Western Watchtower R:0x00018A56 Whiterun C:0x3E0013E7 SlaveDen
;;; 1-33: 0x05C2-0x3E0015F7         Door     < 1660.000000,   1400.000000,  -703.309998> 0x3E007804 L:0x000D9079 Western Watchtower R:0x00018A56 Whiterun C:0x3E0013E7 SlaveDen
;;; 2-34: 0x05C2-0x3E0015F6         Door     < 1375.000000,   1400.000000,  -703.309998> 0x3E0015F7 L:0x000D9079 Western Watchtower R:0x00018A56 Whiterun C:0x3E0013E7 SlaveDen
;;; 3-35: 0x05C2-0x32013DA9         Milk Pump<18096.406250,  -5238.165527, -4140.573242> 0x3E007805 L:0x00018A56 Whiterun           R:0x00018A56 Whiterun C:0x0001A278
;;; 4-46: 0x0022-0x-15-15-15-1-6-15 Cage Gate<18801.457031, -10812.763672, -4591.266602> 0x3E0015F6 L:0x00018A56 Whiterun           R:0x00018A56 Whiterun C:0x000095FC
;;; 5-48: 0x0122-0x0010C010         gate     <  540.000000,    575.000000,     0.000000> 0x3E007806 L:0x00018A56 Whiterun           R:0x00018A56 Whiterun C:0x0000961B
;;; 6-58: 0x05A2-0x3F00AC25         Door     < 1440.000000,    -35.000000,     0.000000> 0x3F00AC25 L:0x00018A4E Kynesgrove         R:0x00018A57 Windhelm C:0x3F00AB60 Holding Cells
;;; 7-60: 0x05A2-0x3F00AC27         Cage Gate<Out of Bounds>                             0x3F00AC2B L:0x00018A4E Kynesgrove         R:0x00018A57 Windhelm C:0x3F00AB60 Holding Cells

   _bGameLoadInProgress = False
   Log("Game Loaded Done: " + (Utility.GetCurrentRealTime() - fCurrRealTime), DL_TRACE, S_MOD)
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

Function UpdateLocalMcmSettings(String szCategory="")
   ; If this is called before we have configured our MCM quest do so now.
   If (!_qMcm)
      _qMcm = ((Self As Quest) As dfwsMcm)
      If (!_qMcm)
         Log("Error: Failed to find MCM quest in UpdateLocalMcmSettings()", DL_ERROR, S_MOD)
         DebugTrace("TraceEvent OnLoadGame: Done (MCM Failed)")
         Return
      EndIf
   EndIf

   If (!szCategory || ("Compatibility" == szCategory))
      _iMcmGagMode     = _qMcm.iGagMode
      _bMcmCatchSdPlus = _qMcm.bCatchSdPlus
   EndIf

   If (!szCategory || ("Leash" == szCategory))
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

   If (!szCategory || ("Furniture" == szCategory))
      _fMcmFurnitureReleaseChance  = _qMcm.fFurnitureReleaseChance
      _fMcmFurnitureVisitorChance  = _qMcm.fFurnitureVisitorChance
      _fMcmFurnitureRemoteVisitor  = _qMcm.fFurnitureRemoteVisitor
   EndIf

   If (!szCategory || ("Mod" == szCategory))
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

   If (!szCategory || ("Events" == szCategory))
      _fMcmEventMilkScene     = _qMcm.fEventMilkScene
      _fMcmEventProposition   = _qMcm.fEventProposition
      _iMcmEventPropArousal   = _qMcm.iEventPropArousal
   EndIf

   If ("Mod" == szCategory)
      ; If we are re-enabling the mod make sure to start the poll.
      If (_bMcmShutdownMod && !_qMcm.bShutdownMod)
         UpdatePollingInterval(_fMcmPollTime)
      EndIf
      _bMcmShutdownMod = _qMcm.bShutdownMod
   EndIf
   DebugTrace("TraceEvent OnLoadGame: Done")
EndFunction

Function CreateItemLists()
   If (21 != _aoIngredientList.Length)
      _aoIngredientList   = New Form[21]
      _aoIngredientPrices = New  Int[21]

      _aoIngredientList[00] = Game.GetFormFromFile(0x000DB5D2, "Skyrim.esm") ;;; Leather01
      _aoIngredientList[01] = Game.GetFormFromFile(0x000800E4, "Skyrim.esm") ;;; LeatherStrips
      _aoIngredientList[02] = Game.GetFormFromFile(0x0005AD93, "Skyrim.esm") ;;; IngotCorundum
      _aoIngredientList[03] = Game.GetFormFromFile(0x000DB8A2, "Skyrim.esm") ;;; IngotDwarven
      _aoIngredientList[04] = Game.GetFormFromFile(0x0005AD9D, "Skyrim.esm") ;;; IngotEbony
      _aoIngredientList[05] = Game.GetFormFromFile(0x0005AD9E, "Skyrim.esm") ;;; IngotGold
      _aoIngredientList[06] = Game.GetFormFromFile(0x0005AD9F, "Skyrim.esm") ;;; IngotMoonstone
      _aoIngredientList[07] = Game.GetFormFromFile(0x0005ACE4, "Skyrim.esm") ;;; IngotIron
      _aoIngredientList[08] = Game.GetFormFromFile(0x0005ADA1, "Skyrim.esm") ;;; IngotMalachite
      _aoIngredientList[09] = Game.GetFormFromFile(0x0005AD99, "Skyrim.esm") ;;; IngotOrichalcum
      _aoIngredientList[10] = Game.GetFormFromFile(0x0005ADA0, "Skyrim.esm") ;;; IngotQuicksilver
      _aoIngredientList[11] = Game.GetFormFromFile(0x0005ACE3, "Skyrim.esm") ;;; IngotSilver
      _aoIngredientList[12] = Game.GetFormFromFile(0x0005ACE5, "Skyrim.esm") ;;; IngotSteel
      _aoIngredientList[13] = Game.GetFormFromFile(0x0003ADA4, "Skyrim.esm") ;;; DragonBone
      _aoIngredientList[14] = Game.GetFormFromFile(0x0003ADA3, "Skyrim.esm") ;;; DragonScale
      _aoIngredientList[15] = Game.GetFormFromFile(0x0006851F, "Skyrim.esm") ;;; GemDiamondFlawless
      _aoIngredientList[16] = Game.GetFormFromFile(0x00063B47, "Skyrim.esm") ;;; GemDiamond
      _aoIngredientList[17] = Game.GetFormFromFile(0x00052695, "Skyrim.esm") ;;; CharredSkeeverHide
      _aoIngredientList[18] = Game.GetFormFromFile(0x0003AD5B, "Skyrim.esm") ;;; DaedraHeart
      _aoIngredientList[19] = Game.GetFormFromFile(0x000E4F0C, "Skyrim.esm") ;;; DragonflyBlue
      _aoIngredientList[20] = Game.GetFormFromFile(0x0002E4FF, "Skyrim.esm") ;;; GrandSoulGem

      _aoIngredientPrices[00] =   10 ;;; Leather01
      _aoIngredientPrices[01] =    3 ;;; LeatherStrips
      _aoIngredientPrices[02] =   40 ;;; IngotCorundum
      _aoIngredientPrices[03] =   30 ;;; IngotDwarven
      _aoIngredientPrices[04] =  150 ;;; IngotEbony
      _aoIngredientPrices[05] =  100 ;;; IngotGold
      _aoIngredientPrices[06] =   75 ;;; IngotMoonstone
      _aoIngredientPrices[07] =    7 ;;; IngotIron
      _aoIngredientPrices[08] =  100 ;;; IngotMalachite
      _aoIngredientPrices[09] =   45 ;;; IngotOrichalcum
      _aoIngredientPrices[10] =   60 ;;; IngotQuicksilver
      _aoIngredientPrices[11] =   50 ;;; IngotSilver
      _aoIngredientPrices[12] =   20 ;;; IngotSteel
      _aoIngredientPrices[13] =  500 ;;; DragonBone
      _aoIngredientPrices[14] =  250 ;;; DragonScale
      _aoIngredientPrices[15] = 1000 ;;; GemDiamondFlawless
      _aoIngredientPrices[16] =  800 ;;; GemDiamond
      _aoIngredientPrices[17] =    1 ;;; CharredSkeeverHide
      _aoIngredientPrices[18] =  250 ;;; DaedraHeart
      _aoIngredientPrices[19] =    1 ;;; DragonflyBlue
      _aoIngredientPrices[20] = 500 ;;; GrandSoulGem
   EndIf

   ;If (10 != _aoSetRequiredPerk.Length)
   If ((55 != _aoRecipeItemId.Length) || (1 != _aiIngredientArray[54]))
      _aoSetRequiredPerk = New Perk[10]
      _aoSetFirstItem    = New Int[10]
      _aoSetLastItem     = New Int[10]

      _aoRecipeItemId     = New Int[55]
      ; Unless otherwise indicated these are zet to 0 (the first array).
      _aiIngredientArray  = New Int[55]
      _aiRecipeFirstItem  = New Int[55]
      _aiRecipeLastItem   = New Int[55]

      _aiRecipeIngredient0 = New Int[126]
      _aiRecipeQuantity0   = New Int[126]
      _aiRecipeIngredient1 = New Int[45]
      _aiRecipeQuantity1   = New Int[45]

      ;;;;;;;;;;;;;;;;;;;;;  Item Set: Imperial Light  ;;;;;;;;;;;;;;;;;;;;;;;;;
      _aoSetRequiredPerk[00] = _oPerkSmithSteel
         _aoSetFirstItem[00] = 000
          _aoSetLastItem[00] = 005

      _aoRecipeItemId[000]    = 0x00013ED9 ;;; Imperial Light Armor ;;;
      _aiRecipeFirstItem[000] = 000
       _aiRecipeLastItem[000] = 002
      _aiRecipeIngredient0[000] = 00 ;;; Leather01
        _aiRecipeQuantity0[000] =  2
      _aiRecipeIngredient0[001] = 01 ;;; LeatherStrips
        _aiRecipeQuantity0[001] =  3
      _aiRecipeIngredient0[002] = 12 ;;; IngotSteel
        _aiRecipeQuantity0[002] =  2

      _aoRecipeItemId[001]    = 0x00013ED7 ;;; Imperial Light Boots ;;;
      _aiRecipeFirstItem[001] = 003
       _aiRecipeLastItem[001] = 005
      _aiRecipeIngredient0[003] = 00 ;;; Leather01
        _aiRecipeQuantity0[003] =  1
      _aiRecipeIngredient0[004] = 01 ;;; LeatherStrips
        _aiRecipeQuantity0[004] =  2
      _aiRecipeIngredient0[005] = 12 ;;; IngotSteel
        _aiRecipeQuantity0[005] =  1

      _aoRecipeItemId[002]    = 0x00013EDA ;;; Imperial Light Bracers ;;;
      _aiRecipeFirstItem[002] = 006
       _aiRecipeLastItem[002] = 008
      _aiRecipeIngredient0[006] = 00 ;;; Leather01
        _aiRecipeQuantity0[006] =  1
      _aiRecipeIngredient0[007] = 01 ;;; LeatherStrips
        _aiRecipeQuantity0[007] =  2
      _aiRecipeIngredient0[008] = 12 ;;; IngotSteel
        _aiRecipeQuantity0[008] =  1

      _aoRecipeItemId[003]    = 0x00013EDB ;;; Imperial Light Helmet ;;;
      _aiRecipeFirstItem[003] = 009
       _aiRecipeLastItem[003] = 011
      _aiRecipeIngredient0[009] = 00 ;;; Leather01
        _aiRecipeQuantity0[009] =  1
      _aiRecipeIngredient0[010] = 01 ;;; LeatherStrips
        _aiRecipeQuantity0[010] =  1
      _aiRecipeIngredient0[011] = 12 ;;; IngotSteel
        _aiRecipeQuantity0[011] =  1

      _aoRecipeItemId[004]    = 0x00013AB2 ;;; Imperial Light Shield ;;;
      _aiRecipeFirstItem[004] = 012
       _aiRecipeLastItem[004] = 013
      _aiRecipeIngredient0[012] = 01 ;;; LeatherStrips
        _aiRecipeQuantity0[012] =  2
      _aiRecipeIngredient0[013] = 12 ;;; IngotSteel
        _aiRecipeQuantity0[013] =  2

      _aoRecipeItemId[005]    = 0x00013989 ;;; Steel Sword ;;;
      _aiRecipeFirstItem[005] = 014
       _aiRecipeLastItem[005] = 016
      _aiRecipeIngredient0[014] = 01 ;;; LeatherStrips
        _aiRecipeQuantity0[014] =  1
      _aiRecipeIngredient0[015] = 07 ;;; IngotIron
        _aiRecipeQuantity0[015] =  1
      _aiRecipeIngredient0[016] = 12 ;;; IngotSteel
        _aiRecipeQuantity0[016] =  2

      ;;;;;;;;;;;;;;;;;;;;;  Item Set: Steel           ;;;;;;;;;;;;;;;;;;;;;;;;;
      _aoSetRequiredPerk[01] = _oPerkSmithSteel
         _aoSetFirstItem[01] = 006
          _aoSetLastItem[01] = 011

      _aoRecipeItemId[006]    = 0x000F6F22 ;;; Steel Armor
      _aiRecipeFirstItem[006] = 017
       _aiRecipeLastItem[006] = 019
      _aiRecipeIngredient0[017] = 01 ;;; LeatherStrips
        _aiRecipeQuantity0[017] =  3
      _aiRecipeIngredient0[018] = 07 ;;; IngotIron
        _aiRecipeQuantity0[018] =  1
      _aiRecipeIngredient0[019] = 12 ;;; IngotSteel
        _aiRecipeQuantity0[019] =  4

      _aoRecipeItemId[007]    = 0x00013951 ;;; Steel Cuffed Boots
      _aiRecipeFirstItem[007] = 020
       _aiRecipeLastItem[007] = 022
      _aiRecipeIngredient0[020] = 01 ;;; LeatherStrips
        _aiRecipeQuantity0[020] =  2
      _aiRecipeIngredient0[021] = 07 ;;; IngotIron
        _aiRecipeQuantity0[021] =  1
      _aiRecipeIngredient0[022] = 12 ;;; IngotSteel
        _aiRecipeQuantity0[022] =  3

      _aoRecipeItemId[008]    = 0x00013953 ;;; Steel Nordic Gauntlets
      _aiRecipeFirstItem[008] = 023
       _aiRecipeLastItem[008] = 025
      _aiRecipeIngredient0[023] = 01 ;;; LeatherStrips
        _aiRecipeQuantity0[023] =  2
      _aiRecipeIngredient0[024] = 07 ;;; IngotIron
        _aiRecipeQuantity0[024] =  1
      _aiRecipeIngredient0[025] = 12 ;;; IngotSteel
        _aiRecipeQuantity0[025] =  2

      _aoRecipeItemId[009]    = 0x00013954 ;;; Steel Helmet
      _aiRecipeFirstItem[009] = 026
       _aiRecipeLastItem[009] = 028
      _aiRecipeIngredient0[026] = 01 ;;; LeatherStrips
        _aiRecipeQuantity0[026] =  2
      _aiRecipeIngredient0[027] = 07 ;;; IngotIron
        _aiRecipeQuantity0[027] =  1
      _aiRecipeIngredient0[028] = 12 ;;; IngotSteel
        _aiRecipeQuantity0[028] =  2

      _aoRecipeItemId[010]    = 0x00013955 ;;; Steel Shield
      _aiRecipeFirstItem[010] = 029
       _aiRecipeLastItem[010] = 031
      _aiRecipeIngredient0[029] = 01 ;;; LeatherStrips
        _aiRecipeQuantity0[029] =  1
      _aiRecipeIngredient0[030] = 07 ;;; IngotIron
        _aiRecipeQuantity0[030] =  1
      _aiRecipeIngredient0[031] = 12 ;;; IngotSteel
        _aiRecipeQuantity0[031] =  3

      _aoRecipeItemId[011]    = 0x00013989 ;;; Steel Sword ;;;
      _aiRecipeFirstItem[011] = 032
       _aiRecipeLastItem[011] = 034
      _aiRecipeIngredient0[032] = 01 ;;; LeatherStrips
        _aiRecipeQuantity0[032] =  1
      _aiRecipeIngredient0[033] = 07 ;;; IngotIron
        _aiRecipeQuantity0[033] =  1
      _aiRecipeIngredient0[034] = 12 ;;; IngotSteel
        _aiRecipeQuantity0[034] =  2

      ;;;;;;;;;;;;;;;;;;;;;  Item Set: Orcish          ;;;;;;;;;;;;;;;;;;;;;;;;;
      _aoSetRequiredPerk[02] = _oPerkSmithOrcish
         _aoSetFirstItem[02] = 012
          _aoSetLastItem[02] = 017

      _aoRecipeItemId[012]    = 0x00013957 ;;; Orcish Armor ;;;
      _aiRecipeFirstItem[012] = 035
       _aiRecipeLastItem[012] = 037
      _aiRecipeIngredient0[035] = 01 ;;; LeatherStrips
        _aiRecipeQuantity0[035] =  3
      _aiRecipeIngredient0[036] = 07 ;;; IngotIron
        _aiRecipeQuantity0[036] =  1
      _aiRecipeIngredient0[037] = 09 ;;; IngotOrichalcum
        _aiRecipeQuantity0[037] =  4

      _aoRecipeItemId[013]    = 0x00013956 ;;; Orcish Boots ;;;
      _aiRecipeFirstItem[013] = 038
       _aiRecipeLastItem[013] = 040
      _aiRecipeIngredient0[038] = 01 ;;; LeatherStrips
        _aiRecipeQuantity0[038] =  2
      _aiRecipeIngredient0[039] = 07 ;;; IngotIron
        _aiRecipeQuantity0[039] =  1
      _aiRecipeIngredient0[040] = 09 ;;; IngotOrichalcum
        _aiRecipeQuantity0[040] =  3

      _aoRecipeItemId[014]    = 0x00013958 ;;; Orcish Gauntlets ;;;
      _aiRecipeFirstItem[014] = 041
       _aiRecipeLastItem[014] = 043
      _aiRecipeIngredient0[041] = 01 ;;; LeatherStrips
        _aiRecipeQuantity0[041] =  2
      _aiRecipeIngredient0[042] = 07 ;;; IngotIron
        _aiRecipeQuantity0[042] =  1
      _aiRecipeIngredient0[043] = 09 ;;; IngotOrichalcum
        _aiRecipeQuantity0[043] =  2

      _aoRecipeItemId[015]    = 0x00013959 ;;; Orcish Helmet ;;;
      _aiRecipeFirstItem[015] = 044
       _aiRecipeLastItem[015] = 046
      _aiRecipeIngredient0[044] = 01 ;;; LeatherStrips
        _aiRecipeQuantity0[044] =  2
      _aiRecipeIngredient0[045] = 07 ;;; IngotIron
        _aiRecipeQuantity0[045] =  1
      _aiRecipeIngredient0[046] = 09 ;;; IngotOrichalcum
        _aiRecipeQuantity0[046] =  2

      _aoRecipeItemId[016]    = 0x00013946 ;;; Orcish Shield ;;;
      _aiRecipeFirstItem[016] = 047
       _aiRecipeLastItem[016] = 049
      _aiRecipeIngredient0[047] = 01 ;;; LeatherStrips
        _aiRecipeQuantity0[047] =  1
      _aiRecipeIngredient0[048] = 07 ;;; IngotIron
        _aiRecipeQuantity0[048] =  1
      _aiRecipeIngredient0[049] = 09 ;;; IngotOrichalcum
        _aiRecipeQuantity0[049] =  3

      _aoRecipeItemId[017]    = 0x00013991 ;;; Orcish Sword ;;;
      _aiRecipeFirstItem[017] = 050
       _aiRecipeLastItem[017] = 052
      _aiRecipeIngredient0[050] = 01 ;;; LeatherStrips
        _aiRecipeQuantity0[050] =  1
      _aiRecipeIngredient0[051] = 07 ;;; IngotIron
        _aiRecipeQuantity0[051] =  1
      _aiRecipeIngredient0[052] = 09 ;;; IngotOrichalcum
        _aiRecipeQuantity0[052] =  1


      ;;;;;;;;;;;;;;;;;;;;;  Item Set: Elven           ;;;;;;;;;;;;;;;;;;;;;;;;;
      _aoSetRequiredPerk[03] = _oPerkSmithElven
         _aoSetFirstItem[03] = 018
          _aoSetLastItem[03] = 023

      _aoRecipeItemId[018]    = 0x0001392A ;;; Elven Gilded Armor ;;;
      _aiRecipeFirstItem[018] = 053
       _aiRecipeLastItem[018] = 056
      _aiRecipeIngredient0[053] = 01 ;;; LeatherStrips
        _aiRecipeQuantity0[053] =  3
      _aiRecipeIngredient0[054] = 06 ;;; IngotMoonstone
        _aiRecipeQuantity0[054] =  4
      _aiRecipeIngredient0[055] = 07 ;;; IngotIron
        _aiRecipeQuantity0[055] =  1
      _aiRecipeIngredient0[056] = 10 ;;; IngotQuicksilver
        _aiRecipeQuantity0[056] =  1

      _aoRecipeItemId[019]    = 0x0001391A ;;; Elven Boots ;;;
      _aiRecipeFirstItem[019] = 057
       _aiRecipeLastItem[019] = 060
      _aiRecipeIngredient0[057] = 00 ;;; Leather01
        _aiRecipeQuantity0[057] =  1
      _aiRecipeIngredient0[058] = 01 ;;; LeatherStrips
        _aiRecipeQuantity0[058] =  2
      _aiRecipeIngredient0[059] = 06 ;;; IngotMoonstone
        _aiRecipeQuantity0[059] =  2
      _aiRecipeIngredient0[060] = 07 ;;; IngotIron
        _aiRecipeQuantity0[060] =  1

      _aoRecipeItemId[020]    = 0x0001391C ;;; Elven Gauntlets ;;;
      _aiRecipeFirstItem[020] = 061
       _aiRecipeLastItem[020] = 064
      _aiRecipeIngredient0[061] = 00 ;;; Leather01
        _aiRecipeQuantity0[061] =  1
      _aiRecipeIngredient0[062] = 01 ;;; LeatherStrips
        _aiRecipeQuantity0[062] =  2
      _aiRecipeIngredient0[063] = 06 ;;; IngotMoonstone
        _aiRecipeQuantity0[063] =  1
      _aiRecipeIngredient0[064] = 07 ;;; IngotIron
        _aiRecipeQuantity0[064] =  1

      _aoRecipeItemId[021]    = 0x0001391D ;;; Elven Helmet ;;;
      _aiRecipeFirstItem[021] = 065
       _aiRecipeLastItem[021] = 068
      _aiRecipeIngredient0[065] = 00 ;;; Leather01
        _aiRecipeQuantity0[065] =  1
      _aiRecipeIngredient0[066] = 01 ;;; LeatherStrips
        _aiRecipeQuantity0[066] =  1
      _aiRecipeIngredient0[067] = 06 ;;; IngotMoonstone
        _aiRecipeQuantity0[067] =  2
      _aiRecipeIngredient0[068] = 07 ;;; IngotIron
        _aiRecipeQuantity0[068] =  1

      _aoRecipeItemId[022]    = 0x0001391E ;;; Elven Shield ;;;
      _aiRecipeFirstItem[022] = 069
       _aiRecipeLastItem[022] = 071
      _aiRecipeIngredient0[069] = 01 ;;; LeatherStrips
        _aiRecipeQuantity0[069] =  2
      _aiRecipeIngredient0[070] = 06 ;;; IngotMoonstone
        _aiRecipeQuantity0[070] =  4
      _aiRecipeIngredient0[071] = 07 ;;; IngotIron
        _aiRecipeQuantity0[071] =  1

      _aoRecipeItemId[023]    = 0x000139A1 ;;; Elven Sword ;;;
      _aiRecipeFirstItem[023] = 072
       _aiRecipeLastItem[023] = 075
      _aiRecipeIngredient0[072] = 01 ;;; LeatherStrips
        _aiRecipeQuantity0[072] =  1
      _aiRecipeIngredient0[073] = 06 ;;; IngotMoonstone
        _aiRecipeQuantity0[073] =  1
      _aiRecipeIngredient0[074] = 07 ;;; IngotIron
        _aiRecipeQuantity0[074] =  1
      _aiRecipeIngredient0[075] = 10 ;;; IngotQuicksilver
        _aiRecipeQuantity0[075] =  1

      ;;;;;;;;;;;;;;;;;;;;;  Item Set: Ebony           ;;;;;;;;;;;;;;;;;;;;;;;;;
      _aoSetRequiredPerk[04] = _oPerkSmithEbony
         _aoSetFirstItem[04] = 024
          _aoSetLastItem[04] = 029

      _aoRecipeItemId[024]    = 0x00013961 ;;; Ebony Armor ;;;
      _aiRecipeFirstItem[024] = 076
       _aiRecipeLastItem[024] = 077
      _aiRecipeIngredient0[076] = 01 ;;; LeatherStrips
        _aiRecipeQuantity0[076] =  3
      _aiRecipeIngredient0[077] = 04 ;;; IngotEbony
        _aiRecipeQuantity0[077] =  5

      _aoRecipeItemId[025]    = 0x00013960 ;;; Ebony Boots ;;;
      _aiRecipeFirstItem[025] = 078
       _aiRecipeLastItem[025] = 079
      _aiRecipeIngredient0[078] = 01 ;;; LeatherStrips
        _aiRecipeQuantity0[078] =  2
      _aiRecipeIngredient0[079] = 04 ;;; IngotEbony
        _aiRecipeQuantity0[079] =  3

      _aoRecipeItemId[026]    = 0x00013962 ;;; Ebony Gauntlets ;;;
      _aiRecipeFirstItem[026] = 080
       _aiRecipeLastItem[026] = 081
      _aiRecipeIngredient0[080] = 01 ;;; LeatherStrips
        _aiRecipeQuantity0[080] =  2
      _aiRecipeIngredient0[081] = 04 ;;; IngotEbony
        _aiRecipeQuantity0[081] =  2

      _aoRecipeItemId[027]    = 0x00013963 ;;; Ebony Helmet ;;;
      _aiRecipeFirstItem[027] = 082
       _aiRecipeLastItem[027] = 083
      _aiRecipeIngredient0[082] = 01 ;;; LeatherStrips
        _aiRecipeQuantity0[082] =  2
      _aiRecipeIngredient0[083] = 04 ;;; IngotEbony
        _aiRecipeQuantity0[083] =  3

      _aoRecipeItemId[028]    = 0x00013964 ;;; Ebony Shield ;;;
      _aiRecipeFirstItem[028] = 084
       _aiRecipeLastItem[028] = 085
      _aiRecipeIngredient0[084] = 01 ;;; LeatherStrips
        _aiRecipeQuantity0[084] =  1
      _aiRecipeIngredient0[085] = 04 ;;; IngotEbony
        _aiRecipeQuantity0[085] =  4

      _aoRecipeItemId[098]    = 0x000139B1 ;;; Ebony Sword ;;;
      _aiRecipeFirstItem[029] = 086
       _aiRecipeLastItem[029] = 087
      _aiRecipeIngredient0[086] = 01 ;;; LeatherStrips
        _aiRecipeQuantity0[086] =  1
      _aiRecipeIngredient0[087] = 04 ;;; IngotEbony
        _aiRecipeQuantity0[087] =  1

      ;;;;;;;;;;;;;;;;;;;;;  Item Set: Glass           ;;;;;;;;;;;;;;;;;;;;;;;;;
      _aoSetRequiredPerk[05] = _oPerkSmithGlass
         _aoSetFirstItem[05] = 030
          _aoSetLastItem[05] = 035

      _aoRecipeItemId[030]    = 0x00013939 ;;; Glass Armor ;;;
      _aiRecipeFirstItem[030] = 088
       _aiRecipeLastItem[030] = 091
      _aiRecipeIngredient0[088] = 00 ;;; Leather01
        _aiRecipeQuantity0[088] =  1
      _aiRecipeIngredient0[089] = 01 ;;; LeatherStrips
        _aiRecipeQuantity0[089] =  3
      _aiRecipeIngredient0[090] = 06 ;;; IngotMoonstone
        _aiRecipeQuantity0[090] =  2
      _aiRecipeIngredient0[091] = 08 ;;; IngotMalachite
        _aiRecipeQuantity0[091] =  4

      _aoRecipeItemId[031]    = 0x00013938 ;;; Glass Boots ;;;
      _aiRecipeFirstItem[031] = 092
       _aiRecipeLastItem[031] = 095
      _aiRecipeIngredient0[092] = 00 ;;; Leather01
        _aiRecipeQuantity0[092] =  1
      _aiRecipeIngredient0[093] = 01 ;;; LeatherStrips
        _aiRecipeQuantity0[093] =  2
      _aiRecipeIngredient0[094] = 06 ;;; IngotMoonstone
        _aiRecipeQuantity0[094] =  1
      _aiRecipeIngredient0[095] = 08 ;;; IngotMalachite
        _aiRecipeQuantity0[095] =  2

      _aoRecipeItemId[032]    = 0x0001393A ;;; Glass Gauntlets ;;;
      _aiRecipeFirstItem[032] = 096
       _aiRecipeLastItem[032] = 099
      _aiRecipeIngredient0[096] = 00 ;;; Leather01
        _aiRecipeQuantity0[096] =  1
      _aiRecipeIngredient0[097] = 01 ;;; LeatherStrips
        _aiRecipeQuantity0[097] =  2
      _aiRecipeIngredient0[098] = 06 ;;; IngotMoonstone
        _aiRecipeQuantity0[098] =  1
      _aiRecipeIngredient0[099] = 08 ;;; IngotMalachite
        _aiRecipeQuantity0[099] =  1

      _aoRecipeItemId[033]    = 0x0001393B ;;; Glass Helmet ;;;
      _aiRecipeFirstItem[033] = 100
       _aiRecipeLastItem[033] = 103
      _aiRecipeIngredient0[100] = 00 ;;; Leather01
        _aiRecipeQuantity0[100] =  1
      _aiRecipeIngredient0[101] = 01 ;;; LeatherStrips
        _aiRecipeQuantity0[101] =  1
      _aiRecipeIngredient0[102] = 06 ;;; IngotMoonstone
        _aiRecipeQuantity0[102] =  1
      _aiRecipeIngredient0[103] = 08 ;;; IngotMalachite
        _aiRecipeQuantity0[103] =  2

      _aoRecipeItemId[034]    = 0x0001393C ;;; Glass Shield ;;;
      _aiRecipeFirstItem[034] = 104
       _aiRecipeLastItem[034] = 106
      _aiRecipeIngredient0[104] = 01 ;;; LeatherStrips
        _aiRecipeQuantity0[104] =  2
      _aiRecipeIngredient0[105] = 06 ;;; IngotMoonstone
        _aiRecipeQuantity0[105] =  1
      _aiRecipeIngredient0[106] = 08 ;;; IngotMalachite
        _aiRecipeQuantity0[106] =  4

      _aoRecipeItemId[035]    = 0x000139A9 ;;; Glass Sword ;;;
      _aiRecipeFirstItem[035] = 107
       _aiRecipeLastItem[035] = 110
      _aiRecipeIngredient0[107] = 00 ;;; Leather01
        _aiRecipeQuantity0[107] =  1
      _aiRecipeIngredient0[108] = 01 ;;; LeatherStrips
        _aiRecipeQuantity0[108] =  1
      _aiRecipeIngredient0[109] = 06 ;;; IngotMoonstone
        _aiRecipeQuantity0[109] =  1
      _aiRecipeIngredient0[110] = 08 ;;; IngotMalachite
        _aiRecipeQuantity0[110] =  1

      ;;;;;;;;;;;;;;;;;;;;;  Item Set: Daedric         ;;;;;;;;;;;;;;;;;;;;;;;;;
      _aoSetRequiredPerk[06] = _oPerkSmithDaedric
         _aoSetFirstItem[06] = 036
          _aoSetLastItem[06] = 041

      _aoRecipeItemId[36] = 0x0001396B ;;; Daedric Armor ;;;
      _aiRecipeFirstItem[36] = 111
       _aiRecipeLastItem[36] = 113
      _aiRecipeIngredient0[111] = 01 ;;; LeatherStrips
        _aiRecipeQuantity0[111] =  3
      _aiRecipeIngredient0[112] = 04 ;;; IngotEbony
        _aiRecipeQuantity0[112] =  5
      _aiRecipeIngredient0[113] = 18 ;;; DaedraHeart
        _aiRecipeQuantity0[113] =  1

      _aoRecipeItemId[37] = 0x0001396A ;;; Daedric Boots ;;;
      _aiRecipeFirstItem[37] = 114
       _aiRecipeLastItem[37] = 116
      _aiRecipeIngredient0[114] = 01 ;;; LeatherStrips
        _aiRecipeQuantity0[114] =  2
      _aiRecipeIngredient0[115] = 04 ;;; IngotEbony
        _aiRecipeQuantity0[115] =  3
      _aiRecipeIngredient0[116] = 18 ;;; DaedraHeart
        _aiRecipeQuantity0[116] =  1

      _aoRecipeItemId[38] = 0x0001396C ;;; Daedric Gauntlets ;;;
      _aiRecipeFirstItem[38] = 117
       _aiRecipeLastItem[38] = 119
      _aiRecipeIngredient0[117] = 01 ;;; LeatherStrips
        _aiRecipeQuantity0[117] =  2
      _aiRecipeIngredient0[118] = 04 ;;; IngotEbony
        _aiRecipeQuantity0[118] =  2
      _aiRecipeIngredient0[119] = 18 ;;; DaedraHeart
        _aiRecipeQuantity0[119] =  1

      _aoRecipeItemId[39] = 0x0001396D ;;; Daedric Helmet ;;;
      _aiRecipeFirstItem[39] = 120
       _aiRecipeLastItem[39] = 122
      _aiRecipeIngredient0[120] = 01 ;;; LeatherStrips
        _aiRecipeQuantity0[120] =  2
      _aiRecipeIngredient0[121] = 04 ;;; IngotEbony
        _aiRecipeQuantity0[121] =  3
      _aiRecipeIngredient0[122] = 18 ;;; DaedraHeart
        _aiRecipeQuantity0[122] =  1

      _aoRecipeItemId[40] = 0x0001396E ;;; Daedric Shield ;;;
      _aiRecipeFirstItem[40] = 123
       _aiRecipeLastItem[40] = 125
      _aiRecipeIngredient0[123] = 01 ;;; LeatherStrips
        _aiRecipeQuantity0[123] =  1
      _aiRecipeIngredient0[124] = 04 ;;; IngotEbony
        _aiRecipeQuantity0[124] =  4
      _aiRecipeIngredient0[125] = 18 ;;; DaedraHeart
        _aiRecipeQuantity0[125] =  1


      ;;; Everything after this point references items in the second ingredient array. ;;;
      ;;; Each item after this point will explicitly set the array to the right value. ;;;


      _aoRecipeItemId[41] = 0x000139B9 ;;; Daedric Sword ;;;
      _aiRecipeFirstItem[41] = 000
       _aiRecipeLastItem[41] = 002
      _aiIngredientArray[41] = 1
      _aiRecipeIngredient1[000] = 01 ;;; LeatherStrips
        _aiRecipeQuantity1[000] =  1
      _aiRecipeIngredient1[001] = 04 ;;; IngotEbony
        _aiRecipeQuantity1[001] =  2
      _aiRecipeIngredient1[002] = 18 ;;; DaedraHeart
        _aiRecipeQuantity1[002] =  1

      ;;;;;;;;;;;;;;;;;;;;;  Item Set: Dragon Scale   ;;;;;;;;;;;;;;;;;;;;;;;;;;
      _aoSetRequiredPerk[07] = _oPerkSmithDragon
         _aoSetFirstItem[07] = 042
          _aoSetLastItem[07] = 047

      _aoRecipeItemId[42]    = 0x0001393D ;;; ArmorDragonscaleBoots ;;;
      _aiRecipeFirstItem[42] = 003
       _aiRecipeLastItem[42] = 006
      _aiIngredientArray[42] = 1
      _aiRecipeIngredient1[003] = 00 ;;; Leather01
        _aiRecipeQuantity1[003] =  1
      _aiRecipeIngredient1[004] = 01 ;;; LeatherStrips
        _aiRecipeQuantity1[004] =  2
      _aiRecipeIngredient1[005] = 07 ;;; IngotIron
        _aiRecipeQuantity1[005] =  1
      _aiRecipeIngredient1[006] = 14 ;;; DragonScale
        _aiRecipeQuantity1[006] =  2

      _aoRecipeItemId[43] = 0x0001393E ;;; ArmorDragonscaleCurias ;;;
      _aiRecipeFirstItem[43] = 007
       _aiRecipeLastItem[43] = 010
      _aiIngredientArray[43] = 1
      _aiRecipeIngredient1[007] = 00 ;;; Leather01
        _aiRecipeQuantity1[007] =  1
      _aiRecipeIngredient1[008] = 01 ;;; LeatherStrips
        _aiRecipeQuantity1[008] =  3
      _aiRecipeIngredient1[009] = 07 ;;; IngotIron
        _aiRecipeQuantity1[009] =  2
      _aiRecipeIngredient1[010] = 14 ;;; DragonScale
        _aiRecipeQuantity1[010] =  4

      _aoRecipeItemId[44] = 0x0001393F ;;; ArmorDragonscaleGuantlets ;;;
      _aiRecipeFirstItem[44] = 011
       _aiRecipeLastItem[44] = 014
      _aiIngredientArray[44] = 1
      _aiRecipeIngredient1[011] = 00 ;;; Leather01
        _aiRecipeQuantity1[011] =  1
      _aiRecipeIngredient1[012] = 01 ;;; LeatherStrips
        _aiRecipeQuantity1[012] =  2
      _aiRecipeIngredient1[013] = 07 ;;; IngotIron
        _aiRecipeQuantity1[013] =  1
      _aiRecipeIngredient1[014] = 14 ;;; DragonScale
        _aiRecipeQuantity1[014] =  2

      _aoRecipeItemId[45] = 0x00013940 ;;; ArmorDragonscaleHelmet ;;;
      _aiRecipeFirstItem[45] = 015
       _aiRecipeLastItem[45] = 018
      _aiIngredientArray[45] = 1
      _aiRecipeIngredient1[015] = 00 ;;; Leather01
        _aiRecipeQuantity1[015] =  1
      _aiRecipeIngredient1[016] = 01 ;;; LeatherStrips
        _aiRecipeQuantity1[016] =  1
      _aiRecipeIngredient1[017] = 07 ;;; IngotIron
        _aiRecipeQuantity1[017] =  1
      _aiRecipeIngredient1[018] = 14 ;;; DragonScale
        _aiRecipeQuantity1[018] =  2

      _aoRecipeItemId[46] = 0x00013941 ;;; ArmorDragonscaleShield ;;;
      _aiRecipeFirstItem[46] = 019
       _aiRecipeLastItem[46] = 021
      _aiIngredientArray[46] = 1
      _aiRecipeIngredient1[019] = 01 ;;; LeatherStrips
        _aiRecipeQuantity1[019] =  2
      _aiRecipeIngredient1[020] = 07 ;;; IngotIron
        _aiRecipeQuantity1[020] =  2
      _aiRecipeIngredient1[021] = 14 ;;; DragonScale
        _aiRecipeQuantity1[021] =  4

      _aoRecipeItemId[47] = 0x000139A9 ;;; GlassSword ;;;
      _aiRecipeFirstItem[47] = 022
       _aiRecipeLastItem[47] = 024
      _aiIngredientArray[47] = 1
      _aiRecipeIngredient1[022] = 01 ;;; LeatherStrips
        _aiRecipeQuantity1[022] =  1
      _aiRecipeIngredient1[023] = 06 ;;; IngotMoonstone
        _aiRecipeQuantity1[023] =  1
      _aiRecipeIngredient1[024] = 08 ;;; IngotMalachite
        _aiRecipeQuantity1[024] =  1

      ;;;;;;;;;;;;;;;;;;;;;  Item Set: Dragon Bone     ;;;;;;;;;;;;;;;;;;;;;;;;;
      _aoSetRequiredPerk[08] = _oPerkSmithDragon
         _aoSetFirstItem[08] = 048
          _aoSetLastItem[08] = 053

      _aoRecipeItemId[48] = 0x00013965 ;;; ArmorDragonplateBoots ;;;
      _aiRecipeFirstItem[48] = 025
       _aiRecipeLastItem[48] = 027
      _aiIngredientArray[48] = 1
      _aiRecipeIngredient1[025] = 01 ;;; LeatherStrips
        _aiRecipeQuantity1[025] =  2
      _aiRecipeIngredient1[026] = 13 ;;; DragonBone
        _aiRecipeQuantity1[026] =  1
      _aiRecipeIngredient1[027] = 14 ;;; DragonScale
        _aiRecipeQuantity1[027] =  3

      _aoRecipeItemId[49] = 0x00013966 ;;; ArmorDragonplateCurias ;;;
      _aiRecipeFirstItem[49] = 028
       _aiRecipeLastItem[49] = 030
      _aiIngredientArray[49] = 1
      _aiRecipeIngredient1[028] = 01 ;;; LeatherStrips
        _aiRecipeQuantity1[028] =  3
      _aiRecipeIngredient1[029] = 13 ;;; DragonBone
        _aiRecipeQuantity1[029] =  2
      _aiRecipeIngredient1[030] = 14 ;;; DragonScale
        _aiRecipeQuantity1[030] =  3

      _aoRecipeItemId[50] = 0x00013967 ;;; ArmorDragonplateGuantlets ;;;
      _aiRecipeFirstItem[50] = 031
       _aiRecipeLastItem[50] = 033
      _aiIngredientArray[50] = 1
      _aiRecipeIngredient1[031] = 01 ;;; LeatherStrips
        _aiRecipeQuantity1[031] =  2
      _aiRecipeIngredient1[032] = 13 ;;; DragonBone
        _aiRecipeQuantity1[032] =  1
      _aiRecipeIngredient1[033] = 14 ;;; DragonScale
        _aiRecipeQuantity1[033] =  2

      _aoRecipeItemId[51] = 0x00013969 ;;; ArmorDragonplateHelmet ;;;
      _aiRecipeFirstItem[51] = 034
       _aiRecipeLastItem[51] = 036
      _aiIngredientArray[51] = 1
      _aiRecipeIngredient1[034] = 01 ;;; LeatherStrips
        _aiRecipeQuantity1[034] =  2
      _aiRecipeIngredient1[035] = 13 ;;; DragonBone
        _aiRecipeQuantity1[035] =  1
      _aiRecipeIngredient1[036] = 14 ;;; DragonScale
        _aiRecipeQuantity1[036] =  2

      _aoRecipeItemId[52] = 0x00013968 ;;; ArmorDragonplateShield ;;;
      _aiRecipeFirstItem[52] = 037
       _aiRecipeLastItem[52] = 039
      _aiIngredientArray[52] = 1
      _aiRecipeIngredient1[037] = 01 ;;; LeatherStrips
        _aiRecipeQuantity1[037] =  1
      _aiRecipeIngredient1[038] = 13 ;;; DragonBone
        _aiRecipeQuantity1[038] =  1
      _aiRecipeIngredient1[039] = 14 ;;; DragonScale
        _aiRecipeQuantity1[039] =  3

      _aoRecipeItemId[53] = 0x000139B9 ;;; DaedricSword ;;;
      _aiRecipeFirstItem[53] = 040
       _aiRecipeLastItem[53] = 042
      _aiIngredientArray[53] = 1
      _aiRecipeIngredient1[040] = 01 ;;; LeatherStrips
        _aiRecipeQuantity1[040] =  1
      _aiRecipeIngredient1[041] = 04 ;;; IngotEbony
        _aiRecipeQuantity1[041] =  2
      _aiRecipeIngredient1[042] = 18 ;;; DaedraHeart
        _aiRecipeQuantity1[042] =  1

      ;;;;;;;;;;;;;;;;;;;;;  Item Set: Healing Potion  ;;;;;;;;;;;;;;;;;;;;;;;;;
      _aoSetRequiredPerk[09] = None
         _aoSetFirstItem[09] = 054
          _aoSetLastItem[09] = 054

      _aoRecipeItemId[54] = -2 ;;; User Created Potion ;;;
      _aiRecipeFirstItem[54] = 043
       _aiRecipeLastItem[54] = 044
      _aiIngredientArray[54] = 1
      _aiRecipeIngredient1[043] = 17 ;;; CharredSkeeverHide
        _aiRecipeQuantity1[043] =  1
      _aiRecipeIngredient1[044] = 19 ;;; DragonflyBlue
        _aiRecipeQuantity1[044] =  1

      ;;; Remember to update array sizes and this If () condition when adding new sets. ;;;
      ;;; Remember to update array sizes and this If () condition when adding new sets. ;;;
      ;v; Remember to update array sizes and this If () condition when adding new sets. ;;;
   EndIf
EndFunction

Function InitSimpleSlaveryAuctions()
   DebugTrace("TraceEvent InitSimpleSlaveryAuctions")
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
   DebugTrace("TraceEvent InitSimpleSlaveryAuctions: Done")
EndFunction


;***********************************************************************************************
;***                                        EVENTS                                           ***
;***********************************************************************************************
; The OnUpdate() code is in a wrapper, PerformOnUpdate().  This is to allow us to return from
; the function without having to add code to re-register for the update at each return point.
Event OnUpdate()
   ;Off-DebugTrace("TraceEvent OnUpdate")
   ; If the script has not been initialized do that instead of performing the update.
   If (!_fCurrVer)
      OnLoadGame()
   ElseIf (_bMcmShutdownMod)
      ; If we are shutting down the mod don't process any requests/events.
      DebugTrace("TraceEvent OnUpdate: Done (Shutting Down)")
      Self.Stop()
      Return
   ElseIf (_iCurrDialogue)
      ; There is a current dialogue.  Monitor it.
      Float fSecurity = 180.0
      DebugTrace("Monitoring Dialogue: " + _iCurrDialogue + "-" + _iCurrDialogueStage)
      While ((0.0 < fSecurity) && _iCurrDialogue && _aCurrDialogueTarget && \
             _aCurrDialogueTarget.IsInDialogueWithPlayer())
         Utility.Wait(0.1)
         fSecurity -= 0.1
      EndWhile

      ; If the dialogue completed via the DialogueComplete() system give it time to do its
      ; processing before we wrap up the dialogue here.
      fSecurity = 30.0
      While (_bCurrDialogueEnding && (0.0 < fSecurity))
         Utility.Wait(0.1)
         fSecurity -= 0.1
      EndWhile
      _bCurrDialogueEnding = False

      DebugTrace("Monitoring Dialogue: Done")
      If (!fSecurity)
         ; TODO: The dialgoue timed out.  Not sure what to do here.
         Log("Dialogue Timed Out: " + _iCurrDialogue + "-" + _iCurrDialogueStage, DL_DEBUG, \
             S_MOD)
      ElseIf (!_aCurrDialogueTarget)
         ; TODO: Why is there no agressor.  We shouldn't change scene data until the scene ends.
         Log("Dialogue No Aggressor: " + _iCurrDialogue + "-" + _iCurrDialogueStage, DL_DEBUG, \
             S_MOD)
      ElseIf (_iCurrDialogue)
         ; TODO: The dialogue ended prematurely initiate the appropriate measures.
         Log("Dialogue Ended Early: " + _iCurrDialogue + "-" + _iCurrDialogueStage, DL_DEBUG, \
             S_MOD)

         EndDialogue(_aCurrDialogueTarget, 1)
      EndIf

      ; TODO: Advancing scene stages should be single dialogue parameter flag to check rather
      ; than checking for a number of dialogues individually.
      If (14 == _iCurrDialogue)
         ModifySceneStage(iDelta=1)
      EndIf

      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      ;;; CULPRIT: Cannot talk to slaver bug!!!  Also Related to Exclusive Dialogues!!! ;;;
      ;;; Especially Branch _dfwsLeashWillingToBehave as Exclusive breaks dialogue!!!   ;;;
      ;;; See https://www.creationkit.com/index.php?title=Dialogue_Branch section       ;;;
      ;;; Exclusive Branches.                                                           ;;;
      _iCurrDialogue = 0                                                                ;;;
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

      _iCurrDialogueStage = 0
      _aCurrDialogueTarget = None

      ; Choose a random path for the next dialogue.
      _iCurrDialoguePath = Utility.RandomInt(1, 100)
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
         ElseIf (!_oMittens)
            FindMittens(_aLeashHolder)
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
   ;Off-DebugTrace("TraceEvent OnUpdate: Done")
EndEvent

Function PerformOnUpdate()
   Float fCurrRealTime = Utility.GetCurrentRealTime()
   DebugTrace("TraceEvent PerformOnUpdate - " + fCurrRealTime)

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
DebugTrace("PerformOnUpdate-CP: Pre Basic Checks")
   If (0 < _iMovementSafety)
      _iMovementSafety -= 1
      If (0 >= _iMovementSafety)
;Off-DebugTrace("PerformOnUpdate: Movement Safety Expired")
         ReMobilizePlayer()
      EndIf
   EndIf

   ; Tick up/down any dialogue timers that may need to be ticked.
   If (1 < _iDialogueFurnitureLocked)
      _iDialogueFurnitureLocked -= 1
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

   ; Keep track of whether the player is enslaved through any means.
   Bool bEnslaved

   ; Check if the player is enslaved by Sanguine's Debauchery (SD+).
DebugTrace("PerformOnUpdate-CP: Checking SD+")
   If (_bMcmCatchSdPlus && _bEnslavedSdPlus)
      ; We think the player is enslaved.  Verify that she actually is.
      If (0 >= StorageUtil.GetIntValue(_aPlayer, "_SD_iEnslaved"))
         StopSdPlus()
      ElseIf (_qMcm.bLeashSdPlus)
         ; The player is still enslaved.  Manage her leashed based on her SD+ caged state.
         bEnslaved = True

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
DebugTrace("PerformOnUpdate-CP: Checking Punishments")
   If (3 == _iAgendaLongTerm)
      ; TODO: Fix this.  This value is recorded incorrectly!
      _fTimePunished += _fMcmPollTime
      If (0 < _iBlindfoldRemaining)
         _iBlindfoldRemaining -= 1
         If (!_iBlindfoldRemaining)
            ; Don't release it now in case there are more important goals to take care of.
            ; Just set a flag and make sure it is released later on in the stack.
            _bReleaseBlindfold = True
         EndIf
      EndIf
      Bool bFurnitureWasOn = (0 < _iFurnitureRemaining)
      ; If no punishments have time remaining that means the slaver is actively considering
      ; ending one or more of the player's punishments.  This whole feature needs to be cleaned
      ; up but for now just treat it as if the furniture punishment is on.
      If ((_oBdsmFurniture || _bIsPlayerCaged) && \
          (!(_iBlindfoldRemaining || _iGagRemaining || _iFurnitureRemaining || _iCrawlRemaining)))
         bFurnitureWasOn = True
      EndIf
      If (0 < _iFurnitureRemaining)
         _iFurnitureRemaining -= 1
         If (!_iFurnitureRemaining)
            ; 4: Start Scene.  Scene 7: Return to the leash game.
            AddPendingAction(4, 7, _aLeashHolder, S_MOD + "_Return")

; TODO: Remove the old _Return path.
;            ; Sex was allowed while the player was being punished.  Revoke that now.
;            If (!_qMcm.bAllowSex)
;               _qFramework.RemovePermission(_aLeashHolder, _qFramework.AP_SEX)
;            EndIf
;            _oPunishmentFurniture = None
;            _qFramework.ApproachPlayer(_aLeashHolder, 300, 2, S_MOD + "_Return")
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
      If (0 < _iCrawlRemaining)
         ; Decrease the player's crawling punishment.  If it expires don't worry about telling
         ; her.  She can figure out that it has ended on her own.
         _iCrawlRemaining -= 1

         ; If the player no longer needs to crawl, lock her back in an arm binder.
         If (!_iCrawlRemaining)
            ; TODO: Eventually we probably want a scene name here but it conflicts with the
            ;       assault which already has a scene name.
            ; 2: Assault Player. 0x0004: Bind Arms (implies Unbind Mittens)
            AddPendingAction(2, 0x0004, _aLeashHolder, iSceneTimeout=60, bPrepend=True)
         EndIf

         ; Make sure the player is crawling.
         ; 0x0100: The pose is considred crawling.
         ; 0x0080: The pose is considred kneeling.
         If (Math.LogicalAnd(0x0100 + 0x0080, _qFramework.GetCurrPoseFlags()))
            ; The player is obeying.
            _iResistCrawlCount = 0
            _qFramework.HoverAtClear(S_MOD + "_ForceCrawl")
         Else
            ; Check if the player needs further incentive.
            _iResistCrawlCount += 1
            If (3 == _iResistCrawlCount)
               ; Have the slaver stand by the player until she obeys.
               _qFramework.HoverAt(_aLeashHolder, _aPlayer, S_MOD + "_ForceCrawl")

               ; 7: Order the player to crawl.
               _iCurrDialogue = 7
               _aCurrDialogueTarget = _aLeashHolder
               StartConversation(_aLeashHolder, iTimeout=3)
            ElseIf (25 < _iResistCrawlCount)
               If (!(_iResistCrawlCount % 5))
                  _qFramework.YankLeash(bForceDamage=True)
               EndIf
            ElseIf (!(_iResistCrawlCount % 12))
               _qFramework.YankLeash(bForceDamage=True)
            ElseIf (!(_iResistCrawlCount % 6))
               ; The player is not obeying.  Increase her punishment time.
               _iCrawlRemaining += ((60 / _fMcmPollTime) As Int)

               ; 7: Order the player to crawl.
               _iCurrDialogue = 7
               _aCurrDialogueTarget = _aLeashHolder
               StartConversation(_aLeashHolder, iTimeout=3)
            EndIf
         EndIf
      EndIf
      ; TODO: We don't actually want to stop the punishment here.  This just means the time is
      ; up.  We don't want to stop the punishment until the slaver had confirmed with the player
      ; she will behave (or anything else needed to confirm the punishment will end).
      If (!bFurnitureWasOn && !(_iBlindfoldRemaining || _iGagRemaining || _iCrawlRemaining))
         _iAgendaLongTerm = 1
         _iDetailsLongTerm = 0
         _fTimePunished = 0.0
         _fTimeLastPunished = Utility.GetCurrentGameTime()
      EndIf
   EndIf

   ; If the player's master is on a temporary sandbox check to see if it is over.
DebugTrace("PerformOnUpdate-CP: Check Sandbox End")
   If (1 == _iAgendaMidTerm)
      If (_aLeashHolder)
         Int iSitState = _aLeashHolder.GetSitState()
         If (_bMasterSandboxIsSitting)
            ; If the leash holder just stood up clear some room for him to walk.
            If ((2 != iSitState) && (3 != iSitState))
               SlavesGiveSpace(_aLeashHolder)
               _bMasterSandboxIsSitting = False
            EndIf
         Else
            ; Make a note if the leash holder is now sitting.
            If ((2 == iSitState) || (3 == iSitState))
               _bMasterSandboxIsSitting = True
            EndIf
         EndIf
      EndIf

      Float fCurrGameTime = Utility.GetCurrentGameTime()
      If (!_fMasterSandboxTime)
         ; An end time has not been scheduled.  Schedule one now.
         _fMasterSandboxTime = fCurrGameTime + \
                               (Utility.RandomFloat(_qMcm.fWalkBreakMinDuration, \
                                                    _qMcm.fWalkBreakMaxDuration) / 24)
      ElseIf (_fMasterSandboxTime < fCurrGameTime)
         _iAgendaMidTerm = 0
         _fMasterSandboxTime = 0.0
         If (_aLeashHolder)
            _qFramework.ReEvaluatePackage(_aLeashHolder)
         EndIf
         Actor aFurnitureLocker = (_aAliasFurnitureLocker.GetReference() As Actor)
         If (aFurnitureLocker)
            _qFramework.ReEvaluatePackage(aFurnitureLocker)
         EndIf
      EndIf
   EndIf


   If (_aLeashHolder)
      ; Manage all the behaveiour of the leash game.
      bEnslaved = True
      PlayLeashGame()
      DebugTrace("TraceEvent PlayLeashGame: Done")
   Else
      ;Off-DebugTrace("Update Event: No Leash Game.")
DebugTrace("PerformOnUpdate-CP: No Leash Game")

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
         PlayApproachAnimationOld(aNpc, "Assault")

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


DebugTrace("PerformOnUpdate-CP: Starting Furniture")
   ObjectReference oCurrFurniture = _qFramework.GetBdsmFurniture()
   If (_oBdsmFurniture && !_bIsPlayerCaged && !oCurrFurniture && \
       !_qFramework.IsBdsmFurnitureLocked())
      ; We think the player is locked in BDSM furniture but she isn't.
      _iDialogueFurnitureLocked = 0
      _iFurnitureExcuse = 0
      SetCurrFurniture(None)
   ElseIf ((_oBdsmFurniture || oCurrFurniture) && !_oPunishmentFurniture && \
           (2 != _iAgendaMidTerm))
      ; If the player is sitting in BDSM furniture, think about messing with her.

      If (_fFurnitureReleaseTime && (_fFurnitureReleaseTime < Utility.GetCurrentGameTime()))
         _fFurnitureReleaseTime = 0
         Log("You hear a click and the furniture unlocks.", DL_CRIT, S_MOD)
         _qFramework.SetBdsmFurnitureLocked(False)
         ;    EnablePlayerControls(Move,  Fight, Cam,   Look,  Sneak, Menu,  Activ, Journ)
         Game.EnablePlayerControls(True,  False, False, False, False, False, True,  False)
      EndIf

      ; If the player is free to move and no one is messing with her think about starting to.
      If (!_bFurnitureForFun && (0 >= _iLeashGameDuration) && !_aLeashHolder && \
          (Game.IsMovementControlsEnabled() || _fFurnitureReleaseTime))
         ; If the player was not previously sitting in the furniture take some actions.
         If (!_oBdsmFurniture)
            ; 1: Self inflicted.  The player entered the furniture of her own accord.
            _iFurnitureExcuse = 1

            ; Keep track of which furniture the player is sitting in.
            SetCurrFurniture(oCurrFurniture)

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
         Log("Furniture Roll: " + fRoll + " / " + fMaxChance, DL_TRACE, S_MOD)
         If ((fMaxChance > fRoll) && !_qSexLab.IsActorActive(_aPlayer))
            ; Find someone nearby to lock the player in the device.
            Actor aNearby = _qFramework.GetRandomActor(iIncludeFlags=_qFramework.AF_DOMINANT, \
                                                       iExcludeFlags=_qFramework.AF_GUARDS)
            If (aNearby && !_qFramework.SceneStarting(S_MOD, 60))
               _qFramework.SetBdsmFurnitureLocked()
               ;    DisablePlayerControls(Move,  Fight, Cam,   Look,  Sneak, Menu,  Active, Journ)
               Game.DisablePlayerControls(True,  False, False, False, False, False, True,   False)
DebugTrace("PerformOnUpdate: Movement Disabled - Locking Furniture")
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
      ElseIf (_bFurnitureForFun && !_qFramework.GetCurrentScene() && \
              !_qSexLab.IsActorActive(_aPlayer) && (0 >= _iLeashGameDuration))
         bEnslaved = True
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
         Log("Furniture End Roll: " + fRoll + " / " + fChance, DL_TRACE, S_MOD)
         If ((fChance > fRoll) && !_qFramework.SceneStarting(S_MOD + "_FRelease", 60))
            ; Add a pending action to release the player.
            ; 4: Start Scene.  Scene 2: Release the player.
            AddPendingAction(4, 2, aHelper, S_MOD + "_FRelease")
         Else
            bConsiderDialogue = True
         EndIf
      EndIf
   ElseIf (_oPunishmentFurniture && _oBdsmFurniture && (3 == _iAgendaLongTerm))
      ; The player is being punished in furniture.  She is available to be played with.
      bConsiderDialogue = True
   EndIf

   ; If the player is enslaved via any means, increase the time she has been enslaved.
   If (bEnslaved)
      _fTimeEnslaved += _fMcmPollTime
   EndIf

   ; If the player is locked in furniture, maybe find someone nearby to start a conversation.
DebugTrace("PerformOnUpdate-CP: Considering Dialogue " + bConsiderDialogue)
   If (bConsiderDialogue)
      Float fChance = _fMcmFurnitureVisitorChance
      ; Don't exclude guards here as it changes the atmosphere of being "remote".
      Actor aNearby = _qFramework.GetRandomActor(iExcludeFlags=_qFramework.AF_SUBMISSIVE + \
                                                               _qFramework.AF_SLAVE)
      If (!aNearby && _bIsPlayerRemote)
         fChance = _fMcmFurnitureRemoteVisitor
      EndIf
      Float fRoll = Utility.RandomFloat(0, 100)
      Log("Furniture Dialogue Roll: " + fRoll + " / " + fChance, DL_TRACE, S_MOD)
      If (fChance > fRoll)
         ; By default the harraser should be the one who locked the furniture.
         Actor aFurnitureLocker = (_aAliasFurnitureLocker.GetReference() As Actor)
         Actor aAgressor = aFurnitureLocker

         ; Sometimes use a random nearby NPC instead of the original locker.
         If (!aAgressor || !_qFramework.IsActorNearby(aAgressor) || \
             (50 >= Utility.RandomInt(1, 100)))
            ; Try to exclude guards here as their whippings can be lethal.
            aNearby = _qFramework.GetRandomActor(iExcludeFlags=_qFramework.AF_SUBMISSIVE + \
                                                               _qFramework.AF_SLAVE + \
                                                               _qFramework.AF_GUARDS)
            If (aNearby)
               aAgressor = aNearby
            EndIf
         EndIf

         Bool bEventSelected
         ; First see if we should preform a player transfer.
         If (_qMcm.iFurnitureTransferChance >= Utility.RandomInt(1, 100))
            ; We are performing a transfer.  Verify there the scene can be started.
            ; Scene 1: Transfer Furniture
            If (CanSceneStart(1))
               bEventSelected = True
               ; 4: Start Scene.  Scene 1: Transfer Furniture
               AddPendingAction(4, 1, aAgressor, S_MOD + "_FTransfer")

               ; Also consider adding a dialogue scene after the transfer occurs.
               If (50 >= Utility.RandomInt(1, 100))
                  ; 1: Start Conversation. 12: Furniture Predicament.
                  AddPendingAction(1, 12, aAgressor, S_MOD + "_FurnForFun")
               EndIf
            EndIf
         EndIf

         ; Next try to start a conversation.
         If (!bEventSelected && aAgressor && !_qFramework.GetPlayerTalkingTo() && \
             !_qSexLab.IsActorActive(_aPlayer) && \
             !_qFramework.SceneStarting(S_MOD + "_StartScene", 180))
            ; The furniture locker has just approached the player from ???
            ; Consider sandboxing nearby after the conversation.
            If ((aFurnitureLocker == aAgressor) && \
                (_qMcm.iFurnitureRemoteSandbox >= Utility.RandomInt(1, 100)))
               ; Only consider it if the furniture is in a remote area and sandboxing is nearby.
               Int iFlags = ToggleFurnitureFlag(_oBdsmFurniture, 0x0000)
               ; 0x0080: Remote
               ; 0x0100: Activity/Sandbox (NPCs can sandbox nearby)
               If ((0x0100 + 0x0080) == Math.LogicalAnd(0x0100 + 0x0080, iFlags))
                  ; 5: Start a Sandbox.
                  AddPendingAction(5, aActor=aAgressor, bPrepend=True)
               EndIf
            EndIf

            ; Schedule the Furniture For Fun conversation for once the player is approached.
            AddPendingAction(1, 12, aAgressor, S_MOD + "_FurnForFun", bPrepend=True)

            ; If the player is caged we want to approach the bars rather than the player.
            If (_bIsPlayerCaged)
               _qFramework.MoveToObjectClose(aAgressor, _oBdsmFurniture, S_MOD + "_StartScene")
            Else
               _qFramework.ApproachPlayer(aAgressor, 15, 2, S_MOD + "_FurnForFun")
            EndIf
         EndIf
      EndIf
   EndIf

   ; Find (and queue) any new event that might be triggered.
   FindEventClockTick()

   ; If there is a current or pending scene try to process it.
DebugTrace("PerformOnUpdate-CP: Process Pending")
   ProcessPendingAction(None)
   DebugTrace("TraceEvent PerformOnUpdate: Done - " + Utility.GetCurrentRealTime())
EndFunction

; This is called from the player event script when an item added event is seen.
Function OnItemAdded(Form oBaseItem, Int iCount, ObjectReference oItem, \
                     ObjectReference oSourceContainer)
   ; If contraban is being monitored check if the player is gaining it.
   If (_aContrabanMonitor)
      Bool bContraban = False
Log("Checking Contraban: " + GetFormName(oBaseItem, True), DL_CRIT, S_MOD)
      Int iBaseId = oBaseItem.GetFormId()
      Int iIndex = _aiAllowedItems.Find(iBaseId)

      ; If the item wasn't found in the list check for user created potions.
      Bool bPotion
      ; 46 (kPotion)
      If (46 == oBaseItem.GetType())
         bPotion = True
         ; -2: User created potion.
         iIndex = _aiAllowedItems.Find(-2)
      EndIf

      If (-1 != iIndex)
Log("Allowed.", DL_CRIT, S_MOD)
         _aiAllowedQuantity[iIndex] = _aiAllowedQuantity[iIndex] - iCount
         If (0 > _aiAllowedQuantity[iIndex])
Log("Too Many Items!", DL_CRIT, S_MOD)
            _aoContraban = _qDfwUtil.AddFormToArray(_aoContraban, oBaseItem)
            _aPlayer.RemoveItem(oBaseItem, (0 - _aiAllowedQuantity[iIndex]), \
                                akOtherContainer=_aContrabanMonitor)
            _aiAllowedQuantity[iIndex] = 0
            bContraban = True
         EndIf

         If (0 == _aiAllowedQuantity[iIndex])
            _aiAllowedItems    = _qDfwUtil.RemoveIntFromArray(_aiAllowedItems, 0, iIndex)
            _aiAllowedQuantity = _qDfwUtil.RemoveIntFromArray(_aiAllowedQuantity, 0, iIndex)
Log("No more items: " + _aiAllowedItems.Length, DL_Trace, S_MOD)
         EndIf

         Int iFlags = _iAllowdItemsFlags
         ; 0x8000: Take allowed items.
         If (0x8000 <= iFlags)
            iFlags -= 0x8000

            ; If this is a potion give a generic version of the potion to the NPC instead.
            ; TODO: For now just assume it is a healing potion.
            ; TODO: Look into possible ways of getting the actual potion to the NPC.
            If (bPotion)
               _aContrabanMonitor.AddItem(_oVigorousHealing, iCount)
            EndIf

            _aPlayer.RemoveItem(oBaseItem, iCount, akOtherContainer=_aContrabanMonitor)
Log("Item Removed.", DL_Trace, S_MOD)
         EndIf

         ; 0x0004: Force the player to stand.
         If (0x0004 <= iFlags)
            iFlags -= 0x0004

            ; TODO: This works but there might be a better way to force the player to stand.
Log("Moving Player: (" + _qFramework + "," + _aPlayer + ")", DL_Trace, S_MOD)
            _qFramework.MovePlayer(_aPlayer)
Log("Player Moved.", DL_Trace, S_MOD)
         EndIf

         ; 0x0002: Compliment the player.
         If (0x0002 <= iFlags)
            iFlags -= 0x0002

            ; 17: Thank the player for crafting a required item.
            _iCurrDialogue = 17
            _aCurrDialogueTarget = _aContrabanMonitor
            StartConversation(_aContrabanMonitor, iTimeout=10)
         EndIf

         ; 0x0001: Equip allowed items.
         If (0x0001 <= iFlags)
            iFlags -= 0x0001

            ; If this is armour related add it to the leash holder's outfit.
            ; 26 (kArmor)
            If ((_aLeashHolder == _aContrabanMonitor) && ((26 == oBaseItem.GetType())))
               _oLeashHolderOutfitContents.AddForm(oBaseItem, 1, 1)
            EndIf
            _aContrabanMonitor.EquipItem(oBaseItem, True)
Log("Item Equiped.", DL_Trace, S_MOD)
         EndIf
      Else
Log("Contraban: " + GetFormName(oBaseItem, True), DL_CRIT, S_MOD)
         _aoContraban = _qDfwUtil.AddFormToArray(_aoContraban, oBaseItem)
         bContraban = True
      EndIf

      If (bContraban)
         Int iFlags = _iContrabanFlags
         ; 0x8000: Take contraban.
         If (0x8000 <= iFlags)
            iFlags -= 0x8000

            _aPlayer.RemoveItem(oBaseItem, iCount, akOtherContainer=_aContrabanMonitor)
         EndIf

         ; 0x0004: Force the player to stand.
         If (0x0004 <= iFlags)
            iFlags -= 0x0004

            ; TODO: This works but there might be a better way to force the player to stand.
            _qFramework.MovePlayer(_aPlayer)
         EndIf

         ; 0x0002: Sternly warn the player.
         If (0x0002 <= iFlags)
            iFlags -= 0x0002

            ; Todo: Start a "Bad slave!" dialogue.
         EndIf

         ; 0x0001: Whip the player.
         If (0x0001 <= iFlags)
            iFlags -= 0x0001

            ; Todo: Start a Whipping animatino.
         EndIf
      EndIf
   EndIf
EndFunction

Event ActorEnslaved(Form oActor, String szMod)
   DebugTrace("TraceEvent ActorEnslaved")
   Actor aActor = (oActor As Actor)
   If (_aPlayer != oActor)
      DebugTrace("TraceEvent ActorEnslaved: Done (Not Player)")
      Return
   EndIf
   Log("Player Enslaved!", DL_CRIT, szMod)
   If ((szMod != _qFramework.GetMasterMod(_qFramework.MD_CLOSE)) && \
       (szMod != _qFramework.GetMasterMod(_qFramework.MD_DISTANT)))
      ; If this mod is not already registered as a player's controller try to find the player's
      ; Master in the narby player list.
      Log("Searching...", DL_CRIT, szMod)
      Form[] aoNearby = _qFramework.GetNearbyActorList()
      Int iIndex = aoNearby.Length - 1
      While (0 <= iIndex)
         Actor aNearbyActor = (aoNearby[iIndex] As Actor)
         If (0 <= aNearbyActor.GetFactionRank(_qZbfSlave.zbfFactionPlayerMaster))
            Log("Master found: " + GetDisplayName(aNearbyActor), DL_CRIT, szMod)
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
   DebugTrace("TraceEvent ActorEnslaved: Done")
EndEvent

Event ActorFreed(Form oActor, String szMod)
   DebugTrace("TraceEvent ActorFreed")
   Actor aActor = (oActor As Actor)
   If (_aPlayer != oActor)
      DebugTrace("TraceEvent ActorFreed: Done (Not Player)")
      Return
   EndIf
   Log("Player Freed!", DL_CRIT, szMod)
   Actor aCurrMaster = _qFramework.GetMaster(_qFramework.MD_CLOSE)
   If (aCurrMaster)
      _qFramework.ClearMaster(aCurrMaster)
   EndIf
   DebugTrace("TraceEvent ActorFreed: Done")
EndEvent

Event DfwNewMaster(String szOldMod, Form oOldMaster)
   DebugTrace("TraceEvent DfwNewMaster")
   ; If any mod has taken control of the player stop our control of the BDSM furniture.
   ; The assumption here is any controlling mod will manage taking the player out of the
   ; furniture on it's own.
   If (_bFurnitureForFun)
      _iDialogueFurnitureLocked = 0
      _iFurnitureExcuse = 0
      SetCurrFurniture(None)
      _qFramework.SetBdsmFurnitureLocked(False)
   EndIf

   Actor aOldMaster = (oOldMaster As Actor)
   If (aOldMaster == _aLeashHolder)
      StopLeashGame(False)
      ; If the leash game has been interrupted by a different mod, start a coolldown to prevent
      ; the game from being played again right away.
      _iLeashGameCooldown = 10
   EndIf
   DebugTrace("TraceEvent DfwNewMaster: Done")
EndEvent

; This is the ZAZ Animation Pack (ZBF) event when an animation for approaching/restrainting
; the player has completed.
Event OnSlaveActionDone(String szType, String szMessage, Form oMaster, Int iSceneIndex)
   DebugTrace("TraceEvent OnSlaveActionDone - " + szMessage)
   ; We are only interested in animations that we started.
   If ((S_MOD + "_" != StringUtil.Substring(szMessage, 0, 5)) && (S_MOD != szMessage))
      DebugTrace("TraceEvent OnSlaveActionDone: Done (Not Our Mod)")
      Return
   EndIf
   ;Off-DebugTrace("ZAZ Slave Action Done: \"" + szMessage + "\"")

   Bool bSceneContinuing
   Actor aMaster = (oMaster As Actor)
   String szName = GetDisplayName(aMaster)

   If (S_MOD + "_Assault" == szMessage)
      FinalizeAssault(aMaster, szName)
      _qFramework.SceneDone(S_MOD)
   ElseIf (S_MOD + "_ModNextStage" == szMessage)
      ; Completing this animation simply progresses the stage of the current scene module.
      ; Increase the module stage and try to continue the scene.
      _iSceneModuleStage += 1
      ProcessPendingAction(aMaster)
   ElseIf (S_MOD + "_NextStage" == szMessage)
      ; Completing this animation simply progresses the stage of the current scene.
      ; Increase the stage and try to continue the scene.
      ModifySceneStage(iDelta=1)
      ProcessPendingAction(aMaster)
   ElseIf (S_MOD + "_PreLock" == szMessage)
      Log(szName + " quietly locks the device you are in.", DL_CRIT, S_MOD)

      ; If the lock hasn't been registered yet, do so now.
      If (!_aAliasFurnitureLocker.GetReference())
         _qFramework.SetBdsmFurnitureLocked()
         ;    DisablePlayerControls(Move,  Fight, Cam,   Look,  Sneak, Menu,  Active, Journ)
         Game.DisablePlayerControls(True,  False, False, False, False, False, True,   False)
;Off-DebugTrace("OnSlaveActionDone: Movement Disabled - Preparing Lock")
         ImmobilizePlayer()
         _aAliasFurnitureLocker.ForceRefTo(aMaster)
         _bFurnitureForFun = True
         _fFurnitureReleaseTime = 0
      EndIf

      bSceneContinuing = True
      ; Disable Milk Mod Economy, preventing it from starting animations on the player.
DebugTrace("Adding Milking Spell: PreLock")
      If (_oMmeBeingMilkedSpell && !_aPlayer.HasSpell(_oMmeBeingMilkedSpell))
         _aPlayer.AddSpell(_oMmeBeingMilkedSpell, False)
         _bMmeSuppressed = True
         ; Add a delay to make sure the spell has taken effect.
         Utility.Wait(0.5)
      EndIf
      _qZbfSlaveActions.RestrainInDevice(_oBdsmFurniture, aMaster, S_MOD)
   ElseIf (S_MOD + "_F_Release" == szMessage)
      Log(szName + " starts unlocking you from your device.", DL_CRIT, S_MOD)

      If (0 < _iMovementSafety)
;Off-DebugTrace("OnSlaveActionDone: Movement Enabled - Unlocking")
         ReMobilizePlayer()
      EndIf
      SetCurrFurniture(None, bClearTransfer=False)
      _qFramework.SetBdsmFurnitureLocked(False)

      ; TODO: Using the scene system we can get here in a different scene.  This should be
      ; cleaned up but is also likely harmless as trying to clear the wrong scene will fail.
      _qFramework.SceneDone(S_MOD)
   ElseIf (S_MOD + "_F_Assault" == szMessage)
      Int iNewItems = FinalizeAssault(aMaster, szName)

      ; If the player is now leashed and arm locked don't lock her back up.
      ; 0x04: Arm Locked
Log("Checking Arm Locked: (" + GetDisplayName(_aLeashHolder) + "," + GetDisplayName(aMaster) + "," + iNewItems + "," + Math.LogicalAnd(0x0004, iNewItems) + ")", DL_CRIT, S_MOD)
      If ((_aLeashHolder == aMaster) && (Math.LogicalAnd(0x0004, iNewItems) || \
                                         _qFramework.IsPlayerArmLocked()))
         _qFramework.SetLeashTarget(aMaster)
         _qFramework.SceneDone(S_MOD)

         ; Clear the furniture as the player is no longer locked in it.
         If (_oBdsmFurniture)
            _iDialogueFurnitureLocked = 0
            _iFurnitureExcuse = 0
            SetCurrFurniture(None)
         EndIf

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
DebugTrace("Adding Milking Spell: F_Assault")
         If (_oMmeBeingMilkedSpell && !_aPlayer.HasSpell(_oMmeBeingMilkedSpell))
            _aPlayer.AddSpell(_oMmeBeingMilkedSpell, False)
            _bMmeSuppressed = True
            ; Add a delay to make sure the spell has taken effect.
            Utility.Wait(0.5)
         EndIf
         ObjectReference oFurniture = _oBdsmFurniture
         If (!oFurniture)
            oFurniture = _oPunishmentFurniture
         EndIf
         _qZbfSlaveActions.RestrainInDevice(oFurniture, aMaster, S_MOD)
         ; Set dialogue to busy 1 to allow for a short delay before the next conversation.
         _iDialogueBusy = 1
      EndIf
   ElseIf (S_MOD + "_S_Assault" == StringUtil.Substring(szMessage, 0, 14))
      ; An assault is in progress using the new Scene system.

      ; If a cage may be open immobilize the player breifly to prevent her running away.
      If (_bIsPlayerCaged)
         ImmobilizePlayer(3)
      EndIf

      FinalizeAssault(aMaster, szName)

      ; If we are to increase the scene stage do so now.
      If (S_MOD + "_S_AssaultNextStage" == szMessage)
         ModifySceneStage(iDelta=1)
      EndIf

      ; If we are to increase the scene module stage do so now.
      If (S_MOD + "_S_AssaultModNextStage" == szMessage)
         _iSceneModuleStage += 1
      EndIf

      ; For a DFWS_DisciplineCallOut scene end it here.
      ; TODO: The DFWS_DisciplineCallOut scene needs to be updated to be an actual scene.
      If (S_MOD + "_DisciplineCallOut" == _qFramework.GetCurrentScene())
         _qFramework.SceneDone(S_MOD + "_DisciplineCallOut")
      EndIf

      ; All further processing for the scene will be done in ProcessPendingAction below.
   ElseIf (S_MOD + "_PrepBdsm" == szMessage)
      ; We are removing the player's arm binder before locking her in furniture.
      ; Find the furniture we are locking her in.
      ObjectReference oFurniture = _oPunishmentFurniture
      If (!oFurniture)
         oFurniture = _oTransferFurniture
         ; If we don't have any punishment or transfer furniture find something nearby.
         If (!oFurniture)
            ; At this point if we have BDSM furniture the transfer has already been complete
            ; (or at least it has begun).
            If (_oBdsmFurniture)
               Return
            EndIf
            oFurniture = GetRandomFurniture(oCell=_aPlayer.GetParentCell())
         EndIf
      EndIf

      ; If the player is crawling allow her to stand.  She can't be crawling in furniture.
      If (_iCrawlRemaining)
         _iCrawlRemaining = 0
         ; If the player is not being punished in other ways clear the punishment status.
         ; TODO: There is still a race condition where these timers could have expired but the
         ; player has not actually been released.  We need a flag (or short term agenda) to
         ; indicate a punishment release is pending.
         If (!_iBlindfoldRemaining && !_iGagRemaining && !_iFurnitureRemaining)
            _iAgendaLongTerm = 1
            _iDetailsLongTerm = 0
            _fTimePunished = 0.0
            _fTimeLastPunished = Utility.GetCurrentGameTime()
         EndIf

         ; 22: zad_DeviousBondageMittens
         UnequipBdsmItem(_aoMittens, _aoZadDeviceKeyword[22], aMaster)
      EndIf

      If (oFurniture)
         ; Clear the automatic release timer if it is running.
         _fFurnitureReleaseTime = 0

         ; Make sure furniture locked dialogue will be available in 300 seconds.
         If (!_iDialogueFurnitureLocked)
            _iDialogueFurnitureLocked = ((300 / _fMcmPollTime) As Int)
         EndIf

         ; 3: The player controller/owner simply wants her locked up in furniture.
         _iFurnitureExcuse = 3
         If (_oPunishmentFurniture)
            ; 2: The player is being punished for bad behaviour.
            _iFurnitureExcuse = 2
         EndIf

         ; Identify the player is now locked in her furniture.
         SetCurrFurniture(oFurniture, True, aMaster)

         ; If the player is being locked in regular furniture prepare her for it.
         If (!_bIsPlayerCaged)
            _qFramework.SetBdsmFurnitureLocked()
            ; 5: zad_DeviousArmbinder  19; zad_DeviousBoots
            UnequipBdsmItem(_aoArmRestraints, _aoZadDeviceKeyword[5], aMaster)
            UnequipBdsmItem(_aoLegRestraints, _aoZadDeviceKeyword[19], aMaster)

            ; Disable Milk Mod Economy, preventing it from starting animations on the player.
DebugTrace("Adding Milking Spell: PrepBdsm")
            If (_oMmeBeingMilkedSpell && !_aPlayer.HasSpell(_oMmeBeingMilkedSpell))
               _aPlayer.AddSpell(_oMmeBeingMilkedSpell, False)
               _bMmeSuppressed = True
               ; Add a delay to make sure the spell has taken effect.
               Utility.Wait(0.5)
            EndIf

            ; The furniture is regular BDSM furniture.  Start the restraining sequence.
            _qZbfSlaveActions.RestrainInDevice(oFurniture, aMaster, S_MOD + "_LeashToBdsm")
            bSceneContinuing = True
         Else
            ; The furniture is a cage.  Lock the player in it.
            LockPlayerInCage(aMaster, oFurniture)
            Log(szName + " pushes you in the cage and closes the door.", DL_CRIT, S_MOD)

            ; For BDSM furniture this is done later once the locking scene is complete.
            ; For cages do it here.
            If (_oPunishmentFurniture)
               _iAgendaLongTerm = 3
               _iDetailsLongTerm = 0
               _fTimeLastPunished = 0.0

               ; Allow sex while the player is being punished.
               _qFramework.AddPermission(aMaster, _qFramework.AP_SEX)
               _qFramework.SetLeashTarget(None)

               ; 15: Tell the player to think about her behaviour.
               _iCurrDialogue = 15
               _aCurrDialogueTarget = aMaster
               StartConversation(aMaster, iTimeout=10)
               bSceneContinuing = True
            Else
               ; The leash game is done.
               Log(szName + " locks you up and walks away.", DL_CRIT, S_MOD)
               _qFramework.MoveToObject(aMaster, _oBdsmFurniture, S_MOD + "_FHoverBrief")

               ; This could just be a furniture transfer.  We may not need to perform a full
               ; stop of the leash game.
               If (0 >= _iLeashGameDuration)
                  StopLeashGame()
               Else
                  _qFramework.RestoreHealthRegen()
                  _qFramework.DisableMagicka(False)
                  _qFramework.SetLeashTarget(None)
               EndIf
            EndIf
            _qFramework.SceneDone(S_MOD + "_MoveToFurniture")
         EndIf

         ; We have just locked the player into furniture.  Consider sandboxing nearby.
         If (_qMcm.iFurnitureRemoteSandbox >= Utility.RandomInt(1, 100))
            ; Only consider it if the furniture is in a remote area and sandboxing is nearby.
            Int iFlags = ToggleFurnitureFlag(oFurniture, 0x0000)
            ; 0x0080: Remote
            ; 0x0100: Activity/Sandbox (NPCs can sandbox nearby)
            If ((0x0100 + 0x0080) == Math.LogicalAnd(0x0100 + 0x0080, iFlags))
               ; 5: Start a Sandbox.
               AddPendingAction(5, aActor=aMaster, bPrepend=True)
            EndIf
         EndIf
      Else
         ; Something went wrong.  End the scene if possible.
         _qFramework.SceneDone(S_MOD)
      EndIf
   ElseIf (S_MOD + "_S_Unlock" == szMessage)
      ; This scenario still uses the old mechanism.  Just unlock the player here.
      SetCurrFurniture(None)
      ReMobilizePlayer()
   ElseIf (S_MOD + "_LeashToBdsm" == szMessage)
      If (_oPunishmentFurniture)
         ; The player is being locked in furniture as a punishment.  Don't stop the leash game.
         _qFramework.SceneDone(S_MOD + "_MoveToFurniture")

         _iAgendaLongTerm = 3
         _iDetailsLongTerm = 0
         _fTimeLastPunished = 0.0

         ; Allow sex while the player is being punished.
         _qFramework.AddPermission(aMaster, _qFramework.AP_SEX)
         _qFramework.SetLeashTarget(None)

         ; Whip the player as further punishment.
         ; 4: Start Scene.  Scene 8: Whip the Player.
         AddPendingAction(4, 8, aMaster, S_MOD + "_WhipBdsmPunish", bPrepend=True)
      ElseIf (MutexLock(_iCurrSceneMutex))
         If (1 != _iCurrScene)
            ; The leash game is done.
            Log(szName + " locks you up and walks away.", DL_CRIT, S_MOD)
            StopLeashGame()
            _qFramework.SceneDone(S_MOD)
         Else
            ; This is just a furniture transfer (most likely).  Just drop the leash.
            _qFramework.SetLeashTarget(None)
         EndIf

         MutexRelease(_iCurrSceneMutex)
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
DebugTrace("Adding Milking Spell: BdsmToLeash")
      If (_oMmeBeingMilkedSpell && !_aPlayer.HasSpell(_oMmeBeingMilkedSpell))
         _aPlayer.AddSpell(_oMmeBeingMilkedSpell, False)
         _bMmeSuppressed = True
         ; Add a delay to make sure the spell has taken effect.
         Utility.Wait(0.5)
      EndIf
      _qZbfSlaveActions.RestrainInDevice(_oBdsmFurniture, aMaster, S_MOD)
      ; If there is already a leash holder we are just re-connecting a game in progress.
      If (_aLeashHolder == aMaster)
         _qFramework.SetLeashLength(_qMcm.iLeashLength)
         _qFramework.SetLeashTarget(aMaster)
         _bFullyRestrained = False
         _bIsCompleteSlave = False
      Else
         ; Otherwise start the leash game as normal.
         StartLeashGame(aMaster)
      EndIf
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

      ; If the whipping is the end of the scene, end it.
      String szCurrScene = _qFramework.GetCurrentScene()
      If (S_MOD + "_FurnForFun" == szCurrScene)
         _qFramework.SceneDone(szCurrScene)
         szCurrScene = ""
      Else
         _qFramework.SceneDone(szMessage)
      EndIf

      If (S_MOD + "_WhipBdsmPunish" == szMessage)
         ; 15: Tell the player to think about her behaviour.
         _iCurrDialogue = 15
         _aCurrDialogueTarget = aMaster
         StartConversation(aMaster, iTimeout=10)

         ; Advance the scene so it knows to end.
         ModifySceneStage(iDelta=1)
      EndIf
   ElseIf (S_MOD == szMessage)
      If (0 < _iMovementSafety)
;Off-DebugTrace("OnSlaveActionDone: Movement Safety Expired")
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
         DebugTrace("Continuing: Furniture")
         ProcessFurnitureGoals(aMaster)

         ; If we have completed all short-term goals clear the variable.
         If (!_iFurnitureGoals && (0 < _iAgendaShortTerm))
            _iAgendaShortTerm = -2
         EndIf
      Else
         ProcessPendingAction(aMaster)
      EndIf
   EndIf
   DebugTrace("TraceEvent OnSlaveActionDone: Done")
EndEvent

Event PreSexCallback(String szEvent, String szArg, Float fNumArgs, Form oSender)
   DebugTrace("TraceEvent PreSexCallback")

   ; Make sure the player is involved in this scene.
   Actor[] aaEventActors = _qSexLab.HookActors(szArg)
   If (-1 == aaEventActors.Find(_aPlayer))
      DebugTrace("TraceEvent PreSexCallback: Done (No Player)")
      Return
   EndIf

   ; If we are configured to hide the player's BDSM furniture during sex, do so.
   If (!_oHiddenFurniture && _qMcm.bFurnitureHide)
      _oHiddenFurniture = _qFramework.GetBdsmFurniture()
      If (_oHiddenFurniture)
         _oHiddenFurniture.Disable()
      EndIf
   EndIf

   ; If the leash game is expected to handle sex events do so now.
   If (((0 < _iLeashGameDuration) || _bPermanency) && _qMcm.bAllowSex && \
       (_aLeashHolder == _qFramework.GetLeashTarget()))
      _bLeashHolderStopped = True
      _qFramework.HoverAt(_aLeashHolder, _aPlayer, S_MOD + "_WatchSex")
   EndIf

   ; If this is a solo event make sure it is permitted.
   ; TODO: configure in MCM.  For now just stop all animations.
   ; TODO: Add a loop so the leash holder can stop the scene when he gets close enough.
   If (1 == aaEventActors.Length)
      sslThreadController oController = _qSexLab.HookController(szArg)
      If (oController)
         If (_aLeashHolder && _aLeashHolder.Is3DLoaded() && \
             (1000 >= _aLeashHolder.GetDistance(_aPlayer)))
            ; Talk to the player about playing with herself without permission.
            ; 1: Start Conversation.  11: Player touching herself without permission.
            AddPendingAction(1, 11, _aLeashHolder, S_MOD + "_NoTouching", bPrepend=True)

            ; 22: zad_DeviousBondageMittens
            If (!_qFramework.IsPlayerArmLocked() || \
               _aPlayer.WornHasKeyword(_aoZadDeviceKeyword[22]))
               ; The player can effectively touch herself.  Stop the scene.

               ; Add a delay so the scene has some time to start before it ends.
               Utility.Wait(Utility.RandomFloat(3.0, 8.0))
               oController.EndAnimation()
            EndIf
         ElseIf (_oBdsmFurniture)
            Log("You can't play with yourself locked in furniture.", DL_ERROR, S_MOD)
            oController.EndAnimation()
         EndIf
      EndIf
   EndIf

   DebugTrace("TraceEvent PreSexCallback: Done")
EndEvent

Event PostSexCallback(String szEvent, String szArg, Float fNumArgs, Form oSender)
   DebugTrace("TraceEvent PostSexCallback")

   ; Set a cooldown timer to make sure another SexLab sex scene doesn't start too quickly.
   _fSexLabCooldown = Utility.GetCurrentRealTime()

   ; Make sure the player is involved in this scene.
   Actor[] aaEventActors = _qSexLab.HookActors(szArg)
   If (-1 == aaEventActors.Find(_aPlayer))
      DebugTrace("TraceEvent PostSexCallback: Done (No Player)")
      ; We can't manage a separate cooldown for each actor.  Only use it for the player.
      _fSexLabCooldown = 0.0
      Return
   EndIf

   ; Check if the NPC's disposition should be adjusted after sex.
   Actor aPartner
   If (_qMcm.bSexDispositions)
      Int iIndex = aaEventActors.Length - 1
      While (0 <= iIndex)
         Actor aParticipant = aaEventActors[iIndex]
         Race oRace = aParticipant.GetRace()
         ; Checking the playable race excludes animals from the processing.
         If ((_aPlayer != aParticipant) && oRace.IsPlayable())
            aPartner = aParticipant
            Int iActorFlags = _qFramework.GetActorFlags(aParticipant)
            Int iCurrDominance = _qFramework.GetActorDominance(aParticipant, 0, 80, True, 1)
            Bool bDominant = (Math.LogicalAnd(_qFramework.AF_SLAVE_TRADER, iActorFlags) || \
                              Math.LogicalAnd(_qFramework.AF_OWNER, iActorFlags) || \
                              (Math.LogicalAnd(_qFramework.AF_DOMINANT, iActorFlags) && \
                               (50 <= iCurrDominance)))
            Actor aVictim = _qSexLab.HookVictim(szArg)
            Int iDeltaInterest = 1
            Int iDeltaDominance = 1
            If (aVictim == aParticipant)
               ; The NPC was raped.
               iDeltaDominance = -2
               If (!bDominant)
                  ; The NPC is submissive.
                  iDeltaInterest = 2
               Else
                  iDeltaInterest = -2
               EndIf
            ElseIf ((_aPlayer == aVictim) || (30 <= _qFramework.GetVulnerability(_aPlayer)))
               ; The player was raped or at least locked in bondage for the sex.
               iDeltaDominance = 2
               If (bDominant)
                  ; The NPC is dominant.
                  iDeltaInterest = 2
               Else
                  iDeltaInterest = -1
               EndIf
            ElseIf (aVictim)
               ; A third party was raped.
               iDeltaDominance = 2
            EndIf
            _qFramework.IncActorInterest(aParticipant, iDeltaInterest, 0, 100)
            _qFramework.IncActorDominance(aParticipant, iDeltaDominance, 0, 100)
         EndIf

         iIndex -= 1
      EndWhile
   EndIf
   If (_bLeashHolderStopped)
      _bLeashHolderStopped = False
      _qFramework.HoverAtClear(S_MOD + "_WatchSex")
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
      If (!_iFurnitureGoals && (0 < _iAgendaShortTerm))
         _iAgendaShortTerm = -2
      EndIf
   EndIf

   ; If there is furniture we have previously hidden, reveal it now.
   If (_oHiddenFurniture)
      _oHiddenFurniture.Enable()
      _oHiddenFurniture = None
   EndIf

   ; If the player is supposed to be caged, make sure she gets back into it.
   If (_bIsPlayerCaged && _oBdsmFurniture)
      ; First try to figure out who nearby can lock up the player.
      Bool bRealPartner = aPartner
      If (!aPartner)
         aPartner = (_aAliasFurnitureLocker.GetReference() As Actor)
         If (!aPartner || !_qFramework.IsActorNearby(aPartner))
            aPartner = _qFramework.GetNearestActor(iExcludeFlags=_qFramework.AF_SUBMISSIVE + \
                                                                 _qFramework.AF_SLAVE)
            If (!aPartner)
               aPartner = _qFramework.GetNearestActor(iExcludeFlags=_qFramework.AF_SLAVE)
               If (!aPartner)
                  aPartner = _qFramework.GetNearestActor()
               EndIf
            EndIf
         EndIf
      EndIf

      ; Add a delay before performing the move.  I suspect we are crashing sometimes without it.
      ; Add a delay.  Trying to move the play too soon after sex can conflict with other mods
      ; moving the player and cause crashes.
      Utility.Wait(2.0)

      ; If the player has somehow been teleported away from the cage add an extra delay.
      If (!_oBdsmFurniture.Is3DLoaded() || (500 <= _aPlayer.GetDistance(_oBdsmFurniture)))
         Utility.Wait(2.0)
      EndIf

      If (!_oBdsmFurniture.Is3DLoaded())
         _qFramework.MovePlayer(_oBdsmFurniture)
      EndIf

      CloseCageDoor(aPartner, _oBdsmFurniture, FindCageLever(_oBdsmFurniture))
      MoveIntoCage(aPartner, _oBdsmFurniture)

      ; If we actually found the player's sex partner try to relocate him outside the cage.
      If (bRealPartner && !_qSexLab.IsActorActive(aPartner))
         ExitCage(aPartner)
      EndIf
   EndIf

   ; If the completion of sex completes the current scene, end it.
   If (_bSceneReadyToEnd)
      String szCurrScene = _qFramework.GetCurrentScene()
      If (S_MOD == StringUtil.Substring(szCurrScene, 0, 4))
         _qFramework.SceneDone(szCurrScene)
         szCurrScene = ""
         _bSceneReadyToEnd = False
      EndIf
      ModifySceneStage(iDelta=1)
   EndIf

   Float fDelay = _qMcm.iModPostSexMonitor
   If (fDelay && _bIsPlayerCaged && _oBdsmFurniture)
      Bool bNotFound
      While (!bNotFound && (0 < fDelay))
         If ((-100 < _aPlayer.X) && (100 > _aPlayer.X) && \
             (-100 < _aPlayer.Y) && (100 > _aPlayer.Y) && \
             (-500 < _aPlayer.Z) && (100 > _aPlayer.Z))
            MoveIntoCage(None, _oBdsmFurniture)
            CloseCageDoor(_aPlayer, _oBdsmFurniture, FindCageLever(_oBdsmFurniture))
            bNotFound = True
         EndIf

         Utility.Wait(0.25)
         fDelay -= 0.25
      EndWhile
   EndIf

   ; If the player is locked in furniture or a cage consider moving her to a different one.
   If (_oBdsmFurniture && (aPartner == (_aAliasFurnitureLocker.GetReference() As Actor)) && \
       (_qMcm.iFurnitureTransferChance >= Utility.RandomInt(1, 100)))
      ; 4: Start Scene.  Scene 1: Transfer Furniture
      AddPendingAction(4, 1, aPartner, S_MOD + "_FTransfer")
   EndIf

   DebugTrace("TraceEvent PostSexCallback: Done")
EndEvent

Event EventSdPlusStart(String szEventName, String szArg, Float fArg = 1.0, Form oSender)
   DebugTrace("TraceEvent EventSdPlusStart")
   StartSdPlus()
   DebugTrace("TraceEvent EventSdPlusStart: Done")
EndEvent

Event EventSdPlusStop(String szEventName, String szArg, Float fArg = 1.0, Form oSender)
   DebugTrace("TraceEvent EventSdPlusStop")
   StopSdPlus()
   DebugTrace("TraceEvent EventSdPlusStop: Done")
EndEvent

Event UpdateDfwMcm(String szCategory="")
   DebugTrace("TraceEvent UpdateDfwMcm")
   If ("SafewordFurniture" == szCategory)
      Log("Safeword BDSM Furniture.", DL_CRIT, S_MOD)
;Off-DebugTrace("UpdateDfwMcm: Movement Enabled - Safeword")
      ReMobilizePlayer()
      _aAliasFurnitureLocker.Clear()
      _bFurnitureForFun = False
      _bIsPlayerCaged = False
      _qFramework.SetBdsmFurnitureLocked(False)
      _qFramework.SceneDone(S_MOD)
   EndIf

   If ("SafewordLeash" == szCategory)
      Log("Safeword Leash.", DL_CRIT, S_MOD)
      StopLeashGame(bReturnItems=True, bUnequip=True)
      _qFramework.SceneDone(S_MOD)
   EndIf
   DebugTrace("TraceEvent UpdateDfwMcm: Done")
EndEvent

Event NewDialogueTarget(Form oActor)
   ; Choose a random path for dialogue in the scene.
   _iCurrDialoguePath = Utility.RandomInt(1, 100)
EndEvent

Event DebugMovePlayer(Int iTarget, Float fXOffset, Float fYOffset)
   DebugTrace("TraceEvent DebugMovePlayer")
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
         _qFramework.SetBdsmFurnitureLocked(False)
         ;    EnablePlayerControls(Move,  Fight, Cam,   Look,  Sneak, Menu,  Activ, Journ)
         Game.EnablePlayerControls(True,  False, False, False, False, False, True,  False)
         Utility.Wait(0.25)
         oCurrFurniture.Activate(_aPlayer)
      EndIf
      _iDialogueFurnitureLocked = 0
      _iFurnitureExcuse = 0
      SetCurrFurniture(None)

      ; If some furniture was hidden for a sex scene re-enable it.
      If (_oHiddenFurniture)
         _oHiddenFurniture.Enable()
         _oHiddenFurniture = None
      EndIf

      ; If the player has been imobilized for some reason restore movement.
      If (0 < _iMovementSafety)
;Off-DebugTrace("DebugMovePlayer: Movement Safety Expired")
         ReMobilizePlayer()
         Utility.Wait(5.0)
      EndIf

      ; Wait for the player and leash holder to not be sitting before moving them.
      Int iSafety = 25
      While (iSafety && (_aLeashHolder.GetSitState() || _aPlayer.GetSitState()))
         Utility.Wait(0.1)
         iSafety -= 1
      EndWhile

      ObjectReference oTarget = (Game.GetFormFromFile(iTarget, "Skyrim.esm") As ObjectReference)
      If (oTarget != _aLeashHolder)
         _aLeashHolder.MoveTo(oTarget, fXOffset, fYOffset)
      EndIf
      ;_qFramework.MovePlayer(_aLeashHolder, fXOffset, fYOffset)
      _qFramework.MovePlayer(_aLeashHolder)
      Utility.Wait(3.0)

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
         ; 0x0004: Bind Arms (implies Unbind Mittens)
         _iAssault = Math.LogicalOr(0x0004, _iAssault)
      EndIf

      ; If there are any reasons to perform an assault scene on the player start it now.
      If (_iAssault)
         FinalizeAssault(_aLeashHolder, GetDisplayName(_aLeashHolder))
      EndIf

      ; If the player was previously in punishment furniture make sure to return her to it.
      If (_oPunishmentFurniture)
         _oPunishmentFurniture = None
         ; 4: Start Scene.  9: Start Furniture Punishment.
         AddPendingAction(4, 9, _aLeashHolder, S_MOD + "_FPunish", bPrepend=True)
      EndIf

      ; Punish the player to discourage the use of this feature.
      _iAgendaLongTerm = 3
      _fTimeLastPunished = 0.0
      _iGagRemaining += 180
      If (_iFurnitureRemaining)
         _iFurnitureRemaining += 300
      EndIf
      If (_iCrawlRemaining)
         _iCrawlRemaining += 300
      EndIf
      If (_iLeashGameDuration)
         _iLeashGameDuration += 180
      EndIf
      If (_iBlindfoldRemaining)
         _iBlindfoldRemaining += 180
      EndIf
   EndIf
   DebugTrace("TraceEvent DebugMovePlayer: Done")
EndEvent

Event OnKeyUp(Int iKeyCode, Float fHoldTime)
   DebugTrace("TraceEvent OnKeyUp")
   ; Ignore any user keypresses if we are shutting down the mod.
   If (_bMcmShutdownMod)
      Log("Key Ignored.  Mod in shutdown mode.", DL_CRIT, S_MOD)
      DebugTrace("TraceEvent OnKeyUp: Done (Mod Shutting Down)")
      Return
   EndIf

   If (_qMcm.iDbgUtilKey == iKeyCode)
      ; If the hotkey is used for cycling the leash holder package do that.
      If (_qMcm.bHotkeyPackage)
         If (_aLeashHolder)
            Log("Cycling Leash Holder AI Package.", DL_DEBUG, S_MOD)
            _qFramework.ReEvaluatePackage(_aLeashHolder)
         Endif
         _qFramework.HandleCallForAttention()
         _qFramework.CallOutDone()
      EndIf

      ; If the hotkey is used for forcing the Multi-Pole/Wall animations try that now.
      If (_qMcm.bHotkeyMultiPose)
         _qFramework.SetMultiAnimation()
         ;zbfSlot qZbfPlayerSlot = zbfBondageShell.GetApi().FindPlayer()
         ;If (qZbfPlayerSlot)
         ;   qZbfPlayerSlot.StopIdleAnim()
         ;EndIf
      EndIf
   EndIf

   DebugTrace("TraceEvent OnKeyUp: Done")
EndEvent

; iCallType: 1 = Call for Help, 2 = Call for Attention
Event HandleCallOut(Int iCallType, Int iRange, Form oRecommendedActor)
   DebugTrace("TraceEvent HandleCallOut")
   ; Don't handle call outs if we are shutting down the mod.
   If (_bMcmShutdownMod)
      DebugTrace("TraceEvent HandleCallOut: Done (Mod Shutdown)")
      Return
   EndIf

   Actor aActor = (oRecommendedActor As Actor)
   String szName = GetDisplayName(aActor)
   Bool bHandleCallOut

   ; If the player is calling out in the middle of one of our scenes handle it immediately.
   ; 3: Sell the player's items.
   ; 6: Ask the blacksmith to remove restraints from other mods.
   ; 10: Proposition the slaver for sex.
   If ((3 == _iCurrScene) || ((6 == _iCurrScene) && (2 <= _iCurrSceneStage)) || \
       (10 == _iCurrScene))
      If (1 == iCallType)
         If (_qFramework.HandleCallForHelp())
            _iVerbalAnnoyance += 2
         EndIf
      ElseIf (2 == iCallType)
         If (_qFramework.HandleCallForAttention())
            _iVerbalAnnoyance += 1
         EndIf
      EndIf

      ; For some scenes the callout needs to be handled.
      ; 6: Ask the blacksmith to remove restraints from other mods.
      If (6 == _iCurrScene)
         ; In some stages of remove restraints an actor should tell the player not to speak.
         Actor aSpeaker = None
         If (5 > _iCurrSceneStage)
            aSpeaker = _aLeashHolder
         ElseIf ((7 <= _iCurrSceneStage) && (14 > _iCurrSceneStage))
            aSpeaker = _aCurrSceneAgressor
         ElseIf ((14 <= _iCurrSceneStage) && (15 != _iCurrSceneStage))
            aSpeaker = _aLeashHolder
         EndIf

         ; If we found someone should be silencing the player start that conversation now.
         If (aSpeaker)
            ; 6: Remove Restraint Scene Blacksmith Dialogues.
            _iCurrDialogue = 6
            _iCurrDialogueStage = 10
            _aCurrDialogueTarget = aSpeaker
            StartConversation(aSpeaker, iTimeout=10)
         EndIf
      EndIf

      ; Otherwise don't do anything.  Let the scene dialogue system handle the call out.
      DebugTrace("TraceEvent HandleCallOut: Done (Scene in Progress)")
      Return
   EndIf

   ; If there is no recommended actor (most likely no one nearby) don't handle it.
   ; Also don't try to handle the call for help if it is the leash holder and he is busy.
   If (!aActor || ((aActor == _aLeashHolder) && IsLeashHolderBusy()))
      DebugTrace("TraceEvent HandleCallOut: Done (No Actor/Busy)")
      Return
   EndIf

   Bool bPreviouslyAnnoyed = (5 < _iVerbalAnnoyance)
   If ((1 == iCallType) && ((0 < _iLeashGameDuration) || \
                            _qFramework.IsBdsmFurnitureLocked() || \
                            _bIsPlayerCaged))
      ; Add a random delay to allow other mods to maybe handle this call out.
      Utility.Wait(Utility.RandomFloat(0, 0.5))

      ; If no other mod is handling the call do so.
      If (!_qFramework.GetCurrentScene() && _qFramework.HandleCallForHelp())
         bHandleCallOut = True
         _iVerbalAnnoyance += 2
      EndIf
   ElseIf ((2 == iCallType) && ((0 < _iLeashGameDuration) || \
                                _qFramework.IsBdsmFurnitureLocked() || \
                                _bIsPlayerCaged))
      ; Add a random delay to allow other mods to maybe handle this call out.
      Utility.Wait(Utility.RandomFloat(0, 0.5))

      ; If no other mod is handling the call do so.
      If (!_qFramework.GetCurrentScene() && _qFramework.HandleCallForAttention())
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
                                                                    _qFramework.AF_GUARDS + \
                                                                    _qFramework.AF_SLAVE)
         EndIf
         If (aNew)
            aActor = aNew
         EndIf
      EndIf

      ; If the player has been causing a scene gag her instead of responding.
      If ((_iVerbalAnnoyance - 3) > Utility.RandomInt(1, 10))
         If (!_qFramework.IsPlayerGagged())
            ; 0x0002: Gag
            ; 0x2000: Make sure the Gag is secure
            _iAssault = Math.LogicalOr(0x2000 + 0x0002, _iAssault)
            PlayApproachAnimationOld(aActor, "Assault")
         ElseIf (!_qFramework.IsGagStrict())
            ; 0x2000: Make sure the Gag is secure
            _iAssault = Math.LogicalOr(0x2000, _iAssault)
            PlayApproachAnimationOld(aActor, "Assault")
         Else
            Log(szName + " looks over at you looking annoyed.", DL_CRIT, S_MOD)
         EndIf
      ElseIf ((1 == iCallType) && (_aLeashHolder == aActor))
         ; The leash holder is responding to the player.  Schedule a punishment scene.
         ; 1: Start Conversation.  1: Discipline - CallOut
         AddPendingAction(1, 1, aActor, S_MOD + "_DisciplineCallOut", bPrepend=True)
      Else
         _qFramework.SceneStarting(S_MOD + "_CallOut", 60)
         _qFramework.ApproachPlayer(aActor, 15, 2, S_MOD + "_CallOut")
      EndIf
   EndIf
   DebugTrace("TraceEvent HandleCallOut: Done")
EndEvent

; iType: 1: Approach Player  2: Move To Location  3: Move To Object
Event MovementDone(Int iType, Form oActor, Bool bSucceeded, String szModId)
   DebugTrace("TraceEvent MovementDone (" + iType + "," + szModId + ")")
   ; We are only interested in animations that we started.
   If (S_MOD != StringUtil.Substring(szModId, 0, 4))
      DebugTrace("TraceEvent MovementDone: Done (Not Our Mod)")
      Return
   EndIf

   Actor aActor = (oActor As Actor)
   String szName = GetDisplayName(aActor)

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
   ;   DebugTrace("TraceEvent MovementDone: Done (Movement Failed)")
   ;   Return
   ;EndIf

   If (S_MOD + "_StartScene" == szModId)
      ; This movement simply starts the next pending scene.
      _qFramework.SceneDone(szModId)
      ProcessPendingAction(aActor)
   ElseIf (S_MOD + "_ModNextStage" == szModId)
      ; This movement simply progresses the stage of the current scene module.
      ; Increase the module stage and try to continue the scene.
      _iSceneModuleStage += 1
      ProcessPendingAction(aActor)
   ElseIf (S_MOD + "_NextStage" == szModId)
      ; This movement simply progresses the stage of the current scene.
      ; Increase the stage and try to continue the scene.
      ModifySceneStage(iDelta=1)
      ProcessPendingAction(aActor)
   ElseIf (S_MOD + "_FHoverBrief" == szModId)
      ; We want the actor to hover around the player's furniture/cage for a few seconds.
      If (_oBdsmFurniture)
         _qFramework.HoverAt(aActor, _oBdsmFurniture, S_MOD + "_Colour", 6)
      EndIf
   ElseIf (S_MOD + "_Approach" == szModId)
      ; Approaching the player is complete.  Hover breifly until the scene continues.
      If (_bIsPlayerCaged && _oBdsmFurniture)
         _qFramework.HoverAt(aActor, _oBdsmFurniture, S_MOD + "_Colour", 6)
      Else
         _qFramework.HoverAt(aActor, _aPlayer, S_MOD + "_Colour", 6)
      EndIf
   ElseIf ((S_MOD + "_CallOut" == szModId) || (S_MOD + "_StartDialogue" == szModId))
      ; If the player is supposed to be restrained but is not discipline her for misbehaving.
      ; 18: zad_DeviousBlindfold
      If ((_iGagRemaining && !_qFramework.IsPlayerGagged()) || \
          (_iBlindfoldRemaining && !_aPlayer.WornHasKeyword(_aoZadDeviceKeyword[18])))
         ; The slaver was interrupted from approaching the player for sex.  Make sure he does so
         ; afterward
         If (S_MOD + "_StartDialogue" == szModId)
            ; 1: Start Conversation. 12: Furniture Predicament.
            AddPendingAction(1, 12, aActor, S_MOD + "_StartDialogue", bPrepend=True)
         EndIf

         ; Goal 14: Punish Removing Restraints
         StartConversation(aActor, 14)
      Else
         ; Goal 12: Approach for Interest
         StartConversation(aActor, 12)
      EndIf
   ElseIf (S_MOD + "_FurnForFun" == szModId)
      ; Checking the player's restraints should either be a separate scene or it should be part
      ; of the furniture for fun scene.  It shouldn't be here, in the movement preparation for
      ; the furniture for fun scene.  Once it is moved movement preparation can be changed to
      ; use the standard movement preparation (DFWS_StartScene).  For now end the scene here.
      _qFramework.SceneDone(S_MOD + "_StartScene")

      ; If the player is supposed to be restrained but is not discipline her for misbehaving.
      ; 18: zad_DeviousBlindfold
      If ((_iGagRemaining && !_qFramework.IsPlayerGagged()) || \
          (_iBlindfoldRemaining && !_aPlayer.WornHasKeyword(_aoZadDeviceKeyword[18])))
         ; Goal 14: Punish Removing Restraints
         StartConversation(aActor, 14)
      Else
         ; Otherwise start the Furniture For Fun scene.
         ProcessPendingAction(aActor)
      EndIf
   ElseIf (S_MOD + "_LeashGame" == szModId)
      If (3 == _iMcmLeashGameStyle)
         Log("Dialogue Leash Game Style not yet supported.", DL_CRIT, S_MOD)
         _qFramework.SceneDone(S_MOD + "_LeashGame")
         DebugTrace("TraceEvent MovementDone: Done (Leash Game Processed)")
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
         Utility.Wait(5.0)
         aActor.EnableAI()
         _qFramework.SceneDone(S_MOD + "_LeashGame")
         DebugTrace("TraceEvent MovementDone: Done (Leash Game Processed-Safe)")
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
         If (2 == iType)
            Log("Arrived at Location.  Moving to furniture." , DL_TRACE, S_MOD)
            ; Add a delay, giving the player time to catch up to the slaver.
            Float fSafety = 1.0
            While (fSafety && (_aPlayer.GetParentCell() != aActor.GetParentCell()))
               Utility.Wait(0.1)
               fSafety -= 0.1
            EndWhile

            ; We have arrived at the furniture's location.  Now move to the furniture.
            _qFramework.MoveToObject(aActor, oFurniture, szModId)
         ElseIf (3 == iType)
            ; We have arrived at the furniture.  Lock the player in.
            ActorSitStateWait(aActor)
            _qZbfSlaveActions.BindPlayer(akMaster=aActor, asMessage=S_MOD + "_PrepBdsm")
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
            Utility.Wait(1.0)
            SendModEvent("SSLV Entry")
         EndIf
      EndIf
   ElseIf (S_MOD + "_SS_Internal" == szModId)
      ; We have arrived at the entrance.  For now start the auction from here.
      ; The short delay helps the player transfer with the proper equipment.
      StopLeashGame(bReturnItems=True, bUnequip=True)
      Utility.Wait(1.0)
      ; Move the leash holder to their package location so they are not in the auction house.
      aActor.EvaluatePackage()
      aActor.MoveToMyEditorLocation()
      aActor.MoveToPackageLocation()
      SendModEvent("SSLV Entry")
; TODO: Remove the old _Return path.
;   ElseIf (S_MOD + "_Return" == szModId)
;      ; Verify the expected state of things before getting the player back to the leash game.
;      If ((aActor != _aLeashHolder) || !_iLeashGameDuration)
;         Log("Error: Cannot continue the leash game.", DL_ERROR, S_MOD)
;         DebugTrace("TraceEvent MovementDone: Done (Return Failed)")
;         Return
;      EndIf
;
;      ; If the player still has a furniture punishment, ignore this event.
;      If (0 < _iFurnitureRemaining)
;         DebugTrace("TraceEvent MovementDone: Done (Return Still Punished)")
;         Return
;      EndIf
;
;      ; Reset the duration of the leash game in case there is little time remaining.
;      Int iDurationSeconds = ((GetLeashGameDuration() / _fMcmPollTime) As Int)
;      If (iDurationSeconds > _iLeashGameDuration)
;         _iLeashGameDuration = iDurationSeconds
;      EndIf
;
;      ;    DisablePlayerControls(Move,  Fight, Cam,   Look,  Sneak, Menu,  Active, Journ)
;      Game.DisablePlayerControls(True,  False, False, False, False, False, True,   False)
;;Off-DebugTrace("MovementDone: Movement Disabled - Slaver Returning")
;      ImmobilizePlayer()
;      _aAliasFurnitureLocker.ForceRefTo(aActor)
;      _bFurnitureForFun = False
;      _bIsPlayerCaged = False
;      _fFurnitureReleaseTime = 0
;      ReleaseFromFurniture(aActor)
;      _qFramework.ForceSave()
   EndIf
   DebugTrace("TraceEvent MovementDone: Done")
EndEvent

; This is called from the Leash Holder Events script when the Leash Holder actor is loaded.
Function RefreshLeashHolder(Actor aLeashHolder)
   If (_bLeashHolderOutfitActive)
      aLeashHolder.SetOutfit(_oLeashHolderOutfit)
   EndIf
EndFunction


;***********************************************************************************************
;***                                  PRIVATE FUNCTIONS                                      ***
;***********************************************************************************************
Function CreateRestraintsArrays()
   DebugTrace("TraceEvent CreateRestraintsArrays")
   _aoGags = New Armor[29]
   _aoGags[00] = (Game.GetFormFromFile(0x0002B073, "Devious Devices - Integration.esm") As Armor)  ;;; zad_gagBallInventory
   _aoGags[01] = (Game.GetFormFromFile(0x0002B075, "Devious Devices - Integration.esm") As Armor)  ;;; zad_gagPanelInventory
   _aoGags[02] = (Game.GetFormFromFile(0x0002B076, "Devious Devices - Integration.esm") As Armor)  ;;; zad_gagRingInventory
   _aoGags[03] = (Game.GetFormFromFile(0x00034253, "Devious Devices - Integration.esm") As Armor)  ;;; zad_gagStrapBallInventory
   _aoGags[04] = (Game.GetFormFromFile(0x00034255, "Devious Devices - Integration.esm") As Armor)  ;;; zad_gagStrapRingInventory
   _aoGags[05] = (Game.GetFormFromFile(0x0000D4EE, "Devious Devices - Expansion.esm") As Armor)    ;;; zadx_GagEboniteBallInventory
   _aoGags[06] = (Game.GetFormFromFile(0x0000D4F3, "Devious Devices - Expansion.esm") As Armor)    ;;; zadx_GagEbonitePanelInventory
   _aoGags[07] = (Game.GetFormFromFile(0x0000D4F0, "Devious Devices - Expansion.esm") As Armor)    ;;; zadx_GagEboniteRingInventory
   _aoGags[08] = (Game.GetFormFromFile(0x0000D4F6, "Devious Devices - Expansion.esm") As Armor)    ;;; zadx_GagEboniteStrapBallInventory
   _aoGags[09] = (Game.GetFormFromFile(0x0000D4F8, "Devious Devices - Expansion.esm") As Armor)    ;;; zadx_GagEboniteStrapRingInventory
   _aoGags[10] = (Game.GetFormFromFile(0x00011126, "Devious Devices - Expansion.esm") As Armor)    ;;; zadx_RDEGagEbBallInventory
   _aoGags[11] = (Game.GetFormFromFile(0x00011130, "Devious Devices - Expansion.esm") As Armor)    ;;; zadx_RDEGagEbHarnPanelInventory
   _aoGags[12] = (Game.GetFormFromFile(0x0001112A, "Devious Devices - Expansion.esm") As Armor)    ;;; zadx_RDEGagEbRingInventory
   _aoGags[13] = (Game.GetFormFromFile(0x00011146, "Devious Devices - Expansion.esm") As Armor)    ;;; zadx_RDEGagEbStrapBallInventory
   _aoGags[14] = (Game.GetFormFromFile(0x0001114A, "Devious Devices - Expansion.esm") As Armor)    ;;; zadx_RDEGagEbStrapRingInventory
   _aoGags[15] = (Game.GetFormFromFile(0x00011124, "Devious Devices - Expansion.esm") As Armor)    ;;; zadx_RDLgagBallInventory
   _aoGags[16] = (Game.GetFormFromFile(0x0001112D, "Devious Devices - Expansion.esm") As Armor)    ;;; zadx_RDLgagHarnPanelInventory
   _aoGags[17] = (Game.GetFormFromFile(0x00011128, "Devious Devices - Expansion.esm") As Armor)    ;;; zadx_RDLgagRingInventory
   _aoGags[18] = (Game.GetFormFromFile(0x00011144, "Devious Devices - Expansion.esm") As Armor)    ;;; zadx_RDLgagStrapBallInventory
   _aoGags[19] = (Game.GetFormFromFile(0x00011148, "Devious Devices - Expansion.esm") As Armor)    ;;; zadx_RDLgagStrapRingInventory
   _aoGags[20] = (Game.GetFormFromFile(0x0000F04A, "Devious Devices - Expansion.esm") As Armor)    ;;; zadx_WTEGagEbBallInventory
   _aoGags[21] = (Game.GetFormFromFile(0x0000F054, "Devious Devices - Expansion.esm") As Armor)    ;;; zadx_WTEGagEbHarnPanelInventory
   _aoGags[22] = (Game.GetFormFromFile(0x0000F04E, "Devious Devices - Expansion.esm") As Armor)    ;;; zadx_WTEGagEbRingInventory
   _aoGags[23] = (Game.GetFormFromFile(0x0000F062, "Devious Devices - Expansion.esm") As Armor)    ;;; zadx_WTEGagEbStrapRingInventory
   _aoGags[24] = (Game.GetFormFromFile(0x0000F048, "Devious Devices - Expansion.esm") As Armor)    ;;; zadx_WTLgagBallInventory
   _aoGags[25] = (Game.GetFormFromFile(0x0000F051, "Devious Devices - Expansion.esm") As Armor)    ;;; zadx_WTLgagHarnPanelInventory
   _aoGags[26] = (Game.GetFormFromFile(0x0000F04C, "Devious Devices - Expansion.esm") As Armor)    ;;; zadx_WTLgagRingInventory
   _aoGags[27] = (Game.GetFormFromFile(0x0000F05C, "Devious Devices - Expansion.esm") As Armor)    ;;; zadx_WTLgagStrapBallInventory
   _aoGags[28] = (Game.GetFormFromFile(0x0000F060, "Devious Devices - Expansion.esm") As Armor)    ;;; zadx_WTLgagStrapRingInventory

   _aoArmRestraints = New Armor[7]
   _aoArmRestraints[0] = (Game.GetFormFromFile(0x00028A5A, "Devious Devices - Integration.esm") As Armor)  ;;; zad_armBinderInventory
   _aoArmRestraints[1] = (Game.GetFormFromFile(0x0000D4D6, "Devious Devices - Expansion.esm") As Armor)    ;;; zadx_EboniteArmbinderInventory
   _aoArmRestraints[2] = (Game.GetFormFromFile(0x000110F2, "Devious Devices - Expansion.esm") As Armor)    ;;; zadx_RDEarmbinderInventory
   _aoArmRestraints[3] = (Game.GetFormFromFile(0x000110F0, "Devious Devices - Expansion.esm") As Armor)    ;;; zadx_RDLarmbinderInventory
   _aoArmRestraints[4] = (Game.GetFormFromFile(0x0000F016, "Devious Devices - Expansion.esm") As Armor)    ;;; zadx_WTEarmbinderInventory
   _aoArmRestraints[5] = (Game.GetFormFromFile(0x0000F013, "Devious Devices - Expansion.esm") As Armor)    ;;; zadx_WTLarmbinderInventory
   _aoArmRestraints[6] = (Game.GetFormFromFile(0x0004F18C, "Devious Devices - Integration.esm") As Armor)  ;;; zad_yokeInventory

   _aoLegRestraints = New Armor[6]
   _aoLegRestraints[00] = (Game.GetFormFromFile(0x000116FA, "Devious Devices - Expansion.esm") As Armor)  ;;; zadx_XinWTLPonyBootsInventory
   _aoLegRestraints[01] = (Game.GetFormFromFile(0x000116FE, "Devious Devices - Expansion.esm") As Armor)  ;;; zadx_XinWTEbonitePonyBootsInventory
   _aoLegRestraints[02] = (Game.GetFormFromFile(0x000116F1, "Devious Devices - Expansion.esm") As Armor)  ;;; zadx_XinPonyBootsInventory
   _aoLegRestraints[03] = (Game.GetFormFromFile(0x000116F6, "Devious Devices - Expansion.esm") As Armor)  ;;; zadx_XinEbonitePonyBootsInventory
   _aoLegRestraints[04] = (Game.GetFormFromFile(0x00011706, "Devious Devices - Expansion.esm") As Armor)  ;;; zadx_XinRDEbonitePonyBootsInventory
   _aoLegRestraints[05] = (Game.GetFormFromFile(0x000048B8, "Devious Devices - Expansion.esm") As Armor)  ;;; zadx_bootsLockingInventory

   _aoCollars = New Armor[14]
   _aoCollars[00] = (Game.GetFormFromFile(0x00017759, "Devious Devices - Integration.esm") As Armor)  ;;; zad_collarPostureSteelInventory
   _aoCollars[01] = (Game.GetFormFromFile(0x0001775C, "Devious Devices - Integration.esm") As Armor)  ;;; zad_cuffsPaddedCollarInventory
   _aoCollars[02] = (Game.GetFormFromFile(0x00032745, "Devious Devices - Integration.esm") As Armor)  ;;; zad_cuffsLeatherCollarInventory
   _aoCollars[03] = (Game.GetFormFromFile(0x00047002, "Devious Devices - Integration.esm") As Armor)  ;;; zad_collarPostureLeatherInventory
   _aoCollars[04] = (Game.GetFormFromFile(0x0000D4DF, "Devious Devices - Expansion.esm") As Armor)    ;;; zadx_CuffsEboniteCollarInventory
   _aoCollars[05] = (Game.GetFormFromFile(0x0000E538, "Devious Devices - Expansion.esm") As Armor)    ;;; zadx_CollarPostureEboniteInventory
   _aoCollars[06] = (Game.GetFormFromFile(0x0000F01D, "Devious Devices - Expansion.esm") As Armor)    ;;; zadx_WTLcuffsLCollarInventory
   _aoCollars[07] = (Game.GetFormFromFile(0x0000F020, "Devious Devices - Expansion.esm") As Armor)    ;;; zadx_WTECuffsECollarInventory
   _aoCollars[08] = (Game.GetFormFromFile(0x0000F06A, "Devious Devices - Expansion.esm") As Armor)    ;;; zadx_WTLCollarPostLeatherInventory
   _aoCollars[09] = (Game.GetFormFromFile(0x0000F06C, "Devious Devices - Expansion.esm") As Armor)    ;;; zadx_WTECollarPostEboniteInventory
   _aoCollars[10] = (Game.GetFormFromFile(0x000110FE, "Devious Devices - Expansion.esm") As Armor)    ;;; zadx_RDLcuffsLCollarInventory
   _aoCollars[11] = (Game.GetFormFromFile(0x00011100, "Devious Devices - Expansion.esm") As Armor)    ;;; zadx_RDECuffsECollarInventory
   _aoCollars[12] = (Game.GetFormFromFile(0x00011152, "Devious Devices - Expansion.esm") As Armor)    ;;; zadx_RDLCollarPostLeatherInventory
   _aoCollars[13] = (Game.GetFormFromFile(0x00011154, "Devious Devices - Expansion.esm") As Armor)    ;;; zadx_RDECollarPostEboniteInventory

   _aoBlindfolds = New Armor[6]
   _aoBlindfolds[00] = (Game.GetFormFromFile(0x00004E25, "Devious Devices - Expansion.esm") As Armor)    ;;; zadx_blindfoldBlockingInventory
   _aoBlindfolds[01] = (Game.GetFormFromFile(0x0001334E, "Devious Devices - Expansion.esm") As Armor)    ;;; zadx_EbblindfoldBlockingInventory
   _aoBlindfolds[02] = (Game.GetFormFromFile(0x00013356, "Devious Devices - Expansion.esm") As Armor)    ;;; zadx_RDEblindfoldBlockingInventory
   _aoBlindfolds[03] = (Game.GetFormFromFile(0x00013354, "Devious Devices - Expansion.esm") As Armor)    ;;; zadx_RDLblindfoldBlockingInventory
   _aoBlindfolds[04] = (Game.GetFormFromFile(0x00013352, "Devious Devices - Expansion.esm") As Armor)    ;;; zadx_WTEblindfoldBlockingInventory
   _aoBlindfolds[05] = (Game.GetFormFromFile(0x00013350, "Devious Devices - Expansion.esm") As Armor)    ;;; zadx_WTLblindfoldBlockingInventory

   _aoMittens = New Armor[6]
   _aoMittens[00] = (Game.GetFormFromFile(0x00026DDD, "Devious Devices - Expansion.esm") As Armor)    ;;; zadx_PawBondageMittensWhiteLatexInventory
   _aoMittens[01] = (Game.GetFormFromFile(0x000237B8, "Devious Devices - Expansion.esm") As Armor)    ;;; zadx_PawBondageMittensWhiteInventory
   _aoMittens[02] = (Game.GetFormFromFile(0x00026879, "Devious Devices - Expansion.esm") As Armor)    ;;; zadx_PawBondageMittensRedLatexInventory
   _aoMittens[03] = (Game.GetFormFromFile(0x000237B5, "Devious Devices - Expansion.esm") As Armor)    ;;; zadx_PawBondageMittensRedInventory
   _aoMittens[04] = (Game.GetFormFromFile(0x00026DDF, "Devious Devices - Expansion.esm") As Armor)    ;;; zadx_PawBondageMittensLatexInventory
   _aoMittens[05] = (Game.GetFormFromFile(0x0002324D, "Devious Devices - Expansion.esm") As Armor)    ;;; zadx_PawBondageMittensInventory

   DebugTrace("TraceEvent CreateRestraintsArrays: Done")
EndFunction

Keyword Function GetDeviousKeyword(Armor oRestraint)
   Int iIndex = _aoZadDeviceKeyword.Length - 1
   While (0 <= iIndex)
      If (oRestraint.HasKeyword(_aoZadDeviceKeyword[iIndex]))
         Return _aoZadDeviceKeyword[iIndex]
      EndIf
      iIndex -= 1
   EndWhile
   Return None
EndFunction

Bool Function IsDeviceFromDfws(Armor oItemRendered)
   Float fCurrRealTime = Utility.GetCurrentRealTime()
   DebugTrace("TraceEvent IsDeviceFromDfws - " + fCurrRealTime)

   ; Find the appropriate keyword on the rendered item.  Since we are only looking for
   ; restraints from our mod we are only interested in a limited set of keywords.
   Keyword oDeviousKeyword = None
   ; 14: zad_DeviousGag
   If (oItemRendered.HasKeyword(_aoZadDeviceKeyword[14]))
      oDeviousKeyword = _aoZadDeviceKeyword[14]
   ; 5: zad_DeviousArmbinder
   ElseIf (oItemRendered.HasKeyword(_aoZadDeviceKeyword[5]))
      oDeviousKeyword = _aoZadDeviceKeyword[5]
   ; 8: zad_DeviousYoke
   ElseIf (oItemRendered.HasKeyword(_aoZadDeviceKeyword[8]))
      oDeviousKeyword = _aoZadDeviceKeyword[8]
   ; 19; zad_DeviousBoots
   ElseIf (oItemRendered.HasKeyword(_aoZadDeviceKeyword[19]))
      oDeviousKeyword = _aoZadDeviceKeyword[19]
   ; 2: zad_DeviousCollar
   ElseIf (oItemRendered.HasKeyword(_aoZadDeviceKeyword[2]))
      oDeviousKeyword = _aoZadDeviceKeyword[2]
   ; 18: zad_DeviousBlindfold
   ElseIf (oItemRendered.HasKeyword(_aoZadDeviceKeyword[18]))
      oDeviousKeyword = _aoZadDeviceKeyword[18]
   EndIf

   ; If it is not one of the simple device keywords it is not one of our items.
   If (!oDeviousKeyword)
      Return False
   EndIf

   ; Keep track of the keyword here to avoid referenceing it often and context switching.
   Keyword oZadKeywordInventory = _qZadLibs.zad_InventoryDevice

   ; Search the inventory for a "Devious Inventory" item with the same keyword.
   Int iIndex = _aPlayer.GetNumItems() - 1
   While (0 <= iIndex)
      ; Check the item is an inventory item, is equipped and has the right keyword.
      Form oInventoryItem = _aPlayer.GetNthForm(iIndex)
      If (oInventoryItem && oInventoryItem.HasKeyword(oZadKeywordInventory))
         If (_aPlayer.IsEquipped(oInventoryItem) && \
             (oDeviousKeyword == _qZadLibs.GetDeviceKeyword(oInventoryItem As Armor)))
            DebugTrace("TraceEvent IsDeviceFromDfws: Done (Found) - " + \
                       (Utility.GetCurrentRealTime() - fCurrRealTime))
            ; This is an equipped item of the same type.  Check if it is one from this mod.
            ; 14: zad_DeviousGag
            If (oDeviousKeyword == _aoZadDeviceKeyword[14])
               Return (-1 != _aoGags.Find((oInventoryItem As Armor)))
            ; 5: zad_DeviousArmbinder
            ElseIf (oDeviousKeyword == _aoZadDeviceKeyword[5])
               Return (-1 != _aoArmRestraints.Find((oInventoryItem As Armor)))
            ; 8: zad_DeviousYoke
            ElseIf (oDeviousKeyword == _aoZadDeviceKeyword[8])
               Return (-1 != _aoArmRestraints.Find((oInventoryItem As Armor)))
            ; 19; zad_DeviousBoots
            ElseIf (oDeviousKeyword == _aoZadDeviceKeyword[19])
               Return (-1 != _aoLegRestraints.Find((oInventoryItem As Armor)))
            ; 2: zad_DeviousCollar
            ElseIf (oDeviousKeyword == _aoZadDeviceKeyword[2])
               Return (-1 != _aoCollars.Find((oInventoryItem As Armor)))
            ; 18: zad_DeviousBlindfold
            ElseIf (oDeviousKeyword == _aoZadDeviceKeyword[18])
               Return (-1 != _aoBlindfolds.Find((oInventoryItem As Armor)))
            ; 22: zad_DeviousBondageMittens
            ElseIf (oDeviousKeyword == _aoZadDeviceKeyword[22])
               Return (-1 != _aoMittens.Find((oInventoryItem As Armor)))
            EndIf
         EndIf
      EndIf
      iIndex -= 1
   EndWhile

   ; If we did not find the associated inventory item assume it is not one of ours.
   DebugTrace("TraceEvent IsDeviceFromDfws: Done - " + (Utility.GetCurrentRealTime() - \
                                                        fCurrRealTime))
   Return False
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

; A special name for function trace log messages making them easier to locate.
Function DebugTrace(String szMessage, Int iLevel=0, String szClass="")
   ; Log to the papyrus file only.
   Debug.Trace("[" + S_MOD + "] " + szMessage)
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

Bool Function IsActor(Form oForm)
   Int iType = oForm.GetType()
   ; 43 (kNPC) 44 (kLeveledCharacter) 62 (kCharacter)
   Return ((43 == iType) || (44 == iType) || (62 == iType))
EndFunction

Function StartNpcAnimation(Actor aNpc, String szAnimation, String szOldAnimation, \
                           ObjectReference oTarget)
   ; If the new animation is the same as the old animation ignore this request.
   If (szAnimation == szOldAnimation)
      Return
   EndIf

   ; Stop any previous animation that may be playing.
   StopNpcAnimation(aNpc, szOldAnimation)

   ; If there is a target have the NPC turn to face it.
   If (oTarget)
      Float fZRotation = aNpc.GetHeadingAngle(oTarget)
      aNpc.SetAngle(aNpc.GetAngleX(), aNpc.GetAngleY(), aNpc.GetAngleZ() + fZRotation)
   EndIf

Log("Starting NPC Animation: " + szAnimation, DL_INFO, S_MOD)
   Debug.SendAnimationEvent(aNpc, szAnimation)
EndFunction

Function StopNpcAnimation(Actor aNpc, String szOldAnimation)
   If (!szOldAnimation)
      Return
   EndIf

Log("Stopping Animation: " + szOldAnimation, DL_TRACE, S_MOD)
   If (("IdleHammerWallEnter" == szOldAnimation) || ("IdleHammerTableEnter" == szOldAnimation))
      Debug.SendAnimationEvent(aNpc, "IdleChairExitStart")
   Else
      ; 0x0010D9EE: IdleStop_Loose
      Idle oIdleStop = (Game.GetFormFromFile(0x0010D9EE, "Skyrim.esm") As Idle)
      aNpc.PlayIdle(oIdleStop)
   EndIf
EndFunction

Int Function StartSex(Actor aNpc, Bool bRape)
   DebugTrace("TraceEvent StartSex")
   If ((0 >= _qSexLab.ValidateActor(_aPlayer)) || (0 >= _qSexLab.ValidateActor(aNpc)))
      DebugTrace("TraceEvent StartSex: Done (Not Valid)")
      Return FAIL
   EndIf

   ; Keep track of some bound animations as the dominant actor cannot be switched for them.
   Bool bBoundAnimation = False

   Actor aVictim
   String szTags
   If (bRape)
      aVictim = _aPlayer
      szTags = "Aggressive"
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
      _qFramework.MovePlayer(_aPlayer, -35 * Math.Sin(_aPlayer.GetAngleZ()), \
                                       -35 * Math.Cos(_aPlayer.GetAngleZ()))
; I suspect this may be contributing to increased crash to desktops.  Commenting out for now.
;   Else
;      ; Adjust the positions to reduce the chance of the player being behind the furniture.
;      aNpc.MoveTo(_aPlayer, 70 * Math.Sin(_aPlayer.GetAngleZ()), \
;                            70 * Math.Cos(_aPlayer.GetAngleZ()), 0.0)
;      _qFramework.MovePlayer(_aPlayer, 35 * Math.Sin(_aPlayer.GetAngleZ()), \
;                                       35 * Math.Cos(_aPlayer.GetAngleZ()))
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

   ; Make sure any previous sex scenes involving these actors have completed before starting.
   If (_fSexLabCooldown)
      Float fTimePassed = Utility.GetCurrentRealTime() - _fSexLabCooldown
      If ((0 < fTimePassed) && (13 > fTimePassed))
         Utility.Wait(13 - fTimePassed)
      EndIf
   EndIf

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
      DebugTrace("TraceEvent StartSex: Done (SexLab Failed)")
      Return FAIL
   EndIf

   ; If this is the beginning of one of our sex scenes that would naturally end a scene, make
   ; sure to mark the scene as ready to end.
   ; This is needed because Post Sex Callbacks don't identify which mod started the scene and
   ; we don't want to end our scenes after sex from other mods.
   String szCurrScene = _qFramework.GetCurrentScene()
   If (S_MOD + "_FurnForFun" == szCurrScene)
      _bSceneReadyToEnd = True
   EndIf

   DebugTrace("TraceEvent StartSex: Done")
   Return SUCCESS
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

; Figures out whether the player can upgrade the NPC's armour based on the smithing perks the
; player has.  The perk that should be used to upgrade the armour is returned or None if the
; NPc's current outfit (based on oMinPerk) is as good as it gets.  The NPC's skill in light
; and heavy armour is also taken into account.
;
; The calculation is NPC's (LightArmour skill / 2) plus a value assigned to the player's
; light armour perks.  Each of these is in the range 0-50.  This is compared to similar
; values for heavy armour.
Perk Function GetForgeUpgradePerk(Actor aNpc, Perk oMinPerk)
   ; If the NPC is already using dragon armour don't try to find something better. 
   If (oMinPerk == _oPerkSmithDragon)
      Return None
   EndIf

   ; If the player has the dragon armour perk return that.
   If (_aPlayer.HasPerk(_oPerkSmithDragon))
      Return _oPerkSmithDragon
   EndIf

   ; Assign a numeric value for the light armour (player's perk and NPC's skill).
   ;  Steel(10)  Elven(20)  Glass(30)
   Int iLightValue = (((aNpc.GetActorValue("LightArmor") As Int) / 2) As Int)
   Perk oLightPerk = oMinPerk
   If ((_oPerkSmithDaedric == oMinPerk) || (_oPerkSmithEbony == oMinPerk) || \
       (_oPerkSmithOrcish == oMinPerk))
      oLightPerk = None
   EndIf
   If ((oLightPerk == _oPerkSmithGlass) || _aPlayer.HasPerk(_oPerkSmithGlass))
      oLightPerk = _oPerkSmithGlass
      iLightValue += 30
   ElseIf ((oLightPerk == _oPerkSmithElven) || _aPlayer.HasPerk(_oPerkSmithElven))
      oLightPerk = _oPerkSmithElven
      iLightValue += 20
   ElseIf ((oLightPerk == _oPerkSmithSteel) || _aPlayer.HasPerk(_oPerkSmithSteel))
      oLightPerk = _oPerkSmithSteel
      iLightValue += 10
   EndIf

   ; Assign a numeric value for the heavy armour (player's perk and NPC's skill).
   ;  Steel(10)  Orcish(20)  Ebony(30)  Daedric(40)
   ;  10 - Steel Smithing
   Int iHeavyValue = (((aNpc.GetActorValue("HeavyArmor") As Int) / 2) As Int)
   Perk oHeavyPerk = oMinPerk
   If ((_oPerkSmithGlass == oMinPerk) || (_oPerkSmithElven == oMinPerk))
      oHeavyPerk = None
   EndIf
   If ((oHeavyPerk == _oPerkSmithDaedric) || _aPlayer.HasPerk(_oPerkSmithDaedric))
      oHeavyPerk = _oPerkSmithDaedric
      iHeavyValue += 40
   ElseIf ((oHeavyPerk == _oPerkSmithEbony) || _aPlayer.HasPerk(_oPerkSmithEbony))
      oHeavyPerk = _oPerkSmithEbony
      iHeavyValue += 30
   ElseIf ((oHeavyPerk == _oPerkSmithOrcish) || _aPlayer.HasPerk(_oPerkSmithOrcish))
      oHeavyPerk = _oPerkSmithOrcish
      iHeavyValue += 20
   ElseIf ((oHeavyPerk == _oPerkSmithSteel) || _aPlayer.HasPerk(_oPerkSmithSteel))
      oHeavyPerk = _oPerkSmithSteel
      iHeavyValue += 10
   EndIf

   DebugLog("Comparing: " + GetFormName(oLightPerk) + "(" + iLightValue + ") vs. " + \
            GetFormName(oHeavyPerk) + "(" + iHeavyValue + ")")
   If (iLightValue > iHeavyValue)
      Return oLightPerk
   EndIf
   Return oHeavyPerk
EndFunction

; 0-100 - Player's Enchanting Level (rounded down to the nearest 10s).
; 101   - Extra Effect
Int Function GetPlayerLevelEnchant(Int iMinLevel=0)

; Enchanting is not currently supported.
Return 0

   If (101 < iMinLevel)
      Perk oExtraEffect = (Game.GetFormFromFile(0x00058F7F, "Skyrim.esm") As Perk)
      If (_aPlayer.HasPerk(oExtraEffect))
         Return 101
      EndIf
   EndIf
   Return (_aPlayer.GetActorValue("Enchanting") As Int)
EndFunction

; 0-100 - Player's Alchemy Level (rounded down to the nearest 10s).
; +10   - Benefactor increases the player's alchemy level by ten.
Int Function GetPlayerLevelAlchemy(Int iMinLevel=0)
   ; If the minimum level is already the maximum just return that.
   If (110 == iMinLevel)
      Return iMinLevel
   EndIf
   Int iLevel = (_aPlayer.GetActorValue("Alchemy") As Int)
   Perk oBenefactor = (Game.GetFormFromFile(0x00058216, "Skyrim.esm") As Perk)
   If (_aPlayer.HasPerk(oBenefactor))
      iLevel += 10
   EndIf
   Return iLevel
EndFunction

; TODO: Filter out equipment the NPC already has.
Function GivePlayerCraftingItems(Int iSetIndex, Actor aNpc, Bool bAddToAllowedItems=True, \
                                 Int iNumItems=1)
   If (-1 == iSetIndex)
      Return
   EndIf

   Int iItemIndex = _aoSetFirstItem[iSetIndex]
   While (iItemIndex <= _aoSetLastItem[iSetIndex])
      Int iItemId = _aoRecipeItemId[iItemIndex]

If (0 < iItemId)
   Form oItem = Game.GetFormFromFile(iItemId, "Skyrim.esm")
   DebugLog("Processing 0x" + _qDfwUtil.ConvertHexToString(iItemId, 8) + ": " + GetFormName(oItem), DL_DEBUG)
Else
   DebugLog("Processing " + iItemId, DL_DEBUG)
EndIf

      If (bAddToAllowedItems)
         Int iAllowedItemIndex = _aiAllowedItems.Find(iItemId)
         If (-1 == iAllowedItemIndex)
            _aiAllowedItems = _qDfwUtil.AddIntToArray(_aiAllowedItems, iItemId)
            _aiAllowedQuantity = _qDfwUtil.AddIntToArray(_aiAllowedQuantity, iNumItems)
         Else
            _aiAllowedQuantity[iAllowedItemIndex] = _aiAllowedQuantity[iAllowedItemIndex] + 1
         EndIf
      EndIf

      Int iIngredientIndex = _aiRecipeFirstItem[iItemIndex]
DebugLog("Ingredient Range " + iItemIndex + ": " + _aiRecipeFirstItem[iItemIndex] + "-" + _aiRecipeLastItem[iItemIndex], DL_DEBUG)
      While (iIngredientIndex <= _aiRecipeLastItem[iItemIndex])
         Int iIngredientListIndex = _aiRecipeIngredient0[iIngredientIndex]
         Int iQuantity = _aiRecipeQuantity0[iIngredientIndex]
         If (1 == _aiIngredientArray[iItemIndex])
            iIngredientListIndex = _aiRecipeIngredient1[iIngredientIndex]
            iQuantity = _aiRecipeQuantity1[iIngredientIndex]
         EndIf
DebugLog("Item(" + iItemIndex + ") Ingredient " + _aiIngredientArray[iItemIndex] + "-" + iIngredientListIndex, DL_DEBUG)

         Form oIngredient = _aoIngredientList[iIngredientListIndex]
DebugLog("Adding " + GetFormName(oIngredient, True) + "(" + iQuantity + ")", DL_DEBUG)


         _aPlayer.AddItem(oIngredient, iNumItems * iQuantity, abSilent=True)

         iIngredientIndex += 1
      EndWhile

      iItemIndex += 1
   EndWhile
EndFunction



Function PrepPlayerActorForScene(Bool bClear=False)
   Actor aPlayerActor = (_aAliasPlayerActor.GetReference() As Actor)

   ; If the scene is done hide/disable the actor.
   If (bClear)
      ; Disable the actor and return her to her editor location.
      aPlayerActor.Disable()
      aPlayerActor.MoveToMyEditorLocation()
      Return
   EndIf

   ; Otherwise the scene is about to start.
   ; Make sure the actor has the correct name.  Do this here in case it has changed.
   aPlayerActor.SetDisplayName(_aPlayer.GetDisplayName(), True)

   ; Make sure the actor is near enough to be in the scene but far enough to be out of sight.
   aPlayerActor.MoveTo(_aPlayer, -7500.0, -7500.0, -7500.0)
   aPlayerActor.Enable()
EndFunction

Function FindEventClockTick()
   ; Find the current hour.  Strip the days, conver to hours, then strip the remainder.
   Float fCurrTime = Utility.GetCurrentGameTime()
   fCurrTime -= (fCurrTime As Int)
   fCurrTime *= 24.0
   Int iCurrHour = (fCurrTime As Int)

   ; Figure out if we have just passed a specific hour.
   Int iHour = -1
   If (iCurrHour != _iEventCheckLastHour)
      iHour = iCurrHour
      _iEventCheckLastHour = iHour
   EndIf

   Bool bEventFound

   ; Consider decreasing the player's bad behaviour count over time.
   If ((0 < _iBadBehaviour) && (0 == iHour))
      ; Decrease it at midnight if the player has been behaving for at least twelve hours.
      If (_fTimeLastPunished < (Utility.GetCurrentGameTime() - (12.0 / 24.0)))
         _iBadBehaviour -= 1
      EndIf
   EndIf

   ; Keep track of what the active scene is.
   String szCurrScene = _qFramework.GetCurrentScene()

   Float fRoll = Utility.RandomFloat(0, 100)
   String szRollLog = "Find Event Roll (Hour " + iHour + "): " + fRoll
   If (0 == iHour)
      ; At midnight if the player is still enslaved increase her training level.
      Actor aMaster = _qFramework.GetMaster()
      If (aMaster)
         IncreaseTrainingLevel(0.5, aMaster)
      EndIf

      ; Check if the player is to become a permanent slave.
      If (fRoll < _qMcm.fEventPermanency)
         _bPermanency = True
      EndIf
   ElseIf ((9 <= iHour) && (12 >= iHour) && !_oPunishmentFurniture)
      ; On each hour in the morning check for events that require open shops.

      ; Check if the slaver wants to sell the player's items to a vendor.
      If (_iWeaponsStolen && !_bAllItemsTaken && (fRoll < _qMcm.fEventSellItems) && \
          (0 < _iLeashGameDuration) && (0 >= _iAgendaShortTerm) && \
          (_iCrawlRemaining < ((180 / _fMcmPollTime) As Int)))
         Int iRegionIndex = _qFramework.GetNearestRegionIndex(iVersion=1)
         If (-1 != iRegionIndex)
            ; 4: Start Scene.  Scene 3: Sell the player's items.
            AddPendingAction(4, 3, szScene=S_MOD + "_SellItems")
            bEventFound = True
         EndIf
      EndIf

      ; Reset the roll to check for a different event.
      fRoll = Utility.RandomFloat(0, 100)
      szRollLog += "  A: " + fRoll

      ; If the player is wearing other mod's restraints see if the blacksmith can remove them.
      If (!_bOtherRestraintsRemoved && (fRoll < _qMcm.fEventRemRestraints) && !bEventFound && \
          (0 < _iLeashGameDuration) && (0 >= _iAgendaShortTerm) && IsWearingInvalidRestraints())
         ; 4: Start Scene.  Scene 6: Ask the blacksmith to remove restraints from other mods.
         AddPendingAction(4, 6, szScene=S_MOD + "_RemoveRestraints", bUnique=True)
         bEventFound = True
      EndIf

      ; Reset the roll to check for a different event.
      fRoll = Utility.RandomFloat(0, 100)
      szRollLog += "  B: " + fRoll

      ; Check if the slaver needs to upgrade his equipment.
      If ((fRoll < _qMcm.fEventEquipSlaver) && !bEventFound && (0 < _iLeashGameDuration) && \
          (0 >= _iAgendaShortTerm))
         ; Verify this event could actually start.
         Location oRegion = _qFramework.GetCurrentRegion()
         ; 0x0008: Work Furniture
         ObjectReference oForge   = GetRandomFurniture(oRegion=oRegion, iIncludeFlags=0x2008)
         ObjectReference oEnchant = GetRandomFurniture(oRegion=oRegion, iIncludeFlags=0x4008)
         ObjectReference oAlchemy = GetRandomFurniture(oRegion=oRegion, iIncludeFlags=0x8008)

         Perk oUpgradForgePerk = GetForgeUpgradePerk(_aLeashHolder, _oEquipForgePerk)
         Int iPlayerLevelEnchant = GetPlayerLevelEnchant(_iEquipEnchantLevel)
         Int iPlayerLevelAlchemy = GetPlayerLevelAlchemy(_iEquipPotionLevel)

         If (oForge && oUpgradForgePerk)
            ; 4: Start Scene.  Scene 11: Force the player to craft armour.
            AddPendingAction(4, 11, szScene=S_MOD + "_ForgeArmour", bUnique=True)
            bEventFound = True
         ElseIf (oEnchant && (iPlayerLevelEnchant > _iEquipEnchantLevel))
            ; 4: Start Scene.  Scene 12: Force the player to enchant armour.
            AddPendingAction(4, 12, szScene=S_MOD + "_EnchantArmour", bUnique=True)
            bEventFound = True
         ElseIf (oAlchemy && (iPlayerLevelAlchemy > _iEquipPotionLevel))
            ; 4: Start Scene.  Scene 13: Force the player to craft healing potions.
            AddPendingAction(4, 13, szScene=S_MOD + "_CraftPotions", bUnique=True)
            bEventFound = True
         EndIf
      EndIf
   ElseIf (18 == iHour)
      ; In the evening have the slaver distribute some of the gold stolen from the player
      ; making it unrecoverable post leash game.
      If (_iGoldStolen)
         Int iGoldCount = _aLeashHolder.GetItemCount(_oGold)
         If (iGoldCount != _iGoldStolen)
            _iGoldStolen = iGoldCount
         EndIf
         ; If the slaver has just a regular amount of gold leave it for him to carry.
         If (180 > _iGoldStolen)
            _iGoldStolen = 0
         EndIf
         If (_iGoldStolen)
            _aPlayer.RemoveItem(_oGold, (_iGoldStolen / 2))
         EndIf
      EndIf
   EndIf

   ; The following events are only valid if the leash game is active.
   If (0 < _iLeashGameDuration)
      ; Check if the Milk Mod Economy mod is installed and the player is ready to be milked.
      If (_oMmeBeingMilkedSpell && !bEventFound && (fRoll < _fMcmEventMilkScene) && \
          !_oTransferFurniture)
         ; Find a usable milking machine.
         Location oRegion = _qFramework.GetCurrentRegion()
         ; 0x0200: Milking Furniture
         ObjectReference oMachine = GetRandomFurniture(oRegion=oRegion, iIncludeFlags=0x0200)

         ; The scene can start if the player is ready to be milked and a machine is nearby.
         ; Also make sure the player isn't wearing any restraints we can't remove.  The milking
         ; furniture won't allow milking under a number of conditions.
         If (oMachine && (_qMcm.fEventMilkThreshold < MME_Storage.getMilkCurrent(_aPlayer)) && \
             !IsWearingInvalidRestraints())
            ; 4: Start Scene.  5: Milk the player (Milk Maid Economy).
            AddPendingAction(4, 5, _aLeashHolder, S_MOD + "_MilkPlayer", bUnique=True)
            bEventFound = True
         EndIf
      EndIf

      ; Only consider the following events if no other scene is going on.
      If (!szCurrScene && !bEventFound && !_aiPendingAction && (1 == _iAgendaLongTerm) && \
          (1 >= _iAgendaMidTerm) && (0 >= _iAgendaShortTerm))
         ; Reset the roll to check for a different event.
         fRoll = Utility.RandomFloat(0, 100)
         szRollLog += "  C: " + fRoll

         If (fRoll < _fMcmEventProposition)
            ; Scan all nearby dominant NPCs to see if they qualify for the scene.
            Form[] aNearbyDoms = _qFramework.GetNearbyActorList(1200.0, _qFramework.AF_DOMINANT)
            If (aNearbyDoms)
               Int iIndex = aNearbyDoms.Length - 1
               While (!bEventFound && (0 <= iIndex))
                  Actor aNearbyDom = (aNearbyDoms[iIndex] As Actor)
                  Int iArousal = _qSexLabAroused.GetActorArousal(aNearbyDom)

                  ; If the NPC qualifies start a proposition scene with him.
                  If ((aNearbyDom != _aLeashHolder) && (_iMcmEventPropArousal <= iArousal) && \
                      (fRoll < ((_fMcmEventProposition * iArousal) / 100)))
                     ; 4: Start Scene.  10: Proposition the slaver for sex.
                     AddPendingAction(4, 10, aNearbyDom, S_MOD + "_PropositionSex")
                     bEventFound = True
                  EndIf

                  iIndex -= 1
               EndWhile
            EndIf
         EndIf
      EndIf
   EndIf
   Log(szRollLog, DL_TRACE, S_MOD)
EndFunction

Int Function LeashGameFindExcuse(Actor aAgressor)
   ; If the leash game excuse has already been identified just use that.
   If (_iLeashGameExcuse)
      Return _iLeashGameExcuse
   EndIf

   ; Only include the vulnerability excuse if the player is actually vulnerable.
   If (40 <= _qFramework.GetVulnerability(_aPlayer))
      Return Utility.RandomInt(1, 5)
   EndIf

   ; For now just choose an excuse at random.
   Return Utility.RandomInt(1, 4)
EndFunction

Bool Function IsWearingInvalidRestraints()
   DebugTrace("TraceEvent IsWearingInvalidRestraints")

   If (_qFramework.IsPlayerGagged())
      ; 14: zad_DeviousGag
      Armor oWorn = _qZadLibs.GetWornDevice(_aPlayer, _aoZadDeviceKeyword[14])
      If (oWorn && (-1 == _aoGags.Find(oWorn)))
         DebugTrace("TraceEvent IsWearingInvalidRestraints: Done (Gag)")
Log("Invalid Gag Detected!", DL_DEBUG, S_MOD)
         Return True
      EndIf
   EndIf

   If (_qFramework.IsPlayerArmLocked())
      ; Check for ArmBinders, Yokes, and Mittens.
      ; 5: zad_DeviousArmbinder
      Armor oWorn = _qZadLibs.GetWornDevice(_aPlayer, _aoZadDeviceKeyword[5])
      If (oWorn && (-1 == _aoArmRestraints.Find(oWorn)))
         DebugTrace("TraceEvent IsWearingInvalidRestraints: Done (Arm Binder)")
Log("Invalid Arm Binder Detected!", DL_DEBUG, S_MOD)
         Return True
      EndIf

      ; 8: zad_DeviousYoke
      oWorn = _qZadLibs.GetWornDevice(_aPlayer, _aoZadDeviceKeyword[5])
      If (oWorn && (-1 == _aoArmRestraints.Find(oWorn)))
         DebugTrace("TraceEvent IsWearingInvalidRestraints: Done (Yoke)")
Log("Invalid Yoke Detected!", DL_DEBUG, S_MOD)
         Return True
      EndIf

      ; 22: zad_DeviousBondageMittens
      oWorn = _qZadLibs.GetWornDevice(_aPlayer, _aoZadDeviceKeyword[22])
      If (oWorn && (-1 == _aoMittens.Find(oWorn)))
         DebugTrace("TraceEvent IsWearingInvalidRestraints: Done (Mittens)")
Log("Invalid Mittens Detected!", DL_DEBUG, S_MOD)
         Return True
      EndIf
   EndIf

   If (_qFramework.IsPlayerHobbled())
      ; 19; zad_DeviousBoots
      Armor oWorn = _qZadLibs.GetWornDevice(_aPlayer, _aoZadDeviceKeyword[19])
      If (oWorn && (-1 == _aoLegRestraints.Find(oWorn)))
         DebugTrace("TraceEvent IsWearingInvalidRestraints: Done (Leg Restraint)")
Log("Invalid Leg Restraint Detected!", DL_DEBUG, S_MOD)
         Return True
      EndIf
   EndIf

   If (_qFramework.IsPlayerCollared())
      ; 2: zad_DeviousCollar
      Armor oWorn = _qZadLibs.GetWornDevice(_aPlayer, _aoZadDeviceKeyword[2])
      If (oWorn && (-1 == _aoCollars.Find(oWorn)))
         DebugTrace("TraceEvent IsWearingInvalidRestraints: Done (Collar)")
Log("Invalid Collar Detected!", DL_DEBUG, S_MOD)
         Return True
      EndIf
   EndIf

   DebugTrace("TraceEvent IsWearingInvalidRestraints: Done")
   Return False
EndFunction

Function SlavesGiveSpace(ObjectReference oTarget, String szModId="", Int iTimeout=4)
   If (!szModId)
      szModId = S_MOD + "_Slaves"
   EndIf

   Form[] aoNearby = _qFramework.GetNearbyActorList(iIncludeFlags=_qFramework.AF_SLAVE)
   If (aoNearby)
      Int iIndex = aoNearby.Length - 1
      While (0 <= iIndex)
         Actor aNearbyActor = (aoNearby[iIndex] As Actor)
         _qFramework.GiveSpace(aNearbyActor, oTarget, szModId, iTimeout)

         iIndex -= 1
      EndWhile
   EndIf
EndFunction

Function ReleaseFromFurniture(Actor aActor)
   ; If the Zaz Animation Pack thinks we are locked in furniture release the player from it.
   If (_qZbfPlayerSlot.GetFurniture())
      _qZbfSlaveActions.RestrainInDevice(None, aActor, S_MOD + "_BdsmToLeash")
   Else
      ; Otherweise call the Slave Action callback function as if the player had just been
      ; released via the Zaz Animaiton Pack API.
      OnSlaveActionDone("No Type", S_MOD + "_BdsmToLeash", aActor, -1)
   EndIf
EndFunction

; iSceneId: The ID of the scene to validate (_iCurrScene).
Bool Function CanSceneStart(Int iSceneId)
   If (1 == iSceneId)
      ; Scene 1: Transfer Furniture

      ; Only perform a transfer if:
      ; There is nearby furniture.
      ; The player is busy (with a Devious Framework or SexLab scene, combat, dialogue).
      ; The player is not in a conversation.
      Return (GetRandomFurniture(oCell=_aPlayer.GetParentCell(), bExcludeCurrent=True) && \
              !_qFramework.IsPlayerBusy())
   EndIf
   Return True
EndFunction

; Actions can be:
; 1: Start Conversation.  Details: The _iCurrDialogue to start.
; 2: Assault Player.      Details: The _iAssault mask.
; 3: Furniture Assault.   Details: The _iFurnitureGoals mask.
; 4: Start Scene.         Details: The ID of the scene to start (_iCurrScene).
; 5: Start a Sandbox.
; 6: Delay Relative.      Details (Float): The (game time) duration from when the delay starts.
; 7: Delay Absolute.      Details (Float): The in game time the delay should end.
; 8: Start a punishment.  Punishment is determined by _iPunishments.
; Unique Tag: AddPendingActionFunction
Function AddPendingAction(Int iAction, Int iDetails=0x0000, Actor aActor=None, \
                          String szScene="", Int iSceneTimeout=180, Float fDetails=0.0, \
                          Bool bPrepend=False, Bool bUnique=False)
   DebugTrace("TraceEvent AddPendingAction (" + iAction + "," + iDetails + ")")
   If (MutexLock(_iPendingActionMutex))
      Bool bDuplicate
      If (bUnique)
         If ((4 == iAction) && (iDetails == _iCurrScene))
            bDuplicate = True
         Else
            Int iIndex = _aiPendingAction.Length - 1
            While (0 <= iIndex)
               If ((_aiPendingAction[iIndex] == iAction) && \
                   (_aiPendingDetails[iIndex] == iDetails))
                  bDuplicate = True
               EndIf

               iIndex -= 1
            EndWhile
         EndIf
      EndIf

      If (!bDuplicate)
         _aiPendingAction  = _qDfwUtil.AddIntToArray(_aiPendingAction, iAction, bPrepend)
         _aoPendingActor   = _qDfwUtil.AddFormToArray(_aoPendingActor, aActor, bPrepend)
         _aiPendingDetails = _qDfwUtil.AddIntToArray(_aiPendingDetails, iDetails, bPrepend)
         _afPendingDetails = _qDfwUtil.AddFloatToArray(_afPendingDetails, fDetails, bPrepend)
         _aszPendingScene  = _qDfwUtil.AddStringToArray(_aszPendingScene, szScene, bPrepend)
         _aiPendingTimeout = _qDfwUtil.AddIntToArray(_aiPendingTimeout, iSceneTimeout, bPrepend)
      EndIf

      MutexRelease(_iPendingActionMutex)
   EndIf
   DebugTrace("TraceEvent AddPendingAction: Done")
EndFunction

Function ReleaseSceneThreadControl()
   If (MutexLock(_iCurrSceneMutex))
      _bSceneThreadControl = False

      MutexRelease(_iCurrSceneMutex)
   EndIf
EndFunction

Function ProcessPendingAction(Actor aAgressor)
   DebugTrace("TraceEvent ProcessPendingAction")
   ; We only want to allow one thread at a time to process pending actions/current scenes.
   ; Since the current scene process is itterative (meaning it will keep processing until
   ; a dealy is encountered) it should be fine if one thread doesn't get to run.  The actively
   ; running thread will likely perform any processing it would do anyway.
   Bool bAbort = False
   Bool bCurrScene
   If (MutexLock(_iCurrSceneMutex))
      If (_bSceneThreadControl)
         bAbort = True
      Else
         _bSceneThreadControl = True
      EndIf

      ; While we have the mutex locked, also keep track of whether a current scene is active.
      bCurrScene = (_iCurrScene As Bool)

      MutexRelease(_iCurrSceneMutex)
   EndIf
   ; If we detected another thread already running, abort.
   If (bAbort)
      DebugTrace("TraceEvent ProcessPendingAction: Done (Already Running)")
      Return
   EndIf

   ; If there is a scene in progress, process that first.
   If (bCurrScene)
      DebugTrace("Process Pending: Continuing Scene.")
      ProcessCurrScene(aAgressor)
      DebugTrace("TraceEvent ProcessPendingAction: Done (Processed Curr Scene)")
      Return ReleaseSceneThreadControl()
   EndIf

   ; If the mod is processing a leash holder activity don't start something else.
   If (IsLeashHolderBusy())
Log("Busy With Leash!!!", DL_CRIT, S_MOD)
      DebugTrace("TraceEvent ProcessPendingAction: Done (Busy With Leash)")
      Return ReleaseSceneThreadControl()
   EndIf

   ; Don't start a new scene in the middle of a sex scene or some other mod's scene.
   String szCurrDfwScene = _qFramework.GetCurrentScene()
   If ((szCurrDfwScene && (S_MOD != StringUtil.Substring(szCurrDfwScene, 0, 4))) || \
       _qSexLab.IsActorActive(_aPlayer))
      DebugTrace("TraceEvent ProcessPendingAction: Done (Busy With SexLab or Other Mods: " + \
                 szCurrDfwScene + ")")
      Return ReleaseSceneThreadControl()
   EndIf

   Int    iAction
   Actor  aActor
   Int    iDetails
   Float  fDetails
   String szScene
   Int    iSceneTimeout
Int iRemainingLength
   If (MutexLock(_iPendingActionMutex))
      If (_aiPendingAction && _aiPendingAction.Length)
         iAction       = _aiPendingAction[0]
         iDetails      = _aiPendingDetails[0]
         fDetails      = _afPendingDetails[0]
         _afPendingDetails
         aActor        = (_aoPendingActor[0] As Actor)
         szScene       = _aszPendingScene[0]
         iSceneTimeout = _aiPendingTimeout[0]

         _aiPendingAction  = _qDfwUtil.RemoveIntFromArray(_aiPendingAction, 0, 0)
         _aoPendingActor   = _qDfwUtil.RemoveFormFromArray(_aoPendingActor, None, 0)
         _aiPendingDetails = _qDfwUtil.RemoveIntFromArray(_aiPendingDetails, 0, 0)
         _afPendingDetails = _qDfwUtil.RemoveFloatFromArray(_afPendingDetails, 0.0, 0)
         _aszPendingScene  = _qDfwUtil.RemoveStringFromArray(_aszPendingScene, "", 0)
         _aiPendingTimeout = _qDfwUtil.RemoveIntFromArray(_aiPendingTimeout, 0, 0)
iRemainingLength = _aiPendingAction.Length
      EndIf

      MutexRelease(_iPendingActionMutex)
   EndIf

   ; If we did not find a pending action return.
   If (!iAction)
      DebugTrace("TraceEvent ProcessPendingAction: Done (Nothing Pending)")
      Return ReleaseSceneThreadControl()
   EndIf
   DebugTrace("Process Pending: New (" + iAction + "," + iDetails + "," + szScene + ")")

; zxc change the scene name as some saved games already have an old scene name.
If ((1 == iAction) && (12 == iDetails))
   szScene = S_MOD + "_FurnForFun"
   DebugTrace("Process Pending: Now (" + iAction + "," + iDetails + "," + szScene + ")")
EndIf

   ; If a scene name was specified make sure we can lock the scene before proceeding.
   If (szScene)
      If (szScene == szCurrDfwScene)
         ; If a scene is running with the same name just continue it.
         _qFramework.SceneContinue(szScene, iSceneTimeout)
      Else
         ; Identify scenes that don't need to extend the CallOut timeout.
         Bool bExtendCallOut = True
         If ((4 == iAction) && (6 == iDetails))
            bExtendCallOut = False
         EndIf

         If (FAIL >= _qFramework.SceneStarting(szScene, iSceneTimeout, \
                                               bExtendCallout=bExtendCallOut))
            ; Can't start the scene now.  Add the action to do later.
            AddPendingAction(iAction, iDetails, aActor, szScene, iSceneTimeout, fDetails, True)
            DebugTrace("TraceEvent ProcessPendingAction: Done (Failed to Start Scene)")
            Return ReleaseSceneThreadControl()
         EndIf
      EndIf
   EndIf

   ; If an actor was specified make sure to use him as the aggressor.
   If (aActor)
      aAgressor = aActor
   EndIf

   If (1 == iAction)
      ; 1: Start Conversation.  Details: the new leash holder goal.

      ; Figure out if our mod is moving the NPC in question toward the player.
      String szCurrMod
      If (_bIsPlayerCaged && _oBdsmFurniture)
         ; The player is caged.  Keep track of who is approaching the cage door.
         szCurrMod = _qFramework.GetMoveToObjectModId()
      Else
         ; Otherwise keep track of who is approaching the player.
         szCurrMod = _qFramework.GetApproachModId()
      EndIf

      ; If the actor is not near the player, have him move there first.
      If (S_MOD + "_Approach" == szCurrMod)
         ; The NPC is still approaching the player before starting the conversation.
         ; The conversation can't start yet so re-schedule it and return.
         AddPendingAction(iAction, iDetails, aAgressor, szScene, iSceneTimeout, fDetails, True)
         DebugTrace("TraceEvent ProcessPendingAction: Done (Still Moving for Dialogue)")
         Return ReleaseSceneThreadControl()
      ElseIf (!aAgressor.Is3DLoaded() || (300 <= aAgressor.GetDistance(_aPlayer)))
         ; The NPC is too far away to start the conversation.  Move him closer.
         If (_bIsPlayerCaged && _oBdsmFurniture)
            _qFramework.MoveToObject(aAgressor, _oBdsmFurniture, S_MOD + "_Approach")
         Else
            _qFramework.ApproachPlayer(aAgressor, 180, 2, S_MOD + "_Approach")
         EndIf

         ; The conversation can't start yet so re-schedule it and return.
         AddPendingAction(iAction, iDetails, aAgressor, szScene, iSceneTimeout, fDetails, True)
         DebugTrace("TraceEvent ProcessPendingAction: Done (Moving for Dialogue)")
         Return ReleaseSceneThreadControl()
      EndIf

      ; Hover at the player (or cage door if caged) to maintain the conversation.
      If (_bIsPlayerCaged && _oBdsmFurniture)
         _qFramework.HoverAt(aAgressor, _oBdsmFurniture, S_MOD + "_Colour", 6)
      Else
         _qFramework.HoverAt(aAgressor, _aPlayer, S_MOD + "_Colour", 6)
      EndIf

      ; Coversation 12 (Approach for Interest) still used the (old) _iAgendaShortTerm to
      ; identify the dialogue.  Until this is changed we have a special case just for it.
      If (12 == iDetails)
         ; Only start this dialogue if the player's punishment is not ending.
         ; 3: Punish the player
         If ((3 != _iAgendaLongTerm) || _iFurnitureRemaining)
            StartConversation(aAgressor, iDetails)
         Else
            ; The player's furniture punishment may be ending.  Don't start another furniture
            ; scene at that time.
            _qFramework.SceneDone(szScene)
         EndIf
      Else
         _iCurrDialogue = iDetails
         _iCurrDialogueStage = 0
         ; Choose a random path for dialogue in the scene.
         _iCurrDialoguePath = Utility.RandomInt(1, 100)
         _aCurrDialogueTarget = aAgressor
         StartConversation(aAgressor)
      EndIf
   ElseIf (2 == iAction)
      ; 2: Assault Player.      Details: The _iAssault mask.

      _iAssault = Math.LogicalOr(iDetails, _iAssault)
      ; Play an animation for the slaver to approach the player.
      ; The assault will happen on the done event (OnSlaveActionDone).
      PlayApproachAnimationOld(aAgressor, "Assault")

      _qFramework.HoverAt(aAgressor, _aPlayer, S_MOD + "_FacePlayer", 3)

      ; Add a delay allow the assault to complete before continuing pending actions.
      ; 6: Delay Relative.
      AddPendingAction(6, szScene=S_MOD + "_Delay", fDetails=(0.01 / 24.0 / 6.0), bPrepend=True)
   ElseIf (3 == iAction)
      ; 3: Furniture Assault.   Details: The _iFurnitureGoals mask.

      _iFurnitureGoals = iDetails
      ProcessFurnitureGoals(aAgressor)
   ElseIf (4 == iAction)
      ; 4: Start Scene.  Details: The number of the scene to start.

      If (MutexLock(_iCurrSceneMutex))
         _iCurrScene = iDetails
         _iCurrSceneStage = 0
         _iLastSceneStage = -1
         _aCurrSceneAgressor = aAgressor
         _iCurrSceneTimeout = iSceneTimeout
         _szCurrSceneName = szScene
         _bSceneReadyToEnd = False
         _abCurrSceneParameter  = _abNone
         _afCurrSceneParameter  = _afNone
         _aoCurrSceneParameter  = _aoNone
         _aszCurrSceneParameter = _aszNone

         MutexRelease(_iCurrSceneMutex)
      EndIf
      ProcessCurrScene(aAgressor)
   ElseIf (5 == iAction)
      ; 5: Start a Sandbox.

      ; Make sure the actor is a valid target for the sandbox package.
      If (!aAgressor || ((aAgressor != _aLeashHolder) && \
                         (aAgressor != (_aAliasFurnitureLocker.GetReference() As Actor))))
         ; Not much we can do with an invalid actor.
         DebugTrace("TraceEvent ProcessPendingAction: Done (Invalid Sandbox)")
         Return ReleaseSceneThreadControl()
      EndIf

      ; Start the sandbox package and reset the duration.
      _fMasterSandboxTime = 0.0
      _iAgendaMidTerm = 1
      _qFramework.ReEvaluatePackage(aAgressor)
   ElseIf (6 == iAction)
      ; 6: Delay Relative.

      ; Calculate the absolute end time of the delay based on the current time + duration.
      Log("Starting Delay: " + fDetails + " + " + Utility.GetCurrentGameTime())
; zxc: The delay has already been added to the save game with the current game time included.
If (1 > fDetails)
      fDetails += Utility.GetCurrentGameTime()
EndIf

      ; Add the delay back to the pending actions as an absolute delay.
      AddPendingAction(7, iDetails, aAgressor, szScene, iSceneTimeout, fDetails, True)
      Return ReleaseSceneThreadControl()
   ElseIf (7 == iAction)
      ; 7: Delay Absolute.      Details (Float): The in game time the delay should end.

      ; If we aren't done the delay just add it back to the pending actions.
      Float fCurrTime = Utility.GetCurrentGameTime()
      Log("In Game Delay: " + fDetails + " vs. " + fCurrTime)
      If (fDetails >= fCurrTime)
         AddPendingAction(iAction, iDetails, aAgressor, szScene, iSceneTimeout, fDetails, True)
         DebugTrace("TraceEvent ProcessPendingAction: Done (Delay Not Done)")
         Return ReleaseSceneThreadControl()
      EndIf

      ; Otherwise we are done.  End the scene.
      _qFramework.SceneDone(szScene)
   ElseIf (8 == iAction)
      ; 8: Start a punishment.  Punishment is determined by _iPunishments.

      ; The following behaviour warrant a furniture punishment.
      ; 0x0001 = Talking of Escape
      ; 0x0002 = Not Accepting her slavery
      If (Math.LogicalAnd(0x0003, _iPunishments))
         PunishPlayer(_aLeashHolder, -1, szScene)
      EndIf
   EndIf
   DebugTrace("TraceEvent ProcessPendingAction: Done")
   Return ReleaseSceneThreadControl()
EndFunction

Function ModifySceneStage(Int iNewValue=-1, Int iDelta=0)
   If (MutexLock(_iCurrSceneMutex))
      ; Only modify the stage if there really is an active scene.
      If (_iCurrScene)
         If (-1 != iNewValue)
            _iCurrSceneStage = iNewValue
         EndIf
         _iCurrSceneStage += iDelta
      EndIf

      MutexRelease(_iCurrSceneMutex)
   EndIf
EndFunction

; All ProcessScene...() functions follow the same return codes.
; Return SUCCESS if the scene progressed immediately and may be able to progress again.
; Return WARNING if the scene is taking a delayed action in order to progress.
; Return FAIL if the scene has ended.
; This function should handle any WARNING loops so calling functions don't need to.
Int Function ProcessCurrScene(Actor aAgressor)
   DebugTrace("TraceEvent ProcessCurrScene")

   If (!aAgressor)
      aAgressor = _aCurrSceneAgressor
   EndIf

   ; We need to use the scene name early to continue the scene during busy failures.
   String szSceneName
   Int iTimeout

   ; Don't try to process/continue one of our scenes during a SexLab scene.
   If (_qSexLab.IsActorActive(_aPlayer))
      If (MutexLock(_iCurrSceneMutex))
         szSceneName = _szCurrSceneName
         iTimeout = _iCurrSceneTimeout

         MutexRelease(_iCurrSceneMutex)
      EndIf

      ; Even when busy try to continue the scene so it doesn't time out.
      If (szSceneName)
         _qFramework.SceneContinue(szSceneName, iTimeout)
      EndIf

      DebugTrace("TraceEvent ProcessCurrScene: Done (SexLab Busy)")
      Return WARNING
   EndIf

   ; Keep processing scenes until it returns FAIL (scene done) or WARNING (pending action).
   Int iStatus = SUCCESS
   Int iScene
   Int iStage
   String szName = "None"
   If (aAgressor)
      szName = GetDisplayName(aAgressor)
   EndIf
   While (SUCCESS == iStatus)
      ; Keep track of which scene/stage we are processing.
      If (MutexLock(_iCurrSceneMutex))
         iScene = _iCurrScene
         iStage = _iCurrSceneStage
         iTimeout = _iCurrSceneTimeout
         szSceneName = _szCurrSceneName

         MutexRelease(_iCurrSceneMutex)
      EndIf

      Log("Processing Scene " + szSceneName + " (" + iScene + "," + iStage + "," + \
          _iSceneModule + "," + _iSceneModuleStage + "," + szName + ")", DL_TRACE, S_MOD)
      If (_iSceneModule)
         Int iModuleStage = _iSceneModuleStage

         DebugTrace("TraceEvent ProcessSceneModule")
         iStatus = ProcessSceneModule(iScene, iStage, aAgressor, iTimeout, szSceneName)
         DebugTrace("TraceEvent ProcessSceneModule: Done")

         _iLastModuleStage = iModuleStage

         ; If the module completed its work clean it up.
         If (FAIL == iStatus)
            _iSceneModule            = 0
            _iSceneModuleStage       = 0
            _abSceneModuleParameter  = _abNone
            _afSceneModuleParameter  = _afNone
            _aoSceneModuleParameter  = _aoNone
            _aszSceneModuleParameter = _aszNone

            ; Once the module is done try to continue the scene right away.
            iStatus = SUCCESS
         EndIf
      ElseIf (1 == iScene)
         ; 1: Transfer Furniture
         DebugTrace("TraceEvent ProcessSceneTransferFurniture")
         iStatus = ProcessSceneTransferFurniture(iStage, aAgressor, iTimeout, szSceneName)
         DebugTrace("TraceEvent ProcessSceneTransferFurniture: Done")
      ElseIf (2 == iScene)
         ; 2: Release the player
         DebugTrace("TraceEvent ProcessSceneReleasePlayer")
         iStatus = ProcessSceneReleasePlayer(iStage, aAgressor, iTimeout, szSceneName)
         DebugTrace("TraceEvent ProcessSceneReleasePlayer: Done")
      ElseIf (3 == iScene)
         ; 3: Sell the player's items.
         DebugTrace("TraceEvent ProcessSceneSellItems")
         iStatus = ProcessSceneSellItems(iStage, aAgressor, iTimeout, szSceneName)
         DebugTrace("TraceEvent ProcessSceneSellItems: Done")
      ElseIf (4 == iScene)
         ; 4: Assault the player.
         DebugTrace("TraceEvent ProcessSceneAssault")
         iStatus = ProcessSceneAssault(iStage, aAgressor, iTimeout, szSceneName)
         DebugTrace("TraceEvent ProcessSceneAssault: Done")
      ElseIf (5 == iScene)
         ; 5: Milk the player (Milk Maid Economy).
         DebugTrace("TraceEvent ProcessSceneMilkPlayer")
         iStatus = ProcessSceneMilkPlayer(iStage, aAgressor, iTimeout, szSceneName)
         DebugTrace("TraceEvent ProcessSceneMilkPlayer: Done")
      ElseIf (6 == iScene)
         ; 6: Ask the blacksmith to remove restraints from other mods.
         DebugTrace("TraceEvent ProcessSceneRemoveRestraints")
         iStatus = ProcessSceneRemoveRestraints(iStage, aAgressor, iTimeout, szSceneName)
         DebugTrace("TraceEvent ProcessSceneRemoveRestraints: Done")
      ElseIf (7 == iScene)
         ; 7: Return to the leash game.
         DebugTrace("TraceEvent ProcessSceneReturnToLeashGame")
         iStatus = ProcessSceneReturnToLeashGame(iStage, aAgressor, iTimeout, szSceneName)
         DebugTrace("TraceEvent ProcessSceneReturnToLeashGame: Done")
      ElseIf (8 == iScene)
         ; 8: Whip the Player.
         DebugTrace("TraceEvent ProcessSceneWhipPlayer")
         iStatus = ProcessSceneWhipPlayer(iStage, aAgressor, iTimeout, szSceneName)
         DebugTrace("TraceEvent ProcessSceneWhipPlayer: Done")
      ElseIf (9 == iScene)
         ; 9: Start Furniture Punishment.
         DebugTrace("TraceEvent ProcessScenePunishFurniture")
         iStatus = ProcessScenePunishFurniture(iStage, aAgressor, iTimeout, szSceneName)
         DebugTrace("TraceEvent ProcessScenePunishFurniture: Done")
      ElseIf (10 == iScene)
         ; 10: Proposition the slaver for sex.
         DebugTrace("TraceEvent ProcessScenePropositionSex")
         iStatus = ProcessScenePropositionSex(iStage, aAgressor, iTimeout, szSceneName)
         DebugTrace("TraceEvent ProcessScenePropositionSex: Done")
      ElseIf (11 == iScene)
         ; 11: Force the player to craft armour.
         DebugTrace("TraceEvent ProcessSceneForgeArmour")
         iStatus = ProcessSceneForgeArmour(iStage, aAgressor, iTimeout, szSceneName)
         DebugTrace("TraceEvent ProcessSceneForgeArmour: Done")
;      ElseIf (12 == iScene)
;         ; 12: Force the player to enchant armour.
;         DebugTrace("TraceEvent ProcessSceneEnchantArmour")
;         iStatus = ProcessSceneEnchantArmour(iStage, aAgressor, iTimeout, szSceneName)
;         DebugTrace("TraceEvent ProcessSceneEnchantArmour: Done")
      ElseIf (13 == iScene)
         ; 13: Force the player to craft healing potions.
         DebugTrace("TraceEvent ProcessSceneCraftPotions")
         iStatus = ProcessSceneCraftPotions(iStage, aAgressor, iTimeout, szSceneName)
         DebugTrace("TraceEvent ProcessSceneCraftPotions: Done")
      Else
         ; Unknown scene.  How did we get here?  Make sure to exit the loop.
         iStatus = FAIL
      EndIf
      _iLastSceneStage = iStage
   EndWhile
   Log("Scene Processed (" + iScene + "," + iStage + "): " + iStatus, DL_TRACE, S_MOD)

   ; The scene is done.  Perform the generic cleanup.
   If (FAIL == iStatus)
      _qFramework.SceneDone(_szCurrSceneName)
      If (MutexLock(_iCurrSceneMutex))
         _iCurrScene = 0
         _iCurrSceneStage = 0
         _iLastSceneStage = -1
         _aCurrSceneAgressor = None
         _iCurrSceneTimeout = 0
         _szCurrSceneName = ""
         _bSceneReadyToEnd = False
         _abCurrSceneParameter  = _abNone
         _afCurrSceneParameter  = _afNone
         _aoCurrSceneParameter  = _aoNone
         _aszCurrSceneParameter = _aszNone

         MutexRelease(_iCurrSceneMutex)
      EndIf
   EndIf
   DebugTrace("TraceEvent ProcessCurrScene: Done")
   Return iStatus
EndFunction

; All ProcessScene...() functions follow the same return codes.
; SUCCESS: The scene progressed immediately and may be able to progress again.
; WARNING: The scene is taking a delayed action in order to progress.
; FAIL:    The scene has ended.
Int Function ProcessSceneModule(Int iScene, Int iStage, Actor aAgressor, Int iTimeout, \
                                String szSceneName)
   ; Reset the scene timeout to let DFW know we are still monitoring progress.
   If (0 > _qFramework.SceneContinue(szSceneName, iTimeout))
      Return FAIL
   EndIf

   ; If the leash game ends for some reason, end certain scene.
   If ((0 >= _iLeashGameDuration) && !_aLeashHolder)
      If ((2 != _iCurrScene) && (4 != _iCurrScene) && (8 != _iCurrScene))
         Return FAIL
      EndIf
   EndIf

   If (1 == _iSceneModule)
      ; 1: Leash the player to an object.

      ; If the player's leash is not an actor abort the module.
      ObjectReference oLeashTarget = _qFramework.GetLeashTarget()
      If (!IsActor(oLeashTarget))
         _iSceneModuleOutput = FAIL
         Return FAIL
      EndIf
      Actor aLeashHolder = (oLeashTarget As Actor)

      ; Parameter 0: The object to move to.
      ObjectReference oTarget = (_aoSceneModuleParameter[0] As ObjectReference)

      ; Stage: 0: Move to object.  1: At the Hitching Post.
      If (0 == _iSceneModuleStage)
         ; Stage 0: Move to object.
         DebugTrace("Scene " + iScene + "-" + iStage + " Module 1-0: ()")

         ; Have the leash holder move to the object.
         If (!_qFramework.IsMoving(aActor=aLeashHolder))
            _qFramework.MoveToObject(aLeashHolder, oTarget, S_MOD + "_ModNextStage")
         EndIf
      ElseIf (1 == _iSceneModuleStage)
         ; Stage 1: At the Hitching Post.
         DebugTrace("Scene " + iScene + "-" + iStage + " Module 1-1: ()")

         ; Have the leash holder stand by the object until the scene starts.
         _qFramework.HoverAt(aLeashHolder, oTarget, szSceneName)

         ; Beckon the player before leashing her to the object.
         Log(GetDisplayName(aLeashHolder) + " secures your leash to the " + \
             GetDisplayName(oTarget) + ".", DL_CRIT, S_MOD)
         ; 10: Order the player to come.
         _iCurrDialogue = 10
         StartConversation(aLeashHolder, iTImeout=3)

         ; Give the player some time to respond and decrease the time she has for the future.
         Utility.Wait(_iExpectedResponseTime)
         If (3 < _iExpectedResponseTime)
            _iExpectedResponseTime -= 1
         EndIf

         ; After the delay, shorten the player's leash and leash her to the object.
         _qFramework.SetLeashLength(100)
         _qFramework.SetLeashTarget(oTarget)

         Return FAIL
      EndIf
   ElseIf (2 == _iSceneModule)
      ; 2: Secure player for being left.

      ; Stage: 0: Pre assault.  1: Assault pending.  2: Post assault.
      If (0 == _iSceneModuleStage)
         ; Stage 0: Pre assault.
         DebugTrace("Scene " + iScene + "-" + iStage + " Module 2-0: ()")

         Bool bGagPlayer
         ; Parameter 0: Gag the player.
         If (1 <= _abSceneModuleParameter.Length)
            bGagPlayer = _abSceneModuleParameter[0]
         EndIf

         ; If the player is crawling allow her to stand.  Also make sure her arms are locked.
         If (_iCrawlRemaining || !_qFramework.IsPlayerArmLocked())
            ; Clear the crawling punishment as the player can't be left alone with free arms.
            If (_iCrawlRemaining)
               _iCrawlRemaining = 0
               ; If the player is not being punished in other ways clear the punishment status.
               ; TODO: There is still a race condition where these timers could have expired but
               ; the player has not actually been released.  We need a flag (or short term
               ; agenda) to indicate a punishment release is pending.
               If (!_iBlindfoldRemaining && !_iGagRemaining && !_iFurnitureRemaining)
                  _iAgendaLongTerm = 1
                  _iDetailsLongTerm = 0
                  _fTimePunished = 0.0
                  _fTimeLastPunished = Utility.GetCurrentGameTime()
               EndIf
            EndIf

            ; 0x0004: Bind Arms (implies Unbind Mittens)
            _iAssault = Math.LogicalOr(0x0004, _iAssault)
         EndIf

         ; Check if the player needs to be gagged.
         If (bGagPlayer && !_qFramework.IsPlayerGagged())
            ; 0x0002: Gag
            _iAssault = Math.LogicalOr(0x0002, _iAssault)
         EndIf

         ; If an assualt is not needed we are done.
         If (!_iAssault)
            Return FAIL
         EndIf

         ; An assualt is needed.  Play an animation for the slaver to approach the player.
         ; The assault will happen on the done event (OnSlaveActionDone).
         ; Parameter 0: The actor performing the assault.
         PlayApproachAnimation((_aoSceneModuleParameter[0] As Actor), "AssaultModNextStage", \
                               szSceneName)
         _iSceneModuleStage += 1
      ElseIf (1 == _iSceneModuleStage)
         ; Stage 1: Assault pending.
         DebugTrace("Scene " + iScene + "-" + iStage + " Module 2-1: ()")

         ; Do nothing in this stage.  Just wait for the stage to increase.
      ElseIf (2 == _iSceneModuleStage)
         ; Stage 2: Post assault.
         DebugTrace("Scene " + iScene + "-" + iStage + " Module 2-2: ()")

         ; We've done as much as we can.  Advance the scene and end the module.
         ModifySceneStage(iDelta=1)
         Return FAIL
      EndIf
   ElseIf (3 == _iSceneModule)
      ; 3: Move to the player for a conversation.

      ; Stage: 0: Actor could be anywhere.  1: Moving to Location.  2: At Location.
      ;        3: Moving to Player.  4: Arrived at player.
      If (0 == _iSceneModuleStage)
         ; Stage 0: Actor could be anywhere.
         DebugTrace("Scene " + iScene + "-" + iStage + " Module 3-0: ()")

         ; If the actor is dead, abort the module.
         If (aAgressor.IsDead())
            Return FAIL
         EndIf

         If (aAgressor.Is3DLoaded() || \
             (_aPlayer.GetCurrentLocation() == aAgressor.GetCurrentLocation()))
            ; The actor is nearby skip straight to moving to the player.
            _iSceneModuleStage = 2
            Return SUCCESS
         ElseIf (_oBdsmFurniture)
            ; The player is locked in furniture.  Move to that.
            Location oFurnitureLocation = _oBdsmFurniture.GetCurrentLocation()

            ; The furniture might be in a custom cell which doesn't have a location.
            If (!oFurnitureLocation)
               If (MutexLock(_iFavouriteFurnitureMutex))
                  Int iIndex = _aoFavouriteFurniture.Find(_oBdsmFurniture)
                  If (-1 != iIndex)
                     oFurnitureLocation = (_aoFavouriteLocation[iIndex] As Location)
                  EndIf

                  MutexRelease(_iFavouriteFurnitureMutex)
               EndIf
            EndIf

            ; If we can't identify the location.  Skip straight to moving to the player.
            If (!oFurnitureLocation)
               _iSceneModuleStage = 2
               Return SUCCESS
            EndIf

            ; Move to the furniture's location.
            _qFramework.MoveToLocation(aAgressor, oFurnitureLocation, S_MOD + "_ModNextStage")
         Else
            ; Move to the player's location.
            _qFramework.MoveToLocation(aAgressor, _aPlayer.GetCurrentLocation(), \
                                          S_MOD + "_ModNextStage")
         EndIf
         _iSceneModuleStage += 1
      ElseIf (1 == _iSceneModuleStage)
         ; Stage 1: Moving to Location.
         DebugTrace("Scene " + iScene + "-" + iStage + " Module 3-1: ()")

         ; Do nothing in this stage.  Just wait for the stage to increase.
      ElseIf (2 == _iSceneModuleStage)
         ; Stage 2: At Location.
         DebugTrace("Scene " + iScene + "-" + iStage + " Module 3-2: ()")

         ; We arrived at the location (or failed to do so).  Try moving to the player.
         If (_bIsPlayerCaged && _oBdsmFurniture)
            _qFramework.MoveToObjectClose(aAgressor, _oBdsmFurniture, S_MOD + "_ModNextStage")
         Else
            _qFramework.ApproachPlayer(aAgressor, 120, 2, S_MOD + "_ModNextStage")
         EndIf
         _iSceneModuleStage += 1
      ElseIf (3 == _iSceneModuleStage)
         ; Stage 3: Moving to Player.
         DebugTrace("Scene " + iScene + "-" + iStage + " Module 3-3: ()")

         ; Do nothing in this stage.  Just wait for the stage to increase.
      ElseIf (4 == _iSceneModuleStage)
         ; Stage 4: Arrived at player.
         DebugTrace("Scene " + iScene + "-" + iStage + " Module 3-4: ()")

         ; Keep track of where the actor is approaching, the player or her furniture.
         ObjectReference oTarget = _aPlayer
         If (_oBdsmFurniture)
            oTarget = _oBdsmFurniture
         EndIf

         ; If the actor isn't nearby, try again to move closer.
         If (!aAgressor.Is3DLoaded() || (300.0 < aAgressor.GetDistance(oTarget)))
            _iSceneModuleStage = 0
            Return SUCCESS
         EndIf

         ; Otherwise have the actor hover at the player or her furniture.
         _qFramework.HoverAt(aAgressor, oTarget, szSceneName)

         ; The module is done.  Advance the scene and end the module.
         ModifySceneStage(iDelta=1)
         Return FAIL
      EndIf
   ElseIf (4 == _iSceneModule)
      ; 4: Move to an object.

      ; Stage: 0: Actor could be anywhere.  1: Moving to Location.  2: At Location.
      ;        3: Moving to the object.  4: Arrived at the object.
      If (0 == _iSceneModuleStage)
         ; Stage 0: Actor could be anywhere.
         DebugTrace("Scene " + iScene + "-" + iStage + " Module 4-0: ()")

         ; If the actor is dead, abort the module.
         If (aAgressor.IsDead())
            Return FAIL
         EndIf

         ObjectReference oTarget = (_aoSceneModuleParameter[0] As ObjectReference)
         Location oTargetLocation = oTarget.GetCurrentLocation()

         ; The object might be furniture in a custom cell.  Check for that.
         If (!oTargetLocation)
            If (MutexLock(_iFavouriteFurnitureMutex))
               Int iIndex = _aoFavouriteFurniture.Find(oTarget)
               If (-1 != iIndex)
                  oTargetLocation = (_aoFavouriteLocation[iIndex] As Location)
               EndIf

               MutexRelease(_iFavouriteFurnitureMutex)
            EndIf
         EndIf

         If (!oTargetLocation || oTarget.Is3DLoaded() || \
             (oTarget.GetCurrentLocation() == aAgressor.GetCurrentLocation()))
            ; Skip moving to the object's location if:
            ;  We can't find the object's location;
            ;  The object is nearby (if the actor is not he will fase in); or
            ;  The actor and the object are both in the same location.
            _iSceneModuleStage = 2
            Return SUCCESS
         EndIf
         ; Otherwise have the actor move to the object's location.
         _qFramework.MoveToLocation(aAgressor, oTargetLocation, S_MOD + "_ModNextStage")
         _iSceneModuleStage += 1
      ElseIf (1 == _iSceneModuleStage)
         ; Stage 1: Moving to Location.
         DebugTrace("Scene " + iScene + "-" + iStage + " Module 4-1: ()")

         ; Do nothing in this stage.  Just wait for the stage to increase.
      ElseIf (2 == _iSceneModuleStage)
         ; Stage 2: At Location.
         DebugTrace("Scene " + iScene + "-" + iStage + " Module 4-2: ()")

         ; We arrived at the location (or failed to do so).  Try moving to the object.
         _qFramework.MoveToObject(aAgressor, (_aoSceneModuleParameter[0] As ObjectReference), \
                                  S_MOD + "_ModNextStage")
         _iSceneModuleStage += 1
      ElseIf (3 == _iSceneModuleStage)
         ; Stage 3: Moving to the object.
         DebugTrace("Scene " + iScene + "-" + iStage + " Module 4-3: ()")

         ; Do nothing in this stage.  Just wait for the stage to increase.
      ElseIf (4 == _iSceneModuleStage)
         ; Stage 4: Arrived at the object.
         DebugTrace("Scene " + iScene + "-" + iStage + " Module 4-4: ()")

         ObjectReference oTarget = (_aoSceneModuleParameter[0] As ObjectReference)

         ; If the actor isn't nearby, try again to move closer.
         If (!aAgressor.Is3DLoaded() || (500.0 < aAgressor.GetDistance(oTarget)))
            _iSceneModuleStage = 0
            Return SUCCESS
         EndIf

         ; Otherwise have the actor hover at the object.
         _qFramework.HoverAt(aAgressor, oTarget, szSceneName)

         ; The module is done.  Advance the scene and end the module.
         ModifySceneStage(iDelta=1)
         Return FAIL
      EndIf
   EndIf
   Return WARNING
EndFunction

; All ProcessScene...() functions follow the same return codes.
; SUCCESS: The scene progressed immediately and may be able to progress again.
; WARNING: The scene is taking a delayed action in order to progress.
; FAIL:    The scene has ended.
Int Function ProcessSceneTransferFurniture(Int iStage, Actor aAgressor, Int iTimeout, \
                                           String szSceneName)
   ; Reset the scene timeout to let DFW know we are still monitoring progress.
   If (0 > _qFramework.SceneContinue(szSceneName, iTimeout))
      Return FAIL
   EndIf

   ; If somehow the agressor leaves the area, reset the scene and try again from the beginning.
   If ((0 != iStage) && (!aAgressor.Is3DLoaded()))
      _oTransferFurniture = None
      ModifySceneStage(iNewValue=0)
   EndIf

   ; If the leash game ends for some reason, end this scene.
   If ((0 >= _iLeashGameDuration) && !_aLeashHolder)
      Return FAIL
   EndIf

   ; 1: Transfer Furniture
   ; Stage: 1: At Current furniture. 2: Arms and Legs Restrained.  3: Released.
   ;        4: Locked In Furniture.
   If (0 == iStage)
      DebugTrace("Scene 1 Stage 0: (" + _oTransferFurniture + "," + _oBdsmFurniture + ")")

      ; If the player is not registered in furniture something went wrong.  Abort the scene.
      If (!_oBdsmFurniture)
         Return FAIL
      EndIf

      ; If the transfer furniture isn't in the same cell as the player clear it.  It must be
      ; leftover from something.  Clear it.  TODO: This shouldn't be needed but it currently is.
      If (_oTransferFurniture && \
          (_oTransferFurniture.GetParentCell() != _oBdsmFurniture.GetParentCell()))
         _oTransferFurniture = None
      EndIf

      ; If we haven't selected the transfer furniture do so now.
      If (!_oTransferFurniture)
         ; Find a random furniture in the player's cell to transfer her to.
         _oTransferFurniture = GetRandomFurniture(oCell=_aPlayer.GetParentCell(), \
                                                  bExcludeCurrent=True)
         If (!_oTransferFurniture)
            Return FAIL
         EndIf
      EndIf

      ; Make sure the slaver is approaching the player to start the scene.
      If (S_MOD + "_NextStage" != _qFramework.GetMoveToObjectModId())
         _qFramework.MoveToObjectClose(aAgressor, _oBdsmFurniture, S_MOD + "_NextStage")
      EndIf
   ElseIf (1 == iStage)
      ; Stage 1: At Current furniture.
      DebugTrace("Scene 1 Stage 1: (" + _qFramework.IsPlayerArmLocked() + "," + \
                 _qFramework.IsPlayerHobbled() + ")")

      ; Set the NPC to hover at the furniture door until he is ready to move.
      _qFramework.HoverAt(aAgressor, _oBdsmFurniture, S_MOD + "_FTransfer")

      ; Start a one line conversation and wait for it to complete.
      StartConversation(aAgressor, iTimeout=3)
      ; One line dialogues are difficult to detect so rely on a timeout for accuracy.
      ; TODO: Maybe just use a timer if we can't detect the conversation?
      WaitForConversation(aAgressor, 8)

      ; Next leash the player to make sure she is secure.
      _qFramework.SetLeashTarget(aAgressor)

      ; Make sure the player is hobbled and her arms are restrained.
      If (!_qFramework.IsPlayerArmLocked())
         ; 0x0004: Bind Arms (implies Unbind Mittens)
         _iAssault = Math.LogicalOr(0x0004, _iAssault)
      EndIf
      If (!_qFramework.IsPlayerHobbled())
         ; 0x4000: Restrain in Boots
         _iAssault = Math.LogicalOr(0x4000, _iAssault)
      EndIf

      If (!_iAssault)
         ; The player is already secure.  Progress to the next stage with no delay.
         ModifySceneStage(iDelta=1)
         Return SUCCESS
      EndIf

      ; An assualt is pending.  Play an animation for the slaver to approach the player.
      ; The assault will happen on the done event (OnSlaveActionDone).
      PlayApproachAnimation(aAgressor, "Assault", szSceneName)
   ElseIf (2 == iStage)
      ; Stage 2: Arms and Legs Restrained.
      DebugTrace("Scene 1 Stage 2: (" + _qFramework.GetBdsmFurniture() + ")")

      ; Release the player from her current predicament.
;Off-DebugTrace("ProcessSceneTransferFurniture: Movement Enabled - Furniture Transfer")
      ReMobilizePlayer()

      ; If the player is caged release her from it.
      If (_bIsPlayerCaged)
         ReleasePlayerFromCage(aAgressor, _oBdsmFurniture)
      EndIf

      ; If the player is locked in furniture release her from it.
      If (_qFramework.GetBdsmFurniture())
         _qZbfSlaveActions.RestrainInDevice(None, aAgressor, S_MOD + "_F_Release")
      Else
         ; There are no pending restrictions on the player.  Increase the scene stage.
         SetCurrFurniture(None, bClearTransfer=False)
         ModifySceneStage(iDelta=1)
         Return SUCCESS
      EndIf
   ElseIf (3 == iStage)
      ; Stage 3: Released.

      DebugTrace("Scene 1 Stage 3: (" + _bIsPlayerCaged + "," + _oBdsmFurniture + "," + \
                 _qFramework.GetBdsmFurniture() + "," + _oTransferFurniture + ")")

      ; If the player is now locked in her new furniture, progress to the next stage.
      If (_bIsPlayerCaged || (_oBdsmFurniture && \
                              (_oBdsmFurniture == _qFramework.GetBdsmFurniture())))
         ModifySceneStage(iDelta=1)
         Return SUCCESS
      EndIf

      ; If there is no transfer furniture we are just waiting on the final restraining action.
      If (!_oTransferFurniture)
         Return WARNING
      EndIf

      ; Make sure the new furniture is now listed as the furniture in use.
      If (_oPunishmentFurniture)
         _oPunishmentFurniture = _oTransferFurniture
      EndIf

      ; We are ready to move to the new furniture.  Clear the NPC hovering at the current.
      _qFramework.HoverAtClear(S_MOD + "_FTransfer")

      ; The player has been leashed and released.  Move to the transfer furniture.
      If (S_MOD + "_Furniture" != _qFramework.GetMoveToObjectModId())
         _qFramework.MoveToObject(aAgressor, _oTransferFurniture, S_MOD + "_Furniture")
      EndIf
   ElseIf (4 == iStage)
      ; Stage 4: Locked In Furniture.
      DebugTrace("Scene 1 Stage 4: ()")

      ; Add a delay to make sure the player's teleport is complete.
      If (_bIsPlayerCaged)
         Utility.Wait(2.0)
      EndIf

      ; The player is now safely locked in the furniture.
      ; Have the agressor comment that he is now satisfied.
      StartConversation(aAgressor, iTimeout=3)

      ; One line dialogues are difficult to detect so rely on a timeout for accuracy.
      ; TODO: Maybe just use a timer if we can't detect the conversation?
      WaitForConversation(aAgressor, 8)

      ; The scene has completed.  End it.
      Return FAIL
   EndIf
   Return WARNING
EndFunction

; All ProcessScene...() functions follow the same return codes.
; SUCCESS: The scene progressed immediately and may be able to progress again.
; WARNING: The scene is taking a delayed action in order to progress.
; FAIL:    The scene has ended.
Int Function ProcessSceneReleasePlayer(Int iStage, Actor aHelper, Int iTimeout, \
                                           String szSceneName)
   ; Reset the scene timeout to let DFW know we are still monitoring progress.
   If (0 > _qFramework.SceneContinue(szSceneName, iTimeout))
      Return FAIL
   EndIf

   ; 2: Release the player
   ; Stage: 1: At Current furniture.  2: Released.  3: Re-restraining.  4: Re-secured.
   If (0 == iStage)
      DebugTrace("Scene 2 Stage 0: (" + _oBdsmFurniture + ")")

      ; Verify we can perform this scene.
      ; If the player is not currently registered as being in furniture don't proceed.
      If (!_oBdsmFurniture)
         Return FAIL
      EndIf

      ; Have the helper move to the player's furniture.
      _qFramework.MoveToObjectClose(aHelper, _oBdsmFurniture, S_MOD + "_NextStage")
   ElseIf (1 == iStage)
      ; Stage 1: At Current furniture.
      DebugTrace("Scene 2 Stage 1: (" + _bIsPlayerCaged + ")")

      ; Immobilize the player in case the helper is teasing her.
;Off-DebugTrace("ProcessSceneReleasePlayer: Movement Disabled - Releasing Player")
      ImmobilizePlayer()

      ; Wait for the NPC if he is in the process of sitting or standing.
      ActorSitStateWait(aHelper)

      If (_bIsPlayerCaged)
         ; If the player is caged, open it.
         ReleasePlayerFromCage(aHelper, _oBdsmFurniture)
         ModifySceneStage(iDelta=1)
         Return SUCCESS
      EndIf

      ; Otherwise start the Zaz Animation to free her.
      Log(GetDisplayName(aHelper) + " starts unlocking your device.", DL_CRIT, S_MOD)
      _qZbfSlaveActions.RestrainInDevice(None, aHelper, S_MOD + "_NextStage")
   ElseIf (2 == iStage)
      ; Stage 2: Released.
      Int iMaxChance = _qMcm.iFurnitureTeaseChance
      Float fRoll = Utility.RandomFloat(0, 100)
      DebugTrace("Scene 2 Stage 2: (" + fRoll + "/" + iMaxChance + "," + \
                 _bIsPlayerCaged + ")")

      ; Check if the NPC was teasing the player about releasing her.
      If (iMaxChance > fRoll)
         Log(GetDisplayName(aHelper) + " was teasing you and keeps you locked up.", DL_CRIT, \
             S_MOD)

         ; The NPC was just teasing the player and really keeps her locked up.
         If (_bIsPlayerCaged)
            ; Close the door again (the player shouldn't have been able to escape).
            Utility.Wait(2.0)
            CloseCageDoor(aHelper, _oBdsmFurniture, FindCageLever(_oBdsmFurniture))
            ModifySceneStage(iDelta=2)
            Return SUCCESS
         EndIf

         ; Disable Milk Mod Economy, preventing it from starting animations on the player.
DebugTrace("Adding Milking Spell: Scene 2")
         If (_oMmeBeingMilkedSpell && !_aPlayer.HasSpell(_oMmeBeingMilkedSpell))
            _aPlayer.AddSpell(_oMmeBeingMilkedSpell, False)
            _bMmeSuppressed = True
            ; Add a delay to make sure the spell has taken effect.
            Utility.Wait(0.5)
         EndIf
         _qZbfSlaveActions.RestrainInDevice(_oBdsmFurniture, aHelper, S_MOD + "_NextStage")
         ModifySceneStage(iDelta=1)
         Return WARNING
      EndIf

      ; Otherwise the player is actually free.  Finalize her release.
      If (!_bIsPlayerCaged)
         _qFramework.SetBdsmFurnitureLocked(False)
      EndIf
      _iDialogueFurnitureLocked = 0
      _iFurnitureExcuse = 0
      SetCurrFurniture(None)
;Off-DebugTrace("ProcessSceneReleasePlayer: Movement Enabled - Release Player Stage 2")
      ReMobilizePlayer()

      ; The scene has completed.  End it.
      Return FAIL
   ElseIf (3 == iStage)
      ; Stage 3: Re-restraining.
      DebugTrace("Scene 2 Stage 3: ()")

      ; Do nothing in this stage.  Just wait for the stage to increase.
   ElseIf (4 == iStage)
      ; Stage 4: Re-secured.
      DebugTrace("Scene 2 Stage 4: ()")

      ; The NPC was teasing.  The player has been resecured.  Clean up the scene and end it.
;Off-DebugTrace("ProcessSceneReleasePlayer: Movement Enabled - Release Player Stage 3")
      ReMobilizePlayer()

      ; If we have suppressed Milk Mod Economy re-enable it.
      If (_bMmeSuppressed)
         If (_oMmeBeingMilkedSpell)
            _aPlayer.RemoveSpell(_oMmeBeingMilkedSpell)
         EndIf
         _bMmeSuppressed = False
      EndIf

      Return FAIL
   EndIf
   Return WARNING
EndFunction

; All ProcessScene...() functions follow the same return codes.
; SUCCESS: The scene progressed immediately and may be able to progress again.
; WARNING: The scene is taking a delayed action in order to progress.
; FAIL:    The scene has ended.
Int Function ProcessSceneSellItems(Int iStage, Actor aHelper, Int iTimeout, String szSceneName)
   ; Reset the scene timeout to let DFW know we are still monitoring progress.
   If (0 > _qFramework.SceneContinue(szSceneName, iTimeout))
      Return FAIL
   EndIf

   ; If the leash game ends for some reason, end this scene.
   If ((0 >= _iLeashGameDuration) && !_aLeashHolder)
      Return FAIL
   EndIf

   ; 3: Sell the player's items.
   ; Stage: 1: At the merchant. 2: In the scene. 3: In Scene Post Gagging.
   ;         4: The scene is complete.
   If (0 == iStage)
      DebugTrace("Scene 3 Stage 0: (" + _aCurrSceneAgressor + ")")

      ; If we haven't identified the merchant yet select the nearest one from a specific list.
      If (!_aCurrSceneAgressor)
         Int iRegionIndex = _qFramework.GetNearestRegionIndex(iVersion=1)
         If (-1 == iRegionIndex)
            Log("Failed to find region for scene 3.  Aborting.", DL_ERROR, S_MOD)
            Return FAIL
         EndIf

         Int[] aiMerchantId = New Int[19]
         aiMerchantId[0]  = 0x0001A6BE ; Rustleif in Dawnstar
         aiMerchantId[1]  = 0x000198C9 ; Sayma in Solitude for Dragon Bridge
         aiMerchantId[2]  = 0x0001981E ; Solaf in Falkreath
         aiMerchantId[3]  = 0x00019E02 ; Wilhelm in Ivarstead for High Hrothgar
         aiMerchantId[4]  = 0x00019E02 ; Wilhelm in Ivarstead
         aiMerchantId[5]  = 0x00019931 ; Ainethach in Karthwasten
         aiMerchantId[6]  = 0x000198EA ; Lisbet in Markarth
         aiMerchantId[7]  = 0x0001AA60 ; Jorgen in Morthal
         aiMerchantId[8]  = 0x00066262 ; LeontiusSalvius in Old Hroldan
         aiMerchantId[9]  = 0x00019DDA ; Haelga in Riften
         aiMerchantId[10] = 0x00013487 ; LucanValerius in Riverwood
         aiMerchantId[11] = 0x0001A6A6 ; Rorik in Rorikstead
         aiMerchantId[12] = 0x00019E09 ; Filnjar in Shors Stone
         aiMerchantId[13] = 0x000198EA ; Lisbet in Markarth for Sky Haven
         aiMerchantId[14] = 0x000198C9 ; Sayma in Solitude
         aiMerchantId[15] = 0x000198C9 ; Sayma in Solitude for Thalmor Embassy
         aiMerchantId[16] = 0x0001A672 ; Belethor in Whiterun
         aiMerchantId[17] = 0x0001B123 ; RevynSadri in Windhelm
         aiMerchantId[18] = 0x0001C18C ; Birna in Winterhold

         If (MutexLock(_iCurrSceneMutex))
            _aCurrSceneAgressor = \
               (Game.GetFormFromFile(aiMerchantId[iRegionIndex], "Skyrim.esm") As Actor)

            MutexRelease(_iCurrSceneMutex)
         EndIf
      EndIf

      ; Verify we can perform this scene.
      If (!_aCurrSceneAgressor)
         Log("Failed to find actor for scene 3.  Aborting.", DL_ERROR, S_MOD)
         Return FAIL
      EndIf
      If (_aCurrSceneAgressor.IsDead())
         Log("Merchant dead for scene 3.  Aborting.", DL_INFO, S_MOD)
         Return FAIL
      EndIf
      If (_oPunishmentFurniture)
         Log("Furniture punishment active for scene 3.  Aborting.", DL_INFO, S_MOD)
         Return FAIL
      EndIf

      ; Have the leash holder move to the selected merchant.
      If (!_qFramework.IsMoving(aActor=_aLeashHolder))
         _qFramework.MoveToObject(_aLeashHolder, _aCurrSceneAgressor, S_MOD + "_NextStage")
      EndIf
   ElseIf (1 == iStage)
      ; Stage 1: At the merchant.
      String szParameters = "S, "
      Scene oDebugScene = (Game.GetFormFromFile(0x0001FEBD, "DfwSupport.esp") As Scene)
      If (!oDebugScene.IsPlaying())
         szParameters = "R, "
      EndIf
      If (oDebugScene == _aLeashHolder.GetCurrentScene())
         szParameters += "LH, "
      Else
         szParameters += "No LH, "
      EndIf
      If (oDebugScene == _aCurrSceneAgressor.GetCurrentScene())
         szParameters += "Agg, "
      Else
         szParameters += "No Agg, "
      EndIf
      If (oDebugScene == _aPlayer.GetCurrentScene())
         szParameters += "Ply, "
      Else
         szParameters = "No Ply, "
      EndIf
      DebugTrace("Scene 3 Stage 1: (" + szParameters + ")")

      ; Add a delay, giving the player time to catch up to the slaver.
      Float fSafety = 1.0
      While (fSafety && (_aPlayer.GetParentCell() != _aLeashHolder.GetParentCell()))
         Utility.Wait(0.1)
         fSafety -= 0.1
      EndWhile

      ; If the leash holder is too far away wait for him to become closer.
      If (!_aCurrSceneAgressor.Is3DLoaded() || \
          (300.0 < _aLeashHolder.GetDistance(_aCurrSceneAgressor)))
         _qFramework.MoveToObject(_aLeashHolder, _aCurrSceneAgressor, S_MOD + "_NextStage", \
                                  True)

         ModifySceneStage(iDelta=-1)
         Return WARNING
      EndIf

      ; Make sure the leash holder stays near the merchant.
      _qFramework.HoverAt(_aLeashHolder, _aCurrSceneAgressor, szSceneName)

      ; Find the Skyrim scene associated with this DFW scene.
      Scene oScene = (Game.GetFormFromFile(0x0001FEBD, "DfwSupport.esp") As Scene)

      ; If the scene is playing progress to the next stage.
      If (oScene.IsPlaying())
         ModifySceneStage(iDelta=1)
         Return SUCCESS
      EndIf

      ; Make sure the player actor is ready to be in the scene.
      PrepPlayerActorForScene()

      ; Choose a random path for dialogue in the scene.
      _iCurrDialoguePath = Utility.RandomInt(1, 100)

      ; Set up the actors for the scene.
      _aAliasQuestActor1.ForceRefTo(_aLeashHolder)
      _aAliasQuestActor2.ForceRefTo(_aCurrSceneAgressor)

      ; Reset the count of the slave's bad behaviour so we can detect it in the scene.
      _iLeashGoalRefusalCount = 0

      ; Start the scene.
      oScene.Start()
   ElseIf (2 == iStage)
      ;  2: In the scene.
      DebugTrace("Scene 3 Stage 2: ()")

      ; Find the Skyrim scene associated with this DFW scene.
      Scene oScene = (Game.GetFormFromFile(0x0001FEBD, "DfwSupport.esp") As Scene)

      ; Gagging the player can exit the scene (by starting a new scene).
      ; If this happens we need to restart the scene at the next stage to continue it.
      If (!oScene.IsPlaying())
         ModifySceneStage(iDelta=1)
         oScene.Start()
      EndIf
   ElseIf (3 == iStage)
      ;  3: In Scene Post Gagging.
      DebugTrace("Scene 3 Stage j: ()")

      ; If the scene is not running for any reason continue it.
      Scene oScene = (Game.GetFormFromFile(0x0001FEBD, "DfwSupport.esp") As Scene)
      If (!oScene.IsPlaying())
         oScene.Start()
      EndIf

      ; Do nothing while waiting for the scene to end.  It should end on its own.
   ElseIf (4 == iStage)
      ;  4: The scene is complete.
      DebugTrace("Scene 3 Stage 4: ()")

      ; The scene is complete.  Clean everything up.
      PrepPlayerActorForScene(True)
      _aAliasQuestActor1.Clear()
      _aAliasQuestActor2.Clear()
      _qFramework.HoverAtClear(szSceneName)

      ; Identify the player has lost her items.
      _bAllItemsTaken = True

      ; If the player was badly behaved (most likely trying to call for help during the scene)
      ; add a delay for the slaver to get outside before having the slaver discipline her.
      If (_iLeashGoalRefusalCount)
         _iLeashGoalRefusalCount = 0

         ; 1: Start Conversation.
         ; 2: Discipline - Misbehaving while selling items (_dfwsDisciplineSellItems).
         AddPendingAction(1, 2, _aLeashHolder, S_MOD + "_DisciplineSellItems", bPrepend=True)

         ; TODO: Eventually we probably want a scene name here but it conflicts with the assault
         ;       which already has a scene name.
         ; Ungag the player before the conversation.
         ; 2: Assault Player. 0x0100: UnGag
         AddPendingAction(2, 0x0100, _aLeashHolder, iSceneTimeout=60, bPrepend=True)

         ; 6: In Game Delay.       Details (Float): The in game time the delay should end.
         AddPendingAction(6, szScene=S_MOD + "_Delay", fDetails=(1.0 / 24.0 / 6.0), \
                          bPrepend=True)
      EndIf
      Return FAIL
   EndIf
   Return WARNING
EndFunction

Bool Function VerifyAssaultNeeded()
   ; 0x0001: Strip
   If (Math.LogicalAnd(0x0001, _iAssault))
      If (_qFramework.GetNakedLevel())
         Return True
      EndIf
      ; This assault clearly isn't needed.  Remove it.
      _iAssault -= 0x0001
   EndIf
   ; 0x0002: Gag
   If (Math.LogicalAnd(0x0002, _iAssault))
      If (!_qFramework.IsPlayerGagged())
         Return True
      EndIf
      ; This assault clearly isn't needed.  Remove it.
      _iAssault -= 0x0002
   EndIf
   ; 0x0004: Bind Arms (implies Unbind Mittens)
   If (Math.LogicalAnd(0x0004, _iAssault))
      If (!_qFramework.IsPlayerArmLocked())
         Return True
      EndIf
      ; This assault clearly isn't needed.  Remove it.
      _iAssault -= 0x0004
   EndIf
   ; 0x0020: Unbind Arms
   If (Math.LogicalAnd(0x0020, _iAssault))
      If (_qFramework.IsPlayerArmLocked())
         Return True
      EndIf
      ; This assault clearly isn't needed.  Remove it.
      _iAssault -= 0x0020
   EndIf
   ; 0x0080: Add Additional Restraint
   If (Math.LogicalAnd(0x0080, _iAssault))
      Return True
   EndIf
   ; 0x0100: UnGag
   If (Math.LogicalAnd(0x0100, _iAssault))
      If (_qFramework.IsPlayerGagged())
         Return True
      EndIf
      ; This assault clearly isn't needed.  Remove it.
      _iAssault -= 0x0100
   EndIf
   ; 0x0200: Restrain in Collar
   If (Math.LogicalAnd(0x0200, _iAssault))
      If (!_qFramework.IsPlayerCollared())
         Return True
      EndIf
      ; This assault clearly isn't needed.  Remove it.
      _iAssault -= 0x0200
   EndIf
   ; 0x0400: Blindfold
   If (Math.LogicalAnd(0x0400, _iAssault))
      ; 18: zad_DeviousBlindfold
      If (!_aPlayer.WornHasKeyword(_aoZadDeviceKeyword[18]))
         Return True
      EndIf
      ; This assault clearly isn't needed.  Remove it.
      _iAssault -= 0x0400
   EndIf
   ; 0x0800: Release Blindfold
   If (Math.LogicalAnd(0x0800, _iAssault))
      ; 18: zad_DeviousBlindfold
      If (_aPlayer.WornHasKeyword(_aoZadDeviceKeyword[18]))
         Return True
      EndIf
      ; This assault clearly isn't needed.  Remove it.
      _iAssault -= 0x0800
   EndIf
   ; 0x2000: Make sure the Gag is secure
   If (Math.LogicalAnd(0x2000, _iAssault))
      If (!_qFramework.IsGagStrict())
         Return True
      EndIf
      ; This assault clearly isn't needed.  Remove it.
      _iAssault -= 0x2000
   EndIf
   ; 0x4000: Restrain in Boots
   If (Math.LogicalAnd(0x4000, _iAssault))
      If (!_qFramework.IsPlayerHobbled())
         Return True
      EndIf
      ; This assault clearly isn't needed.  Remove it.
      _iAssault -= 0x4000
   EndIf
   ; 0x8000: Unbind Boots
   If (Math.LogicalAnd(0x8000, _iAssault))
      If (_qFramework.IsPlayerHobbled())
         Return True
      EndIf
      ; This assault clearly isn't needed.  Remove it.
      _iAssault -= 0x8000
   EndIf
   ; 0x00010000: Restrain in Bondage Mittens (implies Unbind Arms)
   If (Math.LogicalAnd(0x00010000, _iAssault))
      ; 22: zad_DeviousBondageMittens
      If (!_aPlayer.WornHasKeyword(_aoZadDeviceKeyword[22]))
         Return True
      EndIf
      ; This assault clearly isn't needed.  Remove it.
      _iAssault -= 0x00010000
   EndIf
   ; 0x00020000: Release from Bondage Mittens
   If (Math.LogicalAnd(0x00020000, _iAssault))
      ; 22: zad_DeviousBondageMittens
      If (_aPlayer.WornHasKeyword(_aoZadDeviceKeyword[22]))
         Return True
      EndIf
      ; This assault clearly isn't needed.  Remove it.
      _iAssault -= 0x00020000
   EndIf
   Return False
EndFunction

; All ProcessScene...() functions follow the same return codes.
; SUCCESS: The scene progressed immediately and may be able to progress again.
; WARNING: The scene is taking a delayed action in order to progress.
; FAIL:    The scene has ended.
Int Function ProcessSceneAssault(Int iStage, Actor aHelper, Int iTimeout, String szSceneName)
   ; Reset the scene timeout to let DFW know we are still monitoring progress.
   If (0 > _qFramework.SceneContinue(szSceneName, iTimeout))
      Return FAIL
   EndIf

   ;  4: Assault the player.
   ;   Stage 0: Performing Assault. 1: Resecuring Player. 3: Assault is complete.
   If (0 == iStage)
      ; Stage 0: Performing Assault.
      DebugTrace("Scene 4 Stage 0: (" + _bIsPlayerCaged + "," + _oBdsmFurniture + ")")

      ; Stage Entry Code:
      If (_iLastSceneStage != iStage)
         ; Make sure the slaver remains facing the player to begin the assault.
         _qFramework.HoverAt(aHelper, _aPlayer, S_MOD + "_FacePlayer", 3)

         ; Detect if the assualt is needed and end the scene if it isn't.
         If (!VerifyAssaultNeeded())
            Log("Assault scene not needed: 0x" + _qDfwUtil.ConvertHexToString(_iAssault, 8), \
                DL_TRACE, S_MOD)
            Return FAIL
         EndIf

         ; Perform the assault.
         PlayApproachAnimation(aHelper, "AssaultNextStage", szSceneName)
      EndIf

      ; Once the assault has started do nothing.  Just wait for the stage to increase.
   ElseIf (1 == iStage)
      ; Stage 1: Resecuring Player.
      DebugTrace("Scene 4 Stage 1: ()")

      ; Stage Entry Code:
      If (_iLastSceneStage != iStage)
         ; The assault has completed.  Re-secure the player if necessary.
         If (_oBdsmFurniture)
            If (!_bIsPlayerCaged)
               _qZbfSlaveActions.RestrainInDevice(_oBdsmFurniture, aHelper, S_MOD + "_NextStage")

               ; Securing the player is delayed.  Wait for it to complete before ending the scene.
               Return WARNING
            EndIf

            ; The player is caged.  Resecuring her is not delayed.
            CloseCageDoor(aHelper, _oBdsmFurniture, FindCageLever(_oBdsmFurniture))
            MoveIntoCage(aHelper, _oBdsmFurniture)
            ExitCage(aHelper)
         EndIf

         ; The assault has completed.  Progress to the cleanup stage of the scene.
         ModifySceneStage(iDelta=1)
      EndIf

      ; Once resecuring the player has started do nothing.  Just wait for the stage to increase.
   ElseIf (2 == iStage)
      ; Stage 2: Assault is complete.
      DebugTrace("Scene 4 Stage 2: (" + szSceneName + ")")

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

      ; The assault has completed.  Continue any scene that was previously running.
      If ((S_MOD + "_FurnForFun" == szSceneName) || (S_MOD == szSceneName))
         ; 1: Start Conversation. 12: Furniture Predicament.
         AddPendingAction(1, 12, aHelper, S_MOD + "_FurnForFun")
      EndIf
      Return FAIL
   EndIf
   Return WARNING
EndFunction

; All ProcessScene...() functions follow the same return codes.
; SUCCESS: The scene progressed immediately and may be able to progress again.
; WARNING: The scene is taking a delayed action in order to progress.
; FAIL:    The scene has ended.
Int Function ProcessSceneMilkPlayer(Int iStage, Actor aAgressor, Int iTimeout, \
                                    String szSceneName)
   ; Reset the scene timeout to let DFW know we are still monitoring progress.
   If (0 > _qFramework.SceneContinue(szSceneName, iTimeout))
      Return FAIL
   EndIf

   ; If the leash game ends for some reason, end this scene.
   If ((0 >= _iLeashGameDuration) && !_aLeashHolder)
      Return FAIL
   EndIf

   ; 5: Milk the player (Milk Maid Economy).
   ; Stage: 1: Intro dialogue started.  2: Intro dialogue complete.  3: At furniture location.
   ;        4: Arrived at furniture.    5: Preparing player.         6: Prepped for furniture.
   ;        7: Secured in furniture.    8: Player released.
   If (0 == iStage)
      DebugTrace("Scene 5 Stage 0: ()")

      ; Find a milking machine to use.
      Location oRegion = _qFramework.GetCurrentRegion()
      ; 0x0200: Milking Furniture
      ; 0x0040: Private
      ; 0x0080: Remote
      If (!_oTransferFurniture)
         _oTransferFurniture = GetRandomFurniture(oRegion=oRegion, iIncludeFlags=0x0200, \
                                                  iExcludeFlags=0x00C0)
         If (!_oTransferFurniture)
            ; 0x0200: Milking Furniture
            _oTransferFurniture = GetRandomFurniture(oRegion=oRegion, iIncludeFlags=0x0200)
         EndIf
      EndIf

      ; Verify we can perform this scene.
      If (_oPunishmentFurniture)
         Log("Furniture punishment active for scene 5.  Aborting.", DL_INFO, S_MOD)
         Return FAIL
      EndIf

      ; Start a basic conversation with the player.
      ; 5: Milking the player scene.
      _iCurrDialogue = 5
      _iCurrDialogueStage = 0
      _aCurrDialogueTarget = aAgressor
      StartConversation(aAgressor, iTimeout=8)

      ModifySceneStage(iDelta=1)
   ElseIf (1 == iStage)
      ; Stage 1: Intro dialogue started.
      DebugTrace("Scene 5 Stage 1: ()")

      ; Do nothing in this stage.  Just wait for the stage to increase.
   ElseIf (2 == iStage)
      ; Stage 2: Intro dialogue complete.
      DebugTrace("Scene 5 Stage 2: ()")

      ; If the furniture's location is invalid skip this step and try moving directly to it.
      Location oFurnitureLocation = _oTransferFurniture.GetCurrentLocation()
      If (!oFurnitureLocation)
         ModifySceneStage(iDelta=1)
         Return SUCCESS
      EndIf

      ; Otherwise move to the location.
      If (!_qFramework.IsMoving(aActor=aAgressor))
         _qFramework.MoveToLocation(aAgressor, oFurnitureLocation, S_MOD + "_NextStage")
      EndIf
   ElseIf (3 == iStage)
      ; Stage 3: At furniture location.
      DebugTrace("Scene 5 Stage 3: ()")

      ; Next move to the exact object.
      If (!_qFramework.IsMoving(aActor=aAgressor))
         _qFramework.MoveToObject(aAgressor, _oTransferFurniture, S_MOD + "_NextStage")
      EndIf
   ElseIf (4 == iStage)
      ; Stage 4: Arrived at furniture.
      DebugTrace("Scene 5 Stage 4: ()")

      ; Remove the player's hobble and arm binder to make the sceen look right.
      If (_qFramework.IsPlayerArmLocked())
         ; 0x0020: Unbind Arms
         _iAssault = Math.LogicalOr(0x0020, _iAssault)
      EndIf
      If (_qFramework.IsPlayerHobbled())
         ; 0x8000: Unbind Boots
         _iAssault = Math.LogicalOr(0x8000, _iAssault)
      EndIf
      If (_qFramework.IsPlayerGagged())
         ; 0x0100: UnGag
         _iAssault = Math.LogicalOr(0x0100, _iAssault)
      EndIf

      If (!_iAssault)
         ; The player is already prepared.  Skip the assault.
         ModifySceneStage(iDelta=2)
         Return SUCCESS
      EndIf

      ; An assualt is pending.  Play an animation for the slaver to approach the player.
      ; The assault will happen on the done event (OnSlaveActionDone).
      PlayApproachAnimation(aAgressor, "AssaultNextStage", szSceneName)
      ModifySceneStage(iDelta=1)
   ElseIf (5 == iStage)
      ; Stage 5: Preparing player.
      DebugTrace("Scene 5 Stage 5: ()")

      ; Do nothing in this stage.  Just wait for the stage to increase.
   ElseIf (6 == iStage)
      ; Stage 6: Prepped for furniture.
      DebugTrace("Scene 5 Stage 6: (" + _oTransferFurniture + ")")

      ; Upon entering this stage begin securing the player.  After that simply wait to progress
      ; to the next stage.
      If (_iLastSceneStage != iStage)
         ; If the player already has the being milked spell here for any reason remove it.
         If (_bMmeSuppressed || _aPlayer.HasSpell(_oMmeBeingMilkedSpell))
            _aPlayer.RemoveSpell(_oMmeBeingMilkedSpell)
         EndIf

         ; 4: Work.
         _iFurnitureExcuse = 4

         ; Identify the player is now locked in her furniture.
         SetCurrFurniture(_oTransferFurniture, True, aAgressor)
         _qFramework.SetBdsmFurnitureLocked()

         ; Secure the player in the milking machine.
         _qZbfSlaveActions.RestrainInDevice(_oBdsmFurniture, aAgressor, S_MOD + "_NextStage")
         _qFramework.GiveSpace(aAgressor, _aPlayer, S_MOD + "_WatchMilking", iTimeout=1)
         Utility.Wait(1.0)
         _qFramework.HoverAt(aAgressor, aAgressor, S_MOD + "_WatchMilking")

         ; Add a delay to give some time for the milking to start.
;         Utility.Wait(5.0)
      EndIf
   ElseIf (7 == iStage)
      ; Stage 7: Secured in furniture.
      DebugTrace("Scene 5 Stage 7: ()")

      ; Do nothing so long as the player is being milked.
      If (!_oMmeBeingMilkedSpell || !_aPlayer.HasSpell(_oMmeBeingMilkedSpell))
         ModifySceneStage(iDelta=1)
      EndIf
   ElseIf (8 == iStage)
      ; Stage 8: Player released.
      DebugTrace("Scene 5 Stage 8: ()")

      ; 1: Start Conversation.  5: Milking the player scene.
      ; TODO: Add a scene ending dialogue.
;      AddPendingAction(1, 5, aAgressor, szSceneName)

      ; Reset the mod ID for the hover so it can be cleard once the player is restrained.
      _qFramework.HoverAtClear(S_MOD + "_WatchMilking")
      _qFramework.HoverAt(aAgressor, aAgressor, S_MOD + "_SecurePlayer")

      ; Make sure the slaver re-restrains the player before pulling her from the machine.
      ; 2: Dominate the player and make sure she is secure
      _iAgendaMidTerm = 2

      Return FAIL
   EndIf
   Return WARNING
EndFunction

ObjectReference Function GetBlacksmithWorkbench(Int iRegionIndex)
   If (-1 == iRegionIndex)
      Return None
   EndIf

   Int[] aiHitchingPostId = New Int[19]
   aiHitchingPostId[0]  = 0x000CADF6 ; Blacksmith Forge in Dawnstar
   aiHitchingPostId[1]  = 0x000D6CA8 ; Fire Pit in Solitude for Dragon Bridge
   aiHitchingPostId[2]  = 0x00099B88 ; Blacksmith Workbench in Falkreath
   aiHitchingPostId[3]  = 0x0010CD6F ; Mill Weapon Stone in Ivarstead for High Hrothgar
   aiHitchingPostId[4]  = 0x0010CD6F ; Mill Weapon Stone in Ivarstead
   aiHitchingPostId[5]  = 0x0010CD7B ; Crate by Smelter in Karthwasten
   aiHitchingPostId[6]  = 0x0007FB60 ; Jarl Blacksmith Workbench in Markarth
   aiHitchingPostId[7]  = 0x0002D503 ; Mill Weapon Stone in Morthal
   aiHitchingPostId[8]  = 0x0010D3FD ; Weapon Stone in Old Hroldan
   aiHitchingPostId[9]  = 0x00053484 ; Blacksmith Workbench in Riften
   aiHitchingPostId[10] = 0x0003550D ; Blacksmith Workbench in Riverwood
   aiHitchingPostId[11] = 0x00000000 ; No Valid Tools in Rorikstead
   aiHitchingPostId[12] = 0x0005CAC5 ; Blacksmith Workbench in Shors Stone
   aiHitchingPostId[13] = 0x0007FB60 ; Jarl Blacksmith Workbench in Markarth for Sky Haven
   aiHitchingPostId[14] = 0x000D6CA8 ; Fire Pit in Solitude
   aiHitchingPostId[15] = 0x000D6CA8 ; Fire Pit in Solitude for Thalmor Embassy
   aiHitchingPostId[16] = 0x0002056C ; Blacksmith Workbench in Whiterun
   aiHitchingPostId[17] = 0x000FF283 ; Blacksmith Workbench in Windhelm
   aiHitchingPostId[18] = 0x000838BF ; Crate in Hall of Attainment in Winterhold

   Return (Game.GetFormFromFile(aiHitchingPostId[iRegionIndex], "Skyrim.esm") \
           As ObjectReference)
EndFunction

; All ProcessScene...() functions follow the same return codes.
; SUCCESS: The scene progressed immediately and may be able to progress again.
; WARNING: The scene is taking a delayed action in order to progress.
; FAIL:    The scene has ended.
Int Function ProcessSceneRemoveRestraints(Int iStage, Actor aAgressor, Int iTimeout, \
                                          String szSceneName)
   ; Reset the scene timeout to let DFW know we are still monitoring progress.
   If (0 > _qFramework.SceneContinue(szSceneName, iTimeout))
      Return FAIL
   EndIf

   ; If the leash game ends for some reason, end this scene.
   If ((0 >= _iLeashGameDuration) && !_aLeashHolder)
      Return FAIL
   EndIf

   ; 6: Ask the blacksmith to remove restraints from other mods.
   ; Stage: 1: Intro Done.  2: At the Hitching Post.  3: Waiting for the blacksmith.
   ;        4: Blacksmith Arrived.  5: Negotiation scene.
   ;        6: Negotiation scene complete.  7: Blacksmith starts working. 8-xx: Blacksmith tasks.
   ;        11: Slaver is returning.  12: Slaver returns.  13: Result scene.
   ;        14: Result scene complete.
   If (0 == iStage)
      DebugTrace("Scene 6 Stage 0: (" + _aCurrSceneAgressor + "," + _oTransferFurniture + ")")

      ; If we haven't identified the merchant yet select the nearest one from a specific list.
      If (!_aCurrSceneAgressor)
         Int iRegionIndex = _qFramework.GetNearestRegionIndex(iVersion=1)
         If (-1 == iRegionIndex)
            Log("Failed to find region for scene 6.  Aborting.", DL_ERROR, S_MOD)
            Return FAIL
         EndIf

         Int[] aiBlacksmithId = New Int[19]
         aiBlacksmithId[0]  = 0x0001A6BE ; Rustleif in Dawnstar
         aiBlacksmithId[1]  = 0x000198B1 ; Fihada in Solitude for Dragon Bridge
         aiBlacksmithId[2]  = 0x0003A19F ; Lod in Falkreath
         aiBlacksmithId[3]  = 0x00065AB3 ; Temba in Ivarstead for High Hrothgar
         aiBlacksmithId[4]  = 0x00065AB3 ; Temba in Ivarstead
         ; Note this needs to be updated to one of the nearby miners once I find his name.
         aiBlacksmithId[5]  = 0x00019931 ; Ainethach in Karthwasten
         aiBlacksmithId[6]  = 0x00055A63 ; Moth in Markarth
         aiBlacksmithId[7]  = 0x0001AA60 ; Jorgen in Morthal
         aiBlacksmithId[8]  = 0x00066262 ; LeontiusSalvius in Old Hroldan
         aiBlacksmithId[9]  = 0x00019DF1 ; Balimund in Riften
         aiBlacksmithId[10] = 0x00013482 ; Alvor in Riverwood
         aiBlacksmithId[11] = 0x00000000 ; No Valid Tools in Rorikstead
         aiBlacksmithId[12] = 0x00019E09 ; Filnjar in Shors Stone
         aiBlacksmithId[13] = 0x00055A63 ; Moth in Markarth for Sky Haven
         aiBlacksmithId[14] = 0x000198B1 ; Fihada in Solitude
         aiBlacksmithId[15] = 0x000198B1 ; Fihada in Solitude for Thalmor Embassy
         aiBlacksmithId[16] = 0x0001A67C ; AdrianneAvenicci in Whiterun
         aiBlacksmithId[17] = 0x0001B136 ; Hermir in Windhelm
         aiBlacksmithId[18] = 0x0001C1AB ; ArnielGane in Winterhold

         If (MutexLock(_iCurrSceneMutex))
            _aCurrSceneAgressor = \
               (Game.GetFormFromFile(aiBlacksmithId[iRegionIndex], "Skyrim.esm") As Actor)

            MutexRelease(_iCurrSceneMutex)
         EndIf
         _oTransferFurniture = GetBlacksmithWorkbench(iRegionIndex)
      EndIf

      ; Verify we can perform this scene.
      If (!_aCurrSceneAgressor)
         Log("Failed to find actor for scene 6.  Aborting.", DL_INFO, S_MOD)
         Return FAIL
      EndIf
      If (_aCurrSceneAgressor.IsDead())
         Log("Blacksmith dead for scene 6.  Aborting.", DL_INFO, S_MOD)
         Return FAIL
      EndIf
      If (_oPunishmentFurniture)
         Log("Furniture punishment active for scene 6.  Aborting.", DL_INFO, S_MOD)
         Return FAIL
      EndIf

      _qFramework.HoverAt(_aLeashHolder, _aPlayer, szSceneName)
      Utility.Wait(1.0)

      ; Start a basic conversation with the player (controlled via the scene and stage).
      StartConversation(_aLeashHolder, iTimeout=5)
      Utility.Wait(2.0)

      ModifySceneStage(iDelta=1)
   ElseIf (1 == iStage)
      ; Stage 1: Intro Done.
      DebugTrace("Scene 6 Stage 1: ()")

      ; Stage Entry Code:
      If (_iLastSceneStage != iStage)
DebugLog("Scene 6 Stage 1 Entry Code", iLevel=DL_INFO)
         _qFramework.HoverAtClear(szSceneName)
      EndIf

      ; If the furniture has not yet been identified try to load it now.
      If (!_oTransferFurniture)
         _oTransferFurniture = \
            GetBlacksmithWorkbench(_qFramework.GetNearestRegionIndex(iVersion=1))

         ; If we now have furniture to move to abort moving to the blacksmith and move to it.
         If (_oTransferFurniture)
            ; 1: Leash the player to an object.
            _iSceneModule = 1

            ; Generic Form parameters:
            _aoSceneModuleParameter = New Form[1]

            ; Parameter 0: The object to move to.
            _aoSceneModuleParameter[0] = _oTransferFurniture
            Return SUCCESS
         EndIf

         ; If we arrive at the blacksmith and the furniture isn't in range abort the scene.
         If (_aCurrSceneAgressor.Is3DLoaded() && \
             (500 >= _aLeashHolder.GetDistance(_aCurrSceneAgressor)))
            Log("Failed to load furniture for scene 6.  Aborting.", DL_ERROR, S_MOD)
            Return FAIL
         EndIf

         ; If we don't have transfer furniture it is not loaded yet.  Keep moving to the
         ; blacksmith until the furniture comes into range (hopefully it does).
         If (!_qFramework.IsMoving(_aLeashHolder, iMovementType=3))
            _qFramework.MoveToObjectClose(_aLeashHolder, _aCurrSceneAgressor, szSceneName)
         EndIf
         Return WARNING
      EndIf

      ; If the module failed to process the scene abort it.
      If (FAIL == _iSceneModuleOutput)
         Return FAIL
      EndIf

      ; If the slaver is not near the hitching post move to it.
      If (_oTransferFurniture != _qFramework.GetLeashTarget())
         ; 1: Leash the player to an object.
         _iSceneModule = 1
         _iSceneModuleOutput = 0

         ; Generic Form parameters:
         _aoSceneModuleParameter = New Form[1]

         ; Parameter 0: The object to move to.
         _aoSceneModuleParameter[0] = _oTransferFurniture
         Return SUCCESS
      EndIf

      ; The player has been transferred to the hitching post.  Clear it as a transfer furniture.
      _oTransferFurniture = None

      ; Start the blacksmith moving to the player in order to start the scene.
      _qFramework.MoveToObjectClose(_aCurrSceneAgressor, _aLeashHolder, S_MOD + "_NextStage")

      ModifySceneStage(iDelta=1)
   ElseIf (2 == iStage)
      ; Stage 2: Secure the player.
      DebugTrace("Scene 6 Stage 2: ()")

      ; Have the slaver secure the player for being left alone with the blacksmith.
      ; 2: Secure player for being left.
      _iSceneModule = 2

      ; Generic Form parameters:
      _aoSceneModuleParameter = New Form[1]

      ; Parameter 0: The actor performing the assault.
      _aoSceneModuleParameter[0] = _aLeashHolder

      ; Bool parameters:
      _abSceneModuleParameter = New Bool[1]

      ; Parameter 0: Gag the player.
      _abSceneModuleParameter[0] = True

      Return SUCCESS
   ElseIf (3 == iStage)
      ; Stage 3: Waiting for the blacksmith.
      DebugTrace("Scene 6 Stage 3: ()")

      ; If the blacksmith isn't moving re-start his movement.
      If (!_qFramework.IsMoving(aActor=_aCurrSceneAgressor))
         _qFramework.MoveToObjectClose(_aCurrSceneAgressor, _aLeashHolder, S_MOD + "_NextStage")
      EndIf
   ElseIf (4 == iStage)
      ; Stage 4: Blacksmith Arrived.
      DebugTrace("Scene 6 Stage 4: ()")

      ; Have the blacksmith stay near the slaver during the negotiation scene.
      If (!_qFramework.IsMoving(aActor=_aCurrSceneAgressor, iMovementType=4))
         ObjectReference oHitchingPost = _qFramework.GetLeashTarget()
         _qFramework.HoverAt(_aCurrSceneAgressor, oHitchingPost, S_MOD + "_Blacksmith", \
                             bForce=True)
      EndIf

      ; Reset the count of the slave's bad behaviour so we can detect it in the scene.
      _iVerbalAnnoyance = 0

      ; For debugging purposes, skip this scene and move straight to the blacksmith's work.
      ; ModifySceneStage(iDelta=2)
      ; Return SUCCESS

      ; Find the Skyrim scene associated with this DFW scene.
      Scene oScene = (Game.GetFormFromFile(0x000290F7, "DfwSupport.esp") As Scene)

      ; If the scene is playing progress to the next stage.
      If (oScene.IsPlaying())
         ModifySceneStage(iDelta=1)
         Return SUCCESS
      EndIf

      ; Make sure the player actor is ready to be in the scene.
      PrepPlayerActorForScene()

      ; Choose a random path for dialogue in the scene.
      _iCurrDialoguePath = Utility.RandomInt(1, 100)

      ; Set up the actors for the scene.
      _aAliasQuestActor1.ForceRefTo(_aLeashHolder)
      _aAliasQuestActor2.ForceRefTo(_aCurrSceneAgressor)

      ; Start the scene between the slaver and the blacksmith.
      oScene.Start()
   ElseIf (5 == iStage)
      ; Stage 5: Negotiation scene.
      DebugTrace("Scene 6 Stage 5: ()")

      ; If the scene is not running for any reason continue it.
      Scene oScene = (Game.GetFormFromFile(0x000290F7, "DfwSupport.esp") As Scene)
      If (!oScene.IsPlaying())
         oScene.Start()
      EndIf

      ; Do nothing while waiting for the scene to end.  It should end on its own.
   ElseIf (6 == iStage)
      ; Stage 6: Negotiation scene complete.
      DebugTrace("Scene 6 Stage 6: ()")

      ; The scene is done.  Clear the aliases.
      PrepPlayerActorForScene(True)
      _aAliasQuestActor1.Clear()
      _aAliasQuestActor2.Clear()

      ; The slaver is done with this scene.  Have him carry on with his day.
      _qFramework.HoverAtClear(szSceneName)

      ; Change the blacksmith stay near the player now.
      _qFramework.HoverAtClear(S_MOD + "_Blacksmith")
      _qFramework.HoverAt(_aCurrSceneAgressor, _aPlayer, S_MOD + "_Blacksmith", bForce=True)
      ModifySceneStage(iDelta=1)

      ; Return a delayed status so the next stage doesn't start too quickly after this one.
      Return WARNING
   ElseIf (7 == iStage)
      ; Stage 7: Blacksmith starts working.
      DebugTrace("Scene 6 Stage 7: ()")

      ; This stage needs a number of parameters.  Make sure they are set up now.
      ; Bool parameters:
      _abCurrSceneParameter = New Bool[1]

      ; Parameter 0: Flag whether the blacksmith is committed to having sex with the player.
      _abCurrSceneParameter[0] = False

      ; Float parameters:
      _afCurrSceneParameter = New Float[6]

      ; Parameter 0: A return time for the slaver to check on the progress.
      _afCurrSceneParameter[0] = (Utility.GetCurrentGameTime() + (3.0 / 24.0))

      ; Parameter 1: A delay between activities in this stage < 1 minute.
      _afCurrSceneParameter[1] = Utility.GetCurrentRealTime() + 15

      ; Parameter 2: A timer for how long to remain in the current stage < 10 minutes.
      _afCurrSceneParameter[2] = 0

      ; Parameter 2-4: The player's X,Y,Z position.
      _afCurrSceneParameter[3] = _aPlayer.X
      _afCurrSceneParameter[4] = _aPlayer.Y
      _afCurrSceneParameter[5] = _aPlayer.Z

      ; String parameters:
      _aszCurrSceneParameter = New String[1]

      ; Parameter 0: The idle the blacksmith is currently running.
      _aszCurrSceneParameter[0] = None

      ; Keep track of how often the player refuses to behave.
      _iLeashGoalRefusalCount = 0

      ; There are several dialogues in this stage said by the blacksmith only.
      ; Fill an Alias with the blacksmith so the dialogue system can identify him.
      _aAliasQuestActor2.ForceRefTo(_aCurrSceneAgressor)

      ; Have the blacksmith perform an initial greeting to the player.
      Utility.Wait(3)
      ; 6: Remove Restraint Scene Blacksmith Dialogues.
      _iCurrDialogue = 6
      _aCurrDialogueTarget = _aCurrSceneAgressor
      _iCurrDialogueStage = 1
      If (65 <= _qSexLabAroused.GetActorArousal(_aCurrSceneAgressor))
         _iCurrDialogueStage = 0
         _abCurrSceneParameter[0] = True
      EndIf
      StartConversation(_aCurrSceneAgressor, iTImeout=10)

      ModifySceneStage(iDelta=1)

      Return WARNING
   ElseIf ((8 <= iStage) && (12 >= iStage))
      ; Stage 8-xx: Blacksmith tasks.
      DebugTrace("Scene 6 Stage " + iStage + ": (" + _iCurrDialogueStage + ")")

      ; If blacksmith is in the middle of a conversation don't start anything else.
      If (_iCurrDialogueStage)
         Return WARNING
      EndIf

      ; If we are in a delay don't try to start anything.
      Float fCurrRealTime = Utility.GetCurrentRealTime()
      If (_afCurrSceneParameter[1] > fCurrRealTime)
         ; If the delay is more than 60 seconds the game has been loaded.  Reset the delay time.
         If (_afCurrSceneParameter[1] > (fCurrRealTime + 60))
            _afCurrSceneParameter[1] = fCurrRealTime + 8
         EndIf
         Return WARNING
      EndIf

      ; If the player's position has been cleared.  Restore it.
      If (0.0 == _afCurrSceneParameter[3])
         _afCurrSceneParameter[3] = _aPlayer.X
         _afCurrSceneParameter[4] = _aPlayer.Y
         _afCurrSceneParameter[5] = _aPlayer.Z
      EndIf

      ; If the blacksmith is committed to having sex with the player do so now.
      If (_abCurrSceneParameter[0])
         ; Add a delay so nothing else happens before the sex scene begins.
         _afCurrSceneParameter[1] = fCurrRealTime + 5

         ; If the blacksmith is still in a particular pose stop it.
         StopNpcAnimation(_aCurrSceneAgressor, _aszCurrSceneParameter[0])
         _aszCurrSceneParameter[0] = None

         ; Start the sex scene.
         _abCurrSceneParameter[0] = False
         StartSex(_aCurrSceneAgressor, True)

         ; Clear the player's position so she doesn't get in trouble for moving.
         _afCurrSceneParameter[3] = 0.0
         _afCurrSceneParameter[4] = 0.0
         _afCurrSceneParameter[5] = 0.0

         Return WARNING
      EndIf

      ; If the delay is more than 600 seconds the game has been loaded.  Reset the delay time.
      If (_afCurrSceneParameter[2] > (fCurrRealTime + 600))
         _afCurrSceneParameter[2] = fCurrRealTime + 60
      EndIf

      ; If the slaver has been away long enough have him return.  Only do this if the blacksmith
      ; is still working on restraints.  Otherwise the slaver's return will be handled in the
      ; in the next stage of the scene.
      If ((Utility.GetCurrentGameTime() > _afCurrSceneParameter[0]) && \
          !_aoCurrSceneParameter[0])
         ; If the slaver is nearby have him start a dialogue.
         ObjectReference oHitchingPost = _qFramework.GetLeashTarget()
         If (_aLeashHolder.Is3DLoaded() && (500 <= _aLeashHolder.GetDistance(oHitchingPost)))
            ; If the blacksmith is still in a particular pose stop it.
            StopNpcAnimation(_aCurrSceneAgressor, _aszCurrSceneParameter[0])
            _aszCurrSceneParameter[0] = None

            ; Make sure the slaver is hovering at the hitching post.
            If (!_qFramework.IsMoving(aActor=_aLeashHolder, iMovementType=4))
               _qFramework.HoverAt(_aLeashHolder, oHitchingPost, S_MOD + "_MeetUp")
            EndIf

            ; If the blacksmith is far away have him move closer.
            Float fBlacksmithDistance = _aLeashHolder.GetDistance(_aCurrSceneAgressor)
            If (!_aCurrSceneAgressor.Is3DLoaded())
               fBlacksmithDistance = 10000
            EndIf
            If ((350 < fBlacksmithDistance) && \
                !_qFramework.IsMoving(szModId=S_MOD + "_MeetUp", iMovementType=3))
               _qFramework.MoveToObject(_aCurrSceneAgressor, _aLeashHolder, S_MOD + "_MeetUp")
            Else
               ; Make sure the blacksmith is hovering at the slaver.
               If (!_qFramework.IsMoving(aActor=_aCurrSceneAgressor, iMovementType=4))
                  _qFramework.HoverAt(_aCurrSceneAgressor, _aLeashHolder, S_MOD + "_MeetUp")
               EndIf

               ; Otherwise if the scene isn't running start it now.
               Scene oScene = (Game.GetFormFromFile(0x0002CC6F, "DfwSupport.esp") As Scene)
               If (!oScene.IsPlaying())
                  ; Choose a random path for dialogue in the scene.
                  _iCurrDialoguePath = Utility.RandomInt(1, 100)

                  ; Set up the actors for the scene.
                  _aAliasQuestActor1.ForceRefTo(_aLeashHolder)
                  _aAliasQuestActor2.ForceRefTo(_aCurrSceneAgressor)

                  ; Start the scene.
                  oScene.Start()
               EndIf
            EndIf
         Else
            ; Otherwise the slaver should be walking toward the player.
            If (!_qFramework.IsMoving(szModId=S_MOD + "_SceneReturn", iMovementType=3))
               _qFramework.MoveToObject(_aLeashHolder, oHitchingPost, S_MOD + "_SceneReturn")
            EndIf
         EndIf
      EndIf

      ; Stage 8: Identify invalid restraints.
      If (8 == iStage)
         ; 0x00075C3D: IdleExamine
         StartNpcAnimation(_aCurrSceneAgressor, "IdleExamine", _aszCurrSceneParameter[0], \
                           _aPlayer)
         _aszCurrSceneParameter[0] = "IdleExamine"

         _afCurrSceneParameter[1] = fCurrRealTime + 20
         ; Stage 9: Process next restraint.
         ModifySceneStage(iNewValue=9)

         ; Create a list of invalid restraints worn.
         ; Keep track of which slots we've already checked.
         Int iSlotsChecked

         ; Ignore items that would be in reserved slots.
         iSlotsChecked += (CS_RESERVED1 + CS_RESERVED2 + CS_RESERVED3)

         Int iSearchMask = CS_START
         While (iSearchMask < CS_MAX)
            ; Only search slots we haven't found something in already.
            If (!Math.LogicalAnd(iSlotsChecked, iSearchMask))
               Armor oItem = (_aPlayer.GetWornForm(iSearchMask) As Armor)
               If (oItem)
                  ; Only care about this item if it is a restraint not from this mod.
                  If ((oItem.HasKeyword(_qZadLibs.zad_Lockable) || \
                       oItem.HasKeyword(_oKeywordZbfWornDevice)) && \
                      !IsDeviceFromDfws(oItem))
                     If (!_aoCurrSceneParameter)
                        _aoCurrSceneParameter = New Form[1]
                        _aoCurrSceneParameter[0] = oItem
                     Else
                        _aoCurrSceneParameter = \
                           _qDfwUtil.AddFormToArray(_aoCurrSceneParameter, oItem)
                     EndIf
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
         Return WARNING
      EndIf

      ; Stage 9: Process next restraint.
      If (9 == iStage)
         ; Clear the player's position so she doesn't get in trouble for moving.
         _afCurrSceneParameter[3] = 0.0
         _afCurrSceneParameter[4] = 0.0
         _afCurrSceneParameter[5] = 0.0

         ; Check if the blacksmith is aroused enough to play with the player.
         If (40 <= _qSexLabAroused.GetActorArousal(_aCurrSceneAgressor))
            ; 6: Remove Restraint Scene Blacksmith Dialogues.
            _iCurrDialogue = 6
            _iCurrDialogueStage = 9
            _aCurrDialogueTarget = _aCurrSceneAgressor
            StartConversation(_aCurrSceneAgressor, iTImeout=10)
            _abCurrSceneParameter[0] = True

            ; Set a delay until the conversation completes.
            _afCurrSceneParameter[1] = fCurrRealTime + 6

            Return WARNING
         EndIf

         ; Try to handle the first restraint from the invalid restraint array.
         Armor oRestraint = (_aoCurrSceneParameter[0] As Armor)
         If (!oRestraint)
            ; All restraints have been processed.  Clear the blacksmith's work.
            ; If the blacksmith is still in a particular pose stop it.
            StopNpcAnimation(_aCurrSceneAgressor, _aszCurrSceneParameter[0])
            _aszCurrSceneParameter[0] = None

            ; Perform a simple "We're finished" dialogue.
            Utility.Wait(3)
            ; 6: Remove Restraint Scene Blacksmith Dialogues.
            _iCurrDialogue = 6
            _iCurrDialogueStage = 3
            If (!IsWearingInvalidRestraints())
               _iCurrDialogueStage = 2
               _abCurrSceneParameter[0] = True
            EndIf
            _aCurrDialogueTarget = _aCurrSceneAgressor
            StartConversation(_aCurrSceneAgressor)

            ; Clear the blacksmith's package so he can get back to his normal work.
            _qFramework.HoverAtClear(S_MOD + "_Blacksmith")

            ModifySceneStage(iNewValue=13)

            Return WARNING
         EndIf

         ; Find the type keyword associated with the device.
         Keyword oDeviousKeyword = GetDeviousKeyword(oRestraint)

         ; Process any yokes.
         ; 8: zad_DeviousYoke
         If (_aoZadDeviceKeyword[8] == oDeviousKeyword)
            ; Check if this is the Deviously Cursed Loot Yoke Errand quest.
            Keyword oKeywordDcurYoke = Keyword.GetKeyword("dcur_kw_yoke")
            Quest qDcurYokeErrand = Quest.GetQuest("dcur_yokeerrand")
            If (qDcurYokeErrand.IsRunning() && oRestraint.HasKeyword(oKeywordDcurYoke))
               ; A dialogue saying the blacksmith is sending a courier to complete the quest.
               ; 6: Remove Restraint Scene Blacksmith Dialogues.
               _iCurrDialogue = 6
               _iCurrDialogueStage = 6
               _aCurrDialogueTarget = _aCurrSceneAgressor
               StartConversation(_aCurrSceneAgressor)

               ; Set a delay for how long it takes the courier to complete the task.
               _afCurrSceneParameter[2] = fCurrRealTime + 120 + Utility.RandomInt(0, 240)

               ; Have the blacksmith return to his previous work while waiting for the courier.
               Utility.Wait(18.0)
               _qFramework.HoverAtClear(S_MOD + "_Blacksmith")

               ; Clear the player's position so she doesn't get in trouble for moving.
               _afCurrSceneParameter[3] = 0.0
               _afCurrSceneParameter[4] = 0.0
               _afCurrSceneParameter[5] = 0.0

               ; Stage 10: Return to work while waiting.
               ModifySceneStage(iNewValue=10)
               Return WARNING
            EndIf
         EndIf

         ; A dialogue saying the blacksmith is starting work on a new restraint.
         ; 6: Remove Restraint Scene Blacksmith Dialogues.
         _iCurrDialogue = 6
         _iCurrDialogueStage = 8
         _aCurrDialogueTarget = _aCurrSceneAgressor
         StartConversation(_aCurrSceneAgressor)
         Utility.Wait(5.0)

         ; Set a delay for how long it takes the blacksmith to complete the task.
         _afCurrSceneParameter[2] = fCurrRealTime + 120 + Utility.RandomInt(0, 240)

         ; For any other (unknown) restraints try to work on them and check success after.
         ; Check for any lower body restraints (a different pose will be used for them).
         ; 0: zad_DeviousBelt           4: zad_DeviousLegCuffs      6: zad_DeviousHobbleSkirt
         ; 7: zad_DeviousAnkleShackles  15: zad_DeviousPlugVaginal  16: zad_DeviousPlugAnal
         ; 19: zad_DeviousBoots         21: zad_DeviousPiercingsVaginal
         If ((oDeviousKeyword == _aoZadDeviceKeyword[0]) || \
             (oDeviousKeyword == _aoZadDeviceKeyword[4]) || \
             (oDeviousKeyword == _aoZadDeviceKeyword[6]) || \
             (oDeviousKeyword == _aoZadDeviceKeyword[7]) || \
             (oDeviousKeyword == _aoZadDeviceKeyword[15]) || \
             (oDeviousKeyword == _aoZadDeviceKeyword[16]) || \
             (oDeviousKeyword == _aoZadDeviceKeyword[19]) || \
             (oDeviousKeyword == _aoZadDeviceKeyword[21]))
            ; Stage 11: Hammering at restraints (low).
            ModifySceneStage(iNewValue=11)
         Else
            ; Stage 12: Hammering at restraints (high).
            ModifySceneStage(iNewValue=12)
         EndIf

         ; While the blacksmith is working find the inventory device for this rendered device.
         ; Note: _qZadLibs.GetWornDevice() can be a very slow function.  We can only use it here
         ; becaue we have time while the blacksmith is working.
         Armor oInventoryDevice = _qZadLibs.GetWornDevice(_aPlayer, oDeviousKeyword)
         _aoCurrSceneParameter = _qDfwUtil.AddFormToArray(_aoCurrSceneParameter, \
                                                          oInventoryDevice, True)
         Return WARNING
      EndIf

      ; Stage 10: Return to work while waiting.
      If (10 == iStage)
         ; If we are still in the current task don't process anything.
         If (_afCurrSceneParameter[2] > fCurrRealTime)
            Return WARNING
         EndIf

         ; Once the stage is complete the blacksmith returns to finish processing the restraint.
         _qFramework.HoverAt(_aCurrSceneAgressor, _aPlayer, S_MOD + "_Blacksmith", bForce=True)

         ; Keep track of which restraint we are working with.
         Armor oRestraint = (_aoCurrSceneParameter[0] As Armor)

         ; Check if this is the Deviously Cursed Loot Yoke Errand quest.
         Keyword oKeywordDcurYoke = Keyword.GetKeyword("dcur_kw_yoke")
         Quest qDcurYokeErrand = Quest.GetQuest("dcur_yokeerrand")
         If (qDcurYokeErrand.IsRunning() && oRestraint.HasKeyword(oKeywordDcurYoke))
            ; 6: Remove Restraint Scene Blacksmith Dialogues.
            _iCurrDialogue = 6
            _iCurrDialogueStage = 7
            _aCurrDialogueTarget = _aCurrSceneAgressor
            StartConversation(_aCurrSceneAgressor)
            Utility.Wait(10.0)

            ; End the quest.
            dcur_yokeerrandquestscript qYokeErrandQuest = \
               (qDcurYokeErrand As dcur_yokeerrandquestscript)
            qYokeErrandQuest.terminatequest()
            _aPlayer.RemoveItem(oRestraint, 1, akOtherContainer=_aCurrSceneAgressor)

            ; Make sure the blacksmith restrains the players arms in the provided arm binder.
            ; 0x0004: Bind Arms (implies Unbind Mittens)
            _iAssault = Math.LogicalOr(0x0004, _iAssault)
            PlayApproachAnimation(_aCurrSceneAgressor, "Assault", szSceneName)

            ; Set a delay until the approach completes.
            _afCurrSceneParameter[1] = fCurrRealTime + 20
         EndIf

         ; Clear the player's position so she doesn't get in trouble for moving.
         _afCurrSceneParameter[3] = 0.0
         _afCurrSceneParameter[4] = 0.0
         _afCurrSceneParameter[5] = 0.0

         ; Once processed start on the next restraint on the list.
         _aoCurrSceneParameter = _qDfwUtil.RemoveFormFromArray(_aoCurrSceneParameter, None, 0)
         ModifySceneStage(iNewValue=9)
         Return WARNING
      EndIf

      ; If the player is moving about tell her to stand still.
      If (((20 < (_aPlayer.X - _afCurrSceneParameter[3])) || \
           (-20 > (_aPlayer.X - _afCurrSceneParameter[3]))) || \
          ((20 < (_aPlayer.Y - _afCurrSceneParameter[4])) || \
           (-20 > (_aPlayer.Y - _afCurrSceneParameter[4]))) || \
          ((20 < (_aPlayer.Z - _afCurrSceneParameter[5])) || \
           (-20 > (_aPlayer.Z - _afCurrSceneParameter[5]))))
         ; If the blacksmith is still in a particular pose stop it.
         StopNpcAnimation(_aCurrSceneAgressor, _aszCurrSceneParameter[0])
         _aszCurrSceneParameter[0] = None

         ; Add a delay so the player doesn't get punished multiple times before she has a
         ; chance to behave.
         _afCurrSceneParameter[1] = fCurrRealTime + 8

         ; Parameter 1-3: The player's X,Y,Z position.
         _afCurrSceneParameter[3] = _aPlayer.X
         _afCurrSceneParameter[4] = _aPlayer.Y
         _afCurrSceneParameter[5] = _aPlayer.Z

         ; Keep track of how often the player refuses to behave.
         _iLeashGoalRefusalCount += 1

         ; 6: Remove Restraint Scene Blacksmith Dialogues.
         _iCurrDialogue = 6
         _iCurrDialogueStage = 4
         _aCurrDialogueTarget = _aCurrSceneAgressor
         StartConversation(_aCurrSceneAgressor, iTImeout=3)
         Return WARNING
      EndIf

      ; Make sure the player is facing away from the blacksmith.
      Float fAngle = _aPlayer.GetHeadingAngle(_aCurrSceneAgressor)
      If ((9 != iStage) && (10 != iStage) && ((160 > fAngle) && (-160 < fAngle)))
         ; If the blacksmith is still in a particular pose stop it.
         StopNpcAnimation(_aCurrSceneAgressor, _aszCurrSceneParameter[0])
         _aszCurrSceneParameter[0] = None

         ; Add a delay so the player doesn't get punished multiple times before she has a
         ; chance to behave.
         _afCurrSceneParameter[1] = fCurrRealTime + 8

         ; Keep track of how often the player refuses to behave.
         If (_iLeashGoalRefusalCount || (20 >= Utility.RandomInt(1, 100)))
            _iLeashGoalRefusalCount += 1
         EndIf

         ; 6: Remove Restraint Scene Blacksmith Dialogues.
         _iCurrDialogue = 6
         _iCurrDialogueStage = 5
         _aCurrDialogueTarget = _aCurrSceneAgressor
         StartConversation(_aCurrSceneAgressor, iTImeout=3)
         Return WARNING
      EndIf

      ; Stage 11: Hammering at restraints (low).
      ; Stage 12: Hammering at restraints (high).
      If ((11 == iStage) || (12 == iStage))
         ; Make sure the animation for this stage of the scene is running.
         ; 0x000C432D: IdleHammerTableEnter
         String szAnimation = "IdleHammerTableEnter"
         If (12 == iStage)
            ; 0x000C4320: IdleHammerWallEnter
            szAnimation = "IdleHammerWallEnter"
         EndIf

         StartNpcAnimation(_aCurrSceneAgressor, szAnimation, _aszCurrSceneParameter[0], \
                           _aPlayer)
         _aszCurrSceneParameter[0] = szAnimation

         ; If we are still in the current task don't process anything else.
         If (_afCurrSceneParameter[2] > fCurrRealTime)
            Return WARNING
         EndIf

         ; Otherwise the task is done.  See about processing the restraints.
         StopNpcAnimation(_aCurrSceneAgressor, _aszCurrSceneParameter[0])

         ; Keep track of which restraint we are working with.
         Armor oRestraint = (_aoCurrSceneParameter[0] As Armor)

         ; Figure out which key is used to unlock the device.
         Key oRestraintKey = _qZadLibs.GetDeviceKey(oRestraint)
         ; If this is a standard device key, remove the device.
         Int iKeyId = oRestraintKey.GetFormId()
         ; 0x0001775F: zad_RestraintsKey  0x00008A4F: zad_ChastityKey
         ; 0x000409A4: zad_PiercingsRemovalTool
         If ((0x0001775F == Math.LogicalAnd(0x0001775F, iKeyId)) || \
             (0x00008A4F == Math.LogicalAnd(0x00008A4F, iKeyId)) || \
             (0x000409A4 == Math.LogicalAnd(0x000409A4, iKeyId)))
            ; If we found a key the restraint is the Inventory device.  To remove it we also
            ; need the rendered device which should be next on the list.
            Armor oRestraintRendered = (_aoCurrSceneParameter[1] As Armor)
            Keyword oDeviousKeyword = GetDeviousKeyword(oRestraintRendered)
            _qZadLibs.RemoveDevice(_aPlayer, oRestraint, oRestraintRendered, oDeviousKeyword)
            _aPlayer.RemoveItem(oRestraint, 1, akOtherContainer=_aCurrSceneAgressor)

            ; Make sure the blacksmith restrains the player in the replacements provided.
            ; 14: zad_DeviousGag
            If (oDeviousKeyword == _aoZadDeviceKeyword[14])
               ; 0x0002: Gag
               _iAssault = Math.LogicalOr(0x0002, _iAssault)
            ; 3: zad_DeviousArmCuffs  5: zad_DeviousArmbinder  8: zad_DeviousYoke
            ; 11: zad_DeviousGloves   13: zad_DeviousSuit      22: zad_DeviousBondageMittens
            ElseIf ((oDeviousKeyword == _aoZadDeviceKeyword[3]) || \
                    (oDeviousKeyword == _aoZadDeviceKeyword[5]) || \
                    (oDeviousKeyword == _aoZadDeviceKeyword[8]) || \
                    (oDeviousKeyword == _aoZadDeviceKeyword[11]) || \
                    (oDeviousKeyword == _aoZadDeviceKeyword[13]) || \
                    (oDeviousKeyword == _aoZadDeviceKeyword[22]))
               ; 0x0004: Bind Arms (implies Unbind Mittens)
               _iAssault = Math.LogicalOr(0x0004, _iAssault)
            ; 2: zad_DeviousCollar  17: zad_DeviousHarness
            ElseIf ((oDeviousKeyword == _aoZadDeviceKeyword[2]) || \
                    (oDeviousKeyword == _aoZadDeviceKeyword[17]))
               ; 0x0200: Restrain in Collar
               _iAssault = Math.LogicalOr(0x0200, _iAssault)
            ; 4: zad_DeviousLegCuffs  6: zad_DeviousHobbleSkirt  7: zad_DeviousAnkleShackles
            ; 19: zad_DeviousBoots
            ElseIf ((oDeviousKeyword == _aoZadDeviceKeyword[4]) || \
                    (oDeviousKeyword == _aoZadDeviceKeyword[6]) || \
                    (oDeviousKeyword == _aoZadDeviceKeyword[7]) || \
                    (oDeviousKeyword == _aoZadDeviceKeyword[19]))
               ; 0x4000: Restrain in Boots
               _iAssault = Math.LogicalOr(0x4000, _iAssault)
            EndIf
            If (_iAssault)
               PlayApproachAnimation(_aCurrSceneAgressor, "Assault", szSceneName)
            EndIf

            ; Set a delay until the approach completes.
            _afCurrSceneParameter[1] = fCurrRealTime + 20
         EndIf

         ; Once processed start on the next restraint on the list.
         _aoCurrSceneParameter = _qDfwUtil.RemoveFormFromArray(_aoCurrSceneParameter, None, 0)

         ; If this is an inventory device it was added by us in addition to the rendered device.
         If (oRestraint.HasKeyword(_qZadLibs.zad_InventoryDevice))
            ; Remove the rendered device as well.
            _aoCurrSceneParameter = _qDfwUtil.RemoveFormFromArray(_aoCurrSceneParameter, None, \
                                                                  0)
         EndIf
         ModifySceneStage(iNewValue=9)
         Return WARNING
      EndIf
   ElseIf (13 == iStage)
      ; Stage 13: Slaver is returning.
      DebugTrace("Scene 6 Stage 13: ()")

      ; Do nothing while a conversation is still on going.
      If (6 == _iCurrDialogue)
         Return WARNING
      EndIf

      ; The blacksmith still has permission to play with the player.  Check his arousal.
      If (40 <= _qSexLabAroused.GetActorArousal(_aCurrSceneAgressor))
         ; TODO: Fix the dialogue here.

         ; 6: Remove Restraint Scene Blacksmith Dialogues.
         _iCurrDialogue = 6
         _iCurrDialogueStage = 2
         _aCurrDialogueTarget = _aCurrSceneAgressor
         _abCurrSceneParameter[0] = True
         StartConversation(_aCurrSceneAgressor, iTImeout=8)
         Return WARNING
      EndIf

      ; If the blacksmith is committed to having sex with the player do so now.
      If (_abCurrSceneParameter[0])
         _abCurrSceneParameter[0] = False
         StartSex(_aCurrSceneAgressor, True)
         Return WARNING
      EndIf

      ; If the slaver has been away long enough or if he is nearby have him return.
      Float fCurrGameTime = Utility.GetCurrentGameTime()
      If ((fCurrGameTime > _afCurrSceneParameter[0]) || \
          _qFramework.IsActorNearby(_aLeashHolder))
         ; If the slaver isn't moving re-start his movement.
         If (!_qFramework.IsMoving(aActor=_aLeashHolder))
            ObjectReference oHitchingPost = _qFramework.GetLeashTarget()
            _qFramework.MoveToObject(_aLeashHolder, oHitchingPost, S_MOD + "_NextStage")
         EndIf
      EndIf
   ElseIf (14 == iStage)
      ; Stage 14: Waiting for the blacksmith.
      DebugTrace("Scene 6 Stage 14: ()")

      ; Have the slaver hover around the hitching post for the results dialogue.
      If (!_qFramework.IsMoving(aActor=_aLeashHolder, iMovementType=4))
         ObjectReference oHitchingPost = _qFramework.GetLeashTarget()
         _qFramework.HoverAt(_aLeashHolder, oHitchingPost, S_MOD + "_MeetUp")
      EndIf

      ; Have the blacksmith return to the hitching post as well.
      If (!_qFramework.IsMoving(aActor=_aCurrSceneAgressor))
         ObjectReference oHitchingPost = _qFramework.GetLeashTarget()
         _qFramework.MoveToObject(_aCurrSceneAgressor, oHitchingPost, S_MOD + "_NextStage")
      EndIf
   ElseIf (15 == iStage)
      ; Stage 15: Blacksmith Arrived.
      DebugTrace("Scene 6 Stage 15: ()")

      ; Have the blacksmith stay near the slaver during the results scene.
      If (!_qFramework.IsMoving(aActor=_aCurrSceneAgressor, iMovementType=4))
         _qFramework.HoverAt(_aCurrSceneAgressor, _aLeashHolder, S_MOD + "_Blacksmith")
      EndIf

      ; Find the Skyrim scene associated with this DFW scene.
      Scene oScene = (Game.GetFormFromFile(0x0002CC76, "DfwSupport.esp") As Scene)

      ; If the scene is playing progress to the next stage.
      If (oScene.IsPlaying())
         ModifySceneStage(iDelta=1)
         Return SUCCESS
      EndIf

      ; Make sure the player actor is ready to be in the scene.
      PrepPlayerActorForScene()

      ; Identify whether removing the restraints was successful or not.
      _iCurrDialoguePath = 0
      If (!IsWearingInvalidRestraints())
         _iCurrDialoguePath = 1
      EndIf

      ; Set up the actors for the scene.
      _aAliasQuestActor1.ForceRefTo(_aLeashHolder)
      _aAliasQuestActor2.ForceRefTo(_aCurrSceneAgressor)

      ; Start the scene between the slaver and the blacksmith.
      oScene.Start()
   ElseIf (16 == iStage)
      ; Stage 16: Result scene.
      DebugTrace("Scene 6 Stage 16: ()")

      ; If the scene is not running for any reason continue it.
      Scene oScene = (Game.GetFormFromFile(0x0002CC76, "DfwSupport.esp") As Scene)
      If (!oScene.IsPlaying())
         oScene.Start()
      EndIf

      ; Do nothing while waiting for the scene to end.  It should end on its own.
   ElseIf (17 == iStage)
      ; Stage 17: Result scene complete.
      DebugTrace("Scene 6 Stage 17: ()")

      ; The scene is complete.  Clean up.
      _qFramework.HoverAtClear(S_MOD + "_MeetUp")
      _qFramework.HoverAtClear(S_MOD + "_Blacksmith")

      ; All that is left is for the slaver to collect the player.
      _qFramework.SetLeashLength(_qMcm.iLeashLength)
      _qFramework.SetLeashTarget(_aLeashHolder)

      Return FAIL
   ElseIf (99 == iStage)
      ; Stage 99: Misbehaving too much.  Punishment needed.
      DebugTrace("Scene 6 Stage 99: ()")

      ; While the leash holder is still and active participant in a scene don't do anything.
      If (_aLeashHolder.GetCurrentScene())
         Return WARNING
      EndIf

      ; Otherwise the scene has finished.  Start a punishment for the player.
      ; Clear any hovering that is part of the scene.
      _qFramework.HoverAtClear(szSceneName)
      _qFramework.HoverAtClear(S_MOD + "_Blacksmith")

      ; Have the leash holder retake control of the leash.
      _qFramework.SetLeashLength(_qMcm.iLeashLength)
      _qFramework.SetLeashTarget(_aLeashHolder)

      ; Continue the scene as a new punishment scene.
      _qFramework.SceneContinue(S_MOD + "_DisciplineCallOut", 60, szSceneName)
      PunishPlayer(_aLeashHolder, 0, S_MOD + "_DisciplineCallOut")

      Return FAIL
   EndIf
   Return WARNING
EndFunction

; All ProcessScene...() functions follow the same return codes.
; SUCCESS: The scene progressed immediately and may be able to progress again.
; WARNING: The scene is taking a delayed action in order to progress.
; FAIL:    The scene has ended.
Int Function ProcessSceneReturnToLeashGame(Int iStage, Actor aAgressor, Int iTimeout, \
                                           String szSceneName)
   ; Reset the scene timeout to let DFW know we are still monitoring progress.
   If (0 > _qFramework.SceneContinue(szSceneName, iTimeout))
      Return FAIL
   EndIf

   ; If the leash game ends for some reason, end this scene.
   If ((0 >= _iLeashGameDuration) && !_aLeashHolder)
      Return FAIL
   EndIf

   ; 7: Return to the leash game.
   ; Stage: 1: Arrived at player.  2: Player out of arm binder.
   ;        3: Ask the player if she is willing to behave.  4: Conversation complete.
   If (0 == iStage)
      DebugTrace("Scene 7 Stage 0: ()")

      ; If the actor is dead fail the scene.
      If (aAgressor.IsDead())
         Log("Actor dead for scene 7.  Aborting.", DL_ERROR, S_MOD)
         Return FAIL
      EndIf

      ; 3: Move to the player for a conversation.
      _iSceneModule = 3
      Return SUCCESS
   ElseIf (1 == iStage)
      ; Stage 1: Arrived at player.
      DebugTrace("Scene 7 Stage 1: ()")

      ; If the player is caged and out of her arm binder, get her back into it.
      If (_bIsPlayerCaged && !_qFramework.IsPlayerArmLocked())
         ; 12: Player removed her arm binder.
         _iCurrDialogue = 12
         _aCurrDialogueTarget = aAgressor
         StartConversation(aAgressor, iTimeout=20)

         ModifySceneStage(iDelta=1)
         Return SUCCESS
      EndIf
      ; Otherwise start a conversation with the player about her behaviour.
      ModifySceneStage(iDelta=2)
      Return SUCCESS
   ElseIf (2 == iStage)
      ; Stage 2: Player out of arm binder.
      DebugTrace("Scene 7 Stage 2: ()")

      ; TODO: Replacing the arm binder should use the assult player scene rather than
      ; performing it separately here.

      ; If the player is caged and out of her arm binder, get her back into it.
      If (_bIsPlayerCaged && !_qFramework.IsPlayerArmLocked())
         ; If the player is not close enough, beckon her again.
         If (60.0 < aAgressor.GetDistance(_aPlayer))
            ; 10: Order the player to come.
            _iCurrDialogue = 10
            _aCurrDialogueTarget = aAgressor
            StartConversation(aAgressor, iTImeout=3)
            Return WARNING
         EndIf

         Float fAngle = _aPlayer.GetHeadingAngle(aAgressor)
         If ((160 > fAngle) && (-160 < fAngle))
            ; 13: Order the player to turn around.
            _iCurrDialogue = 13
            _aCurrDialogueTarget = aAgressor
            StartConversation(aAgressor, iTImeout=3)
            Return WARNING
         EndIf

         ; The player is close enough and facing away from the slaver.  Add her arm binder.
         FindArmRestraint(aAgressor)
         ; Unequip the player's gloves/forearms as they interact oddly with arm binders.
         _aPlayer.UnequipItemSlot(33) ; 0x00000008
         _aPlayer.UnequipItemSlot(34) ; 0x00000010
         ; 5: zad_DeviousArmbinder
         EquipBdsmItem(_oArmRestraint, _aoZadDeviceKeyword[5], aAgressor)
      EndIf

      ; Otherwise start a conversation with the player about her behaviour.
      ModifySceneStage(iDelta=1)
      Return SUCCESS
   ElseIf (3 == iStage)
      ; Stage 3: Ask the player if she is willing to behave.
      DebugTrace("Scene 7 Stage 3: ()")

      ; 14: Ask the player if she will behave.
      _iCurrDialogue = 14
      _aCurrDialogueTarget = aAgressor
      _iCurrDialogueResults = 0
      StartConversation(aAgressor)
   ElseIf (4 == iStage)
      ; Stage 4: Conversation complete.
      DebugTrace("Scene 7 Stage 4: (" + _iCurrDialogueResults + ")")

      ; If the results are in and the player is not co-operating don't release her.
      If (1 != _iCurrDialogueResults)
         _iFurnitureRemaining += (((180 + (180 * _iBadBehaviour)) / _fMcmPollTime) As Int)
         _qFramework.HoverAtClear(szSceneName)
         _qFramework.ForceSave()
         Return FAIL
      EndIf

      ; The player is co-operating.  Release her from her furniture.
      ; Sex was allowed while the player was being punished.  Revoke that now.
      If (!_qMcm.bAllowSex)
         _qFramework.RemovePermission(aAgressor, _qFramework.AP_SEX)
      EndIf
      _oPunishmentFurniture = None

      ; Have the slaver double check the player is secure and secure her if she is not.
      _iAgendaMidTerm = 2

      ; Reset the duration of the leash game in case there is little time remaining.
      Int iDurationSeconds = ((GetLeashGameDuration() / _fMcmPollTime) As Int)
      If (iDurationSeconds > _iLeashGameDuration)
         _iLeashGameDuration = iDurationSeconds
      EndIf

      _aAliasFurnitureLocker.ForceRefTo(aAgressor)
      _bFurnitureForFun = False
      _fFurnitureReleaseTime = 0
      If (_bIsPlayerCaged)
         ; ReleaseFromFurniture() secures the player in the leash game using the _BdsmToLeash
         ; ZAZ Slave Action Event.  Releasing the player from furniture must also secure
         ; the leash game.  Do that here.
         If (_aLeashHolder == aAgressor)
            _qFramework.SetLeashLength(_qMcm.iLeashLength)
            _qFramework.SetLeashTarget(aAgressor)
            _bFullyRestrained = False
            _bIsCompleteSlave = False
         Else
            ; Otherwise start the leash game as normal.
            StartLeashGame(aAgressor)
         EndIf

         ReleasePlayerFromCage(aAgressor, _oBdsmFurniture)
         _bIsPlayerCaged = False
      Else
         ;    DisablePlayerControls(Move,  Fight, Cam,   Look,  Sneak, Menu,  Active, Journ)
         Game.DisablePlayerControls(True,  False, False, False, False, False, True,   False)
         ImmobilizePlayer()

         ReleaseFromFurniture(aAgressor)
      EndIf
      _qFramework.HoverAtClear(szSceneName)
      _qFramework.ForceSave()

      ; The scene is done.  The player is locked up.  End the scene.
      Return FAIL
   EndIf
   Return WARNING
EndFunction

; All ProcessScene...() functions follow the same return codes.
; SUCCESS: The scene progressed immediately and may be able to progress again.
; WARNING: The scene is taking a delayed action in order to progress.
; FAIL:    The scene has ended.
Int Function ProcessSceneWhipPlayer(Int iStage, Actor aAgressor, Int iTimeout, \
                                    String szSceneName)
   ; Reset the scene timeout to let DFW know we are still monitoring progress.
   If (0 > _qFramework.SceneContinue(szSceneName, iTimeout))
      Return FAIL
   EndIf

   ; 8: Whip the Player.
   ; Stage: 0: Check if Leashed.  1: Enter Cage.  2: Reel Player In.  3: Player Secured.
   ;        4: Whipping.  5: Scene Done.
   If (0 == iStage)
      ; Stage 0: Check if Leashed.
      DebugTrace("Scene 8 Stage 0: ()")

      ; If the player is already secured in BDSM furniture skip to stage 3.
      If (_oBdsmFurniture && !_bIsPlayerCaged)
         ModifySceneStage(iDelta=3)
         Return SUCCESS
      EndIf

      ; For now we don't support any securing the player.  Just move to the next stage.
      If (_bIsPlayerCaged)
         ModifySceneStage(iDelta=1)
         Return SUCCESS
      EndIf
      ModifySceneStage(iDelta=2)
   ElseIf (1 == iStage)
      ; Stage 1: Enter Cage.
      DebugTrace("Scene 8 Stage 1: ()")

      ; TODO: Open the cage door and capture the player.
      ; For now we don't support any securing the player.  Just move to the next stage.
      ModifySceneStage(iDelta=1)
      Return SUCCESS
   ElseIf (2 == iStage)
      ; Stage 2: Reel Player In.
      DebugTrace("Scene 8 Stage 2: ()")

      ; TODO: Beckon the player over and shorten her leash.
      ; For now we don't support any securing the player.  Just move to the next stage.
      ModifySceneStage(iDelta=1)
      Return SUCCESS
   ElseIf (3 == iStage)
      ; Stage 3: Player Secured.
      DebugTrace("Scene 8 Stage 3: ()")

      ; Make sure nearby slaves don't interfere with the whipping scene.
      SlavesGiveSpace(aAgressor, S_MOD + "_Whipping", 120)

      ; Start the whipping scene.
      StartWhippingScene(aAgressor, 120, szSceneName, szCurrScene=szSceneName)
      ModifySceneStage(iDelta=1)
   ElseIf (4 == iStage)
      ; Stage 4: Whipping.
      DebugTrace("Scene 8 Stage 4: ()")

      ; Do nothing.  The whipping is progressing.
   ElseIf (5 == iStage)
      ; Stage 5: Scene Done.
      DebugTrace("Scene 8 Stage 5: ()")

      ; The scene is done.  End the scene.
      Return FAIL
   EndIf
   Return WARNING
EndFunction

; All ProcessScene...() functions follow the same return codes.
; SUCCESS: The scene progressed immediately and may be able to progress again.
; WARNING: The scene is taking a delayed action in order to progress.
; FAIL:    The scene has ended.
Int Function ProcessScenePunishFurniture(Int iStage, Actor aAgressor, Int iTimeout, \
                                         String szSceneName)
   ; Reset the scene timeout to let DFW know we are still monitoring progress.
   If (0 > _qFramework.SceneContinue(szSceneName, iTimeout))
      Return FAIL
   EndIf

   ; If the leash game ends for some reason, end this scene.
   If ((0 >= _iLeashGameDuration) && !_aLeashHolder)
      Return FAIL
   EndIf

   ; 9: Start Furniture Punishment.
   ; Stage: 0: Validate scene.  1: Arrived at furniture.  2: Waiting to prepare.
   ;        3: Preparing the player.  4: Waiting to secure the player.  5: Secure the player.
   If (0 == iStage)
      ; Stage 0: Validate scene.
      DebugTrace("Scene 9 Stage 0: ()")

      ; Verify we can perform this scene.
      If (!_oPunishmentFurniture)
         _oPunishmentFurniture = GetRandomFurniture(_qFramework.GetNearestRegion(), iReason=2)
         If (!_oPunishmentFurniture)
            Log("No nearby furniture for scene 7.  Aborting.", DL_ERROR, S_MOD)
            Return FAIL
         EndIf
      EndIf

      ; Clear the automatic release timer if it is running.
      _fFurnitureReleaseTime = 0

      ; Stage Entry Code:
      If (_iLastSceneStage != iStage)
         ; 16: Beckon the player to come along.
         _iCurrDialogue = 16
         StartConversation(aAgressor, iTImeout=3)
      EndIf

      ; 4: Move to an object.
      _iSceneModule = 4

      ; Generic Form parameters:
      _aoSceneModuleParameter = New Form[1]

      ; Parameter 0: The object to move to.
      _aoSceneModuleParameter[0] = _oPunishmentFurniture
   ElseIf (1 == iStage)
      ; Stage 1: Arrived at furniture.
      DebugTrace("Scene 9 Stage 1: ()")

      ; Add a delay here in case the player needs to be pulled into the cell.
      Utility.Wait(0.5)

      ; We have arrived at the furniture.  Prepare the player for the furniture.
      ActorSitStateWait(aAgressor)
      _qZbfSlaveActions.BindPlayer(akMaster=aAgressor, asMessage=S_MOD + "_NextStage")
      ModifySceneStage(iDelta=1)

      ; Find out if the punishment furniture is a cage or not.
      Bool bIsCage
      If (_oPunishmentFurniture && MutexLock(_iFavouriteFurnitureMutex))
         Int iIndex = _aoFavouriteFurniture.Find(_oPunishmentFurniture)
         ; 0x0002: Cage
         If ((-1 != iIndex) && Math.LogicalAnd(0x0002, _aiFavouriteFlags[iIndex]))
            bIsCage = True
         EndIf

         MutexRelease(_iFavouriteFurnitureMutex)
      EndIf

      ; If this is a cage and the door is closed open it.
      If (bIsCage && (2 < _oPunishmentFurniture.GetOpenState()))
         ObjectReference oLever = FindCageLever(_oPunishmentFurniture)
         If (oLever)
            oLever.Activate(aAgressor)
         Else
            _oPunishmentFurniture.SetOpen(False)
         EndIf
      EndIf
   ElseIf (2 == iStage)
      ; Stage 2: Waiting to prepare.
      DebugTrace("Scene 9 Stage 2: ()")

      ; Do nothing.  The scene will progress once the binding animation is complete.
   ElseIf (3 == iStage)
      ; Stage 3: Preparing the player.
      DebugTrace("Scene 9 Stage 3: ()")

      If (!_oPunishmentFurniture)
         _oPunishmentFurniture = GetRandomFurniture(oCell=_aPlayer.GetParentCell())
         If (!_oPunishmentFurniture)
            ; Something went wrong.  End the scene.
            Log("Lost furniture for scene 7-3.  Aborting.", DL_ERROR, S_MOD)
            _qFramework.HoverAtClear(szSceneName)
            Return FAIL
         EndIf
      EndIf

      ; If the player is crawling allow her to stand.  She can't be crawling in furniture.
      If (_iCrawlRemaining)
         _iCrawlRemaining = 0
         ; If the player is not being punished in other ways clear the punishment status.
         ; TODO: There is still a race condition where these timers could have expired but the
         ; player has not actually been released.  We need a flag (or short term agenda) to
         ; indicate a punishment release is pending.
         If (!_iBlindfoldRemaining && !_iGagRemaining && !_iFurnitureRemaining)
            _iAgendaLongTerm = 1
            _iDetailsLongTerm = 0
            _fTimePunished = 0.0
            _fTimeLastPunished = Utility.GetCurrentGameTime()
         EndIf

         ; 22: zad_DeviousBondageMittens
         UnequipBdsmItem(_aoMittens, _aoZadDeviceKeyword[22], aAgressor)
      EndIf

      ; Make sure furniture locked dialogue will be available for 300 seconds.
      If (!_iDialogueFurnitureLocked)
         _iDialogueFurnitureLocked = ((300 / _fMcmPollTime) As Int)
      EndIf

      ; 2: The player is being punished for bad behaviour.
      _iFurnitureExcuse = 2

      ; Identify the player is now locked in her furniture.
      SetCurrFurniture(_oPunishmentFurniture, True, aAgressor)

      ; Allow sex while the player is being punished.
      _qFramework.AddPermission(aAgressor, _qFramework.AP_SEX)

      ; Preparing the player is different depending on whether she is being caged or not.
      If (_bIsPlayerCaged)
         If (!_qFramework.IsPlayerArmLocked())
            ; 5: zad_DeviousArmbinder
            EquipBdsmItem(_oArmRestraint, _aoZadDeviceKeyword[5], aAgressor)
         EndIf

         ; Locking the player in a cage needs less preparation.  Move on to securing her.
         ModifySceneStage(iDelta=2)
         Return SUCCESS
      EndIf

      ; Otherwise the furniture is not a cage.  Prepare the player for it.
      _qFramework.SetBdsmFurnitureLocked()
      ; 5: zad_DeviousArmbinder  19; zad_DeviousBoots
      UnequipBdsmItem(_aoArmRestraints, _aoZadDeviceKeyword[5], aAgressor)
      UnequipBdsmItem(_aoLegRestraints, _aoZadDeviceKeyword[19], aAgressor)

      If (_iGagRemaining && !_qFramework.IsPlayerGagged())
         ; 14: zad_DeviousGag
         EquipBdsmItem(_oGag, _aoZadDeviceKeyword[14], aAgressor)
      EndIf

      ; Disable Milk Mod Economy, preventing it from starting animations on the player.
      If (_oMmeBeingMilkedSpell && !_aPlayer.HasSpell(_oMmeBeingMilkedSpell))
         _aPlayer.AddSpell(_oMmeBeingMilkedSpell, False)
         _bMmeSuppressed = True
         ; Add a delay to make sure the spell has taken effect.
         Utility.Wait(0.5)
      EndIf

      ; Start the restraining sequence.
      _qZbfSlaveActions.RestrainInDevice(_oPunishmentFurniture, aAgressor, S_MOD + "_NextStage")

      ModifySceneStage(iDelta=1)
   ElseIf (4 == iStage)
      ; Stage 4: Waiting to secure the player.
      DebugTrace("Scene 9 Stage 4: ()")

      ; Do nothing.  The player is being restrained.  The scene will continue when done.
   ElseIf (5 == iStage)
      ; Stage 5: Secure the player.
      DebugTrace("Scene 9 Stage 5: ()")

      ; If we have suppressed Milk Mod Economy re-enable it.
      If (_bMmeSuppressed)
         If (_oMmeBeingMilkedSpell)
            _aPlayer.RemoveSpell(_oMmeBeingMilkedSpell)
         EndIf
         _bMmeSuppressed = False
      EndIf

      ; Securing the player is different depending on whether she is being caged or not.
      If (_bIsPlayerCaged)
         LockPlayerInCage(aAgressor, _oPunishmentFurniture)
         Log(GetDisplayName(aAgressor) + " pushes you in the cage and closes the door.", \
             DL_CRIT, S_MOD)
      Else
         ; Whip the player as further punishment.
         ; 4: Start Scene.  Scene 8: Whip the Player.
         AddPendingAction(4, 8, aAgressor, S_MOD + "_WhipBdsmPunish", bPrepend=True)
      EndIf

      ; Start the punishment.
      _qFramework.SetLeashTarget(None)
      _iFurnitureRemaining += (((180 + (180 * _iBadBehaviour)) / _fMcmPollTime) As Int)
      _iAgendaLongTerm = 3
      _iDetailsLongTerm = 0
      _fTimeLastPunished = 0.0

      ; Make sure the blindfold and gag punishment last until the player is released.
      ; This is to avoid a "remove gag while in furniture" scene that hasn't been created yet.
      If (_iBlindfoldRemaining && (_iBlindfoldRemaining < _iFurnitureRemaining))
         _iBlindfoldRemaining = _iFurnitureRemaining
      EndIf
      If (_iGagRemaining && (_iGagRemaining < _iFurnitureRemaining))
         _iGagRemaining = _iFurnitureRemaining
      EndIf

      ; 15: Tell the player to think about her behaviour.
      _iCurrDialogue = 15
      _aCurrDialogueTarget = aAgressor
      StartConversation(aAgressor, iTimeout=10)

      ; We have just locked the player into furniture.  Consider sandboxing nearby.
      ; 0x0100: Activity/Sandbox (NPCs can sandbox nearby)
      If (_qMcm.iFurnitureRemoteSandbox >= Utility.RandomInt(1, 100) && \
          Math.LogicalAnd(0x0100, ToggleFurnitureFlag(_oPunishmentFurniture, 0x0000)))
         ; 5: Start a Sandbox.
         AddPendingAction(5, aActor=aAgressor, bPrepend=True)
      EndIf

      ; Clear the slaver from hovering from when he arrived at the furniture.
      _qFramework.HoverAtClear(szSceneName)

      ; The scene is done.  End the scene.
      Return FAIL
   EndIf
   Return WARNING
EndFunction

; All ProcessScene...() functions follow the same return codes.
; SUCCESS: The scene progressed immediately and may be able to progress again.
; WARNING: The scene is taking a delayed action in order to progress.
; FAIL:    The scene has ended.
Int Function ProcessScenePropositionSex(Int iStage, Actor aAgressor, Int iTimeout, \
                                        String szSceneName)
   ; Reset the scene timeout to let DFW know we are still monitoring progress.
   If (0 > _qFramework.SceneContinue(szSceneName, iTimeout))
      Return FAIL
   EndIf

   ; If the leash game ends for some reason, end this scene.
   If ((0 >= _iLeashGameDuration) && !_aLeashHolder)
      Return FAIL
   EndIf

   ; 10: Proposition the slaver for sex.
   ; Stage: 0: Start Scenario.  1: NPC arrived at slaver.  Playing Scene.  2: Scene Done.
   ;        3: Preparing the player.  4: Waiting to secure the player.  5: Secure the player.
   If (0 == iStage)
      ; Stage 0: Start Scenario.
      DebugTrace("Scene 10 Stage 0: ()")

      ; Stage Entry Code:
      If (_iLastSceneStage != iStage)
         ; Have the NPC move to the slaver.
         _qFramework.MoveToObject(_aCurrSceneAgressor, _aLeashHolder, S_MOD + "_MeetUp")
      EndIf

      Float fDistance = _aLeashHolder.GetDistance(_aCurrSceneAgressor)

      ; If the NPC is near the slaver have the slaver stop.
      If ((500 > _aLeashHolder.GetDistance(_aCurrSceneAgressor)) && \
          !_qFramework.IsMoving(_aLeashHolder, S_MOD + "_Waiting", 4))
         _qFramework.HoverAt(_aLeashHolder, _aLeashHolder, S_MOD + "_Waiting")
      EndIf

      ; If they are near enough to have a conversation advance the stage.
      If (250 > _aLeashHolder.GetDistance(_aCurrSceneAgressor))
         _qFramework.HoverAt(_aCurrSceneAgressor, _aCurrSceneAgressor, S_MOD + "_Scene")

         ModifySceneStage(iDelta=1)
         Return SUCCESS
      ElseIf (!_qFramework.IsMoving(aActor=_aCurrSceneAgressor))
         ; If the John has stopped moving have him approach the Slaver again.
         ; TODO: This technically shouldn't be needed as the first MoveToObject() should work.
         _qFramework.MoveToObject(_aCurrSceneAgressor, _aLeashHolder, S_MOD + "_MeetUp")
      EndIf
   ElseIf (1 == iStage)
      ; Stage 1: NPC arrived at slaver.  Playing Scene.
      DebugTrace("Scene 10 Stage 1: ()")

      ; Stage Entry Code:
      If (_iLastSceneStage != iStage)
         ; Make sure the player actor is ready to be in the scene.
         PrepPlayerActorForScene()

         ; Reset the count of the slave's bad behaviour so we can detect it in the scene.
         _iVerbalAnnoyance = 0

         ; Choose a random path for dialogue in the scene.
         _iCurrDialoguePath = Utility.RandomInt(1, 100)
      EndIf

      ; If the scene is not running for any reason continue it.
      Scene oScene = (Game.GetFormFromFile(0x00034E24, "DfwSupport.esp") As Scene)
      If (!oScene.IsPlaying())
         ; Set up the actors for the scene.
         _aAliasQuestActor1.ForceRefTo(_aLeashHolder)
         _aAliasQuestActor2.ForceRefTo(_aCurrSceneAgressor)

         oScene.Start()
      EndIf

      ; Do nothing while waiting for the scene to end.  It should end on its own.
   ElseIf (2 == iStage)
      ; Stage 2: Scene Done.
      DebugTrace("Scene 10 Stage 2: ()")

      ; For now sex with the player always nets the leash holder 30 gold.
      _iLeashHolderWealth += 30

      ; The scene will be done after sex.  Prepare to wrap it up.
      _qFramework.HoverAtClear(S_MOD + "_Waiting")
      _qFramework.HoverAtClear(S_MOD + "_Scene")
      _bSceneReadyToEnd = True

      ; Start sex between the NPC and the player.
      StartSex(_aCurrSceneAgressor, _qFramework.WasCallOutRecent(bAttention=False))
      ModifySceneStage(iDelta=1)
   ElseIf (3 == iStage)
      ; Stage 3: Engaged in Sex.
      DebugTrace("Scene 10 Stage 3: ()")

      ; Do nothing.  Just wait for the sex to end.
   ElseIf (4 == iStage)
      ; Stage 4: Sex Complete.
      DebugTrace("Scene 10 Stage 4: ()")

      ; Sex is complete.  End the scene.
      Return FAIL
   EndIf
   Return WARNING
EndFunction

; All ProcessScene...() functions follow the same return codes.
; SUCCESS: The scene progressed immediately and may be able to progress again.
; WARNING: The scene is taking a delayed action in order to progress.
; FAIL:    The scene has ended.
Int Function ProcessSceneForgeArmour(Int iStage, Actor aAgressor, Int iTimeout, \
                                     String szSceneName)
   ; Reset the scene timeout to let DFW know we are still monitoring progress.
   If (0 > _qFramework.SceneContinue(szSceneName, iTimeout))
      Return FAIL
   EndIf

   ; If the leash game ends for some reason, end this scene.
   If ((0 >= _iLeashGameDuration) && !_aLeashHolder)
      Return FAIL
   EndIf

   ; 11: Force the player to craft armour.
   ; Stage: 0: Start Scenario.  1: NPC arrived at slaver.  Playing Scene.  2: Scene Done.
   ;        3: Preparing the player.  4: Waiting to secure the player.  5: Secure the player.
   If (0 == iStage)
      ; Stage 0: Start Scenario.
      DebugTrace("Scene 11 Stage 0: ()")

      ; Stage Entry Code:
      If (_iLastSceneStage != iStage)
         ; Make sure we have furniture for the player to work at.
         If (!_oTransferFurniture)
            ; 0x0008: Work Furniture
            _oTransferFurniture = GetRandomFurniture(oRegion=_qFramework.GetCurrentRegion(), \
                                                     iIncludeFlags=0x2008)
            If (!_oTransferFurniture)
               Return FAIL
            EndIf
         EndIf

         ; 1: Leash the player to an object.
         _iSceneModule = 1

         ; Generic Form parameters:
         _aoSceneModuleParameter = New Form[1]

         ; Parameter 0: The object to move to.
         _aoSceneModuleParameter[0] = _oTransferFurniture
         Return SUCCESS
      EndIf

      ; If the player is now leashed to the transfer furniture continue the scene.
      If (_oTransferFurniture == _qFramework.GetLeashTarget())
         _oTransferFurniture = None
         ModifySceneStage(iDelta=1)
         Return SUCCESS
      Else
         Return FAIL
      EndIf
   ElseIf (1 == iStage)
      ; Stage 1: Leashed to the furniture.
      DebugTrace("Scene 11 Stage 1: ()")

      ; Figure out which set of equipment we are making.
      ; TODO: Search the Required Perk array.
      Perk oUpgradForgePerk = GetForgeUpgradePerk(_aLeashHolder, _oEquipForgePerk)
      Int iEquipmentSetIndex = -1
      If (oUpgradForgePerk == _oPerkSmithDragon)
         iEquipmentSetIndex = 7
         ; Dragon armour could have light or heavy armour.
         If (_aLeashHolder.GetActorValue("HeavyArmor") > \
            _aLeashHolder.GetActorValue("LightArmor"))
            iEquipmentSetIndex += 1
         EndIf
      ElseIf (oUpgradForgePerk == _oPerkSmithDaedric)
         iEquipmentSetIndex = 6
      ElseIf (oUpgradForgePerk == _oPerkSmithGlass)
         iEquipmentSetIndex = 5
      ElseIf (oUpgradForgePerk == _oPerkSmithEbony)
         iEquipmentSetIndex = 4
      ElseIf (oUpgradForgePerk == _oPerkSmithElven)
         iEquipmentSetIndex = 3
      ElseIf (oUpgradForgePerk == _oPerkSmithOrcish)
         iEquipmentSetIndex = 2
      ElseIf (oUpgradForgePerk == _oPerkSmithSteel)
         iEquipmentSetIndex = 0
         ; Steel could have light or heavy armour.
         If (_aLeashHolder.GetActorValue("HeavyArmor") > \
            _aLeashHolder.GetActorValue("LightArmor"))
            iEquipmentSetIndex += 1
         EndIf
      EndIf

      ; 19: Crafting Instructions.
      _iCurrDialogue = 19
      _iCurrDialoguePath = iEquipmentSetIndex
      _aCurrDialogueTarget = _aLeashHolder
Utility.Wait(0.1)
      StartConversation(_aLeashHolder, iTimeout=15)

      ; Make sure the player is gagged and not locked in an arm restraint.
      If (_qFramework.IsPlayerArmLocked())
         ; 22: zad_DeviousBondageMittens
         If (_aPlayer.WornHasKeyword(_aoZadDeviceKeyword[22]))
            UnequipBdsmItem(_aoMittens, _aoZadDeviceKeyword[22], _aLeashHolder)
         EndIf
         ; 5: zad_DeviousArmbinder
         If (_aPlayer.WornHasKeyword(_aoZadDeviceKeyword[5]))
            UnequipBdsmItem(_aoArmRestraints, _aoZadDeviceKeyword[5], _aLeashHolder)
         EndIf
         ; 8: zad_DeviousYoke
         If (_aPlayer.WornHasKeyword(_aoZadDeviceKeyword[8]))
            UnequipBdsmItem(_aoArmRestraints, _aoZadDeviceKeyword[8], _aLeashHolder)
         EndIf
      EndIf
      If (!_qFramework.IsPlayerGagged())
         ; 14: zad_DeviousGag
         EquipBdsmItem(_oGag, _aoZadDeviceKeyword[14], _aLeashHolder)
      EndIf

      ; Get the player the resources she needs to create all of the required items.
      GivePlayerCraftingItems(iEquipmentSetIndex, _aLeashHolder)

      ; Add a delay to ensure the player receives items before we start checking contraban.
      Utility.Wait(0.5)

      ; Make sure the actor doesn't have a default otufit so he will wear these items.
      ; TODO: I'm not sure reverting the contents is needed.
      _oLeashHolderOutfitContents.Revert()
      _aLeashHolder.SetOutfit(_oLeashHolderOutfit)
      _bLeashHolderOutfitActive = True

      ; Monitor the player's activity to ensure she doesn't craft any other items.
      ; 0x0001: Whip the player.
      ; 0x0002: Sternly warn the player.
      ; 0x0004: Force the player to stand.
      ; 0x8000: Take contraban.
      _iContrabanFlags = 0x8007

      ; 0x0001: Equip allowed items.
      ; 0x0002: Compliment the player.
      ; 0x0004: Force the player to stand.
      ; 0x8000: Take allowed items.
      _iAllowdItemsFlags = 0x8007

      _aContrabanMonitor = _aLeashHolder
      _aAliasPlayer.RemoveAllInventoryEventFilters()

      ModifySceneStage(iDelta=1)
   ElseIf (2 == iStage)
      ; Stage 2: Given Items.  Crafting.
      DebugTrace("Scene 11 Stage 2: (" + _aiAllowedItems.Length + ")")

      ; If the player has finished crafting all of her allowed items take them from her.
      If (!_aiAllowedItems.Length)
         ; Stop monitoring the player's behaviour and wrap up the scene.
         _aContrabanMonitor = None
         FormList lEmpty
         _aAliasPlayer.AddInventoryEventFilter(lEmpty)

         _qFramework.SetLeashLength(_qMcm.iLeashLength)
         _qFramework.SetLeashTarget(_aLeashHolder)
         _qFramework.HoverAtClear(S_MOD + "_ForgeArmour")

         ; Make sure the slaver locks the player back into her arm binder.
         _iAgendaMidTerm = 2

         _oEquipForgePerk = GetForgeUpgradePerk(_aLeashHolder, _oEquipForgePerk)

         Return FAIL
      EndIf
   EndIf
   Return WARNING
EndFunction

; All ProcessScene...() functions follow the same return codes.
; SUCCESS: The scene progressed immediately and may be able to progress again.
; WARNING: The scene is taking a delayed action in order to progress.
; FAIL:    The scene has ended.
Int Function ProcessSceneCraftPotions(Int iStage, Actor aAgressor, Int iTimeout, \
                                      String szSceneName)
   ; Reset the scene timeout to let DFW know we are still monitoring progress.
   If (0 > _qFramework.SceneContinue(szSceneName, iTimeout))
      Return FAIL
   EndIf

   ; If the leash game ends for some reason, end this scene.
   If ((0 >= _iLeashGameDuration) && !_aLeashHolder)
      Return FAIL
   EndIf

   ; 13: Force the player to craft healing potions.
   ; Stage: 0: Start Scenario.  1: NPC arrived at slaver.  Playing Scene.  2: Scene Done.
   ;        3: Preparing the player.  4: Waiting to secure the player.  5: Secure the player.
   If (0 == iStage)
      ; Stage 0: Start Scenario.
      DebugTrace("Scene 13 Stage 0: ()")

      ; Stage Entry Code:
      If (_iLastSceneStage != iStage)
         ; Make sure we have furniture for the player to work at.
         If (!_oTransferFurniture)
            ; 0x0008: Work Furniture
            ; 0x8000: Alchemy Table
            _oTransferFurniture = GetRandomFurniture(oRegion=_qFramework.GetCurrentRegion(), \
                                                     iIncludeFlags=0x8008)
            If (!_oTransferFurniture)
               Return FAIL
            EndIf
         EndIf

         ; 1: Leash the player to an object.
         _iSceneModule = 1

         ; Generic Form parameters:
         _aoSceneModuleParameter = New Form[1]

         ; Parameter 0: The object to move to.
         _aoSceneModuleParameter[0] = _oTransferFurniture
         Return SUCCESS
      EndIf

      ; If the player is now leashed to the transfer furniture continue the scene.
      If (_oTransferFurniture == _qFramework.GetLeashTarget())
         _oTransferFurniture = None
         ModifySceneStage(iDelta=1)
         Return SUCCESS
      Else
         Return FAIL
      EndIf
   ElseIf (1 == iStage)
      ; Stage 1: Leashed to the furniture.
      DebugTrace("Scene 13 Stage 1: ()")

      ; Figure out which set of equipment we are making.
      Int iEquipmentSetIndex = 9

      ; 19: Crafting Instructions.
      _iCurrDialogue = 19
      _iCurrDialoguePath = iEquipmentSetIndex
      _aCurrDialogueTarget = _aLeashHolder
Utility.Wait(0.1)
      StartConversation(_aLeashHolder, iTimeout=15)

      ; Make sure the player is gagged and not locked in an arm restraint.
      If (_qFramework.IsPlayerArmLocked())
         ; 22: zad_DeviousBondageMittens
         If (_aPlayer.WornHasKeyword(_aoZadDeviceKeyword[22]))
            UnequipBdsmItem(_aoMittens, _aoZadDeviceKeyword[22], _aLeashHolder)
         EndIf
         ; 5: zad_DeviousArmbinder
         If (_aPlayer.WornHasKeyword(_aoZadDeviceKeyword[5]))
            UnequipBdsmItem(_aoArmRestraints, _aoZadDeviceKeyword[5], _aLeashHolder)
         EndIf
         ; 8: zad_DeviousYoke
         If (_aPlayer.WornHasKeyword(_aoZadDeviceKeyword[8]))
            UnequipBdsmItem(_aoArmRestraints, _aoZadDeviceKeyword[8], _aLeashHolder)
         EndIf
      EndIf
      If (!_qFramework.IsPlayerGagged())
         ; 14: zad_DeviousGag
         EquipBdsmItem(_oGag, _aoZadDeviceKeyword[14], _aLeashHolder)
      EndIf

      ; Get the player the resources she needs to create all of the required items.
      GivePlayerCraftingItems(iEquipmentSetIndex, _aLeashHolder, iNumItems=50)

      ; Add a delay to ensure the player receives items before we start checking contraban.
      Utility.Wait(0.5)

      ; Monitor the player's activity to ensure she doesn't craft any other items.
      ; 0x0001: Whip the player.
      ; 0x0002: Sternly warn the player.
      ; 0x0004: Force the player to stand.
      ; 0x8000: Take contraban.
      _iContrabanFlags = 0x8007

      ; 0x0004: Force the player to stand.
      ; 0x8000: Take allowed items.
      _iAllowdItemsFlags = 0x8004

      _aContrabanMonitor = _aLeashHolder
      _aAliasPlayer.RemoveAllInventoryEventFilters()

      ModifySceneStage(iDelta=1)
   ElseIf (2 == iStage)
      ; Stage 2: Given Items.  Crafting.
      DebugTrace("Scene 13 Stage 2: (" + _aiAllowedItems.Length + ")")

      ; If the player has finished crafting all of her allowed items take them from her.
      If (!_aiAllowedItems.Length)
         ; Stop monitoring the player's behaviour and wrap up the scene.
         _aContrabanMonitor = None
         FormList lEmpty
         _aAliasPlayer.AddInventoryEventFilter(lEmpty)

         _qFramework.SetLeashLength(_qMcm.iLeashLength)
         _qFramework.SetLeashTarget(_aLeashHolder)
         _qFramework.HoverAtClear(S_MOD + "_CraftPotions")

         ; Make sure the slaver locks the player back into her arm binder.
         _iAgendaMidTerm = 2

         _iEquipPotionLevel = GetPlayerLevelAlchemy(_iEquipPotionLevel)

         Return FAIL
      EndIf
   EndIf
   Return WARNING
EndFunction

; TODO: We really need a better mechanism to identify "leash holder activities".
Bool Function IsLeashHolderBusy()
   ; If there is no goal there is likely no imminent leash holder activity.
   If (0 >= _iAgendaShortTerm)
      Return False
   EndIf

   ; Goals 12 through 14 are conversation goals which aren't considered busy.
   If ((12 <= _iAgendaShortTerm) && (14 >= _iAgendaShortTerm))
      Return False
   EndIf

   ; Otherwise the leash holder goal is set.  Consider the leash game busy.
   Return True
EndFunction

Function StopLeashGame(Bool bClearMaster=True, Bool bReturnItems=False, Bool bUnequip=False)
   DebugTrace("TraceEvent StopLeashGame")
   If (bReturnItems)
      ReturnItems(_aLeashHolder)
   EndIf

   If (bUnequip)
      ;  2: zad_DeviousCollar      5: zad_DeviousArmbinder  14: zad_DeviousGa
      ; 18: zad_DeviousBlindfold  19; zad_DeviousBoots      22: zad_DeviousBondageMittens
      UnequipBdsmItem(_aoCollars,       _aoZadDeviceKeyword[2],  _aLeashHolder)
      UnequipBdsmItem(_aoArmRestraints, _aoZadDeviceKeyword[5],  _aLeashHolder)
      UnequipBdsmItem(_aoGags,          _aoZadDeviceKeyword[14], _aLeashHolder)
      UnequipBdsmItem(_aoBlindfolds,    _aoZadDeviceKeyword[18], _aLeashHolder)
      UnequipBdsmItem(_aoLegRestraints, _aoZadDeviceKeyword[19], _aLeashHolder)
      UnequipBdsmItem(_aoMittens,       _aoZadDeviceKeyword[22], _aLeashHolder)
   EndIf

   ; If the leash holder's movement has been stopped for any reason restore it.
   If (_bLeashHolderStopped)
      _bLeashHolderStopped = False
      _qFramework.HoverAtClear(S_MOD + "_WatchSex")
   EndIf

   _qFramework.RestoreHealthRegen()
   _qFramework.DisableMagicka(False)
   _qFramework.SetLeashTarget(None)

   If (bClearMaster)
      _qFramework.ClearMaster(_aLeashHolder)
   EndIf

   _aAliasLastLeashHolder.ForceRefTo(_aLeashHolder)
   _iAgendaShortTerm = 0
   _iAgendaMidTerm = 0
   _iAgendaLongTerm = 0
   _iDetailsLongTerm = 0
   _iLeashGameDuration = 0

   ; Clear the punishment furniture in case the leash game ends during a punishment.
   _oPunishmentFurniture = None
   _oTransferFurniture = None

   ; Setup the variables to control the leash game re-start cooldown.
   _iLeashGameReduction = _qMcm.iLeashCoolDownAmount
   If (_iLeashGameReduction)
      _fLeashCoolDownStart = Utility.GetCurrentGameTime()
      _fLeashCoolDownTotal = ((_qMcm.iLeashCoolDownTime As Float) / 24.0)
   EndIf

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
   DebugTrace("TraceEvent StopLeashGame: Done")
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

Function ImmobilizePlayer(Int iTimeoutPollCount=20)
   If (0 >= _iMovementSafety)
      _iMovementSafety = iTimeoutPollCount
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
                       Bool bStrip=False,          Bool bAddArmBinder=False, \
                       String szExpectedScene="")
   DebugTrace("TraceEvent AssaultPlayer")
   ; If we are already in the middle of an animated assault ignore this request.
   String szCurrScene = _qFramework.GetCurrentScene()
   If (szCurrScene && (szExpectedScene != szCurrScene))
      DebugTrace("TraceEvent AssaultPlayer: Done (Scene Busy)")
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
         _qFramework.YankLeash(fDamageMultiplier, _qFramework.LS_DRAG, bForceDamage=True)
      EndIf

      ; If a health threshold is specified and the player is not below it, nothing more to do.
      If (1 != fHealthThreshold)
         If (fHealthThreshold < _aPlayer.GetActorValuePercentage("Health"))
            DebugTrace("TraceEvent AssaultPlayer: Done (Player Resisting)")
            Return
         EndIf
      EndIf
   EndIf

   If (bUnquipWeapons || bStealWeapons)
      Log(GetDisplayName(_aLeashHolder) + " wrestles your weapons from you.", DL_CRIT, S_MOD)
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
      ; 0x0004: Bind Arms (implies Unbind Mittens)
      _iAssault = Math.LogicalOr(0x0004, _iAssault)
   EndIf

   ; Play an animation for the slaver to approach the player.
   ; The assault will happen on the done event (OnSlaveActionDone).
   If (_iAssault || _iAssaultTakeGold)
      PlayApproachAnimation(_aLeashHolder, "Assault", szExpectedScene)
   EndIf
   DebugTrace("TraceEvent AssaultPlayer: Done")
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
   DebugTrace("TraceEvent SearchInventory")
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

   ; Try to find appropriate bondage mittens in the player's inventory.
   If (!_oMittens)
      Int iIndex = _aoMittens.Length - 1
      Armor oItemFound
      While (!_oMittens && (0 <= iIndex))
         If (_aPlayer.GetItemCount(_aoMittens[iIndex]))
            oItemFound = _aoMittens[iIndex]
            If (IsWorn(oItemFound))
               _oMittens = oItemFound
            EndIf
         EndIf
         iIndex -= 1
      EndWhile
      If (!_oMittens && oItemFound)
         _oMittens = oItemFound
      EndIf
   EndIf

   DebugTrace("TraceEvent SearchInventory: Done")
EndFunction

; This assumes the player's inventory has already been searched with SearchInventory().
Function FindGag(Actor aNpc)
   Float fCurrRealTime = Utility.GetCurrentRealTime()
   DebugTrace("TraceEvent FindGag - " + fCurrRealTime)
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
   DebugTrace("TraceEvent FindGag: Done - " + (Utility.GetCurrentRealTime() - fCurrRealTime))
EndFunction

; This assumes the player's inventory has already been searched with SearchInventory().
Function FindArmRestraint(Actor aNpc)
   Float fCurrRealTime = Utility.GetCurrentRealTime()
   DebugTrace("TraceEvent FindArmRestraint - " + fCurrRealTime)
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
   DebugTrace("TraceEvent FindArmRestraint: Done - " + (Utility.GetCurrentRealTime() - \
                                                        fCurrRealTime))
EndFunction

; This assumes the player's inventory has already been searched with SearchInventory().
Function FindLegRestraint(Actor aNpc)
   Float fCurrRealTime = Utility.GetCurrentRealTime()
   DebugTrace("TraceEvent FindLegRestraint - " + fCurrRealTime)
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
   DebugTrace("TraceEvent FindLegRestraint: Done - " + (Utility.GetCurrentRealTime() - \
                                                        fCurrRealTime))
EndFunction

; This assumes the player's inventory has already been searched with SearchInventory().
Function FindCollar(Actor aNpc)
   Float fCurrRealTime = Utility.GetCurrentRealTime()
   DebugTrace("TraceEvent FindCollar - " + fCurrRealTime)
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
   DebugTrace("TraceEvent FindCollar: Done - " + (Utility.GetCurrentRealTime() - fCurrRealTime))
EndFunction

; This assumes the player's inventory has already been searched with SearchInventory().
Function FindBlindfold(Actor aNpc)
   Float fCurrRealTime = Utility.GetCurrentRealTime()
   DebugTrace("TraceEvent FindBlindfold - " + fCurrRealTime)
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
   DebugTrace("TraceEvent FindBlindfold: Done - " + (Utility.GetCurrentRealTime() - \
                                                     fCurrRealTime))
EndFunction

; This assumes the player's inventory has already been searched with SearchInventory().
Function FindMittens(Actor aNpc)
   Float fCurrRealTime = Utility.GetCurrentRealTime()
   DebugTrace("TraceEvent FindMittens - " + fCurrRealTime)
   If (!_oMittens)
      Int iIndex = _aoMittens.Length - 1
      While (0 <= iIndex)
         If (aNpc.GetItemCount(_aoMittens[iIndex]))
            _oMittens = _aoMittens[iIndex]
            Return
         EndIf
         iIndex -= 1
      EndWhile
      _oMittens = _aoMittens[Utility.RandomInt(0, _aoMittens.Length - 1)]
   EndIf
   DebugTrace("TraceEvent FindMittens: Done - " + (Utility.GetCurrentRealTime() - \
                                                   fCurrRealTime))
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
   Log(GetDisplayName(aNpc) + " returns your things.", DL_CRIT, S_MOD)
   Int iIndex = _aoItemStolen.Length - 1
   While (0 <= iIndex)
      aNpc.RemoveItem(_aoItemStolen[iIndex], 999, akOtherContainer=_aPlayer)
      iIndex -=1
   EndWhile
   _aoItemStolen = None
   _iWeaponsStolen = 0
EndFunction

; Identifies the furniture the player has just been locked into.
; Note: This shouldn't be called if the player hasn't officially been released.
Function SetCurrFurniture(ObjectReference oCurrFurniture, Bool bLocked=False, \
                          Actor aLocker=None, Bool bClearTransfer=True)
   DebugTrace("TraceEvent SetCurrFurniture")

   ; Keep track of the player's new furniture.
   _oBdsmFurniture = oCurrFurniture

   ; If we were transferring the player to new furniture, clear a record of that now.
   If (bClearTransfer)
      _oTransferFurniture = None
   EndIf

   ; Set default values for other characteristics.
   _bIsPlayerCaged = False
   _bIsPlayerRemote = False
   _bFurnitureForFun = False

   ; If someone is responsible for locking the furniture make sure to keept rack of him.
   If (aLocker && oCurrFurniture)
      _aAliasFurnitureLocker.ForceRefTo(aLocker)
   EndIf

   ; If we don't know about the new furniture don't process anything else.
   If (MutexLock(_iFavouriteFurnitureMutex))
      Int iIndex = _aoFavouriteFurniture.Find(oCurrFurniture)
      If (!oCurrFurniture || (-1 == iIndex))
         _aAliasFurnitureLocker.Clear()
      Else
         ; 0x0002: Cage
         _bIsPlayerCaged   = Math.LogicalAnd(0x0002, _aiFavouriteFlags[iIndex])
         ; 0x0080: Remote
         _bIsPlayerRemote  = Math.LogicalAnd(0x0080, _aiFavouriteFlags[iIndex])
         _bFurnitureForFun = (bLocked && !_oPunishmentFurniture)
      EndIf

      MutexRelease(_iFavouriteFurnitureMutex)
   EndIf
   DebugTrace("TraceEvent SetCurrFurniture: Done")
EndFunction

Int Function StartWhippingScene(Actor aActor, Int iDuration, String szMessage, \
                                String szCurrScene="")
   Int iReturnCode
   If (szCurrScene)
      iReturnCode = _qFramework.SceneContinue(szCurrScene, iDuration + 30)
   Else
      iReturnCode = _qFramework.SceneStarting(szMessage, iDuration + 30)
   EndIf
   If (0 <= iReturnCode)
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

; Returns any new items: 0x01: Collar     0x02: Gag  0x04: Arm Locked      0x08: Hobble
;                        0x10: Blindfold  0x20: Belt 0x40: Bondage Mittens
Int Function FinalizeAssault(Actor aNpc, String szName)
   DebugTrace("TraceEvent FinalizeAssault: 0x" + _qDfwUtil.ConvertHexToString(_iAssault, 8))

   ; Keep a local copy of _iAssault so we don't need to worry about concurrent data access.
   Int iAssault = _iAssault
   _iAssault = 0x0000

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
   If (0x40000000 <= iAssault)
      iAssault -= 0x40000000

      bPeaceful = True
   EndIf

   ; 0x00020000: Release from Bondage Mittens
   If (0x00020000 <= iAssault)
      iAssault -= 0x00020000

      ; 22: zad_DeviousBondageMittens
      UnequipBdsmItem(_aoMittens, _aoZadDeviceKeyword[22], aNpc)
   EndIf

   ; 0x00010000: Restrain in Bondage Mittens (implies Unbind Arms)
   If (0x00010000 <= iAssault)
      iAssault -= 0x00010000

      ; If the player's arms are already bound make sure they get unbound.
      ; 0x0020 = Unbind Arms
      If (_qFramework.IsPlayerArmLocked() && !Math.LogicalAnd(0x0020, iAssault))
         iAssault += 0x0020
      EndIf

      FindMittens(aNpc)
      ; 22: zad_DeviousBondageMittens
      EquipBdsmItem(_oMittens, _aoZadDeviceKeyword[22], aNpc)
      iNewItems += 0x40
   EndIf

   ; 0x8000: Unbind Boots
   If (0x8000 <= iAssault)
      iAssault -= 0x8000

      ; 19; zad_DeviousBoots
      UnequipBdsmItem(_aoLegRestraints, _aoZadDeviceKeyword[19], aNpc)
   EndIf

   ; 0x4000: Restrain in Boots
   If (0x4000 <= iAssault)
      iAssault -= 0x4000

      FindLegRestraint(aNpc)
      ; 19; zad_DeviousBoots
      EquipBdsmItem(_oLegRestraint, _aoZadDeviceKeyword[19], aNpc)
      iNewItems += 0x08
   EndIf

   ; 0x2000 = Make sure the Gag is secure
   If (0x2000 <= iAssault)
      iAssault -= 0x2000

      bSecureGag = True
      If (_qFramework.IsPlayerGagged())
         Log(szName + " tightens your gag making it very effective and uncomfortable.", \
             DL_CRIT, S_MOD)
         _qFramework.SetStrictGag()
      Else
         ; If the player is not already gagged make sure it happens further down.
         bSecureGag = True
      EndIf
   EndIf

   ; 0x1000 = Restore Leash Length
   If (0x1000 <= iAssault)
      iAssault -= 0x1000

      _qFramework.SetLeashLength(_qMcm.iLeashLength)
   EndIf

   ; 0x0800 = Release Blindfold
   If (0x0800 <= iAssault)
      iAssault -= 0x0800

      bReleaseBlindfold = True
   EndIf

   ; 0x0400 = Blindfold
   If (0x0400 <= iAssault)
      iAssault -= 0x0400

      If (bPeaceful)
         Log(szName + " secures a blindfold over your eyes.", DL_CRIT, S_MOD)
      Else
         Log(szName + " pulls you to the ground and locks you in a blindfold.", DL_CRIT, S_MOD)
      EndIf
      FindBlindfold(aNpc)
      ; 18: zad_DeviousBlindfold
      EquipBdsmItem(_oBlindfold, _aoZadDeviceKeyword[18], aNpc)
      iNewItems += 0x10
   EndIf

   ; 0x0200 = Restrain in Collar
   If (0x0200 <= iAssault)
      iAssault -= 0x0200

      FindCollar(aNpc)
      ; 2: zad_DeviousCollar
      EquipBdsmItem(_oCollar, _aoZadDeviceKeyword[2], aNpc)
      iNewItems += 0x01
   EndIf

   ; 0x0100 = UnGag
   If (0x0100 <= iAssault)
      iAssault -= 0x0100

      ; Unequip the player's gag.
      ; 14: zad_DeviousGag
      UnequipBdsmItem(_aoGags, _aoZadDeviceKeyword[14], aNpc)
      _bPlayerUngagged = True
      _iGagRemaining = 0
   EndIf

   ; 0x0080 = Add Additional Restraint
   If (0x0080 <= iAssault)
      iAssault -= 0x0080

      ; Create a list of items that can be added so we can randomize which one is added.
      Int[] aiOptions
; Returns any new items: 0x01: Collar     0x02: Gag  0x04: Arm Locked      0x08: Hobble
;                        0x10: Blindfold  0x20: Belt 0x40: Bondage Mittens

      If (_iMcmGagMode && !_qFramework.IsPlayerGagged() && !Math.LogicalAnd(0x02, iNewItems))
         aiOptions = _qDfwUtil.AddIntToArray(aiOptions, 1)
      EndIf
      If (!_bFurnitureForFun && !_qFramework.IsPlayerArmLocked() && \
          !Math.LogicalAnd(0x04, iNewItems))
         aiOptions = _qDfwUtil.AddIntToArray(aiOptions, 2)
      EndIf
      If (!_qFramework.IsPlayerHobbled() && !Math.LogicalAnd(0x08, iNewItems))
         aiOptions = _qDfwUtil.AddIntToArray(aiOptions, 3)
      EndIf
      If (!_qFramework.IsPlayerCollared() && !Math.LogicalAnd(0x01, iNewItems))
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
            ; 14: zad_DeviousGag
            oKeyword = _aoZadDeviceKeyword[14]
            iItem = 0x02
            _bPlayerUngagged = False
         ElseIf (2 == iOption)
            FindArmRestraint(aNpc)
            oRestraint = _oArmRestraint
            ; 5: zad_DeviousArmbinder
            oKeyword = _aoZadDeviceKeyword[5]
            iItem = 0x04
         ElseIf (3 == iOption)
            FindLegRestraint(aNpc)
            oRestraint = _oLegRestraint
            ; 19; zad_DeviousBoots
            oKeyword = _aoZadDeviceKeyword[19]
            iItem = 0x08
         ElseIf (4 == iOption)
            FindCollar(aNpc)
            oRestraint = _oCollar
            ; 2: zad_DeviousCollar
            oKeyword = _aoZadDeviceKeyword[2]
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
               _iAgendaLongTerm = 3
               _iDetailsLongTerm = 0
               _fTimeLastPunished = 0.0
               _iGagRemaining += (((60 + (120 * iBehaviour)) / _fMcmPollTime) As Int)
            EndIf
         EndIf
      EndIf
   EndIf

   ; 0x0040 = Strip Fully
   If (0x0040 <= iAssault)
      iAssault -= 0x0040

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
   EndIf

   ; 0x0020 = Unbind Arms
   If (0x0020 <= iAssault)
      iAssault -= 0x0020

      bUnlockArms = True
   EndIf

   ; 0x0010 = Return All Items
   If (0x0010 <= iAssault)
      iAssault -= 0x0010

      bReturnItems = True
   EndIf

   ; 0x0008 = Take All Weapons
   If (0x0008 <= iAssault)
      iAssault -= 0x0008

      ; Search the inventory for any weapons and move them to the leash holder.
      ; Todo: Quest items taken this way should be made available at a new "Quest Item Vendor".
      Int iIndex = _aPlayer.GetNumItems() - 1
      While (0 <= iIndex)
         ; Check the item is an inventory item, is equipped and has the right keyword.
         Form oInventoryItem = _aPlayer.GetNthForm(iIndex)
         ; 41 (kWeapon)
         If (41 == oInventoryItem.GetType())
            _aPlayer.RemoveItem(oInventoryItem, 999, akOtherContainer=aNpc)
            _aoItemStolen = _qDfwUtil.AddFormToArray(_aoItemStolen, oInventoryItem)
         EndIf
         iIndex -= 1
      EndWhile
      _iWeaponsStolen = 2
   EndIf

   ; 0x0004: Bind Arms (implies Unbind Mittens)
   If (0x0004 <= iAssault)
      iAssault -= 0x0004

      ; If the player is wearing bondage mittens make sure to remove them first.
      ; 22: zad_DeviousBondageMittens
      If (_aPlayer.WornHasKeyword(_aoZadDeviceKeyword[22]))
         UnequipBdsmItem(_aoMittens, _aoZadDeviceKeyword[22], aNpc)
      EndIf

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

         ; 5: zad_DeviousArmbinder
         EquipBdsmItem(_oArmRestraint, _aoZadDeviceKeyword[5], aNpc)
         iNewItems += 0x04
      EndIf
   EndIf

   ; 0x0002 = Gag
   If ((0x0002 <= iAssault) || bSecureGag)
      If (0x0002 <= iAssault)
         iAssault -= 0x0002
      EndIf

      If (!_qFramework.IsPlayerGagged())
         If (bPeaceful)
            Log(szName + " slips a gag into your mouth and locks it in place.", DL_CRIT, S_MOD)
         Else
            Log(szName + " pulls you to the ground and forces a gag into your mouth.", \
                DL_CRIT, S_MOD)
         EndIf

         FindGag(aNpc)
         ; 14: zad_DeviousGag
         EquipBdsmItem(_oGag, _aoZadDeviceKeyword[14], aNpc)
         iNewItems += 0x02

         ; If gag mode is Auto Remove start a timer.
         If (2 == _iMcmGagMode)
            Int iBehaviour = _iBadBehaviour
            If (50 < _qFramework.GetActorAnger(aNpc))
               iBehaviour += 3
            EndIf
            _iAgendaLongTerm = 3
            _iDetailsLongTerm = 0
            _fTimeLastPunished = 0.0
            _iGagRemaining += (((60 + (120 * iBehaviour)) / _fMcmPollTime) As Int)
         EndIf

         _bPlayerUngagged = False
         If (bSecureGag)
            _qFramework.SetStrictGag()
         EndIf
      EndIf
   EndIf

   ; 0x0001 = Strip
   If (0x0001 <= iAssault)
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
      iAssault -= 0x0001
   EndIf

   If (bReturnItems)
      Actor aLastLeashHolder = (_aAliasLastLeashHolder.GetReference() As Actor)
      ReturnItems(aLastLeashHolder)
   EndIf

   If (bReleaseBlindfold)
      ; Unequip the player's blindfold.
      ; 18: zad_DeviousBlindfold
      UnequipBdsmItem(_aoBlindfolds, _aoZadDeviceKeyword[18], aNpc)
   EndIf

   If (bUnlockArms)
      ; 5: zad_DeviousArmbinder
      UnequipBdsmItem(_aoArmRestraints, _aoZadDeviceKeyword[5], aNpc)
      _bFullyRestrained = False
      _bIsCompleteSlave = False
   EndIf
   DebugTrace("TraceEvent FinalizeAssault: Done")
   Return iNewItems
EndFunction

Function StartConversation(Actor aActor, Int iGoal=-1, Int iRefusalCount=-1, \
                           Int iTimeout=20, Bool bInterruptPlayer=False)
   DebugTrace("TraceEvent StartConversation (" + iGoal + "," + _iCurrDialogue + "," + \
              _iCurrDialogueStage + ")")

   ; Teleport the leash holder to interrupt his current package.  For normal
   ; conversations the package is interrupted when the player clicks on (activates)
   ; the actor.  Activating the actor via the Activate() function seems to be
   ; different so we need to interrupt the package manually.
   ; This doesn't appear to be necessary anymore.  I don't know why.
;   aActor.MoveTo(aActor)

   ; Activating the actor causes dialogue problems.
   ; Make sure there is no conversation.
   ; This also resets the player's camera so let's not use it unless it is necessary.
   ; This also prevents the player from engaging in dialogue for a short time.  Needs a delay.
DebugTrace("StartConversation Checkpoint 1")
   If (bInterruptPlayer)
      _qFramework.MovePlayer(_aPlayer)

      ; This MoveTo() prevents the player from engaging in coversation for a short time.
      ; Add a delay to account for that.
      Utility.Wait(0.5)
   EndIf
DebugTrace("StartConversation Checkpoint 2")

   ; Setup the conversation topic variable used by the player dialogue.
   If (-1 != iGoal)
      _iAgendaShortTerm = iGoal
      ; If this is a new conversation we should reset the refusal count.
      If (-1 == iRefusalCount)
         _iLeashGoalRefusalCount = 0
      EndIf
   EndIf
DebugTrace("StartConversation Checkpoint 3")

   ; If the refusal count is specified set it here.
   If (-1 != iRefusalCount)
      _iLeashGoalRefusalCount = iRefusalCount
   EndIf
   If (7 == _iAgendaShortTerm)
      _iLeashGoalRefusalCount = _iTotalWalkInFrontCount
   EndIf
DebugTrace("StartConversation Checkpoint 4")

   ; Wait for any leash yanking to complete before starting the conversation.
   _qFramework.YankLeashWait(500)
DebugTrace("StartConversation Checkpoint 5")

   ; Don't try to talk to the actor while he is in the process of sitting or standing.
   ActorSitStateWait(aActor)
DebugTrace("StartConversation Checkpoint 6")

   ; Set a timeout in case the dialogue doesn't happen.
   _aDialogueTarget = aActor
   _iDialogueBusy = iTimeout
   If (iGoal)
      If ((3 == iGoal) || (5 == iGoal) || (7 == iGoal) || (8 == iGoal) || (9 == iGoal))
         ; For One Liners (comments the player can't respond to) set a shorter timeout.
         _iDialogueBusy = 3
      EndIf
   EndIf
DebugTrace("StartConversation Checkpoint 7")
   If (MutexLock(_iCurrSceneMutex))
      If (_iCurrScene)
         ; TODO: Something is wrong here.  These conditions can't both be true:
         If (1 == _iCurrScene)
            If (0 == _iCurrScene)
               ; For One Liners (comments the player can't respond to) set a shorter timeout.
               _iDialogueBusy = 5
            EndIf
         EndIf
      EndIf

      MutexRelease(_iCurrSceneMutex)
   EndIf
DebugTrace("StartConversation Checkpoint 8")

   ; Prepare the actor for DFW dialogue to ensure DFW conditions are available.
   _qFramework.PrepareActorDialogue(aActor)

   ; If the leash holder's movement has been stopped for any reason restore it.
DebugTrace("StartConversation Checkpoint 9")
   If (_bLeashHolderStopped)
      _bLeashHolderStopped = False
      _qFramework.HoverAtClear(S_MOD + "_WatchSex")
   EndIf

   ; Have the actor speak with the player.
DebugTrace("StartConversation Checkpoint 10")
   aActor.Activate(_aPlayer)
   DebugTrace("TraceEvent StartConversation: Done")
EndFunction

; iTimeout is in seconds.
Function WaitForConversation(Actor aNpc, Int iTimeout=30)
   ; Make sure the conversation actually starts.
   Float fSecurity = 30
   While ((0 < fSecurity) && !aNpc.IsInDialogueWithPlayer() && \
          (_aPlayer != aNpc.GetDialogueTarget()))
      Utility.Wait(0.05)
      fSecurity -= 0.05
   EndWhile

   ; If we timed out waiting for the conversation return.
   If (0 >= fSecurity)
      Int iScene
      Int iStage
      If (MutexLock(_iCurrSceneMutex))
         iScene = _iCurrScene
         iStage = _iCurrSceneStage

         MutexRelease(_iCurrSceneMutex)
      EndIf
      Log("Conversation Never Started: (" + iScene + "," + iStage + ")", DL_DEBUG, S_MOD)
      Return
   EndIf

   fSecurity = iTimeout
   While ((0 < fSecurity) && (aNpc.IsInDialogueWithPlayer() || aNpc.GetDialogueTarget()))
      Utility.Wait(0.05)
      fSecurity -= 0.05
   EndWhile
EndFunction

Function CheckStartLeashGame(Int iVulnerability)
   DebugTrace("TraceEvent CheckStartLeashGame")
   ; Don't start the leash game if we are shutting down the mod.
   If (_bMcmShutdownMod)
      DebugTrace("TraceEvent CheckStartLeashGame: Done (Shutdown)")
      Return
   EndIf

   ; Only play the leash game if the player does not have a current close Master and she is not
   ; otherwise unavailable.
   If (!_qFramework.GetMaster(_qFramework.MD_CLOSE) && \
       _qFramework.IsAllowed(_qFramework.AP_ENSLAVE) && \
       !_qFramework.IsPlayerCriticallyBusy() && \
       (!_qFramework.GetCurrentScene()))
      ; Identify the chance the leash game will start.
      Float fMaxChance = _fMcmLeashGameChance
      If (_iMcmIncreaseWhenVulnerable)
         fMaxChance += ((_iMcmIncreaseWhenVulnerable As Float) * iVulnerability / 100)
      EndIf

      ; Account for any cool down from the last leash game.
      Float fCoolDown = 0.0
      If (0 < _iLeashGameReduction)
         fCoolDown = (_iLeashGameReduction As Float) * \
                      (1.0 - ((Utility.GetCurrentGameTime() - _fLeashCoolDownStart) / \
                              _fLeashCoolDownTotal))
         If (0.0 >= fCoolDown)
            _iLeashGameReduction = 0
            fCoolDown = 0.0
         EndIf
      EndIf

      Float fRoll = Utility.RandomFloat(0, 100)
      Log("Leash Game Roll: " + fRoll + " / (" + fMaxChance + "-" + fCoolDown + ")", DL_TRACE, \
          S_MOD)
      If ((fMaxChance - fCoolDown) > fRoll)
         ; Find an actor to use as the Master in the leash game.
         Int iActorFlags = _qFramework.AF_SLAVE_TRADER
         If (_bMcmIncludeOwners)
            iActorFlags = Math.LogicalOr(_qFramework.AF_OWNER, iActorFlags)
         EndIf
         Actor aRandomActor = _qFramework.GetRandomActor(_iMcmMaxDistance, iActorFlags)

         If (aRandomActor)
            String szName = GetDisplayName(aRandomActor)

            ; If the player is in BDSM furniture but not locked.  Lock it first.
            If (_qFramework.GetBdsmFurniture())
               _qFramework.SetBdsmFurnitureLocked()
               ;    DisablePlayerControls(Move,  Fight, Cam,   Look,  Sneak, Menu,  Active, Journ)
               Game.DisablePlayerControls(True,  False, False, False, False, False, True,   False)
;Off-DebugTrace("CheckStartLeashGame: Movement Disabled - Leash from Furniture")
               ImmobilizePlayer()
               _aAliasFurnitureLocker.ForceRefTo(aRandomActor)
               _bFurnitureForFun = False
               _bIsPlayerCaged = False
               _fFurnitureReleaseTime = 0
               ReleaseFromFurniture(aRandomActor)
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
   DebugTrace("TraceEvent CheckStartLeashGame: Done")
EndFunction

Function PlayLeashGame()
   ; Keep track of the furniture the player is in, if any.
   ObjectReference oCurrFurniture = _qFramework.GetBdsmFurniture()

   DebugTrace("TraceEvent PlayLeashGame: (LH:" + _aLeashHolder + \
                                        ",FR:" + oCurrFurniture + \
                                        ",CB:" + _bIsInCombat + \
                                        ",DL:" + _iDialogueBusy + \
                                        ",DU:" + _iLeashGameDuration + \
                                        ",PU:" + _oPunishmentFurniture + \
                                        ",AG:" + _iAgendaShortTerm + "-" + \
                                                 _iAgendaMidTerm + "-" + \
                                                 _iAgendaLongTerm + "-" + \
                                                  _iDetailsLongTerm + \
                                        ",VA:" + _iVerbalAnnoyance + \
                                        ",RL:" + _bReleaseBlindfold + "-" + _bReleaseGag + \
                                        ",CO:" + _bIsCompleteSlave + \
                                        ",WS:" + _iWeaponsStolen + ")")

   ; The leash holder's anger is used in a number of situation.  Create a variable for it here.
   Int iAnger

   ; Make sure the player is not not too far away from the leash holder.
   Float fDistance = _aLeashHolder.GetDistance(_aPlayer)
   If ((1500 < fDistance) && !oCurrFurniture && !_bIsPlayerCaged)
      ; If the player is in a Sex scene, let it finish before evaluating the situation.
      If (_qSexLab.IsActorActive(_aPlayer))
         Return
      EndIf

      ; If the player is too far from the leash target and they are in a scene, this is most
      ; likely a post bleedout event so stop the leash game.
      If (_qFramework.IsPlayerCriticallyBusy(False))
         ; The player may also be in a local sex scene.
         ; Don't abandon the game unless they're really far.
         If (!_aLeashHolder.IsNearPlayer() && (10000 < fDistance))
            StopLeashGame()
            Return
         EndIf
      EndIf
   EndIf

   ; Handle the case of the slaver being deceased.
   If (_aLeashHolder.IsDead())
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
      _iDialogueBusy -= 1

      If (0 == _iDialogueBusy)
         _aDialogueTarget = None
         ; For pure conversation goals, end them when the dialogue times out.
         If ((12 <= _iAgendaShortTerm) && (14 >= _iAgendaShortTerm))
            _iAgendaShortTerm = 0
         EndIf
      EndIf

      ; If this is a conversation with the leash holder don't try to process the leash game.
      If (_aLeashHolder == _aDialogueTarget)
         Return
      EndIf
   EndIf

   ; Don't do processing during one of our scenes.
   String szCurrScene = _qFramework.GetCurrentScene()
   If (S_MOD == StringUtil.Substring(szCurrScene, 0, 4))
      ; If we are in the process of transferring the player (i.e. at the termination of the
      ; leash game) continue the scene.
      ; TODO: These scenes should reall be setup as proper scenes that would continue the
      ; scenes automatically.
      If (4 == _iAgendaLongTerm)
         _qFramework.SceneContinue(szCurrScene, 60)
      EndIf
      Return
   EndIf

   ; If the leash game is ending check that the slaver is willing to release the player.
   If (0 >= _iLeashGameDuration)
      Log("Leash Game Duration Up.", DL_DEBUG, S_MOD)

      ; Only consider stopping the leash game if nothing else is going on.
      If ((0 >= _iAgendaShortTerm) && (1 == _iAgendaLongTerm) && (1 >= _iAgendaMidTerm) && \
          !_bPermanency && !_qFramework.GetCurrentScene())
         ; The slaver will only release the player if he is not particularly angry with her.
         If (_qMcm.iMaxAngerForRelease >= _qFramework.GetActorAnger(_aLeashHolder))
            Int iChance = _qMcm.iChanceOfRelease
            Int iDominance = _qFramework.GetActorDominance(_aLeashHolder)
            iChance -= (((iDominance - 50) * _qMcm.iDominanceAffectsRelease) / 50)
            Float fRoll = Utility.RandomFloat(0, 100)
            Log("Leash Game End Roll: " + fRoll + " / " + iChance, DL_TRACE, S_MOD)
            If (iChance > fRoll)
               Int iRandom = Utility.RandomInt(1, 100)
               If (_qMcm.iChanceFurnitureTransfer >= iRandom)
                  ObjectReference oFurnitureNearby = \
                     GetRandomFurniture(_qFramework.GetNearestRegion(), iReason=1)

                  If (!oCurrFurniture && oFurnitureNearby && \
                      !_qFramework.SceneStarting(S_MOD + "_MoveToFurniture", 60))
                     _iAgendaLongTerm = 4
                     _iDetailsLongTerm = 1
                     _qFramework.ForceSave()

                     ; Try to narrow down where the furniture is.
                     _oTransferFurniture = oFurnitureNearby
                     Location oFurnitureLocation = _oTransferFurniture.GetCurrentLocation()

                     ; The furniture might be in a custom cell which doesn't have a location.
                     If (!oFurnitureLocation)
                        If (MutexLock(_iFavouriteFurnitureMutex))
                           Int iIndex = _aoFavouriteFurniture.Find(_oTransferFurniture)
                           If (-1 != iIndex)
                              oFurnitureLocation = (_aoFavouriteLocation[iIndex] As Location)
                           EndIf

                           MutexRelease(_iFavouriteFurnitureMutex)
                        EndIf
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
                  _iAgendaLongTerm = 4
                  _iDetailsLongTerm = 2
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
                     Utility.Wait(1.0)
                     SendModEvent("SSLV Entry")
                  EndIf
                  Return
               EndIf
               ; The leash game has ended.  The player will be set free.
               Log(GetDisplayName(_aLeashHolder) + " unties your leash and lets you go.", \
                   DL_CRIT, S_MOD)
               StopLeashGame()
               Return
            EndIf
         EndIf

         ; The leash game has been extended for some reason.  Reset the duration.
         _iLeashGameDuration = GetLeashGameDuration(True)
      Else
         ; A punishment or other activity is going on.  Extend the leash game by a small amount.
         _iLeashGameDuration = 30
      EndIf
   EndIf

   ; Don't process anything further if the player is locked in furniture as a punishement.
   ; For now the move to package doesn't allow other processing.
   If (_oPunishmentFurniture)
      ; Don't bother locking up the player's hands if she is in furniture.
      ; HACK: I don't know how we get in a state where it's needed but we do so check for it.
      If (4 == _iAgendaShortTerm)
         _iAgendaShortTerm = 0
      EndIf
      Return
   EndIf

   ; Next handle cases of the player being locked in BDSM furniture.
   ; 2: Dominate the player and make sure she is secure
   If (oCurrFurniture && (2 == _iAgendaMidTerm))
      ; For now if the player is talking to the guard just don't start a conversation.
      ; TODO: Eventually we want this to happen all the time.  Not just when in furniture;
      ; however, we also need the slaver to be upset with the player when this happens.
      Actor aSpeakingNpc = _qFramework.GetPlayerTalkingTo()
      If (aSpeakingNpc && aSpeakingNpc.IsGuard())
         Return
      EndIf

      If (!_qFramework.IsPlayerGagged())
         ; 0x40000000: Peaceful (the player is co-operating)
         ; 0x0002: Gag
         _iAssault = Math.LogicalOr(0x40000000 + 0x0002, _iAssault)
         ; Goal 8: Restrain the player.
         StartConversation(_aLeashHolder, 8, iTimeout=3)
      ElseIf (2 > _iWeaponsStolen)
         ; Goal 3: Take the player's weapons.
         StartConversation(_aLeashHolder, 3, iTimeout=3)
      ElseIf (_qFramework.GetNakedLevel())
         ; Goal 5: Strip the player fully.
         StartConversation(_aLeashHolder, 5, iTimeout=3)
      ElseIf (!_qFramework.IsPlayerCollared())
         ; 0x40000000: Peaceful (the player is co-operating)
         ; 0x0200: Restrain in Collar
         _iAssault = Math.LogicalOr(0x40000000 + 0x0200, _iAssault)
         ; Goal 8: Restrain the player.
         StartConversation(_aLeashHolder, 8, iTimeout=3)
      ElseIf (!_qFramework.IsPlayerArmLocked())
         If (0 < _iCrawlRemaining)
            ; 0x40000000: Peaceful (the player is co-operating)
            ; 0x00010000: Restrain in Bondage Mittens (implies Unbind Arms)
            _iAssault = Math.LogicalOr(0x40000000 + 0x00010000, _iAssault)
         Else
            ; 0x40000000: Peaceful (the player is co-operating)
            ; 0x0004: Bind Arms (implies Unbind Mittens)
            _iAssault = Math.LogicalOr(0x40000000 + 0x0004, _iAssault)
         EndIf
         ; Goal 8: Restrain the player.
         StartConversation(_aLeashHolder, 8, iTimeout=3)
      Else
         ; The player is all bound up (save collar and boots).  Release her from the furniture.
         _qZbfSlaveActions.RestrainInDevice(None, _aLeashHolder, S_MOD + "_F_Release")
      EndIf
      Return
   EndIf

   ; Next handle cases of the player acting aggressive toward the slaver.
   If (_aPlayer.IsWeaponDrawn() && _bReequipWeapons && _qFramework.GetWeaponLevel())
      DebugTrace("Player Aggressive.")

      ; The player has re-equipped her weapons and drawn them.
      ; The leash holder should be alarmed at this.
      iAnger = _qFramework.IncActorAnger(_aLeashHolder, _iLeashGoalRefusalCount, 0, 100)

      ; If the slaver hasn't spoken to the player about putting her weapons away do so now.
      If (1 != _iAgendaShortTerm)
         ; If we were trying to strip the player take back assisted dressing.
         If (2 == _iAgendaShortTerm)
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
   If (1 == _iAgendaShortTerm)
      ; If the player has put away her weapons.  Relax a little.
      If (!_qFramework.GetWeaponLevel())
         _iAgendaShortTerm = -2
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
   If (2 == _iAgendaShortTerm)
      ; If the player has undressed.  Relax a little.
      If (_qFramework.NS_BOTH_PARTIAL >= _qFramework.GetNakedLevel())
         _qFramework.RemovePermission(_aLeashHolder, _qFramework.AP_DRESSING_ASSISTED)

         _iAgendaShortTerm = -2
         _qFramework.IncActorAnger(_aLeashHolder, -3, 30, 100)
         Return
      EndIf

      ; Increase the leash holder's annoyance at the player's not having undressed yet.
      _iLeashGoalRefusalCount += 1
Log("Increase Anger 1.", DL_DEBUG, S_MOD)
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
   If (4 == _iAgendaShortTerm)
      ; If the player has put on the restraint.  Relax a little.
      If (_qFramework.IsPlayerArmLocked())
         ; 5: zad_DeviousArmbinder
         If (_aPlayer.WornHasKeyword(_aoZadDeviceKeyword[5]) && !_qZadArmbinder.IsLocked && \
             (75 >= Utility.RandomInt(1, 100)))
            PlayApproachAnimationOld(_aLeashHolder, "Inspect")
         EndIf

         _iAgendaShortTerm = -2
         _qFramework.IncActorAnger(_aLeashHolder, -3, 25, 100)
         Return
      EndIf

      ; Increase the leash holder's annoyance at the player's not having complied yet.
      _iLeashGoalRefusalCount += 1
Log("Increase Anger 2.", DL_DEBUG, S_MOD)
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
   If ((2 == _iAgendaMidTerm) && !_oBdsmFurniture)
      _iAgendaMidTerm = 0

      ; Clear hover activity for the leash holder in case he was hovering around the furniture.
      _qFramework.HoverAtClear(S_MOD + "_SecurePlayer")
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
      DebugTrace("Player has weapons!")

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

   ; Don't process any more options if the slaver has leashed the player to something else.
   If (_aLeashHolder != _qFramework.GetLeashTarget())
      Return
   EndIf

   ; Keep track of whether the player is in front of the slaver or not.
   Float fPlayerPosition = _aLeashHolder.GetHeadingAngle(_aPlayer)
   Bool bPlayerInFront = ((80 >= fPlayerPosition) && (-80 <= fPlayerPosition))

   ; Keep track of the current game time.
   Float fCurrGameTime = Utility.GetCurrentGameTime()

   ; Identify the slaver's position to determine moving, travelling, or stationary.
   Int iDirection = GetDirection(_aLeashHolder, _aiLeashHolderCurrPos[0], \
                                 _aiLeashHolderCurrPos[1])
   _aiLeashHolderCurrPos[0] = (_aLeashHolder.X As Int)
   _aiLeashHolderCurrPos[1] = (_aLeashHolder.Y As Int)
   _aiLeashHolderCurrPos[2] = (_aLeashHolder.Z As Int)

   If (4 == iDirection)
      ; If the leash holder is stopped for any reason reset the player's walk in front count.
      _iCurrWalkInFrontCount = 0

      ; Only treat the leash holder as stopped if he is not busy with any other scenes.
      If (!_qSexLab.IsActorActive(_aPlayer) && !_qSexLab.IsActorActive(_aLeashHolder) && \
          !_aLeashHolder.IsInDialogueWithPlayer() && !_qFramework.GetCurrentScene())
         ; The leash holder is stopped.  Keep track of how long he has been stationary.
         _iLeashHolderStationary += 1
         If ((1 != _iAgendaMidTerm) && (10 <= _iLeashHolderStationary))
            ; If the leash holder has been stationary for a while and is not on a break reset
            ; the time until the next sandbox.
            _iLeashHolderMoving = 0
            _fMasterSandboxTime = 0.0
         EndIf

         ; If the player is being forced to crawl make her heel and kneel.
;         If (((25.0 <= _fTrainingLevel) || _iCrawlRemaining) && \
         If (((10.0 <= _fTrainingLevel) || _iCrawlRemaining) && \
             (6 <= _iLeashHolderStationary) && !(_iLeashHolderStationary % 3) && \
             !_iCurrScene && (_aLeashHolder != _qFramework.GetPlayerTalkingTo()))
            Int iPunishmentTime
            If (175.0 < _aLeashHolder.GetDistance(_aPlayer))
               ; 10: Order the player to come.
               _iCurrDialogue = 10
               _aCurrDialogueTarget = _aLeashHolder
               StartConversation(_aLeashHolder, iTImeout=3)

               iPunishmentTime = 10
            ; 0x0080: The pose is considred kneeling.
            ElseIf (!Math.LogicalAnd(0x0080, _qFramework.GetCurrPoseFlags()))
               ; 8: Order the player to kneel.
               _iCurrDialogue = 8
               _aCurrDialogueTarget = _aLeashHolder
               StartConversation(_aLeashHolder, iTImeout=3)

               iPunishmentTime = 16
            ; 0x0200: The pose is considred exposed.
            ElseIf (((50 <= _fTrainingLevel) || (10 <= _iBadBehaviour)) && \
                    !Math.LogicalAnd(0x0200, _qFramework.GetCurrPoseFlags()))
               ; 9: Order the player to spread her knees.
               _iCurrDialogue = 9
               _aCurrDialogueTarget = _aLeashHolder
               StartConversation(_aLeashHolder, iTImeout=3)

               iPunishmentTime = 16
            EndIf

            ; If the player hasn't been obeying pull on her leash.
            If (iPunishmentTime && (iPunishmentTime <= _iLeashHolderStationary))
               Utility.Wait(1.0)
               _qFramework.YankLeash(bForceDamage=True)
            EndIf
         EndIf
      EndIf
   Else
      ; The leash holder is moving.  Keep track of how long he has been moving for.
      _iLeashHolderMoving += 1
      If (10 <= _iLeashHolderMoving)
         ; The leash holder has been moving for a while schedule a sandbox break.
         _iLeashHolderStationary = 0
         If ((1 != _iAgendaMidTerm) && !_fMasterSandboxTime)
            _fMasterSandboxTime = fCurrGameTime + (Utility.RandomFloat(_qMcm.fWalkBreakMinTime, \
                                                               _qMcm.fWalkBreakMaxTime) / 24)
         EndIf
      EndIf

      ; If the leash holder is moving also check for the player walking in front.
      If ((1 <= _iCurrWalkInFrontCount) && bPlayerInFront)
         DebugTrace("Walking in front.")

         ; Every so often the yank the player's leash and talk to her about her behaviour.
         If (!(_iCurrWalkInFrontCount % 3))
            ; Have the slaver get upset at the player's behaviour.
            _iTotalWalkInFrontCount += 1
            _qFramework.IncActorAnger(_aLeashHolder, 1, 0, 65)

            If (!_iMcmLeashResist || (_iMcmLeashResist < Utility.RandomInt(1, 100)))
               _qFramework.YankLeash(bForceDamage=True)
            EndIf
            StartConversation(_aLeashHolder, 7, iTimeout=3)
         EndIf
         Return
      EndIf

      ; If the slaver is scheduled to have a break start it now.
      If ((1 != _iAgendaMidTerm) && _fMasterSandboxTime && \
          (_fMasterSandboxTime < fCurrGameTime) && _qFramework.GetCurrentRegion())
         _fMasterSandboxTime = 0.0
         _iAgendaMidTerm = 1
         _qFramework.ReEvaluatePackage(_aLeashHolder)
      EndIf
   EndIf

   ; If the slaver is fed up with the player's backtalk.  Gag her.
   If ((5 <= _iVerbalAnnoyance) && !_qFramework.IsPlayerGagged())
      StartConversation(_aLeashHolder, 6)
      Return
   EndIf

   ; Otherwise The player has been behaving.
   ;Off-DebugTrace("Player behaving.")

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
      PlayApproachAnimationOld(_aLeashHolder, "Assault")

      _bReleaseBlindfold = False
   ElseIf (_bReleaseGag)
      ; 0x40000000: Peaceful (the player is co-operating)
      ; 0x0100: UnGag
      _iAssault = Math.LogicalOr(0x40000000 + 0x0100, _iAssault)
      PlayApproachAnimationOld(_aLeashHolder, "Assault")

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
   If (1 >= iRandomEvent)
      _qFramework.IncActorDominance(_aLeashHolder, 1, 0, 100)
   EndIf

   ; If the goal is set to less than 0 that indicates a delay.  Just increment it.
   If (0 > _iAgendaShortTerm)
      _iAgendaShortTerm += 1
      Return
   EndIf

   ; If the player is already dressed and decorated as a slave don't process any more options.
   If (_bIsCompleteSlave && (2 <= _iWeaponsStolen))
      ; Inspect the player's restraints to make sure they are secure.
      If (3 >= iRandomEvent)
         ; 5: zad_DeviousArmbinder
         If (_aPlayer.WornHasKeyword(_aoZadDeviceKeyword[5]) && \
             (_qZadArmbinder.StruggleCount || !_qZadArmbinder.IsLocked))
            PlayApproachAnimationOld(_aLeashHolder, "Inspect")
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

      ; If the player still all locked up nothing more is needed.
      If (_qFramework.IsPlayerArmLocked())
         Return
      EndIf

      ; If the player has somehow escaped her arm binder she is no longer fully enslaved.
      _bFullyRestrained = False
      _bIsCompleteSlave = False
   EndIf

   iAnger = _qFramework.GetActorAnger(_aLeashHolder)
   ;Log("Checking events: Anger(" + iAnger + ") Random(" + iRandomEvent + ")", DL_TRACE, S_MOD)

   ; Check if the slaver wants to bind the player's arms based on how angry he is.
   ; Anger >= 75: 100%  Anger 50-65: 50%  Anger 40-50: 15%  Anger < 40: 8%
   If (((75 <= iAnger) || ((65 <= iAnger) && (50 >= iRandomEvent)) || \
        ((40 <= iAnger) && (15 >= iRandomEvent)) || ((40 > iAnger) && (8 >= iRandomEvent))) && \
       _oArmRestraint && ((4 != _iAgendaLongTerm) || (1 != _iDetailsLongTerm)) && \
       !_qFramework.IsPlayerArmLocked() && !_iCrawlRemaining)

      ; Remove any of these items the player may have and make sure she has a single one.
      _aPlayer.RemoveItem(_oArmRestraint, 999, abSilent=True)
      _aPlayer.AddItem(_oArmRestraint)

      StartConversation(_aLeashHolder, 4)
      Return
   EndIf

   ; Check if the slaver wants to strip the player.
   If ((10 < iRandomEvent) && (20 >= iRandomEvent) && \
       (_qFramework.NS_BOTH_PARTIAL < _qFramework.GetNakedLevel()))

      ; Goal 2: Get the player out of her armour.
      StartConversation(_aLeashHolder, 2)
      Return
   EndIf

   ; All of the following will only be considered if the player's arms are locked up.
   iRandomEvent = Utility.RandomInt(1, 100)
   If (_qFramework.IsPlayerArmLocked() && ((iRandomEvent <= _iMcmChanceIdleRestraints) || \
                                           (_oBdsmFurniture && (2 == _iAgendaMidTerm))))
      iRandomEvent = Utility.RandomInt(1, 100)
      DebugTrace("Extra Events: " + iRandomEvent)

      If ((50 >= iRandomEvent) && (2 > _iWeaponsStolen))
         ; Goal 3: Take the player's weapons.
         StartConversation(_aLeashHolder, 3, iTimeout=3)
         Return
      EndIf

      If ((50 < iRandomEvent) && (75 >= iRandomEvent) && _qFramework.GetNakedLevel())
         ; Goal 5: Strip the player fully.
         StartConversation(_aLeashHolder, 5, iTimeout=3)
         Return
      EndIf

      If ((!_bFullyRestrained && (75 < iRandomEvent)) || (2 == _iAgendaMidTerm))
         ; Verify the player is not already restrained like a slave.
         ; Gag, Arms, Boots/Hobble, Collar
         If (!CheckPlayerFullyBound())
            ; Goal 8: Restrain the player.
            StartConversation(_aLeashHolder, 8, iTimeout=3)
            Return
         ElseIf (_oBdsmFurniture && (2 == _iAgendaMidTerm))
            ; If the slaver has an agenda to make sure the player is secure that is done.
            _iAgendaMidTerm = 0

            ; Our agenda is secure and leash the player.  She is secure so unlock the furniture.
            ; If the player is locked in furniture she is secure so we can release her.
            If (_oBdsmFurniture)
               _qZbfSlaveActions.RestrainInDevice(None, _aLeashHolder, S_MOD + "_BdsmToLeash")
            ElseIf (_bIsPlayerCaged)
               ReleasePlayerFromCage(_aLeashHolder, _oBdsmFurniture)
            EndIf
         EndIf
      EndIf
   EndIf
EndFunction

Function StartSdPlus()
   DebugTrace("TraceEvent StartSdPlus")
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
   DebugTrace("TraceEvent StartSdPlus: Done")
EndFunction

Function StopSdPlus()
   DebugTrace("TraceEvent StopSdPlus")
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
   DebugTrace("TraceEvent StopSdPlus: Done")
EndFunction

; This can be used to turn on or of the SD+ leash in the case that the MCM value changes.
Function UpdateSdPlusLeashState(Bool bNewValue)
   DebugTrace("TraceEvent UpdateSdPlusLeashState")
   ; If the player is not SD+ enslaved or the SD+ master is not registered with DFW for some
   ; reason don't try to start/stop the leash.
   If (!_bEnslavedSdPlus || (S_MOD_SD != _qFramework.GetMasterMod(_qFramework.MD_CLOSE)))
      DebugTrace("TraceEvent UpdateSdPlusLeashState: Done (No Master)")
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
   DebugTrace("TraceEvent UpdateSdPlusLeashState: Done")
EndFunction

; iLevel: <-1 the player is resisting more than an acceptable level.
; iLevel:  -1 the player is resisting.
; iLevel:   0 the player doesn't have much of a choice to resist or not.
; iLevel:  >0 the player is behaving and accepting her punishment.
Function PunishPlayer(Actor aNpc, Int iLevel, String szScene)
   ; Restore the Leash Length post assault as a precaution.
   ; 0x1000: Restore Leash Length
   _iAssault = Math.LogicalOr(0x1000, _iAssault)

   _iBadBehaviour += (((_fTrainingLevel As Int) / 25) + 1)
   _iAgendaLongTerm = 3
   _iDetailsLongTerm = 0
   _fTimeLastPunished = 0.0

   ; If the player's arms are not yet bound make sure they are secure.
   If (!_qFramework.IsPlayerArmLocked())
      _iAgendaShortTerm = 4
      If (_aPlayer.IsWeaponDrawn())
         _iAgendaShortTerm = 1
      EndIf
      ; The player can resist.  Perform an assault allowing for a struggle.
      _iGagRemaining += (((60 + (120 * _iBadBehaviour)) / _fMcmPollTime) As Int)
      AssaultPlayer(0.3, bUnquipWeapons=True, bStealWeapons=False, bAddArmBinder=True, \
                    bAddGag=True)
      Return
   EndIf

   ; Make a note the slaver does not want the player ungagged.
   _bPlayerUngagged = False

   ; Add a basic punishment regardless: gag, collar, and hobble.
   If (!_qFramework.IsPlayerGagged())
      ; 0x0002: Gag
      ; 0x2000: Make sure the Gag is secure
      _iAssault = Math.LogicalOr(0x2000 + 0x0002, _iAssault)
      _iGagRemaining += (((60 + (120 * _iBadBehaviour)) / _fMcmPollTime) As Int)

      ; If the player has been particularly misbehaving add an extra restraint.
      If (-1 >= iLevel)
         ; 0x0400: Blindfold
         _iAssault = Math.LogicalOr(0x0400, _iAssault)
         _iBlindfoldRemaining += (((60 + (60 * _iBadBehaviour)) / _fMcmPollTime) As Int)
      EndIf
   Else
      _qFramework.SetStrictGag()
   EndIf
   If (!_qFramework.IsPlayerCollared())
      ; 0x0200: Restrain in Collar
      _iAssault = Math.LogicalOr(0x0200, _iAssault)
   EndIf
   If (!_qFramework.IsPlayerHobbled())
      ; 0x0080: Add Additional Restraint
      _iAssault = Math.LogicalOr(0x0080, _iAssault)
   EndIf

   ; If the player is already being punished in furniture simply increase her punishment time.
   Bool bPunishmentFound
   If (_iFurnitureRemaining || _iCrawlRemaining)
      Log("Punish Player: Increase Existing " + _iFurnitureRemaining + "/" + _iCrawlRemaining, \
          DL_TRACE, S_MOD)
      If (_iFurnitureRemaining)
         _iFurnitureRemaining += (((180 * _iBadBehaviour) / _fMcmPollTime) As Int)
      EndIf
      If (_iCrawlRemaining)
         _iCrawlRemaining += (((180 * _iBadBehaviour) / _fMcmPollTime) As Int)
      EndIf
   Else
      ; Otherwise figure out if a furniture or crawling punshment should be applied.
      Int iWeightBasic
      If (_iAssault)
         iWeightBasic  = _qMcm.iWeightPunishBasic
      EndIf
      Int iWeightFurn  = _qMcm.iWeightPunishFurn + (2 * _iBadBehaviour)
      Int iWeightCrawl = _qMcm.iWeightPunishCrawl + _iBadBehaviour
      Int iRandomChance = Utility.RandomInt(1, (iWeightBasic + iWeightFurn + iWeightCrawl))

      Log("Punishment Roll: " + iRandomChance + " (" + iWeightBasic + "/" + iWeightFurn + \
          "/" + iWeightCrawl + ")", DL_TRACE, S_MOD)

      ; If we elected to lock the player in furniture try to do so now.
      If (iRandomChance < iWeightFurn)
         ; 4: Start Scene.  9: Start Furniture Punishment.
         AddPendingAction(4, 9, aNpc, S_MOD + "_FPunish", bPrepend=True)
         bPunishmentFound = True
         ; End the current scene so the punishment scene can start.
         _qFramework.SceneDone(szScene)
      EndIf

      ; If we elected to force the player to crawl set that punishment time now.
      iRandomChance -= iWeightFurn
      If (!bPunishmentFound && (iRandomChance < iWeightCrawl))
         _iCrawlRemaining = (((180 + (180 * _iBadBehaviour)) / _fMcmPollTime) As Int)
         _iResistCrawlCount = 0
         _iAgendaLongTerm = 3
         _iDetailsLongTerm = 0
         _fTimeLastPunished = 0.0

         ; Place the player in bondage mittens so she can crawl with her arms.
         ; 0x00010000: Restrain in Bondage Mittens (implies Unbind Arms)
         _iAssault = Math.LogicalOr(0x00010000, _iAssault)

         ; If the slaver is in the process of locking the player's arms abandon that.
         If (4 == _iAgendaShortTerm)
            _iAgendaShortTerm = 0
         EndIf

         ; Also remove any blindfold that may be applied (or is about to be).
         ; 0x0800: Release Blindfold
         _iAssault = Math.LogicalOr(0x0800, _iAssault)
         ; 0x0400: Blindfold
         _iAssault = Math.LogicalAnd(Math.LogicalNot(0x0400), _iAssault)
         _iBlindfoldRemaining = 0

         ; Set a pending action ordering the player to crawl.
         ; This needs to happen after the assault to release the player's arms.
         ; 1: Start Conversation. 7: Order the player to crawl.
         AddPendingAction(1, 7, aNpc, bPrepend=True)

         bPunishmentFound = True
      EndIf

      ; Otherwise it is only a basic punishment.  Consider adding a blindfold.
      If (!bPunishmentFound && (!_iAssault || \
                                (_qMcm.iChancePunishBlindfold <= Utility.RandomInt(1, 100))))
         ; 0x0400: Blindfold
         _iAssault = Math.LogicalOr(0x0400, _iAssault)
         _iBlindfoldRemaining += (((60 + (60 * _iBadBehaviour)) / _fMcmPollTime) As Int)
      EndIf
   EndIf

   If (bPunishmentFound)
      ; Increase the actor's feeling of dominance.
      _qFramework.IncActorDominance(aNpc, 1, 0, 100)
      _qFramework.ForceSave()
   EndIf

   ; If there is any sort of assault pending perform it now.
   If (_iAssault)
      PlayApproachAnimation(aNpc, "Assault", szScene)
   EndIf
EndFunction

; Called by dialogue scripts to reset the call out/player protest timeout.
Function CallOutReset()
   _qFramework.CallOutDone()
   _qFramework.CallOutReset()
EndFunction

; Called by dialogue scripts to indicate the dialogue is upsetting the speaker.
Function IncAnger(Actor aActor, Int iDelta)
   DebugTrace("TraceEvent IncAnger")
Log("Increase Anger 3.", DL_DEBUG, S_MOD)
   _qFramework.IncActorAnger(aActor, iDelta, 20, 80)

   ; Reset the dialogue timeout beacuse we are still in a dialogue.
   If (_iDialogueBusy)
      _iDialogueBusy = 20
   EndIf
   DebugTrace("TraceEvent IncAnger: Done")
EndFunction

; Called by dialogue scripts to indicate the player is taking to her training (or not).
Function IncreaseTrainingLevel(Float fDelta, Actor aNpc=None)
   DebugTrace("TraceEvent IncreaseTrainingLevel")
   ; Only consider changing the player's training level if she is not already a complete slave.
   If (100.0 == _fTrainingLevel)
      DebugTrace("TraceEvent IncreaseTrainingLevel: Done (Complete Slave)")
      Return
   EndIf

   If (aNpc)
      If (1.0 <= fDelta)
         ; Increase the actor's feeling of dominance.
         _qFramework.IncActorDominance(aNpc, 1, 0, 100)
      ElseIf (-1.0 >= fDelta)
         ; Increase the actor's feeling of dominance.
         _qFramework.IncActorDominance(aNpc, -1, 0, 100)
      EndIf
   EndIf

   ; If it is a small decrease, and the player is at the threshold of crossing over to the next
   ; level, don't decrease her training level.  When crossing a threshold, only a significant
   ; behaviour event (with a delta of -2 or more) will cross the threshold.
   If ((0.0 > fDelta) && (-2.0 < fDelta) && \
       (((10.0 < _fTrainingLevel) && (10.0 > (_fTrainingLevel + fDelta))) || \
        ((25.0 < _fTrainingLevel) && (25.0 > (_fTrainingLevel + fDelta))) || \
        ((50.0 < _fTrainingLevel) && (50.0 > (_fTrainingLevel + fDelta))) || \
        ((75.0 < _fTrainingLevel) && (75.0 > (_fTrainingLevel + fDelta)))))
      DebugTrace("TraceEvent IncreaseTrainingLevel: Done (Threshold Reached)")
      Return
   EndIf

   _fTrainingLevel += fDelta
   If (0.0 > _fTrainingLevel)
      _fTrainingLevel = 0.0
   ElseIf (100.0 < _fTrainingLevel)
      _fTrainingLevel = 100.0
   EndIf
   DebugTrace("TraceEvent IncreaseTrainingLevel: Done")
EndFunction

; This is typically used to reduce an actor's kindness when the player "tries her luck" to
; to help ensure the actor doesn't change his mind and decide to help the player later.
Function ActorFailedToHelp(Actor aActor, Int iSeverity)
   DebugTrace("TraceEvent ActorFailedToHelp")
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
   DebugTrace("TraceEvent ActorFailedToHelp: Done")
EndFunction

; Called by dialogue scripts to indicate the slaver is feeling more dominant toward the player.
Function IncDominance(Actor aActor, Int iDelta)
   DebugTrace("TraceEvent IncDominance")
   _qFramework.IncActorDominance(aActor, iDelta, 20, 80)

   ; Reset the dialogue timeout beacuse we are still in a dialogue.
   If (_iDialogueBusy)
      _iDialogueBusy = 20
   EndIf
   DebugTrace("TraceEvent IncDominance: Done")
EndFunction

; The player has said something to verbally annoy the slaver.  Increase his annoyance count.
Function VerbalAnnoyance(Int iLevel=1)
   DebugTrace("TraceEvent VerbalAnnoyance")
   _iVerbalAnnoyance += iLevel
   DebugTrace("TraceEvent VerbalAnnoyance: Done")
EndFunction

; Plays a dominant approaching the player choosing an animation based on whether the player is
; in BDSM furniture or not.
Function PlayApproachAnimation(Actor aNpc, String szMessage, String szExpectedScene)
   DebugTrace("TraceEvent PlayApproachAnimation")
   ; Verify we still have the DFW Scene locked.
   String szCurrScene = _qFramework.GetCurrentScene()
   If (!szCurrScene)
      If (_qFramework.SceneStarting(szExpectedScene, 180))
         Log("Approach Failed: Could Not Start Scene " + szExpectedScene, DL_DEBUG, S_MOD)
         DebugTrace("TraceEvent PlayApproachAnimation: Done (Failed to Start Scene)")
         Return
      EndIf
   ElseIf (szExpectedScene != szCurrScene)
      Log("Approach Failed: Scene " + szCurrScene + " != " + szExpectedScene, DL_DEBUG, S_MOD)
      DebugTrace("TraceEvent PlayApproachAnimation: Done (Scene Busy)")
      Return
   EndIf

   ; Wait for the NPC if he is in the process of sitting or standing.
   ActorSitStateWait(aNpc)

   _qFramework.YankLeashWait(500)
   If (_qFramework.GetBdsmFurniture())
      ; If the player is locked in furniture, immobilize her so we can lock her up again after.
;Off-DebugTrace("PlayApproachAnimation: Movement Disabled - Leash from Furniture")
      ImmobilizePlayer()
      _qZbfSlaveActions.RestrainInDevice(None, aNpc, asMessage=S_MOD + "_S_" + szMessage)
   Else
      If (_bIsPlayerCaged)
         ; If the player is locked in a cage, open the door and immobilize her.
;Off-DebugTrace("PlayApproachAnimation: Movement Disabled - Leash from Caged")
         ImmobilizePlayer(5)
         OpenCageDoor(aNpc, _oBdsmFurniture, FindCageLever(_oBdsmFurniture))
         ; Clear some space to allow the NPC to approach the player.
         SlavesGiveSpace(aNpc)
      EndIf
DebugTrace("PlayApproachAnimation: Binding the player: (" + GetDisplayName(aNpc) + "," + S_MOD + "_S_" + szMessage + ").")
      _qZbfSlaveActions.BindPlayer(akMaster=aNpc, asMessage=S_MOD + "_S_" + szMessage)
   EndIf
   DebugTrace("TraceEvent PlayApproachAnimation: Done")
EndFunction

; Plays a dominant approaching the player choosing an animation based on whether the player is
; in BDSM furniture or not.
; Depricated: This should not be used.  Use the newer scene based system if possible.
Function PlayApproachAnimationOld(Actor aNpc, String szMessage)
   DebugTrace("TraceEvent PlayApproachAnimationOld")
   ; If we can't lock the DFW scene flag don't try to start a scene.
   If (_qFramework.SceneStarting(S_MOD, 60))
      DebugTrace("TraceEvent PlayApproachAnimationOld: Done (Failed to Start Scene)")
      Return
   EndIf

   ; Wait for the NPC if he is in the process of sitting or standing.
   ActorSitStateWait(aNpc)

   _qFramework.YankLeashWait(500)
   If (_qFramework.GetBdsmFurniture())
;Off-DebugTrace("PlayApproachAnimationOld: Movement Disabled - Leash from Furniture")
      ImmobilizePlayer()
      _qZbfSlaveActions.RestrainInDevice(None, aNpc, asMessage=S_MOD + "_F_" + szMessage)
   Else
      _qZbfSlaveActions.BindPlayer(akMaster=aNpc, asMessage=S_MOD + "_" + szMessage)
   EndIf
   DebugTrace("TraceEvent PlayApproachAnimationOld: Done")
EndFunction

; Called by dialogue scripts to indicate the player has agreed to or refuses to cooperate.
; The level of cooperation: < 0 not cooperating, 0 = avoiding the subject, > 0 = cooperating.
Function Cooperation(Int iGoal, Int iLevel, Actor aNpc, Bool bWaitForEnd=True)
   DebugTrace("TraceEvent Cooperation (" + iGoal + "," + iLevel + ")")

   ; Note we are processing end of dialogue so the Monitoring Dialogue knows to wait for us.
   _bCurrDialogueEnding = True

   ; If we are expected to wait for the dialogue to end, do so now.
   If (bWaitForEnd)
      Float fSecurity = 30
      While ((0 < fSecurity) && aNpc.IsInDialogueWithPlayer())
         Utility.Wait(0.05)
         fSecurity -= 0.05
      EndWhile
   EndIf

   If (0 < iLevel)
Log("Increase Anger 4.", DL_DEBUG, S_MOD)
      _qFramework.IncActorAnger(aNpc, -1, 20, 80)
   ElseIf (-1 == iLevel)
Log("Increase Anger 5.", DL_DEBUG, S_MOD)
      _qFramework.IncActorAnger(aNpc, 2, 20, 80)
   ElseIf (-1 > iLevel)
Log("Increase Anger 6.", DL_DEBUG, S_MOD)
      _qFramework.IncActorAnger(aNpc, 4, 20, 80)
   EndIf

   If (0 == iGoal)
      ; Make sure there is a bit of delay before we start another dialogue.
      If (0 == _iAgendaShortTerm)
         _iAgendaShortTerm = -1
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
         _qFramework.YankLeash(iOverrideLeashStyle=_qFramework.LS_DRAG, bForceDamage=True)
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
         PlayApproachAnimationOld(aNpc, "Assault")
      ElseIf (3 == iLevel)
         ; The player needs help unequipping her weapons.
         ; Play an animation for the slaver to approach the player.
         ; The assault (stripping) will happen on the done event (OnSlaveActionDone).
         ; 0x40000000: Peaceful (the player is co-operating)
         ; 0x0001: Strip
         _iAssault = Math.LogicalOr(0x40000000 + 0x0001, _iAssault)
         PlayApproachAnimationOld(aNpc, "Assault")
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
      PlayApproachAnimationOld(aNpc, "Assault")
      _iAgendaShortTerm = 0
   ElseIf (5 == iGoal)
      ; Goal 5: Strip the player fully.
      ; 0x40000000: Peaceful (the player is co-operating)
      ; 0x0040: Strip Fully
      _iAssault = Math.LogicalOr(0x40000000 + 0x0040, _iAssault)
      PlayApproachAnimationOld(aNpc, "Assault")
      _iAgendaShortTerm = 0
   ElseIf (7 == iGoal)
      ; After we have spoken to the player about it, don't bring it up for a while.
      _iAgendaShortTerm = 0
   ElseIf (8 == iGoal)
      ; Goal 8: Restrain the player.
      ; 0x40000000: Peaceful (the player is co-operating)
      ; 0x0080: Add Additional Restraint
      _iAssault = Math.LogicalOr(0x40000000 + 0x0080, _iAssault)
      PlayApproachAnimationOld(aNpc, "Assault")
      _iAgendaShortTerm = 0
   ElseIf (9 == iGoal)
      ; Goal 9: Reel in the Player
      _iAgendaShortTerm = 0

      ; Give the player some time to respond and decrease the time she has for the future.
      Utility.Wait(_iExpectedResponseTime)
      If (3 < _iExpectedResponseTime)
         _iExpectedResponseTime -= 1
      EndIf

      ; Shorten the player's leash.
      _qFramework.SetLeashLength(200)

      ; 0x0001 = Talking of Escape
      If (Math.LogicalAnd(0x0001, _iPunishments))
         _iBadBehaviour += (((_fTrainingLevel As Int) / 25) + 1)
         _iAgendaLongTerm = 3
         _iDetailsLongTerm = 0
         _fTimeLastPunished = 0.0
         If (_iBlindfoldRemaining)
            _iBlindfoldRemaining += (((60 + (60 * _iBadBehaviour)) / _fMcmPollTime) As Int)
         EndIf
         If (_iGagRemaining)
            _iGagRemaining += (((60 + (120 * _iBadBehaviour)) / _fMcmPollTime) As Int)
         EndIf

         ; Goal 10: Discipline Talking Escape
         StartConversation(aNpc, 10)
      EndIf
   ElseIf (10 == iGoal)
      ; Goal 10: Discipline Talking Escape

      ; If we were handling a callout end the scene (Note: a new assault scene may start).
      If (S_MOD + "_CallOut" == _qFramework.GetCurrentScene())
         _qFramework.CallOutDone()
         _qFramework.SceneDone(S_MOD + "_CallOut")
      EndIf

      ; The player needs to be disciplined for misbehaving.
      _iAgendaShortTerm = 0
      PunishPlayer(aNpc, iLevel, S_MOD + "_DisciplineCallOut")
   ElseIf (-3 == iGoal)
      ; Post Leash game the player wants her weapons back.
      Actor aLastLeashHolder = (_aAliasLastLeashHolder.GetReference() As Actor)
      If (1 == iLevel)
         ; The player's arms are free.  The slaver wants her locked up before returning them.
         ; Play an animation for the slaver to approach the player.
         ; Restraining the player's arms will happen on the done event (OnSlaveActionDone).
         ; 0x40000000: Peaceful (the player is co-operating)
         ; 0x0010: Return All Items
         ; 0x0004: Bind Arms (implies Unbind Mittens)
         _iAssault = Math.LogicalOr(0x40000000 + 0x0010 + 0x0004, _iAssault)
         PlayApproachAnimationOld(aLastLeashHolder, "Assault")
      ElseIf (2 == iLevel)
         ; 0x40000000: Peaceful (the player is co-operating)
         ; 0x0010: Return All Items
         _iAssault = Math.LogicalOr(0x40000000 + 0x0010, _iAssault)
         FinalizeAssault(aLastLeashHolder, GetDisplayName(aLastLeashHolder))
      EndIf
   ElseIf (-6 == iGoal)
      ; The player has been well behaved and is being ungagged.
      ; 0x40000000: Peaceful (the player is co-operating)
      ; 0x0100: UnGag
      _iAssault = Math.LogicalOr(0x40000000 + 0x0100, _iAssault)
      PlayApproachAnimationOld(aNpc, "Assault")
   EndIf

   ; Identify the dialogue is done.
   _iDialogueBusy = 0
   _aDialogueTarget = None
   _bCurrDialogueEnding = False

   DebugTrace("TraceEvent Cooperation: Done")
EndFunction

; Called by dialogue scripts to indicate the player has received outside assistance.
; Note: The goal here is for Outside Assistance.  It does not match the leash holder goal.
Function OutsideAssistance(Actor aHelper, Int iGoal, Int iLevel)
   DebugTrace("TraceEvent OutsideAssistance")
   String szLeashHolder = GetDisplayName(_aLeashHolder)
   String szHelper = GetDisplayName(aHelper)

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
      _iBadBehaviour += 3 * (((_fTrainingLevel As Int) / 25) + 1)
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
      Log("Escape Detection Roll: " + iRoll + " / " + iMaxChance, DL_TRACE, S_MOD)

      If (!_iAgendaShortTerm && (iMaxChance >= iRoll))
         Log("You feel a tug on the rope around your neck.", DL_CRIT, S_MOD)
Log("Increase Anger 7.", DL_DEBUG, S_MOD)
         _qFramework.IncActorAnger(_aLeashHolder, 2, 20, 80)
         _qFramework.IncActorDominance(_aLeashHolder, -3, 20, 80)

         ; Have the slaver give a warning that he is shortening the player's leash.
         ; Goal 9: Reel in the Player
         StartConversation(_aLeashHolder, 9, iTimeout=3, bInterruptPlayer=True)
         _iPunishments = Math.LogicalOr(0x0001, _iPunishments)
      EndIf
   ElseIf (-1 == iGoal)
      ; Goal -1: The NPC has actually tipped of the slaver that the player is misbehaving.
      If (!_iAgendaShortTerm)
         Log("You feel a tug on the rope around your neck.", DL_CRIT, S_MOD)
Log("Increase Anger 8.", DL_DEBUG, S_MOD)
         _qFramework.IncActorAnger(_aLeashHolder, 5, 20, 80)

         ; Have the slaver give a warning that he is shortening the player's leash.
         ; Goal 9: Reel in the Player
         StartConversation(_aLeashHolder, 9, iTimeout=3, bInterruptPlayer=True)
         _iPunishments = Math.LogicalOr(0x0001, _iPunishments)
      ElseIf (S_MOD + "_CallOut" == _qFramework.GetCurrentScene())
         ; CallOut scenes may continue here.  If it isn't continuing due to the leash holder
         ; goal make sure to end it.

         _qFramework.CallOutDone()
         _qFramework.SceneDone(S_MOD + "_CallOut")
      EndIf
   EndIf
   DebugTrace("TraceEvent OutsideAssistance: Done")
EndFunction

; SUCCESS means pending scenes were started.  WARNING means there is nothing left to process.
Int Function ProcessFurnitureGoals(Actor aNpc, String szExpectedScene="")
   DebugTrace("TraceEvent ProcessFurnitureGoals: " + \
              "0x" + _qDfwUtil.ConvertHexToString(_iAssault, 8) + "-" + \
              "0x" + _qDfwUtil.ConvertHexToString(_iFurnitureGoals, 4))

   Bool bHaveSex = False
   Bool bWhip    = False
   Bool bAlternateAssault = False
   _iAssaultTakeGold = 0
   Bool bCooperating = Math.LogicalAnd(_iFurnitureGoals, 0x0001)

   ; Having an invalid assault value here can ruin the game.  Detect and report that situation.
   If (0 > _iAssault)
      Log("Error: Negative Assault Value!", DL_ERROR, S_MOD)
      Log("Your game should be okay but please report this in the forums.", DL_DEBUG, S_MOD)
      _iAssault = 0
   EndIf

   ; If the player's leash length hasn't been restored, restore it now.
   ; Note: This is a bugged situation we are recovering from.  We shouldn't ever get here with a
   ; restore leash action pending but let's handle it, at least for now until restoring the
   ; leash length is bulletproof.
   ; 0x1000: Restore Leash Length
   If (Math.LogicalAnd(_iAssault, 0x1000))
      _iAssault -= 0x1000

      _qFramework.SetLeashLength(_qMcm.iLeashLength)
   EndIf

   ; First check if the furniture needs to be locked.
   ; 0x8000: Lock Furniture
   If (0x8000 <= _iFurnitureGoals)
      _iFurnitureGoals -= 0x8000

      If (0 < _fFurnitureReleaseTime)
         bAlternateAssault = True
         _qZbfSlaveActions.RestrainInDevice(None, aNpc, S_MOD + "_PreLock")
      EndIf

      DebugTrace("TraceEvent ProcessFurnitureGoals: Done (Locking)")
      Return SUCCESS
   EndIf

; I don't think this check is actually needed.
;   ; Double check the furniture goal value isn't compromised.
;   If (0x1000 < _iFurnitureGoals)
;      _iFurnitureGoals -= 0x1000
;
;      Log("Error: Invalid Furniture Goal: 0x" + \
;          _qDfwUtil.ConvertHexToString(_iFurnitureGoals, 4), DL_ERROR)
;   EndIf

   ; 0x0800: Restrain the player's arms
   If (0x0800 <= _iFurnitureGoals)
      _iFurnitureGoals -= 0x0800

      ; 0x0004: Bind Arms (implies Unbind Mittens)
      _iAssault = Math.LogicalOr(0x0004, _iAssault)
   EndIf

   ; 0x0400: Take the player's gold
   If (0x0400 <= _iFurnitureGoals)
      _iFurnitureGoals -= 0x0400

      bAlternateAssault = True
      Int iLeveledMax = 100 * ((_aPlayer.GetLevel() / 10) + 1)
      _iAssaultTakeGold = _aPlayer.GetGoldAmount()
      If (iLeveledMax < _iAssaultTakeGold)
         _iAssaultTakeGold = iLeveledMax
      EndIf
   EndIf

   ; 0x0200: Play(Sex/Whip)
   If (0x0200 <= _iFurnitureGoals)
      _iFurnitureGoals -= 0x0200

      If (_bIsPlayerCaged || (50 >= Utility.RandomInt(1, 100)))
         bHaveSex = True
      Else
         bWhip    = True
      EndIf
   EndIf

   ; 0x0100: Add Restraints
   If (0x0100 <= _iFurnitureGoals)
      _iFurnitureGoals -= 0x0100

      _iAssault = Math.LogicalOr(0x0080, _iAssault)
   EndIf

   ; 0x0080: Undress
   If (0x0080 <= _iFurnitureGoals)
      _iFurnitureGoals -= 0x0080

      If (_qFramework.NS_NAKED != _qFramework.GetNakedLevel())
         _iAssault = Math.LogicalOr(0x0001, _iAssault)
      EndIf
   EndIf

   ; 0x0040: Gag
   If (0x0040 <= _iFurnitureGoals)
      _iFurnitureGoals -= 0x0040

      _iAssault = Math.LogicalOr(0x0002, _iAssault)

      Int iBehaviour = _iBadBehaviour + (((_fTrainingLevel As Int) / 25) + 1)
      If (50 < _qFramework.GetActorAnger(aNpc))
         iBehaviour += 3
      EndIf
      _iGagRemaining += (((60 + (120 * iBehaviour)) / _fMcmPollTime) As Int)
   EndIf

   ; If the player cooperating is the only assault value, clear it.
   If (0x40000000 == _iAssault)
      _iAssault = 0x00000000
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
      EndIf

      ; If the player is caged the assault is more complex.  Use a scene.
      If (_oBdsmFurniture)
         ; 4: Start Scene.  4: Assault the player.
         AddPendingAction(4, 4, aNpc, szExpectedScene, bPrepend=True)
      ElseIf (!bCooperating)
         ; The player is not co-operating.  Use force.
         AssaultPlayer(szExpectedScene=szExpectedScene)
      Else
         ; TODO: Not sure if this code path is ever used any more.
         PlayApproachAnimation(aNpc, "Assault", szExpectedScene)
      EndIf
      DebugTrace("TraceEvent ProcessFurnitureGoals: Done (Assaulting)")
      Return SUCCESS
   EndIf

   ; 0x0020: Secure Gag
   If (0x0020 <= _iFurnitureGoals)
      _iFurnitureGoals -= 0x0020

      _qFramework.SetStrictGag()

      _iGagRemaining += ((_iGagRemaining * 0.5) As Int)
   EndIf

   ; 0x0010: Whip
   If (bWhip || (0x0010 <= _iFurnitureGoals))
      If (0x0010 <= _iFurnitureGoals)
         _iFurnitureGoals -= 0x0010
      EndIf

      _qFramework.IncActorDominance(aNpc, 1, 0, 100)
      StartWhippingScene(aNpc, 120, S_MOD + "_Whip", szExpectedScene)

      DebugTrace("TraceEvent ProcessFurnitureGoals: Done (Whip Scene)")
      Return SUCCESS
   EndIf

   ; 0x0008: Sex
   If (bHaveSex || (0x0008 <= _iFurnitureGoals))
      If (0x0008 <= _iFurnitureGoals)
         _iFurnitureGoals -= 0x0008
      EndIf

      ; If we are in the middle of a scene, make sure to extend it appropriately.
      If (szExpectedScene)
         _qFramework.SceneContinue(szExpectedScene, 120)
      EndIf
      StartSex(aNpc, !bCooperating)

      DebugTrace("TraceEvent ProcessFurnitureGoals: Done (Sex Scene)")
      Return SUCCESS
   EndIf

   ; 0x0004: Ungag
   If (0x0004 <= _iFurnitureGoals)
      _iFurnitureGoals -= 0x0004

      ; Perform an assault to ungag the player.
      ; The assault will happen on the done event (OnSlaveActionDone).
      ; 0x40000000: Peaceful (the player is co-operating)
      ; 0x0100: UnGag
      _iAssault = Math.LogicalOr(0x40000000 + 0x0100, _iAssault)
      ; If the player is caged ungagging her is more complex.  Use a scene.
      If (_oBdsmFurniture)
         ; 4: Start Scene.  4: Assault the player.
         AddPendingAction(4, 4, aNpc, szExpectedScene, bPrepend=True)
      Else
         ; TODO: Not sure if this code path is ever used any more.
         PlayApproachAnimation(aNpc, "Assault", szExpectedScene)
      EndIf

      DebugTrace("TraceEvent ProcessFurnitureGoals: Done (Ungagging)")
      Return SUCCESS
   EndIf

   ; 0x0002: Release
   If (0x0002 <= _iFurnitureGoals)
      Int iWillingnessToHelp = _qFramework.GetActorWillingnessToHelp(aNpc)
      If (Utility.RandomInt(1, 100) <= iWillingnessToHelp)
         PlayApproachAnimation(aNpc, "Unlock", szExpectedScene)
      Else
         ; Add a delay here because speaking again so soon after a conversation doesn't work.
         Utility.Wait(2.0)

         ; If we were processing another scene, end it to start the new conversation.
         If (szExpectedScene)
            _qFramework.SceneDone(szExpectedScene)
         EndIf

         ; Goal 13: Lying About Release
         StartConversation(aNpc, 13)
         ; Only clear the release flag is the NPC is lying.  If the NPC is releasing the player
         ; we want to still know it is a result of these furniture goals as the scene ends.
         _iFurnitureGoals -= 0x0002
      EndIf
      DebugTrace("TraceEvent ProcessFurnitureGoals: Done (Releasing)")
      Return SUCCESS
   EndIf

   ; 0x0001: Cooperating
   If (0x0001 <= _iFurnitureGoals)
      _iFurnitureGoals -= 0x0001
   EndIf
   DebugTrace("TraceEvent ProcessFurnitureGoals: Done")
   Return WARNING
EndFunction

; Called from within this script to indicate the script has detected the end of dialogue (rather
; than the dialogue calling a function to indicate it is complete).
; Status: 0: Player completed dialogue.          1: Timed out (most likely player exited).
;         2: Too fast.  Dialogue never started.  3: Dialogue failed.  Unknown reason.
Function EndDialogue(Actor aDialogueTarget, Int iStatus=0)
   If (1 == _iCurrDialogue)
      ; 1: Discipline CallOut

      If (1 == iStatus)
         ; The player needs to be disciplined for misbehaving.
         PunishPlayer(aDialogueTarget, Utility.RandomInt(-2, -1), S_MOD + "_DisciplineCallOut")
      EndIf

      ; End the current scene.
      _qFramework.SceneDone(S_MOD + "_DisciplineCallOut")
   ElseIf (2 == _iCurrDialogue)
      ; 2: Discipline - Misbehaving while selling items (_dfwsDisciplineSellItems).

      ; End the current scene.
      _qFramework.SceneDone(S_MOD + "_DisciplineSellItems")

      If (1 == iStatus)
         ; Indicate the player is rebelling against her training.
         IncreaseTrainingLevel(-1.0, aDialogueTarget)

         ; Punish the player for not accepting her place as a slave.
         ; 0x0002 = Not Accepting her slavery
         _iPunishments = Math.LogicalOr(0x0002, _iPunishments)

         ; Start by making sure she is gagged.
         ; 0x0002: Gag
         ; 0x2000: Make sure the Gag is secure
         _iAssault = Math.LogicalOr(0x2000 + 0x0002, _iAssault)
         PlayApproachAnimationOld(aDialogueTarget, "Assault")

         ; Then add an action to start the punishment after the player is gagged.
         AddPendingAction(8, aActor=aDialogueTarget, bPrepend=True)
      EndIf
   ElseIf (4 == _iCurrDialogue)
      ; 4: Introduction to the leash game: What is going on?

      ; 99: The player needs to be punished at the end of the dialogue.
      If (99 == _iCurrDialogueStage)
         IncreaseTrainingLevel(-1.0, aDialogueTarget)

         _iBadBehaviour += (((_fTrainingLevel As Int) / 25) + 1)
         _iAgendaLongTerm = 3
         _iDetailsLongTerm = 0
         _fTimeLastPunished = 0.0
         _iGagRemaining += (((60 + (120 * _iBadBehaviour)) / _fMcmPollTime) As Int)

         ; If the player's arms are already secure simply gag her.
         If (_qFramework.IsPlayerArmLocked())
            ; 0x0002: Gag
            ; 0x2000: Make sure the Gag is secure
            _iAssault = Math.LogicalOr(0x2000 + 0x0002, _iAssault)
            PlayApproachAnimationOld(aDialogueTarget, "Assault")
         Else
            ; The player can resist.  Perform an assault allowing for a struggle.
            AssaultPlayer(0.3, bUnquipWeapons=True, bStealWeapons=False, bAddArmBinder=True, \
                          bAddGag=True)
         EndIf
      EndIf
   ElseIf (5 == _iCurrDialogue)
      ; 5: Milking the player scene.

      If (1 == _iCurrSceneStage)
         ; The dialogue is complete.  Simply increase the scene stage to progress the scene.
         ModifySceneStage(iDelta=1)
      EndIf
   ElseIf (11 == _iCurrDialogue)
      ; End the current scene.
      _qFramework.SceneDone(S_MOD + "_NoTouching")
   EndIf
EndFunction

; Called by dialogue scripts to indicate the player has completed a conversation.
; iContext: 0: No Relevant Context  1: Leash Game  2: Furniture
;           3: Intermediate Conversation.  The conversation ended but did not resolve any scene.
; iActions uses the same definition as _iFurnitureGoals.
; iSpecialActions: 0x0001: Permit Assisted Dressing
;                  0x0002: Resecure All Restraints
;                  0x0004: Record dialogue results
;                  0x0008: Punish the player.
; iCooperation: How cooperative the player is.  Positive numbers indicate cooperation.
Function DialogueComplete(Int iContext, Int iActions, Actor aNpc, Int iCooperation=0, \
                          Int iSpecialActions=0, Bool bWaitForEnd=True)
   ; Note we are processing end of dialogue so the Monitoring Dialogue knows to wait for us.
   _bCurrDialogueEnding = True

   DebugTrace("TraceEvent DialogueComplete: " + iContext + "-" + iCooperation + "-" + \
              "0x" + _qDfwUtil.ConvertHexToString(iActions, 4) + "-" + \
              "0x" + _qDfwUtil.ConvertHexToString(iSpecialActions, 4))

   ; Choose a random path for the next dialogue.
   _iCurrDialoguePath = Utility.RandomInt(1, 100)

   ; If we are expected to wait for the dialogue to end, do so now.
   If (bWaitForEnd)
      Float fSecurity = 30
      While ((0 < fSecurity) && aNpc.IsInDialogueWithPlayer())
         Utility.Wait(0.05)
         fSecurity -= 0.05
      EndWhile
      DebugTrace("TraceEvent DialogueComplete - Proceeding")
   EndIf

   ; If we were handling a callout end the scene.
   String szCurrScene = _qFramework.GetCurrentScene()
   If (S_MOD + "_CallOut" == szCurrScene)
      _qFramework.CallOutDone()
      _qFramework.SceneDone(szCurrScene)
      szCurrScene = ""
   ElseIf (S_MOD + "_StartDialogue" == szCurrScene)
      _qFramework.SceneDone(szCurrScene)
      szCurrScene = ""
   EndIf

   ; Adjust the actor's disposition based on the cooperation of the player.
   If (0 > iCooperation)
      ; The player is not cooperating.  Consider adjusting the NPC's anger and kindness.
      Int iRandom = Utility.RandomInt(iCooperation, 0)
      If (iRandom)
Log("Increase Anger 9.", DL_DEBUG, S_MOD)
         _qFramework.IncActorAnger(aNpc, 0 - iRandom, 0, 80)
         _qFramework.IncActorKindness(aNpc, 2 * iRandom, 0, 80)
      EndIf
      _iVerbalAnnoyance += 1
   ElseIf (0 < iCooperation)
      ; The player is cooperating.  Decrease the NPC's anger.
Log("Increase Anger 10.", DL_DEBUG, S_MOD)
      _qFramework.IncActorAnger(aNpc, 0 - iCooperation, 0, 80)
      _iVerbalAnnoyance -= 1

      ; If the player is cooperating and not being released.  Increase the NPC's dominance.
      If (!Math.LogicalAnd(0x0002, iActions))
         Int iMax = 60 + (10 * iCooperation)
         Int iRandom = Utility.RandomInt(0, iCooperation)
         If (iRandom)
            _qFramework.IncActorDominance(aNpc, 1, 0, iMax)
         EndIf
      EndIf
   EndIf

   ; If there are any special actions process them first.
   If (iSpecialActions)
      ; 0x0008: Punish the player.
      If (0x0008 <= iSpecialActions)
         iSpecialActions -= 0x0008

         AddPendingAction(8, aActor=aNpc, bPrepend=True)
      EndIf

      ; 0x0004: Record dialogue results
      If (0x0004 <= iSpecialActions)
         iSpecialActions -= 0x0004

         _iCurrDialogueResults = iCooperation
      EndIf

      ; 0x0002: Resecure All Restraints
      If (0x0002 <= iSpecialActions)
         iSpecialActions -= 0x0002

         If (!_qFramework.IsPlayerCollared())
            ; 0x0200: Restrain in Collar
            _iAssault = Math.LogicalOr(0x0200, _iAssault)
         EndIf
         If (_iGagRemaining && !_qFramework.IsPlayerGagged())
            ; 0x0002: Gag
            ; 0x2000: Make sure the Gag is secure
            _iAssault = Math.LogicalOr(0x2000 + 0x0002, _iAssault)
         EndIf
         ; 18: zad_DeviousBlindfold
         If (_iBlindfoldRemaining && !_aPlayer.WornHasKeyword(_aoZadDeviceKeyword[18]))
            ; 0x0400: Blindfold
            _iAssault = Math.LogicalOr(0x0400, _iAssault)
         EndIf
         If (_bFullyRestrained && !_qFramework.IsPlayerHobbled())
            ; 0x4000: Restrain in Boots
            _iAssault = Math.LogicalOr(0x4000, _iAssault)
         EndIf

         ; If some restraints weren't added make sure to extend the player's punishment times.
         If (_iAssault)
            _iBadBehaviour += (((_fTrainingLevel As Int) / 25) + 1)
            If (_iFurnitureRemaining)
               _iFurnitureRemaining += (((180 * _iBadBehaviour) / _fMcmPollTime) As Int)
            EndIf
            If (_iBlindfoldRemaining)
               _iBlindfoldRemaining += ((( 60 * _iBadBehaviour) / _fMcmPollTime) As Int)
            EndIf
            If (_iGagRemaining)
               _iGagRemaining       += (((120 * _iBadBehaviour) / _fMcmPollTime) As Int)
            EndIf
            If (_iBlindfoldRemaining < _iFurnitureRemaining)
               _iBlindfoldRemaining = _iFurnitureRemaining
            EndIf
            If (_iGagRemaining < _iFurnitureRemaining)
               _iGagRemaining = _iFurnitureRemaining
            EndIf
         EndIf
      EndIf

      ; 0x0001: Permit Assisted Dressing
      If (0x0001 <= iSpecialActions)
         iSpecialActions -= 0x0001

         _qFramework.AddPermission(aNpc, _qFramework.AP_DRESSING_ASSISTED)
      EndIf
   EndIf

   _iFurnitureGoals = Math.LogicalOr(iActions, _iFurnitureGoals)
   ; Keep track of the player's cooperation in the _iFurnitureGoals flags.
   If (0 < iCooperation)
      _iFurnitureGoals = Math.LogicalOr(0x0001, _iFurnitureGoals)
   EndIf

   ; If we don't have a current scene we may need to start a new one.
   ; Make sure it is called "DFWS" as that is what it has been historically called.
   If (!szCurrScene)
      szCurrScene = S_MOD
      ; Try to detect furniture for fun scenes.
      ; TODO: We need a more precise mechanism for this.
      If (2 == iContext)
         szCurrScene = S_MOD + "_FurnForFun"
      EndIf
   EndIf

   ; Process any furniture goals/assaults that arose from the conversation.
   If (WARNING == ProcessFurnitureGoals(aNpc, szCurrScene))
      ; WARNING indicates there are no more pending actions.  If this is the case it is the
      ; end of the conversation and may be the end of the scene.  Check if we are in a scene
      ; that should be ended now.
      If (S_MOD + "_FurnForFun" == szCurrScene)
         _qFramework.SceneDone(szCurrScene)
         szCurrScene = ""
      EndIf
   EndIf

   ; If we have completed all short-term goals or the conversation was a result of a
   ; conversation goal reset it.
   If (((1 == iContext) && !_iFurnitureGoals && (0 < _iAgendaShortTerm)) || \
       ((12 <= _iAgendaShortTerm) && (14 >= _iAgendaShortTerm)))
      _iAgendaShortTerm = -2
   EndIf

   ; Process any conversation specific actions that should end when the dialogue does.
   If (_iCurrDialogue)
      If (2 == _iCurrDialogue)
         ; 2: Discipline - Misbehaving while selling items (_dfwsDisciplineSellItems).

         If (0 < iCooperation)
            IncreaseTrainingLevel(1.0, aNpc)
         EndIf
      EndIf
   EndIf

   ; Identify the dialogue is done.
   _iDialogueBusy = 0
   _aDialogueTarget = None
   If (3 == iContext)
      ; If the dialogue did not complete a scene set a small delay to allow for any extra
      ; actions that are needed as part of the dialogue/scene.
      _iDialogueBusy = 2
   EndIf
   _bCurrDialogueEnding = False

   DebugTrace("TraceEvent DialogueComplete: Done")
EndFunction

; Called by the dialogue system to progress the dialogue from one stage to the next.
Function UpdateCurrDialogue(Actor aTarget, Int iDialogue=-1, Int iStage=-1, \
                            Int iStageDelta=-1, Int iPath=-1)
   If (aTarget)
      _aCurrDialogueTarget = aTarget
   EndIf

   ; Make sure we are working with the right dialogue.  Start it if we have to.
   If (-1 != iDialogue)
      ; If the dialogue does not match our current dialogue update to use the specified one.
      If (iDialogue != _iCurrDialogue)
         ; If we thought we were in a dialogue already print a warning.
         If (_iCurrDialogue)
            Log("Warning: Dialogue " + _iCurrDialogue + " interrupted by " + iDialogue, \
                DL_INFO, S_MOD)
         EndIf

         ; The dialogue is just starting.
         _iCurrDialogue = iDialogue
         _iCurrDialogueStage = 0

         ; Choose a random path for the dialogue.
         _iCurrDialoguePath = Utility.RandomInt(1, 100)
      EndIf
   EndIf

   ; Set/increase the dialogue stage as specified.
   If (-1 != iStage)
      _iCurrDialogueStage = iStage
   ElseIf (-1 != iStageDelta)
      _iCurrDialogueStage += iStageDelta
   EndIf

   If (-1 != iPath)
      If (iPath)
         _iCurrDialoguePath = iPath
      Else
         ; Choose a random path for the next dialogue.
         _iCurrDialoguePath = Utility.RandomInt(1, 100)
      EndIf
   EndIf
EndFunction

; Called by the dialogue system to ensure the scene stage variable has advanced to the correct
; stage regardless of which conditions might have caused it to get there.
Function SetSceneStage(Int iNewSceneStage)
   If (iNewSceneStage != _iCurrSceneStage)
      ModifySceneStage(iNewValue=iNewSceneStage)
   EndIf
EndFunction

; A set of functions called by the dialogue system to set data during a scene.
Function SetSceneDataBool(Int iIndex, Bool bValue)
   _abCurrSceneParameter[iIndex] = bValue
EndFunction
Function SetSceneDataFloat(Int iIndex, Float fValue)
   _afCurrSceneParameter[iIndex] = fValue
EndFunction
Function SetSceneDataForm(Int iIndex, Form oValue)
   _aoCurrSceneParameter[iIndex] = oValue
EndFunction
Function SetSceneDataString(Int iIndex, String szValue)
   _aszCurrSceneParameter[iIndex] = szValue
EndFunction

; Handles processing of the currently active scene for the stage the scene is in.
; iContext: 0: No Relevant Context  1: Leash Game  2: Furniture
;           3: Intermediate Conversation.  The conversation ended but did not resolve any scene.
; iActions uses the same definition as _iFurnitureGoals.
; iSpecialActions: 0x0001: Permit Assisted Dressing
;                  0x0002: Resecure All Restraints
;                  0x0004: Transfer all the player's items to the collector.
; iAdvanceDialogue: How many stages to advance the current dialogue.
; iAdvanceScene: How many stages to advance the current scene.
; iCooperation: How cooperative the player is.  Positive numbers indicate cooperation.
Function ProgressScene(Int iActions, Actor aNpc, Int iAdvanceDialogue=0, Int iAdvanceScene=0, \
                       Int iCooperation=0, Int iSpecialActions=0)
   DebugTrace("TraceEvent ProgressScene: " + iCooperation + "-" + iAdvanceScene + "-" +\
              "0x" + _qDfwUtil.ConvertHexToString(iActions, 4) + "-" + \
              "0x" + _qDfwUtil.ConvertHexToString(iSpecialActions, 4))

   ; Adjust the actor's disposition based on the cooperation of the player.
   If (0 > iCooperation)
      ; The player is not cooperating.  Increase her behaviour count during the scene.
      _iLeashGoalRefusalCount -= iCooperation

      ; Also consider adjusting the NPC's anger and kindness.
      Int iRandom = Utility.RandomInt(iCooperation, 0)
      If (iRandom)
Log("Increase Anger 11.", DL_DEBUG, S_MOD)
         _qFramework.IncActorAnger(aNpc, 0 - iRandom, 0, 80)
         _qFramework.IncActorKindness(aNpc, 2 * iRandom, 0, 80)
      EndIf
      _iVerbalAnnoyance += 1
   ElseIf (0 < iCooperation)
      ; The player is cooperating.  Decrease the NPC's anger.
Log("Increase Anger 12.", DL_DEBUG, S_MOD)
      _qFramework.IncActorAnger(aNpc, 0 - iCooperation, 0, 80)
      _iVerbalAnnoyance -= 1

      ; If the player is cooperating and not being released.  Increase the NPC's dominance.
      If (!Math.LogicalAnd(0x0002, iActions))
         Int iMax = 60 + (10 * iCooperation)
         Int iRandom = Utility.RandomInt(0, iCooperation)
         If (iRandom)
            _qFramework.IncActorDominance(aNpc, 1, 0, iMax)
         EndIf
      EndIf
   EndIf

   ; If there are any special actions process them first.
   If (iSpecialActions)
      ; 0x0004: Transfer all the player's items to the collector.
      If (0x0004 <= iSpecialActions)
         iSpecialActions -= 0x0004

         ; Move all of the player's items to The Dragonborn Collector's Chests.
         _qFramework.TransferItems()

         ; Take the player's gold.
         Int iGoldCount = _aPlayer.GetItemCount(_oGold)
         _aPlayer.RemoveItem(_oGold, iGoldCount, akOtherContainer=aNpc)
         _iGoldStolen += iGoldCount
         _iLeashHolderWealth += iGoldCount
      EndIf

      ; 0x0002: Resecure All Restraints
      If (0x0002 <= iSpecialActions)
         iSpecialActions -= 0x0002

         If (!_qFramework.IsPlayerCollared())
            ; 0x0200: Restrain in Collar
            _iAssault = Math.LogicalOr(0x0200, _iAssault)
         EndIf
         If (_iGagRemaining && !_qFramework.IsPlayerGagged())
            ; 0x0002: Gag
            ; 0x2000: Make sure the Gag is secure
            _iAssault = Math.LogicalOr(0x2000 + 0x0002, _iAssault)
         EndIf
         ; 18: zad_DeviousBlindfold
         If (_iBlindfoldRemaining && !_aPlayer.WornHasKeyword(_aoZadDeviceKeyword[18]))
            ; 0x0400: Blindfold
            _iAssault = Math.LogicalOr(0x0400, _iAssault)
         EndIf
         If (_bFullyRestrained && !_qFramework.IsPlayerHobbled())
            ; 0x4000: Restrain in Boots
            _iAssault = Math.LogicalOr(0x4000, _iAssault)
         EndIf

         ; If some restraints weren't added make sure to extend the player's punishment times.
         If (_iAssault)
            _iBadBehaviour += (((_fTrainingLevel As Int) / 25) + 1)
            If (_iFurnitureRemaining)
               _iFurnitureRemaining += (((180 * _iBadBehaviour) / _fMcmPollTime) As Int)
            EndIf
            If (_iBlindfoldRemaining)
               _iBlindfoldRemaining += ((( 60 * _iBadBehaviour) / _fMcmPollTime) As Int)
            EndIf
            If (_iGagRemaining)
               _iGagRemaining       += (((120 * _iBadBehaviour) / _fMcmPollTime) As Int)
            EndIf
            If (_iBlindfoldRemaining < _iFurnitureRemaining)
               _iBlindfoldRemaining = _iFurnitureRemaining
            EndIf
            If (_iGagRemaining < _iFurnitureRemaining)
               _iGagRemaining = _iFurnitureRemaining
            EndIf
         EndIf
      EndIf

      ; 0x0001: Permit Assisted Dressing
      If (0x0001 <= iSpecialActions)
         iSpecialActions -= 0x0001

         _qFramework.AddPermission(aNpc, _qFramework.AP_DRESSING_ASSISTED)
      EndIf
   EndIf

   ; TODO: Not sure if we want this.  Either way it should be done as a special action not here.
   If (0x0040 == iActions)
      _qFramework.YankLeash(iOverrideLeashStyle=_qFramework.LS_DRAG, bForceDamage=True)
   EndIf

   _iFurnitureGoals = Math.LogicalOr(iActions, _iFurnitureGoals)
   ; Keep track of the player's cooperation in the _iFurnitureGoals flags.
   If (0 < iCooperation)
      _iFurnitureGoals = Math.LogicalOr(0x0001, _iFurnitureGoals)
   EndIf

   ; Process any furniture goals/assaults that arose from the conversation.
   ProcessFurnitureGoals(aNpc, _szCurrSceneName)

   If (iAdvanceScene)
      ModifySceneStage(iDelta=iAdvanceScene)
   EndIf

   DebugTrace("TraceEvent ProgressScene: Done")
EndFunction

; Called by the dialogue system to clear actors hovering at the end of a scene.
Function ClearHoverPackage(String szModId)
   _qFramework.HoverAtClear(szModId)
EndFunction

Int Function GetLeashGameDuration(Bool bExtend=False)
   ; Figure out how long the leash game will be played for.
   Int iDurationSeconds = (Utility.RandomInt(_qMcm.iDurationMin, _qMcm.iDurationMax) * 60)
   If (bExtend)
      iDurationSeconds = (iDurationSeconds / 2)
   EndIf
   Return ((iDurationSeconds / _fMcmPollTime) As Int)
EndFunction

Function FavouriteCurrentFurniture(ObjectReference oObject=None, Bool bWorkFurniture=False)
   ; 0x0002: Cage
   Int iFlag = 0x0002
   If (!oObject)
      oObject = _qFramework.GetBdsmFurniture()
      ; 0x0001: BDSM Furniture
      iFlag = 0x0001
   ElseIf (bWorkFurniture)
      ; 0x0008: Work Furniture
      ; 0x0020: Public
      iFlag = 0x0028
   EndIf

   ; If this is a cage, guess at it's default closed state based on it's current state.
   If ((0x0002 == iFlag) && (3 <= oObject.GetOpenState()))
      ; 0x0400: Default Closed (Cage doors that start closed)
      iFlag += 0x0400
   EndIf

   ; If the Location doesn't exist most likely we are in the wilderness.  If the Region is
   ; valid it means we are close enough for it to be counted so treat that as the location.
   Location oLocation = _qFramework.GetCurrentLocation()
   Location oRegion = _qFramework.GetCurrentRegion()
   If (!oLocation)
      oLocation = oRegion
   EndIf

   If (MutexLock(_iFavouriteFurnitureMutex))
      ; Only add the furniture if it is valid and not already in the list.
      If (oObject && (-1 == _aoFavouriteFurniture.Find(oObject)))
         _aoFavouriteFurniture = _qDfwUtil.AddFormToArray(_aoFavouriteFurniture, oObject)
         _aoFavouriteCell = _qDfwUtil.AddFormToArray(_aoFavouriteCell, oObject.GetParentCell())
         _aoFavouriteLocation = _qDfwUtil.AddFormToArray(_aoFavouriteLocation, oLocation)
         _aoFavouriteRegion = _qDfwUtil.AddFormToArray(_aoFavouriteRegion, oRegion)
         _aiFavouriteFlags  = _qDfwUtil.AddIntToArray(_aiFavouriteFlags, iFlag)
      EndIf

      MutexRelease(_iFavouriteFurnitureMutex)
   EndIf
EndFunction

; This can be used to get the current flags by passing in 0x0000 for iFlag.
Int Function ToggleFurnitureFlag(ObjectReference oFurniture, Int iFlag)
   ; Figure out which furniture we are toggling the flag for.
   Int iNewFlags
   If (MutexLock(_iFavouriteFurnitureMutex))
      Int iIndex = _aoFavouriteFurniture.Find(oFurniture)
      If (-1 == iIndex)
         Return 0
      EndIf

      ; If the flag is set turn it off.  Otherwise turn it on.
      If (Math.LogicalAnd(_aiFavouriteFlags[iIndex], iFlag))
         _aiFavouriteFlags[iIndex] = _aiFavouriteFlags[iIndex] - iFlag
      Else
         _aiFavouriteFlags[iIndex] = _aiFavouriteFlags[iIndex] + iFlag
      EndIf
      iNewFlags = _aiFavouriteFlags[iIndex]

      MutexRelease(_iFavouriteFurnitureMutex)
   EndIf
   Return iNewFlags
EndFunction

; iIncludeFlags/iExcludeFlags: Flags should match _aiFavouriteFlags
Form[] Function GetFurnitureList(Location oRegion=None, Cell oCell=None, Int iIncludeFlags=0, \
                                 Int iExcludeFlags=0, Bool bExcludeCurrent=False)
   DebugTrace("TraceEvent GetFurnitureList (" + GetFormName(oRegion) + "," + \
              _qDfwUtil.ConvertHexToString(iIncludeFlags, 4) + "," + \
              _qDfwUtil.ConvertHexToString(iExcludeFlags, 4) + ")")
   Form[] aoFurniture
   If (MutexLock(_iFavouriteFurnitureMutex))
      Int iIndex = _aoFavouriteFurniture.Length - 1
      While (0 <= iIndex)
         ; Start by assuming the furniture is valid, then try to prove it isn't.
         Bool bAdd = True
         If (oRegion && (_aoFavouriteRegion[iIndex] != oRegion))
            bAdd = False
         ElseIf (oCell && (_aoFavouriteCell[iIndex] != oCell))
            bAdd = False
         ElseIf (bExcludeCurrent && ((_aoFavouriteFurniture[iIndex] == _oBdsmFurniture) || \
                                     (_aoFavouriteFurniture[iIndex] == _oPunishmentFurniture)))
            bAdd = False
         ElseIf (iIncludeFlags || iExcludeFlags)
            Int iFlags = _aiFavouriteFlags[iIndex]
            If (iIncludeFlags && (iIncludeFlags != Math.LogicalAnd(iIncludeFlags, iFlags)))
               bAdd = False
            ElseIf (iExcludeFlags && Math.LogicalAnd(iExcludeFlags, iFlags))
               bAdd = False
            EndIf
         EndIf
         If (bAdd)
            aoFurniture = _qDfwUtil.AddFormToArray(aoFurniture, _aoFavouriteFurniture[iIndex])
         EndIf
         iIndex -= 1
      EndWhile

      MutexRelease(_iFavouriteFurnitureMutex)
   EndIf
   DebugTrace("TraceEvent GetFurnitureList: Done: " + aoFurniture.Length)
   Return aoFurniture
EndFunction

; Gets a random furniture matching the specified parameters.
; iReason: The reason the furniture is needed.
;          0: No reason. 1: A permanent transfer. 2: Punish the player.
; iIncludeFlags/iExcludeFlags: Flags should match _aiFavouriteFlags
ObjectReference Function GetRandomFurniture(Location oRegion=None, Cell oCell=None, \
                                            Int iIncludeFlags=0, Int iExcludeFlags=0, \
                                            Bool bExcludeCurrent=False, Int iReason=0)
   DebugTrace("TraceEvent GetRandomFurniture (" + iReason + "," + GetFormName(oRegion) + "," + \
              _qDfwUtil.ConvertHexToString(iIncludeFlags, 4) + "," + \
              _qDfwUtil.ConvertHexToString(iExcludeFlags, 4) + ")")
   ; If we are not specifically looking for it don't include work furniture.
   ; 0x0008: Work Furniture
   If (!Math.LogicalAnd(0x0008, iIncludeFlags))
      iExcludeFlags = Math.LogicalOr(0x0008, iExcludeFlags)
   EndIf

   Form[] aoFurnitureList = GetFurnitureList(oRegion, oCell, iIncludeFlags, iExcludeFlags, \
                                             bExcludeCurrent)
   If (!aoFurnitureList.Length)
      DebugTrace("TraceEvent GetRandomFurniture: Done (Empty List)")
      Return None
   EndIf

   Int iRandomIndex = -1

   ; Give a weight to each peice of furniture based on it's flags.
   If (iReason)
      ; Use different weights based on whether it is a transfer or a punishment.
      ; Keep a local copy so we don't have to access another script each time.
      Int iWeightDefault
      Int iWeightFurn
      Int iWeightCage
      Int iWeightBed
      Int iWeightStore
      Int iWeightPublic
      Int iWeightPrivate
      Int iWeightRemote
      If (1 == iReason)
         iWeightDefault = _qMcm.iFWeightTransferDefault
         iWeightFurn    = _qMcm.iFWeightTransferFurn
         iWeightCage    = _qMcm.iFWeightTransferCage
         iWeightBed     = _qMcm.iFWeightTransferBed
         iWeightStore   = _qMcm.iFWeightTransferStore
         iWeightPublic  = _qMcm.iFWeightTransferPublic
         iWeightPrivate = _qMcm.iFWeightTransferPrivate
         iWeightRemote  = _qMcm.iFWeightTransferRemote
      Else
         iWeightDefault = _qMcm.iFWeightPunishDefault
         iWeightFurn    = _qMcm.iFWeightPunishFurn
         iWeightCage    = _qMcm.iFWeightPunishCage
         iWeightBed     = _qMcm.iFWeightPunishBed
         iWeightStore   = _qMcm.iFWeightPunishStore
         iWeightPublic  = _qMcm.iFWeightPunishPublic
         iWeightPrivate = _qMcm.iFWeightPunishPrivate
         iWeightRemote  = _qMcm.iFWeightPunishRemote

         ; If we haven't met the bad behaviour requirement for remote don't use it.
         If (_iBadBehaviour < _qMcm.iPunishMinBehaviourRemote)
            iWeightRemote = -99999
         EndIf
      EndIf

      ; Create an array to hold the weight of each furniture.
      Int[] aiWeight = Utility.CreateIntArray(aoFurnitureList.Length)

      String szDebugReport = ""

      ; Assign a weight for each peice of furniture.
      Int iTotalWeight
      Int iIndex
      Int iTotalFurniture = aoFurnitureList.Length
      While (iIndex < iTotalFurniture)
         Int iFlags = ToggleFurnitureFlag((aoFurnitureList[iIndex] As ObjectReference), 0x0000)
         Int iWeight = iWeightDefault
         ; 0x0400: Default Closed (Cage doors that start closed)
         If (0x0400 <= iFlags)
            iFlags -= 0x0400
         EndIf

         ; 0x0200: Milking Furniture
         If (0x0200 <= iFlags)
            iFlags -= 0x0200
         EndIf

         ; 0x0100: Activity/Sandbox (NPCs can sandbox nearby)
         If (0x0100 <= iFlags)
            iFlags -= 0x0100
         EndIf

         ; 0x0080: Remote
         If (0x0080 <= iFlags)
            iFlags -= 0x0080
            iWeight += iWeightRemote
         EndIf

         ; 0x0040: Private
         If (0x0040 <= iFlags)
            iFlags -= 0x0040
            iWeight += iWeightPrivate
         EndIf

         ; 0x0020: Public
         If (0x0020 <= iFlags)
            iFlags -= 0x0020
            iWeight += iWeightPublic
         EndIf

         ; 0x0010: Store
         If (0x0010 <= iFlags)
            iFlags -= 0x0010
            iWeight += iWeightStore
         EndIf

         ; 0x0008: Work Furniture
         If (0x0008 <= iFlags)
            iFlags -= 0x0008
         EndIf

         ; 0x0004: Bed
         If (0x0004 <= iFlags)
            iFlags -= 0x0004
            iWeight += iWeightBed
         EndIf

         ; 0x0002: Cage
         If (0x0002 <= iFlags)
            iFlags -= 0x0002
            iWeight += iWeightCage
         EndIf

         ; 0x0001: BDSM Furniture
         If (0x0001 <= iFlags)
            iFlags -= 0x0001
            iWeight += iWeightFurn
         EndIf

         If (szDebugReport)
            szDebugReport += ","
         EndIf
         szDebugReport += iWeight

         If (0 > iWeight)
            iWeight = 0
         EndIf

         aiWeight[iIndex] = iWeight
         iTotalWeight += iWeight
         iIndex += 1
      EndWhile

      If (iTotalWeight)
         ; Find a random value within the total weight range.
         Int iRandomWeight = Utility.RandomInt(0, iTotalWeight)

         szDebugReport = iRandomWeight + "/" + iTotalWeight + " (" + szDebugReport + ")"

         ; Convert that to an index based on each furniture's calculated weight.
         iRandomIndex = 0
         While (0 < iRandomWeight)
            If (iRandomWeight > aiWeight[iRandomIndex])
               iRandomIndex += 1
            EndIf
            iRandomWeight -= aiWeight[iRandomIndex]
         EndWhile
      EndIf

      Log("FWeight Roll: " + iRandomIndex + ": " + szDebugReport, DL_TRACE, S_MOD)
   EndIf

   ; If we didn't come up with a valid index, select one at random.
   If (-1 == iRandomIndex)
      iRandomIndex = Utility.RandomInt(0, aoFurnitureList.Length - 1)
   EndIf

   DebugTrace("TraceEvent GetRandomFurniture: Done: " + \
              GetDisplayName((aoFurnitureList[iRandomIndex] As ObjectReference)))
   Return (aoFurnitureList[iRandomIndex] As ObjectReference)
EndFunction

Form[] Function GetFavouriteFurniture()
   Form[] _aoSnapshotFurniture
   If (MutexLock(_iFavouriteFurnitureMutex))
      _aoSnapshotFurniture = _aoFavouriteFurniture

      MutexRelease(_iFavouriteFurnitureMutex)
   EndIf
   Return _aoSnapshotFurniture
EndFunction

Form[] Function GetFavouriteCell()
   Form[] _aoSnapshotCell
   If (MutexLock(_iFavouriteFurnitureMutex))
      _aoSnapshotCell = _aoFavouriteCell

      MutexRelease(_iFavouriteFurnitureMutex)
   EndIf
   Return _aoSnapshotCell
EndFunction

Form[] Function GetFavouriteLocation()
   Form[] _aoSnapshotLocation
   If (MutexLock(_iFavouriteFurnitureMutex))
      _aoSnapshotLocation = _aoFavouriteLocation

      MutexRelease(_iFavouriteFurnitureMutex)
   EndIf
   Return _aoSnapshotLocation
EndFunction

Form[] Function GetFavouriteRegion()
   Form[] _aoSnapshotRegion
   If (MutexLock(_iFavouriteFurnitureMutex))
      _aoSnapshotRegion = _aoFavouriteRegion

      MutexRelease(_iFavouriteFurnitureMutex)
   EndIf
   Return _aoSnapshotRegion
EndFunction

Function RemoveFavourite(Int iIndex)
   If (MutexLock(_iFavouriteFurnitureMutex))
      ; If this is a cage there are more things to remove.
      ; 0x0002: Cage
      If (Math.LogicalAnd(0x0002, _aiFavouriteFlags[iIndex]))
         ; Clear the cage from the location array as well.
         Int iCageIndex = \
            GetFavouriteCageIndex((_aoFavouriteFurniture[iIndex] As ObjectReference), True)
         Int iLastIndex = _afFavouriteCageLocations.Length - 1
         If (iLastIndex >= ((iCageIndex * 3) + 2))
            _afFavouriteCageLocations = \
               _qDfwUtil.RemoveFloatFromArray(_afFavouriteCageLocations, 0.0, iCageIndex)
            _afFavouriteCageLocations = \
               _qDfwUtil.RemoveFloatFromArray(_afFavouriteCageLocations, 0.0, iCageIndex)
            _afFavouriteCageLocations = \
               _qDfwUtil.RemoveFloatFromArray(_afFavouriteCageLocations, 0.0, iCageIndex)
         EndIf

         ; Clear the cage from the lever array if it has one.
         iCageIndex = _aoFavouriteCageLevers.Find(_aoFavouriteFurniture[iIndex])
         If (-1 != iCageIndex)
            _aoFavouriteCageLevers = _qDfwUtil.RemoveFormFromArray(_aoFavouriteCageLevers, \
                                                                   None, iCageIndex)
            _aoFavouriteCageLevers = _qDfwUtil.RemoveFormFromArray(_aoFavouriteCageLevers, \
                                                                   None, iCageIndex)
         EndIf
      EndIf

      ; Then remove the information common to all furniture.
      _aoFavouriteFurniture = _qDfwUtil.RemoveFormFromArray(_aoFavouriteFurniture, None, iIndex)
      _aoFavouriteCell      = _qDfwUtil.RemoveFormFromArray(_aoFavouriteCell,      None, iIndex)
      _aoFavouriteLocation  = _qDfwUtil.RemoveFormFromArray(_aoFavouriteLocation,  None, iIndex)
      _aoFavouriteRegion    = _qDfwUtil.RemoveFormFromArray(_aoFavouriteRegion,    None, iIndex)
      _aiFavouriteFlags     = _qDfwUtil.RemoveIntFromArray(_aiFavouriteFlags,      0,    iIndex)

      MutexRelease(_iFavouriteFurnitureMutex)
   EndIf
EndFunction

; This function is often called after the mutex has been locked to protect the list changing
; while the indexed cage is accessed.  Is this case we do not lock the mutex here.
Int Function GetFavouriteCageIndex(ObjectReference oCage, Bool bMutexLocked=False)
   Int iFoundIndex = -1
   Int iCageIndex
   Int iIndex
   If (bMutexLocked || MutexLock(_iFavouriteFurnitureMutex))
      Int iTotalFurniture = _aoFavouriteFurniture.Length
      While ((iIndex < iTotalFurniture) && (-1 == iFoundIndex))
         ObjectReference oFurniture = (_aoFavouriteFurniture[iIndex] As ObjectReference)
         If (oCage == oFurniture)
            iFoundIndex = iCageIndex
         ; 0x0002: Cage
         ElseIf (Math.LogicalAnd(0x0002, _aiFavouriteFlags[iIndex]))
            iCageIndex += 1
         EndIf
         iIndex += 1
      EndWhile

      If (!bMutexLocked)
         MutexRelease(_iFavouriteFurnitureMutex)
      EndIf
   EndIf
   Return iFoundIndex
EndFunction

Function SetFavouriteCageLocation(ObjectReference oCage)
   If (MutexLock(_iFavouriteFurnitureMutex))
      Int iCageIndex = GetFavouriteCageIndex(oCage, True)
      If (-1 != iCageIndex)
         ; If the cage location array is missing some cages, fill them in with empty values.
         Int iLastIndex = _afFavouriteCageLocations.Length - 1
         While ((iLastIndex + 1) < (iCageIndex * 3))
            _afFavouriteCageLocations = _qDfwUtil.AddFloatToArray(_afFavouriteCageLocations, \
                                                                  0.0)
            _afFavouriteCageLocations = _qDfwUtil.AddFloatToArray(_afFavouriteCageLocations, \
                                                                  0.0)
            _afFavouriteCageLocations = _qDfwUtil.AddFloatToArray(_afFavouriteCageLocations, \
                                                                  0.0)
            iLastIndex += 3
         EndWhile

         If (iLastIndex < (iCageIndex * 3))
            _afFavouriteCageLocations = _qDfwUtil.AddFloatToArray(_afFavouriteCageLocations, \
                                                                  _aPlayer.X)
            _afFavouriteCageLocations = _qDfwUtil.AddFloatToArray(_afFavouriteCageLocations, \
                                                                  _aPlayer.Y)
            _afFavouriteCageLocations = _qDfwUtil.AddFloatToArray(_afFavouriteCageLocations, \
                                                                  _aPlayer.Z)
         Else
            _afFavouriteCageLocations[iCageIndex] = _aPlayer.X
            _afFavouriteCageLocations[iCageIndex] = _aPlayer.Y
            _afFavouriteCageLocations[iCageIndex] = _aPlayer.Z
         EndIf
      EndIf

      MutexRelease(_iFavouriteFurnitureMutex)
   EndIf
EndFunction

Function SetFavouriteCageLever(ObjectReference oCage, ObjectReference oLever)
   If (MutexLock(_iFavouriteFurnitureMutex))
      Int iIndex = _aoFavouriteCageLevers.Find(oCage)
      If (-1 != iIndex)
         _aoFavouriteCageLevers[iIndex + 1] = oLever
      Else
         _aoFavouriteCageLevers = _qDfwUtil.AddFormToArray(_aoFavouriteCageLevers, oCage)
         _aoFavouriteCageLevers = _qDfwUtil.AddFormToArray(_aoFavouriteCageLevers, oLever)
      EndIf

      MutexRelease(_iFavouriteFurnitureMutex)
   EndIf
EndFunction

ObjectReference Function FindCageLever(ObjectReference oCage)
   ObjectReference oFoundLever = None
   If (MutexLock(_iFavouriteFurnitureMutex))
      Int iIndex = _aoFavouriteCageLevers.Find(oCage)
      If (-1 != iIndex)
         oFoundLever = (_aoFavouriteCageLevers[iIndex + 1] As ObjectReference)
      EndIf

      MutexRelease(_iFavouriteFurnitureMutex)
   EndIf
   Return oFoundLever
EndFunction

Function OpenCageDoor(Actor aNpc, ObjectReference oCage, ObjectReference oLever)
   If (2 < oCage.GetOpenState())
      If (oLever)
         oLever.Activate(aNpc)
      Else
         oCage.Activate(aNpc)
      EndIf

      ; Wait for it to finish opening.
      While (2 == oCage.GetOpenState())
         Utility.Wait(0.1)
      EndWhile
   EndIf
EndFunction

Function CloseCageDoor(Actor aNpc, ObjectReference oCage, ObjectReference oLever)
   If (oLever)
      oLever.Activate(aNpc)
   Else
      oCage.Activate(aNpc)
   EndIf
   ; Give the door some time to start closing.
   Utility.Wait(0.1)

   ; Wait for it to finish closing.
   While (4 == oCage.GetOpenState())
      Utility.Wait(0.1)
   EndWhile

   ; Make sure the door has closed.
   If (3 != oCage.GetOpenState())
      oCage.SetOpen(False)
   EndIf

   ; Some cage doors close to the wrong place.  Try forcing them to their editor location.
   ; 0x0400: Default Closed (Cage doors that start closed)
   If (Math.LogicalAnd(0x0400, ToggleFurnitureFlag(oCage, 0x0000)))
      oCage.MoveToMyEditorLocation()
   EndIf

   oCage.SetLockLevel(255)
   oCage.Lock()
EndFunction

Function ExitCage(Actor aNpc)
   ; Add a delay to ensure the player is in the right position first.
   Utility.Wait(0.1)

   Float fDeltaX = _oBdsmFurniture.X - _aPlayer.X
   If (0.0 < fDeltaX)
      fDeltaX += 50
   Else
      fDeltaX -= 50
   EndIf
   Float fDeltaY = _oBdsmFurniture.Y - _aPlayer.Y
   If (0.0 < fDeltaY)
      fDeltaY += 50
   Else
      fDeltaY -= 50
   EndIf
   aNpc.MoveTo(_aPlayer, fDeltaX, fDeltaY, 0)
EndFunction

Function MoveIntoCage(Actor aNpc, ObjectReference oCage)
   ; For now I am just moving the player to the cage location.
   ; Eventually we want to set up a marker and a movement package or use PathToReference.

   ; Figure out where to move the player to.  First try the cage's "postion" if it is set.
   Float fDeltaX
   Float fDeltaY
   Float fDeltaZ
   If (MutexLock(_iFavouriteFurnitureMutex))
      Int iIndex = GetFavouriteCageIndex(oCage, True)
      If ((-1 != iIndex) && _afFavouriteCageLocations[iIndex * 3])
         fDeltaX = _afFavouriteCageLocations[iIndex * 3]       - _aPlayer.X
         fDeltaY = _afFavouriteCageLocations[(iIndex * 3) + 1] - _aPlayer.Y
         fDeltaZ = _afFavouriteCageLocations[(iIndex * 3) + 2] - _aPlayer.Z
      EndIf

      MutexRelease(_iFavouriteFurnitureMutex)
   EndIf

   ; If we found a place to move to, perform the move (relative to the player's location).
   If (fDeltaX)
      _qFramework.MovePlayer(_aPlayer, fDeltaX, fDeltaY, fDeltaZ)
   Else
      ; Otherwise we don't have a location configured for the cage.  Try to guess.
      Log("Warning: No location for cage: " + oCage.GetDisplayName(), DL_ERROR, S_MOD)
      Utility.Wait(1.0)
      If (aNpc)
         fDeltaX = oCage.X - aNpc.X
         fDeltaY = oCage.Y - aNpc.Y
         fDeltaZ = aNpc.Z - oCage.Z
      Else
         fDeltaX = -20
         fDeltaY = -20
         fDeltaZ = _aPlayer.Z - oCage.Z
      EndIf
      ; Move the player (relative to the cage door this time).
      _qFramework.MovePlayer(oCage, fDeltaX, fDeltaY, fDeltaZ)
   EndIf

   ; Have the player face the cage door.
   Float fZRotation = _aPlayer.GetHeadingAngle(oCage)
   _aPlayer.SetAngle(_aPlayer.GetAngleX(), _aPlayer.GetAngleY(), \
                     _aPlayer.GetAngleZ() + fZRotation)
EndFunction

Function LockPlayerInCage(Actor aNpc, ObjectReference oCage)
   ; Keep track of the lever to open the door.
   ObjectReference oLever = FindCageLever(oCage)

   ; If the door is closed open it first.
   OpenCageDoor(aNpc, oCage, oLever)

   ; Wait as a delay would be more realistic.
   Utility.Wait(0.6)

   ; Force the player into the cage.
   MoveIntoCage(aNpc, oCage)

   ; And finally, close the door, hopefully locking it.
   CloseCageDoor(aNpc, oCage, oLever)
EndFunction

Function ReleasePlayerFromCage(Actor aNpc, ObjectReference oCage)
   Log(GetDisplayName(aNpc) + " starts unlocking your cage.", DL_CRIT, S_MOD)

   ; Open the door for the player.
   OpenCageDoor(aNpc, oCage, FindCageLever(oCage))

   Utility.Wait(2.5)
   oCage.SetLockLevel(0)
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
      ; TODO: A negative FormId can indicate a "dynamically created base object" such as a user
      ; crafted potion.  I'm not sure what to do here regarding these.
      ; https://forums.nexusmods.com/index.php?/topic/2611039-identifying-craftedcreated-potions
      Int iFormId = oForm.GetFormId()
      If (0 <= iFormId)
         Return "0x" + _qDfwUtil.ConvertHexToString(iFormId, 8) + " " + oForm.GetName()
      EndIf
      Return "-0x" + _qDfwUtil.ConvertHexToString(0 - iFormId, 8) + " " + oForm.GetName()
   EndIf
   Return oForm.GetName()
EndFunction

String Function GetAliasInfo(ReferenceAlias aAlias)
   If (!aAlias)
      Return S_NONE + "(" + S_NONE + ")"
   EndIf

   String szAliasInfo = aAlias.GetID() + ": " + aAlias.GetName()

   ObjectReference oContents = aAlias.GetReference()
   If (!oContents)
      szAliasInfo += "(" + S_NONE + ")"
   Else
      szAliasInfo += "(" + GetDisplayName(oContents, True) + ")"
   EndIf
   Return szAliasInfo
EndFunction

String Function GetGlobalInfo(GlobalVariable oGlobal)
   If (!oGlobal)
      Return S_NONE + "(" + S_NONE + ")"
   EndIf

   Return "0x" + _qDfwUtil.ConvertHexToString(oGlobal.GetFormId(), 8) + ": " + \
          oGlobal.GetName() + "(" + oGlobal.GetValue() + ")"
EndFunction

Function DebugFixMutexes()
   Int iIndex = _aiMutex.Length - 1
   While (0 <= iIndex)
      If (0 > _aiMutex[iIndex])
         ; Locking the mutex failed for ten seconds.  Reset it.
         Log("Mutex " + iIndex + " (" + _aszMutexName[iIndex] + ") negative!  Resetting!", \
             DL_CRIT, S_MOD)
         _aiMutex[iIndex] = 0
      Else
         Log("Locking mutex: " + iIndex + "-" + _aszMutexName[iIndex], DL_CRIT, S_MOD)
         If (MutexLock(iIndex, 10000))
            ; Locking the mutex was successful.  It is working so release it.
            MutexRelease(iIndex)
            Log("Success!  Mutex " + _aszMutexName[iIndex] + " is okay!", DL_CRIT, S_MOD)
         Else
            ; Locking the mutex failed for ten seconds.  Reset it.
            Log("Lock failed!  Resetting mutex " + _aszMutexName[iIndex] + "!", DL_CRIT, S_MOD)
            _aiMutex[iIndex] = 0
         EndIf
      EndIf

      iIndex -= 1
   EndWhile
EndFunction

Function DebugDumpVariables()
   String S_LEAD = "\n........................ "

   ;*********************
   ;*** Key Variables ***
   ;*********************
   String szInfo = \
      "DFWS_Variable_Dump - Key Unchanging Variables:" +\
      "\nMod Version: ........... " + GetModVersion() +\
      "\nScript Version: ........ " + _fCurrVer +\
      "\nActor Player: .......... " + GetDisplayName(_aPlayer, True) +\
      "\nQuest MCM: ............. " + GetFormName(_qMcm, True) +\
      "\nQuest Devious Framework: " + GetFormName(_qFramework, True) +\
      "\nQuest DFW Utilities: ... " + GetFormName(_qDfwUtil, True) +\
      "\nQuest SexLab: .......... " + GetFormName(_qSexLab, True) +\
      "\nQuest ZAZ Bondage Shell: " + GetFormName(_qZbfShell, True) +\
      "\nQuest ZAZ Slave Control: " + GetFormName(_qZbfSlave, True) +\
      "\nQuest ZAZ Slave Actions: " + GetFormName(_qZbfSlaveActions, True) +\
      "\nQuest ZAZ Player Slot: . " + GetAliasInfo(_qZbfPlayerSlot) +\
      "\nQuest ZAD Libs: ........ " + GetFormName(_qZadLibs, True) +\
      "\nObject Gold ............ " + GetFormName(_oGold, True)
   Log(szInfo, DL_TRACE, S_MOD)

   ;**************************
   ;*** General Quest Data ***
   ;**************************
   String szCurrScene = "None"
   If (MutexLock(_iCurrSceneMutex))
      szCurrScene = _iCurrScene + "-" + _iCurrSceneStage + " (" + _szCurrSceneName + ": " + \
                    GetDisplayName(_aCurrSceneAgressor, True) + "," + _iCurrSceneTimeout + \
                    "," + _bSceneReadyToEnd + ")"

      MutexRelease(_iCurrSceneMutex)
   EndIf

   szInfo = \
      "DFWS_Variable_Dump - Quest Data:" +\
      "\nAlias Quest Actor 1: ... " + GetAliasInfo(_aAliasQuestActor1) +\
      "\nAlias Quest Actor 2: ... " + GetAliasInfo(_aAliasQuestActor2) +\
      "\nAlias Quest Actor 3: ... " + GetAliasInfo(_aAliasQuestActor3) +\
      "\nCurrent Scene Info: .... " + szCurrScene +\
      "\nCurrent Dialogue Info: . " + _iCurrDialogue + "-" + _iCurrDialogueStage + "-" + \
         _iCurrDialoguePath +\
      "\nActor Dialogue Target: . " + GetDisplayName(_aCurrDialogueTarget, True) +\
      "\nLast Event Check: ...... " + _iEventCheckLastHour +\
      "\nChance for Assistance: . " + _iChanceForAssistance +\
      "\nPending Assault: ....... 0x" + _qDfwUtil.ConvertHexToString(_iAssault, 8) + "-" + \
         _iAssaultTakeGold +\
      "\nFast Travel Blocked: ... " + _bFastTravelBlocked +\
      "\nResponse Time: ......... " + _iExpectedResponseTime +\
      "\nLast Poll: ............. " + _fLastUpdatePoll +\
      "\nZAZ Cane/Dam/Resist: ... " + GetFormName(_oWeaponZbfCane, True) + "/" + \
         _iZbfCaneBaseDamage + "/" + _szZbfCaneResistance +\
      "\nSD+ Active: ............ " + _bEnslavedSdPlus +\
      "\nGlobal SD+ Caged State:  " + _bCagedSdPlus + "-" + GetGlobalInfo(_gSdPlusStateCaged)
   Log(szInfo, DL_TRACE, S_MOD)

   ;***********************
   ;*** Pending Actions ***
   ;***********************
   Int iLineCount = 0
   If (MutexLock(_iPendingActionMutex))
      iArrayLength = _aiPendingAction.Length
      szInfo = \
         "DFWS_Variable_Dump - Pending Actions:" +\
         "\nArray Sizes: ........... " + iArrayLength + "/" + _aoPendingActor.Length + "/" + \
            _aiPendingDetails.Length + "/" + _afPendingDetails.Length + "/" + \
            _aszPendingScene.Length + "/" + _aiPendingTimeout.Length

      Int iIndex = 0
      While (iIndex < iArrayLength)
         String szAction = "Unknown"
         If (1 == _aiPendingAction[iIndex])
            szAction = "Conversation-" + _aiPendingDetails[iIndex]
         ElseIf (2 == _aiPendingAction[iIndex])
            szAction = "Assault Player-0x" + \
               _qDfwUtil.ConvertHexToString(_aiPendingDetails[iIndex], 8)
         ElseIf (3 == _aiPendingAction[iIndex])
            szAction = "Furniture Assault-0x" + \
               _qDfwUtil.ConvertHexToString(_aiPendingDetails[iIndex], 8)
         ElseIf (4 == _aiPendingAction[iIndex])
            szAction = "Scene-" + _aiPendingDetails[iIndex]
         ElseIf (5 == _aiPendingAction[iIndex])
            szAction = "Sandbox"
         ElseIf (6 == _aiPendingAction[iIndex])
            szAction = "Delay-" + _afPendingDetails[iIndex]
         ElseIf (7 == _aiPendingAction[iIndex])
            szAction = "Punishment-" + _aiPendingDetails[iIndex]
         EndIf
         szInfo += "\n" + szAction + " (" + _aszPendingScene[iIndex] + "-" + \
                   _aiPendingTimeout[iIndex] + "," + \
                   GetDisplayName((_aoPendingActor[iIndex] As Actor), True) + ")"

         ; Don't store more than ten lines at any time in the szInfo variable.
         iLineCount += 1
         If (!(iLineCount % 10))
            Log(szInfo, DL_TRACE, S_MOD)
            szInfo = "DFWS_Variable_Dump - Pending Actions Continued:"
         EndIf

         iIndex += 1
      EndWhile

      MutexRelease(_iPendingActionMutex)
   EndIf
   If (iLineCount % 10)
      Log(szInfo, DL_TRACE, S_MOD)
   EndIf

   ;***************
   ;*** Mutexes ***
   ;***************
   Int iArrayLength = _aiMutex.Length
   szInfo = \
      "DFWS_Variable_Dump - Mutexes:" +\
      "\nCount/Next: ............ " + iArrayLength + "/" + _iMutexNext
   Int iIndex = 0
   While (iIndex < iArrayLength)
      String szIndex = iIndex
      If (10 > iIndex)
         szIndex = "0" + iIndex
      EndIf
      szInfo += S_LEAD + szIndex + ": " + _aiMutex[iIndex] + " (" + _aszMutexName[iIndex] + ")"
      iIndex += 1
   EndWhile
   Log(szInfo, DL_TRACE, S_MOD)

   ;******************
   ;*** Leash Game ***
   ;******************
   szInfo = \
      "DFWS_Variable_Dump - Leash Game:" +\
      "\nDuration: .............. " + _iLeashGameDuration +\
      "\nCooldown: .............. " + _iLeashGameCooldown + " (" + _iLeashGameReduction + \
         "," + _fLeashCoolDownStart + "/" + _fLeashCoolDownTotal + ")" +\
      "\nAlias Leash Holder: .... " + GetAliasInfo(_aAliasLeashHolder) +\
      "\nAlias Last Leash Holder: " + GetAliasInfo(_aAliasLastLeashHolder) +\
      "\nActor Leash Holder: .... " + GetDisplayName(_aLeashHolder, True) +\
      "\nAgenda Long Term: ...... " + _iAgendaLongTerm + "-" + _iDetailsLongTerm +\
      "\nAgenda Mid Term: ....... " + _iAgendaMidTerm +\
      "\nAgenda Short Term: ..... " + _iAgendaShortTerm +\
      "\nTime Enslaved: ......... " + _fTimeEnslaved +\
      "\nTime Punished: ......... " + _fTimePunished +\
      "\nTraining Level: ........ " + _fTrainingLevel +\
      "\nRefusal Count: ......... " + _iLeashGoalRefusalCount +\
      "\nBad Behaviour: ......... " + _iBadBehaviour +\
      "\nPunishments: ........... 0x" + _qDfwUtil.ConvertHexToString(_iPunishments, 4) +\
      "\nPunishment Blindfold: .. " + _iBlindfoldRemaining + "-" + _bReleaseBlindfold +\
      "\nPunishment Gag: ........ " + _iGagRemaining + "-" + _bReleaseGag +\
      "\nPunishment Furniture: .. " + _iFurnitureRemaining + "-" + _bReleaseGag +\
      "\nWalk In Front Count: ... " + _iCurrWalkInFrontCount + "-" + _iTotalWalkInFrontCount +\
      "\nVerbal Annoyance: ...... " + _iVerbalAnnoyance +\
      "\nPermanency: ............ " + _bPermanency +\
      "\nWeapons Stolen: ........ " + _iWeaponsStolen +\
      "\nFinding Items: ......... " + _bFindItems +\
      "\nGag Used: .............. " + GetFormName(_oGag, True) +\
      "\nArm Restraint Used: .... " + GetFormName(_oArmRestraint, True) +\
      "\nLeg Restraint Used: .... " + GetFormName(_oLegRestraint, True) +\
      "\nCollar Used: ........... " + GetFormName(_oCollar, True) +\
      "\nBlindfold Used: ........ " + GetFormName(_oBlindfold, True) +\
      "\nMittens Used: .......... " + GetFormName(_oMittens, True) +\
      "\nIs Male: ............... " + _bIsLeashHolderMale +\
      "\nStored Confidence: ..... " + _fPreviousConfidence +\
      "\nMoving/Position: ....... " + _bLeashHolderStopped + " (" + _iLeashHolderMoving + \
         "," + _iLeashHolderStationary + ") <" + _aiLeashHolderCurrPos[0] + "," + \
         _aiLeashHolderCurrPos[1] + "," + _aiLeashHolderCurrPos[2] + ">" +\
      "\nMovement Safety: ....... " + _iMovementSafety +\
      "\nSandbox Time: .......... " + _fMasterSandboxTime +\
      "\nRe-equip Weapons: ...... " + _bReequipWeapons +\
      "\nEnslavement Allowed: ... " + _bIsEnslaveAllowed +\
      "\nIn Combat: ............. " + _bIsInCombat +\
      "\nFully Restrained: ...... " + _bFullyRestrained + "-" + _bIsCompleteSlave +\
      "\nUngagged: .............. " + _bPlayerUngagged +\
      "\nDialogue: .............. " + _iDialogueBusy + "-" + \
         GetDisplayName(_aDialogueTarget, True)
   Log(szInfo, DL_TRACE, S_MOD)

   ;*************************
   ;*** Furniture For Fun ***
   ;*************************
   szInfo = \
      "DFWS_Variable_Dump - Furniture For Fun:" +\
      "\nFurniture For Fun: ..... " + _bFurnitureForFun +\
      "\nFurniture Assault: ..... 0x" + _qDfwUtil.ConvertHexToString(_iFurnitureGoals, 4) +\
      "\nAuto Release: .......... " + _fFurnitureReleaseTime +\
      "\nAlias Furniture Locker:  " + GetAliasInfo(_aAliasFurnitureLocker) +\
      "\nFurniture Current: ..... " + GetDisplayName(_oBdsmFurniture, True) +\
      "\nFurniture Punishment: .. " + GetDisplayName(_oPunishmentFurniture, True) +\
      "\nFurniture Transfer: .... " + GetDisplayName(_oTransferFurniture, True) +\
      "\nFurniture Hidden: ...... " + GetDisplayName(_oHiddenFurniture, True) +\
      "\nIs Caged: .............. " + _bIsPlayerCaged +\
      "\nIs Remote: ............. " + _bIsPlayerRemote
   Log(szInfo, DL_TRACE, S_MOD)

   ;***************************
   ;*** Favourite Furniture ***
   ;***************************
   iLineCount = 0
   Int iArrayLengthFurniture = _aoFavouriteFurniture.Length
   Int iArrayLengthFlags = _aiFavouriteFlags.Length
   Int iArrayLengthLocations = _aoFavouriteLocation.Length
   Int iArrayLengthRegions = _aoFavouriteRegion.Length
   Int iArrayLengthCells = _aoFavouriteCell.Length
   Int iArrayLengthCageData = _afFavouriteCageLocations.Length
   Int iArrayLengthLevers = _aoFavouriteCageLevers.Length
   szInfo = \
      "DFWS_Variable_Dump - Faviourite Furniture:" +\
      "\nArray Sizes: ........... " + \
         iArrayLengthFurniture + "/" + iArrayLengthFlags + "/" + iArrayLengthLocations + "/" + \
         iArrayLengthRegions   + "/" + iArrayLengthCells + "/" + iArrayLengthCageData + "/" + \
         iArrayLengthLevers
   iArrayLength = iArrayLengthFurniture
   If (iArrayLengthFlags > iArrayLength)
      iArrayLength = iArrayLengthFlags
   EndIf
   If (iArrayLengthLocations > iArrayLength)
      iArrayLength = iArrayLengthLocations
   EndIf
   If (iArrayLengthRegions > iArrayLength)
      iArrayLength = iArrayLengthRegions
   EndIf
   If (iArrayLengthCells > iArrayLength)
      iArrayLength = iArrayLengthCells
   EndIf
   iIndex = 0
   Int iCageIndex = 0
   While (iIndex < iArrayLength)
      Int iFlags = 0x0000
      String szFlags = "Out of Bounds"
      If (iIndex < iArrayLengthFlags)
         iFlags = _aiFavouriteFlags[iIndex]
         szFlags = "0x" + _qDfwUtil.ConvertHexToString(iFlags, 4)
      EndIf
      String szFurniture = "Out of Bounds"
      If (iIndex < iArrayLengthFurniture)
         szFurniture = GetDisplayName((_aoFavouriteFurniture[iIndex] As ObjectReference), True)
      EndIf
      String szIndex = iIndex
      If (10 > iIndex)
         szIndex = "0" + iIndex
      EndIf
      szInfo += "\n" + szIndex + ": " + szFlags + "-" + szFurniture
      ; 0x0002: Cage
      If (Math.LogicalAnd(0x0002, iFlags))
         String szCageData = "<Out of Bounds>"
         If ((iCageIndex * 3) < iArrayLengthCageData)
            Int iCageDataIndex = iCageIndex * 3
            szCageData = "<" + _afFavouriteCageLocations[iCageDataIndex] + "," + \
                               _afFavouriteCageLocations[iCageDataIndex + 1] + "," + \
                               _afFavouriteCageLocations[iCageDataIndex + 2] + ">"
         EndIf
         String szLever = "Out of Bounds"
         If (iCageIndex < iArrayLengthCageData)
            szLever = GetFormName(_aoFavouriteCageLevers[iCageIndex], True)
         EndIf
         szInfo += szCageData + " " + szLever
         iCageIndex += 1
      EndIf
      String szLocation = "Out of Bounds"
      If (iIndex < iArrayLengthLocations)
         szLocation = GetFormName(_aoFavouriteLocation[iIndex], True)
      EndIf
      String szRegion = "Out of Bounds"
      If (iIndex < iArrayLengthRegions)
         szRegion = GetFormName(_aoFavouriteRegion[iIndex], True)
      EndIf
      String szCell = "Out of Bounds"
      If (iIndex < iArrayLengthCells)
         szCell = GetFormName(_aoFavouriteCell[iIndex], True)
      EndIf
      szInfo += " L:" + szLocation + " R:" + szRegion + " C:" + szCell

      ; Don't store more than ten lines at any time in the szInfo variable.
      iLineCount += 1
      If (!(iLineCount % 10))
         Log(szInfo, DL_TRACE, S_MOD)
         szInfo = "DFWS_Variable_Dump - Faviourites Continued:"
      EndIf

      iIndex += 1
   EndWhile
   If (iLineCount % 10)
      Log(szInfo, DL_TRACE, S_MOD)
   EndIf

   ;**********************
   ;*** Simple Slavery ***
   ;**********************
   iLineCount = 0
   szInfo = \
      "DFWS_Variable_Dump - Simple Slavery:" +\
      "\nInternal Door: ......... " + GetDisplayName(_oSimpleSlaveryInternalDoor, True) +\
      "\nAuctioneer: ............ " + GetDisplayName(_aSimpleSlaveryAuctioneer, True)

   iArrayLength = _aoSimpleSlaveryRegion.Length
   szInfo += "Region Count: .......... " + iArrayLength
   iIndex = 0
   While (iIndex < iArrayLength)
      String szIndex = iIndex
      If (10 > iIndex)
         szIndex = "0" + iIndex
      EndIf
      szInfo += S_LEAD + szIndex + ": " + GetFormName(_aoSimpleSlaveryRegion[iIndex], True)

      ; Don't store more than ten lines at any time in the szInfo variable.
      iLineCount += 1
      If (!(iLineCount % 10))
         Log(szInfo, DL_TRACE, S_MOD)
         szInfo = "DFWS_Variable_Dump - Simple Slavery Continued:"
      EndIf

      iIndex += 1
   EndWhile

   iArrayLength = _aoSimpleSlaveryLocation.Length
   szInfo += "Location Count: ........ " + iArrayLength
   iIndex = 0
   While (iIndex < iArrayLength)
      szInfo += S_LEAD + iIndex + ": " + GetFormName(_aoSimpleSlaveryLocation[iIndex], True)

      ; Don't store more than ten lines at any time in the szInfo variable.
      iLineCount += 1
      If (!(iLineCount % 10))
         Log(szInfo, DL_TRACE, S_MOD)
         szInfo = "DFWS_Variable_Dump - Simple Slavery Continued:"
      EndIf

      iIndex += 1
   EndWhile

   iArrayLength = _aoSimpleSlaveryEntranceObject.Length
   szInfo += "Location Entrances: .... " + iArrayLength
   iIndex = 0
   While (iIndex < iArrayLength)
      String szIndex = iIndex
      If (10 > iIndex)
         szIndex = "0" + iIndex
      EndIf
      szInfo += S_LEAD + szIndex + ": " + \
                GetDisplayName(_aoSimpleSlaveryEntranceObject[iIndex], True)

      ; Don't store more than ten lines at any time in the szInfo variable.
      iLineCount += 1
      If (!(iLineCount % 10))
         Log(szInfo, DL_TRACE, S_MOD)
         szInfo = "DFWS_Variable_Dump - Simple Slavery Continued:"
      EndIf

      iIndex += 1
   EndWhile
   If (iLineCount % 10)
      Log(szInfo, DL_TRACE, S_MOD)
   EndIf
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
   Return "3.00"
EndFunction

Float Function GetLastUpdateTime()
   Return _fLastUpdatePoll
EndFunction

Bool Function IsGameOn()
   Return _iLeashGameDuration
EndFunction

Int Function StartLeashGame(Actor aActor)
   DebugTrace("TraceEvent StartLeashGame")
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
      _iAgendaShortTerm = 0
      _iAgendaMidTerm = 2
      _iAgendaLongTerm = 1
      _fTimeLastPunished = Utility.GetCurrentGameTime()
      _iDetailsLongTerm = 0
      _iExpectedResponseTime = 8
      _iLeashGameExcuse = LeashGameFindExcuse(_aLeashHolder)
      _bDialogueFirstEnslaved = True
      _iWeaponsStolen = 0
      _bAllItemsTaken = False

      ; Make sure the leash holder is a member of a crime faction.
      ; TODO: I don't know if this has any affect at all.
;DebugLog("Checking Faction: " + _aLeashHolder.GetCrimeFaction())
      If (None == _aLeashHolder.GetCrimeFaction())
;DebugLog("Adding Faction: " + _oFactionLeashTargetCrime)
         _aLeashHolder.SetCrimeFaction(_oFactionLeashTargetCrime)
      EndIf

      ; If this is not the last NPC to play the leash game reset some personalized stats.
      ObjectReference oLastAlias = _aAliasLastLeashHolder.GetReference()
      If (oLastAlias && (_aLeashHolder != (oLastAlias As Actor)))
         _bPermanency   = False

         _oGag          = None
         _oArmRestraint = None
         _oLegRestraint = None
         _oCollar       = None
         _oBlindfold    = None
         _oMittens      = None

         _oEquipForgePerk   = None
         _iEquipEnchantLevel = 0
         _iEquipPotionLevel  = 0

         _iBadBehaviour = 0
         _aoItemStolen = None
         _bPlayerUngagged = False
         _iGagRemaining = 0
         _iBlindfoldRemaining = 0
         _bReleaseBlindfold = False

         _oLeashHolderOutfitContents.Revert()
         _bLeashHolderOutfitActive = False

         ; Identify any BDSM items the NPC will want to use during the leash game.
         SearchInventory(_aLeashHolder)
         _bFindItems = True
      EndIf

      _bReequipWeapons = False
      _aAliasLastLeashHolder.Clear()
      _aAliasLeashHolder.ForceRefTo(_aLeashHolder)
      DebugTrace("TraceEvent StartLeashGame: Done (Leash Game Started)")
      Return SUCCESS
   EndIf
   DebugTrace("TraceEvent StartLeashGame: Done")
   Return FAIL
EndFunction

