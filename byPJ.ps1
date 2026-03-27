$solutionRoot   = "C:\Work\MySolution"
$configuration  = "Release"
$packageRoot    = "C:\Work\Package"

$projects = @(
    @{ Name = "pjX"; DestDirName = "001" },
    @{ Name = "pjY"; DestDirName = "002" },
    @{ Name = "pjZ"; DestDirName = "003" }
)

foreach ($project in $projects) {
    $sourceDir = Join-Path $solutionRoot "$($project.Name)\bin\$configuration"
    $destDir   = Join-Path $packageRoot  $project.DestDirName

    New-Item -ItemType Directory -Path $destDir -Force | Out-Null

    Get-ChildItem $sourceDir -File |
        Where-Object {
            $_.Extension -in @(".exe", ".dll", ".config")
        } |
        Copy-Item -Destination $destDir -Force
}
