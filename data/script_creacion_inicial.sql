-- =========================================
-- 1. Crear esquema del grupo
-- =========================================
CREATE SCHEMA LOS_SELECTOS
    AUTHORIZATION dbo;  -- dueño del schema (puede ser dbo u otro usuario)
GO

-- =========================================
-- 2. Creación de Tablas
-- =========================================

-- Crear tabla provincia
CREATE TABLE LOS_SELECTOS.provincia (
    provincia_id BIGINT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(255) NOT NULL
);

-- Crear tabla localidad
CREATE TABLE LOS_SELECTOS.localidad (
    localidad_id BIGINT PRIMARY KEY IDENTITY(1,1),
    provincia_id BIGINT NOT NULL,
    nombre VARCHAR(255) NOT NULL,

    FOREIGN KEY (provincia_id) REFERENCES LOS_SELECTOS.provincia(provincia_id)
);

-- Crear tabla institucion
CREATE TABLE LOS_SELECTOS.institucion (
    id BIGINT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(255) NOT NULL,
    razon_social VARCHAR(255) NOT NULL,
    institucion_cuit VARCHAR(255) NOT NULL UNIQUE
);

-- Crear tabla sede
CREATE TABLE LOS_SELECTOS.sede (
    sede_id BIGINT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(255) NOT NULL,
    direccion VARCHAR(255),
    localidad_id BIGINT NOT NULL,
    telefono VARCHAR(255),
    email VARCHAR(255),
    institucion_id BIGINT NOT NULL,

    FOREIGN KEY (localidad_id) REFERENCES LOS_SELECTOS.localidad(localidad_id),
    FOREIGN KEY (institucion_id) REFERENCES LOS_SELECTOS.institucion(id)
);

--Crear tabla alumno
CREATE TABLE LOS_SELECTOS.alumno (
    alumno_id BIGINT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(60) NOT NULL,
    apellido VARCHAR(60) NOT NULL,
    dni BIGINT NOT NULL UNIQUE,
    direccion VARCHAR(255),
    localidad_id BIGINT NOT NULL,
    email VARCHAR(255),
    legajo BIGINT NOT NULL UNIQUE,
    telefono VARCHAR(60),
    fecha_nacimiento DATETIME,
	
	FOREIGN KEY (localidad_id) REFERENCES LOS_SELECTOS.localidad(localidad_id)
);

--Crear tabla profesor
CREATE TABLE LOS_SELECTOS.profesor (
    profesor_id BIGINT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(255) NOT NULL,
    apellido VARCHAR(255) NOT NULL,
    dni VARCHAR(255) NOT NULL UNIQUE,
    direccion VARCHAR(255),
    localidad_id BIGINT NOT NULL,
    email VARCHAR(255),
    telefono VARCHAR(255),
    fecha_nacimiento DATETIME,
	
	FOREIGN KEY (localidad_id) REFERENCES LOS_SELECTOS.localidad(localidad_id)
);

--DIA
CREATE TABLE LOS_SELECTOS.dia (
    dia_id BIGINT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(255) NOT NULL,
		CHECK (nombre IN ('LUNES', 'MARTES', 'MIERCOLES', 'JUEVES', 'VIERNES', 'SABADO', 'DOMINGO'))
);

--CATEGORIA
CREATE TABLE LOS_SELECTOS.categoria (
    categoria_id BIGINT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(255) NOT NULL,
);

--TURNO
CREATE TABLE LOS_SELECTOS.turno (
    turno_id BIGINT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(255) NOT NULL,
    hora_inicio TIME,
	hora_fin TIME
);

--Crear tabla CURSO
CREATE TABLE LOS_SELECTOS.curso (
    codigo BIGINT PRIMARY KEY,
    sede_id BIGINT NOT NULL,
    profesor_id BIGINT NOT NULL,
    nombre VARCHAR(255),
    descripcion VARCHAR(255),
    categoria_id BIGINT NOT NULL,
    fecha_inicio DATE NOT NULL,
	fecha_fin DATE NOT NULL,
	duracion_meses TINYINT NOT NULL,
	turno_id BIGINT NOT NULL,
	precio_mensual DECIMAL(18,2) NOT NULL

	FOREIGN KEY (sede_id) REFERENCES LOS_SELECTOS.sede(sede_id),
	FOREIGN KEY (profesor_id) REFERENCES LOS_SELECTOS.profesor(profesor_id),
	FOREIGN KEY (categoria_id) REFERENCES LOS_SELECTOS.categoria(categoria_id),
	FOREIGN KEY (turno_id) REFERENCES LOS_SELECTOS.turno(turno_id)
);

-- Tabla intermedia cursoXdia (muchos a muchos)
CREATE TABLE LOS_SELECTOS.cursoXdia (
    curso_id BIGINT NOT NULL,
    dia_id BIGINT NOT NULL,
    PRIMARY KEY (curso_id, dia_id),
    FOREIGN KEY (curso_id) REFERENCES LOS_SELECTOS.curso(codigo),
    FOREIGN KEY (dia_id) REFERENCES LOS_SELECTOS.dia(dia_id)
);

--MODULO
CREATE TABLE LOS_SELECTOS.modulo (
    modulo_id  BIGINT PRIMARY KEY IDENTITY(1,1),
	nombre VARCHAR(255),
	descripcion VARCHAR(255),
    curso_id BIGINT NOT NULL

	FOREIGN KEY (curso_id) REFERENCES LOS_SELECTOS.curso(codigo),
);

--evaluacion
CREATE TABLE LOS_SELECTOS.evaluacion (
    evaluacion_id   BIGINT PRIMARY KEY IDENTITY(1,1),
	fecha DATETIME NOT NULL,
	descripcion VARCHAR(255) NULL,
    modulo_id BIGINT NOT NULL

	FOREIGN KEY (modulo_id) REFERENCES LOS_SELECTOS.modulo(modulo_id),
);

-- Tabla intermedia alumnoXevaluacion (muchos a muchos)
CREATE TABLE LOS_SELECTOS.alumnoXevaluacion (
    alumno_id BIGINT NOT NULL,
    evaluacion_id BIGINT NOT NULL,
	nota TINYINT NOT NULL,
	presente BIT NOT NULL,
	instancia TINYINT NOT NULL,

    PRIMARY KEY (evaluacion_id, alumno_id),
    FOREIGN KEY (alumno_id) REFERENCES LOS_SELECTOS.alumno(alumno_id),
    FOREIGN KEY (evaluacion_id) REFERENCES LOS_SELECTOS.evaluacion(evaluacion_id)
);

--INSCRIPCION
CREATE TABLE LOS_SELECTOS.inscripcion (
    nro_inscripcion  BIGINT PRIMARY KEY IDENTITY(1,1),
	fecha DATE NOT NULL,
    curso_id BIGINT NOT NULL,
	alumno_id BIGINT NOT NULL

	FOREIGN KEY (curso_id) REFERENCES LOS_SELECTOS.curso(codigo),
	FOREIGN KEY (alumno_id) REFERENCES LOS_SELECTOS.alumno(alumno_id)
);

--Evitar inscripciones duplicadas
ALTER TABLE LOS_SELECTOS.inscripcion
ADD CONSTRAINT uq_alumno_curso UNIQUE(alumno_id, curso_id);

--ESTADO
CREATE TABLE LOS_SELECTOS.estado (
    estado_id  BIGINT PRIMARY KEY IDENTITY(1,1),
	descripcion VARCHAR(20) NOT NULL
		CHECK (descripcion IN ('Pendiente', 'Confirmada', 'Rechazada'))
);

--Tabla intermedia estadoXinscripcion (muchos a muchos)
CREATE TABLE LOS_SELECTOS.estadoXinscripcion (
    estado_id BIGINT NOT NULL,
    inscripcion_id BIGINT NOT NULL,
    PRIMARY KEY (estado_id, inscripcion_id),
    FOREIGN KEY (inscripcion_id) REFERENCES LOS_SELECTOS.inscripcion(nro_inscripcion),
    FOREIGN KEY (estado_id) REFERENCES LOS_SELECTOS.estado(estado_id)
);

--TP
CREATE TABLE LOS_SELECTOS.trabajoPractico (
	alumno_id BIGINT NOT NULL,
	curso_id BIGINT NOT NULL,
    titulo VARCHAR(255) NULL,
	fechaEvaluacion DATETIME NULL,
	nota TINYINT

	PRIMARY KEY (alumno_id, curso_id),
	FOREIGN KEY (curso_id) REFERENCES LOS_SELECTOS.curso(codigo),
	FOREIGN KEY (alumno_id) REFERENCES LOS_SELECTOS.alumno(alumno_id)
);

--EXAMEN FINAL
CREATE TABLE LOS_SELECTOS.examenFinal (
	final_id  BIGINT PRIMARY KEY IDENTITY(1,1),
	curso_id BIGINT NOT NULL,
	fecha_hora DATETIME2 NOT NULL,
    descripcion VARCHAR(255)

	FOREIGN KEY (curso_id) REFERENCES LOS_SELECTOS.curso(codigo)
);

--INSCRIPCION A FINAL
CREATE TABLE LOS_SELECTOS.inscripcionFinal (
	inscripcionFinal_id  BIGINT PRIMARY KEY IDENTITY(1,1),
	examenFinal_id BIGINT NOT NULL,
	alumno_id BIGINT NOT NULL,
	fecha_inscripto DATETIME NOT NULL

	FOREIGN KEY (alumno_id) REFERENCES LOS_SELECTOS.alumno(alumno_id),
	FOREIGN KEY (examenFinal_id) REFERENCES LOS_SELECTOS.examenFinal(final_id)
);

--Evaluacion Final
CREATE TABLE LOS_SELECTOS.evaluacionFinal (
	inscripcionFinal_id BIGINT NOT NULL,
    profesor_id BIGINT NOT NULL,
    nota TINYINT NULL,
    presente BIT NOT NULL

    PRIMARY KEY (inscripcionFinal_id),
    FOREIGN KEY (inscripcionFinal_id) REFERENCES LOS_SELECTOS.inscripcionFinal(inscripcionFinal_id),
    FOREIGN KEY (profesor_id) REFERENCES LOS_SELECTOS.profesor(profesor_id)
);

-- Tabla estadoCursada
CREATE TABLE LOS_SELECTOS.estadoCursada (
    estado_id BIGINT PRIMARY KEY,
    descripcion VARCHAR(20) NOT NULL
		CHECK (descripcion IN ('APROBADO', 'DESAPROBADO', 'PROMOCIONADO', 'LIBRE'))
);

-- Tabla intermedia alumnoXcurso (muchos a muchos)
CREATE TABLE LOS_SELECTOS.alumnoXcurso (
    curso_id BIGINT NOT NULL,
    alumno_id BIGINT NOT NULL,
	estado_id BIGINT,
	notaFinal TINYINT

    PRIMARY KEY (curso_id, alumno_id),
    FOREIGN KEY (curso_id) REFERENCES LOS_SELECTOS.curso(codigo),
	FOREIGN KEY (alumno_id) REFERENCES LOS_SELECTOS.alumno(alumno_id),
    FOREIGN KEY (estado_id) REFERENCES LOS_SELECTOS.estadoCursada(estado_id)
);

-- =========================
-- GESTION DE PAGOS
-- =========================

-- Tabla medioDePago
CREATE TABLE LOS_SELECTOS.medioDePago (
    medio_id BIGINT PRIMARY KEY IDENTITY(1,1),
    descripcion VARCHAR(60) NOT NULL
		CHECK (descripcion IN ('TRANSFERENCIA', 'CREDITO', 'DEBITO', 'EFECTIVO'))
);

-- Tabla factura
CREATE TABLE LOS_SELECTOS.factura (
    nroFactura BIGINT PRIMARY KEY IDENTITY(1,1),
    fechaEmision DATETIME NOT NULL,
    fechaVencimiento DATETIME NOT NULL,
    alumno_id BIGINT NOT NULL,
    importeTotal DECIMAL(18,2) NOT NULL,

    FOREIGN KEY (alumno_id) REFERENCES LOS_SELECTOS.alumno(alumno_id)
);

-- Tabla detalle de factura
CREATE TABLE LOS_SELECTOS.detalleFactura (
    id BIGINT PRIMARY KEY IDENTITY(1,1),
    nroFactura BIGINT NOT NULL,
    curso_id BIGINT NOT NULL,
    periodo DATE NOT NULL,
    importe DECIMAL(18,2) NOT NULL,

    FOREIGN KEY (nroFactura) REFERENCES LOS_SELECTOS.factura(nroFactura),
    FOREIGN KEY (curso_id) REFERENCES LOS_SELECTOS.curso(codigo)
);

-- Tabla pago
CREATE TABLE LOS_SELECTOS.pago (
    pago_id BIGINT PRIMARY KEY IDENTITY(1,1),
    nroFactura BIGINT NOT NULL,
    fecha DATE NOT NULL,
    importe DECIMAL(18,2) NOT NULL,
    medio_id BIGINT NOT NULL,

    FOREIGN KEY (nroFactura) REFERENCES LOS_SELECTOS.factura(nroFactura),
    FOREIGN KEY (medio_id) REFERENCES LOS_SELECTOS.medioDePago(medio_id)
);

-- =========================
-- ENCUESTAS
-- =========================

-- Tabla pregunta
CREATE TABLE LOS_SELECTOS.pregunta (
    pregunta_id BIGINT PRIMARY KEY,
    pregunta VARCHAR(255) NOT NULL,
    nota TINYINT NULL
);

-- Tabla encuesta
CREATE TABLE LOS_SELECTOS.encuesta (
    encuesta_id BIGINT PRIMARY KEY,
    curso_id BIGINT NOT NULL,
    alumno_id BIGINT NOT NULL,
    fechaRegistro DATETIME NOT NULL,
    observaciones VARCHAR(255) NULL,

    FOREIGN KEY (curso_id) REFERENCES LOS_SELECTOS.curso(codigo),
    FOREIGN KEY (alumno_id) REFERENCES LOS_SELECTOS.alumno(alumno_id)
);

-- Tabla detalle (relación N:N entre encuesta y pregunta)
CREATE TABLE LOS_SELECTOS.detalleEncuesta (
    pregunta_id BIGINT NOT NULL,
    encuesta_id BIGINT NOT NULL,
    PRIMARY KEY (encuesta_id, pregunta_id),

    FOREIGN KEY (pregunta_id) REFERENCES LOS_SELECTOS.pregunta(pregunta_id),
    FOREIGN KEY (encuesta_id) REFERENCES LOS_SELECTOS.encuesta(encuesta_id)
);

-- =========================
-- TRIGGERS
-- =========================

--Trigger en pago: validar que el importe no supere el saldo de la factura.
--Lógica de negocio: Exige que el pago sea igual al total de la factura (un solo pago permitido).
GO
CREATE TRIGGER LOS_SELECTOS.tg_validar_importe
ON LOS_SELECTOS.pago
AFTER INSERT
AS 
BEGIN
	IF NOT EXISTS (
		SELECT i.importe, f.importeTotal 
		FROM inserted i 
		JOIN factura f ON (f.nroFactura = i.nroFactura) 
		WHERE i.importe = f.importeTotal
	)
	BEGIN
		RAISERROR('El importe del pago difiere del total de la factura.', 16, 1);
	END
END

--Trigger en pregunta: que la nota esté entre 1 y 10.
GO
CREATE TRIGGER LOS_SELECTOS.tg_validar_rango_nota
ON LOS_SELECTOS.pregunta
AFTER INSERT
AS 
BEGIN
	IF NOT EXISTS (
		SELECT i.nota
		FROM inserted i 
		WHERE i.nota BETWEEN 1 AND 10
	)
	BEGIN
		RAISERROR('Debe ser una respuesta entre 1 y 10.', 16, 1);
	END
END

-- =========================
-- ÍNDICES
-- =========================

--Creamos índices NONCLUSTERED en:
--Claves foráneas, para mejorar joins.
--Campos de búsqueda frecuentes (WHERE, JOIN, ORDER BY).
--Campos con alta cardinalidad (muchos valores distintos, ej: DNI, CUIT).

--Ejemplos:

-- Buscar facturas de un alumno
-- Suelo buscar facturas pendientes de la persona de forma frecuente
CREATE INDEX idx_factura_alumno ON LOS_SELECTOS.factura(alumno_id);

-- Hallar inscripciones por curso
-- Muchas instituciones revisan los inscriptos al curso una vez finalizado el período de inscripción
CREATE INDEX idx_inscripcion_curso ON LOS_SELECTOS.inscripcion(curso_id);

-- Hallar detalle por nroFactura
--Cuando pido una factura, suelo consultar el detalle en la mayoría de los casos
CREATE INDEX idx_detalle_factura ON LOS_SELECTOS.detalleFactura(nroFactura);

-- Consultar alumnos por evaluacion 
--Tras una evaluacion, los profesores necesitan consultar los resultados de sus alumnos
CREATE INDEX idx_evaluacion_alumnos ON LOS_SELECTOS.alumnoXevaluacion(evaluacion_id);

-- Consultar notas de un alumno
CREATE INDEX idx_nota_alumno ON LOS_SELECTOS.alumnoXevaluacion(alumno_id);

-- =========================
-- MIGRACIÓN
-- =========================

GO
CREATE PROCEDURE LOS_SELECTOS.migracion_datos_procedure
AS
BEGIN
	--INSTITUCIONES
	INSERT INTO LOS_SELECTOS.institucion (nombre, institucion_cuit, razon_social)
	SELECT DISTINCT 
		Institucion_Nombre, 
		Institucion_Cuit, 
		Institucion_RazonSocial
	FROM gd_esquema.Maestra
	WHERE Institucion_Cuit IS NOT NULL;

	--PROVINCIAS
	INSERT INTO LOS_SELECTOS.provincia(nombre)
	SELECT DISTINCT nombre
	FROM (
		--Sede_Localidad tiene provincias (estan invertidos)
		SELECT Sede_Localidad AS nombre FROM gd_esquema.Maestra WHERE Sede_Localidad IS NOT NULL
		UNION
		SELECT Alumno_Provincia FROM gd_esquema.Maestra WHERE Alumno_Provincia IS NOT NULL
		UNION
		SELECT Profesor_Provincia FROM gd_esquema.Maestra WHERE Profesor_Provincia IS NOT NULL
	) AS provincias;

	INSERT INTO LOS_SELECTOS.localidad(nombre, provincia_id)
	SELECT DISTINCT 
		maestra.localidad, 
		p.provincia_id --FK
	FROM (
		SELECT 
			Sede_Provincia AS localidad, --localidad
			Sede_Localidad AS provincia  --provincia
		FROM gd_esquema.Maestra
		WHERE Sede_Provincia IS NOT NULL AND Sede_Localidad IS NOT NULL

		UNION

		SELECT 
			Alumno_Localidad AS localidad,
			Alumno_Provincia AS provincia
		FROM gd_esquema.Maestra
		WHERE Alumno_Localidad IS NOT NULL AND Alumno_Provincia IS NOT NULL

		UNION

		SELECT 
			Profesor_Localidad AS localidad,
			Profesor_Provincia AS provincia
		FROM gd_esquema.Maestra
		WHERE Profesor_Localidad IS NOT NULL AND Profesor_Provincia IS NOT NULL
	) AS maestra
	
	JOIN LOS_SELECTOS.provincia p 
		ON (p.nombre = maestra.provincia)

	--SEDES
	INSERT INTO LOS_SELECTOS.sede(nombre, direccion, localidad_id, telefono, email, institucion_id)
	SELECT DISTINCT
		m.Sede_Nombre,
		m.Sede_Direccion,
		l.localidad_id, --FK
		m.Sede_Telefono,
		m.Sede_Mail,
		i.id --FK
	FROM gd_esquema.Maestra m
	JOIN LOS_SELECTOS.institucion i
		ON (i.institucion_cuit = m.Institucion_Cuit)
	JOIN LOS_SELECTOS.localidad l
		ON (l.nombre = m.Sede_Provincia) --aca esta la localidad
	WHERE m.Sede_Nombre IS NOT NULL
	AND m.Sede_Provincia IS NOT NULL
	AND m.Institucion_Cuit IS NOT NULL;

	--PROFESORES
	INSERT INTO LOS_SELECTOS.profesor(nombre, apellido, dni, direccion, localidad_id, fecha_nacimiento, email, telefono)
	SELECT DISTINCT
		m.Profesor_nombre,
		m.Profesor_Apellido,
		m.Profesor_Dni,
		m.Profesor_Direccion,
		l.localidad_id, --FK
		m.Profesor_FechaNacimiento,
		m.Profesor_Mail,
		m.Profesor_Telefono
	FROM gd_esquema.Maestra m
	JOIN LOS_SELECTOS.localidad l 
		ON (l.nombre = m.Profesor_Localidad);

	--ALUMNOS
	INSERT INTO LOS_SELECTOS.alumno(nombre, apellido, dni, direccion, localidad_id, email, legajo, telefono, fecha_nacimiento)
	SELECT DISTINCT
		m.Alumno_Nombre,
		m.Alumno_Apellido,
		m.Alumno_Dni,
		m.Alumno_Direccion,
		l.localidad_id, --FK
		m.Alumno_Mail,
		m.Alumno_Legajo,
		m.Alumno_Telefono,
		m.Alumno_FechaNacimiento
	FROM gd_esquema.Maestra m
	JOIN LOS_SELECTOS.localidad l 
		ON (l.nombre = m.Alumno_Localidad);

	--CATEGORIAS
	INSERT INTO LOS_SELECTOS.categoria(nombre)
	SELECT DISTINCT
		Curso_Categoria
	FROM gd_esquema.Maestra
	WHERE Curso_Categoria IS NOT NULL;

	--TURNOS
	INSERT INTO LOS_SELECTOS.turno(nombre)
	SELECT DISTINCT
		Curso_Turno
	FROM gd_esquema.Maestra
	WHERE Curso_Turno IS NOT NULL;
		
	--CURSOS
	INSERT INTO LOS_SELECTOS.curso(codigo, sede_id, profesor_id, categoria_id, turno_id, nombre, descripcion, fecha_inicio, fecha_fin, duracion_meses, precio_mensual)
	SELECT DISTINCT
		m.Curso_Codigo,
		s.sede_id, --FK
		p.profesor_id, --FK
		c.categoria_id, --FK
		t.turno_id, --FK
		m.Curso_Nombre,
		m.Curso_Descripcion,
		m.Curso_FechaInicio,
		m.Curso_FechaFin,
		m.Curso_DuracionMeses,
		m.Curso_PrecioMensual
	FROM gd_esquema.Maestra m
	JOIN LOS_SELECTOS.sede s
		ON (s.nombre = m.Sede_Nombre)
	JOIN LOS_SELECTOS.profesor p
		ON (p.dni = m.Profesor_Dni)
	JOIN LOS_SELECTOS.categoria c
		ON (c.nombre = m.Curso_Categoria)
	JOIN LOS_SELECTOS.turno t
		ON (t.nombre = m.Curso_Turno)
	WHERE m.Curso_Codigo IS NOT NULL
	AND m.Sede_Nombre IS NOT NULL
	AND m.Profesor_Dni IS NOT NULL
	AND m.Curso_Categoria IS NOT NULL
	AND m.Curso_Turno IS NOT NULL;

	--DIAS
	INSERT INTO LOS_SELECTOS.dia(nombre)
	SELECT DISTINCT
		Curso_Dia
	FROM gd_esquema.Maestra
	WHERE Curso_Dia IS NOT NULL;

	--CURSO X DIA
	INSERT INTO LOS_SELECTOS.cursoXdia(curso_id, dia_id)
	SELECT DISTINCT
		m.Curso_Codigo, --PK, FK
		d.dia_id --PK, FK
	FROM gd_esquema.Maestra m
	JOIN LOS_SELECTOS.dia d
		ON(d.nombre = Curso_Dia)
	WHERE Curso_Dia IS NOT NULL
	AND Curso_Codigo IS NOT NULL

	--MODULOS
	INSERT INTO LOS_SELECTOS.modulo(nombre, descripcion, curso_id)
	SELECT DISTINCT
		m.Modulo_Nombre,
		m.Modulo_Descripcion,
		m.Curso_Codigo -- FK
	FROM gd_esquema.Maestra m
	WHERE m.Modulo_Nombre IS NOT NULL

	--INSCRIPCION
	INSERT INTO LOS_SELECTOS.inscripcion(nro_inscripcion, fecha, alumno_id, curso_id)
	SELECT DISTINCT
		m.Inscripcion_Numero,
		m.Inscripcion_Fecha,
		a.alumno_id, -- FK
		m.Curso_Codigo --FK
	FROM gd_esquema.Maestra m
	JOIN LOS_SELECTOS.alumno a
		ON (a.legajo = m.Alumno_Legajo)
	WHERE m.Alumno_Legajo IS NOT NULL

	--ESTADO
	INSERT INTO LOS_SELECTOS.estado(descripcion)
	SELECT DISTINCT
		m.Inscripcion_Estado
	FROM gd_esquema.Maestra m
	WHERE m.Inscripcion_Estado IS NOT NULL	

	--INSCRIPCION X ALUMNO
	INSERT INTO LOS_SELECTOS.estadoXinscripcion(estado_id, inscripcion_id)
	SELECT DISTINCT
		m.Inscripcion_Numero, --PK,FK
		e.estado_id --PK,FK
	FROM gd_esquema.Maestra m
	JOIN LOS_SELECTOS.estado e
		ON (e.descripcion = m.Inscripcion_Estado)
	--WHERE m.Alumno_Legajo IS NOT NULL	 --TODO

	--EVALUACION_CURSO
	INSERT INTO LOS_SELECTOS.evaluacion(modulo_id, fecha)
	SELECT DISTINCT
		mo.modulo_id,
		ma.Evaluacion_Curso_fechaEvaluacion
	FROM gd_esquema.Maestra ma
	JOIN LOS_SELECTOS.modulo mo
		ON (mo.descripcion = ma.Modulo_Descripcion AND mo.nombre = ma.Modulo_Descripcion)
	
	--ALUMNO X EVALUACION_CURSO
	INSERT INTO LOS_SELECTOS.alumnoXevaluacion(alumno_id, evaluacion_id, instancia, nota, presente)
	SELECT DISTINCT
		a.alumno_id, --FK
		e.evaluacion_id,
		m.Evaluacion_Curso_Instancia,
		m.Evaluacion_Curso_Nota,
		m.Evaluacion_Curso_Presente
	FROM gd_esquema.Maestra m
	JOIN LOS_SELECTOS.alumno a
		ON (a.legajo = m.Alumno_Legajo)
	JOIN LOS_SELECTOS.modulo mo
		ON (mo.nombre = m.Modulo_Nombre AND mo.descripcion = m.Modulo_Descripcion AND mo.curso_id = m.Curso_Codigo)
	JOIN LOS_SELECTOS.evaluacion e
		ON (e.fecha = m.Evaluacion_Curso_fechaEvaluacion AND e.modulo_id = mo.modulo_id)
	WHERE m.Evaluacion_Curso_fechaEvaluacion IS NOT NULL 
		AND m.Alumno_Legajo IS NOT NULL

	--TRABAJO PRACTICO
	INSERT INTO LOS_SELECTOS.trabajoPractico(alumno_id, curso_id, fechaEvaluacion, nota)
	SELECT DISTINCT
		a.alumno_id, --PK,FK
		m.Curso_Codigo, --PK,FK
		m.Trabajo_Practico_FechaEvaluacion,
		m.Trabajo_Practico_Nota
	FROM gd_esquema.Maestra m
	JOIN LOS_SELECTOS.alumno a
		ON (a.legajo = m.Alumno_Legajo)
	WHERE m.Trabajo_Practico_FechaEvaluacion IS NOT NULL 
		AND m.Trabajo_Practico_Nota IS NOT NULL;

	--FINAL
	INSERT INTO LOS_SELECTOS.examenFinal (curso_id, fecha_hora, descripcion)
	SELECT DISTINCT
		m.Curso_Codigo,  --FK
		DATEADD(SECOND, DATEDIFF(SECOND, 0, CAST(m.Examen_Final_Hora AS TIME)),		-- convierte '14:00' a segundos
			CAST(m.Examen_Final_Fecha AS DATETIME2)) AS fecha_hora,					-- suma esos segundos a la fecha base
		m.Examen_Final_Descripcion
	FROM gd_esquema.Maestra m
	WHERE m.Examen_Final_Descripcion IS NOT NULL
	AND m.Examen_Final_Fecha IS NOT NULL;

	--INSCRIPCION A FINAL
	INSERT INTO LOS_SELECTOS.inscripcionFinal(inscripcionFinal_id, fecha_inscripto, alumno_id, examenFinal_id)
	SELECT DISTINCT
		m.Inscripcion_Final_Nro, --PK
		m.Inscripcion_Final_Fecha,
		a.alumno_id, --FK
		e.final_id --FK
	FROM gd_esquema.Maestra m
	JOIN LOS_SELECTOS.examenFinal e
		ON (e.descripcion = m.Examen_Final_Descripcion)
	JOIN LOS_SELECTOS.alumno a
		ON (a.legajo = m.Alumno_Legajo)
	WHERE m.Inscripcion_Final_Nro IS NOT NULL
	AND m.Inscripcion_Final_Fecha IS NOT NULL;

	INSERT INTO LOS_SELECTOS.evaluacionFinal(inscripcionFinal_id, nota, presente, profesor_id)
	SELECT DISTINCT
		m.Inscripcion_Final_Nro, --PK, FK
		m.Evaluacion_Final_Nota,
		m.Evaluacion_Final_Presente,
		p.profesor_id --FK
	FROM gd_esquema.Maestra m
	JOIN LOS_SELECTOS.profesor p
		ON (p.dni = m.Profesor_Dni)
	WHERE m.Evaluacion_Final_Nota IS NOT NULL
	AND m.Evaluacion_Final_Presente IS NOT NULL;

	--ENCUESTAS
	--INSERT INTO LOS_SELECTOS.pregunta(pregunta, nota)
	--SELECT
	--	m.Encuesta_Pregunta1,
	--	m.Encuesta_Nota1
	--FROM gd_esquema.Maestra m
	--WHERE m.Encuesta_Pregunta1 IS NOT NULL;

	INSERT INTO LOS_SELECTOS.encuesta(curso_id, alumno_id, fechaRegistro, observaciones)
	SELECT DISTINCT
		m.Curso_Codigo,
		a.alumno_id,
		m.Encuesta_FechaRegistro,
		m.Encuesta_Observacion
	FROM gd_esquema.Maestra m
	JOIN LOS_SELECTOS.alumno a
		ON (a.legajo = m.Alumno_Legajo)
	WHERE m.Encuesta_FechaRegistro IS NOT NULL;

	--PAGOS
END

exec LOS_SELECTOS.migracion_datos_procedure

