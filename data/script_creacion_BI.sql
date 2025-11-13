-- CREACION de ESQUEMA PARA EL MODELO DE BI
CREATE SCHEMA BI_LOS_SELECTOS; -- creacion del esquema
GO

-- ============================================================================
-- CREACION DE TABLAS DE DIMENSIONES
-- ============================================================================
CREATE TABLE BI_LOS_SELECTOS.BI_dim_tiempo(
	tiempo_id BIGINT PRIMARY KEY IDENTITY,
	anio INT, 
	mes INT
);

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

-- Hecho: Final
CREATE TABLE BI_LOS_SELECTOS.BI_dim_final(
	final_id BIGINT PRIMARY KEY,
	alumno_id BIGINT NOT NULL,
	profesor_id BIGINT NOT NULL,
	curso_id BIGINT NOT NULL,
	tiempo_id BIGINT NOT NULL,
	nota TINYINT,
	presente TINYINT,
	tiempoFinalizacion INT

	FOREIGN KEY(alumno_id) REFERENCES BI_LOS_SELECTOS.BI_dim_alumno(alumno_id),
	FOREIGN KEY(profesor_id) REFERENCES BI_LOS_SELECTOS.BI_dim_profesor(profesor_id),
	FOREIGN KEY(curso_id) REFERENCES BI_LOS_SELECTOS.BI_dim_curso(curso_id),
	FOREIGN KEY(tiempo_id) REFERENCES BI_LOS_SELECTOS.BI_dim_tiempo(tiempo_id)
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
	alumno_id BIGINT, --FK
	fechaEmision DATE,
	fechaVto DATE,
	importeTotal DECIMAL(18,2)

	FOREIGN KEY(alumno_id) REFERENCES BI_LOS_SELECTOS.BI_dim_alumno(alumno_id)
);

CREATE TABLE BI_LOS_SELECTOS.BI_dim_detalle_factura(
	detalle_id BIGINT PRIMARY KEY,
	factura_id BIGINT, --FK
	curso_id BIGINT, --FK
	importe DECIMAL(18,2),
	tiempo_id BIGINT --FK

	FOREIGN KEY(curso_id) REFERENCES BI_LOS_SELECTOS.BI_dim_curso(curso_id),
	FOREIGN KEY(factura_id) REFERENCES BI_LOS_SELECTOS.BI_dim_factura(factura_id),
	FOREIGN KEY(tiempo_id) REFERENCES BI_LOS_SELECTOS.BI_dim_tiempo(tiempo_id)
);

-- ============================================================================
-- CREACION DE TABLAS DE HECHOS
-- ============================================================================

--5 HECHOS

-- Hecho: Inscripción
CREATE TABLE BI_LOS_SELECTOS.BI_hecho_inscripcion(
	inscrip_id BIGINT PRIMARY KEY IDENTITY,
	curso_id BIGINT NOT NULL,
	tiempo_id BIGINT NOT NULL,
	cantInscriptos INT,
	cantRechaz INT,
	cantConfirm INT,

	FOREIGN KEY(curso_id) REFERENCES BI_LOS_SELECTOS.BI_dim_curso(curso_id),
	FOREIGN KEY(tiempo_id) REFERENCES BI_LOS_SELECTOS.BI_dim_tiempo(tiempo_id)
);

-- Hecho: Cursada de alumnos en cursos
CREATE TABLE BI_LOS_SELECTOS.BI_hecho_cursada(
	cursada_id BIGINT PRIMARY KEY IDENTITY,
	curso_id BIGINT NOT NULL,
	tiempo_id BIGINT NOT NULL,
	cantAlumnos INT,
	tiempoTotalCurso INT,
	cantDesap INT,
	cantAprob INT,

	FOREIGN KEY(curso_id) REFERENCES BI_LOS_SELECTOS.BI_dim_curso(curso_id),
	FOREIGN KEY(tiempo_id) REFERENCES BI_LOS_SELECTOS.BI_dim_tiempo(tiempo_id)
);

-- Hecho: Evaluacion Final
CREATE TABLE BI_LOS_SELECTOS.BI_hecho_evaluacionFinal(
	evaluacionFinal_id BIGINT PRIMARY KEY IDENTITY,
	final_id BIGINT, --FK
	tFinalizacionPromedio DECIMAL(8,2),
	cantAprobados INT,
	cantDesaprobados INT,
	cantAusentes INT,
	cantPresentes INT

	FOREIGN KEY(final_id) REFERENCES BI_LOS_SELECTOS.BI_dim_final(final_id)
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
CREATE FUNCTION dbo.fn_CalcularEdad (@fechaNacimiento DATE)
RETURNS INT
AS
BEGIN
    DECLARE @edad INT;
    SET @edad = DATEDIFF(YEAR, @fechaNacimiento, GETDATE());

    -- Ajuste por si no cumplió años este año
    IF (DATEADD(YEAR, @edad, @fechaNacimiento) > GETDATE())
        SET @edad = @edad - 1;

    RETURN @edad;
END;

GO
CREATE PROCEDURE migracion_etl_dimensiones
AS
BEGIN
	BEGIN TRY
		BEGIN TRAN

			--tiempo
			INSERT INTO BI_LOS_SELECTOS.BI_dim_tiempo (anio, mes)
			SELECT DISTINCT
				YEAR(fecha) AS anio,
				MONTH(fecha) AS mes
			FROM (
				SELECT p.fecha
				FROM LOS_SELECTOS.pago p
				UNION
				SELECT c.fecha_inicio
				FROM LOS_SELECTOS.curso c
				UNION
				SELECT c.fecha_fin
				FROM LOS_SELECTOS.curso c
				UNION
				SELECT e.fecha_hora
				FROM LOS_SELECTOS.examenFinal e
			) AS fechas
			ORDER BY anio, mes;

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

			--profesor
			INSERT INTO BI_LOS_SELECTOS.BI_dim_profesor (profesor_id, dni, rango_etario_id)
			SELECT 
				p.profesor_id,
				p.dni,
				(CASE 
					WHEN dbo.fn_CalcularEdad(p.fecha_nacimiento) < 25 THEN 1
					WHEN dbo.fn_CalcularEdad(p.fecha_nacimiento) < 35 THEN 2
					WHEN dbo.fn_CalcularEdad(p.fecha_nacimiento) < 50 THEN 3
					ELSE 4
				END) AS rango_etario_id
			FROM LOS_SELECTOS.profesor p;

			--alumno
			INSERT INTO BI_LOS_SELECTOS.BI_dim_alumno(alumno_id, legajo, rango_etario_id)
			SELECT 
				a.alumno_id,
				a.legajo,
				(CASE 
					WHEN dbo.fn_CalcularEdad(a.fecha_nacimiento) < 25 THEN 1
					WHEN dbo.fn_CalcularEdad(a.fecha_nacimiento) < 35 THEN 2
					WHEN dbo.fn_CalcularEdad(a.fecha_nacimiento) < 50 THEN 3
					ELSE 4
				END) AS rango_etario_id
			FROM LOS_SELECTOS.alumno a;

			--curso
			INSERT INTO BI_LOS_SELECTOS.BI_dim_curso(curso_id, sede_id, categoria_id, turno_id, profesor_id, fechaInicio, fechaFin)
			SELECT 
				c.codigo,
				c.sede_id,
				c.categoria_id,
				c.turno_id,
				c.profesor_id,
				c.fecha_inicio,
				c.fecha_fin
			FROM LOS_SELECTOS.curso c;

			--notas de los finales
			INSERT INTO BI_LOS_SELECTOS.BI_dim_final(final_id, curso_id, tiempo_id, alumno_id, profesor_id, nota, presente, tiempoFinalizacion)
			SELECT 
				ex.final_id,
				ex.curso_id,
				t.tiempo_id,
				i.alumno_id,
				ev.profesor_id,
				ev.nota,
				ev.presente,
				DATEDIFF(DAY, c.fecha_inicio, ex.fecha_hora) AS tiempoFinalizacion
			FROM LOS_SELECTOS.examenFinal ex
			JOIN LOS_SELECTOS.curso c 
				ON c.codigo = ex.curso_id
			JOIN BI_LOS_SELECTOS.BI_dim_tiempo t
				ON (t.anio = YEAR(ex.fecha_hora) AND t.mes = MONTH(ex.fecha_hora))
			JOIN LOS_SELECTOS.inscripcionFinal i
				ON (i.examenFinal_id = ex.final_id)
			JOIN LOS_SELECTOS.evaluacionFinal ev
				ON (ev.nro_inscripcion= i.nro_inscripcion)

			--satisfaccion
			INSERT INTO BI_LOS_SELECTOS.BI_dim_satisfaccion(bloque_satis_id, nombre, notaMin, notaMax)
			VALUES
				(1, 'Insatisfechos', 1, 4),
				(2, 'Neutrales', 5, 6),
				(3, 'Satisfechos', 7, 10);

			--medio pago
			INSERT INTO BI_LOS_SELECTOS.BI_dim_medio_pago(medio_id, descripcion)
			SELECT m.medio_id, m.descripcion FROM LOS_SELECTOS.medioDePago m

			--factura
			INSERT INTO BI_LOS_SELECTOS.BI_dim_factura(factura_id, alumno_id, fechaEmision, fechaVto, importeTotal)
			SELECT 
				f.nroFactura, 
				f.alumno_id,
				f.fechaEmision,
				f.fechaVencimiento,
				f.importeTotal
			FROM LOS_SELECTOS.factura f
			JOIN LOS_SELECTOS.detalleFactura d ON (d.nroFactura = f.nroFactura)

			--detalle
			INSERT INTO BI_LOS_SELECTOS.BI_dim_detalle_factura(detalle_id, curso_id, factura_id, importe, tiempo_id)
			SELECT 
				d.id, 
				d.curso_id,
				d.nroFactura,
				d.importe,
				t.tiempo_id
			FROM LOS_SELECTOS.detalleFactura d
			JOIN BI_LOS_SELECTOS.BI_dim_tiempo t
				ON (t.anio = d.periodo_anio AND t.mes = d.periodo_mes)

		COMMIT;
	END TRY

	BEGIN CATCH
		ROLLBACK;
		THROW;
	END CATCH
END;

GO
CREATE PROCEDURE migracion_etl_hechos
AS
BEGIN
	BEGIN TRY
		BEGIN TRAN
			-- HECHO: INSCRIPCIÓN
			INSERT INTO BI_LOS_SELECTOS.BI_hecho_inscripcion(curso_id, tiempo_id, cantInscriptos, cantRechaz, cantConfirm)
			SELECT 
				i.curso_id,
				t.tiempo_id,
				COUNT(DISTINCT i.nro_inscripcion) AS cantInscriptos,
				COUNT(CASE WHEN e.descripcion = 'Rechazada' THEN 1 END) AS cantRechaz,
				COUNT(CASE WHEN e.descripcion = 'Confirmada' THEN 1 END) AS cantConfirm
			FROM LOS_SELECTOS.inscripcion i
			JOIN BI_LOS_SELECTOS.BI_dim_tiempo t
				ON (t.anio = YEAR(i.fecha) AND t.mes = MONTH(i.fecha))
			JOIN LOS_SELECTOS.estadoXinscripcion ei
				ON (ei.inscripcion_id = i.nro_inscripcion)
			JOIN LOS_SELECTOS.estado e
				ON (e.estado_id = ei.estado_id)
			GROUP BY i.curso_id, t.tiempo_id
			ORDER BY curso_id ASC

			-- ==============================================================
			-- HECHO: CURSADA
			-- ==============================================================
			INSERT INTO BI_LOS_SELECTOS.BI_hecho_cursada(curso_id, tiempo_id, cantAlumnos, tiempoTotalCurso, cantDesap, cantAprob)
			SELECT 
				c.codigo,
				t.tiempo_id,
				i.cantConfirm AS cantAlumnos, --los confirmados entran al curso
				DATEDIFF(DAY, c.fecha_inicio, c.fecha_fin) AS tiempoTotalCurso,
				--COUNT() AS cantDesap,
				--COUNT() AS cantAprob revisar notas de todos y calcular!!!!
			FROM LOS_SELECTOS.curso c
			JOIN BI_LOS_SELECTOS.BI_hecho_inscripcion i 
				ON (i.curso_id = c.codigo)
			JOIN BI_LOS_SELECTOS.BI_dim_tiempo t
				ON t.anio = YEAR(c.fecha_inicio)
				AND t.mes = MONTH(c.fecha_inicio)
			GROUP BY c.codigo, t.tiempo_id;

			-- ==============================================================
			-- HECHO: FINAL
			-- ==============================================================
			INSERT INTO BI_LOS_SELECTOS.BI_hecho_evaluacionFinal(final_id, cantAprobados, cantDesaprobados, cantAusentes, cantPresentes, tFinalizacionPromedio)
			SELECT 
				f.final_id,
				
			FROM BI_LOS_SELECTOS.BI_dim_final f;

			-- HECHO: PAGO
			INSERT INTO BI_LOS_SELECTOS.BI_hecho_pago (pago_id, alumno_id, tiempo_id, factura_id, medio_id, montoTotal, pagoVencido)
			SELECT 
				p.pago_id,
				f.alumno_id,
				t.tiempo_id,
				f.nroFactura,
				p.medio_id,
				p.importe,
				CASE WHEN p.fecha > f.fechaVencimiento THEN 1 ELSE 0 END AS pagoVencido
			FROM LOS_SELECTOS.pago p
			JOIN LOS_SELECTOS.factura f ON (p.nroFactura = f.nroFactura)
			JOIN BI_LOS_SELECTOS.BI_dim_tiempo t
				ON t.anio = YEAR(p.fecha)
				AND t.mes = MONTH(p.fecha);

			-- HECHO: ENCUESTA DE SATISFACCIÓN
			INSERT INTO BI_LOS_SELECTOS.BI_hecho_encuesta (encuesta_id, curso_id, bloque_satis_id)
			SELECT 
				e.encuesta_id,
				e.curso_id,
				s.bloque_satis_id
			FROM LOS_SELECTOS.encuesta e
			JOIN BI_LOS_SELECTOS.BI_dim_satisfaccion s
				ON e.nota BETWEEN s.notaMin AND s.notaMax;

		COMMIT;
	END TRY

	BEGIN CATCH
		ROLLBACK;
		THROW;
	END CATCH
END;

-- ============================================================================
-- EJECUCION DEL PROCESO DE MIGRACION COMPLETA
-- ============================================================================

EXECUTE migracion_etl_dimensiones;
EXECUTE migracion_etl_hechos;

-- ============================================================================
-- CREACION DE VISTAS PARA LOS INDICADORES DE NEGOCIO
-- ============================================================================

