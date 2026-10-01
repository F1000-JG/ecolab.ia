<?php

require_once "conexion.php";

// Verificar que se recibió el formulario
if ($_SERVER["REQUEST_METHOD"] !== "POST") {
    die("Acceso no permitido.");
}

// Recibir datos
$nombre = trim($_POST["nombre"] ?? "");
$apellidos = trim($_POST["apellidos"] ?? "");
$usuario = trim($_POST["usuario"] ?? "");
$rol = trim($_POST["rol"] ?? "");
$grado = $_POST["grado"] ?? null;
$password = $_POST["password"] ?? "";

// Validaciones
if ($nombre === "" || $apellidos === "" || $usuario === "" || $rol === "" || $password === "") {
    die("Todos los campos obligatorios deben completarse.");
}

if (!in_array($rol, ["estudiante", "docente"])) {
    die("Rol no válido.");
}

if (strlen($password) < 6) {
    die("La contraseña debe tener al menos 6 caracteres.");
}

// Si es estudiante, debe tener grado
if ($rol === "estudiante") {

    if ($grado === null || !in_array((int)$grado, [7, 8, 9])) {
        die("Debes seleccionar un grado válido.");
    }

} else {

    $grado = null;
}

// Verificar si el usuario ya existe
$sqlExiste = "SELECT id_usuario FROM usuario WHERE LOWER(usuario) = LOWER($1)";
$resultadoExiste = pg_query_params($conexion, $sqlExiste, [$usuario]);

if (!$resultadoExiste) {
    die("Error al comprobar el usuario.");
}

if (pg_num_rows($resultadoExiste) > 0) {
    die("Ese nombre de usuario ya está registrado.");
}

// Encriptar contraseña
$passwordHash = password_hash($password, PASSWORD_DEFAULT);

// Iniciar transacción
pg_query($conexion, "BEGIN");

try {

    // Insertar en usuario
    $sqlUsuario = "
        INSERT INTO usuario
        (usuario, password, rol, activo)
        VALUES ($1, $2, $3, TRUE)
        RETURNING id_usuario
    ";

    $resultadoUsuario = pg_query_params(
        $conexion,
        $sqlUsuario,
        [$usuario, $passwordHash, $rol]
    );

    if (!$resultadoUsuario) {
        throw new Exception("No se pudo crear el usuario.");
    }

    // Obtener ID del usuario
    $fila = pg_fetch_assoc($resultadoUsuario);
    $idUsuario = $fila["id_usuario"];

    // Guardar datos según el rol
    if ($rol === "estudiante") {

        $sqlEstudiante = "
            INSERT INTO estudiante
            (id_estudiante, nombre, apellido, grado)
            VALUES ($1, $2, $3, $4)
        ";

        $resultadoEstudiante = pg_query_params(
            $conexion,
            $sqlEstudiante,
            [$idUsuario, $nombre, $apellidos, (int)$grado]
        );

        if (!$resultadoEstudiante) {
            throw new Exception("No se pudo guardar el estudiante.");
        }

    } else {

        $sqlDocente = "
            INSERT INTO docente
            (id_docente, nombre, apellido)
            VALUES ($1, $2, $3)
        ";

        $resultadoDocente = pg_query_params(
            $conexion,
            $sqlDocente,
            [$idUsuario, $nombre, $apellidos]
        );

        if (!$resultadoDocente) {
            throw new Exception("No se pudo guardar el docente.");
        }
    }

    // Confirmar todos los cambios
    pg_query($conexion, "COMMIT");

    echo "¡Cuenta creada correctamente!";

} catch (Exception $e) {

    // Deshacer cambios si ocurrió un error
    pg_query($conexion, "ROLLBACK");

    die("Error al crear la cuenta: " . $e->getMessage());
}

?>