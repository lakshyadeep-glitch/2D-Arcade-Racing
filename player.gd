extends CharacterBody2D

const MAX_SPEED := 650.0
const ACCELERATION := 900.0
const BRAKE_POWER := 1200.0
const FRICTION := 450.0

const BOOST_SPEED := 1000.0
const BOOST_ACCELERATION := 1800.0
const BOOST_TIME := 1.5

const STEER_SPEED := 350.0

var boost_left := BOOST_TIME
var boosting := false


func _physics_process(delta: float) -> void:
	var accelerate := Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)
	var brake := Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN)
	var boost := Input.is_key_pressed(KEY_SHIFT)

	boosting = boost and accelerate and boost_left > 0.0

	# Acceleration
	if accelerate:
		var acceleration := ACCELERATION
		var target_speed := MAX_SPEED

		if boosting:
			acceleration = BOOST_ACCELERATION
			target_speed = BOOST_SPEED
			boost_left -= delta
		else:
			boost_left = min(boost_left + delta * 0.4, BOOST_TIME)

		velocity.y = move_toward(
			velocity.y,
			-target_speed,
			acceleration * delta
		)
	else:
		boost_left = min(boost_left + delta * 0.4, BOOST_TIME)

		velocity.y = move_toward(
			velocity.y,
			0.0,
			FRICTION * delta
		)

	# Brake
	if brake:
		velocity.y = move_toward(
			velocity.y,
			0.0,
			BRAKE_POWER * delta
		)

	# Steering
	var steering := Input.get_axis("move_left", "move_right")

	velocity.x = move_toward(
		velocity.x,
		steering * STEER_SPEED,
		1500.0 * delta
	)

	velocity.x = clamp(velocity.x, -STEER_SPEED, STEER_SPEED)

	move_and_slide()


func is_boosting() -> bool:
	return boosting
