extends AnimatedSprite2D


@onready var trigger_two: Area2D = $PetniTrigger2
@onready var trigger_three: Area2D = $PetniTrigger3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_flip_h(true)
	set_visible(false)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_petni_trigger_body_entered(body: Node2D) -> void:
	print("???")
	set_visible(true)
	trigger_two.set_monitoring(true)
	trigger_three.set_monitoring(true)
	


func _on_petni_trigger_3_body_entered(body: Node2D) -> void:
	set_flip_h(false)
