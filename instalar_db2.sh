#!/bin/bash
# Script de instalación automatizada de DB2 (Proyecto AquaSmart)
# Requiere privilegios de root

echo "--- 1. Actualizando sistema e instalando dependencias ---"
apt-get update -y
apt-get install -y libaio1 libpam0g:i386 binutils libnuma1

echo "--- 2. Creando usuarios y grupos del sistema para DB2 ---"
groupadd db2iadm1
groupadd db2fadm1
useradd -g db2iadm1 -m -d /home/db2inst1 db2inst1
useradd -g db2fadm1 -m -d /home/db2fenc1 db2fenc1

# Asignando contraseñas por defecto (db2admin)
echo "db2inst1:db2admin" | chpasswd
echo "db2fenc1:db2admin" | chpasswd

echo "--- 3. Ejecutando instalación silenciosa ---"
# Se asume que el binario de DB2 se extrajo en /tmp/server_dec
# y que el archivo de respuesta db2server.rsp está en /tmp/
cd /tmp/server_dec
./db2setup -r /tmp/db2server.rsp

echo "--- 4. Configurando puerto TCP/IP ---"
su - db2inst1 -c "db2set DB2COMM=TCPIP"
su - db2inst1 -c "db2 update dbm cfg using SVCENAME 50000"
su - db2inst1 -c "db2stop && db2start"

echo "✅ DB2 instalado y configurado en el puerto 50000."
