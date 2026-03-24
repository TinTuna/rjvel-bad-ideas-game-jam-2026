extends Interactable

@onready var glass: Sprite2D = $Glass

var is_down: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.glass_reset.connect(glass_reset)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func interact() -> void:
	if is_down == false:
		glass.rotation = -80
		glass.position.y += 60
		is_down = true
		EventBus.glass_knocked_down.emit()

func glass_reset() -> void:
	is_down = false
	glass.rotation = 0
	glass.position.y -= 60
