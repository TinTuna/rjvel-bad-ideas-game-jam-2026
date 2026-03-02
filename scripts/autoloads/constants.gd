extends Node
## Constants - Global constants and scene registry
##
## Centralized location for all game constants including scene paths.
## Uses UIDs for reliable scene referencing that won't break when files move.
##
## Usage:
##   SceneLoader.load_scene(Constants.SCENES.MAIN_MENU)
##   SceneLoader.load_scene(Constants.SCENES.LEVEL_01)

# ============================================================================
# SCENE PATHS (using UIDs)
# ============================================================================

## Dictionary of all game scenes using UIDs
## Format: "SCENE_NAME": "uid://scene_uid_here"
const SCENES := {
	# UI Scenes
	"MAIN_MENU": "uid://b4yqj8vx2kkxm",
	"PAUSE_MENU": "",
	"SETTINGS": "",
	"GAME_OVER": "",
	
	# Level Scenes
	# "LEVEL_01": "",
	# "LEVEL_02": "",
	# "LEVEL_03": "",
	
	# Special Scenes
	# "CREDITS": "",
	# "TUTORIAL": "",
}


# ============================================================================
# GAME CONSTANTS
# ============================================================================

# ============================================================================
# HELPER METHODS
# ============================================================================

## Get a scene UID by name
## @param scene_name: String - The name of the scene (e.g., "MAIN_MENU")
## @return String - The UID of the scene, or empty string if not found
func get_scene(scene_name: String) -> String:
	if SCENES.has(scene_name):
		if SCENES[scene_name].is_empty():
			push_warning("[Constants] Scene '%s' has no UID assigned yet" % scene_name)
		return SCENES[scene_name]
	else:
		push_error("[Constants] Scene '%s' not found in SCENES dictionary" % scene_name)
		return ""


## Check if a scene exists in the registry
## @param scene_name: String - The name of the scene to check
## @return bool - True if the scene exists
func has_scene(scene_name: String) -> bool:
	return SCENES.has(scene_name) and not SCENES[scene_name].is_empty()


## Get all registered scene names
## @return Array[String] - Array of all scene names
func get_all_scene_names() -> Array[String]:
	var names: Array[String] = []
	for key in SCENES.keys():
		names.append(key)
	return names


# ============================================================================
# LIFECYCLE
# ============================================================================

func _ready() -> void:
	print("[Constants] Initialized")
	
	# Validate that all scenes have UIDs assigned
	var missing_uids: Array[String] = []
	for scene_name in SCENES:
		if SCENES[scene_name].is_empty():
			missing_uids.append(scene_name)
	
	if missing_uids.size() > 0:
		push_warning("[Constants] The following scenes are missing UIDs: %s" % str(missing_uids))
