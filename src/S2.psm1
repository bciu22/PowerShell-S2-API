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
    Invoke-WebRequest -URI "$($S2PROTOCOL)$($S2HOSTNAME)/goforms/nbapi" -Method Post -Body $xml | Out-Null
}


Function Search-S2Person {
    Param(
        $LastName,
        $MiddleName,
        $FirstName,
        $PersonID,
        $UDF1,
        $UDF2,
        $UDF3
    )

    [xml]$xml = New-Object System.Xml.XmlDocument
    $wrapper = $xml.AppendChild($xml.CreateElement("NETBOX-API"))
    $wrapper.SetAttribute("sessionid",$NETBOXSessionID)
    $command = $wrapper.AppendChild($xml.CreateElement("COMMAND"))
    $Command.SetAttribute("name","SearchPersonData")
    $Command.SetAttribute("num","1")
    $Command.SetAttribute("dateformat","tzoffset")
    $Parameters=$Command.AppendChild($xml.CreateElement("PARAMS"))

    if ($LastName)
    {
        $param = $xml.CreateElement("LASTNAME")
        $param.innerText = $LastName
        $Parameters.AppendChild($Param) | Out-Null
    }
    if($MiddleName)
    {
        $param = $xml.CreateElement("MIDDLENAME")
        $param.innerText = $MiddleName
        $Parameters.AppendChild($Param) | Out-Null
    }
    if ($FirstName)
    {
        $param = $xml.CreateElement("FIRSTNAME")
        $param.innerText = $FirstName
        $Parameters.AppendChild($Param) | Out-Null
    }
    if ($PersonID)
    {
        $param = $xml.CreateElement("PERSONID")
        $param.innerText = $PersonID
        $Parameters.AppendChild($Param) | Out-Null
    }
    if ($UDF1)
    {
        $param = $xml.CreateElement("UDF1")
        $param.innerText = $UDF1
        $Parameters.AppendChild($Param) | Out-Null
    }
    if($UDF2)
    {
        $param = $xml.CreateElement("UDF2")
        $param.innerText = $UDF2
        $Parameters.AppendChild($Param) | Out-Null
    }
    if($UDF3)
    {
        $param = $xml.CreateElement("UDF3")
        $param.innerText = $UDF3
        $Parameters.AppendChild($Param) | Out-Null
    }

    $param = $xml.CreateElement("CASEINSENSITIVE")
    $param.innerText = "TRUE"
    $Parameters.AppendChild($Param) | Out-Null

    $param = $xml.CreateElement("WILDCARDSEARCH")
    $param.innerText = "TRUE"
    $Parameters.AppendChild($Param) | Out-Null

    $([XML]$(Invoke-WebRequest -URI "$($S2PROTOCOL)$($S2HOSTNAME)/goforms/nbapi" -Method Post -Body $xml.innerXML).content).NETBOX.RESPONSE.DETAILS.PEOPLE.PERSON

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
        $OutFile,
        [Switch]
        $Display
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

    if ($Display)
    {
        $Stream =[System.IO.MemoryStream]::new($Photo.content)
        $img = [System.Drawing.Image]::FromStream($Stream)
        Add-Type -AssemblyName System.Windows.Forms
        $win = New-Object Windows.Forms.Form
        $box = New-Object Windows.Forms.PictureBox
        $box.Width = $img.Width
        $box.Height = $img.Height
        $box.Image = $img
        $win.Controls.Add($box)
        $win.AutoSize = $true
        $win.ShowDialog()
    }
    elseif ($OutFile)
    {
        [System.IO.File]::WriteAllBytes($OutFile,$Photo.content)
    }
    else {
        $Photo.content
    }
}