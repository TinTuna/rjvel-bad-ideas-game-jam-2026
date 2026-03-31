extends Interactable

var _is_opened: bool = false

const BOX_UNDER_BED_OPEN = preload("uid://csk57kw38ckb8")
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D

func interact() -> void:
    if _is_opened == false:
        _is_opened = true
        sprite.texture = BOX_UNDER_BED_OPEN
        var key = get_parent().get_node("Key")
        EventBus.player_picked_up_item.emit(key)
        collision_shape.set_deferred("disabled", true)
