Main()
'TestMsg(ContainerDbExists())
Sub Main()
		If FileExists(Path()&"\deploy\"& Param("[ApplicationContainerName]") &".war") Then
			IF MsgBox("Is Path ( "& Path() & "\oracle\oradata )  Is Sharing in Docker Desktop resources ? ",vbYesNo + vbQuestion,"Docker Information") = 6 Then  
				IF  MsgBox("Is Path ( "& Path() & "\deploy\container-scripts\security )  Is Sharing in Docker Desktop resources ? ",vbYesNo + vbQuestion,"Docker Information") = 6 Then
					 Run()
				END IF
			END IF
		else
			WarMsgCheck("ApplicationContainerName")
		End If 
End Sub

Sub Run()
	  Dim dbExists : dbExists = ContainerDbExists()
	  If  Len(dbExists) = 0 Then Exit Sub
      If dbExists Then
		  If ContainerWlExists()  Then 
			  UrlMsg()
		  else
              if ContainerDbExists() = false then 
			      ExitMsg()
				  Exit Sub
			  end if
			  Shell("wl")	
              WScript.Sleep(20000)			  
		  End If 	
	  else
		  If ContainerWlExists() = False Then  Run()	
	  End If	
End Sub

Function ContainerDbExists()
      Dim dbExists : dbExists = ContainerExists("DataBaseContainerName")	 
	  If  Len(dbExists) = 0 Then Exit Function
      If dbExists = False Then
	      dbExists = CBool(0)
		  Shell("db")
		  WScript.Sleep(20000)
		  If ContainerExists("DataBaseContainerName") Then 
			  dbExists = CBool(1)
		  End If 	  
	  End If
	  ContainerDbExists = dbExists
End Function

Function ContainerWlExists()
      Dim cbol : cbol = CBool(0)
      If ContainerExists("ApplicationContainerName") Then
		  cbol = CBool(1)	  
	  End If
	  ContainerWlExists = cbol
End Function

Dim start : start=CBool(0)
Function ContainerExists(str)
    Dim cbol : cbol = CBool(1)
	Dim status : status = ContainerHealthyStatus(str)
	if (status=Empty) then
		cbol=CBool(0)
	else		 
		 if (status="healthy" Or status="unhealthy") then
			if MsgBox("Container Name : ("& Param("["& str &"]") &") Health Status : (" & status & ") You Want Reinstall ? ",vbYesNo + vbQuestion,"Docker Information") = 6 Then  
				  cbol=CBool(0)
            Else 
			       UnHealthyMsg(str)
                   Exit Function			
			end if	
		elseif (status="starting") then	
		    if start = false then
				HealthyStartingMsg(str)
				Shell(str)
			end if	
			WScript.Sleep(20000)
			If ContainerHealthyStatus(str)="healthy" Then 
				HealthyMsg(str) 
			Else
			    ContainerExists(str)
			End If					
		else
		    cbol=CBool(0)
			Support()
		end if
	end if
	ContainerExists=cbol
End Function

Sub Shell(str)
      Set objShell = CreateObject("Shell.Application")
	  if (str="db") then
		  objShell.ShellExecute Path()+"\bin\"&str,ArgumentsDb(), "", "runas", 1
	  elseif (str="wl") then
          objShell.ShellExecute Path()+"\bin\"&str,ArgumentsWl(), "", "runas", 1   
	  else
          objShell.ShellExecute Path()+"\bin\stts",Param("["& str &"]"), "", "runas", 1
		  start=CBool(1)  
       end if		  
End Sub

Function Path()
	Dim oFSO : Set oFSO = CreateObject("Scripting.FileSystemObject")
	Dim sScriptDir : sScriptDir = oFSO.GetParentFolderName(WScript.ScriptFullName)
	If Len(sScriptDir) = 3 Then sScriptDir = Left(sScriptDir,2)
	path = Left(sScriptDir,InStr(sScriptDir,"bin")-2)
End Function

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

Function FileExists(FilePath)
  Set fso = CreateObject("Scripting.FileSystemObject")
  If fso.FileExists(FilePath) Then
    FileExists=CBool(1)
  Else
    FileExists=CBool(0)
  End If
End Function

Function DataBaseIp(container)
	dataBaseIp = ExecStdOut("docker inspect "& Param("["&container&"]") &" --format={{.NetworkSettings.IPAddress}}")
End Function

Function ContainerStatus(container)
	containerStatus = ExecStdOut("docker inspect "& Param("["&container&"]") &" --format {{.State.Status}}")
End Function

Function ContainerHealthyStatus(container)
	containerHealthyStatus = ExecStdOut("docker inspect "& Param("["&container&"]") &" --format {{.State.Health.Status}}")
End Function

Function ArgumentsDb()
	argumentsDb = Path() &" "& Param("[PasswordGitHub]") &" "& Param("[PasswordDockerHub]") &" "& Param("[PasswordDataBaseAdmin]") &" "& Param("[ApplicationContainerName]") &" "& Param("[DataBaseContainerName]") &" "& Param("[DataBasePort]") &" "& Param("[DataBaseEnterpriseManagerPort]") &" "& Param("[DataBaseSID]") 
End Function

Function ArgumentsWl()
	argumentsWl = Path() &" "& Param("[DataBaseContainerName]") &" "& Param("[PasswordDataBaseAdmin]") &" "& Param("[DataBaseUser]") &" "& Param("[DataBasePassword]") &" "& Param("[DumpName]") &" "& DataBaseIp("DataBaseContainerName") &" "& Param("[DataBasePort]") &" "& Param("[DataBaseSID]") &" "& Param("[WeblogicDS]") &" "& Param("[ApplicationContainerName]") &" "& Param("[WeblogicPort]")
End Function

Sub HealthyStartingMsg(str)
	msg = MsgBox("Container Name : ("& Param("["& str &"]") &") Health Status : (" & ContainerHealthyStatus(str) & ") please wait ...... ",vbOKOnly + vbInformation,"Docker Information")
End Sub

Sub ShowError(strMessage)
    WScript.Echo strMessage
    WScript.Echo Err.Number & " Srce: " & Err.Source & " Desc: " &  Err.Description
    Err.Clear
End Sub

Sub UnHealthyMsg(str)
	msg = MsgBox("Container Name : ("& Param("["& str &"]") &") Health Status : (" & ContainerHealthyStatus(str) & ") Install Will Exit ",vbOKOnly + vbInformation,"Docker Information")
End Sub

Sub ExitMsg()
	msg = MsgBox("Container Name : ("& Param("[DataBaseContainerName]") &") Not Exists Install Will Exit ",vbOKOnly + vbInformation,"Docker Information")
End Sub

Sub HealthyMsg(str)
	msg = MsgBox("Container Name : ("& Param("["& str &"]") &") Health Status : (" & ContainerHealthyStatus(str) & ") thanks for waiting ",vbOKOnly + vbInformation,"Docker Information")
End Sub

Sub WarMsgCheck(str)
	msg = MsgBox("Container Name : ("& Param("["& str &"]") &") And War File In ("&Path()&"\deploy\) Must Be Same Word with out letters (.war) Or War File Not Found Please Check .......",vbOKOnly + vbInformation,"Setup Information")
End Sub

Sub UrlMsg()
	msg = MsgBox("Open Application In (http://localhost:"& Param("[WeblogicPort]") &"/"& Param("[ApplicationContainerName]") &")           Open Weblogic In    (http://localhost:"& Param("[WeblogicPort]") &"/console)                 Open E.manager In  (https://localhost:"& Param("[DataBaseEnterpriseManagerPort]") &"/em) ",vbOKOnly + vbInformation,"URL Information")
End Sub

Sub Support()
	   msg = MsgBox(" Error when install please call support using mail Mhalawa@ejada.com ",vbOKOnly + vbInformation,"Docker Information")
End Sub

Sub TestMsg(str)
	msg = MsgBox(str,vbOKOnly + vbInformation,"URL Information")
End Sub
