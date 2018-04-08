;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 3
Scriptname dfwsSafSellItems4c Extends Scene Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ReferenceAlias akAlias)
;BEGIN CODE
dfwsDfwSupport _qQuest = Self.GetOwningQuest() As dfwsDfwSupport
ReferenceAlias _aAliasQuestActor1 = (_qQuest.GetAlias(6) As ReferenceAlias)
_qQuest.ProgressScene(0x0040, (_aAliasQuestActor1.GetReference() As Actor), iCooperation=-2)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
