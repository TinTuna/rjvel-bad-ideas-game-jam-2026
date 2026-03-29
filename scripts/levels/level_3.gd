extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    EventBus.pizza_delivered.connect(pizza_delivery)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func pizza_delivery() -> void:
    pass
    #TODO: doorbell sound 
