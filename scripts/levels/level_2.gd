extends Node2D

var _is_window_opened: bool = false
@onready var level_end_trigger: Area2D = $LevelEndTrigger

func _ready() -> void:
    Constants.current_day = 2
    EventBus.window_open.connect(window_opened)
    level_end_trigger.body_entered.connect(_on_level_end_triggered)

    await get_tree().process_frame

    var mother: FamilyMemberBase = get_tree().get_first_node_in_group("mother")
    if mother:
        mother.start_for_day(2)
        EventBus.toaster_burnt.connect(mother.react_to_event.bind("toaster_burnt"))
    else:
        push_error("[Level2] Mother NPC not found")

    var daughter: FamilyMemberBase = get_tree().get_first_node_in_group("daughter")
    if daughter:
        daughter.start_for_day(2)
    else:
        push_warning("[Level2] Daughter NPC not found — add daughter.tscn to this level")


func window_opened() -> void:
    _is_window_opened = true


func _on_level_end_triggered(body: Node2D) -> void:
    if _is_window_opened and body.is_in_group("cat"):
        EventBus.day_started.emit(3)
        SceneLoader.load_scene(Constants.SCENES["DAY_RECAP"])
