ECOLAB IA - BASE DE DATOS 7.º Y 9.º
=====================================

Este paquete mantiene intactos todos los archivos HTML originales.
La integración de las evaluaciones nuevas se realizó mediante:

- asistente.js
- php/guardar_evaluacion_auto.php
- database/MIGRAR_7_Y_9.sql

BASE DE DATOS YA EXISTENTE
--------------------------
Si ya tienes la base "ecolab_ia" con las tablas y los datos de 8.º:

1. Abre PostgreSQL / pgAdmin Query Tool.
2. Selecciona la base de datos ecolab_ia.
3. Ejecuta: database/MIGRAR_7_Y_9.sql
4. Conserva php/conexion.php con las credenciales correctas de tu PostgreSQL.

INSTALACIÓN DESDE CERO
----------------------
Si vas a crear la base completa desde cero:

1. Crea una base PostgreSQL llamada ecolab_ia.
2. Ejecuta database/INSTALACION_COMPLETA.sql.
3. Verifica las credenciales de php/conexion.php.

QUÉ SE AGREGÓ
-------------
- 9 experimentos de 7.º grado.
- 43 preguntas de 7.º grado.
- 10 experimentos de 9.º grado.
- 109 preguntas de 9.º grado.
- Todas sus opciones y respuestas correctas.
- Registro automático de intentos, nota, porcentaje y respuestas elegidas.
- Soporte para bancos mayores de 5 preguntas y cuestionarios con 3 o 4 opciones.
- Las evaluaciones que tienen bancos grandes continúan mostrando las preguntas que el HTML selecciona de forma natural.

IMPORTANTE
----------
No se modificó ningún .html del proyecto. Los nombres, diseños, simulaciones y
preguntas visibles permanecen como estaban. El guardado se engancha desde el
archivo asistente.js que los laboratorios ya cargaban.


ACTUALIZACIÓN - CONEXIÓN AUTOMÁTICA
===================================
En la versión corregida no es obligatorio ejecutar MIGRAR_7_Y_9.sql manualmente si la base base de EcoLab ya existe.
php/conexion.php detecta si faltan los datos de 7.º/9.º y ejecuta la migración automáticamente.
Para comprobar el estado real abre php/diagnostico.php desde Apache/PHP.
