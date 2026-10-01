from flask import Flask, request, jsonify
from flask_cors import CORS
import google.generativeai as genai

app = Flask(__name__)
CORS(app)

genai.configure(api_key="AIzaSyCxGnfnEspflX7Qfv5Pi-gLQaQ9LiLA41g")

modelo = genai.GenerativeModel(
    'gemini-3.6-flash',
    system_instruction=(
        "Eres un asistente virtual experto en ciencias para un laboratorio educativo llamado EcoLab. "
        "Tu objetivo es responder de forma corta, directa y concreta a estudiantes de noveno grado. "
        "REGLAS ESTRICTAS: "
        "1. Utiliza obligatoriamente los datos exactos que aparecen en el panel de información actual del experimento para responder (como valores numéricos, presiones, temperaturas o estados). "
        "2. Si el usuario pregunta por un dato que está en ese panel, dalo de inmediato de forma breve. "
        "3. No utilices asteriscos, negritas, cursivas ni símbolos de formato markdown. Solo texto plano."
    )
)

@app.route('/api/chat', methods=['POST'])
def procesar_chat():
    try:
        datos = request.json
        mensaje_usuario = datos.get('mensaje', '')
        experimento_actual = datos.get('experimento', 'Laboratorio de Ciencias')
        datos_panel = datos.get('datos_panel', '') # <--- RECIBIMOS LOS DATOS DEL CUADRO
        
        if not mensaje_usuario:
            return jsonify({"respuesta": "No se recibió ningún mensaje."}), 400

        # Construimos un prompt estricto con la información del cuadro en pantalla
        prompt_completo = (
            f"Experimento actual: '{experimento_actual}'.\n"
            f"INFORMACIÓN ACTUAL EN EL PANEL DEL ESTUDIANTE:\n{datos_panel}\n\n"
            f"Pregunta del estudiante: {mensaje_usuario}"
        )

        respuesta_ia = modelo.generate_content(prompt_completo)
        
        # Limpieza de seguridad por si la IA genera algún asterisco por error
        texto_limpio = (
            respuesta_ia.text
            .replace('**', '')
            .replace('*', '')
            .replace('###', '')
        )
        
        return jsonify({"respuesta": texto_limpio})
        
    except Exception as e:
        print(f"Error detallado: {e}")
        return jsonify({"respuesta": "Hubo un error al procesar tu solicitud."}), 500

if __name__ == '__main__':
    app.run(debug=True, port=5000)