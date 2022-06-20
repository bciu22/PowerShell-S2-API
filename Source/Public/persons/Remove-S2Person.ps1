Function Remove-S2Person {
<#
 .Synopsis
  Allows you to remove a person who should no longer have access.  

 .Description
  Allows you to remove a person who should no longer have access.  
  Note: Remove-S2Person disables the person record, leaving it in the database so that reports of history continue to function. 
  Access levels and credential records are deleted. 

 .Parameter PersonID
  The PersonID of the person you are wishing to remove.

 .Example 
  C:\PS> Remove-S2Person _100
  Will disable a person with the Person ID of _100 and remove all access given to their person account.
#>
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