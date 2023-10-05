extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var coyote_jump_timer = $CoyoteJumpTimer
@onready var starting_position = global_position 

@export var movement_data : PlayerMovementData

var air_jump = false
var just_wall_jumped = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	var input_axis = Input.get_axis("Left", "Right")
	apply_gravity(delta)
	handle_wall_jump()
	handle_jump()
	handle_acceleration(input_axis, delta)
	handle_air_acceleration(input_axis, delta)
	apply_friction(input_axis, delta)
	apply_air_resistance(input_axis, delta)
	update_animations(input_axis)
	just_wall_jumped = false
	
	var was_on_floor = is_on_floor()
	move_and_slide()
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge:
		coyote_jump_timer.start()

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * movement_data.gravity_scale * delta
	

func handle_wall_jump():
	if not is_on_wall_only(): return
	var wall_normal = get_wall_normal()
	if Input.is_action_just_pressed("Left") and wall_normal == Vector2.LEFT:
		velocity.x = wall_normal.x * movement_data.speed
		velocity.y = movement_data.jump_velocity
	if Input.is_action_just_pressed("Right") and wall_normal == Vector2.RIGHT:
		velocity.x = wall_normal.x * movement_data.speed
		velocity.y = movement_data.jump_velocity
		just_wall_jumped = true

func handle_jump():
	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
		if Input.is_action_just_pressed("Jump"):
			velocity.y = movement_data.jump_velocity
			air_jump = true
			coyote_jump_timer.stop()
	elif not is_on_floor():
		if Input.is_action_just_released("Jump") and velocity.y < movement_data.jump_velocity / 2:
			velocity.y = movement_data.jump_velocity / 2
			coyote_jump_timer.stop()
		if Input.is_action_just_pressed("Jump") and air_jump and not just_wall_jumped:
			velocity.y = movement_data.jump_velocity * 0.8
			air_jump = false

func handle_acceleration(input_axis, delta):
	if not is_on_floor(): return
	if input_axis != 0:
		velocity.x = move_toward(velocity.x, movement_data.speed * input_axis, movement_data.acceleration * delta)

func handle_air_acceleration(input_axis, delta):
	if is_on_floor(): return
	if input_axis != 0:
		velocity.x = move_toward(velocity.x, movement_data.speed * input_axis, movement_data.air_acceleration * delta)

func apply_friction(input_axis, delta):
	if input_axis == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.friction * delta)

func apply_air_resistance(input_axis, delta):
	if input_axis == 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.air_resistance * delta)	

func update_animations(input_axis):
	if input_axis != 0:
		animated_sprite_2d.flip_h = (input_axis < 0)
		animated_sprite_2d.play("Run")
	else:
		animated_sprite_2d.play("Idle")

	if not is_on_floor():
		animated_sprite_2d.play("Jump")

func _on_hazard_detector_area_entered(area):
	global_position = starting_position