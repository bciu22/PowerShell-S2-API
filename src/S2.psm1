<#
    .SYNOPSIS

#>


function Connect-S2Service {
    <#

    .PARAMETER Username

    .PARAMETER Password

    #>
    param (
        [parameter(Mandatory=$true)]
        [String]
        $Username,
        [parameter(Mandatory=$true)]
        [String]
        $Password,
        [parameter(Mandatory=$true)]
        [String]
        $S2URL
    )
    Set-Variable -Scope Global -Name "S2NETBOXURL" -Value $S2URL

    $xml = "<NETBOX-API><COMMAND name=`"Login`" num=`"1`" dateformat=`"tzoffset`"><PARAMS><USERNAME>$Username</USERNAME><PASSWORD>$Password</PASSWORD></PARAMS></COMMAND></NETBOX-API>"
    $Response = Invoke-WebRequest -URI "$S2NETBOXURL/goforms/nbapi" -Method Post -Body $xml

    Set-Variable -Scope Global -Name "NETBOXSessionID" -Value $($([xml]$Response.content).NETBOX.sessionid)

}

function Disconnect-S2Service {
    $xml = "<NETBOX-API sessionid=`"$NETBOXSessionID`"><COMMAND name=`"Logout`" num=`"1`" dateformat=`"tzoffset`"></COMMAND></NETBOX-API>"
    Invoke-WebRequest -URI "$S2NETBOXURL/goforms/nbapi" -Method Post -Body $xml
}

function Get-S2Person {
    Param(
        $PersonID
    )
    $xml = "<NETBOX-API sessionid=`"$NETBOXSessionID`"><COMMAND name=`"GetPerson`" num=`"1`" dateformat=`"tzoffset`"><PARAMS><PERSONID>$PersonID</PERSONID></PARAMS></COMMAND></NETBOX-API>"
    $([XML]$(Invoke-WebRequest -URI "$S2NETBOXURL/goforms/nbapi" -Method Post -Body $xml).content).NETBOX.RESPONSE.DETAILS

}

function Get-S2PersonPhoto {
    Param(
        $PersonID,
        $OutFile
    )
    $Person = Get-S2Person -PersonID $PersonID

    $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $cookie = New-Object System.Net.Cookie 
    $cookie.Name = ".sessionId"
    $cookie.Value = $NETBOXSessionID
    $cookie.Domain = $S2NETBOXURL
    $session.Cookies.Add($cookie);

    $S2URL = "$S2NETBOXURL/upload/pics/$($Person.PICTUREURL)"
    $Photo = Invoke-WebRequest -URI $S2URL -Method GET -WebSession $session
    if ($OutFile)
    {
        [System.IO.File]::WriteAllBytes($OutFile,$Photo.content)
    }
    else {
        $Photo.content
    }
}