extends Node

var elapsed_time = 0
var difficulty_threshold = 300  # 5 minutes in seconds

@export var slime_scene: PackedScene
@export var bat_scene: PackedScene 

var CASTLE_LOCATION_X: float
var CASTLE_LOCATION_Y: float
var SPAWN_LEFT: float
var SPAWN_RIGHT: float
const SPAWN_Y = 0

func _ready():
	if get_parent().has_node("Castle"):
		var castle = get_parent().get_node("Castle")
		CASTLE_LOCATION_X = castle.global_position.x
		CASTLE_LOCATION_Y = castle.global_position.y
		
		SPAWN_LEFT = CASTLE_LOCATION_X - (1280 / 3)  # Assuming 1280 is your screen width
		SPAWN_RIGHT = CASTLE_LOCATION_X + (1280 / 3)
	else:
		print("Error: Castle node not found!")

func _process(delta):
	elapsed_time += delta

func spawn_random_enemy():
	var enemy_type = choose_enemy_type()
	var position = calculate_spawn_position(enemy_type)
	spawn_enemy(enemy_type, position)

func choose_enemy_type():
	var random = randf()
	var slime_probability = 1.0 - min(elapsed_time / difficulty_threshold, 0.7)
	
	if random < slime_probability:
		return "slime"
	else:
		return "bat"  # You can add more enemy types and adjust probabilities

func calculate_spawn_position(enemy_type):
	var spawn_left = randf() < 0.5
	var spawn_x = SPAWN_LEFT if spawn_left else SPAWN_RIGHT
	if enemy_type == "bat":
		var spawn_y = randf_range(SPAWN_Y - 500, SPAWN_Y - 250)
		return Vector2(spawn_x, spawn_y)
	else:
		return Vector2(spawn_x, SPAWN_Y)

func spawn_enemy(enemy_type: String, position: Vector2):
	var enemy
	match enemy_type:
		"slime":
			enemy = slime_scene.instantiate()
		"bat":
			enemy = bat_scene.instantiate()
			# TODO: Add signal
	
	enemy.position = position
	enemy.castle_node = get_parent().get_node("Castle")
	
	if enemy_type == "slime":
		enemy.initial_x_direction = 1 if position.x < CASTLE_LOCATION_X else -1
	
		# Add randomness to speeds
		var velocity_component = enemy.get_node("VelocityComponent")
		
		var base_speed_x = enemy.get_speeds()[0]
		var base_speed_y = enemy.get_speeds()[1]
		var speed_variation = base_speed_x * 0.05  # 5% variation for x
		var actual_speed_x = base_speed_x + randf_range(-speed_variation, speed_variation)

		speed_variation = base_speed_y * 0.05  # 5% variation for y
		var actual_speed_y = base_speed_y + randf_range(-speed_variation, speed_variation)

		velocity_component.set_speeds(actual_speed_x, actual_speed_y)
	
	enemy.connect("enemy_defeated", Callable(get_parent(), "_on_enemy_defeated"))
	enemy.connect("enemy_reached_center", Callable(get_parent(), "_on_enemy_reached_center"))
	get_parent().add_child(enemy)
