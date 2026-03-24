extends Interactable

var is_cat_inside: bool = false
var is_cat_interacting: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	if is_cat_interacting and is_cat_inside == false and Input.is_action_pressed("interact"):
		is_cat_inside = true
		EventBus.player_entered_box.emit()
	
	if is_cat_interacting and is_cat_inside and Input.is_action_just_released("interact"):
		is_cat_inside = false
		is_cat_interacting = false
		EventBus.player_left_box.emit()


func interact() -> void:
	is_cat_interacting = true
