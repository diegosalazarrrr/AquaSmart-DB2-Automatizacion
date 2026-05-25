-- =====================================================================
-- SCRIPT DE CONSULTAS SQL Y COMANDOS ADMINISTRATIVOS
-- PROYECTO: AquaSmart - Clúster IBM DB2 Alta Disponibilidad
-- =====================================================================

-- ---------------------------------------------------------------------
-- OBTENCIÓN DE MÉTRICAS LOGÍSTICAS (Uso del Exportador Python)
-- ---------------------------------------------------------------------
-- Conteo de conexiones concurrentes activas:
SELECT COUNT(*) FROM TABLE(MON_GET_CONNECTION(NULL, -1));

-- Monitoreo de carga de transacciones confirmadas (Commits totales):
SELECT SUM(TOTAL_APP_COMMITS) FROM TABLE(MON_GET_WORKLOAD('', -1));

-- Monitoreo del estado del clúster HADR desde SQL:
SELECT HADR_ROLE, HADR_STATE, HADR_CONNECT_STATUS FROM TABLE(MON_GET_HADR(NULL));


-- ---------------------------------------------------------------------
-- CONFIGURACIÓN DE AUDITORÍA DE SEGURIDAD (Fase 6)
-- ---------------------------------------------------------------------
-- Creación de la política de auditoría estricta:
CREATE AUDIT POLICY MiPolitica CATEGORIES ALL STATUS BOTH ERROR TYPE NORMAL;

-- Creación de la tabla sensible simulada:
CREATE TABLE cuentas_auditoria (
    id INT, 
    usuario VARCHAR(50), 
    saldo DECIMAL(10,2)
);

-- Asociación de la política de seguridad a la tabla:
AUDIT TABLE cuentas_auditoria USING POLICY MiPolitica;

-- Sentencias DML ejecutadas para auditoría de eventos:
INSERT INTO cuentas_auditoria VALUES (1, 'Admin', 50000.00);
SELECT * FROM cuentas_auditoria;
UPDATE cuentas_auditoria SET saldo = 0 WHERE id = 1;
DELETE FROM cuentas_auditoria WHERE id = 1;


-- ---------------------------------------------------------------------
-- SIMULACIÓN DE RECUPERACIÓN POINT-IN-TIME - PITR (Fase 7)
-- ---------------------------------------------------------------------
-- Creación de la tabla crítica de datos:
CREATE TABLE tesoro_pitr (
    id INT, 
    valor VARCHAR(50)
);

-- Inserción del dato de validación del proyecto:
INSERT INTO tesoro_pitr VALUES (1, 'Proyecto AquaSmart 100');

-- Captura del reloj transaccional del sistema (Timestamp de resguardo):
SELECT CURRENT TIMESTAMP FROM SYSIBM.SYSDUMMY1;
-- Retorno registrado: 2026-05-25-02.40.52.025887

-- Inyección del error humano crítico (Destrucción de la tabla):
DROP TABLE tesoro_pitr;

-- Confirmación de pérdida del objeto (Lanza error SQL):
SELECT * FROM tesoro_pitr;

-- [Comandos ejecutados en el proceso de Rollforward de logs]:
-- db2 restore db AQUASMRT from /home/db2inst1/respaldos taken at 20260525024023 without prompting
-- db2 "rollforward db AQUASMRT to 2026-05-25-02.40.52.025887 and stop"

-- Validación post-recuperación (Muestra el dato rescatado intacto):
SELECT * FROM tesoro_pitr;
