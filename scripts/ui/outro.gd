extends Control
## Outro - End-of-game slideshow with stats display
##
## Displays closing slides, then shows all game stats from StatsTracker.
## On final interaction, resets stats and returns to the main menu.

const SLIDES: Array[String] = [
    "res://assets/sprites/outro_sequence/outro scene 1_1.png",
    "res://assets/sprites/outro_sequence/outro scene 1_2.png",
    "res://assets/sprites/outro_sequence/outro scene 1_3.png",
    "res://assets/sprites/outro_sequence/outro scene 2_1.png",
]

var _current_slide: int = 0
var _showing_stats: bool = false

@onready var slide_image: TextureRect = $SlideImage
@onready var slide_label: Label = $SlideText
@onready var hint_label: Label = $HintLabel


func _ready() -> void:
    slide_label.hide()
    _show_slide(0)


func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        get_viewport().set_input_as_handled()
        _advance()


func _advance() -> void:
    if _showing_stats:
        StatsTracker.reset()
        SceneLoader.load_scene(Constants.SCENES["MAIN_MENU"])
        return

    _current_slide += 1
    if _current_slide >= SLIDES.size():
        _show_stats()
    else:
        _show_slide(_current_slide)


func _show_slide(index: int) -> void:
    slide_image.texture = load(SLIDES[index])
    hint_label.text = "Press any key to continue"


func _show_stats() -> void:
    _showing_stats = true
    slide_image.hide()
    slide_label.show()
    hint_label.text = "Press any key to return to menu"

    var stats_text := "Your Legacy\n\n"
    for stat: Dictionary in StatsTracker.get_all():
        stats_text += "%s: %d\n" % [stat["label"], stat["value"]]

    slide_label.text = stats_text
