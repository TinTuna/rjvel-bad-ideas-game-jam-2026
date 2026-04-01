class_name HUD
extends CanvasLayer
## HUD - In-game heads-up display
##
## Displays current day name
## Updates via EventBus signals

# ============================================================================
# NODE REFERENCES (using unique names %)
# ============================================================================

@onready var day_label: Label = %DayLabel


# ============================================================================
# STATE
# ============================================================================

## Current day of week (0-6, 0=Monday)
var current_day: int = 0

# ============================================================================
# LIFECYCLE
# ============================================================================

func _ready() -> void:
	# Connect to EventBus signals
	EventBus.day_started.connect(_on_day_started)

	# Initialize display
	update_day_display()

# ============================================================================
# DAY DISPLAY
# ============================================================================

## Set the current day (0-6)
func set_day(day: int) -> void:
	current_day = clamp(day, 0, 6)
	update_day_display()


## Update the day label text
func update_day_display() -> void:
	day_label.text = get_day_name().to_upper()


## Get the current day name from Constants
func get_day_name() -> String:
	if Constants.DAY_NAMES.has(current_day):
		return Constants.DAY_NAMES[current_day]
	return "UNKNOWN"


# ============================================================================
# EVENT HANDLERS
# ============================================================================

## Handle day started event
func _on_day_started(day_number: int) -> void:
	set_day(day_number)