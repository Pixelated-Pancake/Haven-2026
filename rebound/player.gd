extends CharacterBody2D

signal health_changed(current_health: int, max_health: int)

const SPEED := 220.0
const SPRINT_SPEED := 350.0
const JUMP_VELOCITY := -400.0
const GRAVITY := 980.0
const DOUBLE_TAP_TIME := 0.3

var last_right_press := -1.0
var is_sprinting := false

var max_health := 6
var health := 6

@onready var spear_controller = $SpearController


func _physics_process(delta: float) -> void:

	if not is_on_floor():
		velocity.y += GRAVITY * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("move_left", "move_right")

	if Input.is_action_just_pressed("move_right"):
		var current_time := Time.get_ticks_msec() / 1000.0

		if current_time - last_right_press <= DOUBLE_TAP_TIME:
			is_sprinting = true

		last_right_press = current_time

	if direction <= 0:
		is_sprinting = false

	var current_speed := SPRINT_SPEED if is_sprinting else SPEED

	if spear_controller.is_charging:
		current_speed *= 0.4

	velocity.x = direction * current_speed

	move_and_slide()

func take_damage(amount: int) -> void:
	health = clampi(health - amount, 0, max_health)
	health_changed.emit(health, max_health)

	if health <= 0:
		die()


func heal(amount: int) -> void:
	health = clampi(health + amount, 0, max_health)
	health_changed.emit(health, max_health)


func die() -> void:
	print("Player defeated!")
	set_physics_process(false)
