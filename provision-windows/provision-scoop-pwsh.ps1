#Requires -Version 5.1
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
Set-StrictMode -Version Latest

Write-host 'Installing scoop + pwsh...'
iex "& {$(irm get.scoop.sh)} -RunAsAdmin "
scoop config gh_token $env:GITHUB_TOKEN
scoop install pwsh
