#!/bin/bash
# ==============================================================================
# Script de Automatización: Instalación de IBM DB2 - Equipo C
# Nodos: dbnodo1, dbnodo2, dbnodo3
# ==============================================================================

echo "Empezando la instalación automatizada de dependencias para DB2..."

# 1. Instalar dependencias requeridas por IBM DB2 en Ubuntu
sudo apt-get update -y
sudo apt-get install -y libaio1 libnuma1 numactl tar curl binutils libstdc++6 pam dkms

# 2. Crear grupos y usuarios del sistema para la instancia de DB2
echo "Creando usuarios y grupos (db2iadm1, db2inst1, db2fenc1)..."
sudo groupadd db2iadm1
sudo groupadd db2fadm1
sudo useradd -g db2iadm1 -m -d /home/db2inst1 db2inst1 -s /bin/bash
sudo useradd -g db2fadm1 -m -d /home/db2fenc1 db2fenc1 -s /bin/bash

# Ponerles contraseña temporal (db2admin)
echo "db2inst1:db2admin" | sudo chpasswd
echo "db2fenc1:db2admin" | sudo chpasswd

# 3. Crear el archivo de respuestas (Response File) para instalación silenciosa
echo "Generando archivo de respuestas (db2_silent.rsp)..."
cat <<EOF > /tmp/db2_silent.rsp
PROD                      = DB2_SERVER_EDITION
FILE                      = /opt/ibm/db2/V11.5
LIC_AGREEMENT             = ACCEPT
INSTALL_TYPE              = TYPICAL
INSTANCE                  = db2inst1
db2inst1.NAME             = db2inst1
db2inst1.GROUP_NAME       = db2iadm1
db2inst1.HOME_DIRECTORY   = /home/db2inst1
db2inst1.PASSWORD         = db2admin
db2inst1.AUTOSTART        = YES
db2inst1.FENCED_USERNAME  = db2fenc1
db2inst1.FENCED_GROUP_NAME= db2fadm1
db2inst1.FENCED_PASSWORD  = db2admin
EOF

# 4. Preparación final
echo "========================================================================"
echo "¡Dependencias y configuración listas!"
echo "Archivos de respuesta generados en /tmp/db2_silent.rsp"
echo "========================================================================"

# 5. Ejecutar instalación silenciosa
echo "Ejecutando instalación silenciosa de DB2..."
# Asegúrate de estar en la carpeta donde descomprimiste el instalador
cd server_dec
sudo ./db2setup -r /tmp/db2_silent.rsp

echo "========================================================================"
echo "Instalación completada. Reiniciando servicios..."
echo "========================================================================"
