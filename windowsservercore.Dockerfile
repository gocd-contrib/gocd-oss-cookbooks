# escape=`
ARG EDITION
FROM mcr.microsoft.com/windows/servercore:$EDITION
LABEL org.opencontainers.image.authors="GoCD Team <go-cd-dev@googlegroups.com>"

ENV TMP=C:\tmp `
    TEMP=C:\tmp `
    POWERSHELL_TELEMETRY_OPTOUT=1 `
    POWERSHELL_UPDATECHECK=0
VOLUME "C:\tmp"

SHELL ["powershell", "-Command"]
RUN Write-host 'Installing scoop + pwsh...'; `
    $ErrorActionPreference = 'Stop'; `
    $ProgressPreference = 'SilentlyContinue'; `
    iex \"& {$(irm get.scoop.sh)} -RunAsAdmin \"; `
    scoop install pwsh

SHELL ["pwsh", "-Command"]
ARG PROVISION_SCRIPTS_DIR="C:\Users\ContainerAdministrator\provision"
COPY provision $PROVISION_SCRIPTS_DIR
COPY provision-windows $PROVISION_SCRIPTS_DIR
RUN & \"$env:PROVISION_SCRIPTS_DIR\provision-windows.ps1\"

# Create volume where the golang-gocd-bootstrapper will use as work dir
VOLUME "C:\go-working-dir"
CMD ["go-agent.exe"]
