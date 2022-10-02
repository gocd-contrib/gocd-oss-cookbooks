FROM mcr.microsoft.com/windows/servercore:ltsc2022

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

RUN powershell -File C:\\Users\\ContainerAdministrator\\provision\\provision.ps1

CMD ["C:\\go-agent.exe"]
