extends Node
## Handles era switching: loading the right level scene and preserving
## player state across transitions.

signal era_changed(new_era: int)

# Map era indices to scene paths.
var era_scenes: Dictionary = {
	0: "res://levels/test_era1.tscn",
	1: "res://levels/test_era2.tscn",
}


func _ready() -> void:
	pass


func switch_to_era(era: int) -> void:
	if era < 0 or era >= GameState.era_count:
		return
	if era == GameState.current_era:
		return

	# Save player position before switching.
	var player = _find_player()
	if player:
		GameState.player_position = player.global_position

	GameState.current_era = era
	GameState.mark_era_visited(era)
	era_changed.emit(era)

	# Load the new era's scene.
	if era in era_scenes:
		get_tree().change_scene_to_file(era_scenes[era])


func switch_to_next_era() -> void:
	var next = (GameState.current_era + 1) % GameState.era_count
	switch_to_era(next)


func _find_player() -> Node2D:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0] as Node2D
	return null
