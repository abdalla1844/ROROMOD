; #FUNCTION# ====================================================================================================================
; Name ..........: BuilderBaseReport()
; Description ...: Make Resources report of Builders Base
; Syntax ........: BuilderBaseReport()
; Parameters ....:
; Return values .: None
; Author ........: ProMac (05-2017)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2018
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func BuilderBaseReport($bBypass = False, $bSetLog = True)
	PureClickP($aAway, 1, 0, "#0319") ;Click Away
	If _Sleep($DELAYVILLAGEREPORT1) Then Return

	Switch $bBypass
		Case False
			If $bSetLog Then SetLog("تقرير عن القرية الليلية", $COLOR_INFO)
		Case True
			If $bSetLog Then SetLog("تحديث قيم الموارد", $COLOR_INFO)
		Case Else
			If $bSetLog Then SetLog("تقرير غير صحيح!", $COLOR_ERROR)
	EndSwitch

	If Not $bSetLog Then SetLog("تقرير عن القرية", $COLOR_INFO)

	getBuilderCount($bSetLog, True) ; update builder data
	If _Sleep($DELAYRESPOND) Then Return

	$g_aiCurrentLootBB[$eLootTrophyBB] = getTrophyMainScreen(67, 84)
	$g_aiCurrentLootBB[$eLootGoldBB] = getResourcesMainScreen(705, 23)
	$g_aiCurrentLootBB[$eLootElixirBB] = getResourcesMainScreen(705, 72)
	If $bSetLog Then SetLog(" [ذهب]: " & _NumberFormat($g_aiCurrentLootBB[$eLootGoldBB]) & " [اكسير]: " & _NumberFormat($g_aiCurrentLootBB[$eLootElixirBB]) & "[الكؤؤس]: " & _NumberFormat($g_aiCurrentLootBB[$eLootTrophyBB]), $COLOR_SUCCESS)

	If Not $bBypass Then ; update stats
		UpdateStats()
	EndIf
EndFunc   ;==>BuilderBaseReport




