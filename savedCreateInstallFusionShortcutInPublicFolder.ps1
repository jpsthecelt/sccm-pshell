$Shell= New-Object -ComObject ("WScript.Shell")
$Shortcut = $Shell.CreateShortcut("C:\Users\Public\Desktop\InstallFusion.lnk")
$Shortcut.TargetPath = "https://rawportal.csueastbay.edu:81/FusionSetup.aspx"
$Shortcut.IconLocation = "iexplore.exe, 0";
$Shortcut.Save()