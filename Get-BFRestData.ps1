[CmdletBinding()]
param(
    [Alias('rawoutput')]
    [bool] $bRaw = $false,
    [Alias('servername')]
    [string]$server = "adhaytem0a.ad.csueastbay.edu",
    [string]$relevance = "names of bes computers"
)

<#
.SYNOPSIS
Get-BFRestData retrieves the XML returned from a ReST query to the BF server
.PARAMETER braw
Whether the 'dump' is done via raw XML or 'parsed' into fields
.PARAMETER server
the FQDN of the BF server
.PARAMETER relevance
the BigFix 'relevance' language string with with to query
.EXAMPLE
Get-BFRestData  
#>
Write-Warning "----->>>>> Starting Get-BFRestData.ps1" 
 
# Simplify things by ignoring certificate-validation
#
Write-Warning "----->>>>> Starting Get-BFRestData.ps1" 
 
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
[void] [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') 

if ($server.Length -le 0) {
    # Load the Visual Basic input-Widgets
    [void] [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') 

    $server = [Microsoft.VisualBasic.Interaction]::InputBox('(Full path to) ServerName ', 'Target Server Name', '<servername>') 
}

# Create variables to store the values consumed by the Invoke-WebRequest command.

# Get relevance/xpath/server/username/password:
if ($relevance.length -le 0) {
    $relevance = [Microsoft.VisualBasic.Interaction]::InputBox('Relevance with which to query', 'Relevance', '<relevance>') 
    # $xpath = [Microsoft.VisualBasic.Interaction]::InputBox('Xpath to extract ', 'XPath', '<xpath-expression like //Name>') 
    # $server = [Microsoft.VisualBasic.Interaction]::InputBox('(Full path to) ServerName ', 'Target Server Name', '<servername>') 
}
$urlbase = "https://${server}:52311/api/"
$url = $urlbase + "login"
 
$cred = (Get-Credential).GetNetworkCredential()
$EncodedAuthorization = [System.Text.Encoding]::UTF8.GetBytes($cred.username + ':' + $cred.password)
$EncodedPassword = [System.Convert]::ToBase64String($EncodedAuthorization)
$headers = @{"Authorization"="Basic $($EncodedPassword)"}
 
# 'log into' the system to test-out the credentials
$result = Invoke-WebRequest -Uri $url -Method GET -Headers $headers
 
Write-Warning "----->>>>> Rest call to $($url) returned $($result.StatusDescription)"
 
# Having 'logged in', go request all the actions for the current operator.
#
if ($result.Content -ne 'ok') {
    Write-Warning "uh-oh; cant login; go figure out your credentials/access..."
    exit
} else {
   $url = [uri]::EscapeUriString($urlbase + 'query?relevance='+$relevance)
}
 
# Having 'logged in', go request the information specified in the relevance
#
# The next line uses the Invoke-RestMethod routine, the results of which
#     comes back as an XML document or a JSON structure. We specify a 
    $r2 = Invoke-RestMethod -Uri $url -Method GET -Headers $headers -ErrorVariable RestError -ErrorAction SilentlyContinue
 
    if ($RestError) {
        $HttpStatusCode = $RestError.ErrorRecord.Exception.Response.StatusCode.value__
        Write-Warning "ErrorCode = ($HttpStatusCode)"
        $HttpStatusDescription = $RestError.ErrorRecord.Exception.Response.StatusDescription
        Write-Warning "Error Description = ($HttpStatusDescription)"
        exit
    } 
    # if ($r2.StatusCode -ne 200) {
    #     Write-Warning "Error on action-request: $($r2.status)" 
    # }
    # write-warning "Read ($r2.RawContentLength) bytes"
    # [xml] $x = $r2.Content
    # $names = $x.SelectNodes("//Name")

    # Based on command-line, either output the actions, or the raw-xml
    if (-not $bRaw) {
        write-output $r2.OuterXml.BESAPI.Query.Result.Answer
    } else {
        Write-Warning "Outputting Raw 'OuterXML'"
        write-output $r2.OuterXml
    }
# The next line uses the Invoke-RestMethod cmdlet from v3.0;  
#     If you use this call, the result comes back as a parsed XMl-structure.
#    $r2 = Invoke-RestMethod -Uri $url -Method GET -Headers $headers
# 
#    if ($r2.StatusCode -ne 200) {
#        Write-Warning "Error on action-request: $($r2.status)" }
#        exit
#    }
#    [xml] $x = $r2.Content
#    $out_object = $x.SelectNodes($xpath)
#    write-output $out_object
# } Get-BFRestData
