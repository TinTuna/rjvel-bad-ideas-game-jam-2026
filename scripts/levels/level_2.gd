extends Node2D

var _is_window_opened: bool = false
@onready var level_end_trigger: Area2D = $LevelEndTrigger

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    EventBus.window_open.connect(window_opened)
    level_end_trigger.body_entered.connect(_on_level_end_triggered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func window_opened() -> void:
    _is_window_opened = true

func _on_level_end_triggered(body: Node2D) -> void:
    if _is_window_opened and body.is_in_group("cat"):
        EventBus.day_started.emit(3)
        SceneLoader.load_scene(Constants.SCENES["DAY_RECAP"])
