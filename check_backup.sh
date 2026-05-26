#!/bin/bash
# Script de verificación de integridad de respaldos - Proyecto AquaSmart
# Ejecutar como usuario db2inst1

BACKUP_DIR="/mnt/respaldos_nfs"

echo "Buscando el último respaldo generado..."
# Encuentra el archivo más reciente que empiece con AQUASMRT
ULTIMO_BACKUP=$(ls -t $BACKUP_DIR/AQUASMRT.* 2>/dev/null | head -1)

if [ -z "$ULTIMO_BACKUP" ]; then
    echo "❌ ERROR: No se encontraron archivos de respaldo en $BACKUP_DIR."
    exit 1
fi

echo "Verificando integridad física y lógica de: $ULTIMO_BACKUP"
db2ckbkp $ULTIMO_BACKUP

if [ $? -eq 0 ]; then
    echo "✅ ÉXITO: El respaldo es íntegro y completamente funcional para recuperación."
else
    echo "❌ ERROR CRÍTICO: El archivo de respaldo está corrupto."
fi
