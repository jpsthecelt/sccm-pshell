<<<<<<< HEAD
# Note: Previously, this script assumed that $ComputerName was a list, like:
#$ComputerName = "comp1", "comp2", "comp3"
# Now, it is a cmdlet-bound string which could be a single computer or a list...

#[cmdletbinding()]
#Param(
#    [String]$ComputerName,
#    [String]$DrvPath,
#    [String]$DrvInf,
#    [String]$DrvName,
#    [String]$PrtIp
#       )
#
$ComputerName="win7b-11"
$DrvPath="z:\\HP Color LaserJet Pro M454dn\\HP_CLJM453-M454_V4\\"
$DrvInf="hpshC42A4_x64.inf"
$DrvName="HP Color Laserjet Pro M454dn -MI3094"
$PrtIp="134.154.240.7"

foreach ($uut in $ComputerName) {
    if ($DrvPath.length -eq 0 -or $DrvInf.length -eq 0 -or $DrvName.length -eq 0 -or $PrtIp.length -eq 0) {
                  write-error "Insufficent number of parameters"
		                exit
				        }
					        # Now, copy the files to the remote system....
						        Copy-Item -Path "$DrvPath" -Destination "\\$uut\c$\" -Recurse

							        foreach ($uut in $ComputerName) {Copy-Item -Path "$DrvPath" -Destination "\\$uut\c$\" -Recurse}

								    try {
								                    Invoke-Command -ComputerName $uut -ScriptBlock {
										                        if (Test-Path $DrvPath+"\\"+$DrvInf -eq $true) {
													                        $IP = $PrtIp
																                        $Driver = $DrvName
																			                        $Description = "$DrvName (autoinstall)"
																						                #Install Printer Driver
																								                        $driverclass = [WMIClass]"Win32_PrinterDriver"
																											                        $driverobj = $driverclass.createinstance()
																														                                $driverobj.Name="$Driver"
																																		                                $uutPath = "c:\\"+$DrvPath.split("\\")[4]+"\\"
																																						                                $driverobj.DriverPath = $uutPath
																																										                                # "C:\Driver File"
																																														                                $driverobj.Infname = $uutPath+$DrvInf
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
																																																																																																																					                        else {
																																																																																																																								                                Write-Output "File Does not exsist on $env:computername"}
																																																																																																																												                                }
																																																																																																																																        Catch {
																																																																																																																																	                write-host "Whoops!"
																																																																																																																																			        }
																																																																																																																																				}
=======
$comp = "hv2"
$DrvFrmPath="z://Drivers//HP Color LaserJet Pro M454dn//HP_CLJM453-M454_V4//"
$DrvInf="hpshC42A4_x64.inf"
$DrvCat="hpshC42A4_x64.cat"
$NetDrvName="HP Color Laserjet Pro M454dn -MI3094"
$PrtIp="134.154.240.7"
foreach ($uut in $comp) {Copy-Item -Path $DrvFrmPath -Destination "\\$uut\c$\" -Recurse}

try {
    $DrvToPath = 'C:\\'+(Split-Path $DrvFrmPath -Leaf)
    if ((Test-Path ($DrvToPath+'\\'+$DrvInf) -eq $true) {
        $IP = $PrtIp
        $Driver = ($DrvInf.split('.')[0])
        $Description = $NetDrvName

        # Install Printer Driver
        $driverclass = [WMIClass]"Win32_PrinterDriver"
        $driverobj = $driverclass.createinstance()
        $driverobj.Name="$Driver"
        $driverobj.DriverPath = $DrvCat
        $driverobj.Infname = $DrvToPath+'\\'+$DrvInf
        $newdriver = $driverclass.AddPrinterDriver($driverobj)
        $newdriver = $driverclass.Put()

        # Install Printer Port
        $Port = ([wmiclass]"win32_tcpipprinterport").createinstance()
        $Port.Name = "$IP"
        $Port.HostAddress = "$IP"
        $Port.Protocol = "1"
        $Port.PortNumber = "9100"
        $Port.SNMPEnabled = $true
        $Port.Description = "$IP"
        $Port.Put()

        # Install Printer
        $Printer = ([wmiclass]"win32_Printer").createinstance()
        $Printer.Name = "$Description"
        $Printer.DriverName = "$Driver"
        $Printer.DeviceID = "$Description"
        $Printer.Shared = $false
        $Printer.PortName = "$IP"
        $Port.Description = "$IP"
        $Printer.Put()
        }
    else {
        Write-Output "File Does not exsist on $env:computername"} 
	}
} Catch {
    write-error "Install-error"
    write-error $_
}
>>>>>>> 25e9759f2f969543fd15c321795fb56785428c8e
