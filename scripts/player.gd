extends CharacterBody2D

#@onready var dash: GPUParticles2D = $dashparticless
#@onready var wall_particles: GPUParticles2D = $wallparticles
#@onready var dash_timer: Timer = $DashTimer
@onready var p_light: PointLight2D = $Death
@onready var respawn_timer: Timer = $Respawn
#@onready var wall_timer: Timer = $WallTimer
#@onready var dash_timer_2: Timer = $DashTimer2
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var hang_timer: Timer = $HangTimer
#@onready var jumpSound: AudioStreamPlayer = $JumpSound
#@onready var dashSound: AudioStreamPlayer = $DashSound



@export var WALK_SPEED = 150.0
@export var RUN_SPEED = 280.0
var SPEED = WALK_SPEED
@export var JUMP_VELOCITY = -400.0
@export var JUMP_CHARGE_TIME = 0.1
#@export var dash_count = 2
var animated_sprite : AnimatedSprite2D
var jump_charge_timer = 0
var jump_charging = false
var jump_finished = false
var is_dashing = false
@export var max_speed= Vector2(500, 600)
@export var min_speed= Vector2(-500, -600)
var respawning = false
#var wall_stamina = true
var coyote = true
var can_hang = true
@export var coyote_time = 0.1
@export var hang_range = 50
@export var hang_length = 0.05

func _ready() -> void:
	animated_sprite = $Sprite2D
	#dash.emitting = false
	#dash_timer.one_shot = true
	#dash_timer.timeout.connect(_on_dash_timer_timeout)

#func _on_dash_timer_timeout():
	#dash.emitting = false
	#wall_particles.emitting = false  # Stop particles after timer
	
#func _on_wall_timer_timeout() -> void:
	#wall_stamina = false

func _physics_process(delta: float) -> void:
	# Add the gravity
	var p_light_scale = p_light.get_texture_scale()
	var p_light_energy = p_light.get_energy()
	var direction := Input.get_axis("move_left", "move_right")
	var vertical_direction := Input.get_axis("down", "up")
	if !respawning:
		#if is_on_wall() and wall_timer.is_stopped() and wall_stamina and direction != 0:
			#wall_timer.start(1.5)
			#wall_stamina = false
			#animated_sprite.play("hang")
		#elif is_on_wall() and !wall_timer.is_stopped() and direction != 0 and dash_timer_2.is_stopped():
			#wall_timer.set_paused(false)
			#velocity.y = 0
			#velocity += (get_gravity() * delta)
			#animated_sprite.play("hang")
		if not is_on_floor():
			#wall_timer.set_paused(true)
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
					velocity += (get_gravity() * delta) * 0.9
					if velocity.y > 0:
						animated_sprite.play("fall")
			else:
				if can_hang and velocity.y < hang_range and velocity.y >-hang_range and hang_timer.is_stopped():
					hang_timer.start(hang_length)
					can_hang = false
					velocity += (get_gravity() * delta) * 0.1
				if !hang_timer.is_stopped():
					velocity += (get_gravity() * delta) * 0.1
				else:
					velocity += (get_gravity() * delta) * 1.5
					if velocity.y > 0:
						animated_sprite.play("fall")

			#if velocity.y < 0:
				#animated_sprite.play("fall")
				
		#Movement
		is_dashing = Input.is_action_just_pressed("dash")
		
		# Animation
		if direction != 0 and velocity.y == 0 and not jump_charging:
			animated_sprite.flip_h = direction < 0
			animated_sprite.play("run")
		elif direction == 0 and velocity.y == 0 and not jump_charging:
			animated_sprite.play("idle")
		elif direction != 0 and not jump_charging:
			animated_sprite.flip_h = direction < 0
		


		# Jump
		if Input.is_action_just_pressed("jump") and ((!coyote_timer.is_stopped() and !is_dashing) or (is_on_floor() and !is_dashing)):
			jump_charging = true
			animated_sprite.play("charge")
			jump_charge_timer = 0
			
		
		if is_on_floor():
			#dash_count = 2
			#wall_stamina = true
			#wall_timer.start(1.5)
			#wall_timer.set_paused(true)
			coyote = true
			can_hang = true
		
		if jump_charging:
			jump_charge_timer += delta
			if jump_charge_timer >= JUMP_CHARGE_TIME or Input.is_action_just_released("jump"):
				velocity.y = JUMP_VELOCITY
				jump_charging = false
				animated_sprite.play("jump")
				#jumpSound.play()

		# Movement
		if Input.is_action_pressed("dash"):
			SPEED = RUN_SPEED
		else:
			SPEED = WALK_SPEED
		if direction:
			if not jump_charging:
				velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		print(SPEED)
		
		# Dash movement 
		#if dash_count > 0 and is_dashing and !Input.is_action_pressed("jump"):
			#velocity.x += direction * DASH_SPEED * 10
			#velocity.y += -vertical_direction * DASH_SPEED * 2
			##dashSound.play()
			#dash_count -= 1
			## Start particles and timer
			#dash.emitting = false
			#dash.emitting = true
			#dash_timer.start(0.4)
			#dash_timer_2.start(0.4)
	  # Adjust time for trail length
		
		#if is_on_wall_only() and Input.is_action_just_pressed("jump") and !wall_timer.is_stopped():
			#velocity.y = JUMP_VELOCITY * 0.67
			#velocity.x = -direction * 1000
			#wall_particles.emitting = false
			#wall_particles.emitting = true
			#dash_timer.start(0.2)
			##experimental walljump trail
		#if is_on_wall_only():
			#wall_particles.emitting = false
			#wall_particles.emitting = true
			#dash_timer.start(0.02)


		# Flip particles
		#dash.scale.x = -1 if direction < 0 else 1
		#wall_particles.scale.x = -1 if direction < 0 else 1
		
		velocity.y = clamp(velocity.y, -400, 400)
		velocity.x = clamp(velocity.x, -2000, 2000)
		#if velocity==Vector2.ZERO:
			#dash.set_modulate(Color(1,1,1,0.4))

		move_and_slide()
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			if collision.get_collider().name=="SPIKES" or collision.get_collider().name=="SPIKES2":
				if !respawning:
					respawning = true
					p_light.set_enabled(true)
					respawn_timer.start(1)
				#elif respawning and respawn_timer.is_stopped():
					#get_tree().call_deferred("reload_current_scene")
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
		#set_global_position(Vector2(0,0))
	#elif respawning and respawn_timer.is_stopped():
		#print("why")
		#get_tree().call_deferred("reload_current_scene")
