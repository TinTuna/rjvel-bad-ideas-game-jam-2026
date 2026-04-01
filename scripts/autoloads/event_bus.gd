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

## Emitted when a new day/level starts
## @param day_number: int - Day of week (0-6, 0=Monday)
signal day_started(day_number: int)

## Emitted when the cat jumps
## @param None
signal cat_jumped()

## Emitted when the cat is pushed back by an NPC
## @param None
signal cat_pushed_back()

## Emitted when the cat enters an interactable's area
signal cat_near_interactable()

## Emitted when the cat leaves an interactable's area
signal cat_left_interactable()

## Emitted when player enters Cat Box
## @param None
signal player_entered_box()

## Emitted when player leaves Cat Box
## @param None
signal player_left_box()

## Emitted when player picks up item
## @param None
signal player_picked_up_item(item: Node2D)

## Emitted when player puts down item
## @param None
signal player_put_down_item(item: Node2D)

# ============================================================================
# LEVEL/SCENE EVENTS
# ============================================================================

## Emitted when a level is loaded
## @param level_name: String - Name of the loaded level
signal level_loaded(level_name: String)

## Emitted when the player completes a level
signal level_completed()

## Emitted when transitioning to a new scene
## @param scene_path: String - Path to the scene
signal scene_transition_requested(scene_path: String)

# ============================================================================
# DAY EVENTS (Discrete Day System)
# ============================================================================
# Note: day_started signal is defined in PLAYER EVENTS section above
# Each day is a discrete level, no real-time hour/minute progression

## Emitted on day 0 when the glass is knocked down
signal glass_knocked_down()

## Emitted on day 0 when the glass is back up
signal glass_reset()

## Emitted on day 2 when the toaster is burnt and smoking
signal toaster_burnt()

## Emitted on day 2 when the toaster is reset
signal toaster_reset()

## Emitted on day 2 when the kitchen window is open
signal window_open()

## Emitted on day 3 when pizza is delivered
signal pizza_delivered()

## Emitted on day 3 when pizza is put on table
signal pizza_put_on_table()

## Emitted on day 3 when mother opens entry door
signal mother_opens_door()

## Emitted on day 3 when mother closes entry door
signal mother_closes_door()

## Emitted on day 4 when twins get pizza
signal twins_feasted()

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
