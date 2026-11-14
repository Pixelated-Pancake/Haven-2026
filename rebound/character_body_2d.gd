extends CharacterBody3D

const SPEED: float = 3.0

func _physics_process(delta: float) -> void:
	var direction := Vector3.ZERO

	if Input.is_action_pressed("move_forward"):
		direction.z -= 1.0

	if Input.is_action_pressed("move_backward"):
		direction.z += 1.0

	if Input.is_action_pressed("move_left"):
		direction.x -= 1.0

	if Input.is_action_pressed("move_right"):
		direction.x += 1.0

	direction = direction.normalized()

	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED

	move_and_slide()
