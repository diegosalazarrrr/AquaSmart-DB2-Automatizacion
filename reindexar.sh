#!/bin/bash
# Mantenimiento y reindexación semanal - AquaSmart
# Ejecutar como usuario db2inst1 (Semanal)

DB_NAME="AQUASMRT"

echo "Conectando a la base de datos..."
# Cargamos el perfil de DB2 por si se ejecuta desde el cron
source /home/db2inst1/sqllib/db2profile
db2 connect to $DB_NAME

echo "Reorganizando índices fragmentados..."
# ALLOW WRITE ACCESS permite que el sistema siga operando mientras se reindexa
db2 "REORG INDEXES ALL FOR TABLE db2inst1.demo_trafico ALLOW WRITE ACCESS"

echo "Actualizando estadísticas del optimizador (RUNSTATS)..."
db2 "RUNSTATS ON TABLE db2inst1.demo_trafico AND INDEXES ALL"

echo "✅ Mantenimiento y reindexación completados exitosamente."
db2 connect reset
