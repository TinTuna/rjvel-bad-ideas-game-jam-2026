extends Node2D

@onready var living_room: Node2D = $LivingRoom
const PIZZA = preload("uid://d87k0lb4q6fx")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    EventBus.pizza_delivered.connect(pizza_delivery)
    Constants.current_day = 3

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func pizza_delivery() -> void:
    #TODO: doorbell sound 
    var new_pizza = PIZZA.instantiate()
    living_room.add_child(new_pizza)
    new_pizza.position.x = 1516
    new_pizza.position.y = 1150
