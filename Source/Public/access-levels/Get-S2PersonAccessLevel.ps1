Function Get-S2PersonAccessLevel {
    param(
        [parameter(Mandatory=$true)][String] $PersonID
    )
    $(Get-S2Person $PersonID).ACCESSLEVELS.ACCESSLEVEL
}