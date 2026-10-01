<?php

session_start();

require_once "conexion.php";
require_once "fpdf/fpdf.php";


/* =========================================================
   VERIFICAR SESIÓN DEL DOCENTE
========================================================= */

if (
    !isset($_SESSION["id_usuario"]) ||
    !isset($_SESSION["rol"]) ||
    $_SESSION["rol"] !== "docente"
) {
    die("Acceso no autorizado.");
}


/* =========================================================
   OBTENER INFORMACIÓN DEL DOCENTE
========================================================= */

$idDocente = $_SESSION["id_usuario"];

$sqlDocente = "
    SELECT
        nombre,
        apellido
    FROM docente
    WHERE id_docente = $1
";

$resultadoDocente = pg_query_params(
    $conexion,
    $sqlDocente,
    [$idDocente]
);

if (
    !$resultadoDocente ||
    pg_num_rows($resultadoDocente) === 0
) {
    die("No se encontró la información del docente.");
}

$docente = pg_fetch_assoc($resultadoDocente);

$nombreDocente =
    $docente["nombre"] .
    " " .
    $docente["apellido"];


/* =========================================================
   ESTADÍSTICAS GENERALES
========================================================= */

$sqlResumen = "

    SELECT

        COUNT(
            DISTINCT e.id_estudiante
        ) AS total_estudiantes,

        COUNT(
            DISTINCT
            CASE
                WHEN ie.id_intento IS NOT NULL
                THEN ex.id_experimento
            END
        ) AS experimentos_realizados,

        COUNT(
            ie.id_intento
        ) AS evaluaciones_realizadas,

        CASE
            WHEN COUNT(ie.id_intento) > 0
            THEN ROUND(
                AVG(ie.nota),
                2
            )
            ELSE NULL
        END AS promedio_general

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

    WHERE
        u.rol = 'estudiante'
        AND u.activo = TRUE
";


$resultadoResumen = pg_query(
    $conexion,
    $sqlResumen
);

if (!$resultadoResumen) {
    die("Error al obtener el resumen general.");
}

$resumen = pg_fetch_assoc(
    $resultadoResumen
);

$totalEstudiantes =
    (int)$resumen["total_estudiantes"];

$experimentosRealizados =
    (int)$resumen["experimentos_realizados"];

$evaluacionesRealizadas =
    (int)$resumen["evaluaciones_realizadas"];

$promedioGeneral =
    $resumen["promedio_general"] !== null
        ? number_format(
            (float)$resumen["promedio_general"],
            2
        )
        : "-";


/* =========================================================
   OBTENER ESTUDIANTES
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
        ) AS veces_realizados,

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

    WHERE
        u.rol = 'estudiante'
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
    die("Error al obtener los estudiantes.");
}


/* =========================================================
   GUARDAR ESTUDIANTES PARA USARLOS
   EN APROBADOS Y NECESITAN MEJORAR
========================================================= */

$listaEstudiantes = [];

while (
    $fila = pg_fetch_assoc(
        $resultadoEstudiantes
    )
) {
    $listaEstudiantes[] = $fila;
}


/* =========================================================
   RESUMEN POR GRADO
========================================================= */

$sqlGrados = "

    SELECT

        e.grado,

        COUNT(
            DISTINCT e.id_estudiante
        ) AS estudiantes,

        CASE
            WHEN COUNT(ie.id_intento) > 0
            THEN ROUND(
                AVG(ie.nota),
                2
            )
            ELSE NULL
        END AS promedio,

        (
            SELECT

                e2.nombre ||
                ' ' ||
                e2.apellido

            FROM estudiante e2

            INNER JOIN usuario u2
                ON u2.id_usuario =
                   e2.id_estudiante

            INNER JOIN intento_evaluacion ie2
                ON ie2.id_estudiante =
                   e2.id_estudiante
               AND EXISTS (
                    SELECT 1
                    FROM evaluacion ev2
                    INNER JOIN experimento ex2
                        ON ex2.id_experimento = ev2.id_experimento
                    WHERE ev2.id_evaluacion = ie2.id_evaluacion
                      AND ex2.grado = e2.grado
                      AND ex2.activo = TRUE
                      AND ev2.activa = TRUE
               )

            WHERE

                e2.grado = e.grado

                AND u2.rol = 'estudiante'

                AND u2.activo = TRUE

            GROUP BY

                e2.id_estudiante,
                e2.nombre,
                e2.apellido

            ORDER BY

                AVG(ie2.nota) DESC,

                e2.apellido ASC,

                e2.nombre ASC

            LIMIT 1

        ) AS mejor_estudiante,

        (

            SELECT

                ROUND(
                    AVG(ie3.nota),
                    2
                )

            FROM intento_evaluacion ie3

            INNER JOIN estudiante e3
                ON e3.id_estudiante =
                   ie3.id_estudiante

            INNER JOIN evaluacion ev3
                ON ev3.id_evaluacion = ie3.id_evaluacion
               AND ev3.activa = TRUE

            INNER JOIN experimento ex3
                ON ex3.id_experimento = ev3.id_experimento
               AND ex3.grado = e3.grado
               AND ex3.activo = TRUE

            INNER JOIN usuario u3
                ON u3.id_usuario =
                   e3.id_estudiante

            WHERE

                e3.grado = e.grado

                AND u3.rol = 'estudiante'

                AND u3.activo = TRUE

            GROUP BY

                e3.id_estudiante

            ORDER BY

                AVG(ie3.nota) DESC

            LIMIT 1

        ) AS mejor_promedio

    FROM estudiante e

    INNER JOIN usuario u
        ON u.id_usuario =
           e.id_estudiante

    LEFT JOIN intento_evaluacion ie
        ON ie.id_estudiante =
           e.id_estudiante
       AND EXISTS (
            SELECT 1
            FROM evaluacion ev_grado
            INNER JOIN experimento ex_grado
                ON ex_grado.id_experimento = ev_grado.id_experimento
            WHERE ev_grado.id_evaluacion = ie.id_evaluacion
              AND ex_grado.grado = e.grado
              AND ex_grado.activo = TRUE
              AND ev_grado.activa = TRUE
       )

    WHERE

        u.rol = 'estudiante'

        AND u.activo = TRUE

    GROUP BY

        e.grado

    ORDER BY

        e.grado

";


$resultadoGrados = pg_query(
    $conexion,
    $sqlGrados
);

if (!$resultadoGrados) {
    die("Error al obtener el resumen por grado.");
}


/* =========================================================
   RESUMEN DE RENDIMIENTO
========================================================= */

$aprobados = 0;

$necesitanMejorar = 0;

$totalRendimiento = 0;

$listaAprobados = [];

$listaNecesitanMejorar = [];


foreach (
    $listaEstudiantes
    as $estudiante
) {

    /*
       Solamente clasificamos estudiantes
       que ya tienen evaluaciones.
    */

    if (
        $estudiante["promedio"] === null
    ) {
        continue;
    }


    $promedio =
        (float)$estudiante["promedio"];


    $totalRendimiento++;


    if ($promedio >= 6) {

        $aprobados++;

        $listaAprobados[] =
            $estudiante;

    } else {

        $necesitanMejorar++;

        $listaNecesitanMejorar[] =
            $estudiante;
    }
}


/* =========================================================
   PORCENTAJES
========================================================= */

if ($totalRendimiento > 0) {

    $porcentajeAprobacion =
        round(
            (
                $aprobados /
                $totalRendimiento
            ) * 100,
            2
        );

    $porcentajeMejorar =
        round(
            (
                $necesitanMejorar /
                $totalRendimiento
            ) * 100,
            2
        );

} else {

    $porcentajeAprobacion = 0;

    $porcentajeMejorar = 0;
}


/* =========================================================
   MENSAJE DE RENDIMIENTO
========================================================= */

if ($totalRendimiento === 0) {

    $mensajeRendimiento =
        "No hay estudiantes con evaluaciones registradas.";

} elseif ($porcentajeAprobacion >= 80) {

    $mensajeRendimiento =
        "El rendimiento general de los estudiantes es satisfactorio.";

} elseif ($porcentajeAprobacion >= 60) {

    $mensajeRendimiento =
        "El rendimiento general es aceptable, pero se recomienda reforzar algunos contenidos.";

} else {

    $mensajeRendimiento =
        "Se recomienda reforzar los contenidos y brindar mayor seguimiento a los estudiantes.";
}


/* =========================================================
   CLASE PDF
========================================================= */

class ReporteGeneralPDF extends FPDF
{

    /* =====================================================
       ENCABEZADO
    ===================================================== */

    function Header()
    {

        $this->SetFillColor(
            7,
            17,
            13
        );

        $this->Rect(
            0,
            0,
            210,
            25,
            "F"
        );


        /* Línea decorativa */

        $this->SetFillColor(
            80,
            150,
            100
        );

        $this->Rect(
            0,
            25,
            210,
            3,
            "F"
        );


        /* ECOLAB IA */

        $this->SetTextColor(
            102,
            255,
            204
        );

        $this->SetFont(
            "Arial",
            "B",
            18
        );

        $this->SetXY(
            15,
            7
        );

        $this->Cell(
            60,
            8,
            "ECOLAB IA",
            0,
            0,
            "L"
        );


        /* Subtítulo */

        $this->SetTextColor(
            220,
            230,
            225
        );

        $this->SetFont(
            "Arial",
            "",
            8
        );

        $this->SetXY(
            15,
            16
        );

        $this->Cell(
            100,
            5,
            utf8_decode(
                "Laboratorio Científico Virtual Inteligente"
            ),
            0,
            0,
            "L"
        );


        /* Título derecho */

        $this->SetFont(
            "Arial",
            "B",
            9
        );

        $this->SetTextColor(
            255,
            255,
            255
        );

        $this->SetXY(
            145,
            9
        );

        $this->Cell(
            50,
            7,
            "REPORTE GENERAL",
            0,
            0,
            "R"
        );


        $this->Ln(25);
    }


    /* =====================================================
       PIE DE PÁGINA
    ===================================================== */

    function Footer()
    {

        $this->SetY(
            -15
        );


        $this->SetDrawColor(
            80,
            150,
            100
        );


        $this->Line(
            15,
            $this->GetY(),
            195,
            $this->GetY()
        );


        $this->SetFont(
            "Arial",
            "",
            8
        );


        $this->SetTextColor(
            120,
            135,
            128
        );


        $this->Cell(
            0,
            8,
            utf8_decode(
                "EcoLab IA - Reporte general"
            ),
            0,
            0,
            "L"
        );


        $this->Cell(
            0,
            8,
            utf8_decode(
                "Página " .
                $this->PageNo()
            ),
            0,
            0,
            "R"
        );
    }
}


/* =========================================================
   CREAR PDF
========================================================= */

$pdf =
    new ReporteGeneralPDF(
        "P",
        "mm",
        "A4"
    );


$pdf->SetMargins(
    15,
    35,
    15
);


$pdf->SetAutoPageBreak(
    true,
    20
);


$pdf->AddPage();


/* =========================================================
   TÍTULO
========================================================= */

$pdf->SetTextColor(
    20,
    60,
    40
);


$pdf->SetFont(
    "Arial",
    "B",
    20
);


$pdf->Cell(
    0,
    10,
    utf8_decode(
        "Reporte general de estudiantes"
    ),
    0,
    1,
    "L"
);


$pdf->SetFont(
    "Arial",
    "",
    10
);


$pdf->SetTextColor(
    90,
    100,
    95
);


$pdf->Cell(
    0,
    7,
    utf8_decode(
        "Docente: " .
        $nombreDocente
    ),
    0,
    1,
    "L"
);


$pdf->Cell(
    0,
    7,
    utf8_decode(
        "Fecha del reporte: " .
        date("d/m/Y")
    ),
    0,
    1,
    "L"
);


$pdf->Ln(6);


/* =========================================================
   RESUMEN GENERAL
========================================================= */

$pdf->SetFont(
    "Arial",
    "B",
    12
);


$pdf->SetTextColor(
    20,
    60,
    40
);


$pdf->Cell(
    0,
    8,
    "Resumen general",
    0,
    1
);


$pdf->SetFont(
    "Arial",
    "B",
    9
);


$pdf->SetFillColor(
    230,
    245,
    237
);


$pdf->SetTextColor(
    30,
    60,
    45
);


$pdf->Cell(
    43,
    9,
    utf8_decode("Estudiantes"),
    1,
    0,
    "C",
    true
);


$pdf->Cell(
    43,
    9,
    utf8_decode("Experimentos"),
    1,
    0,
    "C",
    true
);


$pdf->Cell(
    43,
    9,
    utf8_decode("Evaluaciones"),
    1,
    0,
    "C",
    true
);


$pdf->Cell(
    43,
    9,
    utf8_decode("Promedio"),
    1,
    1,
    "C",
    true
);


$pdf->SetFont(
    "Arial",
    "B",
    11
);


$pdf->SetFillColor(
    248,
    250,
    249
);


$pdf->Cell(
    43,
    11,
    $totalEstudiantes,
    1,
    0,
    "C",
    true
);


$pdf->Cell(
    43,
    11,
    $experimentosRealizados,
    1,
    0,
    "C",
    true
);


$pdf->Cell(
    43,
    11,
    $evaluacionesRealizadas,
    1,
    0,
    "C",
    true
);


$pdf->Cell(
    43,
    11,
    $promedioGeneral,
    1,
    1,
    "C",
    true
);


$pdf->Ln(8);


/* =========================================================
   RESUMEN POR GRADO
========================================================= */

$pdf->SetFont(
    "Arial",
    "B",
    12
);


$pdf->SetTextColor(
    20,
    60,
    40
);


$pdf->Cell(
    0,
    8,
    utf8_decode(
        "Resumen por grado"
    ),
    0,
    1
);


$pdf->SetDrawColor(
    80,
    150,
    100
);


$pdf->SetLineWidth(
    0.6
);


$pdf->Line(
    15,
    $pdf->GetY(),
    195,
    $pdf->GetY()
);


$pdf->Ln(5);


/* Encabezado */

$pdf->SetFillColor(
    45,
    105,
    70
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
    30,
    9,
    "Grado",
    1,
    0,
    "C",
    true
);


$pdf->Cell(
    30,
    9,
    utf8_decode("Estudiantes"),
    1,
    0,
    "C",
    true
);


$pdf->Cell(
    70,
    9,
    utf8_decode("Mejor estudiante"),
    1,
    0,
    "C",
    true
);


$pdf->Cell(
    45,
    9,
    utf8_decode("Mejor promedio"),
    1,
    1,
    "C",
    true
);


/* Filas */

$pdf->SetFont(
    "Arial",
    "",
    8
);


$pdf->SetTextColor(
    40,
    45,
    42
);


$contadorGrado = 0;


while (
    $gradoData =
        pg_fetch_assoc(
            $resultadoGrados
        )
) {

    if (
        $contadorGrado % 2 === 0
    ) {

        $pdf->SetFillColor(
            248,
            250,
            249
        );

    } else {

        $pdf->SetFillColor(
            232,
            244,
            236
        );
    }


    $gradoTexto =
        $gradoData["grado"] .
        utf8_decode("º");


    $cantidad =
        $gradoData["estudiantes"];


    $mejorEstudiante =
        $gradoData["mejor_estudiante"]
        !== null

        ? utf8_decode(
            $gradoData["mejor_estudiante"]
        )

        : "-";


    $mejorPromedio =
        $gradoData["mejor_promedio"]
        !== null

        ? number_format(
            (float)$gradoData["mejor_promedio"],
            2
        )

        : "-";


    $pdf->Cell(
        30,
        9,
        $gradoTexto,
        1,
        0,
        "C",
        true
    );


    $pdf->Cell(
        30,
        9,
        $cantidad,
        1,
        0,
        "C",
        true
    );


    $pdf->Cell(
        70,
        9,
        $mejorEstudiante,
        1,
        0,
        "L",
        true
    );


    $pdf->Cell(
        45,
        9,
        $mejorPromedio,
        1,
        1,
        "C",
        true
    );


    $contadorGrado++;
}


if (
    $contadorGrado === 0
) {

    $pdf->SetFont(
        "Arial",
        "",
        9
    );


    $pdf->SetTextColor(
        100,
        100,
        100
    );


    $pdf->Cell(
        175,
        10,
        utf8_decode(
            "No hay información por grado."
        ),
        1,
        1,
        "C"
    );
}


$pdf->Ln(8);


/* =========================================================
   RESUMEN DE RENDIMIENTO
========================================================= */

$pdf->SetFont(
    "Arial",
    "B",
    12
);


$pdf->SetTextColor(
    20,
    60,
    40
);


$pdf->Cell(
    0,
    8,
    utf8_decode(
        "Resumen de rendimiento"
    ),
    0,
    1
);


$pdf->SetDrawColor(
    80,
    150,
    100
);


$pdf->SetLineWidth(
    0.6
);


$pdf->Line(
    15,
    $pdf->GetY(),
    195,
    $pdf->GetY()
);


$pdf->Ln(5);


/* Encabezado */

$pdf->SetFillColor(
    45,
    105,
    70
);


$pdf->SetTextColor(
    255,
    255,
    255
);


$pdf->SetFont(
    "Arial",
    "B",
    9
);


$pdf->Cell(
    60,
    9,
    utf8_decode("Indicador"),
    1,
    0,
    "C",
    true
);


$pdf->Cell(
    45,
    9,
    utf8_decode("Cantidad"),
    1,
    0,
    "C",
    true
);


$pdf->Cell(
    70,
    9,
    utf8_decode("Porcentaje"),
    1,
    1,
    "C",
    true
);


/* =========================================================
   APROBADOS
========================================================= */

$pdf->SetFont(
    "Arial",
    "",
    9
);


$pdf->SetTextColor(
    40,
    45,
    42
);


$pdf->SetFillColor(
    235,
    248,
    238
);


$pdf->Cell(
    60,
    9,
    utf8_decode(
        "Estudiantes aprobados"
    ),
    1,
    0,
    "L",
    true
);


$pdf->Cell(
    45,
    9,
    $aprobados,
    1,
    0,
    "C",
    true
);


$pdf->Cell(
    70,
    9,
    number_format(
        $porcentajeAprobacion,
        2
    ) . "%",
    1,
    1,
    "C",
    true
);


/* =========================================================
   NECESITAN MEJORAR
========================================================= */

$pdf->SetFillColor(
    252,
    240,
    240
);


$pdf->Cell(
    60,
    9,
    utf8_decode(
        "Necesitan mejorar"
    ),
    1,
    0,
    "L",
    true
);


$pdf->Cell(
    45,
    9,
    $necesitanMejorar,
    1,
    0,
    "C",
    true
);


$pdf->Cell(
    70,
    9,
    number_format(
        $porcentajeMejorar,
        2
    ) . "%",
    1,
    1,
    "C",
    true
);


/* =========================================================
   TOTAL EVALUADOS
========================================================= */

$pdf->SetFillColor(
    240,
    245,
    242
);


$pdf->Cell(
    60,
    9,
    utf8_decode(
        "Total de estudiantes evaluados"
    ),
    1,
    0,
    "L",
    true
);


$pdf->Cell(
    45,
    9,
    $totalRendimiento,
    1,
    0,
    "C",
    true
);


$pdf->Cell(
    70,
    9,
    "100.00%",
    1,
    1,
    "C",
    true
);


$pdf->Ln(4);


/* =========================================================
   INTERPRETACIÓN
========================================================= */

$pdf->SetFont(
    "Arial",
    "I",
    9
);


$pdf->SetTextColor(
    80,
    80,
    80
);


$pdf->MultiCell(
    175,
    6,
    utf8_decode(
        $mensajeRendimiento
    ),
    0,
    "L"
);


$pdf->Ln(8);


/* =========================================================
   ESTUDIANTES APROBADOS
========================================================= */

$pdf->SetFont(
    "Arial",
    "B",
    12
);


$pdf->SetTextColor(
    20,
    90,
    45
);


$pdf->Cell(
    0,
    8,
    utf8_decode(
        "Estudiantes aprobados"
    ),
    0,
    1
);


$pdf->SetDrawColor(
    80,
    150,
    100
);


$pdf->Line(
    15,
    $pdf->GetY(),
    195,
    $pdf->GetY()
);


$pdf->Ln(4);


/* Encabezado */

$pdf->SetFillColor(
    45,
    105,
    70
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
    70,
    9,
    utf8_decode("Estudiante"),
    1,
    0,
    "C",
    true
);


$pdf->Cell(
    35,
    9,
    "Usuario",
    1,
    0,
    "C",
    true
);


$pdf->Cell(
    30,
    9,
    "Grado",
    1,
    0,
    "C",
    true
);


$pdf->Cell(
    40,
    9,
    "Promedio",
    1,
    1,
    "C",
    true
);


/* Filas aprobados */

$pdf->SetFont(
    "Arial",
    "",
    8
);


$pdf->SetTextColor(
    40,
    45,
    42
);


if (
    count($listaAprobados) > 0
) {

    $contadorAprobados = 0;


    foreach (
        $listaAprobados
        as $estudiante
    ) {

        if (
            $contadorAprobados % 2 === 0
        ) {

            $pdf->SetFillColor(
                235,
                248,
                238
            );

        } else {

            $pdf->SetFillColor(
                248,
                250,
                249
            );
        }


        $nombre =
            $estudiante["nombre"] .
            " " .
            $estudiante["apellido"];


        $grado =
            $estudiante["grado"] .
            utf8_decode("º");


        $promedio =
            number_format(
                (float)$estudiante["promedio"],
                2
            );


        $pdf->Cell(
            70,
            9,
            utf8_decode($nombre),
            1,
            0,
            "L",
            true
        );


        $pdf->Cell(
            35,
            9,
            utf8_decode(
                $estudiante["usuario"]
            ),
            1,
            0,
            "C",
            true
        );


        $pdf->Cell(
            30,
            9,
            $grado,
            1,
            0,
            "C",
            true
        );


        $pdf->Cell(
            40,
            9,
            $promedio,
            1,
            1,
            "C",
            true
        );


        $contadorAprobados++;
    }

} else {

    $pdf->SetFillColor(
        248,
        250,
        249
    );


    $pdf->Cell(
        175,
        10,
        utf8_decode(
            "No hay estudiantes aprobados."
        ),
        1,
        1,
        "C",
        true
    );
}


$pdf->Ln(8);


/* =========================================================
   ESTUDIANTES QUE NECESITAN MEJORAR
========================================================= */

$pdf->SetFont(
    "Arial",
    "B",
    12
);


$pdf->SetTextColor(
    160,
    60,
    50
);


$pdf->Cell(
    0,
    8,
    utf8_decode(
        "Estudiantes que necesitan mejorar"
    ),
    0,
    1
);


$pdf->SetDrawColor(
    180,
    100,
    90
);


$pdf->Line(
    15,
    $pdf->GetY(),
    195,
    $pdf->GetY()
);


$pdf->Ln(4);


/* Encabezado */

$pdf->SetFillColor(
    120,
    75,
    65
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
    70,
    9,
    utf8_decode("Estudiante"),
    1,
    0,
    "C",
    true
);


$pdf->Cell(
    35,
    9,
    "Usuario",
    1,
    0,
    "C",
    true
);


$pdf->Cell(
    30,
    9,
    "Grado",
    1,
    0,
    "C",
    true
);


$pdf->Cell(
    40,
    9,
    "Promedio",
    1,
    1,
    "C",
    true
);


/* Filas necesitan mejorar */

$pdf->SetFont(
    "Arial",
    "",
    8
);


$pdf->SetTextColor(
    40,
    45,
    42
);


if (
    count($listaNecesitanMejorar) > 0
) {

    $contadorMejorar = 0;


    foreach (
        $listaNecesitanMejorar
        as $estudiante
    ) {

        if (
            $contadorMejorar % 2 === 0
        ) {

            $pdf->SetFillColor(
                252,
                240,
                240
            );

        } else {

            $pdf->SetFillColor(
                248,
                250,
                249
            );
        }


        $nombre =
            $estudiante["nombre"] .
            " " .
            $estudiante["apellido"];


        $grado =
            $estudiante["grado"] .
            utf8_decode("º");


        $promedio =
            number_format(
                (float)$estudiante["promedio"],
                2
            );


        $pdf->Cell(
            70,
            9,
            utf8_decode($nombre),
            1,
            0,
            "L",
            true
        );


        $pdf->Cell(
            35,
            9,
            utf8_decode(
                $estudiante["usuario"]
            ),
            1,
            0,
            "C",
            true
        );


        $pdf->Cell(
            30,
            9,
            $grado,
            1,
            0,
            "C",
            true
        );


        $pdf->Cell(
            40,
            9,
            $promedio,
            1,
            1,
            "C",
            true
        );


        $contadorMejorar++;
    }

} else {

    $pdf->SetFillColor(
        248,
        250,
        249
    );


    $pdf->Cell(
        175,
        10,
        utf8_decode(
            "No hay estudiantes que necesiten mejorar."
        ),
        1,
        1,
        "C",
        true
    );
}


/* =========================================================
   MENSAJE FINAL
========================================================= */

$pdf->Ln(8);


$pdf->SetFont(
    "Arial",
    "I",
    8
);


$pdf->SetTextColor(
    100,
    110,
    105
);


$pdf->MultiCell(
    0,
    5,
    utf8_decode(
        "Este reporte presenta un resumen general del " .
        "progreso de los estudiantes registrados en " .
        "EcoLab IA."
    ),
    0,
    "L"
);


/* =========================================================
   MOSTRAR PDF
========================================================= */

$pdf->Output(
    "I",
    "Reporte_General_EcoLab.pdf"
);

?>