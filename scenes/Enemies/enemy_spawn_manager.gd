extends Node

var elapsed_time = 0
var difficulty_threshold = 300  # 5 minutes in seconds

@export var slime_scene: PackedScene
@export var goblin_scene: PackedScene  # Add this once you have a goblin enemy

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
		print("Slime scene", slime_scene)
	else:
		print("Error: Castle node not found!")

func _process(delta):
	elapsed_time += delta

func spawn_random_enemy():
	var enemy_type = choose_enemy_type()
	var position = calculate_spawn_position()
	spawn_enemy(enemy_type, position)

func choose_enemy_type():
	var random = randf()
	var slime_probability = 1.0 - min(elapsed_time / difficulty_threshold, 0.7)
	
	if random < slime_probability:
		return "slime"
	else:
		return "goblin"  # You can add more enemy types and adjust probabilities

func calculate_spawn_position():
	var spawn_left = randf() < 0.5
	var spawn_x = SPAWN_LEFT if spawn_left else SPAWN_RIGHT
	return Vector2(spawn_x, SPAWN_Y)

func spawn_enemy(enemy_type: String, position: Vector2):
	var enemy
	print("Is there slime scene", slime_scene)
	match enemy_type:
		"slime":
			enemy = slime_scene.instantiate()
		"goblin":
			enemy = goblin_scene.instantiate() if goblin_scene else slime_scene.instantiate()
	
	enemy.position = position
	enemy.castle_node = get_parent().get_node("Castle")
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
	
	enemy.connect("slime_killed", Callable(get_parent(), "_on_slime_killed"))
	get_parent().add_child(enemy)
