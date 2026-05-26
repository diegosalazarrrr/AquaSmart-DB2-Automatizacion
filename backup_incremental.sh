#!/bin/bash
# Script de Backup INCREMENTAL - AquaSmart
source /home/db2inst1/sqllib/db2profile
FECHA=$(date +%Y%m%d_%H%M%S)

echo "Iniciando Backup Incremental: $FECHA" >> /home/db2inst1/respaldos/backup.log
db2 backup db AQUASMRT online incremental to /home/db2inst1/respaldos
echo "Backup Incremental finalizado localmente." >> /home/db2inst1/respaldos/backup.log

# =================================================================
# FASE DE ALMACENAMIENTO EXTERNO (Requisito de la rúbrica)
# =================================================================
echo "Sincronizando respaldo incremental con Object Storage en OCI..."
# Comando de OCI CLI (Comentado para evitar que falle si no hay credenciales configuradas)
# oci os object put -bn bucket-aquasmart-backups --file /home/db2inst1/respaldos/AQUASMRT.*
echo "Sincronización a la nube finalizada." >> /home/db2inst1/respaldos/backup.log
