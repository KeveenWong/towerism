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
@onready var castle_top_instance: Node = $CastleTop

func _ready():
	# Initialize floors from existing children
	for child in floor_container.get_children():
		var level = int(abs(child.position.y / FLOOR_HEIGHT)) + 1
		var floor = Floor.new(level, floor_scene)
		floor.instance = child
		floors[level] = floor
	
	# If no floors exist, add one
	if floors.is_empty():
		add_floor(1)
	
	# Ensure castle top exists
	if not castle_top_instance:
		add_castle_top()
	else:
		update_castle_top_position()

func add_floor(level: int):
	if level in floors:
		print("Floor ", level, " already exists!")
		return
	
	var new_floor = Floor.new(level, floor_scene)
	floors[level] = new_floor
	
	instantiate_floor(new_floor)
	update_castle_top_position()

func instantiate_floor(floor: Floor):
	if not floor.instance:
		floor.instance = floor_scene.instantiate()
		floor_container.add_child(floor.instance)
	
	floor.instance.position.y = -(floor.level - 1) * FLOOR_HEIGHT
	
	assert(floor.instance.has_node("PlayerSpawnPoint"), "Floor scene is missing PlayerSpawnPoint!")

func add_castle_top():
	if not castle_top_instance:
		castle_top_instance = castle_top_scene.instantiate()
		add_child(castle_top_instance)
	update_castle_top_position()

func update_castle_top_position():
	if castle_top_instance:
		var highest_floor = floors.keys().max()
		var top_position = -(highest_floor * FLOOR_HEIGHT)
		castle_top_instance.position.y = top_position
		print("Castle top position updated to: ", castle_top_instance.position)

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
	
func get_castle_top_floor_position() -> float:
	var highest_floor = floors.keys().max()
	
	# Access the floor instance of the highest floor
	var floor_instance = floors[highest_floor].instance
	
	if floor_instance:
		# Return the y position of the highest floor instance
		return floor_instance.position.y
	else:
		return 0.0

# ... (other functions remain the same)

#extends Node
#
#class_name Castle
#
#const FLOOR_HEIGHT = 80  # Height of each floor in pixels
#
#class Floor:
	#var level: int
	#var scene: PackedScene
	#var instance: Node = null
	#
	#func _init(_level: int, _scene: PackedScene):
		#level = _level
		#scene = _scene
#
#var floors: Dictionary = {}
#var current_floor: int = 1
#@onready var floor_container = $FloorContainer
#@export var floor_scene: PackedScene
#@export var castle_top_scene: PackedScene
#var castle_top_instance: Node = null
#
#func _ready():
	## Clear any existing floors and castle top that might be in the scene
	#for child in floor_container.get_children():
		#child.queue_free()
	#
	## Start with one floor
	#add_floor(1)
	#
	## Add the castle top
	#add_castle_top()
#
#func add_floor(level: int):
	#if level in floors:
		#print("Floor ", level, " already exists!")
		#return
	#
	#var new_floor = Floor.new(level, floor_scene)
	#floors[level] = new_floor
	#
	#_instantiate_floor(new_floor)
	#update_castle_top_position()
#
#func _instantiate_floor(floor: Floor):
	#floor.instance = floor_scene.instantiate()
	#floor_container.add_child(floor.instance)
	#
	#floor.instance.position.y = -(floor.level - 1) * FLOOR_HEIGHT
	#
	#assert(floor.instance.has_node("PlayerSpawnPoint"), "Floor scene is missing PlayerSpawnPoint!")
#
#func add_castle_top():
	#if castle_top_instance:
		#castle_top_instance.queue_free()
	#
	#castle_top_instance = castle_top_scene.instantiate()
	#add_child(castle_top_instance)
	#update_castle_top_position()
#
#func update_castle_top_position():
	#if castle_top_instance:
		#var highest_floor = floors.keys().max()
		#var top_position = -(highest_floor * FLOOR_HEIGHT)
		#castle_top_instance.position.y = top_position
		#print("Castle top position updated to: ", castle_top_instance.position)
#
#func change_floor(to_level: int) -> bool:
	#if to_level not in floors:
		#print("Floor ", to_level, " doesn't exist!")
		#return false
	#
	#current_floor = to_level
	#return true
#
#func get_floor_center_position(level: int) -> Vector2:
	#if level in floors and floors[level].instance:
		#var center = floors[level].instance.global_position
		#center.y += FLOOR_HEIGHT / 2
		#return center
	#return Vector2.ZERO
#
#func build_new_floor() -> bool:
	#var new_level = floors.keys().max() + 1
	#add_floor(new_level)
	#print("New floor built at level ", new_level)
	#return true
#
## ... (other functions remain the same)
