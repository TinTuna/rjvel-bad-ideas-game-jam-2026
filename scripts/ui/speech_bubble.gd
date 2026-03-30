extends Node2D
## SpeechBubble - Typewriter speech bubble for NPCs
##
## Add as a child of any CharacterBody2D and call show_text() to display.
## Hides itself when hide_bubble() is called.

const CHARS_PER_SECOND := 20.0
const BUBBLE_W := 300.0
const BUBBLE_H := 90.0
const PAD := 10.0

var _bg: ColorRect
var _label: Label
var _tween: Tween


func _ready() -> void:
	_bg = ColorRect.new()
	_bg.color = Color(0.08, 0.08, 0.08, 0.88)
	_bg.size = Vector2(BUBBLE_W, BUBBLE_H)
	_bg.position = Vector2(-BUBBLE_W / 2.0, -BUBBLE_H / 2.0)
	add_child(_bg)

	_label = Label.new()
	_label.size = Vector2(BUBBLE_W - PAD * 2, BUBBLE_H - PAD * 2)
	_label.position = Vector2(-BUBBLE_W / 2.0 + PAD, -BUBBLE_H / 2.0 + PAD)
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(_label)

	visible = false


func show_text(text: String) -> void:
	_label.text = text
	_label.visible_characters = 0
	visible = true

	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_method(
		func(v: int) -> void: _label.visible_characters = v,
		0, text.length(),
		text.length() / CHARS_PER_SECOND
	)


func hide_bubble() -> void:
	if _tween:
		_tween.kill()
	visible = false
