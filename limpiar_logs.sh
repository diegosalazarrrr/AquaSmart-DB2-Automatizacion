#!/bin/bash
# Limpieza de logs de diagnóstico de DB2 con más de 7 días de antigüedad
# Ejecutar como usuario db2inst1 (Diario)

echo "Iniciando limpieza de logs..."

# Directorio por defecto de logs de diagnóstico en DB2
LOG_DIR="/home/db2inst1/sqllib/db2dump/"

# Encuentra y elimina archivos .log con más de 7 días
find $LOG_DIR -name "*.log" -mtime +7 -exec rm {} \;

echo "✅ Logs antiguos eliminados correctamente."
