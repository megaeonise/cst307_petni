extends CanvasModulate

@onready var player = get_parent()
@onready var flash: Timer = $FlashTimer
var max_x = 0
var max_x_divided = 0
var rng = RandomNumberGenerator.new()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player.get_global_position().x>max_x:
		max_x = player.get_global_position().x
	max_x_divided = max_x/100000
	set_color(Color(1-max_x_divided/1.2,1-max_x_divided/1.2,1-max_x_divided/1.2,1))

			


func _on_flash_timer_timeout() -> void:
	print("lignting 2")
	set_color(Color(1-max_x_divided/1.2,1-max_x_divided/1.2,1-max_x_divided/1.2,1))
	flash.stop()


func _on_lightning_timer_timeout() -> void:
	if max_x>35000:
		if rng.randf()>1-max_x_divided/1.2:
			print("?")
			if rng.randf()>0.7:
				print("flash")
				set_color(Color(10,10,10,1))
				flash.start(0.9)
