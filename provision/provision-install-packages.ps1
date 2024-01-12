$JAVA_VERSION='17.0.9.900'
$JAVA_MAJOR_VERSION=$JAVA_VERSION.Split(".")[0]
$NODEJS_VERSION='20.11.0'
$RUBY_VERSION='3.3.0.1'
$NANT_VERSION='0.92.2-gocd'
$ANT_VERSION='1.10.14'

$GOLANG_BOOTSTRAPPER_VERSION='2.10'
$P4D_VERSION='23.2'

# Copy over configs
New-Item "${env:USERPROFILE}\.gradle" -ItemType Directory | Out-Null
New-Item "${env:USERPROFILE}\.m2" -ItemType Directory | Out-Null
New-Item "${env:USERPROFILE}\.bundle" -ItemType Directory | Out-Null

Copy-Item "$PSScriptroot\bundle-config"       "${env:USERPROFILE}\.bundle\config"
Copy-Item "$PSScriptroot\gitconfig-windows"   "${env:USERPROFILE}\.gitconfig"
Copy-Item "$PSScriptroot\init.gradle"         "${env:USERPROFILE}\.gradle\init.gradle"
Copy-Item "$PSScriptroot\npmrc"               "${env:USERPROFILE}\.npmrc"
Copy-Item "$PSScriptroot\settings.xml"        "${env:USERPROFILE}\.m2\settings.xml"

function PrefixToSystemAndCurrentPath {
    param (
        [Parameter(Mandatory=$true)]
        [string]$PathPrefix
    )
    $newSystemPath = "$PathPrefix;" + [System.Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine)
    $env:Path = $newSystemPath + ";" + [System.Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User)
    [Environment]::SetEnvironmentVariable("Path", $newSystemPath, [EnvironmentVariableTarget]::Machine)
}

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
RefreshEnv
corepack enable
yarn --version

choco install --no-progress -y temurin${JAVA_MAJOR_VERSION} --version="${JAVA_VERSION}"
choco install --no-progress -y nant --version="${NANT_VERSION}" --prerelease --source="$PSScriptroot"
choco install --no-progress -y ant --version="${ANT_VERSION}"
choco install --no-progress -y hg sliksvn git gnupg awscli
choco install --no-progress -y --ignore-checksums p4  # Ignore checksums due to package not using repeatable build links to downloads
choco install --no-progress -y windows-sdk-11-version-22h2-all --install-arguments='/features OptionId.SigningTools /ceip off'
choco install --no-progress -y --ignore-checksums googlechrome # Ignore checksums due to package not using repeatable build links to downloads

choco install --no-progress -y ruby --version="${RUBY_VERSION}"
# Install MSYS2 and dev toolchain for compiling certain native Ruby extensions, introduced for google-protobuf 3.25.0+
# Following pattern at https://community.chocolatey.org/packages/msys2#description but disabling the auto-update of
# msys2-runtime due to mysterious hangs on docker. See https://github.com/msys2/msys2-installer/issues/59#issuecomment-1835720068
$msysInstallDir = "C:\tools\msys64"
choco install --no-progress -y msys2 --params "/NoUpdate /InstallDir:${msysInstallDir}"
RefreshEnv
PrefixToSystemAndCurrentPath("${msysInstallDir}\ucrt64\bin;${msysInstallDir}\usr\bin") # Manually add MSYS2 and tools to path to avoid having to do shell-specific "ridk enable" in builds.
ridk exec bash.exe -c "echo -e '[options]\nIgnorePkg = msys2-runtime\nIgnorePkg = pacman' >> /etc/pacman.conf"
ridk install 2 3 # use ruby's ridk to update the system and install development toolchain

# Remove chocolatey from temp location
Remove-Item C:\\Users\\ContainerAdministrator\\AppData\\Local\\Temp\\chocolatey -Force -Recurse | Out-Null

# install p4d / helix-core-server
New-Item "${env:ProgramFiles}\\Perforce\\bin\\" -ItemType Directory | Out-Null
Invoke-WebRequest https://cdist2.perforce.com/perforce/r$P4D_VERSION/bin.ntx64/p4d.exe -Outfile "${env:ProgramFiles}\\Perforce\\bin\\p4d.exe"
PrefixToSystemAndCurrentPath("${env:ProgramFiles}\\Perforce\\bin")

# install gocd bootstrapper
Invoke-WebRequest https://github.com/gocd-contrib/gocd-golang-bootstrapper/releases/download/${GOLANG_BOOTSTRAPPER_VERSION}/go-bootstrapper-${GOLANG_BOOTSTRAPPER_VERSION}.windows.amd64.exe -Outfile C:\\go-agent.exe

Add-LocalGroupMember -Group "Administrators" -Member "ContainerAdministrator"
