extends StaticBody2D
class_name CausalObject
## Base class for objects whose state is affected by causal chains.
## Place in a level, set the effect_id, and it will check GameState
## on ready to see if a prior-era action should change its state.

## Unique ID for this causal effect. Must match across eras.
@export var effect_id: String = ""

## The era this object belongs to (set automatically by the level).
@export var object_era: int = 0

## If true, this object is the "cause" (player interacts with it).
## If false, this object is the "effect" (state changes based on prior eras).
@export var is_cause: bool = false


func _ready() -> void:
	if not is_cause:
		_apply_causal_state()


func _apply_causal_state() -> void:
	if effect_id.is_empty():
		return

	if GameState.check_propagated_effect(object_era, effect_id):
		_on_effect_active()
	else:
		_on_effect_inactive()


## Override in subclasses to define what happens when the causal effect is active.
func _on_effect_active() -> void:
	pass


## Override in subclasses to define the default (no effect) state.
func _on_effect_inactive() -> void:
	pass


## Call this when the player triggers the cause.
func trigger_cause() -> void:
	GameState.set_causal_effect(object_era, effect_id)


func interact() -> void:
	if is_cause:
		trigger_cause()
