#!/bin/bash
# =====================================================================
# Script de Instalación y Preparación de Entorno para IBM DB2
# Proyecto: AquaSmart
# =====================================================================

echo "1. Actualizando repositorios del sistema operativo..."
sudo apt update && sudo apt upgrade -y

echo "2. Instalando dependencias requeridas por DB2 (libaio y libnuma)..."
sudo apt install libaio1 libnuma1 -y

echo "3. Ejecutando creación de la instancia DB2 (db2inst1)..."
sudo /opt/ibm/db2/V11.5/instance/db2icrt -u db2fenc1 db2inst1

echo "4. Configurando el protocolo de comunicación TCP/IP..."
sudo su - db2inst1 -c "db2set DB2COMM=TCPIP"
sudo su - db2inst1 -c "db2 update dbm cfg using SVCENAME 50000"

echo "5. Reiniciando el motor para aplicar los cambios de red..."
sudo su - db2inst1 -c "db2stop"
sudo su - db2inst1 -c "db2start"

echo "6. Creando la base de datos principal y configurando logs para HADR..."
sudo su - db2inst1 -c "db2 create database AQUASMRT"
sudo su - db2inst1 -c "db2 update db cfg for AQUASMRT using LOGARCHMETH1 LOGRETAIN"

echo "Instalación base completada con éxito."
