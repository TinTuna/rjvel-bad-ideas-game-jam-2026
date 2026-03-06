class_name DayManager
extends Node
## DayManager - Tracks the current day in the game
##
## Simple day tracking system for Cat in a Box's discrete level structure.
## Each day (Monday-Sunday) is a separate level/scene.
## Tracks which day the player is currently on and which exits have been used.
##
## Usage:
##   var day_manager = DayManager.new()
##   add_child(day_manager)
##   day_manager.set_current_day(0)  # Monday
##   day_manager.mark_exit_used("cat_flap")

# ============================================================================
# DAY STATE
# ============================================================================

## Current day of the week (0-6, 0=Monday)
var current_day: int = 0

## Total days completed (for progression tracking)
var days_completed: int = 0

## List of exits that have been permanently closed
var used_exits: Array[String] = []


# ============================================================================
# LIFECYCLE
# ============================================================================

func _ready() -> void:
	print("[DayManager] Initialized - Current day: %s" % get_current_day_name())
	
	# Emit initial day started event
	EventBus.day_started.emit(current_day)


# ============================================================================
# DAY MANAGEMENT
# ============================================================================

## Set the current day (0-6)
## @param day: int - Day of week (0=Monday, 1=Tuesday, ..., 6=Sunday)
func set_current_day(day: int) -> void:
	current_day = clamp(day, 0, 6)
	EventBus.day_started.emit(current_day)
	print("[DayManager] Current day set to: %s" % get_current_day_name())


## Advance to the next day
## @return int - The new current day
func advance_day() -> int:
	days_completed += 1
	current_day += 1
	
	# Wrap to Sunday if we go past it (for testing/extra scope)
	if current_day > 6:
		current_day = 6  # Cap at Sunday
	
	EventBus.day_started.emit(current_day)
	print("[DayManager] Advanced to: %s (Day %d completed)" % [get_current_day_name(), days_completed])
	
	return current_day


## Get the current day name
## @return String - Day name (e.g., "Monday")
func get_current_day_name() -> String:
	if Constants.DAY_NAMES.has(current_day):
		return Constants.DAY_NAMES[current_day]
	return "Unknown"


## Get the day name for a specific day index
## @param day: int - Day of week (0-6)
## @return String - Day name
func get_day_name(day: int) -> String:
	if Constants.DAY_NAMES.has(day):
		return Constants.DAY_NAMES[day]
	return "Unknown"


# ============================================================================
# EXIT TRACKING (Permanent Closure System)
# ============================================================================

## Mark an exit as used (permanently closed)
## @param exit_name: String - Name of the exit (e.g., "cat_flap", "kitchen_window")
func mark_exit_used(exit_name: String) -> void:
	if not used_exits.has(exit_name):
		used_exits.append(exit_name)
		print("[DayManager] Exit '%s' permanently closed" % exit_name)


## Check if an exit has been used
## @param exit_name: String - Name of the exit to check
## @return bool - True if the exit has been used
func is_exit_used(exit_name: String) -> bool:
	return used_exits.has(exit_name)


## Get list of all used exits
## @return Array[String] - Array of exit names that have been used
func get_used_exits() -> Array[String]:
	return used_exits.duplicate()


## Reset exit tracking (for new game)
func reset_exits() -> void:
	used_exits.clear()
	print("[DayManager] All exits reset")


# ============================================================================
# PROGRESSION QUERIES
# ============================================================================

## Check if the game is complete (all 6 days done)
## @return bool - True if all 6 days completed
func is_game_complete() -> bool:
	return days_completed >= 6


## Get progression percentage
## @return float - Percentage of game completed (0.0 to 1.0)
func get_progress() -> float:
	return clamp(float(days_completed) / 6.0, 0.0, 1.0)


## Get progression as a dictionary
## @return Dictionary - Full progression state
func get_progression() -> Dictionary:
	return {
		"current_day": current_day,
		"current_day_name": get_current_day_name(),
		"days_completed": days_completed,
		"used_exits": used_exits.duplicate(),
		"progress_percent": get_progress() * 100.0,
		"is_complete": is_game_complete()
	}


# ============================================================================
# SAVE/LOAD SUPPORT
# ============================================================================

## Get save data
## @return Dictionary - Data to save
func get_save_data() -> Dictionary:
	return {
		"current_day": current_day,
		"days_completed": days_completed,
		"used_exits": used_exits.duplicate()
	}


## Load from save data
## @param data: Dictionary - Saved data
func load_save_data(data: Dictionary) -> void:
	if data.has("current_day"):
		current_day = data["current_day"]
	
	if data.has("days_completed"):
		days_completed = data["days_completed"]
	
	if data.has("used_exits"):
		used_exits = data["used_exits"].duplicate()
	
	print("[DayManager] Loaded save data - Day: %s, Completed: %d, Exits used: %d" % 
		[get_current_day_name(), days_completed, used_exits.size()])
	
	# Emit day started event
	EventBus.day_started.emit(current_day)


## Reset to new game state
func reset_to_new_game() -> void:
	current_day = 0
	days_completed = 0
	used_exits.clear()
	EventBus.day_started.emit(current_day)
	print("[DayManager] Reset to new game - Starting Monday")


# ============================================================================
# DEBUG / TESTING
# ============================================================================

## Print current state to console
func print_status() -> void:
	print("=== DayManager Status ===")
	print("Current Day: %s (%d)" % [get_current_day_name(), current_day])
	print("Days Completed: %d / 6" % days_completed)
	print("Progress: %.0f%%" % (get_progress() * 100.0))
	print("Used Exits: %s" % str(used_exits))
	print("Game Complete: %s" % ("Yes" if is_game_complete() else "No"))
	print("========================")
