extends Interactable

const SFX_KEY_OPEN = preload("uid://c2coqd1hn2swf")

func _ready() -> void:
    add_to_group("key")

func interact() -> void:
    _play_one_shot(SFX_KEY_OPEN)
    EventBus.player_picked_up_item.emit(self)


func _play_one_shot(stream: AudioStream) -> void:
    var player := AudioStreamPlayer.new()
    player.stream = stream
    player.bus = Constants.AUDIO_BUSES.SFX
    add_child(player)
    player.play()
    player.finished.connect(player.queue_free)
