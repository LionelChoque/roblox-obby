Excelente proyecto! Voy a expandir significativamente la documentación de tu juego Obby para que tengas una guía completa e implementable. Esta documentación servirá como referencia exhaustiva para el desarrollo en Cursor y Roblox Studio.

# DOCUMENTACIÓN COMPLETA: OBBY DE LAS DIMENSIONES
## El Desafío del Dios del Parkour - Especificación Técnica v2.0

## 📋 TABLA DE CONTENIDOS
1. Arquitectura General del Juego
2. Sistema de Progresión y Guardado
3. Diseño Detallado de Niveles
4. Mecánicas de Juego Expandidas
5. Sistema de Física y Movimiento
6. Interfaz de Usuario (UI/UX)
7. Sistema de Ranking y Puntuación
8. Monetización y Economía
9. Multijugador y Social
10. Implementación Técnica
11. Optimización y Rendimiento
12. Testing y Balanceo
13. Roadmap de Desarrollo

## 1. ARQUITECTURA GENERAL DEL JUEGO

### 1.1 Estructura de Carpetas en Roblox Studio
```
Workspace/
├── Levels/
│   ├── Level1_Forest/
│   │   ├── Platforms/
│   │   ├── Obstacles/
│   │   ├── Checkpoints/
│   │   ├── Portal/
│   │   └── Decorations/
│   ├── Level2_Water/
│   ├── Level3_Lava/
│   ├── Level4_Cyber/
│   ├── Level5_Celestial/
│   └── Level6_Troll/
├── Lobby/
│   ├── SpawnArea/
│   ├── LeaderboardDisplay/
│   ├── TutorialZone/
│   └── ShopArea/
└── SharedAssets/
    ├── Particles/
    ├── Sounds/
    └── Materials/

ServerScriptService/
├── GameCore/
│   ├── PlayerDataManager.lua
│   ├── LevelManager.lua
│   ├── CheckpointSystem.lua
│   └── AntiCheat.lua
├── Mechanics/
│   ├── HammerSystem.lua
│   ├── PlatformBehaviors.lua
│   └── PhysicsModifiers.lua
└── Economy/
    ├── CurrencyManager.lua
    └── PurchaseHandler.lua

ReplicatedStorage/
├── RemoteEvents/
├── RemoteFunctions/
├── SharedModules/
│   ├── PlayerStats.lua
│   └── GameConstants.lua
└── Assets/
    ├── Hammers/
    ├── Effects/
    └── UI/

StarterPlayer/
├── StarterPlayerScripts/
│   ├── MovementController.lua
│   ├── CameraController.lua
│   └── InputHandler.lua
└── StarterCharacterScripts/
    ├── CharacterEffects.lua
    └── DeathHandler.lua
```

### 1.2 Flujo de Juego Principal
El juego sigue una estructura clara de progresión lineal con elementos opcionales. Cuando un jugador entra al servidor, aparece en el Lobby Central donde puede ver su progreso actual, el ranking global y acceder a la tienda. Desde aquí, puede teletransportarse al último nivel desbloqueado o reiniciar desde cualquier nivel anterior.

Cada nivel funciona como una instancia semi-independiente con su propio sistema de checkpoints, pero todos están conectados mediante el sistema de martillos. La progresión se guarda automáticamente cada vez que el jugador obtiene un martillo o alcanza un checkpoint importante.

## 2. SISTEMA DE PROGRESIÓN Y GUARDADO

### 2.1 Estructura de Datos del Jugador
```lua
PlayerData = {
    UserId = 12345678,
    Username = "PlayerName",
    
    Progress = {
        CurrentLevel = 3,
        UnlockedLevels = {true, true, true, false, false, false},
        Hammers = {
            ["Hammer_Beginner"] = true,
            ["Hammer_Navigator"] = true,
            ["Hammer_Warrior"] = false,
            ["Hammer_Coded"] = false,
            ["Hammer_Divine"] = false
        },
        CheckpointsReached = {
            Level1 = {1, 2, 3}, -- IDs de checkpoints alcanzados
            Level2 = {1, 2},
            Level3 = {1}
        }
    },
    
    Statistics = {
        TotalPlayTime = 3600, -- en segundos
        TotalDeaths = 45,
        LevelCompletionTimes = {
            Level1 = 180,
            Level2 = 420,
            Level3 = 0 -- no completado aún
        },
        BestTimes = {
            Level1 = 180,
            Level2 = 420
        },
        DeathsPerLevel = {
            Level1 = 5,
            Level2 = 12,
            Level3 = 28
        }
    },
    
    Currency = {
        Coins = 500,
        Gems = 50,
        TrollTokens = 0
    },
    
    Inventory = {
        Skins = {"Default", "Forest_Camo", "Water_Suit"},
        Trails = {"Basic_Blue"},
        Emotes = {"Wave", "Dance1"}
    },
    
    Achievements = {
        ["FirstBlood"] = true,
        ["SpeedDemon_1"] = true,
        ["NoDeathRun_1"] = false,
        ["HammerCollector"] = false
    },
    
    Settings = {
        MusicVolume = 0.7,
        SFXVolume = 0.8,
        CameraShake = true,
        ShowGhostRunner = true
    }
}
```

### 2.2 Sistema de Checkpoints Detallado
Los checkpoints no son solo puntos de respawn, sino elementos estratégicos del juego. Cada nivel tiene entre 3 y 8 checkpoints distribuidos estratégicamente. Los jugadores deben decidir si activar un checkpoint (lo que consume una "vida" potencial) o arriesgarse a continuar para obtener mejores puntuaciones.

Tipos de checkpoints:
- **Checkpoint Estándar**: Se activa al tocarlo, respawn gratuito
- **Checkpoint Premium**: Requiere 10 monedas para activar, pero da buff temporal
- **Checkpoint Oculto**: Otorga logro especial y ruta alternativa
- **Checkpoint Temporal**: Solo dura 60 segundos después de activarse

## 3. DISEÑO DETALLADO DE NIVELES

### 3.1 NIVEL 1: Bosque de los Iniciados

**Ambiente y Atmósfera**
El Bosque de los Iniciados presenta una estética natural y acogedora con árboles frondosos, luz solar filtrada entre las hojas y sonidos ambientales de pájaros y viento suave. La paleta de colores utiliza verdes vibrantes, marrones tierra y toques dorados de luz solar.

**Estructura del Nivel**
- **Longitud total**: Aproximadamente 500 studs
- **Tiempo estimado**: 3-5 minutos para jugadores nuevos
- **Checkpoints**: 3 principales + 1 secreto

**Secciones Detalladas**:

*Sección 1 - Tutorial Básico (0-100 studs)*
Comienza con una explanada segura donde aparecen instrucciones flotantes. Las primeras plataformas son anchas (10x10 studs) con espacios pequeños entre ellas. Aquí se enseña el salto básico y el control de cámara.

*Sección 2 - Introducción a Obstáculos (100-250 studs)*
Las plataformas se vuelven más estrechas (6x6 studs) y aparecen los primeros obstáculos móviles: troncos rodantes que siguen patrones predecibles. Introduce el concepto de timing con plataformas que suben y bajan lentamente.

*Sección 3 - Puzzle del Árbol Antiguo (250-350 studs)*
Un gran árbol hueco requiere escalar por dentro usando saltos de pared. Aquí está el checkpoint secreto que requiere un salto de fe hacia una plataforma invisible marcada sutilmente por partículas flotantes.

*Sección 4 - Carrera Final (350-500 studs)*
Una colina ascendente con plataformas que se desmoronan 2 segundos después de pisarlas. La música se intensifica y aparece el portal de madera al final, sellado con cadenas místicas.

**Trampa Principal**
En la sección 2, hay un camino que parece obvio con plataformas brillantes y monedas, pero es una plataforma falsa que se rompe inmediatamente. Esto enseña a los jugadores a no confiar en lo obvio.

**Recompensas**
- Martillo del Principiante (obligatorio)
- 50 monedas distribuidas por el nivel
- Skin "Explorador del Bosque" (ruta secreta)
- Achievement "Primer Paso"

### 3.2 NIVEL 2: Ruinas Acuáticas

**Ambiente y Atmósfera**
Un templo antiguo semi-sumergido con cascadas, pozas de agua y arquitectura de piedra cubierta de musgo. La iluminación es azul-verdosa con rayos de luz que penetran desde arriba. Efectos de partículas de burbujas y niebla acuática.

**Mecánicas Nuevas**
- Superficies resbaladizas (fricción reducida al 30%)
- Corrientes de agua que empujan al jugador
- Plataformas flotantes que se hunden con el peso
- Zonas de natación con física modificada

**Estructura del Nivel**
- **Longitud total**: 800 studs
- **Tiempo estimado**: 8-12 minutos
- **Checkpoints**: 5 principales + 2 secretos

**Secciones Detalladas**:

*Sección 1 - Entrada del Templo (0-150 studs)*
Plataformas de piedra parcialmente sumergidas. El agua sube y baja en ciclos de 10 segundos, obligando a calcular el timing. Introduce las superficies resbaladizas gradualmente.

*Sección 2 - Sala de las Corrientes (150-350 studs)*
Chorros de agua horizontales empujan al jugador. Debe usar las corrientes estratégicamente para alcanzar plataformas lejanas. Algunos chorros son trampas que te lanzan al vacío.

*Sección 3 - Ascenso Vertical (350-500 studs)*
Torre central con plataformas circulares que rotan. El agua sube constantemente, creando presión temporal. Lianas colgantes permiten movimiento tipo Tarzán.

*Sección 4 - Laberinto Subacuático (500-650 studs)*
Sección completamente sumergida con física de natación. Burbujas de aire proporcionan oxígeno limitado. Puertas que se abren con interruptores de presión.

*Sección 5 - Escape Final (650-800 studs)*
El templo comienza a colapsar. Plataformas que caen, rocas que bloquean caminos. Secuencia de escape cronometrada de 60 segundos.

**Sistema de Oxígeno**
```lua
OxygenSystem = {
    MaxOxygen = 100,
    DrainRate = 2, -- por segundo bajo el agua
    RechargeRate = 10, -- por segundo en aire
    BubbleRestore = 30, -- al tocar burbuja
    DamageWhenEmpty = 10 -- daño por segundo
}
```

### 3.3 NIVEL 3: Templo de Lava

**Ambiente y Atmósfera**
Interior volcánico con ríos de lava, piedra obsidiana negra y cristales rojos brillantes. Efectos de calor distorsionan la visión. Partículas de ceniza flotan constantemente. La música es intensa con tambores tribales.

**Mecánicas Nuevas**
- Doble salto desbloqueado
- Plataformas que se derriten (timer visible)
- Géiseres de lava con patrones
- Zonas de calor extremo (daño gradual)

**Estructura Completa**
- **Longitud total**: 1200 studs
- **Tiempo estimado**: 15-20 minutos
- **Checkpoints**: 6 principales + 3 secretos

Las secciones incluyen puentes colapsables, saltos de precisión sobre lava, una sala de espejos con lava falsa (ilusión óptica), y un jefe mini-boss opcional (Golem de Lava) que otorga gemas extras.

### 3.4 NIVEL 4: Ciudad Cibernética

**Innovaciones Tecnológicas**
- Plataformas holográficas intermitentes
- Gravedad variable por zonas
- Hackeo de terminales para abrir rutas
- Láseres con patrones complejos
- Plataformas magnéticas (atracción/repulsión)

### 3.5 NIVEL 5: Fortaleza Celestial

**Desafíos Divinos**
- Viento dinámico que afecta trayectorias
- Plataformas de nubes con física especial
- Alas temporales para planear
- Puzzles de constelaciones
- Pruebas de memoria fotográfica

### 3.6 NIVEL 6: Obby Troll del Vacío

Este nivel merece especial atención por su naturaleza única. Es una experiencia diseñada para frustrar y sorprender incluso a jugadores veteranos.

**Mecánicas de Trolleo**
- Controles invertidos aleatoriamente
- Plataformas falsas indistinguibles
- Teletransportes sorpresa
- Cambios de gravedad súbitos
- Ilusiones ópticas constantes
- Música que se distorsiona para desorientar

**Secciones del Nivel Troll**:

*La Entrada Engañosa*
Parece un pasillo simple, pero cada baldosa tiene un efecto diferente: algunas te teletransportan, otras invierten controles, otras son falsas.

*El Laberinto Imposible*
Las paredes se mueven cuando no las miras. La solución requiere caminar hacia atrás con la cámara apuntando al frente.

*La Sala de Espejos Mentirosos*
Múltiples reflejos del jugador, pero solo uno muestra el camino real. Los demás llevan a trampas.

*El Salto de Fe Invertido*
Debes caer hacia arriba en lugar de saltar. La gravedad se invierte solo si no estás saltando.

*El Trono Final*
50% de probabilidad de ser falso y reiniciar todo el nivel. El verdadero trono tiene una pista microscópica.

## 4. MECÁNICAS DE JUEGO EXPANDIDAS

### 4.1 Sistema de Martillos Detallado

Cada martillo no es solo una llave, sino que otorga habilidades pasivas mientras lo tienes equipado:

**Martillo del Principiante**
- Aspecto: Madera simple con detalles de hierro
- Habilidad: +10% velocidad de movimiento
- Efecto visual: Pequeñas hojas verdes al caminar

**Martillo del Navegante**
- Aspecto: Coral azul con incrustaciones de perlas
- Habilidad: No resbalas en superficies mojadas
- Efecto visual: Gotas de agua que caen del martillo

**Martillo del Guerrero Ardiente**
- Aspecto: Obsidiana con venas de lava
- Habilidad: Inmunidad a daño de calor por 3 segundos (cooldown 30s)
- Efecto visual: Llamas pequeñas en la cabeza del martillo

**Martillo de Datos Codificados**
- Aspecto: Holográfico con código binario flotante
- Habilidad: Revela plataformas invisibles en un radio de 10 studs
- Efecto visual: Proyección holográfica intermitente

**Martillo Divino del Equilibrio**
- Aspecto: Cristal dorado con runas flotantes
- Habilidad: Doble salto mejorado + planeo corto
- Efecto visual: Alas etéreas aparecen al saltar

### 4.2 Sistema de Combate PvE (Opcional)

Aunque es principalmente un juego de plataformas, incluye elementos de combate opcionales:

**Mini-Bosses por Nivel**:
1. **Espíritu del Bosque**: Lanza raíces que debes esquivar
2. **Kraken Menor**: Tentáculos que emergen de pozos
3. **Elemental de Magma**: Lanza bolas de fuego en patrones
4. **IA Corrupta**: Hackea tus controles temporalmente
5. **Ángel Caído**: Crea tornados y tormentas

Derrotar mini-bosses otorga:
- Monedas extras (100-500)
- Gemas raras (5-20)
- Skins exclusivas
- Títulos especiales

### 4.3 Sistema de Habilidades Activas

Los jugadores pueden equipar hasta 3 habilidades activas desbloqueables:

**Dash** (Nivel 2)
- Propulsión rápida hacia adelante
- Cooldown: 5 segundos
- Mejora: Dash aéreo

**Marcador Temporal** (Nivel 3)
- Coloca un punto de retorno temporal (máx 10 segundos)
- Cooldown: 30 segundos
- Mejora: Duración extendida a 15 segundos

**Visión Verdadera** (Nivel 4)
- Revela trampas y secretos por 5 segundos
- Cooldown: 45 segundos
- Mejora: Duración de 8 segundos

**Escudo Etéreo** (Nivel 5)
- Inmunidad a un golpe
- Cooldown: 60 segundos
- Mejora: Refleja proyectiles

## 5. SISTEMA DE FÍSICA Y MOVIMIENTO

### 5.1 Parámetros de Movimiento Base
```lua
MovementConfig = {
    WalkSpeed = {
        Base = 16,
        Sprint = 24,
        Crouch = 8,
        Water = 12,
        Lava = 14 -- reducción por calor
    },
    
    JumpPower = {
        Base = 50,
        DoubleJump = 40,
        WaterJump = 35,
        LowGravity = 65
    },
    
    Physics = {
        Gravity = {
            Normal = 196.2,
            Water = 98.1,
            Space = 49.05,
            Inverted = -196.2
        },
        
        AirControl = 0.3, -- Control en el aire
        Friction = {
            Normal = 1.0,
            Ice = 0.1,
            Sticky = 2.0
        }
    }
}
```

### 5.2 Mecánicas de Movimiento Avanzadas

**Wall Jump System**
Permite rebotar entre paredes con un ángulo de 45 grados. Máximo 3 saltos consecutivos antes de necesitar tocar el suelo.

**Momentum Conservation**
La velocidad se conserva parcialmente al aterrizar, permitiendo bunny hopping para speedruns.

**Coyote Time**
0.2 segundos de gracia para saltar después de dejar una plataforma, mejorando la experiencia.

**Jump Buffering**
Si presionas salto 0.1 segundos antes de aterrizar, el salto se ejecuta automáticamente.

## 6. INTERFAZ DE USUARIO (UI/UX)

### 6.1 HUD Principal
```
┌─────────────────────────────────────────────────────┐
│ [❤️❤️❤️] Vidas          Nivel 3: Templo de Lava     │
│                                                      │
│ 🪙 527  💎 23          ⏱️ 05:23  ☠️ 12              │
│                                                      │
│ [═══════════▓────] 75% Progreso                     │
│                                                      │
│ 🔨 Martillos: [✓][✓][✗][✗][✗]                      │
└─────────────────────────────────────────────────────┘
```

### 6.2 Menú Principal
- **Jugar**: Acceso directo al último nivel
- **Niveles**: Selector visual de niveles desbloqueados
- **Tienda**: Cosméticos y mejoras
- **Rankings**: Tablas de clasificación
- **Logros**: Progreso de achievements
- **Configuración**: Audio, gráficos, controles

### 6.3 Sistema de Notificaciones
Notificaciones contextuales que aparecen sin interrumpir el juego:
- "¡Checkpoint Alcanzado!"
- "¡Nuevo Récord Personal!"
- "Secreto Descubierto"
- "¡Cuidado! Zona de Alto Riesgo"

## 7. SISTEMA DE RANKING Y PUNTUACIÓN

### 7.1 Cálculo de Puntuación
```lua
ScoreCalculation = {
    BasePoints = 1000, -- por completar nivel
    TimeBonus = function(time, parTime)
        return math.max(0, (parTime - time) * 10)
    end,
    DeathPenalty = 50, -- por muerte
    SecretBonus = 200, -- por secreto encontrado
    ComboMultiplier = 1.0, -- aumenta con acciones sin morir
    
    FinalScore = function(self, levelData)
        local score = self.BasePoints
        score = score + self.TimeBonus(levelData.time, levelData.parTime)
        score = score - (levelData.deaths * self.DeathPenalty)
        score = score + (levelData.secrets * self.SecretBonus)
        score = score * levelData.comboMultiplier
        return math.floor(score)
    end
}
```

### 7.2 Tablas de Clasificación
**Global**: Top 100 jugadores por puntuación total
**Por Nivel**: Top 50 mejores tiempos por nivel
**Semanal**: Competencias con premios
**Amigos**: Comparación con lista de amigos

### 7.3 Sistema de Ligas
- **Bronce**: 0-1000 puntos
- **Plata**: 1001-5000 puntos
- **Oro**: 5001-15000 puntos
- **Platino**: 15001-30000 puntos
- **Diamante**: 30001-50000 puntos
- **Maestro**: 50001+ puntos

## 8. MONETIZACIÓN Y ECONOMÍA

### 8.1 Monedas del Juego
**Monedas (🪙)**
- Obtenidas: Jugando niveles, desafíos diarios
- Uso: Comprar skins básicas, checkpoints extra
- Ratio: 10 monedas = 1 checkpoint extra

**Gemas (💎)**
- Obtenidas: Logros, mini-bosses, compra real
- Uso: Skins premium, efectos especiales
- Ratio: 100 gemas = $0.99 USD

**Troll Tokens (👹)**
- Obtenidas: Solo en nivel Troll
- Uso: Items exclusivos del "Club Troll"
- Ratio: No comprable, solo skill

### 8.2 Pases y Suscripciones
**VIP Pass (499 Robux/mes)**
- Doble monedas
- Acceso a servidor VIP
- Skin exclusiva mensual
- 5 checkpoints gratis diarios

**Season Pass (999 Robux)**
- 50 niveles de recompensas
- Skins temáticas de temporada
- Desafíos exclusivos
- Boost de XP permanente

### 8.3 Tienda de Cosméticos
**Categorías**:
- Skins de personaje (50-500 gemas)
- Efectos de salto (30-200 gemas)
- Trails/Estelas (40-300 gemas)
- Emotes (20-150 gemas)
- Sonidos de muerte (10-100 gemas)
- Mascotas acompañantes (100-1000 gemas)

## 9. MULTIJUGADOR Y SOCIAL

### 9.1 Modos Multijugador
**Carrera (2-8 jugadores)**
- Todos comienzan simultáneamente
- El primero en terminar gana
- Powerups aleatorios en el mapa
- Podio con top 3

**Supervivencia**
- Oleadas de obstáculos crecientes
- Último en pie gana
- Espectadores pueden votar por obstáculos

**Cooperativo**
- Puzzles que requieren 2+ jugadores
- Compartir vidas entre equipo
- Bonus por sincronización

### 9.2 Sistema de Clanes
```lua
ClanSystem = {
    MaxMembers = 50,
    Ranks = {"Novato", "Miembro", "Veterano", "Oficial", "Líder"},
    
    Benefits = {
        SharedBank = true, -- banco de monedas común
        ClanTag = true, -- tag en el nombre
        ClanChat = true, -- chat privado
        ClanWars = true, -- competencias entre clanes
        XPBoost = 1.1 -- 10% extra XP
    },
    
    Requirements = {
        CreateCost = 1000, -- gemas para crear
        MinLevel = 10, -- nivel mínimo para crear
        ActivityDays = 7 -- días antes de kick por inactividad
    }
}
```

### 9.3 Características Sociales
- Sistema de amigos con estados
- Mensajería privada
- Compartir replays de mejores momentos
- Sistema de mentor/aprendiz
- Intercambio de items cosméticos

## 10. IMPLEMENTACIÓN TÉCNICA

### 10.1 Scripts Core del Sistema

**PlayerDataManager.lua**
```lua
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local PlayerDataStore = DataStoreService:GetDataStore("PlayerData_v2")

local PlayerDataManager = {}
PlayerDataManager.__index = PlayerDataManager

-- Estructura de datos por defecto
local DEFAULT_DATA = {
    Version = 2,
    Progress = {
        CurrentLevel = 1,
        UnlockedLevels = {true, false, false, false, false, false},
        Hammers = {}
    },
    Statistics = {
        TotalPlayTime = 0,
        TotalDeaths = 0,
        JoinDate = os.time()
    },
    Currency = {
        Coins = 100, -- Starting bonus
        Gems = 10,
        TrollTokens = 0
    },
    Settings = {
        MusicVolume = 0.7,
        SFXVolume = 0.8
    }
}

function PlayerDataManager.new(player)
    local self = setmetatable({}, PlayerDataManager)
    self.Player = player
    self.Data = nil
    self.SaveInProgress = false
    self.LastSave = 0
    return self
end

function PlayerDataManager:LoadData()
    local success, data = pcall(function()
        return PlayerDataStore:GetAsync("Player_" .. self.Player.UserId)
    end)
    
    if success and data then
        -- Verificar versión y migrar si es necesario
        if data.Version < DEFAULT_DATA.Version then
            data = self:MigrateData(data)
        end
        self.Data = data
    else
        -- Crear nuevos datos
        self.Data = self:DeepCopy(DEFAULT_DATA)
    end
    
    return self.Data
end

function PlayerDataManager:SaveData(force)
    if self.SaveInProgress and not force then
        return false
    end
    
    local currentTime = os.time()
    if currentTime - self.LastSave < 30 and not force then
        return false -- Evitar saves muy frecuentes
    end
    
    self.SaveInProgress = true
    
    local success, err = pcall(function()
        PlayerDataStore:SetAsync("Player_" .. self.Player.UserId, self.Data)
    end)
    
    self.SaveInProgress = false
    self.LastSave = currentTime
    
    return success
end

function PlayerDataManager:AutoSave()
    while self.Player.Parent do
        wait(60) -- Guardar cada minuto
        self:SaveData()
    end
end

return PlayerDataManager
```

**CheckpointSystem.lua**
```lua
local CheckpointSystem = {}
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local activeCheckpoints = {}

function CheckpointSystem.CreateCheckpoint(position, level, checkpointId)
    local checkpoint = Instance.new("Part")
    checkpoint.Name = "Checkpoint_" .. level .. "_" .. checkpointId
    checkpoint.Size = Vector3.new(10, 1, 10)
    checkpoint.Position = position
    checkpoint.Anchored = true
    checkpoint.CanCollide = false
    checkpoint.Material = Enum.Material.Neon
    checkpoint.BrickColor = BrickColor.new("Lime green")
    checkpoint.Transparency = 0.5
    
    -- Efecto visual
    local selectionBox = Instance.new("SelectionBox")
    selectionBox.Adornee = checkpoint
    selectionBox.Color3 = Color3.new(0, 1, 0)
    selectionBox.LineThickness = 0.1
    selectionBox.Parent = checkpoint
    
    -- Particle effect
    local particle = Instance.new("ParticleEmitter")
    particle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    particle.Rate = 50
    particle.Lifetime = NumberRange.new(1, 2)
    particle.Speed = NumberRange.new(2)
    particle.VelocitySpread = 360
    particle.Parent = checkpoint
    
    -- Sistema de detección
    checkpoint.Touched:Connect(function(hit)
        local humanoid = hit.Parent:FindFirstChild("Humanoid")
        if humanoid then
            local player = game.Players:GetPlayerFromCharacter(hit.Parent)
            if player then
                CheckpointSystem.ActivateCheckpoint(player, level, checkpointId)
            end
        end
    end)
    
    checkpoint.Parent = workspace.Levels["Level" .. level].Checkpoints
    return checkpoint
end

function CheckpointSystem.ActivateCheckpoint(player, level, checkpointId)
    local playerData = activeCheckpoints[player.UserId] or {}
    
    -- Verificar si es un nuevo checkpoint
    if not playerData[level] or playerData[level] < checkpointId then
        playerData[level] = checkpointId
        activeCheckpoints[player.UserId] = playerData
        
        -- Efectos visuales y sonido
        local character = player.Character
        if character then
            local effect = game.ReplicatedStorage.Effects.CheckpointActivated:Clone()
            effect.Parent = character.HumanoidRootPart
            effect:Emit(50)
            
            -- Sonido
            local sound = Instance.new("Sound")
            sound.SoundId = "rbxassetid://131961136"
            sound.Volume = 0.5
            sound.Parent = character.HumanoidRootPart
            sound:Play()
            
            -- Notificación UI
            game.ReplicatedStorage.RemoteEvents.ShowNotification:FireClient(
                player, 
                "¡Checkpoint Activado!", 
                "Nivel " .. level .. " - Checkpoint " .. checkpointId
            )
        end
        
        -- Guardar en datos persistentes
        local dataManager = require(game.ServerScriptService.GameCore.PlayerDataManager)
        local playerDataObj = dataManager.GetPlayerData(player)
        if playerDataObj then
            playerDataObj.Data.Progress.CheckpointsReached["Level" .. level] = 
                playerDataObj.Data.Progress.CheckpointsReached["Level" .. level] or {}
            table.insert(
                playerDataObj.Data.Progress.CheckpointsReached["Level" .. level], 
                checkpointId
            )
            playerDataObj:SaveData()
        end
    end
end

function CheckpointSystem.RespawnAtCheckpoint(player)
    local playerData = activeCheckpoints[player.UserId]
    if not playerData then return end
    
    local currentLevel = -- Obtener nivel actual del jugador
    local checkpointId = playerData[currentLevel]
    
    if checkpointId then
        local checkpoint = workspace.Levels["Level" .. currentLevel]
            .Checkpoints:FindFirstChild("Checkpoint_" .. currentLevel .. "_" .. checkpointId)
        
        if checkpoint then
            -- Teletransportar al jugador
            player.Character:SetPrimaryPartCFrame(
                CFrame.new(checkpoint.Position + Vector3.new(0, 5, 0))
            )
            
            -- Efecto de respawn
            local effect = game.ReplicatedStorage.Effects.RespawnEffect:Clone()
            effect.Parent = player.Character.HumanoidRootPart
            effect:Play()
        end
    end
end

return CheckpointSystem
```

**PlatformBehaviors.lua**
```lua
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local PlatformBehaviors = {}

-- Plataforma que desaparece
function PlatformBehaviors.DisappearingPlatform(platform, disappearTime, reappearTime)
    local originalTransparency = platform.Transparency
    local canActivate = true
    
    platform.Touched:Connect(function(hit)
        if not canActivate then return end
        
        local humanoid = hit.Parent:FindFirstChild("Humanoid")
        if humanoid then
            canActivate = false
            
            -- Advertencia visual
            local warningTween = TweenService:Create(
                platform,
                TweenInfo.new(disappearTime * 0.8, Enum.EasingStyle.Linear),
                {Color = Color3.new(1, 0, 0)}
            )
            warningTween:Play()
            
            -- Desaparecer
            wait(disappearTime)
            local disappearTween = TweenService:Create(
                platform,
                TweenInfo.new(0.3, Enum.EasingStyle.Quad),
                {Transparency = 1}
            )
            disappearTween:Play()
            platform.CanCollide = false
            
            -- Reaparecer
            wait(reappearTime)
            platform.Transparency = originalTransparency
            platform.CanCollide = true
            platform.Color = Color3.new(1, 1, 1)
            canActivate = true
        end
    end)
end

-- Plataforma móvil
function PlatformBehaviors.MovingPlatform(platform, pointA, pointB, speed)
    local direction = 1
    local startPos = pointA
    local endPos = pointB
    
    RunService.Heartbeat:Connect(function(deltaTime)
        local currentPos = platform.Position
        local targetPos = direction == 1 and endPos or startPos
        local moveDirection = (targetPos - currentPos).Unit
        
        platform.Position = platform.Position + (moveDirection * speed * deltaTime)
        
        -- Cambiar dirección
        if (platform.Position - targetPos).Magnitude < 1 then
            direction = direction * -1
        end
        
        -- Mover jugadores sobre la plataforma
        local region = Region3.new(
            platform.Position - platform.Size/2,
            platform.Position + platform.Size/2
        )
        region = region:ExpandToGrid(4)
        
        for _, part in pairs(workspace:FindPartsInRegion3(region)) do
            local humanoid = part.Parent:FindFirstChild("Humanoid")
            if humanoid and part.Parent:FindFirstChild("HumanoidRootPart") then
                part.Parent.HumanoidRootPart.CFrame = 
                    part.Parent.HumanoidRootPart.CFrame + (moveDirection * speed * deltaTime)
            end
        end
    end)
end

-- Plataforma resbaladiza
function PlatformBehaviors.SlipperyPlatform(platform)
    platform.CustomPhysicalProperties = PhysicalProperties.new(
        0.7, -- Densidad
        0.01, -- Fricción (muy baja)
        0.2, -- Elasticidad
        1, -- FrictionWeight
        1 -- ElasticityWeight
    )
    platform.Material = Enum.Material.Ice
    
    -- Efecto visual
    local particle = Instance.new("ParticleEmitter")
    particle.Texture = "rbxasset://textures/particles/smoke_main.dds"
    particle.Rate = 20
    particle.Lifetime = NumberRange.new(0.5, 1)
    particle.Speed = NumberRange.new(1)
    particle.SpreadAngle = Vector2.new(10, 10)
    particle.Color = ColorSequence.new(Color3.new(0.8, 0.9, 1))
    particle.Parent = platform
end

-- Plataforma trampolín
function PlatformBehaviors.BouncyPlatform(platform, bouncePower)
    platform.Material = Enum.Material.Neon
    platform.BrickColor = BrickColor.new("Bright yellow")
    
    platform.Touched:Connect(function(hit)
        local humanoid = hit.Parent:FindFirstChild("Humanoid")
        if humanoid and hit.Parent:FindFirstChild("HumanoidRootPart") then
            local rootPart = hit.Parent.HumanoidRootPart
            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
            bodyVelocity.Velocity = Vector3.new(0, bouncePower, 0)
            bodyVelocity.Parent = rootPart
            
            -- Efecto de sonido
            local sound = Instance.new("Sound")
            sound.SoundId = "rbxassetid://131961136"
            sound.Volume = 0.3
            sound.Pitch = 1.5
            sound.Parent = platform
            sound:Play()
            
            game:GetService("Debris"):AddItem(bodyVelocity, 0.1)
        end
    end)
end

return PlatformBehaviors
```

### 10.2 Sistema de Anti-Cheat

```lua
local AntiCheat = {}
local Players = game:GetService("Players")

local suspiciousActivities = {}
local MAX_SPEED = 50 -- Velocidad máxima permitida
local MAX_JUMP = 100 -- Altura de salto máxima
local TELEPORT_THRESHOLD = 50 -- Distancia máxima de teletransporte

function AntiCheat.Initialize()
    Players.PlayerAdded:Connect(function(player)
        suspiciousActivities[player.UserId] = {
            warnings = 0,
            lastPosition = nil,
            lastCheck = tick()
        }
        
        player.CharacterAdded:Connect(function(character)
            AntiCheat.MonitorPlayer(player, character)
        end)
    end)
end

function AntiCheat.MonitorPlayer(player, character)
    local humanoid = character:WaitForChild("Humanoid")
    local rootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Monitor de velocidad
    spawn(function()
        while character.Parent do
            wait(0.1)
            local velocity = rootPart.Velocity.Magnitude
            
            if velocity > MAX_SPEED then
                AntiCheat.FlagPlayer(player, "SpeedHack", velocity)
            end
            
            -- Detección de teleport
            local data = suspiciousActivities[player.UserId]
            if data.lastPosition then
                local distance = (rootPart.Position - data.lastPosition).Magnitude
                local timeDelta = tick() - data.lastCheck
                
                if distance > TELEPORT_THRESHOLD and timeDelta < 0.5 then
                    AntiCheat.FlagPlayer(player, "Teleport", distance)
                end
            end
            
            data.lastPosition = rootPart.Position
            data.lastCheck = tick()
        end
    end)
    
    -- Monitor de salto
    humanoid.StateChanged:Connect(function(old, new)
        if new == Enum.HumanoidStateType.Jumping then
            wait(0.5)
            if rootPart.Position.Y - data.lastPosition.Y > MAX_JUMP then
                AntiCheat.FlagPlayer(player, "JumpHack", rootPart.Position.Y)
            end
        end
    end)
end

function AntiCheat.FlagPlayer(player, reason, value)
    local data = suspiciousActivities[player.UserId]
    data.warnings = data.warnings + 1
    
    -- Log para moderadores
    warn(string.format("AntiCheat: %s flagged for %s (Value: %s, Warnings: %d)", 
        player.Name, reason, tostring(value), data.warnings))
    
    -- Acciones según warnings
    if data.warnings >= 5 then
        player:Kick("Actividad sospechosa detectada")
    elseif data.warnings >= 3 then
        -- Advertencia al jugador
        game.ReplicatedStorage.RemoteEvents.ShowNotification:FireClient(
            player, 
            "⚠️ Advertencia", 
            "Se ha detectado actividad inusual"
        )
    end
end

return AntiCheat
```

## 11. OPTIMIZACIÓN Y RENDIMIENTO

### 11.1 Sistema de LOD (Level of Detail)
```lua
local LODSystem = {}

function LODSystem.SetupLOD(model, distances)
    -- distances = {high = 50, medium = 150, low = 300}
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    
    RunService.Heartbeat:Connect(function()
        if not character.Parent then return end
        
        local distance = (model.PrimaryPart.Position - character.HumanoidRootPart.Position).Magnitude
        
        if distance < distances.high then
            -- Máxima calidad
            for _, part in pairs(model:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = part:GetAttribute("OriginalTransparency") or 0
                end
            end
        elseif distance < distances.medium then
            -- Calidad media
            for _, part in pairs(model:GetDescendants()) do
                if part:IsA("BasePart") and part.Name:match("Detail") then
                    part.Transparency = 1
                end
            end
        else
            -- Baja calidad o invisible
            for _, part in pairs(model:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = 1
                end
            end
        end
    end)
end

return LODSystem
```

### 11.2 Streaming y Carga de Niveles
- StreamingEnabled activado con rango de 512 studs
- Carga asíncrona de assets pesados
- Precarga del siguiente nivel mientras juegas
- Descarga de niveles no utilizados

### 11.3 Optimización de Partículas
```lua
local ParticleOptimizer = {}

function ParticleOptimizer.OptimizeEmitter(emitter, quality)
    local multipliers = {
        Low = 0.25,
        Medium = 0.5,
        High = 1.0
    }
    
    local mult = multipliers[quality] or 1.0
    
    emitter.Rate = emitter.Rate * mult
    emitter.Lifetime = NumberRange.new(
        emitter.Lifetime.Min * mult,
        emitter.Lifetime.Max * mult
    )
    
    -- Deshabilitar completamente en calidad muy baja
    if quality == "VeryLow" then
        emitter.Enabled = false
    end
end

return ParticleOptimizer
```

## 12. TESTING Y BALANCEO

### 12.1 Métricas de Dificultad
```lua
DifficultyMetrics = {
    Level1 = {
        TargetCompletionRate = 0.95, -- 95% debe completarlo
        TargetTime = 180, -- 3 minutos
        MaxDeaths = 5,
        SkillFloor = "Beginner"
    },
    Level2 = {
        TargetCompletionRate = 0.80,
        TargetTime = 480, -- 8 minutos
        MaxDeaths = 15,
        SkillFloor = "Intermediate"
    },
    Level3 = {
        TargetCompletionRate = 0.60,
        TargetTime = 900, -- 15 minutos
        MaxDeaths = 30,
        SkillFloor = "Advanced"
    },
    Level4 = {
        TargetCompletionRate = 0.40,
        TargetTime = 1200, -- 20 minutos
        MaxDeaths = 50,
        SkillFloor = "Expert"
    },
    Level5 = {
        TargetCompletionRate = 0.20,
        TargetTime = 1800, -- 30 minutos
        MaxDeaths = 100,
        SkillFloor = "Master"
    },
    Level6 = {
        TargetCompletionRate = 0.05,
        TargetTime = 3600, -- 60 minutos
        MaxDeaths = 200,
        SkillFloor = "God"
    }
}
```

### 12.2 Sistema de Telemetría
Recopilar datos anónimos para balanceo:
- Puntos de muerte más comunes
- Tiempo promedio por sección
- Tasa de abandono por nivel
- Uso de checkpoints
- Rutas más utilizadas

### 12.3 Ajuste Dinámico de Dificultad (Opcional)
```lua
local DynamicDifficulty = {}

function DynamicDifficulty.AdjustForPlayer(player, level)
    local deaths = GetPlayerDeathsInLevel(player, level)
    
    if deaths > 20 then
        -- Hacer el nivel ligeramente más fácil
        return {
            PlatformSizeMultiplier = 1.2,
            TimerExtension = 5,
            ExtraCheckpoints = true
        }
    elseif deaths < 3 and level > 1 then
        -- Hacer el nivel ligeramente más difícil
        return {
            PlatformSizeMultiplier = 0.9,
            TimerReduction = 5,
            HiddenTraps = true
        }
    end
    
    return {} -- Sin ajustes
end
```

## 13. ROADMAP DE DESARROLLO

### 13.1 MVP (Minimum Viable Product) - 4 Semanas
**Semana 1-2: Core Mechanics**
- Sistema de movimiento básico
- Plataformas funcionales (estáticas y móviles)
- Sistema de checkpoints
- Nivel 1 completo

**Semana 3: Progresión**
- Sistema de guardado
- UI básica
- Niveles 2 y 3
- Sistema de martillos

**Semana 4: Polish**
- Efectos visuales y sonoros
- Optimización inicial
- Testing y bug fixes
- Preparación para lanzamiento

### 13.2 Fase 1: Lanzamiento (2 Semanas Post-MVP)
- Niveles 4 y 5
- Sistema de ranking básico
- Tienda de cosméticos simple
- Marketing inicial

### 13.3 Fase 2: Expansión (1 Mes)
- Nivel 6 (Troll)
- Modo multijugador
- Sistema de clanes
- Eventos semanales

### 13.4 Fase 3: Contenido Continuo
- Nuevos niveles mensuales
- Temporadas temáticas
- Colaboraciones
- Modo creativo para usuarios

## CONCLUSIÓN

Esta documentación proporciona una base sólida y exhaustiva para el desarrollo de "Obby de las Dimensiones". Cada sistema está diseñado para ser modular y escalable, permitiendo actualizaciones y mejoras continuas. El enfoque en la progresión satisfactoria, combinado con elementos de desafío extremo para jugadores veteranos, asegura una amplia audiencia objetivo.

Los sistemas técnicos están optimizados para el rendimiento en Roblox, mientras que los elementos de monetización están balanceados para ser justos pero rentables. La estructura modular permite que el desarrollo se realice por fases, asegurando un MVP funcional rápidamente mientras se mantiene la visión a largo plazo del proyecto.

Con esta documentación, el equipo de desarrollo en Cursor tendrá una guía clara y detallada para implementar cada aspecto del juego, desde los scripts básicos hasta los sistemas más complejos de progresión y multijugador.