param(
    [string]$Root = ".",

    [string[]]$Include = @(
        # JavaScript / TypeScript / Web
        "*.js", "*.jsx", "*.mjs", "*.cjs",
        "*.ts", "*.tsx", "*.mts", "*.cts",
        "*.vue", "*.svelte", "*.astro",
        "*.html", "*.htm", "*.css", "*.scss", "*.sass", "*.less",

        # C / C++ / Objective-C / CUDA
        "*.c", "*.cc", "*.cpp", "*.cxx", "*.c++",
        "*.h", "*.hh", "*.hpp", "*.hxx", "*.h++",
        "*.inl", "*.ipp", "*.tpp", "*.inc", "*.ixx", "*.cppm",
        "*.m", "*.mm", "*.cu", "*.cuh",
        "*.s", "*.asm", "*.rc", "*.rc2", "*.def", "*.idl",
        "*.natvis", "*.natstepfilter", "*.natjmc",

        # Java / JVM
        "*.java", "*.kt", "*.kts", "*.scala", "*.groovy", "*.gradle",

        # C# / .NET
        "*.cs", "*.csx", "*.fs", "*.fsx", "*.vb",

        # Shader
        "*.shader", "*.glsl", "*.glslinc",
        "*.hlsl", "*.hlsli", "*.fx", "*.fxh",
        "*.cg", "*.cginc", "*.compute", "*.fsl",
        "*.vert", "*.frag", "*.geom", "*.tesc", "*.tese", "*.comp",
        "*.mesh", "*.task", "*.rgen", "*.rmiss", "*.rchit", "*.rahit", "*.rint",
        "*.metal", "*.msl", "*.wgsl", "*.slang", "*.ush", "*.usf",

        # Python / common scripting languages
        "*.py", "*.pyi", "*.pyw", "*.pyx", "*.pxd", "*.pxi",
        "*.rb", "*.php", "*.lua", "*.pl", "*.pm", "*.r",

        # Shell / command scripts
        "*.sh", "*.bash", "*.zsh", "*.fish", "*.ksh", "*.csh", "*.tcsh",
        "*.awk", "*.sed",
        "*.ps1", "*.psm1", "*.psd1", "*.bat", "*.cmd",

        # Other common source / interface languages
        "*.go", "*.rs", "*.swift", "*.dart",
        "*.sql", "*.proto", "*.graphql", "*.gql", "*.thrift",

        # Build / project files
        "*.cmake", "*.mk", "*.make",
        "*.sln", "*.csproj", "*.fsproj", "*.vbproj", "*.vcxproj", "*.vcxproj.filters",
        "*.props", "*.targets", "*.nuspec",
        "CMakeLists.txt", "Makefile", "GNUmakefile",
        "Dockerfile", "Dockerfile.*", "Containerfile", "Containerfile.*",
        "Jenkinsfile", "Vagrantfile",
        "meson.build", "meson_options.txt",
        "BUILD", "BUILD.bazel", "WORKSPACE", "WORKSPACE.bazel", "MODULE.bazel",
        "SConstruct", "SConscript", "configure", "gradlew", "mvnw",

        # Configuration / structured text
        "*.json", "*.jsonc", "*.json5",
        "*.xml", "*.xsd", "*.xsl", "*.xslt",
        "*.yml", "*.yaml", "*.toml",
        "*.ini", "*.cfg", "*.conf", "*.config", "*.properties",
        "*.env", ".env", ".env.*",
        "*.editorconfig",

        # Documentation / plain text
        "*.md", "*.markdown", "*.rst", "*.adoc", "*.txt", "*.csv", "*.tsv", "*.tex",
        "README", "README.*", "LICENSE", "LICENSE.*", "NOTICE", "NOTICE.*",
        "CHANGELOG", "CHANGELOG.*", "CONTRIBUTING", "CONTRIBUTING.*",
        "AUTHORS", "AUTHORS.*",

        # Common repository dotfiles and lock files
        ".gitignore", ".gitattributes", ".gitmodules", ".dockerignore",
        ".editorconfig", ".clang-format", ".clang-tidy", ".cmake-format",
        ".prettierrc", ".prettierignore", ".eslintignore", ".stylelintrc",
        ".babelrc", ".browserslistrc", ".npmrc", ".yarnrc",
        "yarn.lock", "Cargo.lock", "Gemfile.lock", "composer.lock"
    ),

    [switch]$Recurse = $true,

    # Non-UTF files without BOM are decoded with this code page.
    # 936 is GBK; pass 0 to use the system ANSI encoding.
    [int]$AnsiCodePage = 936,

    [string[]]$ExcludeDirectoryName = @(
        '.git', '.svn', '.hg', '.vs', '.idea', '.claude',
        'node_modules', 'bower_components', 'packages', 'vendor',
        'build', 'out', 'dist', 'bin', 'obj', 'target', 'coverage',
        'thirdparty', 'external', 'generated',
        '.next', '.nuxt', '.output', '.cache', '.gradle',
        '__pycache__', '.venv', 'venv', '.tox', '.nox',
        '.mypy_cache', '.pytest_cache', '.ruff_cache',
        '.vscode'
    ),

    [switch]$SkipHidden = $true,

    # Skip files and directories excluded by .gitignore. Requires git on PATH and a
    # work tree; when either is missing the conversion proceeds without this filter.
    [switch]$RespectGitignore = $true
)

$ErrorActionPreference = 'Stop'

# PowerShell 7/.NET may require the code-page provider; Windows PowerShell already has it.
try {
    [System.Text.Encoding]::RegisterProvider([System.Text.CodePagesEncodingProvider]::Instance)
}
catch {
    # No action is required on runtimes where code pages are already built in.
}

$Utf8NoBom  = [System.Text.UTF8Encoding]::new($false)
$Utf8Strict = [System.Text.UTF8Encoding]::new($false, $true)

if ($AnsiCodePage -eq 0) {
    $AnsiEncoding = [System.Text.Encoding]::Default
}
else {
    $AnsiEncoding = [System.Text.Encoding]::GetEncoding($AnsiCodePage)
}

$ExcludedDirectorySet = [System.Collections.Generic.HashSet[string]]::new(
    [System.StringComparer]::OrdinalIgnoreCase
)
foreach ($name in $ExcludeDirectoryName) {
    [void]$ExcludedDirectorySet.Add($name)
}

# Hidden project directories that contain source-controlled text and should still be scanned.
$AllowedHiddenDirectorySet = [System.Collections.Generic.HashSet[string]]::new(
    [System.StringComparer]::OrdinalIgnoreCase
)
foreach ($name in @('.github', '.gitlab', '.devcontainer')) {
    [void]$AllowedHiddenDirectorySet.Add($name)
}

$ExtensionSet = [System.Collections.Generic.HashSet[string]]::new(
    [System.StringComparer]::OrdinalIgnoreCase
)
$WildcardPatterns = [System.Collections.Generic.List[string]]::new()

foreach ($pattern in $Include) {
    if ($pattern -match '^\*\.([^.\*\?]+)$') {
        [void]$ExtensionSet.Add('.' + $matches[1])
    }
    else {
        $WildcardPatterns.Add($pattern)
    }
}

function Test-HiddenAttribute {
    param([System.IO.FileAttributes]$Attributes)

    return (($Attributes -band [System.IO.FileAttributes]::Hidden) -ne 0)
}

function Test-ReparsePoint {
    param([System.IO.FileAttributes]$Attributes)

    return (($Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0)
}

function Test-IncludeFileName {
    param(
        [string]$Name,
        [string]$Extension
    )

    if ($ExtensionSet.Contains($Extension)) {
        return $true
    }

    foreach ($pattern in $WildcardPatterns) {
        if ($Name -like $pattern) {
            return $true
        }
    }

    return $false
}

function Test-ShebangTextFile {
    param([string]$FilePath)

    try {
        $stream = [System.IO.File]::Open(
            $FilePath,
            [System.IO.FileMode]::Open,
            [System.IO.FileAccess]::Read,
            [System.IO.FileShare]::ReadWrite
        )

        try {
            if ($stream.Length -lt 2) {
                return $false
            }

            $bufferLength = [Math]::Min([int64]256, $stream.Length)
            $buffer = [byte[]]::new([int]$bufferLength)
            $read = $stream.Read($buffer, 0, $buffer.Length)
            if ($read -lt 2 -or $buffer[0] -ne 0x23 -or $buffer[1] -ne 0x21) {
                return $false
            }

            $firstLine = [System.Text.Encoding]::ASCII.GetString($buffer, 0, $read)
            return ($firstLine -match '^#![^\r\n]*(sh|bash|zsh|fish|ksh|python([0-9.]+)?|node|ruby|perl|php|pwsh|powershell|env)(\s|$)')
        }
        finally {
            $stream.Dispose()
        }
    }
    catch {
        return $false
    }
}

function Get-BomEncodingInfo {
    param([byte[]]$Bytes)

    if ($Bytes.Length -ge 4 -and
        $Bytes[0] -eq 0xFF -and $Bytes[1] -eq 0xFE -and
        $Bytes[2] -eq 0x00 -and $Bytes[3] -eq 0x00) {
        return @{
            Name      = 'utf32-le'
            Encoding  = [System.Text.Encoding]::UTF32
            BomLength = 4
        }
    }

    if ($Bytes.Length -ge 4 -and
        $Bytes[0] -eq 0x00 -and $Bytes[1] -eq 0x00 -and
        $Bytes[2] -eq 0xFE -and $Bytes[3] -eq 0xFF) {
        return @{
            Name      = 'utf32-be'
            Encoding  = [System.Text.Encoding]::GetEncoding(12001)
            BomLength = 4
        }
    }

    if ($Bytes.Length -ge 3 -and
        $Bytes[0] -eq 0xEF -and $Bytes[1] -eq 0xBB -and $Bytes[2] -eq 0xBF) {
        return @{
            Name      = 'utf8-bom'
            Encoding  = [System.Text.Encoding]::UTF8
            BomLength = 3
        }
    }

    if ($Bytes.Length -ge 2 -and $Bytes[0] -eq 0xFF -and $Bytes[1] -eq 0xFE) {
        return @{
            Name      = 'utf16-le'
            Encoding  = [System.Text.Encoding]::Unicode
            BomLength = 2
        }
    }

    if ($Bytes.Length -ge 2 -and $Bytes[0] -eq 0xFE -and $Bytes[1] -eq 0xFF) {
        return @{
            Name      = 'utf16-be'
            Encoding  = [System.Text.Encoding]::BigEndianUnicode
            BomLength = 2
        }
    }

    return $null
}

function Get-Utf16EncodingInfoWithoutBom {
    param([byte[]]$Bytes)

    $sampleSize = [Math]::Min($Bytes.Length, 8192)
    $pairCount = [Math]::Floor($sampleSize / 2)
    if ($pairCount -lt 8) {
        return $null
    }

    $evenNulls = 0
    $oddNulls = 0

    for ($i = 0; $i -lt ($pairCount * 2); $i += 2) {
        if ($Bytes[$i] -eq 0) {
            $evenNulls++
        }
        if ($Bytes[$i + 1] -eq 0) {
            $oddNulls++
        }
    }

    $evenRatio = $evenNulls / $pairCount
    $oddRatio = $oddNulls / $pairCount

    if ($oddRatio -ge 0.15 -and $oddRatio -ge ($evenRatio * 5 + 0.05)) {
        return @{
            Name      = 'utf16-le-no-bom'
            Encoding  = [System.Text.Encoding]::Unicode
            BomLength = 0
        }
    }

    if ($evenRatio -ge 0.15 -and $evenRatio -ge ($oddRatio * 5 + 0.05)) {
        return @{
            Name      = 'utf16-be-no-bom'
            Encoding  = [System.Text.Encoding]::BigEndianUnicode
            BomLength = 0
        }
    }

    return $null
}

function Test-BinaryFile {
    param([byte[]]$Bytes)

    if ($Bytes.Length -eq 0) {
        return $false
    }

    $sampleSize = [Math]::Min($Bytes.Length, 8192)
    $controlCount = 0

    for ($i = 0; $i -lt $sampleSize; $i++) {
        $value = $Bytes[$i]

        if ($value -eq 0) {
            return $true
        }

        if ($value -lt 0x20 -and
            $value -ne 0x08 -and
            $value -ne 0x09 -and
            $value -ne 0x0A -and
            $value -ne 0x0C -and
            $value -ne 0x0D) {
            $controlCount++
        }
    }

    return (($controlCount / $sampleSize) -gt 0.10)
}

function Test-ValidUtf8 {
    param([byte[]]$Bytes)

    try {
        [void]$Utf8Strict.GetString($Bytes)
        return $true
    }
    catch {
        return $false
    }
}

function Get-FileEncodingInfo {
    param([byte[]]$Bytes)

    $bomInfo = Get-BomEncodingInfo -Bytes $Bytes
    if ($null -ne $bomInfo) {
        return $bomInfo
    }

    $utf16Info = Get-Utf16EncodingInfoWithoutBom -Bytes $Bytes
    if ($null -ne $utf16Info) {
        return $utf16Info
    }

    if (Test-BinaryFile -Bytes $Bytes) {
        return $null
    }

    if (Test-ValidUtf8 -Bytes $Bytes) {
        return @{
            Name      = 'utf8'
            Encoding  = [System.Text.Encoding]::UTF8
            BomLength = 0
        }
    }

    return @{
        Name      = "ansi-$AnsiCodePage"
        Encoding  = $AnsiEncoding
        BomLength = 0
    }
}

function Normalize-LineEndingsToLf {
    param([string]$Text)

    $Text = $Text -replace "`r`n", "`n"
    $Text = $Text -replace "`r", "`n"
    return $Text
}

function Test-ByteArraysEqual {
    param(
        [byte[]]$Left,
        [byte[]]$Right
    )

    if ($Left.Length -ne $Right.Length) {
        return $false
    }

    for ($i = 0; $i -lt $Left.Length; $i++) {
        if ($Left[$i] -ne $Right[$i]) {
            return $false
        }
    }

    return $true
}

function Convert-ToUtf8NoBomLf {
    param([string]$FilePath)

    try {
        $Bytes = [System.IO.File]::ReadAllBytes($FilePath)

        if ($Bytes.Length -eq 0) {
            Write-Host "[SKIP] Empty file: $FilePath"
            return 'skip-empty'
        }

        $Info = Get-FileEncodingInfo -Bytes $Bytes
        if ($null -eq $Info) {
            Write-Host "[SKIP] Binary or unsupported text encoding: $FilePath"
            return 'skip-binary'
        }

        $Text = $Info.Encoding.GetString(
            $Bytes,
            $Info.BomLength,
            $Bytes.Length - $Info.BomLength
        )
        $Text = Normalize-LineEndingsToLf -Text $Text
        $NewBytes = $Utf8NoBom.GetBytes($Text)

        if (Test-ByteArraysEqual -Left $Bytes -Right $NewBytes) {
            Write-Host "[SKIP] Already UTF-8 (no BOM) + LF: $FilePath"
            return 'skip-same'
        }

        [System.IO.File]::WriteAllBytes($FilePath, $NewBytes)
        Write-Host "[OK] $($Info.Name) -> UTF-8 (no BOM) + LF: $FilePath"
        return 'converted'
    }
    catch {
        Write-Host "[ERR] $FilePath"
        Write-Host "      $($_.Exception.Message)"
        return 'error'
    }
}

function Test-SkipDirectory {
    param(
        [string]$Name,
        [System.IO.FileAttributes]$Attributes
    )

    if ($ExcludedDirectorySet.Contains($Name)) {
        return $true
    }

    # Never traverse junctions/symlinks; this avoids cycles and leaving the selected root.
    if (Test-ReparsePoint -Attributes $Attributes) {
        return $true
    }

    if (-not $SkipHidden) {
        return $false
    }

    if ($AllowedHiddenDirectorySet.Contains($Name)) {
        return $false
    }

    if ($Name.StartsWith('.')) {
        return $true
    }

    return (Test-HiddenAttribute -Attributes $Attributes)
}

function Get-CandidateFiles {
    param([string]$SearchRoot)

    $rootPath = [System.IO.Path]::GetFullPath($SearchRoot)
    if (-not [System.IO.Directory]::Exists($rootPath)) {
        throw "Root directory not found: $rootPath"
    }

    $pending = [System.Collections.Generic.Stack[string]]::new()
    $pending.Push($rootPath)

    while ($pending.Count -gt 0) {
        $currentDir = $pending.Pop()

        try {
            $entries = [System.IO.Directory]::GetFileSystemEntries($currentDir)
        }
        catch {
            Write-Host "[ERR] Cannot enumerate directory: $currentDir"
            Write-Host "      $($_.Exception.Message)"
            continue
        }

        foreach ($entryPath in $entries) {
            try {
                $attributes = [System.IO.File]::GetAttributes($entryPath)
            }
            catch {
                Write-Host "[ERR] Cannot access attributes: $entryPath"
                Write-Host "      $($_.Exception.Message)"
                continue
            }

            $name = [System.IO.Path]::GetFileName($entryPath)
            $isDirectory = (($attributes -band [System.IO.FileAttributes]::Directory) -ne 0)

            if ($isDirectory) {
                if ($Recurse -and -not (Test-SkipDirectory -Name $name -Attributes $attributes)) {
                    $pending.Push($entryPath)
                }
                continue
            }

            if (Test-ReparsePoint -Attributes $attributes) {
                continue
            }

            $extension = [System.IO.Path]::GetExtension($entryPath)
            $included = Test-IncludeFileName -Name $name -Extension $extension

            # Extensionless executable scripts are included when they have a recognized shebang.
            if (-not $included -and [string]::IsNullOrEmpty($extension)) {
                $included = Test-ShebangTextFile -FilePath $entryPath
            }

            if (-not $included) {
                continue
            }

            # Explicitly included dotfiles are source files; do not discard them only for being hidden.
            if ($SkipHidden -and
                (Test-HiddenAttribute -Attributes $attributes) -and
                -not $name.StartsWith('.')) {
                continue
            }

            $entryPath
        }
    }
}

function Get-GitVisibleFileInfo {
    param([string]$SearchRoot)

    # Builds the set of paths git treats as present and NOT ignored (tracked plus
    # untracked-but-not-ignored) so that .gitignore entries are skipped. Returns $null
    # when filtering is disabled, git is unavailable, or the root is outside a work tree;
    # callers then convert without .gitignore filtering.
    if (-not $RespectGitignore) {
        return $null
    }

    # Native git reports missing repos and paths through non-zero exit codes rather than
    # thrown errors; keep that contract here so expected failures degrade to $null.
    $ErrorActionPreference = 'Continue'
    $PSNativeCommandUseErrorActionPreference = $false

    try {
        if ($null -eq (Get-Command git -CommandType Application -ErrorAction SilentlyContinue)) {
            return $null
        }

        $inside = & git -C $SearchRoot rev-parse --is-inside-work-tree 2>$null
        if ($LASTEXITCODE -ne 0 -or "$inside".Trim() -ne 'true') {
            return $null
        }

        $repoTop = & git -C $SearchRoot rev-parse --show-toplevel 2>$null
        if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($repoTop)) {
            return $null
        }
        $repoTop = [System.IO.Path]::GetFullPath("$repoTop".Trim())

        # git emits UTF-8 path bytes; decode them as UTF-8 so non-ASCII names match, and
        # core.quotepath=false keeps those names raw instead of octal-escaped.
        $previousOutputEncoding = [Console]::OutputEncoding
        try {
            [Console]::OutputEncoding = $Utf8NoBom
            $lines = & git -C $SearchRoot -c core.quotepath=false ls-files --full-name --cached --others --exclude-standard 2>$null
        }
        finally {
            [Console]::OutputEncoding = $previousOutputEncoding
        }
        if ($LASTEXITCODE -ne 0) {
            return $null
        }

        $visible = [System.Collections.Generic.HashSet[string]]::new(
            [System.StringComparer]::OrdinalIgnoreCase
        )
        foreach ($line in $lines) {
            $relative = "$line".Trim()
            if ($relative -ne '') {
                [void]$visible.Add($relative)
            }
        }

        return @{
            RepoTop = $repoTop
            Visible = $visible
        }
    }
    catch {
        Write-Host "[WARN] .gitignore filtering unavailable: $($_.Exception.Message)"
        return $null
    }
}

function Test-PathVisibleToGit {
    param(
        [string]$Path,
        [hashtable]$GitInfo
    )

    $relative = [System.IO.Path]::GetRelativePath($GitInfo.RepoTop, $Path) -replace '\\', '/'
    return $GitInfo.Visible.Contains($relative)
}

$rootFullPath = [System.IO.Path]::GetFullPath($Root)
if (-not [System.IO.Directory]::Exists($rootFullPath)) {
    throw "Root directory not found: $rootFullPath"
}

$gitInfo = Get-GitVisibleFileInfo -SearchRoot $rootFullPath

$stats = @{
    Converted = 0
    Skipped   = 0
    Errors    = 0
}

foreach ($filePath in Get-CandidateFiles -SearchRoot $rootFullPath) {
    if ($null -ne $gitInfo -and -not (Test-PathVisibleToGit -Path $filePath -GitInfo $gitInfo)) {
        Write-Host "[SKIP] Ignored by .gitignore: $filePath"
        $stats.Skipped++
        continue
    }

    $status = Convert-ToUtf8NoBomLf -FilePath $filePath
    switch ($status) {
        'converted' { $stats.Converted++ }
        'error'     { $stats.Errors++ }
        default     { $stats.Skipped++ }
    }
}

Write-Host (
    "[DONE] root={0} converted={1} skipped={2} errors={3}" -f
    $rootFullPath,
    $stats.Converted,
    $stats.Skipped,
    $stats.Errors
)

if ($stats.Errors -gt 0) {
    exit 1
}
