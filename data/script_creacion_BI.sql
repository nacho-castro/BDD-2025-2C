-- CREACION de ESQUEMA PARA EL MODELO DE BI
CREATE SCHEMA BI_LOS_SELECTOS; -- creacion del esquema
GO

-- ============================================================================
-- CREACION DE TABLAS DE DIMENSIONES
-- ============================================================================
CREATE TABLE BI_LOS_SELECTOS.BI_dim_turno(
	turno_id BIGINT PRIMARY KEY,
	turno VARCHAR(60)
);

CREATE TABLE BI_LOS_SELECTOS.BI_dim_categoria(
	categoria_id BIGINT PRIMARY KEY,
	categoria VARCHAR(60)
);

CREATE TABLE BI_LOS_SELECTOS.BI_dim_sede(
	sede_id BIGINT PRIMARY KEY,
	nombre VARCHAR(255),
);

CREATE TABLE BI_LOS_SELECTOS.BI_dim_rango_etario(
	rango_id BIGINT PRIMARY KEY,
	rangoMin INT,
	rangoMax INT
);

CREATE TABLE BI_LOS_SELECTOS.BI_dim_profesor(
	profesor_id BIGINT PRIMARY KEY,
	dni VARCHAR(255),
	rango_etario_id BIGINT --FK

	FOREIGN KEY(rango_etario_id) REFERENCES BI_LOS_SELECTOS.BI_dim_rango_etario(rango_id)
);

CREATE TABLE BI_LOS_SELECTOS.BI_dim_alumno(
	alumno_id BIGINT PRIMARY KEY,
	legajo BIGINT, 
	rango_etario_id BIGINT --FK

	FOREIGN KEY(rango_etario_id) REFERENCES BI_LOS_SELECTOS.BI_dim_rango_etario(rango_id)
);

CREATE TABLE BI_LOS_SELECTOS.BI_dim_curso(
	curso_id BIGINT PRIMARY KEY,
	sede_id BIGINT, --FK
	categoria_id BIGINT, --FK
	turno_id BIGINT, --FK
	profesor_id BIGINT, --FK
	fechaInicio DATE,
	fechaFin DATE

	FOREIGN KEY(sede_id) REFERENCES BI_LOS_SELECTOS.BI_dim_sede(sede_id),
	FOREIGN KEY(categoria_id) REFERENCES BI_LOS_SELECTOS.BI_dim_categoria(categoria_id),
	FOREIGN KEY(turno_id) REFERENCES BI_LOS_SELECTOS.BI_dim_turno(turno_id),
	FOREIGN KEY(profesor_id) REFERENCES BI_LOS_SELECTOS.BI_dim_profesor(profesor_id)
);

CREATE TABLE BI_LOS_SELECTOS.BI_dim_satisfaccion(
	bloque_satis_id BIGINT PRIMARY KEY,
	nombre VARCHAR(20), 
	notaMin INT,
	notaMax INT
);

CREATE TABLE BI_LOS_SELECTOS.BI_dim_medio_pago(
	medio_id BIGINT PRIMARY KEY,
	descripcion VARCHAR(20), 
);

CREATE TABLE BI_LOS_SELECTOS.BI_dim_factura(
	factura_id BIGINT PRIMARY KEY,
	curso_id BIGINT, --fk
	fechaEmision DATE,
	fechaVto DATE

	FOREIGN KEY(curso_id) REFERENCES BI_LOS_SELECTOS.BI_dim_curso(curso_id),
);

CREATE TABLE BI_LOS_SELECTOS.BI_dim_tiempo(
	tiempo_id BIGINT PRIMARY KEY,
	anio INT, 
	mes INT
);

-- ============================================================================
-- CREACION DE TABLAS DE HECHOS
-- ============================================================================

--5 HECHOS

-- Hecho: Inscripción
CREATE TABLE BI_LOS_SELECTOS.BI_hecho_inscripcion(
	inscrip_id BIGINT PRIMARY KEY,
	curso_id BIGINT NOT NULL,
	tiempo_id BIGINT NOT NULL,
	cantInscriptos INT,
	cantRechaz INT,
	cantAprob INT,

	FOREIGN KEY(curso_id) REFERENCES BI_LOS_SELECTOS.BI_dim_curso(curso_id),
	FOREIGN KEY(tiempo_id) REFERENCES BI_LOS_SELECTOS.BI_dim_tiempo(tiempo_id)
);

CREATE TABLE BI_LOS_SELECTOS.BI_hecho_cursada(
	cursada_id BIGINT PRIMARY KEY,
	curso_id BIGINT NOT NULL,
	tiempo_id BIGINT NOT NULL,
	cantAlumnos INT,
	tiempoTotalCurso INT,
	cantDesap INT,
	cantAprob INT,

	FOREIGN KEY(curso_id) REFERENCES BI_LOS_SELECTOS.BI_dim_curso(curso_id),
	FOREIGN KEY(tiempo_id) REFERENCES BI_LOS_SELECTOS.BI_dim_tiempo(tiempo_id)
);

-- Hecho: Final
CREATE TABLE BI_LOS_SELECTOS.BI_hecho_final(
	final_id BIGINT PRIMARY KEY,
	alumno_id BIGINT NOT NULL,
	curso_id BIGINT NOT NULL,
	tiempo_id BIGINT NOT NULL,
	nota TINYINT,
	presente TINYINT,
	tiempoFinalizacion INT,

	FOREIGN KEY(alumno_id) REFERENCES BI_LOS_SELECTOS.BI_dim_alumno(alumno_id),
	FOREIGN KEY(curso_id) REFERENCES BI_LOS_SELECTOS.BI_dim_curso(curso_id),
	FOREIGN KEY(tiempo_id) REFERENCES BI_LOS_SELECTOS.BI_dim_tiempo(tiempo_id)
);

-- Hecho: Pago
CREATE TABLE BI_LOS_SELECTOS.BI_hecho_pago(
	pago_id BIGINT PRIMARY KEY,
	alumno_id BIGINT NOT NULL,
	tiempo_id BIGINT NOT NULL,
	factura_id BIGINT NOT NULL,
	medio_id BIGINT NOT NULL,
	montoTotal DECIMAL(18,2),
	pagoVencido TINYINT,

	FOREIGN KEY(alumno_id) REFERENCES BI_LOS_SELECTOS.BI_dim_alumno(alumno_id),
	FOREIGN KEY(tiempo_id) REFERENCES BI_LOS_SELECTOS.BI_dim_tiempo(tiempo_id),
	FOREIGN KEY(factura_id) REFERENCES BI_LOS_SELECTOS.BI_dim_factura(factura_id),
	FOREIGN KEY(medio_id) REFERENCES BI_LOS_SELECTOS.BI_dim_medio_pago(medio_id)
);

-- Hecho: Encuesta de satisfacción
CREATE TABLE BI_LOS_SELECTOS.BI_hecho_encuesta(
	encuesta_id BIGINT PRIMARY KEY,
	curso_id BIGINT NOT NULL,
	alumno_id BIGINT NOT NULL,
	bloque_satis_id BIGINT NOT NULL,

	FOREIGN KEY(curso_id) REFERENCES BI_LOS_SELECTOS.BI_dim_curso(curso_id),
	FOREIGN KEY(alumno_id) REFERENCES BI_LOS_SELECTOS.BI_dim_alumno(alumno_id),
	FOREIGN KEY(bloque_satis_id) REFERENCES BI_LOS_SELECTOS.BI_dim_satisfaccion(bloque_satis_id)
);

-- ============================================================================
-- CREACION DE PROCEDIMIENTOS DE MIGRACION (ETL)
-- ============================================================================
GO
CREATE PROCEDURE migracion_etl_bi
AS
BEGIN
	BEGIN TRY
		BEGIN TRAN
			--turnos
			INSERT INTO BI_LOS_SELECTOS.BI_dim_turno(turno_id, turno)
			SELECT t.turno_id, t.nombre FROM LOS_SELECTOS.turno t

			--categoria
			INSERT INTO BI_LOS_SELECTOS.BI_dim_categoria(categoria_id, categoria)
			SELECT c.categoria_id, c.nombre FROM LOS_SELECTOS.categoria c

			--sede
			INSERT INTO BI_LOS_SELECTOS.BI_dim_sede(sede_id, nombre)
			SELECT s.sede_id, s.nombre FROM LOS_SELECTOS.sede s

			--rango etario
			INSERT INTO BI_LOS_SELECTOS.BI_dim_rango_etario (rango_id, rangoMin, rangoMax)
			VALUES 
				(1, 0, 25),		 -- <25
				(2, 25, 35),     -- 25-35
				(3, 35, 50),     -- 35-50
				(4, 50, NULL);   -- >50

		COMMIT;
	END TRY

	BEGIN CATCH
		ROLLBACK;
	END CATCH
END;

-- ============================================================================
-- EJECUCION DEL PROCESO DE MIGRACION COMPLETA
-- ============================================================================



-- ============================================================================
-- CREACION DE VISTAS PARA LOS INDICADORES DE NEGOCIO
-- ============================================================================

