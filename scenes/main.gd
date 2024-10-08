extends Node2D

var scales = 150
var money = 50
var score = 0

@export var slime_scene: PackedScene
@export var turret_scene: PackedScene

@onready var selection_ui = $Ui/CanvasLayer
@onready var selection_menu = $SelectionMenu
@onready var castle = $Castle
@onready var enemy_spawn_manager = $EnemySpawnManager
@onready var HUD = $HUD
@onready var start_game_ui = $StartGameUI
@onready var animation_player = $StartGameUI/AnimationPlayer  # Reference to your AnimationPlayer node

var base_spawn_rate = 5.0  # Start with a 3-second interval
var min_spawn_rate = 0.5  # The minimum spawn interval to cap the frequency
var time_factor = 0.01  # Adjust this value to control how quickly the spawn rate increases
@export var elapsed_time = 0  # Track how long the game has been running

const SCREEN_WIDTH = 1280
const SCREEN_HEIGHT = 720
const AUTO_TURRET_COST = 20

var weapon_types = {
	"Cannon": {
		"scene": preload("res://scenes/Turret/turret.tscn"),
		"cost": 20
	},
	"Crossbow": {
		"scene": preload("res://scenes/Turret/crossbow.tscn"),
		"cost": 15
	},
}

var placed_turrets = {}

var controlled_turret = null
var current_window_key = ""

func _ready():
	## Show the start game UI and pause the game
	start_game_ui.show()
	# Start the flashing animation
	animation_player.play("FlashLabel")
	# Play Music
	$Music.play()
	
	if $Castle:
		enemy_spawn_manager.CASTLE_LOCATION_X = $Castle.global_position.x
		enemy_spawn_manager.CASTLE_LOCATION_Y = $Castle.global_position.y
		enemy_spawn_manager.SPAWN_LEFT = enemy_spawn_manager.CASTLE_LOCATION_X - (SCREEN_WIDTH / 3)
		enemy_spawn_manager.SPAWN_RIGHT = enemy_spawn_manager.CASTLE_LOCATION_X + (SCREEN_WIDTH / 3)
	else:
		print("Error: Castle node not found!")
	
	$EnemyTimer.start(base_spawn_rate)
	$ScoreTimer.start()

	$Castle.floor_build_requested.connect(_on_floor_build_requested)
	selection_menu.control_turret_requested.connect(_on_control_turret_requested)
	selection_menu.make_auto_turret_requested.connect(_on_make_auto_turret_requested)

	HUD.update_scales(scales)
	HUD.update_money(money)
	HUD.update_score(score)

func _unhandled_key_input(event):
	if event.is_pressed() and start_game_ui.visible:
		# Hide the start game UI and unpause the game
		start_game_ui.hide()
		$EnemyTimer.start()
		$ScoreTimer.start()


func _on_enemy_defeated(gold_value: int):
	print("Enemy killed and gained: ", gold_value)
	money += gold_value
	$Hit.play()
	HUD.update_money(money)


func _on_enemy_reached_center(plunder_value: int):
	print("Enemy reached and plundered: ", plunder_value)
	scales -= plunder_value
	HUD.update_scales(scales)
	$LoseScale.play()
		
func _process(delta):
	# Update enemy timer wait time
	elapsed_time += delta
	
	# Gradually reduce the spawn time as the game progresses
	var new_spawn_rate = max(base_spawn_rate - elapsed_time * time_factor, min_spawn_rate)
	$EnemyTimer.wait_time = new_spawn_rate
	
	# Check turret
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
	HUD.update_score(score)

func _on_enemy_timer_timeout() -> void:
	enemy_spawn_manager.spawn_random_enemy()

func show_selection_wheel():
	selection_ui.show_wheel()
	
func hide_selection_wheel():
	selection_ui.hide_wheel()


func _on_floor_build_requested(cost: int):
	if money >= cost:
		money -= cost
		HUD.update_money(money)
		$Castle.add_new_floor_after_payment()
		print("New floor built. Remaining money: ", money)
	else:
		print("Not enough money to build a new floor. Cost: ", cost, ", Available: ", money)


func place_turret(turret_type: String, side: String):
	if not weapon_types.has(turret_type):
		print("Error: Turret type '" + turret_type + "' not found.")
		return

	var turret_data = weapon_types[turret_type]
	var turret_cost = turret_data["cost"]
	
	if money >= turret_cost:
		var turret_scene_to_use = turret_data["scene"]
		
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

			$Build.play()
			add_child(turret)

			# Add the turret to the placed_turrets dictionary
			if turret:
				window_key = "floor_{0}_{1}".format([castle.current_floor, side])
				placed_turrets[window_key] = turret
				print("added turret on floor ", castle.current_floor)
				print("side is  ", side)
				current_window_key = window_key
			
			money -= turret_cost
			HUD.update_money(money)
			print("Placing turret: " + turret_type + " at position: " + str(window_position) + ". Cost: " + str(turret_cost))
		else:
			print("Error: Turret scene not found for type '" + turret_type + "'.")
	else:
		print("Not enough money to place turret. Cost: " + str(turret_cost) + ", Available: " + str(money))

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
		
	# Update the menu options based on the turret's current state
		if current_window_key in placed_turrets:
			var turret = placed_turrets[current_window_key]
			selection_menu.update_auto_button_text(turret.is_auto)

func hide_selection_menu():
	selection_menu.close_menu()
	
func _on_control_turret_requested():
	if current_window_key in placed_turrets:
		controlled_turret = placed_turrets[current_window_key]
		controlled_turret.set_player_control(true)
		$Player.set_controllable(false)

func release_turret_control():
	if controlled_turret:
		controlled_turret.set_player_control(false)
	controlled_turret = null
	$Player.set_controllable(true)
	

func _unhandled_input(event):
	if event.is_action_pressed("interact"):
		if controlled_turret:
			toggle_turret_control()
		else:
			$Player.handle_interaction()
			

func _on_make_auto_turret_requested():
	if current_window_key in placed_turrets:
		var turret = placed_turrets[current_window_key]
		if not turret.is_auto:
			if money >= AUTO_TURRET_COST:
				money -= AUTO_TURRET_COST
				turret.set_auto(true)
				HUD.update_money(money)
				print("Turret set to auto mode. Remaining money: ", money)
			else:
				print("Not enough money to set turret to auto mode. Cost: ", AUTO_TURRET_COST, ", Available: ", money)
		else:
			print("Turret is already in auto mode")
		selection_menu.update_auto_button_text(turret.is_auto)
	else:
		print("No turret found at the current window")

func toggle_turret_control():
	if controlled_turret:
		release_turret_control()
	else:
		_on_control_turret_requested()
