#include-once
#include "CommProg.au3"
#cs
FileOpen:
Mode (read or write) to open the file in.
Can be a combination of the following:
  0 = Read mode
  1 = Write mode (append to end of file)
  2 = Write mode (erase previous contents)
  4 = Read raw mode
  8 = Create directory structure if it doesn't exist (See Remarks).
  16 = Force binary mode (See Remarks).
  32 = Use Unicode UTF16 Little Endian reading and writing mode. Reading does not override existing BOM
  64 = Use Unicode UTF16 Big Endian reading and writing mode. Reading does not override existing BOM
  128 = Use Unicode UTF8 reading and writing mode. Reading does not override existing BOM
Both write modes will create the file if it does not already exist. The folder path must already exist (except using mode '8' - See Remarks).
Return Value
Success: Returns a file "handle" for use with subsequent file functions.
Failure: Returns -1 if error occurs.
Remarks
The file handle must be closed with the FileClose() function.
A file may fail to open due to access rights or attributes.
The default mode when writing text is ANSI - use the unicode flags to change this. When writing unicode files the Windows default mode (and the fastest in AutoIt due to the least conversion) is UTF16 Little Endian (mode 32).
Opening a file in write mode creates the file if it does not exist. Directories are not created unless the correct flag is used.
When reading in raw mode the filename is specified as "\\.\A:". For reading sector on a floppy disk the count must be a multiple of the sector size (default sector size is 512).
When reading and writing via the same file handle, the FileSetPos() function must be used to update the current file position.
Binary mode is only required if you want to read or write a byte-order mark. By default AutoIt handles BOMs automatically. This flag has nothing to do with reading or writing binary data.
#ce
Global Const $FM_READ = 0
Global Const $FM_APPEND = 1
Global Const $FM_WRITE = 2
Global Const $FM_READ_RAW = 4
Global Const $FME_CREATE_DIR = 8
Global Const $FME_BINARY = 16
Global Const $FME_UTF16_1 = 32
Global Const $FME_UTF16_2 = 64
Global Const $FME_UTF8 = 128

Func MyFileOpen ($filename, $mode = $FM_READ)
	Local $f

	$f = FileOpen ($filename, $mode)
	if $f < 0 Then ErrBox ("Nie mo¿na otworzyæ pliku " & $filename & " w trybie " & $mode & ".")
	Return ($f)
EndFunc

func MyFileReadLine ($file, $l = 0)
	Local $line
	While (@error == 0)
	if ($l <> 0) Then
		$line = FileReadLine ($file, $l)
	Else
		$line = FileReadLine ($file)
	EndIf
	if StringLeft ($line, 1) == ";" Then ; omijamy komentarze
		if ($l <> 0) Then $l += 1
		ContinueLoop
	EndIf
	if (@error == 0) Then Return ($line)
	WEnd
	Return (@error)
EndFunc

Func MyFileWriteLine ($file, $line)
	Local $f
	$f = FileWriteLine ($file, $line)
	if $f == 0 Then ErrBox ("Nie mo¿na zapisaæ linii do pliku " & $file & ".")
	Return ($f)
EndFunc

Func ZapiszDateCzas ($fname)
	Local $fInfo, $ret = 0
	$fInfo = MyFileOpen ($fname, 2)
	if $fInfo > 0 Then
		$ret = MyFileWriteLine ($fInfo, @YEAR & "/" & @MON & "/" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC)
		FileClose ($fInfo)
	EndIf
	Return ($ret)
EndFunc
Func OdczytajDateCzas ($fname)
	Local $fInfo, $ret = ""
	$fInfo = MyFileOpen ($fname)
	if $fInfo > 0 Then
		$ret = MyFileReadLine ($fInfo) ; @error = -1 jesli EOF
		$ret = $ret & MyFileReadLine ($fInfo, 2)
		$ret = $ret & MyFileReadLine ($fInfo, 3)
		$ret = $ret & MyFileReadLine ($fInfo, 4)
		FileClose ($fInfo)
	EndIf
	StringReplace ($ret, "" & @LF & @CR, "")
	$ret = "Data produkcji bazy: " & $ret
	Return ($ret)
EndFunc
