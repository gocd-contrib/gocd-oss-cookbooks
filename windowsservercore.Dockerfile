# escape=`
ARG EDITION
FROM mcr.microsoft.com/windows/servercore:$EDITION
LABEL org.opencontainers.image.authors="GoCD Team <go-cd-dev@googlegroups.com>"

ENV TMP=C:\tmp `
    TEMP=C:\tmp `
    POWERSHELL_TELEMETRY_OPTOUT=1 `
    POWERSHELL_UPDATECHECK=0
VOLUME "C:\tmp"

ARG PROVISION_SCRIPTS_DIR="C:\Users\ContainerAdministrator\provision"
COPY provision provision-windows $PROVISION_SCRIPTS_DIR/

ARG GITHUB_TOKEN
SHELL ["powershell", "-Command"]
RUN & \"$env:PROVISION_SCRIPTS_DIR\provision-scoop-pwsh.ps1\" ;`
    pwsh -File \"$env:PROVISION_SCRIPTS_DIR\provision-windows.ps1\"

# Create volume where the golang-gocd-bootstrapper will use as work dir
VOLUME "C:\go-working-dir"
CMD ["go-agent.exe"]
