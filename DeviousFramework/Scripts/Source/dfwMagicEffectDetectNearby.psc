Scriptname dfwMagicEffectDetectNearby extends activemagiceffect  
;***********************************************************************************************
; Mod: Devious Framework
;
; Script: Detect Nearby Actors Magic Effect
;
; This script is triggered when a magic effect is applied to an actor.
; It simply passes this event to the Devious Framework mod's main script.
;
; © Copyright 2016 legume-Vancouver of GitHub
; This file is part of the Devious Framework Skyrim mod.
;
; The Devious Framework Skyrim mod is free software: you can redistribute it and/or modify it
; under the terms of the GNU General Public License as published by the Free Software
; Foundation, either version 3 of the License, or (at your option) any later version.
;
; The Devious Framework Skyrim mod is distributed in the hope that it will be useful, but
; WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
; PARTICULAR PURPOSE.  See the GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License along with The Devious
; Framework Skyrim mod.  If not, see <http://www.gnu.org/licenses/>.
;***********************************************************************************************

; A reference to the main framework quest script.
dfwDeviousFramework Property _qFramework Auto

Event OnEffectStart(Actor aTarget, Actor aCaster)
   _qFramework.NearbyActorSeen(aTarget)
EndEvent

