$JAVA_VERSION='17.0.4.10100'
$JAVA_MAJOR_VERSION=$JAVA_VERSION.Split(".")[0]
$NODEJS_VERSION='16.18.0'
$RUBY_VERSION='3.1.2.1'
$NANT_VERSION='0.92.2'
$ANT_VERSION='1.10.12'

$GOLANG_BOOTSTRAPPER_VERSION='2.3'
$P4D_VERSION='22.1'

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
choco install --no-progress -y nodejs-lts --version="${NODEJS_VERSION}"
choco install --no-progress -y temurin${JAVA_MAJOR_VERSION} --version="${JAVA_VERSION}"
choco install --no-progress -y ruby --version="${RUBY_VERSION}"
choco install --no-progress -y nant --version="${NANT_VERSION}"
choco install --no-progress -y ant -i --version="${ANT_VERSION}"
choco install --no-progress -y hg yarn svn git p4 gnupg awscli
choco install --no-progress -y windows-sdk-10.1 --install-arguments='/features OptionId.SigningTools'
choco install --no-progress -y googlechrome

RefreshEnv

# Remove chocolatey from temp location
Remove-Item C:\\Users\\ContainerAdministrator\\AppData\\Local\\Temp\\chocolatey -Force -Recurse | Out-Null

# install p4d / helix-core-server
New-Item "${env:ProgramFiles}\\Perforce\\bin\\" -ItemType Directory | Out-Null
Invoke-WebRequest https://s3.amazonaws.com/mirrors-archive/local/perforce/r$P4D_VERSION/bin.ntx64/p4d.exe -Outfile "${env:ProgramFiles}\\Perforce\\bin\\p4d.exe"

# install gocd bootstrapper
Invoke-WebRequest https://github.com/ketan/gocd-golang-bootstrapper/releases/download/${GOLANG_BOOTSTRAPPER_VERSION}/go-bootstrapper-${GOLANG_BOOTSTRAPPER_VERSION}.windows.amd64.exe -Outfile C:\\go-agent.exe

$newSystemPath = [System.Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine)
$newSystemPath = "${newSystemPath};${env:ProgramFiles}\\Perforce\\bin"
$env:Path = $newSystemPath + ";" + [System.Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User)
[Environment]::SetEnvironmentVariable("Path", $newSystemPath, [EnvironmentVariableTarget]::Machine)

Add-LocalGroupMember -Group "Administrators" -Member "ContainerAdministrator"
