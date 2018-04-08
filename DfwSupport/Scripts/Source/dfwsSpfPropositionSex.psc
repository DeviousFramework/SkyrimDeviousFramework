;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 3
Scriptname dfwsSpfPropositionSex Extends Scene Hidden

;BEGIN FRAGMENT Fragment_1
Function Fragment_1()
;BEGIN CODE
; Get the object reference for the NPC.
dfwsDfwSupport _qQuest = Self.GetOwningQuest() As dfwsDfwSupport
ReferenceAlias _aAliasQuestActor2 = (_qQuest.GetAlias(8) As ReferenceAlias)

; Make sure the gold sound is not played for beggars.
Actor aNpc = (_aAliasQuestActor2.GetReference() As Actor)
ActorBase oActorBase = (aNpc.GetBaseObject() as ActorBase)
Class oBeggar = (Game.GetFormFromFile(0x0001327B, "Skyrim.esm") As Class) ; Beggar

; Play the gold sound at NPC's location.
If (!oBeggar || !oActorBase || (oBeggar != oActorBase.GetClass()))
   Sound sGold = (Game.GetFormFromFile(0x000334AB, "Skyrim.esm") As Sound) ; ITMGoldDown
   sGold.Play(aNpc)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
dfwsDfwSupport _qQuest = Self.GetOwningQuest() As dfwsDfwSupport
ReferenceAlias _aAliasQuestActor2 = (_qQuest.GetAlias(7) As ReferenceAlias)
_qQuest.ProgressScene(0x0000, (_aAliasQuestActor2.GetReference() As Actor), iAdvanceScene=1)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
