extends FamilyMemberBase
## Mother NPC - Anxious and overprotective
##
## The mother patrols the house and pets the cat when touched

# ============================================================================
# CONFIGURATION
# ============================================================================

func _ready() -> void:
    character_name = "Mother"
    movement_speed = 100.0  # Slower, cautious movement
    
    # Set default patrol route from Constants
    var route = Constants.NPC_PATROL_ROUTES["MOTHER"]
    patrol_points.assign(route)
    patrol_wait_time = 2.0
    auto_start_patrol = true
    
    super._ready()


# ============================================================================
# BEHAVIOR
# ============================================================================

func on_cat_touched(cat: Node2D) -> void:
    super.on_cat_touched(cat)
    
    # TODO: In future, mother could carry cat back to starting box
