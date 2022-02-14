Dim WSHShell
Set WSHShell = WScript.CreateObject("WScript.Shell")
 
Dim MyShortcut, MyDesktop, DesktopPath
' Read desktop path using WshSpecialFolders object
DesktopPath = WSHShell.SpecialFolders("Desktop")
 
' Create a shortcut object on the desktop
Set MyShortcut = WSHShell.CreateShortcut(DesktopPath & "\notepad shortcut.lnk")
 
' Set shortcut object properties and save it
MyShortcut.TargetPath = WSHShell.ExpandEnvironmentStrings("%windir%\notepad.exe")
MyShortcut.WorkingDirectory = WSHShell.ExpandEnvironmentStrings("%windir%")
MyShortcut.WindowStyle = 7 ' &&Maximized=3 7=Minimized  4=Normal 
MyShortcut.IconLocation = WSHShell.ExpandEnvironmentStrings("%windir%\notepad.exe, 0")
MyShortcut.Save
 
WScript.Echo "Notepad Shortcut has been placed on desktop"
