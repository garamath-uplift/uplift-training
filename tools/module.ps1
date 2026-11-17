<#
  Uplift module tools: check, preview and package training modules built from templates/module-starter.

  Usually the AI assistant runs these and explains the results. You can also double-click tools/module.cmd
  (Windows) or tools/module.command (Mac), or run them in any terminal:

    tools/module.ps1 new <name> [-SourceName <folder>] [-Title "<title>"]
    tools/module.ps1 check <name|path|--all> [-Strict]
    tools/module.ps1 contrast <name|path>
    tools/module.ps1 slides <name|path> [<number>|"<title text>"] [-Section <id>]
    tools/module.ps1 preview <name|path>
    tools/module.ps1 package <name|path> [-OutDir <folder>] [-Force]

  <name> is a folder under modules/. <path> is a folder that holds index.html.
  Exit codes: 0 = OK, 1 = problems found, 2 = usage or setup error.
  Runs on Windows PowerShell 5.1 and PowerShell 7 (Windows, Mac, Linux). Nothing to install.
#>
[CmdletBinding()]
param(
  [Parameter(Position = 0)][string]$Command,
  [Parameter(Position = 1)][string]$Target,
  [Parameter(Position = 2)][string]$Item,
  [string]$SourceName,
  [string]$Title,
  [string]$Section,
  [string]$OutDir,
  [string]$RuntimePath,
  [switch]$All,
  [switch]$Strict,
  [switch]$Force,
  [switch]$NoOpen
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$script:RepoRoot = Split-Path -Parent $PSScriptRoot
$script:Utf8 = New-Object System.Text.UTF8Encoding($false)
$script:Fails = 0
$script:Warns = 0
$script:RuntimeVersion = '1'

# ---------------------------------------------------------------- helpers

function Read-Text([string]$Path) { return [IO.File]::ReadAllText($Path, $script:Utf8) }
function Write-Text([string]$Path, [string]$Text) { [IO.File]::WriteAllText($Path, $Text, $script:Utf8) }

function Stop-Usage([string]$Message) {
  Write-Output "ERROR  $Message"
  Write-Output "Run 'tools/module.ps1 help' for the list of commands."
  exit 2
}

function New-LineIndex([string]$Text) {
  $starts = New-Object System.Collections.Generic.List[int]
  $starts.Add(0)
  for ($i = 0; $i -lt $Text.Length; $i++) { if ($Text[$i] -eq "`n") { $starts.Add($i + 1) } }
  return , $starts.ToArray()
}

function Get-LineNumber([int[]]$Index, [int]$Offset) {
  $lo = 0; $hi = $Index.Length - 1
  while ($lo -lt $hi) {
    $mid = [int][Math]::Floor(($lo + $hi + 1) / 2)
    if ($Index[$mid] -le $Offset) { $lo = $mid } else { $hi = $mid - 1 }
  }
  return $lo + 1
}

function Add-Finding([string]$Level, [string]$Rule, [int]$Line, [string]$Message) {
  $where = ''
  if ($Line -gt 0) { $where = "line ${Line}: " }
  Write-Output ('{0,-5} {1,-14} {2}{3}' -f $Level, $Rule, $where, $Message)
  if ($Level -eq 'FAIL') { $script:Fails++ } else { $script:Warns++ }
}

function Test-IsWindows {
  if (Test-Path variable:IsWindows) { return [bool]$IsWindows }
  return $true  # Windows PowerShell 5.1 only runs on Windows
}

function Open-InBrowser([string]$Path) {
  if (Test-IsWindows) { Start-Process -FilePath $Path; return }
  if ((Test-Path variable:IsMacOS) -and $IsMacOS) { & open $Path; return }
  & xdg-open $Path | Out-Null
}

# Plain text with tags, scripts, styles and comments removed. Removed parts keep their line breaks,
# so offsets in the result still map to the same line numbers.
function Get-VisibleText([string]$Html) {
  $keepLines = { param($m) ($m.Value -replace '[^\n]', '') }
  $t = [regex]::Replace($Html, '(?s)<!--.*?-->', $keepLines)
  $t = [regex]::Replace($t, '(?is)<script\b.*?</script>', $keepLines)
  $t = [regex]::Replace($t, '(?is)<style\b.*?</style>', $keepLines)
  $t = [regex]::Replace($t, '(?s)<[^>]*>', $keepLines)
  $t = $t -replace '&nbsp;', ' ' -replace '&amp;', '&' -replace '&#39;|&rsquo;|&lsquo;', "'" -replace '&quot;|&ldquo;|&rdquo;', '"'
  $t = $t -replace '&#?[A-Za-z0-9]+;', ' '                     # any other character reference (&gt; &times; ...)
  $t = [regex]::Replace($t, '(?s)\[\[PLACEHOLDER:.*?\]\]', $keepLines)   # placeholder text is reported separately
  return $t
}

# HTML comments replaced by spaces of the same length (line breaks kept), so offsets and line numbers still match.
function Remove-Comments([string]$Html) {
  return [regex]::Replace($Html, '(?s)<!--.*?-->', { param($m) [regex]::Replace($m.Value, '[^\n]', ' ') })
}

function Get-InnerText([string]$Html) {
  $t = [regex]::Replace($Html, '(?s)<[^>]*>', '')
  return ($t -replace '&nbsp;', ' ' -replace '&amp;', '&' -replace '\s+', ' ').Trim()
}

# ---------------------------------------------------------------- finding a module

function Get-ModuleConfig([string]$Html) {
  $m = [regex]::Match($Html, '(?is)<script[^>]*\bid\s*=\s*["'']uplift-module["''][^>]*>(.*?)</script>')
  if (-not $m.Success) { return $null }
  return [pscustomobject]@{ Raw = $m.Groups[1].Value; Index = $m.Index; Match = $m }
}

# Returns @{ Name; Dir; Index; IsFramework } or exits.
function Resolve-Module([string]$Spec) {
  if (-not $Spec) { Stop-Usage 'Name a module (a folder under modules/) or a folder that holds index.html.' }
  $candidates = @()
  $asPath = $Spec
  if (-not [IO.Path]::IsPathRooted($asPath)) { $asPath = Join-Path (Get-Location).Path $Spec }
  if (Test-Path -LiteralPath (Join-Path $asPath 'index.html')) {
    $candidates = @((Resolve-Path -LiteralPath $asPath).Path)
  } else {
    $modDir = Join-Path (Join-Path $script:RepoRoot 'modules') $Spec
    $srcDir = Join-Path $modDir 'sources'
    if (-not (Test-Path -LiteralPath $srcDir)) { Stop-Usage "No module found at modules/$Spec/sources/ and no index.html in '$Spec'." }
    foreach ($d in (Get-ChildItem -LiteralPath $srcDir -Directory)) {
      $ix = Join-Path $d.FullName 'index.html'
      if ((Test-Path -LiteralPath $ix) -and (Get-ModuleConfig (Read-Text $ix))) { $candidates += $d.FullName }
    }
    if ($candidates.Count -eq 0) { Stop-Usage "modules/$Spec has no source folder with an uplift-module settings block, so it isn't a framework module." }
    if ($candidates.Count -gt 1) { Stop-Usage "modules/$Spec has more than one source folder with a settings block. Pass the folder path instead." }
  }
  $dir = $candidates[0]
  $name = $null
  $parent = Split-Path -Parent $dir
  if ((Split-Path -Leaf $parent) -eq 'sources') { $name = Split-Path -Leaf (Split-Path -Parent $parent) }
  return [pscustomobject]@{ Dir = $dir; Index = (Join-Path $dir 'index.html'); Name = $name }
}

function Get-FrameworkModules {
  $list = @()
  $mods = Join-Path $script:RepoRoot 'modules'
  if (-not (Test-Path -LiteralPath $mods)) { return $list }
  foreach ($m in (Get-ChildItem -LiteralPath $mods -Directory)) {
    $src = Join-Path $m.FullName 'sources'
    if (-not (Test-Path -LiteralPath $src)) { continue }
    foreach ($d in (Get-ChildItem -LiteralPath $src -Directory)) {
      $ix = Join-Path $d.FullName 'index.html'
      if ((Test-Path -LiteralPath $ix) -and (Get-ModuleConfig (Read-Text $ix))) {
        $list += [pscustomobject]@{ Dir = $d.FullName; Index = $ix; Name = $m.Name }
      }
    }
  }
  return $list
}

function Read-Config($Module, [string]$Html) {
  $c = Get-ModuleConfig $Html
  if (-not $c) { return $null }
  try { return ($c.Raw | ConvertFrom-Json) } catch { return $null }
}

# ---------------------------------------------------------------- parsing the module

function Get-SectionIds([string]$Html) {
  $m = [regex]::Match($Html, '(?s)var\s+SECTIONS\s*=\s*\[(.*?)\];')
  $ids = @()
  if ($m.Success) {
    foreach ($x in [regex]::Matches($m.Groups[1].Value, 'id\s*:\s*["'']([^"'']+)["'']')) { $ids += $x.Groups[1].Value }
  }
  return $ids
}

function Get-JalonIds([string]$Html) {
  $ids = @()
  foreach ($x in [regex]::Matches($Html, 'data-jalon\s*=\s*["'']([^"'']+)["'']')) { $ids += $x.Groups[1].Value }
  return $ids
}

# Each slide: number, start/end offsets, attributes.
function Get-Slides([string]$Html) {
  $slides = @()
  $open = [regex]::Matches($Html, '(?is)<section\b[^>]*\bclass\s*=\s*["''][^"'']*\bslide\b[^"'']*["''][^>]*>')
  $n = 0
  foreach ($o in $open) {
    $n++
    # Find the matching </section>, allowing for nested <section> elements.
    $depth = 0; $pos = $o.Index; $end = $Html.Length
    $tags = [regex]::Matches($Html.Substring($o.Index), '(?i)<(/?)section\b[^>]*>')
    foreach ($t in $tags) {
      if ($t.Groups[1].Value -eq '/') { $depth-- } else { $depth++ }
      if ($depth -eq 0) { $end = $o.Index + $t.Index + $t.Length; break }
    }
    $tag = $o.Value
    $attr = {
      param($name)
      $a = [regex]::Match($tag, "(?i)\b$name\s*=\s*[""']([^""']*)[""']")
      if ($a.Success) { return $a.Groups[1].Value } else { return '' }
    }
    $slides += [pscustomobject]@{
      N = $n; Start = $o.Index; End = $end
      Section = (& $attr 'data-section'); Title = (& $attr 'data-title'); Gate = (& $attr 'data-gate')
    }
  }
  return $slides
}

function Get-AssetRefs([string]$Html) {
  $refs = @()
  foreach ($m in [regex]::Matches($Html, '(?i)\b(?:src|href)\s*=\s*["'']assets/([^"''#?]+)["'']')) {
    $refs += [pscustomobject]@{ Path = $m.Groups[1].Value; Index = $m.Index }
  }
  foreach ($m in [regex]::Matches($Html, '(?i)url\(\s*["'']?assets/([^"'')#?]+)["'']?\s*\)')) {
    $refs += [pscustomobject]@{ Path = $m.Groups[1].Value; Index = $m.Index }
  }
  return $refs
}

# ---------------------------------------------------------------- contrast

function Get-Luminance([string]$Hex) {
  $h = $Hex.TrimStart('#')
  if ($h.Length -eq 3) { $h = "$($h[0])$($h[0])$($h[1])$($h[1])$($h[2])$($h[2])" }
  $c = @()
  foreach ($i in 0, 2, 4) {
    $v = [Convert]::ToInt32($h.Substring($i, 2), 16) / 255.0
    if ($v -le 0.03928) { $c += $v / 12.92 } else { $c += [Math]::Pow(($v + 0.055) / 1.055, 2.4) }
  }
  return 0.2126 * $c[0] + 0.7152 * $c[1] + 0.0722 * $c[2]
}

function Get-ContrastRatio([string]$A, [string]$B) {
  $la = Get-Luminance $A; $lb = Get-Luminance $B
  $hi = [Math]::Max($la, $lb); $lo = [Math]::Min($la, $lb)
  return ($hi + 0.05) / ($lo + 0.05)
}

function Get-Tokens([string]$Html) {
  $tokens = @{}
  $root = [regex]::Match($Html, '(?s):root\s*\{(.*?)\}')
  if (-not $root.Success) { return $tokens }
  foreach ($m in [regex]::Matches($root.Groups[1].Value, '--([a-z0-9-]+)\s*:\s*([^;]+);')) {
    $tokens[$m.Groups[1].Value] = $m.Groups[2].Value.Trim()
  }
  return $tokens
}

function Invoke-Contrast([string]$Html, [int[]]$LineIx) {
  $tokens = Get-Tokens $Html
  if ($tokens.Count -eq 0) { Add-Finding 'FAIL' 'contrast' 0 'No :root color tokens found.'; return }
  if (-not $tokens.ContainsKey('on-primary')) { $tokens['on-primary'] = '#ffffff' }
  # fg, bg, minimum, warn-below (for "large text only" pairs)
  $pairs = @(
    @('ink', 'bg', 4.5, 0), @('muted', 'bg', 4.5, 0), @('muted', 'surface', 4.5, 0),
    @('on-brand', 'brand', 4.5, 0), @('on-brand', 'brand-2', 4.5, 0), @('on-primary', 'primary', 4.5, 0),
    @('primary-dark', 'bg', 4.5, 0), @('primary-dark', 'surface', 4.5, 0), @('primary-dark', 'primary-tint', 4.5, 0),
    @('accent', 'brand', 3.0, 0), @('ink', 'accent-tint', 4.5, 0), @('accent-2', 'bg', 3.0, 4.5),
    @('good', 'good-tint', 4.5, 0), @('bad', 'bad-tint', 4.5, 0), @('focus', 'bg', 3.0, 0), @('focus', 'surface', 3.0, 0)
  )
  Write-Output ''
  Write-Output 'Contrast (WCAG 2.1 AA)'
  Write-Output ('  {0,-34} {1,7} {2,6}  {3}' -f 'Pair', 'Ratio', 'Needs', 'Result')
  foreach ($p in $pairs) {
    $fg = $p[0]; $bg = $p[1]; $label = "--$fg on --$bg"
    if (-not ($tokens.ContainsKey($fg) -and $tokens.ContainsKey($bg))) {
      Write-Output ('  {0,-34} {1,7} {2,6}  {3}' -f $label, '-', $p[2], 'WARN missing token')
      $script:Warns++; continue
    }
    $a = $tokens[$fg]; $b = $tokens[$bg]
    if (($a -notmatch '^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$') -or ($b -notmatch '^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$')) {
      Write-Output ('  {0,-34} {1,7} {2,6}  {3}' -f $label, '-', $p[2], "WARN can't check ($a / $b)")
      $script:Warns++; continue
    }
    $r = Get-ContrastRatio $a $b
    $result = 'PASS'
    if ($r -lt $p[2]) { $result = 'FAIL'; $script:Fails++ }
    elseif ($p[3] -gt 0 -and $r -lt $p[3]) { $result = 'WARN large text or non-text only'; $script:Warns++ }
    Write-Output ('  {0,-34} {1,7:N2} {2,6}  {3}' -f $label, $r, $p[2], $result)
  }
}

# ---------------------------------------------------------------- check (lint + contrast)

function Invoke-Check($Module, [switch]$IsStrict, [switch]$Quiet) {
  $raw = Read-Text $Module.Index
  $html = Remove-Comments $raw
  $ix = New-LineIndex $html
  $strictLevel = 'WARN'; if ($IsStrict) { $strictLevel = 'FAIL' }
  if (-not $Quiet) { Write-Output "Checking $($Module.Index)" }

  # Settings block
  $cfgBlock = Get-ModuleConfig $html
  if (-not $cfgBlock) {
    Add-Finding 'FAIL' 'settings' 0 'No <script type="application/json" id="uplift-module"> settings block in <head>.'
  } else {
    $line = Get-LineNumber $ix $cfgBlock.Index
    $cfg = $null
    try { $cfg = $cfgBlock.Raw | ConvertFrom-Json } catch { Add-Finding 'FAIL' 'settings' $line 'Settings block is not valid JSON.' }
    if ($cfg) {
      foreach ($k in 'title', 'identifier', 'version', 'language') {
        if (-not ($cfg.PSObject.Properties.Name -contains $k) -or -not $cfg.$k) { Add-Finding 'FAIL' 'settings' $line "Settings block is missing '$k'." }
      }
      if (($cfg.PSObject.Properties.Name -contains 'identifier') -and ($cfg.identifier -cnotmatch '^uplift-[a-z0-9-]+$')) {
        Add-Finding 'FAIL' 'settings' $line "identifier '$($cfg.identifier)' must look like uplift-<module-name> (lowercase, hyphens)."
      }
      if (($cfg.PSObject.Properties.Name -contains 'version') -and ([string]$cfg.version -notmatch '^\d+\.\d+$')) {
        Add-Finding 'FAIL' 'settings' $line "version '$($cfg.version)' must look like 1.0 (major.minor)."
      }
    }
  }

  # Ship blockers
  $dev = [regex]::Match($html, 'var\s+DEV\s*=\s*true\b')
  if ($dev.Success) { Add-Finding $strictLevel 'dev-mode' (Get-LineNumber $ix $dev.Index) 'DEV = true. Set it to false before packaging.' }
  $ph = [regex]::Matches($html, '\[\[PLACEHOLDER:')
  if ($ph.Count -gt 0) {
    $lines = @(); foreach ($p in $ph) { $ln = Get-LineNumber $ix $p.Index; if ($lines -notcontains $ln) { $lines += $ln }; if ($lines.Count -ge 5) { break } }
    Add-Finding $strictLevel 'placeholder' $lines[0] ("{0} [[PLACEHOLDER marker(s) left (first on lines {1})." -f $ph.Count, ($lines -join ', '))
  }
  $mk = [regex]::Match($html, 'MODULE_KEY\s*=\s*["'']uplift-sample-module["'']')
  if ($mk.Success) { Add-Finding $strictLevel 'module-key' (Get-LineNumber $ix $mk.Index) 'MODULE_KEY is still "uplift-sample-module". Use uplift-<module-name>.' }

  # Offline: no external files
  $extPatterns = @(
    '(?i)<(?:script|img|audio|video|source|iframe|embed|track)\b[^>]*\bsrc\s*=\s*["'']?(?:https?:)?//',
    '(?i)<link\b[^>]*\bhref\s*=\s*["'']?(?:https?:)?//',
    '(?i)url\(\s*["'']?(?:https?:)?//',
    '(?i)@import\s+["'']?(?:url\()?\s*["'']?(?:https?:)?//'
  )
  foreach ($pat in $extPatterns) {
    foreach ($m in [regex]::Matches($html, $pat)) {
      Add-Finding 'FAIL' 'offline' (Get-LineNumber $ix $m.Index) 'Loads a file from the internet. Modules must run offline: put it in assets/.'
    }
  }

  # Assets
  $refs = Get-AssetRefs $html
  $used = @{}
  foreach ($r in $refs) {
    $used[$r.Path.ToLowerInvariant()] = $true
    $f = Join-Path (Join-Path $Module.Dir 'assets') $r.Path
    if (-not (Test-Path -LiteralPath $f)) { Add-Finding 'FAIL' 'asset-missing' (Get-LineNumber $ix $r.Index) "assets/$($r.Path) doesn't exist." }
  }
  $assetDir = Join-Path $Module.Dir 'assets'
  if (Test-Path -LiteralPath $assetDir) {
    foreach ($f in (Get-ChildItem -LiteralPath $assetDir -File -Recurse)) {
      $rel = $f.FullName.Substring($assetDir.Length + 1) -replace '\\', '/'
      if (-not $used.ContainsKey($rel.ToLowerInvariant())) { Add-Finding 'WARN' 'asset-unused' 0 "assets/$rel isn't used. Delete it if it isn't needed." }
    }
  }

  # Images
  foreach ($m in [regex]::Matches($html, '(?is)<img\b[^>]*>')) {
    if ($m.Value -notmatch '(?i)\balt\s*=') { Add-Finding 'FAIL' 'alt-text' (Get-LineNumber $ix $m.Index) '<img> has no alt attribute. Describe it, or use alt="" if it is decorative.' }
  }

  # Headings
  $h1 = [regex]::Matches($html, '(?i)<h1\b')
  if ($h1.Count -ne 1) { Add-Finding 'FAIL' 'headings' 0 "Found $($h1.Count) <h1> elements. A module has exactly one (its title)." }
  $slides = Get-Slides $html
  foreach ($s in $slides) {
    $body = $html.Substring($s.Start, $s.End - $s.Start)
    $prev = 0
    foreach ($h in [regex]::Matches($body, '(?i)<h([1-6])\b')) {
      $lvl = [int]$h.Groups[1].Value
      if ($prev -gt 0 -and $lvl -gt $prev + 1) {
        Add-Finding 'WARN' 'headings' (Get-LineNumber $ix ($s.Start + $h.Index)) "Heading jumps from h$prev to h$lvl on slide $($s.N)."
      }
      $prev = $lvl
    }
    foreach ($h in [regex]::Matches($body, '(?is)<h2\b[^>]*>(.*?)</h2>')) {
      $text = Get-InnerText $h.Groups[1].Value
      if ($text -match '\[\[') { continue }
      $small = @('a', 'an', 'the', 'and', 'or', 'of', 'to', 'in', 'on', 'for', 'with', 'vs', 'by', 'at', 'is', 'it', 'as', 'from')
      $words = @($text -split '\s+' | Where-Object { $_ -match '^[A-Za-z]' })
      $big = @($words | Select-Object -Skip 1 | Where-Object { $small -notcontains $_.ToLowerInvariant() })
      if ($words.Count -ge 3 -and $big.Count -ge 2) {
        $caps = @($big | Where-Object { $_ -cmatch '^[A-Z]' })
        if ($caps.Count -eq $big.Count) {
          Add-Finding 'WARN' 'sentence-case' (Get-LineNumber $ix ($s.Start + $h.Index)) "Heading '$text' looks like Title Case. Use sentence case."
        }
      }
    }
  }

  # Milestones, sections and checks
  $sectionIds = @(Get-SectionIds $html)
  $jalons = @(Get-JalonIds $html)
  if ($sectionIds.Count -eq 0) { Add-Finding 'FAIL' 'milestones' 0 'No "var SECTIONS = [ ... ]" list found in the script.' }
  if ($jalons.Count -eq 0) { Add-Finding 'FAIL' 'milestones' 0 'No data-jalon milestone markers found.' }
  $checkForms = [regex]::Matches($html, '(?is)<form\b[^>]*\bclass\s*=\s*["''][^"'']*\bcheck\b[^"'']*["''][^>]*>.*?</form>')
  $checkIds = @()
  $checkInfo = @{}
  foreach ($f in $checkForms) {
    $line = Get-LineNumber $ix $f.Index
    $cid = [regex]::Match($f.Value, '(?i)data-check\s*=\s*["'']([^"'']+)["'']').Groups[1].Value
    $pass = [regex]::Match($f.Value, '(?i)data-pass\s*=\s*["''](\d+)["'']')
    if (-not $cid) { Add-Finding 'FAIL' 'checks' $line 'A check question has no data-check.'; continue }
    if ($checkIds -notcontains $cid) { $checkIds += $cid; $checkInfo[$cid] = [pscustomobject]@{ Count = 0; Pass = 0; Line = $line } }
    $checkInfo[$cid].Count++
    if ($pass.Success) { $checkInfo[$cid].Pass = [int]$pass.Groups[1].Value }
    if ($sectionIds -notcontains $cid) { Add-Finding 'FAIL' 'checks' $line "data-check '$cid' isn't a section id in SECTIONS." }
    $fs = [regex]::Match($f.Value, '(?i)<fieldset\b[^>]*data-answer\s*=\s*["'']([^"'']+)["'']')
    $values = @(); foreach ($v in [regex]::Matches($f.Value, '(?i)<input\b[^>]*type\s*=\s*["'']radio["''][^>]*value\s*=\s*["'']([^"'']+)["'']')) { $values += $v.Groups[1].Value }
    if (-not $fs.Success) { Add-Finding 'FAIL' 'checks' $line 'Check question has no data-answer on its fieldset.' }
    elseif ($values -notcontains $fs.Groups[1].Value) { Add-Finding 'FAIL' 'checks' $line "data-answer '$($fs.Groups[1].Value)' doesn't match any option value." }
  }
  foreach ($cid in $checkIds) {
    $c = $checkInfo[$cid]
    if ($c.Pass -lt 1 -or $c.Pass -gt $c.Count) { Add-Finding 'FAIL' 'checks' $c.Line "Check '$cid' has data-pass $($c.Pass) but $($c.Count) question(s). It must be between 1 and $($c.Count)." }
  }
  $total = [regex]::Match($html, 'var\s+CHECK_TOTAL\s*=\s*(\d+)')
  if ($checkForms.Count -gt 0 -or $total.Success) {
    if (-not $total.Success) { Add-Finding 'FAIL' 'checks' 0 'No "var CHECK_TOTAL = <n>" found.' }
    elseif ([int]$total.Groups[1].Value -ne $checkForms.Count) {
      Add-Finding 'FAIL' 'checks' (Get-LineNumber $ix $total.Index) "CHECK_TOTAL is $($total.Groups[1].Value) but there are $($checkForms.Count) check questions."
    }
  }
  $expected = @($sectionIds) + @($checkIds | ForEach-Object { "check-$_" })
  $missing = @($expected | Where-Object { $jalons -notcontains $_ })
  $extra = @($jalons | Where-Object { $expected -notcontains $_ })
  if ($missing.Count -gt 0) { Add-Finding 'FAIL' 'milestones' 0 ("No data-jalon marker for: {0}." -f ($missing -join ', ')) }
  if ($extra.Count -gt 0) { Add-Finding 'FAIL' 'milestones' 0 ("data-jalon marker(s) with no matching section or check: {0}." -f ($extra -join ', ')) }
  $dupes = @($jalons | Group-Object | Where-Object { $_.Count -gt 1 } | ForEach-Object { $_.Name })
  if ($dupes.Count -gt 0) { Add-Finding 'FAIL' 'milestones' 0 ("Duplicate data-jalon id(s): {0}." -f ($dupes -join ', ')) }
  foreach ($s in $slides) {
    if (-not $s.Section) { Add-Finding 'FAIL' 'sections' (Get-LineNumber $ix $s.Start) "Slide $($s.N) has no data-section." }
    elseif ($sectionIds -notcontains $s.Section) { Add-Finding 'FAIL' 'sections' (Get-LineNumber $ix $s.Start) "Slide $($s.N) has data-section '$($s.Section)', which isn't in SECTIONS." }
  }

  # Radio names: one per question, never reused (they become interaction ids)
  $names = @{}
  foreach ($q in [regex]::Matches($html, '(?is)<fieldset\b.*?</fieldset>')) {
    $qNames = @(); foreach ($r in [regex]::Matches($q.Value, '(?i)<input\b[^>]*type\s*=\s*["'']radio["''][^>]*\bname\s*=\s*["'']([^"'']+)["'']')) { $qNames += $r.Groups[1].Value }
    $uniq = @($qNames | Select-Object -Unique)
    $line = Get-LineNumber $ix $q.Index
    if ($uniq.Count -gt 1) { Add-Finding 'FAIL' 'question-ids' $line ("One question uses several radio names: {0}." -f ($uniq -join ', ')) }
    foreach ($n in $uniq) {
      if ($names.ContainsKey($n)) { Add-Finding 'FAIL' 'question-ids' $line "Radio name '$n' is also used on line $($names[$n]). Each question needs its own name." }
      else { $names[$n] = $line }
    }
  }

  # Writing and privacy in visible text
  $text = Get-VisibleText $raw
  $tix = New-LineIndex $text  # same line breaks as the file, different offsets
  foreach ($m in [regex]::Matches($text, '\b[Cc]lick(s|ed|ing)?\b')) {
    Add-Finding 'WARN' 'style' (Get-LineNumber $tix $m.Index) "Uses '$($m.Value)'. Write 'Select' so it works for touch and keyboard too."
  }
  foreach ($m in [regex]::Matches($text, '[A-Za-z\)];\s')) {
    Add-Finding 'WARN' 'style' (Get-LineNumber $tix $m.Index) 'Semicolon in learner-facing text. Make two sentences instead.'
  }
  foreach ($m in [regex]::Matches($html, '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}')) {
    if ($m.Value -ne 'ai@uplifteducation.org') { Add-Finding 'WARN' 'privacy' (Get-LineNumber $ix $m.Index) "Email '$($m.Value)'. Make sure it's fictional or a public contact." }
  }
  foreach ($m in [regex]::Matches($text, '(?<![\w#-])\d{6,}(?![\w-])|\(?\b\d{3}\)?[ .-]\d{3}[ .-]\d{4}\b')) {
    Add-Finding 'WARN' 'privacy' (Get-LineNumber $tix $m.Index) "Number '$($m.Value)' looks like an ID or phone number. Make sure it isn't real."
  }

  Invoke-Contrast $html $ix
}

function Write-Summary([string]$What) {
  Write-Output ''
  if ($script:Fails -gt 0) { Write-Output ("RESULT  {0}: {1} problem(s) to fix, {2} warning(s)." -f $What, $script:Fails, $script:Warns) }
  elseif ($script:Warns -gt 0) { Write-Output ("RESULT  {0}: no problems, {1} warning(s) to review." -f $What, $script:Warns) }
  else { Write-Output ("RESULT  {0}: all clear." -f $What) }
}

# ---------------------------------------------------------------- build (preview and package)

function Get-RuntimeFile {
  $p = $RuntimePath
  if (-not $p) { $p = Join-Path (Join-Path (Join-Path $script:RepoRoot 'templates') 'core') 'scorm-runtime.js' }
  if (-not (Test-Path -LiteralPath $p)) { Stop-Usage "SCORM runtime not found at $p." }
  return (Resolve-Path -LiteralPath $p).Path
}

function Get-Mime([string]$Path) {
  switch ([IO.Path]::GetExtension($Path).ToLowerInvariant()) {
    '.png' { return 'image/png' }
    '.jpg' { return 'image/jpeg' }
    '.jpeg' { return 'image/jpeg' }
    '.gif' { return 'image/gif' }
    '.svg' { return 'image/svg+xml' }
    '.webp' { return 'image/webp' }
    '.mp3' { return 'audio/mpeg' }
    '.wav' { return 'audio/wav' }
    '.woff2' { return 'font/woff2' }
    '.woff' { return 'font/woff' }
    default { return $null }
  }
}

# Returns the built HTML (assets inlined, runtime injected) or exits on error.
function Build-Html($Module, $Config, [bool]$TestMode) {
  $html = Read-Text $Module.Index
  $assetDir = Join-Path $Module.Dir 'assets'
  $cache = @{}
  $errors = New-Object System.Collections.Generic.List[string]
  $toData = {
    param($rel)
    $key = $rel.ToLowerInvariant()
    if ($cache.ContainsKey($key)) { return $cache[$key] }
    $f = Join-Path $assetDir $rel
    if (-not (Test-Path -LiteralPath $f)) { $errors.Add("assets/$rel doesn't exist."); return "assets/$rel" }
    $mime = Get-Mime $f
    if (-not $mime) { $errors.Add("assets/$rel has a file type the packager doesn't know."); return "assets/$rel" }
    $uri = "data:$mime;base64," + [Convert]::ToBase64String([IO.File]::ReadAllBytes($f))
    $cache[$key] = $uri
    return $uri
  }
  $html = [regex]::Replace($html, '(?i)(\b(?:src|href)\s*=\s*["''])assets/([^"''#?]+)(["''])', {
      param($m) $m.Groups[1].Value + (& $toData $m.Groups[2].Value) + $m.Groups[3].Value })
  $html = [regex]::Replace($html, '(?i)url\(\s*(["'']?)assets/([^"'')#?]+)\1\s*\)', {
      param($m) 'url("' + (& $toData $m.Groups[2].Value) + '")' })
  if ($errors.Count -gt 0) { foreach ($e in $errors) { Write-Output "FAIL  build          $e" }; exit 1 }

  $runtimeFile = Get-RuntimeFile
  $runtime = Read-Text $runtimeFile
  if ($runtime -match '(?i)</script') { Stop-Usage 'The SCORM runtime contains "</script", which would break the page.' }
  $interactions = 'false'
  if (($Config.PSObject.Properties.Name -contains 'interactions') -and $Config.interactions -eq $true) { $interactions = 'true' }
  $test = 'false'; if ($TestMode) { $test = 'true' }
  $inject = "<script>window.__UPLIFT_SCORM = {`"interactions`":$interactions,`"testMode`":$test};</script>`n" +
    "<script>/* uplift-scorm-runtime v$($script:RuntimeVersion) */`n$runtime`n</script>`n"
  $head = $html.IndexOf('</head>', [StringComparison]::OrdinalIgnoreCase)
  if ($head -lt 0) { Stop-Usage 'index.html has no </head>.' }
  return $html.Substring(0, $head) + $inject + $html.Substring($head)
}

function ConvertTo-XmlText([string]$s) { return [Security.SecurityElement]::Escape($s) }

function Get-Manifest($Config) {
  $id = ConvertTo-XmlText $Config.identifier
  $title = ConvertTo-XmlText $Config.title
  return @"
<?xml version="1.0" encoding="UTF-8"?>
<manifest identifier="$id" version="1.0"
  xmlns="http://www.imsglobal.org/xsd/imscp_v1p1"
  xmlns:adlcp="http://www.adlnet.org/xsd/adlcp_v1p3"
  xmlns:imsss="http://www.imsglobal.org/xsd/imsss"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.imsglobal.org/xsd/imscp_v1p1 imscp_v1p1.xsd http://www.adlnet.org/xsd/adlcp_v1p3 adlcp_v1p3.xsd http://www.imsglobal.org/xsd/imsss imsss_v1p0.xsd">
  <metadata>
    <schema>ADL SCORM</schema>
    <schemaversion>2004 4th Edition</schemaversion>
  </metadata>
  <organizations default="ORG-1">
    <organization identifier="ORG-1">
      <title>$title</title>
      <item identifier="ITEM-1" identifierref="RES-1" isvisible="true">
        <title>$title</title>
        <adlcp:completionThreshold completedByMeasure="true" minProgressMeasure="1.0"/>
        <imsss:sequencing>
          <imsss:deliveryControls completionSetByContent="true" objectiveSetByContent="true"/>
        </imsss:sequencing>
      </item>
    </organization>
  </organizations>
  <resources>
    <resource identifier="RES-1" type="webcontent" adlcp:scormType="sco" href="index.html">
      <file href="index.html"/>
    </resource>
  </resources>
</manifest>
"@
}

function Add-ZipEntry($Zip, [string]$Name, [byte[]]$Bytes) {
  $e = $Zip.CreateEntry($Name, [IO.Compression.CompressionLevel]::Optimal)
  $s = $e.Open()
  try { $s.Write($Bytes, 0, $Bytes.Length) } finally { $s.Dispose() }
}

function Read-ZipText($Zip, [string]$Name) {
  $e = $Zip.GetEntry($Name)
  if (-not $e) { return $null }
  $r = New-Object IO.StreamReader($e.Open(), $script:Utf8)
  try { return $r.ReadToEnd() } finally { $r.Dispose() }
}

function Get-VersionKey([string]$v) {
  $parts = @($v -split '\.' | ForEach-Object { [int]$_ })
  while ($parts.Count -lt 3) { $parts += 0 }
  return ('{0:D5}.{1:D5}.{2:D5}' -f $parts[0], $parts[1], $parts[2])
}

# ---------------------------------------------------------------- commands

function Invoke-New {
  $name = $Target
  if (-not $name -or $name -cnotmatch '^[a-z0-9]+(-[a-z0-9]+)*$') { Stop-Usage 'Module names are kebab-case, for example ai-and-student-data.' }
  $modDir = Join-Path (Join-Path $script:RepoRoot 'modules') $name
  if (Test-Path -LiteralPath $modDir) { Stop-Usage "modules/$name already exists." }
  $src = $SourceName; if (-not $src) { $src = $name }
  if ($src -match '[\\/:*?"<>|]') { Stop-Usage 'SourceName has characters that cannot be used in a folder name.' }
  $t = $Title; if (-not $t) { $t = (Get-Culture).TextInfo.ToTitleCase(($name -replace '-', ' ')) }
  $starter = Join-Path (Join-Path $script:RepoRoot 'templates') 'module-starter'
  if (-not (Test-Path -LiteralPath (Join-Path $starter 'index.html'))) { Stop-Usage 'templates/module-starter/index.html is missing.' }

  $dest = Join-Path (Join-Path $modDir 'sources') $src
  New-Item -ItemType Directory -Force -Path (Join-Path $dest 'assets') | Out-Null
  Copy-Item -Path (Join-Path (Join-Path $starter 'assets') '*') -Destination (Join-Path $dest 'assets') -Recurse

  $html = Read-Text (Join-Path $starter 'index.html')
  $old = [regex]::Match($html, '(?is)<title>(.*?)</title>').Groups[1].Value
  $json = '{"title":' + (ConvertTo-Json $t -Compress) + ',"identifier":"uplift-' + $name + '","version":"1.0","language":"en-US","interactions":false}'
  $cfg = Get-ModuleConfig $html
  if ($cfg) {
    $html = $html.Substring(0, $cfg.Match.Groups[1].Index) + $json + $html.Substring($cfg.Match.Groups[1].Index + $cfg.Match.Groups[1].Length)
  } else {
    $block = "<script type=`"application/json`" id=`"uplift-module`">$json</script>`n"
    $head = $html.IndexOf('</head>', [StringComparison]::OrdinalIgnoreCase)
    $html = $html.Substring(0, $head) + $block + $html.Substring($head)
  }
  $safeT = [Security.SecurityElement]::Escape($t)
  $html = [regex]::Replace($html, '(?is)<title>.*?</title>', { param($m) "<title>$safeT</title>" })
  $html = [regex]::Replace($html, '(?is)(<span class="course">).*?(</span>)', { param($m) $m.Groups[1].Value + $safeT + $m.Groups[2].Value })
  if ($old) {
    $oldEsc = [regex]::Escape($old)
    $html = [regex]::Replace($html, "(?is)(<h1\b[^>]*>)\s*$oldEsc\s*(</h1>)", { param($m) $m.Groups[1].Value + $safeT + $m.Groups[2].Value })
  }
  $html = [regex]::Replace($html, 'MODULE_KEY\s*=\s*["''][^"'']*["'']', "MODULE_KEY = `"uplift-$name`"")
  Write-Text (Join-Path $dest 'index.html') $html

  $docs = Join-Path (Join-Path $script:RepoRoot 'documentation') 'templates'
  Copy-Item -LiteralPath (Join-Path $docs 'module-readme.md') -Destination (Join-Path $modDir 'README.md')
  Copy-Item -LiteralPath (Join-Path $docs 'module-brief.md') -Destination (Join-Path $modDir 'BRIEF.md')

  Write-Output "Created modules/$name/"
  Write-Output "  sources/$src/index.html   the module (from the starter), titled '$t'"
  Write-Output "  sources/$src/assets/      logo and sound effects"
  Write-Output "  README.md                 fill in before release (committed)"
  Write-Output "  BRIEF.md                  the module plan (not committed)"
  Write-Output ''
  Write-Output 'Next: run the design questionnaire (documentation/02-design-questionnaire.md) to fill in BRIEF.md.'
}

function Invoke-CheckCommand {
  if ($All -or $Target -eq '--all') {
    $mods = @(Get-FrameworkModules)
    if ($mods.Count -eq 0) { Write-Output 'No framework modules found (modules without an uplift-module settings block are skipped).'; exit 0 }
    foreach ($m in $mods) { Write-Output "== modules/$($m.Name)"; Invoke-Check $m -IsStrict:$Strict; Write-Output '' }
    Write-Summary ("{0} module(s)" -f $mods.Count)
  } else {
    $m = Resolve-Module $Target
    Invoke-Check $m -IsStrict:$Strict
    Write-Summary 'Check'
  }
  if ($script:Fails -gt 0) { exit 1 }
  exit 0
}

function Invoke-ContrastCommand {
  $m = Resolve-Module $Target
  $html = Read-Text $m.Index
  Invoke-Contrast $html (New-LineIndex $html)
  Write-Summary 'Contrast'
  if ($script:Fails -gt 0) { exit 1 }
  exit 0
}

function Invoke-Slides {
  $m = Resolve-Module $Target
  $html = Read-Text $m.Index
  $ix = New-LineIndex $html
  $slides = @(Get-Slides (Remove-Comments $html))
  $lines = $html -split "`n"
  $pick = @()
  if ($Section) { $pick = @($slides | Where-Object { $_.Section -eq $Section }) }
  elseif ($Item) {
    if ($Item -match '^\d+$') { $pick = @($slides | Where-Object { $_.N -eq [int]$Item }) }
    else { $pick = @($slides | Where-Object { $_.Title -like "*$Item*" }) }
  }
  if (-not $Section -and -not $Item) {
    Write-Output ('{0,3}  {1,-11} {2,-12} {3,-10} {4}' -f '#', 'Lines', 'Section', 'Gate', 'Title')
    foreach ($s in $slides) {
      $range = '{0}-{1}' -f (Get-LineNumber $ix $s.Start), (Get-LineNumber $ix ([Math]::Max($s.Start, $s.End - 1)))
      Write-Output ('{0,3}  {1,-11} {2,-12} {3,-10} {4}' -f $s.N, $range, $s.Section, $s.Gate, $s.Title)
    }
    Write-Output ("{0} slides. Show one with: tools/module.ps1 slides <module> <number>" -f $slides.Count)
    exit 0
  }
  if ($pick.Count -eq 0) { Write-Output 'No matching slide.'; exit 1 }
  foreach ($s in $pick) {
    $a = Get-LineNumber $ix $s.Start; $b = Get-LineNumber $ix ([Math]::Max($s.Start, $s.End - 1))
    Write-Output ("--- slide {0}: {1} (lines {2}-{3})" -f $s.N, $s.Title, $a, $b)
    for ($i = $a; $i -le $b; $i++) { Write-Output ('{0,5}  {1}' -f $i, $lines[$i - 1].TrimEnd("`r")) }
  }
  exit 0
}

function Invoke-Preview {
  $m = Resolve-Module $Target
  $html = Read-Text $m.Index
  $cfg = Read-Config $m $html
  if (-not $cfg) { Stop-Usage 'The module has no valid uplift-module settings block. Run check for details.' }
  $name = $m.Name; if (-not $name) { $name = ($cfg.identifier -replace '^uplift-', '') }
  $out = Join-Path (Join-Path ([IO.Path]::GetTempPath()) 'uplift-preview') $name
  New-Item -ItemType Directory -Force -Path $out | Out-Null
  $built = Build-Html $m $cfg $true
  $file = Join-Path $out 'index.html'
  Write-Text $file $built
  Write-Output "Preview built with the test LMS panel: $file"
  Write-Output 'It opens in your browser. Progress is saved in that browser only, so you can test resume by closing and reopening.'
  if (-not $NoOpen) { Open-InBrowser $file }
  exit 0
}

function Invoke-Package {
  $m = Resolve-Module $Target
  Write-Output 'Step 1 of 4  Checking (strict)'
  Invoke-Check $m -IsStrict -Quiet
  if ($script:Fails -gt 0) { Write-Summary 'Package stopped'; exit 1 }
  Write-Output ("  OK ({0} warning(s) to review)" -f $script:Warns)

  $html = Read-Text $m.Index
  $cfg = Read-Config $m $html
  $name = $m.Name; if (-not $name) { $name = ($cfg.identifier -replace '^uplift-', '') }
  $dir = $OutDir
  if (-not $dir) {
    if (-not $m.Name) { Stop-Usage 'This folder is not under modules/<name>/sources/, so pass -OutDir <folder>.' }
    $dir = Split-Path -Parent (Split-Path -Parent $m.Dir)
  }
  if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
  $dir = (Resolve-Path -LiteralPath $dir).Path
  $zipName = "$name-v$($cfg.version)-scorm.zip"
  $zipPath = Join-Path $dir $zipName
  if ((Test-Path -LiteralPath $zipPath) -and -not $Force) {
    Stop-Usage "$zipName already exists. Bump the version in the settings block (packages are never overwritten), or pass -Force for a test build."
  }

  Write-Output 'Step 2 of 4  Building (inline assets, add the SCORM runtime, write the manifest)'
  $built = Build-Html $m $cfg $false
  $manifest = Get-Manifest $cfg
  $xsdDir = Join-Path $PSScriptRoot 'scorm'
  $xsds = @(Get-ChildItem -LiteralPath $xsdDir -Filter '*.xsd' -File)
  if ($xsds.Count -lt 15) { Stop-Usage "tools/scorm/ should hold 15 .xsd files but has $($xsds.Count)." }
  if (Test-Path -LiteralPath $zipPath) { Remove-Item -LiteralPath $zipPath -Force }
  $fs = [IO.File]::Open($zipPath, [IO.FileMode]::CreateNew)
  $zip = New-Object IO.Compression.ZipArchive($fs, [IO.Compression.ZipArchiveMode]::Create)
  try {
    Add-ZipEntry $zip 'imsmanifest.xml' ($script:Utf8.GetBytes($manifest))
    Add-ZipEntry $zip 'index.html' ($script:Utf8.GetBytes($built))
    foreach ($x in $xsds) { Add-ZipEntry $zip $x.Name ([IO.File]::ReadAllBytes($x.FullName)) }
  } finally { $zip.Dispose(); $fs.Dispose() }

  Write-Output 'Step 3 of 4  Verifying the zip'
  $bad = @()
  $z = [IO.Compression.ZipFile]::OpenRead($zipPath)
  $jalons = @()
  try {
    $names = @($z.Entries | ForEach-Object { $_.FullName })
    foreach ($need in @('imsmanifest.xml', 'index.html') + @($xsds | ForEach-Object { $_.Name })) { if ($names -notcontains $need) { $bad += "missing $need" } }
    if (@($names | Where-Object { $_ -match '[\\/]' }).Count -gt 0) { $bad += 'entries must be at the zip root' }
    $mText = Read-ZipText $z 'imsmanifest.xml'
    try {
      $xml = New-Object Xml.XmlDocument; $xml.LoadXml($mText)
      if ($xml.DocumentElement.GetAttribute('identifier') -ne $cfg.identifier) { $bad += 'manifest identifier mismatch' }
    } catch { $bad += 'imsmanifest.xml is not valid XML' }
    if ($mText -match 'minNormalizedMeasure') { $bad += 'manifest has a mastery score (minNormalizedMeasure)' }
    if ($mText -notmatch 'minProgressMeasure="1\.0"') { $bad += 'completion threshold is not 1.0' }
    $iText = Read-ZipText $z 'index.html'
    if ($iText -notmatch 'uplift-scorm-runtime') { $bad += 'SCORM runtime not in index.html' }
    if ($iText -notmatch '"testMode":false') { $bad += 'test mode is not off' }
    $jalons = @(Get-JalonIds (Remove-Comments $iText))
    if ($jalons.Count -eq 0) { $bad += 'no data-jalon milestones' }
    if ([regex]::IsMatch($iText, '(?i)(?:src|href)\s*=\s*["'']assets/|url\(\s*["'']?assets/')) { $bad += 'assets/ references left (not inlined)' }
  } finally { $z.Dispose() }
  if ($bad.Count -gt 0) {
    foreach ($b in $bad) { Write-Output "FAIL  verify         $b" }
    Remove-Item -LiteralPath $zipPath -Force
    Write-Output 'RESULT  Package failed verification and was deleted.'
    exit 1
  }
  Write-Output '  OK'

  Write-Output 'Step 4 of 4  Comparing with the previous version'
  $cur = Get-VersionKey $cfg.version
  $prev = $null; $prevVer = $null
  foreach ($f in (Get-ChildItem -LiteralPath $dir -Filter "$name-v*-scorm.zip" -File)) {
    $vm = [regex]::Match($f.Name, '-v(\d+(?:\.\d+){1,2})-scorm\.zip$')
    if (-not $vm.Success -or $f.FullName -eq $zipPath) { continue }
    $k = Get-VersionKey $vm.Groups[1].Value
    if ($k -lt $cur -and ((-not $prev) -or $k -gt (Get-VersionKey $prevVer))) { $prev = $f.FullName; $prevVer = $vm.Groups[1].Value }
  }
  $upload = 'NEW COURSE (first upload)'
  if ($prev) {
    $z = [IO.Compression.ZipFile]::OpenRead($prev)
    try {
      $pm = Read-ZipText $z 'imsmanifest.xml'; $pi = Read-ZipText $z 'index.html'
    } finally { $z.Dispose() }
    $reasons = @()
    $pid2 = [regex]::Match([string]$pm, '<manifest[^>]*\bidentifier="([^"]+)"').Groups[1].Value
    if ($pid2 -and $pid2 -ne $cfg.identifier) { $reasons += "identifier changed from $pid2 to $($cfg.identifier)" }
    $pj = @(Get-JalonIds (Remove-Comments ([string]$pi)))
    $gone = @($pj | Where-Object { $jalons -notcontains $_ })
    if ($gone.Count -gt 0) { $reasons += ("milestone(s) removed or renamed: {0}" -f ($gone -join ', ')) }
    if ($reasons.Count -gt 0) { $upload = "NEW COURSE (resets completions) because $($reasons -join '; ')" }
    else {
      $added = @($jalons | Where-Object { $pj -notcontains $_ })
      $upload = "REPLACE v$prevVer (keeps learner progress)"
      if ($added.Count -gt 0) { $upload += (". New milestone(s): {0}. Learners who had finished will need to reach them" -f ($added -join ', ')) }
    }
  }

  $size = (Get-Item -LiteralPath $zipPath).Length
  Write-Output ''
  Write-Output "Package     $zipPath"
  Write-Output ("Size        {0:N0} KB" -f [Math]::Ceiling($size / 1024))
  Write-Output "Identifier  $($cfg.identifier)"
  Write-Output ("Milestones  {0} ({1})" -f $jalons.Count, ($jalons -join ', '))
  Write-Output "LMS upload  $upload"
  Write-Output ''
  Write-Output 'Next: test it in SCORM Cloud or the LMS sandbox (launch, completion, passed, score, resume) before uploading.'
  if ($script:Warns -gt 0) { Write-Output ("Note: {0} warning(s) from the check. Run 'check' to see them." -f $script:Warns) }
  exit 0
}

function Show-Help {
  Write-Output 'Uplift module tools'
  Write-Output '  new <name> [-SourceName <folder>] [-Title "<title>"]   start a module from the starter'
  Write-Output '  check <name|path|--all> [-Strict]                       lint + contrast'
  Write-Output '  contrast <name|path>                                    contrast table only'
  Write-Output '  slides <name|path> [<n>|"<title>"] [-Section <id>]      list slides, or print one'
  Write-Output '  preview <name|path>                                     build with the test LMS and open it'
  Write-Output '  package <name|path> [-OutDir <folder>] [-Force]         build the SCORM 2004 zip'
  Write-Output 'Exit codes: 0 OK, 1 problems found, 2 usage or setup error.'
}

# ---------------------------------------------------------------- dispatch

if (-not $Command) { Show-Help; exit 0 }

switch ($Command) {
  'new' { Invoke-New; exit 0 }
  'check' { Invoke-CheckCommand }
  'contrast' { Invoke-ContrastCommand }
  'slides' { Invoke-Slides }
  'preview' { Invoke-Preview }
  'package' { Invoke-Package }
  'menu' {
    Write-Output 'Uplift module tools'
    Write-Output '  1  Check a module'
    Write-Output '  2  Preview a module in your browser'
    Write-Output '  3  Package a module for the LMS'
    Write-Output '  4  Start a new module'
    Write-Output '  5  List a module''s slides'
    $choice = Read-Host 'Choose 1-5'
    $map = @{ '1' = 'check'; '2' = 'preview'; '3' = 'package'; '4' = 'new'; '5' = 'slides' }
    if (-not $map.ContainsKey([string]$choice)) { Write-Output 'Nothing run.'; exit 2 }
    if ($choice -ne '4') {
      $mods = @(Get-FrameworkModules | ForEach-Object { $_.Name })
      if ($mods.Count -gt 0) { Write-Output ('Modules: {0}' -f ($mods -join ', ')) }
      $name = Read-Host 'Module name (folder under modules/)'
    } else {
      $name = Read-Host 'New module name (kebab-case, for example ai-and-student-data)'
    }
    if (-not $name) { Write-Output 'Nothing run.'; exit 2 }
    $Command = $map[[string]$choice]; $Target = $name
    switch ($Command) {
      'check' { Invoke-CheckCommand }
      'preview' { Invoke-Preview }
      'package' { Invoke-Package }
      'new' { Invoke-New; exit 0 }
      'slides' { Invoke-Slides }
    }
  }
  { @('help', '-h', '--help', '/?') -contains $_ } { Show-Help; exit 0 }
  default { Stop-Usage "Unknown command '$Command'." }
}
