; #FUNCTION# ====================================================================================================================
; Name ..........: NameOfTroop
; Description ...: Returns the string value of the troopname in singular or plural form
; Syntax ........: NameOfTroop($iKind[, $iPlural = 0])
; Parameters ....: $iKind      - an integer value, enumerated value of the troops, like $eBarb = 0, $eArch = 1 etc.
;                  $iPlural    - [optional] a integer value to indicate the $sTroopname returned must be in plural form. Default is 0.
; Return values .: $sTroopname
; Author ........: Unknown (2015)
; Modified ......: ZengZeng (01-2016), Hervidero (01-2016)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2018
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func NameOfTroop($iKind, $iPlural = 0)
	Local $sTroopname
	Switch $iKind
		Case $eBarb
			$sTroopname = "بربر"
		Case $eArch
			$sTroopname = "ارشر"
		Case $eGobl
			$sTroopname = "حرامي"
		Case $eGiant
			$sTroopname = "عملاق"
		Case $eWall
			$sTroopname = "مفجر السور"
		Case $eWiza
			$sTroopname = "ساحر"
		Case $eBall
			$sTroopname = "بالون"
		Case $eHeal
			$sTroopname = "هلر"
		Case $eDrag
			$sTroopname = "تنين"
		Case $ePekk
			$sTroopname = "بيكا"
		Case $eBabyD
			$sTroopname = "بيبي دراغون"
		Case $eMine
			$sTroopname = "حفار"
        Case $eEDrag
			$sTroopname = "تنين الكهربا"			
		Case $eMini
			$sTroopname = "مينون"
		Case $eHogs
			$sTroopname = "الهوك "
		Case $eValk
			$sTroopname = "فالكري"
		Case $eWitc
			$sTroopname = "واتس"
		Case $eGole
			$sTroopname = "غولم"
		Case $eLava
			$sTroopname = "لافا"
		Case $eBowl
			$sTroopname = "باور"
		Case $eKing
			$sTroopname = "الملكة"
			$iPlural = 0 ; safety reset, $sTroopname of $eKing cannot be plural
		Case $eQueen
			$sTroopname = "الملكة"
			$iPlural = 0 ; safety reset
		Case $eWarden
			$sTroopname = "الامر الكبير"
			$iPlural = 0 ; safety reset
		Case $eCastle
			$sTroopname = "قوات القبيلة"
			$iPlural = 0 ; safety reset
		Case $eLSpell
			$sTroopname = "سبيل الصواعق"
		Case $eHSpell
			$sTroopname = "سبيل الصحة"
		Case $eRSpell
			$sTroopname = "سبيل الغضب "
		Case $eJSpell
			$sTroopname = "سبيل القفذ"
		Case $eFSpell
			$sTroopname = "سبيل التجميد"
		Case $eCSpell
			$sTroopname = "سبيل الاستنساخ"
		Case $ePSpell
			$sTroopname = "سبيل السم"
		Case $eESpell
			$sTroopname = "سبيل الزلزال"
		Case $eHaSpell
			$sTroopname = "سبيل التسريع"
		Case $eSkSpell
			$sTroopname = "Skeleton Spell"
		Case $eWallW
			$sTroopname = "Wall Wrecker"
		Case $eBattleB
			$sTroopname = "Battle Blimp"
		Case Else
			Return "" ; error or unknown case
	EndSwitch
	If $iPlural = 1 And $iKind = $eWitc Then $sTroopname &= " " ; adding the "e" for "witches"
	If $iPlural = 1 Then $sTroopname &= " " ; if troop is not $eKing, $eQueen, $eCastle, $eWarden add the plural "s"
	Return $sTroopname
EndFunc   ;==>NameOfTroop
