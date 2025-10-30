# Running gradle task to install gradle

$ErrorActionPreference = "Stop"

Write-Host "Building gocd to install gradle and build gradle cache..."
git clone https://github.com/gocd/gocd --depth 1 C:\\gocd --quiet
cd C:\\gocd
./gradlew resolveExternalDependencies --no-build-cache --quiet

Write-Host "Cleaning up build artifacts..."
./gradlew clean --no-build-cache --quiet
Write-Host "Stopping Gradle daemons..."
./gradlew --stop
Write-Host "Cleaning up entire gocd clone..."
cd \
cmd.exe /c "rmdir /s /q C:\\gocd"

New-Item C:\\go -ItemType Directory | Out-Null
Write-Host "Cleaned."
