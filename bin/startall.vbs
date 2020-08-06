Set objShell = CreateObject("Shell.Application")
objShell.ShellExecute Path()+"\bin\startdb",Param("[DataBaseContainerName]"), "", "runas", 1
objShell.ShellExecute Path()+"\bin\startwl",Param("[ApplicationContainerName]") & " " & Param("[WeblogicPort]") & " " & Path() , "", "runas", 1		  
Function Param(var1)
	Set objFso = CreateObject("Scripting.FileSystemObject")
	Set File = objFso.OpenTextFile("bin\config.properties", 1, True)
	Do while File.AtEndofStream <> True 
		 theLine = "" 
		 theLine = File.ReadLine
		 If Instr(theLine,var1) then 
		 tab = split(theline,":")
		 param = tab(1)
		 exit do
		 End if 
	Loop
End Function

Function Path()
	Dim oFSO : Set oFSO = CreateObject("Scripting.FileSystemObject")
	Dim sScriptDir : sScriptDir = oFSO.GetParentFolderName(WScript.ScriptFullName)
	If Len(sScriptDir) = 3 Then sScriptDir = Left(sScriptDir,2)
	path = Left(sScriptDir,InStr(sScriptDir,"bin")-2)
End Function