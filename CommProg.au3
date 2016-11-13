#include-once
#include <GuiConstantsEx.au3>
#include <WindowsConstants.au3>
#include <GuiListView.au3>
#include <FTPEx.au3>
#include <WinAPI.au3>
#include "nazwy.au3"
#include "pliki.au3"
;#include "CommApt.au3"
;Global $GW_OWNER

Opt ('MustDeclareVars', 1)
Opt("WinTitleMatchMode", 1)
AutoItSetOption ("SendKeyDelay", 50)


;Global Const $prog = "Skrótowiec apteczny"
Global $to_stanowisko; = 0 ; current
Global $prog, $port; = 666
Global Const $yes = 6
Global Const $no = 7
Global Const $tak = 6
Global Const $nie = 7

Func PrzerwijProgram ()
	TCPShutdown ()
	Exit (9)
EndFunc

Func MyWinWait ($title = "", $text = "", $timeout = 300, $verbose = 1)
	Local $ret

	$ret = WinWait ($title, $text, $timeout)
	if ($ret == 0  And $verbose == 1) Then
		errbox ("Przekroczony czas oczekiwania na zaistnienie okna" & @LF & $title & " " & " timeout = " & $timeout)
	EndIf
	Return ($ret)
EndFunc

Func MyWinWaitClose ($title = "", $text = "", $timeout = 300, $verbose = 1)
	Local $ret

	$ret = WinWaitClose ($title, $text, $timeout)
	if ($ret == 0  And $verbose == 1) Then
		errbox ("Przekroczony czas oczekiwania na zamkniêcie okna" & @LF & $title & " " & " timeout = " & $timeout)
	EndIf
	Return ($ret)
EndFunc

Func MyWinWaitActive ($title = "", $text = "", $timeout = 300, $verbose = 1)
	Local $ret

	$ret = WinWaitActive ($title, $text, $timeout)
	if ($ret == 0 And $verbose == 1) Then
		errbox ("Przekroczony czas oczekiwania na aktywacjê okna" & @LF & $title & " " & " timeout = " & $timeout)
	EndIf
	Return ($ret)
EndFunc

Func MyWinWaitNotActive ($title = "", $text = "", $timeout = 300, $verbose = 1)
	Local $ret

	$ret = WinWaitNotActive ($title, $text, $timeout)
	if ($ret == 0 And $verbose == 1) Then
		errbox ("Przekroczony czas oczekiwania na deaktywacjê okna" & @LF & $title & " " & " timeout = " & $timeout)
	EndIf
	Return ($ret)
EndFunc

Func MyWinActivate ($title = "", $text = "", $timeout = 300, $verbose = 1)
	Local $ret
	Local $Tpocz, $Tteraz

	$Tpocz = TimerInit ()
	Do
		$ret = WinActivate ($title, $text)
		if $ret > 0 Then Return ($ret)
		$Tteraz = TimerDiff ($Tpocz)
	Until ($Tteraz > ($timeout * 1000))
	if  $verbose == 1 Then errbox ("Przekroczony czas polecenia aktywacji okna" & @LF & $title & " " & " timeout = " & $timeout)
	Return ($ret)
EndFunc

;0 = Logoff
;1 = Shutdown
;2 = Reboot
;4 = Force
;8 = Power down
;16= Force if hung
;32= Standby
;64= Hibernate

Func WinSend ($txt, $title = "", $winTxt = "")
    Local $ret

	MyWinWait ($title, $winTxt)
	Sleep (25)
	MyWinActivate ($title, $winTxt)
	$ret = SendKeepActive ($title, $winTxt)
	if $ret == 0 Then errbox ("SendKeepActive zwraca 0 przy oknie" & @LF & $title)
	Sleep (25)
	;WinWaitActive ($title, $winTxt)
	Send($txt)
    SendKeepActive ("")
EndFunc

Func Wylacz ()
	;if (DajGnypka () <> "0:") And (DajGnypka () <> $boxPath) Then
	;	excbox ("Odnotowano gnypka w którymœ z otworów. Proszê mi go usun¹æ.")
	;EndIf
	MsgBox (64, $prog, "Wy³¹czam komputer . . .", 7) ;
	TCPShutdown ()
	Shutdown (1 + 4 + 8)
EndFunc

Func Koniec ()
	MsgBox (64, $prog, "Koniec dzia³ania programu.", 7) ;
	TCPShutdown()
	Exit (0)
EndFunc
Func CichyKoniec ()
	TCPShutdown()
	Exit (0)
EndFunc

Func Reload ()
	splashon ("Prze³adowanie programu ...")
	OnAutoItExitRegister ("Load")
	TCPShutdown()
	SplashOff ()
	Exit (0)
EndFunc

Func Load ()
	ShellExecute (@AutoItExe, "/silent")
EndFunc

#cs
0 OK button 0x0
1 OK and Cancel 0x1
2 Abort, Retry, and Ignore 0x2
3 Yes, No, and Cancel 0x3
4 Yes and No 0x4
5 Retry and Cancel 0x5
6 ** Cancel, Try Again, Continue 0x6
decimal flag Icon-related Result hexadecimal flag
0 (No icon) 0x0
16 Stop-sign icon 0x10
32 Question-mark icon 0x20
48 Exclamation-point icon 0x30
64 Information-sign icon

Button Pressed Return Value
OK  1
CANCEL  2
ABORT  3
RETRY  4
IGNORE  5
YES  6
NO  7
TRY AGAIN ** 10
CONTINUE ** 11

#ce

Func ErrBox ($tresc = "", $czas = 0, $flagi = 4112)
	Local $txt
	if @ScriptName == $EXEfak Then ; jesli to fak, to uruchamia fak_exe, aby to zrobil za fak
		$tresc = StringReplace ($tresc, " ", "`")
		$txt = "ErrBox " & $tresc & " " & $czas & " " & $flagi
		ShellExecute ($skrFakExe, $txt)
		Return 1
	EndIf
	$tresc = StringReplace ($tresc, "`", " ")
	Return MsgBox ($flagi, $prog, "B³¹d!" & @LF & $tresc, $czas, $GUIHandle)
EndFunc
Local $comCzas = 0
Func InfBox ($tresc = "", $czas = 0, $flagi = 4160)
	Local $txt
	if @ScriptName == $EXEfak Then ; jesli to fak, to uruchamia fak_exe, aby to zrobil za fak
		$tresc = StringReplace ($tresc, " ", "`")
		$txt = "InfBox " & $tresc & " " & $czas & " " & $flagi
		ShellExecute ($skrFakExe, $txt)
		Return 1
	EndIf
	$tresc = StringReplace ($tresc, "`", " ")
	$comCzas = $czas
	AdlibRegister ("Odliczaj")
	$txt = MsgBox ($flagi, $prog, $tresc, $czas, $GUIHandle)
	AdlibUnRegister ("Odliczaj")
	Return ($txt)
EndFunc
Func Odliczaj ()
	Local $wh = "", $i
	Return (0)
	if $comCzas = 0 Then
		AdlibUnRegister ("Odliczaj")
		Return (0)
	EndIf
	$wh = WinGetHandle ($prog, "OK")
	if $wh == "" Then Return (0)
	ControlSend ($wh, "", "Static2", "Dupa")
	return (1)
EndFunc
Func ExcBox ($tresc = "", $czas = 0, $flagi = 4144, $parent = $GUIHandle)
	Return MsgBox ($flagi, $prog, $tresc, $czas, $parent)
EndFunc
Func QueBox ($tresc = "", $czas = 0, $flagi = 4132)
	Return MsgBox ($flagi, $prog, $tresc, $czas, $GUIHandle)
EndFunc
;InputBox ( "title", "prompt" [, "default" [, "password char" [, width [, height [, left [, top [, timeout [, hwnd]]]]]]]] )
Func InpBox ($tresc = "", $default = "", $czas = 0)
;	Local $szer = 200, $wys = 120
	Return InputBox ($prog, $tresc, $default, "", 250, 180, 300, 150, $czas, $GUIHandle)
EndFunc
Func SplashOn ($tresc = "", $x = 200, $y = 100, $szer = 300, $wys = 50, $size = 10)
	SplashTextOn ("", $tresc, $szer, $wys, $x, $y, 1 + 32 + 16, "", $size, -1)
EndFunc
Func SplashOnCorner ($tresc = "", $x = 30, $y = 20, $szer = 1, $wys = 1, $size = 33)
	SplashTextOn ("", $tresc, $x, $y, $szer, $wys, $size, "", 8, -1)
EndFunc
Local $mySplashHand = 0
Func MySplashOn ($txt = "")
	Local $label

	If ($mySplashHand == 0) Then
		$mySplashHand = GUICreate ("", 200, 40, @DesktopWidth - 303, 50, $WS_POPUP + $WS_BORDER, $WS_EX_TOPMOST)
		$label = GUICtrlCreateLabel ($txt, 1, 15)
		GUICtrlSetColor($label, 0x0000ff)
		GUISetState()
	Else
		GUICtrlSetData ($mySplashHand, $txt)
	EndIf
EndFunc
Func MySplashOff ()
	GUIDelete ($mySplashHand)
	$mySplashHand = 0
EndFunc
Func ErrService ($error, $tresc = "")
	if $error Then
		ErrBox ($tresc)
	EndIf
	Return $error
EndFunc
Local $mySplashHand

Func StartujTCP ()
splashon ("Start TCP ...")
for $i = 1 to 5
	if TCPStartUp() == True Then ExitLoop
	Sleep (5000)
Next
SplashOff ()
EndFunc


Func PokazListeOkien ()
Local $var, $txt, $i, $j = 1

$var = WinList()
while $j <= $var[0][0] - 1
	$txt=""
	For $i = 1 to 40
		$txt = $txt & "Title=" & $var[$j][0] & " Handle=" & $var[$j][1] & " Title=" & $var[$j+1][0] & " Handle=" & $var[$j+1][1] & @LF
		$j += 2
		if $j >= $var[0][0] Then ExitLoop

	Next
	infbox ($txt)
WEnd
EndFunc

Func JestInternet ()
	if Ping ("8.26.56.26", 10000) > 0 Then Return 1 ; to jest DNS Comoda
	Return (0)
EndFunc


Func Menu ($opcje = "Wybierz mnie, wybierz...", $opis = "Wybór opcji:", $fokus = 1)
	Local $opArr, $i, $szerOpcji = 0, $listview, $wybrana, $run, $notrun, $msg, $win
	Local $wysOpcji = 18, $szerLitery = 7

	$opArr = StringSplit ($opcje, "|")
	if ($opArr[0] == 0) Then
		errbox ("Funkcja Menu raportuje brak opcji.")
		Return (0)
	EndIf
	$szerOpcji = StringInStr ($opis, @lf)
	if ($szerOpcji == 0) Then $szerOpcji = StringLen ($opis)
	For $i = 1 To $opArr[0]
		$wybrana = StringLen ($opArr[$i])
		;infbox ($wybrana)
		if ($szerOpcji < $wybrana) Then $szerOpcji = $wybrana
	Next
	if ($szerOpcji < 15) Then $szerOpcji = 15
 	$win = GUICreate($prog, $szerOpcji * $szerLitery + 20, $wysOpcji * $opArr[0] + 90, 400, 250, -1, $WS_EX_ACCEPTFILES)
	GUICtrlCreateLabel ($opis, 10, 10, $szerOpcji * $szerLitery, 50)
	$listview = GUICtrlCreateListView ("", 10, 55, $szerOpcji * $szerLitery, _
	$wysOpcji * $opArr[0], $LVS_LIST); $LVS_NOCOLUMNHEADER);,$LVS_SORTDESCENDING)
	$run = GUICtrlCreateButton("&Wybierz", 10, $wysOpcji * $opArr[0] + 58, 70, 20)
	$notrun = GUICtrlCreateButton("&Zakoñcz [ESC]", 85, $wysOpcji * $opArr[0] + 58, 100, 20)
	GUICtrlSetState ($run, $GUI_DEFBUTTON)
Dim $items[$opArr[0] + 1]

	For $i = 1 To $opArr[0]
		$items[$i] = GUICtrlCreateListViewItem ($opArr[$i] & "                                                                   ", $listview)
	Next
	GUICtrlSetState ($items[$fokus], $GUI_FOCUS)
	GUISetState()
    Do
        $msg = GUIGetMsg()

        Select
			Case $msg = $GUI_EVENT_CLOSE
				$wybrana = 0
			Case $msg = $run
                $wybrana = GUICtrlRead($listview)
				$wybrana -= 6
				;infbox ($wybrana)
				$msg = $GUI_EVENT_CLOSE
			Case $msg = $notrun
				$wybrana = 0
				$msg = $GUI_EVENT_CLOSE
        EndSelect
    Until $msg = $GUI_EVENT_CLOSE
	GUIDelete ($win)
	Return ($wybrana)
EndFunc

Func IleStrInStr ($str, $substr, $casesense = 0, $occurrence = 1, $start = 1)
   Local $i = 1, $pos = 0

   Do
	  $pos = StringInStr ($str, $substr, $casesense, $i, $start)
	  if ($pos > 0) Then $i += 1
   Until ($pos == 0)
   Return ($i - 1)
EndFunc

Func OdczytajZwyklyTag ($str, $substr, $casesense = 0, $occurrence = 1, $start = 1)
   Local $pos, $poskon

   		 $pos = MyStringInStr ($str, $substr, $casesense, $occurrence, $start)
		 if ($pos < 1) Then Return (0)
		 $poskon = MyStringInStr ($str, StringReplace ($substr, "<", "</"), $casesense, $occurrence, $start)
		 if ($poskon < 1) Then Return (0)
		 $pos += StringLen ($substr) ; omin tag i wskazuj bezp. na wartoœæ
		 Return (StringMid ($str, $pos, $poskon - $pos))
EndFunc
Func MyStringInStr ($string, $substring, $casesense = 0, $occurrence = 1, $start = 1)
   Local $pos = 0

   $pos = StringInStr ($string, $substring, $casesense, $occurrence, $start)
   If ($pos = 0) Then ErrBox ("Nie znaleziono ci¹gu " & $substring & ".")
   Return ($pos)
EndFunc
