WITH datos(experimento, numero, letra, texto, es_correcta) AS (
    VALUES

    -- =====================================================
    -- FÍSICA 1: ENERGÍA POTENCIAL Y CINÉTICA
    -- =====================================================

    ('Energía potencial y cinética', 1, 'A', 'Aumenta.', FALSE),
    ('Energía potencial y cinética', 1, 'B', 'Disminuye.', TRUE),
    ('Energía potencial y cinética', 1, 'C', 'Permanece siempre igual.', FALSE),
    ('Energía potencial y cinética', 1, 'D', 'Desaparece completamente.', FALSE),

    ('Energía potencial y cinética', 2, 'A', 'Disminuye.', FALSE),
    ('Energía potencial y cinética', 2, 'B', 'Aumenta.', TRUE),
    ('Energía potencial y cinética', 2, 'C', 'Se vuelve cero.', FALSE),
    ('Energía potencial y cinética', 2, 'D', 'No cambia.', FALSE),

    ('Energía potencial y cinética', 3, 'A', 'De la masa, la gravedad y la altura.', TRUE),
    ('Energía potencial y cinética', 3, 'B', 'Solamente de la velocidad.', FALSE),
    ('Energía potencial y cinética', 3, 'C', 'Solamente del tiempo.', FALSE),
    ('Energía potencial y cinética', 3, 'D', 'Solamente del tamaño de la rampa.', FALSE),

    ('Energía potencial y cinética', 4, 'A', 'La energía potencial disminuye.', FALSE),
    ('Energía potencial y cinética', 4, 'B', 'La energía potencial aumenta.', TRUE),
    ('Energía potencial y cinética', 4, 'C', 'La masa deja de influir.', FALSE),
    ('Energía potencial y cinética', 4, 'D', 'La altura se vuelve cero.', FALSE),

    ('Energía potencial y cinética', 5, 'A', 'Energía cinética a energía potencial.', FALSE),
    ('Energía potencial y cinética', 5, 'B', 'Energía potencial a energía cinética.', TRUE),
    ('Energía potencial y cinética', 5, 'C', 'Energía térmica a energía química.', FALSE),
    ('Energía potencial y cinética', 5, 'D', 'No existe transformación de energía.', FALSE),


    -- =====================================================
    -- FÍSICA 2: FRECUENCIA Y PERÍODO
    -- =====================================================

    ('Frecuencia y período', 1, 'A', 'La cantidad de masa del péndulo.', FALSE),
    ('Frecuencia y período', 1, 'B', 'El tiempo que tarda en realizar una oscilación.', TRUE),
    ('Frecuencia y período', 1, 'C', 'La velocidad máxima del péndulo.', FALSE),
    ('Frecuencia y período', 1, 'D', 'La altura del soporte.', FALSE),

    ('Frecuencia y período', 2, 'A', 'f = T', FALSE),
    ('Frecuencia y período', 2, 'B', 'f = T × g', FALSE),
    ('Frecuencia y período', 2, 'C', 'f = 1 ÷ T.', TRUE),
    ('Frecuencia y período', 2, 'D', 'f = L × T', FALSE),

    ('Frecuencia y período', 3, 'A', 'El período aumenta.', TRUE),
    ('Frecuencia y período', 3, 'B', 'El período siempre se hace cero.', FALSE),
    ('Frecuencia y período', 3, 'C', 'El período desaparece.', FALSE),
    ('Frecuencia y período', 3, 'D', 'No puede medirse.', FALSE),

    ('Frecuencia y período', 4, 'A', 'Metros (m)', FALSE),
    ('Frecuencia y período', 4, 'B', 'Segundos (s)', FALSE),
    ('Frecuencia y período', 4, 'C', 'Hertz (Hz).', TRUE),
    ('Frecuencia y período', 4, 'D', 'Kilogramos (kg)', FALSE),

    ('Frecuencia y período', 5, 'A', 'La longitud de la cuerda.', FALSE),
    ('Frecuencia y período', 5, 'B', 'Cuántas oscilaciones realiza por segundo.', TRUE),
    ('Frecuencia y período', 5, 'C', 'La masa del péndulo.', FALSE),
    ('Frecuencia y período', 5, 'D', 'La altura del soporte.', FALSE),


    -- =====================================================
    -- FÍSICA 3: SONIDO EN UNA CUERDA
    -- =====================================================

    ('Sonido en una cuerda', 1, 'A', 'La frecuencia disminuye.', FALSE),
    ('Sonido en una cuerda', 1, 'B', 'La frecuencia aumenta.', TRUE),
    ('Sonido en una cuerda', 1, 'C', 'La frecuencia desaparece.', FALSE),
    ('Sonido en una cuerda', 1, 'D', 'La frecuencia siempre es cero.', FALSE),

    ('Sonido en una cuerda', 2, 'A', 'T = m × g.', TRUE),
    ('Sonido en una cuerda', 2, 'B', 'T = L × g', FALSE),
    ('Sonido en una cuerda', 2, 'C', 'T = f × L', FALSE),
    ('Sonido en una cuerda', 2, 'D', 'T = m ÷ g', FALSE),

    ('Sonido en una cuerda', 3, 'A', 'El sonido se vuelve más agudo.', FALSE),
    ('Sonido en una cuerda', 3, 'B', 'El sonido se vuelve más grave.', TRUE),
    ('Sonido en una cuerda', 3, 'C', 'El sonido desaparece siempre.', FALSE),
    ('Sonido en una cuerda', 3, 'D', 'La tensión se vuelve cero.', FALSE),

    ('Sonido en una cuerda', 4, 'A', 'Metros (m)', FALSE),
    ('Sonido en una cuerda', 4, 'B', 'Newtons (N)', FALSE),
    ('Sonido en una cuerda', 4, 'C', 'Hertz (Hz).', TRUE),
    ('Sonido en una cuerda', 4, 'D', 'Kilogramos (kg)', FALSE),

    ('Sonido en una cuerda', 5, 'A', 'El sonido tiende a ser más agudo.', TRUE),
    ('Sonido en una cuerda', 5, 'B', 'El sonido siempre se vuelve más grave.', FALSE),
    ('Sonido en una cuerda', 5, 'C', 'La cuerda deja de vibrar.', FALSE),
    ('Sonido en una cuerda', 5, 'D', 'La frecuencia se vuelve cero.', FALSE),


    -- =====================================================
    -- QUÍMICA 4: PREPARACIÓN DE SOLUCIONES
    -- =====================================================

    ('Preparación de soluciones', 1, 'A', 'Una mezcla donde el soluto no se mezcla.', FALSE),
    ('Preparación de soluciones', 1, 'B', 'Una mezcla uniforme donde el soluto está distribuido en el solvente.', TRUE),
    ('Preparación de soluciones', 1, 'C', 'Una mezcla formada únicamente por agua.', FALSE),
    ('Preparación de soluciones', 1, 'D', 'Una sustancia sólida sin disolver.', FALSE),

    ('Preparación de soluciones', 2, 'A', 'La concentración disminuye.', FALSE),
    ('Preparación de soluciones', 2, 'B', 'El agua desaparece.', FALSE),
    ('Preparación de soluciones', 2, 'C', 'La concentración aumenta.', TRUE),
    ('Preparación de soluciones', 2, 'D', 'La solución deja de existir.', FALSE),

    ('Preparación de soluciones', 3, 'A', 'Actúa como solvente.', TRUE),
    ('Preparación de soluciones', 3, 'B', 'Actúa como soluto.', FALSE),
    ('Preparación de soluciones', 3, 'C', 'Aumenta la masa del recipiente.', FALSE),
    ('Preparación de soluciones', 3, 'D', 'Produce partículas de sal.', FALSE),

    ('Preparación de soluciones', 4, 'A', 'C = agua × soluto', FALSE),
    ('Preparación de soluciones', 4, 'B', 'C = masa del soluto ÷ volumen de la solución × 100.', TRUE),
    ('Preparación de soluciones', 4, 'C', 'C = volumen ÷ tiempo', FALSE),
    ('Preparación de soluciones', 4, 'D', 'C = masa × gravedad', FALSE),

    ('Preparación de soluciones', 5, 'A', 'Las partículas se concentran únicamente en el fondo.', FALSE),
    ('Preparación de soluciones', 5, 'B', 'El recipiente desaparece.', FALSE),
    ('Preparación de soluciones', 5, 'C', 'El agua se convierte en sólido.', FALSE),
    ('Preparación de soluciones', 5, 'D', 'Las partículas se dispersan hasta formar una solución uniforme.', TRUE),


    -- =====================================================
    -- QUÍMICA 5: CONCENTRACIÓN DE SOLUCIONES
    -- =====================================================

    ('Concentración de soluciones', 1, 'A', 'La cantidad de solvente que desaparece.', FALSE),
    ('Concentración de soluciones', 1, 'B', 'La relación entre la cantidad de soluto y solvente.', TRUE),
    ('Concentración de soluciones', 1, 'C', 'La temperatura del recipiente.', FALSE),
    ('Concentración de soluciones', 1, 'D', 'El tamaño del vaso.', FALSE),

    ('Concentración de soluciones', 2, 'A', 'Aumenta.', TRUE),
    ('Concentración de soluciones', 2, 'B', 'Disminuye.', FALSE),
    ('Concentración de soluciones', 2, 'C', 'Permanece siempre igual.', FALSE),
    ('Concentración de soluciones', 2, 'D', 'Desaparece.', FALSE),

    ('Concentración de soluciones', 3, 'A', 'El vaso.', FALSE),
    ('Concentración de soluciones', 3, 'B', 'La cuchara.', FALSE),
    ('Concentración de soluciones', 3, 'C', 'La sal.', TRUE),
    ('Concentración de soluciones', 3, 'D', 'El aire.', FALSE),

    ('Concentración de soluciones', 4, 'A', 'Concentración = agua × sal.', FALSE),
    ('Concentración de soluciones', 4, 'B', 'Concentración = agua ÷ sal.', FALSE),
    ('Concentración de soluciones', 4, 'C', 'Concentración = sal + agua.', FALSE),
    ('Concentración de soluciones', 4, 'D', 'Concentración (%) = sal ÷ agua × 100.', TRUE),

    ('Concentración de soluciones', 5, 'A', 'Vaso 1.', FALSE),
    ('Concentración de soluciones', 5, 'B', 'Vaso 2.', FALSE),
    ('Concentración de soluciones', 5, 'C', 'Vaso 3.', TRUE),
    ('Concentración de soluciones', 5, 'D', 'Todos tienen la misma concentración.', FALSE),


    -- =====================================================
    -- QUÍMICA 6: DUREZA DE MINERALES
    -- =====================================================

    ('Dureza de minerales', 1, 'A', 'La temperatura.', FALSE),
    ('Dureza de minerales', 1, 'B', 'La dureza.', TRUE),
    ('Dureza de minerales', 1, 'C', 'La masa.', FALSE),
    ('Dureza de minerales', 1, 'D', 'El volumen.', FALSE),

    ('Dureza de minerales', 2, 'A', 'El mineral puede ser rayado.', TRUE),
    ('Dureza de minerales', 2, 'B', 'El mineral desaparece.', FALSE),
    ('Dureza de minerales', 2, 'C', 'El material se convierte en mineral.', FALSE),
    ('Dureza de minerales', 2, 'D', 'No ocurre absolutamente nada.', FALSE),

    ('Dureza de minerales', 3, 'A', 'La moneda.', FALSE),
    ('Dureza de minerales', 3, 'B', 'El clavo.', FALSE),
    ('Dureza de minerales', 3, 'C', 'El vidrio.', TRUE),
    ('Dureza de minerales', 3, 'D', 'Todos tienen la misma dureza.', FALSE),

    ('Dureza de minerales', 4, 'A', 'Talco.', FALSE),
    ('Dureza de minerales', 4, 'B', 'Calcita.', FALSE),
    ('Dureza de minerales', 4, 'C', 'Cuarzo.', TRUE),
    ('Dureza de minerales', 4, 'D', 'Ninguno.', FALSE),

    ('Dureza de minerales', 5, 'A', 'Para medir la temperatura del mineral.', FALSE),
    ('Dureza de minerales', 5, 'B', 'Para comparar la dureza relativa del mineral.', TRUE),
    ('Dureza de minerales', 5, 'C', 'Para cambiar el color del mineral.', FALSE),
    ('Dureza de minerales', 5, 'D', 'Para medir su peso exacto.', FALSE),


    -- =====================================================
    -- BIOLOGÍA 7: TRANSPORTE DE AGUA EN LAS PLANTAS
    -- =====================================================

    ('Transporte de agua en las plantas', 1, 'A', 'La producción de semillas.', FALSE),
    ('Transporte de agua en las plantas', 1, 'B', 'El transporte y absorción de agua.', TRUE),
    ('Transporte de agua en las plantas', 1, 'C', 'La germinación de una semilla.', FALSE),
    ('Transporte de agua en las plantas', 1, 'D', 'La formación de raíces.', FALSE),

    ('Transporte de agua en las plantas', 2, 'A', 'El tallo y los vasos conductores.', TRUE),
    ('Transporte de agua en las plantas', 2, 'B', 'Las flores solamente.', FALSE),
    ('Transporte de agua en las plantas', 2, 'C', 'Los frutos.', FALSE),
    ('Transporte de agua en las plantas', 2, 'D', 'Las semillas.', FALSE),

    ('Transporte de agua en las plantas', 3, 'A', 'Para alimentar a la planta.', FALSE),
    ('Transporte de agua en las plantas', 3, 'B', 'Para aumentar el tamaño de la planta.', FALSE),
    ('Transporte de agua en las plantas', 3, 'C', 'Para observar visualmente el movimiento del agua.', TRUE),
    ('Transporte de agua en las plantas', 3, 'D', 'Para detener la absorción de agua.', FALSE),

    ('Transporte de agua en las plantas', 4, 'A', 'Sus pétalos pueden adquirir progresivamente el color del agua.', TRUE),
    ('Transporte de agua en las plantas', 4, 'B', 'Los pétalos desaparecen.', FALSE),
    ('Transporte de agua en las plantas', 4, 'C', 'La flor deja de absorber agua inmediatamente.', FALSE),
    ('Transporte de agua en las plantas', 4, 'D', 'La flor cambia automáticamente de especie.', FALSE),

    ('Transporte de agua en las plantas', 5, 'A', 'Que las plantas no necesitan agua.', FALSE),
    ('Transporte de agua en las plantas', 5, 'B', 'Que el agua puede desplazarse desde el tallo hacia otras partes de la planta.', TRUE),
    ('Transporte de agua en las plantas', 5, 'C', 'Que las plantas producen agua coloreada.', FALSE),
    ('Transporte de agua en las plantas', 5, 'D', 'Que las hojas producen el agua que absorbe la planta.', FALSE),


    -- =====================================================
    -- BIOLOGÍA 8: FUNCIÓN DE LAS HOJAS
    -- =====================================================

    ('Función de las hojas', 1, 'A', 'Absorber minerales directamente del suelo.', FALSE),
    ('Función de las hojas', 1, 'B', 'Realizar la fotosíntesis.', TRUE),
    ('Función de las hojas', 1, 'C', 'Producir semillas en todos los casos.', FALSE),
    ('Función de las hojas', 1, 'D', 'Formar las raíces.', FALSE),

    ('Función de las hojas', 2, 'A', 'La luz solar.', TRUE),
    ('Función de las hojas', 2, 'B', 'El viento.', FALSE),
    ('Función de las hojas', 2, 'C', 'El suelo.', FALSE),
    ('Función de las hojas', 2, 'D', 'El vapor de agua.', FALSE),

    ('Función de las hojas', 3, 'A', 'Dióxido de carbono (CO₂).', FALSE),
    ('Función de las hojas', 3, 'B', 'Oxígeno (O₂).', TRUE),
    ('Función de las hojas', 3, 'C', 'Nitrógeno (N₂).', FALSE),
    ('Función de las hojas', 3, 'D', 'Hidrógeno (H₂).', FALSE),

    ('Función de las hojas', 4, 'A', 'Respiración.', FALSE),
    ('Función de las hojas', 4, 'B', 'Fotosíntesis.', FALSE),
    ('Función de las hojas', 4, 'C', 'Transpiración.', TRUE),
    ('Función de las hojas', 4, 'D', 'Germinación.', FALSE),

    ('Función de las hojas', 5, 'A', 'Disminuye la actividad fotosintética.', FALSE),
    ('Función de las hojas', 5, 'B', 'Aumenta la actividad fotosintética.', TRUE),
    ('Función de las hojas', 5, 'C', 'La hoja deja de respirar.', FALSE),
    ('Función de las hojas', 5, 'D', 'Desaparece el vapor de agua.', FALSE),


    -- =====================================================
    -- BIOLOGÍA 9: OBSERVACIÓN DE TEJIDOS ANIMALES
    -- =====================================================

    ('Observación de tejidos animales', 1, 'A', 'El movimiento de los huesos.', FALSE),
    ('Observación de tejidos animales', 1, 'B', 'Las características y estructuras de los tejidos animales.', TRUE),
    ('Observación de tejidos animales', 1, 'C', 'La circulación del agua en las plantas.', FALSE),
    ('Observación de tejidos animales', 1, 'D', 'La reproducción de las plantas.', FALSE),

    ('Observación de tejidos animales', 2, 'A', 'Sus células están muy juntas formando capas.', TRUE),
    ('Observación de tejidos animales', 2, 'B', 'Está formado únicamente por huesos.', FALSE),
    ('Observación de tejidos animales', 2, 'C', 'Está compuesto solamente por neuronas.', FALSE),
    ('Observación de tejidos animales', 2, 'D', 'No posee células.', FALSE),

    ('Observación de tejidos animales', 3, 'A', 'Sus fibras están especializadas en la contracción.', TRUE),
    ('Observación de tejidos animales', 3, 'B', 'Solo sirve para transportar agua.', FALSE),
    ('Observación de tejidos animales', 3, 'C', 'Está formado únicamente por células nerviosas.', FALSE),
    ('Observación de tejidos animales', 3, 'D', 'No puede realizar ningún movimiento.', FALSE),

    ('Observación de tejidos animales', 4, 'A', 'Neuronas, dendritas y axones.', TRUE),
    ('Observación de tejidos animales', 4, 'B', 'Raíces, tallos y hojas.', FALSE),
    ('Observación de tejidos animales', 4, 'C', 'Huesos y cartílagos únicamente.', FALSE),
    ('Observación de tejidos animales', 4, 'D', 'Solo células musculares.', FALSE),

    ('Observación de tejidos animales', 5, 'A', 'Producir únicamente impulsos nerviosos.', FALSE),
    ('Observación de tejidos animales', 5, 'B', 'Realizar la fotosíntesis.', FALSE),
    ('Observación de tejidos animales', 5, 'C', 'Unir, sostener y proteger diferentes partes del cuerpo.', TRUE),
    ('Observación de tejidos animales', 5, 'D', 'Transportar agua desde las raíces.', FALSE)
)

INSERT INTO opcion
(id_pregunta, texto, es_correcta)
SELECT
    p.id_pregunta,
    d.letra || ') ' || d.texto,
    d.es_correcta
FROM datos d
INNER JOIN experimento ex
    ON ex.nombre = d.experimento
INNER JOIN evaluacion e
    ON e.id_experimento = ex.id_experimento
INNER JOIN pregunta p
    ON p.id_evaluacion = e.id_evaluacion
    AND p.numero = d.numero
ORDER BY p.id_pregunta, d.letra;