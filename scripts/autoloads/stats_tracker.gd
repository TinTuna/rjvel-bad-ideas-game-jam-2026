extends Node
## StatsTracker - Global game statistics tracker
##
## Tracks useless-but-fun player statistics across the run.
## Call StatsTracker.increment("stat_key") from anywhere to record an event.
##
## Usage:
##   StatsTracker.increment("times_jumped")
##   StatsTracker.set_stat("days_survived", 3)
##   StatsTracker.get_all() -> Dictionary

# ============================================================================
# STATS DEFINITION
# ============================================================================

## All tracked statistics with their initial values and display labels.
## Add new entries here to track new things.
const STAT_DEFINITIONS := {
	"times_jumped":         { "label": "Times Jumped",                          "value": 0 },
	"glasses_knocked_over": { "label": "Glasses Knocked Over",                  "value": 0 },
	"times_rested":         { "label": "Times Hidden in the Cat Box",           "value": 0 },
	"treats_eaten":         { "label": "Treats Eaten",                          "value": 0 },
	"days_completed":       { "label": "Days Snuck Out",                        "value": 0 },
	"times_pushed_back":    { "label": "Times Yeeted by a family member",       "value": 0 },
	"items_stolen":         { "label": "Items Liberated from Humans",           "value": 0 },
	"toasters_ruined":      { "label": "Times the Kitchen Almost Burned Down",  "value": 0 },
}

## Live stat values (populated from STAT_DEFINITIONS on ready)
var _stats: Dictionary = {}


## Increment a stat by 1 (or a custom amount)
## @param key: String - The stat key (must exist in STAT_DEFINITIONS)
## @param amount: int - How much to add (default 1)
func increment(key: String, amount: int = 1) -> void:
	if not _stats.has(key):
		push_error("[StatsTracker] Unknown stat key: '%s'" % key)
		return
	_stats[key] += amount


## Set a stat to an explicit value
## @param key: String - The stat key
## @param value: int - The value to set
func set_stat(key: String, value: int) -> void:
	if not _stats.has(key):
		push_error("[StatsTracker] Unknown stat key: '%s'" % key)
		return
	_stats[key] = value


## Get the current value of a stat
## @param key: String - The stat key
## @return int - Current value, or -1 if key not found
func get_stat(key: String) -> int:
	if not _stats.has(key):
		push_error("[StatsTracker] Unknown stat key: '%s'" % key)
		return -1
	return _stats[key]


## Get all stats as an array of { label, value } dictionaries, for display
## @return Array[Dictionary] - Each entry has "label" (String) and "value" (int)
func get_all() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for key in STAT_DEFINITIONS:
		result.append({
			"key":   key,
			"label": STAT_DEFINITIONS[key]["label"],
			"value": _stats[key],
		})
	return result


## Reset all stats back to zero (call at game start if restarting)
func reset() -> void:
	for key in STAT_DEFINITIONS:
		_stats[key] = 0
	print("[StatsTracker] Stats reset")


# ============================================================================
# AUTO-TRACKING (EventBus connections)
# ============================================================================

func _connect_events() -> void:
	EventBus.glass_knocked_down.connect(_on_glass_knocked_down)
	EventBus.day_started.connect(_on_day_started)
	EventBus.cat_jumped.connect(_on_cat_jumped)
	EventBus.cat_pushed_back.connect(_on_cat_pushed_back)
	EventBus.player_entered_box.connect(_on_player_entered_box)
	EventBus.player_picked_up_item.connect(_on_player_picked_up_item)
	EventBus.toaster_burnt.connect(_on_toaster_burnt)


func _on_glass_knocked_down() -> void:
	increment("glasses_knocked_over")

func _on_day_started(_day_number: int) -> void:
	increment("days_completed")

func _on_cat_jumped() -> void:
	increment("times_jumped")

func _on_cat_pushed_back() -> void:
	increment("times_pushed_back")

func _on_player_entered_box() -> void:
	increment("times_rested")

func _on_player_picked_up_item(_item: Node2D) -> void:
	increment("items_stolen")

func _on_toaster_burnt() -> void:
	increment("toasters_ruined")


# ============================================================================
# LIFECYCLE
# ============================================================================

func _ready() -> void:
	# Populate live values from definitions
	for key in STAT_DEFINITIONS:
		_stats[key] = STAT_DEFINITIONS[key]["value"]

	_connect_events()
	print("[StatsTracker] Initialized")
