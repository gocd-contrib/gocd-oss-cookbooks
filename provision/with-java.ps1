
# default to Java 11
if (!${env:JAVA_VERSION}) {
    $env:JAVA_VERSION=11
}

if ("${env:JAVA_VERSION}" -eq "1.8") {
    jabba use "1.8"
}
elseif ("${env:JAVA_VERSION}" -eq "11") {
    jabba use "openjdk@1.11"
}
elseif ("${env:JAVA_VERSION}" -eq "12") {
    jabba use "openjdk@1.12"
}

if ($args.Length -eq 0) {
    Write-Host "Exiting because no command line args specified"
    exit 1
}

$agentExe = "$($args[0])"

$process = Start-Process -FilePath $agentExe -NoNewWindow -Wait

exit $process.ExitCode
