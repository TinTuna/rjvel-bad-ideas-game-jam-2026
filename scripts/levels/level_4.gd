extends Node2D

@onready var level_end_trigger: Area2D = $LevelEndTrigger

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass


func _on_level_end_trigger_body_entered(body: Node2D) -> void:
    if body.is_in_group("cat"):
        EventBus.level_completed.emit()
        SceneLoader.load_scene(Constants.SCENES["OUTRO"])
