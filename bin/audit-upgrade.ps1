$ErrorActionPreference = 'Continue'
$cv = "C:\Users\user\scoop\apps\scoop\current\bin\checkver.ps1"
$src = "C:\Users\user\Desktop\scoop-proxy\bucket"
$t = Join-Path $env:TEMP "upgrade-audit"
if (Test-Path $t) { Remove-Item $t -Recurse -Force }
New-Item -ItemType Directory $t | Out-Null

function Get-Hashes($m) {
    $h = @()
    if ($m.PSObject.Properties['hash']) { $h += $m.hash }
    if ($m.architecture) {
        $m.architecture.PSObject.Properties | ForEach-Object { if ($_.Value.hash) { $h += $_.Value.hash } }
    }
    return $h
}

Get-ChildItem $src -Filter *.json | ForEach-Object {
    $n = $_.BaseName
    $orig = Get-Content $_.FullName -Raw | ConvertFrom-Json
    $m = Get-Content $_.FullName -Raw | ConvertFrom-Json
    $m.version = '0.0.0-test'
    [IO.File]::WriteAllText("$t\$n.json", ($m | ConvertTo-Json -Depth 32), [System.Text.UTF8Encoding]::new($false))
    $null = & $cv $n -Dir $t -Update 2>&1
    $u = Get-Content "$t\$n.json" -Raw | ConvertFrom-Json
    $newv = $u.version

    $hashes = @(Get-Hashes $u)
    $origHashes = @(Get-Hashes $orig) | ForEach-Object { $_.ToLower() }

    $hashOk = if ($n -eq 'uu-remote') { 'n/a(CI backfill)' }
        elseif ($hashes.Count -eq 0) { 'NO HASH!' }
        elseif (($hashes | Where-Object { $_ -notmatch '^[0-9a-f]{64}$' }).Count -gt 0) { 'INVALID FORMAT' }
        else {
            $same = $true
            foreach ($h in $hashes) { if ($h.ToLower() -notin $origHashes) { $same = $false } }
            if ($same) { 'match' } else { 'CHANGED!' }
        }

    $urls = @()
    if ($u.PSObject.Properties['url'] -and $u.url) { $urls += $u.url }
    if ($u.architecture) { $u.architecture.PSObject.Properties | ForEach-Object { if ($_.Value.url) { $urls += $_.Value.url } } }
    $substOk = $true
    foreach ($ul in $urls) {
        if ($ul -match '\$version' -and $n -ne 'uu-remote' -and $ul -notlike "*$newv*") { $substOk = $false }
    }
    "AUDIT $n -> v$newv | hashes=$($hashes.Count) [$hashOk] | url-subst=$substOk"
}
