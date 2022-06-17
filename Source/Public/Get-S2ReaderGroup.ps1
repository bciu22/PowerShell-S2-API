Function Get-S2ReaderGroup {
    param(
        [parameter(Mandatory=$true)][String] $ReaderGroupKey
    )
    $xml = "<NETBOX-API sessionid=`"$NETBOXSessionID`"><COMMAND name=`"GetReaderGroup`" num=`"1`"><PARAMS><READERGROUPKEY>$ReaderGroupKey</READERGROUPKEY></PARAMS></COMMAND></NETBOX-API>"
    $([XML]$(Invoke-WebRequest -URI "$($S2PROTOCOL)$($S2HOSTNAME)/goforms/nbapi" -Method Post -Body $xml).content).NETBOX.RESPONSE.DETAILS.READERGROUP
}