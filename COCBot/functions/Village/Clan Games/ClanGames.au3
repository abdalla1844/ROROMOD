; #FUNCTION# ====================================================================================================================
; Name ..........: Clan Games (V3)
; Description ...: This file contains the Clan Gmes algorithm
; Syntax ........: ---
; Parameters ....: ---
; Return values .: ---
; Author ........: ViperZ And Uncle Xbenk 01-2018
; Modified ......: ProMac 02/2018 [v2 and v3] , ProMac 08/2018 v4
; Remarks .......: This file is part of MyBotRun. Copyright 2018
;                  MyBotRun is distributed under the terms of the GNU GPL
; Related .......: ---
; Link ..........: https://www.mybot.run
; Example .......: ---
;================================================================================================================================

; Main Loop Function
Func _ClanGames($test = False)

	; Check If this Feature is Enable on GUI.
	If Not $g_bChkClanGamesEnabled Then Return

	Local $sINIPath = StringReplace($g_sProfileConfigPath, "config.ini", "ClanGames_config.ini")
	If Not FileExists($sINIPath) Then ClanGamesChallenges("", True, $sINIPath, $g_bChkClanGamesDebug)

	; A user Log and a Click away just in case
	ClickP($aAway, 1, 0, "#0000") ;Click Away to prevent any pages on top
	SetLog("مباريات القبيلة ", $COLOR_INFO)
	If _Sleep(500) Then Return

	; Local and Static Variables
	Local $TabChallengesPosition[2] = [820, 130]
	Local $sTimeRemain = "", $sEventName = "", $getCapture = True
	Local Static $YourAccScore[8][2] = [[-1, True], [-1, True], [-1, True], [-1, True], [-1, True], [-1, True], [-1, True], [-1, True]]

	; Check for BS/CoC errors just in case
	If isProblemAffect(True) Then checkMainScreen(False)

	; Initial Timer
	Local $hTimer = TimerInit()

	; Enter on Clan Games window
	If Not IsClanGamesWindow() Then Return

	If $g_bChkClanGamesDebug Then Setlog("_ClanGames IsClanGamesWindow (in " & Round(TimerDiff($hTimer) / 1000, 2) & " seconds)", $COLOR_INFO)
	$hTimer = TimerInit()

	; Let's get some information , like Remain Timer, Score and limit
	Local $ScoreLimits = GetTimesAndScores()
	If $ScoreLimits = -1 Or UBound($ScoreLimits) <> 2 Then Return

	If $g_bChkClanGamesDebug Then Setlog("_ClanGames GetTimesAndScores (in " & Round(TimerDiff($hTimer) / 1000, 2) & " seconds)", $COLOR_INFO)
	$hTimer = TimerInit()

	; Small delay
	If _Sleep(1500) Then Return

	SetLog("نتيجتك: " & Int($ScoreLimits[0]), $COLOR_INFO)
	If Int($ScoreLimits[0]) = Int($ScoreLimits[1]) Then
		SetLog("تم الوصول إلى حد النقاط الخاص بك ...")
		ClickP($aAway, 1, 0, "#0000") ;Click Away
		Return
	ElseIf Int($ScoreLimits[0]) + 200 > Int($ScoreLimits[1]) Then
		SetLog("اكتمال حد درجاتك...")
		If $g_bChkClanGamesStopBeforeReachAndPurge Then
			If CooldownTime() Then Return
			If IsEventRunning() Then Return
			SetLog("توقف قبل أن تتوقف")
			$sEventName = "Builder Base Challenges to Purge"
			If PurgeEvent($g_sImgPurge, $sEventName, True) Then $g_iPurgeJobCount[$g_iCurAccount] += 1
			ClickP($aAway, 1, 0, "#0000") ;Click Away
			Return
		EndIf
	EndIf
	If $YourAccScore[$g_iCurAccount][0] = -1 Then $YourAccScore[$g_iCurAccount][0] = $ScoreLimits[0]

	; Check IF exist the Gem icon
	;check cooldown purge
	If CooldownTime() Then Return

	If $g_bChkClanGamesDebug Then Setlog("_ClanGames CooldownTime (in " & Round(TimerDiff($hTimer) / 1000, 2) & " seconds)", $COLOR_INFO)
	$hTimer = TimerInit()

	; Variable for Stop button
	If $g_bRunState = False Then Return

	If IsEventRunning() Then Return

	If $g_bChkClanGamesDebug Then Setlog("_ClanGames IsEventRunning (in " & Round(TimerDiff($hTimer) / 1000, 2) & " seconds)", $COLOR_INFO)
	$hTimer = TimerInit()

	If $g_bRunState = False Then Return

	If $g_bChkClanGamesDebug Then SetLog("لفل التاون هول :  " & $g_iTownHallLevel)

	; Check for BS/CoC errors just in case
	If isProblemAffect(True) Then checkMainScreen(False)

	Local $Rows = ["300,155,760,245", "300,315,760,405", "300,475,760,550"]

	; Let's selected only the necessary images [Total=71]
	Local $pathImages = @ScriptDir & "\imgxml\Resources\ClanGamesImages\Challenges"
	Local $pathTemp = @TempDir & "\" & $g_sProfileCurrentName & "\Challenges\"

	If $g_bChkClanGamesLoot Then FileCopy($pathImages & "\L-*.xml", $pathTemp, $FC_OVERWRITE + $FC_CREATEPATH)
	If $g_bChkClanGamesAirTroop Then FileCopy($pathImages & "\A-*.xml", $pathTemp, $FC_OVERWRITE + $FC_CREATEPATH)
	If $g_bChkClanGamesGroundTroop Then FileCopy($pathImages & "\G-*.xml", $pathTemp, $FC_OVERWRITE + $FC_CREATEPATH)
	If $g_bChkClanGamesBattle Then FileCopy($pathImages & "\B-*.xml", $pathTemp, $FC_OVERWRITE + $FC_CREATEPATH)
	If $g_bChkClanGamesDestruction Then FileCopy($pathImages & "\D-*.xml", $pathTemp, $FC_OVERWRITE + $FC_CREATEPATH)
	If $g_bChkClanGamesMiscellaneous Then FileCopy($pathImages & "\M-*.xml", $pathTemp, $FC_OVERWRITE + $FC_CREATEPATH)

	Local $HowManyImages = _FileListToArray($pathTemp, "*", $FLTA_FILES)
	If IsArray($HowManyImages) Then
		Setlog($HowManyImages[0] & " Events to search...")
	Else
		Setlog("ClanGames-Error on $HowManyImages: " & @error)
	EndIf

	; To store the detections
	; [0]=ChallengeName [1]=EventName [2]=Xaxis [3]=Yaxis
	Local $aAllDetectionsOnScreen[0][4]

	; we can make an image detection by row !!! can be faster?!!!
	For $x = 0 To UBound($Rows) - 1

		Setlog("كشف رقم الصف " & $x + 1)
		Local $sClanGamesWindow = GetDiamondFromRect($Rows[$x]) ; Contains iXStart, $iYStart, $iXEnd, $iYEnd
		Local $aCurrentDetection = findMultiple($pathTemp, $sClanGamesWindow, "", 0, 1000, 0, "objectname,objectpoints", True)
		Local $aEachDetection

		If $g_bChkClanGamesDebug Then Setlog("_ClanGames findMultiple (in " & Round(TimerDiff($hTimer) / 1000, 2) & " seconds)", $COLOR_INFO)
		$hTimer = TimerInit()

		; Let's split Names and Coordinates and populate a new array
		If UBound($aCurrentDetection) > 0 Then

			; Temp Variables
			Local $FullImageName, $StringCoordinates, $sString, $tempObbj, $tempObbjs, $aNames

			For $i = 0 To UBound($aCurrentDetection) - 1
				If _Sleep(50) Then Return ; just in case of PAUSE
				If Not $g_bRunState Then Return ; Stop Button

				$aEachDetection = $aCurrentDetection[$i]
				; Justto debug
				SetDebugLog(_ArrayToString($aEachDetection))

				$FullImageName = String($aEachDetection[0])
				$StringCoordinates = $aEachDetection[1]

				If $FullImageName = "" Or $StringCoordinates = "" Then ContinueLoop

				; Exist more than One coordinate!?
				If StringInStr($StringCoordinates, "|") Then
					; Code to test the string if exist anomalies on string
					$StringCoordinates = StringReplace($StringCoordinates, "||", "|")
					$sString = StringRight($StringCoordinates, 1)
					If $sString = "|" Then $StringCoordinates = StringTrimRight($StringCoordinates, 1)
					; Split the coordinates
					$tempObbjs = StringSplit($StringCoordinates, "|", $STR_NOCOUNT)
					; Just get the first [0]
					$tempObbj = StringSplit($tempObbjs[0], ",", $STR_NOCOUNT) ;  will be a string : 708,360
					If UBound($tempObbj) <> 2 Then ContinueLoop
				Else
					$tempObbj = StringSplit($StringCoordinates, ",", $STR_NOCOUNT) ;  will be a string : 708,360
					If UBound($tempObbj) <> 2 Then ContinueLoop
				EndIf

				$aNames = StringSplit($FullImageName, "-", $STR_NOCOUNT)

				ReDim $aAllDetectionsOnScreen[UBound($aAllDetectionsOnScreen) + 1][4]
				$aAllDetectionsOnScreen[UBound($aAllDetectionsOnScreen) - 1][0] = $aNames[0] ; Challenge Name
				$aAllDetectionsOnScreen[UBound($aAllDetectionsOnScreen) - 1][1] = $aNames[1] ; Event Name
				$aAllDetectionsOnScreen[UBound($aAllDetectionsOnScreen) - 1][2] = $tempObbj[0] ; Xaxis
				$aAllDetectionsOnScreen[UBound($aAllDetectionsOnScreen) - 1][3] = $tempObbj[1] ; Yaxis
			Next
		EndIf
	Next

	Local $aSelectChallenges[0][5]

	If UBound($aAllDetectionsOnScreen) > 0 Then
		For $i = 0 To UBound($aAllDetectionsOnScreen) - 1
			Switch $aAllDetectionsOnScreen[$i][0]
				Case "L"
					If Not $g_bChkClanGamesLoot Then ContinueLoop
					;[0] = Path Directory , [1] = Name , [2] = TH level , [3] = Difficulty Level , [4] = Time to do it
					Local $LootChallenges = ClanGamesChallenges("$LootChallenges", False, $sINIPath, $g_bChkClanGamesDebug)
					For $j = 0 To UBound($LootChallenges) - 1
						; Match the names
						If $aAllDetectionsOnScreen[$i][1] = $LootChallenges[$j][0] Then
							; Verify your TH level and Challenge kind
							If $g_iTownHallLevel < $LootChallenges[$j][2] Then ExitLoop
							; Disable this event from INI File
							If $LootChallenges[$j][3] = 0 Then ExitLoop
							; [0]Event Name Full Name  , [1] Xaxis ,  [2] Yaxis , [3] difficulty
							Local $aArray = [$LootChallenges[$j][1], $aAllDetectionsOnScreen[$i][2], $aAllDetectionsOnScreen[$i][3], $LootChallenges[$j][3]]
						EndIf
					Next
				Case "D"
					If Not $g_bChkClanGamesDestruction Then ContinueLoop
					;[0] = Path Directory , [1] = Event Name , [2] = TH level , [3] = Difficulty Level , [4] = Time to do it
					Local $DestructionChallenges = ClanGamesChallenges("$DestructionChallenges", False, $sINIPath, $g_bChkClanGamesDebug)
					For $j = 0 To UBound($DestructionChallenges) - 1
						; Match the names
						If $aAllDetectionsOnScreen[$i][1] = $DestructionChallenges[$j][0] Then
							; Verify your TH level and Challenge kind
							If $g_iTownHallLevel < $DestructionChallenges[$j][2] Then ExitLoop

							; Disable this event from INI File
							If $DestructionChallenges[$j][3] = 0 Then ExitLoop

							; Check if you are using Heroes
							If $DestructionChallenges[$j][1] = "Hero Level Hunter" Or _
									$DestructionChallenges[$j][1] = "King Level Hunter" Or _
									$DestructionChallenges[$j][1] = "Queen Level Hunter" Or _
									$DestructionChallenges[$j][1] = "Warden Level Hunter" And ((Int($g_aiAttackUseHeroes[$DB]) = $eHeroNone And $g_iMatchMode = $DB) Or (Int($g_aiAttackUseHeroes[$LB]) = $eHeroNone And $g_iMatchMode = $LB)) Then ExitLoop
							; [0]Event Name Full Name  , [1] Xaxis ,  [2] Yaxis , [3] difficulty
							Local $aArray[4] = [$DestructionChallenges[$j][1], $aAllDetectionsOnScreen[$i][2], $aAllDetectionsOnScreen[$i][3], $DestructionChallenges[$j][3]]
						EndIf
					Next
					Case "B"
					If Not $g_bChkClanGamesBattle Then ContinueLoop
					;[0] = Path Directory , [1] = Event Name , [2] = TH level , [3] = Difficulty Level , [4] = Time to do it
					Local $BattleChallenges = ClanGamesChallenges("$BattleChallenges", False, $sINIPath, $g_bChkClanGamesDebug)
					For $j = 0 To UBound($BattleChallenges) - 1
						; Match the names
						If $aAllDetectionsOnScreen[$i][1] = $BattleChallenges[$j][0] Then
							; Verify your TH level and Challenge
							If $g_iTownHallLevel < $BattleChallenges[$j][2] Then ExitLoop
							; Disable this event from INI File
							If $BattleChallenges[$j][3] = 0 Then ExitLoop
							; If you are a TH12 , doesn't exist the TH13
							If $BattleChallenges[$j][1] = "Attack Up" And $g_iTownHallLevel >= 12 Then ExitLoop
							; Check your Trophy Range
							If $BattleChallenges[$j][1] = "Slaying The Titans" And Int($g_aiCurrentLoot[$eLootTrophy]) < 4100 Then ExitLoop
							; Check if exist a probability to use any Spell
							If $BattleChallenges[$j][1] = "No-Magic Zone" And ($g_bSmartZapEnable = True Or ($g_iMatchMode = $DB And $g_aiAttackAlgorithm[$DB] = 1) Or ($g_iMatchMode = $LB And $g_aiAttackAlgorithm[$LB] = 1)) Then ExitLoop
							; Check if you are using Heroes
							If $BattleChallenges[$j][1] = "No Heroics Allowed" And ((Int($g_aiAttackUseHeroes[$DB]) > $eHeroNone And $g_iMatchMode = $DB) Or (Int($g_aiAttackUseHeroes[$LB]) > $eHeroNone And $g_iMatchMode = $LB)) Then ExitLoop
							; [0]Event Name Full Name  , [1] Xaxis ,  [2] Yaxis , [3] difficulty
							Local $aArray[4] = [$BattleChallenges[$j][1], $aAllDetectionsOnScreen[$i][2], $aAllDetectionsOnScreen[$i][3], $BattleChallenges[$j][3]]
						EndIf
					Next
				Case "A"
					If Not $g_bChkClanGamesAirTroop Then ContinueLoop
					;[0] = Path Directory , [1] = Event Name , [2] = TH level , [3] = Event Quantities
					Local $AirTroopChallenges = ClanGamesChallenges("$AirTroopChallenges", False, $sINIPath, $g_bChkClanGamesDebug)
					For $j = 0 To UBound($AirTroopChallenges) - 1
						; Match the names
						If $aAllDetectionsOnScreen[$i][1] = $AirTroopChallenges[$j][0] Then
							; Verify if the Troops exist in your Army Composition
							Local $TroopIndex = Int(Eval("eTroop" & $AirTroopChallenges[$j][1]))
							; If doesn't Exist the Troop on your Army
							If $g_aiCurrentTroops[$TroopIndex] < 1 Then
								If $g_bChkClanGamesDebug Then SetLog("[" & $AirTroopChallenges[$j][1] & "] لا " & $g_asTroopNames[$TroopIndex] & " على تكوين الجيش الخاص بك.")
								ExitLoop
								; If Exist BUT not is required quantities
							ElseIf $g_aiCurrentTroops[$TroopIndex] > 0 And $g_aiCurrentTroops[$TroopIndex] < $AirTroopChallenges[$j][3] Then
								If $g_bChkClanGamesDebug Then SetLog("[" & $AirTroopChallenges[$j][1] & "] أنت في حاجة أكثر " & $g_asTroopNames[$TroopIndex] & " [" & $g_aiCurrentTroops[$TroopIndex] & "/" & $AirTroopChallenges[$j][3] & "]")
								ExitLoop
							EndIf
							; [0]Event Name Full Name  , [1] Xaxis ,  [2] Yaxis , [3] difficulty
							Local $aArray[4] = [$AirTroopChallenges[$j][1], $aAllDetectionsOnScreen[$i][2], $aAllDetectionsOnScreen[$i][3], 1]
						EndIf
					Next
				Case "G"
					If Not $g_bChkClanGamesGroundTroop Then ContinueLoop
					;[0] = Path Directory , [1] = Event Name , [2] = TH level , [3] = Event Quantities
					Local $GroundTroopChallenges = ClanGamesChallenges("$GroundTroopChallenges", False, $sINIPath, $g_bChkClanGamesDebug)
					For $j = 0 To UBound($GroundTroopChallenges) - 1
						; Match the names
						If $aAllDetectionsOnScreen[$i][1] = $GroundTroopChallenges[$j][0] Then
							; Verify if the Troops exist in your Army Composition
							Local $TroopIndex = Int(Eval("eTroop" & $GroundTroopChallenges[$j][1]))
							; If doesn't Exist the Troop on your Army
							If $g_aiCurrentTroops[$TroopIndex] < 1 Then
								If $g_bChkClanGamesDebug Then SetLog("[" & $GroundTroopChallenges[$j][1] & "] لا " & $g_asTroopNames[$TroopIndex] & " في تكوين الجيش الخاص بك.")
								ExitLoop
								; If Exist BUT not is required quantities
							ElseIf $g_aiCurrentTroops[$TroopIndex] > 0 And $g_aiCurrentTroops[$TroopIndex] < $GroundTroopChallenges[$j][3] Then
								If $g_bChkClanGamesDebug Then SetLog("[" & $GroundTroopChallenges[$j][1] & "] أنت في حاجة أكثر " & $g_asTroopNames[$TroopIndex] & " [" & $g_aiCurrentTroops[$TroopIndex] & "/" & $GroundTroopChallenges[$j][3] & "]")
								ExitLoop
							EndIf
							; [0]Event Name Full Name  , [1] Xaxis ,  [2] Yaxis , [3] difficulty
							Local $aArray[4] = [$GroundTroopChallenges[$j][1], $aAllDetectionsOnScreen[$i][2], $aAllDetectionsOnScreen[$i][3], 1]
						EndIf
					Next
				
				
				Case "M"
					If Not $g_bChkClanGamesMiscellaneous Then ContinueLoop
					;[0] = Path Directory , [1] = Event Name , [2] = TH level , [3] = Difficulty Level , [4] = Time to do it
					Local $MiscChallenges = ClanGamesChallenges("$MiscChallenges", False, $sINIPath, $g_bChkClanGamesDebug)
					For $j = 0 To UBound($MiscChallenges) - 1
						; Match the names
						If $aAllDetectionsOnScreen[$i][1] = $MiscChallenges[$j][0] Then
							; Disable this event from INI File
							If $MiscChallenges[$j][3] = 0 Then ExitLoop

							; Exceptions :
							; 1 - "Gardening Exercise" needs at least a Free Builder
							If $MiscChallenges[$j][1] = "Gardening Exercise" And $g_iFreeBuilderCount < 1 Then ExitLoop

							; 2 - Verify your TH level and Challenge kind
							If $g_iTownHallLevel < $MiscChallenges[$j][2] Then ExitLoop

							; 3 - If you don't Donate Troops
							If $MiscChallenges[$j][1] = "Helping Hand" And Not $g_iActiveDonate Then ExitLoop

							; 4 - If you don't Donate Spells , $g_aiPrepDon[2] = Donate Spells , $g_aiPrepDon[3] = Donate All Spells [PrepareDonateCC()]
							If $MiscChallenges[$j][1] = "Donate Spells" And ($g_aiPrepDon[2] = 0 And $g_aiPrepDon[3] = 0) Then ExitLoop

							; 5 - If you don't use Blimp
							If $MiscChallenges[$j][1] = "Battle Blimp" And ($g_aiAttackUseSiege[$DB] = 2 Or $g_aiAttackUseSiege[$LB] = 2) And $g_aiArmyCompSiegeMachine[$eSiegeBattleBlimp] = 0 Then ExitLoop

							; 6 - If you don't use Wrecker
							If $MiscChallenges[$j][1] = "Wall Wrecker" And ($g_aiAttackUseSiege[$DB] = 1 Or $g_aiAttackUseSiege[$LB] = 1) And $g_aiArmyCompSiegeMachine[$eSiegeWallWrecker] = 0 Then ExitLoop
							; [0]Event Name Full Name  , [1] Xaxis ,  [2] Yaxis , [3] difficulty
							Local $aArray[4] = [$MiscChallenges[$j][1], $aAllDetectionsOnScreen[$i][2], $aAllDetectionsOnScreen[$i][3], $MiscChallenges[$j][3]]
						EndIf
					Next
			EndSwitch
			If IsDeclared("aArray") And $aArray[0] <> "" Then
				ReDim $aSelectChallenges[UBound($aSelectChallenges) + 1][5]
				$aSelectChallenges[UBound($aSelectChallenges) - 1][0] = $aArray[0] ; Event Name Full Name
				$aSelectChallenges[UBound($aSelectChallenges) - 1][1] = $aArray[1] ; Xaxis
				$aSelectChallenges[UBound($aSelectChallenges) - 1][2] = $aArray[2] ; Yaxis
				$aSelectChallenges[UBound($aSelectChallenges) - 1][3] = $aArray[3] ; difficulty
				$aSelectChallenges[UBound($aSelectChallenges) - 1][4] = 0 ; timer minutes
				$aArray[0] = ""
			EndIf
		Next
	EndIf

	; Remove the temp  images Folder
	DirRemove($pathTemp, $DIR_REMOVE)

	If $g_bChkClanGamesDebug Then Setlog("_ClanGames aAllDetectionsOnScreen (in " & Round(TimerDiff($hTimer) / 1000, 2) & " seconds)", $COLOR_INFO)
	$hTimer = TimerInit()

	; Sort by Yaxis , TOP to Bottom
	_ArraySort($aSelectChallenges, 0, 0, 0, 2)

	If UBound($aSelectChallenges) > 0 Then
		; let's get the Event timing
		For $i = 0 To UBound($aSelectChallenges) - 1
			Setlog("الكشف عن " & $aSelectChallenges[$i][0] & " الحدث " & $aSelectChallenges[$i][3])
			Click($aSelectChallenges[$i][1], $aSelectChallenges[$i][2])
			If _Sleep(500) Then Return
			Local $EventHours = GetEventInformation()
			Setlog("الوقت: " & $EventHours & " دقيقة", $COLOR_INFO)
			Click($aSelectChallenges[$i][1], $aSelectChallenges[$i][2])
			If _Sleep(150) Then Return
			$aSelectChallenges[$i][4] = Number($EventHours)
		Next

		; let's get the 60 minutes events and remove from array
		Local $aTempSelectChallenges[0][5]
		For $i = 0 To UBound($aSelectChallenges) - 1
			If $aSelectChallenges[$i][4] = 60 And $g_bChkClanGames60 Then
				Setlog($aSelectChallenges[$i][0] & " غير محدد ، هو حدث 60 دقيقة!", $COLOR_INFO)
				ContinueLoop
			EndIf
			ReDim $aTempSelectChallenges[UBound($aTempSelectChallenges) + 1][5]
			$aTempSelectChallenges[UBound($aTempSelectChallenges) - 1][0] = $aSelectChallenges[$i][0]
			$aTempSelectChallenges[UBound($aTempSelectChallenges) - 1][1] = $aSelectChallenges[$i][1]
			$aTempSelectChallenges[UBound($aTempSelectChallenges) - 1][2] = $aSelectChallenges[$i][2]
			$aTempSelectChallenges[UBound($aTempSelectChallenges) - 1][3] = $aSelectChallenges[$i][3]
			$aTempSelectChallenges[UBound($aTempSelectChallenges) - 1][4] = $aSelectChallenges[$i][4]
		Next

		; Drop to top again , because coordinates Xaxis and Yaxis
		ClickP($TabChallengesPosition, 2, 0, "#Tab")
		If _sleep(250) Then Return
		ClickDrag(807, 210, 807, 385, 500)
		If _Sleep(500) Then Return
	EndIf

	; After removing is necessary check Ubound
	If IsDeclared("aTempSelectChallenges") Then
		If UBound($aTempSelectChallenges) > 0 Then
			SetDebugLog("$aTempSelectChallenges: " & _ArrayToString($aTempSelectChallenges))
			; Sort by difficulties
			_ArraySort($aTempSelectChallenges, 0, 0, 0, 3)

			Setlog("الحدث التالي سيكون " & $aTempSelectChallenges[0][0] & " لجعل في " & $aTempSelectChallenges[0][4] & " دقيقة.")
			; Select and Start EVENT
			$sEventName = $aTempSelectChallenges[0][0]
			Click($aTempSelectChallenges[0][1], $aTempSelectChallenges[0][2])
			If _Sleep(800) Then Return
			If $test Then Return
			If ClickOnEvent($YourAccScore, $ScoreLimits, $sEventName, $getCapture) Then Return
			; Some error occurred let's click on Challenges Tab and proceeds
			ClickP($TabChallengesPosition, 2, 0, "#Tab")
		EndIf
	EndIf

	; Lets test the Builder Base Challenges
	If $g_bChkClanGamesPurge Then
		If $g_iPurgeJobCount[$g_iCurAccount] + 1 < $g_iPurgeMax Or $g_iPurgeMax = 0 Then
			Local $Txt = $g_iPurgeMax
			If $g_iPurgeMax = 0 Then $Txt = "Unlimited"
			SetLog("وظائف تطهير الحالية " & $g_iPurgeJobCount[$g_iCurAccount] + 1 & "  " & $Txt, $COLOR_INFO)
			$sEventName = "Builder Base Challenges to Purge"
			If PurgeEvent($g_sImgPurge, $sEventName, True) Then
				$g_iPurgeJobCount[$g_iCurAccount] += 1
			Else
				SetLog("لا يوجد احداث القرية الليلة في قائمة المهمات لتحديث القائمة", $COLOR_WARNING)
			EndIf
		EndIf
		Return
	EndIf

	SetLog("لا يوجد حدث, تحقق من الاعدادت في البوت", $COLOR_WARNING)
	ClickP($aAway, 1, 0, "#0000") ;Click Away
	If _Sleep(2000) Then Return

EndFunc   ;==>_ClanGames

Func IsClanGamesWindow($getCapture = True)
	If QuickMIS("BC1", $g_sImgCaravan, 200, 55, 300, 135, $getCapture, False) Then
		; If QuickMIS("BC1", $g_sImgCaravan, 236, 119, 270, 122, True) Then
		SetLog("عربة مباريات متاحة  الدخول الى قائمة المهمات ", $COLOR_SUCCESS)
		Click($g_iQuickMISX + 200, $g_iQuickMISY + 55)
		; Just wait for window open
		If _Sleep(1500) Then Return
		If QuickMIS("BC1", $g_sImgReward, 760, 480, 830, 570, $getCapture, $g_bChkClanGamesDebug) Then
			SetLog("مكافأتك جاهزة", $COLOR_INFO)
			ClickP($aAway, 1, 0, "#0000") ;Click Away
			If _Sleep(100) Then Return
			Return False
		EndIf
		If _ColorCheck(_GetPixelColor(384, 388, True), Hex(0xFFFFFF, 6), 5) Then ;
			Local $sTimeRemain = getOcrTimeGameTime(380, 461) ; read Clan Games waiting time
			SetLog("ستبدا مبارات القبيلة في  " & $sTimeRemain, $COLOR_INFO)
			; Update the Label on GUI
			GUICtrlSetData($g_hLblRemainTime, $sTimeRemain)
			GUICtrlSetState($g_hLblRemainTime, $GUI_ENABLE)
			ClickP($aAway, 1, 0, "#0000") ;Click Away
			If _Sleep(100) Then Return
			Return False
		EndIf
	Else
		SetLog("عربة مباريات القبيلة غير متاحة", $COLOR_WARNING)
		ClickP($aAway, 1, 0, "#0000") ;Click Away
		Return False
	EndIf
	If _Sleep(300) Then Return
	Return True
EndFunc   ;==>IsClanGamesWindow

Func GetTimesAndScores()

	Local $rest = -1, $YourScore = "", $ScoreLimits, $sTimeRemain

	;Ocr for game time remaining
	$sTimeRemain = StringReplace(getOcrTimeGameTime(50, 479), " ", "") ; read Clan Games waiting time
	; JUST IN CASE
	If Not _IsValideOCR($sTimeRemain) Then
		SetLog("الحصول على الوقت يبقى الخطأ!!!", $COLOR_WARNING)
		Return -1
	EndIf
	SetLog("الوقت المتبقي ل مبارات القبيلة : " & $sTimeRemain, $COLOR_INFO)

	; Update the Label on GUI
	GUICtrlSetData($g_hLblRemainTime, $sTimeRemain)
	GUICtrlSetState($g_hLblRemainTime, $GUI_ENABLE)

	; This Loop is just to check if the Score is changing , when you complete a previous events is necessary to take some time...
	For $i = 0 To 10
		$YourScore = getOcrYourScore(55, 533) ;  Read your Score
		If $g_bChkClanGamesDebug Then SetLog("نقاط الخاص بك: " & $YourScore)
		$YourScore = StringReplace($YourScore, "#", "/")
		$ScoreLimits = StringSplit($YourScore, "/", $STR_NOCOUNT)
		If UBound($ScoreLimits) > 1 Then
			If $rest = Int($ScoreLimits[0]) Then ExitLoop
			$rest = Int($ScoreLimits[0])
		Else
			Return -1
		EndIf
		If _Sleep(800) Then Return
		If $i = 10 Then Return -1
	Next

	; Update the Label on GUI
	GUICtrlSetData($g_hLblYourScore, $YourScore)
	GUICtrlSetState($g_hLblYourScore, $GUI_ENABLE)

	Return $ScoreLimits
EndFunc   ;==>GetTimesAndScores

Func CooldownTime($getCapture = True)
	; Check IF exist the Gem icon
	;check cooldown purge
	If QuickMIS("BC1", $g_sImgCoolPurge, 480, 370, 570, 410, $getCapture, False) Then
		SetLog("Cooldown Purge Detected", $COLOR_INFO)
		ClickP($aAway, 1, 0, "#0000") ;Click Away
		Return True
	EndIf
	Return False
EndFunc   ;==>CooldownTime

Func IsEventRunning()
	; Check if any event is running or not
	If Not _ColorCheck(_GetPixelColor(304, 257, True), Hex(0x53E050, 6), 5) Then ; Green Bar from First Position
		SetLog("حدث قيد التقدم بالفعل !", $COLOR_SUCCESS)
		If $g_bChkClanGamesDebug Then SetLog("[0]: " & _GetPixelColor(304, 257, True))
		ClickP($aAway, 1, 0, "#0000") ;Click Away
		Return True
	Else
		SetLog("لا يوجد حدث تحت التقدم ... دعنا نبحث عن واحد ...", $COLOR_INFO)
		Return False
	EndIf

EndFunc   ;==>IsEventRunning

Func ClickOnEvent(ByRef $YourAccScore, $ScoreLimits, $sEventName, $getCapture)
	If $YourAccScore[$g_iCurAccount][1] = False Then
		Local $Text = "", $color = $COLOR_SUCCESS
		If $YourAccScore[$g_iCurAccount][0] <> $ScoreLimits[0] Then
			$Text = "You Won " & $ScoreLimits[0] - $YourAccScore[$g_iCurAccount][0] & "pts in last Event"
		Else
			$Text = "You could not complete the last event!!"
			$color = $COLOR_WARNING
		EndIf
		SetLog($Text, $color)
		_FileWriteLog($g_sProfileLogsPath & "\ClanGames.log", " [" & $g_sProfileCurrentName & "] - " & $Text)
	EndIf
	$YourAccScore[$g_iCurAccount][1] = False
	$YourAccScore[$g_iCurAccount][0] = $ScoreLimits[0]
	If $g_bChkClanGamesDebug Then SetLog("ClickOnEvent $YourAccScore[" & $g_iCurAccount & "][1]: " & $YourAccScore[$g_iCurAccount][1])
	If $g_bChkClanGamesDebug Then SetLog("ClickOnEvent $YourAccScore[" & $g_iCurAccount & "][0]: " & $YourAccScore[$g_iCurAccount][0])
	If Not StartsEvent($sEventName, False, $getCapture, $g_bChkClanGamesDebug) Then Return False
	ClickP($aAway, 1, 0, "#0000") ;Click Away
	Return True
EndFunc   ;==>ClickOnEvent

Func StartsEvent($sEventName, $g_bPurgeJob = False, $getCapture = True, $g_bChkClanGamesDebug = False)

	; Start an Event
	If $g_bRunState = False Then Return
	If QuickMIS("BC1", $g_sImgStart, 220, 150, 830, 580, $getCapture, $g_bChkClanGamesDebug) Then
		Local $Timer = GetEventTimeInMinutes($g_iQuickMISX + 220, $g_iQuickMISY + 150)
		SetLog("بدء الحدث" & " [" & $Timer & " دقيقة]", $COLOR_SUCCESS)
		Click($g_iQuickMISX + 220, $g_iQuickMISY + 150)
		GUICtrlSetData($g_hTxtClanGamesLog, @CRLF & _NowDate() & " " & _NowTime() & " [" & $g_sProfileCurrentName & "] - Starting " & $sEventName & " for " & $Timer & " min", 1)
		_FileWriteLog($g_sProfileLogsPath & "\ClanGames.log", " [" & $g_sProfileCurrentName & "] - Starting " & $sEventName & " for " & $Timer & " min")
		If $g_bPurgeJob Then
			If _Sleep(1000) Then Return
			; Click($g_iQuickMISX + 220, $g_iQuickMISY + 150)
			If QuickMIS("BC1", $g_sImgTrashPurge, 220, 150, 830, 580, $getCapture, $g_bChkClanGamesDebug) Then
				Click($g_iQuickMISX + 220, $g_iQuickMISY + 150)
				If _Sleep(1000) Then Return
				SetLog("انقر فوق المهملات", $COLOR_INFO)
				If QuickMIS("BC1", $g_sImgOkayPurge, 440, 400, 580, 450, $getCapture, $g_bChkClanGamesDebug) Then
					SetLog("انقر فوق موافق", $COLOR_INFO)
					Click($g_iQuickMISX + 440, $g_iQuickMISY + 400)
					SetLog("تطهير وظيفة على التقدم !", $COLOR_SUCCESS)
					GUICtrlSetData($g_hTxtClanGamesLog, @CRLF & _NowDate() & " " & _NowTime() & " [" & $g_sProfileCurrentName & "] - [" & $g_iPurgeJobCount[$g_iCurAccount] + 1 & "] - Purging Event ", 1)
					_FileWriteLog($g_sProfileLogsPath & "\ClanGames.log", " [" & $g_sProfileCurrentName & "] - [" & $g_iPurgeJobCount[$g_iCurAccount] + 1 & "] - Purging Event ")
					ClickP($aAway, 1, 0, "#0000") ;Click Away
				Else
					SetLog("$g_sImgOkayPurge Issue!!!", $COLOR_WARNING)
					Return False
				EndIf
			Else
				SetLog("$g_sImgTrashPurge Issue!!!", $COLOR_WARNING)
				Return False
			EndIf
		EndIf
		Return True
	Else
		SetLog("لم تحصل على حدث زر البداية الخضراء!!", $COLOR_WARNING)
		If $g_bChkClanGamesDebug Then SetLog("[X: " & 220 & " Y:" & 150 & " X1: " & 830 & " Y1: " & 580 & "]", $COLOR_WARNING)
		ClickP($aAway, 1, 0, "#0000") ;Click Away
		Return False
	EndIf

EndFunc   ;==>StartsEvent

Func PurgeEvent($directoryImage, $sEventName, $getCapture = True)
	SetLog("التحقق من مهمات القرية الليلة من اجل تحديث قائمة المهمات ", $COLOR_DEBUG)
	; Screen coordinates for ScreenCapture
	Local $x = 281, $y = 150, $x1 = 775, $y1 = 545
	If QuickMIS("BC1", $directoryImage, $x, $y, $x1, $y1, $getCapture, $g_bChkClanGamesDebug) Then
		Click($g_iQuickMISX + $x, $g_iQuickMISY + $y)
		; Start and Purge at same time
		SetLog("بدء مهمة مستحيلة لتطهير ...", $COLOR_INFO)
		If _Sleep(1000) Then Return
		If StartsEvent($sEventName, True, $getCapture, $g_bChkClanGamesDebug) Then
			ClickP($aAway, 1, 0, "#0000") ;Click Away
			Return True
		EndIf
	EndIf
	Return False
EndFunc   ;==>PurgeEvent

Func _IsValideOCR($sString)

	If StringInStr($sString, "d") > 0 Or _
			StringInStr($sString, "h") > 0 Or _
			StringInStr($sString, "m") > 0 Or _
			StringInStr($sString, "s") > 0 Then Return True

	Return False
EndFunc   ;==>_IsValideOCR

Func Ocr2Minutes($StringOCR)

	If Not _IsValideOCR($StringOCR) Then Return 0

	Local $temp

	If StringInStr($StringOCR, "d") > 0 Then
		$temp = StringSplit($StringOCR, "d", $STR_NOCOUNT)
		Local $d = Int($temp[0])
		Local $h = Int(StringReplace($temp[1], "h", ""))
		Return ($d * 24) * 60 + ($h * 60)
	ElseIf StringInStr($StringOCR, "h") > 0 Then
		$temp = StringSplit($StringOCR, "h", $STR_NOCOUNT)
		Local $h = Int($temp[0])
		Local $m = Int(StringReplace($temp[1], "m", ""))
		Return ($h * 60) + $m
	ElseIf StringInStr($StringOCR, "m") > 0 Then
		$temp = StringSplit($StringOCR, "m", $STR_NOCOUNT)
		Return Int($temp[0])
	ElseIf StringInStr($StringOCR, "s") > 0 Then
		Return 1
	EndIf

	Return 0
EndFunc   ;==>Ocr2Minutes

Func GetEventTimeInMinutes($iXStartBtn, $iYStartBtn, $bIsStartBtn = True)

	Local $XAxis = $iXStartBtn - 163 ; Related to Start Button
	Local $YAxis = $iYStartBtn + 8 ; Related to Start Button

	If Not $bIsStartBtn Then
		$XAxis = $iXStartBtn - 163 ; Related to Trash Button
		$YAxis = $iYStartBtn + 8 ; Related to Trash Button
	EndIf

	Local $Ocr = getOcrEventTime($XAxis, $YAxis)
	Return Ocr2Minutes($Ocr)

EndFunc   ;==>GetEventTimeInMinutes

; Just for any button test
Func ClanGames($bTest = False)
	Local $bWasRunState = $g_bRunState
	$g_bRunState = True
	Local $temp = $g_bChkClanGamesDebug
	Local $debug = $g_bDebugSetlog
	$g_bDebugSetlog = True
	$g_bChkClanGamesDebug = True
	Local $tempCurrentTroops = $g_aiCurrentTroops
	For $i = 0 To UBound($g_aiCurrentTroops) - 1
		$g_aiCurrentTroops[$i] = 50
	Next
	Local $Result = _ClanGames(True)
	$g_aiCurrentTroops = $tempCurrentTroops
	$g_bRunState = $bWasRunState
	$g_bChkClanGamesDebug = $temp
	$g_bDebugSetlog = $debug
	Return $Result
EndFunc   ;==>ClanGames

; Extra functions for OCR
Func getOcrTimeGameTime($x_start, $y_start) ;  -> Get the guard/shield time left, middle top of the screen
	Return getOcrAndCapture("coc-clangames", $x_start, $y_start, 116, 31, True)
EndFunc   ;==>getOcrTimeGameTime

Func getOcrYourScore($x_start, $y_start) ; -> Gets CheckValuesCost on Train Window
	Return getOcrAndCapture("coc-ms", $x_start, $y_start, 120, 18, True)
EndFunc   ;==>getOcrYourScore

Func getOcrEventTime($x_start, $y_start) ; -> Gets CheckValuesCost on Train Window
	Return getOcrAndCapture("coc-events", $x_start, $y_start, 80, 20, True)
EndFunc   ;==>getOcrEventTime

#Tidy_Off
Func ClanGamesChallenges($sReturnArray, $makeIni = False, $sINIPath = "", $debug = False)

	;[0]=ImageName 	 					[1]=Challenge Name		[3]=THlevel 	[4]=Priority/TroopsNeeded 	[5]=Extra/to use in future
	Local $LootChallenges[6][5] = [ _
			["GoldChallenge", 			"جمع الذهب", 				         7,  4, 8], _ ; Loot 150,000 Gold from a single Multiplayer Battle				|8h 	|50
			["ElixirChallenge", 		"جمع الاكسير", 			         7,  4, 8], _ ; Loot 150,000 Elixir from a single Multiplayer Battle 			|8h 	|50
			["DarkEChallenge", 			"جمع الدارك اكسير", 		             8,  5, 8], _ ; Loot 1,500 Dark elixir from a single Multiplayer Battle			|8h 	|50
			["GoldGrab", 				"جمع الذهب المكثف",			         3,  1, 1], _ ; Loot a total of 500,000 TO 1,500,000 from Multiplayer Battle 	|1h-2d 	|100-600
			["ElixirEmbezz", 			"جمع الاكسير المكثف", 	         	 3,  1, 1], _ ; Loot a total of 500,000 TO 1,500,000 from Multiplayer Battle 	|1h-2d 	|100-600
			["DarkEHeist", 				"جمع الدارك المكثف", 		         9,  3, 1]]   ; Loot a total of 1,500 TO 12,500 from Multiplayer Battle 		|1h-2d 	|100-600

	Local $AirTroopChallenges[6][5] = [ _
			["Mini", 					"Minion", 						 7, 20, 1], _ ; Earn 2-5 Stars from Multiplayer Battles using 20 Minions		|3h-8h	|40-100
			["Ball", 					"Balloon", 						 4, 12, 1], _ ; Earn 2-5 Stars from Multiplayer Battles using 12 Balloons		|3h-8h	|40-100
			["Drag", 					"Dragon", 						 7,  6, 1], _ ; Earn 2-5 Stars from Multiplayer Battles using 6 Dragons			|3h-8h	|40-100
			["BabyD", 					"BabyDragon", 					 9,  4, 1], _ ; Earn 2-5 Stars from Multiplayer Battles using 4 Baby Dragons	|3h-8h	|40-100
			["Lava", 					"ElectroDragon", 				10,  2, 1], _ ; Earn 2-4 Stars from Multiplayer Battles using 2 Electro Dragon	|3h-8h	|40-300
			["Edrag", 					"Lavahound", 					 9,  3, 1]]   ; Earn 2-5 Stars from Multiplayer Battles using 3 Lava Hounds		|3h-8h	|40-100

	Local $GroundTroopChallenges[14][5] = [ _
			["Arch", 					"Archer", 						 1, 30, 1], _ ; Earn 2-5 Stars from Multiplayer Battles using 30 Barbarians		|3h-8h	|40-100
			["Barb", 					"Barbarian", 					 1, 30, 1], _ ; Earn 2-5 Stars from Multiplayer Battles using 30 Archers		|3h-8h	|40-100
			["Giant", 					"Giant", 						 1, 10, 1], _ ; Earn 2-5 Stars from Multiplayer Battles using 10 Giants			|3h-8h	|40-100
			["Gobl", 					"Goblin", 						 2, 20, 1], _ ; Earn 2-5 Stars from Multiplayer Battles using 20 Goblins		|3h-8h	|40-100
			["Wall", 					"WallBreaker", 					 3,  6, 1], _ ; Earn 2-5 Stars from Multiplayer Battles using 6 Wall Breakers	|3h-8h	|40-100
			["Wiza", 					"Wizard", 						 5, 12, 1], _ ; Earn 2-5 Stars from Multiplayer Battles using 12 Wizards		|3h-8h	|40-100
			["Heal", 					"Healer", 						 6,  3, 1], _ ; Earn 2-5 Stars from Multiplayer Battles using 3 Healers			|3h-8h	|40-100
			["Hogs", 					"HogRider", 					 7, 10, 1], _ ; Earn 2-5 Stars from Multiplayer Battles using 10 Hog Riders		|3h-8h	|40-100
			["Mine", 					"Miner", 						10,  8, 1], _ ; Earn 2-5 Stars from Multiplayer Battles using 8 Miners			|3h-8h	|40-100
			["Pekk", 					"Pekka", 						 8,  2, 1], _ ; Earn 2-5 Stars from Multiplayer Battles using 2 P.E.K.K.As		|3h-8h	|40-100
			["Witc", 					"Witch", 						 9,  4, 1], _ ; Earn 2-5 Stars from Multiplayer Battles using 4 Witches			|3h-8h	|40-100
			["Bowl", 					"Bowler", 						10,  8, 1], _ ; Earn 2-5 Stars from Multiplayer Battles using 8 Bowlers			|3h-8h	|40-100
			["Valk", 					"Valkyrie", 					 8,  8, 1], _ ; Earn 2-5 Stars from Multiplayer Battles using 8 Valkyries		|3h-8h	|40-100
			["Gole", 					"Golem", 						 8,  2, 1]]   ; Earn 2-5 Stars from Multiplayer Battles using 2 Golems			|3h-8h	|40-100

	Local $BattleChallenges[9][5] = [ _
			["Start", 					"جمع نجوم", 				 3,  1, 8], _ ; Collect a total of 6-18 stars from Multiplayer Battles			|8h-2d	|100-600
			["Destruction", 			"جمع نسبة مئوية", 			 3,  3, 8], _ ; Gather a total of 100%-500% destruction from Multi Battles		|8h-2d	|100-600
			["PileOfVictores", 			"فوز بالنجوم", 			 3,  1, 8], _ ; Win 2-8 Multiplayer Battles										|8h-2d	|100-600
			["StarThree", 				"االحصول على 3 نجوم", 		10,  0, 8], _ ; Score a perfect 3 Stars in Multiplayer Battles					|8h 	|200
			["WinningStreak", 			"الفوز في المعركة", 				 9,  0, 8], _ ; Win 2-8 Multiplayer Battles in a row							|8h-2d	|100-600
			["SlayingTitans", 			"الفوز في مركة متتعدة الاعبين", 			11,  3, 5], _ ; Win 5 Multiplayer Battles In Tital LEague						|5h		|300
			["NoHero", 					"الهجوم بدون ملوك", 			 3,  0, 8], _ ; Win stars without using Heroes									|8h		|100
			["NoMagic", 				"الهجوم بدون تعويذات", 				 3,  5, 8], _ ; Win stars without using Spells									|8h		|100
			["AttackUp", 				"الهجوم على تاون اعلى من تاونك", 					 3,  0, 8]]   ; Gain 3 Stars Against Certain Town Hall							|8h		|200

	Local $DestructionChallenges[28][5] = [ _
			["Cannon", 					"تدمير المدفع", 				 3,  1, 1], _ ; Destroy 5-25 Cannons in Multiplayer Battles					|1h-8h	|75-350
			["ArcherT", 				"تدمير برج الارشر", 		         3,  1, 1], _ ; Destroy 5-20 Archer Towers in Multiplayer Battles			|1h-8h	|75-350
			["Mortar", 					"تدمير الهاون", 				 3,  2, 1], _ ; Destroy 4-12 Mortars in Multiplayer Battles					|1h-8h	|40-350
			["AirD", 					"تدمير مضاد الجوية", 		         7,  3, 1], _ ; Destroy 3-12 Air Defenses in Multiplayer Battles			|1h-8h	|40-350
			["WizardT", 				"تدمير برج الساحر", 		         3,  1, 1], _ ; Destroy 4-12 Wizard Towers in Multiplayer Battles			|1h-8h	|40-350
			["AirSweepers", 			"تدمير منفاخ الهوائي", 	     	 8,  5, 1], _ ; Destroy 2-6 Air Sweepers in Multiplayer Battles				|1h-8h	|40-350
			["Tesla", 					"تدمير التيسلا", 		         7,  5, 1], _ ; Destroy 4-12 Hidden Teslas in Multiplayer Battles			|1h-8h	|50-350
			["BombT", 					"تدمير برج القنابل", 		     	 8,  2, 1], _ ; Destroy 2 Bomb Towers in Multiplayer Battles				|1h-8h	|50-350
			["Xbow", 					"تدمير القوس", 			     	 9,  0, 1], _ ; Destroy 3-12 X-Bows in Multiplayer Battles					|1h-8h	|50-350
			["Inferno", 				"تدمير برج النار", 		         11, 0, 1], _ ; Destroy 2 Inferno Towers in Multiplayer Battles				|1h-2d	|50-600
			["EagleA", 					"تدمير مدفع النسر", 	             11,  0, 1], _ ; Destroy 1-7 Eagle Artillery in Multiplayer Battles			|1h-2d	|50-600
			["ClanC", 					"تدمير قلعة القبيلة", 			     5,  3, 1], _ ; Destroy 1-4 Clan Castle in Multiplayer Battles				|1h-8h	|40-350
			["GoldSRaid", 				"تدمير مخزن الذهب", 			     3,  2, 1], _ ; Destroy 3-15 Gold Storages in Multiplayer Battles			|1h-8h	|40-350
			["ElixirSRaid", 			"تدمير مخزن الاكسير", 			 3,  2, 1], _ ; Destroy 3-15 Elixir Storages in Multiplayer Battles			|1h-8h	|40-350
			["DarkEStorageRaid", 		"تدمير مخزن الدارك", 	             8,  0, 1], _ ; Destroy 1-4 Dark Elixir Storage in Multiplayer Battles		|1h-8h	|40-350
			["GoldM", 					"تدمير مستخرجات الذهب", 			 3,  1, 1], _ ; Destroy 6-20 Gold Mines in Multiplayer Battles				|1h-8h	|40-350
			["ElixirPump", 				"تدمير مستخرجات الاكسير", 		 3,  1, 1], _ ; Destroy 6-20 Elixir Collectors in Multiplayer Battles		|1h-8h	|40-350
			["DarkEPlumbers", 			"تدمير مستخرجات الدارك", 		     3,  1, 1], _ ; Destroy 2-8 Dark Elixir Drills in Multiplayer Battles		|1h-8h	|40-350
			["Laboratory", 				"تدمير المخبر", 			         3,  1, 1], _ ; Destroy 2-6 Laboratories in Multiplayer Battles				|1h-8h	|40-200
			["SFacto", 					"تدمير مخبر التعويذات", 	     	 3,  1, 1], _ ; Destroy 2-6 Spell Factories in Multiplayer Battles			|1h-8h	|40-200
			["DESpell", 				"تدمير مخبر التعويذات الدارك", 	     8,  1, 1], _ ; Destroy 2-6 Dark Spell Factories in Multiplayer Battles		|1h-8h	|40-200
			["BKaltar", 				"تدمير قاعة الملك",                9,  3, 1], _ ; Destroy 2-5 Barbarian King Altars in Multiplayer Battles	|1h-8h	|50-150
			["AQaltar", 				"تدمير قاعة الملكة", 	             10,  3, 1], _ ; Destroy 2-5 Archer Queen Altars in Multiplayer Battles		|1h-8h	|50-150
			["GWaltar", 				"تدمير قاعة الامر الكبير", 	         11,  3, 1], _ ; Destroy 2-5 Grand Warden Altars in Multiplayer Battles		|1h-8h	|50-150
			["HeroLevelHunter", 		"قتل المللوك", 			         9,   0, 8], _ ; Knockout 125 Level Heroes on Multiplayer Battles			|8h		|100
			["KingLevelHunter", 		"قتل الملك", 			         9,   5, 8], _ ; Knockout 50 Level King on Multiplayer Battles				|8h		|100
			["QueenLevelHunt", 			"قتل الملكة", 			         10,  5, 8], _ ; Knockout 50 Level Queen on Multiplayer Battles				|8h		|100
			["WardenLevelHunter", 		"قتل الامر الكبير", 		       	 11,  5, 8]]   ; Knockout 20 Level Warden on Multiplayer Battles				|8h		|100

	Local $MiscChallenges[5][5] = [ _
			["Gard", 					"ازالة الشجر", 			 3,  1, 8], _ ; Clear 5 obstacles from your Home Village or Builder Base		|8h	|50
			["DonateSpell", 			"دعم تعويذات", 				 9,  5, 8], _ ; Donate a total of 10 housing space worth of spells				|8h	|50
			["DonateTroop", 			"دعم جنود", 				 6,  5, 8], _ ; Donate a total of 100 housing space worth of troops				|8h	|50
			["BattleBlimpBoogie", 		"استخدام منطاد الحصار", 				12,  1, 1], _ ; Earn 2-4 Stars from Multiplayer Battles using 1 Battle Blimp	|3h-8h	|40-300
			["WallWreckerWallop", 		"استخدام الة الحصار", 				12,  1, 1]]   ; Earn 2-5 Stars from Multiplayer Battles using 1 Wall Wrecker 	|3h-8h	|40-100




	; Just in Case
	Local $LocalINI = $sINIPath
	If $LocalINI = "" Then $LocalINI = StringReplace($g_sProfileConfigPath, "config.ini", "ClanGames_config.ini")

	If $debug Then Setlog(" - Ini Path: " & $LocalINI)

	; Variables to use
	Local $section[4] = ["Loot Challenges", "Battle Challenges", "Destruction Challenges", "Misc Challenges"]
	Local $array[4] = [$LootChallenges, $BattleChallenges, $DestructionChallenges, $MiscChallenges]
	Local $ResultIni = "", $TempChallenge, $tempXSector

	; Store variables
	If $makeIni = False Then

		Switch $sReturnArray
			Case "$AirTroopChallenges"
				Return $AirTroopChallenges
			Case "$GroundTroopChallenges"
				Return $GroundTroopChallenges
			Case "$LootChallenges"
				$TempChallenge = $array[0]
				$tempXSector = $section[0]
			Case "$BattleChallenges"
				$TempChallenge = $array[1]
				$tempXSector = $section[1]
			Case "$DestructionChallenges"
				$TempChallenge = $array[2]
				$tempXSector = $section[2]
			Case "$MiscChallenges"
				$TempChallenge = $array[3]
				$tempXSector = $section[3]
		EndSwitch
		; Read INI File
		If $debug Then Setlog("[" & $tempXSector & "]")
		For $j = 0 To UBound($TempChallenge) - 1
			$ResultIni = Int(IniRead($LocalINI, $tempXSector, $TempChallenge[$j][1], $TempChallenge[$j][3]))
			$TempChallenge[$j][3] = IsNumber($ResultIni) = 1 ? Int($ResultIni) : 0
			If $TempChallenge[$j][3] > 5 Then $TempChallenge[$j][3] = 5
			If $TempChallenge[$j][3] < 0 Then $TempChallenge[$j][3] = 0
			If $debug Then Setlog(" - " & $TempChallenge[$j][1] & ": " & $TempChallenge[$j][3])
			$ResultIni = ""
		Next
		Return $TempChallenge
	Else

		; Write INI File
		Local $File = FileOpen($LocalINI, $FO_APPEND)
		Local $HelpText = "; - MyBotRun 2018 - " & @CRLF & _
				"; - 'Event name' = 'Priority' [1~5][easiest to the hardest] , '0' to disable the event" & @CRLF & _
				"; - Remember on GUI you can enable/disable an entire Section" & @CRLF & _
				"; - Do not change any event name" & @CRLF & _
				"; - Deleting this file will restore the defaults values." & @CRLF & @CRLF
		FileWrite($File, $HelpText)
		FileClose($File)
		For $i = 0 To UBound($array) - 1
			$TempChallenge = $array[$i]
			If $debug Then Setlog("[" & $section[$i] & "]")
			For $j = 0 To UBound($TempChallenge) - 1
				If IniWrite($LocalINI, $section[$i], $TempChallenge[$j][1], $TempChallenge[$j][3]) <> 1 Then SetLog("Error on :" & $section[$i] & "|" & $TempChallenge[$j][1], $COLOR_WARNING)
				If $debug Then Setlog(" - " & $TempChallenge[$j][1] & ": " & $TempChallenge[$j][3])
				If _sleep(100) Then Return
			Next
			$TempChallenge = Null
		Next
	EndIf
EndFunc   ;==>ClanGamesChallenges
#Tidy_Off

Func GetEventInformation()
	If QuickMIS("BC1", $g_sImgStart, 220, 150, 830, 580, True, $g_bChkClanGamesDebug) Then
		Return GetEventTimeInMinutes($g_iQuickMISX + 220, $g_iQuickMISY + 150)
	EndIf
	Return 0
EndFunc