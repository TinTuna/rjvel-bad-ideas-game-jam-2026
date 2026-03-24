extends Interactable

@onready var glass: Sprite2D = $Glass
@onready var glass_down: Sprite2D = $GlassDown

var is_down: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func interact() -> void:
	if is_down == false:
		print("Knocked down glass")
		glass.hide()
		glass_down.show()
		is_down = true
