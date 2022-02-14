﻿#The sample scripts are not supported under any Microsoft standard support 
#program or service. The sample scripts are provided AS IS without warranty  
#of any kind. Microsoft further disclaims all implied warranties including,  
#without limitation, any implied warranties of merchantability or of fitness for 
#a particular purpose. The entire risk arising out of the use or performance of  
#the sample scripts and documentation remains with you. In no event shall 
#Microsoft, its authors, or anyone else involved in the creation, production, or 
#delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, 
#loss of business information, or other pecuniary loss) arising out of the use 
#of or inability to use the sample scripts or documentation, even if Microsoft 
#has been advised of the possibility of such damages 
#--------------------------------------------------------------------------------- 

#requires -version 2.0

<#
 	.SYNOPSIS
        The PowerShell script which can be used to change the system regional settings.
    .DESCRIPTION
        The PowerShell script which can be used to change the system regional settings.
    .PARAMETER  Time
		Spcifies a time to export the specified data.
    .PARAMETER  CSVFilePath
		Spcifies path to export the csv file.
    .EXAMPLE
        C:\PS> C:\Script\ExportIEHistory.ps1 -Time "2WeeksAgo" -CSVFilePath C:\History\
        
        Successfully exported history of Internext Explorer.

        This command exports the history of Internet Explorer 2 weeks ago.
#>
[CmdletBinding()]
Param
(
    [Parameter(Mandatory=$false)]
    [ValidateSet("3WeeksAgo","2WeeksAgo", "LastWeek", "Today")]
    [String]$Time = "Today",
    [Parameter(Mandatory=$true)]
    [String]$CSVFilePath
)

$Shell = New-Object -ComObject Shell.Application
$IEHistory = $Shell.NameSpace(34)
  
Switch($Time)
{
    '3WeeksAgo'
    {
        $TimeLine = '3 Weeks Ago'
        break
    }
    '2WeeksAgo'
    {
        $TimeLine = '2 Weeks Ago'
        break
    }
    'LastWeek'
    {
        $TimeLine = 'Last Week'
        break
    }
    'Today'
    {
        $TimeLine = 'Today'
        break
    }
}

$Objs = @()
$Items = $IEHistory.Items()
Foreach($Item in $Items)
{
    If($Item.IsFolder -and $Item.Name -eq $TimeLine)
    {
        $WebSiteItems = $Item.GetFolder.Items()
        Foreach($WebSiteItem in $WebSiteItems)
        {
            If($WebSiteItem.IsFolder)
            {
                $SiteFolder = $WebSiteItem.GetFolder
                $SiteFolder.Items()|Foreach{$WebSite = $WebSiteItem.Name
                                            $URL = $($SiteFolder.GetDetailsOf($_,0))
                                            $Date = $($SiteFolder.GetDetailsOf($_,2))

                $Obj = New-Object -TypeName PSObject -Property @{WebSite = $WebSite
                                                                URL = $URL
                                                                Date = $Date}
                $Objs += $Obj}
            }
        }
    }
}

If($CSVFilePath)
{
    If(Test-Path -Path $CSVFilePath)
    {
        $Objs | Export-Csv -Path "$CSVFilePath\IEHistory.csv" -NoTypeInformation
        Write-Host "Successfully exported history of Internext Explorer."
    }
    Else
    {
        Write-Host "The path does not exist, please ensure that you entered a correct path."
    }
}