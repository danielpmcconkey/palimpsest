extends CharacterBody2D
## Player controller for isometric movement.
## Tap-to-move: tap a direction to start moving, tap again to stop.
## Tap a different direction to change. Opposing directions cancel.

@export var speed: float = 200.0

# Isometric movement basis vectors.
const ISO_RIGHT := Vector2(1, 0.5)
const ISO_DOWN := Vector2(-1, 0.5)

# Current movement intent — persists until changed by another tap.
var _move_intent := Vector2.ZERO


func _ready() -> void:
	add_to_group("player")
	if GameState.player_position != Vector2.ZERO:
		global_position = GameState.player_position


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.is_echo()):
		return

	match event.physical_keycode:
		KEY_W:
			if _move_intent.y < 0:
				_move_intent.y = 0  # Already moving up, stop vertical
			else:
				_move_intent.y = -1
		KEY_S:
			if _move_intent.y > 0:
				_move_intent.y = 0  # Already moving down, stop vertical
			else:
				_move_intent.y = 1
		KEY_A:
			if _move_intent.x < 0:
				_move_intent.x = 0
			else:
				_move_intent.x = -1
		KEY_D:
			if _move_intent.x > 0:
				_move_intent.x = 0
			else:
				_move_intent.x = 1
		KEY_SPACE:
			_move_intent = Vector2.ZERO  # Full stop
		KEY_E:
				EraManager.switch_to_next_era()
		KEY_F:
				_try_interact()


func _physics_process(_delta: float) -> void:
	var input = _move_intent.normalized()

	var iso_velocity := Vector2.ZERO
	iso_velocity += ISO_RIGHT * input.x
	iso_velocity += ISO_DOWN * input.y

	if input.length() > 0:
		iso_velocity = iso_velocity.normalized() * speed

	velocity = iso_velocity
	move_and_slide()


func _try_interact() -> void:
	var area = get_node_or_null("InteractionArea")
	if not area:
		return

	var bodies = area.get_overlapping_bodies()
	for body in bodies:
		if body.has_method("interact"):
			body.interact()
			return

	var areas = area.get_overlapping_areas()
	for a in areas:
		if a.has_method("interact"):
			a.interact()
			return
