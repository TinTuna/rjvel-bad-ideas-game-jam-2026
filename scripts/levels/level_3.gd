extends Node2D

@onready var house: Node2D = $House
@onready var doorbell_player: AudioStreamPlayer2D = $DoorbellPlayer
@onready var level_end_trigger: Area2D = $LevelEndTrigger
@onready var entry_door: Sprite2D = $House/EntryDoor

const PIZZA = preload("uid://d87k0lb4q6fx")

func _ready() -> void:
    Constants.current_day = 3
    EventBus.pizza_delivered.connect(pizza_delivery)
    level_end_trigger.body_entered.connect(_on_level_end_triggered)

    await get_tree().process_frame

    var mother: FamilyMemberBase = get_tree().get_first_node_in_group("mother")
    if mother:
        mother.start_for_day(3)
        EventBus.pizza_delivered.connect(mother.react_to_event.bind("pizza_delivered"))
    else:
        push_error("[Level3] Mother NPC not found")

    var twins: FamilyMemberBase = get_tree().get_first_node_in_group("twins")
    if twins:
        twins.start_for_day(3)
    else:
        push_warning("[Level3] Twins NPC not found — add twins.tscn to this level")


func pizza_delivery() -> void:
    doorbell_player.play()
    var new_pizza = PIZZA.instantiate()
    house.add_child(new_pizza)
    new_pizza.position.x = 2600
    new_pizza.position.y = 650

func _on_level_end_triggered(body: Node2D) -> void:
    if entry_door.is_open and body.is_in_group("cat"):
        EventBus.day_started.emit(4)
        SceneLoader.load_scene(Constants.SCENES["DAY_RECAP"])
