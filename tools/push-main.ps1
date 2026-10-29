<## Push the existing main commit without invoking Git's crashing credential-helper path.
    Credentials are read from Windows Credential Manager and used only in process memory.
    This script never stages files, creates commits, stores a token or force-pushes. ##>
$ErrorActionPreference = 'Stop'
Push-Location (Split-Path -Parent $PSScriptRoot)
$environmentNames = @('GIT_CONFIG_COUNT','GIT_CONFIG_KEY_0','GIT_CONFIG_VALUE_0','GIT_TERMINAL_PROMPT','GIT_TRACE','GIT_TRACE_CURL','GIT_CURL_VERBOSE')
$previousEnvironment = @{}
foreach ($environmentName in $environmentNames) { $previousEnvironment[$environmentName] = [Environment]::GetEnvironmentVariable($environmentName, 'Process') }
try {
  $branch = git branch --show-current
  if ($LASTEXITCODE -ne 0 -or $branch -ne 'main') { throw 'Run this only from the main branch.' }
  $remote = git remote get-url origin
  if ($remote -ne 'https://github.com/Desha29/NewCare.git') { throw 'Unexpected origin URL; nothing was pushed.' }
  $credentialResult = @("protocol=https`nhost=github.com`nusername=Desha29`n`n" | git credential-manager get)
  if ($LASTEXITCODE -ne 0) { throw 'Credential Manager could not retrieve the GitHub sign-in.' }
  $passwordLine = $credentialResult | Where-Object { $_ -like 'password=*' } | Select-Object -First 1
  if (-not $passwordLine) { throw 'No saved GitHub credential is available.' }
  $password = $passwordLine.Substring('password='.Length)
  $encoded = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("Desha29:$password"))
  $env:GIT_CONFIG_COUNT = '1'
  $env:GIT_CONFIG_KEY_0 = 'http.https://github.com/.extraheader'
  $env:GIT_CONFIG_VALUE_0 = "AUTHORIZATION: basic $encoded"
  $env:GIT_TERMINAL_PROMPT = '0'
  foreach ($traceName in @('GIT_TRACE','GIT_TRACE_CURL','GIT_CURL_VERBOSE')) { [Environment]::SetEnvironmentVariable($traceName, $null, 'Process') }
  git -c credential.helper= push --porcelain --set-upstream origin main
  if ($LASTEXITCODE -ne 0) { throw 'Push failed. Read the Git error above; no commits were created.' }
} finally {
  foreach ($environmentName in $environmentNames) { [Environment]::SetEnvironmentVariable($environmentName, $previousEnvironment[$environmentName], 'Process') }
  Remove-Variable credentialResult,passwordLine,password,encoded -ErrorAction SilentlyContinue
  Pop-Location
}
