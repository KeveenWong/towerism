extends Node2D

var money = 0
var score
@export var enemy_scene: PackedScene
@export var turret_scene: PackedScene  # Reference to the current turret scene
@onready var selection_ui = $Ui/CanvasLayer
@onready var castle = $Castle

var CASTLE_LOCATION_X: float
var CASTLE_LOCATION_Y: float
const SCREEN_WIDTH = 1280
const SCREEN_HEIGHT = 720
var SPAWN_LEFT: float
var SPAWN_RIGHT: float
const SPAWN_Y = 0

# Dictionary to store different turret types (for future use)
var turret_types = {
	"Cannon": preload("res://scenes/Turret/turret.tscn"),
	# Add more turret types here in the future
	# "Crossbow": preload("res://scenes/Turret/crossbow.tscn"),
}

func _ready():
	score = 0
	
	if $Castle:
		CASTLE_LOCATION_X = $Castle.global_position.x
		CASTLE_LOCATION_Y = $Castle.global_position.y
		
		SPAWN_LEFT = CASTLE_LOCATION_X - (SCREEN_WIDTH / 3)
		SPAWN_RIGHT = CASTLE_LOCATION_X + (SCREEN_WIDTH / 3)
	else:
		print("Error: Castle node not found!")
	
	$EnemyTimer.start()

func _on_enemy_killed():
	pass

func _on_score_timer_timeout() -> void:
	score += 1

func _on_enemy_timer_timeout() -> void:
	var enemy = enemy_scene.instantiate()
	
	enemy.castle_node = $Castle
	
	var spawn_left = randf() < 0.5
	var spawn_x = SPAWN_LEFT if spawn_left else SPAWN_RIGHT
	
	enemy.position = Vector2(spawn_x, SPAWN_Y)
	enemy.initial_x_direction = 1 if spawn_left else -1
	
	enemy.connect("enemy_killed", _on_enemy_killed)
	add_child(enemy)

func show_selection_wheel():
	selection_ui.show_wheel()
	
func hide_selection_wheel():
	selection_ui.hide_wheel()

func place_turret(turret_type: String, side: String):
	var turret_cost = 0  # Set the cost of the turret
	
	if money >= turret_cost:
		var turret_scene_to_use = turret_types.get(turret_type, turret_scene)
		
		if turret_scene_to_use:
			var current_floor = $Castle.floors[castle.current_floor].instance
			var window: Area2D
			var window_position: Vector2
			
			if side == "left":
				window = current_floor.get_node("LeftWindow")
			elif side == "right":
				window = current_floor.get_node("RightWindow")
			else:
				print("Error: Invalid side specified for turret placement.")
				return
			
			# Get the global position of the Area2D (window) itself
			window_position = window.global_position
			window_position.y = window_position.y + 150
			var turret = turret_scene_to_use.instantiate()
			turret.global_position = window_position
			
			if side == "left":
				turret.scale.y = -1
			add_child(turret)
			
			money -= turret_cost
			print("Placing turret: " + turret_type + " at position: " + str(window_position))
		else:
			print("Error: Turret type '" + turret_type + "' not found.")
	else:
		print("Not enough money to place turret.")
