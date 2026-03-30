extends Control

@onready var options_dropdown: OptionButton = $HBoxContainer/MarginContainer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/OptionsDropdown
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var restart_button: Button = $HBoxContainer/MarginContainer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/RestartButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    if Constants.is_settings_initialised:
        restart_button.disabled = false


func _on_confirm_button_pressed() -> void:
    Constants.voice_pack = options_dropdown.get_selected_id()
    Constants.is_settings_initialised = true

func _on_options_dropdown_item_selected(index: int) -> void:
    var voice_pack = Constants.VOICE_PACKS[index]
    var audio_path = "res://assets/audio/sfx/Voiceover/Cat/" + voice_pack + "/miao_" + voice_pack + "_button_0.wav" 
    var audio_file = load(audio_path)
    audio_player.stream = audio_file
    audio_player.play()


func _on_restart_button_pressed() -> void:
    EventBus.day_started.emit(Constants.current_day)
    SceneLoader.load_scene(Constants.SCENES["LEVEL_" + str(Constants.current_day)])
