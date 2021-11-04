# Running gradle task to install gradle

$ErrorActionPreference = "Stop"

Write-Host "Builing gocd to install gradle and build gradle cache"

git clone https://github.com/gocd/gocd --depth 1 C:\\gocd --quiet
cd C:\\gocd
yarn.cmd config set network-timeout 300000
./gradlew.bat prepare --no-build-cache --quiet
yarn.cmd config delete network-timeout
Start-Sleep -Seconds 5
./gradlew.bat clean --quiet
Start-Sleep -Seconds 5
tasklist
taskkill /F /IM java.exe
git clean -ffddx
tasklist
cd \
Remove-Item -Path C:\\gocd -Force -Recurse | Out-Null
New-Item C:\\go -ItemType Directory | Out-Null
