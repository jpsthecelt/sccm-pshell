[CmdletBinding()]
param(
    [Alias('rawoutput')]
    [bool] $bRaw = $false,
    [bool] $bJSON = $false,
    [string]$relevance = "names of bes computers"
)

<#
.SYNOPSIS
Get-BFRestData retrieves the XML returned from a ReST query to the BF server
.PARAMETER bRaw
Whether the 'dump' is done via raw XML or 'parsed' into fields
.PARAMETER bJSON
Whether the 'RAW dump' should be in JSON vs. XML
.PARAMETER relevance
the BigFix 'relevance' language string with with to query
.EXAMPLE
Get-BFRestData  
#>
# BEGIN {}
# PROCESS{
# Write-Warning "----->>>>> Starting Get-BFRestData.ps1" 
 
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
$server = "https://<your-bigfix-server:52311>"

Try {
    # Create variables to store the values consumed by the Invoke-WebRequest command.
    #
    [void] [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') 

    #  So, if a configuration-file exists in the parent folder, read that server/username/password info...
    #      (& add 'base-level' cred.username and cred.password members so we can 'stuff' them into our credentials, below)
    if (Test-Path ../credentials.json) {
        $cred = $(get-content ../credentials.json | ConvertFrom-JSON | select-object credentials)
        $server = $cred.credentials.server
        Add-Member -InputObject $cred -MemberType NoteProperty -Name username -Value $cred.credentials.username
        Add-Member -InputObject $cred -MemberType NoteProperty -Name password -Value $cred.credentials.password
    } else {
        # Load the Visual Basic input-Widgets
        [void] [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') 

        $server = [Microsoft.VisualBasic.Interaction]::InputBox('(AD path to) ServerName ', 'Target Server Name', '<servername>') 
        $cred = (Get-Credential).GetNetworkCredential()
    }

    # Creating variables to store the values consumed by the Invoke-WebRequest command...
    #   Get relevance....
    if ($relevance.length -le 0) {
        $relevance = [Microsoft.VisualBasic.Interaction]::InputBox('Relevance with which to query', 'Relevance', '<relevance>') 
    }
    $urlbase = "https://${server}:52311/api/"
    $url = $urlbase + "login"
    
    $EncodedAuthorization = [System.Text.Encoding]::UTF8.GetBytes($cred.username + ':' + $cred.password)
    $EncodedPassword = [System.Convert]::ToBase64String($EncodedAuthorization)
    $headers = @{"Authorization"="Basic $($EncodedPassword)"}
    
    # 'log into' the system to test-out the credentials
    $result = Invoke-WebRequest -Uri $url -Method GET -Headers $headers
    
    # Write-Warning "----->>>>> Rest call to $($url) returned $($result.StatusDescription)"
    Write-Warning "login returned $($result.StatusDescription)"
    
    # Having 'logged in', go the relevance-data, raw-xml/json, or otherwise... 
    #
    if ($result.Content -ne 'ok') {
        Write-Warning "uh-oh; cant login; go figure out your credentials/access..."
        exit
    } else {
        $urlbase += 'query?'
        if ($bJSON) {
            $urlbase += "output=json&"
        }
        $url = [uri]::EscapeUriString($urlbase + 'relevance='+$relevance)
    }
    
    # Having 'logged in', go request the information specified in the relevance
    #
    # The next line uses the Invoke-RestMethod routine, the results of which
    #     comes back as an XML document or a JSON structure. We specify an error-variable with which to check success 
        $r2 = Invoke-RestMethod -Uri $url -Method GET -Headers $headers -ErrorVariable RestError -ErrorAction SilentlyContinue
    
        if ($RestError) {
            $HttpStatusCode = $RestError.ErrorRecord.Exception.Response.StatusCode.value__
            Write-Warning "ErrorCode = ($HttpStatusCode)"
            $HttpStatusDescription = $RestError.ErrorRecord.Exception.Response.StatusDescription
            Write-Warning "Error Description = ($HttpStatusDescription)"
            exit
        } 
        # Invoke-RestMethod automatically tries to format returned XML into an XML-document, so the following commented-out
        # code is only needed if we use invoke-webrequest:
        #
        # if ($r2.StatusCode -ne 200) {
        #     Write-Warning "Error on action-request: $($r2.status)" 
        # }
        # write-warning "Read ($r2.RawContentLength) bytes"
        # [xml] $x = $r2.Content
        # $names = $x.SelectNodes("//Name")

        # Based on command-line, output the answer, the raw-xml, or the JSON
        if (-not $bRaw) {
            write-output $r2.BESAPI.Query.Result.Answer
        } else {
            if ($bJSON) {
                write-output $r2.result
            } else {
                write-output $r2.OuterXml
            }
        }
} Catch {
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    if ($FailedItem.Length -le 0) {
        $FailedItem = "ERROR - "
    }
	Write-Error "Failed: $FailedItem. Error message was: $ErrorMessage"
    Break
}
# }
# END{}