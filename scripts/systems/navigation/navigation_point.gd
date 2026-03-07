extends Node2D
class_name NavigationPoint

## Type of navigation point
enum PointType {
	DEFAULT,              ## Regular navigation point
	INTERACTABLE_SITTING, ## Point where NPC can sit
	INTERACTABLE_STANDING,## Point where NPC can stand and interact
	STAIRS                ## Point for vertical floor transitions
}

## Type of this navigation point
@export var point_type: PointType = PointType.DEFAULT

## Connected navigation points (NodePaths to other NavigationPoint nodes)
## Min 1 for dead end, max 3 for complex intersections
@export var connections: Array[NodePath] = []

## Visual debug color in editor
@export var debug_color: Color = Color.YELLOW

## Visual debug radius
@export var debug_radius: float = 8.0

## Unique ID assigned by NavigationGraph
var point_id: int = -1

func _ready() -> void:
	# Ensure this point is visible in editor for debugging
	set_notify_transform(true)

func _draw() -> void:
	var should_draw := Engine.is_editor_hint()
	if not should_draw and get_parent() and "debug_mode" in get_parent():
		should_draw = get_parent().debug_mode
	
	if should_draw:
		# Draw point circle
		draw_circle(Vector2.ZERO, debug_radius, debug_color)
		
		# Draw type indicator
		var type_text := ""
		match point_type:
			PointType.DEFAULT:
				type_text = "D"
			PointType.INTERACTABLE_SITTING:
				type_text = "S"
			PointType.INTERACTABLE_STANDING:
				type_text = "I"
			PointType.STAIRS:
				type_text = "^"
		
		# Draw letter in center
		var font := ThemeDB.fallback_font
		var font_size := 12
		var text_size := font.get_string_size(type_text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
		draw_string(font, Vector2(-text_size.x / 2, font_size / 2), type_text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color.BLACK)

func get_connection_count() -> int:
	return connections.size()

func get_connected_points() -> Array[NavigationPoint]:
	var result: Array[NavigationPoint] = []
	for path in connections:
		var node := get_node_or_null(path)
		if node and node is NavigationPoint:
			result.append(node)
	return result

func is_stairs() -> bool:
	return point_type == PointType.STAIRS
