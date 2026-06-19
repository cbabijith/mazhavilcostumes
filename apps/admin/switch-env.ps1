# ============================================================================
# ENV SWITCHER — Rentocostume
# ============================================================================
# Run this script to switch between production and demo environments
#
# Usage:
#   .\switch-env.ps1 production   → Use production Supabase
#   .\switch-env.ps1 demo         → Use demo Supabase (training)
#   .\switch-env.ps1 status       → Show current environment
# ============================================================================

param(
    [Parameter(Position=0)]
    [ValidateSet("production", "demo", "status")]
    [string]$Action = "status"
)

$adminDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$envLocal = Join-Path $adminDir ".env.local"
$envProd  = Join-Path $adminDir ".env.production"
$envDemo  = Join-Path $adminDir ".env.demo"

function Show-Status {
    if (Test-Path $envLocal) {
        $content = Get-Content $envLocal -Raw
        if ($content -match "zbyrwteiuijjbpcrcwdm") {
            Write-Host "Current environment: DEMO (training)" -ForegroundColor Yellow
        } else {
            Write-Host "Current environment: PRODUCTION" -ForegroundColor Green
        }
    } else {
        Write-Host "No .env.local found!" -ForegroundColor Red
    }

    Write-Host ""
    Write-Host "Available env files:"
    if (Test-Path $envProd) { Write-Host "  .env.production  ✓" -ForegroundColor Green }
    else { Write-Host "  .env.production  ✗ (not created yet)" -ForegroundColor Red }
    if (Test-Path $envDemo) { Write-Host "  .env.demo        ✓" -ForegroundColor Green }
    else { Write-Host "  .env.demo        ✗ (not created yet)" -ForegroundColor Red }
}

function Switch-Env {
    param([string]$Target)

    $source = if ($Target -eq "production") { $envProd } else { $envDemo }

    if (-not (Test-Path $source)) {
        Write-Host "Error: .env.$Target does not exist!" -ForegroundColor Red
        Write-Host ""
        Write-Host "To set it up:"
        if ($Target -eq "production") {
            Write-Host "  1. Your current .env.local IS production"
            Write-Host "  2. Run: Copy-Item .env.local .env.production"
        } else {
            Write-Host "  1. Create .env.demo with your demo Supabase credentials"
            Write-Host "  2. Use the same R2 credentials as production (shared bucket)"
        }
        return
    }

    Copy-Item $source $envLocal -Force
    Write-Host "Switched to $Target environment!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Restart your dev server to apply changes:"
    Write-Host "  pnpm --filter admin dev" -ForegroundColor Cyan
}

switch ($Action) {
    "production" { Switch-Env "production" }
    "demo"       { Switch-Env "demo" }
    "status"     { Show-Status }
}
