extends FamilyMemberBase
## Mother NPC

# ============================================================================
# CONFIGURATION
# ============================================================================

const SpeechBubble = preload("res://scripts/ui/speech_bubble.gd")

var _voice_player: AudioStreamPlayer
var _speech_bubble: Node2D
var _hide_token: int = 0


func _ready() -> void:
    character_name = "Mother"
    movement_speed = 300.0

    # Set default patrol route from Constants
    var route = Constants.NPC_PATROL_ROUTES["MOTHER"]
    patrol_points.assign(route)
    patrol_wait_time = 2.0
    auto_start_patrol = true

    add_to_group("mother")

    _voice_player = AudioStreamPlayer.new()
    _voice_player.bus = Constants.AUDIO_BUSES.SFX
    _voice_player.finished.connect(_on_voice_finished)
    add_child(_voice_player)

    _speech_bubble = SpeechBubble.new()
    _speech_bubble.position = Vector2(0, -375)
    add_child(_speech_bubble)

    super._ready()
    _filler_loop()


func _on_voice_finished() -> void:
    _hide_token += 1
    var token := _hide_token
    await get_tree().create_timer(5.0).timeout
    if token == _hide_token:
        _speech_bubble.hide_bubble()


## Play a single voice line by code and optional display text.
func play_voice_line(code: String, text: String = "") -> void:
    if _voice_player.playing:
        return
    var stream: AudioStream = load(Constants.get_voice_audio_path("Mum", code))
    if not stream:
        push_error("[Mother] Failed to load voice line: %s" % code)
        return
    _voice_player.stream = stream
    _voice_player.play()
    if not text.is_empty():
        _speech_bubble.show_text(text)


func _filler_loop() -> void:
    while is_inside_tree():
        await get_tree().create_timer(randf_range(20.0, 40.0)).timeout
        if not _voice_player.playing:
            var fillers: Array = Constants.get_voice_lines("Mum", "Filler")
            if not fillers.is_empty():
                var line: Dictionary = fillers[randi() % fillers.size()]
                play_voice_line(line["code"], line["text"])


## Play all day-specific lines for a given day number, in order.
func speak_day_lines(day: int) -> void:
    var lines: Array = Constants.get_voice_lines("Mum", "Day %d" % day)
    for line_data: Dictionary in lines:
        if _voice_player.playing:
            await _voice_player.finished
        play_voice_line(line_data["code"], line_data["text"])
        await _voice_player.finished


# ============================================================================
# BEHAVIOR
# ============================================================================

var _resetting_glass: bool = false


func on_cat_touched(cat: Node2D) -> void:
    super.on_cat_touched(cat)

    # TODO: In future, mother could carry cat back to starting box


func react_to_event(event_name: String) -> void:
    print("[%s] Reacting to event: %s" % [character_name, event_name])
    if event_name == "glass_knocked_down":
        var glass: Node2D = get_tree().get_first_node_in_group("glass")
        if glass:
            _resetting_glass = true
            navigate_to_position(glass.global_position, current_floor)
        else:
            push_error("[Mother] Could not find glass node to navigate to")


func on_destination_reached() -> void:
    if _resetting_glass:
        _resetting_glass = false
        EventBus.glass_reset.emit()

    super.on_destination_reached()
