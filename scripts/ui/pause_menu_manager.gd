extends CanvasLayer
## PauseMenuManager - Global pause menu handler
##
## Autoload CanvasLayer that intercepts Escape and shows the pause menu
## whenever a level is active (detected by the presence of a "cat" group node).
## Setting process_mode to ALWAYS means it and its children keep running
## even when get_tree().paused = true.

var _menu: Control


func _ready() -> void:
    layer = 10
    process_mode = Node.PROCESS_MODE_ALWAYS

    var scene: PackedScene = preload("res://scenes/menus/pause_menu.tscn")
    _menu = scene.instantiate()
    _menu.process_mode = Node.PROCESS_MODE_ALWAYS
    add_child(_menu)
    _menu.hide()


func _unhandled_input(event: InputEvent) -> void:
    if not event.is_action_pressed("ui_cancel"):
        return
    if get_tree().get_nodes_in_group("cat").is_empty():
        # hack to see if we're in game
        return
    if _menu.visible:
        _menu.hide_menu()
    else:
        _menu.show_menu()
    get_viewport().set_input_as_handled()
