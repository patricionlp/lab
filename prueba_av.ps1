\
<# 
    Script: prueba_av.ps1
    Propósito: Pruebas seguras de antivirus usando la cadena EICAR (no es malware).
    Acciones:
      - Crea archivos con la cadena EICAR en una carpeta temporal.
      - Crea un ZIP que contiene el archivo EICAR para probar análisis en archivos comprimidos.
      - Registra qué acciones fueron bloqueadas por el AV.
    Nota: La mayoría de AV detectará/borrará estos archivos inmediatamente.
#>

$ErrorActionPreference = 'Stop'

# Carpeta de trabajo
$base = Join-Path $env:TEMP "AV_Test_" + (Get-Date -Format "yyyyMMdd_HHmmss")
New-Item -Path $base -ItemType Directory -Force | Out-Null

# Cadena EICAR oficial (la 'O' es letra O mayúscula, no cero)
$EICAR = 'X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*'

# Rutas de prueba
$txtPath = Join-Path $base "eicar.txt"
$comPath = Join-Path $base "eicar.com"
$logPath = Join-Path $base "resultado_prueba.log"
$zipPath = Join-Path $base "eicar.zip"

# Función auxiliar para registrar eventos
function Write-Log($msg) {
    $stamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$stamp`t$msg" | Add-Content -Path $logPath -Encoding UTF8
    Write-Output $msg
}

Write-Log "Carpeta de trabajo: $base"

# 1) Crear eicar.txt
try {
    Set-Content -Path $txtPath -Value $EICAR -Encoding ASCII -NoNewline
    Write-Log "Creado: $txtPath"
} catch {
    Write-Log "AV bloqueó la creación de $txtPath: $($_.Exception.Message)"
}

# 2) Crear eicar.com (algunos AV lo bloquean más agresivamente)
try {
    Set-Content -Path $comPath -Value $EICAR -Encoding ASCII -NoNewline
    Write-Log "Creado: $comPath"
} catch {
    Write-Log "AV bloqueó la creación de $comPath: $($_.Exception.Message)"
}

# 3) Crear ZIP con eicar.txt adentro para probar análisis en archivos comprimidos
try {
    # Asegurar que exista el archivo fuente; si no, volver a crearlo en memoria
    if (-not (Test-Path $txtPath)) {
        Set-Content -Path $txtPath -Value $EICAR -Encoding ASCII -NoNewline -ErrorAction SilentlyContinue | Out-Null
    }

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    if (Test-Path $zipPath) { Remove-Item $zipPath -Force -ErrorAction SilentlyContinue }
    [System.IO.Compression.ZipFile]::CreateFromDirectory($base, $zipPath)
    Write-Log "Creado ZIP (puede que el AV lo bloquee): $zipPath"
} catch {
    Write-Log "AV bloqueó la creación del ZIP: $($_.Exception.Message)"
}

# 4) Intentar leer los archivos para ver si ya fueron removidos por el AV
foreach ($p in @($txtPath, $comPath, $zipPath)) {
    if (Test-Path $p) {
        try {
            $len = (Get-Item $p).Length
            Write-Log "Presente: $p (tamaño: $len bytes)"
        } catch {
            Write-Log "No se pudo acceder a $p: $($_.Exception.Message)"
        }
    } else {
        Write-Log "El AV removió o bloqueó: $p"
    }
}

Write-Log "Prueba finalizada. Revisa $logPath y tu consola de seguridad para alertas."
Write-Output "=== RESUMEN ==="
Get-Content -Path $logPath -ErrorAction SilentlyContinue | ForEach-Object { $_ }
