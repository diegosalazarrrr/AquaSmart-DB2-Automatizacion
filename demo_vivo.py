import ibm_db
import time
from datetime import datetime

# APUNTAMOS AL BALANCEADOR (Localhost o la IP del balanceador, puerto 56000)
conn_str = "DATABASE=AQUASMRT;HOSTNAME=127.0.0.1;PORT=56000;PROTOCOL=TCPIP;UID=db2inst1;PWD=db2admin;"

print("Iniciando simulación de sensores AquaSmart (ESP32) -> HAProxy...")
fallo_inicio = None

# 1. Intentamos crear la tabla al arrancar (ignorando el error si ya existe)
try:
    conn = ibm_db.connect(conn_str, "", "")
    try:
        ibm_db.exec_immediate(conn, "CREATE TABLE demo_trafico (id INT GENERATED ALWAYS AS IDENTITY, mensaje VARCHAR(100), nodo VARCHAR(50))")
    except:
        pass # Si la tabla ya existe, DB2 arroja error, pero lo ignoramos para seguir
    ibm_db.close(conn)
except Exception as e:
    print("Aviso: No se pudo conectar al inicio. ¿Está encendido el clúster?")

# 2. Bucle principal indestructible
while True:
    try:
        # LA CONEXIÓN DEBE ESTAR ADENTRO DEL BUCLE para que intente reconectarse si se cae
        conn = ibm_db.connect(conn_str, "", "")
        
        # Si veníamos de un error, calculamos el RTO exacto
        if fallo_inicio:
            rto = (datetime.now() - fallo_inicio).total_seconds()
            print(f"\n✅ [RECUPERADO] HAProxy redirigió el tráfico exitosamente.")
            print(f"⏱️  RTO (Tiempo de Recuperación) medido: {rto:.2f} segundos.\n")
            fallo_inicio = None
        
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        
        # Averiguar qué nodo físico nos está atendiendo realmente
        stmt_nodo = ibm_db.exec_immediate(conn, "SELECT HOST_NAME FROM TABLE(SYSPROC.ENV_GET_SYS_INFO())")
        nodo_actual = ibm_db.fetch_tuple(stmt_nodo)[0]
        
        # Insertar 1 registro de telemetría simulando el tinaco
        insert_sql = f"INSERT INTO demo_trafico (mensaje, nodo) VALUES ('Telemetría {timestamp}', '{nodo_actual}')"
        ibm_db.exec_immediate(conn, insert_sql)
        
        print(f"[{timestamp}] INSERT EXITOSO | Atendido por: {nodo_actual}")
        
        ibm_db.close(conn)
        time.sleep(1) # Pulso cada 1 segundo
        
    except Exception as e:
        if not fallo_inicio:
            print(f"\n❌ [{datetime.now().strftime('%H:%M:%S')}] ALERTA CRÍTICA: Nodo Primario caído.")
            print("   Esperando a que HAProxy redirija el tráfico al Nodo de Reserva...")
            fallo_inicio = datetime.now()
        time.sleep(1)
