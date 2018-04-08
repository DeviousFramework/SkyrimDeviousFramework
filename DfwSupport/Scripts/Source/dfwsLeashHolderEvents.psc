Scriptname dfwsLeashHolderEvents extends ReferenceAlias  
{Maintains characteristics of an actor that are normally reset when the actor is unloaded.
 In particular characteristics key to leash holder behaviour (confidence and aggression)
 are maintained by this script.
 Additionally character items should be maintainable via this script.}

;***********************************************************************************************
; Mod: DFW Support
;
; Script: Leash Holder Events
;
; Events for maintaining actor characteristics required for proper behaviour of leash holders.
; In particular confidence and aggression must be maintained across unloads to maintain a proper
; combat AI.
;
; © Copyright 2017 legume-Vancouver of GitHub
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
; 1.0 2017-08-24 by legume
; Initial version.
;***********************************************************************************************

;***********************************************************************************************
;***                                      CONSTANTS                                          ***
;***********************************************************************************************
String S_MOD = "DFWS-LHE"


;***********************************************************************************************
;***                                      VARIABLES                                          ***
;***********************************************************************************************
; Main quest (MQ) player friend faction: MQ103TemporaryFriendsFaction.  This faction is actually
; an ally to the player.  We use it to ally the slaver with the player so he protects her in
; combat.
Faction _oFactionTemporaryPlayerAllyMQ103


;***********************************************************************************************
;***                                    INITIALIZATION                                       ***
;***********************************************************************************************
Function InitData()
   ; If the player ally faction has not yet been identified do so now.
   If (!_oFactionTemporaryPlayerAllyMQ103)
      _oFactionTemporaryPlayerAllyMQ103 = \
         (Game.GetFormFromFile(0x0001C5D0, "Skyrim.esm") As Faction)
   EndIf
EndFunction

Event OnInit()
   Log("Initializing Leash Holder Alias.", 2)

   InitData()

   If (!Self)
      Log("Error: No alias on Init!", 2)
      Return
   EndIf

   Actor aSelf = (Self.GetReference() As Actor)
   If (!aSelf)
      Log("Warning: No reference on Init!", 2)
      Return
   EndIf

   ; Overly aggressive actors can start fights with townspeople.  Under aggresive
   ; actors won't defend against enemies.  Make sure the captor's aggression is 1.
   ; For more information see: https://www.creationkit.com/index.php?title=AI_Data_Tab
   aSelf.SetActorValue("Aggression", 1.0)
   aSelf.SetActorValue("Confidence", 3.0)
   aSelf.SetActorValue("Assistance", 1.0)

   ; Make sure the leash holder is an ally of the player so he can defend her.
   If (!aSelf.IsInFaction(_oFactionTemporaryPlayerAllyMQ103))
      aSelf.SetFactionRank(_oFactionTemporaryPlayerAllyMQ103, 0)
   EndIf
EndEvent


;***********************************************************************************************
;***                                        EVENTS                                           ***
;***********************************************************************************************
Event OnLoad()
   Log("Leash Holder Alias Loaded.", 2)

   Actor aSelf = (Self.GetReference() As Actor)
   If (!aSelf)
      Log("Error: Alias loaded but no reference!", 2)
      Return
   EndIf

   InitData()

   ; Overly aggressive actors can start fights with townspeople.  Under aggresive
   ; actors won't defend against enemies.  Make sure the captor's aggression is 1.
   ; For more information see: https://www.creationkit.com/index.php?title=AI_Data_Tab
   aSelf.SetActorValue("Aggression", 1.0)
   aSelf.SetActorValue("Confidence", 3.0)
   aSelf.SetActorValue("Assistance", 1.0)

   ; Make sure the leash holder is an ally of the player so he can defend her.
   If (!aSelf.IsInFaction(_oFactionTemporaryPlayerAllyMQ103))
      aSelf.SetFactionRank(_oFactionTemporaryPlayerAllyMQ103, 0)
   EndIf

   ; Tell the main DFW Support quest script to update it's leash holder data too.
   dfwsDfwSupport qDfwSupport = (Self.GetOwningQuest() As dfwsDfwSupport)
   qDfwSupport.RefreshLeashHolder(aSelf)
EndEvent


;***********************************************************************************************
;***                                  PRIVATE FUNCTIONS                                      ***
;***********************************************************************************************
Function Log(String szMessage, Int iLevel=0, Int iClass=0)
   szMessage = "[" + S_MOD + "] " + szMessage

   ; Log to the papyrus file.
   Debug.Trace(szMessage)

   ; Also log to the Notification area of the screen.
   If (2 <= iLevel)
      Debug.Notification(szMessage)
   EndIf
EndFunction


;***********************************************************************************************
;***                                   PUBLIC FUNCTIONS                                      ***
;***********************************************************************************************
