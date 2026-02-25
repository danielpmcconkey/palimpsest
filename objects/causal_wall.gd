extends CausalObject
class_name CausalWall
## A wall/barrier that can be created or destroyed via causal chains.
## Example: collapse a passage in Era 1 -> it's blocked in Era 2.

## If true, the wall EXISTS when the effect is active (cause created a blockage).
## If false, the wall is REMOVED when the effect is active (cause opened a path).
@export var blocks_when_active: bool = true

@onready var collision := $CollisionShape2D if has_node("CollisionShape2D") else null
@onready var sprite := $Sprite2D if has_node("Sprite2D") else null


func _on_effect_active() -> void:
	if blocks_when_active:
		_show_wall()
	else:
		_hide_wall()


func _on_effect_inactive() -> void:
	if blocks_when_active:
		_hide_wall()
	else:
		_show_wall()


func _show_wall() -> void:
	visible = true
	if collision:
		collision.disabled = false


func _hide_wall() -> void:
	visible = false
	if collision:
		collision.disabled = true
