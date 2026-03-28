extends CharacterBody2D

@export var JUMP_SPEED: float = -500
@export var MOVEMENT_SPEED: float = 500
@export var ACCELERATION: float = 40

@onready var sprite: Sprite2D = $Area/Sprite
@onready var jump_sprite: Sprite2D = $Area/JumpSprite
@onready var area: Area2D = $Area

@export var PUSH_SPEED: float = 600.0
@export var PUSH_DURATION: float = 0.4

@onready var item_container: Node2D = $ItemContainer

var _push_timer: float = 0.0
var _is_movement_disabled: bool = false

func _ready() -> void:
	add_to_group("cat")
	EventBus.player_entered_box.connect(hide_in_box)
	EventBus.player_left_box.connect(leave_box)
	EventBus.player_picked_up_item.connect(pick_up_item)
	EventBus.player_put_down_item.connect(put_down_item)


func _physics_process(delta: float) -> void:
	velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity") * delta

	if _push_timer > 0.0:
		_push_timer -= delta
	else:
		if jump_sprite.visible and is_on_floor():
			jump_sprite.hide()
			sprite.show()

		if _is_movement_disabled == false and is_on_floor() and Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_SPEED
			sprite.hide()
			jump_sprite.show()
			EventBus.cat_jumped.emit()

		if _is_movement_disabled == false and (Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")):
			var new_velocity = velocity.x + ACCELERATION * Input.get_axis("move_left", "move_right")
			velocity.x = clamp(new_velocity, -MOVEMENT_SPEED, MOVEMENT_SPEED)
		elif velocity.x != 0:
			velocity.x = move_toward(velocity.x, 0.0, ACCELERATION)

	move_and_slide()
	
	if _is_movement_disabled == false and Input.is_action_just_pressed("interact") and area.has_overlapping_areas():
		var object_to_interact = area.get_overlapping_areas()[0]
		if object_to_interact is Interactable:
			object_to_interact.interact()

## Called by an NPC when it touches the cat.
## Launches the cat away from the NPC's position with a small upward jump.
func push_back(source_position: Vector2) -> void:
	if _is_movement_disabled:
		return
	var direction := signf(global_position.x - source_position.x)
	if direction == 0.0:
		direction = 1.0
	velocity.x = direction * PUSH_SPEED
	velocity.y = JUMP_SPEED
	_push_timer = PUSH_DURATION
	sprite.hide()
	jump_sprite.show()
	EventBus.cat_pushed_back.emit()

func hide_in_box() -> void:
	area.hide()
	_is_movement_disabled = true

func leave_box() -> void:
	area.show()
	_is_movement_disabled = false

func pick_up_item(item: Node2D) -> void:
	item.reparent(item_container)
	item.position.x = 50
	item.position.y = -80

func put_down_item(item: Node2D) -> void:
	item.reparent(self.get_parent())
	
