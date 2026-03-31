extends Node2D

@onready var twins_pizza_trigger: Area2D = $TwinsPizzaTrigger
@onready var open_pizza_box: Sprite2D = $House/OpenPizzaBox
@onready var level_end_trigger: Area2D = $LevelEndTrigger
@onready var twins: CharacterBody2D = $Twins

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass


func _on_twins_pizza_trigger_area_entered(area: Area2D) -> void:
    if area.is_in_group("pizza"):
        EventBus.player_put_down_item.emit(area)
        area.queue_free()
        open_pizza_box.show()
        twins.position.x = 4354


func _on_level_end_trigger_body_entered(body: Node2D) -> void:
    if body.is_in_group("cat"):
        SceneLoader.load_scene(Constants.SCENES["OUTRO"])
