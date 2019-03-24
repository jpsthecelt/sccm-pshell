# Set Default Parameters

$hkey_uninstall = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\'
$hk_uninst = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\'
$ht = @{}

# Set Parameter-keys...
$as_ztve_zt_int = "6dc43c7e-563d-4fa0-84f3-a4a870f52075"
$as_ztve_zr_wave = "7351fcdb-e302-4e51-826c-b75bd0e97011"
$as_ztve_zt = "0e370b0e-70fb-4c12-a066-bc208dd7f28f"
$as_ztve_zt_dom = "aa173019-5c9f-44e1-8782-85571c5861d9"
$as_zoomtext = "59F7E930-3FE4-49CF-A829-C9C81501AAC8"
$as_ztsp_paul = "5AA07C82-F1F3-453D-97EC-C9BD21BE6974"
$as_ztsp_kate = "FD92D897-3391-4BC4-93E4-B59283774AD9"

# Setup Parameters Speech Engines 
$as_ztsp_paul = "5AA07C82-F1F3-453D-97EC-C9BD21BE6974"
$as_ztsp_kate = "FD92D897-3391-4BC4-93E4-B59283774AD9"

# Setup Core Parameters 
$as_zt_main = "F7F20305-1476-4421-B909-BB5B90D1F222"
$code_meter = "3C40446D-C306-4D9A-8AD2-F9D07E7B781B"
$as_runtime = "3B6D6149-A3ED-4246-B09A-4693084AC20A"

# Remove Products Core 
$gotPaul = Get-ChildItem $hk_uninst -Recurse | Where Name -like "*$as_ztsp_paul*" | foreach { $_.GetValue("DisplayName"),$_.GetValue("UninstallString"),$_.GetValue("InstallLocation") }
$gotKate = Get-ChildItem $hk_uninst -Recurse | Where Name -like "*$as_ztsp_kate*" | foreach { $_.GetValue("DisplayName"),$_.GetValue("UninstallString"),$_.GetValue("InstallLocation") }  
$gotZtMain = Get-ChildItem $hk_uninst -Recurse | Where Name -like "*$as_zt_main*" | foreach { $_.GetValue("DisplayName"),$_.GetValue("UninstallString"),$_.GetValue("InstallLocation") }  
$gotAsRuntime = Get-ChildItem $hk_uninst -Recurse | Where Name -like "*$as_runtime*" | foreach { $_.GetValue("DisplayName"),$_.GetValue("UninstallString"),$_.GetValue("InstallLocation") }  
$gotCodemeter = Get-ChildItem $hk_uninst -Recurse | Where Name -like "*$code_meter*" | foreach { $_.GetValue("DisplayName"),$_.GetValue("UninstallString"),$_.GetValue("InstallLocation") }  
$gotAsZoomtext = Get-ChildItem $hk_uninst -Recurse | Where Name -like "*$as_zoomtext*" | foreach { $_.GetValue("DisplayName"),$_.GetValue("UninstallString"),$_.GetValue("InstallLocation") }
$gotZtInt = Get-ChildItem $hk_uninst -Recurse | Where Name -like "*$as_ztve_zt_int*" | foreach { $_.GetValue("DisplayName"),$_.GetValue("UninstallString"),$_.GetValue("InstallLocation") }  
$gotZtWave = Get-ChildItem $hk_uninst -Recurse | Where Name -like "*$as_ztve_zr_wave*" | foreach { $_.GetValue("DisplayName"),$_.GetValue("UninstallString"),$_.GetValue("InstallLocation") }  
$gotZtveZt = Get-ChildItem $hk_uninst -Recurse | Where Name -like "*$as_ztve_zt*" | foreach { $_.GetValue("DisplayName"),$_.GetValue("UninstallString"),$_.GetValue("InstallLocation") }  
$gotZtveZtDom = Get-ChildItem $hk_uninst -Recurse | Where Name -like "*$as_ztve_zt_dom*" | foreach { $_.GetValue("DisplayName"),$_.GetValue("UninstallString"),$_.GetValue("InstallLocation") }  

if ($gotZtMain.Length -gt 0) {

	# KillTask & service, if running 
	taskkill /IM "ZtUac64.exe" /f
	Stop-Service -name "ZoomText Helper Service" -Force
	set-service -name "ZoomText Helper Service" -StartupType Manual


	# As with all of these registry-keys, note that $gotZtMain[0] is the Display Name, [1] is the uninstall-string, 
	#	 and [2] is the install-location -- If we have a registry-uninstall key, execute it.
	if ($gotZtMain[1].Length -gt 0) {
		invoke-command -scriptblock { $gotZtMain[1] }
		# ... and 'kill' the associated registry sub-hive...
		remove-item -path ($hk_uninst+'{'+$as_zt_main+'}') -Recurse -Force
	}

	# If we don't have the runtime-path information, just delete any related subdirectories 'manually'
	if ($gotAsRuntime.Length -gt 0) {
		remove-item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\ZoomText 10.1" -recurse -force
		remove-item -Path "C:\Program Files (x86)\InstallShield Installation Information\{$hkey_as_zt_main}" -recurse -force
		remove-item -Path "C:\Program Files (x86)\ZoomText 10.1" -recurse -force
		remove-service -Name "ZoomText Helper Service"
	}
}
# Execute Codemeter uninstall-line
if ($gotCodemeter[1].Length -gt 0) {
	invoke-command -scriptblock {($gotCodemeter[1] )}
}

# Similarly (& quietly) Remove both Speech Products  (Kate & Paul)
if ($gotPaul.Length -gt 0 -and $gotPaul[1].Length -gt 0) {
	invoke-command -scriptblock { $gotPaul[1]} 
}
if ($gotKate.Length -gt 0 -and $gotKate[1].Length -gt 0) {
	invoke-command -scriptblock {($gotKate[1] )}
}

# Likewise, then (quietly) Remove any other related sub-products that are still installed
if ($gotAsZoomtext.Length -gt 0 -and $gotAsZoomtext[1].Length -gt 0) {
	invoke-command -scriptblock {($gotAsZoomtext[1])}
	remove-item -path ($hk_uninst+'{'+$as_zoomtext+'}') -Recurse -Force
}
if ($gotZtInt.Length -gt 0 -and $gotZtInt[1].Length -gt 0) {
	invoke-command -scriptblock {$gotZtInt[1]}
}
if ($gotZtWave.Length -gt 0 -and $gotZtWave[1].Length -gt 0) {
	invoke-command -scriptblock {$gotZtWave[1] } 
}
if ($gotZtveZt.Length -gt 0 -and $gotZtveZt[1].Length -gt 0) {
	invoke-command -scriptblock {$gotZtveZt[1] }
}
if ($gotZtveZtDom.Length -gt 0 -and $gotZtveZtDom[1].Length -gt 0) { 
	invoke-command -scriptblock { $gotZtveZtDom[1] }
}

remove-item -Path "C:\Users\Public\Desktop\AT software\*Zoom*.*" -Force
