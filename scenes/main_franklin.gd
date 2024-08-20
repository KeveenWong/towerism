extends Node2D

var scales = 150
var money = 20
var score = 0

@export var slime_scene: PackedScene
@export var turret_scene: PackedScene

@onready var selection_ui = $Ui/CanvasLayer
@onready var castle = $Castle
@onready var enemy_spawn_manager = $EnemySpawnManager
@onready var HUD = $HUD

const SCREEN_WIDTH = 1280
const SCREEN_HEIGHT = 720

var turret_types = {
	"Cannon": preload("res://scenes/Turret/turret.tscn"),
	# Add more turret types here in the future
}

var placed_turrets = {}

func _ready():
	if $Castle:
		enemy_spawn_manager.CASTLE_LOCATION_X = $Castle.global_position.x
		enemy_spawn_manager.CASTLE_LOCATION_Y = $Castle.global_position.y
		enemy_spawn_manager.SPAWN_LEFT = enemy_spawn_manager.CASTLE_LOCATION_X - (SCREEN_WIDTH / 3)
		enemy_spawn_manager.SPAWN_RIGHT = enemy_spawn_manager.CASTLE_LOCATION_X + (SCREEN_WIDTH / 3)
	else:
		print("Error: Castle node not found!")
	
	$EnemyTimer.start()
	$ScoreTimer.start()
	HUD.update_scales(scales)
	HUD.update_money(money)
	HUD.update_score(score)

func _on_enemy_defeated(gold_value: int):
	print("Enemy killed and gained: ", gold_value)
	money += gold_value
	HUD.update_money(money)


func _on_enemy_reached_center(plunder_value: int):
	print("Enemy reached and plundered: ", plunder_value)
	scales -= plunder_value
	HUD.update_scales(scales)

func _on_score_timer_timeout() -> void:
	score += 1
	HUD.update_score(score)

func _on_enemy_timer_timeout() -> void:
	enemy_spawn_manager.spawn_random_enemy()

func show_selection_wheel():
	selection_ui.show_wheel()
	
func hide_selection_wheel():
	selection_ui.hide_wheel()

func place_turret(turret_type: String, side: String):
	var turret_cost = 10  # Set the cost of the turret
	
	if money >= turret_cost:
		var turret_scene_to_use = turret_types.get(turret_type, turret_scene)
		
		if turret_scene_to_use:
			var current_floor = castle.floors[castle.current_floor].instance
			var window: Area2D
			var window_key: String
			
			if side == "left":
				window = current_floor.get_node("LeftWindow")
				window_key = "floor_{0}_left".format([castle.current_floor])
			elif side == "right":
				window = current_floor.get_node("RightWindow")
				window_key = "floor_{0}_right".format([castle.current_floor])
			else:
				print("Error: Invalid side specified for turret placement.")
				return
			
			# Check if a turret already exists at this window
			if placed_turrets.has(window_key):
				print("Error: A turret already exists at this window.")
				return
			
			# Get the global position of the Area2D (window) itself
			var window_position = window.global_position
			window_position.y += 150
			var turret = turret_scene_to_use.instantiate()
			turret.global_position = window_position
			
			if side == "left":
				turret.scale.y = -1
			
			add_child(turret)
			
			# Add the turret to the placed_turrets dictionary
			placed_turrets[window_key] = turret
			
			money -= turret_cost
			HUD.update_money(money)
			print("Placing turret: " + turret_type + " at position: " + str(window_position))
		else:
			print("Error: Turret type '" + turret_type + "' not found.")
	else:
		print("Not enough money to place turret.")

# Function to remove a turret (if needed in the future)
func remove_turret(floor_number: int, side: String):
	var window_key = "floor_{0}_{1}".format([floor_number, side])
	if placed_turrets.has(window_key):
		var turret = placed_turrets[window_key]
		turret.queue_free()
		placed_turrets.erase(window_key)
		print("Turret removed from floor {0}, {1} side".format([floor_number, side]))
	else:
		print("No turret found at floor {0}, {1} side".format([floor_number, side]))
