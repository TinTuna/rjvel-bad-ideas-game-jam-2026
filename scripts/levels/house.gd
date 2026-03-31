extends Node2D

## Reusable House scene controller.
## Attach this script to the House root node to control which floors are accessible.

enum FrontDoorState { CLOSED, CATFLAP_OPEN, OPEN }

@export var upstairs_enabled: bool = true:
    set(value):
        upstairs_enabled = value
        if is_node_ready():
            _apply_upstairs_state()

@export var front_door_state: FrontDoorState = FrontDoorState.CLOSED:
    set(value):
        front_door_state = value
        if is_node_ready():
            _apply_front_door_state()

@onready var _upstairs_rooms: Array[Node] = [
    $Landing,
    $BoysRoom,
    $MumsBedroomRoom,
    $Dividers/Divider_Landing_BoysRoom,
    $Dividers/Divider_MumsBedroom_Landing,
]
@onready var _stairs_bottom: StairInteractable = $StairsBottom
@onready var _stairs_top: StairInteractable = $StairsTop
@onready var _front_door_closed: Sprite2D = $Entry/FrontDoor
@onready var _front_door_flap_open: Sprite2D = $Entry/FrontDoorFlapOpen
@onready var _front_door_open: Sprite2D = $Entry/FrontDoorOpen


func _ready() -> void:
    _apply_upstairs_state()
    _apply_front_door_state()


func _apply_upstairs_state() -> void:
    for room in _upstairs_rooms:
        room.visible = upstairs_enabled

    _stairs_bottom.monitoring = upstairs_enabled
    _stairs_bottom.monitorable = upstairs_enabled
    _stairs_top.monitoring = upstairs_enabled
    _stairs_top.monitorable = upstairs_enabled

    for stair in [_stairs_bottom, _stairs_top]:
        for child in stair.get_children():
            if child is CollisionShape2D:
                child.disabled = not upstairs_enabled


func _apply_front_door_state() -> void:
    _front_door_closed.visible = front_door_state == FrontDoorState.CLOSED
    _front_door_flap_open.visible = front_door_state == FrontDoorState.CATFLAP_OPEN
    _front_door_open.visible = front_door_state == FrontDoorState.OPEN
