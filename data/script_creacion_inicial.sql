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
    hora_inicio DATETIME NOT NULL,
	hora_fin DATETIME NOT NULL
);

--Crear tabla CURSO
CREATE TABLE LOS_SELECTOS.curso (
    codigo BIGINT PRIMARY KEY IDENTITY(1,1),
    sede_id BIGINT NOT NULL,
    profesor_id BIGINT NOT NULL,
    nombre VARCHAR(255),
    descripcion VARCHAR(255),
    categoria_id BIGINT NOT NULL,
    fecha_inicio DATE NOT NULL,
	fecha_fin DATE NOT NULL,
	duracion TINYINT NOT NULL,
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
	descripcion VARCHAR(255),
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
		CHECK (descripcion IN ('PENDIENTE', 'ACEPTADA', 'RECHAZADA'))
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
    titulo VARCHAR(255) NOT NULL,
	fechaEvaluacion DATETIME NOT NULL,
	nota TINYINT

	PRIMARY KEY (alumno_id, curso_id),
	FOREIGN KEY (curso_id) REFERENCES LOS_SELECTOS.curso(codigo),
	FOREIGN KEY (alumno_id) REFERENCES LOS_SELECTOS.alumno(alumno_id)
);

--EXAMEN FINAL
CREATE TABLE LOS_SELECTOS.examenFinal (
	final_id  BIGINT PRIMARY KEY IDENTITY(1,1),
	curso_id BIGINT NOT NULL,
	fecha_hora DATETIME NOT NULL,
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
		RAISERROR('El importe de los pagos difiere del total de la factura.', 16, 1);
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
CREATE PROCEDURE LOS_SELECTOS.migrarDatos
AS
BEGIN
END
