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
    #TODO: start smoke + person opens window
    EventBus.toaster_burnt.emit()

func reset() -> void:
    sprite.texture = TOASTER_OFF
    _is_on = false
    #TODO: stop smoke
    collision_shape.set_deferred("disabled", false)
