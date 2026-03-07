extends Node2D

@onready var treat: Node2D = $Treat
@onready var nav_graph: NavigationGraph = $NavigationGraph

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    # Wait for navigation graph to build from children
    await get_tree().process_frame
    
    # Print navigation graph info
    nav_graph.print_graph_info()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if Input.is_action_just_pressed("interact") and treat.has_overlapping_bodies():
        treat.interact()
