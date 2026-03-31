extends Node2D
## Level 1 — Full House (Ground Floor + First Floor)
##
## Ground floor: Kitchen, Living Room, Entry.
## First floor: Mum's Bedroom (left), Upstairs Corridor/Landing (centre), Boys' Room (right).

@onready var nav_graph: NavigationGraph = $NavigationGraph
@onready var level_end_trigger: Area2D = $LevelEndTrigger2
@onready var cat_flap_trigger: Area2D = $CatFlapTrigger

func _ready() -> void:
    Constants.current_day = 1
    level_end_trigger.body_entered.connect(_on_level_end_triggered)
    cat_flap_trigger.area_entered.connect(_on_cat_flap_triggered)

    await get_tree().process_frame
    nav_graph.print_graph_info()

    var mother: FamilyMemberBase = get_tree().get_first_node_in_group("mother")
    if mother:
        mother.start_for_day(1)
    else:
        push_error("[Level1] Mother NPC not found")

    var daughter: FamilyMemberBase = get_tree().get_first_node_in_group("daughter")
    if daughter:
        daughter.start_for_day(2)
    else:
        push_warning("[Level2] Daughter NPC not found — add daughter.tscn to this level")


func _on_cat_flap_triggered(area: Area2D) -> void:
    if area.is_in_group("key"):
        $House.front_door_state = 1  # CATFLAP_OPEN
        EventBus.player_put_down_item.emit(area)
        area.queue_free()


func _on_level_end_triggered(body: Node2D) -> void:
    if body.is_in_group("cat") and $House.front_door_state == 1:
        EventBus.day_started.emit(2)
        SceneLoader.load_scene(Constants.SCENES["DAY_RECAP"])
