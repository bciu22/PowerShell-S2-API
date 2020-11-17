<#
 .Synopsis
  Establishes a connection to the S2 NETBOX API.

 .Description
  Establishes a connection to the S2 NETBOX API for querying and modifying data.

 .Parameter Username
  Valid username of an S2 Account

 .Parameter Password
  Corresponding password to specified username

 .Parameter S2Hostname
  The network location to the S2 Netbox API server.

 .Parameter S2Protocol
  Specifiy what http protocal to use.  By default it uses http.

 .Link
  Forked from bciu22/PowerShell-S2-API
  https://github.com/bciu22/PowerShell-S2-API/blob/master/src/S2.psm1
#>
Function Connect-S2Service {
    <#
    .PARAMETER Username
    .PARAMETER Password
    #>
    param (
        [parameter(Mandatory=$true)][String] $Username,
        [parameter(Mandatory=$true)][String] $Password,
        [parameter(Mandatory=$true)][String] $S2Hostname,
        [String] $S2Protocol = "http://"
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

    if($ReturnXML.NETBOX.RESPONSE.APIERROR)
    {
        throw "Unable to connect to NETBOX-API.  Error code: $($ReturnXML.NETBOX.RESPONSE.APIERROR)"
    }
    else
    {
        Set-Variable -Scope Global -Name "NETBOXSessionID" -Value $($ReturnXML.NETBOX.sessionid)
    }
}

Function Disconnect-S2Service {
    $xml = "<NETBOX-API sessionid=`"$NETBOXSessionID`"><COMMAND name=`"Logout`" num=`"1`" dateformat=`"tzoffset`"></COMMAND></NETBOX-API>"
    Invoke-WebRequest -URI "$($S2PROTOCOL)$($S2HOSTNAME)/goforms/nbapi" -Method Post -Body $xml | Out-Null
}

Function Search-S2Person {
    param(
        [String] $LastName,
        [String] $MiddleName,
        [String] $FirstName,
        [String] $PersonID,
        [String] $UDF1,
        [String] $UDF2,
        [String] $UDF3
    )

    [xml]$xml = New-Object System.Xml.XmlDocument
    $wrapper = $xml.AppendChild($xml.CreateElement("NETBOX-API"))
    $wrapper.SetAttribute("sessionid",$NETBOXSessionID)
    $command = $wrapper.AppendChild($xml.CreateElement("COMMAND"))
    $Command.SetAttribute("name","SearchPersonData")
    $Command.SetAttribute("num","1")
    $Command.SetAttribute("dateformat","tzoffset")
    $Parameters=$Command.AppendChild($xml.CreateElement("PARAMS"))

    if($LastName)
    {
        $param = $xml.CreateElement("LASTNAME")
        $param.innerText = $LastName
        $Parameters.AppendChild($param) | Out-Null
    }
    if($MiddleName)
    {
        $param = $xml.CreateElement("MIDDLENAME")
        $param.innerText = $MiddleName
        $Parameters.AppendChild($param) | Out-Null
    }
    if($FirstName)
    {
        $param = $xml.CreateElement("FIRSTNAME")
        $param.innerText = $FirstName
        $Parameters.AppendChild($param) | Out-Null
    }
    if($PersonID)
    {
        $param = $xml.CreateElement("PERSONID")
        $param.innerText = $PersonID
        $Parameters.AppendChild($param) | Out-Null
    }
    if($UDF1)
    {
        $param = $xml.CreateElement("UDF1")
        $param.innerText = $UDF1
        $Parameters.AppendChild($param) | Out-Null
    }
    if($UDF2)
    {
        $param = $xml.CreateElement("UDF2")
        $param.innerText = $UDF2
        $Parameters.AppendChild($param) | Out-Null
    }
    if($UDF3)
    {
        $param = $xml.CreateElement("UDF3")
        $param.innerText = $UDF3
        $Parameters.AppendChild($param) | Out-Null
    }

    $param = $xml.CreateElement("CASEINSENSITIVE")
    $param.innerText = "TRUE"
    $Parameters.AppendChild($param) | Out-Null

    $param = $xml.CreateElement("WILDCARDSEARCH")
    $param.innerText = "TRUE"
    $Parameters.AppendChild($param) | Out-Null

    $([XML]$(Invoke-WebRequest -URI "$($S2PROTOCOL)$($S2HOSTNAME)/goforms/nbapi" -Method Post -Body $xml.innerXML).content).NETBOX.RESPONSE.DETAILS.PEOPLE.PERSON
}

Function Get-S2Person {
    param(
        $PersonID
    )
    $xml = "<NETBOX-API sessionid=`"$NETBOXSessionID`"><COMMAND name=`"GetPerson`" num=`"1`" dateformat=`"tzoffset`"><PARAMS><PERSONID>$PersonID</PERSONID></PARAMS></COMMAND></NETBOX-API>"
    $([XML]$(Invoke-WebRequest -URI "$($S2PROTOCOL)$($S2HOSTNAME)/goforms/nbapi" -Method Post -Body $xml).content).NETBOX.RESPONSE.DETAILS
}

Function Get-S2AccessLevels {
    $xml = "<NETBOX-API sessionid=`"$NETBOXSessionID`"><COMMAND name=`"GetAccessLevels`" num=`"1`"></COMMAND></NETBOX-API>"
    $([XML]$(Invoke-WebRequest -URI "$($S2PROTOCOL)$($S2HOSTNAME)/goforms/nbapi" -Method Post -Body $xml).content).NETBOX.RESPONSE.DETAILS.ACCESSLEVELS.ACCESSLEVEL
}

Function Get-S2CardFormats {
    $xml = "<NETBOX-API sessionid=`"$NETBOXSessionID`"><COMMAND name=`"GetCardFormats`" num=`"1`"></COMMAND></NETBOX-API>"
    $([XML]$(Invoke-WebRequest -URI "$($S2PROTOCOL)$($S2HOSTNAME)/goforms/nbapi" -Method Post -Body $xml).content).NETBOX.RESPONSE.DETAILS.CARDFORMATS.CARDFORMAT
}

Function Get-S2PersonPhoto {
    param(
        $PersonID,
        $OutFile,
        [Switch]$Display
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

    if($Display)
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
    elseif($OutFile)
    {
        [System.IO.File]::WriteAllBytes($OutFile,$Photo.content)
    }
    else {
        $Photo.content
    }
}

Function New-S2Person {
    param(
        [String] $PersonID,
        [parameter(Mandatory=$true)][String] $FirstName,
        [parameter(Mandatory=$true)][String] $LastName,
        [String] $MiddleName,
        [String[]] $AccessLevels,
        [String] $UDF1,
        [String] $UDF2,
        [String] $UDF3,
        [String] $UDF4,
        [String] $UDF5,
        [String] $UDF6,
        [String] $UDF7,
        [String] $UDF8,
        [String] $UDF9
    )

    [xml]$xml = New-Object System.Xml.XmlDocument
    $wrapper = $xml.AppendChild($xml.CreateElement("NETBOX-API"))
    $wrapper.SetAttribute("sessionid",$NETBOXSessionID)
    $command = $wrapper.AppendChild($xml.CreateElement("COMMAND"))
    $Command.SetAttribute("name","AddPerson")
    $Command.SetAttribute("num","1")
    $Parameters=$Command.AppendChild($xml.CreateElement("PARAMS"))
    if($PersonID)
    {
        $param = $xml.CreateElement("PERSONID")
        $param.innerText = $PersonID
        $Parameters.AppendChild($param) | Out-Null
    }
    $param = $xml.CreateElement("FIRSTNAME")
    $param.innerText = $FirstName
    $Parameters.AppendChild($param) | Out-Null
    $param = $xml.CreateElement("LASTNAME")
    $param.innerText = $LastName
    $Parameters.AppendChild($param) | Out-Null
    if($MiddleName)
    {
        $param = $xml.CreateElement("MIDDLENAME")
        $param.innerText = $MiddleName
        $Parameters.AppendChild($param) | Out-Null
    }
    if($ACCESSLEVELS)
    {
        $param = $xml.CreateElement("ACCESSLEVELS")
        foreach($ACCESSLEVEL in $ACCESSLEVELS) {
            $ParamAccessLevel = $xml.CreateElement('ACCESSLEVEL')
            $ParamAccessLevel.innerText = $AccessLevels
            $param.AppendChild($ParamAccessLevel) | Out-Null
        }
        $Parameters.AppendChild($param) | Out-Null
    }
    if($UDF1)
    {
        $param = $xml.CreateElement("UDF1")
        $param.innerText = $UDF1
        $Parameters.AppendChild($param) | Out-Null
    }
    if($UDF2)
    {
        $param = $xml.CreateElement("UDF2")
        $param.innerText = $UDF2
        $Parameters.AppendChild($param) | Out-Null
    }
    if($UDF3)
    {
        $param = $xml.CreateElement("UDF3")
        $param.innerText = $UDF3
        $Parameters.AppendChild($param) | Out-Null
    }
    if($UDF3)
    {
        $param = $xml.CreateElement("UDF4")
        $param.innerText = $UDF4
        $Parameters.AppendChild($param) | Out-Null
    }
    if($UDF3)
    {
        $param = $xml.CreateElement("UDF5")
        $param.innerText = $UDF5
        $Parameters.AppendChild($param) | Out-Null
    }
    if($UDF3)
    {
        $param = $xml.CreateElement("UDF6")
        $param.innerText = $UDF6
        $Parameters.AppendChild($param) | Out-Null
    }
    if($UDF3)
    {
        $param = $xml.CreateElement("UDF7")
        $param.innerText = $UDF7
        $Parameters.AppendChild($param) | Out-Null
    }
    if($UDF3)
    {
        $param = $xml.CreateElement("UDF8")
        $param.innerText = $UDF8
        $Parameters.AppendChild($param) | Out-Null
    }
    if($UDF3)
    {
        $param = $xml.CreateElement("UDF9")
        $param.innerText = $UDF9
        $Parameters.AppendChild($param) | Out-Null
    }
  
    $([XML]$(Invoke-WebRequest -URI "$($S2PROTOCOL)$($S2HOSTNAME)/goforms/nbapi" -Method Post -Body $xml).content).NETBOX.RESPONSE.DETAILS
}

Function Edit-S2Person {
    param(
        [parameter(Mandatory=$true)][String] $PersonID,
        [String] $FirstName,
        [String] $LastName,
        [String] $MiddleName,
        [String[]] $AccessLevels,
        [String] $UDF1,
        [String] $UDF2,
        [String] $UDF3,
        [String] $UDF4,
        [String] $UDF5,
        [String] $UDF6,
        [String] $UDF7,
        [String] $UDF8,
        [String] $UDF9
    )

    [xml]$xml = New-Object System.Xml.XmlDocument
    $wrapper = $xml.AppendChild($xml.CreateElement("NETBOX-API"))
    $wrapper.SetAttribute("sessionid",$NETBOXSessionID)
    $command = $wrapper.AppendChild($xml.CreateElement("COMMAND"))
    $Command.SetAttribute("name","ModifyPerson")
    $Command.SetAttribute("num","1")
    $Parameters=$Command.AppendChild($xml.CreateElement("PARAMS"))
    $param = $xml.CreateElement("PERSONID")
    $param.innerText = $PersonID
    $Parameters.AppendChild($param) | Out-Null
    if($FirstName)
    {
        $param = $xml.CreateElement("FIRSTNAME")
        $param.innerText = $FirstName
        $Parameters.AppendChild($param) | Out-Null
    }
    if($LastName)
    {
        $param = $xml.CreateElement("LASTNAME")
        $param.innerText = $LastName
        $Parameters.AppendChild($param) | Out-Null
    }
    if($MiddleName)
    {
        $param = $xml.CreateElement("MIDDLENAME")
        $param.innerText = $MiddleName
        $Parameters.AppendChild($param) | Out-Null
    }
    if($ACCESSLEVELS)
    {
        $param = $xml.CreateElement("ACCESSLEVELS")
        foreach($ACCESSLEVEL in $ACCESSLEVELS) {
            $ParamAccessLevel = $xml.CreateElement('ACCESSLEVEL')
            $ParamAccessLevel.innerText = $AccessLevel
            $param.AppendChild($ParamAccessLevel) | Out-Null
        }
        $Parameters.AppendChild($param) | Out-Null
    }
    if($UDF1)
    {
        $param = $xml.CreateElement("UDF1")
        $param.innerText = $UDF1
        $Parameters.AppendChild($param) | Out-Null
    }
    if($UDF2)
    {
        $param = $xml.CreateElement("UDF2")
        $param.innerText = $UDF2
        $Parameters.AppendChild($param) | Out-Null
    }
    if($UDF3)
    {
        $param = $xml.CreateElement("UDF3")
        $param.innerText = $UDF3
        $Parameters.AppendChild($param) | Out-Null
    }
    if($UDF4)
    {
        $param = $xml.CreateElement("UDF4")
        $param.innerText = $UDF4
        $Parameters.AppendChild($param) | Out-Null
    }
    if($UDF5)
    {
        $param = $xml.CreateElement("UDF5")
        $param.innerText = $UDF5
        $Parameters.AppendChild($param) | Out-Null
    }
    if($UDF6)
    {
        $param = $xml.CreateElement("UDF6")
        $param.innerText = $UDF6
        $Parameters.AppendChild($param) | Out-Null
    }
    if($UDF7)
    {
        $param = $xml.CreateElement("UDF7")
        $param.innerText = $UDF7
        $Parameters.AppendChild($param) | Out-Null
    }
    if($UDF8)
    {
        $param = $xml.CreateElement("UDF8")
        $param.innerText = $UDF8
        $Parameters.AppendChild($param) | Out-Null
    }
    if($UDF9)
    {
        $param = $xml.CreateElement("UDF9")
        $param.innerText = $UDF9
        $Parameters.AppendChild($param) | Out-Null
    }

    $([XML]$(Invoke-WebRequest -URI "$($S2PROTOCOL)$($S2HOSTNAME)/goforms/nbapi" -Method Post -Body $xml).content).NETBOX.RESPONSE.DETAILS
}

Function Remove-S2Person {
    param(
        [parameter(Mandatory=$true)][String] $PersonID
    )

    [xml]$xml = New-Object System.Xml.XmlDocument
    $wrapper = $xml.AppendChild($xml.CreateElement("NETBOX-API"))
    $wrapper.SetAttribute("sessionid",$NETBOXSessionID)
    $command = $wrapper.AppendChild($xml.CreateElement("COMMAND"))
    $Command.SetAttribute("name","RemovePerson")
    $Command.SetAttribute("num","1")
    $Parameters=$Command.AppendChild($xml.CreateElement("PARAMS"))
    $param = $xml.CreateElement("PERSONID")
    $param.innerText = $PersonID
    $Parameters.AppendChild($param) | Out-Null
    
    $Response = Invoke-WebRequest -URI "$($S2PROTOCOL)$($S2HOSTNAME)/goforms/nbapi" -Method Post -Body $xml
    $ReturnXML = $([xml]$Response.content)

    switch ($ReturnXML.NETBOX.RESPONSE.CODE) {
        "SUCCESS" { Return $true  }
        Default { 
            Write-Output $ReturnXML.NETBOX.RESPONSE.CODE
            Return $false 
        }
    }
}

Function Add-S2Credential {
    param(
        [parameter(Mandatory=$true)][String] $PersonID,
        [parameter(Mandatory=$true)][String] $CardFormat,
        [parameter(Mandatory=$true)][Int] $CardNumber
    )

    [xml]$xml = New-Object System.Xml.XmlDocument
    $wrapper = $xml.AppendChild($xml.CreateElement("NETBOX-API"))
    $wrapper.SetAttribute("sessionid",$NETBOXSessionID)
    $command = $wrapper.AppendChild($xml.CreateElement("COMMAND"))
    $Command.SetAttribute("name","AddCredential")
    $Command.SetAttribute("num","1")
    $Parameters=$Command.AppendChild($xml.CreateElement("PARAMS"))
    $param = $xml.CreateElement("PERSONID")
    $param.innerText = $PersonID
    $Parameters.AppendChild($param) | Out-Null
    $param = $xml.CreateElement("CARDFORMAT")
    $param.innerText = $CardFormat
    $Parameters.AppendChild($param) | Out-Null
    $param = $xml.CreateElement("ENCODEDNUM")
    $param.innerText = $CardNumber
    $Parameters.AppendChild($param) | Out-Null
   
    $Response = Invoke-WebRequest -URI "$($S2PROTOCOL)$($S2HOSTNAME)/goforms/nbapi" -Method Post -Body $xml
    $ReturnXML = $([xml]$Response.content)

    switch ($ReturnXML.NETBOX.RESPONSE.CODE) {
        "SUCCESS" { Return $true  }
        Default { 
            Write-Output $ReturnXML.NETBOX.RESPONSE.CODE
            Return $false 
        }
    }
}

Function Remove-S2Credential {
    param(
        [parameter(Mandatory=$true)][String] $PersonID,
        [parameter(Mandatory=$true)][String] $CardFormat,
        [parameter(Mandatory=$true)][Int] $CardNumber
    )

    [xml]$xml = New-Object System.Xml.XmlDocument
    $wrapper = $xml.AppendChild($xml.CreateElement("NETBOX-API"))
    $wrapper.SetAttribute("sessionid",$NETBOXSessionID)
    $command = $wrapper.AppendChild($xml.CreateElement("COMMAND"))
    $Command.SetAttribute("name","RemoveCredential")
    $Command.SetAttribute("num","1")
    $Parameters=$Command.AppendChild($xml.CreateElement("PARAMS"))
    $param = $xml.CreateElement("PERSONID")
    $param.innerText = $PersonID
    $Parameters.AppendChild($param) | Out-Null
    $param = $xml.CreateElement("CARDFORMAT")
    $param.innerText = $CardFormat
    $Parameters.AppendChild($param) | Out-Null
    $param = $xml.CreateElement("ENCODEDNUM")
    $param.innerText = $CardNumber
    $Parameters.AppendChild($param) | Out-Null
   
    $Response = Invoke-WebRequest -URI "$($S2PROTOCOL)$($S2HOSTNAME)/goforms/nbapi" -Method Post -Body $xml
    $ReturnXML = $([xml]$Response.content)

    switch ($ReturnXML.NETBOX.RESPONSE.CODE) {
        "SUCCESS" { Return $true }
        Default { 
            Write-Output $ReturnXML.NETBOX.RESPONSE.CODE
            Return $false 
        }
    }
}