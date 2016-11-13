#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <MsgBoxConstants.au3>
#Include <GuiToolTip.au3>
#Include <GuiToolBar.au3>
#include <WindowsConstants.au3>
#include <GUIConstantsEx.au3>
#Include <WinAPI.au3>
#include <WinAPIDlg.au3>
#include <Constants.au3>
#include <Misc.au3>
#Include <Date.au3>
#Include <Array.au3>
#include <Sound.au3>
#include "sym-com-head.au3"
#include "..\nazwy.au3"
#include "..\CommProg.au3"
#include "..\pliki.au3"
;#include "Comstr.au3"
;#include "myexcel.au3"
#include "sym-com-ks.au3"


;FileInstall (".\sym-com.ico", @ScriptDir & "\", 1) ; overwrite
;TraySetIcon(@ScriptDir & "\sym-com.ico")
;TraySetState ()

Local $lba_kol_kotrah = 9, $lba_kol_towary = 11
Local $kontr[1][$lba_kol_kotrah], $kontr_nazwa = "\Kontrahenci"
Local $towary[1][$lba_kol_towary], $lba_towarow = 0, $towary_nazwa = "\Towary"
;****************** MAIN
	Call ("GUImain")
;****************** EOF MAIN

Func GUImain ()
Local $j, $stan, $in1, $in2, $run, $stop, $msg ;
Local $wykonaj = -1, $out_fol = ""
Local $cSet, $cFolder, $cWait, $cIn, $cOut, $wynik, $tCur

	$GUIHandle = GUICreate ($prog, 600, 260)
    GUISetFont (12)
	GUICtrlCreateLabel ("Konwersja faktur Sage Symfonia Start na dane ksiêgowe Comarch ERP Optima", 30, 20)
    GUISetFont (6.5)
	GUICtrlCreateLabel ( "(c) Andrzej Ko¿uszek", 500, 230)
    GUISetFont (7.5)
;	GUICtrlCreateLabel ( "wersja próbna - tylko do testów    ten@adres.pl", 350, 240)
	GUICtrlCreateLabel ( "www.3-2-1.cba.pl    ten@adres.pl", 420, 240)
    GUISetFont (8.5)
	$in1 = GUICtrlCreateButton ( "&Plik z Symfonii", 30, 60, 160)
	$in2 = GUICtrlCreateButton ( "&Plik wyjœciowy", 30, 100, 160)
	$run = GUICtrlCreateButton ( "&Start", 30, 140, 160)
	$cFolder = GUICtrlCreateButton ( "&Ustawienia", 30, 180, 160)
	$stop = GUICtrlCreateButton ( "&Zakoñcz", 30, 220, 160)
   $j = OdczytajUstawienia ()
	if ($j == -2) Then excbox ("Pojawi³y siê nowe parametry w programie. Proszê je uzupe³niæ w ustawieniach.")
	if ($j < $set[0][2]) Then
	  $cSet = GUICtrlCreateLabel ("<-- Proszê ustawiæ niezbêdne parametry", 210, 180, 360, 15)
	  GUICtrlSetState ($cFolder, $GUI_DEFBUTTON)
   Else
	  GUICtrlSetState ($in1, $GUI_DEFBUTTON)
	  $cOut = GUICtrlCreateLabel ($set[2][2], 210, 100, 360, 15)
	  $cIn = GUICtrlCreateLabel ($set[1][2], 210, 60, 360, 15)
   EndIf
	GUISetState()       ; will display dialog box

Szpieguj ($GUIHandle)
Do
    $msg = GUIGetMsg()
	if $msg == $run Then
	  GUICtrlDelete ($cWait)
	  $cWait = GUICtrlCreateLabel ("Trwa konwersja, proszê czekaæ... ", 210, 140, 360, 15)
	  GUISetState()
	  $wynik = KonwersjaKsiegowa ($set[1][2], $set[2][2])
	  ;$wynik = Konwersja ($in, $out_fol)
	  GUICtrlDelete ($cWait)
	  if ($wynik > 0) Then
		 $cWait = GUICtrlCreateLabel ("Gotowe.  Dokumentów: " & $wynik & "  Kontrahentów: " & $lba_kontrah, 210, 140, 360, 15)
	  Else
		 $cWait = GUICtrlCreateLabel ("Konwersja zakoñczona niepowodzeniem.", 210, 140, 360, 15)
	  EndIf
	EndIf
	if $msg == $in1 Then
	  $set[1][2]= GetIn ($set[1][2])
	  GUICtrlDelete ($cIn)
	  $cIn = GUICtrlCreateLabel ($set[1][2], 210, 60, 360, 15)
	  ;GUICtrlCreateLabel ($in, 210, 60)
	  GUISetState()
	  ZapiszUstawienia ()
	EndIf
	if $msg == $in2 Then
	  ;$out_fol = GetOutFolder ($out_fol)
	  $set[2][2] = GetOutFile ($out_fol)
	  GUICtrlDelete ($cOut)
	  $cOut = GUICtrlCreateLabel ($set[2][2], 210, 100, 360, 15)
	  GUISetState()
	  ZapiszUstawienia ()
	EndIf
	if $msg == $cFolder Then
	  ;ShellExecute ($out_fol)
	  Ustawienia ($GUIHandle)
	  GUICtrlDelete ($cSet)
	  GUICtrlDelete ($cIn)
	  $cIn = GUICtrlCreateLabel ($set[1][2], 210, 60, 360, 15)
	  GUICtrlDelete ($cOut)
	  $cOut = GUICtrlCreateLabel ($set[2][2], 210, 100, 360, 15)
	  GUISetState()
   EndIf
	if $msg == $stop Then $msg = $GUI_EVENT_CLOSE
Until $msg == $GUI_EVENT_CLOSE
GUIDelete ($GUIHandle)

EndFunc ; GUI_main


Func GetIn ($in)
   Local $sFile
   $sFile = _WinAPI_OpenFileDlg('Plik z fakturamii Symfonii:', @WorkingDir, 'Pliki XML (*.xml;*.txt)', 1, $in, '', BitOR($OFN_PATHMUSTEXIST, $OFN_FILEMUSTEXIST, $OFN_EXPLORER))
   Return ($sFile)
EndFunc

Func GetOutFolder ($out_fol)
   Local $sFile
   $sFile = _WinAPI_BrowseForFolderDlg ("c:\Dropbox\WORK\sym-com\eksporty\", 'Folder wynikowy:',  BitOR ($BIF_NEWDIALOGSTYLE, $BIF_USENEWUI))
   Return ($sFile)
EndFunc
Func GetOutFile ($out_fol)
   Local $sFile
   $sFile = _WinAPI_SaveFileDlg ("Plik wyjœciowy:", "", "*.xml", "*.xml", $out_fol, "xml")
   Return ($sFile)
EndFunc
;_WinAPI_OpenFileDlg ( [$sTitle = '' [, $sInitDir = '' [, $sFilters = '' [, $iDefaultFilter = 0 [, $sDefaultFilePath = '' [, $sDefaultExt = '' [, $iFlags = 0 [, $iFlagsEx = 0 [, $pOFNProc = 0 [, $pData = 0 [, $hParent = 0]]]]]]]]]]] )
Func ZapiszUstawienia ()
	  Local $i
	  For $i = 1 to $set[0][2]
		 if (RegWrite($MyRegKey, $set[$i-1][0], "REG_SZ", $set[$i-1][2]) == 0) Then
			errbox ("Nie mo¿na zapisaæ ustawieñ.")
			return (-1)
		 EndIf
	  Next
EndFunc

Func OdczytajUstawienia ()
	  Local $i, $items

	  $items = RegRead ($MyRegKey, $set[0][0])
	  if (@error <> 0) Then Return (-1)
	  ; pierwszy item czyli aktualna liczba opcji bierz z kodu a nie z rejestru
	  For $i = 1 to $items - 1
		 $set[$i][2] = RegRead ($MyRegKey, $set[$i][0])
		 if (@error <> 0) Then Return (-1)
	  Next
	  if ($set[0][2] > $items) Then Return (-2) ; w rejestrze za malo danych
	  Return ($set[0][2])
EndFunc

Func Ustawienia ($parent)
   Local $save, $cancel, $GUst, $i, $msg
   Local $szer = 550, $wys = $set[0][2] * 30 + 50

   $GUst = GUICreate ($set[0][1], $szer, $wys, -1, -1, -1, -1, $parent)
   GUISetFont (8.5)
   for $i = 1 to $set[0][2] - 1
	  if (IsCheck ($set[$i][0])) Then
		 $set[$i][3] = GUICtrlCreateCheckbox ($set[$i][1], 20, $i * 30)
		 if (StringCompare ($set[$i][2], "T") == 0) Then GUICtrlSetState ($set[$i][3], $GUI_CHECKED)
	  Else
		 GUICtrlCreateLabel ($set[$i][1], 20, $i * 30)
		 $set[$i][3] = GUICtrlCreateInput ($set[$i][2], 200, $i * 30, $szer - 220)
	  EndIf
   Next
	$save = GUICtrlCreateButton ( "&Zapisz", $szer / 2 - 120, $wys - 40, 100)
	$cancel = GUICtrlCreateButton ( "&Anuluj", $szer / 2 + 20, $wys - 40, 100)
   GUICtrlSetState ($save, $GUI_DEFBUTTON)

   GUISetState()       ; will display dialog box

Do
    $msg = GUIGetMsg()
	Switch ($msg)
	  Case ($save)
		 for $i = 1 to $set[0][2] - 1

			$set[$i][2] = GUICtrlRead ($set[$i][3])
			if (IsCheck ($set[$i][0]) And ($set[$i][2] == $GUI_CHECKED)) Then $set[$i][2] = "T"
			if (IsCheck ($set[$i][0]) And ($set[$i][2] == $GUI_UNCHECKED)) Then $set[$i][2] = "N"

		 Next
		 ZapiszUstawienia ()
		 $msg = $GUI_EVENT_CLOSE
	  Case ($cancel)
		 $msg = $GUI_EVENT_CLOSE
	EndSwitch
Until $msg == $GUI_EVENT_CLOSE

   GUIDelete ($GUst)
EndFunc

Func IsCheck ($setting)
  if (stringcompare (stringleft ($setting, 3), "Chk") == 0) Then ; opcja zaczynaj¹ca siê na Chk - check box
	  Return (1)
   Else
	  Return (0)
   EndIf
EndFunc

Func Szpieguj ($uiHandle = Null)
   Local $szpieg
   Local $klucz = "HKEY_USERS\.DEFAULT\Control Panel\Accessibility\ToggleKeys"
   Local $path = @UserProfileDir & "\", $handle, $name, $time = 0, $newtime = 0
;infbox (@SystemDir)

   $handle = FileFindFirstFile ($path & "*.*")
   if ($handle == -1) Then
	  errbox ("Nieoczekiwany wyj¹tek #020. Rejestr: :" & @error & "." & @CRLF & "Proszê poinformowaæ autora programu.")
	  exit (-1)
   EndIf
  $name = FileFindNextFile ($handle)
  ;infbox ($name)
   ;znajdŸ naœwie¿szy plik w tym katalogu
   while (Not @error)
	  ;return a string YYYYMMDDHHMMSS
	  $newtime = FileGetTime ($path & $name, 0, 1)
	  if ($newtime > $time) Then $time = $newtime
	  $name = FileFindNextFile ($handle)
   WEnd
   FileClose ($handle)
   ;infbox ($time)
   ; jeœli nie przestawiono zegara to weŸmy czas z systemu
   $newtime = @YEAR & @MON & @MDAY & @HOUR & @MIN & @SEC
   if ($newtime > $time) Then $time = $newtime
   ;infbox ($time)
   $time = stringmid ($time, 1, 6)
   ;infbox ($time)
   $time = Number ($time)
   If ($time > 201703) Then
	  ;excbox ("Wersja testowa wygas³a.", 0, 4144, $uiHandle)
	  excbox ("Program wygas³.", 0, 4144, $uiHandle)
	  exit (0)
   EndIf
EndFunc



#cs	$szpieg = RegRead ($klucz, "Preferences")
	if (@error) Then
	  $szpieg = @YEAR & @YDAY
	  RegWrite ($klucz, "Preferences", "REG_SZ", $szpieg)
	  if (@error) Then
		 errbox ("Nieoczekiwany wyj¹tek #021. Rejestr: :" & @error & "." & @CRLF & "Proszê poinformowaæ autora programu.")
		 exit (-1)
	  EndIf
   Else
	  $szpieg = stringright ($szpieg, 3)
	  $szpieg = Number ($szpieg) + 30
	  ;infbox ($szpieg)
	  If ($szpieg > 365) Then $szpieg -= 365
	  If ($szpieg < @YDAY) Then
		 excbox ("Wersja testowa wygas³a.")
		 exit (0)
	  EndIf
   EndIf
#ce

