Function Get-S2AccessLevel {
    param(
        [parameter(Mandatory=$true)][String] $AccessLevelKey
        # [parameter(Mandatory=$true)][String] $ACCESSLEVELNAME
    )
    $xml = "<NETBOX-API sessionid=`"$NETBOXSessionID`"><COMMAND name=`"GetAccessLevel`" num=`"1`"><PARAMS><ACCESSLEVELKEY>$AccessLevelKey</ACCESSLEVELKEY></PARAMS></COMMAND></NETBOX-API>"
    $([XML]$(Invoke-WebRequest -URI "$($S2PROTOCOL)$($S2HOSTNAME)/goforms/nbapi" -Method Post -Body $xml).content).NETBOX.RESPONSE.DETAILS
}