SELECT
    ex.id_experimento,
    ex.nombre AS experimento,
    ex.area,
    ex.grado,
    e.id_evaluacion,
    e.titulo AS evaluacion,
    COUNT(DISTINCT p.id_pregunta) AS preguntas,
    COUNT(o.id_opcion) AS opciones
FROM experimento ex
INNER JOIN evaluacion e
    ON ex.id_experimento = e.id_experimento
INNER JOIN pregunta p
    ON e.id_evaluacion = p.id_evaluacion
INNER JOIN opcion o
    ON p.id_pregunta = o.id_pregunta
GROUP BY
    ex.id_experimento,
    ex.nombre,
    ex.area,
    ex.grado,
    e.id_evaluacion,
    e.titulo
ORDER BY
    ex.grado,
    ex.area,
    ex.id_experimento;