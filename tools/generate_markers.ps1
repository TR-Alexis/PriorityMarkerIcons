param(
    [string]$OutputDirectory = (Join-Path $PSScriptRoot "..\Media")
)

$resolvedOutput = [System.IO.Path]::GetFullPath($OutputDirectory)
[System.IO.Directory]::CreateDirectory($resolvedOutput) | Out-Null

function Write-Tga {
    param(
        [string]$Path,
        [ValidateSet("Triangle", "Square")]
        [string]$Shape
    )

    $size = 64
    $stream = [System.IO.File]::Open($Path, [System.IO.FileMode]::Create)
    $writer = [System.IO.BinaryWriter]::new($stream)
    try {
        # TGA 2: uncompressed true-color, 64x64, 32-bit BGRA, top-left origin.
        $writer.Write([byte]0)
        $writer.Write([byte]0)
        $writer.Write([byte]2)
        $writer.Write([byte[]](0, 0, 0, 0, 0))
        $writer.Write([UInt16]0)
        $writer.Write([UInt16]0)
        $writer.Write([UInt16]$size)
        $writer.Write([UInt16]$size)
        $writer.Write([byte]32)
        $writer.Write([byte]0x28)

        for ($y = 0; $y -lt $size; $y++) {
            for ($x = 0; $x -lt $size; $x++) {
                $inside = $false
                $border = $false

                if ($Shape -eq "Triangle") {
                    $halfWidth = ($y - 8) * 0.48
                    $inside = $y -ge 8 -and $y -le 56 -and [Math]::Abs($x - 31.5) -le $halfWidth
                    $innerHalfWidth = ($y - 13) * 0.42
                    $inner = $y -ge 14 -and $y -le 50 -and [Math]::Abs($x - 31.5) -le $innerHalfWidth
                    $border = $inside -and -not $inner
                } else {
                    $inside = $x -ge 8 -and $x -le 55 -and $y -ge 8 -and $y -le 55
                    $border = $inside -and ($x -lt 14 -or $x -gt 49 -or $y -lt 14 -or $y -gt 49)
                }

                if (-not $inside) {
                    $writer.Write([byte[]](0, 0, 0, 0))
                } elseif ($border) {
                    $writer.Write([byte[]](8, 12, 12, 255))
                } elseif ($Shape -eq "Triangle") {
                    $writer.Write([byte[]](40, 220, 35, 255))
                } else {
                    $writer.Write([byte[]](235, 125, 30, 255))
                }
            }
        }
    } finally {
        $writer.Dispose()
        $stream.Dispose()
    }
}

if (-not (Test-Path -LiteralPath (Join-Path $resolvedOutput "_triangle.tga"))) {
    Write-Tga -Path (Join-Path $resolvedOutput "_triangle.tga") -Shape Triangle
}

if (-not (Test-Path -LiteralPath (Join-Path $resolvedOutput "_square.tga"))) {
    Write-Tga -Path (Join-Path $resolvedOutput "_square.tga") -Shape Square
}

Write-Output "Generated only missing legacy marker templates in $resolvedOutput"
