Write-Output "Ejecutando tarea básica en PowerShell..."

# Obtener la fecha y hora actual
$fecha = Get-Date

# Crear un archivo de texto con la fecha y hora actual
$path = "$PSScriptRoot\resultado.txt"
"El script se ejecutó en: $fecha" | Out-File -FilePath $path -Encoding UTF8

Write-Output "Archivo creado en $path"
