FROM mcr.microsoft.com/windows/servercore:ltsc2022
LABEL org.opencontainers.image.authors="GoCD Team <go-cd-dev@googlegroups.com>"

# Shamelessly nabbed from https://github.com/gantrior/docker-chrome-windows
#
# Fonts are needed for Chrome to launch and function. Windows Server Core
# does not include fonts, so we need to install them ourselves.
ADD Files/FontsToAdd.tar /Fonts/
WORKDIR /Fonts/
RUN powershell -File .\\Add-Font.ps1 Fonts
WORKDIR /

ENV TMP=C:\\tmp \
    TEMP=C:\\tmp

COPY provision C:\\Users\\ContainerAdministrator\\provision

RUN powershell -File C:\\Users\\ContainerAdministrator\\provision\\provision-choco.ps1

# Create volume where the golang-gocd-bootstrapper will use as work dir
VOLUME C:\\go-working-dir

CMD ["C:\\go-agent.exe"]
