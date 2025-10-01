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
    direccion VARCHAR(255) NOT NULL,
    localidad_id BIGINT NOT NULL,
    telefono VARCHAR(255),
    email VARCHAR(255),
    institucion_id BIGINT NOT NULL,

    FOREIGN KEY (localidad_id) REFERENCES LOS_SELECTOS.localidad(localidad_id),
    FOREIGN KEY (institucion_id) REFERENCES LOS_SELECTOS.institucion(id)
);

