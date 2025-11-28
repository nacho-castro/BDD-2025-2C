-- CREACION de ESQUEMA PARA EL MODELO DE BI
CREATE SCHEMA BI_LOS_SELECTOS; -- creacion del esquema
GO

-- ============================================================================
-- CREACION DE TABLAS DE DIMENSIONES
-- ============================================================================
CREATE TABLE BI_LOS_SELECTOS.BI_dim_tiempo(
	tiempo_id BIGINT PRIMARY KEY IDENTITY,
	anio INT, 
	mes TINYINT,
	semestre TINYINT
);

CREATE TABLE BI_LOS_SELECTOS.BI_dim_sede(
	sede_id BIGINT PRIMARY KEY,
	nombre VARCHAR(255)
);

CREATE TABLE BI_LOS_SELECTOS.BI_dim_rango_etario_profesor(
	rango_id BIGINT PRIMARY KEY,
	rangoMin INT,
	rangoMax INT
);

CREATE TABLE BI_LOS_SELECTOS.BI_dim_rango_etario_alumno(
	rango_id BIGINT PRIMARY KEY,
	rangoMin INT,
	rangoMax INT
);

CREATE TABLE BI_LOS_SELECTOS.BI_dim_turno(
	turno_id BIGINT PRIMARY KEY,
	turno VARCHAR(60)
);

CREATE TABLE BI_LOS_SELECTOS.BI_dim_categoria(
	categoria_id BIGINT PRIMARY KEY,
	categoria VARCHAR(60)
);

CREATE TABLE BI_LOS_SELECTOS.BI_dim_medio_pago(
	medio_id BIGINT PRIMARY KEY,
	descripcion VARCHAR(80)
);

CREATE TABLE BI_LOS_SELECTOS.BI_dim_bloq_satisfaccion(
	bloque_id BIGINT PRIMARY KEY,
	nombre VARCHAR(20), 
	notaMin INT,
	notaMax INT
);

-- ============================================================================
-- CREACION DE TABLAS DE HECHOS
-- ============================================================================

--Total: 5 HECHOS
-- Hecho: Inscripcion
CREATE TABLE BI_LOS_SELECTOS.BI_hecho_inscripcion(
	inscrip_id BIGINT PRIMARY KEY IDENTITY,
	turno_id BIGINT, --dim FK
	categoria_id BIGINT, --dim FK
	sede_id BIGINT, --dim FK
	tiempo_id BIGINT NOT NULL, --dim FK

	cantInscriptos INT,
	cantRechaz INT,
	cantConfirm INT,

	FOREIGN KEY(tiempo_id) REFERENCES BI_LOS_SELECTOS.BI_dim_tiempo(tiempo_id),
	FOREIGN KEY(turno_id) REFERENCES BI_LOS_SELECTOS.BI_dim_turno(turno_id),
	FOREIGN KEY(sede_id) REFERENCES BI_LOS_SELECTOS.BI_dim_sede(sede_id),
	FOREIGN KEY(categoria_id) REFERENCES BI_LOS_SELECTOS.BI_dim_categoria(categoria_id),
);

CREATE TABLE BI_LOS_SELECTOS.BI_hecho_pago(
	pago_id BIGINT PRIMARY KEY IDENTITY,
	tiempo_id BIGINT, --FK dim
	categoria_id BIGINT, --dim FK
	sede_id BIGINT, --dim FK
	medio_id BIGINT, --FK dim

	cantPagos INT,
	cantDesviados INT,
	totalPagado DECIMAL(18,2),

	FOREIGN KEY(medio_id) REFERENCES BI_LOS_SELECTOS.BI_dim_medio_pago(medio_id),
	FOREIGN KEY(categoria_id) REFERENCES BI_LOS_SELECTOS.BI_dim_categoria(categoria_id),
	FOREIGN KEY(tiempo_id) REFERENCES BI_LOS_SELECTOS.BI_dim_tiempo(tiempo_id),
	FOREIGN KEY(sede_id) REFERENCES BI_LOS_SELECTOS.BI_dim_sede(sede_id)
);

CREATE TABLE BI_LOS_SELECTOS.BI_hecho_encuesta(
	encuesta_id BIGINT PRIMARY KEY IDENTITY,
	tiempo_id BIGINT NOT NULL, --FK dim
	sede_id BIGINT NOT NULL, --FK dim
	rango_id BIGINT NOT NULL, --FK dim
	bloque_id BIGINT NOT NULL, --FK dim
	
	cantEncuestas INT,

	FOREIGN KEY(tiempo_id) REFERENCES BI_LOS_SELECTOS.BI_dim_tiempo(tiempo_id),
	FOREIGN KEY(sede_id) REFERENCES BI_LOS_SELECTOS.BI_dim_sede(sede_id),
	FOREIGN KEY(rango_id) REFERENCES BI_LOS_SELECTOS.BI_dim_rango_etario_profesor(rango_id),
	FOREIGN KEY(bloque_id) REFERENCES BI_LOS_SELECTOS.BI_dim_bloq_satisfaccion(bloque_id)
);

CREATE TABLE BI_LOS_SELECTOS.BI_hecho_final(
	final_id BIGINT PRIMARY KEY IDENTITY,
	tiempo_id BIGINT NOT NULL, --FK dim
	sede_id BIGINT NOT NULL, --FK dim
	categoria_id BIGINT, --dim FK
	rango_id BIGINT NOT NULL, --FK dim

	cantInscriptos INT,
	cantAprobados INT,
	cantDesaprobados INT,
	cantAusentes INT,
	cantPresentes INT,
	promedioNotas DECIMAL(8,2),

	FOREIGN KEY(tiempo_id) REFERENCES BI_LOS_SELECTOS.BI_dim_tiempo(tiempo_id),
	FOREIGN KEY(sede_id) REFERENCES BI_LOS_SELECTOS.BI_dim_sede(sede_id),
	FOREIGN KEY(categoria_id) REFERENCES BI_LOS_SELECTOS.BI_dim_categoria(categoria_id),
	FOREIGN KEY(rango_id) REFERENCES BI_LOS_SELECTOS.BI_dim_rango_etario_alumno(rango_id)
);

CREATE TABLE BI_LOS_SELECTOS.BI_hecho_curso(
	curso_id BIGINT PRIMARY KEY IDENTITY,
	tiempo_id BIGINT NOT NULL, --FK dim
	sede_id BIGINT NOT NULL, --FK dim
	categoria_id BIGINT, --dim FK

	cantAlumnos INT,
	cantAprobados INT,
	cantDesaprobados INT,
	totalAdeudado DECIMAL(18,2),
	totalEsperado DECIMAL(18,2),
	totalFacturado DECIMAL(18,2),

	FOREIGN KEY(tiempo_id) REFERENCES BI_LOS_SELECTOS.BI_dim_tiempo(tiempo_id),
	FOREIGN KEY(sede_id) REFERENCES BI_LOS_SELECTOS.BI_dim_sede(sede_id),
	FOREIGN KEY(categoria_id) REFERENCES BI_LOS_SELECTOS.BI_dim_categoria(categoria_id)
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

    -- Ajuste por si no cumplio anios este anio
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
			INSERT INTO BI_LOS_SELECTOS.BI_dim_tiempo(anio, mes, semestre)
			SELECT DISTINCT
				YEAR(fecha) AS anio,
				MONTH(fecha) AS mes,
				CASE WHEN MONTH(fecha) <= 6 THEN 1 ELSE 2 END
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

			--sede
			INSERT INTO BI_LOS_SELECTOS.BI_dim_sede(sede_id, nombre)
			SELECT s.sede_id, s.nombre FROM LOS_SELECTOS.sede s;

			--rango etario prof
			INSERT INTO BI_LOS_SELECTOS.BI_dim_rango_etario_profesor(rango_id, rangoMin, rangoMax)
			VALUES 
				(1, 25, 35),     -- 25-35
				(2, 35, 50),     -- 35-50
				(3, 50, NULL);   -- >50

			--rango etario alumn
			INSERT INTO BI_LOS_SELECTOS.BI_dim_rango_etario_alumno(rango_id, rangoMin, rangoMax)
			VALUES 
				(1, 0, 25),		 -- <25
				(2, 25, 35),     -- 25-35
				(3, 35, 50),     -- 35-50
				(4, 50, NULL);   -- >50

			--turno
			INSERT INTO BI_LOS_SELECTOS.BI_dim_turno(turno_id, turno)
			SELECT t.turno_id, t.nombre FROM LOS_SELECTOS.turno t;

			--categoria
			INSERT INTO BI_LOS_SELECTOS.BI_dim_categoria(categoria_id, categoria)
			SELECT c.categoria_id, c.nombre FROM LOS_SELECTOS.categoria c;

			--medio pago
			INSERT INTO BI_LOS_SELECTOS.BI_dim_medio_pago(medio_id, descripcion)
			SELECT m.medio_id, m.descripcion FROM LOS_SELECTOS.medioDePago m;

			--satisfaccion
			INSERT INTO BI_LOS_SELECTOS.BI_dim_bloq_satisfaccion(bloque_id, nombre, notaMin, notaMax)
			VALUES
				(1, 'Insatisfecho', 1, 4),
				(2, 'Neutral', 5, 6),
				(3, 'Satisfecho', 7, 10);
		COMMIT;
	END TRY

	BEGIN CATCH
		ROLLBACK;
		THROW;
	END CATCH
END;


GO
CREATE PROCEDURE BI_LOS_SELECTOS.migracion_etl_hechos
AS
BEGIN
	BEGIN TRY
		BEGIN TRAN
			-- HECHO INSCRIPCION
			INSERT INTO BI_LOS_SELECTOS.BI_hecho_inscripcion(turno_id, categoria_id, sede_id, tiempo_id, cantInscriptos, cantRechaz, cantConfirm)
			SELECT 
				tr.turno_id,
				c.categoria_id,
				s.sede_id,
				t.tiempo_id,
				COUNT(DISTINCT i.nro_inscripcion) AS cantInscriptos,
				COALESCE(SUM(CASE WHEN e.descripcion = 'Rechazada'  THEN 1 ELSE 0 END), 0) AS cantRechaz,
				COALESCE(SUM(CASE WHEN e.descripcion = 'Confirmada' THEN 1 ELSE 0 END), 0) AS cantConfirm
			FROM LOS_SELECTOS.inscripcion i
			JOIN LOS_SELECTOS.curso curso ON (i.curso_id = curso.codigo)
			JOIN LOS_SELECTOS.estadoXinscripcion ei ON (ei.inscripcion_id = i.nro_inscripcion)
			JOIN LOS_SELECTOS.estado e ON (e.estado_id = ei.estado_id)
			--join dimensiones
			JOIN BI_LOS_SELECTOS.BI_dim_turno tr ON (tr.turno_id = curso.turno_id)
			JOIN BI_LOS_SELECTOS.BI_dim_categoria c ON (c.categoria_id = curso.categoria_id)
			JOIN BI_LOS_SELECTOS.BI_dim_sede s ON (s.sede_id = curso.sede_id)
			JOIN BI_LOS_SELECTOS.BI_dim_tiempo t ON (t.anio = YEAR(i.fecha) AND t.mes = MONTH(i.fecha))
			GROUP BY tr.turno_id, c.categoria_id, s.sede_id, t.tiempo_id;

			--HECHO:PAGO
			INSERT INTO BI_LOS_SELECTOS.BI_hecho_pago(tiempo_id, sede_id, categoria_id, medio_id, cantPagos, cantDesviados, totalPagado)
			SELECT 
				t.tiempo_id,
				s.sede_id,
				c.categoria_id,
				m.medio_id,
				COUNT(DISTINCT p.pago_id) AS cantPagos,
				COALESCE(SUM(CASE WHEN p.fecha > f.fechaVencimiento THEN 1 ELSE 0 END), 0) AS cantDesviados,
				SUM(p.importe) AS totalPagado
			FROM LOS_SELECTOS.pago p
			JOIN LOS_SELECTOS.factura f ON (f.nroFactura = p.nroFactura)
			JOIN LOS_SELECTOS.detalleFactura d ON (d.nroFactura = f.nroFactura)
			JOIN LOS_SELECTOS.curso curso ON (curso.codigo = d.curso_id)
			--join dimensiones
			JOIN BI_LOS_SELECTOS.BI_dim_tiempo t ON (t.anio = YEAR(p.fecha) AND t.mes = MONTH(p.fecha))
			JOIN BI_LOS_SELECTOS.BI_dim_sede s ON (s.sede_id = curso.sede_id)
			JOIN BI_LOS_SELECTOS.BI_dim_categoria c ON (c.categoria_id = curso.categoria_id)
			JOIN BI_LOS_SELECTOS.BI_dim_medio_pago m ON (m.medio_id = p.medio_id)
			GROUP BY t.tiempo_id,s.sede_id,c.categoria_id,m.medio_id;

			-- HECHO:ENCUESTA
			INSERT INTO BI_LOS_SELECTOS.BI_hecho_encuesta(bloque_id, rango_id, sede_id, tiempo_id, cantEncuestas)
			SELECT
				b.bloque_id,
				r.rango_id,
				s.sede_id,
				t.tiempo_id,
				COUNT(DISTINCT e.encuesta_id) AS cantEncuestas
			FROM LOS_SELECTOS.encuesta e 
			JOIN LOS_SELECTOS.detalleEncuesta de ON (de.encuesta_id = e.encuesta_id)
			JOIN LOS_SELECTOS.pregunta preg ON (preg.pregunta_id = de.pregunta_id)
			JOIN LOS_SELECTOS.curso curso ON (curso.codigo = e.curso_id)
			JOIN LOS_SELECTOS.profesor prof ON (prof.profesor_id = curso.profesor_id)
			--join dimensiones
			JOIN BI_LOS_SELECTOS.BI_dim_bloq_satisfaccion b ON (preg.nota BETWEEN b.notaMin AND b.notaMax)
			JOIN BI_LOS_SELECTOS.BI_dim_rango_etario_profesor r 
				ON (BI_LOS_SELECTOS.fn_CalcularEdad(prof.fecha_nacimiento) BETWEEN r.rangoMin AND COALESCE(r.rangoMax, 200))
			JOIN BI_LOS_SELECTOS.BI_dim_tiempo t ON (t.anio = YEAR(e.fechaRegistro) AND t.mes = MONTH(e.fechaRegistro))
			JOIN BI_LOS_SELECTOS.BI_dim_sede s ON (s.sede_id = curso.sede_id)
			GROUP BY b.bloque_id, r.rango_id, s.sede_id, t.tiempo_id;

			-- HECHO:FINAL
			INSERT INTO BI_LOS_SELECTOS.BI_hecho_final(tiempo_id, sede_id, categoria_id, rango_id, cantInscriptos, cantAprobados, cantDesaprobados, cantAusentes, cantPresentes, promedioNotas)
			SELECT 
				t.tiempo_id,
				s.sede_id,
				c.categoria_id,
				r.rango_id,
				COUNT(DISTINCT insf.nro_inscripcion) AS cantInscriptos,
				SUM(CASE WHEN evf.presente = 1 AND evf.nota >= 4 THEN 1 ELSE 0 END) AS cantAprobados,
				SUM(CASE WHEN evf.presente = 1 AND evf.nota < 4  THEN 1 ELSE 0 END) AS cantDesaprobados,
				SUM(CASE WHEN evf.presente = 0 THEN 1 ELSE 0 END) AS cantAusentes,
				SUM(CASE WHEN evf.presente = 1 THEN 1 ELSE 0 END) AS cantPresentes,
				COALESCE(SUM(evf.nota) * 1.0 / NULLIF(COUNT(CASE WHEN evf.presente = 1 THEN 1 END), 0), 0) AS promedioNotas
			FROM LOS_SELECTOS.evaluacionFinal evf
			JOIN LOS_SELECTOS.inscripcionFinal insf ON (insf.nro_inscripcion = evf.nro_inscripcion)
			JOIN LOS_SELECTOS.examenFinal exf ON (exf.final_id = insf.examenFinal_id)
			JOIN LOS_SELECTOS.curso curso ON (exf.curso_id = curso.codigo)
			JOIN LOS_SELECTOS.alumno alu ON (alu.alumno_id = insf.alumno_id)
			--join dimensiones
			JOIN BI_LOS_SELECTOS.BI_dim_categoria c ON (c.categoria_id = curso.categoria_id)
			JOIN BI_LOS_SELECTOS.BI_dim_sede s ON (s.sede_id = curso.sede_id)
			JOIN BI_LOS_SELECTOS.BI_dim_rango_etario_alumno r 
				ON (BI_LOS_SELECTOS.fn_CalcularEdad(alu.fecha_nacimiento) BETWEEN r.rangoMin AND COALESCE(r.rangoMax, 200))
			JOIN BI_LOS_SELECTOS.BI_dim_tiempo t ON (t.anio = YEAR(insf.fecha_inscripto) AND t.mes = MONTH(insf.fecha_inscripto))
			GROUP BY t.tiempo_id, s.sede_id, c.categoria_id, r.rango_id;

			--HECHO:CURSO
			INSERT INTO BI_LOS_SELECTOS.BI_hecho_curso(tiempo_id, sede_id, categoria_id, cantAlumnos, cantAprobados, cantDesaprobados,totalEsperado, totalFacturado, totalAdeudado)
			SELECT
				t.tiempo_id,
				s.sede_id,
				c.categoria_id,
				COALESCE(alu.cantAlumnos, 0) AS cantAlumnos,
				COALESCE(eval.cantAprobados, 0) AS cantAprobados,
				COALESCE(eval.cantDesaprobados, 0) AS cantDesaprobados,
				COALESCE(fac.totalEsperado, 0) AS totalEsperado,
				COALESCE(fac.totalFacturado, 0) AS totalFacturado,
				COALESCE(fac.totalAdeudado, 0) AS totalAdeudado
			FROM LOS_SELECTOS.curso curso
			JOIN BI_LOS_SELECTOS.BI_dim_categoria c ON c.categoria_id = curso.categoria_id
			JOIN BI_LOS_SELECTOS.BI_dim_sede s ON s.sede_id = curso.sede_id
			JOIN BI_LOS_SELECTOS.BI_dim_tiempo t ON (t.anio = YEAR(curso.fecha_inicio) AND t.mes = MONTH(curso.fecha_fin))

			-- SUBQUERY ALUMNOS POR CURSO
			JOIN (
				SELECT 
					ins.curso_id,
					SUM(CASE WHEN ei.estado_id = 1 THEN 1 ELSE 0 END) AS cantAlumnos
				FROM LOS_SELECTOS.inscripcion ins
				JOIN LOS_SELECTOS.estadoXinscripcion ei ON ei.inscripcion_id = ins.nro_inscripcion
				GROUP BY ins.curso_id
			) alu ON alu.curso_id = curso.codigo

			-- SUBQUERY EVALUACIONES + TP (por alumno)
			JOIN (
				SELECT
					x.curso_id,
					SUM(CASE WHEN x.aprobado = 1 THEN 1 ELSE 0 END) AS cantAprobados,
					SUM(CASE WHEN x.aprobado = 0 THEN 1 ELSE 0 END) AS cantDesaprobados
				FROM (
					SELECT 
						alu.alumno_id,
						ins.curso_id,
            
						-- Si TODAS sus evaluaciones tienen nota >= 4
						-- Y si existe TP, debe estar aprobado
						CASE 
							WHEN MIN(CASE WHEN aev.nota >= 4 THEN 1 ELSE 0 END) = 1
								AND (MAX(tp.nota) IS NULL OR MAX(CASE WHEN tp.nota >= 4 THEN 1 ELSE 0 END) = 1)
							THEN 1 ELSE 0
						END AS aprobado

					--solo alumnos inscriptos
					FROM LOS_SELECTOS.inscripcion ins
					JOIN LOS_SELECTOS.estadoXinscripcion ei ON ei.inscripcion_id = ins.nro_inscripcion AND ei.estado_id = 1

					JOIN LOS_SELECTOS.alumno alu ON alu.alumno_id = ins.alumno_id
					LEFT JOIN LOS_SELECTOS.modulo m ON m.curso_id = ins.curso_id
					LEFT JOIN LOS_SELECTOS.evaluacion ev ON ev.modulo_id = m.modulo_id
					LEFT JOIN LOS_SELECTOS.alumnoXevaluacion aev ON aev.evaluacion_id = ev.evaluacion_id AND aev.alumno_id = alu.alumno_id
					LEFT JOIN LOS_SELECTOS.trabajoPractico tp ON tp.curso_id = ins.curso_id AND tp.alumno_id = alu.alumno_id
					GROUP BY alu.alumno_id, ins.curso_id
				) x
				GROUP BY x.curso_id
			) eval ON eval.curso_id = curso.codigo

			-- SUBQUERY FACTURACIÓN POR CURSO
			JOIN (
				SELECT 
					df.curso_id,
					SUM(df.importe) AS totalEsperado,
					SUM(CASE WHEN p.importe IS NOT NULL THEN p.importe ELSE 0 END) AS totalFacturado,
					SUM(CASE
							WHEN p.nroFactura IS NULL AND f.nroFactura IS NOT NULL THEN df.importe
							ELSE 0
						END) AS totalAdeudado
				FROM LOS_SELECTOS.detalleFactura df
				LEFT JOIN LOS_SELECTOS.factura f ON f.nroFactura = df.nroFactura
				LEFT JOIN LOS_SELECTOS.pago p ON p.nroFactura = f.nroFactura
				GROUP BY df.curso_id
			) fac ON fac.curso_id = curso.codigo;
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
GO
EXECUTE BI_LOS_SELECTOS.migracion_etl_dimensiones;
GO
EXECUTE BI_LOS_SELECTOS.migracion_etl_hechos;
GO
