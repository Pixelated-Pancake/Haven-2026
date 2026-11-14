extends CanvasLayer

@export var full_heart: Texture2D
@export var half_heart: Texture2D
@export var empty_heart: Texture2D

@export var player_path: NodePath

const MAX_HEARTS := 3
const HEART_SIZE := Vector2(48, 48)

var hearts: Array[TextureRect] = []
var pulse_tweens: Array[Tween] = []

@onready var hearts_container: HBoxContainer = $HeartsContainer


func _ready() -> void:
	create_hearts()

	var player = get_node_or_null(player_path)

	if player:
		player.health_changed.connect(update_health)
		update_health(player.health, player.max_health)
	else:
		push_warning("Player not found! Check player_path.")


func create_hearts() -> void:

	hearts_container.add_theme_constant_override("separation", 8)

	for i in range(MAX_HEARTS):

		var heart := TextureRect.new()

		heart.custom_minimum_size = HEART_SIZE
		heart.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		heart.pivot_offset = HEART_SIZE / 2

		hearts_container.add_child(heart)
		hearts.append(heart)


func update_health(current_health: int, _max_health: int) -> void:

	for i in range(MAX_HEARTS):

		var heart_health := current_health - (i * 2)

		if heart_health >= 2:
			hearts[i].texture = full_heart

		elif heart_health == 1:
			hearts[i].texture = half_heart

		else:
			hearts[i].texture = empty_heart

	update_heartbeat(current_health)


func update_heartbeat(current_health: int) -> void:

	for tween in pulse_tweens:
		if tween and tween.is_running():
			tween.kill()

	pulse_tweens.clear()

	for heart in hearts:
		heart.scale = Vector2.ONE

	var remaining_hearts := ceili(float(current_health) / 2.0)

	if remaining_hearts <= 0:
		return

	var beat_interval := 0.25 + (remaining_hearts * 0.35)

	for i in range(remaining_hearts):

		var heart := hearts[i]

		var tween := create_tween()
		tween.set_loops()

		tween.tween_property(
			heart,
			"scale",
			Vector2(1.2, 1.2),
			0.12
		).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

		tween.tween_property(
			heart,
			"scale",
			Vector2.ONE,
			0.12
		).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)

		tween.tween_interval(beat_interval)

		pulse_tweens.append(tween)
