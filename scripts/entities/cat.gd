extends CharacterBody2D

@export var JUMP_SPEED: float = -500
@export var MOVEMENT_SPEED: float = 500
@export var ACCELERATION: float = 40

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var interact_prompt: Label = $InteractPrompt

@export var PUSH_SPEED: float = 600.0
@export var PUSH_DURATION: float = 0.4

@onready var item_container: Node2D = $ItemContainer

var _push_timer: float = 0.0
var _is_movement_disabled: bool = false
var _nearby_interactable_count: int = 0
var _is_carrying_item: bool = false

const DROP_THROUGH_DURATION: float = 0.3
var _drop_timer: float = 0.0

enum AnimState { IDLE, WALK, JUMP, JUMP_DOWN }
var _anim_state: AnimState = AnimState.IDLE

func _ready() -> void:
    add_to_group("cat")
    EventBus.player_entered_box.connect(hide_in_box)
    EventBus.player_left_box.connect(leave_box)
    EventBus.player_picked_up_item.connect(pick_up_item)
    EventBus.player_put_down_item.connect(put_down_item)
    EventBus.cat_near_interactable.connect(_on_cat_near_interactable)
    EventBus.cat_left_interactable.connect(_on_cat_left_interactable)
    set_collision_mask_value(2, true)


func _process(_delta: float) -> void:
    if Input.is_action_just_pressed("drop"):
        SfxManager.play_cat_voice("button")
    
    if Input.is_action_just_pressed("drop") and _is_movement_disabled == false:
        if _is_carrying_item:
            EventBus.player_put_down_item.emit(item_container.get_child(0))
        else:
            SfxManager.play_cat_voice("button")

func _physics_process(delta: float) -> void:
    var pre_input_vx := velocity.x
    velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity") * delta

    if _push_timer > 0.0:
        _push_timer -= delta
    else:
        if _is_movement_disabled == false and is_on_floor() and Input.is_action_just_pressed("jump"):
            velocity.y = JUMP_SPEED
            EventBus.cat_jumped.emit()

        if _is_movement_disabled == false and (Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")):
            var new_velocity = velocity.x + ACCELERATION * Input.get_axis("move_left", "move_right")
            velocity.x = clamp(new_velocity, -MOVEMENT_SPEED, MOVEMENT_SPEED)
        elif velocity.x != 0:
            velocity.x = move_toward(velocity.x, 0.0, ACCELERATION)

    if _drop_timer > 0.0:
        _drop_timer -= delta
        set_collision_mask_value(2, false)
    else:
        set_collision_mask_value(2, true)
        if _is_movement_disabled == false and is_on_floor() and Input.is_action_just_pressed("move_down"):
            _drop_timer = DROP_THROUGH_DURATION

    move_and_slide()
    _update_animation(pre_input_vx)

    if _is_movement_disabled == false and Input.is_action_just_pressed("interact"):
        var space_state := get_world_2d().direct_space_state
        var params := PhysicsShapeQueryParameters2D.new()
        params.shape = collision_shape.shape
        params.transform = collision_shape.global_transform
        params.collide_with_areas = true
        params.collide_with_bodies = false
        for result in space_state.intersect_shape(params):
            if result["collider"] is Interactable:
                result["collider"].interact()
                break


func _update_animation(pre_input_vx: float) -> void:
    var new_state: AnimState

    if not is_on_floor():
        new_state = AnimState.JUMP_DOWN if velocity.y > 0.0 else AnimState.JUMP
    elif abs(pre_input_vx) > 10.0:
        new_state = AnimState.WALK
    else:
        new_state = AnimState.IDLE

    # Flip sprite based on movement direction (default animation faces left)
    if velocity.x > 0.0:
        animated_sprite.flip_h = true
    elif velocity.x < 0.0:
        animated_sprite.flip_h = false

    if new_state == _anim_state:
        return

    _anim_state = new_state
    match _anim_state:
        AnimState.WALK:
            animated_sprite.play("walk")
            animated_sprite.scale = Vector2(1.0, 1.0)
            animated_sprite.position.y = -34.0
        AnimState.IDLE:
            animated_sprite.play("idle")
            animated_sprite.scale = Vector2(0.65, 0.65)
            animated_sprite.position.y = -35.0
        AnimState.JUMP:
            animated_sprite.play("jump_up")
            animated_sprite.scale = Vector2(0.20, 0.20)
            animated_sprite.position.y = -35.0
        AnimState.JUMP_DOWN:
            animated_sprite.play("jump_down")
            animated_sprite.scale = Vector2(0.20, 0.20)
            animated_sprite.position.y = -35.0


## Called by an NPC when it touches the cat.
## Launches the cat away from the NPC's position with a small upward jump.
func push_back(source_position: Vector2) -> void:
    var direction := signf(global_position.x - source_position.x)
    if direction == 0.0:
        direction = 1.0
    velocity.x = direction * PUSH_SPEED
    if is_on_floor():
        velocity.y = JUMP_SPEED
    _push_timer = PUSH_DURATION
    EventBus.cat_pushed_back.emit()

func play_walk_animation(face_right: bool) -> void:
    animated_sprite.flip_h = face_right
    animated_sprite.play("walk")
    animated_sprite.scale = Vector2(1.0, 1.0)
    animated_sprite.position.y = -34.0
    _anim_state = AnimState.WALK

func take_control() -> void:
    _is_movement_disabled = true
    velocity = Vector2.ZERO
    collision_layer = 0
    set_physics_process(false)

func release_control() -> void:
    _is_movement_disabled = false
    velocity = Vector2.ZERO
    collision_layer = 1
    set_physics_process(true)

func hide_in_box() -> void:
    animated_sprite.hide()
    _is_movement_disabled = true
    collision_layer = 0
    if item_container.get_child_count() != 0:
        item_container.get_child(0).hide()

func leave_box() -> void:
    animated_sprite.show()
    _is_movement_disabled = false
    collision_layer = 1
    if item_container.get_child_count() != 0:
        item_container.get_child(0).show()

func pick_up_item(item: Node2D) -> void:
    item.reparent(item_container)
    item.position.x = -50
    item.position.y = 0
    _is_carrying_item = true

func put_down_item(item: Node2D) -> void:
    _is_carrying_item = false
    item.position.x = 0
    item.reparent(self.get_parent())

func show_interact_prompt() -> void:
    interact_prompt.show()

func hide_interact_prompt() -> void:
    interact_prompt.hide()

func _on_cat_near_interactable() -> void:
    _nearby_interactable_count += 1
    show_interact_prompt()

func _on_cat_left_interactable() -> void:
    _nearby_interactable_count = max(0, _nearby_interactable_count - 1)
    if _nearby_interactable_count == 0:
        hide_interact_prompt()
