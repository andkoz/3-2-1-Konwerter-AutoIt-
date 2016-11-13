#include-once
;Precyzyjne okre�lenie okna mo�liwe za pomoc� tytu�u ($W...) oraz tekstu ($WTXT...) danego okna.

; KS-APTEKA
Global const $rok = "2014"
Global $ver = "2014"
Global $exeDir = "c:\KS\APW\EXE\"
Global $naglowekTytOknaExe = "KS-AOW "


if WinExists ("KS-AOW 2008") <> 0 then
	$ver = "2008"
	$exeDir = "c:\KS_ROB\APW\EXE\"
	$naglowekTytOknaExe = "KS-Apteka "
EndIf
if WinExists ("KS-AOW 2011") <> 0 then
	$ver = "2011"
	$naglowekTytOknaExe = "KS-Apteka "
EndIf
if WinExists ("KS-AOW 2012") <> 0 then
	$ver = "2012"
	$naglowekTytOknaExe = "KS-AOW "
EndIf
if WinExists ("KS-AOW 2013") <> 0 then
	$ver = "2013"
	$naglowekTytOknaExe = "KS-AOW "
EndIf

Global const $EXEapman = "c:\KS\APW\apman.exe"
Global const $EXEkomunikacja = $exeDir & "APW44.EXE"
Global const $EXkontrola = "APW23.exe"
Global const $EXEkontrola = $exeDir & $EXkontrola
Global const $EXsprzedaz = "APW11.exe"
Global const $EXEsprzedaz = $exeDir & $EXsprzedaz
Global const $EXzestaw = "APW21.exe"
Global const $EXEzestaw = $exeDir & $EXzestaw
Global const $EXzakupy = "APW13.exe"
Global const $EXEzakupy = $exeDir & $EXzakupy
Global const $EXarch = "APW43.exe"
Global const $EXEarch = $exeDir & $EXarch

Global const $Wpytanie = "Pytanie"
Global const $Winformacja = "Informacja"
Global const $Wuwaga = "Uwaga"
Global const $Wwybor_druku = "[class:TPrnPrintForm]"
Global const $Wdrukowanie = "[class:TPrnProgressForm]"

Global const $Wzakupy = $naglowekTytOknaExe & $ver & " - Zakupy"
Global const $Wpajaczek = "[" & $naglowekTytOknaExe & $ver & " - Zakupy] - Dokumenty"
Global const $Wlistafaktur = "[" & $naglowekTytOknaExe & $ver & " - Zakupy] - Przegl�danie i poprawki wprowadzonych dokument�w /Magazyn 1"
Global const $Wpozycje = "[" & $naglowekTytOknaExe & $ver & " - Zakupy] -"
Global const $WpozycjeTresc = "Faktura VAT zakupu - "
Global const $Wkontrola = $naglowekTytOknaExe & $ver & " - Kontrola"
Global const $Wkomunikacja = "KS-AOW " & $ver & " - Komunikacja"
Global const $Warch = $naglowekTytOknaExe & $ver & " - Archiwer"

Global const $Wsprzedaz = $naglowekTytOknaExe & $ver & " - Sprzeda�"
Global const $Wsprzedaz_zamowienie = "Zam�wienie / lista brak�w ze sprzeda�y"
Global const $WTXTsprzedaz_raport_kasowy = "Raport kasowy"
;Global const $WTXTsprzedaz_menu_glowne = "KS-Apteka"
; gdzieniegdzie (w danej wersji KS) pojawia sie taki tekscik w srodku okna:
Global const $WTXTsprzedaz_menu_glowne = "bu"
Global const $Wzestaw = $naglowekTytOknaExe & $ver & " - Zestawienia"

Global const $WpoprawaKartZakupu = "Poprawa kart zakupu (Magazyn 1)"

Global const $blozDir = "\\S-1\c\KS\APW\TRANSFER\"

; istotniejsze zmiany nazw w nowej wersji programu
If $ver == 2011 Then
 ;$Wpozycje = "[KS-Apteka " & $ver & " - Zakupy] - Pozycje dokumentu zakupu"

EndIf

; END KS-APTEKA

Global const $Wmetki = "cenyzlkody.ods"
if FileExists ("c:\vil11.") Then
	Global $boxPath = "c:\dropbox"
	Global $gnypMenuData =  "\bazaap\menu.txt"
	Global $gnypMenuExe = $boxPath & "\bazaap\menu.exe"
Else
	Global $boxPath = "\\s-3\c\dropbox"
	Global $gnypMenuData = "\bazaap\menu.txt"
	Global $gnypMenuExe = $boxPath & "\bazaap\menu.exe"
EndIf
Global Const $skryptDir = "\\S-1\c\skrypty\"
; tam skad uruchomione fak - stamtad i reszta
Global Const $skrBackup = @ScriptDir & "\fak_back.exe"
Global Const $skrFakExe = @ScriptDir & "\fak_exe.exe"
;Global Const $skrFakExe = "C:\Program Files\AutoIt3\autoit3" & " " & @ScriptDir & "\fak_exe.au3"
Global Const $EXEfakExe = "fak_exe.exe"
Global Const $EXEfak = "fak.au3"

Global Const $dPakuje = "//s-3/c/ksbaza/ks-apw/pakuje.txt"
Global Const $dCopy1_3 = "//s-3/c/ksbaza/ks-apw/copy1-3.txt"
Global Const $dArchKS2 = "//s-3/c/ksbaza/ks-apw/ArchKS2.txt"
Global Const $dtransCzekaNaKase = "//s-3/c/ksbaza/ks-apw/trans_czeka_na_kase.txt"
Global Const $dtransCofnij = "//s-3/c/ksbaza/ks-apw/cofnij_trans.txt"

Global Const $CMDtransZam = "\\S-1\C\SKRYPTY\transfer.cmd a trans_zam"
Global Const $CMDtransZamBezKasy = "\\S-1\C\SKRYPTY\transfer.cmd a trans_zam czekaj_na_kase"

Global Const $zesteleDir = "\\S-1\c\zest-ele\"
Global Const $zamDir = "\\S-1\c\zest-ele\ZAM\"
Global Const $plikKasy = $zesteleDir & "kasa.ods"
Global Const $Wkasa = "kasa"
Global Const $konfig = @ScriptDir & "\konfig.fak"

Global Const $DOKreklSlawex = @UserProfileDir & "\Pulpit\reklamacja Slawex.ods"
Global Const $WreklSlawex = "reklamacja Slawex.ods - OpenOffice.org Calc"

Global Const $PolaczeniaSieciowe = @AppDataCommonDir & "\Microsoft\Network\Connections\Pbk\rasphone.pbk"
Global Const $WPolaczeniaSieciowe = "Po��czenia sieciowe - rasphone.pbk"
Global Const $WLaczenie = "��czenie z TP 2"
Global Const $WTrwaLaczenie = "Trwa ��czenie z TP 2"

Global Const $EXEsoffice = "c:\Program Files\OpenOffice.org 3\program\soffice.exe"
Global Const $EXEscalc = "c:\Program Files\OpenOffice.org 3\program\scalc.exe"

Global Const $Wbeztyt = "Bez tytu�u "
Global Const $RaportCSV = "c:\temp\raport.csv"

; pola: klawisz, funkcja, tip, znacznik: [1|2|0|3|4]
;                                         0 - nie wy�wietlaj
;                                         1 - podst. f. apteczna
;                                         2 - ext. f. apteczna
;                                         3 -
;                                         4 - podst. f. domowa
Local $nKeys = 32
Dim $keys[$nKeys][4] = 	[["+!d", "Dyskietka", "SHIFT ALT D" & @LF & "wczytanie dyskietki z faktur�", 1], _
					["+!e", "EksportDoSCalc", "SHIFT ALT E" & @LF & "eksport faktur do arkusza metek", 1], _
					["+!{ENTER}", "Reload", "SHIFT ALT ENTER" & @LF & "przerwanie programu i jego ponowne za�adowanie", 1], _
					["+!{F9}", "AltF9Handler", "ALT F9" & @LF & "", 0], _
					["+!{F10}", "AltF10Handler", "ALT F10" & @LF & "", 0], _
					["+!z", "ZestawienieDzienne", "SHIFT ALT Z" & @LF & "zestawienie dzienne i recept", 1], _
					["+!r", "RaportFiskalny", "SHIFT ALT R" & @LF & "dzienny raport fiskalny", 1], _
					["+!t", "Wyslij", "SHIFT ALT T" & @LF & "wysy�anie polecenia", 2], _
					["+!i", "Info", "SHIFT ALT I" & @LF & "informacja o dostepnych klawiszach i stanowiskach", 1], _
					["+!q", "Koniec", "SHIFT ALT Q" & @LF & "koniec tego programu", 1], _
					["+!u", "Wylacz", "SHIFT ALT U" & @LF & "wy��czenie komputera", 1], _
					["+!p", "ProgPing", "SHIFT ALT P" & @LF & "wys�anie PING do programu na innym stanowisku", 1], _
					["+!a", "ArchKS", "SHIFT ALT A" & @LF & "archiwizacja bazy programem Archiwer Kamsoftu", 1], _
					["+!l", "PokazLeki", "SHIFT ALT L" & @LF & "przegl�d lek�w w programach lojalno�ciowych", 1], _
					["+!.", "Proba", "SHIFT ALT ." & @LF & "funkcja pr�bna", 2], _
					["+!0", "WyslijKompleksoweKonczenieDnia", "SHIFT ALT 0" & @LF & "kompleksowe ko�czenie dnia" & @LF & "i zamkni�cie stanowisk", 1], _
					["+!K", "Reklamacja", "SHIFT ALT K" & @LF & "wstawienie danych z karty zakupu do reklamacji", 1], _
					["+!b", "Back", "SHIFT ALT B" & @LF & "backup bazy danych", 1], _
					["+!m", "GUImain", "SHIFT ALT M" & @LF & "wywo�anie tego okienka dialogowego", 1], _
					["+!^z", "DaneDoInternetu", "SHIFT ALT CTRL Z" & @LF & "wysy�anie danych do internetu", 1], _
					["+!w", "PokazListeOkien", "SHIFT ALT W" & @LF & "wy�wietlenie listy wszystkich istniej�cych okien", 2], _
					["+![", "PingujPozostalych", "SHIFT ALT [" & @LF & "Ping", 2 ], _
					["+!v", "PodliczanieKasy", "SHIFT ALT V" & @LF & "wywo�anie pliku podsumowania kasy i wklejenie do niego" & @LF & "sumy z zestawienia sprzedazy", 1], _
					["+!g", "MenuGnypkowe", "SHIFT ALT G" & @LF & "wywo�anie menu gnypkowego (je�li gnypek jest)", 3], _
					["", "PolaczZInternetem", "Brak skr�tu klawiaturowego" & @LF & "Po��czenie z internetem", 3], _
					["", "RozlaczZInternetem", "Brak skr�tu klawiaturowego" & @LF & "Roz��czenie z internetem", 3], _
					["", "WyswietlDateCzasBazy", "Brak skr�tu klawiaturowego" & @LF & "WyswietlDateCzasBazy", 3], _
					["", "ZacznijOdswiezac", "Brak skr�tu klawiaturowego" & @LF & "wciska F5 co zadan� ilosc sekund", 3], _
					["", "PokazIleWKasie", "Brak skr�tu klawiaturowego" & @LF & "pokazuje raport kasowy og�lny w sprzeda�y", 1], _
					["", "WylaczPoSkanowaniu", "Brak skr�tu klawiaturowego" & @LF & "czeka na zakonczenie skanowania antywirusa i wylacza komputer", 3], _
					["+!f", "OdbierzFakturyPrzezIternet", "SHIFT ALT F" & @LF & "�ci�gni�cie faktur z gmaila", 1], _
					["+!o", "OdblokujProgramy", "SHIFT ALT O" & @LF & "odblokowanie program�w, kt�rych termin przydatno�ci" & @LF & "ju� niestety min��", 4]]
Local Const $help = @LF & "SHIFT ALT D - wczytanie dyskietki z faktur�" _
					& @LF & "SHIFT ALT E - eksport faktur do arkusza metek" _
					& @LF & "SHIFT ALT Z - zestawienie dzienne i recept" _
					& @LF & "SHIFT ALT R - dzienny raport fiskalny" _
					& @LF & "SHIFT ALT T - wysy�anie polecenia" _
					& @LF & "SHIFT ALT I - ta informacja o klawiszach" _
					& @LF & "SHIFT ALT Q - koniec tego programu" _
					& @LF & "SHIFT ALT U - wy��czenie komputera" _
					& @LF & "SHIFT ALT 0 - kompleksowe ko�czenie dnia"	_
					& @LF & "SHIFT ALT K - wstawienie danych z karty zakupu do reklamacji"

Local Const $pass = "zxc"
