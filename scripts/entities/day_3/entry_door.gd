extends Sprite2D

var is_open: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    EventBus.mother_opens_door.connect(open)
    EventBus.mother_closes_door.connect(close)

func open() -> void:
    show()
    is_open = true
    
func close() -> void:
    hide()
    is_open = false
