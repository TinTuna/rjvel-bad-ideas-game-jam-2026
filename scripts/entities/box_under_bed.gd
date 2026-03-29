extends Interactable

var _is_opened: bool = false

const BOX_UNDER_BED_OPEN = preload("uid://csk57kw38ckb8")
const KEY = preload("uid://c3lhfy4xcqrbt")

@onready var sprite: Sprite2D = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func interact() -> void:
	if _is_opened == false:
		_is_opened = true
		sprite.texture = BOX_UNDER_BED_OPEN
		var bedroom = self.get_parent()
		var new_key = KEY.instantiate()
		bedroom.add_child(new_key)
		new_key.position.x = 1750
		new_key.position.y = 1950
