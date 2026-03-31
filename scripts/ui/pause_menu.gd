extends Control

@onready var panel_container: PanelContainer = $CenterContainer/PanelContainer
@onready var settings: Control = $Settings

const LEVEL_SCENES := {
    0: "LEVEL_0",
    1: "LEVEL_1",
    2: "LEVEL_2",
    3: "LEVEL_3",
    4: "LEVEL_4",
}


func _ready() -> void:
    settings.visibility_changed.connect(_on_settings_visibility_changed)


func show_menu() -> void:
    show()
    panel_container.show()
    settings.hide()
    get_tree().paused = true


func hide_menu() -> void:
    hide()
    get_tree().paused = false


func _on_resume_pressed() -> void:
    hide_menu()


func _on_settings_pressed() -> void:
    panel_container.hide()
    settings.show()


func _on_reset_day_pressed() -> void:
    hide_menu()
    var scene_name: String = LEVEL_SCENES.get(Constants.current_day, "")
    if scene_name.is_empty():
        push_warning("[PauseMenu] No level scene mapped for day %d" % Constants.current_day)
        return
    SceneLoader.load_scene(Constants.SCENES[scene_name])


func _on_quit_to_menu_pressed() -> void:
    hide_menu()
    SceneLoader.load_scene(Constants.SCENES["MAIN_MENU"])


func _on_settings_visibility_changed() -> void:
    if not settings.visible:
        panel_container.show()
