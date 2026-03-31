extends FamilyMemberBase
## Twins NPC
##
## Day 1: Static in Living Room (playing).
## Day 3: Static in Boys' Room (playing).
## Day 4: Static in Boys' Room on the ladder. If the cat enters with a pizza box,
##         triggers a voice line and the twins move to their feast spot to eat.

const SpeechBubble = preload("res://scripts/ui/speech_bubble.gd")

## Nav point the twins walk to when triggered by a pizza delivery on Day 4.
@export var feast_nav_point: String = "Boys_Room"

var _voice_player: AudioStreamPlayer
var _speech_bubble: Node2D

var _cat_has_pizza: bool = false
var _pizza_item: Node2D = null
var _feast_triggered: bool = false


func _ready() -> void:
    character_name = "Twins"
    movement_speed = 280.0
    patrol_wait_time = 1.5
    auto_start_patrol = false  # Level scripts call start_for_day(day)

    add_to_group("twins")

    _voice_player = AudioStreamPlayer.new()
    _voice_player.bus = Constants.AUDIO_BUSES.SFX
    _voice_player.finished.connect(_on_voice_finished)
    add_child(_voice_player)

    _speech_bubble = SpeechBubble.new()
    _speech_bubble.position = Vector2(0, -375)
    add_child(_speech_bubble)

    EventBus.player_picked_up_item.connect(_on_player_picked_up_item)
    EventBus.player_put_down_item.connect(_on_player_put_down_item)

    super._ready()


func _on_voice_finished() -> void:
    await get_tree().create_timer(5.0).timeout
    _speech_bubble.hide_bubble()


func play_voice_line(code: String, text: String = "") -> void:
    if _voice_player.playing:
        return
    var stream: AudioStream = load(Constants.get_voice_audio_path("Twins", code))
    if not stream:
        push_error("[Twins] Failed to load voice line: %s" % code)
        return
    _voice_player.stream = stream
    _voice_player.play()
    if not text.is_empty():
        _speech_bubble.show_text(text)


func _on_player_picked_up_item(item: Node2D) -> void:
    if item.is_in_group("pizza"):
        _cat_has_pizza = true
        _pizza_item = item


func _on_player_put_down_item(item: Node2D) -> void:
    if item.is_in_group("pizza"):
        _cat_has_pizza = false
        _pizza_item = null


# ============================================================================
# DAY 4 — PIZZA FEAST REACTION
# ============================================================================

func on_cat_touched(cat: Node2D) -> void:
    if _feast_triggered:
        return  # Already reacted, don't push the cat away either
    if _cat_has_pizza:
        _trigger_pizza_feast()
        return
    super.on_cat_touched(cat)


func _trigger_pizza_feast() -> void:
    _feast_triggered = true

    # Play a voice line if one exists for this context
    var lines: Array = Constants.get_voice_lines("Twins", "Pizza")
    if not lines.is_empty():
        var line: Dictionary = lines[randi() % lines.size()]
        play_voice_line(line["code"], line["text"])

    # Move the pizza box to the feast destination
    if _pizza_item and navigation_graph and navigation_graph.has_point(feast_nav_point):
        var feast_pos: Vector2 = navigation_graph.get_point_position(feast_nav_point)
        _pizza_item.global_position = feast_pos

    # Walk to the feast spot
    navigate_to_point(feast_nav_point)
