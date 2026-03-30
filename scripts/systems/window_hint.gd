extends Node2D
## WindowHint — Cinematic hint trigger at the living room window.
##
## When the cat reaches the windowsill the camera pans and zooms to the window
## and shows a message from the outside cat. Resets when the cat leaves.

@export var hint_text: String = "Glass?"
@export var zoom_in_duration: float = 1.0
@export var zoom_out_duration: float = 1.0
@export var target_zoom: Vector2 = Vector2(2.5, 2.5)
@export var trigger_delay: float = 0.25

@onready var trigger: Area2D = $Trigger
@onready var hint_label: Label = $"../HintOverlay/HintLabel"

var _camera: Camera2D
var _is_showing: bool = false
var _cat_in_trigger: bool = false
var _cat: CharacterBody2D


func _ready() -> void:
    hint_label.visible = false
    hint_label.text = hint_text
    trigger.collision_mask = 1
    trigger.body_entered.connect(_on_trigger_entered)
    trigger.body_exited.connect(_on_trigger_exited)

    await get_tree().process_frame
    _camera = get_tree().get_first_node_in_group("game_camera")


func _on_trigger_entered(body: Node2D) -> void:
    if _is_showing or not body.is_in_group("cat"):
        return
    _cat = body
    _cat_in_trigger = true

    await get_tree().create_timer(trigger_delay).timeout

    # Abort if the cat left the area or is still airborne after the delay.
    if not _cat_in_trigger or not _cat.is_on_floor():
        return

    _is_showing = true
    _camera.enter_cinematic($CinematicCamera.global_position, target_zoom, zoom_in_duration)
    await get_tree().create_timer(zoom_in_duration).timeout
    if _is_showing:
        hint_label.visible = true


func _on_trigger_exited(body: Node2D) -> void:
    if not body.is_in_group("cat"):
        return
    _cat_in_trigger = false
    if not _is_showing:
        return
    _is_showing = false
    hint_label.visible = false
    _camera.exit_cinematic(zoom_out_duration)
