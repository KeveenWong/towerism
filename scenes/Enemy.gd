extends CharacterBody2D

signal enemy_killed

func _ready():
	add_to_group("enemies")

func hit():
	emit_signal("enemy_killed")
	queue_free()
