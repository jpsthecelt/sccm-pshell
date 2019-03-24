new-item -ItemType directory -Path C:\Users\Public\Desktop\Courseware
new-item -ItemType directory -Path C:\Users\Public\Desktop\Courseware\Geology
new-item -ItemType directory -Path C:\Users\Public\Desktop\Courseware\Geology\docs
$TargetFile = "C:\Windows\System32\notepad.exe"
$ShortcutFile = "C:\Users\Public\Desktop\Courseware\Geoloty\docs\Notepad.lnk"
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
$Shortcut.TargetPath = $TargetFile
$Shortcut.Save()
