-- GameConstants.lua
-- Constantes del juego para mantener valores consistentes

local GameConstants = {}

-- Configuración de niveles
GameConstants.LEVELS = {
    FOREST = 1,
    WATER = 2,
    LAVA = 3,
    CYBER = 4,
    CELESTIAL = 5,
    TROLL = 6
}

-- Nombres de martillos
GameConstants.HAMMERS = {
    BEGINNER = "Hammer_Beginner",
    NAVIGATOR = "Hammer_Navigator", 
    WARRIOR = "Hammer_Warrior",
    CODED = "Hammer_Coded",
    DIVINE = "Hammer_Divine"
}

-- Configuración de checkpoints
GameConstants.CHECKPOINT_TYPES = {
    STANDARD = "Standard",
    PREMIUM = "Premium",
    HIDDEN = "Hidden",
    TEMPORAL = "Temporal"
}

-- Configuración de monedas y economía
GameConstants.CURRENCY = {
    COIN_VALUE = 1,
    GEM_VALUE = 100,
    TROLL_TOKEN_VALUE = 500,
    
    -- Costos de checkpoints premium
    PREMIUM_CHECKPOINT_COST = 10,
    
    -- Recompensas por nivel
    LEVEL_COMPLETION_COINS = 50,
    LEVEL_COMPLETION_GEMS = 5,
    
    -- Recompensas por martillos
    HAMMER_COINS = 25,
    HAMMER_GEMS = 2
}

-- Configuración de física y movimiento
GameConstants.PHYSICS = {
    JUMP_POWER = 50,
    WALK_SPEED = 16,
    RUN_SPEED = 24,
    
    -- Configuración de plataformas
    PLATFORM_FADE_TIME = 2.0,
    MOVING_PLATFORM_SPEED = 5.0,
    
    -- Configuración de obstáculos
    OBSTACLE_DAMAGE = 1,
    SAFE_ZONE_HEIGHT = 5
}

-- Configuración de UI
GameConstants.UI = {
    -- Tiempos de animación
    FADE_IN_TIME = 0.5,
    FADE_OUT_TIME = 0.3,
    
    -- Colores del tema
    PRIMARY_COLOR = Color3.fromRGB(0, 150, 255),
    SECONDARY_COLOR = Color3.fromRGB(255, 255, 255),
    SUCCESS_COLOR = Color3.fromRGB(0, 255, 0),
    ERROR_COLOR = Color3.fromRGB(255, 0, 0),
    WARNING_COLOR = Color3.fromRGB(255, 255, 0)
}

-- Configuración de sonido
GameConstants.AUDIO = {
    -- Volúmenes por defecto
    DEFAULT_MUSIC_VOLUME = 0.7,
    DEFAULT_SFX_VOLUME = 0.8,
    
    -- IDs de sonidos (se configurarán en Roblox Studio)
    SOUND_JUMP = "JumpSound",
    SOUND_COIN = "CoinSound",
    SOUND_DEATH = "DeathSound",
    SOUND_CHECKPOINT = "CheckpointSound",
    SOUND_HAMMER = "HammerSound"
}

-- Configuración de guardado
GameConstants.SAVE = {
    -- Frecuencia de guardado automático (en segundos)
    AUTO_SAVE_INTERVAL = 30,
    
    -- Datos que se guardan automáticamente
    AUTO_SAVE_DATA = {
        "Progress",
        "Statistics", 
        "Currency",
        "Achievements"
    }
}

-- Configuración de anti-cheat
GameConstants.ANTI_CHEAT = {
    -- Tiempo máximo permitido para completar un nivel (en segundos)
    MAX_LEVEL_TIME = 300, -- 5 minutos
    
    -- Distancia máxima permitida para teletransporte
    MAX_TELEPORT_DISTANCE = 1000,
    
    -- Verificaciones de integridad
    ENABLE_SPEED_CHECKS = true,
    ENABLE_POSITION_CHECKS = true,
    ENABLE_TIME_CHECKS = true
}

-- Configuración de multijugador
GameConstants.MULTIPLAYER = {
    -- Número máximo de jugadores por servidor
    MAX_PLAYERS = 20,
    
    -- Tiempo de espera para respawn (en segundos)
    RESPAWN_TIME = 3,
    
    -- Configuración de ghost runners
    GHOST_RUNNER_DURATION = 60, -- 1 minuto
    MAX_GHOST_RUNNERS = 5,
    
    -- Configuraciones adicionales de multijugador
    MAX_PLAYERS_PER_LEVEL = 10,
    CHAT_COOLDOWN = 3,
    SPECTATE_DISTANCE = 20,
    CHALLENGE_TIMEOUT = 30,
    TOURNAMENT_MIN_PLAYERS = 4,
    FRIEND_REQUEST_TIMEOUT = 60,
    CLAN_MAX_MEMBERS = 50,
    CLAN_CREATION_COST = 1000,
    REPORT_COOLDOWN = 300,
    MODERATOR_ACTION_COOLDOWN = 60
}

-- Configuración de economía
GameConstants.ECONOMY = {
    STARTING_COINS = 100,
    STARTING_GEMS = 5,
    STARTING_TOKENS = 0,
    BASE_LEVEL_REWARD = 50,
    MIN_LEVEL_REWARD = 10,
    DAILY_REWARD_COINS_MIN = 50,
    DAILY_REWARD_COINS_MAX = 150,
    DAILY_REWARD_GEMS_MIN = 1,
    DAILY_REWARD_GEMS_MAX = 3,
    SPECIAL_LEVEL_BONUS = 100,
    PERFECT_RUN_BONUS = 25,
    SPEED_RUN_BONUS = 50,
    FIRST_TIME_BONUS = 100,
    WEEKLY_BONUS = 500,
    MONTHLY_BONUS = 2000,
    ACHIEVEMENT_REWARD_COINS = 25,
    ACHIEVEMENT_REWARD_GEMS = 1,
    TOURNAMENT_REWARD_COINS = 200,
    TOURNAMENT_REWARD_GEMS = 5,
    CLAN_REWARD_COINS = 100,
    CLAN_REWARD_GEMS = 2,
    REFERRAL_REWARD_COINS = 250,
    REFERRAL_REWARD_GEMS = 10,
    LOGIN_STREAK_BONUS = 50,
    MAX_LOGIN_STREAK = 7,
    LOGIN_STREAK_MULTIPLIER = 1.5
}

-- Configuración de audio
GameConstants.AUDIO = {
    -- Volúmenes por defecto
    DEFAULT_MUSIC_VOLUME = 0.7,
    DEFAULT_SFX_VOLUME = 0.8,
    DEFAULT_VOICE_VOLUME = 0.6,
    DEFAULT_AMBIENT_VOLUME = 0.5,
    
    -- Configuración de efectos de sonido
    SFX_CONFIG = {
        JUMP = { volume = 0.5, pitch = 1.0 },
        DEATH = { volume = 0.6, pitch = 1.0 },
        COIN = { volume = 0.4, pitch = 1.0 },
        GEM = { volume = 0.5, pitch = 1.0 },
        CHECKPOINT = { volume = 0.6, pitch = 1.0 },
        HAMMER = { volume = 0.5, pitch = 1.0 },
        BUTTON = { volume = 0.3, pitch = 1.0 },
        ERROR = { volume = 0.4, pitch = 1.0 },
        SUCCESS = { volume = 0.5, pitch = 1.0 }
    },
    
    -- Configuración de música
    MUSIC_CONFIG = {
        LOBBY = { volume = 0.5, fadeIn = 2, fadeOut = 1 },
        MENU = { volume = 0.5, fadeIn = 2, fadeOut = 1 },
        FOREST = { volume = 0.4, fadeIn = 3, fadeOut = 2 },
        WATER = { volume = 0.4, fadeIn = 3, fadeOut = 2 },
        LAVA = { volume = 0.4, fadeIn = 3, fadeOut = 2 },
        CYBER = { volume = 0.4, fadeIn = 3, fadeOut = 2 },
        CELESTIAL = { volume = 0.4, fadeIn = 3, fadeOut = 2 },
        TROLL = { volume = 0.4, fadeIn = 3, fadeOut = 2 },
        VICTORY = { volume = 0.6, fadeIn = 1, fadeOut = 1 },
        DEFEAT = { volume = 0.5, fadeIn = 1, fadeOut = 1 }
    },
    
    -- Configuración de efectos 3D
    SFX_3D_CONFIG = {
        MAX_DISTANCE = 100,
        ROLLOFF_MODE = Enum.RollOffMode.Linear,
        MIN_DISTANCE = 5
    },
    
    -- Configuración de ambiente
    AMBIENT_CONFIG = {
        FOREST = { volume = 0.3, looped = true },
        WATER = { volume = 0.3, looped = true },
        LAVA = { volume = 0.3, looped = true },
        CYBER = { volume = 0.3, looped = true },
        CELESTIAL = { volume = 0.3, looped = true },
        TROLL = { volume = 0.3, looped = true }
    }
}

-- Configuración de logros
GameConstants.ACHIEVEMENTS = {
    FIRST_BLOOD = {
        id = "FirstBlood",
        name = "Primera Sangre",
        description = "Muere por primera vez",
        reward = {coins = 10, gems = 1}
    },
    
    SPEED_DEMON_1 = {
        id = "SpeedDemon_1", 
        name = "Demonio de Velocidad I",
        description = "Completa el nivel 1 en menos de 2 minutos",
        reward = {coins = 25, gems = 2}
    },
    
    NO_DEATH_RUN_1 = {
        id = "NoDeathRun_1",
        name = "Sin Muerte I", 
        description = "Completa el nivel 1 sin morir",
        reward = {coins = 50, gems = 5}
    },
    
    HAMMER_COLLECTOR = {
        id = "HammerCollector",
        name = "Coleccionista de Martillos",
        description = "Obtén todos los martillos",
        reward = {coins = 100, gems = 10, trollTokens = 1}
    }
}

return GameConstants 