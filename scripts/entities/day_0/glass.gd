extends Interactable

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
const MOVE_GLASS = preload("uid://81qy1qohdupt")
const GLASS_FALL = preload("uid://bw25kt8c63kew")

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
        audio_player.stream = MOVE_GLASS
        audio_player.play()
        animation_player.play("knock_glass_to_floor")
        EventBus.glass_knocked_down.emit()

func glass_reset() -> void:
    is_down = false
    animation_player.play_backwards("knock_glass_to_floor")


func _on_fall_animation_finished(anim_name: StringName) -> void:
    audio_player.stream = GLASS_FALL
    audio_player.play()
