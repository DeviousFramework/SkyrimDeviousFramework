;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname dfwsTfLgp1 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
dfwsDfwSupport _qQuest = Self.GetOwningQuest() As dfwsDfwSupport
_qQuest.IncDominance(akSpeaker, 1)
_qQuest.Cooperation(6, 1)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
