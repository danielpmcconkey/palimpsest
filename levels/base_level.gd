extends Node2D
class_name BaseLevel
## Base script for all level scenes.
## Handles setting the era index, positioning the player,
## and applying causal effects on load.

## Which era this level represents (0-indexed).
@export var era_index: int = 0

## Display name for this era.
@export var era_name: String = "Unknown"

## Where to spawn the player if they have no saved position.
@export var default_player_position: Vector2 = Vector2(400, 300)


func _ready() -> void:
	GameState.current_era = era_index
	GameState.mark_era_visited(era_index)
	_position_player()
	_apply_causal_effects()


func _position_player() -> void:
	# Find the player in the scene tree.
	var players = get_tree().get_nodes_in_group("player")
	if players.size() == 0:
		return

	var player = players[0] as Node2D
	if GameState.player_position != Vector2.ZERO:
		player.global_position = GameState.player_position
	else:
		player.global_position = default_player_position


func _apply_causal_effects() -> void:
	# Find all CausalObjects in this level and let them check their state.
	# CausalObject._ready() already handles this, but if objects are added
	# dynamically later, call this to re-check.
	var causal_nodes = get_tree().get_nodes_in_group("causal_objects")
	for node in causal_nodes:
		if node.has_method("_apply_causal_state"):
			node._apply_causal_state()
