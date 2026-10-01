<?php

ob_start();
session_start();

require_once "conexion.php";

header("Content-Type: application/json; charset=UTF-8");

function responder($datos)
{
    // Elimina cualquier texto que PHP haya generado antes
    ob_clean();

    echo json_encode(
        $datos,
        JSON_UNESCAPED_UNICODE
    );

    exit;
}


// ==========================================
// VERIFICAR MÉTODO
// ==========================================

if ($_SERVER["REQUEST_METHOD"] !== "POST") {

    responder([
        "exito" => false,
        "mensaje" => "Acceso no permitido."
    ]);
}


// ==========================================
// RECIBIR DATOS
// ==========================================

$usuario = trim($_POST["usuario"] ?? "");
$password = $_POST["password"] ?? "";


// ==========================================
// VALIDAR CAMPOS
// ==========================================

if ($usuario === "" || $password === "") {

    responder([
        "exito" => false,
        "mensaje" => "Debes ingresar usuario y contraseña."
    ]);
}


// ==========================================
// BUSCAR USUARIO
// ==========================================

$sql = "
    SELECT
        id_usuario,
        usuario,
        password,
        rol,
        activo
    FROM usuario
    WHERE LOWER(usuario) = LOWER($1)
    LIMIT 1
";

$resultado = pg_query_params(
    $conexion,
    $sql,
    [$usuario]
);


// ==========================================
// VERIFICAR CONSULTA
// ==========================================

if (!$resultado) {

    responder([
        "exito" => false,
        "mensaje" => "Error al consultar la base de datos."
    ]);
}


// ==========================================
// VERIFICAR SI EXISTE
// ==========================================

if (pg_num_rows($resultado) === 0) {

    responder([
        "exito" => false,
        "mensaje" => "Usuario o contraseña incorrectos."
    ]);
}


// ==========================================
// OBTENER DATOS
// ==========================================

$datos = pg_fetch_assoc($resultado);


// ==========================================
// VERIFICAR CUENTA ACTIVA
// ==========================================

if ($datos["activo"] !== "t" && $datos["activo"] !== true) {

    responder([
        "exito" => false,
        "mensaje" => "Esta cuenta se encuentra desactivada."
    ]);
}


// ==========================================
// VERIFICAR CONTRASEÑA
// ==========================================

if (!password_verify($password, $datos["password"])) {

    responder([
        "exito" => false,
        "mensaje" => "Usuario o contraseña incorrectos."
    ]);
}


// ==========================================
// GUARDAR SESIÓN
// ==========================================

$_SESSION["id_usuario"] = $datos["id_usuario"];
$_SESSION["usuario"] = $datos["usuario"];
$_SESSION["rol"] = $datos["rol"];


// ==========================================
// ESTUDIANTE
// ==========================================

if ($datos["rol"] === "estudiante") {

    $sqlEstudiante = "
        SELECT nombre, apellido, grado
        FROM estudiante
        WHERE id_estudiante = $1
    ";

    $resultadoEstudiante = pg_query_params(
        $conexion,
        $sqlEstudiante,
        [$datos["id_usuario"]]
    );

    if (
        $resultadoEstudiante &&
        pg_num_rows($resultadoEstudiante) > 0
    ) {

        $estudiante = pg_fetch_assoc($resultadoEstudiante);

        $_SESSION["nombre"] = $estudiante["nombre"];
        $_SESSION["apellidos"] = $estudiante["apellido"];
        $_SESSION["grado"] = $estudiante["grado"];

        responder([
            "exito" => true,
            "mensaje" => "¡Inicio de sesión correcto!",
            "rol" => "estudiante",
            "grado" => $estudiante["grado"]
        ]);
    }
}


// ==========================================
// DOCENTE
// ==========================================

if ($datos["rol"] === "docente") {

    $sqlDocente = "
        SELECT nombre, apellido
        FROM docente
        WHERE id_docente = $1
    ";

    $resultadoDocente = pg_query_params(
        $conexion,
        $sqlDocente,
        [$datos["id_usuario"]]
    );

    if (
        $resultadoDocente &&
        pg_num_rows($resultadoDocente) > 0
    ) {

        $docente = pg_fetch_assoc($resultadoDocente);

        $_SESSION["nombre"] = $docente["nombre"];
        $_SESSION["apellidos"] = $docente["apellido"];

        responder([
            "exito" => true,
            "mensaje" => "¡Inicio de sesión correcto!",
            "rol" => "docente"
        ]);
    }
}


// ==========================================
// PERFIL NO ENCONTRADO
// ==========================================

responder([
    "exito" => false,
    "mensaje" => "No se encontró la información del perfil."
]);

?>