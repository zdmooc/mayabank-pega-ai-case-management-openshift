param(
    [string]$Pe84Root = 'C:\workspaces\paga\116674_PE8.4.0\PRPC_PE\PersonalEdition'
)

$ErrorActionPreference = 'Continue'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$outDir = Join-Path $repoRoot "evidence\runtime\pe84-local\$timestamp"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$summary = New-Object System.Collections.Generic.List[string]
function Add-Summary([string]$line) { $summary.Add($line) | Out-Null }
function Save-Text([string]$name, $value) {
    $value | Out-File -FilePath (Join-Path $outDir $name) -Encoding utf8
}

Add-Summary '# Pega 8.4 Personal Edition — Local Evidence'
Add-Summary ''
Add-Summary "- Timestamp: $(Get-Date -Format o)"
Add-Summary "- Root: `$Pe84Root`"

if (-not (Test-Path $Pe84Root)) {
    Add-Summary '- Root status: NOT FOUND'
    $summary | Out-File (Join-Path $outDir 'SUMMARY.md') -Encoding utf8
    Write-Error "Pega Personal Edition root not found: $Pe84Root"
    exit 2
}
Add-Summary '- Root status: FOUND'

# Java/JRE
$java = Join-Path $Pe84Root 'jre1.8.0_121\bin\java.exe'
if (Test-Path $java) {
    $javaVersion = (& $java -version 2>&1 | Out-String).Trim()
    Save-Text 'java-version.txt' $javaVersion
    Add-Summary '- Java: FOUND (see java-version.txt)'
} else {
    Add-Summary '- Java: bundled jre1.8.0_121 not found at expected path'
}

# Tomcat
$tomcatVersionBat = Join-Path $Pe84Root 'tomcat\bin\version.bat'
if (Test-Path $tomcatVersionBat) {
    $tomcatVersion = (& cmd.exe /c "`"$tomcatVersionBat`"" 2>&1 | Out-String).Trim()
    Save-Text 'tomcat-version.txt' $tomcatVersion
    Add-Summary '- Tomcat: FOUND (see tomcat-version.txt)'
} else {
    Add-Summary '- Tomcat version script: NOT FOUND'
}

# PostgreSQL
$postgres = Join-Path $Pe84Root 'pgsql\bin\postgres.exe'
if (Test-Path $postgres) {
    $postgresVersion = (& $postgres --version 2>&1 | Out-String).Trim()
    Save-Text 'postgres-version.txt' $postgresVersion
    Add-Summary '- PostgreSQL: FOUND (see postgres-version.txt)'
} else {
    Add-Summary '- PostgreSQL binary: NOT FOUND'
}

# Important artifacts: metadata only, never copy binaries.
$artifacts = @(
    (Join-Path $Pe84Root 'tomcat\webapps\prweb.war'),
    (Join-Path $Pe84Root 'tomcat\webapps\prhelp.war'),
    (Join-Path $Pe84Root 'tomcat\lib\postgresql-42.0.0.jar')
)
$artifactRows = @()
foreach ($artifact in $artifacts) {
    if (Test-Path $artifact) {
        $item = Get-Item $artifact
        $hash = Get-FileHash -Algorithm SHA256 $artifact
        $artifactRows += [pscustomobject]@{
            Name = $item.Name
            Path = $item.FullName
            LengthBytes = $item.Length
            LastWriteTime = $item.LastWriteTime.ToString('o')
            SHA256 = $hash.Hash
        }
        Add-Summary "- Artifact $($item.Name): FOUND, $($item.Length) bytes"
    } else {
        Add-Summary "- Artifact $(Split-Path $artifact -Leaf): NOT FOUND"
    }
}
$artifactRows | ConvertTo-Json -Depth 3 | Save-Text 'artifact-metadata.json'

# Expanded prweb presence (names/count only, no proprietary contents copied).
$expandedPrweb = Join-Path $Pe84Root 'tomcat\webapps\prweb'
if (Test-Path $expandedPrweb) {
    $expandedFiles = @(Get-ChildItem -Path $expandedPrweb -File -Recurse -ErrorAction SilentlyContinue)
    Add-Summary "- Expanded prweb directory: FOUND ($($expandedFiles.Count) files)"
    Get-ChildItem -Path $expandedPrweb -Force -ErrorAction SilentlyContinue |
        Select-Object Name, Mode, Length, LastWriteTime |
        Format-Table -AutoSize | Out-String | Save-Text 'prweb-top-level.txt'
} else {
    Add-Summary '- Expanded prweb directory: NOT FOUND'
}

# Configuration presence only. Do not copy configuration contents automatically.
$configPaths = @(
    'tomcat\conf\server.xml',
    'tomcat\conf\context.xml',
    'tomcat\conf\catalina.properties',
    'tomcat\conf\web.xml',
    'scripts\startup.bat',
    'scripts\shutdown.bat',
    'scripts\pg_env.bat'
)
$configRows = foreach ($relative in $configPaths) {
    $full = Join-Path $Pe84Root $relative
    [pscustomobject]@{ RelativePath = $relative; Present = (Test-Path $full) }
}
$configRows | ConvertTo-Json | Save-Text 'config-presence.json'

# Local ports: metadata only.
$portRows = @()
foreach ($port in @(8080, 5432)) {
    $connections = @(Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue)
    if ($connections.Count -gt 0) {
        foreach ($connection in $connections) {
            $portRows += [pscustomobject]@{
                LocalPort = $port
                State = $connection.State
                OwningProcess = $connection.OwningProcess
            }
        }
        Add-Summary "- TCP $port: LISTENING"
    } else {
        Add-Summary "- TCP $port: not listening"
    }
}
$portRows | ConvertTo-Json | Save-Text 'listening-ports.json'

# Non-authenticated reachability probe only.
$probeUrl = 'http://127.0.0.1:8080/prweb/'
try {
    $response = Invoke-WebRequest -Uri $probeUrl -UseBasicParsing -TimeoutSec 10
    Add-Summary "- HTTP probe $probeUrl: $($response.StatusCode)"
    Save-Text 'http-probe.txt' "URL=$probeUrl`nStatusCode=$($response.StatusCode)`nStatusDescription=$($response.StatusDescription)"
} catch {
    Add-Summary "- HTTP probe $probeUrl: FAILED / not reachable"
    Save-Text 'http-probe.txt' "URL=$probeUrl`nResult=FAILED`nError=$($_.Exception.Message)"
}

Add-Summary ''
Add-Summary '## Interpretation'
Add-Summary ''
Add-Summary 'This collection proves only local technical facts. It does not by itself prove a successful authenticated Pega login, functional Case Management, or OpenShift compatibility.'

$summary | Out-File (Join-Path $outDir 'SUMMARY.md') -Encoding utf8
Write-Host "Evidence written to: $outDir"
Write-Host "Review/redact outputs before committing any evidence."
