# Running gradle task to install gradle

$ErrorActionPreference = "Stop"

Write-Host "Building gocd to install gradle and build gradle cache..."
git clone https://github.com/gocd/gocd --depth 1 C:\\gocd --quiet
cd C:\\gocd
yarn config set network-timeout 300000
./gradlew compileAll yarnInstall --no-build-cache --quiet
yarn config delete network-timeout

Write-Host "Cleaning up build artifacts..."
./gradlew clean --no-build-cache --quiet
Write-Host "Stopping Gradle daemons..."
./gradlew --stop
Write-Host "Cleaning up entire gocd clone..."
cd \
cmd /c "rmdir /s /q C:\\gocd"

New-Item C:\\go -ItemType Directory | Out-Null
