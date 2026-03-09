FROM mcr.microsoft.com/powershell:lts-windowsservercore-ltsc2022
LABEL org.opencontainers.image.authors="GoCD Team <go-cd-dev@googlegroups.com>"

ENV TMP=C:\\tmp \
    TEMP=C:\\tmp

ARG PROVISION_SCRIPTS_DIR="C:\\Users\\ContainerAdministrator\\provision"

COPY provision $PROVISION_SCRIPTS_DIR
COPY provision-windows $PROVISION_SCRIPTS_DIR

RUN pwsh -File "$PROVISION_SCRIPTS_DIR\\provision-scoop.ps1"

# Create volume where the golang-gocd-bootstrapper will use as work dir
VOLUME "C:\\go-working-dir"

CMD ["go-agent.exe"]
