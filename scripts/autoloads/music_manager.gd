extends Node
## MusicManager - Handles music playback with seamless crossfading
##
## Manages music transitions between tracks with smooth crossfading.
##
## Usage:
##   EventBus.music_transition_requested.emit("LEVEL_01", 1.0)
##   EventBus.music_transition_requested.emit("LEVEL_01_ACTION", 0.5)

# ============================================================================
# CONFIGURATION
# ============================================================================

## Default crossfade duration (seconds)
const DEFAULT_CROSSFADE_DURATION: float = 1.0

## Master volume multiplier (0.0 to 1.0)
var master_volume: float = 1.0


# ============================================================================
# AUDIO PLAYERS
# ============================================================================

## Player A - alternates between tracks
var player_a: AudioStreamPlayer

## Player B - alternates between tracks
var player_b: AudioStreamPlayer

## Which player is currently active (true = A, false = B)
var active_is_a: bool = true


# ============================================================================
# STATE TRACKING
# ============================================================================

## Current track name
var current_track: String = ""

## Is music currently playing?
var is_playing: bool = false

## Is music paused?
var is_paused: bool = false

## Cache of loaded music streams
var music_cache: Dictionary = {}


# ============================================================================
# TWEEN MANAGEMENT
# ============================================================================

## Active tween for smooth transitions
var active_tween: Tween = null


# ============================================================================
# LIFECYCLE
# ============================================================================

func _ready() -> void:
	# Create player A
	player_a = AudioStreamPlayer.new()
	player_a.bus = Constants.AUDIO_BUSES.MUSIC
	player_a.volume_db = linear_to_db(0.0)  # Start silent
	add_child(player_a)
	
	# Create player B
	player_b = AudioStreamPlayer.new()
	player_b.bus = Constants.AUDIO_BUSES.MUSIC
	player_b.volume_db = linear_to_db(0.0)  # Start silent
	add_child(player_b)
	
	# Connect to EventBus signals
	EventBus.music_transition_requested.connect(_on_music_transition_requested)
	EventBus.music_stop_requested.connect(_on_music_stop_requested)
	EventBus.music_pause_requested.connect(_on_pause_requested)
	EventBus.music_resume_requested.connect(_on_resume_requested)
	EventBus.music_volume_changed.connect(_on_volume_changed)
	
	print("[MusicManager] Initialized with seamless crossfading")


# ============================================================================
# MUSIC LOADING
# ============================================================================

## Load a music stream from UID (with caching)
func _load_music_stream(music_uid: String) -> AudioStream:
	if music_uid.is_empty():
		return null
	
	# Check cache first
	if music_cache.has(music_uid):
		return music_cache[music_uid]
	
	# Load the resource
	var stream: AudioStream = load(music_uid)
	
	if stream:
		music_cache[music_uid] = stream
		print("[MusicManager] Cached music: %s" % music_uid)
	else:
		push_error("[MusicManager] Failed to load music: %s" % music_uid)
	
	return stream


# ============================================================================
# PLAYBACK CONTROL
# ============================================================================

## Transition to a new music track
func _on_music_transition_requested(track_name: String, crossfade_duration: float) -> void:
	if track_name.is_empty():
		push_warning("[MusicManager] Cannot play music: track name is empty")
		return
	
	# If already playing this track, don't restart
	if current_track == track_name and is_playing:
		print("[MusicManager] Already playing: %s" % track_name)
		return
	
	# Get track UID
	var track_uid := Constants.get_music(track_name)
	if track_uid.is_empty():
		push_error("[MusicManager] No UID found for track: %s" % track_name)
		return
	
	# Load the stream
	var stream := _load_music_stream(track_uid)
	if not stream:
		return
	
	# Determine which player to use for the new track
	var new_player := player_b if active_is_a else player_a
	var old_player := player_a if active_is_a else player_b
	
	# Configure new player
	new_player.stream = stream
	new_player.volume_db = linear_to_db(0.0)  # Start silent
	new_player.play()
	
	# Crossfade
	if is_playing:
		# Fade out old player, fade in new player
		_crossfade_players(old_player, new_player, crossfade_duration)
		
		# Wait for crossfade to complete, then stop old player
		await get_tree().create_timer(crossfade_duration).timeout
		old_player.stop()
	else:
		# No previous music, just fade in
		_fade_volume(new_player, master_volume, crossfade_duration)
	
	# Switch active player
	active_is_a = not active_is_a
	
	# Update state
	current_track = track_name
	is_playing = true
	is_paused = false
	
	print("[MusicManager] Transitioning to: %s (crossfade: %.1fs)" % [track_name, crossfade_duration])


## Stop current music
func _on_music_stop_requested(fade_duration: float) -> void:
	if not is_playing:
		return
	
	var current_player := player_a if active_is_a else player_b
	
	# Fade out
	_fade_volume(current_player, 0.0, fade_duration)
	
	# Wait for fade to complete
	await get_tree().create_timer(fade_duration).timeout
	
	# Stop player
	current_player.stop()
	
	# Reset state
	current_track = ""
	is_playing = false
	
	print("[MusicManager] Stopped music (fade: %.1fs)" % fade_duration)


# ============================================================================
# PAUSE/RESUME
# ============================================================================

## Pause music
func _on_pause_requested() -> void:
	if not is_playing or is_paused:
		return
	
	var current_player := player_a if active_is_a else player_b
	current_player.stream_paused = true
	is_paused = true
	
	print("[MusicManager] Paused")


## Resume music
func _on_resume_requested() -> void:
	if not is_playing or not is_paused:
		return
	
	var current_player := player_a if active_is_a else player_b
	current_player.stream_paused = false
	is_paused = false
	
	print("[MusicManager] Resumed")


# ============================================================================
# VOLUME CONTROL
# ============================================================================

## Change master volume
func _on_volume_changed(volume: float) -> void:
	master_volume = clamp(volume, 0.0, 1.0)
	
	# Update current player volume
	if is_playing:
		var current_player := player_a if active_is_a else player_b
		current_player.volume_db = linear_to_db(master_volume)
	
	print("[MusicManager] Volume changed to %.0f%%" % (master_volume * 100))


# ============================================================================
# TWEEN UTILITIES
# ============================================================================

## Fade volume of a player smoothly
func _fade_volume(player: AudioStreamPlayer, target_volume: float, duration: float) -> void:
	# Cancel existing tween if any
	if active_tween and active_tween.is_valid():
		active_tween.kill()
	
	# Create new tween
	active_tween = create_tween()
	active_tween.set_trans(Tween.TRANS_SINE)
	active_tween.set_ease(Tween.EASE_IN_OUT)
	
	# Tween volume_db
	var target_db := linear_to_db(target_volume) if target_volume > 0.0 else -80.0
	active_tween.tween_property(player, "volume_db", target_db, duration)


## Crossfade between two players
func _crossfade_players(fade_out_player: AudioStreamPlayer, fade_in_player: AudioStreamPlayer, duration: float) -> void:
	# Cancel existing tween if any
	if active_tween and active_tween.is_valid():
		active_tween.kill()
	
	# Create new tween
	active_tween = create_tween()
	active_tween.set_trans(Tween.TRANS_SINE)
	active_tween.set_ease(Tween.EASE_IN_OUT)
	active_tween.set_parallel(true)  # Both tweens run at the same time
	
	# Fade out old player
	active_tween.tween_property(fade_out_player, "volume_db", -80.0, duration)
	
	# Fade in new player
	var target_db := linear_to_db(master_volume)
	active_tween.tween_property(fade_in_player, "volume_db", target_db, duration)


# ============================================================================
# PUBLIC API (for direct calls, not through EventBus)
# ============================================================================

## Transition to a track directly
func transition_to(track_name: String, crossfade_duration: float = DEFAULT_CROSSFADE_DURATION) -> void:
	EventBus.music_transition_requested.emit(track_name, crossfade_duration)


## Stop music directly
func stop_music(fade_duration: float = DEFAULT_CROSSFADE_DURATION) -> void:
	EventBus.music_stop_requested.emit(fade_duration)


## Pause music directly
func pause() -> void:
	EventBus.music_pause_requested.emit()


## Resume music directly
func resume() -> void:
	EventBus.music_resume_requested.emit()


## Set volume directly
func set_volume(volume: float) -> void:
	EventBus.music_volume_changed.emit(volume)


# ============================================================================
# QUERY METHODS
# ============================================================================

## Get current track name
func get_current_track() -> String:
	return current_track


## Check if music is currently playing
func get_is_playing() -> bool:
	return is_playing


## Check if music is paused
func get_is_paused() -> bool:
	return is_paused


## Get current playback position
func get_playback_position() -> float:
	if is_playing:
		var current_player := player_a if active_is_a else player_b
		return current_player.get_playback_position()
	return 0.0
