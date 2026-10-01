<?php

ob_start();
session_start();

require_once "conexion.php";

header("Content-Type: application/json; charset=UTF-8");

function responder($datos)
{
    ob_clean();

    echo json_encode(
        $datos,
        JSON_UNESCAPED_UNICODE
    );

    exit;
}


/* =========================================================
   1. VERIFICAR SESIÓN
   ========================================================= */

if (
    !isset($_SESSION["id_usuario"]) ||
    !isset($_SESSION["rol"]) ||
    $_SESSION["rol"] !== "estudiante"
) {
    responder([
        "exito" => false,
        "mensaje" => "Debes iniciar sesión como estudiante."
    ]);
}

$idEstudiante = (int) $_SESSION["id_usuario"];


/* =========================================================
   2. RECIBIR DATOS
   ========================================================= */

$datosRecibidos = json_decode(
    file_get_contents("php://input"),
    true
);

if (!is_array($datosRecibidos)) {
    responder([
        "exito" => false,
        "mensaje" => "Los datos recibidos no son válidos."
    ]);
}

$idEvaluacion = isset($datosRecibidos["id_evaluacion"])
    ? (int) $datosRecibidos["id_evaluacion"]
    : 0;

$respuestas = $datosRecibidos["respuestas"] ?? null;


/* =========================================================
   3. VALIDAR DATOS
   ========================================================= */

if ($idEvaluacion <= 0) {
    responder([
        "exito" => false,
        "mensaje" => "No se indicó una evaluación válida."
    ]);
}

if (!is_array($respuestas)) {
    responder([
        "exito" => false,
        "mensaje" => "No se recibieron las respuestas."
    ]);
}


/* =========================================================
   4. OBTENER LAS PREGUNTAS DE LA EVALUACIÓN
   ========================================================= */

$sqlPreguntas = "
    SELECT
        p.id_pregunta,
        p.numero,
        p.puntaje
    FROM pregunta p
    INNER JOIN evaluacion ev
        ON ev.id_evaluacion = p.id_evaluacion
    WHERE p.id_evaluacion = $1
      AND ev.activa = TRUE
    ORDER BY p.numero
";

$resultadoPreguntas = pg_query_params(
    $conexion,
    $sqlPreguntas,
    [$idEvaluacion]
);

if (!$resultadoPreguntas) {
    responder([
        "exito" => false,
        "mensaje" => "No se pudieron obtener las preguntas."
    ]);
}

$preguntas = [];

while ($fila = pg_fetch_assoc($resultadoPreguntas)) {
    $preguntas[(int)$fila["numero"]] = $fila;
}


/* =========================================================
   5. VERIFICAR QUE EXISTAN LAS 5 PREGUNTAS
   ========================================================= */

if (count($preguntas) !== 5) {
    responder([
        "exito" => false,
        "mensaje" => "La evaluación no tiene las 5 preguntas configuradas."
    ]);
}


/* =========================================================
   6. OBTENER LAS OPCIONES CORRECTAS
   ========================================================= */

$opcionesPorPregunta = [];

foreach ($preguntas as $numero => $pregunta) {

    $idPregunta = (int)$pregunta["id_pregunta"];

    $sqlOpciones = "
        SELECT
            id_opcion,
            texto,
            es_correcta
        FROM opcion
        WHERE id_pregunta = $1
        ORDER BY id_opcion
    ";

    $resultadoOpciones = pg_query_params(
        $conexion,
        $sqlOpciones,
        [$idPregunta]
    );

    if (!$resultadoOpciones) {
        responder([
            "exito" => false,
            "mensaje" => "No se pudieron obtener las opciones de la pregunta $numero."
        ]);
    }

    $opciones = [];

    while ($opcion = pg_fetch_assoc($resultadoOpciones)) {
        $opciones[] = $opcion;
    }

    if (count($opciones) !== 4) {
        responder([
            "exito" => false,
            "mensaje" => "La pregunta $numero no tiene 4 opciones."
        ]);
    }

    $opcionesPorPregunta[$numero] = $opciones;
}


/* =========================================================
   7. VALIDAR LAS 5 RESPUESTAS
   ========================================================= */

for ($i = 1; $i <= 5; $i++) {

    $clave = "q" . $i;

    if (
        !array_key_exists($clave, $respuestas) ||
        $respuestas[$clave] === "" ||
        $respuestas[$clave] === null
    ) {
        responder([
            "exito" => false,
            "mensaje" => "Debes responder todas las preguntas."
        ]);
    }

    $indice = (int)$respuestas[$clave];

    if ($indice < 0 || $indice > 3) {
        responder([
            "exito" => false,
            "mensaje" => "Se recibió una opción no válida en la pregunta $i."
        ]);
    }
}


/* =========================================================
   8. CALCULAR RESULTADO EN EL SERVIDOR
   ========================================================= */

$aciertos = 0;
$puntosObtenidos = 0;

$respuestasProcesadas = [];

for ($numero = 1; $numero <= 5; $numero++) {

    $indiceSeleccionado = (int)$respuestas["q" . $numero];

    $opciones = $opcionesPorPregunta[$numero];

    $opcionSeleccionada = $opciones[$indiceSeleccionado];

    $esCorrecta = (
        $opcionSeleccionada["es_correcta"] === "t" ||
        $opcionSeleccionada["es_correcta"] === true
    );

    $puntajePregunta = (int)$preguntas[$numero]["puntaje"];

    $puntos = $esCorrecta
        ? $puntajePregunta
        : 0;

    if ($esCorrecta) {
        $aciertos++;
    }

    $puntosObtenidos += $puntos;

    $respuestasProcesadas[] = [
        "id_pregunta" => (int)$preguntas[$numero]["id_pregunta"],
        "id_opcion" => (int)$opcionSeleccionada["id_opcion"],
        "es_correcta" => $esCorrecta ? "true" : "false",
        "puntos" => $puntos
    ];

}


/* =========================================================
   9. CALCULAR NOTA Y PORCENTAJE
   ========================================================= */

$nota = (float)$puntosObtenidos;

$porcentaje = $nota * 10;

$aprobado = $nota >= 6 ? "true" : "false";


/* =========================================================
   10. GUARDAR TODO EN UNA TRANSACCIÓN
   ========================================================= */

pg_query($conexion, "BEGIN");

try {

    /* ---------------------------------------------
       Guardar intento
       --------------------------------------------- */

    $sqlIntento = "
        INSERT INTO intento_evaluacion
        (
            id_estudiante,
            id_evaluacion,
            fecha_inicio,
            fecha_finalizacion,
            nota,
            porcentaje,
            aprobado
        )
        VALUES
        (
            $1,
            $2,
            CURRENT_TIMESTAMP,
            CURRENT_TIMESTAMP,
            $3,
            $4,
            $5
        )
        RETURNING id_intento
    ";

    $resultadoIntento = pg_query_params(
        $conexion,
        $sqlIntento,
        [
            $idEstudiante,
            $idEvaluacion,
            $nota,
            $porcentaje,
            $aprobado
        ]
    );

    if (!$resultadoIntento) {
    throw new Exception(
        "No se pudo guardar el intento de evaluación. PostgreSQL dice: " .
        pg_last_error($conexion)
    );
}

    $filaIntento = pg_fetch_assoc($resultadoIntento);

    $idIntento = (int)$filaIntento["id_intento"];


    /* ---------------------------------------------
       Guardar las 5 respuestas
       --------------------------------------------- */

    foreach ($respuestasProcesadas as $respuesta) {

        $sqlRespuesta = "
            INSERT INTO respuesta
            (
                id_intento,
                id_pregunta,
                id_opcion,
                es_correcta,
                puntos_obtenidos
            )
            VALUES
            (
                $1,
                $2,
                $3,
                $4,
                $5
            )
        ";

        $resultadoRespuesta = pg_query_params(
            $conexion,
            $sqlRespuesta,
            [
                $idIntento,
                $respuesta["id_pregunta"],
                $respuesta["id_opcion"],
                $respuesta["es_correcta"],
                $respuesta["puntos"]
            ]
        );

        if (!$resultadoRespuesta) {
            throw new Exception(
                "No se pudo guardar una de las respuestas."
            );
        }
    }


    /* ---------------------------------------------
       Confirmar transacción
       --------------------------------------------- */

    pg_query($conexion, "COMMIT");


    /* =================================================
       11. RESPONDER AL JAVASCRIPT
       ================================================= */

    responder([
        "exito" => true,
        "mensaje" => "Evaluación guardada correctamente.",
        "id_intento" => $idIntento,
        "aciertos" => $aciertos,
        "nota" => $nota,
        "porcentaje" => $porcentaje,
        "aprobado" => $aprobado
    ]);

} catch (Exception $e) {

    pg_query($conexion, "ROLLBACK");

    responder([
        "exito" => false,
        "mensaje" => "Error al guardar la evaluación: " . $e->getMessage()
    ]);
}

?>