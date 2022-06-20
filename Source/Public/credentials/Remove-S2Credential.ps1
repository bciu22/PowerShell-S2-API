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