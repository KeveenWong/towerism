extends Node

class_name Castle

# A single floor in the castle
class Floor:
	var level: int
	var scene: PackedScene
	var instance: Node = null
	
	func _init(_level: int, _scene: PackedScene):
		level = _level
		scene = _scene

# Castle properties
var floors: Dictionary = {}
var current_floor: int = 1
@onready var floor_container = $FloorContainer

# Floor scene preload
@export var floor_scene: PackedScene

func _ready():
	add_floor(1)  # Start with one floor

func add_floor(level: int):
	if level in floors:
		print("Floor ", level, " already exists!")
		return
	
	var new_floor = Floor.new(level, floor_scene)
	floors[level] = new_floor
	
	if level == current_floor:
		_instantiate_floor(new_floor)

func remove_floor(level: int):
	if level not in floors:
		print("Floor ", level, " doesn't exist!")
		return
	
	if floors[level].instance:
		floors[level].instance.queue_free()
	
	floors.erase(level)

func change_floor(to_level: int):
	if to_level not in floors:
		print("Floor ", to_level, " doesn't exist!")
		return
	
	if floors[current_floor].instance:
		floors[current_floor].instance.queue_free()
	
	current_floor = to_level
	_instantiate_floor(floors[current_floor])

func _instantiate_floor(floor: Floor):
	floor.instance = floor.scene.instantiate()
	floor_container.add_child(floor.instance)
	
	# You might want to set the player's position here
	# For example:
	# $Player.global_position = floor.instance.get_node("PlayerSpawnPoint").global_position

# Helper functions for player movement
func move_up():
	change_floor(current_floor + 1)

func move_down():
	change_floor(current_floor - 1)

# Function to build a new floor
func build_new_floor():
	var new_level = floors.keys().max() + 1
	add_floor(new_level)
	print("New floor built at level ", new_level)
