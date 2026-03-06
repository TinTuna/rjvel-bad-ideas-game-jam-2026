class_name HUD
extends CanvasLayer
## HUD - In-game heads-up display
##
## Displays current day name and stress level (3 lightning bolts)
## Updates via EventBus signals

# ============================================================================
# NODE REFERENCES (using unique names %)
# ============================================================================

@onready var day_label: Label = %DayLabel
@onready var stress_bolt_1: ColorRect = %StressBolt1
@onready var stress_bolt_2: ColorRect = %StressBolt2
@onready var stress_bolt_3: ColorRect = %StressBolt3
@onready var stress_meter: HBoxContainer = %StressMeter

# Store references to all stress indicators for easy iteration
@onready var stress_bolts: Array[ColorRect] = [stress_bolt_1, stress_bolt_2, stress_bolt_3]


# ============================================================================
# STATE
# ============================================================================

## Current day of week (0-6, 0=Monday)
var current_day: int = 0

## Current stress level (0-3)
var current_stress: int = 3

## Animation tween reference
var active_tween: Tween = null


# ============================================================================
# LIFECYCLE
# ============================================================================

func _ready() -> void:
	# Connect to EventBus signals
	EventBus.day_started.connect(_on_day_started)
	EventBus.player_stress_changed.connect(_on_stress_changed)
	EventBus.player_stress_lost.connect(_on_stress_lost)
	EventBus.player_stress_restored.connect(_on_stress_restored)
	
	# Initialize display
	update_day_display()
	update_stress_display()
	
	print("[HUD] Initialized")


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
# STRESS DISPLAY
# ============================================================================

## Set stress level (0-3) with optional animation
func set_stress(stress: int, animate: bool = false) -> void:
	var old_stress := current_stress
	current_stress = clamp(stress, 0, 3)
	
	if animate and old_stress != current_stress:
		if current_stress < old_stress:
			animate_stress_loss()
		else:
			animate_stress_gain()
	else:
		update_stress_display()


## Update stress bolt visibility based on current stress
func update_stress_display() -> void:
	for i in range(stress_bolts.size()):
		stress_bolts[i].visible = i < current_stress


## Animate stress loss (shake + fade out)
func animate_stress_loss() -> void:
	# Cancel any active tween
	if active_tween and active_tween.is_valid():
		active_tween.kill()
	
	# Create shake + fade animation
	active_tween = create_tween()
	active_tween.set_parallel(true)  # Run all animations simultaneously
	
	# Shake the entire stress meter
	var original_position := stress_meter.position
	active_tween.tween_property(stress_meter, "position:x", original_position.x + 5, 0.05)
	active_tween.chain().tween_property(stress_meter, "position:x", original_position.x - 5, 0.05)
	active_tween.chain().tween_property(stress_meter, "position:x", original_position.x + 5, 0.05)
	active_tween.chain().tween_property(stress_meter, "position:x", original_position.x, 0.05)
	
	# Fade out the lost bolt (the one at current_stress index)
	if current_stress >= 0 and current_stress < stress_bolts.size():
		var lost_bolt := stress_bolts[current_stress]
		active_tween.tween_property(lost_bolt, "modulate:a", 0.0, 0.2)
	
	# Wait for animations to complete, then update display
	await active_tween.finished
	update_stress_display()
	
	# Reset modulate alpha for all bolts
	for bolt in stress_bolts:
		bolt.modulate.a = 1.0


## Animate stress gain (fade in + brief glow)
func animate_stress_gain() -> void:
	# Cancel any active tween
	if active_tween and active_tween.is_valid():
		active_tween.kill()
	
	# First update display to show new bolt
	update_stress_display()
	
	# Then animate the newly visible bolt
	var new_bolt_index := current_stress - 1
	if new_bolt_index >= 0 and new_bolt_index < stress_bolts.size():
		var new_bolt := stress_bolts[new_bolt_index]
		
		# Start invisible
		new_bolt.modulate.a = 0.0
		
		# Fade in with slight scale pulse
		active_tween = create_tween()
		active_tween.set_parallel(true)
		active_tween.tween_property(new_bolt, "modulate:a", 1.0, 0.3)
		active_tween.tween_property(new_bolt, "scale", Vector2(1.2, 1.2), 0.15)
		active_tween.chain().tween_property(new_bolt, "scale", Vector2(1.0, 1.0), 0.15)


# ============================================================================
# EVENT HANDLERS
# ============================================================================

## Handle day started event
func _on_day_started(day_number: int) -> void:
	set_day(day_number)
	print("[HUD] Day started: %s" % get_day_name())


## Handle stress changed event
func _on_stress_changed(new_stress: int) -> void:
	set_stress(new_stress, true)  # Animate the change


## Handle stress lost event
func _on_stress_lost(amount: int) -> void:
	set_stress(current_stress - amount, true)
	print("[HUD] Stress lost! Current: %d/3" % current_stress)


## Handle stress restored event
func _on_stress_restored() -> void:
	set_stress(3, true)  # Full restore with animation
	print("[HUD] Stress fully restored!")


# ============================================================================
# DEBUG / TESTING
# ============================================================================

## Debug function for testing stress changes
func _input(event: InputEvent) -> void:
	if OS.is_debug_build():
		# Press 1/2/3 keys to set stress level (debug only)
		if event is InputEventKey and event.pressed:
			match event.keycode:
				KEY_1:
					set_stress(1, true)
				KEY_2:
					set_stress(2, true)
				KEY_3:
					set_stress(3, true)
				KEY_0:
					set_stress(0, true)
