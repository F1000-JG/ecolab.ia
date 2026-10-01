<?php
/* ============================================================
   ECOLAB IA - CONEXIÓN CENTRAL A POSTGRESQL
   - Mantiene los valores originales del proyecto.
   - Permite sobreescribirlos con variables de entorno.
   - Instala/migra automáticamente 7.º y 9.º si hace falta.
   ============================================================ */

$host       = getenv('ECOLAB_DB_HOST') ?: 'localhost';
$puerto     = getenv('ECOLAB_DB_PORT') ?: '5432';
$base_datos = getenv('ECOLAB_DB_NAME') ?: 'ecolab_ia';
$usuario    = getenv('ECOLAB_DB_USER') ?: 'postgres';
$contrasena = getenv('ECOLAB_DB_PASSWORD');
if ($contrasena === false || $contrasena === '') {
    $contrasena = '20072008';
}

$GLOBALS['ECOLAB_MIGRACION_ERROR'] = null;
$GLOBALS['ECOLAB_MIGRACION_APLICADA'] = false;

if (!function_exists('pg_connect')) {
    http_response_code(500);
    die('Error: PHP no tiene habilitada la extensión pgsql para PostgreSQL.');
}

$cadenaConexion = sprintf(
    'host=%s port=%s dbname=%s user=%s password=%s connect_timeout=5',
    $host,
    $puerto,
    $base_datos,
    $usuario,
    $contrasena
);

$conexion = @pg_connect($cadenaConexion);

if (!$conexion) {
    http_response_code(500);
    die('Error: No se pudo conectar con PostgreSQL. Revisa host, puerto, base de datos, usuario y contraseña en php/conexion.php.');
}

@pg_set_client_encoding($conexion, 'UTF8');

function ecolab_tabla_existe($conexion, $tabla)
{
    $r = @pg_query_params(
        $conexion,
        "SELECT to_regclass('public.' || $1) IS NOT NULL AS existe",
        [$tabla]
    );

    if (!$r) {
        return false;
    }

    $valor = pg_fetch_result($r, 0, 'existe');
    return $valor === 't' || $valor === true;
}

function ecolab_ejecutar_archivo_sql($conexion, $ruta)
{
    if (!is_file($ruta)) {
        throw new RuntimeException('No se encontró el archivo SQL: ' . basename($ruta));
    }

    $sql = file_get_contents($ruta);
    if ($sql === false || trim($sql) === '') {
        throw new RuntimeException('El archivo SQL está vacío o no se pudo leer: ' . basename($ruta));
    }

    $resultado = @pg_query($conexion, $sql);
    if ($resultado === false) {
        throw new RuntimeException(pg_last_error($conexion));
    }

    return true;
}

function ecolab_necesita_migracion_7_9($conexion)
{
    $r = @pg_query($conexion, "
        SELECT
            COUNT(DISTINCT ex.ruta) AS rutas,
            COUNT(DISTINCT p.id_pregunta) AS preguntas,
            COUNT(DISTINCT o.id_opcion) AS opciones
        FROM experimento ex
        LEFT JOIN evaluacion ev ON ev.id_experimento = ex.id_experimento
        LEFT JOIN pregunta p ON p.id_evaluacion = ev.id_evaluacion
        LEFT JOIN opcion o ON o.id_pregunta = p.id_pregunta
        WHERE ex.grado IN (7, 9)
          AND ex.ruta IN (
            'generador.html','horno.html','efecto.html','corrosion.html','oxidos.html',
            'sintesis.html','estraccio.html','red.html','replicacion.html',
            'laboratorio1.html','laboratorio2.html','laboratorio3.html','laboratorio4.html',
            'laboratorio5.html','laboratorio6.html','laboratorio7.html','laboratorio8.html',
            'laboratorio9.html','laboratorio10.html'
          )
    ");

    if (!$r) {
        return true;
    }

    $fila = pg_fetch_assoc($r);
    return (
        (int)($fila['rutas'] ?? 0) < 19 ||
        (int)($fila['preguntas'] ?? 0) < 152 ||
        (int)($fila['opciones'] ?? 0) < 587
    );
}

/* ============================================================
   AUTO-INICIALIZACIÓN
   ============================================================ */
try {
    $tieneUsuario = ecolab_tabla_existe($conexion, 'usuario');
    $tieneExperimento = ecolab_tabla_existe($conexion, 'experimento');

    // Base completamente nueva: crear todo.
    if (!$tieneUsuario && !$tieneExperimento) {
        ecolab_ejecutar_archivo_sql(
            $conexion,
            __DIR__ . '/../database/INSTALACION_COMPLETA.sql'
        );
        $GLOBALS['ECOLAB_MIGRACION_APLICADA'] = true;
    }
    // Base ya existente: completar únicamente 7.º y 9.º si falta algo.
    elseif ($tieneUsuario && $tieneExperimento && ecolab_necesita_migracion_7_9($conexion)) {
        ecolab_ejecutar_archivo_sql(
            $conexion,
            __DIR__ . '/../database/MIGRAR_7_Y_9.sql'
        );
        $GLOBALS['ECOLAB_MIGRACION_APLICADA'] = true;
    }
} catch (Throwable $e) {
    // No destruimos login/registro por un fallo de migración. El endpoint de
    // evaluaciones y diagnostico.php mostrarán el error exacto.
    $GLOBALS['ECOLAB_MIGRACION_ERROR'] = $e->getMessage();
    error_log('EcoLab migración: ' . $e->getMessage());
}
?>
