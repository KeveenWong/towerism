extends Node2D

var money = 0
@onready var money_label = $CanvasLayer/MoneyLabel
@onready var enemy = $Enemy

func _ready():
	money_label.text = "Money: $" + str(money)
	enemy.enemy_killed.connect(_on_enemy_killed)

func _on_enemy_killed():
	money += 10
	money_label.text = "Money: $" + str(money)
	print("Enemy killed! Money: $", money)  # Debugging Line
