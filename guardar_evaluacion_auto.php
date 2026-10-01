<?php
ob_start();
session_start();
require_once 'conexion.php';
header('Content-Type: application/json; charset=UTF-8');

function responder($datos, $codigo = 200)
{
    http_response_code($codigo);
    if (ob_get_length()) {
        ob_clean();
    }
    echo json_encode($datos, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit;
}

function clave_texto($texto)
{
    $texto = html_entity_decode(strip_tags((string)$texto), ENT_QUOTES | ENT_HTML5, 'UTF-8');
    $texto = preg_replace('/^\s*\d+\s*[\.\)\-:]\s*/u', '', $texto);
    $texto = preg_replace('/^\s*[A-D]\s*[\)\.\-:]\s*/iu', '', $texto);
    $texto = preg_replace('/\s+/u', ' ', trim($texto));

    if (function_exists('mb_strtolower')) {
        $texto = mb_strtolower($texto, 'UTF-8');
    } else {
        $texto = strtolower($texto);
    }

    // Elimina diferencias de puntuación/renderizado, pero conserva letras y números.
    return preg_replace('/[^\p{L}\p{N}%°ρ]+/u', '', $texto);
}

function buscar_por_similitud($clave, $elementos, $campoClave, $usados = [])
{
    if ($clave === '') {
        return null;
    }

    $mejor = null;
    $mejorPuntaje = 0.0;

    foreach ($elementos as $item) {
        $id = $item['id_pregunta'] ?? $item['id_opcion'] ?? null;
        if ($id !== null && isset($usados[$id])) {
            continue;
        }

        $candidata = $item[$campoClave] ?? '';
        if ($candidata === '') {
            continue;
        }

        if ($clave === $candidata) {
            return $item;
        }

        if (str_contains($clave, $candidata) || str_contains($candidata, $clave)) {
            $min = min(strlen($clave), strlen($candidata));
            $max = max(strlen($clave), strlen($candidata));
            $puntaje = $max > 0 ? ($min / $max) * 100 : 0;
        } else {
            similar_text($clave, $candidata, $puntaje);
        }

        if ($puntaje > $mejorPuntaje) {
            $mejorPuntaje = $puntaje;
            $mejor = $item;
        }
    }

    return $mejorPuntaje >= 82.0 ? $mejor : null;
}

if (!isset($_SESSION['id_usuario'], $_SESSION['rol']) || $_SESSION['rol'] !== 'estudiante') {
    responder([
        'exito' => false,
        'mensaje' => 'Debes iniciar sesión como estudiante antes de guardar una evaluación.'
    ], 401);
}

$entrada = json_decode(file_get_contents('php://input'), true);
if (!is_array($entrada)) {
    responder(['exito' => false, 'mensaje' => 'Solicitud JSON no válida.'], 400);
}

$pagina = basename((string)($entrada['pagina'] ?? ''));
$respuestasRecibidas = $entrada['respuestas'] ?? null;
$idEstudiante = (int)$_SESSION['id_usuario'];

if ($pagina === '' || !is_array($respuestasRecibidas) || count($respuestasRecibidas) < 1) {
    responder(['exito' => false, 'mensaje' => 'Faltan datos de la evaluación.'], 400);
}

$sqlExp = "
    SELECT
        ex.id_experimento,
        ex.nombre,
        ex.grado,
        ev.id_evaluacion,
        ev.puntaje_maximo
    FROM experimento ex
    INNER JOIN evaluacion ev ON ev.id_experimento = ex.id_experimento
    WHERE ex.ruta = $1
      AND ex.grado IN (7, 9)
      AND ex.activo = TRUE
      AND ev.activa = TRUE
    ORDER BY ev.id_evaluacion
    LIMIT 1
";

$rExp = @pg_query_params($conexion, $sqlExp, [$pagina]);
if (!$rExp || pg_num_rows($rExp) !== 1) {
    $detalle = $GLOBALS['ECOLAB_MIGRACION_ERROR'] ?? null;
    responder([
        'exito' => false,
        'mensaje' => 'El laboratorio no está disponible en PostgreSQL.',
        'pagina' => $pagina,
        'detalle' => $detalle ?: 'Revisa php/diagnostico.php para verificar la instalación de la base de datos.'
    ], 404);
}

$exp = pg_fetch_assoc($rExp);
$idEvaluacion = (int)$exp['id_evaluacion'];
$gradoExperimento = (int)$exp['grado'];
$puntajeMaximo = (float)($exp['puntaje_maximo'] ?? 10);
if ($puntajeMaximo <= 0) {
    $puntajeMaximo = 10;
}

$rEst = @pg_query_params(
    $conexion,
    'SELECT grado FROM estudiante WHERE id_estudiante = $1',
    [$idEstudiante]
);

if (!$rEst || pg_num_rows($rEst) !== 1) {
    responder(['exito' => false, 'mensaje' => 'No se encontró el perfil del estudiante.'], 403);
}

$gradoEstudiante = (int)pg_fetch_result($rEst, 0, 'grado');
if ($gradoEstudiante !== $gradoExperimento) {
    responder([
        'exito' => false,
        'mensaje' => 'La evaluación no corresponde al grado del estudiante.',
        'grado_estudiante' => $gradoEstudiante,
        'grado_laboratorio' => $gradoExperimento
    ], 403);
}

$sqlBanco = "
    SELECT
        p.id_pregunta,
        p.numero,
        p.enunciado,
        p.puntaje,
        o.id_opcion,
        o.texto,
        o.es_correcta
    FROM pregunta p
    INNER JOIN opcion o ON o.id_pregunta = p.id_pregunta
    WHERE p.id_evaluacion = $1
    ORDER BY p.numero, o.id_opcion
";

$rBanco = @pg_query_params($conexion, $sqlBanco, [$idEvaluacion]);
if (!$rBanco) {
    responder([
        'exito' => false,
        'mensaje' => 'No se pudo consultar el banco de preguntas.',
        'detalle' => pg_last_error($conexion)
    ], 500);
}

$preguntas = [];
$indiceExacto = [];

while ($fila = pg_fetch_assoc($rBanco)) {
    $idPregunta = (int)$fila['id_pregunta'];
    $kPregunta = clave_texto($fila['enunciado']);

    if (!isset($preguntas[$idPregunta])) {
        $preguntas[$idPregunta] = [
            'id_pregunta' => $idPregunta,
            'numero' => (int)$fila['numero'],
            'enunciado' => $fila['enunciado'],
            'clave' => $kPregunta,
            'puntaje' => (float)$fila['puntaje'],
            'opciones' => []
        ];
        $indiceExacto[$kPregunta] = $idPregunta;
    }

    $preguntas[$idPregunta]['opciones'][] = [
        'id_opcion' => (int)$fila['id_opcion'],
        'texto' => $fila['texto'],
        'clave' => clave_texto($fila['texto']),
        'es_correcta' => ($fila['es_correcta'] === 't' || $fila['es_correcta'] === true)
    ];
}

if (!$preguntas) {
    responder([
        'exito' => false,
        'mensaje' => 'La evaluación existe, pero no tiene preguntas configuradas en PostgreSQL.'
    ], 422);
}

$listaPreguntas = array_values($preguntas);
$procesadas = [];
$usadas = [];
$noRelacionadas = [];

foreach ($respuestasRecibidas as $posicion => $r) {
    if (!is_array($r)) {
        continue;
    }

    $textoPregunta = (string)($r['pregunta'] ?? '');
    $textoRespuesta = (string)($r['respuesta'] ?? '');
    $kPregunta = clave_texto($textoPregunta);
    $kRespuesta = clave_texto($textoRespuesta);

    if ($kPregunta === '' || $kRespuesta === '') {
        $noRelacionadas[] = ['posicion' => $posicion + 1, 'motivo' => 'Pregunta o respuesta vacía'];
        continue;
    }

    $p = null;
    if (isset($indiceExacto[$kPregunta])) {
        $id = $indiceExacto[$kPregunta];
        if (!isset($usadas[$id])) {
            $p = $preguntas[$id];
        }
    }

    if ($p === null) {
        $p = buscar_por_similitud($kPregunta, $listaPreguntas, 'clave', $usadas);
    }

    if ($p === null) {
        $noRelacionadas[] = [
            'posicion' => $posicion + 1,
            'pregunta' => $textoPregunta,
            'motivo' => 'No coincide con el banco de preguntas'
        ];
        continue;
    }

    $opcion = buscar_por_similitud($kRespuesta, $p['opciones'], 'clave');
    if ($opcion === null) {
        $noRelacionadas[] = [
            'posicion' => $posicion + 1,
            'pregunta' => $textoPregunta,
            'respuesta' => $textoRespuesta,
            'motivo' => 'La opción seleccionada no coincide con las opciones de PostgreSQL'
        ];
        continue;
    }

    $usadas[$p['id_pregunta']] = true;
    $procesadas[] = [
        'id_pregunta' => $p['id_pregunta'],
        'id_opcion' => $opcion['id_opcion'],
        'es_correcta' => $opcion['es_correcta']
    ];
}

if (count($procesadas) !== count($respuestasRecibidas)) {
    responder([
        'exito' => false,
        'mensaje' => 'No fue posible relacionar todas las respuestas con PostgreSQL.',
        'recibidas' => count($respuestasRecibidas),
        'procesadas' => count($procesadas),
        'no_relacionadas' => $noRelacionadas
    ], 422);
}

$total = count($procesadas);
if ($total < 1) {
    responder(['exito' => false, 'mensaje' => 'No se recibió ninguna respuesta válida.'], 422);
}

$aciertos = 0;
foreach ($procesadas as $p) {
    if ($p['es_correcta']) {
        $aciertos++;
    }
}

$nota = round(($aciertos / $total) * $puntajeMaximo, 2);
$porcentaje = round(($aciertos / $total) * 100, 2);
$aprobado = $nota >= 6.0;
$puntosPorAcierto = $puntajeMaximo / $total;

@pg_query($conexion, 'BEGIN');
try {
    $sqlIntento = "
        INSERT INTO intento_evaluacion
        (id_estudiante, id_evaluacion, fecha_inicio, fecha_finalizacion, nota, porcentaje, aprobado)
        VALUES ($1, $2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, $3, $4, $5)
        RETURNING id_intento
    ";

    $rIntento = @pg_query_params($conexion, $sqlIntento, [
        $idEstudiante,
        $idEvaluacion,
        $nota,
        $porcentaje,
        $aprobado ? 'true' : 'false'
    ]);

    if (!$rIntento) {
        throw new RuntimeException(pg_last_error($conexion));
    }

    $idIntento = (int)pg_fetch_result($rIntento, 0, 'id_intento');

    foreach ($procesadas as $p) {
        $puntos = $p['es_correcta'] ? round($puntosPorAcierto, 4) : 0;
        $ok = @pg_query_params(
            $conexion,
            "
                INSERT INTO respuesta
                (id_intento, id_pregunta, id_opcion, es_correcta, puntos_obtenidos)
                VALUES ($1, $2, $3, $4, $5)
            ",
            [
                $idIntento,
                $p['id_pregunta'],
                $p['id_opcion'],
                $p['es_correcta'] ? 'true' : 'false',
                $puntos
            ]
        );

        if (!$ok) {
            throw new RuntimeException(pg_last_error($conexion));
        }
    }

    @pg_query($conexion, 'COMMIT');

    responder([
        'exito' => true,
        'mensaje' => 'Evaluación guardada en PostgreSQL.',
        'id_intento' => $idIntento,
        'experimento' => $exp['nombre'],
        'pagina' => $pagina,
        'total' => $total,
        'aciertos' => $aciertos,
        'nota' => $nota,
        'porcentaje' => $porcentaje,
        'aprobado' => $aprobado
    ]);
} catch (Throwable $e) {
    @pg_query($conexion, 'ROLLBACK');
    responder([
        'exito' => false,
        'mensaje' => 'No se pudo guardar la evaluación en PostgreSQL.',
        'detalle' => $e->getMessage()
    ], 500);
}
