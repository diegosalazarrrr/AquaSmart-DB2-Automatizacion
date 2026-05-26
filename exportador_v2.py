import ibm_db
import time
from prometheus_client import start_http_server, Gauge

# Configuración de conexión (Usamos el puerto 50000 porque lee métricas internas del nodo local)
conn_str = "DATABASE=AQUASMRT;HOSTNAME=10.0.0.132;PORT=50000;PROTOCOL=TCPIP;UID=db2inst1;PWD=db2admin;"

# Definición de las 5 métricas requeridas para el dashboard de Grafana
metric_conexiones = Gauge('db2_active_connections', 'Número de conexiones activas a la BD')
metric_tps = Gauge('db2_total_commits', 'Total de commits (Transacciones)')
metric_lag = Gauge('db2_replica_lag_bytes', 'Lag de la réplica HADR en bytes')
metric_disco = Gauge('db2_disk_usage_percent', 'Porcentaje de uso de disco (Tablespaces)')
metric_lentas = Gauge('db2_slow_queries_total', 'Consultas que tardan más de 2 segundos')

def recolectar_metricas():
    # Inicia el servidor web en el puerto 8000 para que Prometheus raspe los datos
    start_http_server(8000)
    print("Exportador V2 listo en puerto 8000... Transmitiendo 5 métricas.")

    while True:
        try:
            # 0. Conectar a la base de datos
            conn = ibm_db.connect(conn_str, "", "")

            # 1. Conexiones Activas
            stmt = ibm_db.exec_immediate(conn, "SELECT COUNT(*) FROM TABLE(MON_GET_CONNECTION(NULL, -2))")
            conexiones = ibm_db.fetch_tuple(stmt)[0]
            metric_conexiones.set(conexiones)

            # 2. Transacciones (TPS / Commits)
            stmt = ibm_db.exec_immediate(conn, "SELECT SUM(TOTAL_APP_COMMITS) FROM TABLE(MON_GET_WORKLOAD('', -2))")
            tps = ibm_db.fetch_tuple(stmt)[0]
            if tps is not None: metric_tps.set(tps)

            # 3. Réplica Lag (HADR_LOG_GAP)
            try:
                stmt_lag = ibm_db.exec_immediate(conn, "SELECT HADR_LOG_GAP FROM TABLE(MON_GET_HADR(NULL))")
                lag_val = ibm_db.fetch_tuple(stmt_lag)
                if lag_val and lag_val[0] is not None:
                    metric_lag.set(lag_val[0])
                else:
                    metric_lag.set(0)
            except:
                metric_lag.set(0)

            # 4. Uso de Disco
            try:
                stmt_disk = ibm_db.exec_immediate(conn, "SELECT SUM(TBSP_USED_PAGES) * 100.0 / SUM(TBSP_USABLE_PAGES) FROM TABLE(MON_GET_TABLESPACE('', -2)) WHERE TBSP_USABLE_PAGES > 0")
                disk_val = ibm_db.fetch_tuple(stmt_disk)
                if disk_val and disk_val[0] is not None:
                    metric_disco.set(float(disk_val[0]))
            except:
                pass

            # 5. Consultas Lentas (Cache execution time > 2000 milisegundos)
            try:
                stmt_slow = ibm_db.exec_immediate(conn, "SELECT count(*) FROM TABLE(MON_GET_PKG_CACHE_STMT('D', NULL, NULL, -2)) WHERE STMT_EXEC_TIME > 2000")
                slow_val = ibm_db.fetch_tuple(stmt_slow)
                if slow_val and slow_val[0] is not None:
                    metric_lentas.set(slow_val[0])
            except:
                pass

            # Cerrar conexión limpia
            ibm_db.close(conn)
            
        except Exception as e:
            # CRÍTICO PARA LA DEMO: Si detienes el nodo, el script reporta error pero no se cierra
            print(f"[{time.strftime('%X')}] Base de datos inaccesible (Posible prueba de Failover)... reintentando.")
        
        # Espera 5 segundos antes de volver a consultar (Balance entre frescura de datos y carga al CPU)
        time.sleep(5)

if __name__ == "__main__":
    recolectar_metricas()
