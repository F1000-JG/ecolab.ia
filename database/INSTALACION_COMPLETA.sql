
-- ===== TABLAS.sql =====
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

-- ===== EXPERIMENTOS.sql =====
-- ============================================================
-- ECOLAB IA
-- QUERY TOOL 2: REGISTRO DE EXPERIMENTOS
-- ============================================================

INSERT INTO experimento
(nombre, area, grado, descripcion, ruta)
VALUES

-- ============================================================
-- FÍSICA - 8.º GRADO
-- ============================================================

(
    'Energía potencial y cinética',
    'fisica',
    8,
    'Simulación para estudiar la transformación entre energía potencial y energía cinética.',
    'fisica/energia.html'
),

(
    'Frecuencia y período',
    'fisica',
    8,
    'Experimento virtual para estudiar la frecuencia y el período de un movimiento oscilatorio.',
    'fisica/frecuencia.html'
),

(
    'Sonido en una cuerda',
    'fisica',
    8,
    'Simulación para observar cómo se produce y transmite el sonido mediante una cuerda.',
    'fisica/sonido.html'
),


-- ============================================================
-- QUÍMICA - 8.º GRADO
-- ============================================================

(
    'Preparación de soluciones',
    'quimica',
    8,
    'Simulación de la preparación y mezcla de sustancias para formar una solución.',
    'quimica/preparacion.html'
),

(
    'Concentración de soluciones',
    'quimica',
    8,
    'Experimento para estudiar cómo cambia la concentración de una solución.',
    'quimica/concentracion.html'
),

(
    'Dureza de minerales',
    'quimica',
    8,
    'Experimento virtual para comparar la dureza de diferentes minerales.',
    'quimica/dureza.html'
),


-- ============================================================
-- BIOLOGÍA - 8.º GRADO
-- ============================================================

(
    'Transporte de agua en las plantas',
    'biologia',
    8,
    'Experimento virtual para observar cómo se transporta el agua desde las raíces hacia otras partes de la planta.',
    'biologia/Transporte.html'
),

(
    'Función de las hojas',
    'biologia',
    8,
    'Experimento virtual para estudiar las principales funciones de las hojas.',
    'biologia/funcion.html'
),

(
    'Observación de tejidos animales',
    'biologia',
    8,
    'Simulación para observar diferentes tipos de tejidos animales y sus funciones.',
    'biologia/tejido.html'
);

-- ===== EVALUACIONES.sql =====
-- ============================================================
-- ECOLAB IA
-- QUERY TOOL 3: CREACIÓN DE EVALUACIONES
-- ============================================================

INSERT INTO evaluacion
(
    id_experimento,
    titulo,
    puntaje_maximo,
    activa
)
SELECT
    id_experimento,
    'Evaluación - ' || nombre,
    10,
    TRUE
FROM experimento
ORDER BY id_experimento;

-- ===== PREGUNTAS.sql =====
-- ============================================================
-- ECOLAB IA
-- QUERY TOOL 4: REGISTRO DE LAS 45 PREGUNTAS
-- ============================================================

-- ============================================================
-- FÍSICA
-- 1. Energía Potencial y Cinética
-- ============================================================

INSERT INTO pregunta
(id_evaluacion, enunciado, puntaje, numero)
SELECT id_evaluacion,
       '¿Qué ocurre con la energía potencial cuando la pelota desciende por la rampa?',
       2, 1
FROM evaluacion
WHERE id_experimento = (
    SELECT id_experimento
    FROM experimento
    WHERE nombre = 'Energía potencial y cinética'
);


INSERT INTO pregunta
(id_evaluacion, enunciado, puntaje, numero)
SELECT id_evaluacion,
       '¿Qué sucede con la energía cinética mientras la pelota aumenta su velocidad?',
       2, 2
FROM evaluacion
WHERE id_experimento = (
    SELECT id_experimento
    FROM experimento
    WHERE nombre = 'Energía potencial y cinética'
);


INSERT INTO pregunta
(id_evaluacion, enunciado, puntaje, numero)
SELECT id_evaluacion,
       '¿De qué depende la energía potencial gravitatoria?',
       2, 3
FROM evaluacion
WHERE id_experimento = (
    SELECT id_experimento
    FROM experimento
    WHERE nombre = 'Energía potencial y cinética'
);


INSERT INTO pregunta
(id_evaluacion, enunciado, puntaje, numero)
SELECT id_evaluacion,
       '¿Qué ocurre si aumentamos la masa de la pelota manteniendo la misma altura?',
       2, 4
FROM evaluacion
WHERE id_experimento = (
    SELECT id_experimento
    FROM experimento
    WHERE nombre = 'Energía potencial y cinética'
);


INSERT INTO pregunta
(id_evaluacion, enunciado, puntaje, numero)
SELECT id_evaluacion,
       '¿Qué transformación de energía se observa principalmente durante el descenso?',
       2, 5
FROM evaluacion
WHERE id_experimento = (
    SELECT id_experimento
    FROM experimento
    WHERE nombre = 'Energía potencial y cinética'
);


-- ============================================================
-- 2. Frecuencia y Período
-- ============================================================

INSERT INTO pregunta
(id_evaluacion, enunciado, puntaje, numero)
SELECT id_evaluacion,
       '¿Qué representa el período de un péndulo?',
       2, 1
FROM evaluacion
WHERE id_experimento = (
    SELECT id_experimento
    FROM experimento
    WHERE nombre = 'Frecuencia y período'
);


INSERT INTO pregunta
(id_evaluacion, enunciado, puntaje, numero)
SELECT id_evaluacion,
       '¿Qué fórmula permite calcular la frecuencia?',
       2, 2
FROM evaluacion
WHERE id_experimento = (
    SELECT id_experimento
    FROM experimento
    WHERE nombre = 'Frecuencia y período'
);


INSERT INTO pregunta
(id_evaluacion, enunciado, puntaje, numero)
SELECT id_evaluacion,
       '¿Qué ocurre con el período cuando aumenta la longitud del péndulo?',
       2, 3
FROM evaluacion
WHERE id_experimento = (
    SELECT id_experimento
    FROM experimento
    WHERE nombre = 'Frecuencia y período'
);


INSERT INTO pregunta
(id_evaluacion, enunciado, puntaje, numero)
SELECT id_evaluacion,
       '¿En qué unidad se mide la frecuencia?',
       2, 4
FROM evaluacion
WHERE id_experimento = (
    SELECT id_experimento
    FROM experimento
    WHERE nombre = 'Frecuencia y período'
);


INSERT INTO pregunta
(id_evaluacion, enunciado, puntaje, numero)
SELECT id_evaluacion,
       '¿Qué indica la frecuencia?',
       2, 5
FROM evaluacion
WHERE id_experimento = (
    SELECT id_experimento
    FROM experimento
    WHERE nombre = 'Frecuencia y período'
);


-- ============================================================
-- 3. Sonido en una cuerda
-- ============================================================

INSERT INTO pregunta
(id_evaluacion, enunciado, puntaje, numero)
SELECT id_evaluacion,
       '¿Qué ocurre con la frecuencia cuando aumenta la tensión de una cuerda?',
       2, 1
FROM evaluacion
WHERE id_experimento = (
    SELECT id_experimento
    FROM experimento
    WHERE nombre = 'Sonido en una cuerda'
);


INSERT INTO pregunta
(id_evaluacion, enunciado, puntaje, numero)
SELECT id_evaluacion,
       '¿Qué fórmula representa la tensión de la cuerda?',
       2, 2
FROM evaluacion
WHERE id_experimento = (
    SELECT id_experimento
    FROM experimento
    WHERE nombre = 'Sonido en una cuerda'
);


INSERT INTO pregunta
(id_evaluacion, enunciado, puntaje, numero)
SELECT id_evaluacion,
       '¿Qué ocurre con el sonido cuando aumenta la longitud de la cuerda?',
       2, 3
FROM evaluacion
WHERE id_experimento = (
    SELECT id_experimento
    FROM experimento
    WHERE nombre = 'Sonido en una cuerda'
);


INSERT INTO pregunta
(id_evaluacion, enunciado, puntaje, numero)
SELECT id_evaluacion,
       '¿En qué unidad se mide la frecuencia?',
       2, 4
FROM evaluacion
WHERE id_experimento = (
    SELECT id_experimento
    FROM experimento
    WHERE nombre = 'Sonido en una cuerda'
);


INSERT INTO pregunta
(id_evaluacion, enunciado, puntaje, numero)
SELECT id_evaluacion,
       '¿Qué sucede generalmente cuando aumenta la tensión de una cuerda?',
       2, 5
FROM evaluacion
WHERE id_experimento = (
    SELECT id_experimento
    FROM experimento
    WHERE nombre = 'Sonido en una cuerda'
);


-- ============================================================
-- QUÍMICA
-- 4. Preparación de soluciones
-- ============================================================

INSERT INTO pregunta
(id_evaluacion, enunciado, puntaje, numero)
SELECT id_evaluacion,
       '¿Qué es una solución homogénea?',
       2, 1
FROM evaluacion
WHERE id_experimento = (
    SELECT id_experimento
    FROM experimento
    WHERE nombre = 'Preparación de soluciones'
);


INSERT INTO pregunta
(id_evaluacion, enunciado, puntaje, numero)
SELECT id_evaluacion,
       '¿Qué ocurre cuando aumenta la cantidad de soluto?',
       2, 2
FROM evaluacion
WHERE id_experimento = (
    SELECT id_experimento
    FROM experimento
    WHERE nombre = 'Preparación de soluciones'
);


INSERT INTO pregunta
(id_evaluacion, enunciado, puntaje, numero)
SELECT id_evaluacion,
       '¿Qué función cumple el agua en este experimento?',
       2, 3
FROM evaluacion
WHERE id_experimento = (
    SELECT id_experimento
    FROM experimento
    WHERE nombre = 'Preparación de soluciones'
);


INSERT INTO pregunta
(id_evaluacion, enunciado, puntaje, numero)
SELECT id_evaluacion,
       '¿Cuál es la fórmula utilizada para calcular la concentración?',
       2, 4
FROM evaluacion
WHERE id_experimento = (
    SELECT id_experimento
    FROM experimento
    WHERE nombre = 'Preparación de soluciones'
);


INSERT INTO pregunta
(id_evaluacion, enunciado, puntaje, numero)
SELECT id_evaluacion,
       '¿Qué sucede durante la mezcla con una cuchara?',
       2, 5
FROM evaluacion
WHERE id_experimento = (
    SELECT id_experimento
    FROM experimento
    WHERE nombre = 'Preparación de soluciones'
);


-- ============================================================
-- 5. Concentración de soluciones
-- ============================================================

INSERT INTO pregunta
(id_evaluacion, enunciado, puntaje, numero)
SELECT id_evaluacion,
       '¿Qué representa la concentración de una solución?',
       2, 1
FROM evaluacion
WHERE id_experimento = (
    SELECT id_experimento
    FROM experimento
    WHERE nombre = 'Concentración de soluciones'
);


INSERT INTO pregunta
(id_evaluacion, enunciado, puntaje, numero)
SELECT id_evaluacion,
       'Si tenemos la misma cantidad de agua y aumentamos la cantidad de sal, ¿qué ocurre con la concentración?',
       2, 2
FROM evaluacion
WHERE id_experimento = (
    SELECT id_experimento
    FROM experimento
    WHERE nombre = 'Concentración de soluciones'
);


INSERT INTO pregunta
(id_evaluacion, enunciado, puntaje, numero)
SELECT id_evaluacion,
       'En el experimento, ¿qué sustancia actúa como soluto?',
       2, 3
FROM evaluacion
WHERE id_experimento = (
    SELECT id_experimento
    FROM experimento
    WHERE nombre = 'Concentración de soluciones'
);


INSERT INTO pregunta
(id_evaluacion, enunciado, puntaje, numero)
SELECT id_evaluacion,
       '¿Cuál es la fórmula utilizada para calcular la concentración en este experimento?',
       2, 4
FROM evaluacion
WHERE id_experimento = (
    SELECT id_experimento
    FROM experimento
    WHERE nombre = 'Concentración de soluciones'
);


INSERT INTO pregunta
(id_evaluacion, enunciado, puntaje, numero)
SELECT id_evaluacion,
       '¿Cuál de los tres vasos tiene inicialmente la mayor concentración?',
       2, 5
FROM evaluacion
WHERE id_experimento = (
    SELECT id_experimento
    FROM experimento
    WHERE nombre = 'Concentración de soluciones'
);


-- ============================================================
-- 6. Dureza de minerales
-- ============================================================

INSERT INTO pregunta
(id_evaluacion, enunciado, puntaje, numero)
SELECT id_evaluacion,
       '¿Qué propiedad de los minerales se está estudiando en este experimento?',
       2, 1
FROM evaluacion
WHERE id_experimento = (
    SELECT id_experimento
    FROM experimento
    WHERE nombre = 'Dureza de minerales'
);


INSERT INTO pregunta
(id_evaluacion, enunciado, puntaje, numero)
SELECT id_evaluacion,
       '¿Qué ocurre cuando el material utilizado para probar es más duro que el mineral?',
       2, 2
FROM evaluacion
WHERE id_experimento = (
    SELECT id_experimento
    FROM experimento
    WHERE nombre = 'Dureza de minerales'
);


INSERT INTO pregunta
(id_evaluacion, enunciado, puntaje, numero)
SELECT id_evaluacion,
       '¿Cuál de los siguientes materiales tiene la mayor dureza aproximada en el experimento?',
       2, 3
FROM evaluacion
WHERE id_experimento = (
    SELECT id_experimento
    FROM experimento
    WHERE nombre = 'Dureza de minerales'
);


INSERT INTO pregunta
(id_evaluacion, enunciado, puntaje, numero)
SELECT id_evaluacion,
       '¿Cuál de estos minerales tiene una dureza de 7?',
       2, 4
FROM evaluacion
WHERE id_experimento = (
    SELECT id_experimento
    FROM experimento
    WHERE nombre = 'Dureza de minerales'
);


INSERT INTO pregunta
(id_evaluacion, enunciado, puntaje, numero)
SELECT id_evaluacion,
       '¿Para qué sirven las pruebas realizadas con el clavo, la moneda y el vidrio?',
       2, 5
FROM evaluacion
WHERE id_experimento = (
    SELECT id_experimento
    FROM experimento
    WHERE nombre = 'Dureza de minerales'
);


-- ============================================================
-- BIOLOGÍA
-- 7. Transporte de agua en las plantas
-- ============================================================

INSERT INTO pregunta
(id_evaluacion, enunciado, puntaje, numero)
SELECT id_evaluacion,
       '¿Qué proceso se observó principalmente durante el experimento?',
       2, 1
FROM evaluacion
WHERE id_experimento = (
    SELECT id_experimento
    FROM experimento
    WHERE nombre = 'Transporte de agua en las plantas'
);


INSERT INTO pregunta
(id_evaluacion, enunciado, puntaje, numero)
SELECT id_evaluacion,
       '¿Qué estructura de la planta absorbe y transporta el agua hacia las partes superiores?',
       2, 2
FROM evaluacion
WHERE id_experimento = (
    SELECT id_experimento
    FROM experimento
    WHERE nombre = 'Transporte de agua en las plantas'
);


INSERT INTO pregunta
(id_evaluacion, enunciado, puntaje, numero)
SELECT id_evaluacion,
       '¿Por qué se utiliza agua coloreada en este experimento?',
       2, 3
FROM evaluacion
WHERE id_experimento = (
    SELECT id_experimento
    FROM experimento
    WHERE nombre = 'Transporte de agua en las plantas'
);


INSERT INTO pregunta
(id_evaluacion, enunciado, puntaje, numero)
SELECT id_evaluacion,
       '¿Qué ocurre con una flor blanca colocada en agua coloreada?',
       2, 4
FROM evaluacion
WHERE id_experimento = (
    SELECT id_experimento
    FROM experimento
    WHERE nombre = 'Transporte de agua en las plantas'
);


INSERT INTO pregunta
(id_evaluacion, enunciado, puntaje, numero)
SELECT id_evaluacion,
       '¿Qué demuestra principalmente este experimento?',
       2, 5
FROM evaluacion
WHERE id_experimento = (
    SELECT id_experimento
    FROM experimento
    WHERE nombre = 'Transporte de agua en las plantas'
);


-- ============================================================
-- 8. Función de las hojas
-- ============================================================

INSERT INTO pregunta
(id_evaluacion, enunciado, puntaje, numero)
SELECT id_evaluacion,
       '¿Cuál es una de las principales funciones de las hojas?',
       2, 1
FROM evaluacion
WHERE id_experimento = (
    SELECT id_experimento
    FROM experimento
    WHERE nombre = 'Función de las hojas'
);


INSERT INTO pregunta
(id_evaluacion, enunciado, puntaje, numero)
SELECT id_evaluacion,
       '¿Qué fuente de energía utiliza la hoja para realizar la fotosíntesis?',
       2, 2
FROM evaluacion
WHERE id_experimento = (
    SELECT id_experimento
    FROM experimento
    WHERE nombre = 'Función de las hojas'
);


INSERT INTO pregunta
(id_evaluacion, enunciado, puntaje, numero)
SELECT id_evaluacion,
       '¿Qué gas se produce durante la fotosíntesis y se representa saliendo de la hoja?',
       2, 3
FROM evaluacion
WHERE id_experimento = (
    SELECT id_experimento
    FROM experimento
    WHERE nombre = 'Función de las hojas'
);


INSERT INTO pregunta
(id_evaluacion, enunciado, puntaje, numero)
SELECT id_evaluacion,
       '¿Qué proceso consiste en la pérdida de agua en forma de vapor por las hojas?',
       2, 4
FROM evaluacion
WHERE id_experimento = (
    SELECT id_experimento
    FROM experimento
    WHERE nombre = 'Función de las hojas'
);


INSERT INTO pregunta
(id_evaluacion, enunciado, puntaje, numero)
SELECT id_evaluacion,
       '¿Qué ocurre generalmente cuando aumenta la intensidad de luz en la simulación?',
       2, 5
FROM evaluacion
WHERE id_experimento = (
    SELECT id_experimento
    FROM experimento
    WHERE nombre = 'Función de las hojas'
);


-- ============================================================
-- 9. Observación de tejidos animales
-- ============================================================

INSERT INTO pregunta
(id_evaluacion, enunciado, puntaje, numero)
SELECT id_evaluacion,
       '¿Qué se estudia principalmente en esta actividad?',
       2, 1
FROM evaluacion
WHERE id_experimento = (
    SELECT id_experimento
    FROM experimento
    WHERE nombre = 'Observación de tejidos animales'
);


INSERT INTO pregunta
(id_evaluacion, enunciado, puntaje, numero)
SELECT id_evaluacion,
       '¿Cómo se caracteriza principalmente el tejido epitelial?',
       2, 2
FROM evaluacion
WHERE id_experimento = (
    SELECT id_experimento
    FROM experimento
    WHERE nombre = 'Observación de tejidos animales'
);


INSERT INTO pregunta
(id_evaluacion, enunciado, puntaje, numero)
SELECT id_evaluacion,
       '¿Cuál es una característica del tejido muscular?',
       2, 3
FROM evaluacion
WHERE id_experimento = (
    SELECT id_experimento
    FROM experimento
    WHERE nombre = 'Observación de tejidos animales'
);


INSERT INTO pregunta
(id_evaluacion, enunciado, puntaje, numero)
SELECT id_evaluacion,
       '¿Qué estructuras encontramos en el tejido nervioso?',
       2, 4
FROM evaluacion
WHERE id_experimento = (
    SELECT id_experimento
    FROM experimento
    WHERE nombre = 'Observación de tejidos animales'
);


INSERT INTO pregunta
(id_evaluacion, enunciado, puntaje, numero)
SELECT id_evaluacion,
       '¿Cuál es una función importante del tejido conectivo?',
       2, 5
FROM evaluacion
WHERE id_experimento = (
    SELECT id_experimento
    FROM experimento
    WHERE nombre = 'Observación de tejidos animales'
);



SELECT
    p.id_pregunta,
    ex.nombre AS experimento,
    ex.area,
    ex.grado,
    p.numero,
    p.puntaje,
    p.enunciado
FROM pregunta p
INNER JOIN evaluacion e
    ON p.id_evaluacion = e.id_evaluacion
INNER JOIN experimento ex
    ON e.id_experimento = ex.id_experimento
ORDER BY ex.id_experimento, p.numero;


SELECT COUNT(*) AS total_preguntas
FROM pregunta;


SELECT
    ex.nombre AS experimento,
    COUNT(p.id_pregunta) AS cantidad_preguntas
FROM experimento ex
INNER JOIN evaluacion e
    ON ex.id_experimento = e.id_experimento
INNER JOIN pregunta p
    ON e.id_evaluacion = p.id_evaluacion
GROUP BY ex.id_experimento, ex.nombre
ORDER BY ex.id_experimento;

-- ===== RESPUESTAS CORRECTAS.sql =====
WITH datos(experimento, numero, letra, texto, es_correcta) AS (
    VALUES

    -- =====================================================
    -- FÍSICA 1: ENERGÍA POTENCIAL Y CINÉTICA
    -- =====================================================

    ('Energía potencial y cinética', 1, 'A', 'Aumenta.', FALSE),
    ('Energía potencial y cinética', 1, 'B', 'Disminuye.', TRUE),
    ('Energía potencial y cinética', 1, 'C', 'Permanece siempre igual.', FALSE),
    ('Energía potencial y cinética', 1, 'D', 'Desaparece completamente.', FALSE),

    ('Energía potencial y cinética', 2, 'A', 'Disminuye.', FALSE),
    ('Energía potencial y cinética', 2, 'B', 'Aumenta.', TRUE),
    ('Energía potencial y cinética', 2, 'C', 'Se vuelve cero.', FALSE),
    ('Energía potencial y cinética', 2, 'D', 'No cambia.', FALSE),

    ('Energía potencial y cinética', 3, 'A', 'De la masa, la gravedad y la altura.', TRUE),
    ('Energía potencial y cinética', 3, 'B', 'Solamente de la velocidad.', FALSE),
    ('Energía potencial y cinética', 3, 'C', 'Solamente del tiempo.', FALSE),
    ('Energía potencial y cinética', 3, 'D', 'Solamente del tamaño de la rampa.', FALSE),

    ('Energía potencial y cinética', 4, 'A', 'La energía potencial disminuye.', FALSE),
    ('Energía potencial y cinética', 4, 'B', 'La energía potencial aumenta.', TRUE),
    ('Energía potencial y cinética', 4, 'C', 'La masa deja de influir.', FALSE),
    ('Energía potencial y cinética', 4, 'D', 'La altura se vuelve cero.', FALSE),

    ('Energía potencial y cinética', 5, 'A', 'Energía cinética a energía potencial.', FALSE),
    ('Energía potencial y cinética', 5, 'B', 'Energía potencial a energía cinética.', TRUE),
    ('Energía potencial y cinética', 5, 'C', 'Energía térmica a energía química.', FALSE),
    ('Energía potencial y cinética', 5, 'D', 'No existe transformación de energía.', FALSE),


    -- =====================================================
    -- FÍSICA 2: FRECUENCIA Y PERÍODO
    -- =====================================================

    ('Frecuencia y período', 1, 'A', 'La cantidad de masa del péndulo.', FALSE),
    ('Frecuencia y período', 1, 'B', 'El tiempo que tarda en realizar una oscilación.', TRUE),
    ('Frecuencia y período', 1, 'C', 'La velocidad máxima del péndulo.', FALSE),
    ('Frecuencia y período', 1, 'D', 'La altura del soporte.', FALSE),

    ('Frecuencia y período', 2, 'A', 'f = T', FALSE),
    ('Frecuencia y período', 2, 'B', 'f = T × g', FALSE),
    ('Frecuencia y período', 2, 'C', 'f = 1 ÷ T.', TRUE),
    ('Frecuencia y período', 2, 'D', 'f = L × T', FALSE),

    ('Frecuencia y período', 3, 'A', 'El período aumenta.', TRUE),
    ('Frecuencia y período', 3, 'B', 'El período siempre se hace cero.', FALSE),
    ('Frecuencia y período', 3, 'C', 'El período desaparece.', FALSE),
    ('Frecuencia y período', 3, 'D', 'No puede medirse.', FALSE),

    ('Frecuencia y período', 4, 'A', 'Metros (m)', FALSE),
    ('Frecuencia y período', 4, 'B', 'Segundos (s)', FALSE),
    ('Frecuencia y período', 4, 'C', 'Hertz (Hz).', TRUE),
    ('Frecuencia y período', 4, 'D', 'Kilogramos (kg)', FALSE),

    ('Frecuencia y período', 5, 'A', 'La longitud de la cuerda.', FALSE),
    ('Frecuencia y período', 5, 'B', 'Cuántas oscilaciones realiza por segundo.', TRUE),
    ('Frecuencia y período', 5, 'C', 'La masa del péndulo.', FALSE),
    ('Frecuencia y período', 5, 'D', 'La altura del soporte.', FALSE),


    -- =====================================================
    -- FÍSICA 3: SONIDO EN UNA CUERDA
    -- =====================================================

    ('Sonido en una cuerda', 1, 'A', 'La frecuencia disminuye.', FALSE),
    ('Sonido en una cuerda', 1, 'B', 'La frecuencia aumenta.', TRUE),
    ('Sonido en una cuerda', 1, 'C', 'La frecuencia desaparece.', FALSE),
    ('Sonido en una cuerda', 1, 'D', 'La frecuencia siempre es cero.', FALSE),

    ('Sonido en una cuerda', 2, 'A', 'T = m × g.', TRUE),
    ('Sonido en una cuerda', 2, 'B', 'T = L × g', FALSE),
    ('Sonido en una cuerda', 2, 'C', 'T = f × L', FALSE),
    ('Sonido en una cuerda', 2, 'D', 'T = m ÷ g', FALSE),

    ('Sonido en una cuerda', 3, 'A', 'El sonido se vuelve más agudo.', FALSE),
    ('Sonido en una cuerda', 3, 'B', 'El sonido se vuelve más grave.', TRUE),
    ('Sonido en una cuerda', 3, 'C', 'El sonido desaparece siempre.', FALSE),
    ('Sonido en una cuerda', 3, 'D', 'La tensión se vuelve cero.', FALSE),

    ('Sonido en una cuerda', 4, 'A', 'Metros (m)', FALSE),
    ('Sonido en una cuerda', 4, 'B', 'Newtons (N)', FALSE),
    ('Sonido en una cuerda', 4, 'C', 'Hertz (Hz).', TRUE),
    ('Sonido en una cuerda', 4, 'D', 'Kilogramos (kg)', FALSE),

    ('Sonido en una cuerda', 5, 'A', 'El sonido tiende a ser más agudo.', TRUE),
    ('Sonido en una cuerda', 5, 'B', 'El sonido siempre se vuelve más grave.', FALSE),
    ('Sonido en una cuerda', 5, 'C', 'La cuerda deja de vibrar.', FALSE),
    ('Sonido en una cuerda', 5, 'D', 'La frecuencia se vuelve cero.', FALSE),


    -- =====================================================
    -- QUÍMICA 4: PREPARACIÓN DE SOLUCIONES
    -- =====================================================

    ('Preparación de soluciones', 1, 'A', 'Una mezcla donde el soluto no se mezcla.', FALSE),
    ('Preparación de soluciones', 1, 'B', 'Una mezcla uniforme donde el soluto está distribuido en el solvente.', TRUE),
    ('Preparación de soluciones', 1, 'C', 'Una mezcla formada únicamente por agua.', FALSE),
    ('Preparación de soluciones', 1, 'D', 'Una sustancia sólida sin disolver.', FALSE),

    ('Preparación de soluciones', 2, 'A', 'La concentración disminuye.', FALSE),
    ('Preparación de soluciones', 2, 'B', 'El agua desaparece.', FALSE),
    ('Preparación de soluciones', 2, 'C', 'La concentración aumenta.', TRUE),
    ('Preparación de soluciones', 2, 'D', 'La solución deja de existir.', FALSE),

    ('Preparación de soluciones', 3, 'A', 'Actúa como solvente.', TRUE),
    ('Preparación de soluciones', 3, 'B', 'Actúa como soluto.', FALSE),
    ('Preparación de soluciones', 3, 'C', 'Aumenta la masa del recipiente.', FALSE),
    ('Preparación de soluciones', 3, 'D', 'Produce partículas de sal.', FALSE),

    ('Preparación de soluciones', 4, 'A', 'C = agua × soluto', FALSE),
    ('Preparación de soluciones', 4, 'B', 'C = masa del soluto ÷ volumen de la solución × 100.', TRUE),
    ('Preparación de soluciones', 4, 'C', 'C = volumen ÷ tiempo', FALSE),
    ('Preparación de soluciones', 4, 'D', 'C = masa × gravedad', FALSE),

    ('Preparación de soluciones', 5, 'A', 'Las partículas se concentran únicamente en el fondo.', FALSE),
    ('Preparación de soluciones', 5, 'B', 'El recipiente desaparece.', FALSE),
    ('Preparación de soluciones', 5, 'C', 'El agua se convierte en sólido.', FALSE),
    ('Preparación de soluciones', 5, 'D', 'Las partículas se dispersan hasta formar una solución uniforme.', TRUE),


    -- =====================================================
    -- QUÍMICA 5: CONCENTRACIÓN DE SOLUCIONES
    -- =====================================================

    ('Concentración de soluciones', 1, 'A', 'La cantidad de solvente que desaparece.', FALSE),
    ('Concentración de soluciones', 1, 'B', 'La relación entre la cantidad de soluto y solvente.', TRUE),
    ('Concentración de soluciones', 1, 'C', 'La temperatura del recipiente.', FALSE),
    ('Concentración de soluciones', 1, 'D', 'El tamaño del vaso.', FALSE),

    ('Concentración de soluciones', 2, 'A', 'Aumenta.', TRUE),
    ('Concentración de soluciones', 2, 'B', 'Disminuye.', FALSE),
    ('Concentración de soluciones', 2, 'C', 'Permanece siempre igual.', FALSE),
    ('Concentración de soluciones', 2, 'D', 'Desaparece.', FALSE),

    ('Concentración de soluciones', 3, 'A', 'El vaso.', FALSE),
    ('Concentración de soluciones', 3, 'B', 'La cuchara.', FALSE),
    ('Concentración de soluciones', 3, 'C', 'La sal.', TRUE),
    ('Concentración de soluciones', 3, 'D', 'El aire.', FALSE),

    ('Concentración de soluciones', 4, 'A', 'Concentración = agua × sal.', FALSE),
    ('Concentración de soluciones', 4, 'B', 'Concentración = agua ÷ sal.', FALSE),
    ('Concentración de soluciones', 4, 'C', 'Concentración = sal + agua.', FALSE),
    ('Concentración de soluciones', 4, 'D', 'Concentración (%) = sal ÷ agua × 100.', TRUE),

    ('Concentración de soluciones', 5, 'A', 'Vaso 1.', FALSE),
    ('Concentración de soluciones', 5, 'B', 'Vaso 2.', FALSE),
    ('Concentración de soluciones', 5, 'C', 'Vaso 3.', TRUE),
    ('Concentración de soluciones', 5, 'D', 'Todos tienen la misma concentración.', FALSE),


    -- =====================================================
    -- QUÍMICA 6: DUREZA DE MINERALES
    -- =====================================================

    ('Dureza de minerales', 1, 'A', 'La temperatura.', FALSE),
    ('Dureza de minerales', 1, 'B', 'La dureza.', TRUE),
    ('Dureza de minerales', 1, 'C', 'La masa.', FALSE),
    ('Dureza de minerales', 1, 'D', 'El volumen.', FALSE),

    ('Dureza de minerales', 2, 'A', 'El mineral puede ser rayado.', TRUE),
    ('Dureza de minerales', 2, 'B', 'El mineral desaparece.', FALSE),
    ('Dureza de minerales', 2, 'C', 'El material se convierte en mineral.', FALSE),
    ('Dureza de minerales', 2, 'D', 'No ocurre absolutamente nada.', FALSE),

    ('Dureza de minerales', 3, 'A', 'La moneda.', FALSE),
    ('Dureza de minerales', 3, 'B', 'El clavo.', FALSE),
    ('Dureza de minerales', 3, 'C', 'El vidrio.', TRUE),
    ('Dureza de minerales', 3, 'D', 'Todos tienen la misma dureza.', FALSE),

    ('Dureza de minerales', 4, 'A', 'Talco.', FALSE),
    ('Dureza de minerales', 4, 'B', 'Calcita.', FALSE),
    ('Dureza de minerales', 4, 'C', 'Cuarzo.', TRUE),
    ('Dureza de minerales', 4, 'D', 'Ninguno.', FALSE),

    ('Dureza de minerales', 5, 'A', 'Para medir la temperatura del mineral.', FALSE),
    ('Dureza de minerales', 5, 'B', 'Para comparar la dureza relativa del mineral.', TRUE),
    ('Dureza de minerales', 5, 'C', 'Para cambiar el color del mineral.', FALSE),
    ('Dureza de minerales', 5, 'D', 'Para medir su peso exacto.', FALSE),


    -- =====================================================
    -- BIOLOGÍA 7: TRANSPORTE DE AGUA EN LAS PLANTAS
    -- =====================================================

    ('Transporte de agua en las plantas', 1, 'A', 'La producción de semillas.', FALSE),
    ('Transporte de agua en las plantas', 1, 'B', 'El transporte y absorción de agua.', TRUE),
    ('Transporte de agua en las plantas', 1, 'C', 'La germinación de una semilla.', FALSE),
    ('Transporte de agua en las plantas', 1, 'D', 'La formación de raíces.', FALSE),

    ('Transporte de agua en las plantas', 2, 'A', 'El tallo y los vasos conductores.', TRUE),
    ('Transporte de agua en las plantas', 2, 'B', 'Las flores solamente.', FALSE),
    ('Transporte de agua en las plantas', 2, 'C', 'Los frutos.', FALSE),
    ('Transporte de agua en las plantas', 2, 'D', 'Las semillas.', FALSE),

    ('Transporte de agua en las plantas', 3, 'A', 'Para alimentar a la planta.', FALSE),
    ('Transporte de agua en las plantas', 3, 'B', 'Para aumentar el tamaño de la planta.', FALSE),
    ('Transporte de agua en las plantas', 3, 'C', 'Para observar visualmente el movimiento del agua.', TRUE),
    ('Transporte de agua en las plantas', 3, 'D', 'Para detener la absorción de agua.', FALSE),

    ('Transporte de agua en las plantas', 4, 'A', 'Sus pétalos pueden adquirir progresivamente el color del agua.', TRUE),
    ('Transporte de agua en las plantas', 4, 'B', 'Los pétalos desaparecen.', FALSE),
    ('Transporte de agua en las plantas', 4, 'C', 'La flor deja de absorber agua inmediatamente.', FALSE),
    ('Transporte de agua en las plantas', 4, 'D', 'La flor cambia automáticamente de especie.', FALSE),

    ('Transporte de agua en las plantas', 5, 'A', 'Que las plantas no necesitan agua.', FALSE),
    ('Transporte de agua en las plantas', 5, 'B', 'Que el agua puede desplazarse desde el tallo hacia otras partes de la planta.', TRUE),
    ('Transporte de agua en las plantas', 5, 'C', 'Que las plantas producen agua coloreada.', FALSE),
    ('Transporte de agua en las plantas', 5, 'D', 'Que las hojas producen el agua que absorbe la planta.', FALSE),


    -- =====================================================
    -- BIOLOGÍA 8: FUNCIÓN DE LAS HOJAS
    -- =====================================================

    ('Función de las hojas', 1, 'A', 'Absorber minerales directamente del suelo.', FALSE),
    ('Función de las hojas', 1, 'B', 'Realizar la fotosíntesis.', TRUE),
    ('Función de las hojas', 1, 'C', 'Producir semillas en todos los casos.', FALSE),
    ('Función de las hojas', 1, 'D', 'Formar las raíces.', FALSE),

    ('Función de las hojas', 2, 'A', 'La luz solar.', TRUE),
    ('Función de las hojas', 2, 'B', 'El viento.', FALSE),
    ('Función de las hojas', 2, 'C', 'El suelo.', FALSE),
    ('Función de las hojas', 2, 'D', 'El vapor de agua.', FALSE),

    ('Función de las hojas', 3, 'A', 'Dióxido de carbono (CO₂).', FALSE),
    ('Función de las hojas', 3, 'B', 'Oxígeno (O₂).', TRUE),
    ('Función de las hojas', 3, 'C', 'Nitrógeno (N₂).', FALSE),
    ('Función de las hojas', 3, 'D', 'Hidrógeno (H₂).', FALSE),

    ('Función de las hojas', 4, 'A', 'Respiración.', FALSE),
    ('Función de las hojas', 4, 'B', 'Fotosíntesis.', FALSE),
    ('Función de las hojas', 4, 'C', 'Transpiración.', TRUE),
    ('Función de las hojas', 4, 'D', 'Germinación.', FALSE),

    ('Función de las hojas', 5, 'A', 'Disminuye la actividad fotosintética.', FALSE),
    ('Función de las hojas', 5, 'B', 'Aumenta la actividad fotosintética.', TRUE),
    ('Función de las hojas', 5, 'C', 'La hoja deja de respirar.', FALSE),
    ('Función de las hojas', 5, 'D', 'Desaparece el vapor de agua.', FALSE),


    -- =====================================================
    -- BIOLOGÍA 9: OBSERVACIÓN DE TEJIDOS ANIMALES
    -- =====================================================

    ('Observación de tejidos animales', 1, 'A', 'El movimiento de los huesos.', FALSE),
    ('Observación de tejidos animales', 1, 'B', 'Las características y estructuras de los tejidos animales.', TRUE),
    ('Observación de tejidos animales', 1, 'C', 'La circulación del agua en las plantas.', FALSE),
    ('Observación de tejidos animales', 1, 'D', 'La reproducción de las plantas.', FALSE),

    ('Observación de tejidos animales', 2, 'A', 'Sus células están muy juntas formando capas.', TRUE),
    ('Observación de tejidos animales', 2, 'B', 'Está formado únicamente por huesos.', FALSE),
    ('Observación de tejidos animales', 2, 'C', 'Está compuesto solamente por neuronas.', FALSE),
    ('Observación de tejidos animales', 2, 'D', 'No posee células.', FALSE),

    ('Observación de tejidos animales', 3, 'A', 'Sus fibras están especializadas en la contracción.', TRUE),
    ('Observación de tejidos animales', 3, 'B', 'Solo sirve para transportar agua.', FALSE),
    ('Observación de tejidos animales', 3, 'C', 'Está formado únicamente por células nerviosas.', FALSE),
    ('Observación de tejidos animales', 3, 'D', 'No puede realizar ningún movimiento.', FALSE),

    ('Observación de tejidos animales', 4, 'A', 'Neuronas, dendritas y axones.', TRUE),
    ('Observación de tejidos animales', 4, 'B', 'Raíces, tallos y hojas.', FALSE),
    ('Observación de tejidos animales', 4, 'C', 'Huesos y cartílagos únicamente.', FALSE),
    ('Observación de tejidos animales', 4, 'D', 'Solo células musculares.', FALSE),

    ('Observación de tejidos animales', 5, 'A', 'Producir únicamente impulsos nerviosos.', FALSE),
    ('Observación de tejidos animales', 5, 'B', 'Realizar la fotosíntesis.', FALSE),
    ('Observación de tejidos animales', 5, 'C', 'Unir, sostener y proteger diferentes partes del cuerpo.', TRUE),
    ('Observación de tejidos animales', 5, 'D', 'Transportar agua desde las raíces.', FALSE)
)

INSERT INTO opcion
(id_pregunta, texto, es_correcta)
SELECT
    p.id_pregunta,
    d.letra || ') ' || d.texto,
    d.es_correcta
FROM datos d
INNER JOIN experimento ex
    ON ex.nombre = d.experimento
INNER JOIN evaluacion e
    ON e.id_experimento = ex.id_experimento
INNER JOIN pregunta p
    ON p.id_evaluacion = e.id_evaluacion
    AND p.numero = d.numero
ORDER BY p.id_pregunta, d.letra;

-- ===== MIGRAR_7_Y_9.sql =====
-- ============================================================
-- ECOLAB IA - MIGRACIÓN 7.º Y 9.º
-- No modifica archivos HTML.
-- Ejecutar sobre la base ecolab_ia que ya contiene las tablas.
-- ============================================================

BEGIN;

ALTER TABLE pregunta DROP CONSTRAINT IF EXISTS chk_numero;
ALTER TABLE pregunta ADD CONSTRAINT chk_numero CHECK (numero >= 1);

-- EXPERIMENTOS
INSERT INTO experimento (nombre, area, grado, descripcion, ruta)
SELECT 'Generador Hidroeléctrico', 'fisica', 7, 'Explora cómo la energía cinética del agua se convierte en energía eléctrica mediante un generador hidroeléctrico. Aprende sobre el flujo de agua, la rotación de la turbina y la generación de electricidad.', 'generador.html'
WHERE NOT EXISTS (SELECT 1 FROM experimento WHERE ruta = 'generador.html');

INSERT INTO experimento (nombre, area, grado, descripcion, ruta)
SELECT 'Horno solar', 'fisica', 7, 'Comprende como un horno solar utiliza la energía del sol para cocinar alimentos. Observa cómo los rayos solares se concentran en un punto y cómo se genera calor para cocinar de manera eficiente y sostenible.', 'horno.html'
WHERE NOT EXISTS (SELECT 1 FROM experimento WHERE ruta = 'horno.html');

INSERT INTO experimento (nombre, area, grado, descripcion, ruta)
SELECT 'Efecto invernadero', 'fisica', 7, 'Observa cómo los gases de efecto invernadero atrapan el calor en la atmósfera y cómo esto afecta la temperatura global. Aprende sobre el impacto del cambio climático y la importancia de reducir las emisiones de gases de efecto invernadero.', 'efecto.html'
WHERE NOT EXISTS (SELECT 1 FROM experimento WHERE ruta = 'efecto.html');

INSERT INTO experimento (nombre, area, grado, descripcion, ruta)
SELECT 'Corrosión de Hierro', 'quimica', 7, 'Observa cómo el hierro se oxida y se corroe cuando se expone al agua y al oxígeno. Aprende sobre los procesos químicos que ocurren durante la corrosión y cómo se pueden prevenir mediante recubrimientos protectores y aleaciones resistentes a la corrosión.', 'corrosion.html'
WHERE NOT EXISTS (SELECT 1 FROM experimento WHERE ruta = 'corrosion.html');

INSERT INTO experimento (nombre, area, grado, descripcion, ruta)
SELECT 'Obtención de Óxidos', 'quimica', 7, 'Observa cómo se forman los óxidos en diferentes condiciones y cómo se pueden identificar. Aprende sobre las propiedades de los óxidos y su importancia en la química y la industria.', 'oxidos.html'
WHERE NOT EXISTS (SELECT 1 FROM experimento WHERE ruta = 'oxidos.html');

INSERT INTO experimento (nombre, area, grado, descripcion, ruta)
SELECT 'Síntesis de Sales Binarias', 'quimica', 7, 'Observa como se forman las sales binarias a partir de la combinación de un metal y un no metal. Aprende sobre las propiedades de las sales binarias y su importancia en la química y la industria.', 'sintesis.html'
WHERE NOT EXISTS (SELECT 1 FROM experimento WHERE ruta = 'sintesis.html');

INSERT INTO experimento (nombre, area, grado, descripcion, ruta)
SELECT 'Extracción de ADN frutas', 'biologia', 7, 'Observa cómo se extrae el ADN de diferentes frutas y cómo se pueden identificar sus características.', 'estraccio.html'
WHERE NOT EXISTS (SELECT 1 FROM experimento WHERE ruta = 'estraccio.html');

INSERT INTO experimento (nombre, area, grado, descripcion, ruta)
SELECT 'Red Ecosistema', 'biologia', 7, 'Observa cómo los diferentes organismos de un ecosistema interactúan entre sí y cómo se relacionan con su entorno. Aprende sobre la importancia de la biodiversidad y cómo los cambios en el ecosistema pueden afectar a todas las especies que lo habitan.', 'red.html'
WHERE NOT EXISTS (SELECT 1 FROM experimento WHERE ruta = 'red.html');

INSERT INTO experimento (nombre, area, grado, descripcion, ruta)
SELECT 'Replicación de ADN', 'biologia', 7, 'Observa cómo los diferentes tejidos del cuerpo humano se organizan y funcionan juntos para mantener la vida. Aprende sobre la estructura y función de los tejidos y su importancia en la salud y el bienestar.', 'replicacion.html'
WHERE NOT EXISTS (SELECT 1 FROM experimento WHERE ruta = 'replicacion.html');

INSERT INTO experimento (nombre, area, grado, descripcion, ruta)
SELECT 'Presión y Nivel del Agua', 'fisica', 9, 'Explora cómo cambia la presión del agua dependiendo de la profundidad y observa sus efectos mediante una simulación 3D.', 'laboratorio1.html'
WHERE NOT EXISTS (SELECT 1 FROM experimento WHERE ruta = 'laboratorio1.html');

INSERT INTO experimento (nombre, area, grado, descripcion, ruta)
SELECT 'Jeringas Hidráulicas', 'fisica', 9, 'Comprende el Principio de Pascal y observa cómo la presión aplicada a un líquido puede transmitirse a través de un sistema hidráulico.', 'laboratorio2.html'
WHERE NOT EXISTS (SELECT 1 FROM experimento WHERE ruta = 'laboratorio2.html');

INSERT INTO experimento (nombre, area, grado, descripcion, ruta)
SELECT 'Cambios de Estado', 'fisica', 9, 'Observa cómo el agua cambia entre sólido, líquido y gas al modificar la temperatura cinético-molecular.', 'laboratorio3.html'
WHERE NOT EXISTS (SELECT 1 FROM experimento WHERE ruta = 'laboratorio3.html');

INSERT INTO experimento (nombre, area, grado, descripcion, ruta)
SELECT 'Genética y Herencia', 'biologia', 9, 'Explora cómo se transmiten las características genéticas realizando cruces y evaluando probabilidades de fenotipo.', 'laboratorio4.html'
WHERE NOT EXISTS (SELECT 1 FROM experimento WHERE ruta = 'laboratorio4.html');

INSERT INTO experimento (nombre, area, grado, descripcion, ruta)
SELECT 'Mitosis y División Celular', 'biologia', 9, 'Visualiza de manera interactiva las fases del ciclo celular (profase, metafase, anafase y telofase) en 3D.', 'laboratorio5.html'
WHERE NOT EXISTS (SELECT 1 FROM experimento WHERE ruta = 'laboratorio5.html');

INSERT INTO experimento (nombre, area, grado, descripcion, ruta)
SELECT 'Fotosíntesis y Cloroplastos', 'biologia', 9, 'Comprende cómo las plantas transforman la luz solar, agua y CO2 en glucosa y oxígeno a nivel molecular.', 'laboratorio6.html'
WHERE NOT EXISTS (SELECT 1 FROM experimento WHERE ruta = 'laboratorio6.html');

INSERT INTO experimento (nombre, area, grado, descripcion, ruta)
SELECT 'Estructura del ADN y ARN', 'biologia', 9, 'Explora la estructura de doble hélice del ADN, los pares de bases nitrogenadas y la transcripción genómica.', 'laboratorio7.html'
WHERE NOT EXISTS (SELECT 1 FROM experimento WHERE ruta = 'laboratorio7.html');

INSERT INTO experimento (nombre, area, grado, descripcion, ruta)
SELECT 'Modelo Atómico de Bohr 3D', 'quimica', 9, 'Explora la estructura atómica, órbitas cuantizadas de electrones y los niveles de energía de distintos elementos.', 'laboratorio8.html'
WHERE NOT EXISTS (SELECT 1 FROM experimento WHERE ruta = 'laboratorio8.html');

INSERT INTO experimento (nombre, area, grado, descripcion, ruta)
SELECT 'Reacciones y Enlaces', 'quimica', 9, 'Explora cómo interactúan los átomos para formar moléculas, observa el intercambio electrónico y la liberación energética.', 'laboratorio9.html'
WHERE NOT EXISTS (SELECT 1 FROM experimento WHERE ruta = 'laboratorio9.html');

INSERT INTO experimento (nombre, area, grado, descripcion, ruta)
SELECT 'Tabla Periódica e Isótopos', 'quimica', 9, 'Visualiza la estructura nuclear de distintos elementos, la distribución neutrónica y el comportamiento isotópico.', 'laboratorio10.html'
WHERE NOT EXISTS (SELECT 1 FROM experimento WHERE ruta = 'laboratorio10.html');

-- EVALUACIONES
INSERT INTO evaluacion (id_experimento, titulo, puntaje_maximo, activa)
SELECT ex.id_experimento, 'Evaluación - Generador Hidroeléctrico', 10, TRUE
FROM experimento ex WHERE ex.ruta = 'generador.html'
AND NOT EXISTS (SELECT 1 FROM evaluacion e WHERE e.id_experimento = ex.id_experimento);

INSERT INTO evaluacion (id_experimento, titulo, puntaje_maximo, activa)
SELECT ex.id_experimento, 'Evaluación - Horno solar', 10, TRUE
FROM experimento ex WHERE ex.ruta = 'horno.html'
AND NOT EXISTS (SELECT 1 FROM evaluacion e WHERE e.id_experimento = ex.id_experimento);

INSERT INTO evaluacion (id_experimento, titulo, puntaje_maximo, activa)
SELECT ex.id_experimento, 'Evaluación - Efecto invernadero', 10, TRUE
FROM experimento ex WHERE ex.ruta = 'efecto.html'
AND NOT EXISTS (SELECT 1 FROM evaluacion e WHERE e.id_experimento = ex.id_experimento);

INSERT INTO evaluacion (id_experimento, titulo, puntaje_maximo, activa)
SELECT ex.id_experimento, 'Evaluación - Corrosión de Hierro', 10, TRUE
FROM experimento ex WHERE ex.ruta = 'corrosion.html'
AND NOT EXISTS (SELECT 1 FROM evaluacion e WHERE e.id_experimento = ex.id_experimento);

INSERT INTO evaluacion (id_experimento, titulo, puntaje_maximo, activa)
SELECT ex.id_experimento, 'Evaluación - Obtención de Óxidos', 10, TRUE
FROM experimento ex WHERE ex.ruta = 'oxidos.html'
AND NOT EXISTS (SELECT 1 FROM evaluacion e WHERE e.id_experimento = ex.id_experimento);

INSERT INTO evaluacion (id_experimento, titulo, puntaje_maximo, activa)
SELECT ex.id_experimento, 'Evaluación - Síntesis de Sales Binarias', 10, TRUE
FROM experimento ex WHERE ex.ruta = 'sintesis.html'
AND NOT EXISTS (SELECT 1 FROM evaluacion e WHERE e.id_experimento = ex.id_experimento);

INSERT INTO evaluacion (id_experimento, titulo, puntaje_maximo, activa)
SELECT ex.id_experimento, 'Evaluación - Extracción de ADN frutas', 10, TRUE
FROM experimento ex WHERE ex.ruta = 'estraccio.html'
AND NOT EXISTS (SELECT 1 FROM evaluacion e WHERE e.id_experimento = ex.id_experimento);

INSERT INTO evaluacion (id_experimento, titulo, puntaje_maximo, activa)
SELECT ex.id_experimento, 'Evaluación - Red Ecosistema', 10, TRUE
FROM experimento ex WHERE ex.ruta = 'red.html'
AND NOT EXISTS (SELECT 1 FROM evaluacion e WHERE e.id_experimento = ex.id_experimento);

INSERT INTO evaluacion (id_experimento, titulo, puntaje_maximo, activa)
SELECT ex.id_experimento, 'Evaluación - Replicación de ADN', 10, TRUE
FROM experimento ex WHERE ex.ruta = 'replicacion.html'
AND NOT EXISTS (SELECT 1 FROM evaluacion e WHERE e.id_experimento = ex.id_experimento);

INSERT INTO evaluacion (id_experimento, titulo, puntaje_maximo, activa)
SELECT ex.id_experimento, 'Evaluación - Presión y Nivel del Agua', 10, TRUE
FROM experimento ex WHERE ex.ruta = 'laboratorio1.html'
AND NOT EXISTS (SELECT 1 FROM evaluacion e WHERE e.id_experimento = ex.id_experimento);

INSERT INTO evaluacion (id_experimento, titulo, puntaje_maximo, activa)
SELECT ex.id_experimento, 'Evaluación - Jeringas Hidráulicas', 10, TRUE
FROM experimento ex WHERE ex.ruta = 'laboratorio2.html'
AND NOT EXISTS (SELECT 1 FROM evaluacion e WHERE e.id_experimento = ex.id_experimento);

INSERT INTO evaluacion (id_experimento, titulo, puntaje_maximo, activa)
SELECT ex.id_experimento, 'Evaluación - Cambios de Estado', 10, TRUE
FROM experimento ex WHERE ex.ruta = 'laboratorio3.html'
AND NOT EXISTS (SELECT 1 FROM evaluacion e WHERE e.id_experimento = ex.id_experimento);

INSERT INTO evaluacion (id_experimento, titulo, puntaje_maximo, activa)
SELECT ex.id_experimento, 'Evaluación - Genética y Herencia', 10, TRUE
FROM experimento ex WHERE ex.ruta = 'laboratorio4.html'
AND NOT EXISTS (SELECT 1 FROM evaluacion e WHERE e.id_experimento = ex.id_experimento);

INSERT INTO evaluacion (id_experimento, titulo, puntaje_maximo, activa)
SELECT ex.id_experimento, 'Evaluación - Mitosis y División Celular', 10, TRUE
FROM experimento ex WHERE ex.ruta = 'laboratorio5.html'
AND NOT EXISTS (SELECT 1 FROM evaluacion e WHERE e.id_experimento = ex.id_experimento);

INSERT INTO evaluacion (id_experimento, titulo, puntaje_maximo, activa)
SELECT ex.id_experimento, 'Evaluación - Fotosíntesis y Cloroplastos', 10, TRUE
FROM experimento ex WHERE ex.ruta = 'laboratorio6.html'
AND NOT EXISTS (SELECT 1 FROM evaluacion e WHERE e.id_experimento = ex.id_experimento);

INSERT INTO evaluacion (id_experimento, titulo, puntaje_maximo, activa)
SELECT ex.id_experimento, 'Evaluación - Estructura del ADN y ARN', 10, TRUE
FROM experimento ex WHERE ex.ruta = 'laboratorio7.html'
AND NOT EXISTS (SELECT 1 FROM evaluacion e WHERE e.id_experimento = ex.id_experimento);

INSERT INTO evaluacion (id_experimento, titulo, puntaje_maximo, activa)
SELECT ex.id_experimento, 'Evaluación - Modelo Atómico de Bohr 3D', 10, TRUE
FROM experimento ex WHERE ex.ruta = 'laboratorio8.html'
AND NOT EXISTS (SELECT 1 FROM evaluacion e WHERE e.id_experimento = ex.id_experimento);

INSERT INTO evaluacion (id_experimento, titulo, puntaje_maximo, activa)
SELECT ex.id_experimento, 'Evaluación - Reacciones y Enlaces', 10, TRUE
FROM experimento ex WHERE ex.ruta = 'laboratorio9.html'
AND NOT EXISTS (SELECT 1 FROM evaluacion e WHERE e.id_experimento = ex.id_experimento);

INSERT INTO evaluacion (id_experimento, titulo, puntaje_maximo, activa)
SELECT ex.id_experimento, 'Evaluación - Tabla Periódica e Isótopos', 10, TRUE
FROM experimento ex WHERE ex.ruta = 'laboratorio10.html'
AND NOT EXISTS (SELECT 1 FROM evaluacion e WHERE e.id_experimento = ex.id_experimento);

-- PREGUNTAS Y OPCIONES
-- 7.º | FISICA | Generador Hidroeléctrico
INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Cuál es la principal fuente de energía utilizada por el generador hidroeléctrico?', 2, 1
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'generador.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=1);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Electricidad', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='generador.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Electricidad');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Energía hidráulica (Agua)', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='generador.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Energía hidráulica (Agua)');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Gas', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='generador.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Gas');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Carbón', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='generador.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Carbón');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué función cumple la hélice en el sistema?', 2, 2
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'generador.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=2);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Transformar el flujo de agua en movimiento rotatorio', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='generador.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Transformar el flujo de agua en movimiento rotatorio');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Filtrar el agua', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='generador.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Filtrar el agua');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Almacenar la energía eléctrica', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='generador.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Almacenar la energía eléctrica');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Encender el LED directamente', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='generador.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Encender el LED directamente');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué dispositivo convierte la energía mecánica en energía eléctrica?', 2, 3
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'generador.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=3);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'El conducto', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='generador.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='El conducto');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'La botella', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='generador.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='La botella');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'El motor de 12 V', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='generador.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='El motor de 12 V');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'La base de cartón', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='generador.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='La base de cartón');

-- 7.º | FISICA | Horno solar
INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Cuál es la principal fuente de energía del horno solar?', 2, 1
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'horno.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=1);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'El agua', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='horno.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='El agua');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'El Sol', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='horno.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='El Sol');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'El cartón', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='horno.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='El cartón');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'El viento', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='horno.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='El viento');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Para qué se utiliza el papel aluminio dentro del horno?', 2, 2
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'horno.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=2);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Para absorber agua', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='horno.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Para absorber agua');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Para enfriar el alimento', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='horno.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Para enfriar el alimento');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Para reflejar la radiación solar', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='horno.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Para reflejar la radiación solar');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Para decorar la caja', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='horno.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Para decorar la caja');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué función cumple el plástico transparente?', 2, 3
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'horno.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=3);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Permite entrar la luz y ayuda a conservar el calor', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='horno.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Permite entrar la luz y ayuda a conservar el calor');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Bloquea toda la luz', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='horno.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Bloquea toda la luz');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Enfría el horno', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='horno.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Enfría el horno');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Produce electricidad', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='horno.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Produce electricidad');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué sucede con la temperatura dentro del horno cuando recibe radiación solar?', 2, 4
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'horno.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=4);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Disminuye', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='horno.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Disminuye');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Aumenta', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='horno.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Aumenta');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Permanece siempre igual', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='horno.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Permanece siempre igual');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Se convierte en agua', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='horno.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Se convierte en agua');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué condición permite que el horno solar funcione mejor?', 2, 5
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'horno.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=5);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Un día soleado', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='horno.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Un día soleado');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Una noche oscura', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='horno.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Una noche oscura');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Una tormenta fuerte', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='horno.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Una tormenta fuerte');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Un lugar sin luz', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='horno.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Un lugar sin luz');

-- 7.º | FISICA | Efecto invernadero
INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué contiene el recipiente A?', 2, 1
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'efecto.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=1);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Agua', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='efecto.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Agua');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Suelo', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='efecto.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Suelo');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Bebida carbonatada', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='efecto.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Bebida carbonatada');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Nada', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='efecto.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Nada');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué contiene el recipiente B?', 2, 2
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'efecto.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=2);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Agua', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='efecto.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Agua');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Bebida carbonatada', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='efecto.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Bebida carbonatada');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Suelo', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='efecto.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Suelo');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Solamente aire', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='efecto.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Solamente aire');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Por qué se utiliza un recipiente de control?', 2, 3
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'efecto.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=3);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Para comparar los cambios de temperatura', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='efecto.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Para comparar los cambios de temperatura');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Para aumentar la temperatura', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='efecto.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Para aumentar la temperatura');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Para contener agua', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='efecto.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Para contener agua');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Para producir luz', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='efecto.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Para producir luz');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué instrumento permite medir la temperatura?', 2, 4
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'efecto.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=4);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'El marcador', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='efecto.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='El marcador');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'La cinta adhesiva', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='efecto.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='La cinta adhesiva');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'El termómetro', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='efecto.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='El termómetro');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'La tapadera', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='efecto.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='La tapadera');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué se puede observar al exponer los recipientes al Sol?', 2, 5
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'efecto.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=5);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Un aumento de temperatura', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='efecto.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Un aumento de temperatura');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Una disminución inmediata de temperatura', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='efecto.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Una disminución inmediata de temperatura');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Que los termómetros dejan de funcionar', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='efecto.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Que los termómetros dejan de funcionar');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Que desaparece el Sol', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='efecto.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Que desaparece el Sol');

-- 7.º | QUIMICA | Corrosión de Hierro
INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué proceso ocurre en el hierro durante este experimento?', 2, 1
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'corrosion.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=1);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Evaporación', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='corrosion.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Evaporación');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Corrosión', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='corrosion.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Corrosión');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Fusión', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='corrosion.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Fusión');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Congelación', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='corrosion.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Congelación');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué se agrega al agua para preparar la solución?', 2, 2
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'corrosion.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=2);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Azúcar', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='corrosion.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Azúcar');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Arena', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='corrosion.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Arena');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Sal', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='corrosion.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Sal');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Aceite', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='corrosion.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Aceite');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué fuente de energía se utiliza en el experimento?', 2, 3
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'corrosion.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=3);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Una pila de 9 V', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='corrosion.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Una pila de 9 V');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Una vela', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='corrosion.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Una vela');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'El Sol', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='corrosion.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='El Sol');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Un motor', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='corrosion.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Un motor');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué aspecto puede presentar el hierro después de corroerse?', 2, 4
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'corrosion.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=4);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Una capa transparente', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='corrosion.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Una capa transparente');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Una capa rojiza o marrón', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='corrosion.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Una capa rojiza o marrón');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Una capa azul brillante', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='corrosion.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Una capa azul brillante');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Se convierte en plástico', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='corrosion.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Se convierte en plástico');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué factores favorecen la corrosión del hierro?', 2, 5
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'corrosion.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=5);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Agua, oxígeno y una solución conductora', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='corrosion.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Agua, oxígeno y una solución conductora');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Únicamente la luz', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='corrosion.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Únicamente la luz');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Solo el aire seco', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='corrosion.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Solo el aire seco');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Únicamente el calor', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='corrosion.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Únicamente el calor');

-- 7.º | QUIMICA | Obtención de Óxidos
INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué sustancia se obtiene al quemar la cinta de magnesio?', 2, 1
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'oxidos.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=1);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Óxido de magnesio (MgO)', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='oxidos.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Óxido de magnesio (MgO)');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Ácido clorhídrico', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='oxidos.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Ácido clorhídrico');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Cloruro de magnesio', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='oxidos.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Cloruro de magnesio');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Ácido carbónico', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='oxidos.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Ácido carbónico');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué tipo de óxido se obtiene al quemar el magnesio?', 2, 2
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'oxidos.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=2);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Óxido metálico', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='oxidos.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Óxido metálico');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Óxido no metálico', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='oxidos.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Óxido no metálico');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Ácido', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='oxidos.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Ácido');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Sal', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='oxidos.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Sal');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué producto se forma cuando el MgO reacciona con agua?', 2, 3
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'oxidos.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=3);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'CO₂', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='oxidos.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='CO₂');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Mg(OH)₂', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='oxidos.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Mg(OH)₂');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'O₂', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='oxidos.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='O₂');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'HCl', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='oxidos.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='HCl');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué ocurre cuando se introduce CO₂ en el agua con indicador?', 2, 4
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'oxidos.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=4);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Se forma ácido carbónico y cambia el indicador', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='oxidos.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Se forma ácido carbónico y cambia el indicador');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Se forma oxígeno', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='oxidos.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Se forma oxígeno');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'El agua desaparece', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='oxidos.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='El agua desaparece');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Se forma MgO', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='oxidos.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Se forma MgO');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Cuál es la reacción que representa la formación de ácido carbónico?', 2, 5
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'oxidos.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=5);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'CO₂ + H₂O → H₂CO₃', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='oxidos.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='CO₂ + H₂O → H₂CO₃');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Mg + O₂ → MgO', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='oxidos.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Mg + O₂ → MgO');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'MgO + H₂O → Mg(OH)₂', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='oxidos.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='MgO + H₂O → Mg(OH)₂');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'H₂ + O₂ → H₂O', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='oxidos.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='H₂ + O₂ → H₂O');

-- 7.º | QUIMICA | Síntesis de Sales Binarias
INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué sustancia se agregó primero a los tubos de ensayo?', 2, 1
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'sintesis.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=1);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Agua', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='sintesis.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Agua');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Ácido clorhídrico (HCl)', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='sintesis.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Ácido clorhídrico (HCl)');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Oxígeno', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='sintesis.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Oxígeno');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Cloruro de sodio', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='sintesis.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Cloruro de sodio');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué ocurre cuando el zinc reacciona con el HCl?', 2, 2
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'sintesis.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=2);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Se forma ZnCl₂ y se libera H₂', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='sintesis.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Se forma ZnCl₂ y se libera H₂');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'No ocurre ninguna reacción', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='sintesis.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='No ocurre ninguna reacción');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Se forma agua únicamente', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='sintesis.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Se forma agua únicamente');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'El zinc desaparece sin producir sustancias', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='sintesis.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='El zinc desaparece sin producir sustancias');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué gas se libera durante la reacción?', 2, 3
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'sintesis.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=3);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Oxígeno', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='sintesis.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Oxígeno');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Nitrógeno', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='sintesis.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Nitrógeno');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Hidrógeno', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='sintesis.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Hidrógeno');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Dióxido de carbono', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='sintesis.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Dióxido de carbono');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué tipo de reacción representa esta actividad?', 2, 4
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'sintesis.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=4);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Combustión', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='sintesis.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Combustión');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Desplazamiento simple', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='sintesis.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Desplazamiento simple');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Neutralización', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='sintesis.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Neutralización');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Descomposición', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='sintesis.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Descomposición');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Cuál es uno de los productos de la reacción entre el zinc y el HCl?', 2, 5
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'sintesis.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=5);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'ZnCl₂', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='sintesis.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='ZnCl₂');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'O₂', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='sintesis.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='O₂');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'H₂O₂', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='sintesis.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='H₂O₂');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'NaCl', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='sintesis.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='NaCl');

-- 7.º | BIOLOGIA | Extracción de ADN frutas
INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Por qué se enfría el alcohol antes de utilizarlo?', 2, 1
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'estraccio.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=1);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Para que cambie de color', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='estraccio.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Para que cambie de color');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Para favorecer la precipitación del ADN', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='estraccio.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Para favorecer la precipitación del ADN');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Para destruir el ADN', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='estraccio.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Para destruir el ADN');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Para calentar la muestra', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='estraccio.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Para calentar la muestra');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué función cumple principalmente el jabón líquido?', 2, 2
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'estraccio.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=2);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Colorear el ADN', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='estraccio.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Colorear el ADN');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Romper las membranas celulares', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='estraccio.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Romper las membranas celulares');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Enfriar la fruta', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='estraccio.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Enfriar la fruta');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Evaporar el agua', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='estraccio.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Evaporar el agua');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Para qué se macera la fruta?', 2, 3
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'estraccio.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=3);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Para romper las células y liberar su contenido', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='estraccio.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Para romper las células y liberar su contenido');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Para congelarla', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='estraccio.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Para congelarla');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Para cambiar su ADN', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='estraccio.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Para cambiar su ADN');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Para eliminar toda el agua', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='estraccio.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Para eliminar toda el agua');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué se observa cuando el ADN precipita?', 2, 4
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'estraccio.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=4);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Una llama', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='estraccio.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Una llama');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Grumos o material blanquecino', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='estraccio.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Grumos o material blanquecino');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Un gas azul', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='estraccio.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Un gas azul');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Una capa de aceite', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='estraccio.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Una capa de aceite');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué función cumple el azul de metileno en la simulación?', 2, 5
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'estraccio.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=5);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Ayuda a observar mejor los grumos de ADN', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='estraccio.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Ayuda a observar mejor los grumos de ADN');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Destruye las células', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='estraccio.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Destruye las células');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Enfría el alcohol', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='estraccio.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Enfría el alcohol');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Convierte la fruta en líquido', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='estraccio.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Convierte la fruta en líquido');

-- 7.º | BIOLOGIA | Red Ecosistema
INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué representa la lana en el experimento?', 2, 1
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'red.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=1);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'El clima', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='red.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='El clima');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Las relaciones entre los componentes', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='red.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Las relaciones entre los componentes');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Únicamente a los animales', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='red.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Únicamente a los animales');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'La temperatura', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='red.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='La temperatura');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Cuál de los siguientes es un elemento no vivo?', 2, 2
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'red.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=2);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Colibrí', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='red.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Colibrí');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Árbol', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='red.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Árbol');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Sol', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='red.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Sol');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Flor', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='red.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Flor');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Por qué el árbol está relacionado con el suelo?', 2, 3
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'red.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=3);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Obtiene nutrientes y soporte', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='red.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Obtiene nutrientes y soporte');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'El suelo puede volar', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='red.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='El suelo puede volar');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'El árbol crea el suelo', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='red.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='El árbol crea el suelo');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'No tienen relación', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='red.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='No tienen relación');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué relación existe entre la flor y el colibrí?', 2, 4
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'red.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=4);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'El colibrí obtiene alimento y ayuda a polinizar', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='red.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='El colibrí obtiene alimento y ayuda a polinizar');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'No existe relación', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='red.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='No existe relación');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'La flor persigue al colibrí', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='red.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='La flor persigue al colibrí');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'El colibrí produce el Sol', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='red.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='El colibrí produce el Sol');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué demuestra la red de interacciones?', 2, 5
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'red.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=5);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Que todos viven aislados', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='red.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Que todos viven aislados');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Que los componentes del ecosistema se relacionan', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='red.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Que los componentes del ecosistema se relacionan');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Que solo importan los animales', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='red.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Que solo importan los animales');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Que el suelo no es importante', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='red.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Que el suelo no es importante');

-- 7.º | BIOLOGIA | Replicación de ADN
INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué base nitrogenada se une de forma complementaria con la Adenina (A)?', 2, 1
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'replicacion.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=1);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Citosina (C)', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='replicacion.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Citosina (C)');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Timina (T)', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='replicacion.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Timina (T)');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Guanina (G)', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='replicacion.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Guanina (G)');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Uracilo (U)', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='replicacion.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Uracilo (U)');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué enzima se encarga de sintetizar las nuevas cadenas de ADN incorporando los nucleótidos?', 2, 2
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'replicacion.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=2);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Ligasa', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='replicacion.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Ligasa');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Helicasa', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='replicacion.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Helicasa');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'ADN Polimerasa', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='replicacion.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='ADN Polimerasa');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'ARN Primasa', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='replicacion.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='ARN Primasa');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Cuál es la función principal de la enzima Ligasa en el proceso?', 2, 3
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'replicacion.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=3);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Separar las dos cadenas de ADN', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='replicacion.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Separar las dos cadenas de ADN');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Unir los fragmentos de la nueva cadena de ADN', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='replicacion.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Unir los fragmentos de la nueva cadena de ADN');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Marcar el sitio de inicio con un cebador', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='replicacion.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Marcar el sitio de inicio con un cebador');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Leer la secuencia original', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='replicacion.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Leer la secuencia original');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué función cumple el cebador en la replicación?', 2, 4
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'replicacion.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=4);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Indicar el punto de inicio para la construcción de la nueva cadena', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='replicacion.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Indicar el punto de inicio para la construcción de la nueva cadena');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Unir las bases nitrogenadas mediante puentes de hidrógeno', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='replicacion.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Unir las bases nitrogenadas mediante puentes de hidrógeno');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Destruir las hebras defectuosas', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='replicacion.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Destruir las hebras defectuosas');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Cerrar la horquilla de replicación', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='replicacion.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Cerrar la horquilla de replicación');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, 'Al finalizar la replicación, ¿cómo se componen las dos nuevas moléculas resultantes?', 2, 5
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'replicacion.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=5);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Dos hebras totalmente nuevas cada una', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='replicacion.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Dos hebras totalmente nuevas cada una');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Una hebra original y una hebra nueva en cada molécula', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='replicacion.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Una hebra original y una hebra nueva en cada molécula');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Una molécula con hebras viejas y otra con hebras nuevas', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='replicacion.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Una molécula con hebras viejas y otra con hebras nuevas');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Cuatro hebras individuales separadas', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='replicacion.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Cuatro hebras individuales separadas');

-- 9.º | FISICA | Presión y Nivel del Agua
INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué sucede con la presión hidrostática a medida que aumenta la profundidad del sensor?', 2, 1
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio1.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=1);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Disminuye de forma lineal.', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio1.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Disminuye de forma lineal.');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Aumenta proporcionalmente a la profundidad.', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio1.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Aumenta proporcionalmente a la profundidad.');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Se mantiene constante en todo el prisma.', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio1.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Se mantiene constante en todo el prisma.');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, 'Si el sensor está en la superficie del agua (h = 0.0 m), ¿cuál es la presión registrada?', 2, 2
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio1.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=2);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, '0.0 kPa', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio1.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='0.0 kPa');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Presión atmosférica (~101.3 kPa)', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio1.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Presión atmosférica (~101.3 kPa)');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, '9.81 kPa', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio1.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='9.81 kPa');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué término de la fórmula P = Patm+ ρ·g·h representa la densidad del fluido?', 2, 3
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio1.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=3);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'g', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio1.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='g');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'h', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio1.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='h');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'ρ (rho)', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio1.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='ρ (rho)');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, 'Si usamos un líquido más denso que el agua a la misma profundidad, ¿qué pasa con la presión?', 2, 4
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio1.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=4);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'La presión será mayor.', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio1.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='La presión será mayor.');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'La presión disminuirá.', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio1.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='La presión disminuirá.');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Permanecerá invariable.', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio1.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Permanecerá invariable.');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Cuál es la unidad de medida en la que el panel reporta la presión total?', 2, 5
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio1.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=5);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Newtons (N)', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio1.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Newtons (N)');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Kilopascales (kPa)', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio1.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Kilopascales (kPa)');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Densidad relativa', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio1.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Densidad relativa');

-- 9.º | FISICA | Jeringas Hidráulicas
INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué establece el Principio de Pascal en fluidos incompresibles?', 2, 1
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio2.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=1);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'La presión se transmite íntegramente en todas direcciones.', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio2.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='La presión se transmite íntegramente en todas direcciones.');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'La presión se pierde progresivamente con la distancia.', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio2.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='La presión se pierde progresivamente con la distancia.');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'La presión aumenta solo en la superficie del líquido.', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio2.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='La presión aumenta solo en la superficie del líquido.');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, 'Si disminuimos el área del émbolo de entrada manteniendo la fuerza constante, ¿qué ocurre con la presión?', 2, 2
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio2.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=2);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Aumenta proporcionalmente (P = F / A).', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio2.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Aumenta proporcionalmente (P = F / A).');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Disminuye proporcionalmente.', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio2.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Disminuye proporcionalmente.');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Permanece exactamente igual.', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio2.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Permanece exactamente igual.');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Por qué se prefiere un fluido líquido sobre un gas en un sistema hidráulico?', 2, 3
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio2.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=3);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Porque el líquido es incompresible y transmite la fuerza eficientemente.', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio2.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Porque el líquido es incompresible y transmite la fuerza eficientemente.');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Porque los gases pesan demasiado dentro de las mangueras.', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio2.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Porque los gases pesan demasiado dentro de las mangueras.');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Porque el aire se congela bajo presión constante.', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio2.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Porque el aire se congela bajo presión constante.');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, 'En una prensa hidráulica, si el área de la salida es el triple de la entrada, la fuerza de salida será:', 2, 4
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio2.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=4);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'El triple de la fuerza aplicada.', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio2.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='El triple de la fuerza aplicada.');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Un tercio de la fuerza aplicada.', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio2.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Un tercio de la fuerza aplicada.');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Exactamente igual a la fuerza inicial.', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio2.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Exactamente igual a la fuerza inicial.');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Cuál es la unidad de medida de la presión en el Sistema Internacional (SI)?', 2, 5
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio2.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=5);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Pascal (Pa) o N/m²', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio2.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Pascal (Pa) o N/m²');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Joule (J)', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio2.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Joule (J)');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Newton (N)', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio2.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Newton (N)');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué ocurre con el volumen de un líquido incompresible al aplicarle presión?', 2, 6
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio2.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=6);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Se mantiene constante.', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio2.html' AND p.numero=6
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Se mantiene constante.');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Se reduce significativamente.', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio2.html' AND p.numero=6
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Se reduce significativamente.');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Aumenta proporcionalmente a la fuerza.', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio2.html' AND p.numero=6
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Aumenta proporcionalmente a la fuerza.');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Cómo se define la fórmula matemática de la presión?', 2, 7
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio2.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=7);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'P = Fuerza / Área', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio2.html' AND p.numero=7
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='P = Fuerza / Área');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'P = Fuerza × Área', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio2.html' AND p.numero=7
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='P = Fuerza × Área');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'P = Área / Fuerza', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio2.html' AND p.numero=7
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='P = Área / Fuerza');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué dispositivo de la vida real utiliza principalmente el Principio de Pascal?', 2, 8
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio2.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=8);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Frenos hidráulicos de un automóvil.', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio2.html' AND p.numero=8
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Frenos hidráulicos de un automóvil.');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Un motor de combustión interna.', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio2.html' AND p.numero=8
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Un motor de combustión interna.');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Un termómetro de mercurio.', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio2.html' AND p.numero=8
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Un termómetro de mercurio.');

-- 9.º | FISICA | Cambios de Estado
INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿A qué temperatura se produce el punto de ebullición del agua a nivel del mar?', 2, 1
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio3.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=1);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, '0 °C', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio3.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='0 °C');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, '50 °C', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio3.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='50 °C');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, '100 °C', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio3.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='100 °C');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, '150 °C', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio3.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='150 °C');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué cambio de estado ocurre cuando el agua pasa de Líquido a Sólido?', 2, 2
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio3.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=2);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Fusión', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio3.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Fusión');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Solidificación', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio3.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Solidificación');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Evaporación', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio3.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Evaporación');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Sublimación', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio3.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Sublimación');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, 'Si la temperatura está en -15 °C, ¿en qué estado se encuentra el agua?', 2, 3
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio3.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=3);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Líquido', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio3.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Líquido');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Gas', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio3.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Gas');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Plasma', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio3.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Plasma');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Sólido', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio3.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Sólido');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Cómo se llama el cambio de Sólido a Líquido al aumentar el calor?', 2, 4
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio3.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=4);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Fusión', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio3.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Fusión');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Condensación', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio3.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Condensación');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Ebullición', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio3.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Ebullición');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Congelación', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio3.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Congelación');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué sucede con la energía cinética de las moléculas al aumentar la temperatura?', 2, 5
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio3.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=5);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Disminuye', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio3.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Disminuye');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Se mantiene igual', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio3.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Se mantiene igual');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Aumenta', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio3.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Aumenta');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Desaparece', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio3.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Desaparece');

-- 9.º | BIOLOGIA | Genética y Herencia
INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué representa un genotipo homocigoto dominante?', 2, 1
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio4.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=1);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Dos alelos dominantes iguales (AA)', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio4.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Dos alelos dominantes iguales (AA)');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Dos alelos recesivos iguales (aa)', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio4.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Dos alelos recesivos iguales (aa)');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Un alelo dominante y uno recesivo (Aa)', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio4.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Un alelo dominante y uno recesivo (Aa)');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, 'Si cruzamos dos heterocigotos (Aa x Aa), ¿cuál es la probabilidad de obtener fenotipo recesivo?', 2, 2
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio4.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=2);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, '25%', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio4.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='25%');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, '50%', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio4.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='50%');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, '75%', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio4.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='75%');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué es el fenotipo de un organismo?', 2, 3
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio4.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=3);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Las características físicas observables', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio4.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Las características físicas observables');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'El conjunto exacto de genes', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio4.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='El conjunto exacto de genes');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'La cantidad total de ADN cromosómico', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio4.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='La cantidad total de ADN cromosómico');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Cómo se conoce también a la Primera Ley de Mendel?', 2, 4
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio4.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=4);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Principio de la Uniformidad', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio4.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Principio de la Uniformidad');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Ley de Segregación Independiente', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio4.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Ley de Segregación Independiente');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Herencia Ligada al Sexo', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio4.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Herencia Ligada al Sexo');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué genotipo se requiere para expresar visualmente un rasgo recesivo?', 2, 5
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio4.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=5);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Homocigoto recesivo (aa)', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio4.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Homocigoto recesivo (aa)');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Heterocigoto (Aa)', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio4.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Heterocigoto (Aa)');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Homocigoto dominante (AA)', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio4.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Homocigoto dominante (AA)');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Cuál es la proporción genotípica esperada del cruce Aa x Aa?', 2, 6
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio4.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=6);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, '1 AA : 2 Aa : 1 aa', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio4.html' AND p.numero=6
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='1 AA : 2 Aa : 1 aa');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, '3 AA : 1 aa', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio4.html' AND p.numero=6
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='3 AA : 1 aa');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, '2 Aa : 2 aa', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio4.html' AND p.numero=6
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='2 Aa : 2 aa');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué es un alelo?', 2, 7
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio4.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=7);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Una variante alternativa de un mismo gen', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio4.html' AND p.numero=7
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Una variante alternativa de un mismo gen');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Una proteína celular', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio4.html' AND p.numero=7
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Una proteína celular');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Un tipo de célula reproductora', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio4.html' AND p.numero=7
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Un tipo de célula reproductora');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, 'Si cruzamos AA x aa, ¿qué porcentaje de descendientes será heterocigoto (Aa)?', 2, 8
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio4.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=8);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, '100%', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio4.html' AND p.numero=8
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='100%');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, '50%', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio4.html' AND p.numero=8
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='50%');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, '25%', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio4.html' AND p.numero=8
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='25%');

-- 9.º | BIOLOGIA | Mitosis y División Celular
INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué enzima es la encargada de romper los puentes de hidrógeno para separar las hebras de ADN?', 2, 1
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio5.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=1);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'ADN Polimerasa', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio5.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='ADN Polimerasa');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Helicasa', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio5.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Helicasa');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'ARN Primasa', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio5.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='ARN Primasa');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Ligasa', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio5.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Ligasa');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, 'Según la regla de complementariedad, ¿con qué base se aparea la Adenina (A) en el ADN?', 2, 2
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio5.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=2);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Guanina (G)', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio5.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Guanina (G)');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Citosina (C)', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio5.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Citosina (C)');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Timina (T)', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio5.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Timina (T)');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Uracilo (U)', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio5.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Uracilo (U)');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Cuántos puentes de hidrógeno unen al par Citosina - Guanina (C-G)?', 2, 3
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio5.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=3);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, '1 puente', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio5.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='1 puente');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, '2 puentes', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio5.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='2 puentes');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, '3 puentes', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio5.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='3 puentes');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, '4 puentes', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio5.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='4 puentes');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué estructura constituye el esqueleto exterior de la molécula de ADN?', 2, 4
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio5.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=4);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Bases nitrogenadas y aminoácidos', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio5.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Bases nitrogenadas y aminoácidos');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Grupo fosfato y desoxirribosa', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio5.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Grupo fosfato y desoxirribosa');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Proteínas histonas', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio5.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Proteínas histonas');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Enlaces peptídicos', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio5.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Enlaces peptídicos');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué término describe el hecho de que las dos hebras del ADN corren en direcciones opuestas?', 2, 5
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio5.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=5);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Paralelas', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio5.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Paralelas');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Antiparalelas', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio5.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Antiparalelas');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Semiconservativas', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio5.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Semiconservativas');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Simétricas', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio5.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Simétricas');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué tipo de enlace une a las bases nitrogenadas entre sí en el centro de la hélice?', 2, 6
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio5.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=6);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Enlaces covalentes', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio5.html' AND p.numero=6
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Enlaces covalentes');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Puentes de hidrógeno', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio5.html' AND p.numero=6
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Puentes de hidrógeno');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Enlaces iónicos', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio5.html' AND p.numero=6
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Enlaces iónicos');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Puentes disulfuro', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio5.html' AND p.numero=6
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Puentes disulfuro');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, 'En el modelo 3D visualizado, ¿qué representan las esferas grises del esqueleto externo?', 2, 7
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio5.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=7);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Bases nitrogenadas', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio5.html' AND p.numero=7
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Bases nitrogenadas');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Nodos de Fosfato / Desoxirribosa', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio5.html' AND p.numero=7
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Nodos de Fosfato / Desoxirribosa');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Enzimas Helicasas', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio5.html' AND p.numero=7
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Enzimas Helicasas');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Moléculas de agua', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio5.html' AND p.numero=7
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Moléculas de agua');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, 'Si la hebra de ADN se separa al 100% durante el experimento, ¿qué proceso biológico inicia?', 2, 8
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio5.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=8);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Traducción proteica', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio5.html' AND p.numero=8
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Traducción proteica');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Replicación del ADN', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio5.html' AND p.numero=8
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Replicación del ADN');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Síntesis de lípidos', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio5.html' AND p.numero=8
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Síntesis de lípidos');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Glucólisis', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio5.html' AND p.numero=8
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Glucólisis');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Con cuál base se aparea la Guanina (G)?', 2, 9
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio5.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=9);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Adenina (A)', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio5.html' AND p.numero=9
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Adenina (A)');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Timina (T)', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio5.html' AND p.numero=9
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Timina (T)');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Citosina (C)', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio5.html' AND p.numero=9
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Citosina (C)');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Uracilo (U)', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio5.html' AND p.numero=9
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Uracilo (U)');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Cuál es la forma geométrica característica de la molécula de ADN?', 2, 10
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio5.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=10);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Hélice simple', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio5.html' AND p.numero=10
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Hélice simple');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Doble hélice', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio5.html' AND p.numero=10
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Doble hélice');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Anillo plano', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio5.html' AND p.numero=10
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Anillo plano');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Cadena lineal plegada', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio5.html' AND p.numero=10
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Cadena lineal plegada');

-- 9.º | BIOLOGIA | Fotosíntesis y Cloroplastos
INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué es la ósmosis?', 2, 1
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio6.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=1);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'El movimiento de proteínas dentro de la célula', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio6.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='El movimiento de proteínas dentro de la célula');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'El movimiento de agua a través de una membrana semipermeable', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio6.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='El movimiento de agua a través de una membrana semipermeable');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'La producción de energía en la célula', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio6.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='La producción de energía en la célula');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'La división celular', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio6.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='La división celular');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué ocurre con un eritrocito en un medio hipotónico?', 2, 2
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio6.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=2);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Pierde agua y se encoge', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio6.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Pierde agua y se encoge');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'No ocurre ningún cambio', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio6.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='No ocurre ningún cambio');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Entra agua y puede producirse citólisis', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio6.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Entra agua y puede producirse citólisis');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Se convierte en una célula vegetal', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio6.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Se convierte en una célula vegetal');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué característica permite a la célula vegetal resistir la entrada excesiva de agua?', 2, 3
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio6.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=3);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'La pared celular', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio6.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='La pared celular');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'El núcleo', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio6.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='El núcleo');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'El citoplasma', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio6.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='El citoplasma');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Los ribosomas', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio6.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Los ribosomas');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué ocurre cuando una célula se encuentra en un medio hipertónico?', 2, 4
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio6.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=4);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'El agua tiende a salir de la célula', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio6.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='El agua tiende a salir de la célula');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'El agua siempre entra a la célula', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio6.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='El agua siempre entra a la célula');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'La célula produce más oxígeno', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio6.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='La célula produce más oxígeno');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'La célula deja de tener membrana', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio6.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='La célula deja de tener membrana');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué fenómeno ocurre en una célula vegetal colocada en un medio hipertónico?', 2, 5
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio6.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=5);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Turgencia', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio6.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Turgencia');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Plasmólisis', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio6.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Plasmólisis');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Fotosíntesis', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio6.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Fotosíntesis');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Citolisis', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio6.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Citolisis');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué ocurre en un medio isotónico?', 2, 6
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio6.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=6);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Existe un equilibrio en el flujo neto de agua', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio6.html' AND p.numero=6
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Existe un equilibrio en el flujo neto de agua');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'La célula siempre explota', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio6.html' AND p.numero=6
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='La célula siempre explota');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Toda el agua sale de la célula', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio6.html' AND p.numero=6
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Toda el agua sale de la célula');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'La pared celular desaparece', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio6.html' AND p.numero=6
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='La pared celular desaparece');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué estructura permite el paso de agua a través de la membrana celular?', 2, 7
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio6.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=7);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Acuaporinas', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio6.html' AND p.numero=7
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Acuaporinas');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Ribosomas', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio6.html' AND p.numero=7
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Ribosomas');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Cromosomas', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio6.html' AND p.numero=7
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Cromosomas');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Mitocondrias', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio6.html' AND p.numero=7
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Mitocondrias');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué sucede con una célula animal en un medio hipertónico?', 2, 8
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio6.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=8);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Aumenta mucho su volumen', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio6.html' AND p.numero=8
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Aumenta mucho su volumen');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Pierde agua y puede presentar crenación', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio6.html' AND p.numero=8
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Pierde agua y puede presentar crenación');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Desarrolla una pared celular', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio6.html' AND p.numero=8
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Desarrolla una pared celular');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Se vuelve vegetal', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio6.html' AND p.numero=8
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Se vuelve vegetal');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué significa que una célula vegetal esté turgente?', 2, 9
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio6.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=9);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Ha perdido toda su agua', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio6.html' AND p.numero=9
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Ha perdido toda su agua');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Ha recibido agua y su presión interna aumenta', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio6.html' AND p.numero=9
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Ha recibido agua y su presión interna aumenta');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Su membrana desapareció', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio6.html' AND p.numero=9
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Su membrana desapareció');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Está completamente deshidratada', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio6.html' AND p.numero=9
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Está completamente deshidratada');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿De qué depende principalmente el movimiento osmótico del agua?', 2, 10
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio6.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=10);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'De la diferencia de concentración de solutos', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio6.html' AND p.numero=10
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='De la diferencia de concentración de solutos');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Del color de la célula', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio6.html' AND p.numero=10
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Del color de la célula');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Del tamaño del núcleo', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio6.html' AND p.numero=10
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Del tamaño del núcleo');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'De la cantidad de cromosomas', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio6.html' AND p.numero=10
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='De la cantidad de cromosomas');

-- 9.º | BIOLOGIA | Estructura del ADN y ARN
INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Cuál es la función principal de la mitosis?', 2, 1
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio7.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=1);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Producir células hijas genéticamente similares', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio7.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Producir células hijas genéticamente similares');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Producir únicamente células sexuales', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio7.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Producir únicamente células sexuales');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Reducir a la mitad el número de cromosomas', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio7.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Reducir a la mitad el número de cromosomas');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Eliminar el ADN de la célula', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio7.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Eliminar el ADN de la célula');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿En qué fase los cromosomas se alinean en el centro de la célula?', 2, 2
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio7.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=2);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Profase', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio7.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Profase');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Metafase', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio7.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Metafase');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Anafase', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio7.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Anafase');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Telofase', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio7.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Telofase');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué ocurre durante la anafase?', 2, 3
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio7.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=3);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Se forma nuevamente la envoltura nuclear', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio7.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Se forma nuevamente la envoltura nuclear');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Los cromosomas desaparecen', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio7.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Los cromosomas desaparecen');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Las cromátidas hermanas se separan', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio7.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Las cromátidas hermanas se separan');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'El ADN comienza a replicarse', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio7.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='El ADN comienza a replicarse');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué sucede principalmente durante la profase?', 2, 4
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio7.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=4);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Los cromosomas se condensan y se forma el huso mitótico', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio7.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Los cromosomas se condensan y se forma el huso mitótico');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Las células hijas se separan completamente', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio7.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Las células hijas se separan completamente');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Los cromosomas se alinean en el ecuador', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio7.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Los cromosomas se alinean en el ecuador');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Las cromátidas se dirigen a los polos', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio7.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Las cromátidas se dirigen a los polos');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué estructura organiza los microtúbulos del huso mitótico?', 2, 5
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio7.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=5);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Los ribosomas', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio7.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Los ribosomas');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Los centrosomas', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio7.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Los centrosomas');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Las vacuolas', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio7.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Las vacuolas');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Los lisosomas', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio7.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Los lisosomas');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué ocurre durante la telofase?', 2, 6
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio7.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=6);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Los cromosomas se alinean en el centro', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio7.html' AND p.numero=6
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Los cromosomas se alinean en el centro');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Las cromátidas comienzan a separarse', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio7.html' AND p.numero=6
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Las cromátidas comienzan a separarse');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Se forman nuevamente los núcleos', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio7.html' AND p.numero=6
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Se forman nuevamente los núcleos');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Se duplica el ADN', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio7.html' AND p.numero=6
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Se duplica el ADN');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué proceso divide el citoplasma para formar las células hijas?', 2, 7
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio7.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=7);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Replicación', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio7.html' AND p.numero=7
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Replicación');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Citocinesis', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio7.html' AND p.numero=7
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Citocinesis');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Transcripción', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio7.html' AND p.numero=7
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Transcripción');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Mutación', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio7.html' AND p.numero=7
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Mutación');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué ocurre con las cromátidas hermanas durante la mitosis?', 2, 8
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio7.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=8);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Se separan para distribuirse entre las células hijas', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio7.html' AND p.numero=8
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Se separan para distribuirse entre las células hijas');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Se destruyen antes de la división', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio7.html' AND p.numero=8
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Se destruyen antes de la división');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Se convierten en proteínas', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio7.html' AND p.numero=8
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Se convierten en proteínas');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Permanecen siempre en la misma célula', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio7.html' AND p.numero=8
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Permanecen siempre en la misma célula');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Cuál es la función del huso mitótico?', 2, 9
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio7.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=9);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Producir energía', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio7.html' AND p.numero=9
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Producir energía');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Transportar nutrientes', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio7.html' AND p.numero=9
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Transportar nutrientes');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Ayudar a mover y separar los cromosomas', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio7.html' AND p.numero=9
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Ayudar a mover y separar los cromosomas');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Crear nuevas proteínas', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio7.html' AND p.numero=9
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Crear nuevas proteínas');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Cuál es el resultado final de la mitosis?', 2, 10
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio7.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=10);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Dos células hijas con información genética equivalente', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio7.html' AND p.numero=10
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Dos células hijas con información genética equivalente');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Cuatro células sexuales', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio7.html' AND p.numero=10
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Cuatro células sexuales');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Una sola célula sin núcleo', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio7.html' AND p.numero=10
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Una sola célula sin núcleo');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Dos células con la mitad de cromosomas', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio7.html' AND p.numero=10
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Dos células con la mitad de cromosomas');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué estructura contiene el material genético durante la mayor parte del ciclo celular?', 2, 11
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio7.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=11);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Núcleo', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio7.html' AND p.numero=11
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Núcleo');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Membrana celular', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio7.html' AND p.numero=11
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Membrana celular');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Ribosoma', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio7.html' AND p.numero=11
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Ribosoma');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Centrosoma', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio7.html' AND p.numero=11
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Centrosoma');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Por qué es importante la alineación de los cromosomas en metafase?', 2, 12
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio7.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=12);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Permite una distribución adecuada del material genético', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio7.html' AND p.numero=12
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Permite una distribución adecuada del material genético');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Hace que desaparezca el ADN', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio7.html' AND p.numero=12
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Hace que desaparezca el ADN');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Impide que se formen células hijas', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio7.html' AND p.numero=12
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Impide que se formen células hijas');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Detiene permanentemente la división', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio7.html' AND p.numero=12
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Detiene permanentemente la división');

-- 9.º | QUIMICA | Modelo Atómico de Bohr 3D
INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Quién propuso el modelo atómico que utiliza niveles de energía cuantizados?', 2, 1
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio8.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=1);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Niels Bohr', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Niels Bohr');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Isaac Newton', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Isaac Newton');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Charles Darwin', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Charles Darwin');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Gregor Mendel', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Gregor Mendel');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué partícula se encuentra en los orbitales o niveles de energía del modelo de Bohr?', 2, 2
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio8.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=2);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Protón', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Protón');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Neutrón', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Neutrón');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Electrón', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Electrón');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Núcleo', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Núcleo');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué representa la letra ''n'' en el modelo de Bohr?', 2, 3
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio8.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=3);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'La cantidad de neutrones', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='La cantidad de neutrones');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'El nivel de energía', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='El nivel de energía');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'La cantidad de protones', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='La cantidad de protones');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'La masa atómica', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='La masa atómica');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Dónde se encuentran los protones y neutrones?', 2, 4
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio8.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=4);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'En las órbitas', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='En las órbitas');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'En los niveles de energía', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='En los niveles de energía');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'En el núcleo', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='En el núcleo');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Fuera del átomo', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Fuera del átomo');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué sucede cuando un electrón absorbe energía?', 2, 5
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio8.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=5);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Desaparece', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Desaparece');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Puede pasar a un nivel de energía superior', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Puede pasar a un nivel de energía superior');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Se convierte en protón', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Se convierte en protón');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Sale del núcleo', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Sale del núcleo');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué ocurre cuando un electrón regresa a un nivel de energía menor?', 2, 6
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio8.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=6);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Libera energía', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=6
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Libera energía');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Se convierte en neutrón', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=6
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Se convierte en neutrón');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Aumenta su masa', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=6
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Aumenta su masa');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Desaparece', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=6
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Desaparece');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Cuál es el número atómico del hidrógeno?', 2, 7
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio8.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=7);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, '0', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=7
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='0');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, '1', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=7
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='1');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, '2', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=7
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='2');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, '11', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=7
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='11');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Cuántos electrones tiene un átomo neutro de carbono?', 2, 8
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio8.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=8);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, '2', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=8
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='2');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, '4', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=8
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='4');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, '6', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=8
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='6');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, '8', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=8
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='8');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Cuál es la distribución electrónica simplificada del sodio mostrada en la simulación?', 2, 9
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio8.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=9);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, '2, 8, 1', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=9
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='2, 8, 1');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, '2, 7, 2', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=9
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='2, 7, 2');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, '8, 2, 1', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=9
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='8, 2, 1');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, '2, 9', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=9
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='2, 9');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Cuál de estos elementos tiene dos niveles de energía en la simulación?', 2, 10
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio8.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=10);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Hidrógeno', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=10
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Hidrógeno');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Carbono', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=10
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Carbono');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Ninguno', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=10
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Ninguno');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Solo sodio', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=10
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Solo sodio');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué representa el color cian en la simulación?', 2, 11
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio8.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=11);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Los electrones', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=11
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Los electrones');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Los protones', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=11
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Los protones');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Los neutrones', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=11
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Los neutrones');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'El núcleo', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=11
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='El núcleo');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué representa el color rosado o magenta en el núcleo?', 2, 12
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio8.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=12);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Electrones', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=12
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Electrones');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Neutrones', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=12
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Neutrones');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Protones', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=12
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Protones');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Niveles de energía', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=12
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Niveles de energía');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué representa el color blanco dentro del núcleo?', 2, 13
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio8.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=13);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Protones', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=13
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Protones');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Neutrones', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=13
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Neutrones');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Electrones', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=13
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Electrones');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Fotones', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=13
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Fotones');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Cuál de estos elementos tiene tres niveles de energía en la simulación?', 2, 14
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio8.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=14);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Hidrógeno', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=14
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Hidrógeno');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Carbono', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=14
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Carbono');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Oxígeno', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=14
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Oxígeno');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Sodio', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=14
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Sodio');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Cuál es una característica importante del modelo de Bohr?', 2, 15
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio8.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=15);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Los electrones pueden ocupar niveles de energía definidos', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=15
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Los electrones pueden ocupar niveles de energía definidos');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Los protones giran alrededor de los electrones', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=15
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Los protones giran alrededor de los electrones');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'El núcleo está vacío', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=15
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='El núcleo está vacío');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Los neutrones se encuentran en las órbitas', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=15
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Los neutrones se encuentran en las órbitas');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué partícula determina el número atómico de un elemento?', 2, 16
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio8.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=16);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Electrones', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=16
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Electrones');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Neutrones', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=16
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Neutrones');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Protones', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=16
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Protones');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Fotones', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio8.html' AND p.numero=16
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Fotones');

-- 9.º | QUIMICA | Reacciones y Enlaces
INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué es la convección?', 2, 1
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio9.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=1);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Transferencia de calor mediante el movimiento de un fluido', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Transferencia de calor mediante el movimiento de un fluido');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Transferencia de calor únicamente por luz', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Transferencia de calor únicamente por luz');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Cambio de estado de un sólido', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Cambio de estado de un sólido');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Movimiento de electrones en un metal', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Movimiento de electrones en un metal');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué ocurre generalmente con la densidad de un fluido cuando aumenta su temperatura?', 2, 2
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio9.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=2);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Aumenta mucho', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Aumenta mucho');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Disminuye', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Disminuye');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Permanece siempre igual', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Permanece siempre igual');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Desaparece', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Desaparece');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué sucede con el fluido caliente dentro de la simulación?', 2, 3
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio9.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=3);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Desciende', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Desciende');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Permanece inmóvil', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Permanece inmóvil');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Asciende', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Asciende');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Se convierte en sólido', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Se convierte en sólido');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué sucede con el fluido más frío?', 2, 4
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio9.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=4);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Desciende', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Desciende');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Siempre asciende', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Siempre asciende');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Desaparece', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Desaparece');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Se convierte en gas', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Se convierte en gas');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué representa la flecha de color rosa/rojo?', 2, 5
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio9.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=5);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'El movimiento descendente del fluido frío', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='El movimiento descendente del fluido frío');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'El movimiento ascendente del fluido caliente', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='El movimiento ascendente del fluido caliente');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'La velocidad de la cámara', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='La velocidad de la cámara');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'La presión atmosférica', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='La presión atmosférica');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué representan las flechas de color cian?', 2, 6
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio9.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=6);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'El movimiento descendente del fluido más frío', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=6
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='El movimiento descendente del fluido más frío');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'El calor producido por la luz', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=6
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='El calor producido por la luz');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'La evaporación', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=6
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='La evaporación');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'La densidad máxima', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=6
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='La densidad máxima');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué ocurre al aumentar la potencia térmica?', 2, 7
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio9.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=7);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Disminuye el movimiento del fluido', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=7
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Disminuye el movimiento del fluido');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Aumenta el calentamiento y el movimiento convectivo', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=7
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Aumenta el calentamiento y el movimiento convectivo');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'El fluido deja de existir', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=7
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='El fluido deja de existir');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'La viscosidad siempre llega a cero', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=7
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='La viscosidad siempre llega a cero');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué ocurre cuando la potencia térmica es 0 %?', 2, 8
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio9.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=8);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'El régimen aparece como estático', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=8
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='El régimen aparece como estático');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'El régimen siempre es turbulento', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=8
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='El régimen siempre es turbulento');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'El fluido hierve', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=8
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='El fluido hierve');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'La temperatura llega a 100 °C', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=8
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='La temperatura llega a 100 °C');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué régimen muestra la simulación cuando la potencia es menor al 50 %, pero mayor que 0 %?', 2, 9
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio9.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=9);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Turbulento', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=9
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Turbulento');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Estático', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=9
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Estático');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Laminar', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=9
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Laminar');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Congelado', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=9
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Congelado');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué régimen muestra la simulación cuando la potencia térmica es igual o mayor al 50 %?', 2, 10
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio9.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=10);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Laminar', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=10
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Laminar');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Turbulento', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=10
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Turbulento');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Estático', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=10
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Estático');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Sin flujo', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=10
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Sin flujo');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué propiedad representa la resistencia de un fluido al movimiento o flujo?', 2, 11
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio9.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=11);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Temperatura', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=11
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Temperatura');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Densidad', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=11
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Densidad');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Viscosidad', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=11
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Viscosidad');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Luminosidad', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=11
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Luminosidad');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Cuál de estos fluidos tiene mayor viscosidad en la simulación?', 2, 12
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio9.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=12);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Agua', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=12
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Agua');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Aceite vegetal', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=12
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Aceite vegetal');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Glicerina', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=12
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Glicerina');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Todos tienen la misma', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=12
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Todos tienen la misma');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Cuál es la viscosidad mostrada para el agua?', 2, 13
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio9.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=13);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, '1200 cP', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=13
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='1200 cP');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, '50.0 cP', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=13
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='50.0 cP');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, '1.0 cP', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=13
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='1.0 cP');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, '500 cP', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=13
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='500 cP');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué relación representa ΔT → Δρ en la simulación?', 2, 14
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio9.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=14);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Relación entre temperatura y densidad', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=14
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Relación entre temperatura y densidad');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Relación entre luz y sonido', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=14
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Relación entre luz y sonido');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Relación entre presión y electricidad', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=14
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Relación entre presión y electricidad');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Relación entre masa y color', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=14
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Relación entre masa y color');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué genera principalmente las corrientes de convección?', 2, 15
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio9.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=15);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Diferencias de temperatura y densidad', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=15
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Diferencias de temperatura y densidad');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'La oscuridad del recipiente', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=15
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='La oscuridad del recipiente');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'El tamaño de la pantalla', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=15
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='El tamaño de la pantalla');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'La ausencia de partículas', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=15
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='La ausencia de partículas');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Cuál es el objetivo principal de este experimento?', 2, 16
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio9.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=16);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Observar cómo el calentamiento produce movimiento en el fluido', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=16
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Observar cómo el calentamiento produce movimiento en el fluido');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Medir la velocidad de la luz', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=16
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Medir la velocidad de la luz');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Estudiar únicamente los sólidos', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=16
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Estudiar únicamente los sólidos');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Eliminar la transferencia de calor', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio9.html' AND p.numero=16
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Eliminar la transferencia de calor');

-- 9.º | QUIMICA | Tabla Periódica e Isótopos
INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué es un enlace químico?', 2, 1
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio10.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=1);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Una interacción que mantiene unidos a los átomos', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Una interacción que mantiene unidos a los átomos');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Un cambio de temperatura', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Un cambio de temperatura');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Una corriente eléctrica', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Una corriente eléctrica');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Una separación de moléculas', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=1
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Una separación de moléculas');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué ocurre en un enlace iónico?', 2, 2
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio10.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=2);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Los átomos comparten electrones por igual', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Los átomos comparten electrones por igual');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Se transfieren electrones entre átomos', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Se transfieren electrones entre átomos');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Los protones cambian de átomo', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Los protones cambian de átomo');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Los neutrones desaparecen', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=2
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Los neutrones desaparecen');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué tipo de enlace presenta el NaCl?', 2, 3
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio10.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=3);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Covalente apolar', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Covalente apolar');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Covalente polar', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Covalente polar');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Iónico', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Iónico');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Metálico', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=3
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Metálico');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué ocurre en un enlace covalente?', 2, 4
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio10.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=4);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Los átomos comparten electrones', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Los átomos comparten electrones');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Los átomos pierden todos sus protones', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Los átomos pierden todos sus protones');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Se destruyen los electrones', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Se destruyen los electrones');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Los neutrones se transfieren', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=4
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Los neutrones se transfieren');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué característica tiene un enlace covalente polar?', 2, 5
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio10.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=5);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Los electrones se comparten de manera desigual', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Los electrones se comparten de manera desigual');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'No existen electrones', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='No existen electrones');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Siempre se transfieren electrones', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Siempre se transfieren electrones');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Los átomos tienen la misma carga', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=5
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Los átomos tienen la misma carga');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué ocurre en un enlace covalente apolar?', 2, 6
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio10.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=6);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Los electrones se comparten de forma similar', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=6
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Los electrones se comparten de forma similar');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Un átomo pierde todos sus electrones', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=6
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Un átomo pierde todos sus electrones');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Se forman únicamente iones', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=6
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Se forman únicamente iones');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Los protones son compartidos', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=6
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Los protones son compartidos');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué representa la diferencia de electronegatividad (ΔEN)?', 2, 7
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio10.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=7);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'La diferencia de masa entre átomos', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=7
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='La diferencia de masa entre átomos');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'La diferencia en la capacidad de atraer electrones', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=7
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='La diferencia en la capacidad de atraer electrones');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'La cantidad de protones', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=7
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='La cantidad de protones');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'La temperatura de la molécula', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=7
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='La temperatura de la molécula');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Cuál tiene una diferencia de electronegatividad de 0.0 en esta simulación?', 2, 8
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio10.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=8);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'NaCl', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=8
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='NaCl');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'H₂O', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=8
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='H₂O');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'H₂', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=8
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='H₂');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'NH₃', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=8
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='NH₃');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Cuál es la diferencia de electronegatividad mostrada para NaCl?', 2, 9
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio10.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=9);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, '0.0', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=9
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='0.0');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, '0.9', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=9
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='0.9');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, '1.4', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=9
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='1.4');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, '2.1', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=9
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='2.1');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Cuál es la diferencia de electronegatividad mostrada para H₂O?', 2, 10
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio10.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=10);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, '1.4', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=10
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='1.4');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, '2.1', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=10
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='2.1');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, '0.0', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=10
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='0.0');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, '0.9', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=10
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='0.9');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué sucede al disminuir la distancia entre los átomos en la simulación?', 2, 11
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio10.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=11);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Los átomos se alejan', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=11
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Los átomos se alejan');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Los átomos se aproximan', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=11
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Los átomos se aproximan');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Los electrones desaparecen', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=11
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Los electrones desaparecen');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'La temperatura se vuelve cero', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=11
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='La temperatura se vuelve cero');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué efecto tiene aumentar la temperatura en la simulación?', 2, 12
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio10.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=12);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Aumenta la vibración de los átomos', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=12
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Aumenta la vibración de los átomos');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Elimina los átomos', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=12
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Elimina los átomos');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Detiene completamente los electrones', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=12
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Detiene completamente los electrones');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Convierte todos los enlaces en iónicos', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=12
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Convierte todos los enlaces en iónicos');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué partículas participan directamente en la formación de enlaces químicos?', 2, 13
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio10.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=13);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Electrones', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=13
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Electrones');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Neutrones únicamente', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=13
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Neutrones únicamente');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Fotones únicamente', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=13
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Fotones únicamente');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Núcleos sin electrones', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=13
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Núcleos sin electrones');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué representa la entalpía de reacción (ΔH)?', 2, 14
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio10.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=14);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Un cambio de energía asociado a una reacción', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=14
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Un cambio de energía asociado a una reacción');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'El número de electrones', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=14
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='El número de electrones');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'La masa de un átomo', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=14
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='La masa de un átomo');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'La cantidad de neutrones', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=14
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='La cantidad de neutrones');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Cuál es el valor de ΔH mostrado para la formación de H₂?', 2, 15
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio10.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=15);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, '−91.8 kJ/mol', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=15
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='−91.8 kJ/mol');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, '−285.8 kJ/mol', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=15
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='−285.8 kJ/mol');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, '−411 kJ/mol', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=15
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='−411 kJ/mol');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, '−436 kJ/mol', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=15
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='−436 kJ/mol');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Cuál es el objetivo principal de este laboratorio?', 2, 16
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio10.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=16);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Observar y comprender la formación de enlaces químicos', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=16
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Observar y comprender la formación de enlaces químicos');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Medir la velocidad del sonido', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=16
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Medir la velocidad del sonido');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Estudiar el movimiento de planetas', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=16
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Estudiar el movimiento de planetas');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Calcular la gravedad terrestre', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=16
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Calcular la gravedad terrestre');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué representa la fórmula Na + Cl → Na⁺ + Cl⁻?', 2, 17
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio10.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=17);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Una transferencia de electrones', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=17
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Una transferencia de electrones');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Una evaporación', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=17
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Una evaporación');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Una reacción nuclear', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=17
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Una reacción nuclear');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Una separación de protones', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=17
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Una separación de protones');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Qué elemento tiene mayor electronegatividad en un enlace NaCl?', 2, 18
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio10.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=18);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Sodio', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=18
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Sodio');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Cloro', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=18
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Cloro');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Ambos tienen exactamente la misma', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=18
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Ambos tienen exactamente la misma');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Ninguno', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=18
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Ninguno');

INSERT INTO pregunta (id_evaluacion, enunciado, puntaje, numero)
SELECT e.id_evaluacion, '¿Cuál de estas opciones corresponde a una reacción de síntesis mostrada?', 2, 19
FROM evaluacion e JOIN experimento ex ON ex.id_experimento = e.id_experimento
WHERE ex.ruta = 'laboratorio10.html'
AND NOT EXISTS (SELECT 1 FROM pregunta p WHERE p.id_evaluacion=e.id_evaluacion AND p.numero=19);
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'N₂ + 3H₂ → 2NH₃', TRUE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=19
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='N₂ + 3H₂ → 2NH₃');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'Na + Cl → Na⁺ + Cl⁻', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=19
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='Na + Cl → Na⁺ + Cl⁻');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'H + H → H₂', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=19
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='H + H → H₂');
INSERT INTO opcion (id_pregunta, texto, es_correcta)
SELECT p.id_pregunta, 'H₂O → H + O', FALSE
FROM pregunta p JOIN evaluacion e ON e.id_evaluacion=p.id_evaluacion JOIN experimento ex ON ex.id_experimento=e.id_experimento
WHERE ex.ruta='laboratorio10.html' AND p.numero=19
AND NOT EXISTS (SELECT 1 FROM opcion o WHERE o.id_pregunta=p.id_pregunta AND o.texto='H₂O → H + O');

COMMIT;

SELECT ex.grado, ex.area, ex.nombre, ex.ruta, COUNT(DISTINCT p.id_pregunta) AS preguntas, COUNT(o.id_opcion) AS opciones
FROM experimento ex JOIN evaluacion e ON e.id_experimento=ex.id_experimento JOIN pregunta p ON p.id_evaluacion=e.id_evaluacion JOIN opcion o ON o.id_pregunta=p.id_pregunta
WHERE ex.grado IN (7,9)
GROUP BY ex.id_experimento, ex.grado, ex.area, ex.nombre, ex.ruta
ORDER BY ex.grado, ex.area, ex.nombre;


-- ===== VISTA PARA DOCENTES.sql =====
CREATE OR REPLACE VIEW vista_docentes AS
SELECT
    u.id_usuario,
    u.usuario,
    d.nombre,
    d.apellido,
    u.activo,
    u.fecha_registro
FROM usuario u
INNER JOIN docente d
    ON u.id_usuario = d.id_docente
WHERE u.rol = 'docente';

-- ===== VISTA PARA CONSULTAR ESTUDIANTES.sql =====
CREATE OR REPLACE VIEW vista_estudiantes AS
SELECT
    u.id_usuario,
    u.usuario,
    e.nombre,
    e.apellido,
    e.grado,
    u.activo,
    u.fecha_registro
FROM usuario u
INNER JOIN estudiante e
    ON u.id_usuario = e.id_estudiante
WHERE u.rol = 'estudiante';