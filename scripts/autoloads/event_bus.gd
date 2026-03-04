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
# TIME/CALENDAR EVENTS
# ============================================================================

## Emitted every game hour
## @param hour: int - Current hour (0-23)
signal time_hour_changed(hour: int)

## Emitted when a new day starts
## @param day_of_week: int - Day of week (0-6, 0=Monday)
## @param total_days: int - Total days elapsed since game start
signal time_day_changed(day_of_week: int, total_days: int)

## Emitted when dusk begins (10 PM / 22:00)
signal time_dusk_started()

## Emitted when dawn begins (4 AM / 04:00)
signal time_dawn_started()

## Emitted when transitioning between day/night periods
## @param is_night: bool - True if now nighttime (22:00-04:00)
signal time_period_changed(is_night: bool)


# ============================================================================
# MUSIC EVENTS
# ============================================================================

## Emitted when music should transition to a new track
## @param track_name: String - Name of the music track (from Constants.MUSIC)
## @param crossfade_duration: float - How long to crossfade between tracks (seconds, default 1.0)
signal music_transition_requested(track_name: String, crossfade_duration: float)

## Emitted when music should stop
## @param fade_duration: float - How long to fade out (seconds, default 1.0)
signal music_stop_requested(fade_duration: float)

## Emitted when music should be paused
signal music_pause_requested()

## Emitted when music should be resumed
signal music_resume_requested()

## Emitted when music volume should change
## @param volume: float - Volume multiplier (0.0 to 1.0)
signal music_volume_changed(volume: float)


# ============================================================================
# LIFECYCLE
# ============================================================================

func _ready() -> void:
	print("[EventBus] Initialized")
