#!/bin/bash
# Script para promover este nodo Standby a Primario (Failover Manual)
# Ejecutar como usuario db2inst1 en el Nodo 2 o Nodo 3

DB_NAME="AQUASMRT"

echo "Iniciando proceso de Takeover (Promoviendo a Primario)..."
db2 takeover hadr on db $DB_NAME

echo "Verificando nuevo estado del nodo..."
db2pd -db $DB_NAME -hadr | grep "HADR_ROLE"

echo "✅ El nodo ha asumido el rol primario exitosamente y está listo para recibir escrituras."
