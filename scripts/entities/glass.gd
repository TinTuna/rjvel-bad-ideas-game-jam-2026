extends Interactable

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_down: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("glass")
	EventBus.glass_reset.connect(glass_reset)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func interact() -> void:
	if is_down == false:
		is_down = true
		animation_player.play("knock_glass_to_floor")
		EventBus.glass_knocked_down.emit()

func glass_reset() -> void:
	is_down = false
	animation_player.play_backwards("knock_glass_to_floor")
