extends Control

@onready var settings: Control = $Settings


func _ready() -> void:
    MusicManager.transition_to("MAIN_MENU")


func _on_play_button_pressed() -> void:
    if Constants.has_scene("INTRO"):
        SceneLoader.load_scene(Constants.SCENES.INTRO)
    else:
        push_warning("[MainMenu] INTRO scene not configured in Constants")


func _on_settings_button_pressed() -> void:
    settings.show()


func _on_quit_button_pressed() -> void:
    # Quit the game
    get_tree().quit()
