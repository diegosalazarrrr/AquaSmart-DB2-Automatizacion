#!/usr/bin/env python3
from prometheus_client import start_http_server, Gauge
import ibm_db
import time

# Definición de métricas para Grafana
conexiones_activas = Gauge('db2_conexiones_activas', 'Conexiones actuales a la base de datos')
total_commits = Gauge('db2_total_commits', 'Total de transacciones confirmadas (App Commits)')

# Cadena de conexión al Nodo Primario local
conn_str = "DATABASE=AQUASMRT;HOSTNAME=10.0.0.132;PORT=50000;PROTOCOL=TCPIP;UID=db2inst1;PWD=db2admin;"

def obtener_metricas():
    try:
        conn = ibm_db.connect(conn_str, "", "")
        
        # 1. Extracción de conexiones activas desde MON_GET_CONNECTION
        stmt1 = ibm_db.exec_immediate(conn, "SELECT COUNT(*) FROM TABLE(MON_GET_CONNECTION(NULL, -1))")
        row1 = ibm_db.fetch_tuple(stmt1)
        if row1:
            conexiones_activas.set(row1[0])
        
        # 2. Extracción de Commits Totales desde MON_GET_WORKLOAD
        stmt2 = ibm_db.exec_immediate(conn, "SELECT SUM(TOTAL_APP_COMMITS) FROM TABLE(MON_GET_WORKLOAD('', -1))")
        row2 = ibm_db.fetch_tuple(stmt2)
        if row2 and row2[0] is not None:
            total_commits.set(row2[0])
            
        ibm_db.close(conn)
    except Exception as e:
        # Si la base de datos está caída, las conexiones bajan a 0 para activar la alerta de Grafana
        conexiones_activas.set(0)

if __name__ == '__main__':
    # Iniciar el servidor HTTP interno en el puerto 8000 para Prometheus
    start_http_server(8000)
    print("Exportador de DB2 AquaSmart transmitiendo en el puerto 8000...")
    while True:
        obtener_metricas()
        time.sleep(5)
