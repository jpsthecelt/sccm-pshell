$password = Read-Host -AsSecureString
New-LocalUser -Name geostudent -Description "Generic student account used for this lab" -Password $password
Add-LocalGroupMember -Group "Administrators" -Member "geostudent"
get-localuser
