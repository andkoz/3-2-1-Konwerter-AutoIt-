#include-once
#include "sym-com-head.au3"
#include "..\Pliki.au3"

Func OdczytajPlikFK ($in)
   Local $Symstr, $Dokstr, $Fragstr, $fin, $i, $pos, $poskon, $kolej_dok, $kolej_kontr
   Local $Pozstr, $lba_poz_w_dok, $kolej_poz

   $fin = MyFileOpen ($in)
   if ($fin < 0) Then Return (-1)
   $Symstr = FileRead ($fin)
   FileClose ($fin)
;pomiñ nag³ówek typu INFO{ licz¹c klamry otwarcia i zamkniecia
   $pos = StringInStr ($Symstr, "}", 0, 2)
   $Symstr = StringTrimLeft ($Symstr, $pos)
   $lba_dokument = IleStrInStr ($Symstr, "Dokument{")
   $lba_kontrah = IleStrInStr ($Symstr, $kontraFK[0][0])
   infbox ("Doks:" & $lba_dokument & "   Kontr:" & $lba_kontrah)
   if ($lba_dokument <> $lba_kontrah) Then
	  infbox ("Uwaga: liczba dokumentow w pliku ró¿na od liczby kontrahentów (z powtórzeniami). Dokumentów:" & $lba_dokument & "    Kontrahentów:" & $lba_kontrah)
   EndIf
   For $kolej_kontr = 1 to $lba_kontrah
	  $Dokstr = OdczytajKlamre ($Symstr, $kontraFK[0][0], 0, $kolej_kontr)
;	  infbox (StringMid ($Dokstr, 200))
	  For $i = 1 To $kontraFK[0][1]
		 $kontraFK[$i][1] = OdczytajWartoscFK ($Dokstr, $kontraFK[$i][0])
		 $wszyscy_kontrah[($kolej_kontr - 1) * $kontraFK[0][1] + $i - 1][1] = $kontraFK[$i][1]
	  Next
;	  _ArrayDisplay ($kontraFK)
   Next
;   _ArrayDisplay ($wszyscy_kontrah)

   For $kolej_dok = 1 to $lba_dokument
	  $Dokstr = OdczytajKlamre ($Symstr, $dokumentFK[0][0], 0, $kolej_dok)
	  For $i = 1 To $dokumentFK[0][1]
		 $dokumentFK[$i][1] = OdczytajWartoscFK ($Dokstr, $dokumentFK[$i][0])
		 $wszystkie_dokument[($kolej_dok - 1) * $dokumentFK[0][1] + $i - 1][1] = $dokumentFK[$i][1]
	  Next
 _ArrayDisplay ($dokumentFK)

	  if ((StringCompare ($dokumentFK[4][1], "Faktura VAT") <> 0) And (StringCompare ($dokumentFK[4][1], "Korekta faktury") <> 0)) Then ; omijam nie-faktury
		 excbox ("Uwaga. Dokument " & $dokumentFK[3][1] & " nie jest faktur¹.")
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

   Return (0)




EndFunc
#cs
Func OdczytajPlikWejsciowy ($in)

EndFunc
#ce

Func OdczytajKlamre ($Symstr, $pocz, $casesense, $ktora)
   Local $pos, $open, $close

   $pos = StringInStr ($Symstr, $pocz, $casesense, $ktora)
   if ($pos == 0) Then Return (-1)
   $Symstr = StringTrimLeft ($Symstr, $pos - 1)
	  $open = StringInStr ($Symstr, "{")
	  $close = StringInStr ($Symstr, "}")
	  While ($open)
		 $open = StringInStr ($Symstr, "{", 0, 1, $open + 1)

		 if ($open == 0 Or $open > $close) Then ExitLoop
		 $close = StringInStr ($Symstr, "}", 0, 1, $close + 1)
		 ;infbox ($open & " " & $close)
	  WEnd

   $Symstr = StringMid ($Symstr, 1, $close)
   Return ($Symstr)
EndFunc

Func OdczytajWartoscFK ($Dokstr, $dana)
   Local $wartosc, $poskon, $pos
;   infbox ($dana)
   $pos = StringInStr ($Dokstr, $dana)
   if ($pos == 0) Then Return (-1)
   $pos += StringLen ($dana)
   $poskon = StringInStr ($Dokstr, @CRLF, 0, 1, $pos)
   $wartosc = StringMid ($Dokstr, $pos, $poskon - $pos)
;   infbox ($wartosc)
   Return ($wartosc)

EndFunc
