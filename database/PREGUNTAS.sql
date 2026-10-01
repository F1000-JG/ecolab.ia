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