extends Node2D

var money = 0
var score
@export var enemy_scene: PackedScene
@export var turret_scene: PackedScene  # Reference to the current turret scene
@onready var selection_ui = $Ui/CanvasLayer
@onready var selection_menu = $SelectionMenu
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

# Dictionary to keep track of placed turrets
var placed_turrets = {}

var controlled_turret = null
var current_window_key = ""

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
	
	selection_menu.control_turret_requested.connect(_on_control_turret_requested)
	
func _process(delta):
	if controlled_turret:
		var mouse_pos = get_global_mouse_position()
		var angle_to_mouse = controlled_turret.global_position.angle_to_point(mouse_pos)

		# Limit the rotation based on the side
		if controlled_turret.side == "left":
			angle_to_mouse = fmod(angle_to_mouse + 2*PI, 2*PI)
			angle_to_mouse = clamp(angle_to_mouse, PI/2, 3*PI/2)
		else:  # right side
			angle_to_mouse = clamp(angle_to_mouse, -PI/2, PI/2)
		
		# Set the rotation
		controlled_turret.global_rotation = angle_to_mouse
		
		if Input.is_action_pressed("fire"):
			controlled_turret.shoot()
			
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
			
			turret.side = side

			
			add_child(turret)

			# Add the turret to the placed_turrets dictionary
			if turret:
				window_key = "floor_{0}_{1}".format([castle.current_floor, side])
				placed_turrets[window_key] = turret
				print("added turret on floor ", castle.current_floor)
				print("side is  ", side)
				current_window_key = window_key
			
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


func has_turret_at_window(floor_number: int, side: String) -> bool:
	var window_key = "floor_{0}_{1}".format([floor_number, side])
	return placed_turrets.has(window_key)
	
func show_selection_menu(side: String):
	current_window_key = "floor_{0}_{1}".format([castle.current_floor, side])
	var current_floor = castle.floors[castle.current_floor].instance
	var window: Node2D
	var menu_offset = Vector2(35, -40)  # Adjust this value to change how far from the window the menu appears

	if side == "left":
		window = current_floor.get_node("LeftWindow")
		menu_offset.x = -selection_menu.size.x - menu_offset.x  # Position menu to the left of the window
	elif side == "right":
		window = current_floor.get_node("RightWindow")
		# For right side, we keep the positive x offset

	if window:
		var window_global_pos = window.global_position
		var menu_position = window_global_pos + menu_offset
		
		selection_menu.global_position = menu_position
		selection_menu.display_menu()

func hide_selection_menu():
	selection_menu.close_menu()
	
func _on_control_turret_requested():
	if current_window_key in placed_turrets:
		controlled_turret = placed_turrets[current_window_key]
		$Player.set_controllable(false)

func release_turret_control():
	controlled_turret = null
	$Player.set_controllable(true)
	
func toggle_turret_control():
	if controlled_turret:
		release_turret_control()
	else:
		_on_control_turret_requested()

func _unhandled_input(event):
	if event.is_action_pressed("interact"):
		if controlled_turret:
			toggle_turret_control()
		else:
			$Player.handle_interaction()
