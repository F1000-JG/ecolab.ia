CREATE OR REPLACE VIEW vista_docentes AS
SELECT
    u.id_usuario,
    u.usuario,
    d.nombre,
    d.apellido,
    u.activo,
    u.fecha_registro
FROM usuario u
INNER JOIN docente d
    ON u.id_usuario = d.id_docente
WHERE u.rol = 'docente';