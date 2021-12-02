$ShortcutFile2 = "C:\Users\Public\Desktop\ONSHAPEcloud Student Signup.lnk";
$WScriptShell = New-Object -ComObject WScript.Shell;
$Shortcut = $WScriptShell.CreateShortcut($ShortcutFile2);
$Shortcut.TargetPath = "https://www.onshape.com/en/education/#form-container";
$Shortcut.IconLocation = "c:\Windows\System32\SHELL32.DLL, 13";
$Shortcut.Save();
$ShortcutFile = "C:\Users\Public\Desktop\go2ONSHAPEcloud.lnk";
$WScriptShell = New-Object -ComObject WScript.Shell;
$Shortcut = $WScriptShell.CreateShortcut($ShortcutFile);
$Shortcut.TargetPath = "http:/cad.onshape.com/signin";
$Shortcut.IconLocation = "c:\Windows\System32\SHELL32.DLL, 13";
$Shortcut.Save()