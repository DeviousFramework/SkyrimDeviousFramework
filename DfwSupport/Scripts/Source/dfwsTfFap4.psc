;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 3
Scriptname dfwsTfFap4 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_2
Function Fragment_2(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
dfwsDfwSupport _qQuest = Self.GetOwningQuest() As dfwsDfwSupport
_qQuest.DialogueComplete(2, 0x8200, akSpeaker, -3)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
