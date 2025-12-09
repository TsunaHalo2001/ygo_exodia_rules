# 🎮 Yu-Gi-Oh! Duel Game - Flutter & Flame

Implementación de un juego de duelos de Yu-Gi-Oh para dos jugadores, desarrollado en **Flutter** utilizando el motor 2D **Flame Engine**.

## 📋 Tabla de Contenidos

- [Descripción](#-descripción)
- [Características](#-características)
- [Tecnologías](#-tecnologías)
- [Arquitectura](#-arquitectura)
- [Sistema de Duelos](#-sistema-de-duelos)
- [Instalación](#-instalación)
- [Uso](#-uso)
- [Estructura del Proyecto](#-estructura-del-proyecto)

## 📖 Descripción

Este proyecto recrea una experiencia básica del sistema de duelo del juego original de Yu-Gi-Oh, incluyendo gestión completa de turnos, fases, manos, campo de batalla, invocaciones, sistema de combate y puntos de vida.

## ✨ Características

### Sistema de Juego
- ⚔️ **Duelos PvP**: Modo para dos jugadores humanos
- 🎴 **Gestión de cartas**: Mano, deck, cementerio y campo de batalla
- 🔄 **Sistema de turnos**: Implementación completa de las 6 fases del TCG
- ⚡ **Sistema de combate**: Cálculo de daño, posiciones de ataque/defensa
- 💫 **Invocaciones**: Normal y Set (defensa)
- 🎯 **Ataques directos**: Cuando el oponente no tiene monstruos

### Características Técnicas
- 🎨 Animaciones fluidas de transición entre fases
- 📱 Interfaz responsiva con overlays de Flutter
- 🃏 Componentes gráficos modulares para cartas
- 🎮 Gestión reactiva del estado con ValueNotifier
- 🔊 Sistema de audio integrado

## 🛠 Tecnologías

| Tecnología | Propósito |
|------------|-----------|
| **Flutter** | Framework principal, UI y widgets |
| **Flame Engine** | Motor 2D, renderizado y componentes |
| **Flame Audio** | Reproducción de música BGM |
| **ValueNotifier** | Gestión reactiva del estado |

## 🏗 Arquitectura

### Componentes Principales

```
DuelGame (FlameGame)
├── PlayerData (Modelo de jugador)
│   ├── Deck
│   ├── Hand
│   ├── Graveyard
│   └── Life Points
├── CardComponent (Visualización de cartas)
├── GameField (Campo de batalla)
│   ├── ZoneComponent (Zonas de monstruos/hechizos)
│   └── HandComponent (Zona de mano)
└── Phase/Turn Components (Animaciones)
```

### Clase Principal: `DuelGame`

La clase `DuelGame` extiende `FlameGame` y gestiona:

- ✅ Fases del duelo
- ✅ Sistema de turnos
- ✅ Interacción entre jugadores
- ✅ Lógica de combate
- ✅ Componentes gráficos
- ✅ Reproducción de música
- ✅ Menús y overlays

## 🎯 Sistema de Duelos

### Modos de Juego

```dart
enum GameMode {
  testing,  // Dos jugadores humanos (PvP)
  vsAI,     // Jugador vs Inteligencia Artificial
}
```

### Fases del Turno

El sistema implementa las 6 fases clásicas del TCG:

```dart
enum TurnPhases {
  drawPhase,      // 1. Fase de Robo
  standbyPhase,   // 2. Fase de Preparación
  mainPhase1,     // 3. Fase Principal 1
  battlePhase,    // 4. Fase de Batalla
  mainPhase2,     // 5. Fase Principal 2
  endPhase,       // 6. Fase Final
}
```

**Transiciones entre fases:**
- Animaciones visuales personalizadas
- Temporizadores de transición
- Actualizaciones reactivas del estado

### Sistema de Combate

#### Cálculo de Daño
```
ATK atacante > ATK/DEF defensor → Daño al oponente
ATK atacante < ATK/DEF defensor → Daño al jugador actual
ATK atacante = ATK/DEF defensor → Ambos destruidos, sin daño
```

#### Características del Combate
- ⚔️ Comparación ATK vs ATK
- 🛡️ Comparación ATK vs DEF
- 💔 Reducción de Life Points
- 🪦 Envío automático al cementerio
- 🎯 Ataques directos cuando no hay defensa

### Invocaciones

#### Tipos de Invocación
- **Invocación Normal** (Posición de Ataque)
  - Carta visible, puede atacar el siguiente turno
  - Rotación: 0°

- **Set** (Posición de Defensa)
  - Carta boca abajo, no puede atacar
  - Rotación: 90°

```dart
// Ejemplo de Set
selectedCardComponent?.angle = pi / 2;
selectedCardComponent?.isInDefensePosition = true;
```

## 🎮 Uso

### Iniciar un Duelo

```dart
// Modo PvP
final game = DuelGame(mode: GameMode.testing);
```

### Controles Básicos

| Acción | Control |
|--------|---------|
| Seleccionar carta | Tap/Click |
| Invocar monstruo | Tap en zona vacía del campo |
| Cambiar posición | Tap en monstruo invocado |
| Atacar | Tap en monstruo atacante → Tap en objetivo |
| Ver deck | Botón Deck |
| Cambiar fase | Automático/Botón Next Phase |

### Menús Disponibles

- 📚 **Deck Menu**: Ver cartas del deck
- ⭐ **Extra Deck Menu**: Ver cartas del Extra Deck
- ℹ️ **Card Info**: Información detallada de la carta
- 🎴 **Summon Menu**: Opciones de invocación

## 📁 Estructura del Proyecto

```
lib/
├── game/
│   ├── duel_game.dart          # Clase principal del juego
│   ├── components/
│   │   ├── card_component.dart # Componente visual de cartas
│   │   ├── game_field.dart     # Campo de batalla
│   │   ├── zone_component.dart # Zonas de juego
│   │   └── hand_component.dart # Zona de mano
│   ├── models/
│   │   ├── player_data.dart    # Modelo de jugador
│   │   └── card_model.dart     # Modelo de carta
│   └── overlays/
│       ├── summon_menu.dart    # Menú de invocación
│       ├── deck_menu.dart      # Menú del deck
│       └── card_info.dart      # Info de carta
├── assets/
│   ├── images/                 # Sprites y fondos
│   └── audio/
│       └── BGM_DUEL_NORMAL_*.ogg # Música de duelo
└── main.dart                   # Punto de entrada
```

## 🔧 Funcionalidades Avanzadas

### Gestión de Estado

El juego utiliza `ValueNotifier` para gestión reactiva:

```dart
final ValueNotifier<TurnPhases> currentPhaseNotifier;
```

### Sistema de Audio

Selección aleatoria de BGM:

```dart
currentBgm = Random().nextInt(16) + 1;
FlameAudio.bgm.play('BGM_DUEL_NORMAL_$bgmPadded.ogg');
```

### Animaciones de Fase

```dart
await animatePhaseChange(
  "Battle Phase",
  phaseSize,
  phasePos,
  TurnPhases.battlePhase
);
```

## 🎯 Características del Código

### Flujo de Inicialización (`onLoad`)

1. ✅ Carga del fondo del campo
2. ✅ Generación de manos iniciales
3. ✅ Creación del campo de batalla
4. ✅ Inicialización de componentes visuales
5. ✅ Asignación del turno inicial
6. ✅ Inicio de música BGM

### Renderizado de Cartas

```dart
final cardComponent = CardComponent(
  card: card,
  isFaceUp: true,
  size: size.y * 0.3,
  position: Vector2(0, size.y * 0.475),
  player: player1,
);
```

### Control de Overlays

```dart
// Mostrar menú
overlays.add('SummonMenu');

// Ocultar menú
overlays.remove('DeckMenu1');
```

## 👥 Autores

- Joan Villamil
- Vanessa Durán
- Jesús Loaiza