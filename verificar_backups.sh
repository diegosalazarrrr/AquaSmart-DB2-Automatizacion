#!/bin/bash
# Script de Verificación de Integridad de Backups de DB2
echo "Iniciando escaneo de integridad de archivos de respaldo..."
cd /home/db2inst1/respaldos

# Usar db2ckbkp para comprobar que los archivos generados no estén corruptos
for backup_file in AQUASMRT.0.*; do
    if [ -f "$backup_file" ]; then
        db2ckbkp "$backup_file"
        if [ $? -eq 0 ]; then
            echo "[OK] Respaldo íntegro: $backup_file" >> integridad.log
        else
            echo "[ERROR] Respaldo corrupto detectado: $backup_file" >> integridad.log
        fi
    fi
done
echo "Verificación completada. Revise integridad.log"
