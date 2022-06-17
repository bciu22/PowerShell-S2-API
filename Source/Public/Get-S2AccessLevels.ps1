Function Get-S2AccessLevels {
    param(
        [Switch] $WantKey
    )
    [xml]$xml = New-Object System.Xml.XmlDocument
    $wrapper = $xml.AppendChild($xml.CreateElement("NETBOX-API"))
    $wrapper.SetAttribute("sessionid",$NETBOXSessionID)
    $command = $wrapper.AppendChild($xml.CreateElement("COMMAND"))
    $Command.SetAttribute("name","GetAccessLevels")
    $Command.SetAttribute("num","1")
    if($WantKey)
    {
        $Parameters=$Command.AppendChild($xml.CreateElement("PARAMS"))
        $param = $xml.CreateElement("WANTKEY")
        $param.innerText = ("TRUE")
        $Parameters.AppendChild($param) | Out-Null
    }

    $([XML]$(Invoke-WebRequest -URI "$($S2PROTOCOL)$($S2HOSTNAME)/goforms/nbapi" -Method Post -Body $xml).content).NETBOX.RESPONSE.DETAILS.ACCESSLEVELS.ACCESSLEVEL
}