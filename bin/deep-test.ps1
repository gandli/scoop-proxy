#Requires -Version 5.1
<#
.SYNOPSIS
    Deep validation for the bucket: cross-manifest consistency, URL liveness,
    autoupdate expansion and version resolution.

.NOTES
    Exit code = number of hard failures. Warnings do not fail the run.
    Set GH_TOKEN env var to authenticate GitHub API calls (rate limits).
#>
[CmdletBinding()]
param([switch]$SkipOnline)

$ErrorActionPreference = 'Continue'
$bucketRoot = Split-Path $PSScriptRoot -Parent
$bucketDir = Join-Path $bucketRoot 'bucket'
$UA = 'Scoop/1.0 (+https://github.com/gandli/scoop-proxy)'
$script:Failed = 0
$script:Warned = 0

function Write-Result([bool]$ok, [string]$name, [string]$detail, [switch]$IsWarn) {
    if ($ok) { Write-Host "  [PASS] $name" }
    elseif ($IsWarn) { $script:Warned++; Write-Host "  [WARN] $name : $detail" }
    else { $script:Failed++; Write-Host "  [FAIL] $name : $detail" }
}

function Test-Url([string]$url, [string]$name) {
    if ([string]::IsNullOrWhiteSpace($url)) { Write-Result $false $name 'empty url'; return }
    $target = ($url -split '#')[0]
    for ($i = 0; $i -lt 2; $i++) {
        try {
            $resp = Invoke-WebRequest -Uri $target -Method Head -UserAgent $UA -UseBasicParsing -MaximumRedirection 5 -TimeoutSec 30 -ErrorAction Stop
            if ($resp.StatusCode -ge 200 -and $resp.StatusCode -lt 300) { Write-Result $true $name; return }
        } catch {
            $code = $null
            if ($_.Exception.Response) { $code = [int]$_.Exception.Response.StatusCode }
            if ($code -in 429, 403, 503) { Write-Result $false $name "HTTP $code (rate limited / transient)" -IsWarn; return }
            if ($i -eq 0) { Start-Sleep 2; continue }
            Write-Result $false $name "HTTP $code / $($_.Exception.Message)"
            return
        }
    }
}

# checkver: use $env:SCOOP_HOME if set (CI), else the local scoop install
$checkver = if ($env:SCOOP_HOME) { Join-Path $env:SCOOP_HOME 'bin\checkver.ps1' }
            else { "$env:USERPROFILE\scoop\apps\scoop\current\bin\checkver.ps1" }

$manifests = Get-ChildItem $bucketDir -Filter *.json

Write-Host "`n=== Layer 2: cross-manifest consistency ==="
$allBins = @{}
foreach ($f in $manifests) {
    $m = Get-Content $f.FullName -Raw | ConvertFrom-Json
    $name = $f.BaseName
    if (-not $m.bin) { continue }
    foreach ($b in @($m.bin)) {
        if ($null -eq $b) { continue }
        if ($b -is [string]) { $binName = $b }
        elseif ($b.Count -gt 1) { $binName = $b[1] }
        else { $binName = $b[0] }
        $binName = ($binName -replace '\.exe$', '').ToLower()
        if ($allBins.ContainsKey($binName) -and $allBins[$binName] -ne $name) {
            Write-Result $false "shim '$binName'" "collision between $name and $($allBins[$binName])"
        }
        $allBins[$binName] = $name
    }
}
Write-Result $true "shim uniqueness ($($allBins.Count) shims across $($manifests.Count) manifests)"

Write-Host "`n=== Layer 3: URL liveness ==="
foreach ($f in $manifests) {
    $m = Get-Content $f.FullName -Raw | ConvertFrom-Json
    $name = $f.BaseName
    Test-Url $m.homepage "$name homepage"
    $licenseUrl = $m.license.url
    if ($licenseUrl -and $licenseUrl -match '^https?://') { Test-Url $licenseUrl "$name license.url" }
    if ($SkipOnline) { continue }
    foreach ($prop in $m.architecture.PSObject.Properties) {
        foreach ($u in @($prop.Value.url)) { Test-Url $u "$name/$($prop.Name) install url" }
    }
}

Write-Host "`n=== Layer 4: autoupdate expansion + version resolution ==="
$temp = Join-Path $env:TEMP 'deep-test'
if (Test-Path $temp) { Remove-Item $temp -Recurse -Force }
New-Item -ItemType Directory $temp | Out-Null
# manifests whose hashes are backfilled by the auto-update workflow (no upstream hash source)
$backfillList = @('uu-remote')

foreach ($f in $manifests) {
    $name = $f.BaseName
    $real = Get-Content $f.FullName -Raw | ConvertFrom-Json

    # expand autoupdate on a fake-version copy: the resolved version and
    # expanded urls/hashes both come out of the updated manifest
    $copy = Get-Content $f.FullName -Raw | ConvertFrom-Json
    $copy.version = '0.0.0-audit'
    $copyPath = Join-Path $temp "$name.json"
    [IO.File]::WriteAllText($copyPath, ($copy | ConvertTo-Json -Depth 32), [System.Text.UTF8Encoding]::new($false))
    $null = & $checkver $name -Dir $temp -Update 2>&1
    $updated = Get-Content $copyPath -Raw | ConvertFrom-Json
    $resolved = $updated.version

    if ($resolved -match '^\d[\w.\-+]*$') {
        if ($resolved -ne $real.version) {
            Write-Host "  [INFO] $name manifest=$($real.version) upstream=$resolved"
        }
        Write-Result $true "$name version resolution"
    } else {
        Write-Result $false "$name version resolution" "unresolvable: $resolved"
        continue
    }

    $archCount = 0; $expandOk = $true; $hashOk = $true; $detail = @()
    $urlGroups = @()
    if ($updated.url) { $urlGroups += @($updated.url) }
    if ($updated.architecture) {
        foreach ($prop in $updated.architecture.PSObject.Properties) {
            $archCount++
            $urlGroups += @($prop.Value.url)
            $hashConf = $prop.Value.hash
            $isGithub = ((@($prop.Value.url)[0]) -split '#')[0] -match 'github\.com/[^/]+/[^/]+/releases/download/'
            if (-not $hashConf -and -not $isGithub -and $name -notin $backfillList) {
                $hashOk = $false; $detail += "no hash source for $($prop.Name)"
            }
            if ($hashConf -and $hashConf.url -match '^https?://') {
                $hUrl = ($hashConf.url -split '#')[0]
                try {
                    $h = (Invoke-WebRequest -Uri $hUrl -UserAgent $UA -UseBasicParsing -TimeoutSec 30).Content
                    if ($h -notmatch '[a-fA-F0-9]{64}') { $hashOk = $false; $detail += "hash url returned no sha256: $hUrl" }
                } catch { $hashOk = $false; $detail += "hash url unreachable: $hUrl" }
            }
        }
    }
    foreach ($u in $urlGroups) {
        if ($u -match '\$version|0\.0\.0-audit|\$basename|\$match') { $expandOk = $false; $detail += "unexpanded url: $u" }
    }
    Write-Result ($expandOk -and $hashOk) "$name autoupdate ($archCount arch)" ($detail -join '; ')
}

Write-Host "`n=== Summary: $($manifests.Count) manifests | FAIL $script:Failed | WARN $script:Warned ==="
exit $script:Failed
