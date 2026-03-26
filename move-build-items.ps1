$ErrorActionPreference = "Stop"

$solutionPath   = "C:\Work\MySolution\MySolution.sln"
$msbuildPath    = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2017\Professional\MSBuild\15.0\Bin\MSBuild.exe"

$projectOutDir  = "C:\Work\MySolution\MyApp\bin\Release"
$packageDir     = "C:\Work\Package"
$zipPath        = "C:\Work\Package.zip"

Write-Host "=== Restore start ==="

# 1. restore
& $msbuildPath $solutionPath /t:Restore /p:Configuration=Release
if ($LASTEXITCODE -ne 0) {
    throw "MSBuild restore failed. ExitCode=$LASTEXITCODE"
}

Write-Host "=== Restore success ==="
Write-Host "=== Build start ==="

# 2. build
& $msbuildPath $solutionPath /t:Build /p:Configuration=Release
if ($LASTEXITCODE -ne 0) {
    throw "MSBuild build failed. ExitCode=$LASTEXITCODE"
}

Write-Host "=== Build success ==="

# 3. 配布フォルダ作り直し
if (Test-Path $packageDir) {
    Remove-Item $packageDir -Recurse -Force
}
New-Item -ItemType Directory -Path $packageDir | Out-Null

# 4. 必要ファイルをコピー
Get-ChildItem $projectOutDir -File |
    Where-Object {
        $_.Extension -in @(".exe", ".dll", ".config")
    } |
    Copy-Item -Destination $packageDir

# 5. 補助フォルダをコピー
Copy-Item "C:\Work\MySolution\MyApp\Templates" "$packageDir\Templates" -Recurse

# 6. ZIP 作成
if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
}
Compress-Archive -Path "$packageDir\*" -DestinationPath $zipPath

Write-Host "=== Package completed ==="
Write-Host "PackageDir: $packageDir"
Write-Host "ZipPath   : $zipPath"
