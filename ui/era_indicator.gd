extends CanvasLayer
## Simple HUD overlay showing the current era name and control hints.

@onready var era_label := $EraLabel
@onready var controls_label := $ControlsLabel

var era_names: Dictionary = {
	0: "Era 1 - Ancient",
	1: "Era 2 - Modern",
}


func _ready() -> void:
	EraManager.era_changed.connect(_on_era_changed)
	_update_display(GameState.current_era)


func _on_era_changed(new_era: int) -> void:
	_update_display(new_era)


func _update_display(era: int) -> void:
	if era_label:
		era_label.text = era_names.get(era, "Era %d" % era)
