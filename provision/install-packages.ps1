$GOLANG_BOOTSTRAPPER_VERSION='2.3'
$P4_VERSION='15.1'
$P4D_VERSION='16.2'
$NODEJS_VERSION='16.13.2'
$RUBY_VERSION='2.7.2.1'
$NANT_VERSION='0.92.2'
$ANT_VERSION='1.10.12'
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

RefreshEnv

# install packages
choco install --no-progress -y nodejs --version="${NODEJS_VERSION}"

# Install tools to support node-gyp compilation of native stuff on Windows
choco upgrade --no-progress -y python visualstudio2017buildtools visualstudio2017-workload-vctools
RefreshEnv
npm config --global set msvs_version 2017

# install jabba
Invoke-Expression (Invoke-WebRequest https://github.com/shyiko/jabba/raw/master/install.ps1 -UseBasicParsing).Content

# install multiple openjdk versions
Write-Host "Installing openjdk variants"
jabba install openjdk@1.11
jabba install openjdk@1.15
jabba install openjdk@1.17

jabba use "openjdk@1.15"

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
