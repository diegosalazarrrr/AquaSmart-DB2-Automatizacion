import ibm_db
import time
from datetime import datetime

# CONFIGURACIÓN
nodos = ["10.0.0.132", "10.0.0.246", "10.0.0.248"]
primario_actual = "10.0.0.132" 

print("Iniciando telemetría de AquaSmart (Modo Alta Disponibilidad)...")

while True:
    try:
        conn_str = f"DATABASE=AQUASMRT;HOSTNAME={primario_actual};PORT=50000;PROTOCOL=TCPIP;UID=db2inst1;PWD=db2admin;"
        conn = ibm_db.connect(conn_str, "", "")

        # CHECK BLINDADO: Verificamos el rol oficial (Requisito de la rúbrica)
        stmt_check = ibm_db.exec_immediate(conn, "SELECT HADR_ROLE FROM TABLE(MON_GET_HADR(NULL))")
        hadr_info = ibm_db.fetch_assoc(stmt_check)
        
        if hadr_info['HADR_ROLE'] != 'PRIMARY':
            raise Exception(f"El nodo es {hadr_info['HADR_ROLE']}, se rechazan escrituras.")
        
        # Inserción
        sql_insert = f"INSERT INTO SENSORES_DEMOSTRACION (NODO_ACTIVO, FECHA) VALUES ('{primario_actual}', CURRENT TIMESTAMP)"
        ibm_db.exec_immediate(conn, sql_insert)

        # Lectura
        sql_select = "SELECT ID, NODO_ACTIVO, FECHA FROM SENSORES_DEMOSTRACION ORDER BY FECHA DESC FETCH FIRST 10 ROWS ONLY"
        stmt = ibm_db.exec_immediate(conn, sql_select)
        
        print(f"\n--- Últimos 10 registros (Atendido por {primario_actual}) ---")
        row = ibm_db.fetch_assoc(stmt)
        while row:
            print(row)
            row = ibm_db.fetch_assoc(stmt)
        print("-------------------------------------------------------")

        ibm_db.close(conn)

    except Exception as e:
        # Si el primario falla, mostramos el error real y buscamos al nuevo jefe
        print(f"\n⚠️ [ALERTA] Balanceador: El nodo {primario_actual} no responde. Marcando en estado DOWN.")
        print(f"🛑 Detalle técnico: {e}") 
        print("🔄 Buscando nodo de respaldo PRIMARY disponible...")
        
        nuevo_encontrado = False
        for ip in nodos:
            if ip == primario_actual:
                continue 
            
            try:
                test_str = f"DATABASE=AQUASMRT;HOSTNAME={ip};PORT=50000;PROTOCOL=TCPIP;UID=db2inst1;PWD=db2admin;"
                test_conn = ibm_db.connect(test_str, "", "")
                
                # Verificamos que el candidato de respaldo SÍ sea el PRIMARY
                stmt_test = ibm_db.exec_immediate(test_conn, "SELECT HADR_ROLE FROM TABLE(MON_GET_HADR(NULL))")
                test_info = ibm_db.fetch_assoc(stmt_test)
                ibm_db.close(test_conn)
                
                if test_info['HADR_ROLE'] == 'PRIMARY':
                    print(f"✅ ¡Éxito! Tráfico redirigido al nuevo primario: {ip}")
                    primario_actual = ip
                    nuevo_encontrado = True
                    break
            except:
                continue
        
        if not nuevo_encontrado:
            print(f"[{datetime.now().strftime('%H:%M:%S')}] ❌ ALERTA CRÍTICA: Ningún nodo tiene el rol PRIMARY activo.")
            
    time.sleep(2)
