msg = MsgBox("Is Path ( "& Path() & "\"& Param("[ApplicationName]")  &"\oracle\oradata )  Is Sharing in Docker Desktop resources ? ",vbYesNo + vbQuestion,"Information")
IF msg = 6 Then
	Set objShell = CreateObject("Shell.Application")
	objShell.ShellExecute Path()+"\db",ArgumentsDb(), "", "runas", 1
	Dim strMessage : strMessage="run"
	Do Until (Len(ContainerStatus())= Len("running") And Len(ContainerHealthyStatus())= Len("healthy"))
		WScript.Sleep(5000)
		if (strMessage <> "stop") Then
			strMessage = Inputbox("Container Name "& Param("[DataBaseContainerName]") &" still not running or unhealthy, If You Want Stop This Message Type stop ","Reminder")
		end if	
	Loop
	objShell.ShellExecute Path()+"\wl",ArgumentsWl(), "", "runas", 1
END IF
Function Path()
	Dim oFSO : Set oFSO = CreateObject("Scripting.FileSystemObject")
	Dim sScriptDir : sScriptDir = oFSO.GetParentFolderName(WScript.ScriptFullName)
	If Len(sScriptDir) = 3 Then sScriptDir = Left(sScriptDir,2)
	path = sScriptDir
End Function

Function Param(var1)
	Set objFso = CreateObject("Scripting.FileSystemObject")
	Set File = objFso.OpenTextFile("config.properties", 1, True)
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

Function ExecStdOut(cmd)
   On Error Resume Next
   'Dim goWSH : Set goWSH = CreateObject( "WScript.Shell" ) 
   'Dim aRet: Set aRet = goWSH.exec(cmd)
   'execStdOut = aRet.StdOut.ReadAll()
	With CreateObject("WScript.Shell")
		.Run "cmd /c "&cmd&" > "&Path()&"\info.txt", 0, True
	End With	
	Const ForReading = 1, ForWriting = 2
	Dim fs, txt, contents
	Set fs = CreateObject("Scripting.FileSystemObject")
	Set txt = fs.OpenTextFile(Path()&"\info.txt", ForReading)
	contents = txt.ReadAll
	txt.Close
	contents = Replace(contents, vbCr, "")
	contents = Replace(contents, vbLf, "")
	Set txt = fs.OpenTextFile(Path()&"\info.txt", ForWriting)
	txt.Write contents
	txt.Close	
	Dim strOutput
	With CreateObject("Scripting.FileSystemObject")
		strOutput = .OpenTextFile(Path()&"\info.txt").ReadAll()
		.DeleteFile Path()&"\info.txt"
	End With
	execStdOut = strOutput
	'If Err.Number <> 0 Then ShowError("It failed")
End Function 

Sub ShowError(strMessage)
    WScript.Echo strMessage
    WScript.Echo Err.Number & " Srce: " & Err.Source & " Desc: " &  Err.Description
    Err.Clear
End Sub

Function DataBaseIp()
	dataBaseIp = ExecStdOut("docker inspect "& Param("[DataBaseContainerName]") &" --format={{.NetworkSettings.IPAddress}}")
End Function

Function ContainerStatus()
	containerStatus = ExecStdOut("docker inspect "& Param("[DataBaseContainerName]") &" --format {{.State.Status}}")
End Function

Function ContainerHealthyStatus()
	containerHealthyStatus = ExecStdOut("docker inspect "& Param("[DataBaseContainerName]") &" --format {{.State.Health.Status}}")
End Function

Function ArgumentsDb()
	argumentsDb = Path() &" "& Param("[PasswordGitHub]") &" "& Param("[PasswordDockerHub]") &" "& Param("[PasswordDataBaseAdmin]") &" "& Param("[ApplicationName]") &" "& Param("[DataBaseContainerName]") &" "& Param("[DataBasePort]") &" "& Param("[DataBaseEnterpriseManagerPort]") &" "& Param("[DataBaseSID]") 
End Function

Function ArgumentsWl()
	argumentsWl = Path() &" "& Param("[DataBaseContainerName]") &" "& Param("[PasswordDataBaseAdmin]") &" "& Param("[DataBaseUser]") &" "& Param("[DataBasePassword]") &" "& Param("[DumpName]") &" "& DataBaseIp() &" "& Param("[DataBasePort]") &" "& Param("[DataBaseSID]") &" "& Param("[WeblogicDS]") &" "& Param("[ApplicationName]") 
End Function
