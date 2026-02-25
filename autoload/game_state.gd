extends Node
## Persistent game state that survives scene transitions.
## Tracks causal chain effects: what the player did in each era
## that should propagate to later eras.

# Dictionary of causal effects keyed by era index.
# Each entry is a dict of effect_id -> bool (or value).
# Example: { 0: { "blocked_passage_A": true }, 1: {} }
var causal_effects: Dictionary = {}

# Current era the player is in (0-indexed).
var current_era: int = 0

# Total number of eras available in this prototype.
var era_count: int = 2

# Player position to restore after era switch.
var player_position: Vector2 = Vector2.ZERO

# Track which eras the player has visited.
var visited_eras: Dictionary = {}


func _ready() -> void:
	for i in range(era_count):
		causal_effects[i] = {}
		visited_eras[i] = false


func set_causal_effect(era: int, effect_id: String, value: Variant = true) -> void:
	if era not in causal_effects:
		causal_effects[era] = {}
	causal_effects[era][effect_id] = value


func get_causal_effect(era: int, effect_id: String, default: Variant = false) -> Variant:
	if era not in causal_effects:
		return default
	return causal_effects[era].get(effect_id, default)


func has_causal_effect(era: int, effect_id: String) -> bool:
	if era not in causal_effects:
		return false
	return effect_id in causal_effects[era]


## Check if an effect set in an earlier era should propagate to the given era.
## Effects propagate forward in time: if you block a door in era 0, it's blocked
## in era 1. This checks all eras <= the given era for the effect.
func check_propagated_effect(up_to_era: int, effect_id: String) -> bool:
	for era in range(up_to_era + 1):
		if has_causal_effect(era, effect_id):
			return true
	return false


func mark_era_visited(era: int) -> void:
	visited_eras[era] = true


func reset() -> void:
	for i in range(era_count):
		causal_effects[i] = {}
		visited_eras[i] = false
	current_era = 0
	player_position = Vector2.ZERO
