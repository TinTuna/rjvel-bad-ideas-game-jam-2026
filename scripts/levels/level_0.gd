extends Node2D
## Level 0 — Ground Floor
##
## Three rooms left to right: Kitchen, Living Room, Entry.
## This is the first playable level (tutorial day).

@onready var nav_graph: NavigationGraph = $NavigationGraph

func _ready() -> void:
    await get_tree().process_frame
    nav_graph.print_graph_info()

    var mother: FamilyMemberBase = get_tree().get_first_node_in_group("mother")
    if mother:
        EventBus.glass_knocked_down.connect(mother.react_to_event.bind("glass_knocked_down"))
    else:
        push_error("[Level0] Mother NPC not found — glass_knocked_down signal not connected")
