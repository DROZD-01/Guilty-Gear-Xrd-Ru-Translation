#Include <File.au3>
#include <Binary.au3>
Dim $NEWdata,$Num = 1
$TxtPath = FileOpenDialog("Select the TXT file", @ScriptDir, "text files (*.txt)",1)
If @error = 1 Then Exit
_FileReadToArray($TxtPath,$NEWdata)
$Dir = FileSelectFolder ( "Select the folder OR press Cancel to select the file", "", "", @ScriptDir)
If $Dir = "" Then
	$Path = FileOpenDialog("Select the REDAssetAdvText file", @ScriptDir, "REDAssetAdvText files (*.REDAssetAdvText)",1)
	If @error = 1 Then Exit
	$File = fileopen($Path,16)
EndIf
If $Dir <> "" Then
	$Names = _FileListToArrayRec($Dir, "*.REDAssetLocalizeText", 1,1)
	If $Names = "" Then
		MsgBox(0,"Error","There are no REDAssetLocalizeText files in the folder.")
		Exit
	EndIf
	For $i=1 to $Names[0]
		$File = FileOpen($Dir &"\"& $Names[$i], 0+16)
		FileSetPos($File,28,0)
		$Size = _BinaryToInt32(FileRead($File,4))+56
		FileSetPos($File,56,0)
		$Files = _BinaryToInt32(FileRead($File,4))
		$Offset = $Files * 132 + 8
		FileSetPos($File,0,0)
		$Newfile = FileRead($File,$Offset+56)
		$pos = 193
		For $n = 1 to $Files
			$Str = $NEWdata[$Num]
			$Str = StringReplace($Str,"<cf>",@CRLF)
			$Str = StringReplace($Str,"<lf>",@LF)
			$Str = StringReplace($Str,"<cr>",@CR)
			$Newtext = StringToBinary($Str,2) & Binary ("0x" & Hex(0,4))
			$Len = BinaryLen($Newtext)
			$Newfile = _BinaryPoke($Newfile,$pos,$Offset,"dword")
			$Offset += $Len
			$pos += 132
			$Newfile &= $Newtext
			$Num += 1
		Next
		$Newsize = BinaryLen($Newfile)
		$Newfile = _BinaryPoke($Newfile,29,BinaryLen($Newfile)-56,"dword")
		$Newfile = _BinaryPoke($Newfile,45,BinaryLen($Newfile)-56,"dword")
		$Newfile = _BinaryPoke($Newfile,49,BinaryLen($Newfile)-56,"dword")
		FileSetPos($File,$Size+12,0)
		$End = _BinaryToInt32(FileRead($File,4))
		$Newfile &= _BinaryRandom(12,0,0) & _BinaryReverse(Binary ("0x" & Hex($End + (BinaryLen($Newfile) - $Size),8)))
		$hNewfile = FileOpen ($Dir &"\"& $Names[$i], 2+16)
		FileWrite($hNewfile,$Newfile)
		FileClose($hNewfile)
		FileClose($File)
	Next
Else
	$Offset = 0
	$Newfiletext = Binary ("0x" & Hex(0,2))
	FileSetPos($File,60,0)
	$Files = FileRead($File,4)
	FileSetPos($File,88,0)
	$pos = _BinaryToInt32(FileRead($File,4))+56
	FileSetPos($File,120,0)
	$BaseOff = _BinaryToInt32(FileRead($File,4))
	FileRead($File,4)
	$Size = _BinaryToInt32(FileRead($File,4))
	FileSetPos($File,0,0)
	$Newfile = FileRead($File,$BaseOff+56)
	For $i = 1 to $Files
		$Str = $NEWdata[$i]
		$Str = StringReplace($Str,"<cf>",@CRLF)
		$Str = StringReplace($Str,"<lf>",@LF)
		$Str = StringReplace($Str,"<cr>",@CR)
		$Newtext = StringToBinary($Str,2)
		$Len = BinaryLen($Newtext)
		$Newfile = _BinaryPoke($Newfile,$pos+17,int($Offset/2),"dword")
		$Newfile = _BinaryPoke($Newfile,$pos+21,int($Len/2),"dword")
		$Newfiletext &= $Newtext & Binary ("0x" & Hex(0,4))
		$Offset += $Len + 2
		$pos += 32
	Next
	$Len = BinaryLen($Newfiletext)-1
	$Newfile = _BinaryPoke($Newfile,29,$BaseOff + $Len,"dword")
	$Newfile = _BinaryPoke($Newfile,45,$BaseOff + $Len,"dword")
	$Newfile = _BinaryPoke($Newfile,49,$BaseOff + $Len,"dword")
	$Newfile = _BinaryPoke($Newfile,125,int($Len/2),"dword")
	$Newfile = _BinaryPoke($Newfile,129,$Len,"dword")
	FileSetPos($File,$BaseOff+$Size+68,0)
	$End = _BinaryToInt32(FileRead($File,4))
	$Newfiletext &= _BinaryRandom(12,0,0) & _BinaryReverse(Binary ("0x" & Hex($End + ($Len - $Size),8)))
	$hNewfile = FileOpen ("NEW_" & CompGetFileName($Path), 2+16)
	FileWrite($hNewfile,$Newfile&BinaryMid($Newfiletext,2))
	FileClose($hNewfile)
	FileClose($File)
EndIf
TrayTip("Importer", "Finish!", 3)
sleep(3000)
Func CompGetFileName($Path)
If StringLen($Path) < 4 Then Return -1
$ret = StringSplit($Path,"\",2)
If IsArray($ret) Then
Return $ret[UBound($ret)-1]
EndIf
If @error Then Return -1
EndFunc
