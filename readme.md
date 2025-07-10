# Obby de las Dimensiones

## Estructura del proyecto

### Carpetas principales
- `src/Workspace/` - Contenido del workspace de Roblox Studio
  - `Levels/` - Todos los niveles del juego (Level1_Forest, Level2_Water, etc.)
  - `Lobby/` - Área del lobby con spawn, leaderboard, tutorial y tienda
  - `SharedAssets/` - Assets compartidos (partículas, sonidos, materiales)

- `src/ServerScriptService/` - Scripts del servidor
  - `GameCore/` - Scripts principales del juego (PlayerDataManager, CheckpointSystem, LevelManager, AntiCheat)
  - `Mechanics/` - Mecánicas del juego (PlatformBehaviors, HammerSystem, PhysicsModifiers)
  - `Economy/` - Sistema de economía y compras

- `src/ReplicatedStorage/` - Módulos y assets compartidos
  - `RemoteEvents/` - Eventos remotos para comunicación cliente-servidor
  - `RemoteFunctions/` - Funciones remotas
  - `SharedModules/` - Módulos compartidos (PlayerStats, GameConstants)
  - `Assets/` - Assets del juego (martillos, efectos, UI)

- `src/StarterPlayer/` - Scripts del cliente
  - `StarterPlayerScripts/` - Scripts que se ejecutan en el cliente
  - `StarterCharacterScripts/` - Scripts del personaje

### Archivos principales creados
- `src/ReplicatedStorage/SharedModules/PlayerStats.lua` - Módulo para manejar estadísticas del jugador
- `src/ReplicatedStorage/SharedModules/GameConstants.lua` - Constantes del juego
- `src/ServerScriptService/GameCore/PlayerDataManager.lua` - Gestión de datos del jugador
- `src/ServerScriptService/GameCore/CheckpointSystem.lua` - Sistema de checkpoints detallado
- `src/ServerScriptService/GameCore/LevelManager.lua` - Gestión de niveles y progresión
- `src/ServerScriptService/GameCore/AntiCheat.lua` - Sistema básico de anti-cheat
- `src/ServerScriptService/Mechanics/PlatformBehaviors.lua` - Sistema de comportamientos de plataformas
- `src/ServerScriptService/Mechanics/HammerSystem.lua` - Sistema de martillos con efectos
- `src/ServerScriptService/Mechanics/PhysicsModifiers.lua` - Modificadores de física
- `src/Workspace/Levels/Level1_Forest/Level1Script.server.lua` - Script del primer nivel
- `src/ReplicatedStorage/RemoteEvents/CheckpointEvents.lua` - Eventos para checkpoints
- `src/ReplicatedStorage/RemoteEvents/LevelEvents.lua` - Eventos para niveles
- `default.project.json` - Configuración de Rojo para mapear directorios

## ¿Cómo sincronizar con Roblox Studio?

1. Abre una terminal en la raíz del proyecto.
2. Ejecuta:
   ```sh
   rojo serve
   ```
3. En Roblox Studio, abre el plugin de Rojo, verifica que esté en `localhost:34872` y haz clic en **Connect**.
4. Ejecuta el juego y revisa la ventana Output para ver los mensajes de los scripts de ejemplo.

## Funcionalidades implementadas

### Sistema de Datos del Jugador
- Estructura completa de datos del jugador con progreso, estadísticas, monedas, inventario y logros
- Sistema de guardado automático con DataStore
- Gestión de checkpoints, martillos y recompensas

### Sistema de Checkpoints Detallado
- **Checkpoint Estándar**: Activación gratuita, respawn básico
- **Checkpoint Premium**: Requiere 10 monedas, otorga buff temporal de velocidad
- **Checkpoint Oculto**: Ruta alternativa, logro especial y bonus de 50 monedas
- **Checkpoint Temporal**: Solo dura 60 segundos después de activarse
- Efectos visuales con partículas para cada tipo
- Sistema de respawn automático en el último checkpoint activo

### Gestión de Niveles
- **6 niveles configurados** con diferentes dificultades y temáticas
- Sistema de desbloqueo progresivo (cada nivel requiere completar el anterior)
- Configuración detallada de cada nivel (tiempo estimado, recompensas, posiciones)
- Sistema de teleportación y gestión de tiempo por nivel
- Verificación de acceso a niveles según progreso del jugador

### Sistema de Plataformas Avanzado
- **8 tipos de plataformas**: Normal, Fading, Moving, Invisible, Bouncy, Ice, Magnetic, Trap
- **Plataformas que se desmoronan**: Desaparecen después de pisarlas con efectos visuales
- **Plataformas móviles**: Se mueven en patrones predefinidos con TweenService
- **Plataformas invisibles**: Aparecen al tocarlas y desaparecen después de un tiempo
- **Plataformas rebotadoras**: Aumentan el poder de salto temporalmente
- **Plataformas de hielo**: Reducen la fricción para efecto resbaladizo
- **Plataformas magnéticas**: Atraen al jugador con fuerza configurable
- **Plataformas trampa**: Matan al jugador al tocarlas

### Sistema de Martillos Completo
- **5 tipos de martillos**: Beginner, Navigator, Warrior, Coded, Divine
- **Efectos especiales**: Cada martillo otorga efectos únicos al recolectarlo
- **Efectos visuales**: Rotación, flotación, brillo y partículas
- **Martillo del Navegante**: Guía visual con partículas
- **Martillo del Guerrero**: Escudo de protección temporal
- **Martillo Codificado**: Revela plataformas invisibles
- **Martillo Divino**: Múltiples efectos combinados (guía, protección, revelación, velocidad)

### Sistema de Física y Modificadores
- **7 tipos de modificadores**: Gravedad, Viento, Magnético, Cámara lenta, Boost de velocidad, Boost de salto, Anti-gravedad
- **Modificadores de gravedad**: Cambian la gravedad del workspace
- **Modificadores de viento**: Aplican fuerza horizontal al jugador
- **Modificadores magnéticos**: Atraen al jugador hacia posiciones específicas
- **Cámara lenta**: Modifica la escala de tiempo del juego
- **Boosts temporales**: Aumentan velocidad o poder de salto por tiempo limitado
- **Anti-gravedad**: Permite flotar temporalmente

### Sistema Anti-Cheat Básico
- Verificación de velocidad de movimiento y salto
- Detección de teletransportes sospechosos
- Control de límites de posición (altura máxima/mínima)
- Verificación de tiempo máximo por nivel
- Sistema de advertencias progresivas con acciones automáticas
- Reset automático de jugadores que violan las reglas

### Ejemplo de Nivel Implementado
- **Nivel 1: Bosque de los Iniciados** completamente funcional
- **8 plataformas diferentes** con comportamientos únicos
- **2 obstáculos dinámicos**: Giratorio y móvil
- **1 checkpoint estándar** con efectos visuales
- **1 martillo del principiante** con efectos de recolección
- **Portal de salida** con efectos de completado
- **Decoraciones** (árboles) para ambientación

### Constantes del Juego
- Configuración de niveles, martillos y checkpoints
- Configuración de economía (monedas, gemas, tokens)
- Configuración de física, UI, sonido y anti-cheat
- Definición de logros y recompensas

### Comunicación Cliente-Servidor
- Eventos remotos para activación de checkpoints
- Eventos para gestión de niveles y progresión
- Funciones remotas para obtener información de jugador y niveles

### Gestión de Datos
- Carga automática de datos al entrar al juego
- Guardado automático cada 30 segundos
- Sistema de respaldo y recuperación de datos corruptos

## Paso 4: Interfaz de Usuario (UI/UX) ✅

### Controlador Principal de UI
- **UIController.client.lua** implementado con:
  - Sistema de navegación entre pantallas
  - Menú principal con botones de juego
  - UI del lobby con información del jugador
  - UI del nivel con estadísticas en tiempo real
  - Menú de pausa con opciones de juego

### Sistema de Configuración
- **SettingsUI.client.lua** implementado con:
  - Configuración de audio (música y efectos)
  - Configuración de gráficos (partículas, cámara)
  - Configuración de notificaciones
  - Guardado y carga de preferencias
  - Interfaz intuitiva con toggles

### Sistema de Notificaciones
- **NotificationSystem.client.lua** implementado con:
  - **7 tipos de notificaciones**:
    - Éxito: Verde con ✓
    - Error: Rojo con ✗
    - Advertencia: Amarillo con ⚠
    - Información: Azul con ℹ
    - Logro: Dorado con 🏆
    - Checkpoint: Verde con 📍
    - Completado: Cian con 🎉
  - Cola de notificaciones automática
  - Animaciones de entrada y salida
  - Feedback específico para cada acción

### Sistema de Efectos Visuales
- **VisualEffects.client.lua** implementado con:
  - **Partículas especializadas**:
    - Checkpoint: Humo verde
    - Muerte: Chispas rojas
    - Monedas: Partículas doradas
    - Gemas: Partículas cian
    - Portal: Efectos dimensionales
  - **Efectos de cámara**:
    - Sacudida de cámara configurable
    - Flash de pantalla
    - Distorsión de pantalla
  - **Efectos de iluminación**:
    - Cambios de ambiente por eventos
    - Efectos de color dinámicos
  - **Trails y explosiones**:
    - Trails en el jugador
    - Explosiones sin daño

### Sistema de HUD
- **HUDSystem.client.lua** implementado con:
  - **Panel superior**: Título del nivel, tiempo, muertes
  - **Panel inferior**: Monedas, gemas, checkpoints
  - **Panel lateral**: Power-ups activos con timers
  - **Indicadores dinámicos**:
    - Checkpoint alcanzado
    - Muerte del jugador
    - Estadísticas de nivel completado
  - **Actualización en tiempo real** de:
    - Tiempo transcurrido
    - Contadores de muerte
    - Progreso de checkpoints
    - Monedas y gemas recolectadas

### Características de la UI
- **Diseño moderno y responsive**
- **Colores consistentes** con la paleta del juego
- **Animaciones suaves** con TweenService
- **Navegación intuitiva** entre pantallas
- **Feedback visual inmediato** para todas las acciones
- **Configuración personalizable** de efectos
- **Sistema de notificaciones no intrusivo**
- **HUD informativo sin obstruir gameplay**

### Integración con Sistemas Existentes
- **Conectado con**:
  - Sistema de progresión y guardado
  - Sistema de checkpoints
  - Sistema de niveles
  - Sistema de economía (monedas/gemas)
  - Sistema de logros
  - Sistema de power-ups

---

## Paso 5: Sistema de Ranking y Multijugador ✅

### Sistema de Ranking
- **RankingSystem.server.lua** implementado con:
  - **Ranking global** con top 100 jugadores
  - **Récords por nivel** con top 50 por nivel
  - **Estadísticas semanales** y mensuales
  - **Sistema de puntuación** basado en nivel, tiempo, muertes y checkpoints
  - **Guardado automático** en DataStore
  - **Limpieza de datos antiguos** automática

### Eventos Remotos de Ranking
- **RankingEvents.lua** implementado con:
  - **50+ eventos remotos** para comunicación cliente-servidor
  - Eventos para actualización de ranking
  - Eventos para multijugador y chat
  - Eventos para espectadores y desafíos
  - Eventos para torneos y eventos especiales
  - Eventos para sistema de amigos y clanes
  - Eventos para recompensas y logros

### Sistema de Gestión Multijugador
- **MultiplayerManager.server.lua** implementado con:
  - **Estados de jugador**: Lobby, Playing, Spectating, AFK, Offline
  - **Gestión de jugadores por nivel** con notificaciones en tiempo real
  - **Sistema de chat** por nivel y lobby
  - **Sistema de espectadores** para ver otros jugadores
  - **Sistema de desafíos** entre jugadores
  - **Configuración personalizable** por jugador
  - **Estadísticas de multijugador** en tiempo real

### Interfaz de Leaderboard
- **LeaderboardUI.client.lua** implementado con:
  - **4 tipos de leaderboard**: Global, Por Nivel, Semanal, Mensual
  - **Interfaz moderna** con animaciones suaves
  - **Selección de nivel** con dropdown
  - **Lista de jugadores** con scroll y colores alternados
  - **Información detallada**: Posición, jugador, puntuación, nivel, tiempo
  - **Actualización en tiempo real** de datos
  - **Manejo de errores** y estados de carga

### Características del Sistema de Ranking
- **Puntuación inteligente** que considera múltiples factores
- **Récords históricos** por nivel con fechas
- **Estadísticas temporales** (semanal/mensual)
- **Sistema de limpieza** automática de datos antiguos
- **Backup y recuperación** de datos corruptos
- **Análisis detallado** de rendimiento por jugador

### Características del Sistema Multijugador
- **Notificaciones en tiempo real** de eventos importantes
- **Sistema de amigos** y gestión de relaciones
- **Sistema de clanes** para grupos de jugadores
- **Chat por nivel** y lobby general
- **Espectadores** para ver jugadores en tiempo real
- **Desafíos** entre jugadores con aceptación/rechazo
- **Configuración personalizable** de visibilidad y efectos

### Integración con Sistemas Existentes
- **Conectado con**:
  - Sistema de progresión y guardado
  - Sistema de niveles y checkpoints
  - Sistema de UI y notificaciones
  - Sistema de economía y recompensas
  - Sistema de logros y estadísticas

### Funcionalidades Avanzadas
- **Sistema de torneos** para competencias organizadas
- **Eventos especiales** con rankings temporales
- **Sistema de moderación** para reportes
- **Análisis de datos** para estadísticas detalladas
- **Sistema de feedback** para mejoras del juego
- **Sistema de tutorial** integrado con ranking

---

## Paso 6: Sistema de Economía y Tienda ✅

### Sistema de Economía
- **EconomySystem.server.lua** implementado con:
  - **3 tipos de moneda**: Coins, Gems y Tokens
  - **Sistema de recompensas** por completar niveles
  - **Recompensas diarias** con sistema de streak
  - **Recompensas por logros** y eventos especiales
  - **Sistema de transacciones** con historial completo
  - **Guardado automático** en DataStore
  - **Verificación de fondos** antes de compras

### Sistema de Tienda
- **ShopSystem.server.lua** implementado con:
  - **5 categorías de items**: Personajes, Efectos, Boosts, Cosméticos, Power-ups
  - **Sistema de precios dinámicos** con descuentos
  - **Sistema de promociones** activas
  - **Verificación de inventario** para evitar duplicados
  - **Sistema de stock** para items limitados
  - **Procesamiento seguro** de transacciones
  - **Estadísticas de ventas** y popularidad

### Interfaz de Tienda
- **ShopUI.client.lua** implementado con:
  - **Interfaz moderna** con categorías organizadas
  - **Vista previa de items** con imágenes y descripciones
  - **Sistema de filtros** por categoría y rareza
  - **Información de precios** con múltiples monedas
  - **Botones de compra** con verificación de fondos
  - **Notificaciones** de éxito y error en compras
  - **Actualización en tiempo real** de monedas

### Sistema de Inventario
- **InventoryUI.client.lua** implementado con:
  - **Gestión de inventario** con categorías
  - **Sistema de equipamiento** de items
  - **Vista previa detallada** de items seleccionados
  - **Botones de equipar/desequipar** con confirmación
  - **Organización por tipo**: Personajes, Efectos, Cosméticos
  - **Indicadores visuales** de items equipados
  - **Sistema de selección** con información detallada

### Características del Sistema de Economía
- **Monedas iniciales**: 100 Coins, 5 Gems, 0 Tokens
- **Recompensas por nivel**: 50-150 Coins + bonus por tiempo
- **Recompensas diarias**: 50-150 Coins + 1-3 Gems
- **Bonus especiales**: Niveles especiales, perfect runs, speed runs
- **Sistema de streak**: Bonus por días consecutivos
- **Recompensas por logros**: Coins y Gems por desbloquear logros
- **Recompensas por eventos**: Torneos, clanes, referidos

### Características del Sistema de Tienda
- **Items por defecto**: 15+ items organizados por categoría
- **Sistema de rareza**: Common, Uncommon, Rare, Epic, Legendary
- **Precios dinámicos**: Múltiples monedas por item
- **Sistema de descuentos**: Promociones temporales
- **Verificación de fondos**: Validación antes de compras
- **Historial de transacciones**: Registro completo de compras
- **Estadísticas de ventas**: Análisis de popularidad

### Items de la Tienda
- **Personajes**: Speedster, Jumper, Shield con habilidades especiales
- **Efectos**: Trails, partículas, efectos arcoíris
- **Boosts**: Velocidad, salto, boost completo (1 hora)
- **Cosméticos**: Corona, alas, halo con efectos visuales
- **Power-ups**: Doble salto, teletransporte, escudo protector

### Integración con Sistemas Existentes
- **Conectado con**:
  - Sistema de progresión y guardado
  - Sistema de ranking y multijugador
  - Sistema de UI y notificaciones
  - Sistema de logros y estadísticas
  - Sistema de eventos especiales

### Funcionalidades Avanzadas
- **Sistema de promociones** con fechas de inicio/fin
- **Análisis de economía** con estadísticas detalladas
- **Sistema de reembolsos** para transacciones fallidas
- **Backup de inventario** para recuperación de datos
- **Sistema de regalos** entre jugadores
- **Eventos económicos** con precios especiales

---

## Paso 7: Sistema de Sonido y Música ✅

### Sistema de Audio del Servidor
- **AudioSystem.server.lua** implementado con:
  - **Gestión centralizada** de todos los sonidos y música
  - **Configuración de sonidos** por defecto (15+ efectos)
  - **Configuración de música** por nivel y área
  - **Sistema de volúmenes** independientes por tipo
  - **Creación de sonidos personalizados** dinámicamente
  - **Gestión de sonidos 3D** con posicionamiento
  - **Estadísticas de audio** detalladas

### Sistema de Audio del Cliente
- **AudioSystem.client.lua** implementado con:
  - **Reproducción de sonidos** con configuración personalizada
  - **Sistema de música** con fade in/out automático
  - **Gestión de volúmenes** en tiempo real
  - **Interfaz de configuración** de audio
  - **Limpieza automática** de recursos de audio
  - **Sistema de cola** para efectos de sonido

### Sistema de Música de Fondo
- **BackgroundMusic.client.lua** implementado con:
  - **Música por área**: Lobby, menú, niveles, victoria, derrota
  - **Transiciones suaves** entre música con fade
  - **Sistema de cola** para música
  - **Configuración por nivel** con volúmenes específicos
  - **Detección automática** de cambios de área
  - **Música personalizada** con configuración temporal

### Sistema de Efectos de Sonido
- **SoundEffects.client.lua** implementado con:
  - **20+ efectos de sonido** organizados por categoría
  - **Efectos de movimiento**: Salto, aterrizaje, carrera
  - **Efectos de interacción**: Botones, switches, puertas
  - **Efectos de recolección**: Monedas, gemas, martillos
  - **Efectos de ambiente**: Agua, fuego, viento, electricidad
  - **Efectos de UI**: Menús, notificaciones, logros
  - **Efectos 3D** con posicionamiento espacial

### Características del Sistema de Audio
- **Volúmenes independientes**: Música, SFX, Voz, Ambiental
- **Configuración personalizable** por jugador
- **Efectos 3D** con distancia y rolloff
- **Sistema de prioridades** para efectos
- **Limpieza automática** de recursos
- **Cola de efectos** para evitar sobrecarga
- **Estadísticas detalladas** de uso de audio

### Efectos de Sonido Implementados
- **Movimiento**: Salto, aterrizaje, carrera
- **Interacción**: Botones, switches, puertas
- **Recolección**: Monedas, gemas, martillos, checkpoints
- **Estado**: Daño, curación, power-ups, escudos
- **Ambiente**: Agua, fuego, viento, electricidad
- **UI**: Menús, notificaciones, logros

### Música por Área
- **Lobby**: Música relajante para espera
- **Menú**: Música de navegación
- **Niveles**: Música específica por dimensión (Bosque, Agua, Lava, Cyber, Celestial, Troll)
- **Eventos**: Música de victoria y derrota
- **Transiciones**: Fade in/out automático

### Integración con Sistemas Existentes
- **Conectado con**:
  - Sistema de progresión y guardado
  - Sistema de niveles y checkpoints
  - Sistema de economía y tienda
  - Sistema de UI y notificaciones
  - Sistema de ranking y multijugador

### Funcionalidades Avanzadas
- **Sistema de cola** para evitar sobrecarga de audio
- **Efectos 3D** con posicionamiento espacial
- **Configuración dinámica** de volúmenes
- **Creación de sonidos personalizados** en tiempo real
- **Estadísticas de uso** de audio
- **Sistema de prioridades** para efectos importantes
- **Limpieza automática** de recursos no utilizados

---

## Próximos pasos
1. Implementar sistema de partículas avanzado
2. Crear sistema de logros y estadísticas
3. Implementar sistema de eventos especiales
4. Desarrollar sistema de tutorial interactivo
5. Crear sistema de personalización avanzada
