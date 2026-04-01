extends Interactable

class_name StairInteractable

const STAIRS_CREAK = preload("uid://cbuce7cixfsbs")

## Midpoint marker at the top/bottom of the stair sprite itself.
@export var stairs_marker: Marker2D

## The final marker the cat arrives at after the stairs (landing or entry spot).
@export var destination_marker: Marker2D

## Duration of the first leg (entry → stairs waypoint).
@export var leg1_duration: float = 2.0

## Duration of the second leg (stairs waypoint → destination).
@export var leg2_duration: float = 0.5

## Direction the cat faces during traversal. Up = left (false), Down = right (true).
@export var face_right: bool = false

## Z-index applied to the cat at the start of traversal (while on the stairs).
## Going up from entry: 1. Going down from landing: 0.
@export var starting_z_index: int = 2

## Z-index applied to the cat on arrival. Should be 3 to be in front of NPCs, 2 for default.
@export var destination_z_index: int = 5

func interact() -> void:
    var cat = get_tree().get_first_node_in_group("cat")
    if not cat:
        return

    var audio := AudioStreamPlayer.new()
    audio.stream = STAIRS_CREAK
    audio.bus = Constants.AUDIO_BUSES.SFX
    add_child(audio)
    audio.play()
    audio.finished.connect(audio.queue_free)

    cat.z_index = starting_z_index
    cat.take_control()
    cat.play_walk_animation(face_right)

    var tween := create_tween()
    tween.tween_property(cat, "global_position", stairs_marker.global_position, leg1_duration).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
    tween.tween_property(cat, "global_position", destination_marker.global_position, leg2_duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
    tween.tween_callback(func() -> void:
        cat.z_index = destination_z_index
        cat.release_control()
    )
