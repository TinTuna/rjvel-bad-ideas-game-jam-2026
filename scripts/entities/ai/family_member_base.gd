class_name FamilyMemberBase
extends CharacterBody2D
## Base class for all family member NPCs with navigation

const SFX_HUMAN_WALKING = preload("uid://bx1plfvq4j6ic")

# ============================================================================
# EXPORTS
# ============================================================================

@export var movement_speed: float = 80.0
@export var character_name: String = "Family Member"
@export var starting_floor: int = 0

@export_group("Patrol")
@export var patrol_points: Array[String] = []  # Array of point names to patrol
@export var patrol_wait_time: float = 2.0  # Time to wait at each point
@export var auto_start_patrol: bool = true

@export_group("Debug")
@export var debug_draw: bool = false

# ============================================================================
# NODES
# ============================================================================

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _interaction_area: Area2D = $Area2D

# var _walk_player: AudioStreamPlayer
var _was_walking: bool = false

# ============================================================================
# STATE
# ============================================================================

enum State {
    IDLE,
    MOVING_TO_TARGET,
    WAITING,
    INTERACTING_SITTING,
    INTERACTING_STANDING
}

var current_state: State = State.IDLE
var current_floor: int = 0

# Navigation
var navigation_graph: NavigationGraph
var current_path: Array[Dictionary] = []
var current_path_index: int = 0
var target_waypoint: Dictionary = {}

# Patrol
var patrol_index: int = 0
var wait_timer: float = 0.0

# ============================================================================
# LIFECYCLE
# ============================================================================

func _ready() -> void:
    add_to_group("family_members")
    current_floor = starting_floor

    # _walk_player = AudioStreamPlayer.new()
    # _walk_player.stream = SFX_HUMAN_WALKING
    # _walk_player.bus = Constants.AUDIO_BUSES.SFX
    # _walk_player.finished.connect(func():
    #     if _was_walking:
    #         _walk_player.play()
    # )
    # add_child(_walk_player)

    # Wire Area2D to detect the cat
    var area: Area2D = $Area2D
    area.collision_mask = 1
    area.body_entered.connect(_on_area_body_entered)

    # Find navigation graph
    await get_tree().process_frame  # Wait for graph to initialize
    navigation_graph = get_tree().get_first_node_in_group("navigation_graph")

    if not navigation_graph:
        push_error("[%s] No NavigationGraph found!" % character_name)
        return

    print("[%s] Initialized on floor %d" % [character_name, current_floor])

    # Start patrol if enabled
    if auto_start_patrol and patrol_points.size() > 0:
        call_deferred("start_patrol")


func _physics_process(delta: float) -> void:
    match current_state:
        State.IDLE:
            velocity = Vector2.ZERO
        
        State.MOVING_TO_TARGET:
            process_movement(delta)
        
        State.WAITING:
            velocity = Vector2.ZERO
            wait_timer -= delta
            if wait_timer <= 0:
                continue_patrol()
    
    move_and_slide()
    update_animation()
    
    if debug_draw:
        queue_redraw()


func _draw() -> void:
    if not debug_draw or not OS.is_debug_build():
        return
    
    # Draw current path
    if current_path.size() > 0:
        for i in range(current_path_index, current_path.size()):
            var waypoint = current_path[i]
            var local_pos = to_local(waypoint.position)
            
            # Draw waypoint
            draw_circle(local_pos, 6, Color.GREEN)
            
            # Draw connection to next
            if i < current_path.size() - 1:
                var next_waypoint = current_path[i + 1]
                var next_local = to_local(next_waypoint.position)
                draw_line(local_pos, next_local, Color.GREEN, 1.0)
    
    # Draw current target
    if not target_waypoint.is_empty():
        var target_local = to_local(target_waypoint.position)
        draw_circle(target_local, 8, Color.RED)
        draw_line(Vector2.ZERO, target_local, Color.RED, 1.0, true)


# ============================================================================
# NAVIGATION API
# ============================================================================

## Navigate to a named point in the navigation graph
func navigate_to_point(point_name: String) -> void:
    if not navigation_graph:
        push_error("[%s] No navigation graph available" % character_name)
        return
    
    if not navigation_graph.has_point(point_name):
        push_error("[%s] Point '%s' does not exist" % [character_name, point_name])
        return
    
    var target_pos = navigation_graph.get_point_position(point_name)
    var target_floor = navigation_graph.get_point_floor(point_name)
    
    navigate_to_position(target_pos, target_floor)


## Navigate to a specific position
func navigate_to_position(target_pos: Vector2, target_floor: int) -> void:
    if target_floor == current_floor and global_position.distance_to(target_pos) <= 5.0:
        return

    current_path = navigation_graph.find_path(
        global_position, current_floor,
        target_pos, target_floor
    )

    if current_path.is_empty():
        print("[%s] No path found to target" % character_name)
        current_state = State.IDLE
        return

    current_path_index = 0
    target_waypoint = current_path[0]
    current_state = State.MOVING_TO_TARGET
    
    print("[%s] Starting navigation with %d waypoints" % [character_name, current_path.size()])


## Stop current navigation
func stop_navigation() -> void:
    current_state = State.IDLE
    current_path.clear()
    current_path_index = 0
    target_waypoint = {}
    velocity = Vector2.ZERO


# ============================================================================
# MOVEMENT PROCESSING
# ============================================================================

func process_movement(delta: float) -> void:
    if current_path.is_empty() or current_path_index >= current_path.size():
        arrive_at_destination()
        return
    
    target_waypoint = current_path[current_path_index]
    var target_pos = target_waypoint.position
    
    # Calculate direction
    var direction = (target_pos - global_position).normalized()
    var distance = global_position.distance_to(target_pos)
    
    # Move towards target
    if distance > 5.0:
        velocity = direction * movement_speed
    else:
        # Reached waypoint
        _on_waypoint_reached(current_path[current_path_index], current_path_index)
        current_path_index += 1

        if current_path_index >= current_path.size():
            arrive_at_destination()
        else:
            # Continue to next waypoint
            target_waypoint = current_path[current_path_index]


func arrive_at_destination() -> void:
    current_state = State.IDLE
    velocity = Vector2.ZERO
    current_path.clear()
    target_waypoint = {}
    
    print("[%s] Arrived at destination" % character_name)
    
    on_destination_reached()


func _on_waypoint_reached(waypoint: Dictionary, waypoint_index: int) -> void:
    var wname: String = waypoint["name"]
    var has_next: bool = waypoint_index + 1 < current_path.size()
    var next_name: String = current_path[waypoint_index + 1]["name"] if has_next else ""

    var new_z: int = z_index
    var on_stairs: bool
    if wname == "Landing" and next_name == "Stairs_top":
        new_z = 0  # Leaving landing, starting descent
        on_stairs = true
    elif wname == "Entry" and next_name == "Stairs_bottom":
        new_z = 1  # Leaving entry, starting ascent
        on_stairs = true
    elif wname == "Stairs_bottom" and next_name == "Entry":
        new_z = 3  # Finished descending, back on ground floor
        on_stairs = false
    elif wname == "Stairs_top" and next_name == "Landing":
        new_z = 3  # Finished ascending, back on landing
        on_stairs = false
    else:
        return

    _interaction_area.monitoring = not on_stairs
    _interaction_area.monitorable = not on_stairs
    print("[%s] Reached '%s' → next '%s' → z_index %d -> %d | collision %s" % [
        character_name, wname, next_name, z_index, new_z, "OFF" if on_stairs else "ON"
    ])
    z_index = new_z


## Override in subclasses to react to level-specific events
func react_to_event(_event_name: String) -> void:
    pass


## Override this in subclasses for custom behavior
func on_destination_reached() -> void:
    # If patrolling, wait then continue
    if patrol_points.size() > 0:
        current_state = State.WAITING
        wait_timer = patrol_wait_time


# ============================================================================
# PATROL SYSTEM
# ============================================================================

func start_patrol() -> void:
    if patrol_points.is_empty():
        push_warning("[%s] No patrol points defined" % character_name)
        return
    
    patrol_index = 0
    navigate_to_next_patrol_point()
    print("[%s] Started patrol with %d points" % [character_name, patrol_points.size()])


func navigate_to_next_patrol_point() -> void:
    if patrol_points.is_empty():
        return
    
    var point_name = patrol_points[patrol_index]
    navigate_to_point(point_name)


func continue_patrol() -> void:
    patrol_index = (patrol_index + 1) % patrol_points.size()
    navigate_to_next_patrol_point()


## Configure patrol route for a specific day and immediately start patrolling.
## Looks up Constants.NPC_PATROL_ROUTES using the NPC's character_name (uppercased).
func start_for_day(day: int) -> void:
    var route: Array = Constants.get_patrol_route(character_name.to_upper(), day)
    if route.is_empty():
        push_warning("[%s] No patrol route defined for day %d" % [character_name, day])
        return
    patrol_points.assign(route)
    patrol_index = 0
    start_patrol()


# ============================================================================
# INTERACTION
# ============================================================================

func _on_area_body_entered(body: Node2D) -> void:
    if body.is_in_group("cat"):
        on_cat_touched(body)


func on_cat_touched(cat: Node2D) -> void:
    print("Cat touched!")
    cat.push_back(global_position)


# ============================================================================
# ANIMATION
# ============================================================================

func update_animation() -> void:
    if not animated_sprite:
        return

    var is_walking := current_state == State.MOVING_TO_TARGET
    # if is_walking and not _was_walking:
    #     _walk_player.play()
    # elif not is_walking and _was_walking:
    #     _walk_player.stop()
    _was_walking = is_walking

    match current_state:
        State.IDLE:
            animated_sprite.play("standing")

        State.MOVING_TO_TARGET:
            animated_sprite.play("walking")
            # Flip sprite based on horizontal movement direction
            if velocity.x != 0:
                animated_sprite.flip_h = velocity.x > 0

        State.WAITING:
            animated_sprite.play("standing")

        State.INTERACTING_SITTING:
            animated_sprite.play("sitting")

        State.INTERACTING_STANDING:
            animated_sprite.play("interacting")


# ============================================================================
# DEBUG
# ============================================================================

# func _input(event: InputEvent) -> void:
#     if not OS.is_debug_build():
#         return
    
#     # Toggle debug draw with D key
#     if event is InputEventKey and event.pressed and event.keycode == KEY_G:
#         debug_draw = not debug_draw
#         queue_redraw()
#         print("[%s] Debug draw: %s" % [character_name, "ON" if debug_draw else "OFF"])
