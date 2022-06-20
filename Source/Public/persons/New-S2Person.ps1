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
