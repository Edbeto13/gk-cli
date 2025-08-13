<#
.SYNOPSIS
    Instalación y configuración de GitKraken CLI (gk) en Windows 11 con integración en VS Code.
.DESCRIPTION
    Este script:
    1. Verifica dependencias (Git, winget).
    2. Instala GitKraken CLI si no existe.
    3. Valida instalación.
    4. Integra `gk` en terminales de VS Code.
    5. Ofrece autenticación inicial.
.NOTES
    Autor: Edson Onboarding Template
    Fecha: (Get-Date -Format 'yyyy-MM-dd')
#>

param(
    [switch]$ForceReinstall
)

Write-Host "Verificando dependencias..." -ForegroundColor Cyan

# 1️⃣ Verificar Git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Instalando Git..." -ForegroundColor Yellow
    winget install --id Git.Git -e --source winget
} else {
    Write-Host "Git detectado: $(git --version)" -ForegroundColor Green
}

# 2️⃣ Verificar winget
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "winget no detectado. Debes instalarlo desde Microsoft Store antes de continuar." -ForegroundColor Red
    exit 1
}

# 3️⃣ Instalar/Reinstalar GitKraken CLI
$pkgId = 'GitKraken.cli'  # id oficial en winget
$needInstall = $ForceReinstall -or -not (Get-Command gk -ErrorAction SilentlyContinue)
if ($needInstall) {
    if ($ForceReinstall) {
    Write-Host "Reinstalando GitKraken CLI..." -ForegroundColor Yellow
        winget uninstall $pkgId -h --source winget | Out-Null
    } else {
    Write-Host "Instalando GitKraken CLI..." -ForegroundColor Yellow
    }
    winget install --id $pkgId -e --source winget
} else {
    Write-Host "GitKraken CLI ya instalado: $(gk version)" -ForegroundColor Green
}

# Validar instalacion y alias de sesion si PATH no refresco
$gk = Get-Command gk -ErrorAction SilentlyContinue
if (-not $gk) {
    # Buscar gk.exe instalado por winget
    $gkExe = Get-ChildItem "$Env:LOCALAPPDATA" -Recurse -Filter gk.exe -ErrorAction SilentlyContinue | Where-Object { $_.FullName -match "WinGet\\Packages\\GitKraken\.cli" } | Select-Object -First 1 -ExpandProperty FullName
    if ($gkExe) {
        Write-Host "Configurando alias temporal 'gk' en esta sesion..." -ForegroundColor Yellow
        Set-Alias -Name gk -Value $gkExe -Scope Global
    }
}

if (Get-Command gk -ErrorAction SilentlyContinue) {
    Write-Host "Validacion OK: $(gk version)" -ForegroundColor Green
} else {
    Write-Host "Error: gk no se pudo instalar o no esta en PATH. Abre una nueva terminal y reintenta, o ejecuta el script con -ForceReinstall." -ForegroundColor Red
    exit 1
}

# Integrar con VS Code (opcional) - instalar extension MCP client si existe
Write-Host "Integrando con VS Code..." -ForegroundColor Cyan
try {
    if (Get-Command code -ErrorAction SilentlyContinue) {
        code --install-extension ms-vscode.vscode-mcp | Out-Null
    } else {
        Write-Host "VS Code CLI 'code' no detectado, omitiendo instalacion de extension." -ForegroundColor DarkYellow
    }
} catch {
    Write-Host "No se pudo instalar la extension, continuando..." -ForegroundColor DarkYellow
}

# Autenticacion inicial
Write-Host "Ejecutando 'gk auth login'... esto abrira el navegador" -ForegroundColor Magenta
try {
    gk auth login
} catch {
    Write-Host "Si falla, reabre una nueva terminal o ejecuta: gk auth login -v" -ForegroundColor DarkYellow
}

Write-Host "Instalacion y configuracion completadas." -ForegroundColor Green
