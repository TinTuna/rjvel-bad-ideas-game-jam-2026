extends Node2D
## Level 0 — Ground Floor
##
## Three rooms left to right: Kitchen, Living Room, Entry.
## This is the first playable level (tutorial day).

@onready var nav_graph: NavigationGraph = $NavigationGraph
@onready var level_end_trigger: Area2D = $LevelEndTrigger

func _ready() -> void:
    Constants.current_day = 0
    level_end_trigger.body_entered.connect(_on_level_end_triggered)

    await get_tree().process_frame
    nav_graph.print_graph_info()

    var mother: FamilyMemberBase = get_tree().get_first_node_in_group("mother")
    if mother:
        mother.start_for_day(0)
        EventBus.glass_knocked_down.connect(mother.react_to_event.bind("glass_knocked_down"))
        mother.speak_day_lines(0)
    else:
        push_error("[Level0] Mother NPC not found")


func _on_level_end_triggered(body: Node2D) -> void:
    if body.is_in_group("cat"):
        EventBus.day_started.emit(1)
        SceneLoader.load_scene(Constants.SCENES["DAY_RECAP"])
