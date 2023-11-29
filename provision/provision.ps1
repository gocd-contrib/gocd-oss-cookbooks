Write-Host "Installing packages..."
&"$PSScriptroot\provision-install-packages.ps1"
Write-Host "Initilizing Gradle cache for gocd..."
&"$PSScriptroot\provision-init-gradle-cache.ps1"
Write-Host "Done."
Get-Job
tasklist /V
