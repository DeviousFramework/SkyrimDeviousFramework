Scriptname dfwMagicEffectDetectNearby extends activemagiceffect  

; A reference to the main framework quest script.
dfwDeviousFramework Property _qFramework Auto

Event OnEffectStart(Actor aTarget, Actor aCaster)
   _qFramework.NearbyActorSeen(aTarget)
EndEvent

