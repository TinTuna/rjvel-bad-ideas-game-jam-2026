extends Camera2D
## GameCamera — Single scene camera that follows the cat and supports cinematics.
##
## Lives at the scene root. In normal mode it lerps toward the cat every frame.
## Cinematic mode tweens to a target position/zoom; exiting cinematic re-enables
## the follow lerp immediately so the camera drifts back naturally while zooming out.

@export var follow_offset: Vector2 = Vector2(0, -250)
@export var follow_smoothing: float = 8.0

var _target: Node2D
var _cinematic_mode: bool = false
var _returning: bool = false
var _tween: Tween


func _ready() -> void:
	add_to_group("game_camera")
	await get_tree().process_frame
	_target = get_tree().get_first_node_in_group("cat")
	if _target:
		global_position = _target.global_position + follow_offset


func _process(delta: float) -> void:
	if not _target:
		return
	# Follow the cat in normal mode, or while returning from a cinematic.
	if not _cinematic_mode or _returning:
		global_position = global_position.lerp(
			_target.global_position + follow_offset,
			follow_smoothing * delta
		)


## Pan and zoom to a world-space position over `duration` seconds.
func enter_cinematic(target_pos: Vector2, target_zoom: Vector2, duration: float) -> void:
	if _tween:
		_tween.kill()
	_returning = false
	_cinematic_mode = true
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_IN_OUT)
	_tween.set_trans(Tween.TRANS_CUBIC)
	_tween.set_parallel(true)
	_tween.tween_property(self, "global_position", target_pos, duration)
	_tween.tween_property(self, "zoom", target_zoom, duration)


## Tween zoom back to 1.0 while lerping position back to the cat.
## Clears cinematic mode only once the zoom tween finishes.
func exit_cinematic(duration: float) -> void:
	if _tween:
		_tween.kill()
	_returning = true
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_IN_OUT)
	_tween.set_trans(Tween.TRANS_CUBIC)
	_tween.tween_property(self, "zoom", Vector2.ONE, duration)
	_tween.tween_callback(func():
		_cinematic_mode = false
		_returning = false
		_tween = null
	)
