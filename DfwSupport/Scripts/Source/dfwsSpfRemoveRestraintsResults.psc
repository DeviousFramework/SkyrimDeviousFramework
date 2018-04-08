;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 3
Scriptname dfwsSpfRemoveRestraintsResults Extends Scene Hidden

;BEGIN FRAGMENT Fragment_1
Function Fragment_1()
;BEGIN CODE
dfwsDfwSupport _qQuest = Self.GetOwningQuest() As dfwsDfwSupport
ReferenceAlias _aAliasQuestActor1 = (_qQuest.GetAlias(6) As ReferenceAlias)
_qQuest.ProgressScene(0x0000, (_aAliasQuestActor1.GetReference() As Actor), iAdvanceScene=1)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
