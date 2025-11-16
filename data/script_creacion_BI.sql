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

CREATE TABLE BI_LOS_SELECTOS.BI_dim_ubicacion(
	ubicacion_id BIGINT PRIMARY KEY,
	localidad VARCHAR(80),
	direccion VARCHAR(80),
	provincia VARCHAR(80)
);

CREATE TABLE BI_LOS_SELECTOS.BI_dim_sede(
	sede_id BIGINT PRIMARY KEY,
	nombre VARCHAR(255),
	ubicacion_id BIGINT --FK

		FOREIGN KEY(ubicacion_id) REFERENCES BI_LOS_SELECTOS.BI_dim_ubicacion(ubicacion_id)
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

CREATE TABLE BI_LOS_SELECTOS.BI_dim_final(
	final_id BIGINT PRIMARY KEY,
	curso_id BIGINT NOT NULL, --FK
	tiempo_id BIGINT NOT NULL, --FK

	FOREIGN KEY(curso_id) REFERENCES BI_LOS_SELECTOS.BI_dim_curso(curso_id),
	FOREIGN KEY(tiempo_id) REFERENCES BI_LOS_SELECTOS.BI_dim_tiempo(tiempo_id)
);

CREATE TABLE BI_LOS_SELECTOS.BI_dim_nota_final(
	nota_final_id BIGINT PRIMARY KEY,
	final_id BIGINT, --FK
	alumno_id BIGINT NOT NULL, --FK
	profesor_id BIGINT NOT NULL, --FK
	nota TINYINT,
	presente BIT,
	tiempoFinalizacion INT

	FOREIGN KEY(final_id) REFERENCES BI_LOS_SELECTOS.BI_dim_final(final_id),
	FOREIGN KEY(alumno_id) REFERENCES BI_LOS_SELECTOS.BI_dim_alumno(alumno_id),
	FOREIGN KEY(profesor_id) REFERENCES BI_LOS_SELECTOS.BI_dim_profesor(profesor_id),
);

CREATE TABLE BI_LOS_SELECTOS.BI_dim_bloq_satisfaccion(
	bloque_id BIGINT PRIMARY KEY,
	nombre VARCHAR(20), 
	notaMin INT,
	notaMax INT
);

CREATE TABLE BI_LOS_SELECTOS.BI_dim_encuesta(
	encuesta_id BIGINT PRIMARY KEY,
	curso_id BIGINT NOT NULL,
	bloque_id BIGINT NOT NULL,
	fecha_realizada DATE

	FOREIGN KEY(curso_id) REFERENCES BI_LOS_SELECTOS.BI_dim_curso(curso_id),
	FOREIGN KEY(bloque_id) REFERENCES BI_LOS_SELECTOS.BI_dim_bloq_satisfaccion(bloque_id)
);

CREATE TABLE BI_LOS_SELECTOS.BI_dim_medio_pago(
	medio_id BIGINT PRIMARY KEY,
	descripcion VARCHAR(80), 
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

CREATE TABLE BI_LOS_SELECTOS.BI_dim_pago(
	pago_id BIGINT PRIMARY KEY,
	factura_id BIGINT, --FK
	tiempo_id BIGINT, --FK
	medio_id BIGINT, --FK
	desviado BIT,
	importe DECIMAL(18,2)

	FOREIGN KEY(medio_id) REFERENCES BI_LOS_SELECTOS.BI_dim_medio_pago(medio_id),
	FOREIGN KEY(factura_id) REFERENCES BI_LOS_SELECTOS.BI_dim_factura(factura_id),
	FOREIGN KEY(tiempo_id) REFERENCES BI_LOS_SELECTOS.BI_dim_tiempo(tiempo_id)
);

CREATE TABLE BI_LOS_SELECTOS.BI_dim_examen_tp(
	examen_id BIGINT PRIMARY KEY,
	alumno_id BIGINT, --FK
	curso_id BIGINT, --FK
	tiempo_id BIGINT, --FK
	nota TINYINT,
	presente BIT

	FOREIGN KEY(alumno_id) REFERENCES BI_LOS_SELECTOS.BI_dim_alumno(alumno_id),
	FOREIGN KEY(curso_id) REFERENCES BI_LOS_SELECTOS.BI_dim_curso(curso_id),
	FOREIGN KEY(tiempo_id) REFERENCES BI_LOS_SELECTOS.BI_dim_tiempo(tiempo_id)

);

-- ============================================================================
-- CREACION DE TABLAS DE HECHOS
-- ============================================================================

--Total: 5 HECHOS

-- Hecho: Inscripci�n
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

-- Hecho: Cursada (alumnos en cursos)
CREATE TABLE BI_LOS_SELECTOS.BI_hecho_cursada(
	cursada_id BIGINT PRIMARY KEY IDENTITY,
	curso_id BIGINT NOT NULL, --FK
	tiempo_id BIGINT NOT NULL, --FK
	cantAlumnos INT,
	tiempoTotalCurso INT, --FechaFin - FechaInicio
	cantDesap INT,
	cantAprob INT,

	FOREIGN KEY(curso_id) REFERENCES BI_LOS_SELECTOS.BI_dim_curso(curso_id),
	FOREIGN KEY(tiempo_id) REFERENCES BI_LOS_SELECTOS.BI_dim_tiempo(tiempo_id)
);

-- Hecho: Evaluacion Final
CREATE TABLE BI_LOS_SELECTOS.BI_hecho_evaluacionFinal(
	evaluacionFinal_id BIGINT PRIMARY KEY IDENTITY,
	final_id BIGINT, --FK
	tFinalizacionPromedio DECIMAL(8,2), --FechaFinal - FechaInicioCurso
	cantInscriptos INT,
	cantAprobados INT,
	cantDesaprobados INT,
	cantAusentes INT,
	cantPresentes INT

	FOREIGN KEY(final_id) REFERENCES BI_LOS_SELECTOS.BI_dim_final(final_id)
);

-- Hecho: Facturacion X Curso
CREATE TABLE BI_LOS_SELECTOS.BI_hecho_facturacionCurso(
	facturacionCurso_id BIGINT PRIMARY KEY IDENTITY,
	curso_id BIGINT NOT NULL, --FK
	tiempo_id BIGINT NOT NULL, --FK
	totalAdeudado DECIMAL(18,2),
	totalEsperado DECIMAL(18,2),
	totalFacturado DECIMAL(18,2),
	cantFacturasPagadas INT,
	cantFacturasImpagas INT,
	cantPagosDesviados INT,
	medioIdMasComun BIGINT --FK

	FOREIGN KEY(tiempo_id) REFERENCES BI_LOS_SELECTOS.BI_dim_tiempo(tiempo_id),
	FOREIGN KEY(curso_id) REFERENCES BI_LOS_SELECTOS.BI_dim_curso(curso_id),
	FOREIGN KEY(medioIdMasComun) REFERENCES BI_LOS_SELECTOS.BI_dim_medio_pago(medio_id)
);

-- Hecho: Encuesta de satisfacci�n
CREATE TABLE BI_LOS_SELECTOS.BI_hecho_satisfaccion(
	satisfaccion_id BIGINT PRIMARY KEY IDENTITY,
	profesor_id BIGINT NOT NULL, --FK
	anio INT,
	cantEncuestas INT,
	cantSatisf INT,
	cantInsatisf INT,
	cantNeutral INT

	FOREIGN KEY(profesor_id) REFERENCES BI_LOS_SELECTOS.BI_dim_profesor(profesor_id)
);

-- ============================================================================
-- CREACION DE PROCEDIMIENTOS DE MIGRACION (ETL)
-- ============================================================================
GO
CREATE FUNCTION BI_LOS_SELECTOS.fn_CalcularEdad (@fechaNacimiento DATE)
RETURNS INT
AS
BEGIN
    DECLARE @edad INT;
    SET @edad = DATEDIFF(YEAR, @fechaNacimiento, GETDATE());

    -- Ajuste por si no cumpli� a�os este a�o
    IF (DATEADD(YEAR, @edad, @fechaNacimiento) > GETDATE())
        SET @edad = @edad - 1;

    RETURN @edad;
END;

GO
CREATE PROCEDURE BI_LOS_SELECTOS.migracion_etl_dimensiones
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
					WHEN BI_LOS_SELECTOS.fn_CalcularEdad(p.fecha_nacimiento) < 25 THEN 1
					WHEN BI_LOS_SELECTOS.fn_CalcularEdad(p.fecha_nacimiento) < 35 THEN 2
					WHEN BI_LOS_SELECTOS.fn_CalcularEdad(p.fecha_nacimiento) < 50 THEN 3
					ELSE 4
				END) AS rango_etario_id
			FROM LOS_SELECTOS.profesor p;

			--alumno
			INSERT INTO BI_LOS_SELECTOS.BI_dim_alumno(alumno_id, legajo, rango_etario_id)
			SELECT 
				a.alumno_id,
				a.legajo,
				(CASE 
					WHEN BI_LOS_SELECTOS.fn_CalcularEdad(a.fecha_nacimiento) < 25 THEN 1
					WHEN BI_LOS_SELECTOS.fn_CalcularEdad(a.fecha_nacimiento) < 35 THEN 2
					WHEN BI_LOS_SELECTOS.fn_CalcularEdad(a.fecha_nacimiento) < 50 THEN 3
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
			INSERT INTO BI_LOS_SELECTOS.BI_dim_final(final_id, curso_id, tiempo_id)
			SELECT DISTINCT
				exf.final_id,
				exf.curso_id,
				t.tiempo_id
			FROM LOS_SELECTOS.examenFinal exf
			JOIN BI_LOS_SELECTOS.BI_dim_tiempo t
				ON (t.anio = YEAR(exf.fecha_hora) AND t.mes = MONTH(exf.fecha_hora));

			--notas de los finales
			INSERT INTO BI_LOS_SELECTOS.BI_dim_nota_final(nota_final_id, final_id, alumno_id, profesor_id, nota, presente, tiempoFinalizacion)
			SELECT 
				ev.nro_inscripcion,
				i.examenFinal_id,
				i.alumno_id,
				ev.profesor_id,
				ev.nota,
				ev.presente,
				DATEDIFF(DAY, c.fecha_inicio, exf.fecha_hora) AS tiempoFinalizacion
			FROM LOS_SELECTOS.evaluacionFinal ev
			JOIN LOS_SELECTOS.inscripcionFinal i
				ON (ev.nro_inscripcion = i.nro_inscripcion)
			JOIN LOS_SELECTOS.examenFinal exf
				ON (i.examenFinal_id = exf.final_id) --conocer fecha final
			JOIN LOS_SELECTOS.curso c 
				ON (c.codigo = exf.curso_id) --conocer fecha inicio
			JOIN BI_LOS_SELECTOS.BI_dim_tiempo t
				ON (t.anio = YEAR(exf.fecha_hora) AND t.mes = MONTH(exf.fecha_hora));

			--satisfaccion
			INSERT INTO BI_LOS_SELECTOS.BI_dim_bloq_satisfaccion(bloque_id, nombre, notaMin, notaMax)
			VALUES
				(1, 'Insatisfecho', 1, 4),
				(2, 'Neutral', 5, 6),
				(3, 'Satisfecho', 7, 10);
			
			--encuestas
			INSERT INTO BI_LOS_SELECTOS.BI_dim_encuesta(encuesta_id, curso_id, bloque_id,fecha_realizada)
			SELECT
				e.encuesta_id,
				e.curso_id,
				s.bloque_id,
				GETDATE()
			FROM LOS_SELECTOS.encuesta e
			JOIN LOS_SELECTOS.detalleEncuesta d
				ON (d.encuesta_id = e.encuesta_id)
			JOIN (
				-- Obtener el promedio por encuesta
				SELECT 
					d.encuesta_id,
					AVG(p.nota) AS promedio
				FROM LOS_SELECTOS.detalleEncuesta d
				JOIN LOS_SELECTOS.pregunta p ON (p.pregunta_id = d.pregunta_id)
				GROUP BY d.encuesta_id
			) prom ON (prom.encuesta_id = e.encuesta_id)
			JOIN BI_LOS_SELECTOS.BI_dim_bloq_satisfaccion s 
				ON (prom.promedio BETWEEN s.notaMin AND s.notaMax)
			GROUP BY
				e.encuesta_id,
				e.curso_id,
				s.bloque_id;

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
			JOIN LOS_SELECTOS.detalleFactura d ON (d.nroFactura = f.nroFactura);

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
				ON (t.anio = d.periodo_anio AND t.mes = d.periodo_mes);
			
			--pago
			INSERT INTO BI_LOS_SELECTOS.BI_dim_pago(pago_id, medio_id, tiempo_id, factura_id, importe, desviado)
			SELECT 
				p.pago_id, 
				p.medio_id,
				t.tiempo_id,
				p.nroFactura,
				p.importe,
				CASE 
					WHEN p.fecha > f.fechaVto THEN 1  -- pago desviado
					ELSE 0                            -- pago normal
				END AS desviado
			FROM LOS_SELECTOS.pago p
			JOIN BI_LOS_SELECTOS.BI_dim_tiempo t
				ON (t.anio = YEAR(p.fecha) AND t.mes = MONTH(p.fecha))
			JOIN BI_LOS_SELECTOS.BI_dim_factura f
				ON (f.factura_id = p.nroFactura)

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
			-- HECHO: INSCRIPCIONES x CURSO-FECHA
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
			GROUP BY i.curso_id, t.tiempo_id;

			-- HECHO: CURSADA --TODO

			INSERT INTO BI_LOS_SELECTOS.BI_hecho_cursada(curso_id, tiempo_id, cantAlumnos, tiempoTotalCurso, cantDesap, cantAprob)
			SELECT 
				c.codigo,
				t.tiempo_id,
				i.cantConfirm AS cantAlumnos, --los confirmados entran al curso
				DATEDIFF(DAY, c.fecha_inicio, c.fecha_fin) AS tiempoTotalCurso,
				(SELECT COUNT(DISTINCT a.alumno_id) FROM BI_LOS_SELECTOS.BI_dim_alumno a
				INNER JOIN BI_LOS_SELECTOS.BI_dim_examen_tp e ON e.alumno_id = a.alumno_id
				WHERE e.nota < 4			
				) AS cantDesap,
				(SELECT COUNT(*)
				FROM BI_LOS_SELECTOS.BI_dim_alumno a
				INNER JOIN BI_LOS_SELECTOS.BI_dim_examen_tp e 
				ON e.alumno_id = a.alumno_id
				GROUP BY a.alumno_id
				HAVING MIN(e.nota) >= 4) as cantAprob
			FROM LOS_SELECTOS.curso c
			JOIN BI_LOS_SELECTOS.BI_hecho_inscripcion i 
				ON (i.curso_id = c.codigo)
			JOIN BI_LOS_SELECTOS.BI_dim_tiempo t
				ON t.anio = YEAR(c.fecha_inicio)
				AND t.mes = MONTH(c.fecha_inicio)
			GROUP BY c.codigo, t.tiempo_id;

			-- HECHO: NOTAS x Evaluacion FINAL
			INSERT INTO BI_LOS_SELECTOS.BI_hecho_evaluacionFinal(final_id, cantInscriptos, cantAprobados, cantDesaprobados, cantAusentes, cantPresentes, tFinalizacionPromedio)
			SELECT 
				f.final_id,
				COUNT(*) AS cantInscriptos,
				SUM(CASE WHEN f.nota >= 4 AND f.presente = 1 THEN 1 ELSE 0 END) AS cantAprobados,
				SUM(CASE WHEN f.nota < 4 AND f.presente = 1 THEN 1 ELSE 0 END) AS cantDesaprobados,
				SUM(CASE WHEN f.presente = 0 THEN 1 ELSE 0 END) AS cantAusentes,
				SUM(CASE WHEN f.presente = 1 THEN 1 ELSE 0 END) AS cantPresentes,
				AVG(CASE WHEN f.nota >= 4 AND f.presente = 1 THEN f.tiempoFinalizacion END) AS tFinalizacionPromedio --aprobados que firmaron la materia
			FROM BI_LOS_SELECTOS.BI_dim_nota_final f
			GROUP BY f.final_id;

			-- HECHO: FACTURACION x Curso-Fecha
			INSERT INTO BI_LOS_SELECTOS.BI_hecho_facturacionCurso(curso_id, tiempo_id, totalEsperado, totalFacturado, totalAdeudado, cantPagosDesviados, cantFacturasPagadas, cantFacturasImpagas)
			SELECT
				df.curso_id,
				df.tiempo_id,
				SUM(df.importe) AS totalEsperado,
				SUM(COALESCE(p.importe, 0)) AS totalFacturado,
				SUM(df.importe) - SUM(COALESCE(p.importe, 0)) AS totalAdeudado,
				SUM(CASE WHEN p.desviado = 1 THEN 1 ELSE 0 END) AS cantPagosDesviados,
				COUNT(DISTINCT CASE WHEN p.factura_id IS NOT NULL THEN f.factura_id END) AS cantFacturasPagadas,
				COUNT(DISTINCT CASE WHEN p.factura_id IS NULL THEN f.factura_id END) AS cantFacturasImpagas
			FROM BI_LOS_SELECTOS.BI_dim_detalle_factura df
			JOIN BI_LOS_SELECTOS.BI_dim_factura f
				ON (df.factura_id = f.factura_id)
			LEFT JOIN BI_LOS_SELECTOS.BI_dim_pago p --LEFT: pueden no existir pagos
				ON (f.factura_id = p.factura_id)
			GROUP BY df.curso_id, df.tiempo_id;

			-- HECHO: SATISFACCI�N x Profesor-Anio
			INSERT INTO BI_LOS_SELECTOS.BI_hecho_satisfaccion(profesor_id, anio, cantEncuestas, cantInsatisf, cantNeutral, cantSatisf)
			SELECT
				c.profesor_id,
				YEAR(c.fechaInicio) AS anio,
				COUNT(*) AS cantEncuestas,
				SUM(CASE WHEN b.nombre = 'Insatisfecho' THEN 1 ELSE 0 END) AS cantInsatisf,
				SUM(CASE WHEN b.nombre = 'Neutral' THEN 1 ELSE 0 END) AS cantNeutral,
				SUM(CASE WHEN b.nombre = 'Satisfecho' THEN 1 ELSE 0 END) AS cantSatisf
			FROM BI_LOS_SELECTOS.BI_dim_encuesta e
			JOIN BI_LOS_SELECTOS.BI_dim_bloq_satisfaccion b
				ON e.bloque_id = b.bloque_id
			JOIN BI_LOS_SELECTOS.BI_dim_curso c
				ON e.curso_id = c.curso_id
			GROUP BY c.profesor_id, YEAR(c.fechaInicio);

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

EXECUTE BI_LOS_SELECTOS.migracion_etl_dimensiones;
EXECUTE BI_LOS_SELECTOS.migracion_etl_hechos;

-- ============================================================================
-- CREACION DE VISTAS PARA LOS INDICADORES DE NEGOCIO
-- ============================================================================

--1.
--a) TOP 3 CATEGORIAS MAS SOLICITADAS
SELECT TOP 3
    c.categoria,
    SUM(h.cantInscriptos) AS totalInscriptos
FROM BI_LOS_SELECTOS.BI_hecho_inscripcion h
JOIN BI_LOS_SELECTOS.BI_dim_curso cu ON (cu.curso_id = h.curso_id)
JOIN BI_LOS_SELECTOS.BI_dim_categoria c ON (c.categoria_id = cu.categoria_id)
GROUP BY c.categoria
ORDER BY totalInscriptos DESC;

--1. 
--b) TOP 3 TURNOS MAS SOLICITADOS
SELECT TOP 3
    t.turno,
    SUM(h.cantInscriptos) AS totalInscriptos
FROM BI_LOS_SELECTOS.BI_hecho_inscripcion h
JOIN BI_LOS_SELECTOS.BI_dim_curso cu ON cu.curso_id = h.curso_id
JOIN BI_LOS_SELECTOS.BI_dim_turno t ON t.turno_id = cu.turno_id
GROUP BY t.turno
ORDER BY totalInscriptos DESC;

-- 2. Porcentaje de inscripciones rechazadas por MES por SEDE
SELECT
    t.mes,
    cu.sede_id,
    SUM(h.cantRechaz) * 1.0 / SUM(h.cantInscriptos) AS porcRechazadas
FROM BI_LOS_SELECTOS.BI_hecho_inscripcion h
JOIN BI_LOS_SELECTOS.BI_dim_tiempo t 
    ON t.tiempo_id = h.tiempo_id
JOIN BI_LOS_SELECTOS.BI_dim_curso cu 
    ON cu.curso_id = h.curso_id
GROUP BY t.mes, cu.sede_id;

--3. TODO

--4. PROMEDIO DE FINALIZACION DE CURSO x anio y categoria
SELECT
	t.anio,
	c.categoria_id,
    AVG(ef.tFinalizacionPromedio) finalizacionPromedio
FROM BI_LOS_SELECTOS.BI_hecho_evaluacionFinal ef
JOIN BI_LOS_SELECTOS.BI_dim_final f 
    ON f.final_id = ef.final_id
JOIN BI_LOS_SELECTOS.BI_dim_tiempo t 
    ON t.tiempo_id = f.tiempo_id
JOIN BI_LOS_SELECTOS.BI_dim_curso c
    ON f.curso_id = c.curso_id
GROUP BY t.anio, c.categoria_id
ORDER BY t.anio

--5 nota promedio x rango etario y categoria
SELECT
	c.categoria_id,
	a.rango_etario_id,
    AVG(nf.nota)
FROM BI_LOS_SELECTOS.BI_dim_final f 
JOIN BI_LOS_SELECTOS.BI_dim_nota_final nf 
    ON f.final_id = nf.final_id
JOIN BI_LOS_SELECTOS.BI_dim_alumno a 
    ON a.alumno_id = nf.alumno_id
JOIN BI_LOS_SELECTOS.BI_dim_curso c
    ON f.curso_id = c.curso_id
GROUP BY c.categoria_id, a.rango_etario_id
ORDER BY c.categoria_id, a.rango_etario_id

--6 tasa ausentismo finales x sede
SELECT
    c.sede_id,
    CAST(SUM(ef.cantAusentes) AS FLOAT) / NULLIF(SUM(ef.cantInscriptos), 0) AS tasaAusentismo
FROM BI_LOS_SELECTOS.BI_hecho_evaluacionFinal ef 
JOIN BI_LOS_SELECTOS.BI_dim_final f
    ON ef.final_id = f.final_id
JOIN BI_LOS_SELECTOS.BI_dim_curso c
    ON f.curso_id = c.curso_id
GROUP BY c.sede_id
ORDER BY c.sede_id;

--7 % desvio de pagos x anio
SELECT
    t.anio,
    CAST(SUM(f.cantPagosDesviados) AS FLOAT)
        / NULLIF(SUM(f.cantFacturasPagadas), 0) AS porcentajeDesvio
FROM BI_LOS_SELECTOS.BI_hecho_facturacionCurso f
JOIN BI_LOS_SELECTOS.BI_dim_tiempo t
    ON t.tiempo_id = f.tiempo_id
GROUP BY t.anio
ORDER BY t.anio;

--8
SELECT
    t.mes,
    t.anio,
    SUM(f.totalAdeudado) / NULLIF(SUM(f.totalEsperado), 0) AS tasaMorosidad
FROM BI_LOS_SELECTOS.BI_hecho_facturacionCurso f
JOIN BI_LOS_SELECTOS.BI_dim_tiempo t
    ON t.tiempo_id = f.tiempo_id
GROUP BY
    t.mes, t.anio
ORDER BY
    t.anio, t.mes;

--9
SELECT
    x.anio,
    x.sede_id,
    x.categoria,
    x.ingresos
FROM (
    SELECT
        t.anio,
        cu.sede_id,
        cat.categoria,
        SUM(df.importe) AS ingresos,
        ROW_NUMBER() OVER(
            PARTITION BY t.anio, cu.sede_id
            ORDER BY SUM(df.importe) DESC
        ) AS rn
    FROM BI_LOS_SELECTOS.BI_dim_detalle_factura df
    JOIN BI_LOS_SELECTOS.BI_dim_factura f
        ON f.factura_id = df.factura_id
    JOIN BI_LOS_SELECTOS.BI_dim_curso cu
        ON cu.curso_id = df.curso_id
    JOIN BI_LOS_SELECTOS.BI_dim_categoria cat
        ON cat.categoria_id = cu.categoria_id
    JOIN BI_LOS_SELECTOS.BI_dim_tiempo t
        ON t.tiempo_id = df.tiempo_id
    GROUP BY
        t.anio, cu.sede_id, cat.categoria
) x
WHERE x.rn <= 3
ORDER BY x.anio, x.sede_id, x.rn;

--10
SELECT
    h.profesor_id,
    c.sede_id,
    h.anio,
    (
        (CAST(SUM(h.cantSatisf) AS FLOAT) / NULLIF(SUM(h.cantEncuestas), 0)) * 100
        - (CAST(SUM(h.cantInsatisf) AS FLOAT) / NULLIF(SUM(h.cantEncuestas), 0)) * 100
        + 100
    ) / 2 AS indiceSatisfaccion
FROM BI_LOS_SELECTOS.BI_hecho_satisfaccion h
JOIN BI_LOS_SELECTOS.BI_dim_profesor p
    ON p.profesor_id = h.profesor_id
JOIN BI_LOS_SELECTOS.BI_dim_curso c
    ON c.profesor_id = p.profesor_id
GROUP BY h.profesor_id, c.sede_id, h.anio
ORDER BY h.anio, c.sede_id, h.profesor_id;



