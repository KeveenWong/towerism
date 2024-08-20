extends Node

class_name HealthComponent

signal health_depleted
signal health_changed(new_health: int)

@export var max_health: int
@export var current_health: int

func _ready():
	current_health = max_health

func take_damage(amount: int):
	print("Curent health before: ", current_health)
	current_health = max(0, current_health - amount)
	emit_signal("health_changed", current_health)
	print("Damage amount: ", amount)
	print("Current health: ", current_health)
	if current_health == 0:
		emit_signal("health_depleted")

func heal(amount: int):
	current_health = min(max_health, current_health + amount)
	emit_signal("health_changed", current_health)

func get_health() -> int:
	return current_health
