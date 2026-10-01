<?php
ob_start();
session_start();
require_once 'conexion.php';
header('Content-Type: application/json; charset=UTF-8');

function valor_unico($conexion, $sql, $params = [])
{
    $r = $params
        ? @pg_query_params($conexion, $sql, $params)
        : @pg_query($conexion, $sql);

    if (!$r || pg_num_rows($r) < 1) {
        return null;
    }
    return pg_fetch_result($r, 0, 0);
}

function filas($conexion, $sql, $params = [])
{
    $r = $params
        ? @pg_query_params($conexion, $sql, $params)
        : @pg_query($conexion, $sql);

    if (!$r) {
        return [];
    }

    $out = [];
    while ($f = pg_fetch_assoc($r)) {
        $out[] = $f;
    }
    return $out;
}

$tablas = ['usuario','estudiante','docente','experimento','evaluacion','pregunta','opcion','intento_evaluacion','respuesta'];
$estadoTablas = [];
foreach ($tablas as $tabla) {
    $estadoTablas[$tabla] = ecolab_tabla_existe($conexion, $tabla);
}

$datos = [
    'exito' => true,
    'mensaje' => 'PHP está conectado con PostgreSQL.',
    'servidor' => [
        'base_datos' => valor_unico($conexion, 'SELECT current_database()'),
        'usuario_bd' => valor_unico($conexion, 'SELECT current_user'),
        'postgresql' => valor_unico($conexion, 'SHOW server_version'),
        'php' => PHP_VERSION,
        'pgsql_habilitado' => function_exists('pg_connect')
    ],
    'auto_migracion' => [
        'aplicada_en_esta_peticion' => (bool)($GLOBALS['ECOLAB_MIGRACION_APLICADA'] ?? false),
        'error' => $GLOBALS['ECOLAB_MIGRACION_ERROR'] ?? null
    ],
    'sesion' => [
        'iniciada' => isset($_SESSION['id_usuario']),
        'id_usuario' => $_SESSION['id_usuario'] ?? null,
        'usuario' => $_SESSION['usuario'] ?? null,
        'rol' => $_SESSION['rol'] ?? null,
        'grado' => $_SESSION['grado'] ?? null
    ],
    'tablas' => $estadoTablas,
    'usuarios' => [],
    'contenido' => [],
    'evaluaciones' => []
];

if ($estadoTablas['usuario'] && $estadoTablas['estudiante']) {
    $datos['usuarios'] = [
        'usuarios_total' => (int)(valor_unico($conexion, 'SELECT COUNT(*) FROM usuario') ?? 0),
        'estudiantes_total' => (int)(valor_unico($conexion, 'SELECT COUNT(*) FROM estudiante') ?? 0),
        'docentes_total' => (int)(valor_unico($conexion, 'SELECT COUNT(*) FROM docente') ?? 0),
        'estudiantes_por_grado' => filas($conexion, 'SELECT grado, COUNT(*)::int AS cantidad FROM estudiante GROUP BY grado ORDER BY grado')
    ];
}

if ($estadoTablas['experimento'] && $estadoTablas['evaluacion'] && $estadoTablas['pregunta'] && $estadoTablas['opcion']) {
    $datos['contenido'] = [
        'experimentos_por_grado' => filas($conexion, 'SELECT grado, COUNT(*)::int AS cantidad FROM experimento WHERE activo=TRUE GROUP BY grado ORDER BY grado'),
        'preguntas_por_grado' => filas($conexion, "
            SELECT ex.grado, COUNT(p.id_pregunta)::int AS cantidad
            FROM experimento ex
            JOIN evaluacion ev ON ev.id_experimento=ex.id_experimento
            JOIN pregunta p ON p.id_evaluacion=ev.id_evaluacion
            GROUP BY ex.grado ORDER BY ex.grado
        "),
        'opciones_por_grado' => filas($conexion, "
            SELECT ex.grado, COUNT(o.id_opcion)::int AS cantidad
            FROM experimento ex
            JOIN evaluacion ev ON ev.id_experimento=ex.id_experimento
            JOIN pregunta p ON p.id_evaluacion=ev.id_evaluacion
            JOIN opcion o ON o.id_pregunta=p.id_pregunta
            GROUP BY ex.grado ORDER BY ex.grado
        ")
    ];
}

if ($estadoTablas['intento_evaluacion'] && $estadoTablas['respuesta']) {
    $datos['evaluaciones'] = [
        'intentos_total' => (int)(valor_unico($conexion, 'SELECT COUNT(*) FROM intento_evaluacion') ?? 0),
        'respuestas_total' => (int)(valor_unico($conexion, 'SELECT COUNT(*) FROM respuesta') ?? 0),
        'intentos_por_grado' => filas($conexion, "
            SELECT es.grado, COUNT(ie.id_intento)::int AS cantidad
            FROM intento_evaluacion ie
            JOIN estudiante es ON es.id_estudiante=ie.id_estudiante
            GROUP BY es.grado ORDER BY es.grado
        "),
        'ultimos_intentos' => filas($conexion, "
            SELECT
                ie.id_intento,
                es.nombre || ' ' || es.apellido AS estudiante,
                es.grado,
                ex.nombre AS experimento,
                ie.nota,
                ie.porcentaje,
                ie.fecha_finalizacion
            FROM intento_evaluacion ie
            JOIN estudiante es ON es.id_estudiante=ie.id_estudiante
            JOIN evaluacion ev ON ev.id_evaluacion=ie.id_evaluacion
            JOIN experimento ex ON ex.id_experimento=ev.id_experimento
            ORDER BY ie.id_intento DESC
            LIMIT 10
        ")
    ];
}

if (ob_get_length()) {
    ob_clean();
}
echo json_encode($datos, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_PRETTY_PRINT);
