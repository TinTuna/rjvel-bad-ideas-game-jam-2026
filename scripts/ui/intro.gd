extends Control
## Intro - Slideshow intro sequence
##
## Displays a series of text slides on a black background.
## Any key press advances to the next slide.
## After the final slide, loads the first level.

const SLIDES: Array[String] = [
	"Intro",
]

var _current_slide: int = 0

@onready var slide_label: Label = $SlideText
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
	slide_label.text = SLIDES[index]
	var is_last := index == SLIDES.size() - 1
	hint_label.text = "Press any key to begin" if is_last else "Press any key to continue"
