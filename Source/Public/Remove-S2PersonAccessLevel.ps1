Function Remove-S2PersonAccessLevel {
<#
 .Synopsis
  Allows you to remove one or multiple Access Level assigned to a Person.

 .Description
  Allows you to remove one or multiple Access Level assigned to a Person. 
  You do have to specify specify which Access Levels you wanting to be removed thouogh.

 .Parameter PersonID
  The PersonID of the person you are wanting to change.

 .Parameter AccessLevels
  Specify what Access Level or Levels you want the person to be removed from.
#>
    param(
        [parameter(Mandatory=$true)][String] $PersonID,
        [parameter(Mandatory=$true)][String[]] $AccessLevels
    )
    $ExistingAccessLevels = Get-S2PersonAccessLevel $PersonID
    Edit-S2Person -PersonID $PersonID -AccessLevels $(Compare-Object $AccessLevels $ExistingAccessLevels | Select-Object -ExpandProperty InputObject)
}