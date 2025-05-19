extends RichTextLabel

@export var chars = 0
@onready var TextSpeed = get_node("../TextSpeed")
@onready var TextVanish = get_node("../TextVanish")
@onready var Voice = get_node("../AudioStreamPlayer2D")
@onready var panel = get_parent()
@export var max_chars = 14
@export var char_per_tick = 1
@export var textspeed = 0.1


var speaking = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible_characters = 0



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	visible_characters = chars
	if speaking:
		print(text)
		chars = 0
		panel.set_visible(true)
		TextSpeed.start(textspeed)
		speaking = false



func _on_petni_trigger_2_body_entered(body: Node2D) -> void:
	speaking = true
	Voice.play()
	


func _on_text_speed_timeout() -> void:
	if chars!=max_chars:
		chars += char_per_tick
	else:
		TextSpeed.stop()
		TextVanish.start(2)


func _on_text_vanish_timeout() -> void:
	chars = 0
	TextVanish.stop()
	panel.set_visible(false)
	Voice.stop()


func _on_petni_trigger_3_body_entered(body: Node2D) -> void:
	speaking = true
	Voice.play()
