<?php

ob_start();
session_start();

require_once "conexion.php";

header("Content-Type: application/json; charset=UTF-8");


/* =========================================================
   FUNCIÓN PARA RESPONDER EN JSON
   ========================================================= */

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
   VERIFICAR SESIÓN
   ========================================================= */

if (!isset($_SESSION["id_usuario"])) {

    responder([
        "exito" => false,
        "mensaje" => "No hay una sesión iniciada."
    ]);

}


/* =========================================================
   VERIFICAR QUE SEA DOCENTE
   ========================================================= */

if (
    !isset($_SESSION["rol"]) ||
    $_SESSION["rol"] !== "docente"
) {

    responder([
        "exito" => false,
        "mensaje" => "No tienes permisos para acceder al panel docente."
    ]);

}


$idDocente = (int)$_SESSION["id_usuario"];


/* =========================================================
   OBTENER INFORMACIÓN DEL DOCENTE
   ========================================================= */

$sqlDocente = "

    SELECT
        d.nombre,
        d.apellido,
        u.usuario

    FROM docente d

    INNER JOIN usuario u
        ON u.id_usuario = d.id_docente

    WHERE d.id_docente = $1
      AND u.rol = 'docente'

    LIMIT 1

";


$resultadoDocente = pg_query_params(
    $conexion,
    $sqlDocente,
    [$idDocente]
);


if (!$resultadoDocente) {

    responder([
        "exito" => false,
        "mensaje" => "Error al consultar los datos del docente."
    ]);

}


if (pg_num_rows($resultadoDocente) === 0) {

    responder([
        "exito" => false,
        "mensaje" => "No se encontró el perfil del docente."
    ]);

}


$docente = pg_fetch_assoc(
    $resultadoDocente
);


/* =========================================================
   OBTENER ESTUDIANTES Y SU PROGRESO
   ========================================================= */

$sqlEstudiantes = "

    SELECT

        e.id_estudiante,

        e.nombre,

        e.apellido,

        e.grado,

        u.usuario,

        COUNT(
            DISTINCT
            CASE
                WHEN ie.id_intento IS NOT NULL
                THEN ex.id_experimento
            END
        ) AS experimentos,

        COUNT(
            ie.id_intento
        ) AS veces,

        COUNT(
            ie.id_intento
        ) AS evaluaciones,

        CASE
            WHEN COUNT(ie.id_intento) > 0
            THEN ROUND(
                MAX(ie.nota),
                2
            )
            ELSE NULL
        END AS mejor_nota,

        CASE
            WHEN COUNT(ie.id_intento) > 0
            THEN ROUND(
                AVG(ie.nota),
                2
            )
            ELSE NULL
        END AS promedio

    FROM estudiante e

    INNER JOIN usuario u
        ON u.id_usuario = e.id_estudiante

    LEFT JOIN experimento ex
        ON ex.grado = e.grado
       AND ex.activo = TRUE

    LEFT JOIN evaluacion ev
        ON ev.id_experimento = ex.id_experimento
       AND ev.activa = TRUE

    LEFT JOIN intento_evaluacion ie
        ON ie.id_evaluacion = ev.id_evaluacion
       AND ie.id_estudiante = e.id_estudiante

    WHERE u.rol = 'estudiante'
      AND u.activo = TRUE

    GROUP BY
        e.id_estudiante,
        e.nombre,
        e.apellido,
        e.grado,
        u.usuario

    ORDER BY
        e.grado,
        e.apellido,
        e.nombre

";


$resultadoEstudiantes = pg_query(
    $conexion,
    $sqlEstudiantes
);


if (!$resultadoEstudiantes) {

    responder([
        "exito" => false,
        "mensaje" => "Error al consultar los estudiantes."
    ]);

}


/* =========================================================
   CREAR ESTRUCTURA POR GRADOS
   ========================================================= */

$grados = [

    "7" => [],

    "8" => [],

    "9" => []

];


/* =========================================================
   CONTADORES GENERALES
   ========================================================= */

$totalEstudiantes = 0;

$totalExperimentos = 0;

$totalEvaluaciones = 0;


/* =========================================================
   RECORRER ESTUDIANTES
   ========================================================= */

while ($fila = pg_fetch_assoc($resultadoEstudiantes)) {

    $grado = (string)$fila["grado"];

    $idEstudiante = (int)$fila["id_estudiante"];

    $experimentos = (int)$fila["experimentos"];

    $veces = (int)$fila["veces"];

    $evaluaciones = (int)$fila["evaluaciones"];


    /* =====================================================
       OBTENER LOS 9 EXPERIMENTOS DEL GRADO
       ===================================================== */

    $sqlDetalle = "

        SELECT

            ex.id_experimento,

            ex.nombre AS experimento,

            ex.area,

            COUNT(ie.id_intento) AS veces_realizado,

            COUNT(ie.id_intento) AS evaluaciones,

            CASE
                WHEN COUNT(ie.id_intento) > 0
                THEN ROUND(
                    MAX(ie.nota),
                    2
                )
                ELSE NULL
            END AS mejor_nota,

            CASE
                WHEN COUNT(ie.id_intento) > 0
                THEN ROUND(
                    AVG(ie.nota),
                    2
                )
                ELSE NULL
            END AS promedio

        FROM experimento ex

        LEFT JOIN evaluacion ev
            ON ev.id_experimento = ex.id_experimento
           AND ev.activa = TRUE

        LEFT JOIN intento_evaluacion ie
            ON ie.id_evaluacion = ev.id_evaluacion
           AND ie.id_estudiante = $1

        WHERE ex.grado = $2
          AND ex.activo = TRUE

        GROUP BY

            ex.id_experimento,
            ex.nombre,
            ex.area

        ORDER BY

            ex.area,
            ex.id_experimento

    ";


    $resultadoDetalle = pg_query_params(

        $conexion,

        $sqlDetalle,

        [
            $idEstudiante,
            $grado
        ]

    );


    $experimentosDetalle = [];


    if ($resultadoDetalle) {

        while (
            $detalle = pg_fetch_assoc(
                $resultadoDetalle
            )
        ) {

            $experimentosDetalle[] = [

                "id_experimento" =>
                    (int)$detalle["id_experimento"],

                "experimento" =>
                    $detalle["experimento"],

                "area" =>
                    $detalle["area"],

                "veces_realizado" =>
                    (int)$detalle["veces_realizado"],

                "evaluaciones" =>
                    (int)$detalle["evaluaciones"],

                "mejor_nota" =>
                    $detalle["mejor_nota"] !== null
                        ? (float)$detalle["mejor_nota"]
                        : null,

                "promedio" =>
                    $detalle["promedio"] !== null
                        ? (float)$detalle["promedio"]
                        : null

            ];

        }

    }


    /* =====================================================
       CONVERTIR NOTAS GENERALES
       ===================================================== */

    $mejorNota = null;

    if ($fila["mejor_nota"] !== null) {

        $mejorNota =
            (float)$fila["mejor_nota"];

    }


    $promedio = null;

    if ($fila["promedio"] !== null) {

        $promedio =
            (float)$fila["promedio"];

    }


    /* =====================================================
       CREAR DATOS DEL ESTUDIANTE
       ===================================================== */

    $estudiante = [

        "id_estudiante" =>
            $idEstudiante,

        "nombre" =>
            $fila["nombre"],

        "apellido" =>
            $fila["apellido"],

        "nombre_completo" =>
            $fila["nombre"]
            . " "
            . $fila["apellido"],

        "usuario" =>
            $fila["usuario"],

        "grado" =>
            (int)$fila["grado"],

        "experimentos" =>
            $experimentos,

        "veces" =>
            $veces,

        "evaluaciones" =>
            $evaluaciones,

        "mejor_nota" =>
            $mejorNota,

        "promedio" =>
            $promedio,

        "experimentos_detalle" =>
            $experimentosDetalle

    ];


    /* =====================================================
       GUARDAR EN SU GRADO
       ===================================================== */

    if (isset($grados[$grado])) {

        $grados[$grado][] =
            $estudiante;

    }


    /* =====================================================
       ACTUALIZAR CONTADORES
       ===================================================== */

    $totalEstudiantes++;

    $totalExperimentos +=
        $experimentos;

    $totalEvaluaciones +=
        $evaluaciones;

}


/* =========================================================
   ENVIAR RESPUESTA
   ========================================================= */

responder([

    "exito" => true,

    "mensaje" =>
        "Información cargada correctamente.",

    "docente" => [

        "id" =>
            $idDocente,

        "nombre" =>
            $docente["nombre"],

        "apellido" =>
            $docente["apellido"],

        "nombre_completo" =>
            $docente["nombre"]
            . " "
            . $docente["apellido"],

        "usuario" =>
            $docente["usuario"]

    ],

    "resumen" => [

        "total_estudiantes" =>
            $totalEstudiantes,

        "total_experimentos" =>
            $totalExperimentos,

        "total_evaluaciones" =>
            $totalEvaluaciones

    ],

    "grados" =>
        $grados

]);

?>