#!/bin/bash
# Mantenimiento y Reindexación - AquaSmart
source /home/db2inst1/sqllib/db2profile
db2 connect to AQUASMRT
echo "Reorganizando tablas e índices fragmentados..."
db2 reorgchk update statistics on table all
db2 disconnect AQUASMRT
echo "Limpiando logs antiguos de auditoría..."
db2audit prune date $(date --date="7 days ago" +%Y%m%d)
