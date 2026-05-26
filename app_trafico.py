import ibm_db
import time
import datetime

# Conecta al balanceador HAProxy (Puerto 50000)
conn_str = "DATABASE=AQUASMRT;HOSTNAME=10.0.0.132;PORT=50000;PROTOCOL=TCPIP;UID=db2inst1;PWD=db2admin;"

try:
    conn = ibm_db.connect(conn_str, "", "")
    print("Conectado exitosamente vía HAProxy al clúster AQUASMRT")
    
    # Crear tabla temporal para la demo si no existe
    ibm_db.exec_immediate(conn, "CREATE TABLE IF NOT EXISTS demo_trafico (id INT GENERATED ALWAYS AS IDENTITY, mensaje VARCHAR(100), nodo VARCHAR(50))")
    
    while True:
        timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        
        # 1. Averiguar qué nodo nos está atendiendo
        stmt_nodo = ibm_db.exec_immediate(conn, "SELECT HOST_NAME FROM TABLE(SYSPROC.ENV_GET_SYS_INFO())")
        nodo_actual = ibm_db.fetch_tuple(stmt_nodo)[0]
        
        # 2. Insertar 1 registro por segundo
        insert_sql = f"INSERT INTO demo_trafico (mensaje, nodo) VALUES ('Telemetría {timestamp}', '{nodo_actual}')"
        ibm_db.exec_immediate(conn, insert_sql)
        
        print(f"[{timestamp}] INSERT EXITOSO | Atendido por: {nodo_actual}")
        time.sleep(1)

except Exception as e:
    print(f"Error de conexión durante el Failover: {e}")
    print("Reintentando reconexión a través del balanceador...")
