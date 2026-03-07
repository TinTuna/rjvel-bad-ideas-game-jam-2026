class_name NavigationGraph
extends Node2D
## Navigation graph for NPC pathfinding using AStar2D
##
## Manages navigation points and connections for multi-floor movement

# ============================================================================
# EXPORTS
# ============================================================================

@export var debug_draw_enabled: bool = true
@export var debug_draw_color: Color = Color.YELLOW
@export var debug_point_radius: float = 8.0
@export var auto_build_from_children: bool = true  ## Auto-detect NavigationPoint children on _ready()

# ============================================================================
# STATE
# ============================================================================

var astar: AStar2D = AStar2D.new()
var point_positions: Dictionary = {}  # id -> Vector2 (global position)
var point_names: Dictionary = {}  # id -> String
var point_floors: Dictionary = {}  # id -> int (floor number)
var point_ids: Dictionary = {}  # name -> id (reverse lookup)
var point_nodes: Dictionary = {}  # id -> NavigationPoint node reference

var next_id: int = 0
var debug_mode: bool = true  ## Exposed to NavigationPoint for drawing

# ============================================================================
# LIFECYCLE
# ============================================================================

func _ready() -> void:
    add_to_group("navigation_graph")
    debug_mode = debug_draw_enabled
    
    if auto_build_from_children:
        build_from_children()
    
    print("[NavigationGraph] Initialized with %d points" % astar.get_point_count())


func _draw() -> void:
    if not debug_draw_enabled or not OS.is_debug_build():
        return
    
    # Draw connections
    for point_id in astar.get_point_ids():
        var from_pos = to_local(point_positions[point_id])
        
        for connection_id in astar.get_point_connections(point_id):
            if connection_id > point_id:  # Avoid drawing twice
                var to_pos = to_local(point_positions[connection_id])
                draw_line(from_pos, to_pos, debug_draw_color, 2.0)
    
    # Draw points
    for point_id in astar.get_point_ids():
        var pos = to_local(point_positions[point_id])
        draw_circle(pos, debug_point_radius, debug_draw_color)
        
        # Draw point name
        if point_names.has(point_id):
            var font = ThemeDB.fallback_font
            var font_size = ThemeDB.fallback_font_size
            draw_string(font, pos + Vector2(12, -12), point_names[point_id], HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.WHITE)


# ============================================================================
# PUBLIC API - ADD POINTS
# ============================================================================

## Add a navigation point to the graph
func add_navigation_point(point_name: String, position: Vector2, floor: int = 0) -> int:
    var id = next_id
    next_id += 1
    
    # Store point data
    astar.add_point(id, position)
    point_positions[id] = position
    point_names[id] = point_name
    point_floors[id] = floor
    point_ids[point_name] = id
    
    queue_redraw()
    
    print("[NavigationGraph] Added point '%s' (ID: %d) at %v on floor %d" % [point_name, id, position, floor])
    return id


## Remove a navigation point
func remove_navigation_point(point_name: String) -> void:
    if not point_ids.has(point_name):
        push_warning("[NavigationGraph] Point '%s' does not exist" % point_name)
        return
    
    var id = point_ids[point_name]
    
    astar.remove_point(id)
    point_positions.erase(id)
    point_names.erase(id)
    point_floors.erase(id)
    point_ids.erase(point_name)
    
    queue_redraw()


# ============================================================================
# PUBLIC API - CONNECT POINTS
# ============================================================================

## Connect two navigation points (bidirectional by default)
func connect_points_by_name(from_name: String, to_name: String, bidirectional: bool = true) -> void:
    if not point_ids.has(from_name):
        push_error("[NavigationGraph] Point '%s' does not exist" % from_name)
        return
    
    if not point_ids.has(to_name):
        push_error("[NavigationGraph] Point '%s' does not exist" % to_name)
        return
    
    var from_id = point_ids[from_name]
    var to_id = point_ids[to_name]
    
    astar.connect_points(from_id, to_id, bidirectional)
    queue_redraw()
    
    print("[NavigationGraph] Connected '%s' <-> '%s'" % [from_name, to_name])


## Connect two points by ID
func connect_points_by_id(from_id: int, to_id: int, bidirectional: bool = true) -> void:
    astar.connect_points(from_id, to_id, bidirectional)
    queue_redraw()


# ============================================================================
# PUBLIC API - PATHFINDING
# ============================================================================

## Find path from one position to another
func find_path(from_pos: Vector2, from_floor: int, to_pos: Vector2, to_floor: int) -> Array[Dictionary]:
    var from_id = find_nearest_point_id(from_pos, from_floor)
    var to_id = find_nearest_point_id(to_pos, to_floor)
    
    if from_id == -1 or to_id == -1:
        push_warning("[NavigationGraph] Could not find navigation points near positions")
        return []
    
    return find_path_by_ids(from_id, to_id)


## Find path between two named points
func find_path_by_names(from_name: String, to_name: String) -> Array[Dictionary]:
    if not point_ids.has(from_name) or not point_ids.has(to_name):
        push_warning("[NavigationGraph] Point name not found")
        return []
    
    return find_path_by_ids(point_ids[from_name], point_ids[to_name])


## Find path between two point IDs
func find_path_by_ids(from_id: int, to_id: int) -> Array[Dictionary]:
    var path_ids = astar.get_id_path(from_id, to_id)
    
    var path: Array[Dictionary] = []
    for id in path_ids:
        path.append({
            "id": id,
            "position": point_positions[id],
            "floor": point_floors[id],
            "name": point_names[id]
        })
    
    return path


# ============================================================================
# PUBLIC API - QUERIES
# ============================================================================

## Find the nearest navigation point to a position on a specific floor
func find_nearest_point_id(position: Vector2, floor: int) -> int:
    var nearest_id: int = -1
    var nearest_distance: float = INF
    
    for id in astar.get_point_ids():
        if point_floors[id] != floor:
            continue
        
        var point_pos = point_positions[id]
        var distance = position.distance_to(point_pos)
        
        if distance < nearest_distance:
            nearest_distance = distance
            nearest_id = id
    
    return nearest_id


## Get point position by name
func get_point_position(point_name: String) -> Vector2:
    if point_ids.has(point_name):
        return point_positions[point_ids[point_name]]
    return Vector2.ZERO


## Get point floor by name
func get_point_floor(point_name: String) -> int:
    if point_ids.has(point_name):
        return point_floors[point_ids[point_name]]
    return 0


## Check if point exists
func has_point(point_name: String) -> bool:
    return point_ids.has(point_name)


# ============================================================================
# DEBUG
# ============================================================================

func print_graph_info() -> void:
    print("=== Navigation Graph Info ===")
    print("Total points: %d" % astar.get_point_count())
    for id in astar.get_point_ids():
        var connections = astar.get_point_connections(id)
        print("  %s (ID: %d, Floor: %d) -> %d connections" % 
            [point_names[id], id, point_floors[id], connections.size()])
    print("============================")


# ============================================================================
# AUTO-BUILD FROM CHILDREN
# ============================================================================

## Build navigation graph from NavigationPoint children
func build_from_children() -> void:
    print("[NavigationGraph] Building graph from NavigationPoint children...")
    
    # Step 1: Find all NavigationPoint children and assign IDs
    var nav_points: Array[NavigationPoint] = []
    for child in get_children():
        if child is NavigationPoint:
            nav_points.append(child)
    
    if nav_points.is_empty():
        print("[NavigationGraph] No NavigationPoint children found")
        return
    
    # Step 2: Add each point to AStar graph
    for point in nav_points:
        var id = next_id
        next_id += 1
        
        # Assign ID to the point
        point.point_id = id
        
        # Store point data
        var global_pos = point.global_position
        astar.add_point(id, global_pos)
        point_positions[id] = global_pos
        point_names[id] = point.name
        point_floors[id] = 0  # TODO: Add floor detection later
        point_ids[point.name] = id
        point_nodes[id] = point
        
        print("[NavigationGraph]   Added '%s' (ID: %d) at %v" % [point.name, id, global_pos])
    
    # Step 3: Build connections based on NodePath references
    for point in nav_points:
        var from_id = point.point_id
        
        for connection_path in point.connections:
            var connected_node = point.get_node_or_null(connection_path)
            
            if not connected_node:
                push_warning("[NavigationGraph] Point '%s': connection path '%s' not found" % [point.name, connection_path])
                continue
            
            if not connected_node is NavigationPoint:
                push_warning("[NavigationGraph] Point '%s': connection '%s' is not a NavigationPoint" % [point.name, connection_path])
                continue
            
            var to_id = connected_node.point_id
            
            # Connect bidirectionally
            if not astar.are_points_connected(from_id, to_id):
                astar.connect_points(from_id, to_id, true)
                print("[NavigationGraph]   Connected '%s' <-> '%s'" % [point.name, connected_node.name])
    
    queue_redraw()
    print("[NavigationGraph] Graph build complete!")
