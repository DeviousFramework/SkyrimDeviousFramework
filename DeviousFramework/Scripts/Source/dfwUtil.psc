Scriptname dfwUtil extends Quest  
{General Utility functions made public by the Devious Framework module.}

;***********************************************************************************************
; Mod: Devious Framework
;
; Script: Utility
;
; A collection of general utility functions made public with the expectation of backward
; compatability.
;
; Functions made available by this script:
;   String ConvertHexToString(Int iHexValue, Int iMinLength)
;      Int ConvertStringToHex(String szHexString)
;    Int[] AddIntToArray(Int[] aiArray, Int iNewItem, Bool bPrepend)
; String[] AddStringToArray(String[] aszArray, String szNewItem, Bool bPrepend)
;  Float[] AddFloatToArray(Float[] afArray, Float fNewItem, Bool bPrepend)
;   Form[] AddFormToArray(Form[] aoArray, Form oNewItem, Bool bPrepend)
;    Int[] RemoveIntFromArray(Int[] aiArray, Int iItem, Int iPos)
; String[] RemoveStringFromArray(String[] aszArray, String szItem, Int iPos)
;  Float[] RemoveFloatFromArray(Float[] afArray, Float fItem, Int iPos)
;   Form[] RemoveFormFromArray(Form[] aoArray, Form oItem, Int iPos)
;          TeleportToward(ObjectReference oTarget, Int iPercent, Bool bRotate)
;     Bool IsChestSlot(Int iSlotMask)
;     Bool IsWaistSlot(Int iSlotMask)
;     Bool IsBodySlot(Int iSlotMask)
;     Bool IsFeetSlot(Int iSlotMask)
;     Bool IsNight()
;      Int iMutexCreate(String szName, Int iTimeoutMs)
;     Bool MutexLock(Int iMutex, Int iTimeoutMs)
;          MutexRelease(Int iMutex)
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
;
; History:
; 1.0 2016-06-07 by legume
; Initial version.
;***********************************************************************************************

;***********************************************************************************************
;***                                      CONSTANTS                                          ***
;***********************************************************************************************
; Clothing slot (CS_) constants.
Int CS_BODY      = 0x00000004
Int CS_FEET      = 0x00000080


;***********************************************************************************************
;***                                      VARIABLES                                          ***
;***********************************************************************************************
; A local variable to store a reference to the player for faster access.
Actor _aPlayer

; Version control for this script.
; Note: This is versioning control for the script.  It is unrelated to the mod version.
Float _fCurrVer = 0.00

; A reference to the MCM quest script.
dfwMCM _qMcm

; A set of variables to manage mutexes.  Since variables are pass-by-value scripts can't declare
; their own mutex variables.
Int[] _aiMutex
String[] _aszMutexName
Int _iMutexNext



;***********************************************************************************************
;***                                    INITIALIZATION                                       ***
;***********************************************************************************************
; This is called from the main Devious Framework script script when a game is loaded.
; This function is primarily to ensure new variables are initialized for new script versions.
Function OnPlayerLoadGame()
   ; Reset the version number.
   ; _fCurrVer = 0.00

   ; Very basic initialization.
   If (0.01 > _fCurrVer)
      _aPlayer = Game.GetPlayer()
      _qMcm = (Self As Quest) As dfwMCM
   EndIf

   ; If the script is at the current version we are done.
   Float fScriptVer = 0.02
   If (fScriptVer == _fCurrVer)
      Return
   EndIf

   ; Added support for mutexes.
   If (0.02 > _fCurrVer)
      ; Create an initial mutex for protecting the mutex list.
      _aiMutex      = New Int[1]
      _aszMutexName = New String[1]
      _aiMutex[0]      = 0
      _aszMutexName[0] = "Mutex List Mutex"
      _iMutexNext      = 1
   EndIf

   ; Finally update the version number.
   _fCurrVer = fScriptVer
EndFunction


;***********************************************************************************************
;***                                        EVENTS                                           ***
;***********************************************************************************************

;***********************************************************************************************
;***                                  PRIVATE FUNCTIONS                                      ***
;***********************************************************************************************

;***********************************************************************************************
;***                                   PUBLIC FUNCTIONS                                      ***
;***********************************************************************************************
String Function ConvertHexToString(Int iHexValue, Int iMinLength=0)
   String szHexString
   While (iHexValue)
      Int iDigit = iHexValue % 16
      String szChar

      If (10 > iDigit)
         szChar = iDigit
      ElseIf (10 == iDigit)
         szChar = "A"
      ElseIf (11 == iDigit)
         szChar = "B"
      ElseIf (12 == iDigit)
         szChar = "C"
      ElseIf (13 == iDigit)
         szChar = "D"
      ElseIf (14 == iDigit)
         szChar = "E"
      ElseIf (15 == iDigit)
         szChar = "F"
      EndIf

      szHexString = szChar + szHexString
      iHexValue /= 16
   EndWhile

   While (iMinLength > StringUtil.GetLength(szHexString))
      szHexString = "0" + szHexString
   EndWhile
   Return szHexString
EndFunction

Int Function ConvertStringToHex(String szHexString)
   Int iHexValue
   Int iPlace = 1
   Int iStrLength = StringUtil.GetLength(szHexString)
   While (iStrLength)
      String szChar = StringUtil.GetNthChar(szHexString, iStrLength - 1)
      Int iDigit
      If (("A" == szChar) || ("a" == szChar))
         iDigit = 10
      ElseIf (("B" == szChar) || ("b" == szChar))
         iDigit = 11
      ElseIf (("C" == szChar) || ("c" == szChar))
         iDigit = 12
      ElseIf (("D" == szChar) || ("d" == szChar))
         iDigit = 13
      ElseIf (("E" == szChar) || ("e" == szChar))
         iDigit = 14
      ElseIf (("F" == szChar) || ("f" == szChar))
         iDigit = 15
      ElseIf ("x" == szChar)
         ; An "x" indicates we are finished with the string, e.g. 0x0482.
         Return iHexValue
      Else
         ; There is probably a better string => number conversion but I haven't found it.
         iDigit = StringUtil.AsOrd(szChar) - 48
      EndIf

      iHexValue += (iDigit * iPlace)

      iPlace *= 16
      szHexString = StringUtil.Substring(szHexString, 0, iStrLength - 1)
      iStrLength -= 1
   EndWhile
   Return iHexValue
EndFunction

Int[] Function AddIntToArray(Int[] aiArray, Int iNewItem, Bool bPrepend=False)
   ; Keep track of the length of the array.
   Int iLength = aiArray.Length

   ; Create an array with one extra element.
   Int[] aiNewArray = Utility.CreateIntArray(iLength + 1)

   ; If we are supposed to prepend the element add it now.
   Int iOffset = 0
   If (bPrepend)
      aiNewArray[0] = iNewItem
      iOffset = 1
   EndIf

   ; Create the new array and fill it with the elements of the array.
   Int iIndex
   While (iIndex < iLength)
      aiNewArray[iIndex + iOffset] = aiArray[iIndex]
      iIndex += 1
   EndWhile

   ; Add the new element.
   If (!bPrepend)
      aiNewArray[iLength] = iNewItem
   EndIf

   Return aiNewArray
EndFunction

String[] Function AddStringToArray(String[] aszArray, String szNewItem, Bool bPrepend=False)
   ; Keep track of the length of the array.
   Int iLength = aszArray.Length

   ; Create an array with one extra element.
   String[] aszNewArray = Utility.CreateStringArray(iLength + 1)

   ; If we are supposed to prepend the element add it now.
   Int iOffset = 0
   If (bPrepend)
      aszNewArray[0] = szNewItem
      iOffset = 1
   EndIf

   ; Create the new array and fill it with the elements of the array.
   Int iIndex
   While (iIndex < iLength)
      aszNewArray[iIndex + iOffset] = aszArray[iIndex]
      iIndex += 1
   EndWhile

   ; Add the new element.
   If (!bPrepend)
      aszNewArray[iLength] = szNewItem
   EndIf

   Return aszNewArray
EndFunction

Float[] Function AddFloatToArray(Float[] afArray, Float fNewItem, Bool bPrepend=False)
   ; Keep track of the length of the array.
   Int iLength = afArray.Length

   ; Create an array with one extra element.
   Float[] afNewArray = Utility.CreateFloatArray(iLength + 1)

   ; If we are supposed to prepend the element add it now.
   Int iOffset = 0
   If (bPrepend)
      afNewArray[0] = fNewItem
      iOffset = 1
   EndIf

   ; Create the new array and fill it with the elements of the array.
   Int iIndex
   While (iIndex < iLength)
      afNewArray[iIndex + iOffset] = afArray[iIndex]
      iIndex += 1
   EndWhile

   ; Add the new element.
   If (!bPrepend)
      afNewArray[iLength] = fNewItem
   EndIf

   Return afNewArray
EndFunction

Form[] Function AddFormToArray(Form[] aoArray, Form oNewItem, Bool bPrepend=False)
   ; Keep track of the length of the array.
   Int iLength = aoArray.Length

   ; Create an array with one extra element.
   Form[] aoNewArray = Utility.CreateFormArray(iLength + 1)

   ; If we are supposed to prepend the element add it now.
   Int iOffset = 0
   If (bPrepend)
      aoNewArray[0] = oNewItem
      iOffset = 1
   EndIf

   ; Create the new array and fill it with the elements of the array.
   Int iIndex
   While (iIndex < iLength)
      aoNewArray[iIndex + iOffset] = aoArray[iIndex]
      iIndex += 1
   EndWhile

   ; Add the new element.
   If (!bPrepend)
      aoNewArray[iLength] = oNewItem
   EndIf

   Return aoNewArray
EndFunction

; Remove the first instance of the integer from the array.
; Either specity the index (iPos) or the element to search for.
Int[] Function RemoveIntFromArray(Int[] aiArray, Int iItem, Int iPos=-1)
   ; Accessing an emptry array can cause game crashes.  If the array is empty return here.
   If (!aiArray || !aiArray.Length)
      Return aiArray
   EndIf

   ; Keep track of the length of the array.
   Int iLength = aiArray.Length

   If (0 > iPos)
      iPos = aiArray.Find(iItem)
   EndIf
   If (0 > iPos)
      Return aiArray
   EndIf

   ; Create the new array and fill it with other elements of the array.
   Int[] aiNewArray = Utility.CreateIntArray(iLength - 1)
   Int iIndex
   While (iPos > iIndex)
      aiNewArray[iIndex] = aiArray[iIndex]
      iIndex += 1
   EndWhile
   While (iLength - 1 > iIndex)
      aiNewArray[iIndex] = aiArray[iIndex+1]
      iIndex += 1
   EndWhile

   Return aiNewArray
EndFunction

; Remove the first instance of the string from the array.
; Either specity the index (iPos) or the element to search for.
String[] Function RemoveStringFromArray(String[] aszArray, String szItem, Int iPos=-1)
   ; Accessing an emptry array can cause game crashes.  If the array is empty return here.
   If (!aszArray || !aszArray.Length)
      Return aszArray
   EndIf

   ; Keep track of the length of the array.
   Int iLength = aszArray.Length

   If (0 > iPos)
      iPos = aszArray.Find(szItem)
   EndIf
   If (0 > iPos)
      Return aszArray
   EndIf

   ; Create the new array and fill it with other elements of the array.
   String[] aszNewArray = Utility.CreateStringArray(iLength - 1)
   Int iIndex
   While (iPos > iIndex)
      aszNewArray[iIndex] = aszArray[iIndex]
      iIndex += 1
   EndWhile
   While (iLength - 1 > iIndex)
      aszNewArray[iIndex] = aszArray[iIndex+1]
      iIndex += 1
   EndWhile

   Return aszNewArray
EndFunction

; Remove the first instance of the float from the array.
; Either specity the index (iPos) or the element to search for.
Float[] Function RemoveFloatFromArray(Float[] afArray, Float fItem, Int iPos=-1)
   ; Accessing an emptry array can cause game crashes.  If the array is empty return here.
   If (!afArray || !afArray.Length)
      Return afArray
   EndIf

   ; Keep track of the length of the array.
   Int iLength = afArray.Length

   If (0 > iPos)
      iPos = afArray.Find(fItem)
   EndIf
   If (0 > iPos)
      Return afArray
   EndIf

   ; Create the new array and fill it with other elements of the array.
   Float[] afNewArray = Utility.CreateFloatArray(iLength - 1)
   Int iIndex
   While (iPos > iIndex)
      afNewArray[iIndex] = afArray[iIndex]
      iIndex += 1
   EndWhile
   While (iLength - 1 > iIndex)
      afNewArray[iIndex] = afArray[iIndex+1]
      iIndex += 1
   EndWhile

   Return afNewArray
EndFunction

; Remove the first instance of the actor from the array.
; Either specity the index (iPos) or the element to search for.
Form[] Function RemoveFormFromArray(Form[] aoArray, Form oItem, Int iPos=-1)
   ; Accessing an emptry array can cause game crashes.  If the array is empty return here.
   If (!aoArray || !aoArray.Length)
      Return aoArray
   EndIf

   ; Keep track of the length of the array.
   Int iLength = aoArray.Length

   If (0 > iPos)
      iPos = aoArray.Find(oItem)
   EndIf
   If (0 > iPos)
      Return aoArray
   EndIf

   ; Create the new array and fill it with other elements of the array.
   Form[] aoNewArray = Utility.CreateFormArray(iLength - 1)
   Int iIndex
   While (iPos > iIndex)
      aoNewArray[iIndex] = aoArray[iIndex]
      iIndex += 1
   EndWhile
   While (iLength - 1 > iIndex)
      aoNewArray[iIndex] = aoArray[iIndex+1]
      iIndex += 1
   EndWhile

   Return aoNewArray
EndFunction

Function TeleportToward(Actor aSource, ObjectReference oTarget, Int iPercent, Bool bRotate=True)
   ; The offset is measured distance from the actor.  The percent is distance from the player.
   iPercent = (100 - iPercent)

   ; Calculate the offset.
   Float fDeltaX = ((aSource.X - oTarget.X) * iPercent / 100)
   Float fDeltaY = ((aSource.Y - oTarget.Y) * iPercent / 100)
   Float fDeltaZ = ((aSource.Z - oTarget.Z) * iPercent / 100)

   ; Move the player closer to the target.  Add 50 to Z for uneven ground.
   aSource.MoveTo(oTarget, fDeltaX, fDeltaY, fDeltaZ + 50, bRotate)
EndFunction

Bool Function IsChestSlot(Int iSlotMask)
   Int iIndex = _qMcm.aiSettingsSlotsChest.Length - 1
   While (0 <= iIndex)
      If (Math.LogicalAnd(iSlotMask, _qMcm.aiSettingsSlotsChest[iIndex]))
         Return True
      EndIf
      iIndex -= 1
   EndWhile
   Return False
EndFunction

Bool Function IsWaistSlot(Int iSlotMask)
   Int iIndex = _qMcm.aiSettingsSlotsWaist.Length - 1
   While (0 <= iIndex)
      If (Math.LogicalAnd(iSlotMask, _qMcm.aiSettingsSlotsWaist[iIndex]))
         Return True
      EndIf
      iIndex -= 1
   EndWhile
   Return False
EndFunction

Bool Function IsBodySlot(Int iSlotMask)
   Return Math.LogicalAnd(iSlotMask, CS_BODY)
EndFunction

Bool Function IsFeetSlot(Int iSlotMask)
   Return Math.LogicalAnd(iSlotMask, CS_FEET)
EndFunction

Bool Function IsNight()
   Float fTime = Utility.GetCurrentGameTime()

   ; Remove "previous in-game days passed" bit
   fTime -= Math.Floor(fTime)

   ; Convert from fraction of a day to number of hours
   fTime = (fTime * 24)

   Return (fTime >= 20 || fTime < 5)
EndFunction

; Warning: These mutexes have poor next process priority selection.  Please allow ample unlocked
;          time to avoid deadlocks.
Int Function iMutexCreate(String szName, Int iTimeoutMs=1000)
   Int iIndex = -1

   ; Lock the mutex protecting the mutex list to avoid creating two mutexes at once.
   If (MutexLock(0, iTimeoutMs))
      iIndex = _aszMutexName.Find(szName)
      If (0 <= iIndex)
         ; This mutex already exists clear it.
         _aiMutex[iIndex] = 0
      Else
         ; Otherwise create a new mutex entry.
         _aiMutex      = AddIntToArray(_aiMutex, 0)
         _aszMutexName = AddStringToArray(_aszMutexName, szName)
         iIndex = _iMutexNext
         _iMutexNext += 1
      EndIf

      ; Release the mutex protecting the mutex list.
      MutexRelease(0)
   EndIf
   Return iIndex
EndFunction

Bool Function MutexLock(Int iMutex, Int iTimeoutMs=1000)
   ; If this is not a valid mutex return a failure.
   If ((0 > iMutex) || (_iMutexNext <= iMutex))
      Return False
   EndIf

   Bool bUseTimeout = (iTimeoutMs As Bool)
   While (0 < _aiMutex[iMutex])
      Utility.Wait(0.1)
      If (bUseTimeout)
         iTimeoutMs -= 100
         If (0 >= iTimeoutMs)
            ; Locking Failed due to timeout.
            Return False
         EndIf
      EndIf
   EndWhile
   ; Locking succeeded.  Increment the mutex and return success.
   _aiMutex[iMutex] = _aiMutex[iMutex] + 1
   Return True
EndFunction

Function MutexRelease(Int iMutex)
   ; If this is a valid mutex decrement it.
   If ((0 <= iMutex) && (_iMutexNext > iMutex))
      _aiMutex[iMutex] = _aiMutex[iMutex] - 1
   EndIf
EndFunction

