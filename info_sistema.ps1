<# 
    Script: info_sistema.ps1
    Propósito: Recolectar información básica del sistema de manera inocua.
    Acciones:
      - Muestra procesos en ejecución.
      - Lista servicios en ejecución.
      - Guarda la información en un archivo log en la carpeta del script.
#>

Write-Output "Recolectando información del sistema..."

# Obtener fecha y ruta base
$fecha = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$logPath = "$PSScriptRoot\sistema_info.log"

# Escribir encabezado
"===== Información del sistema =====" | Out-File -FilePath $logPath -Encoding UTF8
"Fecha de ejecución: $fecha" | Out-File -FilePath $logPath -Encoding UTF8 -Append

# Listar procesos
"=== Procesos en ejecución ===" | Out-File -FilePath $logPath -Encoding UTF8 -Append
Get-Process | Select-Object -First 20 | Out-File -FilePath $logPath -Encoding UTF8 -Append

# Listar servicios
"=== Servicios en ejecución ===" | Out-File -FilePath $logPath -Encoding UTF8 -Append
Get-Service | Where-Object {$_.Status -eq 'Running'} | Select-Object -First 20 | Out-File -FilePath $logPath -Encoding UTF8 -Append

Write-Output "Información recopilada en $logPath"
