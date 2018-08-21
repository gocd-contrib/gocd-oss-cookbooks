# Running gradle task to install gradle
$ErrorActionPreference = "Stop"
git clone https://github.com/gocd/gocd --depth 1 C:\\gocd --quiet
cd C:\\gocd
./gradlew.bat prepare --no-build-cache --quiet
timeout 5
./gradlew.bat clean --quiet
timeout 5
tasklist
taskkill /F /IM java.exe
git clean -ffddx
tasklist
cd \
Remove-Item -Path C:\\gocd -Force -Recurse | Out-Null
New-Item C:\\go -ItemType Directory | Out-Null
