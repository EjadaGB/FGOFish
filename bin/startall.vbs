Set objShell = CreateObject("Shell.Application")
objShell.ShellExecute Path()+"\bin\start",Param("[DataBaseContainerName]"), "", "runas", 1
objShell.ShellExecute Path()+"\bin\start",Param("[ApplicationContainerName]"), "", "runas", 1		  
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

