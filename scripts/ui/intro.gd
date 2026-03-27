extends Control
## Intro - Slideshow intro sequence
##
## Displays a series of image panels with a subtle Ken Burns effect.
## Any key press advances to the next panel.
## After the final panel, loads the first level.

const SLIDES: Array[String] = [
    "res://assets/sprites/intro_sequence/All scenes/intro scene 1_1.png",
    "res://assets/sprites/intro_sequence/All scenes/intro scene 1_2.png",
    "res://assets/sprites/intro_sequence/All scenes/intro scene 2_1.png",
    "res://assets/sprites/intro_sequence/All scenes/intro scene 2_2.png",
    "res://assets/sprites/intro_sequence/All scenes/intro scene 3 1_1.png",
]

var _current_slide: int = 0

@onready var slide_image: TextureRect = $ImageContainer/SlideImage
@onready var hint_label: Label = $HintLabel


func _ready() -> void:
    _show_slide(0)


func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        get_viewport().set_input_as_handled()
        _advance()


func _advance() -> void:
    _current_slide += 1
    if _current_slide >= SLIDES.size():
        SceneLoader.load_scene(Constants.SCENES["LEVEL_0"])
    else:
        _show_slide(_current_slide)


func _show_slide(index: int) -> void:
    slide_image.texture = load(SLIDES[index])

    var is_last := index == SLIDES.size() - 1
    hint_label.text = "Press any key to begin" if is_last else "Press any key to continue"
