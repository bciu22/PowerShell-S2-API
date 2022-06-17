param(
    [version]$Version = "1.0.0"
)
#Requires -Module ModuleBuilder

$params = @{
    SourcePath = "$PSScriptRoot\Source\LenelS2-NetBox.psd1"
    CopyPaths = @("$PSScriptRoot\README.md")
    Version = $Version
    UnversionedOutputDirectory = $true
}
Build-Module @params