extends Node
## SceneLoader - Handles threaded scene loading with transitions
##
## This autoload manages loading scenes in the background using threads,
## preventing the game from freezing during scene transitions.
##
## Usage:
##   SceneLoader.load_scene(Constants.SCENES.LEVEL_01)
##   SceneLoader.load_scene("uid://your_scene_uid_here")

# ============================================================================
# SIGNALS
# ============================================================================

## Emitted when the loading progress changes
## @param progress: float - Progress value from 0.0 to 1.0
signal progress_changed(progress: float)

## Emitted when the scene has finished loading
signal load_finished()


# ============================================================================
# VARIABLES
# ============================================================================

## Reference to the loading screen packed scene
var loading_screen: PackedScene = preload("uid://do65m5olymn6r")

## The loaded resource (scene)
var loaded_resource: PackedScene

## UID or path to the scene being loaded
var scene_uid: String = ""

## Progress array (used by ResourceLoader)
var progress: Array = []

## Whether to use sub-threads for loading (faster but may cause issues on some systems)
var use_sub_threads: bool = true


# ============================================================================
# LIFECYCLE
# ============================================================================

func _ready() -> void:
		# Initially disable processing until we start loading
		set_process(false)
		print("[SceneLoader] Initialized")


func _process(_delta: float) -> void:
	# Get the current load status and update progress
	var load_status := ResourceLoader.load_threaded_get_status(scene_uid, progress)
	
	# Emit progress update
	progress_changed.emit(progress[0])
	
	# Check the load status
	match load_status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, ResourceLoader.THREAD_LOAD_FAILED:
			# Loading failed, stop processing
			set_process(false)
			push_error("[SceneLoader] Failed to load scene: " + scene_uid)
		
		ResourceLoader.THREAD_LOAD_LOADED:
			# Loading complete, get the resource
			loaded_resource = ResourceLoader.load_threaded_get(scene_uid)
			
			# Switch to the new scene
			get_tree().change_scene_to_packed(loaded_resource)
			
			# Emit load finished signal
			load_finished.emit()
			
			# Stop processing
			set_process(false)


# ============================================================================
# PUBLIC METHODS
# ============================================================================

## Load a scene with a transition screen
## @param _scene_uid: String - UID of the scene to load (e.g., "uid://abc123" or Constants.SCENES.LEVEL_01)
func load_scene(_scene_uid: String) -> void:
	# Validate scene UID
	if _scene_uid.is_empty():
		push_error("[SceneLoader] Cannot load scene: UID is empty")
		return
	
	# Update the scene UID
	scene_uid = _scene_uid
	
	print("[SceneLoader] Loading scene: " + scene_uid)
	
	# Create a new loading screen instance
	var new_load_screen := loading_screen.instantiate()
	add_child(new_load_screen)
	
	# Connect signals to the loading screen
	progress_changed.connect(new_load_screen.on_progress_changed)
	load_finished.connect(new_load_screen.on_load_finished)
	
	# Wait for the loading screen to be ready (fade in complete)
	await new_load_screen.loading_screen_ready
	
	# Start the load process
	start_load()


## Start the threaded loading process
func start_load() -> void:
	# Request threaded loading
	var state := ResourceLoader.load_threaded_request(scene_uid, "", use_sub_threads)
	
	# If request was successful, start processing
	if state == OK:
		set_process(true)
	else:
		push_error("[SceneLoader] Failed to start loading: " + scene_uid)
