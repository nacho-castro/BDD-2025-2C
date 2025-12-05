# 🎓 FRBA - Gestión de Cursos: Database & BI Solution

> **Proyecto integral de Base de Datos y Business Intelligence desarrollado para la gestión académica, desde el modelo transaccional hasta la analítica de datos.**

Este repositorio contiene el trabajo práctico desarrollado por el grupo **"Los SELECTos"** (Grupo 17) para la asignatura **Bases de Datos** de la **UTN FRBA**. El objetivo fue diseñar, implementar y explotar una base de datos relacional robusta y un Data Warehouse eficiente para la toma de decisiones.

---

## 🚀 Arquitectura del Proyecto

El desarrollo se divide en tres fases técnicas clave, simulando un ciclo de vida real de ingeniería de datos:

### 1. Modelado Relacional (OLTP)
Diseño de un esquema normalizado para garantizar la integridad de los datos transaccionales.

- **Normalización:** Aplicación de formas normales para entidades complejas como *Institución/Sede*, *Cursos* y *Alumnos*.
- **Integridad de Datos:** Implementación de **Triggers** de negocio:
  - `tg_validar_importe`: Asegura la consistencia entre pagos y facturas.
  - `tg_validar_rango_nota`: Valida rangos de notas en el sistema de encuestas.
- **Performance:** Creación de índices `NONCLUSTERED` en claves foráneas y campos de alta cardinalidad para optimizar JOINs y búsquedas frecuentes.

### 2. Migración de Datos
Procedimientos almacenados para la transformación y carga de datos desde una tabla maestra (legacy) hacia el nuevo esquema normalizado.

- **Volumen Migrado:** Procesamiento exitoso de más de 14.900 alumnos, 68.000 facturas y 54.000 pagos.
- **Eficiencia:** Script unificado `migracion_datos_procedure` con tiempo de ejecución optimizado (~8 segundos) para poblar 30 tablas.

### 3. Business Intelligence (OLAP)
Construcción de un Data Warehouse utilizando un **Esquema en Estrella (Star Schema)** para análisis gerencial.

- **ETL:** Procesos `migracion_etl_dimensiones` y `migracion_etl_hechos` para la carga del DW.
- **Hechos y Dimensiones:**
  - Tablas de hechos pre-calculadas para métricas de *Inscripción, Pagos, Encuestas, Finales y Cursos*.
  - Dimensión temporal optimizada con cálculo de semestres y granularidad mensual.

---

## 📊 KPIs e Indicadores de Negocio

El sistema provee Vistas SQL para responder a requerimientos estratégicos como:

- **📈 Rendimiento Académico:** Tasa de aprobación y tiempo promedio de finalización de carrera por categoría.
- **💸 Finanzas:** Análisis de ingresos top 3 por sede y tasa de morosidad mensual.
- **📉 Deserción y Ausentismo:** Tasa de rechazo de inscripciones y porcentaje de ausentismo en finales.
- **⭐ Calidad:** Índice de satisfacción basado en encuestas segmentado por rango etario del profesor.

---

## 🛠️ Stack Tecnológico & Conceptos

- **Motor de Base de Datos:** SQL Server (Transact-SQL).
- **Modelado de Datos:** DER, Normalización, Esquema Estrella.
- **Ingeniería de Datos:** Stored Procedures, Triggers, Índices, Procesos ETL.

---

### 👥 Equipo "Los SELECTos"
- Sofia Baudo
- Ignacio Castro
- Valentina Arbarello
- Carlos Daniel Ojeda Cabrera
