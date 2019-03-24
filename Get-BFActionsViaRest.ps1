# function Get-BFActionsViaRest {
[CmdletBinding()]
param(
    [Alias('rawoutput')]
    [bool] $bRaw = $false,
    [Alias('servername')]
    [string]$server = "adhaytem0a.ad.csueastbay.edu"
)
#
# Author: John Singer, bigfix specialist; IBM,All-Things-Endpoint CSUEB
# Created: 1.15.15
# Assumes: Powershell environment, 2.0 or greater, servername, username, password
# (depending on whether you use line 40 or 41), below.
#          server installed on port 52311.  For the purposes of this demo, the user is a master-
#          operator. Also, note that we must have set the Execution-Policy to Unrestricted or RemoteSigned.
# WhatItDoes: gets all the operators actions
# Copyright: This source-code is freely usable, as long as you mention somewhere in your 
#          source-code that it was based on my example. Thanks, jps.
 
<#
.SYNOPSIS
Get-BFActionsViaRest retrieves the XML returned from a ReST query to the BF server
.PARAMETER braw
Whether the 'dump' is done via raw XML or 'parsed' into fields
.PARAMETER server
the FQDN of the BF server
.EXAMPLE
Get-VFActionViaRest  | select Id,Name | Format-Table -auto
#>
Write-Warning "----->>>>> Starting Get-BFActionsViaRest.ps1" 
 
# Simplify things by ignoring certificate-validation
#
add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

# Create variables to store the values consumed by the Invoke-WebRequest command.
#
if ($server.Length -le 0) {
    # Load the Visual Basic input-Widgets
    [void] [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') 

    $server = [Microsoft.VisualBasic.Interaction]::InputBox('(Full path to) ServerName ', 'Target Server Name', '<servername>') 
}
$urlbase = "https://${server}:52311/api/"
$url = $urlbase + "login"
 
$cred = (Get-Credential).GetNetworkCredential()
$EncodedAuthorization = [System.Text.Encoding]::UTF8.GetBytes($cred.username + ':' + $cred.password)
$EncodedPassword = [System.Convert]::ToBase64String($EncodedAuthorization)
$headers = @{"Authorization"="Basic $($EncodedPassword)"}
 
$result = Invoke-RestMethod -Uri $url -Method GET -Headers $headers
 
Write-Warning "----->>>>> Rest call to $($url) was $($result)"
 
# Having 'logged in', go request all the actions for the current operator.
#
if ($result -eq 'ok') {
    $url = $urlbase + "actions"
 
# The next line uses the Invoke-WebRequest cmdlet from v2.0;  The result 
#     comes back as a string.
    $r2 = Invoke-WebRequest -Uri $url -Method GET -Headers $headers
 
    if ($r2.StatusCode -ne 200) {
        Write-Warning "Error on action-request: $($r2.status)" }
    }
    [xml] $x = $r2.Content
    # $names = $x.SelectNodes("//Name")

    # Based on command-line, either output the actions, or the raw-xml
    if (-not $bRaw) {
        write-output $x.BESAPI.Action
    } else {
        Write-Warning "Outputting Raw 'InnerXML'"
        write-output $x.InnerXml
    }
# } Get-BFActionsViaRest