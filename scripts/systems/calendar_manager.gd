class_name CalendarManager
extends Node
## CalendarManager - Handles in-game time progression and calendar events
##
## This system tracks day of week, hour, and minute, emitting signals for time events.
## Time automatically progresses based on real-time delta, with configurable speed.
## All time events are emitted through the EventBus for decoupled listening.
##
## Usage:
##   var calendar = CalendarManager.new()
##   add_child(calendar)
##   calendar.set_time(0, 8, 0)  # Monday, 8:00 AM
##   EventBus.time_hour_changed.connect(_on_hour_changed)

# ============================================================================
# TIME STATE
# ============================================================================

## Current minute (0-59)
var current_minute: int = 0

## Current hour (0-23, 24-hour format)
var current_hour: int = 8

## Current day of week (0-6, 0=Monday)
var current_day_of_week: int = 0

## Total days elapsed since game start
var total_days_elapsed: int = 0

## Whether time progression is paused
var is_paused: bool = false


# ============================================================================
# INTERNAL STATE
# ============================================================================

## Accumulator for fractional time progression
var _time_accumulator: float = 0.0

## Cached nighttime state to detect transitions
var _is_nighttime: bool = false


# ============================================================================
# LIFECYCLE
# ============================================================================

func _ready() -> void:
	print("[CalendarManager] Initialized - Starting at %s" % get_time_string())
	
	# Connect to game pause/resume events
	EventBus.game_paused.connect(_on_game_paused)
	EventBus.game_resumed.connect(_on_game_resumed)
	
	_update_nighttime_state()


func _process(delta: float) -> void:
	if is_paused:
		return
	
	# Accumulate real time
	_time_accumulator += delta
	
	# Check if a game minute has passed
	var seconds_per_minute := Constants.TIME["SECONDS_PER_GAME_MINUTE"]
	while _time_accumulator >= seconds_per_minute:
		_time_accumulator -= seconds_per_minute
		_advance_minute()


# ============================================================================
# TIME ADVANCEMENT
# ============================================================================

## Advance time by the specified number of game minutes
## @param minutes: int - Number of game minutes to advance
func advance_time(minutes: int) -> void:
	for i in range(minutes):
		_advance_minute()


## Internal method to advance by one minute
func _advance_minute() -> void:
	current_minute += 1
	
	# Check for hour rollover
	if current_minute >= Constants.TIME["MINUTES_PER_HOUR"]:
		current_minute = 0
		_advance_hour()


## Internal method to advance by one hour
func _advance_hour() -> void:
	current_hour += 1
	
	# Emit hour change
	EventBus.time_hour_changed.emit(current_hour)
	
	# Check for special hour events (dusk/dawn)
	_check_special_hours()
	
	# Check for day/night transition
	_check_day_night_transition()
	
	# Check for day rollover
	if current_hour >= Constants.TIME["HOURS_PER_DAY"]:
		current_hour = 0
		_advance_day()


## Internal method to advance by one day
func _advance_day() -> void:
	current_day_of_week += 1
	total_days_elapsed += 1
	
	# Wrap day of week
	if current_day_of_week >= Constants.TIME["DAYS_PER_WEEK"]:
		current_day_of_week = 0
	
	# Emit day change
	EventBus.time_day_changed.emit(current_day_of_week, total_days_elapsed)


# ============================================================================
# SPECIAL TIME EVENTS
# ============================================================================

## Check for dusk/dawn events
func _check_special_hours() -> void:
	if current_hour == Constants.TIME["DUSK_HOUR"]:
		EventBus.time_dusk_started.emit()
		print("[CalendarManager] Dusk started - %s" % get_time_string())
	
	if current_hour == Constants.TIME["DAWN_HOUR"]:
		EventBus.time_dawn_started.emit()
		print("[CalendarManager] Dawn started - %s" % get_time_string())


## Check if day/night period has changed
func _check_day_night_transition() -> void:
	var was_nighttime := _is_nighttime
	_update_nighttime_state()
	
	# Emit transition signal if state changed
	if was_nighttime != _is_nighttime:
		EventBus.time_period_changed.emit(_is_nighttime)
		var period := "nighttime" if _is_nighttime else "daytime"
		print("[CalendarManager] Time period changed to %s - %s" % [period, get_time_string()])


## Update the cached nighttime state
func _update_nighttime_state() -> void:
	_is_nighttime = is_nighttime()


# ============================================================================
# PUBLIC API
# ============================================================================

## Set the current time to specific values
## @param day: int - Day of week (0-6, 0=Monday)
## @param hour: int - Hour (0-23)
## @param minute: int - Minute (0-59)
func set_time(day: int, hour: int, minute: int) -> void:
	current_day_of_week = clamp(day, 0, Constants.TIME["DAYS_PER_WEEK"] - 1)
	current_hour = clamp(hour, 0, Constants.TIME["HOURS_PER_DAY"] - 1)
	current_minute = clamp(minute, 0, Constants.TIME["MINUTES_PER_HOUR"] - 1)
	
	_update_nighttime_state()
	
	print("[CalendarManager] Time set to %s" % get_time_string())


## Get the current time as a dictionary
## @return Dictionary - {day_of_week, hour, minute, total_days, is_night}
func get_current_time() -> Dictionary:
	return {
		"day_of_week": current_day_of_week,
		"hour": current_hour,
		"minute": current_minute,
		"total_days": total_days_elapsed,
		"is_night": is_nighttime(),
	}


## Check if it's currently nighttime (22:00-04:00)
## @return bool - True if nighttime
func is_nighttime() -> bool:
	var dusk := Constants.TIME["DUSK_HOUR"]
	var dawn := Constants.TIME["DAWN_HOUR"]
	
	# Night spans from dusk (22) to dawn (4)
	# This crosses midnight, so we need special logic
	if dusk > dawn:
		return current_hour >= dusk or current_hour < dawn
	else:
		return current_hour >= dusk and current_hour < dawn


## Get formatted time string
## @param use_12_hour: bool - Use 12-hour format (default: false for 24-hour)
## @return String - Formatted time (e.g., "Monday 14:30" or "Monday 2:30 PM")
func get_time_string(use_12_hour: bool = false) -> String:
	var day_name: String = Constants.DAY_NAMES[current_day_of_week]
	
	if use_12_hour:
		var display_hour := current_hour
		var meridiem := "AM"
		
		if current_hour == 0:
			display_hour = 12
		elif current_hour == 12:
			meridiem = "PM"
		elif current_hour > 12:
			display_hour = current_hour - 12
			meridiem = "PM"
		
		return "%s %d:%02d %s" % [day_name, display_hour, current_minute, meridiem]
	else:
		return "%s %02d:%02d" % [day_name, current_hour, current_minute]


## Pause time progression
func pause_time() -> void:
	is_paused = true
	print("[CalendarManager] Time paused at %s" % get_time_string())


## Resume time progression
func resume_time() -> void:
	is_paused = false
	print("[CalendarManager] Time resumed at %s" % get_time_string())


## Get the day name for the current day
## @return String - Day name (e.g., "Monday")
func get_current_day_name() -> String:
	return Constants.DAY_NAMES[current_day_of_week]


## Get the day name for a specific day index
## @param day: int - Day of week (0-6)
## @return String - Day name
func get_day_name(day: int) -> String:
	if day >= 0 and day < Constants.TIME["DAYS_PER_WEEK"]:
		return Constants.DAY_NAMES[day]
	return "Invalid Day"


# ============================================================================
# EVENT HANDLERS
# ============================================================================

## Handle game pause event from EventBus
func _on_game_paused() -> void:
	pause_time()


## Handle game resume event from EventBus
func _on_game_resumed() -> void:
	resume_time()
