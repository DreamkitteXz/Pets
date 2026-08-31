<#
.SYNOPSIS
    Gera o keystore de release e escreve android/key.properties.

.DESCRIPTION
    Faz na sua máquina o único passo que não pode ser automatizado de fora: a
    criação da chave de assinatura. As senhas são digitadas em campo oculto e
    nunca aparecem em linha de comando, histórico de shell ou log.

    O keystore é gravado FORA do repositório. O key.properties gerado é
    ignorado pelo git (android/.gitignore).

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File tool\setup_release_signing.ps1
#>

[CmdletBinding()]
param(
    # Onde gravar o .jks. Padrão: fora do repo, no perfil do usuário.
    [string]$KeystorePath = "$env:USERPROFILE\keystores\pet-app-release.jks",
    [string]$Alias = 'pet-app',
    [int]$ValidityDays = 10000
)

$ErrorActionPreference = 'Stop'

# O console do Windows abre em codepage 850/1252 e lê este arquivo (UTF-8) com
# a tabela errada — acentos saem como "CÃ“PIA". Alinhar a saída em UTF-8 corrige
# sem depender de `chcp` na sessão do usuário.
try {
    [Console]::OutputEncoding = [Text.Encoding]::UTF8
    $OutputEncoding = [Text.Encoding]::UTF8
} catch {
    # Console redirecionado ou host sem suporte: segue sem acento bonito.
}

function Find-Keytool {
    $cmd = Get-Command keytool -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }

    # Fallback: JDK que acompanha o Android Studio (o mesmo que o Gradle usa).
    $candidates = @(
        "$env:ProgramFiles\Android\Android Studio\jbr\bin\keytool.exe",
        "${env:ProgramFiles(x86)}\Android\Android Studio\jbr\bin\keytool.exe",
        "$env:LOCALAPPDATA\Programs\Android Studio\jbr\bin\keytool.exe"
    )
    foreach ($c in $candidates) {
        if (Test-Path $c) { return $c }
    }
    throw "keytool não encontrado. Instale um JDK ou o Android Studio."
}

function Read-Secret([string]$Prompt) {
    $secure = Read-Host -Prompt $Prompt -AsSecureString
    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
    try {
        return [Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
    } finally {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
    }
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$keyProperties = Join-Path $repoRoot 'android\key.properties'
$keytool = Find-Keytool

Write-Host ''
Write-Host 'Assinatura de release — Pet App' -ForegroundColor Cyan
Write-Host "keytool  : $keytool"
Write-Host "keystore : $KeystorePath"
Write-Host "alias    : $Alias"
Write-Host ''

# ── Guarda contra destruição ────────────────────────────────────────────────
# Sobrescrever um keystore existente é IRREVERSÍVEL: os APKs já distribuídos
# deixam de poder ser atualizados, porque a assinatura não bate mais.
if (Test-Path $KeystorePath) {
    Write-Host "JÁ EXISTE um keystore em:" -ForegroundColor Yellow
    Write-Host "  $KeystorePath"
    Write-Host ''
    Write-Host 'Sobrescrever quebraria a atualização de todo APK já instalado.' -ForegroundColor Yellow
    Write-Host 'Este script NÃO vai tocar nele. Se quer mesmo uma chave nova,'
    Write-Host 'mova a antiga para outro lugar e rode de novo.'
    exit 1
}

$keystoreDir = Split-Path -Parent $KeystorePath
if (-not (Test-Path $keystoreDir)) {
    New-Item -ItemType Directory -Path $keystoreDir -Force | Out-Null
    Write-Host "Pasta criada: $keystoreDir"
}

# ── Senhas ──────────────────────────────────────────────────────────────────
$storePass = Read-Secret 'Senha do keystore (min. 6 caracteres)'
if ($storePass.Length -lt 6) { throw 'A senha precisa ter ao menos 6 caracteres.' }
$storePassConfirm = Read-Secret 'Repita a senha do keystore'
if ($storePass -ne $storePassConfirm) { throw 'As senhas não conferem.' }

Write-Host ''
Write-Host 'Enter vazio usa a mesma senha para a chave (o mais comum).'
$keyPass = Read-Secret "Senha da chave '$Alias' [Enter = mesma do keystore]"
if ([string]::IsNullOrEmpty($keyPass)) { $keyPass = $storePass }

Write-Host ''
$dname = Read-Host 'Nome/organização para o certificado (ex.: Kayque Amado)'
if ([string]::IsNullOrWhiteSpace($dname)) { $dname = 'Pet App' }

# ── Geração ─────────────────────────────────────────────────────────────────
# As senhas vão por STDIN, não como argumento: argumento apareceria na lista de
# processos e ficaria legível por outros usuários da máquina enquanto roda.
Write-Host ''
Write-Host 'Gerando a chave...' -ForegroundColor Cyan

$keytoolArgs = @(
    '-genkeypair', '-v',
    '-keystore', $KeystorePath,
    # Sem -storetype: o JDK moderno usa PKCS12 por padrão. Forçar JKS faz o
    # keytool avisar que é "formato proprietário" e recomendar a migração —
    # PKCS12 é o padrão da indústria e o AGP lê sem configuração extra.
    '-keyalg', 'RSA',
    '-keysize', '2048',
    '-validity', "$ValidityDays",
    '-alias', $Alias,
    '-dname', "CN=$dname, OU=, O=, L=, S=, C=BR",
    '-storepass:env', 'PETAPP_STOREPASS',
    '-keypass:env', 'PETAPP_KEYPASS'
)

$env:PETAPP_STOREPASS = $storePass
$env:PETAPP_KEYPASS = $keyPass
try {
    & $keytool @keytoolArgs
    if ($LASTEXITCODE -ne 0) { throw "keytool falhou (código $LASTEXITCODE)." }
} finally {
    Remove-Item Env:PETAPP_STOREPASS -ErrorAction SilentlyContinue
    Remove-Item Env:PETAPP_KEYPASS -ErrorAction SilentlyContinue
}

# ── key.properties ──────────────────────────────────────────────────────────
# Barras normais: Properties do Java trata "\" como escape e "C:\Users" viraria
# um caminho corrompido em silêncio.
$storeFileForGradle = $KeystorePath -replace '\\', '/'

$content = @"
# Gerado por tool/setup_release_signing.ps1 — NÃO versionar.
storeFile=$storeFileForGradle
storePassword=$storePass
keyAlias=$Alias
keyPassword=$keyPass
"@

Set-Content -Path $keyProperties -Value $content -Encoding utf8 -NoNewline
Write-Host ''
Write-Host "key.properties escrito em: $keyProperties" -ForegroundColor Green

# ── Conferência ─────────────────────────────────────────────────────────────
Write-Host ''
Write-Host 'Conferindo se o git está ignorando os segredos...' -ForegroundColor Cyan
Push-Location $repoRoot
try {
    git check-ignore -q 'android/key.properties'
    if ($LASTEXITCODE -eq 0) {
        Write-Host '  OK  android/key.properties ignorado pelo git' -ForegroundColor Green
    } else {
        Write-Host '  ATENÇÃO: key.properties NÃO está sendo ignorado!' -ForegroundColor Red
    }
} finally {
    Pop-Location
}

Write-Host ''
Write-Host 'Pronto. Agora:' -ForegroundColor Cyan
Write-Host '  flutter build apk --release'
Write-Host ''
Write-Host 'GUARDE UMA CÓPIA DO KEYSTORE fora desta máquina.' -ForegroundColor Yellow
Write-Host 'Perdê-lo significa nunca mais conseguir atualizar os APKs já'
Write-Host 'instalados — sem recuperação possível fora da Play Store.'
Write-Host ''
