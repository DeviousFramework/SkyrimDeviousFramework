;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 2
Scriptname dfwsTfLus8 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_1
Function Fragment_1(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
dfwsDfwSupport _qQuest = Self.GetOwningQuest() As dfwsDfwSupport
_qQuest.DialogueComplete(3, 0x0000, akSpeaker, 1, iSpeciaActions=0x0001)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
