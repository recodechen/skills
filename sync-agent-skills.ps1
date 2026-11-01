# 先进入当前目录再执行
$src = ".\"
$dst = "..\..\.claude\skills"

New-Item -ItemType Directory -Force $dst | Out-Null

Get-ChildItem $src -Directory | ForEach-Object {
    $target = Join-Path $dst $_.Name

    if (-not (Test-Path $target)) {
        cmd /c mklink /J `
            $target `
            $_.FullName
    }
}