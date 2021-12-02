    [CmdletBinding()]
    param (
        $Src
    )
#  This will be used via SCCM to install WinSalt
# 
if (-not (Test-Path -Path c:\temp)) {
    mkdir c:\temp
}
if (-not (Test-Path -Path "$env:ProgramData/SALT Software/SALT 20/")) {
    mkdir "$env:ProgramData/SALT Software/SALT 20/"
}
# 
Copy-Item $Src/* c:/temp/
msiexec /qn /i "c:\temp\WinSALT20.msi”
Copy-Item c:/temp/SALT_20_LIC.dat "$env:ProgramData/SALT Software/SALT 20/"