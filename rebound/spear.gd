class_name SpearWeapon
extends Area2D

@export var damage: int = 25
@export var base_speed: float = 600.0
@export var max_speed: float = 1100.0
@export var return_speed: float = 850.0

var velocity: Vector2 = Vector2.ZERO

var thrown: bool = false
var returning: bool = false
var has_hit: bool = false

var target_player: Node2D

const RETURN_DISTANCE: float = 25.0
const RETURN_DELAY: float = 0.25


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func throw(direction: Vector2, charge: float, player: Node2D) -> void:

	thrown = true
	returning = false
	has_hit = false

	target_player = player

	var charge_ratio := clamp(charge / 2.0, 0.0, 1.0)

	var speed := lerp(
		base_speed,
		max_speed,
		charge_ratio
	)

	velocity = direction.normalized() * speed


func _physics_process(delta: float) -> void:

	if thrown:

		global_position += velocity * delta
		global_rotation = velocity.angle()

	elif returning and is_instance_valid(target_player):

		# Calculate direction back to player s = ut + 1/2at^2
		var direction := global_position.direction_to(
			target_player.global_position
		)

		# Move towards player
		global_position += direction * return_speed * delta

		# Point spear towards player
		global_rotation = direction.angle()

		# Check whether spear reached player
		if global_position.distance_to(
			target_player.global_position
		) <= RETURN_DISTANCE:

			returning = false
			thrown = false

			# Telling tht controller that spear has returned
			target_player.get_node("spear").on_spear_returned(self)


func _on_body_entered(body: Node2D) -> void:

	if not thrown or has_hit:
		return

	has_hit = true

	# Damage enemy brutally !!!!!
	if body.is_in_group("enemies"):

		if body.has_method("take_damage"):
			body.take_damage(damage)

	thrown = false
	velocity = Vector2.ZERO

	# Begin return after a short pause after brutally killing and violating the enemy like in the 1800s
	await get_tree().create_timer(RETURN_DELAY).timeout

	if is_instance_valid(self):
		returning = true
