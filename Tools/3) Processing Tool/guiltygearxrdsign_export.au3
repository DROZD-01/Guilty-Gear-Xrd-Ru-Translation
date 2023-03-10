#Include <File.au3>
#include <Binary.au3>
$Dir = FileSelectFolder("Select the folder OR press Cancel to select the file", "", "", @ScriptDir)
If $Dir = "" Then
	$Path = FileOpenDialog("Select the REDAssetAdvText file", @ScriptDir, "REDAssetAdvText files (*.REDAssetAdvText)",1)
	If @error = 1 Then Exit
	$File = fileopen($Path,16)
EndIf
Dim $Text
If $Dir <> "" Then
	$Names = _FileListToArrayRec($Dir, "*.REDAssetLocalizeText", 1,1)
	If $Names = "" Then
		MsgBox(0,"Error","There are no REDAssetLocalizeText files in the folder.")
		Exit
	EndIf
	For $i=1 to $Names[0]
		$File = FileOpen($Dir &"\"& $Names[$i], 0+16)
		FileSetPos($File,56,0)
		$Files = FileRead($File,4)
		FileRead($File,4)
		For $n = 1 to $Files
			FileRead($File,128)
			$Offset = _BinaryToInt32(FileRead($File,4))+56
			$pos = FileGetPos($File)
			FileSetPos($File,$Offset,0)
			$S = ""
			$Str = ""
			Do
				$Str &= BinaryToString($S,2)
				$S = FileRead ($File, 2)
			Until $S = 0
			$Str = StringReplace($Str,@CRLF,"<cf>")
			$Str = StringReplace($Str,@LF,"<lf>")
			$Str = StringReplace($Str,@CR,"<cr>")
			$Text &= $Str & @CRLF
			FileSetPos($File,$pos,0)
		Next
		FileClose($File)
	Next
	$hTextFile = FileOpen (CompGetFileName($Dir)&".txt", 2+32)
	FileWrite ($hTextFile, $Text)
	FileClose ($hTextFile)
Else
	FileSetPos($File,60,0)
	$Files = FileRead($File,4)
	FileSetPos($File,88,0)
	$pos = _BinaryToInt32(FileRead($File,4))+56
	FileSetPos($File,120,0)
	$BaseOff = _BinaryToInt32(FileRead($File,4))+56
	For $i = 1 to $Files
		FileSetPos($File,$pos,0)
		FileRead($File,16)
		$Offset = _BinaryToInt32(FileRead($File,4))*2+$BaseOff
		$Size = _BinaryToInt32(FileRead($File,4))*2
		FileRead($File,8)
		$pos = FileGetPos($File)
		FileSetPos($File,$Offset,0)
		$Str = BinaryToString(FileRead($File,$Size),2)
		$Str = StringReplace($Str,@CRLF,"<cf>")
		$Str = StringReplace($Str,@LF,"<lf>")
		$Str = StringReplace($Str,@CR,"<cr>")
		$Text &= $Str & @CRLF
	Next
	$hFile = FileOpen (CompGetFileName($Path)&".txt", 2+32)
	FileWrite($hFile, $Text)
	FileClose($hFile)
EndIf
TrayTip ("Exporter", "Finish!", 3)
sleep (3000)
Func CompGetFileName($Path)
If StringLen($Path) < 4 Then Return -1
$ret = StringSplit($Path,"\",2)
If IsArray($ret) Then
Return $ret[UBound($ret)-1]
EndIf
If @error Then Return -1
EndFunc
