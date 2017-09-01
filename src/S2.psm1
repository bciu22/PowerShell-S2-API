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
        $S2HOSTNAME,
        [String]
        $S2PROTOCOL = "https://"
    )
    Set-Variable -Scope Global -Name "S2HOSTNAME" -Value $S2HOSTNAME
    Set-Variable -Scope Global -Name "S2PROTOCOL" -Value $S2PROTOCOL

    [xml]$xml = New-Object System.Xml.XmlDocument
    $wrapper = $xml.AppendChild($xml.CreateElement("NETBOX-API"))
    $command = $wrapper.AppendChild($xml.CreateElement("COMMAND"))
    $Command.SetAttribute("name","Login")
    $Command.SetAttribute("num","1")
    $Command.SetAttribute("dateformat","tzoffset")
    $Parameters=$Command.AppendChild($xml.CreateElement("PARAMS"))
    $UsernameXML = $xml.CreateElement("USERNAME")
    $UsernameXML.innerText = $Username
    $PasswordXML = $xml.CreateElement("PASSWORD")
    $PasswordXML.InnerText = $Password
    $Parameters.AppendChild($UsernameXML) | Out-Null
    $Parameters.AppendChild($PasswordXML) | Out-Null

    $Response = Invoke-WebRequest -URI "$($S2PROTOCOL)$($S2HOSTNAME)/goforms/nbapi" -Method Post -Body $($xml.innerXML)
    $ReturnXML = $([xml]$Response.content)

    if ($ReturnXML.NETBOX.RESPONSE.APIERROR)
    {
        throw "Unable to connect to NETBOX-API.  Error code: $($ReturnXML.NETBOX.RESPONSE.APIERROR)"
    }
    else
    {
        Set-Variable -Scope Global -Name "NETBOXSessionID" -Value $($ReturnXML.NETBOX.sessionid)
    }
    

}

function Disconnect-S2Service {
    $xml = "<NETBOX-API sessionid=`"$NETBOXSessionID`"><COMMAND name=`"Logout`" num=`"1`" dateformat=`"tzoffset`"></COMMAND></NETBOX-API>"
    Invoke-WebRequest -URI "$($S2PROTOCOL)$($S2HOSTNAME)/goforms/nbapi" -Method Post -Body $xml
}


Function Search-S2Person {
    Param(
        $PersonID,
        $UDF1,
        $UDF2,
        $UDF3
    )
    if ($PersonID)
    {
        $params="<PERSONID>$PersonID</PERSONID>"
    }
    elseif ($UDF1)
    {
        $params="<UDF1>$UDF1</UDF1>"
    }
    elseif($UDF2)
    {
        $params="<UDF2>$UDF2</UDF2>"
    }
    elseif($UDF3)
    {
        $params="<UDF3>$UDF3</UDF3>"
    }
    

    $xml = "<NETBOX-API sessionid=`"$NETBOXSessionID`"><COMMAND name=`"SearchPersonData`" num=`"1`" dateformat=`"tzoffset`"><PARAMS>$Params</PARAMS></COMMAND></NETBOX-API>"
    $([XML]$(Invoke-WebRequest -URI "$($S2PROTOCOL)$($S2HOSTNAME)/goforms/nbapi" -Method Post -Body $xml).content).NETBOX.RESPONSE.DETAILS.PEOPLE.PERSON

}

function Get-S2Person {
    Param(
        $PersonID
    )
    $xml = "<NETBOX-API sessionid=`"$NETBOXSessionID`"><COMMAND name=`"GetPerson`" num=`"1`" dateformat=`"tzoffset`"><PARAMS><PERSONID>$PersonID</PERSONID></PARAMS></COMMAND></NETBOX-API>"
    $([XML]$(Invoke-WebRequest -URI "$($S2PROTOCOL)$($S2HOSTNAME)/goforms/nbapi" -Method Post -Body $xml).content).NETBOX.RESPONSE.DETAILS

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
    $cookie.Domain = $S2HOSTNAME
    $session.Cookies.Add($cookie);

    $S2URL = "$($S2PROTOCOL)$($S2HOSTNAME)/upload/pics/$($Person.PICTUREURL)"
    $Photo = Invoke-WebRequest -URI $S2URL -Method GET -WebSession $session
    if ($OutFile)
    {
        [System.IO.File]::WriteAllBytes($OutFile,$Photo.content)
    }
    else {
        $Photo.content
    }
}