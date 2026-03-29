extends Interactable

const PHONE_OFF = preload("uid://d0io0ulk0xex7")
const PHONE_ON = preload("uid://e6xfdbgrmeyd")

@onready var sprite: Sprite2D = $Sprite2D
@onready var timer: Timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func interact() -> void:
    sprite.texture = PHONE_ON
    #TODO: Conversation on the phone
    timer.start()
    sprite.texture = PHONE_OFF


func _on_timer_timeout() -> void:
    EventBus.pizza_delivered.emit
