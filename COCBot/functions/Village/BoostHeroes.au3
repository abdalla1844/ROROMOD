; #FUNCTION# ====================================================================================================================
; Name ..........: BoostKing & BoostQueen
; Description ...:
; Syntax ........: BoostKing() & BoostQueen()
; Parameters ....:
; Return values .: None
; Author ........: ProMac 2015
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2018
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func BoostKing()
	; Verifying existent Variables to run this routine
	If AllowBoosting("Barbarian King", $g_iCmbBoostBarbarianKing) = False Then Return

	SetLog("تسريع الملك...", $COLOR_INFO)
	If $g_aiKingAltarPos[0] = "" Or $g_aiKingAltarPos[0] = -1 Then
		LocateKingAltar()
		SaveConfig()
		If _Sleep($DELAYBOOSTHEROES4) Then Return
	EndIf

	If BoostStructure("Barbarian King", "King", $g_aiKingAltarPos, $g_iCmbBoostBarbarianKing, $g_hCmbBoostBarbarianKing) Then $g_aiHeroBoost[$eHeroBarbarianKing] = _NowCalc()
	$g_aiTimeTrain[2] = 0 ; reset Heroes remaining time

	If _Sleep($DELAYBOOSTBARRACKS3) Then Return
	checkMainScreen(False) ; Check for errors during function
EndFunc   ;==>BoostKing


Func BoostQueen()
	; Verifying existent Variables to run this routine
	If AllowBoosting("Archer Queen", $g_iCmbBoostArcherQueen) = False Then Return

	SetLog("تسريع الملكة...", $COLOR_INFO)
	If $g_aiQueenAltarPos[0] = "" Or $g_aiQueenAltarPos[0] = -1 Then
		LocateQueenAltar()
		SaveConfig()
		If _Sleep($DELAYBOOSTHEROES4) Then Return
	EndIf

	If BoostStructure("Archer Queen", "Quee", $g_aiQueenAltarPos, $g_iCmbBoostArcherQueen, $g_hCmbBoostArcherQueen) Then $g_aiHeroBoost[$eHeroArcherQueen] = _NowCalc()
	$g_aiTimeTrain[2] = 0 ; reset Heroes remaining time

	If _Sleep($DELAYBOOSTBARRACKS3) Then Return
	checkMainScreen(False) ; Check for errors during function
EndFunc   ;==>BoostQueen

Func BoostWarden()
	; Verifying existent Variables to run this routine
	If AllowBoosting("Grand Warden", $g_iCmbBoostWarden) = False Then Return

	SetLog("تسريع الأمر الكبير...", $COLOR_INFO)
	If $g_aiWardenAltarPos[0] = "" Or $g_aiWardenAltarPos[0] = -1 Then
		LocateWardenAltar()
		SaveConfig()
		If _Sleep($DELAYBOOSTHEROES4) Then Return
	EndIf

	If BoostStructure("Grand Warden", "Warden", $g_aiWardenAltarPos, $g_iCmbBoostWarden, $g_hCmbBoostWarden) Then $g_aiHeroBoost[$eHeroGrandWarden] = _NowCalc()
	$g_aiTimeTrain[2] = 0 ; reset Heroes remaining time

	If _Sleep($DELAYBOOSTBARRACKS3) Then Return
	checkMainScreen(False) ; Check for errors during function
EndFunc   ;==>BoostWarden
