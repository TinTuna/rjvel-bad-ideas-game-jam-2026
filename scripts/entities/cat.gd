extends CharacterBody2D

const JUMP_SPEED: float = -500
const MOVEMENT_SPEED: float = 500
const ACCELERATION: float = 40
@onready var sprite: Sprite2D = $Sprite
@onready var jump_sprite: Sprite2D = $JumpSprite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity") * delta
	
	if jump_sprite.visible and is_on_floor():
		jump_sprite.hide()
		sprite.show()
	
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_SPEED
		sprite.hide()
		jump_sprite.show()
	
	if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
		var new_velocity = velocity.x + ACCELERATION * Input.get_axis("move_left","move_right")
		velocity.x = clamp(new_velocity, -MOVEMENT_SPEED, MOVEMENT_SPEED)
	elif velocity.x != 0:
		velocity.x = move_toward(velocity.x, 0.0, ACCELERATION)
		
	move_and_slide()
