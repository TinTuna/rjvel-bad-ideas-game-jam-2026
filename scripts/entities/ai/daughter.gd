extends FamilyMemberBase
## Daughter NPC

const SpeechBubble = preload("res://scripts/ui/speech_bubble.gd")

var _voice_player: AudioStreamPlayer
var _speech_bubble: Node2D


func _ready() -> void:
    character_name = "Daughter"
    movement_speed = 250.0
    patrol_wait_time = 1.5
    auto_start_patrol = false  # Level scripts call start_for_day(day)

    add_to_group("daughter")

    _voice_player = AudioStreamPlayer.new()
    _voice_player.bus = Constants.AUDIO_BUSES.SFX
    _voice_player.finished.connect(_on_voice_finished)
    add_child(_voice_player)

    _speech_bubble = SpeechBubble.new()
    _speech_bubble.position = Vector2(0, -375)
    add_child(_speech_bubble)

    super._ready()


func _on_voice_finished() -> void:
    await get_tree().create_timer(5.0).timeout
    _speech_bubble.hide_bubble()


func play_voice_line(code: String, text: String = "") -> void:
    if _voice_player.playing:
        return
    var stream: AudioStream = load(Constants.get_voice_audio_path("Girl", code))
    if not stream:
        push_error("[Daughter] Failed to load voice line: %s" % code)
        return
    _voice_player.stream = stream
    _voice_player.play()
    if not text.is_empty():
        _speech_bubble.show_text(text)
