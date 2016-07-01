Scriptname dfwPlayerEvents extends ReferenceAlias
{Handles Devious Framework events for the player.}
;***********************************************************************************************
; Mod: Devious Framework
;
; Script: Player Events
;
; Extends the script of the player to handle any events generated by the player.
;
; Created by legume
;
; Many aspects of this mod are taken from the Deviously Enslaved and Deviously Enslaved
; Continued mods.
; Many thanks to Verstort and Chase Roxand for all of their work on that mod.
;
; History:
; 1.0 2016-05-26 by legume
; Initial version.
;***********************************************************************************************

dfwDeviousFramework _qFramework

Event OnObjectUnequipped(Form oItem, ObjectReference oReference)
   ; Only process this event if an actual item was unequipped.
   If (oItem)
      _qFramework.ItemUnequipped(oItem, oReference)
Else
Debug.Notification("Unequip-No Item: " + oReference)
Debug.Notification("(" + oReference.GetFormID() + "-" + oReference.GetName() + ")")

   EndIf
EndEvent

Event OnObjectEquipped(Form oItem, ObjectReference oReference)
   ; Only process this event if an actual item was equipped.
   If (oItem)
      _qFramework.ItemEquipped(oItem, oReference)
   EndIf
EndEvent

Event OnPlayerLoadGame()
   ; Make sure we have a valid reference to the main devious framework script.
   If (!_qFramework)
      _qFramework = Self.GetOwningQuest() As dfwDeviousFramework
   EndIf

   ; Forward this event to the main devious framework script.
   _qFramework.OnPlayerLoadGame()
EndEvent

Event OnEnterBleedout()
   _qFramework.EnteredBleedout()
EndEvent
