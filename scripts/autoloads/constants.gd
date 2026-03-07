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
    
    # Level Scenes
    "TEST_LEVEL": "uid://d1rty8b8d5w2j",
    
    # Special Scenes
    # "CREDITS": "",
}


# ============================================================================
# MUSIC REGISTRY (using UIDs)
# ============================================================================

## Dictionary of music tracks
## Format: "TRACK_NAME": "uid://track_uid_here"
const MUSIC := {
    # Menu Music
    "MAIN_MENU": "",
    
    # Game Music
    "GAME_BASE": "",
    "GAME_ACTION": "",
}

## Audio bus names
const AUDIO_BUSES := {
    "MASTER": "Master",
    "MUSIC": "Music",
    "SFX": "SFX",
}


# ============================================================================
# GAME CONSTANTS
# ============================================================================

# ============================================================================
# DAY SYSTEM CONSTANTS
# ============================================================================

## Total number of days in the game (6 days = Mon-Sat, Tutorial + 5 levels)
const TOTAL_DAYS: int = 6

## Day of week names (0-6)
## Maps day index to day name for display
const DAY_NAMES := {
    0: "Monday",      # Tutorial day
    1: "Tuesday",     # Day 2
    2: "Wednesday",   # Day 3
    3: "Thursday",    # Day 4
    4: "Friday",      # Day 5
    5: "Saturday",    # Day 6
    6: "Sunday",      # Extra/unused
}

# ============================================================================
# NPC NAVIGATION CONSTANTS
# ============================================================================

## Default patrol routes for family members
## Format: "NPC_NAME": [array of navigation point names]
const NPC_PATROL_ROUTES := {
    "MOTHER": ["Living_Room", "Ground_Floor_Stairs", "First_Floor_StairsTop", "First_Bedroom", "First_Floor_StairsTop", "Ground_Floor_Stairs", "Kitchen", "Ground_Floor_Stairs"],
}

# ============================================================================
# HELPER METHODS - SCENES
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
# HELPER METHODS - MUSIC
# ============================================================================

## Get a music track UID by name
## @param track_name: String - The track name (e.g., "LEVEL_01")
## @return String - The UID of the track, or empty string if not found
func get_music(track_name: String) -> String:
    if MUSIC.has(track_name):
        if MUSIC[track_name].is_empty():
            push_warning("[Constants] Music '%s' has no UID assigned yet" % track_name)
        return MUSIC[track_name]
    else:
        push_error("[Constants] Music track '%s' not found" % track_name)
        return ""


## Check if a music track exists
## @param track_name: String - The track name to check
## @return bool - True if the track exists
func has_music(track_name: String) -> bool:
    return MUSIC.has(track_name) and not MUSIC[track_name].is_empty()


## Get all music track names
## @return Array[String] - Array of track names
func get_all_music_tracks() -> Array[String]:
    var tracks: Array[String] = []
    for key in MUSIC.keys():
        tracks.append(key)
    return tracks


# ============================================================================
# LIFECYCLE
# ============================================================================

func _ready() -> void:
    print("[Constants] Initialized")
    
    # Validate that all scenes have UIDs assigned
    var missing_scene_uids: Array[String] = []
    for scene_name in SCENES:
        if SCENES[scene_name].is_empty():
            missing_scene_uids.append(scene_name)
    
    if missing_scene_uids.size() > 0:
        push_warning("[Constants] The following scenes are missing UIDs: %s" % str(missing_scene_uids))
    
    # Validate that music tracks have UIDs assigned
    var missing_music_uids: Array[String] = []
    for track_name in MUSIC:
        if MUSIC[track_name].is_empty():
            missing_music_uids.append(track_name)
    
    if missing_music_uids.size() > 0:
        push_warning("[Constants] The following music tracks are missing UIDs: %s" % str(missing_music_uids))
