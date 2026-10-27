# Build Rexx/SQL 2.6 beta 3 against ooRexx, with SQLite 3, on Windows x64
# with Microsoft Visual C++ (run from a Developer PowerShell, or after
# setting up the MSVC environment: cl, link, lib, rc, nmake on the PATH).
#
# Downloads the author's source release (pinned by checksum) and builds it
# with its own makefile, vcwin64.mak, unchanged. The settings passed to it:
#
#   INT=OOREXX4      the makefile's target for ooRexx 4.0 and later
#                    (defines USE_OOREXX and OOREXX_40).
#   OOREXX4_REXXINC, where ooRexx's headers and import libraries are: the
#   OOREXX4_REXXLIBS makefile expects them in REXX_HOME\api; ooRexx 5
#                    keeps them in REXX_HOME\include and REXX_HOME\lib.
#   DB=LITE,         SQLite 3. sqlite3.lib is built here, as a static
#   SQLITE3_HOMEDIR  library, from SQLite's official amalgamation (pinned
#                    by checksum).
#
# The makefile runs two Rexx helper scripts of the package (makedef.rexx,
# fixrc.rexx) with `rexx`, so ooRexx's bin folder must be on the PATH.
#
# Usage: rexxsql\build-windows.ps1 -RexxHome <ooRexx folder> [-Work <dir>]
#
# This file is under the GNU Library General Public License version 2,
# the licence of Rexx/SQL (see LICENSE in this folder).

param(
  [Parameter(Mandatory = $true)][string]$RexxHome,
  [string]$Work = "build\rexxsql"
)

$ErrorActionPreference = "Stop"

$Version   = "2.6B3"
$Zip       = "rxsql26B3_src.zip"
$Url       = "https://downloads.sourceforge.net/project/rexxsql/rexxsql/2.6/$Zip"
$Sha256    = "57e5b7082ce141820c0fd6c8a26e0c82da8b625f090ff454497d62fd1f8e59e8"

$SqliteZip = "sqlite-amalgamation-3540100.zip"
$SqliteUrl = "https://www.sqlite.org/2026/$SqliteZip"
$SqliteSha = "0a9c8e34352dad46006aa82836d5383bff9dc6bc9ce5a60553c05aa30e6ad1f9"

function Get-Pinned($url, $file, $sha) {
  if (-not (Test-Path $file)) {
    & curl.exe -fsSL -o $file $url
    if ($LASTEXITCODE -ne 0) { throw "download failed: $url" }
  }
  $got = (Get-FileHash -Algorithm SHA256 $file).Hash.ToLower()
  if ($got -ne $sha) { throw "checksum mismatch for ${file}: $got" }
}

function Invoke-Checked($exe, [string[]]$arguments) {
  & $exe @arguments
  if ($LASTEXITCODE -ne 0) { throw "$exe failed with exit code $LASTEXITCODE" }
}

$RexxHome = (Resolve-Path $RexxHome).Path
New-Item -ItemType Directory -Force $Work | Out-Null
$Work = (Resolve-Path $Work).Path
Set-Location $Work

# SQLite 3 as a static library, with the same runtime as Rexx/SQL (-MT).
Get-Pinned $SqliteUrl $SqliteZip $SqliteSha
Remove-Item -Recurse -Force sqlite -ErrorAction SilentlyContinue
Expand-Archive $SqliteZip -DestinationPath sqlite-src
New-Item -ItemType Directory -Force sqlite\include, sqlite\lib | Out-Null
$amalg = Get-ChildItem sqlite-src -Directory | Select-Object -First 1
Copy-Item "$($amalg.FullName)\sqlite3.h" sqlite\include\
Push-Location sqlite\lib
Invoke-Checked cl @("-nologo", "-c", "-O2", "-MT", "$($amalg.FullName)\sqlite3.c")
Invoke-Checked lib @("-nologo", "-out:sqlite3.lib", "sqlite3.obj")
Pop-Location
Remove-Item -Recurse -Force sqlite-src

# Rexx/SQL
Get-Pinned $Url $Zip $Sha256
Remove-Item -Recurse -Force src, obj -ErrorAction SilentlyContinue
Expand-Archive $Zip -DestinationPath src
New-Item -ItemType Directory -Force obj | Out-Null
Set-Location obj

Invoke-Checked nmake @(
  "-nologo", "-f", "$Work\src\vcwin64.mak",
  "REXXSQL_SRCDIR=$Work\src",
  "INT=OOREXX4", "DB=LITE",
  "OOREXX4_REXXINC=-I$RexxHome\include -DUSE_OOREXX -DOOREXX_40",
  "OOREXX4_REXXLIBS=$RexxHome\lib\rexx.lib $RexxHome\lib\rexxapi.lib",
  "SQLITE3_HOMEDIR=$Work\sqlite",
  "rexxsql.dll", "rexxsql.exe"
)

Write-Host "Built Rexx/SQL $Version for ooRexx in ${Work}\obj:"
Get-ChildItem rexxsql.dll, rexxsql.exe | Format-Table Name, Length
