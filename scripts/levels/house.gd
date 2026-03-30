extends Node2D

## Reusable House scene controller.
## Attach this script to the House root node to control which floors are accessible.

@export var upstairs_enabled: bool = true:
    set(value):
        upstairs_enabled = value
        if is_node_ready():
            _apply_upstairs_state()

@onready var _upstairs_rooms: Array[Node] = [
    $Landing,
    $BoysRoom,
    $MumsBedroomRoom,
    $Dividers/Divider_Landing_BoysRoom,
    $Dividers/Divider_MumsBedroom_Landing,
]
@onready var _stairs_bottom: StairInteractable = $StairsBottom
@onready var _stairs_top: StairInteractable = $StairsTop


func _ready() -> void:
    _apply_upstairs_state()


func _apply_upstairs_state() -> void:
    for room in _upstairs_rooms:
        room.visible = upstairs_enabled

    _stairs_bottom.monitoring = upstairs_enabled
    _stairs_bottom.monitorable = upstairs_enabled
    _stairs_top.monitoring = upstairs_enabled
    _stairs_top.monitorable = upstairs_enabled
