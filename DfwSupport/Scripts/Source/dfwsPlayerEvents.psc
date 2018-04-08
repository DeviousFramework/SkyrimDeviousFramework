Scriptname dfwsPlayerEvents extends ReferenceAlias  
{Handles Devious Framework events for the player.}
;***********************************************************************************************
; Mod: DFW Support
;
; Script: Player Events
;
; Extends the script of the player to handle any events generated by the player.
;
; Many aspects of this mod are taken from the Deviously Enslaved and Deviously Enslaved
; Continued mods.
; Many thanks to Verstort and Chase Roxand for all of their work on that mod.
;
; � Copyright 2016 legume-Vancouver of GitHub
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
;
; History:
; 1.0 2018-01-06 by legume
; Initial version.
;***********************************************************************************************

dfwsDfwSupport _qDfwSupport

Event OnItemAdded(Form oBaseItem, Int iCount, ObjectReference oItem, \
                  ObjectReference oSourceContainer)
   _qDfwSupport.OnItemAdded(oBaseItem, iCount, oItem, oSourceContainer)
EndEvent

Event OnPlayerLoadGame()
   ; Update all quest variables upon loading each game.
   ; There are too many things that can cause them to become invalid.
   _qDfwSupport = (Self.GetOwningQuest() As dfwsDfwSupport)
EndEvent


