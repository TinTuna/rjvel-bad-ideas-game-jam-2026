extends Sprite2D

var is_open: bool = false

@onready var timer: Timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    EventBus.pizza_delivered.connect(open)

func open() -> void:
    show()
    is_open = true
    timer.start()
    
func _on_timer_timeout() -> void:
    hide()
    is_open = false
