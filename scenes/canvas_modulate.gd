extends CanvasModulate

@onready var player = get_parent()
@onready var flash: Timer = $FlashTimer
@onready var thunder: AudioStreamPlayer2D = $Lightning
var max_x = 0
var max_x_divided = 0
var rng = RandomNumberGenerator.new()
var end = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player.get_global_position().x>max_x:
		max_x = player.get_global_position().x
	max_x_divided = max_x/100000
	#set_color(Color(1-max_x_divided/1.2,1-max_x_divided/1.2,1-max_x_divided/1.2,1))

			


func _on_flash_timer_timeout() -> void:
	print("lignting 2")
	set_color(Color(1-max_x_divided/1.2,1-max_x_divided/1.2,1-max_x_divided/1.2,1))
	flash.stop()
	thunder.stop()


func _on_lightning_timer_timeout() -> void:
	if max_x>35000 and !end:
		if rng.randf()>1-max_x_divided/1.2:
			print("?")
			if rng.randf()>0.85:
				print("flash")
				set_color(Color(7,7,7,1))
				flash.start(1.2)
				thunder.play()


func _on_end_body_entered(body: Node2D) -> void:
	end = true
	
