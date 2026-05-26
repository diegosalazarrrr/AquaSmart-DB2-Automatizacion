#!/bin/bash
# Script de Demostración PITR - AquaSmart
# Ejecutar como usuario db2inst1

DB_NAME="AQUASMRT"
BACKUP_DIR="/mnt/respaldos_nfs" # Usamos tu montaje NFS
TIMESTAMP_DROP=""

echo "--- 1. Insertando datos de prueba ---"
db2 "INSERT INTO demo_trafico (mensaje, nodo) VALUES ('Dato antes del desastre', 'dbnodo1')"
db2 "COMMIT"

echo "--- 2. Tomando Backup en caliente ---"
db2 backup db $DB_NAME online to $BACKUP_DIR
sleep 2

echo "--- 3. Marcando hora exacta del desastre ---"
TIMESTAMP_DROP=$(date +"%Y-%m-%d-%H.%M.%S")
echo "Desastre ocurrirá en: $TIMESTAMP_DROP"

echo "--- 4. SIMULANDO DESASTRE (Borrando datos...) ---"
db2 "DELETE FROM demo_trafico"
db2 "COMMIT"
echo "¡Datos borrados! La tabla demo_trafico está vacía."

echo "--- 5. Recuperando al pasado (PITR) ---"
# Restaurar desde el backup más reciente
# Nota: db2 buscará el timestamp automáticamente en el directorio
db2 restore db $DB_NAME from $BACKUP_DIR taken at <TIMESTAMP_BACKUP>
db2 "rollforward db $DB_NAME to $TIMESTAMP_DROP and stop"

echo "--- Verificando resultado ---"
db2 "SELECT count(*) FROM demo_trafico"
