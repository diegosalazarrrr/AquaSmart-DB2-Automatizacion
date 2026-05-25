#!/bin/bash
# Script de Backup FULL - AquaSmart
source /home/db2inst1/sqllib/db2profile
FECHA=$(date +%Y%m%d_%H%M%S)
echo "Iniciando Backup Full: $FECHA" >> /home/db2inst1/respaldos/backup.log
db2 backup db AQUASMRT online to /home/db2inst1/respaldos
echo "Backup Full finalizado." >> /home/db2inst1/respaldos/backup.log
