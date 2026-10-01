CREATE OR REPLACE VIEW vista_estudiantes AS
SELECT
    u.id_usuario,
    u.usuario,
    e.nombre,
    e.apellido,
    e.grado,
    u.activo,
    u.fecha_registro
FROM usuario u
INNER JOIN estudiante e
    ON u.id_usuario = e.id_estudiante
WHERE u.rol = 'estudiante';