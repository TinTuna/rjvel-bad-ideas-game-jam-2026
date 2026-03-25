extends FamilyMemberBase
## Mother NPC

# ============================================================================
# CONFIGURATION
# ============================================================================

func _ready() -> void:
    character_name = "Mother"
    movement_speed = 300.0

    # Set default patrol route from Constants
    var route = Constants.NPC_PATROL_ROUTES["MOTHER"]
    patrol_points.assign(route)
    patrol_wait_time = 2.0
    auto_start_patrol = true

    add_to_group("mother")
    super._ready()


# ============================================================================
# BEHAVIOR
# ============================================================================

var _resetting_glass: bool = false


func on_cat_touched(cat: Node2D) -> void:
    super.on_cat_touched(cat)

    # TODO: In future, mother could carry cat back to starting box


func react_to_event(event_name: String) -> void:
    print("[%s] Reacting to event: %s" % [character_name, event_name])
    if event_name == "glass_knocked_down":
        var glass: Node2D = get_tree().get_first_node_in_group("glass")
        if glass:
            _resetting_glass = true
            navigate_to_position(glass.global_position, current_floor)
        else:
            push_error("[Mother] Could not find glass node to navigate to")


func on_destination_reached() -> void:
    if _resetting_glass:
        _resetting_glass = false
        EventBus.glass_reset.emit()
    super.on_destination_reached()
