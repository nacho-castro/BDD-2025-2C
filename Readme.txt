# 🎓 FRBA - Gestión de Cursos: Database & BI Solution

> **Proyecto integral de Base de Datos y Business Intelligence desarrollado para la gestión académica, desde el modelo transaccional hasta la analítica de datos.**

[cite_start]Este repositorio contiene el trabajo práctico desarrollado por el grupo **"Los SELECTos"** (Grupo 17) para la asignatura **Bases de Datos** de la **UTN FRBA**[cite: 2, 3, 8]. El objetivo fue diseñar, implementar y explotar una base de datos relacional robusta y un Data Warehouse eficiente para la toma de decisiones.

DOCUMENTACIÓN: [PDF](https://drive.google.com/file/d/1O52p-DftZI7y-GHTA9fuOWc1CJCK2hpL/view?usp=sharing)

---

## 🚀 Arquitectura del Proyecto

[cite_start]El desarrollo se divide en tres fases técnicas clave, simulando un ciclo de vida real de ingeniería de datos[cite: 13]:

### 1. Modelado Relacional (OLTP)
Diseño de un esquema normalizado para garantizar la integridad de los datos transaccionales.
* [cite_start]**Normalización:** Aplicación de formas normales para entidades complejas como *Institución/Sede* (1FN), *Cursos* (2FN) y *Alumnos*[cite: 17, 36, 77].
* **Integridad de Datos:** Implementación de **Triggers** de negocio:
    * [cite_start]`tg_validar_importe`: Asegura la consistencia entre pagos y facturas[cite: 358].
    * [cite_start]`tg_validar_rango_nota`: Valida inputs en el sistema de encuestas[cite: 361].
* [cite_start]**Performance:** Creación de índices `NONCLUSTERED` en claves foráneas y campos de alta cardinalidad para optimizar JOINs y búsquedas frecuentes[cite: 366].

### 2. Migración de Datos
Procedimientos almacenados para la transformación y carga de datos desde una tabla maestra (legacy) hacia el nuevo esquema normalizado.
* [cite_start]**Volumen Migrado:** Procesamiento exitoso de +14,900 alumnos, +68,000 facturas y +54,000 pagos[cite: 393, 410, 412].
* [cite_start]**Eficiencia:** Script unificado `migracion_datos_procedure` con un tiempo de ejecución optimizado de ~8 segundos para poblar 30 tablas[cite: 307, 382, 385].

### 3. Business Intelligence (OLAP)
[cite_start]Construcción de un Data Warehouse utilizando un **Esquema en Estrella (Star Schema)** para análisis gerencial[cite: 574].
* [cite_start]**ETL:** Procesos `migracion_etl_dimensiones` y `migracion_etl_hechos` transaccionales para la carga del DW[cite: 585].
* **Hechos y Dimensiones:**
    * [cite_start]Tablas de hechos pre-calculadas para métricas de *Inscripción, Pagos, Encuestas, Finales y Cursos*[cite: 708, 712, 716].
    * [cite_start]Dimensión temporal optimizada con cálculo pre-computado de semestres y granularidad mensual[cite: 690, 691].

---

## 📊 KPIs e Indicadores de Negocio

El sistema provee Vistas SQL para responder a requerimientos estratégicos complejos, tales como:

* [cite_start]**📈 Rendimiento Académico:** Tasa de aprobación y tiempo promedio de finalización de carrera por categoría[cite: 753, 759].
* [cite_start]**💸 Finanzas:** Análisis de ingresos top 3 por sede y tasa de morosidad mensual sobre facturación esperada[cite: 786, 793].
* [cite_start]**📉 Deserción y Ausentismo:** Tasa de rechazo de inscripciones y porcentaje de ausentismo en exámenes finales[cite: 744, 774].
* [cite_start]**⭐ Calidad:** Índice de satisfacción anual basado en encuestas, segmentado por rango etario del profesor[cite: 798].

---

## 🛠️ Stack Tecnológico & Conceptos

* **Motor de Base de Datos:** SQL Server (Transact-SQL).
* **Modelado de Datos:** DER (Diagrama Entidad-Relación), Normalización, Esquema Estrella.
* **Ingeniería de Datos:** Stored Procedures, Triggers, Índices, Procesos ETL.

---

### 👥 Equipo "Los SELECTos"
* Sofia Baudo
* Ignacio Castro
* Valentina Arbarello
* Carlos Daniel Ojeda Cabrera
[cite_start][cite: 8, 9, 10, 11]
