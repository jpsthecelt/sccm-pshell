$adu2=$(get-aduser -property HomeDrive,HomeDirectory -filter {(HomeDirectory -ne "$Null")} | select-object @{l='NetDir'; e={$_.HomeDirectory}} )
foreach ($l in $adu2) { attrib +r /s /d $l.NetDir}