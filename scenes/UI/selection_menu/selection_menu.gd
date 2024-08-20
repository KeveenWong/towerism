extends Node2D

signal make_auto_turret_requested
signal control_turret_requested
@onready var panel: Panel = $Panel
var size: Vector2

func _ready():
	panel.visible = false
	size = panel.size

func display_menu():
	print('displaying')
	panel.visible = true

func close_menu():
	panel.visible = false

func _on_upgrade_pressed() -> void:
	print("Upgrade selected")
	close_menu()

func _on_control_pressed() -> void:
	print("Control selected")
	emit_signal("control_turret_requested")
	close_menu()

func _on_make_auto_pressed() -> void:
	print("Make Auto selected")
	emit_signal("make_auto_turret_requested")
	close_menu()
	
func update_auto_button_text(is_auto: bool):
	var auto_button = $Panel/MakeAuto
	if is_auto:
		auto_button.text = "Auto"
	else:
		auto_button.text = "Make Auto"
