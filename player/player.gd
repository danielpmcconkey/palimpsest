extends CharacterBody2D
## Player controller for isometric movement.
## Uses WASD mapped to isometric axes.

@export var speed: float = 200.0

# Isometric movement basis vectors.
# In isometric projection, "right" on the ground plane is (1, 0.5)
# and "down" on the ground plane is (-1, 0.5) in screen space.
const ISO_RIGHT := Vector2(1, 0.5)
const ISO_DOWN := Vector2(-1, 0.5)


func _ready() -> void:
	add_to_group("player")
	_ensure_input_actions()
	# Restore position from GameState if we're returning from an era switch.
	if GameState.player_position != Vector2.ZERO:
		global_position = GameState.player_position


func _ensure_input_actions() -> void:
	# Register input actions in code as a safety net.
	# If project.godot input map loaded fine, these are no-ops.
	_add_key_action("move_up", KEY_W)
	_add_key_action("move_down", KEY_S)
	_add_key_action("move_left", KEY_A)
	_add_key_action("move_right", KEY_D)
	_add_key_action("switch_era", KEY_E)
	_add_key_action("interact", KEY_F)


func _add_key_action(action_name: String, keycode: Key) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	# Check if the action already has events. If so, don't duplicate.
	var events = InputMap.action_get_events(action_name)
	if events.size() > 0:
		return
	var event := InputEventKey.new()
	event.keycode = keycode
	event.physical_keycode = keycode
	InputMap.action_add_event(action_name, event)


func _physics_process(_delta: float) -> void:
	var input := Vector2.ZERO

	if Input.is_action_pressed("move_up"):
		input.y -= 1
	if Input.is_action_pressed("move_down"):
		input.y += 1
	if Input.is_action_pressed("move_left"):
		input.x -= 1
	if Input.is_action_pressed("move_right"):
		input.x += 1

	input = input.normalized()

	# Convert cardinal input to isometric screen movement.
	var iso_velocity := Vector2.ZERO
	iso_velocity += ISO_RIGHT * input.x
	iso_velocity += ISO_DOWN * input.y
	iso_velocity = iso_velocity.normalized() * speed

	velocity = iso_velocity
	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("switch_era"):
		EraManager.switch_to_next_era()

	if event.is_action_pressed("interact"):
		_try_interact()


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
