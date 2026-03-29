extends Interactable


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    add_to_group("key")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func interact() -> void:
    EventBus.player_picked_up_item.emit(self)
