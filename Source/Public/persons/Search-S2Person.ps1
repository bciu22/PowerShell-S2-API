Function Search-S2Person {
    param(
        [String] $LastName,
        [String] $MiddleName,
        [String] $FirstName,
        [String] $PersonID,
        [String] $UDF1,
        [String] $UDF2,
        [String] $UDF3,
        [Switch] $Deleted
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

    if($Deleted)
    {
        $param = $xml.CreateElement("DELETED")
        $param.innerText = "ALL"
        $Parameters.AppendChild($param) | Out-Null
    } else {
        $param = $xml.CreateElement("DELETED")
        $param.innerText = "FALSE"
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