# 🏎️ Poly Racer

**Poly Racer** es un juego de carreras estilo *Endless Runner* desarrollado en **Flutter**, inspirado en la nostalgia y la estética **Low-Poly de la era de PlayStation 1**.

El objetivo es simple pero desafiante: conduce tan lejos como puedas, esquiva obstáculos, recoge monedas y gestiona tus recursos (gasolina y neumáticos) antes de que se agoten. ¡Todo esto mientras disfrutas de una banda sonora dinámica generada por IA que se adapta a cada escenario!

---

## 🎮 Características Principales

### 🌍 Escenarios Temáticos (Mundos)
El juego cuenta con un sistema de **Backgrounds Seamless** (scroll infinito) que cambia la atmósfera y la música del juego.
- **🌲 Forest:** Un bosque clásico y soleado estilo arcade.
- **👻 Haunted Forest:** Un bosque tenebroso con niebla y vibras de Halloween.
- **❄️ North Pole:** Pista helada con estética invernal.
- **🌊 Deep Ocean:** Una carrera submarina rodeada de coral.
- **🪐 Desert:** Un desierto desolado y antiguo.
- **🏙️ Futuristic:** Una ciudad cyberpunk llena de luces de neón.

### 🚗 Garaje y Vehículos
Selecciona tu vehículo favorito en el garaje. Cada coche tiene su propio estilo visual pixel-art:
- **Chevrolet Camaro:** Potencia clásica americana.
- **Honda Civic Type R:** Agilidad japonesa.
- **Nissan GTR Nismo:** Velocidad pura.
- **Mazda Miata:** Ligero y divertido.

### 🛠️ Mecánicas de Juego
- **Sistema de Recursos:**
  - ⛽ **Gasolina:** Se consume con el tiempo. ¡Recoge bidones para no quedarte tirado!
  - 🛞 **Llantas:** Representan tu "vida". Chocar con rocas grandes o pequeñas daña tus neumáticos. Recoge kits de reparación.
- **Economía:** Recoge **Monedas ($)** para aumentar tu puntuación.
- **Dificultad Dinámica:** La velocidad del juego aumenta progresivamente a medida que recoges más monedas.
- **Responsividad Total:** Juega en modo **Vertical (Portrait)** con una mano o **Horizontal (Landscape)** para una vista panorámica. El juego adapta la interfaz y los controles automáticamente.

### 💾 Persistencia y Backend
- **Shared Preferences:** Guarda tu nombre de piloto, tu coche favorito, el último escenario seleccionado y tus ajustes de volumen localmente.
- **Supabase:** Integración para autenticación y (opcionalmente) guardado de puntuaciones en la nube.

---

## 👥 Autores

Este proyecto fue desarrollado por:

* **ARROYO LOPEZ MIGUEL ANGEL**
* **BORCHARDT CASTELLANOS GAEL HUMBERTO**
* **PEREZ IBARRA ANGEL FRANCISCO**

---

## 🔧 Configuración de Variables de Entorno

Esta aplicación utiliza variables de entorno para gestionar configuraciones sensibles como la conexión a la base de datos.

### Configuración Inicial

1.  Copia el archivo de ejemplo `.env.example` a `.env`:
    ```bash
    cp .env.example .env
    ```

2.  Edita el archivo `.env` con tus credenciales reales:
    ```env
    # Supabase Configuration
    SUPABASE_URL=[https://tu-proyecto.supabase.co](https://tu-proyecto.supabase.co)
    SUPABASE_ANON_KEY=tu_anon_key_aqui

    # Authentication
    AUTH_EMAIL=tu_email@example.com
    AUTH_PASSWORD=tu_password_aqui
    ```

3.  **Nota:** El archivo `.env` está en `.gitignore` y **NO debe** ser subido al repositorio.

### Variables Disponibles

| Variable | Descripción |
|----------|-------------|
| `SUPABASE_URL` | URL de tu proyecto Supabase |
| `SUPABASE_ANON_KEY` | Clave anónima pública de Supabase |
| `AUTH_EMAIL` | Email para autenticación por defecto |
| `AUTH_PASSWORD` | Contraseña para autenticación por defecto |

---

## 🚀 Instalación y Ejecución

1.  Asegúrate de tener Flutter instalado (SDK ^3.9.2).
2.  Instala las dependencias:
    ```bash
    flutter pub get
    ```
3.  Configura tu archivo `.env` (ver sección anterior).
4.  Ejecuta la aplicación:
    ```bash
    flutter run
    ```
5.  Crear .apk de la aplicación:
    ```bash
    flutter build ap --release
    ```
6.  Buscar la aplicación en: `(ruta del proyecto)\build\app\outputs\apk\release\app-release.apk`
---

## 📦 Dependencias Clave

* [`flutter`](https://flutter.dev): Framework UI.
* [`supabase_flutter`](https://pub.dev/packages/supabase_flutter): Backend as a Service.
* [`shared_preferences`](https://pub.dev/packages/shared_preferences): Guardado de datos local.
* [`audioplayers`](https://pub.dev/packages/audioplayers): Reproducción de música y efectos de sonido.
* [`flutter_dotenv`](https://pub.dev/packages/flutter_dotenv): Manejo de secretos.

---

## 🪪 Créditos y Assets

* **Música:** Generada con IA (Suno/Udio) utilizando prompts específicos para lograr los estilos deseados.
* **Efectos de sonido:** Obtenidos de la libreria de sonidos gratis "Freesound".
* **Gráficos:** Sprites de coches y tilesets generados y editados para mantener la estética Pixel Art / Low Poly.
* **Iconos:** [freepngimg](https://freepngimg.com/png/148675-car-top-vector-view-free-hd-image) y Material Icons.
