;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 20
Scriptname dfwsSpfRemoveRestraints Extends Scene Hidden

;BEGIN FRAGMENT Fragment_6
Function Fragment_6()
;BEGIN CODE
dfwsDfwSupport _qQuest = Self.GetOwningQuest() As dfwsDfwSupport
_qQuest.CallOutReset()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_9
Function Fragment_9()
;BEGIN CODE
dfwsDfwSupport _qQuest = Self.GetOwningQuest() As dfwsDfwSupport
_qQuest.CallOutReset()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_12
Function Fragment_12()
;BEGIN CODE
dfwsDfwSupport _qQuest = Self.GetOwningQuest() As dfwsDfwSupport
_qQuest.CallOutReset()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
; Get the object reference for the blacksmith.
dfwsDfwSupport _qQuest = Self.GetOwningQuest() As dfwsDfwSupport
ReferenceAlias _aAliasQuestActor2 = (_qQuest.GetAlias(8) As ReferenceAlias)

; Play the armour sound at blacksmith location.
Sound sArmour = (Game.GetFormFromFile(0x00032877, "Skyrim.esm") As Sound) ; ITMGenericArmorDown
sArmour.Play(_aAliasQuestActor2.GetReference())
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_4
Function Fragment_4()
;BEGIN CODE
dfwsDfwSupport _qQuest = Self.GetOwningQuest() As dfwsDfwSupport
ReferenceAlias _aAliasQuestActor1 = (_qQuest.GetAlias(6) As ReferenceAlias)
_qQuest.ProgressScene(0x0000, (_aAliasQuestActor1.GetReference() As Actor), iAdvanceScene=1)
_qQuest.CallOutReset()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_17
Function Fragment_17()
;BEGIN CODE
dfwsDfwSupport _qQuest = Self.GetOwningQuest() As dfwsDfwSupport
_qQuest.CallOutReset()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_2
Function Fragment_2()
;BEGIN CODE
; Get the object reference for the blacksmith.
dfwsDfwSupport _qQuest = Self.GetOwningQuest() As dfwsDfwSupport
ReferenceAlias _aAliasQuestActor2 = (_qQuest.GetAlias(8) As ReferenceAlias)

; Play the gold sound at blacksmith location.
Sound sGold = (Game.GetFormFromFile(0x000334AB, "Skyrim.esm") As Sound) ; ITMGoldDown
sGold.Play(_aAliasQuestActor2.GetReference())
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_18
Function Fragment_18()
;BEGIN CODE
dfwsDfwSupport _qQuest = Self.GetOwningQuest() As dfwsDfwSupport
_qQuest.CallOutReset()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
