# escape=`
ARG EDITION
FROM mcr.microsoft.com/powershell:lts-windowsservercore-ltsc2022 as powershell
FROM mcr.microsoft.com/windows/servercore:$EDITION
LABEL org.opencontainers.image.authors="GoCD Team <go-cd-dev@googlegroups.com>"

ENV TMP=C:\\tmp `
    TEMP=C:\\tmp

# See https://github.com/PowerShell/PowerShell-Docker/blob/master/release/7-6/windowsservercore2022/docker/Dockerfile
ENV ProgramFiles="C:\Program Files" `
    PSModuleAnalysisCachePath="C:\Users\Public\AppData\Local\Microsoft\Windows\PowerShell\docker\ModuleAnalysisCache" `
    POWERSHELL_TELEMETRY_OPTOUT="1"
COPY --from=powershell "$ProgramFiles\\PowerShell\\latest" "$ProgramFiles\\PowerShell\\latest"
RUN setx /M PATH "%ProgramFiles%\PowerShell\latest;%PATH%;"

ARG PROVISION_SCRIPTS_DIR="C:\Users\ContainerAdministrator\provision"
COPY provision $PROVISION_SCRIPTS_DIR
COPY provision-windows $PROVISION_SCRIPTS_DIR

RUN pwsh -File "%PROVISION_SCRIPTS_DIR%\\provision-windows.ps1"

# Create volume where the golang-gocd-bootstrapper will use as work dir
VOLUME "C:\\go-working-dir"

CMD ["go-agent.exe"]
