
class_name SpearWeapon
extends Area2D

@export var damage: int = 25
@export var base_speed: float = 600.0
@export var max_speed: float = 1100.0
@export var return_speed: float = 850.0

const MAX_CHARGE_TIME: float = 2.0
const RETURN_DISTANCE: float = 25.0
const RETURN_DELAY: float = 0.25

var velocity: Vector2 = Vector2.ZERO

var thrown: bool = false
var returning: bool = false
var has_hit: bool = false

var return_timer: float = 0.0

var target_player: Node2D
var controller: SpearController


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func throw(
	direction: Vector2,
	charge: float,
	player: Node2D,
	spear_controller: SpearController
) -> void:

	if direction.length_squared() == 0.0:
		return

	thrown = true
	returning = false
	has_hit = false
	return_timer = 0.0

	target_player = player
	controller = spear_controller

	var charge_ratio: float = clampf(
		charge / MAX_CHARGE_TIME,
		0.0,
		1.0
	)

	var speed: float = lerpf(
		base_speed,
		max_speed,
		charge_ratio
	)

	velocity = direction.normalized() * speed


func _physics_process(delta: float) -> void:

	# SPEAR THROWING
	if thrown:
		global_position += velocity * delta
		global_rotation = velocity.angle()
		return

	# WAIT BEFORE RETURNING
	if return_timer > 0.0:
		return_timer -= delta

		if return_timer <= 0.0:
			returning = true

	# SPEAR RETURNING
	if returning:

		if not is_instance_valid(target_player):
			return

		var target_position: Vector2 = target_player.global_position

		var direction: Vector2 = global_position.direction_to(
			target_position
		)

		global_position = global_position.move_toward(
			target_position,
			return_speed * delta
		)

		if direction.length_squared() > 0.0:
			global_rotation = direction.angle()

		# SPEAR REACHED PLAYER
		if global_position.distance_to(target_position) <= RETURN_DISTANCE:

			returning = false
			thrown = false
			velocity = Vector2.ZERO

			if is_instance_valid(controller):
				controller.on_spear_returned(self)


func _on_body_entered(body: Node2D) -> void:

	if not thrown or has_hit:
		return

	if body == target_player:
		return

	has_hit = true
	thrown = false
	velocity = Vector2.ZERO

	# DEAL DAMAGE
	if body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			body.take_damage(damage)

	return_timer = RETURN_DELAY
