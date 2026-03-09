$P4_VERSION='25.2'

# Copy over configs
New-Item "${env:USERPROFILE}\.gradle" -ItemType Directory | Out-Null
New-Item "${env:USERPROFILE}\.m2" -ItemType Directory | Out-Null
New-Item "${env:USERPROFILE}\.bundle" -ItemType Directory | Out-Null

Copy-Item "$PSScriptroot\gitconfig-windows"   "${env:USERPROFILE}\.gitconfig"
Copy-Item "$PSScriptroot\init.gradle"         "${env:USERPROFILE}\.gradle\init.gradle"
Copy-Item "$PSScriptroot\maven-settings.xml"  "${env:USERPROFILE}\.m2\settings.xml"
Copy-Item "$PSScriptroot\bundle-config"       "${env:USERPROFILE}\.bundle\config"
Copy-Item "$PSScriptroot\npmrc"               "${env:USERPROFILE}\.npmrc"
Copy-Item "$PSScriptroot\yarnrc.yml"          "${env:USERPROFILE}\.yarnrc.yml"

function PrefixToSystemAndCurrentPath {
    param (
        [Parameter(Mandatory=$true)]
        [string]$PathPrefix
    )
    $newSystemPath = "$PathPrefix;" + [System.Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine)
    $env:Path = $newSystemPath + ";" + [System.Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User)
    [Environment]::SetEnvironmentVariable("Path", $newSystemPath, [EnvironmentVariableTarget]::Machine)
}

# install scoop
iex "& {$(irm get.scoop.sh)} -RunAsAdmin"
scoop bucket add extras
scoop install git mise extras/googlechrome
& "$PSScriptroot\Add-Font.ps1" "$PSScriptroot\Fonts"

mise install
mise settings ruby.compile=false
$env:GITHUB_TOKEN = Get-Content C:\ProgramData\Docker\secrets\github_token
$env:CLICOLOR_FORCE = 1
mise install

ridk install 2 3 # Update packages and install development toolchain

# install p4 client and p4d / helix-core-server
New-Item "${env:ProgramFiles}\\Perforce\\bin\\" -ItemType Directory | Out-Null
PrefixToSystemAndCurrentPath("${env:ProgramFiles}\\Perforce\\bin")
Invoke-WebRequest https://cdist2.perforce.com/perforce/r$P4_VERSION/bin.ntx64/p4.exe -Outfile "${env:ProgramFiles}\\Perforce\\bin\\p4.exe"
Invoke-WebRequest https://cdist2.perforce.com/perforce/r$P4_VERSION/bin.ntx64/p4d.exe -Outfile "${env:ProgramFiles}\\Perforce\\bin\\p4d.exe"

# Install nant
Invoke-WebRequest https://onboardcloud.dl.sourceforge.net/project/nant/nant/${NANT_VERSION}/nant-${NANT_VERSION}-bin.zip?viasf=1 -Outfile "${env:TEMP}\\nant.zip"
Expand-Archive -Path "${env:TEMP}\\nant.zip" -DestinationPath "C:\\tools"
PrefixToSystemAndCurrentPath("C:\\tools\\nant-${NANT_VERSION}\\bin")
Remove-Item "${env:TEMP}\\nant.zip" -Force

Add-LocalGroupMember -Group "Administrators" -Member "ContainerAdministrator"
