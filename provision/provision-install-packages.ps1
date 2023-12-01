$JAVA_VERSION='17.0.9.900'
$JAVA_MAJOR_VERSION=$JAVA_VERSION.Split(".")[0]
$NODEJS_VERSION='20.10.0'
$RUBY_VERSION='3.1.3.1'
$NANT_VERSION='0.92.2-gocd'
$ANT_VERSION='1.10.14'

$GOLANG_BOOTSTRAPPER_VERSION='2.9'
$P4D_VERSION='23.1'

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
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

$env:ChocolateyInstall = Convert-Path "$((Get-Command choco).path)\..\.."
Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"

RefreshEnv

# install packages
choco install --no-progress -y nodejs-lts --version="${NODEJS_VERSION}"
choco install --no-progress -y temurin${JAVA_MAJOR_VERSION} --version="${JAVA_VERSION}"
choco install --no-progress -y ruby --version="${RUBY_VERSION}"
choco install --no-progress -y msys2 --params "/NoUpdate" # For compiling certain native Ruby extensions, introduced for google-protobuf 3.25.0+
choco install --no-progress -y nant --version="${NANT_VERSION}" --prerelease --source="$PSScriptroot"
choco install --no-progress -y ant --version="${ANT_VERSION}"
choco install --no-progress -y hg sliksvn git p4 gnupg awscli
choco install --no-progress -y windows-sdk-11-version-22h2-all --install-arguments='/features OptionId.SigningTools /ceip off'
choco install --no-progress -y --ignore-checksums googlechrome # Ignore checksums due to package not using repeatable build links to Google downloads

RefreshEnv
corepack enable
yarn --version
#ridk install 3 # Install only MSYS2 and MINGW development toolchain (MSYS2 and system update already done by Chocolatey package)
#ridk enable
#cc --version

# Remove chocolatey from temp location
Remove-Item C:\\Users\\ContainerAdministrator\\AppData\\Local\\Temp\\chocolatey -Force -Recurse | Out-Null

# install p4d / helix-core-server
New-Item "${env:ProgramFiles}\\Perforce\\bin\\" -ItemType Directory | Out-Null
Invoke-WebRequest https://cdist2.perforce.com/perforce/r$P4D_VERSION/bin.ntx64/p4d.exe -Outfile "${env:ProgramFiles}\\Perforce\\bin\\p4d.exe"

# install gocd bootstrapper
Invoke-WebRequest https://github.com/gocd-contrib/gocd-golang-bootstrapper/releases/download/${GOLANG_BOOTSTRAPPER_VERSION}/go-bootstrapper-${GOLANG_BOOTSTRAPPER_VERSION}.windows.amd64.exe -Outfile C:\\go-agent.exe

$newSystemPath = [System.Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine)
$newSystemPath = "${newSystemPath};${env:ProgramFiles}\\Perforce\\bin"
$env:Path = $newSystemPath + ";" + [System.Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User)
[Environment]::SetEnvironmentVariable("Path", $newSystemPath, [EnvironmentVariableTarget]::Machine)

Add-LocalGroupMember -Group "Administrators" -Member "ContainerAdministrator"
