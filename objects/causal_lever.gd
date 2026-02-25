extends CausalObject
class_name CausalLever
## A simple lever/switch the player can interact with.
## When activated, it triggers a causal effect and changes color
## to indicate it's been pulled.

@onready var sprite := $Sprite2D if has_node("Sprite2D") else null

var activated: bool = false

## Color when the lever is in its default (off) state.
@export var color_off: Color = Color(0.8, 0.6, 0.2, 1.0)

## Color when the lever has been activated.
@export var color_on: Color = Color(0.2, 0.9, 0.3, 1.0)


func _ready() -> void:
	super._ready()
	# Always set up as a cause object.
	is_cause = true
	_update_visual()


func interact() -> void:
	if activated:
		return
	activated = true
	trigger_cause()
	_update_visual()
	print("[CausalLever] Activated: %s (era %d)" % [effect_id, object_era])


func _update_visual() -> void:
	if sprite:
		if activated:
			sprite.self_modulate = color_on
		else:
			sprite.self_modulate = color_off


## If returning to this era and the effect was already triggered,
## show it as activated.
func _apply_causal_state() -> void:
	if effect_id.is_empty():
		return
	if GameState.has_causal_effect(object_era, effect_id):
		activated = true
		_update_visual()
