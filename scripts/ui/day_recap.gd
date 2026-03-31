extends Control
## DayRecap - Intermediate scene shown between levels
##
## Displays an image and text based on which day was just completed.
## Any key press advances to the next level, or the outro if no further levels exist.
##
## Day index is derived from StatsTracker.days_completed.
## To add images: populate the "image" field in DAY_RECAPS with a res:// path.

const DAY_RECAPS: Array[Dictionary] = [
    {
        "text": "Monday done.",
        "image": "uid://bawa68foy7u6b",
    },
    {
        "text": "Tuesday complete.",
        "image": "uid://bawa68foy7u6b",
    },
    {
        "text": "Halfway through the week.",
        "image": "uid://bawa68foy7u6b",
    },
    {
        "text": "Thursday.",
        "image": "uid://bawa68foy7u6b",
    },
    {
        "text": "Friday.",
        "image": "uid://bawa68foy7u6b",
    },
    {
        "text": "Saturday.",
        "image": "uid://bawa68foy7u6b",
    },
]

@onready var slide_label: Label = $SlideText
@onready var day_image: TextureRect = $DayImage
@onready var hint_label: Label = $HintLabel


func _ready() -> void:
    var day_index: int = StatsTracker.get_stat("days_completed") - 1
    day_index = clamp(day_index, 0, DAY_RECAPS.size() - 1)

    var recap: Dictionary = DAY_RECAPS[day_index]
    slide_label.text = recap["text"]
    hint_label.text = "Press any key to continue"

    if not recap["image"].is_empty():
        day_image.texture = load(recap["image"])
    else:
        day_image.hide()


func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        get_viewport().set_input_as_handled()
        SceneLoader.load_scene(_get_next_scene())


func _get_next_scene() -> String:
    var days_done: int = StatsTracker.get_stat("days_completed")
    var next_level_key: String = "LEVEL_%d" % days_done
    if Constants.has_scene(next_level_key):
        return Constants.SCENES[next_level_key]
    if Constants.has_scene("OUTRO"):
        return Constants.SCENES["OUTRO"]
    return Constants.SCENES["MAIN_MENU"]
