extends Interactable

const PHONE_OFF = preload("uid://d0io0ulk0xex7")
const PHONE_ON = preload("uid://e6xfdbgrmeyd")

@onready var sprite: Sprite2D = $Sprite2D
@onready var pizza_timer: Timer = $PizzaTimer
@onready var phone_timer: Timer = $PhoneTimer
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

var _is_interactable = true

signal phone_reset()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    phone_reset.connect(_on_phone_reset)


func interact() -> void:
    if _is_interactable == false:
        return
    _is_interactable = false
    sprite.texture = PHONE_ON
    audio_player.play()
    await get_tree().create_timer(6.6).timeout
    pizza_timer.start()
    phone_timer.start()
    sprite.texture = PHONE_OFF


func _on_phone_timer_timeout() -> void:
    phone_reset.emit()

func _on_pizza_timer_timeout() -> void:
    EventBus.pizza_delivered.emit()

func _on_phone_reset() -> void:
    _is_interactable = true
