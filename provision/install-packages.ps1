$GOLANG_BOOTSTRAPPER_VERSION='2.3'
$P4_VERSION='15.1'
$P4D_VERSION='16.2'
$NODEJS_VERSION='14.5.0'
$RUBY_VERSION='2.7.1.1'
$NANT_VERSION='0.92.2'
$ANT_VERSION='1.10.1' # because newer ant versions will pull down a JRE, which we do not want
# Copy over configs
New-Item "${env:USERPROFILE}\.gradle" -ItemType Directory | Out-Null
New-Item "${env:USERPROFILE}\.m2" -ItemType Directory | Out-Null
New-Item "${env:USERPROFILE}\.bundle" -ItemType Directory | Out-Null

Copy-Item "$PSScriptroot\bundle-config"       "${env:USERPROFILE}\.bundle\config"
Copy-Item "$PSScriptroot\gitconfig-windows"   "${env:USERPROFILE}\.gitconfig"
Copy-Item "$PSScriptroot\init.gradle"         "${env:USERPROFILE}\.gradle\init.gradle"
Copy-Item "$PSScriptroot\npmrc"               "${env:USERPROFILE}\.npmrc"
Copy-Item "$PSScriptroot\settings.xml"        "${env:USERPROFILE}\.m2\settings.xml"

# install chocolatey
$chocolateyUseWindowsCompression = 'true'
$env:chocolateyUseWindowsCompression = 'true'
$ErrorActionPreference = "Stop"
$progressPreference = 'silentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Set-ExecutionPolicy Bypass -Scope Process -Force
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

$env:ChocolateyInstall = Convert-Path "$((Get-Command choco).path)\..\.."
Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"

refreshenv

# install packages
choco install --no-progress -y choco nodejs --version="${NODEJS_VERSION}"

refreshenv

npm install --global --production windows-build-tools

# install jabba
Invoke-Expression (Invoke-WebRequest https://github.com/shyiko/jabba/raw/master/install.ps1 -UseBasicParsing).Content

# install openjdk 11, 12 and 13. Make openjdk 11 default
Write-Host "Installing jabba and openjdk(11, 12, 13, 14), setting openjdk 11 as default"
jabba install openjdk@1.11
jabba install openjdk@1.12
jabba install openjdk@1.13
jabba install openjdk@1.14

jabba use "openjdk@1.11"

choco install --no-progress -y ruby --version="${RUBY_VERSION}"
choco install --no-progress -y nant --version="${NANT_VERSION}"
choco install --no-progress -y ant -i --version="${ANT_VERSION}"
choco install --no-progress -y hg yarn svn git gpg4win-vanilla windows-sdk-8.1 awscli
choco install --no-progress -y googlechrome

RefreshEnv

# Remove chocolatey from temp location
Remove-Item C:\\Users\\ContainerAdministrator\\AppData\\Local\\Temp\\chocolatey -Force -Recurse | Out-Null


# install p4
New-Item "${env:ProgramFiles(x86)}\\Perforce\\bin\\" -ItemType Directory | Out-Null
Invoke-WebRequest https://s3.amazonaws.com/mirrors-archive/local/perforce/r$P4_VERSION/bin.ntx64/p4.exe -Outfile "C:\\Program Files (x86)\\Perforce\\bin\\p4.exe"
Invoke-WebRequest https://s3.amazonaws.com/mirrors-archive/local/perforce/r$P4D_VERSION/bin.ntx64/p4d.exe -Outfile "C:\\Program Files (x86)\\Perforce\\bin\\p4d.exe"

# install gocd bootstrapper
Invoke-WebRequest https://github.com/ketan/gocd-golang-bootstrapper/releases/download/${GOLANG_BOOTSTRAPPER_VERSION}/go-bootstrapper-${GOLANG_BOOTSTRAPPER_VERSION}.windows.amd64.exe -Outfile C:\\go-agent.exe

$newSystemPath = [System.Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine)
$newSystemPath = "${newSystemPath};${env:ProgramFiles(x86)}\\Perforce\\bin;${env:USERPROFILE}\\.jabba\\bin"
$env:Path = $newSystemPath + ";" + [System.Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User)
[Environment]::SetEnvironmentVariable("Path", $newSystemPath, [EnvironmentVariableTarget]::Machine)

Add-LocalGroupMember -Group "Administrators" -Member "ContainerAdministrator"
# npm config set msvs_version 2015
