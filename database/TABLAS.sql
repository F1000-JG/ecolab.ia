-- ============================================================
-- ECOLAB IA
-- BASE DE DATOS DESDE CERO
-- QUERY TOOL 1: CREACIÓN DE TABLAS
-- ============================================================


-- ============================================================
-- 1. USUARIOS
-- Guarda la información utilizada para iniciar sesión.
-- ============================================================

CREATE TABLE usuario (
    id_usuario SERIAL PRIMARY KEY,
    usuario VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,

    rol VARCHAR(20) NOT NULL
        CHECK (rol IN ('estudiante', 'docente')),

    activo BOOLEAN DEFAULT TRUE,

    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 2. ESTUDIANTES
-- Cada estudiante pertenece a un usuario.
-- Puede ser de 7.º, 8.º o 9.º.
-- ============================================================

CREATE TABLE estudiante (
    id_estudiante INTEGER PRIMARY KEY,

    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,

    grado INTEGER NOT NULL
        CHECK (grado IN (7, 8, 9)),

    CONSTRAINT fk_estudiante_usuario
        FOREIGN KEY (id_estudiante)
        REFERENCES usuario(id_usuario)
        ON DELETE CASCADE
);


-- ============================================================
-- 3. DOCENTES
-- Cada docente pertenece a un usuario.
-- ============================================================

CREATE TABLE docente (
    id_docente INTEGER PRIMARY KEY,

    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,

    CONSTRAINT fk_docente_usuario
        FOREIGN KEY (id_docente)
        REFERENCES usuario(id_usuario)
        ON DELETE CASCADE
);


-- ============================================================
-- 4. EXPERIMENTOS
-- Guarda todos los experimentos de EcoLab.
--
-- Los experimentos pueden pertenecer a:
-- Física
-- Química
-- Biología
--
-- Y pueden ser de 7.º, 8.º o 9.º.
-- ============================================================

CREATE TABLE experimento (
    id_experimento SERIAL PRIMARY KEY,

    nombre VARCHAR(150) NOT NULL,

    area VARCHAR(20) NOT NULL
        CHECK (area IN ('fisica', 'quimica', 'biologia')),

    grado INTEGER NOT NULL
        CHECK (grado IN (7, 8, 9)),

    descripcion TEXT,

    ruta VARCHAR(255),

    activo BOOLEAN DEFAULT TRUE,

    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 5. EVALUACIONES
-- Cada experimento puede tener una evaluación.
-- ============================================================

CREATE TABLE evaluacion (
    id_evaluacion SERIAL PRIMARY KEY,

    id_experimento INTEGER NOT NULL,

    titulo VARCHAR(150) NOT NULL,

    puntaje_maximo INTEGER DEFAULT 10,

    activa BOOLEAN DEFAULT TRUE,

    CONSTRAINT fk_evaluacion_experimento
        FOREIGN KEY (id_experimento)
        REFERENCES experimento(id_experimento)
        ON DELETE CASCADE
);


-- ============================================================
-- 6. PREGUNTAS
-- Cada evaluación tendrá 5 preguntas.
-- ============================================================

CREATE TABLE pregunta (
    id_pregunta SERIAL PRIMARY KEY,

    id_evaluacion INTEGER NOT NULL,

    enunciado TEXT NOT NULL,

    puntaje INTEGER DEFAULT 2,

    numero INTEGER NOT NULL,

    CONSTRAINT fk_pregunta_evaluacion
        FOREIGN KEY (id_evaluacion)
        REFERENCES evaluacion(id_evaluacion)
        ON DELETE CASCADE,

    CONSTRAINT chk_puntaje
        CHECK (puntaje > 0),

    CONSTRAINT chk_numero
        CHECK (numero BETWEEN 1 AND 5),

    CONSTRAINT uq_pregunta_numero
        UNIQUE (id_evaluacion, numero)
);


-- ============================================================
-- 7. OPCIONES
-- Cada pregunta tendrá sus opciones de respuesta.
-- Una de ellas será la correcta.
-- ============================================================

CREATE TABLE opcion (
    id_opcion SERIAL PRIMARY KEY,

    id_pregunta INTEGER NOT NULL,

    texto TEXT NOT NULL,

    es_correcta BOOLEAN DEFAULT FALSE,

    CONSTRAINT fk_opcion_pregunta
        FOREIGN KEY (id_pregunta)
        REFERENCES pregunta(id_pregunta)
        ON DELETE CASCADE
);


-- ============================================================
-- 8. INTENTOS DE EVALUACIÓN
--
-- Guarda cada vez que un estudiante realiza una evaluación.
--
-- Ejemplo:
--
-- Alexander → Energía → Intento 1 → 8/10
-- Alexander → Energía → Intento 2 → 10/10
--
-- Esto permitirá generar posteriormente los reportes.
-- ============================================================

CREATE TABLE intento_evaluacion (
    id_intento SERIAL PRIMARY KEY,

    id_estudiante INTEGER NOT NULL,

    id_evaluacion INTEGER NOT NULL,

    fecha_inicio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    fecha_finalizacion TIMESTAMP,

    nota NUMERIC(5,2),

    porcentaje NUMERIC(5,2),

    aprobado BOOLEAN,

    CONSTRAINT fk_intento_estudiante
        FOREIGN KEY (id_estudiante)
        REFERENCES estudiante(id_estudiante)
        ON DELETE CASCADE,

    CONSTRAINT fk_intento_evaluacion
        FOREIGN KEY (id_evaluacion)
        REFERENCES evaluacion(id_evaluacion)
        ON DELETE CASCADE,

    CONSTRAINT chk_nota
        CHECK (
            nota IS NULL
            OR (nota >= 0 AND nota <= 10)
        ),

    CONSTRAINT chk_porcentaje
        CHECK (
            porcentaje IS NULL
            OR (porcentaje >= 0 AND porcentaje <= 100)
        )
);


-- ============================================================
-- 9. RESPUESTAS
--
-- Guarda qué opción seleccionó el estudiante
-- en cada pregunta de cada intento.
-- ============================================================

CREATE TABLE respuesta (
    id_respuesta SERIAL PRIMARY KEY,

    id_intento INTEGER NOT NULL,

    id_pregunta INTEGER NOT NULL,

    id_opcion INTEGER NOT NULL,

    es_correcta BOOLEAN,

    puntos_obtenidos NUMERIC(5,2),

    CONSTRAINT fk_respuesta_intento
        FOREIGN KEY (id_intento)
        REFERENCES intento_evaluacion(id_intento)
        ON DELETE CASCADE,

    CONSTRAINT fk_respuesta_pregunta
        FOREIGN KEY (id_pregunta)
        REFERENCES pregunta(id_pregunta)
        ON DELETE CASCADE,

    CONSTRAINT fk_respuesta_opcion
        FOREIGN KEY (id_opcion)
        REFERENCES opcion(id_opcion)
        ON DELETE CASCADE,

    CONSTRAINT chk_puntos_obtenidos
        CHECK (
            puntos_obtenidos IS NULL
            OR puntos_obtenidos >= 0
        ),

    CONSTRAINT uq_respuesta_pregunta
        UNIQUE (id_intento, id_pregunta)
);

-- ============================================================
-- ECOLAB IA
-- COMPROBACIÓN DE TABLAS
-- ============================================================

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;