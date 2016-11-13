#include-once
#include "sym-com-head.au3"
#include "sym-com-fk.au3"
#include "..\CommProg.au3"
#include "..\Pliki.au3"

Func DajOpcje ($opcja)
   Local $i
   for $i = 1 to $set[0][2] - 1
	  if (StringCompare ($set[$i][0], $opcja) == 0) Then Return ($set[$i][2])
   Next
   Return (Null)
EndFunc

Func OdczytajPlikWejsciowy ($in)
   Local $Symstr, $Dokstr, $Fragstr, $fin, $i, $pos, $poskon, $kolej_dok, $kolej_kontr
   Local $Pozstr, $lba_poz_w_dok, $kolej_poz

   $fin = MyFileOpen ($in)
   if ($fin < 0) Then Return (-1)
   $Symstr = FileRead ($fin)
   FileClose ($fin)

   $lba_dokument = IleStrInStr ($Symstr, $dokument[0][0])
   $lba_kontrah = IleStrInStr ($Symstr, $kontrah[0][0])
   if ($lba_dokument <> $lba_kontrah) Then
	  infbox ("Uwaga: liczba dokumentow w pliku ró¿na od liczby kontrahentów (z powtórzeniami). Dokumentów:" & $lba_dokument & "    Kontrahentów:" & $lba_kontrah)
   EndIf

   For $kolej_dok = 1 to $lba_dokument
	  $Dokstr = OdczytajZwyklyTag ($Symstr, $dokument[0][0], 0, $kolej_dok)
	  For $i = 1 To $dokument[0][1]
		 $dokument[$i][1] = OdczytajZwyklyTag ($Dokstr, $dokument[$i][0])
		 $wszystkie_dokument[($kolej_dok - 1) * $dokument[0][1] + $i - 1][1] = $dokument[$i][1]
	  Next
	  if ((StringCompare ($dokument[4][1], "Faktura VAT") <> 0) And (StringCompare ($dokument[4][1], "Korekta faktury") <> 0)) Then ; omijam nie-faktury
		 excbox ("Uwaga. Dokument " & $dokument[3][1] & " nie jest faktur¹.")
		 return (-3)
	  EndIf
	  For $i = 1 To $naglowek[0][1]
		 $naglowek[$i][1] = OdczytajZwyklyTag ($Dokstr, $naglowek[$i][0])
		 $wszystkie_naglowek[($kolej_dok - 1) * $naglowek[0][1] + $i - 1][1] = $naglowek[$i][1]
	  Next
	  $lba_poz_w_dok = IleStrInStr ($Dokstr, $pozycja[0][0])
	  ; we wzystkich pozycjach tutaj zapisuje il pozycji w tym dokumencie
	  $wszystkie_pozycja[$kolej_dok - 1][0][0][1] = $lba_poz_w_dok
	  ;excbox ("dok:" & $kolej_dok & "    lba_poz:" & $wszystkie_pozycja[$kolej_dok - 1][0][0][1])

	  For $kolej_poz = 1 To $lba_poz_w_dok
		 $Pozstr = OdczytajZwyklyTag ($Dokstr, $pozycja[0][0], 0, $kolej_poz)
		 For $i = 1 To $pozycja[0][1]
			; ta jednostka sie powtarza - patrz plik zrolowy xml symfonii
			if (StringCompare ($pozycja[$i][0], "<JednostkaMiary>") == 0) Then
			   $pozycja[$i][1] = OdczytajZwyklyTag ($Pozstr, $pozycja[$i][0], 0, 2) ; drugie occurence
			Else
			   $pozycja[$i][1] = OdczytajZwyklyTag ($Pozstr, $pozycja[$i][0])
			EndIf
			; 2 ostatnie indeksy wszystkie_pozycja pokrywaja sie z indeksami pozycja
			; 1 i 2 sa zero based, 3 i 4:[0][0] reserved, [0][1] number of positions in current doc
			$wszystkie_pozycja[$kolej_dok - 1][$kolej_poz - 1][$i][1] = $pozycja[$i][1]

		 Next
	 ; _ArrayDisplay ($pozycja)
	  Next
;	  _ArrayDisplay ($naglowek_wew)
   Next
;   _ArrayDisplay ($wszystkie_dokument)
;   _ArrayDisplay ($wszystkie_naglowek)
;   _ArrayDisplay ($wszystkie_pozycja)

   For $kolej_kontr = 1 to $lba_kontrah
	  $Dokstr = OdczytajZwyklyTag ($Symstr, $kontrah[0][0], 0, $kolej_kontr)
	  For $i = 1 To $kontrah[0][1]
		 $kontrah[$i][1] = OdczytajZwyklyTag ($Dokstr, $kontrah[$i][0])
		 $wszyscy_kontrah[($kolej_kontr - 1) * $kontrah[0][1] + $i - 1][1] = $kontrah[$i][1]
	  Next
;	  _ArrayDisplay ($kontrah)
   Next
;   _ArrayDisplay ($wszyscy_kontrah)

   Return (0)
EndFunc

; **********************************************************************************************************************************
; **********************************************************************************************************************************
; **********************************************************************************************************************************
; **********************************************************************************************************************************
Func RobNaglowek ()
   ; to jest tylko przypisanie wykorzstywane w innych funkcjach
   $CxmlWersjaBaza = "<WERSJA>2.00</WERSJA><BAZA_ZRD_ID>" & DajOpcje ("SourceBase") & "</BAZA_ZRD_ID>" _
					 & "<BAZA_DOC_ID>" & DajOpcje ("TargetBase") & "</BAZA_DOC_ID>"
   $CxmlOut = $CxmlNagl
EndFunc
Func RobStopke ()
   $CxmlOut = $CxmlOut & "</ROOT>"
EndFunc


Func RobKontrahentow ()
   Local $i, $wstaw
   $CxmlOut = $CxmlOut & "<KONTRAHENCI>"
   $CxmlOut = $CxmlOut & $CxmlWersjaBaza

   For $i = 0 to $lba_kontrah - 1
      $CxmlOut = $CxmlOut & "<KONTRAHENT>"
	  $CxmlOut = $CxmlOut & $CxmlIdZrodla
	  ; do akronimu usuwamy z kodu spacje
	  $wstaw = $wszyscy_kontrah[$i * $kontrah[0][1] + 1][1]
	  $wstaw = StringStripWS ($wstaw, $STR_STRIPALL)
	  $CxmlOut = $CxmlOut & "<AKRONIM><![CDATA[" & $wstaw & "]]></AKRONIM><RODZAJ>Odbiorca</RODZAJ>"
	  ;$CxmlOut = $CxmlOut & "<ZEZWOLENIE><![CDATA[]]></ZEZWOLENIE><OPIS><![CDATA[]]></OPIS><CHRONIONY></CHRONIONY>"
	  $CxmlOut = $CxmlOut & "<RODZAJ></RODZAJ><EKSPORT>krajowy</EKSPORT><FINALNY>Nie</FINALNY><PLATNIK_VAT>Tak</PLATNIK_VAT>"
	  ;$CxmlOut = $CxmlOut & "<MEDIALNY></MEDIALNY><NIEAKTYWNY></NIEAKTYWNY><ROLNIK></ROLNIK><KONTOODB><![CDATA[]]></KONTOODB>"
	  $CxmlOut = $CxmlOut & "<KONTODOST><![CDATA[]]></KONTODOST><FORMA_PLATNOSCI><![CDATA[Pobranie]]></FORMA_PLATNOSCI>"
	  ;$CxmlOut = $CxmlOut & "<FORMA_PLATNOSCI_ID><![CDATA[]]></FORMA_PLATNOSCI_ID><MAX_ZWLOKA></MAX_ZWLOKA><CENY></CENY>"
	  ;$CxmlOut = $CxmlOut & "<JEST_LIMIT_KREDYTU></JEST_LIMIT_KREDYTU><LIMIT_KREDYTU></LIMIT_KREDYTU><NIE_PODLEGA_ROZLICZENIU></NIE_PODLEGA_ROZLICZENIU>"
	  ;$CxmlOut = $CxmlOut & "<UPUST></UPUST><INFORMACJE></INFORMACJE><INDYWIDUALNY_TERMIN></INDYWIDUALNY_TERMIN><TERMIN></TERMIN>"
	  ;$CxmlOut = $CxmlOut & "<KAUCJE_PLATNOSCI></KAUCJE_PLATNOSCI><KAUCJE_TERMIN></KAUCJE_TERMIN><KOD_TRANSAKCJI><![CDATA[]]></KOD_TRANSAKCJI>"
	  ;$CxmlOut = $CxmlOut & "<BLOKADA_DOKUMENTOW></BLOKADA_DOKUMENTOW><LIMIT_PRZETERMINOWANY></LIMIT_PRZETERMINOWANY>"
	  $CxmlOut = $CxmlOut & "<LIMIT_PRZETERMINOWANY_WARTOSC></LIMIT_PRZETERMINOWANY_WARTOSC><KRAJ_ISO><![CDATA[PL]]></KRAJ_ISO>"
	  ;$CxmlOut = $CxmlOut & "<OPIEKUN><![CDATA[]]></OPIEKUN><PRZEDSTAWICIELE><![CDATA[]]></PRZEDSTAWICIELE>"
	  ;$CxmlOut = $CxmlOut & "<ODBIORCY><![CDATA[]]></ODBIORCY><ATRYBUTY><![CDATA[]]></ATRYBUTY><KNT_RACHUNKI><![CDATA[]]></KNT_RACHUNKI>"
	  $CxmlOut = $CxmlOut & "<ADRESY><ADRES><STATUS></STATUS><EAN><![CDATA[]]></EAN><GLN><![CDATA[]]></GLN>"
	  $wstaw = $wszyscy_kontrah[$i * $kontrah[0][1] + 2][1]
	  $CxmlOut = $CxmlOut & "<NAZWA1><![CDATA[" & $wstaw & "]]></NAZWA1>"
	  $CxmlOut = $CxmlOut & "<NAZWA2><![CDATA[]]></NAZWA2><NAZWA3><![CDATA[]]></NAZWA3>"
	  $wstaw = $wszyscy_kontrah[$i * $kontrah[0][1] + 9][1]
	  $CxmlOut = $CxmlOut & "<KRAJ><![CDATA[" & $wstaw & "]]></KRAJ>"
	  $wstaw = $wszyscy_kontrah[$i * $kontrah[0][1] + 8][1]
	  $CxmlOut = $CxmlOut & "<WOJEWODZTWO><![CDATA[" & $wstaw & "]]></WOJEWODZTWO>"
	  $CxmlOut = $CxmlOut & "<POWIAT><![CDATA[]]></POWIAT><GMINA><![CDATA[]]></GMINA>"
	  $wstaw = $wszyscy_kontrah[$i * $kontrah[0][1] + 7][1]
	  $CxmlOut = $CxmlOut & "<MIASTO><![CDATA[" & $wstaw & "]]></MIASTO>"
	  $wstaw = $wszyscy_kontrah[$i * $kontrah[0][1] + 3][1]
	  $CxmlOut = $CxmlOut & "<ULICA><![CDATA[" & $wstaw & "]]></ULICA>"
	  $wstaw = $wszyscy_kontrah[$i * $kontrah[0][1] + 4][1]
	  $CxmlOut = $CxmlOut & "<NR_DOMU><![CDATA[" & $wstaw & "]]></NR_DOMU>"
	  $wstaw = $wszyscy_kontrah[$i * $kontrah[0][1] + 5][1]
	  $CxmlOut = $CxmlOut & "<NR_LOKALU><![CDATA[" & $wstaw & "]]></NR_LOKALU>"
	  $wstaw = $wszyscy_kontrah[$i * $kontrah[0][1] + 6][1]
	  $CxmlOut = $CxmlOut & "<KOD_POCZTOWY><![CDATA[" & $wstaw & "]]></KOD_POCZTOWY>"
	  $CxmlOut = $CxmlOut & "<POCZTA><![CDATA[]]></POCZTA><DODATKOWE><![CDATA[]]></DODATKOWE><NIP_KRAJ><![CDATA[]]></NIP_KRAJ>"
	  $wstaw = $wszyscy_kontrah[$i * $kontrah[0][1] + 10][1]
	  $CxmlOut = $CxmlOut & "<NIP><![CDATA[" & $wstaw & "]]></NIP>"
	  $wstaw = $wszyscy_kontrah[$i * $kontrah[0][1] + 11][1]
	  $CxmlOut = $CxmlOut & "<REGON><![CDATA[" & $wstaw & "]]></REGON>"
	  $wstaw = $wszyscy_kontrah[$i * $kontrah[0][1] + 12][1]
	  $CxmlOut = $CxmlOut & "<PESEL><![CDATA[" & $wstaw & "]]></PESEL>"
	  $wstaw = $wszyscy_kontrah[$i * $kontrah[0][1] + 16][1]
	  $CxmlOut = $CxmlOut & "<TELEFON1><![CDATA[" & $wstaw & "]]></TELEFON1>"
	  $wstaw = $wszyscy_kontrah[$i * $kontrah[0][1] + 17][1]
	  $CxmlOut = $CxmlOut & "<TELEFON2><![CDATA[" & $wstaw & "]]></TELEFON2>"
	  $wstaw = $wszyscy_kontrah[$i * $kontrah[0][1] + 18][1]
	  $CxmlOut = $CxmlOut & "<FAX><![CDATA[" & $wstaw & "]]></FAX>"
	  $wstaw = $wszyscy_kontrah[$i * $kontrah[0][1] + 19][1]
	  $CxmlOut = $CxmlOut & "<EMAIL><![CDATA[" & $wstaw & "]]></EMAIL>"
	  $CxmlOut = $CxmlOut & "<URL><![CDATA[]]></URL></ADRES></ADRESY><GRUPY><GRUPA><NAZWA><![CDATA[]]></NAZWA></GRUPA></GRUPY>"
	  $CxmlOut = $CxmlOut & "</KONTRAHENT>"

   Next
   $CxmlOut = $CxmlOut & "</KONTRAHENCI>"

EndFunc

Func RobRejestrySprzedazy ()
   Local $i, $j, $k, $wstaw, $korekta
   Local $poz_praw = "", $poz_zast = "" ; pozycja zastepcza towaru
   Local $kategoriaSprzedaz = "SPRZEDA¯"

   $CxmlOut = $CxmlOut & "<REJESTRY_SPRZEDAZY_VAT>"
   $CxmlOut = $CxmlOut & $CxmlWersjaBaza

;i - akt dok, j - akt poz

   For $i = 0 to $lba_dokument - 1
	  $korekta = 0
	  if (StringCompare ($wszystkie_dokument[$i * $dokument[0][1] + 1][1], "Korekta faktury") == 0) Then $korekta = 1
      $CxmlOut = $CxmlOut & "<REJESTR_SPRZEDAZY_VAT>"
	  $wstaw = $wszystkie_dokument[$i * $dokument[0][1] + 2][1]
	  $CxmlOut = $CxmlOut & "<ID_ZRODLA><![CDATA[" & $wstaw & "]]></ID_ZRODLA>"
	  $CxmlOut = $CxmlOut & "<NUMER><![CDATA[" & $wstaw & "]]></NUMER>"
	  $CxmlOut = $CxmlOut & "<IDENTYFIKATOR_KSIEGOWY><![CDATA[" & $wstaw & "]]></IDENTYFIKATOR_KSIEGOWY>"
	  ; te typy i rejestry poustalaæ
	  $CxmlOut = $CxmlOut & "<REJESTR><![CDATA[SPRZEDA¯]]></REJESTR>"
	  if ($korekta) Then
		 $CxmlOut = $CxmlOut & "<TYP><![CDATA[Korekta faktury]]></TYP><KOREKTA><![CDATA[Tak]]></KOREKTA><KOREKTA_NUMER><![CDATA[]]></KOREKTA_NUMER>"
	  Else
		 $CxmlOut = $CxmlOut & "<TYP><![CDATA[Faktura sprzeda¿y]]></TYP><KOREKTA><![CDATA[Nie]]></KOREKTA><KOREKTA_NUMER><![CDATA[]]></KOREKTA_NUMER>"
	  EndIf
	  $wstaw = $wszystkie_naglowek[$i * $naglowek[0][1] + 3][1]
	  $CxmlOut = $CxmlOut & "<DATA_WYSTAWIENIA><![CDATA[" & $wstaw & "]]></DATA_WYSTAWIENIA>"
	  $wstaw = $wszystkie_naglowek[$i * $naglowek[0][1] + 4][1]
	  $CxmlOut = $CxmlOut & "<DATA_SPRZEDAZY><![CDATA[" & $wstaw & "]]></DATA_SPRZEDAZY>"
	  $wstaw = $wszystkie_naglowek[$i * $naglowek[0][1] + 8][1]
	  ; czego to termin? to termin platnosci
	  $CxmlOut = $CxmlOut & "<TERMIN><![CDATA[" & $wstaw & "]]></TERMIN>"
	  $CxmlOut = $CxmlOut & "<FISKALNA>Nie</FISKALNA><DETALICZNA></DETALICZNA><WEWNETRZNA>Nie</WEWNETRZNA><EKSPORT>Nie</EKSPORT><FINALNY>Nie</FINALNY>"
; sekcja KONTRAHENT w dokumencie

	  $CxmlOut = $CxmlOut & "<TYP_PODMIOTU><![CDATA[kontrahent]]></TYP_PODMIOTU>"
	  ; do akronimu usuwamy z kodu spacje
	  $wstaw = $wszyscy_kontrah[$i * $kontrah[0][1] + 1][1]
	  $wstaw = StringStripWS ($wstaw, $STR_STRIPALL)
	  $CxmlOut = $CxmlOut & "<PODMIOT><![CDATA[" & $wstaw & "]]></PODMIOT><PODMIOT_ID><![CDATA[]]></PODMIOT_ID>"
	  $wstaw = $wszyscy_kontrah[$i * $kontrah[0][1] + 2][1]
	  $CxmlOut = $CxmlOut & "<NAZWA1><![CDATA[" & $wstaw & "]]></NAZWA1>"
	  $CxmlOut = $CxmlOut & "<NAZWA2><![CDATA[]]></NAZWA2><NAZWA3><![CDATA[]]></NAZWA3>"
	  $CxmlOut = $CxmlOut & "<KATEGORIA><![CDATA[SPRZED.TOWARÓW]]></KATEGORIA>"
	  $wstaw = $wszyscy_kontrah[$i * $kontrah[0][1] + 9][1]
	  $CxmlOut = $CxmlOut & "<KRAJ><![CDATA[" & $wstaw & "]]></KRAJ>"
	  $wstaw = $wszyscy_kontrah[$i * $kontrah[0][1] + 8][1]
	  $CxmlOut = $CxmlOut & "<WOJEWODZTWO><![CDATA[" & $wstaw & "]]></WOJEWODZTWO>"
	  $CxmlOut = $CxmlOut & "<POWIAT><![CDATA[]]></POWIAT><GMINA><![CDATA[]]></GMINA>"
	  $wstaw = $wszyscy_kontrah[$i * $kontrah[0][1] + 7][1]
	  $CxmlOut = $CxmlOut & "<MIASTO><![CDATA[" & $wstaw & "]]></MIASTO>"
	  $wstaw = $wszyscy_kontrah[$i * $kontrah[0][1] + 3][1]
	  $CxmlOut = $CxmlOut & "<ULICA><![CDATA[" & $wstaw & "]]></ULICA>"
	  $wstaw = $wszyscy_kontrah[$i * $kontrah[0][1] + 4][1]
	  $CxmlOut = $CxmlOut & "<NR_DOMU><![CDATA[" & $wstaw & "]]></NR_DOMU>"
	  $wstaw = $wszyscy_kontrah[$i * $kontrah[0][1] + 5][1]
	  $CxmlOut = $CxmlOut & "<NR_LOKALU><![CDATA[" & $wstaw & "]]></NR_LOKALU>"
	  $wstaw = $wszyscy_kontrah[$i * $kontrah[0][1] + 6][1]
	  $CxmlOut = $CxmlOut & "<KOD_POCZTOWY><![CDATA[" & $wstaw & "]]></KOD_POCZTOWY>"
	  $CxmlOut = $CxmlOut & "<POCZTA><![CDATA[]]></POCZTA><DODATKOWE><![CDATA[]]></DODATKOWE><NIP_KRAJ><![CDATA[]]></NIP_KRAJ>"
	  $wstaw = $wszyscy_kontrah[$i * $kontrah[0][1] + 10][1]
	  $CxmlOut = $CxmlOut & "<NIP><![CDATA[" & $wstaw & "]]></NIP>"
	  $wstaw = $wszyscy_kontrah[$i * $kontrah[0][1] + 11][1]
	  $CxmlOut = $CxmlOut & "<REGON><![CDATA[" & $wstaw & "]]></REGON>"
	  $wstaw = $wszyscy_kontrah[$i * $kontrah[0][1] + 12][1]
	  $CxmlOut = $CxmlOut & "<PESEL><![CDATA[" & $wstaw & "]]></PESEL>"
	  $wstaw = $wszyscy_kontrah[$i * $kontrah[0][1] + 16][1]
	  $CxmlOut = $CxmlOut & "<TELEFON1><![CDATA[" & $wstaw & "]]></TELEFON1>"
	  $wstaw = $wszyscy_kontrah[$i * $kontrah[0][1] + 17][1]
	  $CxmlOut = $CxmlOut & "<TELEFON2><![CDATA[" & $wstaw & "]]></TELEFON2>"
	  $wstaw = $wszyscy_kontrah[$i * $kontrah[0][1] + 18][1]
	  $CxmlOut = $CxmlOut & "<FAX><![CDATA[" & $wstaw & "]]></FAX>"
	  $wstaw = $wszyscy_kontrah[$i * $kontrah[0][1] + 19][1]
	  $CxmlOut = $CxmlOut & "<EMAIL><![CDATA[" & $wstaw & "]]></EMAIL>"


; KONIEC sekcji KONTRAHENT w dokumencie

	  ;do opisu dok. wstawiam pare pierwszych pozycji
	  $wstaw = "SPRZEDA¯-" & $wszystkie_pozycja[$i][0][7][1] & ";" & $wszystkie_pozycja[$i][1][7][1] & ";" & $wszystkie_pozycja[$i][2][7][1] & ";" & $wszystkie_pozycja[$i][3][7][1]
	  $CxmlOut = $CxmlOut & "<OPIS><![CDATA[" & $wstaw & "]]></OPIS>"
#cs
<KURS_WALUTY><![CDATA[NBP]]></KURS_WALUTY>
<NOTOWANIE_WALUTY_ILE>1</NOTOWANIE_WALUTY_ILE>
<NOTOWANIE_WALUTY_ZA_ILE>1</NOTOWANIE_WALUTY_ZA_ILE>
<KURS_DO_KSIEGOWANIA>Nie</KURS_DO_KSIEGOWANIA>
<KURS_WALUTY_2><![CDATA[NBP]]></KURS_WALUTY_2>
<NOTOWANIE_WALUTY_ILE_2>1</NOTOWANIE_WALUTY_ILE_2>
<NOTOWANIE_WALUTY_ZA_ILE_2>1</NOTOWANIE_WALUTY_ZA_ILE_2>
<PLATNOSC_VAT_W_PLN><![CDATA[Nie]]></PLATNOSC_VAT_W_PLN>
#ce
	  $wstaw = $wszystkie_naglowek[$i * $naglowek[0][1] + 6][1]
	  Switch StringLeft ($wstaw, 4)
		 Case "czek"
			$wstaw = "czek"
		 Case "gotó"
			$wstaw = "gotówka"
		 Case "kred"
			$wstaw = "kredyt"
		 Case "prze"
			$wstaw = "przelew"
		 Case Else
			$wstaw = "inna"
	  EndSwitch

	  $CxmlOut = $CxmlOut & "<FORMA_PLATNOSCI><![CDATA[" & $wstaw & "]]></FORMA_PLATNOSCI>"
	  $CxmlOut = $CxmlOut & "<FORMA_PLATNOSCI_ID><![CDATA[]]></FORMA_PLATNOSCI_ID>"
	  $CxmlOut = $CxmlOut & "<WALUTA><![CDATA[]]></WALUTA>"
	  ; miesiac deklaracji vat7 biore z daty sprzedazy
	  ;$wstaw = $wszystkie_naglowek[$i * $naglowek[0][1] + 4][1]
	  ;$wstaw = StringLeft ($wstaw, 7)
	  ;$CxmlOut = $CxmlOut & "<DEKLARACJA_VAT7><![CDATA[" & $wstaw & "]]></DEKLARACJA_VAT7><DEKLARACJA_VATUE><![CDATA[Tak]]></DEKLARACJA_VATUE>"

	  $CxmlOut = $CxmlOut & "<ATRYBUTY><![CDATA[]]></ATRYBUTY>"

	  $CxmlOut = $CxmlOut & "<POZYCJE>"
	  ;excbox ($wszystkie_pozycja[$i][0][0][1] - 1)
	  ; reset platnosci
	  ; nie zeruja sie france w jednym rzedzie
	  For $k = 0 to $max_stawek_vat - 1
		 $sum_plat[$k][0] = ""
		 $sum_plat[$k][1] = 0
		 $sum_plat[$k][2] = 0
		 $sum_plat[$k][3] = 0
	  Next
	  $poz_praw = ""
	  $poz_zast = ""

	  for $j = 0 to $wszystkie_pozycja[$i][0][0][1] - 1
		 $platnosc[0][1] = ""
		 $platnosc[0][0] = 0
		 $platnosc[1][1] = 0
		 $platnosc[2][1] = 0
		 $platnosc[3][1] = 0
		 $poz_praw = $poz_praw & "<POZYCJA>"
		 $wstaw = $wszystkie_pozycja[$i][$j][4][1]
		 $platnosc[0][1] = $wstaw
		 ; stawka w procentach
		 $poz_praw = $poz_praw & "<STAWKA_VAT><![CDATA[" & $wstaw & "]]></STAWKA_VAT>"
		 if (StringCompare ($wstaw, "NP") == 0) Then
			$wstaw = "nie podlega"
			ElseIf (StringCompare ($wstaw, "ZW") == 0) Then
			   $wstaw = "zwolniona"
		 Else
			$wstaw = "opodatkowana"
		 EndIf
		 $poz_praw = $poz_praw & "<STATUS_VAT><![CDATA[" & $wstaw & "]]></STATUS_VAT>"
		 $wstaw = $wszystkie_pozycja[$i][$j][6][1] ; kwota vat
		 $platnosc[2][1] = Number ($wstaw)
		 $platnosc[0][0] = Number ($wstaw) ; pojedyncza kwota watu do obliczen - platnosc[0][0] chyba jest wolne
		 $poz_praw = $poz_praw & "<VAT><![CDATA[" & $wstaw & "]]></VAT>"
		 $poz_praw = $poz_praw & "<VAT_SYS><![CDATA[" & $wstaw & "]]></VAT_SYS>"
		 $poz_praw = $poz_praw & "<VAT_SYS2><![CDATA[" & $wstaw & "]]></VAT_SYS2>"
		 $wstaw = $wszystkie_pozycja[$i][$j][5][1] ; brutto lub netto; sprawdzmy:
		 if (StringCompare ($wszystkie_naglowek[$i * $naglowek[0][1]][1], "Brutto") == 0) Then ; <RodzajCeny>
			$platnosc[3][1] = Number ($wstaw)
			; i trza zrobic netto
			$wstaw = Number ($wstaw) - Number ($platnosc[0][0])
			$platnosc[1][1] = Number ($wstaw)
		 Else
			$platnosc[1][1] = Number ($wstaw)
			;  i trza zrobic brutto
			$wstaw = Number ($wstaw) + Number ($platnosc[0][0])
			$platnosc[3][1] = Number ($wstaw)
		 EndIf
		 $poz_praw = $poz_praw & "<NETTO><![CDATA[" & $wstaw & "]]></NETTO>"
		 $poz_praw = $poz_praw & "<NETTO_SYS><![CDATA[" & $wstaw & "]]></NETTO_SYS>"
		 $poz_praw = $poz_praw & "<NETTO_SYS2><![CDATA[" & $wstaw & "]]></NETTO_SYS2>"
		 $wstaw = $wszystkie_pozycja[$i][$j][8][1] ; rodzaj pozycji
		 Switch $wstaw
			Case DajOpcje ("RodzIn1")
			   $wstaw = DajOpcje ("RodzOut1")
			Case DajOpcje ("RodzIn2")
			   $wstaw = DajOpcje ("RodzOut2")
			Case DajOpcje ("RodzIn3")
			   $wstaw = DajOpcje ("RodzOut3")
			Case Else
			   $wstaw = DajOpcje ("RodzOut1")
		 EndSwitch
		 $poz_praw = $poz_praw & "<RODZAJ_SPRZEDAZY><![CDATA[" & $wstaw & "]]></RODZAJ_SPRZEDAZY><UWZ_W_PROPORCJI><![CDATA[Tak]]></UWZ_W_PROPORCJI>"
		 $poz_praw = $poz_praw & "<ODLICZENIA_VAT><![CDATA[tak]]></ODLICZENIA_VAT>"
		 Switch $wstaw
			Case DajOpcje ("RodzIn1")
			   $wstaw = DajOpcje ("KatOut1")
			Case DajOpcje ("RodzIn2")
			   $wstaw = DajOpcje ("KatOut2")
			Case DajOpcje ("RodzIn3")
			   $wstaw = DajOpcje ("KatOut3")
			Case Else
			   $wstaw = DajOpcje ("KatOut1")
		 EndSwitch


;			$wstaw = $kategoriaSprzedaz
			$poz_zast = $poz_zast & "<KATEGORIA_POS><![CDATA[" & $wstaw & "]]></KATEGORIA_POS>"
			$poz_zast = $poz_zast & "<KATEGORIA_ID_POS><![CDATA[]]></KATEGORIA_ID_POS>"
			$wstaw = "SPRZEDA¯"
			$poz_zast = $poz_zast & "<KOLUMNA_KPR><![CDATA[" & $wstaw & "]]></KOLUMNA_KPR>"


		 $poz_praw = $poz_praw & "</POZYCJA>"
		 ;_ArrayDisplay ($platnosc)
		 For $k = 0 to $max_stawek_vat - 1
			; jesli jest taka stawka w sum_plat to dodaj do niej pozycje, jak nie ma, to stworz na koncu stawke
			if ((StringCompare ($sum_plat[$k][0], $platnosc[0][1]) == 0) Or (StringCompare ($sum_plat[$k][0], "") == 0)) Then
			   $sum_plat[$k][0] = $platnosc[0][1]
			   $sum_plat[$k][1] += $platnosc[1][1]
			   $sum_plat[$k][2] += $platnosc[2][1]
			   $sum_plat[$k][3] += $platnosc[3][1]
			   ExitLoop
			EndIf
		 Next
		 if ($k == $max_stawek_vat) Then errbox ("Przekroczona maksymalna liczba stawek VAT w dokumencie.")
	  Next; $k jest tera liczba stawek vat - 1
	  ;_ArrayDisplay ($sum_plat)
	  if (DajOpcje ("ChkSinglePos") == "T") Then ; zrob pozycje zastepcze z sumami poszcz. vatów
		 for $j = 0 to $k
			$poz_zast = $poz_zast & "<POZYCJA>"
			$wstaw = $sum_plat[$j][0]
		 ; stawka w procentach
			$poz_zast = $poz_zast & "<STAWKA_VAT><![CDATA[" & $wstaw & "]]></STAWKA_VAT>"
			if (StringCompare ($wstaw, "NP") == 0) Then
			   $wstaw = "nie podlega"
			ElseIf (StringCompare ($wstaw, "ZW") == 0) Then
			   $wstaw = "zwolniona"
			Else
			   $wstaw = "opodatkowana"
			EndIf
			$poz_zast = $poz_zast & "<STATUS_VAT><![CDATA[" & $wstaw & "]]></STATUS_VAT>"
			$wstaw = $sum_plat[$j][2]
			$poz_zast = $poz_zast & "<VAT><![CDATA[" & $wstaw & "]]></VAT>"
			$poz_zast = $poz_zast & "<VAT_SYS><![CDATA[" & $wstaw & "]]></VAT_SYS>"
			$poz_zast = $poz_zast & "<VAT_SYS2><![CDATA[" & $wstaw & "]]></VAT_SYS2>"
			$wstaw = $sum_plat[$j][1]
			$poz_zast = $poz_zast & "<NETTO><![CDATA[" & $wstaw & "]]></NETTO>"
			$poz_zast = $poz_zast & "<NETTO_SYS><![CDATA[" & $wstaw & "]]></NETTO_SYS>"
			$poz_zast = $poz_zast & "<NETTO_SYS2><![CDATA[" & $wstaw & "]]></NETTO_SYS2>"

			$poz_zast = $poz_zast & "<RODZAJ_SPRZEDAZY><![CDATA[towary]]></RODZAJ_SPRZEDAZY><UWZ_W_PROPORCJI><![CDATA[Tak]]></UWZ_W_PROPORCJI>"
			$poz_zast = $poz_zast & "<ODLICZENIA_VAT><![CDATA[tak]]></ODLICZENIA_VAT>"

			$wstaw = $kategoriaSprzedaz
			$poz_zast = $poz_zast & "<KATEGORIA_POS><![CDATA[" & $wstaw & "]]></KATEGORIA_POS>"
			$poz_zast = $poz_zast & "<KATEGORIA_ID_POS><![CDATA[]]></KATEGORIA_ID_POS>"
			$wstaw = "SPRZEDA¯"
			$poz_zast = $poz_zast & "<KOLUMNA_KPR><![CDATA[" & $wstaw & "]]></KOLUMNA_KPR>"

			$poz_zast = $poz_zast & "</POZYCJA>"
			;_ArrayDisplay ($p)
		 Next
		 $CxmlOut = $CxmlOut & $poz_zast
	  Else
		 $CxmlOut = $CxmlOut & $poz_praw
	  EndIf
	  $CxmlOut = $CxmlOut & "</POZYCJE>"
	  $CxmlOut = $CxmlOut & "<PLATNOSCI>"
	  $CxmlOut = $CxmlOut & "<PLATNOSC><ID_ZRODLA_PLAT><![CDATA[]]></ID_ZRODLA_PLAT>"
	  $wstaw = $wszystkie_naglowek[$i * $naglowek[0][1] + 8][1]
	  $CxmlOut = $CxmlOut & "<TERMIN_PLAT><![CDATA[" & $wstaw & "]]></TERMIN_PLAT>"
	  $CxmlOut = $CxmlOut & "<DATA_KURSU_PLAT><![CDATA[" & $wstaw & "]]></DATA_KURSU_PLAT>"
	  $wstaw = $wszystkie_naglowek[$i * $naglowek[0][1] + 6][1]
	  Switch StringLeft ($wstaw, 4)
		 Case "czek"
			$wstaw = "czek"
		 Case "gotó"
			$wstaw = "gotówka"
		 Case "kred"
			$wstaw = "kredyt"
		 Case "prze"
			$wstaw = "przelew"
		 Case Else
			$wstaw = "inna"
	  EndSwitch

	  ;EndIf
	  $CxmlOut = $CxmlOut & "<FORMA_PLATNOSCI_PLAT><![CDATA[" & $wstaw & "]]></FORMA_PLATNOSCI_PLAT>"
	  $CxmlOut = $CxmlOut & "<FORMA_PLATNOSCI_ID_PLAT><![CDATA[]]></FORMA_PLATNOSCI_ID_PLAT>"
	  $wstaw = 0
	  For $k = 0 to $max_stawek_vat - 1
		 $wstaw += $sum_plat[$k][3]
	  Next
	  if ($korekta) Then
		 $wstaw = -$wstaw
		 $CxmlOut = $CxmlOut & "<KWOTA_PLAT>" & $wstaw & "</KWOTA_PLAT><KIERUNEK>rozchód</KIERUNEK>"
		 $CxmlOut = $CxmlOut & "<KWOTA_PLN_PLAT>" & $wstaw & "</KWOTA_PLN_PLAT>"
	  Else
		 $CxmlOut = $CxmlOut & "<KWOTA_PLAT>" & $wstaw & "</KWOTA_PLAT><KIERUNEK>przychód</KIERUNEK>"
		 $CxmlOut = $CxmlOut & "<KWOTA_PLN_PLAT>" & $wstaw & "</KWOTA_PLN_PLAT>"
	  EndIf

	  $CxmlOut = $CxmlOut & "<WALUTA_PLAT><![CDATA[]]></WALUTA_PLAT><KURS_WALUTY_PLAT><![CDATA[NBP]]></KURS_WALUTY_PLAT>"
	  $CxmlOut = $CxmlOut & "<NOTOWANIE_WALUTY_ILE_PLAT>1</NOTOWANIE_WALUTY_ILE_PLAT><NOTOWANIE_WALUTY_ZA_ILE_PLAT>1</NOTOWANIE_WALUTY_ZA_ILE_PLAT>"
	  $CxmlOut = $CxmlOut & "<PODLEGA_ROZLICZENIU>tak</PODLEGA_ROZLICZENIU><KONTO><![CDATA[]]></KONTO>"
	  $CxmlOut = $CxmlOut & "<WALUTA_DOK><![CDATA[]]></WALUTA_DOK>"
	  $CxmlOut = $CxmlOut & "</PLATNOSC></PLATNOSCI>"

	  $CxmlOut = $CxmlOut & "</REJESTR_SPRZEDAZY_VAT>"

   Next
   $CxmlOut = $CxmlOut & "</REJESTRY_SPRZEDAZY_VAT>"

EndFunc



#cs


<NIP_KRAJ><![CDATA[]]></NIP_KRAJ>
<NIP><![CDATA[5541868876]]></NIP>
<KRAJ><![CDATA[Polska]]></KRAJ>
<WOJEWODZTWO><![CDATA[]]></WOJEWODZTWO>
<POWIAT><![CDATA[]]></POWIAT>
<GMINA><![CDATA[]]></GMINA>
<ULICA><![CDATA[Sybiraków 12/71]]></ULICA>
<NR_DOMU><![CDATA[]]></NR_DOMU>
<NR_LOKALU><![CDATA[]]></NR_LOKALU>
<MIASTO><![CDATA[Bydgoszcz]]></MIASTO>
<KOD_POCZTOWY><![CDATA[85-795]]></KOD_POCZTOWY>
<POCZTA><![CDATA[]]></POCZTA>
<DODATKOWE><![CDATA[]]></DODATKOWE>
<ROLNIK><![CDATA[Nie]]></ROLNIK>
#ce

func RobKategorie ()
   Local $i, $wstaw

   if (StringCompare (DajOpcje ("ChkKategorie"), "N") == 0) Then Return (0)

   $CxmlOut = $CxmlOut & "<KATEGORIE>"
   $CxmlOut = $CxmlOut & $CxmlWersjaBaza

   For $i = 0 to $lba_kategorii - 1
      $CxmlOut = $CxmlOut & "<KATEGORIA>"
	  $CxmlOut = $CxmlOut & $CxmlIdZrodla
	  $CxmlOut = $CxmlOut & "<KOD_OGOLNY><![CDATA[PRZYCHODY]]></KOD_OGOLNY>"
	  $wstaw = DajOpcje ("KatOut" & String ($i + 1))
	  $CxmlOut = $CxmlOut & "<KOD><![CDATA[" & $wstaw & "]]></KOD>"
	  $CxmlOut = $CxmlOut & "<POZIOM><![CDATA[szczegó³owa]]></POZIOM>"
	  $CxmlOut = $CxmlOut & "<TYP><![CDATA[przychód]]></TYP>"
	  $CxmlOut = $CxmlOut & "<KOLUMNA_KPR><![CDATA[sprzeda¿]]></KOLUMNA_KPR>"
      $CxmlOut = $CxmlOut & "</KATEGORIA>"
   Next
   $CxmlOut = $CxmlOut & "</KATEGORIE>"
EndFunc


; ****************************************************************************
; ****************************************************************************
; ****************************************************************************


Func KonwersjaKsiegowa ($in, $out)
   Local $typ

   $typ = SprawdzTypPlikuWejsciowego ($in)
   if ($typ < 1) then Return (-3)
   if ($typ == 2) Then ; typ XML
	  $typ = OdczytajPlikWejsciowy ($in)
   ElseIf ($typ == 1) Then ; typ FK
	  Return (-5)
	  ;$typ = OdczytajPlikFK ($in)
   Else
	  Return (-4)
   EndIf
   if ($typ < 0) Then Return (-1)
   RobNaglowek ()
   RobKategorie ()
   RobKontrahentow ()
   RobRejestrySprzedazy ()
   RobStopke ()
   ;infbox ($CxmlOut)

   FileDelete ($out)
   if (FileWrite ($out, $CxmlOut) < 1) Then
	  errbox ("Nie mo¿na zapisaæ do pliku " & $out & ".")
	  Return (-2)
   EndIf
   Return ($lba_dokument)
EndFunc

Func SprawdzTypPlikuWejsciowego ($in)
   Local $Symstr, $fin
   Local $NagSymfoniaFK = "INFO{", $NagSymfoniaXML = "<?xml"

   $fin = MyFileOpen ($in)
   if ($fin < 0) Then Return (-1)
   $Symstr = MyFileReadLine ($fin, 1)
   FileClose ($fin)
   if (StringCompare (stringleft ($Symstr, 5), $NagSymfoniaFK) == 0) Then Return (1)
   if (StringCompare (stringleft ($Symstr, 5), $NagSymfoniaXML) == 0) Then Return (2)
   return (0)
EndFunc