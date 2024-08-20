extends Node2D

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
	close_menu()
