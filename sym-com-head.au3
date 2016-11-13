#include-once
Global $GUIHandle
Global $MyRegKey = "HKEY_CURRENT_USER\Software\Andko\Sym-com"
Global $lba_kontrah ; liczbe dokumentow zwraca funkcja konwersji
Global $prog = "3-2-1 Konwerter"
Global $set[16][4] = [["Items", "Ustawienia", "16", ""], _
					 ["InFile", "Plik wejœciowy", "", ""], _
					 ["OutFile", "Plik wyjœciowy", "", ""], _
					 ["SourceBase", "Oznaczenie bazy Ÿród³owej", "", ""], _
					 ["TargetBase", "Oznaczenie bazy docelowej", "", ""], _
					 ["RodzIn1", "Rodzaj pozycji 1 wejœcie (Artyku³)", "", ""], _
					 ["RodzOut1", "Rodzaj pozycji 1 wyjœcie (towary)", "", ""], _
					 ["KatOut1", "Kategoria sprzeda¿y 1 wyjœcie", "", ""], _
					 ["RodzIn2", "Rodzaj pozycji 2 wejœcie (Us³uga)", "", ""], _
					 ["RodzOut2", "Rodzaj pozycji 2 wyjœcie (us³ugi)", "", ""], _
					 ["KatOut2", "Kategoria sprzeda¿y 2 wyjœcie", "", ""], _
					 ["RodzIn3", "Rodzaj pozycji 3 wejœcie", "", ""], _
					 ["RodzOut3", "Rodzaj pozycji 3 wyjœcie (œr. transportu)", "", ""], _
					 ["KatOut3", "Kategoria sprzeda¿y 3 wyjœcie", "", ""], _
					 ["ChkKategorie", "Przesy³aj kategorie", "", ""], _
					 ["ChkSinglePos", "Pojedyncze pozycje dla poszczególnych stawek VAT w dokumentach", "", ""]]
					 ;["KatPrzyOg", "Kategoria przychód ogólna", "", ""], _
					 ;["KatPrzySz", "Kategoria przychód szczegó³owa", "", ""]]

Global $CxmlNagl = "<?xml version=""1.0"" encoding=""UTF-8""?>" & _
				  "<ROOT xmlns=""http://www.comarch.pl/cdn/optima/offline"">"
Global $CxmlWersjaBaza ; przypisanie tej zmniennej robi funkcja RobNaglowek
Global $CxmlIdZrodla = "<ID_ZRODLA><![CDATA[]]></ID_ZRODLA>"

Local $CxmlOut = "" ;

Local $max_lba_dok = 500
Local $max_lba_poz_w_dok = 500
; uwaga na kazdy dok jest jeden kontrahent - moga sie dublowac - do ew. zmiany
Local $wszyscy_kontrah[$max_lba_dok * 20][2]
Local $kontrah[21][2] = [["<Odbiorca>", "20"], _
						["<GUID>", ""], _
						["<Kod>", ""], _ ;AGD Adam</Kod>
						["<Nazwa>", ""], _ ;AGD Adam</Nazwa>
						["<Ulica>", ""], _ ;W¹ska</Ulica>
						["<NumerDomu>", ""], _ ;90</NumerDomu>
						["<NumerLokalu>", ""], _ ;</NumerLokalu>
						["<KodPocztowy>", ""], _ ;22-400</KodPocztowy>
						["<Miejscowosc>", ""], _ ;Zamoœæ</Miejscowosc>
						["<Wojewodztwo>", ""], _ ;</Wojewodztwo>
						["<Kraj>", ""], _ ;PL</Kraj>
						["<NIP>", ""], _ ;879-23-23-465</NIP>
						["<REGON>", ""], _ ;</REGON>
						["<PESEL>", ""], _ ;</PESEL>
						["<VIES>", ""], _ ;Nie</VIES>
						["<VATUE>", ""], _ ;</VATUE>
						["<NumerRachunkuBankowego>", ""], _ ;</NumerRachunkuBankowego>
						["<Telefon1>", ""], _ ;</Telefon1>
						["<Telefon2>", ""], _ ;</Telefon2>
						["<Fax>", ""], _ ;</Fax>
						["<Email>", ""]] ;</Email>
Local $kontraFK[21][2] = [["Kontrahent{", "20"], _
						["guid =", ""], _
						["kod =", ""], _ ;AGD Adam</Kod>
						["nazwa =", ""], _ ;AGD Adam</Nazwa>
						["ulica =", ""], _ ;W¹ska</Ulica>
						["dom =", ""], _ ;90</NumerDomu>
						["lokal =", ""], _ ;</NumerLokalu>
						["kodpocz =", ""], _ ;22-400</KodPocztowy>
						["miejscowosc =", ""], _ ;Zamoœæ</Miejscowosc>
						["<Wojewodztwo>", ""], _ ;</Wojewodztwo>
						["krajNazwa =", ""], _ ;PL</Kraj>
						["nip =", ""], _ ;879-23-23-465</NIP>
						["regon =", ""], _ ;</REGON>
						["pesel =", ""], _ ;</PESEL>
						["<VIES>", ""], _ ;Nie</VIES>
						["statusUE =", ""], _ ;</VATUE>
						["bkonto =", ""], _ ;</NumerRachunkuBankowego>
						["tel1 =", ""], _ ;</Telefon1>
						["tel2 =", ""], _ ;</Telefon2>
						["fax =", ""], _ ;</Fax>
						["email =", ""]] ;</Email>
Local $wszystkie_dokument[$max_lba_dok * 8][2]
Local $dokument[8][2] = [["<DokumentHandlowy>", "7"], _
						["<GUID>", ""], _ ;</GUID>
						["<Status>", ""], _ ;Faktura</Status>
						["<NumerDokumentu>", ""], _ ;16-FVS/0001</NumerDokumentu>
						["<Nazwa>", ""], _ ;Faktura</Nazwa>
						["<Charakter>", ""], _ ;40</Charakter>
						["<Typ>", ""], _ ; FVS</Typ>
						["<Seria>", ""]] ;sFVS</Seria>

Local $dokumentFK[9][2] = [["Dokument{", "8"], _
						["guid =", ""], _ ;</GUID>
						["e_status =", ""], _ ;Faktura</Status>
						["kod =", ""], _ ;16-FVS/0001</NumerDokumentu>
						["nazwa =", ""], _ ;Faktura</Nazwa> lub Faktura koryguj¹ca
						["subtypi =", ""], _ ;40</Charakter>
						["typ_dk =", ""], _ ; FVS</Typ>
						["seria =", ""], _ ;sFVS</Seria>
						["NazwaKor =", ""]] ;sFVS</Seria>

Local $wszystkie_naglowek[$max_lba_dok * 12][2]
Local $naglowek[13][2] = [["<Rejestr>", "12"], _ ;Sprzeda¿ VAT</Rejestr>
						   ["<RodzajCeny>", ""], _ ;Netto</RodzajCeny>
						   ["<NaliczanieVAT>", ""], _ ;Iloczynowe</NaliczanieVAT>
						   ["<MetodaRozliczaniaVAT>", ""], _ ;Memoria³owa</MetodaRozliczaniaVAT>
						   ["<DataWystawienia>", ""], _ ;2016-02-12</DataWystawienia>
						   ["<DataSprzedazy>", ""], _ ;2016-02-12</DataSprzedazy>
						   ["<RejestrPlatnosci>", ""], _ ;KASA</RejestrPlatnosci>
						   ["<FormaPlatnosci>", ""], _ ;gotówka</FormaPlatnosci>
						   ["<TerminPlatnosci>", ""], _ ;0 dni</TerminPlatnosci>
						   ["<DataPlatnosci>", ""], _ ;2016-02-12</DataPlatnosci>
						   ["<KursVAT>", ""], _ ;1.0000</KursVAT>
						   ["<KursCITPIT>", ""], _ ;1.0000</KursCITPIT>
						   ["<OdebranyPrzez>", ""]] ;Adam Wieczorek</OdebranyPrzez>

Local $naglowekFK[13][2] = [["Rejestr{", "12"], _ ;Sprzeda¿ VAT</Rejestr>
						   ["Rodzaj =", ""], _ ;Netto</RodzajCeny>, 1
						   ["naliczenie_VAT =", ""], _ ;Iloczynowe</NaliczanieVAT>, 0
						   ["metoda_VAT =", ""], _ ;Memoria³owa</MetodaRozliczaniaVAT>, 0
						   ["data =", ""], _ ;2016-02-12</DataWystawienia>
						   ["datasp =", ""], _ ;2016-02-12</DataSprzedazy>
						   ["rejestr_platnosci =", ""], _ ;KASA</RejestrPlatnosci>
						   ["forma_platnosci =", ""], _ ;gotówka</FormaPlatnosci>
						   ["plattermin =", ""], _ ;0 dni</TerminPlatnosci>, w wersji fk jest data a nie ilosc dni
						   ["data_pn =", ""], _ ;2016-02-12</DataPlatnosci>
						   ["<KursVAT>", ""], _ ;1.0000</KursVAT>
						   ["<KursCITPIT>", ""], _ ;1.0000</KursCITPIT>
						   ["odnazwa =", ""]] ;Adam Wieczorek</OdebranyPrzez>
; w symfonii xml nie ma platnosci - bedziemy wyliczac z sumy pozycji
Local $platnosc[4][2] = [["", ""], _ ;8%</StawkaVAT>
						["<Netto>", ""], _ ;30.00</Wartosc>
						["<WartoscVAT>", ""], _
						["<Brutto>", ""]] ;2.40</WartoscVAT>
Local $platnoscFK[4][2] = [["", ""], _ ;8%</StawkaVAT>
						["netto =", ""], _ ;30.00</Wartosc>
						["vat =", ""], _
						["wplaty =", ""]] ; ?
Local $max_stawek_vat = 7
Local $sum_plat[$max_stawek_vat][4]
Local $pozycja[9][2] = [["<PozycjaDokumentu>", "8"], _
						["<JednostkaMiary>", ""], _ ;szt</JednostkaMiary>
						["<Ilosc>", ""], _ ;1.0000</Ilosc>
						["<Cena>", ""], _ ;30.000000</Cena>
						["<StawkaVAT>", ""], _ ;8%</StawkaVAT>
						["<Wartosc>", ""], _ ;30.00</Wartosc>
						["<WartoscVAT>", ""], _
						["<Opis>", ""], _
						["<Rodzaj>", ""]]
Local $pozycjaFK[9][2] = [["Pozycja dokumentu{", "8"], _
						["jm =", ""], _ ;szt</JednostkaMiary>
						["ilosc =", ""], _ ;1.0000</Ilosc>
						["cena =", ""], _ ;30.000000</Cena>
						["stawkaVAT =", ""], _ ;8%</StawkaVAT>
						["walbrutto =", ""], _ ; na razie brutto
						["wartvat =", ""], _
						["opis =", ""], _
						["typks =", ""]]
Local $wszystkie_pozycja[$max_lba_dok][$max_lba_poz_w_dok][$pozycja[0][1]+1][2]
	  ; we wzystkich pozycjach tutaj zapisuje il pozycji w tym dokumencie
	  ; $wszystkie_pozycja[$kolej_dok - 1][0][0][1] = $lba_poz_w_dok

Local $lba_dokument, $lba_pozycji
Global $lba_kontrah
Local $lba_kategorii = 3

