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
