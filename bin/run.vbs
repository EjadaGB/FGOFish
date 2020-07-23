
Main()

Sub Main()
		If FileExists(Path()&"\deploy\"& Param("[ApplicationContainerName]") &".war") Then
		              DockerDesktopMsg()
					  'Installion()
 	                  InstallionDbWl()
		else
			WarMsgCheck("ApplicationContainerName")
		End If 
End Sub

Sub InstallionDbWl()
		RunDb("") 
		Wait("DataBaseContainerName")
        RunWl()
		Wait("ApplicationContainerName") 
        UrlMsg()			
End Sub

Sub Wait(str)
	if str = "DataBaseContainerName" then
			Do While (ContainerHealthyStatus(str) <> "healthy" And ContainerStatus(str) <> "running")
			Loop
	elseif  str = "ApplicationContainerName" then
			Do While (ContainerStatus(str) <> "running")
			Loop
	end if
End Sub

Sub Installion()
	  input = InputBox("For Install Database Enter Letter D For Install Weblogic Enter Letter W For Get URL Enter Letter U ", "User", "W")
	  Choose(UCase(input))					 
End Sub

Sub Choose(str)
		if  str = "D" then  
		   RunDb("choose")
		elseif  str = "W" then     
		   RunWl()
		elseif  str = "U" then     
		   UrlMsg()	   
		else
		    ErrorChoiceMsg()
		end if
End Sub



Sub RunDb(msg)
    if msg = "choose" then
	   msg = " Then Open (start.cmd) again To Install Weblogic "
	else
       msg = ""
    end if	   
    Dim dbExist : dbExist = ContainerHealthyStatus("DataBaseContainerName")
    Dim dbStatus 	
    if  Len(dbExist)=0 then
		Shell("db")
		'msg = MsgBox("DB1 - DataBase Installion Will Take Some Time Please Preview The Command Window When Status Changed From Starting To Healthy " & msg,vbOKOnly + vbInformation,"Docker Information")
		if MsgBox("DB1 - DataBase Installion Will Take Some Time Please Preview The Command Window When Status Changed From Starting To Healthy " & msg & " Do You Need Preview Status ?",vbYesNo + vbQuestion,"Docker Information") = 6 Then  
		   Shell("DataBaseContainerName")
		end if
        Exit Sub
    elseif  dbExist="healthy" then
            dbStatus = ContainerStatus("DataBaseContainerName")
		    if dbStatus="running" then
				if MsgBox("DB2 - Container Name : ("& Param("[DataBaseContainerName]") &") Health Status : (" & dbExist & ") You Want Reinstall ? ",vbYesNo + vbQuestion,"Docker Information") = 6 Then  
						'msg = MsgBox("DB3 - DataBase Installion Will Take Some Time Please Preview The Command Window When Status Changed From Starting To Healthy " & msg,vbOKOnly + vbInformation,"Docker Information")
						Shell("db")	
						if MsgBox("DB3 - DataBase Installion Will Take Some Time Please Preview The Command Window When Status Changed From Starting To Healthy " & msg & " Do You Need Preview Status ?",vbYesNo + vbQuestion,"Docker Information") = 6 Then  
						   Shell("DataBaseContainerName")
						end if					
				end if	
				Exit Sub
            elseif dbStatus="exited" then	
				if MsgBox("DB4 - Container Name : ("& Param("[DataBaseContainerName]") &") Is Stopped Do You Need Start ? ",vbYesNo + vbQuestion,"Docker Information") = 6 Then  
						'msg = MsgBox("DB5 - DataBase Starting Will Take Some Time Please Preview The Command Window When Status Changed From Starting To Healthy " & msg,vbOKOnly + vbInformation,"Docker Information")
                        Shell("startdb") 
						if MsgBox("DB5 - DataBase Starting Will Take Some Time Please Preview The Command Window When Status Changed From Starting To Healthy " & msg & " Do You Need Preview Status ?",vbYesNo + vbQuestion,"Docker Information") = 6 Then  
						   Shell("DataBaseContainerName")
						end if							
				end if	
				Exit Sub	
			else
				if MsgBox("DB6 - Container Name : ("& Param("[DataBaseContainerName]") &") Status : (" & dbStatus & ") Do You Want Reinstall ? ",vbYesNo + vbQuestion,"Docker Information") = 6 Then  						
						'msg = MsgBox("DB7 - DataBase Installion Will Take Some Time Please Preview The Command Window When Status Changed From Starting To Healthy " & msg,vbOKOnly + vbInformation,"Docker Information")
						Shell("db")
						if MsgBox("DB7 - DataBase Installion Will Take Some Time Please Preview The Command Window When Status Changed From Starting To Healthy " & msg & " Do You Need Preview Status ?",vbYesNo + vbQuestion,"Docker Information") = 6 Then  
						   Shell("DataBaseContainerName")
						end if		                  		
				end if	
				Exit Sub				
			end if
    elseif  dbExist="starting" then 
		    'msg = MsgBox("DB8 - DataBase Installion Will Take Some Time Please Preview The Command Window When Status Changed From Starting To Healthy " & msg,vbOKOnly + vbInformation,"Docker Information")
			if MsgBox("DB8 - DataBase Installion Will Take Some Time Please Preview The Command Window When Status Changed From Starting To Healthy " & msg & " Do You Need Preview Status ?",vbYesNo + vbQuestion,"Docker Information") = 6 Then  
			   Shell("DataBaseContainerName")
			end if		
	        Exit Sub	
	else 
            dbStatus = ContainerStatus("DataBaseContainerName")
		    if dbStatus="running" then
		        msg = MsgBox("DB9 - DataBase Is Running ",vbOKOnly + vbInformation,"Docker Information")		
				Exit Sub
            elseif dbStatus="exited" then	
				if MsgBox("DB10 - Container Name : ("& Param("[DataBaseContainerName]") &") Is Stopped Do You Need Start ? ",vbYesNo + vbQuestion,"Docker Information") = 6 Then  
						Shell("startdb") 
						'msg = MsgBox("DB11 - DataBase Starting Will Take Some Time Please Preview The Command Window When Status Changed From Starting To Healthy " & msg,vbOKOnly + vbInformation,"Docker Information")
						if MsgBox("DB11 - DataBase Starting Will Take Some Time Please Preview The Command Window When Status Changed From Starting To Healthy " & msg & " Do You Need Preview Status ?",vbYesNo + vbQuestion,"Docker Information") = 6 Then  
						   Shell("DataBaseContainerName")
						end if		                          		
				end if	
				Exit Sub	
			else
				if MsgBox("DB12 - Container Name : ("& Param("[DataBaseContainerName]") &") Status : (" & dbStatus & ") Do You Want Reinstall ? ",vbYesNo + vbQuestion,"Docker Information") = 6 Then  
						Shell("db")
						'msg = MsgBox("DB13 - DataBase Installion Will Take Some Time Please Preview The Command Window When Status Changed From Starting To Healthy " & msg,vbOKOnly + vbInformation,"Docker Information")
						if MsgBox("DB13 - DataBase Installion Will Take Some Time Please Preview The Command Window When Status Changed From Starting To Healthy " & msg & " Do You Need Preview Status ?",vbYesNo + vbQuestion,"Docker Information") = 6 Then  
						   Shell("DataBaseContainerName")
						end if	                  		
				end if	
				Exit Sub				
			end if
		end if		
End Sub

Sub RunWl()
    Dim dbExist : dbExist = ContainerHealthyStatus("DataBaseContainerName")	
    if  Len(dbExist)=0 then
	     msg = MsgBox("WL1 - Container Name : ("& Param("[DataBaseContainerName]") &") Is Not Found Please Open (start.cmd) file again and Write (D) to Install DataBase First ",vbOKOnly + vbInformation,"Docker Information")
		 Exit Sub
	elseif  dbExist="starting" then 
		    'msg = MsgBox("WL2 - DataBase Installion Will Take Some Time Please Preview The Command Window When Status Changed From Starting To Healthy Then Open (start.cmd) again ",vbOKOnly + vbInformation,"Docker Information")
		    if MsgBox("WL2 - DataBase Installion Will Take Some Time Please Preview The Command Window When Status Changed From Starting To Healthy Then Open (start.cmd) again Do You Need Preview Status ?",vbYesNo + vbQuestion,"Docker Information") = 6 Then  
				Shell("DataBaseContainerName")
			end if	 	
	        Exit Sub	 
	else	
		Dim dbStatus : dbStatus = ContainerStatus("DataBaseContainerName")
		if dbStatus <> "running" then
			msg = MsgBox("WL3 - Container Name : ("& Param("[DataBaseContainerName]") &") Is Not Running Please Open (start.cmd) file again and Write (D) to Install DataBase First ",vbOKOnly + vbInformation,"Docker Information")		
			Exit Sub
	     end if
	end if	
	Dim wlExist : wlExist = ContainerHealthyStatus("ApplicationContainerName")
	Dim wlStatus
    if  Len(wlExist)=0 then
		Shell("wl")
		'msg = MsgBox("WL4 - Weblogic Installion Will Take Some Time Please Preview The Command Window When Status Changed From Starting To Healthy ",vbOKOnly + vbInformation,"Docker Information")
		if MsgBox("WL4 - Weblogic Installion Will Take Some Time Please Preview The Command Window When Status Changed From Starting To Healthy Do You Need Preview Status ?",vbYesNo + vbQuestion,"Docker Information") = 6 Then  
			Shell("ApplicationContainerName")
		end if	
        Exit Sub
    elseif  wlExist="healthy" then	
		wlStatus = ContainerStatus("ApplicationContainerName")
		if wlStatus="running" then
			msg = MsgBox("WL5 - Weblogic Is Running ",vbOKOnly + vbInformation,"Docker Information")		
			Exit Sub
		elseif wlStatus="exited" then	
			if MsgBox("WL6 - Container Name : ("& Param("[ApplicationContainerName]") &") Is Stopped Do You Need Start ? ",vbYesNo + vbQuestion,"Docker Information") = 6 Then  
					Shell("startwl")
					'msg = MsgBox("WL7 - Weblogic Starting Will Take Some Time Please Preview The Command Window When Status Changed From Starting To Healthy ",vbOKOnly + vbInformation,"Docker Information")
					if MsgBox("WL7 - Weblogic Starting Will Take Some Time Please Preview The Command Window When Status Changed From Starting To Healthy Do You Need Preview Status ?",vbYesNo + vbQuestion,"Docker Information") = 6 Then  
						Shell("ApplicationContainerName")
					end if	    		
			end if	
			Exit Sub	
		else
			if MsgBox("WL8 - Container Name : ("& Param("[ApplicationContainerName]") &") Status : (" & dbStatus & ") Do You Want Reinstall ? ",vbYesNo + vbQuestion,"Docker Information") = 6 Then  			
					Shell("wl")
					'msg = MsgBox("WL9 - Weblogic Installion Will Take Some Time Please Preview The Command Window When Status Changed From Starting To Healthy ",vbOKOnly + vbInformation,"Docker Information")
					if MsgBox("WL9 - Weblogic Installion Will Take Some Time Please Preview The Command Window When Status Changed From Starting To Healthy Do You Need Preview Status ?",vbYesNo + vbQuestion,"Docker Information") = 6 Then  
						Shell("ApplicationContainerName")
					end if					
			end if	
			Exit Sub				
		end if			
    elseif  wlExist="starting" then 
		    'msg = MsgBox("WL10 - Weblogic Installion Will Take Some Time Please Preview The Command Window When Status Changed From Starting To Healthy ",vbOKOnly + vbInformation,"Docker Information")
		    if MsgBox("WL10 - Weblogic Installion Will Take Some Time Please Preview The Command Window When Status Changed From Starting To Healthy Do You Need Preview Status ?",vbYesNo + vbQuestion,"Docker Information") = 6 Then  
						Shell("ApplicationContainerName")
			end if		 	
	        Exit Sub	
	else 
		wlStatus = ContainerStatus("ApplicationContainerName")
		if wlStatus="running" then
			msg = MsgBox("WL11 - Weblogic Is Running ",vbOKOnly + vbInformation,"Docker Information")		
			Exit Sub
		elseif wlStatus="exited" then	
			if MsgBox("WL12 - Container Name : ("& Param("[ApplicationContainerName]") &") Is Stopped Do You Need Start ? ",vbYesNo + vbQuestion,"Docker Information") = 6 Then  
					Shell("startwl") 
					'msg = MsgBox("WL13 - Weblogic Starting Will Take Some Time Please Preview The Command Window When Status Changed From Starting To Healthy ",vbOKOnly + vbInformation,"Docker Information")
					if MsgBox("WL13 - Weblogic Starting Will Take Some Time Please Preview The Command Window When Status Changed From Starting To Healthy Do You Need Preview Status ?",vbYesNo + vbQuestion,"Docker Information") = 6 Then  
								Shell("ApplicationContainerName")
					end if						   		
			end if	
			Exit Sub	
		else
			if MsgBox("WL14 - Container Name : ("& Param("[ApplicationContainerName]") &") Status : (" & dbStatus & ") Do You Want Reinstall ? ",vbYesNo + vbQuestion,"Docker Information") = 6 Then  			
					Shell("wl")
					'msg = MsgBox("WL15 - Weblogic Installion Will Take Some Time Please Preview The Command Window When Status Changed From Starting To Healthy ",vbOKOnly + vbInformation,"Docker Information")
					if MsgBox("WL15 - Weblogic Installion Will Take Some Time Please Preview The Command Window When Status Changed From Starting To Healthy Do You Need Preview Status ?",vbYesNo + vbQuestion,"Docker Information") = 6 Then  
								Shell("ApplicationContainerName")
					end if					
			end if	
			Exit Sub				
		end if		
    end If 
End Sub

Sub Shell(str)
      Set objShell = CreateObject("Shell.Application")
	  if (str="db") then
		  objShell.ShellExecute Path()+"\bin\"&str,ArgumentsDb(), "", "runas", 1
	  elseif (str="wl") then
          objShell.ShellExecute Path()+"\bin\"&str,ArgumentsWl(), "", "runas", 1 
      elseif (str="startdb") then
	      objShell.ShellExecute Path()+"\bin\start",Param("[DataBaseContainerName]"), "", "runas", 0
      elseif (str="startwl") then
	      objShell.ShellExecute Path()+"\bin\start",Param("[ApplicationContainerName]"), "", "runas", 1		  
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


Sub ShowError(strMessage)
    WScript.Echo strMessage
    WScript.Echo Err.Number & " Srce: " & Err.Source & " Desc: " &  Err.Description
    Err.Clear
End Sub

Sub ErrorChoiceMsg()
	msg = MsgBox("The Entered Value Is Not True The Installion Will Exit Try Again . For Support Send Problem To Mhalawa@ejada.com",vbOKOnly + vbInformation,"Docker Information")
End Sub

Sub WarMsgCheck(str)
	msg = MsgBox("Container Name : ("& Param("["& str &"]") &") And War File In ("&Path()&"\deploy\) Must Be Same Word with out letters (.war) Or War File Not Found Please Check .......",vbOKOnly + vbInformation,"Setup Information")
End Sub

Sub UrlMsg()
	msg = MsgBox("Open Application In (http://localhost:"& Param("[WeblogicPort]") &"/"& Param("[ApplicationContainerName]") &")           Open Weblogic In    (http://localhost:"& Param("[WeblogicPort]") &"/console)                 Open E.manager In  (https://localhost:"& Param("[DataBaseEnterpriseManagerPort]") &"/em) ",vbOKOnly + vbInformation,"URL Information")
End Sub

Sub DockerDesktopMsg()
	msg = MsgBox("If Sharing Folder For Pathes ( "& Path() & "\oracle\oradata   And   "& Path() & "\deploy\container-scripts\security ) Not Found The Docker Desktop Will Ask To Share Please Accept That When Installion ",vbOKOnly + vbInformation,"URL Information")
End Sub

