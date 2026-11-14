
class_name SpearController
extends Node2D

const MAX_CHARGE_TIME: float = 2.0

var spear_instance: SpearWeapon

var is_charging: bool = false
var charge_time: float = 0.0


func _ready() -> void:
	spear_instance = get_node_or_null("Spear") as SpearWeapon

	if spear_instance == null:
		push_warning("Spear node not found inside SpearController!")


func _process(delta: float) -> void:

	if not is_instance_valid(spear_instance):
		return

	aim_spear()

	if Input.is_action_just_pressed("charge_spear"):
		is_charging = true
		charge_time = 0.0

	if Input.is_action_pressed("charge_spear") and is_charging:
		charge_time = minf(
			charge_time + delta,
			MAX_CHARGE_TIME
		)

	if Input.is_action_just_released("charge_spear") and is_charging:
		is_charging = false
		throw_spear()


func aim_spear() -> void:

	var direction := global_position.direction_to(
		get_global_mouse_position()
	)

	if direction.length_squared() > 0.0:
		spear_instance.global_rotation = direction.angle()


func throw_spear() -> void:

	if not is_instance_valid(spear_instance):
		return

	var player := get_parent() as Node2D

	if player == null:
		push_warning("SpearController parent is not a Node2D!")
		return

	var direction := global_position.direction_to(
		get_global_mouse_position()
	)

	if direction.length_squared() == 0.0:
		return

	var thrown_spear := spear_instance

	# Detach spear from player
	thrown_spear.reparent(
		get_tree().current_scene,
		true
	)

	# Throw spear
	thrown_spear.throw(
		direction,
		charge_time,
		player,
		self
	)

	# Clear controller reference while spear is away
	spear_instance = null
	charge_time = 0.0


func on_spear_returned(returned_spear: SpearWeapon) -> void:

	if not is_instance_valid(returned_spear):
		return

	# Attach spear back to controller
	returned_spear.reparent(self, true)

	returned_spear.position = Vector2.ZERO
	returned_spear.rotation = 0.0

	spear_instance = returned_spear
	charge_time = 0.0
	is_charging = false
