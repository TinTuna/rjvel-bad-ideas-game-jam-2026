extends Area2D
## Adjusts the z_index of cat / family-member characters as they pass through
## a stair boundary, so they draw behind or in front of the stair art correctly.
##
## Place one instance at the TOP of the stairs and one at the BOTTOM.
## Set the exports per-instance:
##
##   Stairs_top    → z_going_down = 0,  z_going_up = 3
##   Stairs_bottom → z_going_down = 3,  z_going_up = 1

## Z-index applied when a character enters this zone moving downward (velocity.y > 0).
@export var z_going_down: int = 0
## Z-index applied when a character enters this zone moving upward (velocity.y < 0).
@export var z_going_up: int = 5

## Minimum |velocity.y| to count as intentional vertical movement.
## Filters out the small positive value gravity gives while standing on a surface.
@export var velocity_threshold: float = 20.0


func _on_body_entered(body: Node2D) -> void:

	if not (body.is_in_group("cat") or body.is_in_group("family_members")):
		return

	if body.velocity.y > velocity_threshold:
		body.z_index = z_going_down
	elif body.velocity.y < -velocity_threshold:
		body.z_index = z_going_up
