extends Interactable

const SFX_CAT_ENTERS_BOX = preload("uid://dgctxx0wbtaii")
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_cat_inside: bool = false
var is_cat_interacting: bool = false

func _process(delta: float) -> void:
    if is_cat_interacting and is_cat_inside == false and Input.is_action_pressed("interact"):
        is_cat_inside = true
        EventBus.player_entered_box.emit()
        animation_player.play("box_shake")
        _play_one_shot(SFX_CAT_ENTERS_BOX)

    if is_cat_interacting and is_cat_inside and Input.is_action_just_released("interact"):
        is_cat_inside = false
        is_cat_interacting = false
        EventBus.player_left_box.emit()
        animation_player.play("box_shake")


func interact() -> void:
    is_cat_interacting = true


func _play_one_shot(stream: AudioStream) -> void:
    var player := AudioStreamPlayer.new()
    player.stream = stream
    player.bus = Constants.AUDIO_BUSES.SFX
    add_child(player)
    player.play()
    player.finished.connect(player.queue_free)
