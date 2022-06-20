Function Get-S2PortalGroup {
    param(
        [parameter(Mandatory=$true)][String] $PortalKey
    )
    $xml = "<NETBOX-API sessionid=`"$NETBOXSessionID`"><COMMAND name=`"GetPortalGroup`" num=`"1`"><PARAMS><PORTALGROUPKEY>$PortalKey</PORTALGROUPKEY></PARAMS></COMMAND></NETBOX-API>"
    $([XML]$(Invoke-WebRequest -URI "$($S2PROTOCOL)$($S2HOSTNAME)/goforms/nbapi" -Method Post -Body $xml).content).NETBOX.RESPONSE.DETAILS.PORTALGROUP
}