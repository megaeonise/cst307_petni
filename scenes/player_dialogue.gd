extends RichTextLabel

@export var chars = 0
@onready var TextSpeed = get_node("../TextSpeed")
@onready var TextVanish= get_node("../TextVanish")
@onready var panel = get_parent()
@export var textspeed = 0.2
@export var char_per_tick = 1
@export var max_chars = 32

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible_characters = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#Mantra
	visible_characters = chars
	if Input.is_action_just_pressed("mantra"):
		chars = 0
		panel.set_visible(true)
		TextSpeed.start(textspeed)
		


func _on_text_speed_timeout() -> void:
	print("textspeedtimeout")
	if chars!=max_chars:
		chars += char_per_tick
	else:
		TextSpeed.stop()
		TextVanish.start(2)


func _on_text_vanish_timeout() -> void:
	chars = 0
	TextVanish.stop()
	panel.set_visible(false)
