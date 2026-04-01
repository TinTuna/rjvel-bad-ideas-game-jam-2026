extends Node2D

@onready var level_end_trigger: Area2D = $LevelEndTrigger

func _ready() -> void:
    Constants.current_day = 4
    EventBus.twins_feasted.connect(drop_pizza)


func _on_level_end_trigger_body_entered(body: Node2D) -> void:
    if body.is_in_group("cat"):
        SceneLoader.load_scene(Constants.SCENES["OUTRO"])

func drop_pizza() -> void:
    Input.action_press("drop")
