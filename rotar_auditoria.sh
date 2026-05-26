#!/bin/bash
# Extrae, archiva y mueve los registros de auditoría al almacenamiento externo (NFS)
# Ejecutar como usuario db2inst1 en el Nodo 1

FECHA=$(date +"%Y%m%d_%H%M%S")
RUTA_DESTINO="/mnt/respaldos_nfs/auditoria"
ARCHIVO_TMP="/tmp/auditoria_$FECHA.del"

echo "Archivando logs de auditoría activos..."
db2audit archive

echo "Extrayendo registros a texto plano..."
db2audit extract file $ARCHIVO_TMP

echo "Moviendo archivo al almacenamiento externo (NFS)..."
# Aseguramos que la carpeta de destino exista en el NFS por si acaso
mkdir -p $RUTA_DESTINO
mv $ARCHIVO_TMP $RUTA_DESTINO/

echo "✅ Evidencia de auditoría guardada de forma segura en: $RUTA_DESTINO/auditoria_$FECHA.del"
