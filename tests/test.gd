extends Node2D

@onready var treat: Node2D = $Treat

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if Input.is_action_just_pressed("interact") and treat.has_overlapping_bodies():
        treat.interact()
        
