extends Node2D

@onready var nav_graph: NavigationGraph = $NavigationGraph
@onready var glass: Area2D = $Glass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    # Wait for navigation graph to build from children
    await get_tree().process_frame
    
    # Print navigation graph info
    # nav_graph.print_graph_info()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    if Input.is_action_just_pressed("interact") and glass.has_overlapping_bodies():
        glass.interact()
