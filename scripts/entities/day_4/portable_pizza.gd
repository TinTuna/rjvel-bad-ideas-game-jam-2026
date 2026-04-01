extends Interactable

const OPEN_PIZZA_BOX = preload("uid://uewpy6qpdt03")
@onready var sprite: Sprite2D = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    add_to_group("pizza")
    EventBus.twins_feasted.connect(open)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func interact() -> void:
    EventBus.player_picked_up_item.emit(self)

func open() -> void:
    sprite.texture = OPEN_PIZZA_BOX
    sprite.scale = Vector2(0.6, 0.6)
