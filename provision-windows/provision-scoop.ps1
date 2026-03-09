$PSNativeCommandUseErrorActionPreference = $true
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

Write-Host "Installing packages..."
& "$PSScriptroot\provision-install-packages-scoop.ps1"
Write-Host "Initializing Gradle cache for gocd..."
& "$PSScriptroot\provision-init-gradle-cache.ps1"
Write-Host "Completed provisioning (layer now exporting...)"
