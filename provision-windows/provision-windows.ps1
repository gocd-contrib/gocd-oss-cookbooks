#Requires -PSEdition Core
#Requires -Version 7.3
$PSNativeCommandUseErrorActionPreference = $true
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
Set-StrictMode -Version Latest

Write-Host "Installing packages..."
$P4_VERSION='25.2'

# Copy over configs
New-Item "${env:USERPROFILE}\.config\mise" -ItemType Directory | Out-Null
New-Item "${env:USERPROFILE}\.gradle"      -ItemType Directory | Out-Null
New-Item "${env:USERPROFILE}\.m2"          -ItemType Directory | Out-Null
New-Item "${env:USERPROFILE}\.bundle"      -ItemType Directory | Out-Null

Copy-Item "$PSScriptroot\gitconfig-windows"  "${env:USERPROFILE}\.gitconfig"
Copy-Item "$PSScriptroot\mise-windows.toml"  "${env:USERPROFILE}\.config\mise\config.toml"
Copy-Item "$PSScriptroot\init.gradle"        "${env:USERPROFILE}\.gradle\init.gradle"
Copy-Item "$PSScriptroot\maven-settings.xml" "${env:USERPROFILE}\.m2\settings.xml"
Copy-Item "$PSScriptroot\bundle-config"      "${env:USERPROFILE}\.bundle\config"
Copy-Item "$PSScriptroot\npmrc"              "${env:USERPROFILE}\.npmrc"
Copy-Item "$PSScriptroot\yarnrc.yml"         "${env:USERPROFILE}\.yarnrc.yml"

function PrefixToUserAndCurrentPath {
    param (
        [Parameter(Mandatory=$true)]
        [string]$PathPrefix
    )
    [Environment]::SetEnvironmentVariable("Path", "$PathPrefix;" + [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User), [EnvironmentVariableTarget]::User)
    $env:Path = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine) + ";" + [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User)
}

function SetUserEnvironmentVariable {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Name,
        [Parameter(Mandatory=$true)]
        [string]$Value
    )
    Set-Item -Path "Env:$Name" -Value $value
    [Environment]::SetEnvironmentVariable($Name, $Value, [EnvironmentVariableTarget]::User)
}

Write-Host "Installing tools via scoop..."
scoop install git mercurial sliksvn msys2 ruby
Write-Host "Installing ruby with devkit..."
msys2 # initialize msys2
ridk install 2 3 # Update packages and install development toolchain

Write-Host "Installing mise..."
scoop bucket add extras
scoop install mise extras/vcredist2022

Write-Host "Installing mise tools..."
$env:CLICOLOR_FORCE = 1
mise install --yes
SetUserEnvironmentVariable "JAVA_HOME" (mise where java)
PrefixToUserAndCurrentPath "${env:LOCALAPPDATA}\mise\shims"

Write-Host "Installing perforce client/server..."
# install p4 client and p4d / helix-core-server
New-Item "C:\tools\Perforce\bin" -ItemType Directory | Out-Null
Invoke-WebRequest https://cdist2.perforce.com/perforce/r$P4_VERSION/bin.ntx64/p4.exe -Outfile "C:\tools\Perforce\bin\p4.exe"
Invoke-WebRequest https://cdist2.perforce.com/perforce/r$P4_VERSION/bin.ntx64/p4d.exe -Outfile "C:\tools\Perforce\bin\p4d.exe"
PrefixToUserAndCurrentPath "C:\tools\Perforce\bin"

Write-Host "Installing chrome..."
scoop install extras/googlechrome chromedriver
SetUserEnvironmentVariable "CHROME_BIN" $env:CHROME_EXECUTABLE # Needed for karma-jasmine-runner only
pwsh -File "$PSScriptroot\Add-Font.ps1" "$PSScriptroot\Fonts"

Add-LocalGroupMember -Group "Administrators" -Member "ContainerAdministrator"

# Prime local caches for gocd build
Write-Host "Initializing Gradle cache for gocd..."
git clone https://github.com/gocd/gocd --depth 1 "${env:TEMP}\gocd" --quiet
cd "${env:TEMP}\gocd"
mise install --yes
mise list --local --no-header --yes | % { $p = $_ -split '\s{2,}'; mise use --global --yes "$($p[0])@$($p[3])" }
./gradlew resolveExternalDependencies compileAll --no-build-cache --quiet --stacktrace --no-daemon
Write-Host "Cleaning up entire gocd clone..."
./gradlew clean --no-build-cache --quiet --no-daemon
cd \
cmd.exe /c "rmdir /s /q ${env:TEMP}\gocd"
Write-Host "Cleaning up caches..."
mise cache clear
scoop cache rm *
scoop config rm gh_token
Write-Host "Completed provisioning (layer now exporting...)"
