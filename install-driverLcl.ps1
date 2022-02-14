# Note: Previously, this script assumed that $ComputerName was a list, like:
#$ComputerName = "comp1", "comp2", "comp3"
# Now, it is a cmdlet-bound string which could be a single computer or a list...

[cmdletbinding()]
Param(
	[Parameter(ValueFromPipeline=$True,
	           Mandatory=$True)]
    [String]$ComputerName,
    [String]$DrvPath,
    [String]$DrvInf,
    [String]$DrvName, 
    [String]$PrtIp
	)

BEGIN{
    $ComputerName="rogue-013"
    $DrvPath="z:\\HP Color LaserJet Pro M454dn\\HP_CLJM453-M454_V4\\"
    $DrvInf="hpshC42A4_x64.inf"
    $DrvName="HP Color Laserjet Pro M454dn -MI3094"
    $PrtIp="134.154.240.7"
}

PROCESS {
    foreach ($uut in $ComputerName) {
        if ($DrvPath.length -eq 0 -or $DrvInf.length -eq 0 -or $DrvName.length -eq 0 -or $PrtIp.length -eq 0) {
    	      write-error "Insufficent number of parameters"
    	      exit
    	}
    	# Now, copy the files to the remote system....
    	Copy-Item -Path "$DrvPath" -Destination "\\$uut\c$\" -Recurse
    
    #	foreach ($uut in $ComputerName) {Copy-Item -Path "$DrvPath" -Destination "\\$uut\c$\" -Recurse}
    	
        try {
	 			$uutPath=('C:\\'+(split-path $DrvPath -leaf))
    		    if ((Test-Path ($uutPath+'\\'+$DrvInf)) -eq $True) {
    		        $IP = $PrtIp
    		        $Driver = $DrvName
    		        $Description = "$DrvName (autoinstall)"
    		#Install Printer Driver
    		        $driverclass = [WMIClass]"Win32_PrinterDriver"
    		        $driverobj = $driverclass.createinstance()
    				$driverobj.Name="$Driver"
    				$driverobj.DriverPath = $uutPath
    				# "C:\Driver File"
    				$driverobj.Infname = $uutPath+'\\'+$DrvInf
    				# "C:\Driver File\Driver.inf"
    		        $newdriver = $driverclass.AddPrinterDriver($driverobj)
    		        $newdriver = $driverclass.Put()
    		#Install Printer Port
    		        $Port = ([wmiclass]"win32_tcpipprinterport").createinstance()
    		        $Port.Name = "$IP"
    		        $Port.HostAddress = "$IP"
    		        $Port.Protocol = "1"
    		        $Port.PortNumber = "9100"
    		        $Port.SNMPEnabled = $true
    		        $Port.Description = "$IP"
    		        $Port.Put()
    		#Install Printer
    		        $Printer = ([wmiclass]"win32_Printer").createinstance()
    		        $Printer.Name = "$Description"
    		        $Printer.DriverName = "$Driver"
    		        $Printer.DeviceID = "$Description"
    		        $Printer.Shared = $false
    		        $Printer.PortName = "$IP"
    		        $Port.Description = "$IP"
    		        $Printer.Put()
					}
			}
    	Catch {
			write-host "Whoops!"
			write-host $_
		}
	}
} # Process
END {}
