# Install the consult and grill-me skills into a repository (Windows PowerShell 5.1 or PowerShell 7).
#
# Usage: powershell -ExecutionPolicy Bypass -File .\install.ps1 -Repo C:\path\to\repo [-Skills consult,grill-me] [-DevinCli] [-DryRun]
#
# Each skill goes to <Repo>\.claude\skills\<skill>\ as one real folder (no symlinks). Claude Code,
# GitHub Copilot, Cursor and Devin cloud all read that folder. An existing copy is moved to
# <Repo>\.kos\install\backup\ before it is replaced. -DevinCli also installs to %APPDATA%\devin\skills.
param(
  [Parameter(Mandatory = $true)][string]$Repo,
  [string[]]$Skills = @("consult", "grill-me"),
  [switch]$DevinCli,
  [switch]$DryRun
)
$ErrorActionPreference = "Stop"
$Src = (Get-Item -LiteralPath $PSScriptRoot).FullName
if (-not (Test-Path -LiteralPath $Repo -PathType Container)) { throw "Not a directory: $Repo" }
$Base = (Get-Item -LiteralPath $Repo).FullName
$Exclude = @(".git", "__pycache__", ".DS_Store")

function Copy-Tree([string]$from, [string]$to) {
  New-Item -ItemType Directory -Force -Path $to | Out-Null
  Get-ChildItem -LiteralPath $from -Force | Where-Object { $Exclude -notcontains $_.Name -and $_.Extension -ne ".pyc" } | ForEach-Object {
    $target = Join-Path $to $_.Name
    if ($_.PSIsContainer) { Copy-Tree $_.FullName $target } else { Copy-Item -LiteralPath $_.FullName -Destination $target -Force }
  }
}

function Install-Skill([string]$from, [string]$dest, [string]$work) {
  $fromFull = [IO.Path]::GetFullPath($from).TrimEnd('\')
  $destFull = [IO.Path]::GetFullPath($dest).TrimEnd('\')
  if ($fromFull -eq $destFull) { Write-Host "  $dest is the source itself; nothing to do"; return }
  if (($fromFull + '\').StartsWith($destFull + '\', [StringComparison]::OrdinalIgnoreCase)) {
    throw "Source $fromFull is inside $destFull; run the installer from a separate checkout."
  }
  if ($DryRun) { Write-Host "  would: copy $fromFull -> $destFull"; return }
  $parent = Split-Path -Parent $destFull
  New-Item -ItemType Directory -Force -Path $parent | Out-Null
  # temp copy lives outside every skills folder, so an interrupted run never leaves a second SKILL.md
  $tmp = Join-Path $work ("tmp\" + (Split-Path -Leaf $destFull) + "." + [Guid]::NewGuid().ToString("N").Substring(0, 8))
  Copy-Tree $fromFull $tmp
  if (-not (Test-Path -LiteralPath (Join-Path $tmp "SKILL.md"))) { throw "Copy of $fromFull is incomplete" }
  $existing = Get-Item -LiteralPath $destFull -Force -ErrorAction SilentlyContinue
  if ($existing) {
    if ($existing.LinkType) {
      $existing.Delete()   # removes the link or junction itself, never its target
    } else {
      $bkDir = Join-Path $work "backup"
      New-Item -ItemType Directory -Force -Path $bkDir | Out-Null
      $bk = Join-Path $bkDir ((Split-Path -Leaf $destFull) + "-" + (Get-Date -Format "yyyyMMddHHmmss") + "-" + [Guid]::NewGuid().ToString("N").Substring(0, 6))
      Move-Item -LiteralPath $destFull -Destination $bk
      Write-Host "  previous copy moved to $bk"
    }
  }
  Move-Item -LiteralPath $tmp -Destination $destFull
}

foreach ($s in ($Skills -join ",").Split(",") | Where-Object { $_ }) {
  $from = Join-Path $Src $s
  if (-not (Test-Path -LiteralPath (Join-Path $from "SKILL.md"))) { throw "No skill named '$s' in $Src" }
  Write-Host "Installing $s"
  Install-Skill $from (Join-Path $Base ".claude\skills\$s") (Join-Path $Base ".kos\install")
  if ($DevinCli) { Install-Skill $from (Join-Path $env:APPDATA "devin\skills\$s") (Join-Path $env:APPDATA "devin\.kos-install") }
}
if (-not $DryRun) {
  Write-Host "Done. Skills are in $Base\.claude\skills\ (Claude Code, Copilot, Cursor, Devin cloud)."
  Write-Host "Tip: add '.kos/' to .gitignore (saved maps and installer backups live there)."
}
