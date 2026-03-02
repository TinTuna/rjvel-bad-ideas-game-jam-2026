extends CanvasLayer
## LoadingScreen - Visual feedback during scene transitions
##
## This scene handles the fade in/out animation during scene loading.
## It automatically cleans itself up after the transition completes.

# ============================================================================
# SIGNALS
# ============================================================================

## Emitted when the loading screen has fully faded in and is ready
signal loading_screen_ready()


# ============================================================================
# EXPORTS
# ============================================================================

## Reference to the AnimationPlayer node
@export var animation_player: AnimationPlayer


# ============================================================================
# LIFECYCLE
# ============================================================================

func _ready() -> void:
    # Wait for the fade-in animation to complete
    await animation_player.animation_finished
    
    # Emit that the loading screen is ready
    loading_screen_ready.emit()


# ============================================================================
# CALLBACK METHODS
# ============================================================================

## Called when loading progress changes
## @param new_value: float - Progress from 0.0 to 1.0
func on_progress_changed(new_value: float) -> void:
    # You can use this to update a progress bar or other visual feedback
    # For example:
    # progress_bar.value = new_value * 100
    pass


## Called when the scene has finished loading
func on_load_finished() -> void:
    # Play the fade-out animation
    animation_player.play_backwards("transition")
    
    # Wait for animation to complete
    await animation_player.animation_finished
    
    # Clean up this loading screen
    queue_free()
