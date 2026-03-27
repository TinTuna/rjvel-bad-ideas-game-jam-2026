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
	print("[StairZTrigger] %s entered '%s' | velocity.y=%.1f | threshold=%.1f" % [body.name, name, body.velocity.y, velocity_threshold])

	if not (body.is_in_group("cat") or body.is_in_group("family_members")):
		print("[StairZTrigger] -> ignored (not cat or family_member)")
		return

	if body.velocity.y > velocity_threshold:
		print("[StairZTrigger] -> going DOWN — z_index %d -> %d" % [body.z_index, z_going_down])
		body.z_index = z_going_down
	elif body.velocity.y < -velocity_threshold:
		print("[StairZTrigger] -> going UP — z_index %d -> %d" % [body.z_index, z_going_up])
		body.z_index = z_going_up
	else:
		print("[StairZTrigger] -> velocity below threshold, no z_index change")
