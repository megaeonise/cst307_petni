extends Camera2D

@export var target_path: NodePath
@export var new_target: NodePath
@export var follow_speed := 8.0
@export var pixel_snap := true
@export var pixel_size := 1.0

@export var zoom_speed: float = 5
@export var zoom_scale: float = 1.5

var is_zooming : bool = false

var target: Node2D

func _ready():
	target = get_node(target_path)

func _change_target():
	target = get_node(new_target)

func _zoom_trigger():
	is_zooming = true

func _process(delta):
	if not target:
		return

	# Smooth follow
	var target_position = target.global_position
	#var new_position = target.global_position
	var new_position = global_position.lerp(target_position, delta * follow_speed)
	
	if is_zooming:
		zoom = zoom.lerp(Vector2(zoom_scale, zoom_scale), zoom_speed * delta)
		zoom.x = zoom.y
		#for fixing potential jittering issues
		if abs(zoom.x - zoom_scale) < 0.01:
			zoom = Vector2(zoom_scale, zoom_scale)
			is_zooming = false
	
	if pixel_snap and pixel_size > 0:
		new_position.x = floor(new_position.x / pixel_size + 0.5) * pixel_size
		#new_position.y = floor(new_position.y / pixel_size + 0.5) * pixel_size

	global_position.x = new_position.x
