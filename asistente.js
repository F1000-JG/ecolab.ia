document.addEventListener("DOMContentLoaded", () => {
    
    // 1. Inyectar la estructura HTML si no existe todavía en la página
    if (!document.getElementById("ai-floating-btn")) {
        const asistenteHTML = `
            <div id="ai-floating-btn">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="30" height="30" fill="white">
                    <path d="M19 9h-2V7a2 2 0 0 0-2-2h-6a2 2 0 0 0-2 2v2H5a2 2 0 0 0-2 2v6a2 2 0 0 0 2 2h2v1a2 2 0 0 0 2 2h6a2 2 0 0 0 2-2v-1h2a2 2 0 0 0 2-2v-6a2 2 0 0 0-2-2zM9 13a1.5 1.5 0 1 1 0-3 1.5 1.5 0 0 1 0 3zm6 0a1.5 1.5 0 1 1 0-3 1.5 1.5 0 0 1 0 3z" />
                    <path d="M12 2a1 1 0 0 1 1 1v1h-2V3a1 1 0 0 1 1-1z" />
                </svg>
            </div>
            
            <div id="ai-chat-panel" class="oculto">
                <div>
                    <span style="display: flex; align-items: center; gap: 8px;">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="18" height="18" fill="white">
                            <path d="M19 9h-2V7a2 2 0 0 0-2-2h-6a2 2 0 0 0-2 2v2H5a2 2 0 0 0-2 2v6a2 2 0 0 0 2 2h2v1a2 2 0 0 0 2 2h6a2 2 0 0 0 2-2v-1h2a2 2 0 0 0 2-2v-6a2 2 0 0 0-2-2zM9 13a1.5 1.5 0 1 1 0-3 1.5 1.5 0 0 1 0 3zm6 0a1.5 1.5 0 1 1 0-3 1.5 1.5 0 0 1 0 3z" />
                            <path d="M12 2a1 1 0 0 1 1 1v1h-2V3a1 1 0 0 1 1-1z" />
                        </svg>
                        Asistente IA
                    </span>
                    <button id="cerrar-chat">✖</button>
                </div>
                
                <div id="chat-historial">
                    <p class="mensaje-ia">¡Hola! Estoy listo para ayudarte con este experimento. ¿Qué dudas tienes?</p>
                </div>
                
                <div>
                    <input type="text" id="ai-input" placeholder="Escribe tu mensaje...">
                    <button id="enviar-btn">Enviar</button>
                </div>
            </div>
        `;
        document.body.insertAdjacentHTML('beforeend', asistenteHTML);
    }

    // 2. Referencias a los elementos
    const aiBtn = document.getElementById("ai-floating-btn");
    const aiPanel = document.getElementById("ai-chat-panel");
    const closeBtn = document.getElementById("cerrar-chat");
    const enviarBtn = document.getElementById("enviar-btn");
    const aiInput = document.getElementById("ai-input");
    const historial = document.getElementById("chat-historial");

    // 3. Abrir y cerrar panel con eventos seguros
    if (aiBtn && aiPanel) {
        aiBtn.onclick = () => {
            aiPanel.classList.toggle("oculto");
        };
    }

    if (closeBtn && aiPanel) {
        closeBtn.onclick = () => {
            aiPanel.classList.add("oculto");
        };
    }

    // 4. Lógica de envío y captura de datos del panel de forma flexible
    if (enviarBtn && aiInput && historial) {
        const manejarEnvio = async () => {
            const textoUsuario = aiInput.value.trim();
            
            if(textoUsuario !== "") {
                const tituloElem = document.querySelector(".titulo-experimento, h1, h2");
                const experimentoActual = tituloElem ? tituloElem.textContent.trim() : document.title;

                // Busca cualquier panel de información disponible en la página actual
                const panelElem = document.querySelector("#info-card, .info-panel, #panel-datos, div[style*='background']");
                const datosPanelActual = panelElem ? panelElem.innerText : "No se encontró un panel de datos específico.";

                // Mostrar mensaje del usuario
                const burbujaUsuario = document.createElement("p");
                burbujaUsuario.style.background = "#e3f2fd";
                burbujaUsuario.style.padding = "10px";
                burbujaUsuario.style.borderRadius = "8px";
                burbujaUsuario.style.textAlign = "right";
                burbujaUsuario.style.marginBottom = "10px";
                burbujaUsuario.style.border = "1px solid #bbdefb";
                burbujaUsuario.textContent = textoUsuario;
                historial.appendChild(burbujaUsuario);
                
                aiInput.value = "";
                historial.scrollTop = historial.scrollHeight;

                // Burbuja de carga
                const burbujaIa = document.createElement("p");
                burbujaIa.className = "mensaje-ia";
                burbujaIa.style.background = "#f1f3f4";
                burbujaIa.style.padding = "10px";
                burbujaIa.style.borderRadius = "8px";
                burbujaIa.style.textAlign = "left";
                burbujaIa.style.marginBottom = "10px";
                burbujaIa.textContent = "Analizando el experimento...";
                historial.appendChild(burbujaIa);
                historial.scrollTop = historial.scrollHeight;

                try {
                    const peticion = await fetch("http://localhost:5000/api/chat", {
                        method: "POST",
                        headers: { "Content-Type": "application/json" },
                        body: JSON.stringify({ 
                            mensaje: textoUsuario, 
                            experimento: experimentoActual,
                            datos_panel: datosPanelActual 
                        })
                    });

                    const datos = await peticion.json();
                    
                    let textoLimpio = datos.respuesta
                        .replace(/\*\*/g, '')
                        .replace(/\*/g, '')
                        .replace(/###/g, '');

                    burbujaIa.textContent = textoLimpio;

                } catch (error) {
                    console.error("Error de conexión:", error);
                    burbujaIa.textContent = "Lo siento, no pude conectarme con el servidor de Python.";
                    burbujaIa.style.background = "#ffcdd2"; 
                }
                
                historial.scrollTop = historial.scrollHeight;
            }
        };

        enviarBtn.onclick = manejarEnvio;

        aiInput.onkeypress = function(event) {
            if (event.key === "Enter") {
                event.preventDefault();
                manejarEnvio();
            }
        };
    }
});
/* =============================================================
   REGISTRO AUTOMÁTICO DE EVALUACIONES 7.º Y 9.º
   No modifica los HTML. Escucha los cuestionarios existentes y
   guarda el intento en PostgreSQL cuando la evaluación termina.
   ============================================================= */
(() => {
    const paginasConBD = new Set([
        "generador.html", "horno.html", "efecto.html", "corrosion.html",
        "oxidos.html", "sintesis.html", "estraccio.html", "red.html",
        "replicacion.html",
        "laboratorio1.html", "laboratorio2.html", "laboratorio3.html",
        "laboratorio4.html", "laboratorio5.html", "laboratorio6.html",
        "laboratorio7.html", "laboratorio8.html", "laboratorio9.html",
        "laboratorio10.html"
    ]);

    const pagina = decodeURIComponent(location.pathname.split("/").pop() || "");
    if (!paginasConBD.has(pagina)) return;

    const respuestas = new Map();
    let envioRealizado = false;
    let envioEnCurso = false;

    const limpiar = (texto) => (texto || "")
        .replace(/^\s*\d+\s*[.\)\-:]\s*/, "")
        .replace(/^\s*[A-D]\s*[\)\.\-:]\s*/i, "")
        .replace(/\s+/g, " ")
        .trim();

    const visible = (el) => {
        if (!el) return false;
        const st = getComputedStyle(el);
        return st.display !== "none" && st.visibility !== "hidden" && el.getClientRects().length > 0;
    };

    function mostrarEstado(mensaje, ok = true) {
        let aviso = document.getElementById("ecolab-db-status");
        if (!aviso) {
            aviso = document.createElement("div");
            aviso.id = "ecolab-db-status";
            Object.assign(aviso.style, {
                position: "fixed",
                left: "18px",
                bottom: "18px",
                zIndex: "2147483647",
                maxWidth: "420px",
                padding: "11px 14px",
                borderRadius: "10px",
                color: "#fff",
                fontFamily: "Arial, sans-serif",
                fontSize: "14px",
                lineHeight: "1.35",
                boxShadow: "0 5px 18px rgba(0,0,0,.25)",
                transition: "opacity .2s ease"
            });
            document.body.appendChild(aviso);
        }
        aviso.style.background = ok ? "#16794a" : "#b3261e";
        aviso.style.opacity = "1";
        aviso.textContent = mensaje;
        clearTimeout(aviso._ecolabTimer);
        aviso._ecolabTimer = setTimeout(() => { aviso.style.opacity = "0"; }, ok ? 3500 : 7500);
    }

    function obtenerPregunta(origen) {
        const bloque = origen?.closest?.(
            ".quiz-question, .question-block, .pregunta-box, .question-card, " +
            ".question-item, .pregunta-item, .quiz-item, [data-question]"
        );

        if (bloque) {
            const titulo = bloque.querySelector(
                ".question-title, .question-text, .pregunta-titulo, .pregunta-texto, h3, h4, p"
            );
            if (titulo) return limpiar(titulo.textContent);
        }

        const candidatos = [
            "#question-text", "#quiz-question", ".question-text", ".question-title",
            ".pregunta-titulo", ".pregunta-texto", "#question"
        ];
        for (const sel of candidatos) {
            const actual = [...document.querySelectorAll(sel)].find(visible);
            if (actual) return limpiar(actual.textContent);
        }

        // Último recurso para radios: buscar el texto cercano al grupo.
        if (origen instanceof HTMLInputElement && origen.name) {
            const grupo = [...document.getElementsByName(origen.name)]
                .filter(r => r instanceof HTMLInputElement && r.type === "radio")
                .map(r => r.closest("div, section, li"))
                .find(Boolean);
            const titulo = grupo?.querySelector("h3, h4, p, .question-title, .question-text");
            if (titulo) return limpiar(titulo.textContent);
        }

        return "";
    }

    function textoOpcion(origen) {
        if (!origen) return "";

        const label = origen.closest?.("label");
        if (label) return limpiar(label.textContent);

        const opcion = origen.closest?.(
            ".answer, .answer-option, .answer-btn, .option-btn, .quiz-option, " +
            ".option, .option-item, [role='button']"
        );
        if (opcion) return limpiar(opcion.textContent);

        return limpiar(origen.textContent || origen.value || "");
    }

    function registrar(pregunta, respuesta) {
        pregunta = limpiar(pregunta);
        respuesta = limpiar(respuesta);
        if (pregunta && respuesta) respuestas.set(pregunta, respuesta);
    }

    function capturarRadios() {
        document.querySelectorAll("input[type='radio']:checked").forEach(radio => {
            registrar(obtenerPregunta(radio), textoOpcion(radio));
        });
    }

    function capturarSeleccionVisual(origen) {
        const pregunta = obtenerPregunta(origen);
        const respuesta = textoOpcion(origen);
        registrar(pregunta, respuesta);
    }

    document.addEventListener("change", (ev) => {
        const input = ev.target;
        if (input instanceof HTMLInputElement && input.type === "radio" && input.checked) {
            capturarSeleccionVisual(input);
        }
    }, true);

    document.addEventListener("click", (ev) => {
        const target = ev.target instanceof Element ? ev.target : null;
        if (!target) return;

        const opcion = target.closest(
            "#answers-container .answer, #answers-container button, " +
            "#quiz-options button, #options-container button, " +
            ".answer-option, .answer-btn, .option-btn, .quiz-option, .option-item"
        );
        if (opcion) capturarSeleccionVisual(opcion);

        const boton = target.closest("button, input[type='button'], input[type='submit'], a");
        if (!boton) return;

        const texto = limpiar(boton.textContent || boton.value || "").toLowerCase();
        const id = (boton.id || "").toLowerCase();

        if (/restart|retry|reiniciar|reintentar/.test(id + " " + texto)) {
            respuestas.clear();
            envioRealizado = false;
            envioEnCurso = false;
            return;
        }

        const finalPorTexto = /enviar respuestas|enviar examen|enviar evaluación|evaluar mis respuestas|finalizar evaluación|finalizar/.test(texto);
        const finalPorId = /submit-exam|send-quiz-btn|submit-quiz|finish-quiz/.test(id);
        // Cambios de Estado mantiene el mismo texto "Siguiente pregunta" hasta el final.
        const finalLaboratorio3 = pagina === "laboratorio3.html" && id === "next-question-btn" && respuestas.size >= 5;

        if (finalPorTexto || finalPorId || finalLaboratorio3) {
            // Se captura antes de que el onclick del HTML oculte/cambie el cuestionario.
            capturarRadios();
            setTimeout(intentarEnvio, 180);
        }
    }, true);

    document.addEventListener("submit", () => {
        capturarRadios();
        setTimeout(intentarEnvio, 180);
    }, true);

    // Algunos cuestionarios no tienen un botón final distinto: cambian a una pantalla de resultado.
    const observer = new MutationObserver(() => {
        const selectoresResultado = [
            "#result-screen", "#resultModal", "#quiz-results", ".result-screen", ".results-screen"
        ];
        const hayResultado = selectoresResultado.some(sel =>
            [...document.querySelectorAll(sel)].some(visible)
        );
        if (hayResultado) {
            capturarRadios();
            setTimeout(intentarEnvio, 120);
        }
    });

    observer.observe(document.documentElement, {
        subtree: true,
        childList: true,
        attributes: true,
        attributeFilter: ["class", "style"]
    });

    async function intentarEnvio() {
        if (envioRealizado || envioEnCurso) return;
        if (respuestas.size < 1) return;
        await enviarABase();
    }

    async function enviarABase() {
        envioEnCurso = true;
        const payload = {
            pagina,
            respuestas: [...respuestas.entries()].map(([pregunta, respuesta]) => ({ pregunta, respuesta }))
        };

        try {
            const r = await fetch("php/guardar_evaluacion_auto.php", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                credentials: "same-origin",
                cache: "no-store",
                body: JSON.stringify(payload)
            });

            const texto = await r.text();
            let data;
            try {
                data = JSON.parse(texto);
            } catch (_) {
                throw new Error(`PHP no devolvió JSON. HTTP ${r.status}. ${texto.slice(0, 220)}`);
            }

            if (!r.ok || !data.exito) {
                const detalle = data.detalle ? ` ${data.detalle}` : "";
                throw new Error((data.mensaje || `Error HTTP ${r.status}.`) + detalle);
            }

            envioRealizado = true;
            mostrarEstado(`✓ Evaluación guardada en PostgreSQL. Nota: ${Number(data.nota).toFixed(2)}`, true);
            console.info("EcoLab: evaluación registrada en PostgreSQL.", data);
        } catch (error) {
            envioRealizado = false;
            console.error("EcoLab: fallo guardando evaluación.", error);
            mostrarEstado(`No se guardó en la base de datos: ${error.message}`, false);
        } finally {
            envioEnCurso = false;
        }
    }
})();

