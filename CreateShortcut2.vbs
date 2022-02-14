Set oWS = WScript.CreateObject("WScript.Shell") 
sLinkFile = "C:\Users\Public\Desktop\runJmeter.lnk" 
Set oLink = oWS.CreateShortcut(sLinkFile) 
oLink.WindowsStyle=7 
oLink.TargetPath = "c:\apache-jmeter-3.2\bin\jmeter.bat" 
oLink.Save 
