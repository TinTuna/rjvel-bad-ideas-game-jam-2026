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
    patrol_wait_time = 2.0
    auto_start_patrol = false  # Level scripts call start_for_day(day) to configure

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
        await get_tree().create_timer(randf_range(10.0, 30.0)).timeout
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
var _playing_once_anim: bool = false
var _abandoned_patrol: bool = false
var _opening_window: bool = false
# Pizza delivery sequence: 0=inactive, 1=heading to door, 3=heading to table
var _pizza_step: int = 0


func update_animation() -> void:
    if _playing_once_anim:
        return
    super.update_animation()


func on_cat_touched(cat: Node2D) -> void:
    super.on_cat_touched(cat)

    # TODO: In future, mother could carry cat back to starting box


func react_to_event(event_name: String) -> void:
    print("[%s] Reacting to event: %s" % [character_name, event_name])
    if event_name == "glass_knocked_down":
        var glass: Node2D = get_tree().get_first_node_in_group("glass")
        if glass:
            _resetting_glass = true
            var approach_x = glass.global_position.x + sign(global_position.x - glass.global_position.x) * 200.0
            navigate_to_position(Vector2(approach_x, global_position.y), current_floor)
        else:
            push_error("[Mother] Could not find glass node to navigate to")

    elif event_name == "toaster_burnt":
        # Day 2: Mom plays a voice line then heads to the kitchen to open the window
        _abandoned_patrol = true
        _opening_window = true
        stop_navigation()
        play_voice_line("M_2_0", "*Cough* Let's let the room air out, I can't breathe in here!")
        navigate_to_point("Kitchen_Window")

    elif event_name == "pizza_delivered":
        # Day 3: Mom answers the door, comes back, drops pizza on table, resumes patrol
        _pizza_step = 1
        stop_navigation()
        navigate_to_point("Entry")


func _handle_pizza_at_entry() -> void:
    # Wait at the door for 4 seconds (simulating going outside and back)
    _pizza_step = 2
    current_state = State.IDLE
    await get_tree().create_timer(4.0).timeout
    _pizza_step = 3
    navigate_to_point("Living_Room")


func on_destination_reached() -> void:
    if _resetting_glass:
        _resetting_glass = false
        _playing_once_anim = true
        animated_sprite.play("interacting")
        EventBus.glass_reset.emit()
        await animated_sprite.animation_finished
        _playing_once_anim = false
        super.on_destination_reached()
        return

    if _opening_window:
        _opening_window = false
        _playing_once_anim = true
        animated_sprite.play("interacting")
        await animated_sprite.animation_finished
        _playing_once_anim = false
        EventBus.window_open.emit()
        navigate_to_point("Mums_Bedroom")
        return

    if _pizza_step == 1:
        _handle_pizza_at_entry()
        return

    if _pizza_step == 3:
        # At the table — drop the pizza
        _pizza_step = 4
        _playing_once_anim = true
        animated_sprite.play("interacting")
        await animated_sprite.animation_finished
        _playing_once_anim = false
        _pizza_step = 0
        # Resume patrol
        if patrol_points.size() > 0:
            patrol_index = 0
            start_patrol()
        return

    if _abandoned_patrol:
        # Stay in Mum's room, don't resume patrol
        current_state = State.IDLE
        return

    super.on_destination_reached()
