extends Node2D

@onready var player = get_node("../Player")
var max_x = 0
var max_x_divided = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player.get_global_position().x>max_x:
		max_x = player.get_global_position().x
	max_x_divided = max_x/100000
	set_modulate(Color(1-max_x_divided,1-max_x_divided,1-max_x_divided,1))
