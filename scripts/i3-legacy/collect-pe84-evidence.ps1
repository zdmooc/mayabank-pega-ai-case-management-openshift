param(
    [string]$Pe84Root = 'C:\workspaces\paga\116674_PE8.4.0\PRPC_PE\PersonalEdition'
)

$ErrorActionPreference = 'Continue'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$outDir = Join-Path $repoRoot ("evidence\runtime\pe84-local\{0}" -f $timestamp)
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$summary = New-Object System.Collections.Generic.List[string]

function Add-Summary([string]$line) {
    $summary.Add($line) | Out-Null
}

function Save-Text([string]$name, $value) {
    $target = Join-Path $outDir $name
    $value | Out-File -FilePath $target -Encoding utf8
}

Add-Summary '# Pega 8.4 Personal Edition - Local Evidence'
Add-Summary ''
Add-Summary ("- Timestamp: {0}" -f (Get-Date -Format o))
Add-Summary ("- Root: {0}" -f $Pe84Root)

if (-not (Test-Path -LiteralPath $Pe84Root)) {
    Add-Summary '- Root status: NOT FOUND'
    $summary | Out-File (Join-Path $outDir 'SUMMARY.md') -Encoding utf8
    Write-Error ("Pega Personal Edition root not found: {0}" -f $Pe84Root)
    exit 2
}
Add-Summary '- Root status: FOUND'

# Java/JRE
$java = Join-Path $Pe84Root 'jre1.8.0_121\bin\java.exe'
if (Test-Path -LiteralPath $java) {
    $javaVersion = (& $java -version 2>&1 | Out-String).Trim()
    Save-Text 'java-version.txt' $javaVersion
    Add-Summary '- Java: FOUND (see java-version.txt)'
} else {
    Add-Summary '- Java: bundled jre1.8.0_121 not found at expected path'
}

# Tomcat
$tomcatVersionBat = Join-Path $Pe84Root 'tomcat\bin\version.bat'
if (Test-Path -LiteralPath $tomcatVersionBat) {
    $tomcatVersion = (& cmd.exe /d /c ('"{0}"' -f $tomcatVersionBat) 2>&1 | Out-String).Trim()
    Save-Text 'tomcat-version.txt' $tomcatVersion
    Add-Summary '- Tomcat: FOUND (see tomcat-version.txt)'
} else {
    Add-Summary '- Tomcat version script: NOT FOUND'
}

# PostgreSQL
$postgres = Join-Path $Pe84Root 'pgsql\bin\postgres.exe'
if (Test-Path -LiteralPath $postgres) {
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
    if (Test-Path -LiteralPath $artifact) {
        $item = Get-Item -LiteralPath $artifact
        $hash = Get-FileHash -Algorithm SHA256 -LiteralPath $artifact
        $artifactRows += [pscustomobject]@{
            Name = $item.Name
            Path = $item.FullName
            LengthBytes = $item.Length
            LastWriteTime = $item.LastWriteTime.ToString('o')
            SHA256 = $hash.Hash
        }
        Add-Summary ("- Artifact {0}: FOUND, {1} bytes" -f $item.Name, $item.Length)
    } else {
        Add-Summary ("- Artifact {0}: NOT FOUND" -f (Split-Path $artifact -Leaf))
    }
}
$artifactJson = $artifactRows | ConvertTo-Json -Depth 3
Save-Text 'artifact-metadata.json' $artifactJson

# Expanded prweb presence (names/count only, no proprietary contents copied).
$expandedPrweb = Join-Path $Pe84Root 'tomcat\webapps\prweb'
if (Test-Path -LiteralPath $expandedPrweb) {
    $expandedFiles = @(Get-ChildItem -LiteralPath $expandedPrweb -File -Recurse -ErrorAction SilentlyContinue)
    Add-Summary ("- Expanded prweb directory: FOUND ({0} files)" -f $expandedFiles.Count)
    $prwebTopLevel = Get-ChildItem -LiteralPath $expandedPrweb -Force -ErrorAction SilentlyContinue |
        Select-Object Name, Mode, Length, LastWriteTime |
        Format-Table -AutoSize |
        Out-String
    Save-Text 'prweb-top-level.txt' $prwebTopLevel
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
    [pscustomobject]@{
        RelativePath = $relative
        Present = (Test-Path -LiteralPath $full)
    }
}
$configJson = $configRows | ConvertTo-Json -Depth 3
Save-Text 'config-presence.json' $configJson

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
        Add-Summary ("- TCP {0}: LISTENING" -f $port)
    } else {
        Add-Summary ("- TCP {0}: not listening" -f $port)
    }
}
$portsJson = $portRows | ConvertTo-Json -Depth 3
Save-Text 'listening-ports.json' $portsJson

# Non-authenticated reachability probe only.
$probeUrl = 'http://127.0.0.1:8080/prweb/'
try {
    $response = Invoke-WebRequest -Uri $probeUrl -UseBasicParsing -TimeoutSec 10
    Add-Summary ("- HTTP probe {0}: {1}" -f $probeUrl, $response.StatusCode)
    $httpProbe = "URL={0}`nStatusCode={1}`nStatusDescription={2}" -f $probeUrl, $response.StatusCode, $response.StatusDescription
    Save-Text 'http-probe.txt' $httpProbe
} catch {
    Add-Summary ("- HTTP probe {0}: FAILED / not reachable" -f $probeUrl)
    $httpProbe = "URL={0}`nResult=FAILED`nError={1}" -f $probeUrl, $_.Exception.Message
    Save-Text 'http-probe.txt' $httpProbe
}

Add-Summary ''
Add-Summary '## Interpretation'
Add-Summary ''
Add-Summary 'This collection proves only local technical facts. It does not by itself prove a successful authenticated Pega login, functional Case Management, or OpenShift compatibility.'

$summary | Out-File (Join-Path $outDir 'SUMMARY.md') -Encoding utf8
Write-Host ("Evidence written to: {0}" -f $outDir)
Write-Host 'Review/redact outputs before committing any evidence.'
