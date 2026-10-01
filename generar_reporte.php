<?php

/* =========================================================
   GENERAR REPORTE PDF - ECOLAB IA
   ========================================================= */

session_start();

require_once "conexion.php";
require_once __DIR__ . '/fpdf/fpdf.php';


/* =========================================================
   VERIFICAR SESIÓN
   ========================================================= */

if (!isset($_SESSION["id_usuario"])) {
    die("No hay una sesión iniciada.");
}


/* =========================================================
   VERIFICAR ROL DOCENTE
   ========================================================= */

if (
    !isset($_SESSION["rol"]) ||
    $_SESSION["rol"] !== "docente"
) {
    die("No tienes permisos para generar reportes.");
}


/* =========================================================
   OBTENER ID DEL ESTUDIANTE
   ========================================================= */

$idEstudiante =
    isset($_GET["id_estudiante"])
        ? (int)$_GET["id_estudiante"]
        : 0;

if ($idEstudiante <= 0) {
    die("Estudiante no válido.");
}


/* =========================================================
   BUSCAR DATOS DEL ESTUDIANTE
   ========================================================= */

$sqlEstudiante = "
    SELECT
        id_estudiante,
        nombre,
        apellido,
        grado
    FROM estudiante
    WHERE id_estudiante = $1
    LIMIT 1
";

$resultadoEstudiante =
    pg_query_params(
        $conexion,
        $sqlEstudiante,
        [$idEstudiante]
    );

if (!$resultadoEstudiante) {
    die("Error al consultar el estudiante.");
}

if (pg_num_rows($resultadoEstudiante) === 0) {
    die("El estudiante no existe.");
}

$estudiante =
    pg_fetch_assoc(
        $resultadoEstudiante
    );


/* =========================================================
   CONSULTAR EXPERIMENTOS
   ========================================================= */

$sqlExperimentos = "
    SELECT

        e.id_experimento,

        e.nombre AS experimento,

        e.area,

        COUNT(ie.id_intento) AS veces_realizado,

        COUNT(ie.id_intento) AS evaluaciones,

        COALESCE(
            MAX(ie.nota),
            0
        ) AS mejor_nota,

        COALESCE(
            ROUND(
                AVG(ie.nota),
                2
            ),
            0
        ) AS promedio

    FROM experimento e

    LEFT JOIN evaluacion ev
        ON ev.id_experimento =
           e.id_experimento

    LEFT JOIN intento_evaluacion ie
        ON ie.id_evaluacion =
           ev.id_evaluacion

        AND ie.id_estudiante =
            $1

    WHERE e.activo = TRUE
      AND e.grado = $2

    GROUP BY
        e.id_experimento,
        e.nombre,
        e.area

    ORDER BY
        e.area,
        e.id_experimento
";

$resultadoExperimentos =
    pg_query_params(
        $conexion,
        $sqlExperimentos,
        [
            $idEstudiante,
            (int)$estudiante["grado"]
        ]
    );

if (!$resultadoExperimentos) {
    die("Error al consultar los experimentos.");
}


/* =========================================================
   GUARDAR RESULTADOS
   ========================================================= */

$experimentos = [];

$totalVeces = 0;

$totalExperimentosRealizados = 0;

$totalEvaluaciones = 0;

$sumaNotas = 0;

$cantidadNotas = 0;


while (
    $fila =
    pg_fetch_assoc(
        $resultadoExperimentos
    )
) {

    $veces =
        (int)$fila["veces_realizado"];

    $evaluaciones =
        (int)$fila["evaluaciones"];

    $mejorNota =
        (float)$fila["mejor_nota"];

    $promedio =
        (float)$fila["promedio"];


    if ($veces > 0) {

        $totalVeces += $veces;

        $totalExperimentosRealizados++;

        $totalEvaluaciones += $evaluaciones;

        $sumaNotas +=
            $promedio * $evaluaciones;

        $cantidadNotas +=
            $evaluaciones;
    }


    $experimentos[] = [

        "nombre" =>
            $fila["experimento"],

        "area" =>
            $fila["area"],

        "veces" =>
            $veces,

        "evaluaciones" =>
            $evaluaciones,

        "mejor_nota" =>
            $mejorNota,

        "promedio" =>
            $promedio
    ];
}


/* =========================================================
   PROMEDIO GENERAL
   ========================================================= */

if ($cantidadNotas > 0) {

    $promedioGeneral =
        round(
            $sumaNotas / $cantidadNotas,
            2
        );

} else {

    $promedioGeneral = 0;
}


/* =========================================================
   CONVERTIR ÁREA
   ========================================================= */

function nombreArea($area)
{

    switch ($area) {

        case "fisica":
            return "Física";

        case "quimica":
            return "Química";

        case "biologia":
            return "Biología";

        default:
            return ucfirst($area);
    }
}


/* =========================================================
   CREAR PDF
   ========================================================= */

$pdf =
    new FPDF(
        "P",
        "mm",
        "A4"
    );

$pdf->AddPage();

$pdf->SetAutoPageBreak(
    true,
    20
);


/* =========================================================
   COLORES ECOLAB
   ========================================================= */

/*
   Verde oscuro principal
*/
$pdf->SetFillColor(
    20,
    70,
    45
);

/*
   Verde claro
*/
$pdf->SetTextColor(
    20,
    70,
    45
);


/* =========================================================
   ENCABEZADO DECORATIVO
   ========================================================= */

/*
   Franja superior
*/

$pdf->SetFillColor(
    20,
    70,
    45
);

$pdf->Rect(
    0,
    0,
    210,
    30,
    "F"
);


/*
   Círculos decorativos
*/

$pdf->SetFillColor(
    80,
    150,
    100
);

$pdf->Rect(
    0,
    27,
    210,
    3,
    "F"
);

/*
   Texto ECOLAB IA
*/

$pdf->SetTextColor(
    255,
    255,
    255
);

$pdf->SetFont(
    "Arial",
    "B",
    23
);

$pdf->SetY(7);

$pdf->Cell(
    0,
    10,
    "ECOLAB IA",
    0,
    1,
    "C"
);


/*
   Subtítulo
*/

$pdf->SetFont(
    "Arial",
    "",
    9
);

$pdf->Cell(
    0,
    6,
    utf8_decode(
        "Laboratorio Científico Virtual Inteligente"
    ),
    0,
    1,
    "C"
);


/*
   Regresar color del texto
*/

$pdf->SetTextColor(
    0,
    0,
    0
);

$pdf->SetY(38);


/* =========================================================
   TÍTULO DEL REPORTE
   ========================================================= */

$pdf->SetFont(
    "Arial",
    "B",
    16
);

$pdf->SetTextColor(
    20,
    70,
    45
);

$pdf->Cell(
    0,
    9,
    "REPORTE DE ESTUDIANTE",
    0,
    1,
    "C"
);


/*
   Línea decorativa
*/

$pdf->SetDrawColor(
    80,
    150,
    100
);

$pdf->SetLineWidth(
    1
);

$pdf->Line(
    55,
    50,
    155,
    50
);

$pdf->SetLineWidth(
    0.2
);

$pdf->Ln(8);


/* =========================================================
   DATOS DEL ESTUDIANTE
   ========================================================= */

$pdf->SetTextColor(
    0,
    0,
    0
);

$pdf->SetFont(
    "Arial",
    "B",
    11
);

$pdf->Cell(
    35,
    8,
    "Estudiante:",
    0,
    0
);

$pdf->SetFont(
    "Arial",
    "",
    11
);

$nombreCompleto =
    $estudiante["nombre"]
    . " "
    . $estudiante["apellido"];

$pdf->Cell(
    0,
    8,
    utf8_decode(
        $nombreCompleto
    ),
    0,
    1
);


$pdf->SetFont(
    "Arial",
    "B",
    11
);

$pdf->Cell(
    35,
    8,
    "Grado:",
    0,
    0
);

$pdf->SetFont(
    "Arial",
    "",
    11
);

$pdf->Cell(
    0,
    8,
    $estudiante["grado"] . ".",
    0,
    1
);


/* =========================================================
   LÍNEA SEPARADORA
   ========================================================= */

$pdf->Ln(3);

$pdf->SetDrawColor(
    190,
    210,
    195
);

$pdf->Line(
    15,
    $pdf->GetY(),
    195,
    $pdf->GetY()
);

$pdf->Ln(6);


/* =========================================================
   RESUMEN GENERAL
   ========================================================= */

$pdf->SetTextColor(
    20,
    70,
    45
);

$pdf->SetFont(
    "Arial",
    "B",
    13
);

$pdf->Cell(
    0,
    9,
    utf8_decode("Resumen general"),
    0,
    1
);


/* =========================================================
   TABLA DEL RESUMEN
   ========================================================= */

$pdf->SetFont(
    "Arial",
    "B",
    10
);


/*
   Encabezado izquierdo
*/

$pdf->SetFillColor(
    225,
    240,
    228
);

$pdf->SetTextColor(
    20,
    70,
    45
);

$pdf->Cell(
    60,
    8,
    "Indicador",
    1,
    0,
    "C",
    true
);

$pdf->Cell(
    35,
    8,
    "Resultado",
    1,
    1,
    "C",
    true
);


/*
   Datos
*/

$pdf->SetFont(
    "Arial",
    "",
    10
);

$pdf->SetTextColor(
    0,
    0,
    0
);


$pdf->Cell(
    60,
    8,
    "Experimentos realizados",
    1,
    0
);

$pdf->Cell(
    35,
    8,
    $totalExperimentosRealizados,
    1,
    1,
    "C"
);


$pdf->Cell(
    60,
    8,
    "Total de veces realizados",
    1,
    0
);

$pdf->Cell(
    35,
    8,
    $totalVeces,
    1,
    1,
    "C"
);


$pdf->Cell(
    60,
    8,
    "Evaluaciones realizadas",
    1,
    0
);

$pdf->Cell(
    35,
    8,
    $totalEvaluaciones,
    1,
    1,
    "C"
);


$pdf->Cell(
    60,
    8,
    "Promedio general",
    1,
    0
);

$pdf->Cell(
    35,
    8,
    number_format(
        $promedioGeneral,
        2
    ),
    1,
    1,
    "C"
);


$pdf->Ln(9);


/* =========================================================
   DETALLE DE EXPERIMENTOS
   ========================================================= */

$pdf->SetTextColor(
    20,
    70,
    45
);

$pdf->SetFont(
    "Arial",
    "B",
    13
);

$pdf->Cell(
    0,
    9,
    "Detalle de experimentos",
    0,
    1
);


/* =========================================================
   ENCABEZADO DE TABLA
   ========================================================= */

$pdf->SetFillColor(
    20,
    70,
    45
);

$pdf->SetTextColor(
    255,
    255,
    255
);

$pdf->SetFont(
    "Arial",
    "B",
    8
);


$pdf->Cell(
    48,
    10,
    "Experimento",
    1,
    0,
    "C",
    true
);

$pdf->Cell(
    24,
    10,
    utf8_decode("Área"),
    1,
    0,
    "C",
    true
);

$pdf->Cell(
    25,
    10,
    "Veces",
    1,
    0,
    "C",
    true
);

$pdf->Cell(
    27,
    10,
    "Evaluaciones",
    1,
    0,
    "C",
    true
);

$pdf->Cell(
    25,
    10,
    "Mejor nota",
    1,
    0,
    "C",
    true
);

$pdf->Cell(
    25,
    10,
    "Promedio",
    1,
    1,
    "C",
    true
);


/* =========================================================
   DATOS DE LA TABLA
   ========================================================= */

$pdf->SetFont(
    "Arial",
    "",
    7
);

$pdf->SetTextColor(
    0,
    0,
    0
);


$contador = 0;


foreach (
    $experimentos
    as $experimento
) {

    $nombre =
        utf8_decode(
            $experimento["nombre"]
        );

    $area =
        utf8_decode(
            nombreArea(
                $experimento["area"]
            )
        );

    $veces =
        $experimento["veces"];

    $evaluaciones =
        $experimento["evaluaciones"];

    $mejorNota =
        number_format(
            $experimento["mejor_nota"],
            2
        );

    $promedio =
        number_format(
            $experimento["promedio"],
            2
        );


    /*
       Alternar ligeramente el fondo
       de las filas.
    */

    if ($contador % 2 == 0) {

        $pdf->SetFillColor(
            245,
            249,
            245
        );

    } else {

        $pdf->SetFillColor(
            255,
            255,
            255
        );
    }


    $pdf->Cell(
        48,
        9,
        $nombre,
        1,
        0,
        "L",
        true
    );

    $pdf->Cell(
        24,
        9,
        $area,
        1,
        0,
        "C",
        true
    );

    $pdf->Cell(
        25,
        9,
        $veces,
        1,
        0,
        "C",
        true
    );

    $pdf->Cell(
        27,
        9,
        $evaluaciones,
        1,
        0,
        "C",
        true
    );

    $pdf->Cell(
        25,
        9,
        $mejorNota,
        1,
        0,
        "C",
        true
    );

    $pdf->Cell(
        25,
        9,
        $promedio,
        1,
        1,
        "C",
        true
    );


    $contador++;
}


/* =========================================================
   MENSAJE SI NO HAY EVALUACIONES
   ========================================================= */

if (
    $totalEvaluaciones === 0
) {

    $pdf->Ln(7);

    $pdf->SetFont(
        "Arial",
        "I",
        9
    );

    $pdf->SetTextColor(
        90,
        90,
        90
    );

    $pdf->Cell(
        0,
        8,
        utf8_decode(
            "El estudiante aún no ha realizado evaluaciones."
        ),
        0,
        1,
        "C"
    );
}


/* =========================================================
   DECORACIÓN FINAL
   ========================================================= */

$pdf->Ln(8);

$pdf->SetDrawColor(
    80,
    150,
    100
);

$pdf->Line(
    25,
    $pdf->GetY(),
    185,
    $pdf->GetY()
);

$pdf->Ln(5);


/* =========================================================
   PIE DEL REPORTE
   ========================================================= */

$pdf->SetFont(
    "Arial",
    "B",
    9
);

$pdf->SetTextColor(
    20,
    70,
    45
);

$pdf->Cell(
    0,
    6,
    "ECOLAB IA",
    0,
    1,
    "C"
);


$pdf->SetFont(
    "Arial",
    "I",
    8
);

$pdf->SetTextColor(
    90,
    90,
    90
);

$pdf->Cell(
    0,
    5,
    utf8_decode(
        "Laboratorio Científico Virtual Inteligente"
    ),
    0,
    1,
    "C"
);


$pdf->Cell(
    0,
    5,
    utf8_decode(
        "Ciencia - Vida - Experimentación"
    ),
    0,
    1,
    "C"
);


$pdf->Cell(
    0,
    5,
    "Reporte generado: " .
    date("d/m/Y H:i"),
    0,
    1,
    "C"
);


/* =========================================================
   NOMBRE DEL ARCHIVO
   ========================================================= */

$nombreArchivo =
    "Reporte_"
    . preg_replace(
        "/[^A-Za-z0-9_-]/",
        "_",
        $estudiante["nombre"]
        . "_"
        . $estudiante["apellido"]
    )
    . ".pdf";


/* =========================================================
   MOSTRAR PDF
   ========================================================= */

$pdf->Output(
    "I",
    $nombreArchivo
);

?>