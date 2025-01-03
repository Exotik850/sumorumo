extends CharacterBody2D

@export var speed = 200
@export var acceleration = 800
@export var friction = 600
@export var knockback_force = 500  # Force applied to physics objects on collision
@export var dash_speed = 500  # Speed during dash
@export var dash_duration = 0.2  # Duration of dash
@export var dash_cooldown = 1.0  # Cooldown between dashes

var screen_size
var knockback = Vector2.ZERO
var is_dashing = false
var dash_timer = 0.0
var dash_cooldown_timer = 0.0

func _ready() -> void:
	screen_size = get_viewport_rect().size

func _process(delta: float) -> void:
	var input_vector = Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		input_vector.x += 1
	if Input.is_action_pressed("ui_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("ui_down"):
		input_vector.y += 1
	if Input.is_action_pressed("ui_up"):
		input_vector.y -= 1

	input_vector = input_vector.normalized()

	# Handle dash input
	if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0:
		is_dashing = true
		dash_timer = dash_duration
		dash_cooldown_timer = dash_cooldown

	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
		velocity = input_vector.normalized() * dash_speed
	else:
		dash_cooldown_timer -= delta
		if input_vector != Vector2.ZERO:
			velocity = velocity.move_toward(input_vector * speed, acceleration * delta)
		else:
			velocity = velocity.move_toward(Vector2.ZERO, 600 * delta)

	# Apply knockback
	velocity += knockback
	knockback = knockback.move_toward(Vector2.ZERO, friction * delta)

	# Move the player and handle collisions
	move_and_slide()

	# Check for collisions with RigidBody2D nodes
	for i in get_slide_collision_count():
		var collision_info = get_slide_collision(i)
		var collider = collision_info.get_collider()

		if collider is RigidBody2D:
			# Apply a force or impulse to the RigidBody2D
			var direction = collision_info.get_normal()  # Direction of the collision
			var force = direction * knockback_force
			collider.apply_central_impulse(-force)  # Apply impulse in the opposite direction

	position = position.clamp(Vector2.ZERO, screen_size)
