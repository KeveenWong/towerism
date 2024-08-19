extends Node

class_name Castle

const FLOOR_HEIGHT = 80  # Height of each floor in pixels

class Floor:
	var level: int
	var scene: PackedScene
	var instance: Node = null
	
	func _init(_level: int, _scene: PackedScene):
		level = _level
		scene = _scene

var floors: Dictionary = {}
var current_floor: int = 1
@onready var floor_container = $FloorContainer
@export var floor_scene: PackedScene
@export var castle_top_scene: PackedScene
@export var smoke_effect_scene: PackedScene
var castle_top_instance: Node = null
var initial_setup_complete = false

func _ready():
	# Clear any existing floors and castle top that might be in the scene
	for child in floor_container.get_children():
		child.queue_free()
	
	# Start with one floor
	add_floor(1)
	
	# Add the castle top
	add_castle_top()
	
	initial_setup_complete = true

func add_floor(level: int):
	if level in floors:
		print("Floor ", level, " already exists!")
		return
	
	var new_floor = Floor.new(level, floor_scene)
	floors[level] = new_floor
	
	_instantiate_floor(new_floor)
	update_castle_top_position()

func _instantiate_floor(floor: Floor):
	floor.instance = floor_scene.instantiate()
	floor_container.add_child(floor.instance)
	
	floor.instance.position.y = -(floor.level - 1) * FLOOR_HEIGHT
	
	assert(floor.instance.has_node("PlayerSpawnPoint"), "Floor scene is missing PlayerSpawnPoint!")
	
	# Play smoke effect
	play_smoke_effect(floor.instance.position)
	print("Floor ", floor.level, " position: ", floor.instance.global_position)  # Debug print

func add_castle_top():
	if castle_top_instance:
		castle_top_instance.queue_free()
	
	castle_top_instance = castle_top_scene.instantiate()
	add_child(castle_top_instance)
	update_castle_top_position()
	
	# Play smoke effect for castle top
	play_smoke_effect(Vector2(0, castle_top_instance.position.y - floor_container.position.y))

	
func play_smoke_effect(position: Vector2):
	if smoke_effect_scene:
		var smoke = smoke_effect_scene.instantiate()
		add_child(smoke)
		
		# Calculate global position based on the floor_container's global position
		var global_pos = floor_container.global_position + position
		
		# Adjust for any offset in your smoke effect scene
		var smoke_offset = Vector2(0, -FLOOR_HEIGHT / 2)  # Adjust this if needed
		
		smoke.global_position = global_pos + smoke_offset
		
		print("Smoke effect created at global position: ", smoke.global_position)  # Debug print
		
		if smoke.has_method("start_effect") and initial_setup_complete:
			smoke.start_effect()
		else:
			print("start_effect method not found on smoke effect!")
	else:
		print("Smoke effect scene is not set!")  # Debug print

func update_castle_top_position():
	if castle_top_instance:
		var highest_floor = floors.keys().max()
		var top_position = -(highest_floor * FLOOR_HEIGHT)
		castle_top_instance.position.y = top_position
		print("Floor container global position: ", floor_container.global_position)
		print("Castle top global position: ", castle_top_instance.global_position)

func change_floor(to_level: int) -> bool:
	if to_level not in floors:
		print("Floor ", to_level, " doesn't exist!")
		return false
	
	current_floor = to_level
	return true

func get_floor_center_position(level: int) -> Vector2:
	if level in floors and floors[level].instance:
		var center = floors[level].instance.global_position
		center.y += FLOOR_HEIGHT / 2
		return center
	return Vector2.ZERO

func build_new_floor() -> bool:
	var new_level = floors.keys().max() + 1
	add_floor(new_level)
	print("New floor built at level ", new_level)
	return true

# ... (other functions remain the same)
