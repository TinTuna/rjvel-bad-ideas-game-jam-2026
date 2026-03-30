extends Interactable

const TOASTER_OFF = preload("uid://c7augj8shy30l")
const TOASTER_ON = preload("uid://cevcrd8e3h2u6")
@onready var timer: Timer = $Timer
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

@export var is_interactable: bool = true

var _is_on: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    EventBus.toaster_reset.connect(reset)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func interact() -> void:
    if _is_on == false and is_interactable:
        _is_on = true
        timer.start()
        sprite.texture = TOASTER_ON
        collision_shape.set_deferred("disabled", true)


func _on_timer_timeout() -> void:
    #TODO: person opens window
    EventBus.toaster_burnt.emit()
    $CPUParticles2D.emitting = true
    await get_tree().create_timer(5.0).timeout
    $CPUParticles2D2.emitting = true

func reset() -> void:
    sprite.texture = TOASTER_OFF
    _is_on = false
    $CPUParticles2D.emitting = false
    $CPUParticles2D2.emitting = false
    collision_shape.set_deferred("disabled", false)
