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
# TIME SYSTEM CONSTANTS
# ============================================================================

## Time progression configuration
## 1 real second = 4 game minutes (1 day = 6 real minutes)
const TIME := {
    "SECONDS_PER_GAME_MINUTE": 0.25,  # 1 real second = 4 game minutes
    "MINUTES_PER_HOUR": 60,
    "HOURS_PER_DAY": 24,
    "DAYS_PER_WEEK": 7,
    "DUSK_HOUR": 22,  # 10 PM - Night begins
    "DAWN_HOUR": 4,   # 4 AM - Day begins
}

## Day of week names (0-6)
const DAY_NAMES := {
    0: "Monday",
    1: "Tuesday",
    2: "Wednesday",
    3: "Thursday",
    4: "Friday",
    5: "Saturday",
    6: "Sunday",
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
