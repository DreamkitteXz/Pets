<#
.SYNOPSIS
    Calcula os campos de `app_config/android` a partir do APK gerado.

.DESCRIPTION
    Lê versionName e versionCode do próprio APK (não do pubspec — o que vale é
    o que foi realmente empacotado), calcula SHA-256 e tamanho, e monta a URL
    de download do Firebase Storage.

    Não escreve nada em lugar nenhum: só imprime os valores para você colar no
    console. A escrita é negada a todo cliente por rule, de propósito.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File tool\release_metadata.ps1
    powershell -ExecutionPolicy Bypass -File tool\release_metadata.ps1 -Changelog "Corrige upload de foto"
#>

[CmdletBinding()]
param(
    [string]$ApkPath = 'build\app\outputs\flutter-apk\app-release.apk',
    [string]$Bucket = 'pet-app-fccae.appspot.com',
    [string]$StorageFolder = 'app-releases',
    [string]$Changelog = ''
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path $ApkPath)) {
    throw "APK nao encontrado: $ApkPath`nRode antes: flutter build apk --release"
}

# aapt vem do build-tools do SDK; pega a versao mais recente instalada.
$sdk = if ($env:ANDROID_HOME) { $env:ANDROID_HOME } else { "$env:LOCALAPPDATA\Android\Sdk" }
$buildTools = Get-ChildItem "$sdk\build-tools" -Directory -ErrorAction SilentlyContinue |
    Sort-Object Name | Select-Object -Last 1
if (-not $buildTools) { throw "build-tools nao encontrado em $sdk" }
$aapt = Join-Path $buildTools.FullName 'aapt.exe'

$badging = & $aapt dump badging $ApkPath | Select-Object -First 1
if ($badging -notmatch "versionCode='(\d+)'" ) { throw 'Nao consegui ler o versionCode do APK.' }
$versionCode = [int]$Matches[1]
if ($badging -notmatch "versionName='([^']+)'") { throw 'Nao consegui ler o versionName do APK.' }
$versionName = $Matches[1]
if ($badging -notmatch "package: name='([^']+)'") { throw 'Nao consegui ler o package do APK.' }
$package = $Matches[1]

$file = Get-Item $ApkPath
$sha = (Get-FileHash $ApkPath -Algorithm SHA256).Hash.ToLower()

# Nome com versao embutida: subir sempre como "app-release.apk" faria uma
# versao sobrescrever a anterior no Storage.
$storageName = "pets-$versionName-$versionCode.apk"
$storagePath = "$StorageFolder/$storageName"

# Com `allow read: if true`, a URL ?alt=media funciona SEM token de download.
$encoded = [System.Uri]::EscapeDataString($storagePath)
$url = "https://firebasestorage.googleapis.com/v0/b/$Bucket/o/$encoded" + "?alt=media"

Write-Host ''
Write-Host '=== APK ===' -ForegroundColor Cyan
Write-Host "arquivo   : $($file.FullName)"
Write-Host "package   : $package"
Write-Host "tamanho   : $([math]::Round($file.Length / 1MB, 1)) MB"
Write-Host ''
Write-Host '=== 1. Suba o APK no Storage com este nome ===' -ForegroundColor Cyan
Write-Host "  $storagePath" -ForegroundColor Yellow
Write-Host ''
Write-Host '=== 2. Campos de app_config/android ===' -ForegroundColor Cyan
Write-Host ''
Write-Host "latestVersionName        (string)  $versionName"
Write-Host "latestBuildNumber        (number)  $versionCode"
Write-Host "minSupportedBuildNumber  (number)  <voce decide — ver nota>"
Write-Host "apkUrl                   (string)  $url"
Write-Host "apkSha256                (string)  $sha"
Write-Host "apkSizeBytes             (number)  $($file.Length)"
if ($Changelog) {
    Write-Host "changelog                (string)  $Changelog"
} else {
    Write-Host "changelog                (string)  <o que mudou nesta versao>"
}
Write-Host "releasedAt               (timestamp) agora"
Write-Host ''
Write-Host 'NOTA sobre minSupportedBuildNumber:' -ForegroundColor Yellow
Write-Host '  Mantenha o valor ANTERIOR na maioria dos releases. So suba quando'
Write-Host '  a versao antiga realmente quebrar (ex.: mudanca de estrutura no'
Write-Host '  Firestore) — subir sem necessidade tranca o app de quem ainda nao'
Write-Host '  atualizou, sem motivo.'
Write-Host ''
Write-Host 'Confira o SHA-256 depois do upload baixando pela apkUrl e rodando:' -ForegroundColor Cyan
Write-Host "  Get-FileHash <arquivo-baixado> -Algorithm SHA256"
Write-Host ''
