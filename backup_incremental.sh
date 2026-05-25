#!/bin/bash
# Script de Backup INCREMENTAL - AquaSmart
source /home/db2inst1/sqllib/db2profile
FECHA=$(date +%Y%m%d_%H%M%S)
echo "Iniciando Backup Incremental: $FECHA" >> /home/db2inst1/respaldos/backup.log
db2 backup db AQUASMRT online incremental to /home/db2inst1/respaldos
echo "Backup Incremental finalizado." >> /home/db2inst1/respaldos/backup.log
