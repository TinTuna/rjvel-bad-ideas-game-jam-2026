extends Interactable

const TOASTER_OFF = preload("uid://c7augj8shy30l")
const TOASTER_ON = preload("uid://cevcrd8e3h2u6")
const SFX_TOASTER_PRESS = preload("uid://dahwhqc4a8jee")
const SFX_TOASTER_FINISH = preload("uid://dqkybjps8h4td")
@onready var timer: Timer = $Timer
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

@export var is_interactable: bool = true

var _is_on: bool = false

func _ready() -> void:
    EventBus.toaster_reset.connect(reset)

func interact() -> void:
    if _is_on == false and is_interactable:
        _is_on = true
        timer.start()
        sprite.texture = TOASTER_ON
        collision_shape.set_deferred("disabled", true)
        _play_one_shot(SFX_TOASTER_PRESS)


func _on_timer_timeout() -> void:
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


func _play_one_shot(stream: AudioStream) -> void:
    var player := AudioStreamPlayer.new()
    player.stream = stream
    player.bus = Constants.AUDIO_BUSES.SFX
    add_child(player)
    player.play()
    player.finished.connect(player.queue_free)
