extends Node2D
## Level 1 — Full House (Ground Floor + First Floor)
##
## Ground floor: Kitchen, Living Room, Entry.
## First floor: Mum's Bedroom (left), Upstairs Corridor/Landing (centre), Boys' Room (right).

@onready var nav_graph: NavigationGraph = $NavigationGraph
@onready var level_end_trigger: Area2D = $LevelEndTrigger

func _ready() -> void:
    level_end_trigger.area_entered.connect(_on_level_end_triggered)
    
    await get_tree().process_frame
    nav_graph.print_graph_info()

    var mother: FamilyMemberBase = get_tree().get_first_node_in_group("mother")
    if mother:
        EventBus.glass_knocked_down.connect(mother.react_to_event.bind("glass_knocked_down"))
    else:
        push_error("[Level1] Mother NPC not found — glass_knocked_down signal not connected")
    
    Constants.current_day = 1


func _on_level_end_triggered(body: Node2D) -> void:
    if body.is_in_group("key"):
        EventBus.day_started.emit(2)
        SceneLoader.load_scene(Constants.SCENES["DAY_RECAP"])
