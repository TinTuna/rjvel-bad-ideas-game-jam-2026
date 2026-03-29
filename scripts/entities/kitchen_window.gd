extends Sprite2D

const WINDOW_2_OPEN = preload("uid://15aekovu53cq")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.window_open.connect(window_opened)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func window_opened() -> void:
	texture = WINDOW_2_OPEN
