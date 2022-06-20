Function Add-S2PersonAccessLevel {
<#
 .Synopsis
  Allows you to a Access Level to a person list of existing Access Levels.  

 .Description
  Allows you to add Access Levels to a person's existing Access Levels.  

 .Parameter PersonID
  The PersonID of the person you are wanting to change.

 .Parameter AccessLevels
  Specify what Access Level or Levels you want the person to be added to.
#>
    param(
        [parameter(Mandatory=$true)][String] $PersonID,
        [parameter(Mandatory=$true)][String[]] $AccessLevels
    )
    $ExistingAccessLevels = Get-S2PersonAccessLevel $PersonID
    Edit-S2Person -PersonID $PersonID -AccessLevels $($AccessLevels + $ExistingAccessLevels)
}
