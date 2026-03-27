extends Area2D

class_name Interactable

func _notification(what: int) -> void:
	if what == NOTIFICATION_READY:
		body_entered.connect(_on_body_entered)
		body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("cat"):
		EventBus.cat_near_interactable.emit()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("cat"):
		EventBus.cat_left_interactable.emit()

func interact() -> void:
	pass
