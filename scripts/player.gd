extends CharacterBody2D


@onready var p_light: PointLight2D = $Death
@onready var respawn_timer: Timer = $Respawn
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var hang_timer: Timer = $HangTimer
@onready var stamina_timer: Timer = $Stamina
@onready var timer: Timer = $Timer
@onready var mud_timer: Timer = $Mud
@onready var freeze_timer: Timer = $Freeze
@onready var sanity_cooldown: Timer = $SanityCooldown
@onready var sanity_modulate: CanvasModulate = $Sanity
@onready var sanity_effect_timer: Timer = $SanityEffect
@onready var sanity_effect_duration: Timer = $SanityDuration
@onready var sanity_drain_timer: Timer = $SanityDrain
@onready var petni: AnimatedSprite2D = $Petni
@onready var current_position = Vector2.ZERO
@export var WALK_SPEED = 120.0
@export var RUN_SPEED = 280.0
var SPEED = WALK_SPEED
@export var JUMP_VELOCITY = -400.0
@export var JUMP_CHARGE_TIME = 0.2
@export var sanity = 100
var animated_sprite : AnimatedSprite2D
var jump_charge_timer = 0
var jump_charging = false
var jump_finished = false
var is_dashing = false
var is_running = false
var is_jumping = false
var tp_counter = 0
var tp_forward = false
var control = true
var max_x = 0
var max_x_divided = 0
@export var MAX_STAMINA = 300
@export var max_speed= Vector2(500, 600)
@export var min_speed= Vector2(-500, -600)
var stamina = MAX_STAMINA
var respawning = false
var coyote = true
var can_hang = true
@export var coyote_time = 0.1
@export var hang_range = 50
@export var hang_length = 0.05
var rng = RandomNumberGenerator.new()
@onready var current_color = sanity_modulate.get_color()



func _ready() -> void:
	animated_sprite = $Sprite2D
	current_position = petni.get_position()


func _physics_process(delta: float) -> void:
	# Add the gravity
	var p_light_scale = p_light.get_texture_scale()
	var p_light_energy = p_light.get_energy()
	var direction := Input.get_axis("move_left", "move_right")
	var vertical_direction := Input.get_axis("down", "up")
	petni.set_position(current_position)
	if sanity_effect_duration.is_stopped():
		if global_position.x>max_x:
			max_x = global_position.x
			max_x_divided = max_x/100000
			sanity_modulate.set_color(Color(1-max_x_divided/2,1-max_x_divided/2,1-max_x_divided/2,1))
	if !respawning:
		if not is_on_floor():
			if coyote:
				coyote_timer.start(0.1)
				coyote = false
			if Input.is_action_pressed("jump") and control:
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
		
		if Input.is_action_just_pressed("mantra") and sanity_cooldown.is_stopped():
			sanity += 20
			if sanity >100:
				sanity = 100
			sanity_cooldown.start(1.5)
			print("sanityup")
		if sanity<0:
			sanity = 0

		
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
		if control and Input.is_action_just_pressed("jump") and ((!coyote_timer.is_stopped() and !is_dashing and !jump_charging and !is_jumping) or (is_on_floor() and !is_dashing)):
			jump_charging = true
			animated_sprite.play("charge")
			jump_charge_timer = 0

			
		
		if is_on_floor():
			coyote = true
			can_hang = true
			if is_jumping:
				animated_sprite.play("landing")
				is_jumping = false
		
		if jump_charging:
			jump_charge_timer += delta
			if jump_charge_timer >= JUMP_CHARGE_TIME or Input.is_action_just_released("jump"):
				velocity.y = JUMP_VELOCITY
				jump_charging = false
				animated_sprite.play("jump")
				is_jumping = true

		# Movement
		if control and Input.is_action_pressed("dash") and !is_running and stamina>=0 and direction!=0 and is_on_floor():
			SPEED = RUN_SPEED
			is_running = true
			stamina -= 150*delta
			stamina_timer.set_paused(true)
			if animated_sprite.get_animation()!="running" or animated_sprite.get_animation()!="landing" or (animated_sprite.get_animation()=="landing" and animated_sprite.get_frame()==3):
				animated_sprite.play("running")
		elif control and Input.is_action_pressed("dash") and is_running and stamina>=0 and direction!=0 and is_on_floor(): 
			SPEED = RUN_SPEED
			stamina -= 100*delta
			stamina_timer.set_paused(true)
			#if animated_sprite.get_animation()!="running" or animated_sprite.get_animation()!="landing" or (animated_sprite.get_animation()=="landing" and animated_sprite.get_frame()==3):
				#animated_sprite.play("running")
		else:
			if stamina_timer.is_paused() and stamina<30:
				stamina_timer.set_paused(false)
				stamina_timer.start(5)
			else:
				if stamina<MAX_STAMINA and stamina>30:
					stamina+=20*delta
			if is_on_floor():
				SPEED = WALK_SPEED
			is_running = false
		if direction and control:
			if not jump_charging:
				velocity.x = direction * SPEED
		elif control:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		
		if stamina <= 50:
			set_modulate(Color(1.5, cos(timer.get_time_left()), cos(timer.get_time_left()), 1))
		else:
			set_modulate(Color(1,1,1,1))
		
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
			elif collision.get_collider().name=="SPIKE":
				if !respawning:
					respawning = true
					sanity -= 20
					p_light.set_enabled(true)
					respawn_timer.start(1)
			elif collision.get_collider().name=="MUD":
				WALK_SPEED = 50
				RUN_SPEED = 100
				mud_timer.start(2)
				
	if respawning and respawn_timer.is_stopped():
		if tp_counter==1:
			position.x -= 3000
			tp_counter += 1
		elif tp_forward:
			position.x += 3000
			tp_forward = false
		else:
			position.x -= 1000
		respawning = false
		p_light.set_texture_scale(0.1)
		p_light.set_energy(1)
		p_light.set_enabled(false)
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


func _on_mud_timeout() -> void:
	WALK_SPEED = 150.0
	RUN_SPEED = 280.0
	sanity -= 10


func _on_petni_trigger_body_entered(body: Node2D) -> void:
	if tp_counter==0:
		tp_counter += 1
		if !respawning:
			respawning = true
			p_light.set_enabled(true)
			respawn_timer.start(1)


func _on_petni_trigger_2_body_entered(body: Node2D) -> void:
	control = false
	sanity -= 60
	print(sanity)
	freeze_timer.start(2)
	tp_forward = true
	sanity_drain_timer.start(0.5)
	velocity = Vector2(0,0)


func _on_freeze_timeout() -> void:
	control = true
	if !respawning:
		respawning = true
		p_light.set_enabled(true)
		respawn_timer.start(1)
	freeze_timer.stop()


func _on_petni_trigger_3_body_entered(body: Node2D) -> void:
	control = false
	tp_forward = true
	sanity -= 60
	print(sanity)
	freeze_timer.start(2)
	sanity_drain_timer.start(0.5)
	velocity = Vector2(0,0)


func _on_sanity_cooldown_timeout() -> void:
	sanity_cooldown.stop()


func _on_sanity_effect_timeout() -> void:
	print("sanitycheck", position, sanity)
	current_color = sanity_modulate.get_color()
	var proc = 0
	if sanity<80:
		if rng.randf()-(sanity/100)>0.7:
			sanity_modulate.set_color(Color(rng.randf(),rng.randf(),rng.randf(),rng.randf()))
			proc+=1
			print("option1")
			if rng.randf()-(sanity/100)>0.7:
				print("shes there")
				control = false
				petni.set_visible(true)
				var random_scale = rng.randf_range(1,3)
				petni.set_scale(Vector2(random_scale, random_scale))
				current_position = Vector2(rng.randi_range(-300-sanity, 300+sanity), rng.randi_range(-100,100))
				petni.set_position(Vector2(rng.randi_range(-300-sanity, 300+sanity), rng.randi_range(-100,100)))
				if petni.get_position().x<0 and petni.get_position().x>-100 and random_scale<2.5: #petni.get_position().x<0
					petni.set_position(Vector2(-100, current_position.y))
					current_position = Vector2(-100, current_position.y)
					print("getaway")
				if petni.get_position().x>0 and petni.get_position().x<100 and random_scale<2.5: #petni.get_position().x<0
					petni.set_position(Vector2(100, current_position.y))
					print("getaway")
					current_position = Vector2(-100, current_position.y)
				proc+=1
				petni.set_flip_h(!petni.is_flipped_h())
				velocity = Vector2(0,0)
	if proc>0:
		proc = 0
		sanity_effect_duration.start(0.2+(1-sanity/100))
		sanity_effect_timer.stop()

func _on_sanity_duration_timeout() -> void:
	sanity_modulate.set_color(current_color)
	sanity_effect_timer.start(2)
	petni.set_visible(false)
	control = true
	


func _on_sanity_drain_timeout() -> void:
	sanity -= 2
