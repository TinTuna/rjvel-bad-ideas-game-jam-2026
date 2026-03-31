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

    # Cutscene / Flow Scenes
    "INTRO":     "uid://ckibki5wxkbmj",
    "OUTRO":     "uid://bpaibl03r5m3y",
    "DAY_RECAP": "uid://dyw6fdsolwcim",

    # Level Scenes
    "TEST_LEVEL": "uid://d1rty8b8d5w2j",
    "LEVEL_0": "uid://b0t4qvl2dtmwh",
    "LEVEL_1": "uid://cbuvoblyq65vv",
    "LEVEL_2": "uid://dptpgdeh6jtn6",
    "LEVEL_3": "uid://cr41m00w4iscd",
    "LEVEL_4": "uid://cwvd5tqm016tq"

    # Special Scenes
    # "CREDITS": "",
}


# ============================================================================
# MUSIC REGISTRY (using UIDs)
# ============================================================================

## Voiceover lines parsed from CSV at runtime
## Structure: { "Mum": { "Day 0": [{ text, code }, ...], "Filler": [...] }, ... }
var VOICEOVER_LINES: Dictionary = {}

const VOICEOVER_CSV_PATH := "res://assets/audio/sfx/Voiceover/sounds.csv"

## Maps CSV character name → folder name under Voiceover/
const VOICEOVER_FOLDERS := {
    "Mum":   "Mother",
    "Girl":  "Girl",
    "Twins": "Twins",
    "Cat":   "Cat",
}


## Dictionary of music tracks
## Format: "TRACK_NAME": "uid://track_uid_here"
const MUSIC := {
    # Menu Music
    "MAIN_MENU": "uid://hlp0rjw7ll0h",

    # Game Music
    # "GAME_BASE": "",
    # "GAME_ACTION": "",

    # Box 1 Music
    "BOX1_INTRO": "uid://dykanqblaqgur",
    "BOX1_MAIN":  "uid://djabkvcxp4s80",
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

## Current day 
var current_day: int = 0

## ID of a cat voice pack 
var voice_pack: int = 0

## Voice packs ID and corresponding letter code
## Format: ID: "Letter"
const VOICE_PACKS := {
    0: "E",
    1: "J",
    2: "L",
    3: "V",
    4: "T",
}

## ID of a cat voice pack 
var is_settings_initialised: bool = false

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

## Default patrol routes per family member per day.
## Format: "NPC_NAME": { day_int: [nav point names, ...] }
## A single-element array makes the NPC effectively static (navigates there and waits).
const NPC_PATROL_ROUTES := {
    "MOTHER": {
        0: ["Entry"],
        1: ["Entry", "Mums_Bedroom"],
        2: ["Kitchen"],
        3: ["Entry", "Kitchen"],
        4: ["Mums_Bedroom", "Kitchen"],
    },
    "TWINS": {
        1: ["Living_Room"],
        3: ["Boys_Room"],
        4: ["Boys_Room"],
    },
    "DAUGHTER": {
        2: ["Living_Room"],
        4: ["Entry"],
    },
}


## Returns the patrol route for an NPC on a given day. Returns [] if none defined.
func get_patrol_route(npc_name: String, day: int) -> Array:
    var npc_routes: Dictionary = NPC_PATROL_ROUTES.get(npc_name, {})
    return npc_routes.get(day, [])

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

## Get all voice lines for a character and context (e.g. "Mum", "Filler" or "Day 0")
func get_voice_lines(character: String, context: String) -> Array:
    return VOICEOVER_LINES.get(character, {}).get(context, [])


## Build the res:// path for a voiceover audio file by character and code
func get_voice_audio_path(character: String, code: String) -> String:
    var folder: String = VOICEOVER_FOLDERS.get(character, character)
    return "res://assets/audio/sfx/Voiceover/%s/%s.wav" % [folder, code]


func _parse_voiceover_csv() -> void:
    var csv = load(VOICEOVER_CSV_PATH)
    if not csv:
        push_error("[Constants] Failed to load voiceover CSV: %s" % VOICEOVER_CSV_PATH)
        return
    for record: Dictionary in csv.records:
        var character: String = record.get("Vocal name", "").strip_edges()
        var text: String = record.get("Vocal text", "").strip_edges()
        var context: String = record.get("Context", "").strip_edges()
        var code: String = record.get("Code", "").strip_edges()
        if character.is_empty() or code.is_empty():
            continue
        if not VOICEOVER_LINES.has(character):
            VOICEOVER_LINES[character] = {}
        if not VOICEOVER_LINES[character].has(context):
            VOICEOVER_LINES[character][context] = []
        VOICEOVER_LINES[character][context].append({"text": text, "code": code})
    print("[Constants] Voiceover lines loaded for: %s" % str(VOICEOVER_LINES.keys()))


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
    _parse_voiceover_csv()
    
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
    
    var rng = RandomNumberGenerator.new()
    voice_pack = rng.randi_range(0, 3)
