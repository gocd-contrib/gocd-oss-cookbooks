$JAVA_VERSION='21.0.6.7'
$NODEJS_VERSION='22.16.0'

$GOLANG_BOOTSTRAPPER_VERSION='2.29'
$P4_VERSION='25.1'
$ANT_VERSION='1.10.15'
$NANT_VERSION='0.92'

# Copy over configs
New-Item "${env:USERPROFILE}\.gradle" -ItemType Directory | Out-Null
New-Item "${env:USERPROFILE}\.m2" -ItemType Directory | Out-Null
New-Item "${env:USERPROFILE}\.bundle" -ItemType Directory | Out-Null

Copy-Item "$PSScriptroot\bundle-config"       "${env:USERPROFILE}\.bundle\config"
Copy-Item "$PSScriptroot\gitconfig-windows"   "${env:USERPROFILE}\.gitconfig"
Copy-Item "$PSScriptroot\init.gradle"         "${env:USERPROFILE}\.gradle\init.gradle"
Copy-Item "$PSScriptroot\npmrc"               "${env:USERPROFILE}\.npmrc"
Copy-Item "$PSScriptroot\settings.xml"        "${env:USERPROFILE}\.m2\settings.xml"

function Winget-Install {
    winget install --accept-source-agreements --accept-package-agreements --disable-interactivity @args
}

function PrefixToSystemAndCurrentPath {
    param (
        [Parameter(Mandatory=$true)]
        [string]$PathPrefix
    )
    $newSystemPath = "$PathPrefix;" + [System.Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine)
    $env:Path = $newSystemPath + ";" + [System.Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User)
    [Environment]::SetEnvironmentVariable("Path", $newSystemPath, [EnvironmentVariableTarget]::Machine)
}

# install packages
Winget-Install OpenJS.NodeJS.LTS --version="${NODEJS_VERSION}"
corepack enable
yarn --version

Winget-Install EclipseAdoptium.Temurin.21.JDK --version="${JAVA_VERSION}"

Winget-Install Git.Git Mercurial.Mercurial Slik.Subversion Google.Chrome
git config --global core.autocrlf false

Winget-Install RubyInstallerTeam.RubyWithDevKit.3.2
ridk install 2 3 # Update packages and install development toolchain

# install p4 client and p4d / helix-core-server
New-Item "${env:ProgramFiles}\\Perforce\\bin\\" -ItemType Directory | Out-Null
PrefixToSystemAndCurrentPath("${env:ProgramFiles}\\Perforce\\bin")
Invoke-WebRequest https://cdist2.perforce.com/perforce/r$P4_VERSION/bin.ntx64/p4.exe -Outfile "${env:ProgramFiles}\\Perforce\\bin\\p4.exe"
Invoke-WebRequest https://cdist2.perforce.com/perforce/r$P4_VERSION/bin.ntx64/p4d.exe -Outfile "${env:ProgramFiles}\\Perforce\\bin\\p4d.exe"

# Install ant
Invoke-WebRequest https://dlcdn.apache.org//ant/binaries/apache-ant-${ANT_VERSION}-bin.zip -Outfile "${env:TEMP}\\ant.zip"
Expand-Archive -Path "${env:TEMP}\\ant.zip" -DestinationPath "C:\\tools"
PrefixToSystemAndCurrentPath("C:\\tools\\apache-ant-${ANT_VERSION}\\bin")
Remove-Item "${env:TEMP}\\ant.zip" -Force

# Install nant
Invoke-WebRequest https://onboardcloud.dl.sourceforge.net/project/nant/nant/${NANT_VERSION}/nant-${NANT_VERSION}-bin.zip?viasf=1 -Outfile "${env:TEMP}\\nant.zip"
Expand-Archive -Path "${env:TEMP}\\nant.zip" -DestinationPath "C:\\tools"
PrefixToSystemAndCurrentPath("C:\\tools\\nant-${NANT_VERSION}\\bin")
Remove-Item "${env:TEMP}\\nant.zip" -Force

# install gocd bootstrapper
Invoke-WebRequest https://github.com/gocd-contrib/gocd-golang-bootstrapper/releases/download/${GOLANG_BOOTSTRAPPER_VERSION}/go-bootstrapper-${GOLANG_BOOTSTRAPPER_VERSION}.windows.amd64.exe -Outfile C:\\go-agent.exe

Add-LocalGroupMember -Group "Administrators" -Member "ContainerAdministrator"
