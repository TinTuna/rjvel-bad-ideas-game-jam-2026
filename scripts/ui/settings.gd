extends Control

@onready var options_dropdown: OptionButton = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/OptionsDropdown
@onready var music_slider: HSlider = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer3/HSlider
@onready var sfx_slider: HSlider = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer4/HSlider2
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D


func _ready() -> void:
    options_dropdown.selected = Constants.voice_pack
    music_slider.value = Constants.music_volume * 10.0
    sfx_slider.value = Constants.sfx_volume * 10.0


func _on_confirm_button_pressed() -> void:
    Constants.voice_pack = options_dropdown.get_selected_id()
    Constants.music_volume = music_slider.value / 10.0
    Constants.sfx_volume = sfx_slider.value / 10.0
    Constants.is_settings_initialised = true
    Constants.apply_audio_settings()
    hide()


func _on_options_dropdown_item_selected(index: int) -> void:
    var voice_pack = Constants.VOICE_PACKS[index]
    var audio_path = "res://assets/audio/sfx/Voiceover/Cat/" + voice_pack + "/miao_" + voice_pack + "_button_0.wav"
    var audio_file = load(audio_path)
    audio_player.stream = audio_file
    audio_player.play()


func _on_music_slider_value_changed(value: float) -> void:
    Constants.music_volume = value / 10.0
    Constants.apply_audio_settings()


func _on_sfx_slider_2_value_changed(value: float) -> void:
    Constants.sfx_volume = value / 10.0
    Constants.apply_audio_settings()


func _on_back_button_pressed() -> void:
    hide()
