extends Node2D

var money = 0
var score
@export var enemy_scene: PackedScene
@export var turret_scene: PackedScene  # Reference to the current turret scene
@onready var selection_ui = $Ui/CanvasLayer
@onready var castle = $Castle
@onready var start_game_ui = $StartGameUI
@onready var animation_player = $StartGameUI/AnimationPlayer  # Reference to your AnimationPlayer node

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

# Dictionary to keep track of placed turrets
var placed_turrets = {}

func _ready():
	## Show the start game UI and pause the game
	start_game_ui.show()
	# Start the flashing animation
	animation_player.play("FlashLabel")
	
	score = 0
	
	if $Castle:
		CASTLE_LOCATION_X = $Castle.global_position.x
		CASTLE_LOCATION_Y = $Castle.global_position.y
		
		SPAWN_LEFT = CASTLE_LOCATION_X - (SCREEN_WIDTH / 3)
		SPAWN_RIGHT = CASTLE_LOCATION_X + (SCREEN_WIDTH / 3)
	else:
		print("Error: Castle node not found!")
	
func _unhandled_key_input(event):
	if event.is_pressed() and start_game_ui.visible:
		# Hide the start game UI and unpause the game
		start_game_ui.hide()
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
