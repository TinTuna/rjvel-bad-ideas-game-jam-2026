extends Node
## SfxManager - Handles sound effect playback with audio variation
##
## Listens to EventBus events and plays the appropriate cat voice line
## for the active voice pack, with small random pitch variation each time.
## Also handles environment sound effects triggered by game events.
##
## Usage (direct):
##   SfxManager.play_cat_voice("box")
##   SfxManager.play_cat_voice("collide")
##   SfxManager.play_cat_voice("end")
##   SfxManager.play_cat_voice("button")

# How many button variants exist per voice pack letter
const BUTTON_VARIANT_COUNTS := {"E": 3, "J": 4, "L": 3, "V": 3, "T": 1}

## Pitch variation applied each play (± this amount around 1.0)
const PITCH_VARIATION: float = 0.18

## Volume variation in dB (± this amount around the base volume)
const VOLUME_VARIATION_DB: float = 2

## Base volume in dB (reduced from 0 to bring overall level down)
const BASE_VOLUME_DB: float = -8.0

const SFX_DOOR_OPEN     = preload("uid://cs6f4b46736pu")
const SFX_DOOR_CLOSE    = preload("uid://dcopmy25qh3rb")
const SFX_WINDOW_OPEN   = preload("uid://dfu8mcvfpyq47")
const SFX_TOASTER_FINISH = preload("uid://dqkybjps8h4td")

var _player: AudioStreamPlayer
var _env_player: AudioStreamPlayer
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_player = AudioStreamPlayer.new()
	_player.bus = Constants.AUDIO_BUSES.SFX
	_player.volume_db = BASE_VOLUME_DB
	add_child(_player)
	_player.finished.connect(func(): _player.stream = null)

	_env_player = AudioStreamPlayer.new()
	_env_player.bus = Constants.AUDIO_BUSES.SFX
	add_child(_env_player)

	EventBus.player_entered_box.connect(_on_player_entered_box)
	EventBus.cat_pushed_back.connect(_on_cat_pushed_back)
	EventBus.level_completed.connect(_on_level_completed)
	EventBus.mother_opens_door.connect(func(): _play_env(SFX_DOOR_OPEN))
	EventBus.mother_closes_door.connect(func(): _play_env(SFX_DOOR_CLOSE))
	EventBus.window_open.connect(func(): _play_env(SFX_WINDOW_OPEN))
	EventBus.toaster_burnt.connect(func(): _play_env(SFX_TOASTER_FINISH))

	print("[SfxManager] Initialized")


## Play a cat voice line for the given event ("box", "collide", "end", "button").
func play_cat_voice(event: String) -> void:
	var letter: String = Constants.VOICE_PACKS.get(Constants.voice_pack, "E")
	var path: String

	if event == "button":
		var count: int = BUTTON_VARIANT_COUNTS.get(letter, 3)
		var variant: int = _rng.randi_range(0, count - 1)
		path = "res://assets/audio/sfx/Voiceover/Cat/%s/miao_%s_button_%d.wav" % [letter, letter, variant]
	else:
		path = "res://assets/audio/sfx/Voiceover/Cat/%s/miao_%s_%s.wav" % [letter, letter, event]

	if _player.playing:
		return

	var stream: AudioStream = load(path)
	if not stream:
		push_warning("[SfxManager] Could not load cat voice: %s" % path)
		return

	_player.stream = stream
	_player.pitch_scale = 1.0 + _rng.randf_range(-PITCH_VARIATION, PITCH_VARIATION)
	_player.volume_db = BASE_VOLUME_DB + _rng.randf_range(-VOLUME_VARIATION_DB, VOLUME_VARIATION_DB)
	_player.play()


func _play_env(stream: AudioStream) -> void:
	_env_player.stream = stream
	_env_player.play()


func _on_player_entered_box() -> void:
	play_cat_voice("box")


func _on_cat_pushed_back() -> void:
	play_cat_voice("collide")


func _on_level_completed() -> void:
	play_cat_voice("end")
