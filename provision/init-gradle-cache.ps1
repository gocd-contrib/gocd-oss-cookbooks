# Running gradle task to install gradle

$ErrorActionPreference = "Stop"

Write-Host "Builing gocd to install gradle and build gradle cache..."
git clone https://github.com/gocd/gocd --depth 1 C:\\gocd --quiet
cd C:\\gocd
yarn.cmd config set network-timeout 300000
./gradlew.bat prepare --no-build-cache --quiet
yarn.cmd config delete network-timeout

Write-Host "Stopping Gradle daemons..."
./gradlew.bat --stop

Write-Host "Cleaning up..."
cd c:\\
cmd /c "rmdir /s /q C:\\gocd"

New-Item C:\\go -ItemType Directory | Out-Null
