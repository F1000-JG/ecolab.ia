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