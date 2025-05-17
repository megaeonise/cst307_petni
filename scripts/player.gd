extends CharacterBody2D


@onready var p_light: PointLight2D = $Death
@onready var respawn_timer: Timer = $Respawn
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var hang_timer: Timer = $HangTimer
@onready var stamina_timer: Timer = $Stamina
@export var WALK_SPEED = 150.0
@export var RUN_SPEED = 280.0
var SPEED = WALK_SPEED
@export var JUMP_VELOCITY = -400.0
@export var JUMP_CHARGE_TIME = 0.2
var animated_sprite : AnimatedSprite2D
var jump_charge_timer = 0
var jump_charging = false
var jump_finished = false
var is_dashing = false
var is_running = false
var is_jumping = false
@export var MAX_STAMINA = 200
@export var max_speed= Vector2(500, 600)
@export var min_speed= Vector2(-500, -600)
var stamina = MAX_STAMINA
var respawning = false
var coyote = true
var can_hang = true
@export var coyote_time = 0.1
@export var hang_range = 50
@export var hang_length = 0.05

func _ready() -> void:
	animated_sprite = $Sprite2D


func _physics_process(delta: float) -> void:
	# Add the gravity
	var p_light_scale = p_light.get_texture_scale()
	var p_light_energy = p_light.get_energy()
	var direction := Input.get_axis("move_left", "move_right")
	var vertical_direction := Input.get_axis("down", "up")
	if !respawning:
		if not is_on_floor():
			if coyote:
				coyote_timer.start(0.1)
				coyote = false
			if Input.is_action_pressed("jump"):
				if can_hang and velocity.y < hang_range and velocity.y >-hang_range and hang_timer.is_stopped():
					hang_timer.start(hang_length)
					can_hang = false
					velocity += (get_gravity() * delta) * 0.1
				if !hang_timer.is_stopped():
					velocity += (get_gravity() * delta) * 0.1
				else:
					velocity += (get_gravity() * delta) * 1.2
					#if velocity.y > 0:
						#animated_sprite.play("fall")
			else:
				if can_hang and velocity.y < hang_range and velocity.y >-hang_range and hang_timer.is_stopped():
					hang_timer.start(hang_length)
					can_hang = false
					velocity += (get_gravity() * delta) * 0.1
				if !hang_timer.is_stopped():
					velocity += (get_gravity() * delta) * 0.1
				else:
					velocity += (get_gravity() * delta) * 2
					#if velocity.y > 0:
						#animated_sprite.play("fall")

				
		#Movement
		is_dashing = Input.is_action_just_pressed("dash")
		
		# Animation
		if direction != 0 and velocity.y == 0 and not jump_charging:
			animated_sprite.flip_h = direction > 0
			if animated_sprite.get_animation()!="landing" or (animated_sprite.get_animation()=="landing" and animated_sprite.get_frame()==3):
				animated_sprite.play("run")
		elif direction == 0 and velocity.y == 0 and not jump_charging:
			animated_sprite.play("idle")
		elif direction != 0 and not jump_charging:
			animated_sprite.flip_h = direction > 0
		


		# Jump
		if Input.is_action_just_pressed("jump") and ((!coyote_timer.is_stopped() and !is_dashing) or (is_on_floor() and !is_dashing)):
			jump_charging = true
			print("Why")
			animated_sprite.play("charge")
			jump_charge_timer = 0
			
		
		if is_on_floor():
			coyote = true
			can_hang = true
			if is_jumping:
				animated_sprite.play("landing")
				is_jumping = false
		
		if jump_charging:
			print(jump_charge_timer)
			jump_charge_timer += delta
			if jump_charge_timer >= JUMP_CHARGE_TIME or Input.is_action_just_released("jump"):
				velocity.y = JUMP_VELOCITY
				jump_charging = false
				animated_sprite.play("jump")
				is_jumping = true

		# Movement
		if Input.is_action_pressed("dash") and !is_running and stamina>=0 and direction!=0 and is_on_floor():
			SPEED = RUN_SPEED
			is_running = true
			stamina -= 150*delta
			stamina_timer.set_paused(true)
			if animated_sprite.get_animation()!="running" or animated_sprite.get_animation()!="landing" or (animated_sprite.get_animation()=="landing" and animated_sprite.get_frame()==3):
				animated_sprite.play("running")
		elif Input.is_action_pressed("dash") and is_running and stamina>=0 and direction!=0 and is_on_floor(): 
			SPEED = RUN_SPEED
			stamina -= 100*delta
			stamina_timer.set_paused(true)
			#if animated_sprite.get_animation()!="running" or animated_sprite.get_animation()!="landing" or (animated_sprite.get_animation()=="landing" and animated_sprite.get_frame()==3):
				#animated_sprite.play("running")
		else:
			if stamina_timer.is_paused():
				stamina_timer.set_paused(false)
				stamina_timer.start(1)
			SPEED = WALK_SPEED
			is_running = false
		if direction:
			if not jump_charging:
				velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		

		velocity.y = clamp(velocity.y, -400, 400)
		velocity.x = clamp(velocity.x, -2000, 2000)

		move_and_slide()
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			if collision.get_collider().name=="SPIKES" or collision.get_collider().name=="SPIKES2":
				if !respawning:
					respawning = true
					p_light.set_enabled(true)
					respawn_timer.start(1)
	if respawning and respawn_timer.is_stopped():
		get_tree().call("reload_current_scene")
	elif respawning:
		p_light.set_texture_scale(p_light_scale+0.1)
		p_light.set_energy(p_light_energy+0.02)


func _on_kill_plane_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if !respawning:
		respawning = true
		p_light.set_enabled(true)
		respawn_timer.start(1)


func _on_stamina_timeout() -> void:
	stamina = MAX_STAMINA
