extends Area2D

var becoming_vis = false
@onready var black_box: Sprite2D = $Box
@onready var TextSpeed: Timer = $TextSpeed
@onready var TextLabel: RichTextLabel = $RichTextLabel
var max_chars = 1000
var current_alpha = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	TextLabel.visible_characters = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print(current_alpha)
	if current_alpha < 1:
		current_alpha = black_box.get_modulate().a
	if becoming_vis and current_alpha<1:
		black_box.set_modulate(Color(1,1,1,current_alpha+0.5*delta))
	if current_alpha>1 and current_alpha!=1.2:
		print("hello")
		current_alpha = 1.2
		TextSpeed.start(0.1)
		


func _on_body_entered(body: Node2D) -> void:
	becoming_vis = true
	black_box.set_visible(true)
	
	


func _on_text_speed_timeout() -> void:
	if TextLabel.visible_characters<max_chars:
		TextLabel.visible_characters += 1
