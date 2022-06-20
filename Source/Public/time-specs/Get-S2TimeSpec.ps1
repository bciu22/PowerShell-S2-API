Function Get-S2TimeSpec {
    param(
        [parameter(Mandatory=$true)][String] $TimeSpecKey
    )
    $xml = "<NETBOX-API sessionid=`"$NETBOXSessionID`"><COMMAND name=`"GetTimeSpec`" num=`"1`"><PARAMS><TIMESPECKEY>$TimeSpecKey</TIMESPECKEY></PARAMS></COMMAND></NETBOX-API>"
    $([XML]$(Invoke-WebRequest -URI "$($S2PROTOCOL)$($S2HOSTNAME)/goforms/nbapi" -Method Post -Body $xml).content).NETBOX.RESPONSE.DETAILS.TIMESPEC
}