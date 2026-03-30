extends Control

@onready var options_dropdown: OptionButton = $HBoxContainer/MarginContainer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/OptionsDropdown
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


func _on_confirm_button_pressed() -> void:
    Constants.voice_pack = options_dropdown.get_selected_id()


func _on_options_dropdown_item_selected(index: int) -> void:
    #var rng = RandomNumberGenerator.new()
    #var random_miao_number = rng.randi_range(0, Constants.MIAOS_NUMBER[index] - 1)
    #var code: String = "miao_" + Constants.VOICE_PACKS[index] + "_button_" + str(random_miao_number)
    #var audio_path = Constants.get_voice_audio_path("Cat", code)
    #audio_player.stream. = audio_path
    #audio_player.play()
    pass


func _on_restart_button_pressed() -> void:
    pass # Replace with function body.
