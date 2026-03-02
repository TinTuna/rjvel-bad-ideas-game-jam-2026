extends Control

func _on_play_button_pressed() -> void:
    if Constants.has_scene("LEVEL_01"):
        SceneLoader.load_scene(Constants.SCENES.LEVEL_01)
    else:
        push_warning("[MainMenu] LEVEL_01 scene not configured in Constants")


func _on_settings_button_pressed() -> void:
    # Load settings menu
    if Constants.has_scene("SETTINGS"):
        SceneLoader.load_scene(Constants.SCENES.SETTINGS)
    else:
        push_warning("[MainMenu] SETTINGS scene not configured in Constants")


func _on_quit_button_pressed() -> void:
    # Quit the game
    get_tree().quit()
