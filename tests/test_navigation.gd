extends Node2D
## Test scene for NPC navigation system

@onready var nav_graph: NavigationGraph = $NavigationGraph
@onready var mother: FamilyMemberBase = $Mother

func _ready() -> void:
    print("=== Navigation Test Scene ===")
    
    # Navigation graph auto-builds from NavigationPoint children
    # Wait one frame for graph to be ready
    await get_tree().process_frame
    
    # Print graph info
    nav_graph.print_graph_info()
    
    # Setup mother's patrol
    setup_mother_patrol()
    

func setup_mother_patrol() -> void:
    # Set mother's patrol points
    mother.patrol_points = ["point_a", "point_b", "point_c"]
    mother.patrol_wait_time = 1.5
    mother.auto_start_patrol = true
