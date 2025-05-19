extends RichTextLabel

@export var chars = 0
@onready var TextSpeed = get_node("../TextSpeed")
@onready var TextVanish= get_node("../TextVanish")
@onready var panel = get_parent()
@export var textspeed = 0.2
@export var char_per_tick = 1
@export var max_chars = 35
var text_array = ["Bhoot amar poot, petni amar jhee", "Press F to recite mantra", "Hold Shift to run", "Go right to reach your uncle's home"]
var tutorial = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible_characters = 0
	set_text(text_array[0])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#Mantra
	visible_characters = chars
	if Input.is_action_just_pressed("mantra") or tutorial:
		print(text)
		chars = 0
		panel.set_visible(true)
		TextSpeed.start(textspeed)
		if tutorial:
			tutorial = false
			textspeed = textspeed*2
	
		


func _on_text_speed_timeout() -> void:
	if chars!=max_chars:
		chars += char_per_tick
	else:
		TextSpeed.stop()
		TextVanish.start(1)


func _on_text_vanish_timeout() -> void:
	chars = 0
	TextVanish.stop()
	panel.set_visible(false)
	set_text(text_array[0])


func _on_tutorial_body_entered(body: Node2D) -> void:
	tutorial = true
	textspeed = textspeed/2
	set_text(text_array[1])


func _on_tutorial_2_body_entered(body: Node2D) -> void:
	tutorial = true
	textspeed = textspeed/2
	set_text(text_array[2])


func _on_tutorial_3_body_entered(body: Node2D) -> void:
	tutorial = true
	textspeed = textspeed/2
	set_text(text_array[3])
