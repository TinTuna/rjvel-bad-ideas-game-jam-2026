extends Node2D
## Level 0 — Ground Floor
##
## Three rooms left to right: Kitchen, Living Room, Entry.
## This is the first playable level (tutorial day).

@onready var nav_graph: NavigationGraph = $NavigationGraph

func _ready() -> void:
	await get_tree().process_frame
	nav_graph.print_graph_info()
