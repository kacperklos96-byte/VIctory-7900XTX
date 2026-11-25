# Low-memory experimental profile. Use only titles you are authorized to run.
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Exe,
    [switch]$Fast,
    [switch]$Air,
    [switch]$Indirect,
    [switch]$BuildOnly,
    [switch]$Build
)
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$state = Join-Path (Split-Path $root -Parent) ((Split-Path $root -Leaf) + '-NvidiaData')
if (Get-Process victory -ErrorAction SilentlyContinue) { throw 'Close other VIctory sessions first.' }
if ($Build -or $BuildOnly) {
    Push-Location $root
    try {
        & cargo build --locked --profile diag -p victory --features diagnostics
        if ($LASTEXITCODE -ne 0) { throw 'Build failed.' }
    } finally { Pop-Location }
}
if ($BuildOnly) { return }
$Exe = (Resolve-Path -LiteralPath $Exe).Path
if (-not (Test-Path -LiteralPath $Exe -PathType Leaf)) { throw 'Executable not found.' }
if (-not (Test-Path -LiteralPath (Join-Path $root 'target\diag\victory.exe'))) { throw 'Build first using -Build.' }
# The runtime protects the package through its path-taking file imports.
# This is not an OS sandbox; use a separate copy if strict isolation is required.
$previous = @{}
Get-ChildItem Env:VICTORY_* | ForEach-Object { $previous[$_.Name] = $_.Value }
try {
    Get-ChildItem Env:VICTORY_* | ForEach-Object { Remove-Item "Env:$($_.Name)" }
    $env:VICTORY_GAME_DIR = Split-Path $Exe -Parent
    $env:VICTORY_CACHE_DIR = Join-Path $state 'cache'
    $env:VICTORY_DATA_DIR = Join-Path $state 'data'
    New-Item -ItemType Directory -Force $env:VICTORY_CACHE_DIR, $env:VICTORY_DATA_DIR | Out-Null
    $runs = Join-Path $state 'runs'
    New-Item -ItemType Directory -Force $runs | Out-Null
    $log = Join-Path $runs ("run-" + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.log')
    $more = @{
        VICTORY_DISPLAY_MODE = '1280x720'
        VICTORY_CARD_BUFFERS_MB = '512'
        VICTORY_TEXTURE_BUDGET_MB = '768'
        VICTORY_TEXTURE_CATCHUP = '0'
        VICTORY_RIPE_BLOCKS = '2'
        VICTORY_PIPELINE_WORKERS = '3'
        VICTORY_SCREEN_WAIT_MS = '3000'
        VICTORY_THIN_THREADS = '2'
        VICTORY_UNDER_THREADS = '2'
        VICTORY_FAST_CORES = '0'
        VICTORY_SHOW_AFTER = '1'
        VICTORY_WAIT_RESIDENT = '1'
        VICTORY_TEXTURE_NO_WAIT = '0'
        VICTORY_KEEP_SHOWN = '1'
        VICTORY_AMBIENT = '0.8'
        VICTORY_D3D12_DRED = 'light'
        VICTORY_CARD_AWAKE = '0'
        VICTORY_JOIN_PARTS = '1'
    }
    if ($Fast) {
        $more.VICTORY_THIN = '1'
        $more.VICTORY_UPLOAD_AHEAD = '1'
    } else {
        $more.VICTORY_THIN = '0'
        $more.VICTORY_UPLOAD_AHEAD = '0'
    }
    if ($Air) { $more.VICTORY_AMBIENT_AIR = '2' }
    if ($Indirect) { $more.VICTORY_INDIRECT_REST = '0' }
    Write-Host "Isolated state: $state"
    Write-Host "Log: $log"
    & (Join-Path $PSScriptRoot 'play.ps1') -Exe $Exe -Safe -More $more 2>&1 | Tee-Object -FilePath $log
} finally {
    Get-ChildItem Env:VICTORY_* | ForEach-Object { Remove-Item "Env:$($_.Name)" }
    foreach ($key in $previous.Keys) { Set-Item "Env:$key" $previous[$key] }
}
