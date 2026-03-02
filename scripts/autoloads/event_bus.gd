extends Node
## EventBus - Centralized event management system
##
## A global singleton for managing game events using signals.
## This allows decoupled communication between different parts of the game.
##
## Usage:
##   EventBus.connect("event_name", callable)
##   EventBus.emit_signal("event_name", arg1, arg2)

# ============================================================================
# GAME STATE EVENTS
# ============================================================================

## Emitted when the game starts
signal game_started()

## Emitted when the game is paused
signal game_paused()

## Emitted when the game is resumed
signal game_resumed()

## Emitted when the game ends
signal game_ended()


# ============================================================================
# PLAYER EVENTS
# ============================================================================

## Emitted when the player takes damage
## @param damage: int - Amount of damage taken
signal player_damaged(damage: int)

## Emitted when the player dies
signal player_died()

## Emitted when the player respawns
signal player_respawned()

## Emitted when player health changes
## @param current_health: int - Current health value
## @param max_health: int - Maximum health value
signal player_health_changed(current_health: int, max_health: int)


# ============================================================================
# LEVEL/SCENE EVENTS
# ============================================================================

## Emitted when a level is loaded
## @param level_name: String - Name of the loaded level
signal level_loaded(level_name: String)

## Emitted when transitioning to a new scene
## @param scene_path: String - Path to the scene
signal scene_transition_requested(scene_path: String)


# ============================================================================
# LIFECYCLE
# ============================================================================

func _ready() -> void:
	print("[EventBus] Initialized")
